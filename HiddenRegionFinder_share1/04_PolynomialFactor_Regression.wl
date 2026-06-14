(* 04_PolynomialFactor_Regression.wl
   Regression and target-case harness for footnote-4 polynomial factors.

   Tracks:
     - additional f_k relative to binomial mode
     - generator candidates accepted/discarded
     - hidden-region stability across modes

   Usage:
     Get["HiddenRegionFinder.wl"];
     Get["04_PolynomialFactor_Regression.wl"];
     Ex04PolynomialRegressionTable
     Ex04PolynomialRegressionNarrative
*)

If[! ValueQ[$HRFUsePolynomialCancellationFactors], $HRFUsePolynomialCancellationFactors = True];
If[! ValueQ[$HRFExample04Report], $HRFExample04Report = True];
If[! ValueQ[$HRFRunEx04ThreeLoopOnLoad], $HRFRunEx04ThreeLoopOnLoad = False];

$HRFExample04Directory = If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName],
  Quiet[Check[NotebookDirectory[], Directory[]]]
];

If[! ValueQ[findObstructions],
  Quiet @ Check[Unprotect[safeCancellationFactors, safeCancellationFactorsExtended], Null];
  Get[FileNameJoin[{$HRFExample04Directory, "HiddenRegionFinder.wl"}]]
];
Get[FileNameJoin[{$HRFExample04Directory, "HRF_PolynomialCancellationFactors.wl"}]];
Get[FileNameJoin[{$HRFExample04Directory, "HRF_FinalLogicPatch.wl"}]];
Get[FileNameJoin[{$HRFExample04Directory, "HRF_PolynomialFactorReporting.wl"}]];

ClearAll[hrfEx04Say, hrfEx04ScanInMode, hrfEx04CompareModes, hrfEx04LoadExample01,
  hrfEx04LoadExample03Seed, hrfEx04CrownRegression, hrfEx04HyperCrownX11Target,
  hrfEx04ThreeLoopVertexTarget, hrfEx04BuildRegressionTable];

hrfEx04Say[msg_] := If[TrueQ[$HRFExample04Report], Print["[Example 04] " <> msg]];

hrfEx04ScanInMode[mode_String, F_, vars_, kinAssump_, kinVars_, maxSize_:20] := Block[
  {$HRFUsePolynomialCancellationFactors = (mode === "Polynomial")},
  findObstructions[
    F, vars, kinAssump, kinVars, maxSize,
    "GeneratorMode" -> "PairSectors",
    "UseExtendedFactors" -> True,
    "MaxGenerators" -> 2
  ]
];

