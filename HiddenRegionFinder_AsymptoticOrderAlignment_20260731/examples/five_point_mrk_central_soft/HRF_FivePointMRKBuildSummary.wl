$HistoryLength = 0;
base = DirectoryName[$InputFileName];
repo = DirectoryName[DirectoryName[base]];

ClearAll[load, hiddenCount, stagedCount, survivorCount];
load[name_] := Module[{paths, path},
  paths = {FileNameJoin[{base, name}],
    FileNameJoin[{DirectoryName[repo], "five_point_mrk_exploration", name}]};
  path = SelectFirst[paths, FileExistsQ, Missing["FileNotFound", name]];
  If[StringQ[path], Get[path], path]
];
hiddenCount[r_] := If[AssociationQ[Lookup[r, "Scan", Missing[]]],
  Lookup[r["Scan"]["Summary"], "HiddenRegionCount", 0], 0];
stagedCount[r_] := If[AssociationQ[Lookup[r, "Scan", Missing[]]],
  Lookup[r["Scan"]["Summary"], "StagedHiddenRegionCount", 0], 0];
survivorCount[r_] := Lookup[r, "PreselectionSurvivorCount", 0];

allLabels12Plus = load[
  "five_point_mrk_all_labels_full_layer_audit_1_2_plus.wl"];
allLabels13Plus = load[
  "five_point_mrk_all_labels_full_layer_audit_1_3_plus.wl"];
allLabels23Plus = load[
  "five_point_mrk_all_labels_full_layer_audit_2_3_plus.wl"];
allLabels12Minus = load[
  "five_point_mrk_all_labels_full_layer_audit_1_2_minus.wl"];

orderRows = Table[
  exactSeed = allLabels12Plus["Results"][[i, "Audit"]];
  exactPentagon = load["targeted_pentagon_" <> ToString[i] <>
    "_exact-soft-plus_1_2.wl"];
  genericSeed = load["targeted_seed_" <> ToString[i] <> "_generic.wl"];
  order = exactSeed["ExternalOrder"];
  <|
    "Index" -> i,
    "ExternalOrderAtVertices" -> order,
    "CentralGluonVertex" -> First@First@Position[order, 4],
    "CentralGluonAtFourValentVertexQ" ->
      MemberQ[{3, 5}, First@First@Position[order, 4]],
    "OneLoopCompositePreselectionSurvivors" -> survivorCount[exactPentagon],
    "OneLoopCompositeHiddenRegions" -> hiddenCount[exactPentagon],
    "TwoLoopGenericMRKPreselectionSurvivors" -> survivorCount[genericSeed],
    "TwoLoopGenericMRKStagedCandidates" -> stagedCount[genericSeed],
    "TwoLoopGenericMRKHiddenRegions" -> hiddenCount[genericSeed],
    "TwoLoopCompositePreselectionSurvivors" -> survivorCount[exactSeed],
    "TwoLoopCompositeStagedCandidates" -> stagedCount[exactSeed],
    "TwoLoopCompositeHiddenRegions" -> hiddenCount[exactSeed]
  |>,
  {i, 12}
];

representativeResult = allLabels12Plus["Results"][[2, "Audit"]];
representativeRow = First[representativeResult["Scan"]["HiddenRegionRows"]];
representativeAudit = representativeRow["TotalScalingAudit"];
representative = <|
  "ExternalOrderAtVertices" -> representativeResult["ExternalOrder"],
  "AlignedSuperleadingPolynomial" -> Factor[representativeRow["Polynomial"]],
  "CancellationGenerator" -> representativeRow["HRFSummary"]["Generators"],
  "FaceScaling" -> representativeAudit["FaceScaling"],
  "HRFScaling" -> representativeAudit["HRFScaling"],
  "TotalScaling" -> representativeAudit["TotalScaling"],
  "RelativeTotalScaling" -> representativeAudit["RelativeTotalScaling"],
  "WSL" -> representativeAudit["WSL"],
  "WHR" -> representativeAudit["WHR"],
  "HierarchyGap" -> representativeAudit["HierarchyGap"],
  "ResolvedFacetRank" -> representativeAudit["ResolvedWHRAffineRank"],
  "RequiredFacetRank" -> representativeAudit["RequiredFacetRank"],
  "AuditStatus" -> representativeAudit["AuditStatus"],
  "CertificationVectorSource" -> representativeAudit["CertificationVectorSource"]
|>;

hrOrders = Lookup[
  Select[orderRows, #["TwoLoopCompositeHiddenRegions"] > 0 &],
  "ExternalOrderAtVertices"
];

rateRows = Flatten @ Table[
  a = ab[[1]]; b = ab[[2]];
  rateAudit = Switch[{a, b}, {1, 2}, allLabels12Plus,
    {1, 3}, allLabels13Plus, {2, 3}, allLabels23Plus];
  r = rateAudit["Results"][[i, "Audit"]];
  <|
    "ExternalOrderAtVertices" -> r["ExternalOrder"],
    "a" -> a, "b" -> b, "p4PowerOverMRKPower" -> a/b,
    "HiddenRegionCount" -> hiddenCount[r]
  |>,
  {ab, {{1, 2}, {1, 3}, {2, 3}}},
  {i, {2, 3, 4, 5, 9, 10}}
];

signRows = Table[
  plus = allLabels12Plus["Results"][[i, "Audit"]];
  minus = allLabels12Minus["Results"][[i, "Audit"]];
  <|
    "ExternalOrderAtVertices" -> plus["ExternalOrder"],
    "PlusChartHiddenRegionCount" -> hiddenCount[plus],
    "MinusChartHiddenRegionCount" -> hiddenCount[minus]
  |>,
  {i, {2, 3, 4, 5, 9, 10}}
];

summary = <|
  "Status" -> "Full-native-layer exact-chart certificate",
  "MathematicaVersion" -> $Version,
  "OrderCount" -> Length[orderRows],
  "OneLoopCompositeHROrderCount" -> Count[
    Lookup[orderRows, "OneLoopCompositeHiddenRegions"], _?(# > 0 &)],
  "TwoLoopGenericMRKHROrderCount" -> Count[
    Lookup[orderRows, "TwoLoopGenericMRKHiddenRegions"], _?(# > 0 &)],
  "TwoLoopCompositeHROrderCount" -> Count[
    Lookup[orderRows, "TwoLoopCompositeHiddenRegions"], _?(# > 0 &)],
  "CompositeHROrders" -> hrOrders,
  "TopologyCriterionObserved" ->
    "HR iff p4 is attached to internal vertex 3 or 5 (the two four-valent vertices), within this 12-ordering two-loop seed scan",
  "OrderRows" -> orderRows,
  "RepresentativeCertificate" -> representative,
  "RateChecks" -> rateRows,
  "TransverseSignChecks" -> signRows
|>;

out = FileNameJoin[{base, "certified_summary.wl"}];
Export[out, summary, "Package"];
Print[InputForm[KeyDrop[summary, {"OrderRows", "RateChecks", "TransverseSignChecks"}]]];
Print["Exported ", out];
