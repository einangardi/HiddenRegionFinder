(* HRF_PolynomialFactorReporting.wl
   Audit tables for polynomial-factor development: track new f_k, suppressed
   candidates, and generator-set acceptance/discards. *)

If[! ValueQ[hrfPolynomialCompact],
  Quiet @ Check[Unprotect[safeCancellationFactors, safeCancellationFactorsExtended], Null];
  Get[FileNameJoin[{
    If[StringQ[$InputFileName] && $InputFileName =!= "", DirectoryName[$InputFileName],
      If[StringQ[$HRFExample04Directory], $HRFExample04Directory, Directory[]]],
    "HRF_PolynomialCancellationFactors.wl"
  }]];
];

ClearAll[
  hrfPolyHiddenRegionQ, hrfPolyGeneratorDiscardReason,
  hrfPolyGeneratorAuditRow, hrfPolyGeneratorAuditTable,
  hrfPolyFactorAuditDisplayRow, hrfPolyFactorAuditTable,
  hrfPolyFactorDiffDisplayRow, hrfPolyFactorDiffTable,
  hrfPolyModeComparisonRow, hrfPolyModeComparisonTable,
  hrfPolyRegressionSummaryNarrative
];

hrfPolyHiddenRegionQ[scan_, regionType_: "Interior"] := Module[{sc = <||>, hiddenQ, exactQ, admQ, rem},
  If[! AssociationQ[scan], Return[False]];
  If[ValueQ[hrfHiddenSummaryRow],
    Return[TrueQ[hrfHiddenSummaryRow["probe", regionType, {}, {}, scan, Automatic]["Hidden region identified?"] === "Yes"]]
  ];
  admQ = TrueQ[Lookup[scan, "AdmissibleGeneratorSetQ", False]];
  exactQ = If[ValueQ[hrfExactReductionQ], hrfExactReductionQ[scan], False];
  rem = If[ValueQ[hrfGeneratorUseRemainder], hrfGeneratorUseRemainder[scan], Missing["NotAvailable"]];
  hiddenQ = If[ValueQ[hrfObstructionFoundQ],
    hrfObstructionFoundQ[scan] && admQ && (
      regionType === "Interior" && (exactQ || TrueQ[Expand[rem] === 0]) ||
      regionType =!= "Interior"
    ),
    admQ && AssociationQ[Lookup[scan, "ObstructionData", Missing[]]]
  ];
  hiddenQ
];

hrfPolyGeneratorDiscardReason[trial_Association] := Module[{perGen, adm, obs},
  perGen = TrueQ[Lookup[trial, "PerGeneratorAdmissibleQ", False]];
  adm = TrueQ[Lookup[trial, "AdmissibleSLSectorQ", False]];
  obs = Lookup[trial, "ObstructionData", Missing[]];
  Which[
    ! perGen, "discarded: per-generator admissibility failed",
    MatchQ[obs, _Missing], "discarded: no obstruction data",
    AssociationQ[obs] && TrueQ[Expand[Lookup[obs, "Superleading", 1]] === 0],
      "discarded: exact reduction (Superleading SL sector zero; Complement may be used in reporting)",
    ! adm, "discarded: SL-sector admissibility failed after obstruction",
    True, "accepted candidate"
  ]
];

