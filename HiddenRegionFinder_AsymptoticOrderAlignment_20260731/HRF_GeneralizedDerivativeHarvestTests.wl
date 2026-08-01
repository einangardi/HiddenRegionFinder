(* Regression tests for opt-in candidate-specific derivative-ideal saturation.

   The five-point coplanar example is tested symbolically, with the Gram
   equation supplied as the leading kinematic surface.  No numerical
   specialization, cancellation-factor override or generator override is
   used.  The test must reproduce the established three-generator HRF
   decomposition and scaling. *)

$HistoryLength = 0;
repo = DirectoryName[$InputFileName];
$HRFPackageDirectory = repo;
$HRFQuietReports = True;
Get[FileNameJoin[{repo, "HiddenRegionFinder.wl"}]];

$HRF5WALandshoffAuditLibraryOnly = True;
Get[FileNameJoin[{repo, "examples", "five_point_wide_angle",
  "HRF_FivePointWideAngleLandshoffAllLayerAudit.wl"}]];

audit = hrf5WALandshoffAllLayerAudit[];
sym = audit["InvariantSymmetricForm"];
witness = sym["InvariantPositiveWitness"];
vars = audit["Graph", "Variables"];
kinVars = $HRF5WAKinematicVariables;
f0Symbolic = Expand[audit["Graph", "F0"]];
u = Expand[audit["Graph", "U"]];
expectedFactors = Factor /@ (sym["OriginalNormalPolynomials"] /. witness);
qNonzero = Values[sym["QuadraticCoefficients"]];

symbolicHarvest = hrfSaturatedDerivativeFactorHarvest[
  f0Symbolic, vars, kinVars, {hrf5WAGramDeterminant[] == 0}, qNonzero, 30,
  Automatic
];

symbolicAtWitness = Factor /@ (
  symbolicHarvest["Factors"] /. witness
);
symbolicWitnessClassesQ = And @@ (
  Function[target,
    AnyTrue[symbolicAtWitness,
      hrfCancellationFactorsEquivalentModuloConstraintsQ[
        target, #, vars, {}, {}
      ] &]
  ] /@ expectedFactors
);

scan = findObstructions[
  f0Symbolic, vars, $HRF5WAPhysicalCoplanarDomain, kinVars, Automatic,
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
  "FObsForScaling" -> <|"DeltaLayers" -> <|2 -> x1 x3 x5|>|>,
  "MaxScalingAbs" -> 6,
  "CoverageScalingMethod" -> "ExactCoverage",
  "RequireValidScalingForHiddenRegionQ" -> True
];

(* Independent positive control: the three-loop Crown at an exact physical
   wide-angle witness.  The generalized route must find, not override, its
   cancellation factors and pass the ordinary scaling certificate. *)
Get[FileNameJoin[{repo, "HRF_ExactCoverageRegressionTests.wl"}]];
crownScan = findObstructions[
  Expand[F0Crown /. {s12 -> 1, s23 -> -1}], VarsCrown, True, {}, Automatic,
  "DerivativeFactorHarvestMode" -> "SaturatedLeadingIdeal",
  "FullGradientSaturationJustifiedQ" -> True,
  "GeneratorMode" -> "PairSectors",
  "MaxGenerators" -> 2,
  "CandidateGeneratorSetLimit" -> Infinity,
  "MaxTwoGeneratorUnionTrials" -> Infinity,
  "StopOnFirstAdmissible" -> False,
  "U" -> CrownData["UF"]["U"],
  "CoverageScalingMethod" -> "ExactCoverage",
  "RequireValidScalingForHiddenRegionQ" -> True
];

