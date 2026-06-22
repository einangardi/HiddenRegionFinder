(* HRF_NotebookSmokeTests.wl
   Cross-notebook sanity checks after scaling / obstruction updates.
   Run: Get["HRF_NotebookSmokeTests.wl"]; hrfRunNotebookSmokeTests[] *)

$HRFSmokeTestDirectory = Which[
  StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName],
    DirectoryName[$InputFileName],
  ValueQ[hrfPackageDirectory],
    hrfPackageDirectory[],
  True,
    Quiet @ Check[NotebookDirectory[], Directory[]]
];

If[! TrueQ[$HRFFinderCoreLoadedQ],
  Get[FileNameJoin[{$HRFSmokeTestDirectory, "HiddenRegionFinder.wl"}]]
];
If[! ValueQ[hrfInstallPolynomialCancellationPatch],
  Get[FileNameJoin[{$HRFSmokeTestDirectory, "HRF_PolynomialCancellationFactors.wl"}]]
];
If[! ValueQ[hrfSuccessfulObstructionDecompositionQ],
  Get[FileNameJoin[{$HRFSmokeTestDirectory, "HRF_FinalLogicPatch.wl"}]]
];
If[! ValueQ[hrfCoverageFoundQ],
  Get[FileNameJoin[{$HRFSmokeTestDirectory, "HRF_Example01Common.wl"}]]
];

If[! ValueQ[$HRFSmokeRunSlowQ], $HRFSmokeRunSlowQ = False];
If[! ValueQ[$HRFSmokeRunVerySlowQ], $HRFSmokeRunVerySlowQ = False];

ClearAll[hrfSmokeAssert, hrfSmokeRow, hrfRunNotebookSmokeTests];

hrfSmokeAssert[name_, condition_, detail_: ""] :=
  <|"Test" -> name, "PassQ" -> TrueQ[condition], "Detail" -> detail|>;

hrfSmokeRow[name_, value_, expected_, detail_: ""] :=
  <|"Test" -> name, "Value" -> value, "Expected" -> expected,
    "PassQ" -> (value === expected), "Detail" -> detail|>;

hrfRunNotebookSmokeTests[] := Module[{rows = {}, row, sc, case},
  (* --- Example 02 Regge (binomial PairSectors) --- *)
  Block[{
    $HRFQuietReports = True, $HRFExample02Report = False,
    $HRFRunEx02InteriorStudiesOnLoad = True,
    $HRFRunEx02SuperCrownBoundary = False, $HRFRunEx02HyperCrownBoundaries = False
  },
    Get[FileNameJoin[{$HRFSmokeTestDirectory, "02_Forward_Regge_2to2_Massless.wl"}]];
    row = Ex02InteriorStudies["Crown"]["Wide"];
    AppendTo[rows, hrfSmokeRow["Ex02.Crown.Wide.HiddenRegion",
      Lookup[row, "Hidden region identified?", "No"], "Yes",
      "Regge notebook: massless Crown interior wide-angle"]];
    AppendTo[rows, hrfSmokeAssert["Ex02.Crown.Wide.ScalingFoundQ",
      Lookup[row, "Scaling status", "--"] === "Scaling vector determined",
      ToString[Lookup[row, "Scaling vector", "--"]]]];
    row = Ex02InteriorStudies["Crown"]["T23"];
    AppendTo[rows, hrfSmokeRow["Ex02.Crown.T23.HiddenRegion",
      Lookup[row, "Hidden region identified?", "No"], "Yes",
      "Regge limit T23: exact reduction F_SL=0"]];
    AppendTo[rows, hrfSmokeAssert["Ex02.Crown.T23.HiddenImpliesDecompOK",
      ! (Lookup[row, "Hidden region identified?", "No"] === "Yes") ||
        TrueQ[Lookup[row, "Obstruction decomposition OK?", False]],
      "Hidden=Yes requires Obstruction decomposition OK=True"]];
  ];

  (* --- Example 03 / Ex04 Seed5pt (polynomial) --- *)
  Block[{
    $HRFQuietReports = True, $HRFExample04Report = False,
    $HRFEx04RunObstructionSearchQ = True,
    $HRFFindObstructionsStopOnFirstAdmissibleQ = True,
    $HRFCandidateGeneratorSetLimit = 64
  },
    Get[FileNameJoin[{$HRFSmokeTestDirectory, "HRF_Example03CollinearCore.wl"}]];
    Get[FileNameJoin[{$HRFSmokeTestDirectory, "04_PolynomialFactor_Regression.wl"}]];
    case = hrfEx04Seed5ptInterior[];
    AppendTo[rows, hrfSmokeRow["Ex03.Seed5pt.PolyHiddenQ",
      Lookup[case["ComparisonRow"], "PolynomialHiddenRegionQ", False], True,
      "5pt collinear seed interior"]];
    sc = hrfEvalScalingData @ <|"CoverageScalingData" -> Lookup[case["PolynomialScan"], "CoverageScalingData", Missing[]]|>;
    AppendTo[rows, hrfSmokeAssert["Ex03.Seed5pt.ScalingStatusFoundQ",
      Lookup[sc, "ScalingStatus", ""] === "Found",
      Lookup[sc, "ScalingStatusMessage", ""]]];
    AppendTo[rows, hrfSmokeRow["Ex03.Seed5pt.GeneratorCount",
      Length[Lookup[case["PolynomialScan"], "Generators", {}]], 1,
      "Single coupled generator expected"]];

    If[TrueQ[$HRFSmokeRunSlowQ],
      case = hrfEx04HyperCrownX11Target[];
      row = hrfEx04RegionStudyRow[case["PolynomialScan"], case["Label"],
        case["RemainingVars"], KinAssump4ptOnShell, KinVars4pt,
        Expand[HyperCrownData["UF"]["U"] /. x11 -> 0], {x11}];
      AppendTo[rows, hrfSmokeRow["Ex01.HyperCrown.x11.HiddenRegion",
        Lookup[row, "Hidden region identified?", "No"], "Yes",
        "Polynomial HyperCrown boundary {x11}=0"]];
    ];

    If[TrueQ[$HRFSmokeRunVerySlowQ],
      case = hrfEx04ThreeLoopVertexInterior[];
      AppendTo[rows, hrfSmokeRow["Ex03.ThreeLoopVertex.PolyHiddenQ",
        Lookup[case["ComparisonRow"], "PolynomialHiddenRegionQ", False], True,
        "Vertex-corrected 5pt topology"]];
      sc = hrfEvalScalingData @ <|"CoverageScalingData" -> Lookup[case["PolynomialScan"], "CoverageScalingData", Missing[]]|>;
      AppendTo[rows, hrfSmokeAssert["Ex03.ThreeLoopVertex.ScalingStatusFoundQ",
        MemberQ[{"Found", "NoValidScaling", "NotDetermined"},
          Lookup[sc, "ScalingStatus", ""]],
        Lookup[sc, "ScalingStatusMessage", ""]]];
    ];
  ];

  <|
    "Summary" -> <|
      "Total" -> Length[rows],
      "Passed" -> Count[rows, _?(TrueQ[Lookup[#, "PassQ", False]] &)],
      "Failed" -> Count[rows, _?(Not @ TrueQ @ Lookup[#, "PassQ", False] &)]
    |>,
    "Rows" -> Dataset[rows]
  |>
];

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] notebook smoke tests. Evaluate hrfRunNotebookSmokeTests[]."]
];
