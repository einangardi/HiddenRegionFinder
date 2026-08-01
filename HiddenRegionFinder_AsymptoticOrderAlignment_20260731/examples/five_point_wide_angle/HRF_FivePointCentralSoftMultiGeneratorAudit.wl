(* Diagnostic audit of the first two aligned central-soft layers.
   This deliberately bypasses the alignment wrapper so that generator sets
   with more than two members can be tested explicitly. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
repo = DirectoryName[DirectoryName[base]];
$HRFPackageDirectory = repo;
$HRFQuietReports = True;
$HRFScalingReport = False;
Get[FileNameJoin[{repo, "HiddenRegionFinder.wl"}]];

vars = {x0, x1, x2, x3, x4, x5};
kinVars = {P, M, K, T};
assumptions = P > 0 && M > 0 && K > 0 && T > 0;

(* Aligned weights -13 and -12, after removing their common powers and
   irrelevant positive overall factors. *)
fAlignedTwoLayers = Expand[
  -M (P x2 - K x3) (x1 x4 - x0 x5) - T x0 x3 x4
];

ClearAll[runAtGeneratorCap, compactResult];

runAtGeneratorCap[n_Integer?Positive] := findObstructions[
  fAlignedTwoLayers, vars, assumptions, kinVars, Automatic,
  "GeneratorMode" -> "PairSectors",
  "MaxGenerators" -> n,
  "UseExtendedFactors" -> True,
  "DimensionfulKinVars" -> {},
  "StopOnFirstAdmissible" -> False,
  "PreferFewerGenerators" -> False,
  "CandidateGeneratorSetLimit" -> Infinity,
  "MaxTwoGeneratorUnionTrials" -> Infinity,
  "StoreAllObstructionTrialsQ" -> True,
  "RequireValidScalingForHiddenRegionQ" -> False,
  "EnumerateHiddenRegionsQ" -> False,
  "AsymptoticOrderAlignmentMode" -> "Off"
];

compactResult[n_, scan_Association] := <|
  "MaxGenerators" -> n,
  "CancellationFactors" -> Factor /@ Lookup[scan, "CancellationFactors", {}],
  "CandidateGeneratorCount" -> Lookup[scan, "CandidateGeneratorCount", 0],
  "GeneratorCountHistogram" -> Lookup[
    Lookup[scan, "ObstructionAttemptSummary", <||>],
    "GeneratorCountHistogram", <||>
  ],
  "ValidObstructionTrialCount" -> Lookup[scan, "ValidObstructionTrialCount", 0],
  "AdmissibleCandidateGeneratorSets" ->
    (Factor /@ # & /@ Lookup[scan, "AdmissibleCandidateGeneratorSets", {}]),
  "SelectedGenerators" -> Factor /@ Lookup[scan, "Generators", {}],
  "SelectedObstructionData" -> Lookup[scan, "ObstructionData", Missing["None"]],
  "SearchTruncatedQ" -> Lookup[scan, "SearchTruncatedQ", Missing["NotReported"]],
  "SearchCompleteQ" -> Lookup[scan, "HiddenRegionSearchCompleteQ", Missing["NotReported"]]
|>;

scans = Association @ Table[n -> runAtGeneratorCap[n], {n, 1, 4}];
summary = Association @ KeyValueMap[#1 -> compactResult[#1, #2] &, scans];

Print[InputForm[summary]];
Export[FileNameJoin[{base, "five_point_central_soft_multigenerator_audit.wl"}],
  <|"Polynomial" -> fAlignedTwoLayers, "Scans" -> scans, "Summary" -> summary|>,
  "Package"];
