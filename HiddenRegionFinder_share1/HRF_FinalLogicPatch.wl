(* HRF_FinalLogicPatch.wl
   Final reporting logic patch for Example 01.
   - Do not equate zero Superleading remainder with absence of an obstruction record.
   - Treat exact reduction (Superleading == 0) as a hidden-region-identifying cancellation, even though no LP scaling vector is needed/reported.
*)

ClearAll[hrfObstructionFoundQ, hrfExactReductionQ, hrfCoverageData, hrfHiddenSummaryRow, hrfGeneratorUseRemainder];

hrfGeneratorUseRemainder[scan_] := Module[{use},
  use = If[AssociationQ[scan], Lookup[scan, "GeneratorUseData", <||>], <||>];
  If[AssociationQ[use], Lookup[use, "Remainder", Missing["NotAvailable"]], Missing["NotAvailable"]]
];

hrfObstructionFoundQ[scan_] := Module[{od},
  od = If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing["NoScan"]], Missing["NoScan"]];
  AssociationQ[od] && KeyExistsQ[od, "Superleading"]
];

hrfExactReductionQ[scan_] := Module[{od, sl},
  od = If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing["NoScan"]], Missing["NoScan"]];
  If[!(AssociationQ[od] && KeyExistsQ[od, "Superleading"]), Return[False]];
  sl = od["Superleading"];
  TrueQ[Expand[sl] === 0]
];

hrfCoverageData[scan_, U_, activeVars_, maxAbs_:5, fObs_:None] := Module[{od},
  If[! hrfObstructionFoundQ[scan], Return[Missing["NoObstructionFound"]]];
  If[hrfExactReductionQ[scan],
    Return[<|
      "Scaling" -> Missing["ExactReductionNoScalingNeeded"],
      "CandidateGenerationMethod" -> "ExactReduction",
      "CandidateCount" -> 0,
      "AcceptedCount" -> 0,
      "UniqueAcceptedScalingQ" -> Missing["NotApplicable"],
      "SelectedCandidateDiagnostic" -> <||>,
      "Status" -> "Exact superleading reduction; no nonzero F_SL passed to scaling finder"
    |>]
  ];
  od = scan["ObstructionData"];
  hrfNotebookTimed["findCoverageLPScaling vars=" <> ToString[Length[activeVars]], findCoverageLPScaling[od["Superleading"], Expand[U], activeVars, maxAbs, fObs]]
];