hrfEx04CompareModes[F_, vars_, kinAssump_, kinVars_, label_, maxSize_:20] := Module[
  {diff, binScan, polyScan, polyAudit},
  diff = hrfPolynomialFactorAudit[F, vars, kinAssump, kinVars, Automatic];
  binScan = hrfEx04ScanInMode["Binomial", F, vars, kinAssump, kinVars, maxSize];
  polyScan = hrfEx04ScanInMode["Polynomial", F, vars, kinAssump, kinVars, maxSize];
  polyAudit = hrfPolyFactorAuditTable[
    Select[Lookup[$HRFPolynomialLastFactorAudit, "AuditRows", {}], TrueQ[Lookup[#, "AcceptedQ", False]] &]
  ];
  <|
    "Label" -> label,
    "FactorDiff" -> diff,
    "BinomialScan" -> binScan,
    "PolynomialScan" -> polyScan,
    "ComparisonRow" -> hrfPolyModeComparisonRow[label, binScan, polyScan, diff],
    "GeneratorAudit" -> <|
      "Binomial" -> hrfPolyGeneratorAuditRow[binScan, label <> " / binomial"],
      "Polynomial" -> hrfPolyGeneratorAuditRow[polyScan, label <> " / polynomial"]
    |>,
    "FactorAuditDataset" -> polyAudit,
    "RejectedFactorAuditDataset" -> hrfPolyFactorAuditTable[
      Select[Lookup[$HRFPolynomialLastFactorAudit, "AuditRows", {}], ! TrueQ[Lookup[#, "AcceptedQ", False]] &]
    ]
  |>
];

hrfEx04LoadExample01[] := If[! ValueQ[F0Crown],
  Block[{
    $HRFExample01Report = False,
    $HRFRunHyperCrownInteriorScan = False,
    $HRFRunHyperCrownBoundaryScansOnLoad = False,
    $HRFRunSuperCrownInteriorScan = False,
    $HRFRunSuperCrownBoundaryScanOnLoad = False,
    $HRFRunDivingBeetleDiagnosticsOnLoad = False
  },
    Get[FileNameJoin[{$HRFExample04Directory, "01_WideAngle_2to2_OffShell.wl"}]]
  ];
  True,
  True
];

hrfEx04LoadExample03Seed[] := If[! ValueQ[FSeed5pt],
  hrfEx04Say["loading 03_FivePoint_Spacelike_Collinear.wl for ThreeLoopVertex target (may take a few minutes)."];
  Get[FileNameJoin[{$HRFExample04Directory, "03_FivePoint_Spacelike_Collinear.wl"}]];
  True,
  True
];

hrfEx04CrownRegression[] := Module[{},
  hrfEx04LoadExample01[];
  hrfEx04CompareModes[F0Crown, VarsCrown, KinAssump4ptOnShell, KinVars4pt, "Crown interior regression", 20]
];

hrfEx04HyperCrownX11Target[] := Module[{fB, varsB, uB},
  hrfEx04LoadExample01[];
  fB = Expand[F0HyperCrown /. x11 -> 0];
  varsB = Complement[VarsHyperCrown, {x11}];
  hrfEx04CompareModes[fB, varsB, KinAssump4ptOnShell, KinVars4pt, "HyperCrown boundary {x11}=0", 30]
];

hrfEx04ThreeLoopVertexTarget[] := Module[{uf, f, vars, fLead, pack},
  hrfEx04LoadExample03Seed[];
  uf = SymanzikUF[ThreeLoopVertexInternalLines, seedExternalLines];
  f = toCyclicMandelstams[uf["F"]];
  vars = uf["Variables"];
  fLead = Expand[f /. collPar1];
  pack = hrfEx04CompareModes[fLead, vars, KinAssump, KinVars, "ThreeLoopVertex collinear leading", 20];
  Join[pack, <|"UF" -> uf, "FLeading" -> fLead, "Vars" -> vars|>]
];

hrfEx04BuildRegressionTable[] := Module[{rows = {}, cases = {}},
  hrfEx04Say["Crown interior regression."];
  AppendTo[cases, hrfEx04CrownRegression[]];
  hrfEx04Say["HyperCrown boundary {x11}=0 target."];
  AppendTo[cases, hrfEx04HyperCrownX11Target[]];
  If[TrueQ[$HRFRunEx04ThreeLoopOnLoad],
    hrfEx04Say["ThreeLoopVertex target."];
    AppendTo[cases, hrfEx04ThreeLoopVertexTarget[]];
  ];
  rows = Lookup[#, "ComparisonRow", <||>] & /@ cases;
  <|
    "Cases" -> cases,
    "ComparisonTable" -> hrfPolyModeComparisonTable[rows],
    "Narrative" -> hrfPolyRegressionSummaryNarrative[rows]
  |>
];

hrfEx04Say["ready. Evaluate hrfEx04BuildRegressionTable[] or reload to populate Ex04PolynomialRegression*."];

(* Lazy by default: set $HRFRunEx04RegressionOnLoad = True before Get to auto-run. *)
If[! ValueQ[$HRFRunEx04RegressionOnLoad], $HRFRunEx04RegressionOnLoad = False];

If[TrueQ[$HRFRunEx04RegressionOnLoad],
  hrfEx04Say["building regression table (Crown + HyperCrown x11)."];
  Ex04PolynomialRegression = hrfEx04BuildRegressionTable[];
  Ex04PolynomialRegressionTable = Ex04PolynomialRegression["ComparisonTable"];
  Ex04PolynomialRegressionNarrative = Ex04PolynomialRegression["Narrative"];
  Ex04CrownRegression = FirstCase[Ex04PolynomialRegression["Cases"], c_ /; c["Label"] === "Crown interior regression", <||>];
  Ex04HyperCrownX11Target = FirstCase[Ex04PolynomialRegression["Cases"], c_ /; StringContainsQ[c["Label"], "HyperCrown boundary"], <||>];
  Print[Ex04PolynomialRegressionNarrative];,
  Ex04PolynomialRegression = Missing["NotRun", "Set $HRFRunEx04RegressionOnLoad=True or evaluate hrfEx04BuildRegressionTable[]"];
  Ex04PolynomialRegressionTable = Dataset[{}];
  Ex04PolynomialRegressionNarrative = "Example 04 regression not run on load. Evaluate hrfEx04BuildRegressionTable[].";
  Ex04CrownRegression = <||>;
  Ex04HyperCrownX11Target = <||>;
];
