$HistoryLength = 0;
$HRF5MRKLibraryOnly = True;
Get[FileNameJoin[{DirectoryName[$InputFileName], "HRF_FivePointMRKExploratory.wl"}]];
Get[FileNameJoin[{repoDirectory, "HRF_AsymptoticOrderAlignment.wl"}]];

ClearAll[targetedPreselectionFaces, targetedRun];
targetedPreselectionFaces[data_, rules_, range_, assumptions_] := Module[
  {expr, td, faces, rows},
  expr = Together[data["F"] /. rules];
  td = hrfAsymptoticOrderAlignmentTermTable[expr, data["Variables"], delta];
  faces = hrfAsymptoticOrderAlignmentEnumerateFaces[
    td, data["Variables"], "ScalingRange" -> range,
    "RequirePromotedQ" -> False, "MinFaceTerms" -> 2
  ];
  rows = hrfAsymptoticOrderAlignmentFaceScanRow[
      #, data["Variables"], "RunHRFQ" -> False,
      "KinematicAssumptions" -> assumptions
    ] & /@ faces;
  Select[rows, TrueQ[Lookup[#, "PreselectionPotentialPinchQ", False]] &]
];

targetedRun[data_, label_, rules_, range_, kinVars_, assumptions_] := Module[
  {survivors, vectors, scan},
  survivors = targetedPreselectionFaces[data, rules, range, assumptions];
  vectors = Lookup[survivors, "Scaling", {}];
  Print["[target] topology=", data["Topology"], " order=", data["ExternalOrder"],
    " chart=", label, " survivorFaces=", Length[vectors]];
  If[vectors === {},
    Return[<|
      "Topology" -> data["Topology"], "ExternalOrder" -> data["ExternalOrder"],
      "Chart" -> label, "PreselectionSurvivorCount" -> 0,
      "Scan" -> Missing["NoSurvivingFace"]
    |>]
  ];
  scan = hrfAsymptoticOrderAlignmentSearch[
    data["F"], data["Variables"],
    "EtaSymbol" -> delta,
    "KinematicRules" -> rules,
    "FaceVectors" -> vectors,
    "MinFaceTerms" -> 2,
    "RequirePromotedQ" -> False,
    "RunHRFQ" -> True,
    "KinematicAssumptions" -> assumptions,
    "KinematicVariables" -> kinVars,
    "MandelstamVariables" -> {},
    "DisableMandelstamLinearityForChartVariablesQ" -> True,
    "U" -> data["U"],
    "HRFOptions" -> {
      "MaxScalingAbs" -> 12,
      "CandidateGeneratorSetLimit" -> 256
    },
    "RequireTotalLowerFacetQ" -> True
  ];
  Print["[target] summary=", InputForm[scan["Summary"]]];
  <|
    "Topology" -> data["Topology"], "ExternalOrder" -> data["ExternalOrder"],
    "Chart" -> label, "PreselectionSurvivorCount" -> Length[vectors],
    "Scan" -> scan
  |>
];

If[! TrueQ[$HRF5MRKTargetedLibraryOnly],
orders = hrf5MRKCyclicOrders[];
orderIndex = If[Length[$ScriptCommandLine] >= 2,
  ToExpression[$ScriptCommandLine[[2]]], 2];
chartName = If[Length[$ScriptCommandLine] >= 3,
  $ScriptCommandLine[[3]], "soft-plus"];
softA = If[Length[$ScriptCommandLine] >= 4,
  ToExpression[$ScriptCommandLine[[4]]], 1];
softB = If[Length[$ScriptCommandLine] >= 5,
  ToExpression[$ScriptCommandLine[[5]]], 2];
topologyName = If[Length[$ScriptCommandLine] >= 6,
  $ScriptCommandLine[[6]], "seed"];

If[! IntegerQ[orderIndex] || orderIndex < 1 || orderIndex > Length[orders],
  Print["order index must lie in 1..", Length[orders]]; Exit[2]
];

data = Switch[topologyName,
  "seed", hrf5MRKSeedData[orders[[orderIndex]]],
  "pentagon", hrf5MRKPentagonData[orders[[orderIndex]]],
  _, Print["unknown topology: ", topologyName]; Exit[2]
];
Switch[chartName,
  "generic",
    rules = hrf5MRKGenericRules[];
    range = Range[-2, 0];
    kinVars = {S, A, B, T1, T2};
    assumptions = S > 0 && A > 0 && B > 0 && T1 > 0 && T2 > 0,
  "soft-plus",
    rules = hrf5MRKCentralSoftRules[softA, softB, 1];
    range = Range[-(softA + softB), 0];
    kinVars = {S, A, B, T, C};
    assumptions = S > 0 && A > 0 && B > 0 && T > 0 && C > 0,
  "soft-minus",
    rules = hrf5MRKCentralSoftRules[softA, softB, -1];
    range = Range[-(softA + softB), 0];
    kinVars = {S, A, B, T, C};
    assumptions = S > 0 && A > 0 && B > 0 && T > 0 && C > 0,
  "exact-soft-plus",
    rules = hrf5MRKExactCentralSoftRules[softA, softB, 1];
    range = Range[-(softA + softB), 0];
    kinVars = {P, M, K, R, T, C};
    assumptions = P > 0 && M > 0 && K > 0 && R > 0 && T > 0 && C > 0 &&
      C^2 < 4 R T,
  "exact-soft-minus",
    rules = hrf5MRKExactCentralSoftRules[softA, softB, -1];
    range = Range[-(softA + softB), 0];
    kinVars = {P, M, K, R, T, C};
    assumptions = P > 0 && M > 0 && K > 0 && R > 0 && T > 0 && C > 0 &&
      C^2 < 4 R T,
  _, Print["unknown chart: ", chartName]; Exit[2]
];

result = targetedRun[data, chartName, rules, range, kinVars, assumptions];
out = FileNameJoin[{DirectoryName[$InputFileName],
  "targeted_" <> topologyName <> "_" <> ToString[orderIndex] <> "_" <> chartName <>
    If[StringContainsQ[chartName, "soft"],
      "_" <> ToString[softA] <> "_" <> ToString[softB], ""] <> ".wl"}];
Export[out, result, "Package"];
Print["Exported ", out];
];