hrfHiddenSummaryRow[label_, configuration_, zeroVars_, activeVars_, scan_, scaling_:Automatic] := Module[
  {sc = hrfScalingAssoc[scaling], diag, hiddenQ, exactQ, admQ, hasGeneratorsQ,
   isInteriorQ, isBoundaryQ, gens, rem},
  diag = hrfSelectedDiagnostic[sc];
  exactQ = hrfExactReductionQ[scan];
  gens = Lookup[If[AssociationQ[scan], scan, <||>], "Generators", {}];
  hasGeneratorsQ = ListQ[gens] && Length[gens] > 0;
  admQ = TrueQ[Lookup[If[AssociationQ[scan], scan, <||>], "AdmissibleGeneratorSetQ", False]];
  isInteriorQ = TrueQ[zeroVars === {}] || StringContainsQ[ToString[configuration], "Interior"];
  isBoundaryQ = ! isInteriorQ;
  rem = hrfGeneratorUseRemainder[scan];

  (* Reporting convention:
     - Interior: an admissible generator set with an obstruction record identifies the Crown-type hidden region.
       Exact reduction/remainder zero is a successful division, not a failure.
     - Boundary: exact reduction alone is not enough to declare a hidden region; require a genuine accepted scaling.
  *)
  hiddenQ = hrfObstructionFoundQ[scan] && admQ && hasGeneratorsQ &&
    If[isBoundaryQ,
      hrfCoverageFoundQ[sc],
      (hrfCoverageFoundQ[sc] || exactQ || TrueQ[Expand[rem] === 0])
    ];

  <|
    "Case" -> label,
    "Hidden region identified?" -> If[hiddenQ, "Yes", "No"],
    "Configuration" -> configuration,
    "Boundary variables set to zero" -> hrfCompact[zeroVars],
    "Generators" -> hrfCompact[gens],
    "Generator set admissible?" -> admQ,
    "W_SL" -> If[exactQ, "exact reduction", hrfWeight[diag, "WSL", "FSLWeight"]],
    "W_HR" -> If[exactQ, "exact reduction", hrfWeight[diag, "WHR", "PostCancellationLeadingWeight"]],
    "Variables at W_SL" -> hrfCompact[Lookup[diag, "VariablesCoveredByFSLAtWSL", Missing["NotAvailable"]]],
    "Variables at W_HR" -> hrfCompact[Lookup[diag, "VariablesInPostCancellationLeadingSupport", Missing["NotAvailable"]]],
    "Scaling vector" -> hrfCompact[Lookup[sc, "Scaling", Missing["NotAvailable"]]],
    "Variable scaling" -> hrfCompact[Lookup[diag, "VariableScaling", Missing["NotAvailable"]]],
    "Accepted scaling count" -> Lookup[sc, "AcceptedCount", Missing["NotAvailable"]],
    "Unique accepted scaling?" -> Lookup[sc, "UniqueAcceptedScalingQ", Missing["NotAvailable"]],
    "Candidate count" -> Lookup[sc, "CandidateCount", Missing["NotAvailable"]],
    "Comment" -> Which[
      hiddenQ && isInteriorQ && exactQ, "interior hidden region: admissible generators give exact reduction",
      hiddenQ && TrueQ[Lookup[sc, "UniqueAcceptedScalingQ", False]], "unique accepted scaling found",
      hiddenQ, "hidden-region criteria satisfied; inspect accepted diagnostics for possible non-uniqueness",
      ! hrfObstructionFoundQ[scan], "no obstruction record produced by the obstruction scan",
      ! hasGeneratorsQ, "no generators reported by the obstruction scan",
      ! admQ, "no admissible generator set survived the scan",
      isBoundaryQ && exactQ, "boundary exact reduction only; not by itself counted as a hidden region",
      isBoundaryQ && ! hrfCoverageFoundQ[sc], "boundary scan found no accepted coverage scaling",
      ! hrfCoverageFoundQ[sc], "superleading sector found, but no accepted coverage scaling in this test",
      True, "not available"
    ]
  |>
];

(* HRF reporting/scaling patch: use the unreduced Complement as the displayed/scaled
   superleading sector when PolynomialReduce gives Superleading -> 0.  This keeps
   exact reduction as successful but still reports W_SL, W_HR, scaling vectors,
   and variable supports. *)

ClearAll[hrfEffectiveSuperleadingSector, hrfEffectiveSuperleadingSource,
  hrfObstructionFoundQ, hrfCoverageData, hrfHiddenSummaryRow, hrfScanRow];

hrfEffectiveSuperleadingSector[scan_] := Module[{od, sl, comp},
  od = If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing["NoScan"]], Missing["NoScan"]];
  If[! AssociationQ[od], Return[Missing["NoObstructionData"]]];
  sl = Lookup[od, "Superleading", Missing["NoSuperleading"]];
  comp = Lookup[od, "Complement", Missing["NoComplement"]];
  Which[
    ! MatchQ[comp, _Missing] && ! TrueQ[Expand[comp] === 0], comp,
    ! MatchQ[sl, _Missing], sl,
    True, Missing["NoSuperleadingSector"]
  ]
];

