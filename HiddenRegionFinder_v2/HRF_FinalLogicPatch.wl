(* HRF_FinalLogicPatch.wl
   Final reporting logic patch for Example 01.
   - Do not equate zero Superleading remainder with absence of an obstruction record.
   - Treat exact reduction (Superleading == 0) as a hidden-region-identifying cancellation, even though no LP scaling vector is needed/reported.
*)

ClearAll[hrfExactReductionQ, hrfGeneratorUseRemainder, hrfSuccessfulObstructionDecompositionQ];

hrfGeneratorUseRemainder[scan_] := Module[{use},
  use = If[AssociationQ[scan], Lookup[scan, "GeneratorUseData", <||>], <||>];
  If[AssociationQ[use], Lookup[use, "Remainder", Missing["NotAvailable"]], Missing["NotAvailable"]]
];

hrfExactReductionQ[scan_] := Module[{od, sl},
  od = If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing["NoScan"]], Missing["NoScan"]];
  If[!(AssociationQ[od] && KeyExistsQ[od, "Superleading"]), Return[False]];
  sl = od["Superleading"];
  TrueQ[Expand[sl] === 0]
];

(* HRF reporting/scaling patch: use the unreduced Complement as the displayed/scaled
   superleading sector when PolynomialReduce gives Superleading -> 0.  This keeps
   exact reduction as successful but still reports W_SL, W_HR, scaling vectors,
   and variable supports. *)

ClearAll[hrfEffectiveSuperleadingSector, hrfEffectiveSuperleadingSource,
  hrfObstructionPolynomialParts, hrfSuperleadingGeneratorForm,
  hrfSuccessfulObstructionDecompositionQ, hrfObstructionFoundQ,
  hrfObstructionSearchCertificateQ, hrfNoInteriorHiddenRegionCertificateQ,
  hrfObstructionForCoverageScaling,
  hrfScanCoverageScalingData, hrfScanCoverageScalingReadyQ, hrfAttachCoverageScalingData,
  hrfCoverageData, hrfHiddenRegionScanListTable, hrfHiddenSummaryRow, hrfScanRow,
  hrfEffectiveInputPolynomial, hrfRestrictedF0Labels, hrfScalingStatusLabel,
  hrfResolvedScalingVector, hrfResolvedVariableScaling];

(* PDF / boundary convention: all obstruction data refer to F_0^restricted,
   i.e. F_0 after setting boundary variables to zero (trivially F_0 on interior). *)
hrfRestrictedF0Labels[zeroVars_: {}] := <|
  "InputF" -> "F_0^restricted",
  "InputFNote" -> If[zeroVars === {}, "interior: no x_i set to zero", "boundary: x_i -> 0 applied"],
  "Obstruction" -> "Obstruction (F_0^restricted terms not in F_SL ideal)",
  "FSL" -> "F_SL (= F_0^restricted - Obstruction)",
  "Reconstruction" -> "Obstruction + F_SL = F_0^restricted?",
  "DecompositionSource" -> "F_0^restricted = Obstruction + F_SL"
|>;

hrfEffectiveSuperleadingSector[scan_] := Module[{od, sl},
  od = If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing["NoScan"]], Missing["NoScan"]];
  If[! AssociationQ[od], Return[Missing["NoObstructionData"]]];
  sl = Lookup[od, "Superleading", Lookup[od, "Complement", Missing["NoSuperleading"]]];
  If[MatchQ[sl, _Missing], Missing["NoSuperleadingSector"], sl]
];

hrfEffectiveSuperleadingSource[scan_] := Module[{od, obst, sl, labels},
  od = If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing["NoScan"]], Missing["NoScan"]];
  If[! AssociationQ[od], Return[Missing["NoObstructionData"]]];
  obst = Lookup[od, "Obstruction", Missing["NoObstruction"]];
  sl = Lookup[od, "Superleading", Lookup[od, "Complement", Missing["NoSuperleading"]]];
  labels = hrfRestrictedF0Labels[Lookup[scan, "ZeroVars", {}]];
  Which[
    ! MatchQ[obst, _Missing] && ! TrueQ[Expand[obst] === 0] && ! MatchQ[sl, _Missing],
      labels["DecompositionSource"],
    ! MatchQ[sl, _Missing], "F_SL sector only",
    True, Missing["NoSuperleadingSector"]
  ]
];

