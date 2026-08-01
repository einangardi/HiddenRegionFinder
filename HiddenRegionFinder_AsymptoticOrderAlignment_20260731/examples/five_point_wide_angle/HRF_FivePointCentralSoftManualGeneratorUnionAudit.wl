(* Exhaustive small-polynomial audit of multi-generator unions for the first
   two aligned central-soft layers.  The standard constructor preferentially
   restricts unions to kinematics-free pair generators; here every literal
   pair generator already harvested by HRF is allowed in the union. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
repo = DirectoryName[DirectoryName[base]];
$HRFPackageDirectory = repo;
$HRFQuietReports = True;
$HRFScalingReport = False;
Get[FileNameJoin[{repo, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{repo, "HRF_AsymptoticOrderAlignment.wl"}]];

saved = Get[FileNameJoin[{base,
  "five_point_central_soft_multigenerator_audit.wl"}]];
baseScan = saved["Scans"][1];
f = saved["Polynomial"];
vars = {x0, x1, x2, x3, x4, x5};
kinVars = {P, M, K, T};
assumptions = P > 0 && M > 0 && K > 0 && T > 0;
safe = Lookup[baseScan, "CancellationFactors", {}];
pairGenerators = DeleteDuplicates @ Flatten[
  Lookup[baseScan, "CandidateGeneratorSets", {}]
];
ClearAll[manualTrial];
manualTrial[generators_List] := Module[{obs},
  (* Every member of pairGenerators has already passed the standard literal
     per-generator positive-domain test in baseScan.  Repeating the
     semialgebraic test for each of the 1350 unions is unnecessary and much
     slower; what is new here is only the exact multi-generator ideal test. *)
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
    "ValidQ" -> True,
    "PerGeneratorAdmissibleQ" -> True,
    "AdmissibleSLSectorQ" -> True,
    "AdmissibleGeneratorSetQ" -> True,
    "ObstructionData" -> obs
  |>
];

trialsBySize = Association @ Table[
  n -> (manualTrial /@ Subsets[pairGenerators, {n}]),
  {n, 1, Min[3, Length[pairGenerators]]}
];
validBySize = Map[Select[#, TrueQ[Lookup[#, "ValidQ", False]] &] &,
  trialsBySize];

summary = Association @ KeyValueMap[
  #1 -> <|
    "TrialCount" -> Length[#2],
    "ValidCount" -> Length[validBySize[#1]],
    "DistinctSuperleadingSectors" -> DeleteDuplicates[
      Factor[Lookup[Lookup[#, "ObstructionData", <||>], "Superleading", 0]] & /@
        validBySize[#1]
    ],
    "ValidGeneratorSets" -> (Factor /@ Lookup[#, "Generators", {}] & /@
      validBySize[#1])
  |> &,
  trialsBySize
];

(* Test one smallest-generator representative of each distinct exact F_SL,
   first by the ordinary coverage equations and then against every native
   delta layer through the total lower-facet audit. *)
$HRF5MRKRepoDirectory = repo;
$HRF5MRKLibraryOnly = True;
Get[FileNameJoin[{DirectoryName[base], "five_point_mrk_central_soft",
  "HRF_FivePointMRKExploratory.wl"}]];
graphData = hrf5MRKSeedData[{1, 2, 3, 5, 4}];
allValid = Flatten[Values[validBySize]];
representatives = First /@ Values @ GroupBy[
  SortBy[allValid, Length[Lookup[#, "Generators", {}]] &],
  ToString[InputForm[Factor[
    Lookup[Lookup[#, "ObstructionData", <||>], "Superleading", 0]
  ]]] &
];
scalingEvaluations = hrfEvaluateValidTrialScaling[
    #, graphData["U"], vars, 12, Automatic, "ExactCoverage"
  ] & /@ representatives;
scalingFound = Select[scalingEvaluations,
  TrueQ[Lookup[#, "ValidScalingQ", False]] &];

bundle = DirectoryName[repo];
target = Get[FileNameJoin[{bundle, "five_point_mrk_exploration",
  "targeted_seed_2_exact-soft-plus_1_2.wl"}]];
targetScan = target["Scan"];
targetRow = SelectFirst[targetScan["Rows"],
  Lookup[#, "Scaling", {}] === {-3, -2, 0, -3, -3, -2} &];

ClearAll[totalAuditForEvaluation];
totalAuditForEvaluation[ev_Association] := Module[{trial, cov, mini, row},
  trial = ev["Trial"];
  cov = ev["CoverageScalingData"];
  mini = hrfHiddenRegionScanFromTrial[trial, cov, <||>, True];
  row = Join[targetRow, <|
    "HRFScan" -> mini,
    "HRFSummary" -> <|
      "HiddenRegionQ" -> True,
      "StagedHiddenRegionQ" -> True,
      "CoverageScalingData" -> cov
    |>
  |>];
  <|
    "Generators" -> Factor /@ ev["Generators"],
    "Superleading" -> Factor[
      Lookup[trial["ObstructionData"], "Superleading", 0]
    ],
    "RelativeScaling" -> Lookup[cov, "RationalScalingWithUnitGap",
      Lookup[cov, "Scaling", Missing["None"]]],
    "Audit" -> hrfAsymptoticOrderAlignmentTotalLowerFacetAudit[
      row, targetScan["TermData"], vars, graphData["U"], Identity, delta
    ]
  |>
];
totalAudits = totalAuditForEvaluation /@ scalingFound;
certified = Select[totalAudits,
  TrueQ[Lookup[Lookup[#, "Audit", <||>], "TotalLowerFacetQ", False]] &];

result = <|
  "Polynomial" -> f,
  "PairGeneratorCount" -> Length[pairGenerators],
  "PairGenerators" -> Factor /@ pairGenerators,
  "Summary" -> summary,
  "ValidTrialsBySize" -> validBySize,
  "DistinctSuperleadingRepresentativeCount" -> Length[representatives],
  "CoverageScalingFoundCount" -> Length[scalingFound],
  "TotalFacetAudits" -> totalAudits,
  "CertifiedHiddenRegions" -> certified
|>;
Print[InputForm[KeyValueMap[
  #1 -> KeyDrop[#2, "ValidGeneratorSets"] &,
  summary
]]];
Print["distinct FSL representatives: ", Length[representatives],
  "; coverage scalings: ", Length[scalingFound],
  "; total-facet certified: ", Length[certified]];
If[certified =!= {}, Print[InputForm[certified]]];
Export[FileNameJoin[{base,
  "five_point_central_soft_manual_generator_union_audit.wl"}],
  result, "Package"];
