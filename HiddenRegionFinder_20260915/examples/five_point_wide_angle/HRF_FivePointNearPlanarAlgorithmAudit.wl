(* End-to-end HRF audit of the exactly massless five-point near-planar region.

   This is the algorithmic counterpart of the analytic all-layer audit.  It
   starts from the ordinary Mandelstam polynomial on Gamma5=0.  On this
   surface its complete leading polynomial is the cancellation sector, so a
   candidate-specific saturated-gradient calculation is valid.  The audit
   constructs the factorized generators, identifies the leading sector,
   and solves the restored-layer coverage problem.  No cancellation factor,
   generator or numerical kinematic witness is supplied. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
$HRF5WALandshoffAuditLibraryOnly = True;
Get[FileNameJoin[{base,
  "HRF_FivePointWideAngleLandshoffAllLayerAudit.wl"}]];

ClearAll[hrf5WANearPlanarAlgorithmAudit];

hrf5WANearPlanarAlgorithmAudit[] := Module[
  {audit, symmetric, vars, kinVars, f, u, qNonzero, scan, summary},
  audit = hrf5WALandshoffAllLayerAudit[];
  symmetric = audit["InvariantSymmetricForm"];
  vars = audit["Graph", "Variables"];
  kinVars = $HRF5WAKinematicVariables;
  f = Expand[audit["Graph", "F0"]];
  u = Expand[audit["Graph", "U"]];
  qNonzero = Values[symmetric["QuadraticCoefficients"]];

  scan = findObstructions[
    f, vars, $HRF5WAPhysicalCoplanarDomain, kinVars, Automatic,
    "DerivativeFactorHarvestMode" -> "SaturatedLeadingIdeal",
    "FullGradientSaturationJustifiedQ" -> True,
    "FactorHarvestKinematicConstraints" ->
      {hrf5WAGramDeterminant[] == 0},
    "FactorHarvestNonzeroKinematicFactors" -> qNonzero,
    "GeneratorMode" -> "PairSectors",
    "MaxGenerators" -> 3,
    "CandidateGeneratorSetLimit" -> Infinity,
    "MaxTwoGeneratorUnionTrials" -> Infinity,
    "PolynomialMaxMonomials" -> Automatic,
    "StopOnFirstAdmissible" -> False,
    "StoreAllObstructionTrialsQ" -> True,
    "U" -> u,
    "FObsForScaling" -> <|
      "DeltaLayers" -> <|2 -> x1 x3 x5|>
    |>,
    "MaxScalingAbs" -> 6,
    "CoverageScalingMethod" -> "ExactCoverage",
    "RequireValidScalingForHiddenRegionQ" -> True
  ];

  summary = <|
    "HarvestMode" -> scan["EffectiveSearchConfiguration",
      "DerivativeFactorHarvestMode"],
    "ObstructionIdealMode" -> scan["EffectiveSearchConfiguration",
      "ObstructionIdealMode"],
    "CandidateSpecificNormalFactorCount" -> scan[
      "GeneralizedDerivativeHarvestAudit", "DomainCompatibleFactorCount"],
    "CandidateGeneratorCountHistogram" -> scan[
      "ObstructionAttemptSummary", "GeneratorCountHistogram"],
    "ValidDecompositionCount" -> scan["ValidObstructionTrialCount"],
    "SelectedGeneratorCount" -> Length[scan["Generators"]],
    "RegionVector" -> scan["CoverageScalingData", "Scaling"],
    "WSL" -> scan["CoverageScalingData", "FSLWeightPrimitive"],
    "WHR" -> scan["CoverageScalingData",
      "PostCancellationLeadingWeightPrimitive"],
    "HiddenRegionQ" -> scan["HiddenRegionQ"],
    "SearchTruncatedQ" -> scan["SearchTruncatedQ"]
  |>;

  <|"Summary" -> summary, "Scan" -> scan|>
];

If[! TrueQ[ValueQ[$HRF5WANearPlanarAlgorithmAuditLibraryOnly] &&
    $HRF5WANearPlanarAlgorithmAuditLibraryOnly],
  result = hrf5WANearPlanarAlgorithmAudit[];
  Print[InputForm[result["Summary"]]]
];
