(* Exact audit of literal irreducible derivative-polynomial generator sets on
   the aligned central-soft face that contains both weights -13 and -12.
   This is the direct analogue of the successful five-point wide-angle
   irreducible-generator audit, and contains only 2^5-1=31 subsets. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
repo = DirectoryName[DirectoryName[base]];
bundle = DirectoryName[repo];
$HRFPackageDirectory = repo;
$HRFQuietReports = True;
$HRFScalingReport = False;
Get[FileNameJoin[{repo, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{repo, "HRF_AsymptoticOrderAlignment.wl"}]];

$HRF5MRKRepoDirectory = repo;
$HRF5MRKLibraryOnly = True;
Get[FileNameJoin[{DirectoryName[base], "five_point_mrk_central_soft",
  "HRF_FivePointMRKExploratory.wl"}]];
graphData = hrf5MRKSeedData[{1, 2, 3, 5, 4}];

target = Get[FileNameJoin[{bundle, "five_point_mrk_exploration",
  "targeted_seed_2_exact-soft-plus_1_2.wl"}]];
targetScan = target["Scan"];
row = SelectFirst[targetScan["Rows"],
  Lookup[#, "Scaling", {}] === {-3, -2, 0, -3, -3, -2} &];

f = Expand[row["Polynomial"]];
vars = {x0, x1, x2, x3, x4, x5};
kinVars = {P, M, K, T};
assumptions = P > 0 && M > 0 && K > 0 && T > 0;
safe = DeleteDuplicates[Lookup[row["HRFScan"], "CancellationFactors", {}]];
bounds = hrfResolveGeneratorDegreeBounds[f, vars, <||>];

ClearAll[literalTrial];
literalTrial[generators_List] := Module[{positiveQ, obs},
  (* The standard pair-product admissibility helper rejects an irreducible
     derivative polynomial merely because it is not presented as a product
     of two harvested factors.  That is a representation restriction, not a
     positive-domain statement.  Test the literal generator locus directly. *)
  positiveQ = simultaneouslyAdmissibleSubsetQ[
    generators, vars, assumptions, kinVars
  ];
  If[! TrueQ[positiveQ],
    Return[<|"Generators" -> generators, "ValidQ" -> False,
      "Reason" -> "NoSimultaneousPositiveGeneratorLocus"|>]
  ];
  obs = obstructionByOriginalTermsGeneral[
    f, generators, vars, kinVars, Automatic, assumptions
  ];
  If[! (AssociationQ[obs] &&
      hrfValidObstructionResultQ[obs, generators, vars, kinVars]),
    Return[<|"Generators" -> generators, "ValidQ" -> False,
      "Reason" -> "NoExactSLObstructionDecomposition"|>]
  ];
  <|
    "Generators" -> generators,
    "GeneratorCount" -> Length[generators],
    "ValidQ" -> True,
    "PerGeneratorAdmissibleQ" -> True,
    "SimultaneouslyAdmissibleGeneratorSetQ" -> True,
    "AdmissibleSLSectorQ" -> True,
    "AdmissibleGeneratorSetQ" -> True,
    "ObstructionData" -> obs
  |>
];

generatorSets = Rest[Subsets[safe]];
trials = literalTrial /@ generatorSets;
validTrials = Select[trials, TrueQ[Lookup[#, "ValidQ", False]] &];
evaluations = hrfEvaluateValidTrialScaling[
    #, graphData["U"], vars, 12, Automatic, "ExactCoverage"
  ] & /@ validTrials;
scalingFound = Select[evaluations,
  TrueQ[Lookup[#, "ValidScalingQ", False]] &];

ClearAll[auditEvaluation];
auditEvaluation[ev_Association] := Module[{trial, cov, mini, testRow, audit},
  trial = ev["Trial"];
  cov = ev["CoverageScalingData"];
  mini = hrfHiddenRegionScanFromTrial[trial, cov, <||>, True];
  testRow = Join[row, <|
    "HRFScan" -> mini,
    "HRFSummary" -> <|
      "HiddenRegionQ" -> True,
      "StagedHiddenRegionQ" -> True,
      "CoverageScalingData" -> cov
    |>
  |>];
  audit = hrfAsymptoticOrderAlignmentTotalLowerFacetAudit[
    testRow, targetScan["TermData"], vars, graphData["U"], Identity, delta
  ];
  <|
    "Generators" -> Factor /@ ev["Generators"],
    "GeneratorCount" -> Length[ev["Generators"]],
    "Superleading" -> Factor[Lookup[
      trial["ObstructionData"], "Superleading", 0]],
    "Obstruction" -> Factor[Lookup[
      trial["ObstructionData"], "Obstruction", 0]],
    "RelativeScaling" -> Lookup[cov, "RationalScalingWithUnitGap",
      Lookup[cov, "Scaling", Missing["None"]]],
    "Audit" -> audit
  |>
];

audits = auditEvaluation /@ scalingFound;
certified = Select[audits,
  TrueQ[Lookup[Lookup[#, "Audit", <||>], "TotalLowerFacetQ", False]] &];

result = <|
  "AlignmentScaling" -> row["Scaling"],
  "AlignedPolynomial" -> f,
  "IrreducibleDerivativeGenerators" -> Factor /@ safe,
  "GeneratorSubsetCount" -> Length[generatorSets],
  "TrialOutcomeCounts" -> Counts[
    If[TrueQ[Lookup[#, "ValidQ", False]], "Valid",
      Lookup[#, "Reason", "SLSectorInadmissible"]] & /@ trials
  ],
  "ValidDecompositionCount" -> Length[validTrials],
  "ValidDecompositionCountByGeneratorNumber" ->
    Counts[Lookup[validTrials, "GeneratorCount", {}]],
  "CoverageScalingFoundCount" -> Length[scalingFound],
  "CoverageScalingFoundCountByGeneratorNumber" ->
    Counts[Length[Lookup[#, "Generators", {}]] & /@ scalingFound],
  "TotalFacetAuditCount" -> Length[audits],
  "CertifiedHiddenRegionCount" -> Length[certified],
  "CertifiedHiddenRegions" -> certified,
  "AllTotalFacetAudits" -> audits,
  "AllTrials" -> trials,
  "ValidTrials" -> validTrials
|>;

Print[InputForm[KeyDrop[result,
  {"AlignedPolynomial", "AllTrials", "ValidTrials", "AllTotalFacetAudits"}]]];
Export[FileNameJoin[{base,
  "five_point_central_soft_irreducible_generator_audit.wl"}],
  result, "Package"];
