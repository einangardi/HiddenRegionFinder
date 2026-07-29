(* Compact regression tests for the wide-angle momentum certificates. *)

$HRFWideAngleMomentumTestDirectory = DirectoryName[$InputFileName];

If[! ValueQ[CrownInternalEdges] || ! ValueQ[HyperCrownInternalEdges],
  Block[{
    $HRFQuietReports = True,
    $HRFExample01Report = False,
    $HRFRunCrownInteriorScanOnLoad = False,
    $HRFRunExample01ReportingOnLoad = False,
    $HRFRunScalingDiagnostics = False,
    $HRFRunSuperCrownInteriorScan = False,
    $HRFRunSuperCrownBoundaryScanOnLoad = False,
    $HRFRunHyperCrownInteriorScan = False,
    $HRFRunHyperCrownBoundaryScansOnLoad = False,
    $HRFRunDivingBeetleDiagnosticsOnLoad = False,
    $HRFRunDivingBeetleInteriorScanOnLoad = False
  },
    Get[FileNameJoin[{
      $HRFWideAngleMomentumTestDirectory, "01_WideAngle_2to2_OffShell.wl"
    }]]
  ]
];

If[Length[DownValues[hrfWideAngleCrownMomentumCertificate]] == 0,
  Get[FileNameJoin[{
    $HRFWideAngleMomentumTestDirectory, "HRF_WideAngleMomentumReconstruction.wl"
  }]]
];

ClearAll[hrfRunWideAngleMomentumReconstructionTests];

hrfRunWideAngleMomentumReconstructionTests[] := Module[
  {crown, hyper, positives, checks, rows},
  crown = hrfWideAngleCrownMomentumCertificate[];
  hyper = hrfWideAngleHyperCrownX11MomentumCertificate[];
  positives = hrfWideAngleHyperCrownPositiveMomentumCertificates[];
  checks = <|
    "CrownScaling" ->
      crown["ScalingVectorWithDelta"] ===
        {-1, -1, -1, -1, -1, -1, -1, -1, 1},
    "CrownVirtualities" ->
      Values[crown["VirtualityPowers"]] === ConstantArray[1, 8],
    "CrownVertexConservation" -> TrueQ[
      crown["VertexAudit", "AllVertexComponentsCompatibleQ"]],
    "CrownLoopBasis" -> TrueQ[crown["IndependentLoopBasisValidQ"]],
    "HyperBoundaryContracted" ->
      hyper["BoundaryContraction", "ContractedVariable"] === x11 &&
      FreeQ[hyper["ActiveVariables"], x11],
    "HyperScaling" ->
      hyper["ScalingVectorWithDelta"] ===
        {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -2, 1},
    "HyperVirtualities" ->
      Lookup[hyper["VirtualityPowers"], hyper["ActiveVariables"]] ===
        {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2},
    "HyperSoftEdge" ->
      hyper["ModeLabels"][x10] === "soft" &&
      hyper["Branch", "EdgeComponentPowers", x10] === {1, 1, 1},
    "HyperVertexConservation" -> TrueQ[
      hyper["VertexAudit", "AllVertexComponentsCompatibleQ"]],
    "HyperLoopBasis" -> TrueQ[hyper["IndependentLoopBasisValidQ"]],
    "AllPositiveHyperCrownVertexConservation" -> And @@
      (# ["VertexAudit", "AllVertexComponentsCompatibleQ"] & /@ Values[positives]),
    "AllPositiveHyperCrownLoopBases" -> And @@
      (# ["IndependentLoopBasisValidQ"] & /@ Values[positives]),
    "CodimensionOneSoftEdges" ->
      positives["{x8}", "ModeLabels", x9] === "soft" &&
      positives["{x9}", "ModeLabels", x8] === "soft" &&
      positives["{x10}", "ModeLabels", x11] === "soft" &&
      positives["{x11}", "ModeLabels", x10] === "soft",
    "CodimensionTwoUniformJetModes" -> And @@ Flatten[
      (Values[positives[#, "ModeLabels"]] === ConstantArray["jet", 10] & /@
        {"{x8, x10}", "{x8, x11}", "{x9, x10}", "{x9, x11}"})],
    "SymmetryCompletedPositiveCount" -> Length[positives] === 8,
    "NoUndeterminedVirtualities" -> FreeQ[
      Join[Values[crown["Branch", "VirtualityTypes"]],
        Values[hyper["Branch", "VirtualityTypes"]]], "Undetermined"]
  |>;
  rows = KeyValueMap[<|"Check" -> #1, "PassedQ" -> TrueQ[#2]|> &, checks];
  <|
    "Summary" -> <|
      "Passed" -> Count[Values[checks], True],
      "Failed" -> Count[Values[checks], Except[True]],
      "AllPassedQ" -> And @@ Values[checks]
    |>,
    "Rows" -> Dataset[rows],
    "Checks" -> checks
  |>
];
