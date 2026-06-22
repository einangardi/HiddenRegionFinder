(* 04_PolynomialFactor_Regression.wl
   Regression and target-case harness for footnote-4 polynomial factors.

   Tracks:
     - additional f_k relative to binomial mode (primitive cancellation factors)
     - generator candidates accepted/discarded
     - hidden-region stability across modes

   Cases (default on load):
     - Crown interior (4pt regression)
     - HyperCrown {x11}=0 (4pt target)
     - Seed5pt interior vs ThreeLoopVertex interior (5pt collinear core)

   Usage:
     Get["HiddenRegionFinder.wl"];
     $HRFRunEx04RegressionOnLoad = True;   (* fast cases only by default *)
     $HRFRunEx04SlowCasesOnLoad = True;   (* optional: HyperCrown interior + 5pt *)
     Get["04_PolynomialFactor_Regression.wl"];
     Ex04PolynomialRegressionTable
*)

If[! ValueQ[$HRFUsePolynomialCancellationFactors], $HRFUsePolynomialCancellationFactors = True];
If[! ValueQ[$HRFExample04Report], $HRFExample04Report = True];
If[! ValueQ[$HRFRunEx04FivePointOnLoad], $HRFRunEx04FivePointOnLoad = True];
(* Back-compat *)
If[ValueQ[$HRFRunEx04ThreeLoopOnLoad] && ! ValueQ[$HRFRunEx04FivePointOnLoad],
  $HRFRunEx04FivePointOnLoad = $HRFRunEx04ThreeLoopOnLoad
];
If[! ValueQ[$HRFRunScalingDiagnostics], $HRFRunScalingDiagnostics = False];
If[! ValueQ[$HRFPreferExample01HiddenSummaryForPolyQ], $HRFPreferExample01HiddenSummaryForPolyQ = False];
If[! ValueQ[$HRFFindObstructionsStopOnFirstAdmissibleQ], $HRFFindObstructionsStopOnFirstAdmissibleQ = False];
If[! ValueQ[$HRFCandidateGeneratorSetLimit], $HRFCandidateGeneratorSetLimit = 64];
If[! ValueQ[$HRFRunEx04SlowCasesOnLoad], $HRFRunEx04SlowCasesOnLoad = False];
If[! ValueQ[$HRFEx04BuildGeneratorPairTablesQ], $HRFEx04BuildGeneratorPairTablesQ = False];
(* Auto-build pair tables when |f_k| is small; Crown (36) needs explicit opt-in. *)
If[! ValueQ[$HRFEx04GeneratorPairTableMaxFactors], $HRFEx04GeneratorPairTableMaxFactors = 16];
If[! ValueQ[$HRFEx04RunObstructionSearchQ], $HRFEx04RunObstructionSearchQ = False];
If[! ValueQ[$HRFObstructionFindInstanceTimeLimit], $HRFObstructionFindInstanceTimeLimit = 20];
If[! ValueQ[$HRFKinDomainFindInstanceTimeLimit], $HRFKinDomainFindInstanceTimeLimit = 5];
If[! ValueQ[$HRFMaxProductSubsetSize], $HRFMaxProductSubsetSize = 2];

$HRFExample04Directory = If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName],
  Quiet[Check[NotebookDirectory[], Directory[]]]
];

If[! TrueQ[$HRFFinderCoreLoadedQ],
  Quiet @ Check[Unprotect[safeCancellationFactors, safeCancellationFactorsExtended], Null];
  Get[FileNameJoin[{$HRFExample04Directory, "HiddenRegionFinder.wl"}]]
];
Get[FileNameJoin[{$HRFExample04Directory, "HRF_PolynomialCancellationFactors.wl"}]];
Get[FileNameJoin[{$HRFExample04Directory, "HRF_FinalLogicPatch.wl"}]];
If[Length[DownValues[hrfCoverageFoundQ]] === 0,
  Get[FileNameJoin[{$HRFExample04Directory, "HRF_Example01Common.wl"}]]
];
Get[FileNameJoin[{$HRFExample04Directory, "HRF_PolynomialFactorReporting.wl"}]];
Quiet @ Get[FileNameJoin[{$HRFExample04Directory, "HRF_PolynomialFactorRegressionTests.wl"}]];

If[! ValueQ[$HRFUseGeneratorPhysicsFilterQ], $HRFUseGeneratorPhysicsFilterQ = True];
(* Default polynomial-only: binomial compare doubles runtime and RAM. *)
If[! ValueQ[$HRFEx04CompareBinomialQ], $HRFEx04CompareBinomialQ = False];
If[! ValueQ[$HRFEx04TrimScanStorageQ], $HRFEx04TrimScanStorageQ = True];
(* Lightweight boundary cases: skip factor audits; defer coverage LP to display row. *)
If[! ValueQ[$HRFEx04LightweightCaseQ], $HRFEx04LightweightCaseQ = False];
If[! ValueQ[$HRFEx04DeferCoverageScalingQ], $HRFEx04DeferCoverageScalingQ = False];
If[! ValueQ[$HRFEx04ObstructionProgressQ], $HRFEx04ObstructionProgressQ = False];

ClearAll[
  hrfEx04Say, hrfEx04ReinstallPolynomialPatch, hrfEx04ObstructionOptions, hrfEx04ScanInMode, hrfEx04CompareModes,
  hrfEx04PolynomialOnlyCase, hrfEx04RunObstructionCase, hrfEx04TrimPolynomialScan,
  hrfEx04LoadExample01, hrfEx04LoadExample03Core,
  hrfEx04CrownRegression, hrfEx04SuperCrownInterior, hrfEx04HyperCrownInterior,
  hrfEx04HyperCrownX11Target,
  hrfEx04DivingBeetleInterior, hrfEx04DivingBeetleX89Boundary,
  hrfEx04DivingBeetleCaseDisplay, hrfEx04DivingBeetleInteriorDisplay, hrfEx04DivingBeetleX89Display,
  hrfEx04Seed5ptInterior, hrfEx04ThreeLoopVertexInterior,
  hrfEx04FivePointLeadingU, hrfEx04InspectFivePointCase, hrfEx04BuildFivePointComparison,
  hrfEx04FivePointFactorDiffTable, hrfEx04FivePointGeneratorStats,
  hrfEx04FactorSupportStudy, hrfEx04CrownFactorSupportAudit,
  hrfEx04ShouldBuildGeneratorPairTableQ, hrfEx04GeneratorPairTable,
  hrfEx04ThreeMonomialPairAudit,
  hrfEx04BuildRegressionTable, hrfEx04InspectPolynomialScan, hrfEx04RegionStudyRow,
  hrfEx04CasePopulatedQ, hrfEx04CaseExtract, hrfEx04CaseIngredients,
  hrfEx04HyperCrownX11Display, hrfEx04CrownSanityDisplay, hrfEx04FivePointCaseDisplay
];

hrfEx04Say[msg_] := If[TrueQ[$HRFExample04Report], Print["[Example 04] " <> msg]];

hrfEx04TrimPolynomialScan[scan_] := If[! TrueQ[$HRFEx04TrimScanStorageQ] || ! AssociationQ[scan],
  scan,
  KeyDrop[scan, {
    "ObstructionAttemptData", "AdmissibleObstructionAttemptData",
    "CandidateGeneratorSets", "CandidateGeneratorSetDiagnostics",
    "CandidateGeneratorFactorData", "AdmissibleCandidateGeneratorFactorData",
    "AdmissibleCandidateGeneratorSetFactorUnions"
    (* keep GeneratorSetScalingSummary, ValidTrialScalingEvaluations, HiddenRegionScans *)
  }]
];

(* Example 01 reloads the native binomial safeCancellationFactors* definitions.
   Re-install the polynomial patch whenever Example 01/03 core graphs are loaded. *)
hrfEx04ReinstallPolynomialPatch[] := Block[{$HRFPolynomialPatchQuietReinstallQ = True},
  Quiet @ Check[hrfInstallPolynomialCancellationPatch[], False]
];

hrfEx04ObstructionOptions[kinVars_] := Join[
  If[MemberQ[kinVars, s], {"DimensionfulKinVars" -> {s}}, {}],
  {}
];

hrfEx04CasePopulatedQ[case_] := AssociationQ[case] && KeyExistsQ[case, "PolynomialScan"] &&
  AssociationQ[Lookup[case, "PolynomialScan", None]];