hrfEffectiveSuperleadingSource[scan_] := Module[{od, sl, comp},
  od = If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing["NoScan"]], Missing["NoScan"]];
  If[! AssociationQ[od], Return[Missing["NoObstructionData"]]];
  sl = Lookup[od, "Superleading", Missing["NoSuperleading"]];
  comp = Lookup[od, "Complement", Missing["NoComplement"]];
  Which[
    ! MatchQ[comp, _Missing] && ! TrueQ[Expand[comp] === 0], "Complement/unreduced superleading sector",
    ! MatchQ[sl, _Missing], "Superleading/remainder sector",
    True, Missing["NoSuperleadingSector"]
  ]
];

hrfObstructionFoundQ[scan_] := Module[{od},
  od = If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing["NoScan"]], Missing["NoScan"]];
  AssociationQ[od] && (KeyExistsQ[od, "Superleading"] || KeyExistsQ[od, "Complement"])
];

hrfCoverageData[scan_, U_, activeVars_, maxAbs_:5, fObs_:None] := Module[{fsl},
  If[! hrfObstructionFoundQ[scan], Return[Missing["NoObstructionFound"]]];
  fsl = hrfEffectiveSuperleadingSector[scan];
  If[MatchQ[fsl, _Missing] || TrueQ[Expand[fsl] === 0],
    Return[Missing["NoNonzeroSuperleadingSector"]]
  ];
  hrfNotebookTimed["findCoverageLPScaling vars=" <> ToString[Length[activeVars]],
    findCoverageLPScaling[fsl, Expand[U], activeVars, maxAbs, fObs]
  ]
];

hrfHiddenSummaryRow[label_, configuration_, zeroVars_, activeVars_, scan_, scaling_:Automatic] := Module[
  {sc = hrfScalingAssoc[scaling], diag, hiddenQ, exactQ, admQ, hasGeneratorsQ,
   isInteriorQ, isBoundaryQ, gens, rem, fsl, fslSource},
  diag = hrfSelectedDiagnostic[sc];
  exactQ = hrfExactReductionQ[scan];
  gens = Lookup[If[AssociationQ[scan], scan, <||>], "Generators", {}];
  hasGeneratorsQ = ListQ[gens] && Length[gens] > 0;
  admQ = TrueQ[Lookup[If[AssociationQ[scan], scan, <||>], "AdmissibleGeneratorSetQ", False]];
  isInteriorQ = TrueQ[zeroVars === {}] || StringContainsQ[ToString[configuration], "Interior"];
  isBoundaryQ = ! isInteriorQ;
  rem = hrfGeneratorUseRemainder[scan];
  fsl = hrfEffectiveSuperleadingSector[scan];
  fslSource = hrfEffectiveSuperleadingSource[scan];

  (* A hidden-region claim now requires the scaling/coverage test, except that
     the Crown-like interior exact-reduction case is still accepted if the raw
     obstruction data are present and the generators are admissible. *)
  hiddenQ = hrfObstructionFoundQ[scan] && admQ && hasGeneratorsQ &&
    If[isBoundaryQ,
      hrfCoverageFoundQ[sc],
      (hrfCoverageFoundQ[sc] || exactQ || TrueQ[Expand[rem] === 0])
    ];

  <|
    "Case" -> label,
    "Hidden region identified?" -> If[hiddenQ, "Yes", "No"],
    "Configuration" -> configuration,
    "Boundary variables set to zero" -> hrfCompact[zeroVars],
    "Generators" -> hrfCompact[gens],
    "Generator set admissible?" -> admQ,
    "Superleading sector used for scaling" -> hrfFactorOrDash[fsl],
    "Superleading sector source" -> hrfCompact[fslSource],
    "W_SL" -> hrfWeight[diag, "WSL", "FSLWeight"],
    "W_HR" -> hrfWeight[diag, "WHR", "PostCancellationLeadingWeight"],
    "Variables at W_SL" -> hrfCompact[Lookup[diag, "VariablesCoveredByFSLAtWSL", Missing["NotAvailable"]]],
    "Variables at W_HR" -> hrfCompact[Lookup[diag, "VariablesInPostCancellationLeadingSupport", Missing["NotAvailable"]]],
    "Scaling vector" -> hrfCompact[Lookup[sc, "Scaling", Missing["NotAvailable"]]],
    "Variable scaling" -> hrfCompact[Lookup[diag, "VariableScaling", Missing["NotAvailable"]]],
    "Accepted scaling count" -> Lookup[sc, "AcceptedCount", Missing["NotAvailable"]],
    "Unique accepted scaling?" -> Lookup[sc, "UniqueAcceptedScalingQ", Missing["NotAvailable"]],
    "Candidate count" -> Lookup[sc, "CandidateCount", Missing["NotAvailable"]],
    "Comment" -> Which[
      hiddenQ && hrfCoverageFoundQ[sc] && TrueQ[Lookup[sc, "UniqueAcceptedScalingQ", False]], "unique accepted scaling found",
      hiddenQ && hrfCoverageFoundQ[sc], "accepted scaling found; inspect diagnostics for possible non-uniqueness",
      hiddenQ && isInteriorQ && exactQ, "interior exact reduction by admissible generators; scaling data may be diagnostic",
      ! hrfObstructionFoundQ[scan], "no obstruction record produced by the obstruction scan",
      ! hasGeneratorsQ, "no generators reported by the obstruction scan",
      ! admQ, "no admissible generator set survived the scan",
      isBoundaryQ && ! hrfCoverageFoundQ[sc], "boundary scan found no accepted coverage scaling",
      ! hrfCoverageFoundQ[sc], "no accepted coverage scaling in this test",
      True, "not available"
    ]
  |>
];