(* PDF convention: Obstruction = selected F monomials not in the SL ideal;
   Superleading (Complement) = F - Obstruction, divisible by generators.
   On boundaries F is always the restricted polynomial after x_i -> 0. *)
hrfEffectiveInputPolynomial[scan_] := Module[{f},
  f = If[AssociationQ[scan], Lookup[scan, "InputPolynomial", Missing[]], Missing[]];
  If[! MatchQ[f, _Missing], f, Missing["NoInputPolynomial"]]
];

hrfObstructionPolynomialParts[scan_] := Module[{od},
  od = If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing[]], Missing[]];
  If[! AssociationQ[od], Return[<||>]];
  <|
    "Obstruction" -> Lookup[od, "Obstruction", Missing["NoObstruction"]],
    "Superleading" -> Lookup[od, "Superleading", Lookup[od, "Complement", Missing["NoSuperleading"]]],
    "ObstructionFoundQ" -> hrfSuccessfulObstructionDecompositionQ[scan]
  |>
];

hrfSuperleadingGeneratorForm[scan_, vars_, kinVars_] := Module[
  {od, fsl, gens, allVars, quot, rem, presentation},
  If[! AssociationQ[scan], Return[Missing["NoScan"]]];
  od = Lookup[scan, "ObstructionData", Missing[]];
  If[! AssociationQ[od], Return[Missing["NoObstructionData"]]];
  fsl = Lookup[od, "Superleading", Lookup[od, "Complement", 0]];
  gens = Lookup[scan, "Generators", {}];
  If[gens === {}, Return[Missing["NoGenerators"]]];
  allVars = DeleteDuplicates @ Join[vars, kinVars];
  {quot, rem} = PolynomialReduce[Expand[fsl], gens, allVars];
  presentation = Expand @ Total[
    Table[Expand[quot[[i]]] * gens[[i]], {i, Min[Length[quot], Length[gens]]}]
  ];
  <|
    "SuperleadingExpanded" -> Expand[fsl],
    "Quotients" -> quot,
    "Remainder" -> Expand[rem],
    "InGeneratorIdealQ" -> TrueQ[Expand[rem] === 0],
    "GeneratorForm" -> presentation,
    "GeneratorFormCompact" -> hrfCompact[presentation]
  |>
];

(* Successful obstruction decomposition (PDF): F_0^restricted = Obstruction + F_SL with
   PolynomialReduce[F_SL, generators] remainder == 0 exactly (including F_SL = 0 exact reduction). *)
hrfSuccessfulObstructionDecompositionQ[scan_] := Module[{od, gens, activeVars, kinVars, fIn},
  If[! AssociationQ[scan], Return[False]];
  od = Lookup[scan, "ObstructionData", Missing["NoScan"]];
  If[! AssociationQ[od], Return[False]];
  gens = Lookup[scan, "Generators", {}];
  If[gens === {}, Return[False]];
  activeVars = Lookup[scan, "ActiveVars", Lookup[scan, "RemainingVars", {}]];
  kinVars = Lookup[scan, "KinVars", {s12, s23}];
  If[activeVars === {}, Return[False]];
  If[! hrfValidObstructionResultQ[od, gens, activeVars, kinVars], Return[False]];
  fIn = Lookup[scan, "InputPolynomial", Missing[]];
  If[MatchQ[fIn, _Missing], True, hrfObstructionDecompositionConsistentQ[scan, fIn]]
];

hrfObstructionFoundQ[scan_] := hrfSuccessfulObstructionDecompositionQ[scan];

(* Conclusive negative within the bounded generator/obstruction search:
   every capped candidate set was obstruction-tested and none yielded a valid HR trial. *)