hrfEx04CaseExtract[case_Association] := Module[
  {scan, activeVars, zeroVars, label, trialRows, admRows, hrScans},
  If[! hrfEx04CasePopulatedQ[case], Return[Missing["NotRun", "Evaluate the matching hrfEx04*[] cell first."]]];
  scan = case["PolynomialScan"];
  activeVars = Which[
    KeyExistsQ[case, "RemainingVars"], case["RemainingVars"],
    KeyExistsQ[scan, "ActiveVars"], scan["ActiveVars"],
    True, {}
  ];
  zeroVars = Lookup[case, "ZeroVars", Lookup[scan, "ZeroVars", {}]];
  label = Lookup[case, "Label", "case"];
  trialRows = hrfPolyGeneratorSetScalingRows[scan, activeVars];
  admRows = Select[trialRows,
    TrueQ[Lookup[#, "AdmissibleSLSectorQ", False]] &&
      TrueQ[Lookup[#, "PerGeneratorAdmissibleQ", False]] &
  ];
  hrScans = Lookup[scan, "HiddenRegionScans", {}];
  <|
    "Primary" -> hrfEx04ScanPrimaryIngredients[scan, activeVars, zeroVars, label],
    "TrialRows" -> trialRows,
    "AdmissibleTrialRows" -> admRows,
    "HiddenRegionCount" -> Lookup[scan, "HiddenRegionCount", Length[hrScans]],
    "HiddenRegionScans" -> hrScans,
    "HiddenRegionIngredients" -> Table[
      hrfEx04ScanPrimaryIngredients[hrScans[[i]], activeVars, zeroVars,
        label <> " / HR " <> ToString[i]],
      {i, Length[hrScans]}
    ],
    "Scan" -> scan,
    "Case" -> case
  |>
];

hrfEx04CaseIngredients[case_Association] := Module[{ex, primary, hrPos},
  ex = hrfEx04CaseExtract[case];
  If[MatchQ[ex, _Missing], Return[ex]];
  primary = ex["Primary"];
  If[! AssociationQ[primary],
    Return[<|"Error" -> "Primary ingredients unavailable (scan missing or invalid). Re-run the matching hrfEx04DivingBeetle*[] cell."|>]
  ];
  hrPos = Select[ex["TrialRows"], TrueQ[Lookup[#, "HiddenRegionQ", False]] &];
  <|
    "Case" -> Lookup[primary, "Case", "case"],
    "RegionVariables" -> Lookup[primary, "RegionVariables", {}],
    "BoundaryZeroVariables" -> Lookup[primary, "BoundaryZeroVariables", {}],
    "Generators" -> Lookup[primary, "Generators", {}],
    "ScalingVector" -> Lookup[primary, "ScalingVector", Missing["NotAvailable"]],
    "VariableScaling" -> Lookup[primary, "VariableScaling", Missing["NotAvailable"]],
    "VariablesAtWSL" -> Lookup[primary, "VariablesAtWSL", Missing["NotAvailable"]],
    "VariablesAtWHR" -> Lookup[primary, "VariablesAtWHR", Missing["NotAvailable"]],
    "HiddenRegionQ" -> Lookup[primary, "HiddenRegionQ", False],
    "Obstruction" -> Lookup[primary, "Obstruction", Missing["NotAvailable"]],
    "FSL" -> Lookup[primary, "FSL", Missing["NotAvailable"]],
    "ScalingStatus" -> Lookup[primary, "ScalingStatus", "--"],
    "HiddenRegionTrialRows" -> hrPos,
    "AllTrialScalingVectors" -> Lookup[#, "ScalingVector", Missing[]] & /@ ex["TrialRows"]
  |>
];

hrfEx04DivingBeetleInteriorDisplay[] := Module[{},
  If[! hrfEx04CasePopulatedQ[Ex04DivingBeetleInterior],
    Ex04DivingBeetleInterior = hrfEx04DivingBeetleInterior[]
  ];
  hrfEx04DivingBeetleCaseDisplay[Ex04DivingBeetleInterior]
];

hrfEx04DivingBeetleX89Display[] := Module[{},
  If[! hrfEx04CasePopulatedQ[Ex04DivingBeetleX89Target],
    Ex04DivingBeetleX89Target = hrfEx04DivingBeetleX89Boundary[]
  ];
  hrfEx04DivingBeetleCaseDisplay[Ex04DivingBeetleX89Target]
];

hrfEx04DivingBeetleCaseDisplay[case_Association, label_: Automatic] := Module[
  {scan, zeroVars, activeVars, u, title, cols, row, scalingTable, admTable, extract, ingredients},
  If[! AssociationQ[case],
    Return[<|"Error" -> "Expected an Association case (run In[6] first, or use hrfEx04DivingBeetleX89Display[])."|>]
  ];
  If[! hrfEx04CasePopulatedQ[case],
    Return[<|"Error" -> "Case not populated. Run hrfEx04DivingBeetleInterior[] or hrfEx04DivingBeetleX89Boundary[] first."|>]
  ];
  hrfEx04LoadExample01[];
  scan = case["PolynomialScan"];
  zeroVars = Lookup[case, "ZeroVars", {}];
  activeVars = Lookup[case, "RemainingVars", Complement[VarsDB, zeroVars]];
  u = If[zeroVars === {}, DBData["UF"]["U"], Expand[DBData["UF"]["U"] /. Thread[zeroVars -> 0]]];
  title = If[label === Automatic, Lookup[case, "Label", "Diving Beetle case"], label];
  cols = {"Region vector", "Hidden region identified?", "Generators", "Scaling status",
    "Scaling vector", "Variable scaling by region variable", "W_SL", "W_HR",
    "Variables at W_SL", "Variables at W_HR", "Comment"};
  row = KeyTake[
    hrfEx04RegionStudyRow[scan, title, activeVars, KinAssump4ptOnShell, KinVars4pt, u, zeroVars],
    cols
  ];
  scalingTable = hrfPolyGeneratorSetScalingTable[scan, title <> " / all valid trials"];
  admTable = hrfPolyAdmissibleGeneratorSetTable[scan, title <> " / admissible"];
  extract = hrfEx04CaseExtract[case];
  ingredients = hrfEx04CaseIngredients[case];
  If[TrueQ[$HRFExample04Report],
    Print["[Example 04] ", title, ": assign report = hrfEx04DivingBeetleCaseDisplay[case]; ",
      "then report[\"Ingredients\"][\"ScalingVector\"], etc."]
  ];
  <|
    "Summary" -> Dataset[{row}],
    "AllValidTrialsScaling" -> scalingTable,
    "AdmissibleGeneratorSets" -> admTable,
    "Extract" -> extract,
    "Ingredients" -> ingredients,
    "Case" -> case
  |>
];

hrfEx04HyperCrownX11Display[] := Module[{case, row, cols, scalingTable, admTable, extract, ingredients},
  If[! hrfEx04CasePopulatedQ[Ex04HyperCrownX11Target],
    Ex04HyperCrownX11Target = hrfEx04HyperCrownX11Target[]
  ];
  case = Ex04HyperCrownX11Target;
  cols = {"Region vector", "Hidden region identified?", "Generators", "Scaling status",
    "Scaling vector", "Variable scaling by region variable", "W_SL", "W_HR",
    "Variables at W_SL", "Variables at W_HR", "Comment"};
  row = KeyTake[
    hrfEx04RegionStudyRow[
      case["PolynomialScan"], "HyperCrown boundary {x11}=0",
      Complement[VarsHyperCrown, {x11}], KinAssump4ptOnShell, KinVars4pt,
      Expand[HyperCrownData["UF"]["U"] /. x11 -> 0], {x11}
    ],
    cols
  ];
  scalingTable = hrfPolyGeneratorSetScalingTable[case["PolynomialScan"], "HyperCrown x11=0 / all valid trials"];
  admTable = hrfPolyAdmissibleGeneratorSetTable[case["PolynomialScan"], "HyperCrown x11=0 / admissible"];
  extract = hrfEx04CaseExtract[case];
  ingredients = hrfEx04CaseIngredients[case];
  If[TrueQ[$HRFExample04Report],
    Print["[Example 04] HyperCrown x11: primary row = first scaling-positive set (if any). ",
      "Assign hrfX11Report = hrfEx04HyperCrownX11Display[]; then hrfX11Report[\"Ingredients\"][\"ScalingVector\"], etc."]
  ];
  <|
    "Summary" -> Dataset[{row}],
    "AllValidTrialsScaling" -> scalingTable,
    "AdmissibleGeneratorSets" -> admTable,
    "Extract" -> extract,
    "Ingredients" -> ingredients,
    "Case" -> case
  |>
];

hrfEx04FivePointCaseDisplay[case_Association, target_String : "Seed5pt"] := Module[
  {scan, vars, u, label, cols, row, scalingTable, admTable, extract, ingredients},
  If[! hrfEx04CasePopulatedQ[case],
    Return[<|"Error" -> "Case not populated. Run hrfEx04Seed5ptInterior[] or hrfEx04ThreeLoopVertexInterior[] first."|>]
  ];
  hrfEx04LoadExample03Core[];
  vars = Switch[target,
    "ThreeLoopVertex" | "Vertex", VarsThreeLoopVertex5pt,
    _, VarsSeed5pt
  ];
  u = hrfEx04FivePointLeadingU[target];
  label = Lookup[case, "Label", target <> " collinear interior"];
  scan = case["PolynomialScan"];
  cols = {"Region vector", "Hidden region identified?", "Generators", "Scaling status",
    "Scaling vector", "Variable scaling by region variable", "W_SL", "W_HR",
    "Variables at W_SL", "Variables at W_HR", "Comment"};
  row = KeyTake[
    hrfEx04RegionStudyRow[scan, label, vars, KinAssump, KinVars, u, Lookup[case, "ZeroVars", {}]],
    cols
  ];
  scalingTable = hrfPolyGeneratorSetScalingTable[scan, label <> " / all valid trials"];
  admTable = hrfPolyAdmissibleGeneratorSetTable[scan, label <> " / admissible"];
  extract = hrfEx04CaseExtract[case];
  ingredients = hrfEx04CaseIngredients[case];
  If[TrueQ[$HRFExample04Report],
    Print["[Example 04] ", label, ": MaxGenerators=1 (Collinear5pt preset). ",
      "Assign report = hrfEx04FivePointCaseDisplay[case, \"", target, "\"]; ",
      "then report[\"Ingredients\"][\"ScalingVector\"], etc."]
  ];
  <|
    "Target" -> target,
    "Summary" -> Dataset[{row}],
    "AllValidTrialsScaling" -> scalingTable,
    "AdmissibleGeneratorSets" -> admTable,
    "Extract" -> extract,
    "Ingredients" -> ingredients,
    "Case" -> case
  |>
];

hrfEx04InspectPolynomialScan[case_Association, label_: Automatic, vars_: Automatic, kinAssump_: Automatic, kinVars_: Automatic, U_: Automatic] := Module[
  {scan, title, gd, activeVars, zeroVars, fIn, ka, kv, u, parts, slForm, row, regionKind, caseSym, runHint},
  caseSym = ToString[HoldForm[case]];
  If[! hrfEx04CasePopulatedQ[case],
    runHint = Switch[caseSym,
      "Ex04HyperCrownInterior", "Run In[19]: Ex04HyperCrownInterior = hrfEx04HyperCrownInterior[]",
      "Ex04HyperCrownX11Target", "Run hrfEx04HyperCrownX11Display[] (or hrfEx04HyperCrownX11Target[])",
      "Ex04DivingBeetleInterior", "Run hrfEx04DivingBeetleInterior[]",
      "Ex04DivingBeetleX89Target", "Run hrfEx04DivingBeetleX89Boundary[]",
      "Ex04CrownRegression", "Run In[1] (loads Ex04CrownRegression via hrfEx04CrownRegression[]) or In[15]",
      _, "Evaluate the matching hrfEx04*[] cell, assign to " <> caseSym <> ", then re-inspect."
    ];
    Return[Missing["NotRun", "No " <> caseSym <> " data. " <> runHint]]
  ];
  scan = case["PolynomialScan"];
  title = If[label === Automatic, Lookup[case, "Label", "case"], label];
  zeroVars = Lookup[case, "ZeroVars", Lookup[scan, "ZeroVars", {}]];
  activeVars = Which[
    ! MatchQ[vars, Automatic], vars,
    KeyExistsQ[case, "RemainingVars"], case["RemainingVars"],
    KeyExistsQ[scan, "ActiveVars"], scan["ActiveVars"],
    True, Missing["SupplyVars"]
  ];
  fIn = Which[
    KeyExistsQ[case, "FRestricted"], case["FRestricted"],
    KeyExistsQ[scan, "InputPolynomial"], scan["InputPolynomial"],
    True, Missing["NoInputPolynomial"]
  ];
  ka = If[kinAssump === Automatic, True, kinAssump];
  kv = If[kinVars === Automatic, {}, kinVars];
  u = U;
  regionKind = If[zeroVars === {}, "interior", "boundary"];
  Print["\n=== ", title, " (polynomial obstruction, ", regionKind, ") ==="];
  If[zeroVars =!= {}, Print["  Boundary zero vars: ", zeroVars]];
  If[! MatchQ[activeVars, _Missing], Print["  Region vector (active x): ", activeVars]];
  If[! MatchQ[fIn, _Missing], Print["  Input polynomial: restricted F after zero vars"]];
  Print["  Successful obstruction decomposition? ", hrfSuccessfulObstructionDecompositionQ[scan]];
  Print["  Valid obstruction (F_SL in ideal)? ", hrfObstructionFoundQ[scan]];
  Print["  Exhaustive no-HR certificate? ", hrfObstructionSearchCertificateQ[scan]];
  If[KeyExistsQ[case, "KinematicLimit"], Print["  Kinematic limit preset: ", case["KinematicLimit"]]];
  If[KeyExistsQ[scan, "ObstructionAttemptSummary"],
    Module[{sum = scan["ObstructionAttemptSummary"]},
      Print["  Trials run: ", Lookup[sum, "TrialCount", "--"],
        " / candidates ", Lookup[sum, "CandidateGeneratorCount", "--"],
        "  (per-gen admissible ", Lookup[sum, "PerGeneratorAdmissibleCount", "--"],
        ", SL admissible ", Lookup[sum, "AdmissibleSLSectorCount", "--"],
        ", valid obstruction ", Lookup[sum, "ValidObstructionCount", "--"],
        ", hidden region(s) ", Lookup[sum, "HiddenRegionWithValidScalingCount", "--"], ")"];
      If[TrueQ[Lookup[scan, "CandidateGeneratorSetLimitReachedQ", False]],
        Print["  Warning: candidate cap reached; exhaustive certificate requires raising $HRFCandidateGeneratorSetLimit."];
      ];
    ]
  ];
  Print["  Cancellation factors: ", Length[Lookup[scan, "CancellationFactors", {}]]];
  Print["  Candidate sets: ", Lookup[scan, "CandidateGeneratorCount",
    Length[Lookup[scan, "CandidateGeneratorSets", {}]]]];
  Print["  Accepted generators: ", Length[Lookup[scan, "Generators", {}]]];
  Print["  AdmissibleGeneratorSetQ: ", Lookup[scan, "AdmissibleGeneratorSetQ", False]];
  Print["  HiddenRegionQ (poly): ", hrfPolyHiddenRegionQ[scan, Automatic]];
  If[KeyExistsQ[scan, "HiddenRegionCount"],
    Print["  Hidden region count (valid scaling): ", scan["HiddenRegionCount"]];
  ];
  If[ListQ[Lookup[scan, "HiddenRegionScans", {}]] && scan["HiddenRegionScans"] =!= {},
    Print["  Hidden region generator sets:"];
    Do[
      Print["    HR ", i, ": ", hrfPolynomialCompact /@ Lookup[scan["HiddenRegionScans"][[i]], "Generators", {}]],
      {i, Length[scan["HiddenRegionScans"]]}
    ];
  ,
    If[ListQ[Lookup[scan, "ValidTrialScalingEvaluations", {}]] &&
        scan["ValidTrialScalingEvaluations"] =!= {},
      Module[{pos = Select[scan["ValidTrialScalingEvaluations"], TrueQ[Lookup[#, "ValidScalingQ", False]] &]},
        If[pos =!= {},
          Print["  Scaling-positive valid trials:"];
          Do[
            Print["    trial ", Lookup[pos[[i]], "TrialIndex", i], ": ",
              hrfPolynomialCompact /@ Lookup[pos[[i]], "Generators", {}]],
            {i, Length[pos]}
          ];
        ];
      ];
    ]
  ];
  If[kv =!= {} && ! MatchQ[fIn, _Missing] && AssociationQ[Lookup[scan, "ObstructionData", Missing[]]],
    Module[{fsl = Expand @ Lookup[Lookup[scan, "ObstructionData", <||>], "Superleading", 0]},
      Print["  Mandelstam sectors in F_SL: ", Select[kv, ! FreeQ[fsl, #] &]];
    ]
  ];
  parts = hrfObstructionPolynomialParts[scan];
  If[parts =!= <||>,
    Module[{labels = hrfRestrictedF0Labels[zeroVars]},
      Print["  ", labels["Obstruction"], ": ", hrfPolynomialCompact[Lookup[parts, "Obstruction", "--"]]];
      Print["  ", labels["FSL"], ": ", hrfPolynomialCompact[Lookup[parts, "Superleading", "--"]]];
      If[! MatchQ[fIn, _Missing],
        Print["  ", labels["Reconstruction"], " ", hrfObstructionDecompositionConsistentQ[scan, fIn]];
      ];
    ];
  ];
  If[ListQ[Lookup[scan, "Generators", {}]] && ! MatchQ[activeVars, _Missing],
    slForm = hrfSuperleadingGeneratorForm[scan, activeVars, kv];
    If[AssociationQ[slForm],
      Print["  F_SL in generator ideal? ", slForm["InGeneratorIdealQ"]];
      Print["  F_SL in generator form: ", slForm["GeneratorFormCompact"]];
    ];
  ];
  gd = Lookup[scan, "GeneratorFactorData", {}];
  If[gd =!= {},
    Print["\n--- Generator / f_k breakdown ---"];
    Print[Dataset @ Table[
      <|
        "Generator" -> hrfPolynomialCompact[Lookup[gd[[i]], "Generator", "--"]],
        "FactorCount" -> Lookup[gd[[i]], "GeneratorFactorCount", "--"],
        "MaxVarExponent" -> Lookup[gd[[i]], "MaxVarExponent", "--"],
        "MasslessMonomialOK" -> Lookup[gd[[i]], "MasslessMonomialAdmissibleQ", "--"],
        "AdmissibleGeneratorQ" -> Lookup[gd[[i]], "AdmissibleGeneratorQ", False],
        "Factors" -> StringRiffle[
          hrfPolynomialCompact /@ Lookup[gd[[i]], "GeneratorFactors", {}], " * "]
      |>,
      {i, Length[gd]}
    ]];
  ];
  If[KeyExistsQ[scan, "ObstructionAttemptData"] && scan["ObstructionAttemptData"] =!= {},
    Print["\n--- Trial log ---"];
    Print[hrfPolyGeneratorTrialTable[scan, title]];
  ,
    If[ListQ[Lookup[scan, "GeneratorSetScalingSummary", {}]] &&
        scan["GeneratorSetScalingSummary"] =!= {},
      Print["\n--- Generator sets / scaling (compact summary; full trial log trimmed) ---"];
      Print[hrfPolyGeneratorSetScalingTable[scan, title <> " / all trials"]];
      Print["\n--- Admissible generator sets only ---"];
      Print[hrfPolyAdmissibleGeneratorSetTable[scan, title <> " / admissible"]];
    ]
  ];
  If[! MatchQ[activeVars, _Missing] && ! MissingQ[u],
    Module[{row, sc, diag},
      row = hrfEx04RegionStudyRow[scan, title, activeVars, ka, kv, u, zeroVars];
      sc = hrfCoverageData[scan, u, activeVars, 5];
      diag = hrfSelectedDiagnostic[sc];
      If[AssociationQ[diag] && KeyExistsQ[diag, "FObsLeadingWeights"],
        Print["  W_FObs leading (at selected scaling): ",
          With[{w = diag["FObsLeadingWeights"]},
            If[ListQ[w] && w =!= {}, Min[w], w]
          ]
        ];
      ];
      If[AssociationQ[diag] && KeyExistsQ[diag, "HierarchyGapPostLPminusFSL"],
        Print["  Hierarchy gap W_HR - W_SL: ", diag["HierarchyGapPostLPminusFSL"]];
      ];
      If[AssociationQ[sc] && KeyExistsQ[sc, "ScalingStatusMessage"],
        Print["  Scaling status: ", sc["ScalingStatusMessage"]];
      ];
      If[AssociationQ[sc],
        Print["  Scaling vector: ", hrfCompact @ hrfResolvedScalingVector[sc]];
        Print["  Variable scaling: ", hrfCompact @ hrfResolvedVariableScaling[sc, activeVars]];
      ];
      Print["\n--- Region / scaling summary ---"];
      Print[Dataset[{row}]];
    ];
  ,
    Print["\n(Supply vars, kinAssump, kinVars, U for region vector and scaling row.)"];
  ];
  scan
];

hrfEx04RegionStudyRow[scan_, label_, vars_, kinAssump_, kinVars_, U_, zeroVars_: {},
   opts:OptionsPattern[]] := Module[{sc, config, skipQ},
  If[! AssociationQ[scan],
    Return[<|
      "Case" -> label,
      "Hidden region identified?" -> "No",
      "Comment" -> "No obstruction scan (run setup In[1] and wait for '=== Example 01 CORE LOAD COMPLETE ===').",
      "Error" -> "InvalidScan",
      "ScanHead" -> Head[scan]
    |>]
  ];
  skipQ = TrueQ[OptionValue["SkipCoverageScalingQ"]] || TrueQ[$HRFEx04DeferCoverageScalingQ];
  sc = Which[
    skipQ, <|"ScalingStatusMessage" -> "Deferred (run hrfEx04InspectPolynomialScan for coverage LP)"|>,
    hrfScanCoverageScalingReadyQ[scan],
      scan["CoverageScalingData"],
    KeyExistsQ[scan, "CoverageScalingData"] && AssociationQ[hrfScalingDataAssoc @ scan["CoverageScalingData"]],
      scan["CoverageScalingData"],
    True,
      With[{raw = hrfAttachCoverageScalingData[scan, U, vars, 5]["CoverageScalingData"]},
        If[AssociationQ[raw], raw, <|"ScalingStatusMessage" -> "No scaling data"|>]
      ]
  ];
  config = If[zeroVars === {}, "Interior", "Boundary " <> ToString[InputForm[zeroVars]]];
  hrfHiddenSummaryRow[label, config, zeroVars, vars, scan, sc]
];

Options[hrfEx04RegionStudyRow] = {"SkipCoverageScalingQ" -> False};

hrfEx04CrownSanityColumns[] := {
  "Region vector", "Hidden region identified?", "Generators", "Scaling status",
  "Scaling vector", "Variable scaling by region variable", "W_SL", "W_HR",
  "Variables at W_SL", "Variables at W_HR", "Comment"
};

hrfEx04CrownSanityDisplay[] := Module[{case, scan, row, cols, ds},
  cols = hrfEx04CrownSanityColumns[];
  If[! ValueQ[Ex04CrownRegression] || ! AssociationQ[Ex04CrownRegression],
    Return @ Dataset @ {<|
      "Message" -> "Ex04CrownRegression not loaded. Evaluate setup (Example 01 In[1] / your In[2]) and wait for '=== Example 01 CORE LOAD COMPLETE ==='."
    |>}
  ];
  case = Ex04CrownRegression;
  scan = Lookup[case, "PolynomialScan", Missing["NoPolynomialScan"]];
  If[! AssociationQ[scan],
    Return @ Dataset @ {<|
      "Message" -> "Crown polynomial scan missing. Re-run setup In[1]; check $HRFEx04RunObstructionSearchQ = True before Get[04_PolynomialFactor_Regression.wl]."
    |>}
  ];
  If[Length[DownValues[hrfEx04RegionStudyRow]] === 0,
    Return @ Dataset @ {<|
      "Message" -> "hrfEx04RegionStudyRow not defined. Get[04_PolynomialFactor_Regression.wl] did not load — re-run setup In[1]."
    |>}
  ];
  row = hrfEx04RegionStudyRow[
    scan, "Crown interior sanity", VarsCrown, KinAssump4ptOnShell, KinVars4pt,
    CrownData["UF"]["U"], {}
  ];
  If[! AssociationQ[row],
    Return @ Dataset @ {<|"Message" -> "Region study row failed.", "Detail" -> row|>}
  ];
  ds = Dataset[{KeyTake[row, cols]}];
  Print["Crown sanity: hidden region=", Lookup[row, "Hidden region identified?", "--"],
    "; generators=", Lookup[row, "Generators", "--"],
    "; scaling=", Lookup[row, "Scaling status", "--"]];
  ds
];

hrfEx04ShouldBuildGeneratorPairTableQ[scan_Association] := Module[{n},
  n = Length[Lookup[scan, "CancellationFactors", {}]];
  TrueQ[$HRFEx04BuildGeneratorPairTablesQ] ||
    (IntegerQ[$HRFEx04GeneratorPairTableMaxFactors] && $HRFEx04GeneratorPairTableMaxFactors > 0 &&
      n >= 2 && n <= $HRFEx04GeneratorPairTableMaxFactors)
];

hrfEx04GeneratorPairTable[case_Association, mode_String, vars_, kinAssump_, kinVars_] := Module[
  {scanKey = mode <> "Scan", scan},
  If[! AssociationQ[case] || ! KeyExistsQ[case, scanKey],
    Return[Missing["NotRun", "Case not populated. Run regression setup or the slow-case section first."]]
  ];
  scan = case[scanKey];
  ff = Lookup[scan, "CancellationFactors", {}];
  If[Length[ff] < 2,
    Return[Dataset[{<|"Note" -> "Fewer than 2 cancellation factors; no pair generators."|>}]]
  ];
  If[! hrfEx04ShouldBuildGeneratorPairTableQ[scan],
    Return[Missing["Deferred",
      "Too many cancellation factors (" <> ToString[Length[Lookup[scan, "CancellationFactors", {}]]] <>
        "). Set $HRFEx04BuildGeneratorPairTablesQ=True and re-evaluate hrfEx04GeneratorPairTable[...], or raise $HRFEx04GeneratorPairTableMaxFactors."]]
  ];
  hrfPolyGeneratorPairTable[scan, vars, kinAssump, kinVars]
];

hrfEx04ThreeMonomialPairAudit[case_: Automatic] := Module[{c, scan, vars},
  c = Which[
    case === Automatic,
      If[hrfEx04CasePopulatedQ[Ex04HyperCrownX11Target], Ex04HyperCrownX11Target,
        Return[Missing["NotRun", "Evaluate hrfEx04HyperCrownX11Target[] first, or pass a populated case."]]
      ],
    AssociationQ[case], case,
    True, Return[Missing["InvalidCase", "Pass Ex04HyperCrownX11Target or another Example 04 case association."]]
  ];
  If[! KeyExistsQ[c, "PolynomialScan"],
    Return[Missing["NotRun", "Case has no PolynomialScan. Run the matching hrfEx04*[] cell first."]]
  ];
  scan = c["PolynomialScan"];
  vars = Lookup[c, "RemainingVars", Lookup[scan, "ActiveVars", {}]];
  hrfPolyThreeMonomialPairAudit[scan, vars, KinAssump4ptOnShell, KinVars4pt]
];

hrfEx04ScanInMode[mode_String, F_, vars_, kinAssump_, kinVars_, maxSize_:Automatic,
   kinLimit_: Automatic, stopOnFirstAdmissible_: Automatic, U_: Automatic] := Block[
  {$HRFUsePolynomialCancellationFactors = (mode === "Polynomial")},
  hrfEx04ReinstallPolynomialPatch[];
  Module[{degreeOpts, degreeBounds, ff, scan, limit = kinLimit},
    If[limit === Automatic, limit = hrfKinematicLimitFromKinVars[kinVars]];
    degreeOpts = <|
      "MaxGeneratorTotalDegree" -> Automatic,
      "MaxGeneratorVarExponent" -> Automatic,
      "CandidateGeneratorSetLimit" -> $HRFCandidateGeneratorSetLimit
    |>;
    degreeBounds = hrfResolveGeneratorDegreeBounds[F, vars, degreeOpts];
    ff = If[mode === "Polynomial",
      hrfSafeCancellationFactorsPolynomial[F, vars, kinAssump, kinVars, Automatic][[1]],
      hrfBinomialOnlySafeFactorsExtended[F, vars, kinAssump, kinVars, Automatic][[1]]
    ];
    scan = If[! TrueQ[$HRFEx04RunObstructionSearchQ],
      <|
        "CancellationFactors" -> ff,
        "GeneratorDegreeBounds" -> degreeBounds,
        "CandidateGeneratorCount" -> 0,
        "Generators" -> {},
        "ObstructionData" -> Missing["Deferred", "Obstruction search disabled ($HRFEx04RunObstructionSearchQ=False)"],
        "AdmissibleGeneratorSetQ" -> False,
        "ObstructionAttemptData" -> {}
      |>,
      findObstructions[
        F, vars, kinAssump, kinVars, maxSize,
        "UseExtendedFactors" -> hrfKinematicLimitUseExtendedFactorsQ[limit],
        Sequence @@ hrfKinematicLimitObstructionOptions[limit],
        "StopOnFirstAdmissible" -> Which[
          stopOnFirstAdmissible =!= Automatic, stopOnFirstAdmissible,
          True, TrueQ[$HRFFindObstructionsStopOnFirstAdmissibleQ]
        ],
        "U" -> U,
        "CandidateGeneratorSetLimit" -> $HRFCandidateGeneratorSetLimit,
        "StoreAllObstructionTrialsQ" -> ! TrueQ[$HRFEx04TrimScanStorageQ],
        Sequence @@ hrfEx04ObstructionOptions[kinVars]
      ]
    ];
    Join[hrfAttachBoundaryScanContext[scan, F, vars, {}], <|"KinVars" -> kinVars, "KinematicLimit" -> limit|>]
  ]
];

hrfEx04FactorSupportStudy[F_, vars_, kinAssump_, kinVars_, label_] := Module[
  {diff, binSupport, polySupport, rows, kinMixed, f0OK},
  diff = hrfPolynomialFactorAudit[F, vars, kinAssump, kinVars, Automatic];
  binSupport = hrfFactorF0SupportAudit[F, vars, kinAssump, kinVars, "Binomial"];
  polySupport = hrfFactorF0SupportAudit[F, vars, kinAssump, kinVars, "Polynomial"];
  rows = Normal[polySupport];
  kinMixed = Count[rows, _?(TrueQ[Lookup[#, "ContainsKinVarsQ", False]] &)];
  f0OK = Count[rows, _?(TrueQ[Lookup[#, "AllTermsInF0UpToXMonomialQ", False]] &)];
  <|
    "Label" -> label,
    "FactorDiff" -> diff,
    "BinomialFactorSupportAudit" -> binSupport,
    "PolynomialFactorSupportAudit" -> polySupport,
    "SupportSummary" -> <|
      "PolynomialFactorCount" -> Length[rows],
      "KinVarsInsideFactorCount" -> kinMixed,
      "AllTermsInF0UpToXMonomialCount" -> f0OK,
      "Note" -> "Generator rules: PDF (5.12), degree bounds, and F0 monomial support (each g monomial matches some F0 term after s12/s23 and optional extra x_i)."
    |>
  |>
];

hrfEx04CrownFactorSupportAudit[] := Module[{},
  hrfEx04LoadExample01[];
  hrfEx04FactorSupportStudy[F0Crown, VarsCrown, KinAssump4ptOnShell, KinVars4pt, "Crown interior"]
];

hrfEx04CompareModes[F_, vars_, kinAssump_, kinVars_, label_, maxSize_:Automatic, zeroVars_: {}, U_:Automatic,
   kinLimit_: Automatic, stopOnFirstAdmissible_: Automatic] := Module[
  {fWork, varsWork, diff, binScan, polyScan, binFactors, polyFactors, attachScaling},
  fWork = If[zeroVars === {}, Expand[F], Expand[F /. Thread[zeroVars -> 0]]];
  varsWork = If[zeroVars === {}, vars, Complement[vars, zeroVars]];
  attachScaling[scan_] := If[! MatchQ[U, Automatic | Missing] && ! hrfScanCoverageScalingReadyQ[scan],
    hrfAttachCoverageScalingData[scan, U, varsWork, 5],
    scan
  ];
  diff = hrfPolynomialFactorAudit[fWork, varsWork, kinAssump, kinVars, Automatic];
  binScan = attachScaling @ hrfAttachBoundaryScanContext[
    hrfEx04ScanInMode["Binomial", fWork, varsWork, kinAssump, kinVars, maxSize, kinLimit, stopOnFirstAdmissible, U],
    fWork, varsWork, zeroVars
  ];
  polyScan = hrfEx04TrimPolynomialScan @ attachScaling @ hrfAttachBoundaryScanContext[
    hrfEx04ScanInMode["Polynomial", fWork, varsWork, kinAssump, kinVars, maxSize, kinLimit, stopOnFirstAdmissible, U],
    fWork, varsWork, zeroVars
  ];
  binFactors = hrfPolyFactorAuditForMode[fWork, varsWork, kinAssump, kinVars, "Binomial"];
  polyFactors = hrfPolyFactorAuditForMode[fWork, varsWork, kinAssump, kinVars, "Polynomial"];
  <|
    "Label" -> label,
    "ZeroVars" -> zeroVars,
    "FRestricted" -> fWork,
    "RemainingVars" -> varsWork,
    "FactorDiff" -> diff,
    "BinomialScan" -> binScan,
    "PolynomialScan" -> polyScan,
    "ComparisonRow" -> hrfPolyModeComparisonRow[label, binScan, polyScan, diff, zeroVars],
    "GeneratorAudit" -> <|
      "Binomial" -> hrfPolyGeneratorAuditRow[binScan, label <> " / binomial"],
      "Polynomial" -> hrfPolyGeneratorAuditRow[polyScan, label <> " / polynomial"]
    |>,
    "GeneratorTrialTable" -> <|
      "Binomial" -> hrfPolyGeneratorTrialTable[binScan, label <> " / binomial"],
      "Polynomial" -> hrfPolyGeneratorTrialTable[polyScan, label <> " / polynomial"]
    |>,
    "FactorSupportAudit" -> <|
      "Binomial" -> hrfFactorF0SupportAudit[fWork, varsWork, kinAssump, kinVars, "Binomial"],
      "Polynomial" -> hrfFactorF0SupportAudit[fWork, varsWork, kinAssump, kinVars, "Polynomial"]
    |>,
    "GeneratorPairTable" -> <|
      "Binomial" -> Module[{ff = Lookup[binScan, "CancellationFactors", {}]},
        Which[
          Length[ff] < 2, Dataset[{<|"Note" -> "Fewer than 2 cancellation factors; no pair generators."|>}],
          hrfEx04ShouldBuildGeneratorPairTableQ[binScan],
            hrfPolyGeneratorPairTable[binScan, vars, kinAssump, kinVars],
          True,
            Missing["Deferred",
              "Pair table skipped (" <> ToString[Length[ff]] <>
                " factors). Set $HRFEx04BuildGeneratorPairTablesQ=True or use hrfEx04GeneratorPairTable[case, \"Binomial\", ...]."]
        ]
      ],
      "Polynomial" -> Module[{ff = Lookup[polyScan, "CancellationFactors", {}]},
        Which[
          Length[ff] < 2, Dataset[{<|"Note" -> "Fewer than 2 cancellation factors; no pair generators."|>}],
          hrfEx04ShouldBuildGeneratorPairTableQ[polyScan],
            hrfPolyGeneratorPairTable[polyScan, vars, kinAssump, kinVars],
          True,
            Missing["Deferred",
              "Pair table skipped (" <> ToString[Length[ff]] <>
                " factors). Set $HRFEx04BuildGeneratorPairTablesQ=True or use hrfEx04GeneratorPairTable[case, \"Polynomial\", ...]."]
        ]
      ]
    |>,
    "GeneratorPhysicsSummary" -> Module[{bounds, phys},
      bounds = Lookup[polyScan, "GeneratorDegreeBounds", hrfResolveGeneratorDegreeBounds[F, vars, <||>]];
      phys = hrfFilterFactorsForGeneratorPhysics[Lookup[polyScan, "CancellationFactors", {}], vars, kinVars, bounds];
      <|
        "RawFactorCount" -> Length[Lookup[polyScan, "CancellationFactors", {}]],
        "PhysicsEligibleFactorCount" -> Length[phys["Factors"]],
        "SpanRedundantKinMixedDropped" -> Length[phys["SpanRedundantKinMixed"]],
        "PhysicsAdmissiblePairCount" -> Count[
          Subsets[phys["Factors"], {2}],
          hrfGeneratorPairPhysicsAdmissibleQ[#[[1]], #[[2]], bounds, vars, kinVars] &
        ],
        "ModuleRedundantKinMixedPairDropped" -> Module[{pairs, dedup},
          pairs = Select[
            Subsets[phys["Factors"], {2}],
            simultaneouslyAdmissibleSubsetQ[#, vars, kinAssump, kinVars] &&
              hrfGeneratorPairPhysicsAdmissibleQ[#[[1]], #[[2]], bounds, vars, kinVars] &
          ];
          dedup = hrfFilterAdmissiblePairsModuleDedup[
            pairs,
            phys["KinFreeFactors"],
            vars,
            kinVars
          ];
          Length[dedup["ModuleRedundantKinMixedPairs"]]
        ],
        "SectorQuotientCanonicalGenerators" -> Module[{pairs, pairGens, kinFreePairGens, quot},
          pairs = Select[
            Subsets[phys["Factors"], {2}],
            simultaneouslyAdmissibleSubsetQ[#, vars, kinAssump, kinVars] &&
              hrfGeneratorPairPhysicsAdmissibleQ[#[[1]], #[[2]], bounds, vars, kinVars] &
          ];
          pairGens = Expand[Times @@@ pairs];
          kinFreePairGens = Expand[Times @@@ Select[pairs,
            ! hrfFactorContainsKinVarsQ[#[[1]], kinVars] &&
              ! hrfFactorContainsKinVarsQ[#[[2]], kinVars] &
          ]];
          quot = hrfCanonicalizeGeneratorsModKinSectors[pairGens, kinFreePairGens, vars, kinVars];
          quot["CanonicalCount"]
        ],
        "SectorQuotientRedundantGenerators" -> Module[{pairs, pairGens, kinFreePairGens, quot},
          pairs = Select[
            Subsets[phys["Factors"], {2}],
            simultaneouslyAdmissibleSubsetQ[#, vars, kinAssump, kinVars] &&
              hrfGeneratorPairPhysicsAdmissibleQ[#[[1]], #[[2]], bounds, vars, kinVars] &
          ];
          pairGens = Expand[Times @@@ pairs];
          kinFreePairGens = Expand[Times @@@ Select[pairs,
            ! hrfFactorContainsKinVarsQ[#[[1]], kinVars] &&
              ! hrfFactorContainsKinVarsQ[#[[2]], kinVars] &
          ]];
          quot = hrfCanonicalizeGeneratorsModKinSectors[pairGens, kinFreePairGens, vars, kinVars];
          quot["RedundantCount"]
        ]
      |>
    ],
    "AcceptedFactors" -> <|
      "Binomial" -> hrfPolyAcceptedFactorTable[binScan],
      "Polynomial" -> hrfPolyAcceptedFactorTable[polyScan]
    |>,
    "FactorAuditDataset" -> polyFactors["Accepted"],
    "RejectedFactorAuditDataset" -> polyFactors["Rejected"],
    "BinomialRejectedFactorAuditDataset" -> binFactors["Rejected"]
  |>
];

hrfEx04PolynomialOnlyCase[F_, vars_, kinAssump_, kinVars_, label_, maxSize_:Automatic, zeroVars_: {}, U_:Automatic,
   kinLimit_: Automatic, stopOnFirstAdmissible_: Automatic, lightweight_: Automatic] := Module[
  {fWork, varsWork, polyScan, polyFactors, attachScaling, limit = kinLimit, lightQ},
  fWork = If[zeroVars === {}, Expand[F], Expand[F /. Thread[zeroVars -> 0]]];
  varsWork = If[zeroVars === {}, vars, Complement[vars, zeroVars]];
  If[limit === Automatic, limit = hrfKinematicLimitFromKinVars[kinVars]];
  lightQ = Which[
    lightweight =!= Automatic, TrueQ[lightweight],
    True, TrueQ[$HRFEx04LightweightCaseQ]
  ];
  attachScaling[scan_] := If[! MatchQ[U, Automatic | Missing] && ! lightQ &&
      ! hrfScanCoverageScalingReadyQ[scan],
    hrfAttachCoverageScalingData[scan, U, varsWork, 5],
    scan
  ];
  hrfEx04ReinstallPolynomialPatch[];
  polyScan = hrfEx04TrimPolynomialScan @ attachScaling @ hrfAttachBoundaryScanContext[
    hrfEx04ScanInMode["Polynomial", fWork, varsWork, kinAssump, kinVars, maxSize, limit, stopOnFirstAdmissible, U],
    fWork, varsWork, zeroVars
  ];
  polyFactors = If[lightQ, Missing["LightweightCase"], hrfPolyFactorAuditForMode[fWork, varsWork, kinAssump, kinVars, "Polynomial"]];
  <|
    "Label" -> label,
    "KinematicLimit" -> limit,
    "ZeroVars" -> zeroVars,
    "FRestricted" -> fWork,
    "RemainingVars" -> varsWork,
    "FactorDiff" -> Missing["NotRun", "Binomial compare skipped ($HRFEx04CompareBinomialQ=False)"],
    "BinomialScan" -> Missing["NotRun", "Binomial compare skipped ($HRFEx04CompareBinomialQ=False)"],
    "PolynomialScan" -> polyScan,
    "ComparisonRow" -> hrfPolyModeComparisonRow[label, Missing["NotRun"], polyScan,
      <|"Mode" -> "PolynomialOnly"|>, zeroVars],
    "GeneratorAudit" -> If[lightQ, Missing["LightweightCase"],
      <|"Polynomial" -> hrfPolyGeneratorAuditRow[polyScan, label <> " / polynomial"]|>],
    "GeneratorTrialTable" -> If[lightQ, Missing["LightweightCase"],
      <|"Polynomial" -> hrfPolyGeneratorTrialTable[polyScan, label <> " / polynomial"]|>],
    "FactorSupportAudit" -> If[lightQ, Missing["LightweightCase"],
      <|"Polynomial" -> hrfFactorF0SupportAudit[fWork, varsWork, kinAssump, kinVars, "Polynomial"]|>],
    "AcceptedFactors" -> <|"Polynomial" -> hrfPolyAcceptedFactorTable[polyScan]|>,
    "FactorAuditDataset" -> If[lightQ, Missing["LightweightCase"], polyFactors["Accepted"]],
    "RejectedFactorAuditDataset" -> If[lightQ, Missing["LightweightCase"], polyFactors["Rejected"]]
  |>
];

hrfEx04RunObstructionCase[F_, vars_, kinAssump_, kinVars_, label_, maxSize_, zeroVars_, U_, kinLimit_: Automatic] := Module[{case, t0, limit = kinLimit},
  If[limit === Automatic, limit = hrfKinematicLimitFromKinVars[kinVars]];
  hrfEx04Say[label <> "  [" <> limit <> ", " <> hrfKinematicLimitDescription[limit] <> "]  (started " <>
    DateString[{"Hour24", ":", "Minute", ":", "Second"}] <> ")"];
  t0 = AbsoluteTime[];
  case = Block[{$HRFEx04ObstructionProgressQ = TrueQ[$HRFExample04Report]},
    If[TrueQ[$HRFEx04CompareBinomialQ],
      hrfEx04CompareModes[F, vars, kinAssump, kinVars, label, maxSize, zeroVars, U, limit],
      hrfEx04PolynomialOnlyCase[F, vars, kinAssump, kinVars, label, maxSize, zeroVars, U, limit]
    ]
  ];
  hrfEx04Say[label <> "  (done; " <> ToString[NumberForm[AbsoluteTime[] - t0, {6, 1}]] <> " s)"];
  case
];

hrfEx04LoadExample01[] := Module[{},
  If[! ValueQ[F0Crown],
    Block[{
      $HRFExample01Report = False,
      $HRFRunCrownInteriorScanOnLoad = False,
      $HRFRunExample01ReportingOnLoad = False,
      $HRFRunScalingDiagnostics = False,
      $HRFRunHyperCrownInteriorScan = False,
      $HRFRunHyperCrownBoundaryScansOnLoad = False,
      $HRFRunSuperCrownInteriorScan = False,
      $HRFRunSuperCrownBoundaryScanOnLoad = False,
      $HRFRunDivingBeetleDiagnosticsOnLoad = False,
      $HRFRunDivingBeetleInteriorScanOnLoad = False
    },
      Get[FileNameJoin[{$HRFExample04Directory, "01_WideAngle_2to2_OffShell.wl"}]]
    ]
  ];
  hrfEx04ReinstallPolynomialPatch[];
  True
];

hrfEx04LoadExample03Core[] := Module[{},
  If[! ValueQ[F0Seed5pt],
    hrfEx04Say["loading HRF_Example03CollinearCore.wl (seed + ThreeLoopVertex only)."];
    Get[FileNameJoin[{$HRFExample04Directory, "HRF_Example03CollinearCore.wl"}]]
  ];
  hrfEx04ReinstallPolynomialPatch[];
  True
];

SetAttributes[hrfEx04StoreCase, HoldFirst];
hrfEx04StoreCase[s_Symbol, case_Association] := (s = case; case);

hrfEx04CrownRegression[] := Module[{case},
  hrfEx04LoadExample01[];
  case = hrfEx04RunObstructionCase[
    F0Crown, VarsCrown, KinAssump4ptOnShell, KinVars4pt,
    "Crown interior regression", Automatic, {}, CrownData["UF"]["U"]
  ];
  hrfEx04StoreCase[Ex04CrownRegression, case]
];

hrfEx04SuperCrownInterior[] := Module[{case},
  hrfEx04LoadExample01[];
  case = hrfEx04RunObstructionCase[
    F0SuperCrown, VarsSuperCrown, KinAssump4ptOnShell, KinVars4pt,
    "SuperCrown interior", 30, {}, Automatic
  ];
  hrfEx04StoreCase[Ex04SuperCrownInterior, case]
];

hrfEx04HyperCrownInterior[] := Module[{case},
  hrfEx04LoadExample01[];
  case = hrfEx04RunObstructionCase[
    F0HyperCrown, VarsHyperCrown, KinAssump4ptOnShell, KinVars4pt,
    "HyperCrown interior", 20, {}, HyperCrownData["UF"]["U"], "WideAngle4ptExhaustive"
  ];
  hrfEx04StoreCase[Ex04HyperCrownInterior, case]
];

hrfEx04HyperCrownX11Target[] := Module[{case},
  hrfEx04LoadExample01[];
  case = Block[
    {$HRFEx04LightweightCaseQ = True, $HRFPolynomialEnableSignedMonomialPairs = False},
    hrfEx04RunObstructionCase[
      F0HyperCrown, VarsHyperCrown, KinAssump4ptOnShell, KinVars4pt,
      "HyperCrown boundary {x11}=0", Automatic, {x11},
      Expand[HyperCrownData["UF"]["U"] /. x11 -> 0], "WideAngle4ptBoundary"
    ]
  ];
  hrfEx04StoreCase[Ex04HyperCrownX11Target, case]
];

hrfEx04DivingBeetleInterior[] := Module[{case},
  hrfEx04LoadExample01[];
  case = hrfEx04RunObstructionCase[
    F0DB, VarsDB, KinAssump4ptOnShell, KinVars4pt,
    "Diving Beetle interior", 20, {}, DBData["UF"]["U"], "WideAngle4ptExhaustive"
  ];
  hrfEx04StoreCase[Ex04DivingBeetleInterior, case]
];

hrfEx04DivingBeetleX89Boundary[] := Module[{case},
  hrfEx04LoadExample01[];
  case = Block[
    {$HRFEx04LightweightCaseQ = True, $HRFPolynomialEnableSignedMonomialPairs = False},
    hrfEx04RunObstructionCase[
      F0DB, VarsDB, KinAssump4ptOnShell, KinVars4pt,
      "Diving Beetle boundary {x8,x9}=0", 20, {x8, x9},
      Expand[DBData["UF"]["U"] /. {x8 -> 0, x9 -> 0}], "WideAngle4ptBoundary"
    ]
  ];
  hrfEx04StoreCase[Ex04DivingBeetleX89Target, case]
];

hrfEx04FivePointLeadingU[target_String : "Seed5pt"] := Module[{},
  hrfEx04LoadExample03Core[];
  Switch[target,
    "Seed" | "Seed5pt",
      hrfEx03LeadingDeltaPolynomial[Expand[USeed5pt /. collPar1]],
    "ThreeLoopVertex" | "Vertex",
      hrfEx03LeadingDeltaPolynomial[Expand[UThreeLoopVertex5pt /. collPar1]],
    _, Missing["UnknownFivePointTarget", target]
  ]
];

hrfEx04FivePointGeneratorStats[scan_Association] := hrfPolyFivePointGeneratorStats[scan];

hrfEx04InspectFivePointCase[case_Association, target_String : "Seed5pt"] := Module[{vars, u},
  If[! AssociationQ[case] || case === <||>, Return[Missing["NotRun", "Evaluate the matching hrfEx04*Interior[] cell first."]]];
  hrfEx04LoadExample03Core[];
  vars = Switch[target,
    "ThreeLoopVertex" | "Vertex", VarsThreeLoopVertex5pt,
    _, VarsSeed5pt
  ];
  u = hrfEx04FivePointLeadingU[target];
  hrfEx04InspectPolynomialScan[case, Automatic, vars, KinAssump, KinVars, u]
];

hrfEx04FivePointFactorDiffTable[] := Module[{seedDiff, vertexDiff},
  hrfEx04LoadExample03Core[];
  seedDiff = hrfPolynomialFactorAudit[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars, Automatic];
  vertexDiff = hrfPolynomialFactorAudit[F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars, Automatic];
  Dataset @ {
    <|"Case" -> "Seed5pt", Sequence @@ Normal @ hrfPolyFactorDiffDisplayRow[seedDiff]|>,
    <|"Case" -> "ThreeLoopVertex", Sequence @@ Normal @ hrfPolyFactorDiffDisplayRow[vertexDiff]|>
  }
];

hrfEx04BuildFivePointComparison[] := Module[{cases},
  cases = {hrfEx04Seed5ptInterior[], hrfEx04ThreeLoopVertexInterior[]};
  Ex04FivePointComparison = hrfEx04FivePointComparisonDisplay[cases];
  hrfEx04Say["five-point comparison ready; evaluate Ex04FivePointComparison."];
  cases
];

hrfEx04Seed5ptInterior[] := Module[{case},
  hrfEx04LoadExample03Core[];
  case = hrfEx04RunObstructionCase[
    F0Seed5pt, VarsSeed5pt, KinAssump, KinVars,
    "Seed5pt collinear interior", Automatic, {}, hrfEx04FivePointLeadingU["Seed5pt"], "Collinear5pt"
  ];
  hrfEx04StoreCase[Ex04Seed5ptInterior, case]
];

hrfEx04ThreeLoopVertexInterior[] := Module[{case},
  hrfEx04LoadExample03Core[];
  case = hrfEx04RunObstructionCase[
    F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars,
    "ThreeLoopVertex collinear interior", Automatic, {},
    hrfEx04FivePointLeadingU["ThreeLoopVertex"], "Collinear5pt"
  ];
  hrfEx04StoreCase[Ex04ThreeLoopVertexInterior, case]
];

hrfEx04BuildRegressionTable[] := Module[{rows = {}, cases = {}, t0, runCase, includeSlow},
  includeSlow = TrueQ[$HRFRunEx04SlowCasesOnLoad];
  hrfEx04Say["building regression table; slow cases=" <> ToString[includeSlow] <>
    "; $HRFExample04Report = " <> ToString[TrueQ[$HRFExample04Report]]];
  hrfEx04Say["fast cases: Crown, SuperCrown, HyperCrown {x11}=0."];
  If[includeSlow,
    hrfEx04Say["slow cases enabled: HyperCrown interior, Seed5pt, ThreeLoopVertex."],
    hrfEx04Say["slow cases skipped (set $HRFRunEx04SlowCasesOnLoad=True for full regression)."]
  ];
  runCase[label_, expr_] := Module[{},
    hrfEx04Say[label <> "  (started " <> DateString[{"Hour24", ":", "Minute", ":", "Second"}] <> ")"];
    t0 = AbsoluteTime[];
    AppendTo[cases, expr];
    hrfEx04Say[label <> "  (done; " <> ToString[NumberForm[AbsoluteTime[] - t0, {6, 1}]] <> " s)"];
  ];
  runCase["Crown interior regression.", hrfEx04CrownRegression[]];
  runCase["SuperCrown interior.", hrfEx04SuperCrownInterior[]];
  If[includeSlow,
    runCase["HyperCrown interior (slow; many obstruction trials).", hrfEx04HyperCrownInterior[]]
  ];
  runCase["HyperCrown boundary {x11}=0 target.", hrfEx04HyperCrownX11Target[]];
  If[TrueQ[$HRFRunEx04FivePointOnLoad] && includeSlow,
    runCase["Seed5pt collinear interior.", hrfEx04Seed5ptInterior[]];
    runCase["ThreeLoopVertex collinear interior.", hrfEx04ThreeLoopVertexInterior[]];
  ];
  rows = Lookup[#, "ComparisonRow", <||>] & /@ cases;
  <|
    "Cases" -> cases,
    "ComparisonTable" -> hrfPolyModeComparisonTable[rows],
    "Narrative" -> hrfPolyRegressionSummaryNarrative[rows],
    "FivePointComparison" -> hrfEx04FivePointComparisonDisplay[cases]
  |>
];

hrfEx04Say["ready. Evaluate hrfEx04BuildRegressionTable[] or reload to populate Ex04PolynomialRegression*."];

If[! ValueQ[$HRFRunEx04RegressionOnLoad], $HRFRunEx04RegressionOnLoad = False];

hrfEx04AssignRegressionResults[reg_] := Module[{cases},
  cases = Lookup[reg, "Cases", {}];
  Ex04PolynomialRegression = reg;
  Ex04PolynomialRegressionTable = reg["ComparisonTable"];
  Ex04PolynomialRegressionNarrative = reg["Narrative"];
  Ex04FivePointComparison = Lookup[reg, "FivePointComparison", Missing["NotRun"]];
  Ex04CrownRegression = FirstCase[cases, c_ /; c["Label"] === "Crown interior regression", <||>];
  Ex04SuperCrownInterior = FirstCase[cases, c_ /; StringContainsQ[c["Label"], "SuperCrown interior"], <||>];
  Ex04HyperCrownInterior = FirstCase[cases, c_ /; StringContainsQ[c["Label"], "HyperCrown interior"], <||>];
  Ex04HyperCrownX11Target = FirstCase[cases, c_ /; StringContainsQ[c["Label"], "HyperCrown boundary"], <||>];
  Ex04Seed5ptInterior = FirstCase[cases, c_ /; StringContainsQ[c["Label"], "Seed5pt"], <||>];
  Ex04ThreeLoopVertexInterior = FirstCase[cases, c_ /; StringContainsQ[c["Label"], "ThreeLoopVertex"], <||>];
  Ex04CrownFactorSupport = Lookup[Ex04CrownRegression, "FactorSupportAudit", <||>];
];

If[TrueQ[$HRFRunEx04RegressionOnLoad],
  hrfEx04Say["building fast regression table on load (set $HRFRunEx04SlowCasesOnLoad=True for slow cases)."];
  hrfEx04AssignRegressionResults[hrfEx04BuildRegressionTable[]];
  Print[Ex04PolynomialRegressionNarrative];
  If[MatchQ[Ex04FivePointComparison, _Dataset],
    Print["Five-point interior comparison (collinear leading, core load only)."];
    Print[Ex04FivePointComparison];,
    If[! MatchQ[Ex04FivePointComparison, HoldPattern[Missing["NotAvailable", _]]],
      Print[Ex04FivePointComparison]
    ]
  ];,
  Ex04PolynomialRegression = Missing["NotRun", "Set $HRFRunEx04RegressionOnLoad=True or evaluate hrfEx04BuildRegressionTable[]"];
  Ex04PolynomialRegressionTable = Dataset[{}];
  Ex04PolynomialRegressionNarrative = "Example 04 regression not run on load. Evaluate hrfEx04BuildRegressionTable[].";
  Ex04FivePointComparison = Missing["NotRun"];
  Clear[Ex04CrownRegression, Ex04SuperCrownInterior, Ex04HyperCrownInterior,
    Ex04HyperCrownX11Target, Ex04Seed5ptInterior, Ex04ThreeLoopVertexInterior];
  Ex04CrownFactorSupport = <||>;
];