hrfPolyGeneratorAuditRow[scan_Association, label_: "scan"] := Module[
  {cand, adm, trials, accepted, discarded},
  If[! AssociationQ[scan], Return[<||>]];
  cand = Lookup[scan, "CandidateGeneratorSets", {}];
  adm = Lookup[scan, "AdmissibleCandidateGeneratorSets", {}];
  trials = If[KeyExistsQ[scan, "ObstructionAttemptData"], scan["ObstructionAttemptData"], {}];
  accepted = Lookup[scan, "Generators", {}];
  discarded = Select[cand, ! MemberQ[adm, #] &];
  <|
    "Label" -> label,
    "CancellationFactorCount" -> Length[Lookup[scan, "CancellationFactors", {}]],
    "CandidateGeneratorCount" -> Length[cand],
    "AdmissibleGeneratorCount" -> Length[adm],
    "DiscardedGeneratorCount" -> Length[discarded],
    "AcceptedGenerators" -> hrfPolynomialCompact[accepted],
    "DiscardedGenerators" -> hrfPolynomialCompact[discarded],
    "HiddenRegionQ" -> hrfPolyHiddenRegionQ[scan, "Interior"]
  |>
];

hrfPolyGeneratorAuditTable[scans_Association] := Dataset[KeyValueMap[hrfPolyGeneratorAuditRow[#2, #1] &, scans]];

hrfPolyFactorAuditDisplayRow[row_Association] := <|
  "Factor" -> hrfPolynomialCompact[Lookup[row, "Factor", "--"]],
  "Class" -> Lookup[row, "Class", "--"],
  "MonomialCount" -> Lookup[row, "MonomialCount", "--"],
  "MixedSign" -> Lookup[row, "MixedSignQ", "--"],
  "Accepted" -> Lookup[row, "AcceptedQ", False],
  "RejectReason" -> Lookup[row, "RejectReason", "--"]
|>;

hrfPolyFactorAuditTable[auditRows_List] := Dataset[hrfPolyFactorAuditDisplayRow /@ auditRows];

hrfPolyFactorDiffDisplayRow[diff_Association] := <|
  "BinomialCount" -> Lookup[diff, "BinomialCount", 0],
  "PolynomialCount" -> Lookup[diff, "PolynomialCount", 0],
  "AddedFactorCount" -> Lookup[diff, "AddedFactorCount", 0],
  "AddedFactors" -> hrfPolynomialCompact[Lookup[diff, "AddedFactors", {}]],
  "OpenKinematicFilter" -> Lookup[diff, "OpenKinematicFilterActiveQ", False]
|>;

hrfPolyFactorDiffTable[diff_Association] := Dataset[{hrfPolyFactorDiffDisplayRow[diff]}];

hrfPolyModeComparisonRow[label_, binScan_, polyScan_, factorDiff_] := <|
  "Case" -> label,
  "BinomialFactorCount" -> Lookup[factorDiff, "BinomialCount", 0],
  "PolynomialFactorCount" -> Lookup[factorDiff, "PolynomialCount", 0],
  "AddedFactors" -> hrfPolynomialCompact[Lookup[factorDiff, "AddedFactors", {}]],
  "BinomialHiddenRegionQ" -> hrfPolyHiddenRegionQ[binScan, "Interior"],
  "PolynomialHiddenRegionQ" -> hrfPolyHiddenRegionQ[polyScan, "Interior"],
  "BinomialGenerators" -> hrfPolynomialCompact[Lookup[binScan, "Generators", {}]],
  "PolynomialGenerators" -> hrfPolynomialCompact[Lookup[polyScan, "Generators", {}]],
  "BinomialCandidateGenerators" -> Lookup[binScan, "CandidateGeneratorCount", 0],
  "PolynomialCandidateGenerators" -> Lookup[polyScan, "CandidateGeneratorCount", 0],
  "BinomialDiscardedGenerators" -> Lookup[hrfPolyGeneratorAuditRow[binScan, label], "DiscardedGeneratorCount", 0],
  "PolynomialDiscardedGenerators" -> Lookup[hrfPolyGeneratorAuditRow[polyScan, label], "DiscardedGeneratorCount", 0],
  "RegressionStableQ" -> (
    hrfPolyHiddenRegionQ[binScan, "Interior"] === hrfPolyHiddenRegionQ[polyScan, "Interior"]
  )
|>;

hrfPolyModeComparisonTable[rows_List] := Dataset[rows];

hrfPolyRegressionSummaryNarrative[comparisonTable_] := Module[{rows, unstable, added},
  rows = If[Head[comparisonTable] === Dataset, Normal[comparisonTable], comparisonTable];
  unstable = Select[rows, ! TrueQ[Lookup[#, "RegressionStableQ", True]] &];
  added = Select[rows, TrueQ[Lookup[#, "AddedFactorCount", 0] > 0] &];
  StringRiffle[{
    "Polynomial-factor regression summary.",
    "Cases with changed hidden-region verdict (binomial vs polynomial): " <> ToString[Length[unstable]],
    If[unstable =!= {},
      "  " <> StringRiffle[Lookup[#, "Case"] & /@ unstable, ", "],
      Nothing
    ],
    "Cases with added f_k under polynomial mode: " <> ToString[Length[added]],
    If[added =!= {},
      "  " <> StringRiffle[
        Lookup[#, "Case"] <> " (+" <> ToString[Lookup[#, "AddedFactorCount", 0]] <> ")" & /@ added,
        ", "
      ],
      Nothing
    ],
    "Open-kinematic-stratum filter active: " <> ToString[$HRFPolynomialRequireOpenKinematicStratum]
  }, "\n"]
];

If[! TrueQ[$HRFQuietReports], Print["[loaded] polynomial-factor reporting helpers."]];