hrfObstructionSearchCertificateQ[scan_] := Module[{completeQ, noValidQ, summary, perGen, tested},
  If[! AssociationQ[scan], Return[False]];
  completeQ = TrueQ[Lookup[scan, "AllCandidateGeneratorSetsTriedQ", False]] &&
    TrueQ[Lookup[scan, "ObstructionSearchCompleteQ", False]] &&
    ! TrueQ[Lookup[scan, "CandidateGeneratorSetLimitReachedQ", False]];
  noValidQ = TrueQ[Lookup[scan, "NoObstructionWithinSearchBoundsQ", False]];
  summary = Lookup[scan, "ObstructionAttemptSummary", <||>];
  perGen = Lookup[summary, "PerGeneratorAdmissibleCount", Missing["NotAvailable"]];
  tested = Lookup[summary, "ObstructionFindInstanceCount", Missing["NotAvailable"]];
  completeQ && noValidQ && ! hrfObstructionFoundQ[scan] &&
    IntegerQ[perGen] && IntegerQ[tested] && perGen === tested
];

hrfNoInteriorHiddenRegionCertificateQ[scan_] := Module[{zeroVars},
  If[! AssociationQ[scan], Return[False]];
  zeroVars = Lookup[scan, "ZeroVars", {}];
  zeroVars === {} && hrfObstructionSearchCertificateQ[scan]
];

(* Obstruction polynomial fed into post-cancellation LP scaling (U + F_obs). *)
hrfObstructionForCoverageScaling[scan_] := Module[{od, obst},
  od = If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing[]], Missing[]];
  If[! AssociationQ[od], Return[None]];
  obst = Lookup[od, "Obstruction", None];
  If[MatchQ[obst, None | Missing] || TrueQ[Expand[obst] === 0], None, obst]
];

(* True when scan already has a usable cached coverage LP result (avoid 2-arg Lookup -> KeyAbsent). *)
hrfScanCoverageScalingReadyQ[scan_] := AssociationQ[scan] &&
  KeyExistsQ[scan, "CoverageScalingData"] &&
  AssociationQ[scan["CoverageScalingData"]] &&
  KeyExistsQ[scan["CoverageScalingData"], "ScalingStatus"];

(* Resolve coverage LP scaling stored on a scan or passed explicitly. *)
hrfScanCoverageScalingData[scan_, scaling_:Automatic] := Which[
  AssociationQ[scaling], scaling,
  AssociationQ[scan] && KeyExistsQ[scan, "CoverageScalingData"],
    hrfScalingDataAssoc @ scan["CoverageScalingData"],
  True, <||>
];

hrfAttachCoverageScalingData[scan_, U_, activeVars_, maxAbs_:5, fObs_:Automatic] := Module[{cov},
  If[! AssociationQ[scan] || MatchQ[U, None | Automatic | Missing], Return[scan]];
  cov = hrfCoverageData[scan, U, activeVars, maxAbs, fObs];
  If[! AssociationQ[cov], scan, Join[scan, <|"CoverageScalingData" -> cov|>]]
];

hrfCoverageData[scan_, U_, activeVars_, maxAbs_:5, fObs_:Automatic] := Module[{cached, fsl, obs},
  cached = hrfScanCoverageScalingData[scan, Automatic];
  If[AssociationQ[cached] && KeyExistsQ[cached, "ScalingStatus"],
    Return[cached]
  ];
  If[! hrfObstructionFoundQ[scan], Return[Missing["NoObstructionFound"]]];
  fsl = hrfEffectiveSuperleadingSector[scan];
  If[MatchQ[fsl, _Missing] || TrueQ[Expand[fsl] === 0],
    Return[hrfExactReductionCoverageScalingData[]]
  ];
  obs = Which[
    fObs === Automatic, hrfObstructionForCoverageScaling[scan],
    TrueQ[fObs === None], None,
    True, fObs
  ];
  (* Guard: if the helper failed to evaluate, fall back to stored obstruction data. *)
  If[MatchQ[obs, HoldPattern[hrfObstructionForCoverageScaling[_]]],
    obs = With[{od = Lookup[scan, "ObstructionData", <||>]},
      If[AssociationQ[od], Lookup[od, "Obstruction", None], None]
    ]
  ];
  hrfNotebookTimed["findCoverageLPScaling vars=" <> ToString[Length[activeVars]],
    findCoverageLPScaling[fsl, Expand[U], activeVars, maxAbs, obs]
  ]
];

