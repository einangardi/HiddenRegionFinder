(* Regression tests for user-supplied polynomial-generator sets. *)

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
fCop = Expand[sym["OriginalF0GeneratorDecomposition"] /. witness];
u = Expand[audit["Graph", "U"]];
factors = Factor /@ (sym["OriginalNormalPolynomials"] /. witness);
generators = Factor /@ (sym["OriginalFactorizedGenerators"] /. witness);
transverseLayer = x1 x3 x5;

scan = findObstructions[
  fCop, vars, True, {}, Automatic,
  "CancellationFactorOverride" -> factors,
  "GeneratorSetOverride" -> {generators},
  "MaxGenerators" -> 3,
  "StopOnFirstAdmissible" -> False,
  "StoreAllObstructionTrialsQ" -> True,
  "U" -> u,
  "FObsForScaling" -> <|
    "DeltaLayers" -> <|2 -> transverseLayer|>
  |>,
  "MaxScalingAbs" -> 6,
  "CoverageScalingMethod" -> "ExactCoverage",
  "RequireValidScalingForHiddenRegionQ" -> True
];

tests = {
  <|"Test" -> "OverrideRecordedQ",
    "PassQ" -> TrueQ[scan["GeneratorConstructionAudit",
      "GeneratorSetOverrideQ"]]|>,
  <|"Test" -> "ExactlyOneGeneratorSetTriedQ",
    "PassQ" -> TrueQ[scan["CandidateGeneratorCount"] == 1]|>,
  <|"Test" -> "ThreeGeneratorsRetainedQ",
    "PassQ" -> TrueQ[Length[scan["Generators"]] == 3]|>,
  <|"Test" -> "ExactDecompositionFoundQ",
    "PassQ" -> AssociationQ[scan["ObstructionData"]]|>,
  <|"Test" -> "ScalingFoundQ",
    "PassQ" -> TrueQ[scan["HiddenRegionQ"]]|>,
  <|"Test" -> "NearPlanarVectorRecoveredQ",
    "PassQ" -> TrueQ[
      scan["CoverageScalingData", "Scaling"] ===
        {-2, -2, -2, -2, -2, -2} &&
      scan["CoverageScalingData", "SelectedCandidateDiagnostic", "WSL"] === -6 &&
      scan["CoverageScalingData", "SelectedCandidateDiagnostic", "WHR"] === -4
    ]|>
};

result = <|
  "Summary" -> <|
    "Passed" -> Count[tests, t_ /; TrueQ[t["PassQ"]]],
    "Failed" -> Count[tests, t_ /; ! TrueQ[t["PassQ"]]],
    "Total" -> Length[tests]
  |>,
  "Tests" -> tests,
  "ScanSummary" -> KeyTake[scan, {
    "HiddenRegionQ", "HiddenRegionCount", "Generators",
    "ObstructionData", "GeneratorConstructionAudit",
    "EffectiveSearchConfiguration", "SearchTruncatedQ"
  }]
|>;

Print[InputForm[result]];
If[result["Summary", "Failed"] > 0, Exit[1]];