tests = {
  <|"Test" -> "DefaultRemainsOffQ",
    "PassQ" -> TrueQ[
      ("DerivativeFactorHarvestMode" /. Options[findObstructions]) === "Off"
    ]|>,
  <|"Test" -> "UnsafeFullGradientUseRejectedQ",
    "PassQ" -> TrueQ[
      Module[{unsafe},
        unsafe = findObstructions[
          f0Symbolic, vars, $HRF5WAPhysicalCoplanarDomain, kinVars,
          Automatic,
          "DerivativeFactorHarvestMode" -> "SaturatedLeadingIdeal"
        ];
        unsafe["GeneralizedDerivativeHarvestAudit", "Status"] ===
          "ApplicabilityNotEstablished" && unsafe["SearchTruncatedQ"]
      ]
    ]|>,
  <|"Test" -> "SymbolicGramHarvestCompleteQ",
    "PassQ" -> TrueQ[
      symbolicHarvest["Status"] === "Done" &&
      ! symbolicHarvest["SearchTruncatedQ"]
    ]|>,
  <|"Test" -> "SymbolicGramHarvestHasThreeClassesQ",
    "PassQ" -> TrueQ[
      Length[symbolicHarvest["Factors"]] === 3 && symbolicWitnessClassesQ
    ]|>,
  <|"Test" -> "NoFactorOrGeneratorOverrideQ",
    "PassQ" -> TrueQ[
      ! Lookup[scan["PolynomialFactorHarvestAudit"],
        "CancellationFactorOverrideQ", False] &&
      ! Lookup[scan["GeneratorConstructionAudit"],
        "GeneratorSetOverrideQ", False]
    ]|>,
  <|"Test" -> "SymbolicCoefficientFieldIdealQ",
    "PassQ" -> TrueQ[
      scan["EffectiveSearchConfiguration", "ObstructionIdealMode"] ===
        "KinematicCoefficientField" &&
      scan["EffectiveSearchConfiguration", "AllowKinematicFactorPairsQ"]
    ]|>,
  <|"Test" -> "ThreeNormalFactorsRecoveredQ",
    "PassQ" -> TrueQ[
      Length[scan["GeneralizedDerivativeHarvestAudit",
        "DomainCompatibleFactors"]] === 3
    ]|>,
  <|"Test" -> "ThreePairGeneratorsConstructedQ",
    "PassQ" -> TrueQ[Length[scan["Generators"]] === 3]|>,
  <|"Test" -> "OnlyThreeGeneratorDecompositionSurvivesQ",
    "PassQ" -> TrueQ[
      scan["ValidObstructionTrialCount"] === 1 &&
      scan["ObstructionAttemptSummary", "GeneratorCountHistogram"] ===
        <|3 -> 1, 2 -> 3, 1 -> 4|>
    ]|>,
  <|"Test" -> "NearPlanarHiddenRegionRecoveredQ",
    "PassQ" -> TrueQ[
      scan["HiddenRegionQ"] && scan["HiddenRegionCount"] === 1 &&
      scan["CoverageScalingData", "Scaling"] ===
        {-2, -2, -2, -2, -2, -2}
    ]|>,
  <|"Test" -> "GeneralizedHarvestUntruncatedQ",
    "PassQ" -> TrueQ[! scan["SearchTruncatedQ"]]|>,
  <|"Test" -> "CrownFactorsHarvestedQ",
    "PassQ" -> TrueQ[
      Length[crownScan["GeneralizedDerivativeHarvestAudit",
        "DomainCompatibleFactors"]] === 2
    ]|>,
  <|"Test" -> "CrownHiddenRegionRecoveredQ",
    "PassQ" -> TrueQ[
      crownScan["HiddenRegionQ"] && ! crownScan["SearchTruncatedQ"]
    ]|>
};

result = <|
  "Summary" -> <|
    "Passed" -> Count[tests, t_ /; TrueQ[t["PassQ"]]],
    "Failed" -> Count[tests, t_ /; ! TrueQ[t["PassQ"]]],
    "Total" -> Length[tests]
  |>,
  "Tests" -> tests,
  "SymbolicHarvest" -> symbolicHarvest,
  "ScanSummary" -> KeyTake[scan, {
    "HiddenRegionQ", "HiddenRegionCount", "Generators",
    "CoverageScalingData", "GeneralizedDerivativeHarvestAudit",
    "EffectiveSearchConfiguration", "SearchTruncatedQ"
  }],
  "CrownScanSummary" -> KeyTake[crownScan, {
    "HiddenRegionQ", "HiddenRegionCount", "Generators",
    "GeneralizedDerivativeHarvestAudit", "SearchTruncatedQ"
  }]
|>;

Print[InputForm[result["Summary"]]];
If[result["Summary", "Failed"] > 0,
  Print[InputForm[Select[tests, ! TrueQ[#1["PassQ"]] &]]];
  Exit[1]
];