hrfHiddenRegionScanListTable[scan_Association] := Module[{hrs, rows},
  hrs = Lookup[scan, "HiddenRegionScans", {}];
  If[! ListQ[hrs] || hrs === {}, Return[Dataset[{}]]];
  rows = Table[
    With[{hrSc = hrs[[i]], sc = hrfScanCoverageScalingData[hrs[[i]], Automatic]},
      <|
        "Index" -> i,
        "Generators" -> hrfCompact[Lookup[hrSc, "Generators", {}]],
        "ScalingStatus" -> hrfScalingStatusLabel[sc],
        "Scaling vector" -> hrfCompact[hrfResolvedScalingVector[sc]],
        "HiddenRegionQ" -> TrueQ[Lookup[hrSc, "HiddenRegionQ", False]]
      |>
    ],
    {i, Length[hrs]}
  ];
  Dataset[rows]
];

hrfScalingStatusLabel[sc_Association] := Module[{msg},
  msg = Lookup[sc, "ScalingStatusMessage", Missing["NotAvailable"]];
  If[StringQ[msg] && msg =!= "", msg,
    Switch[Lookup[sc, "ScalingStatus", Missing[]],
      "Found", "Scaling vector determined",
      "NoValidScaling",
        "No scaling vector exists under LP constraints (uniform F_SL, W_SL<W_HR, variable coverage) within the searched nullspace box",
      "NotDetermined",
        "HR decomposition found but scaling vector not determined (nullspace coefficient search incomplete)",
      _, "--"
    ]
  ]
];

(* Resolve the accepted scaling vector from stored LP output (top-level or diagnostic). *)
hrfResolvedScalingVector[sc_Association] := Module[{diag, sv},
  If[! AssociationQ[sc], Return[Missing["NotAvailable"]]];
  diag = hrfSelectedDiagnostic[sc];
  Which[
    ListQ[Lookup[sc, "Scaling", {}]], sc["Scaling"],
    ListQ[Lookup[diag, "ScalingVector", {}]], diag["ScalingVector"],
    ListQ[Lookup[sc, "AcceptedScalingVectors", {}]] && sc["AcceptedScalingVectors"] =!= {},
      sc["AcceptedScalingVectors"][[1]],
    True, Lookup[sc, "Scaling", Missing["NotAvailable"]]
  ]
];

hrfResolvedVariableScaling[sc_Association, activeVars_: {}] := Module[{diag, vs},
  If[! AssociationQ[sc], Return[Missing["NotAvailable"]]];
  diag = hrfSelectedDiagnostic[sc];
  vs = Lookup[diag, "VariableScaling", Missing["NotAvailable"]];
  If[AssociationQ[vs], Return[vs]];
  sv = hrfResolvedScalingVector[sc];
  If[ListQ[sv] && ListQ[activeVars] && Length[sv] === Length[activeVars],
    Return[AssociationThread[activeVars, sv]]
  ];
  vs
];

