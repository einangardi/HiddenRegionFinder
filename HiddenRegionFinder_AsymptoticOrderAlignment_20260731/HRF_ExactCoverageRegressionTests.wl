(* Regression tests for the layer-aware exact LP coverage solver.

   The HyperCrown x11=0 case is the essential non-uniform-F_SL regression:
   the full polynomial in the cancellation ideal has weights {-6,-5}, while
   only its -6 lower face is F_SL at the hidden-region scaling. *)

$HRFExactCoverageTestDirectory = If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName], Directory[]];

If[! TrueQ[$HRFFinderCoreLoadedQ],
  Get[FileNameJoin[{$HRFExactCoverageTestDirectory, "HiddenRegionFinder.wl"}]]
];

If[! ValueQ[F0Crown] || ! ValueQ[F0HyperCrown],
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
  }, Get[FileNameJoin[{$HRFExactCoverageTestDirectory, "01_WideAngle_2to2_OffShell.wl"}]]]
];

ClearAll[hrfExactCoverageRegressionCase, hrfRunExactCoverageRegressionTests];

hrfExactCoverageRegressionCase[label_, f_, u_, vars_, generators_, expectedScaling_,
    expectedWSL_, expectedWHR_] := Module[{diag, obs, trial, exact, leadingFSL, use, pass},
  diag = obstructionByOriginalTermsGeneralDiagnostic[
    f, generators, vars, KinVars4pt, Automatic, KinAssump4ptOnShell];
  obs = Lookup[diag, "Result", Missing[]];
  If[! AssociationQ[obs],
    Return[<|"Case" -> label, "PassQ" -> False,
      "Failure" -> "No obstruction decomposition"|>]
  ];
  trial = <|"ObstructionData" -> obs, "Generators" -> generators|>;
  exact = hrfTrialCoverageScalingData[trial, u, vars, 5, Automatic, "ExactCoverage"];
  leadingFSL = If[ListQ[Lookup[exact, "Scaling", Missing[]]],
    Total[leadingTerms[obs["Superleading"], vars, exact["Scaling"]]], 0];
  use = generatorUseData[leadingFSL, generators, vars, {}];
  pass = Lookup[exact, "ScalingStatus", ""] === "Found" &&
    Lookup[exact, "Scaling", Missing[]] === expectedScaling &&
    Lookup[exact, "FSLWeightPrimitive", Missing[]] === expectedWSL &&
    Lookup[exact, "PostCancellationLeadingWeightPrimitive", Missing[]] === expectedWHR &&
    TrueQ[Lookup[exact, "LeadingRegionCoverageQ", False]] &&
    TrueQ[Expand[Lookup[use, "Remainder", 1]] === 0] &&
    Length[Lookup[use, "UsedGenerators", {}]] === Length[generators];
  <|
    "Case" -> label,
    "PassQ" -> pass,
    "ScalingStatus" -> Lookup[exact, "ScalingStatus", Missing[]],
    "Scaling" -> Lookup[exact, "Scaling", Missing[]],
    "ExpectedScaling" -> expectedScaling,
    "WSL" -> Lookup[exact, "FSLWeightPrimitive", Missing[]],
    "WHR" -> Lookup[exact, "PostCancellationLeadingWeightPrimitive", Missing[]],
    "LeadingFaceGeneratorRemainder" -> Lookup[use, "Remainder", Missing[]],
    "UsedGeneratorCount" -> Length[Lookup[use, "UsedGenerators", {}]]
  |>
];

hrfRunExactCoverageRegressionTests[] := Module[{rows},
  rows = {
    hrfExactCoverageRegressionCase[
      "Crown interior",
      F0Crown, CrownData["UF"]["U"], VarsCrown,
      {(x3*x4 - x2*x5)*(x1*x6 - x0*x7),
       (x1*x2 - x0*x3)*(x5*x6 - x4*x7)},
      ConstantArray[-1, 8], -4, -3
    ],
    hrfExactCoverageRegressionCase[
      "HyperCrown boundary x11=0",
      Expand[F0HyperCrown /. x11 -> 0],
      Expand[HyperCrownData["UF"]["U"] /. x11 -> 0],
      Complement[VarsHyperCrown, {x11}],
      {(x1*x2 - x0*x3 + x1*x8)*(x5*x6 - x4*x7 + x5*x9),
       (x1*x4 - x0*x5)*(x3*x6 - x2*x7 - x7*x8 + x3*x9)},
      {-1, -1, -2, -1, -1, -1, -1, -1, -1, -1, -1}, -6, -5
    ]
  };
  <|
    "Summary" -> <|
      "Passed" -> Count[Lookup[rows, "PassQ", False], True],
      "Failed" -> Count[Lookup[rows, "PassQ", False], False],
      "AllPassedQ" -> And @@ Lookup[rows, "PassQ", False]
    |>,
    "Rows" -> rows,
    "Dataset" -> Dataset[rows]
  |>
];