hrfScanRow[label_, region_, zeroVars_, activeVars_, scan_, generatorCheck_: Missing["NotComputed"]] := Module[
  {od, use, sl, rem, fsl, fslSource},
  od = If[AssociationQ[scan] && AssociationQ[Lookup[scan, "ObstructionData", Missing[]]], scan["ObstructionData"], <||>];
  use = hrfUseData[scan];
  sl = Lookup[od, "Superleading", Missing["Absent"]];
  fsl = hrfEffectiveSuperleadingSector[scan];
  fslSource = hrfEffectiveSuperleadingSource[scan];
  rem = If[ListQ[generatorCheck] && Length[generatorCheck] >= 2, generatorCheck[[2]], Lookup[use, "Remainder", generatorCheck]];
  <|
    "Case" -> label,
    "Region" -> region,
    "Status" -> hrfStatus[scan],
    "Zero variables" -> hrfCompact[zeroVars],
    "Region vector" -> hrfCompact[activeVars],
    "Cancellation factors" -> hrfCompact[If[AssociationQ[scan], Lookup[scan, "CancellationFactors", Missing["Absent"]], Missing["NoScan"]]],
    "Generators" -> hrfCompact[If[AssociationQ[scan], Factor /@ Lookup[scan, "Generators", {}], Missing["NoScan"]]],
    "Generator factors" -> hrfCompact[If[AssociationQ[scan], Lookup[scan, "GeneratorFactorData", Missing["Absent"]], Missing["NoScan"]]],
    "Admissible generator set?" -> hrfCompact[If[AssociationQ[scan], Lookup[scan, "AdmissibleGeneratorSetQ", Missing["Absent"]], Missing["NoScan"]]],
    "Superleading sector" -> hrfFactorOrDash[fsl],
    "Superleading sector source" -> hrfCompact[fslSource],
    "Reduction remainder" -> hrfFactorOrDash[sl],
    "Generator quotients" -> hrfCompact[Lookup[use, "Quotients", Missing["NotComputed"]]],
    "Obstruction" -> hrfFactorOrDash[Lookup[od, "Obstruction", Missing["Absent"]]]
  |>
];

If[! TrueQ[$HRFQuietReports], Print["[patch loaded] reporting/scaling uses Complement sector for exact reductions."]];