hrfHiddenSummaryRow[label_, configuration_, zeroVars_, activeVars_, scan_, scaling_:Automatic] := Module[
  {sc, diag, hiddenQ, exactQ, admQ, hasGeneratorsQ, decompOK,
   isInteriorQ, isBoundaryQ, gens, rem, fsl, parts, slForm, kinVars = {s12, s23},
   fIn, decompQ, labels, scalingStatus, scalingMsg, scalingVec, varScaling},
  sc = hrfScalingAssoc @ hrfScanCoverageScalingData[scan, scaling];
  diag = hrfSelectedDiagnostic[sc];
  exactQ = hrfExactReductionQ[scan];
  gens = Lookup[If[AssociationQ[scan], scan, <||>], "Generators", {}];
  hasGeneratorsQ = ListQ[gens] && Length[gens] > 0;
  admQ = TrueQ[Lookup[If[AssociationQ[scan], scan, <||>], "AdmissibleGeneratorSetQ", False]];
  isInteriorQ = TrueQ[zeroVars === {}] || StringContainsQ[ToString[configuration], "Interior"];
  isBoundaryQ = ! isInteriorQ;
  rem = hrfGeneratorUseRemainder[scan];
  fsl = hrfEffectiveSuperleadingSector[scan];
  parts = hrfObstructionPolynomialParts[scan];
  fIn = hrfEffectiveInputPolynomial[scan];
  decompQ = If[! MatchQ[fIn, _Missing], hrfObstructionDecompositionConsistentQ[scan, fIn], Missing["NoInputPolynomial"]];
  labels = hrfRestrictedF0Labels[zeroVars];
  slForm = If[AssociationQ[scan] && hasGeneratorsQ,
    hrfSuperleadingGeneratorForm[scan, activeVars, kinVars],
    Missing["NotComputed"]
  ];

  decompOK = hrfSuccessfulObstructionDecompositionQ[scan] && admQ && hasGeneratorsQ;
  scalingStatus = Lookup[sc, "ScalingStatus", Missing["NotAvailable"]];
  scalingMsg = hrfScalingStatusLabel[sc];
  scalingVec = hrfResolvedScalingVector[sc];
  varScaling = hrfResolvedVariableScaling[sc, activeVars];

  (* Hidden region requires a successful obstruction decomposition first; scaling (or
     interior exact reduction of an already-valid F_SL) is evaluated only after that. *)
  hiddenQ = decompOK &&
    If[isBoundaryQ,
      hrfCoverageFoundQ[sc] || (exactQ && TrueQ[Expand[rem] === 0]),
      (hrfCoverageFoundQ[sc] || (exactQ && TrueQ[Expand[rem] === 0]))
    ];

  <|
    "Case" -> label,
    "Hidden region identified?" -> Which[
      hiddenQ, "Yes",
      decompOK && ! hrfCoverageFoundQ[sc], "No (" <> scalingMsg <> ")",
      True, "No"
    ],
    "Configuration" -> configuration,
    "Region vector" -> hrfCompact[activeVars],
    "Boundary variables set to zero" -> hrfCompact[zeroVars],
    "Obstruction found?" -> TrueQ[Lookup[parts, "ObstructionFoundQ", False]] && hrfObstructionFoundQ[scan],
    "Input F_0^restricted note" -> labels["InputFNote"],
    labels["Obstruction"] -> hrfFactorOrDash[Lookup[parts, "Obstruction", Missing[]]],
    labels["FSL"] -> hrfFactorOrDash[fsl],
    labels["Reconstruction"] -> decompQ,
    "F_SL in generator form" -> If[AssociationQ[slForm],
      Lookup[slForm, "GeneratorFormCompact", hrfCompact[Lookup[slForm, "GeneratorForm", "--"]]],
      "--"
    ],
    "F_SL in generator ideal?" -> If[AssociationQ[slForm], Lookup[slForm, "InGeneratorIdealQ", False], False],
    "Generators" -> hrfCompact[gens],
    "Generator set admissible?" -> admQ,
    "W_SL" -> hrfWeight[diag, "WSL", "FSLWeight"],
    "W_HR" -> hrfWeight[diag, "WHR", "PostCancellationLeadingWeight"],
    "W_FObs leading" -> hrfCompact[
      With[{wObs = Lookup[diag, "FObsLeadingWeights", Missing["NotAvailable"]]},
        Which[
          ListQ[wObs] && wObs =!= {}, Min[wObs],
          NumberQ[wObs], wObs,
          True, Missing["NotAvailable"]
        ]
      ]
    ],
    "Hierarchy gap (W_HR - W_SL)" -> hrfWeight[diag, "HierarchyGapPostLPminusFSL", "GapWHRminusWSL"],
    "Scaling hierarchy OK?" -> TrueQ[Lookup[diag, "HiddenDominatesPostCancellationLPQ", False]],
    "Scaling status" -> scalingMsg,
    "Scaling vector" -> hrfCompact[scalingVec],
    "Variable scaling by region variable" -> hrfCompact[varScaling],
    "Variables at W_SL" -> hrfCompact[Lookup[diag, "VariablesCoveredByFSLAtWSL", Missing["NotAvailable"]]],
    "Variables at W_HR" -> hrfCompact[Lookup[diag, "VariablesInPostCancellationLeadingSupport", Missing["NotAvailable"]]],
    "Accepted scaling count" -> Lookup[sc, "AcceptedCount", Missing["NotAvailable"]],
    "Unique accepted scaling?" -> Lookup[sc, "UniqueAcceptedScalingQ", Missing["NotAvailable"]],
    "Candidate count" -> Lookup[sc, "CandidateCount", Missing["NotAvailable"]],
    "Scaling search exhaustive?" -> Lookup[sc, "ScalingSearchExhaustiveQ", Missing["NotAvailable"]],
    "Comment" -> Which[
      hiddenQ && hrfCoverageFoundQ[sc] && TrueQ[Lookup[sc, "UniqueAcceptedScalingQ", False]], "unique accepted scaling found",
      hiddenQ && hrfCoverageFoundQ[sc], "accepted scaling found; inspect diagnostics for possible non-uniqueness",
      hiddenQ && isBoundaryQ && exactQ, "boundary exact reduction by admissible generators",
      hiddenQ && isInteriorQ && exactQ, "interior exact reduction by admissible generators",
      decompOK && scalingStatus === "NoValidScaling",
        "HR decomposition found; no scaling vector exists under LP constraints in searched nullspace box",
      decompOK && scalingStatus === "NotDetermined",
        "HR decomposition found but scaling vector not determined (nullspace search incomplete)",
      AssociationQ[slForm] && ! TrueQ[Lookup[slForm, "InGeneratorIdealQ", False]],
        "warning: reported superleading is not in the generator ideal (check generators or obstruction decomposition)",
      TrueQ[decompQ === False],
        "warning: Obstruction + F_SL does not reconstruct F_0^restricted",
      ! hrfSuccessfulObstructionDecompositionQ[scan],
        "no successful obstruction decomposition (F_SL not in generator ideal or F_0^restricted mismatch)",
      hrfSuccessfulObstructionDecompositionQ[scan] && admQ && ! hrfCoverageFoundQ[sc] &&
        ! MatchQ[scalingStatus, "NoValidScaling" | "NotDetermined"],
        "F_SL in generator ideal but no valid scaling (need W_SL strictly less than leading weight of U + F_obs)",
      ! hrfObstructionFoundQ[scan], Which[
        TrueQ[Lookup[scan, "NoObstructionWithinSearchBoundsQ", False]],
          "exhaustive search: no valid obstruction among all candidate generator sets (within cap/degree/physics bounds)",
        TrueQ[Lookup[scan, "CandidateGeneratorSetLimitReachedQ", False]],
          "search hit candidate cap before all theoretical sets could be tried; negative result not certified",
        True, "no obstruction decomposition produced by the scan"
      ],
      ! hasGeneratorsQ, "no generators reported by the scan",
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
    "F_SL sector" -> hrfFactorOrDash[fsl],
    "F_SL sector source" -> hrfCompact[fslSource],
    "Reduction remainder" -> hrfFactorOrDash[sl],
    "Generator quotients" -> hrfCompact[Lookup[use, "Quotients", Missing["NotComputed"]]],
    "Obstruction" -> hrfFactorOrDash[Lookup[od, "Obstruction", Missing["Absent"]]]
  |>
];

If[! TrueQ[$HRFQuietReports], Print["[patch loaded] Obstruction reporting: F_0^restricted - Obstruction = F_SL; Obstruction + F_SL = F_0^restricted."]];
