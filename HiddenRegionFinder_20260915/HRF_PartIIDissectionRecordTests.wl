(* Fast consistency checks for the exhaustive two-loop zero-recoil NMRK
   Part-II/dissection records.  This validates the compact saved results; it
   does not rerun the expensive local chart enumeration. *)

$HistoryLength = 0;
testDirectory = DirectoryName[$InputFileName];
resultDirectory = FileNameJoin[{testDirectory, "results", "nmrk_wz"}];

planar = Get[FileNameJoin[{resultDirectory,
  "partII_dissection_13_candidate_audit.wl"}]];
samePath = Get[FileNameJoin[{resultDirectory,
  "partII_dissection_same_path_hexagon_pentagon_audit.wl"}]];
separatePath = Get[FileNameJoin[{resultDirectory,
  "partII_dissection_separate_path_hexagon_pentagon_audit.wl"}]];
comparison = Get[FileNameJoin[{resultDirectory,
  "partII_dissection_table8_topology_comparison.wl"}]];

ClearAll[hrfPartIIRecordTest];
hrfPartIIRecordTest[name_, value_, expected_] := <|
  "Test" -> name,
  "Value" -> value,
  "Expected" -> expected,
  "PassQ" -> TrueQ[value === expected]
|>;

rows = {
  hrfPartIIRecordTest["Planar.StagedCandidates",
    planar["Summary", "StagedCandidateCount"], 13],
  hrfPartIIRecordTest["Planar.CertifiedCandidates",
    planar["Summary", "CandidatesWithAtLeastOneCertificate"], 13],
  hrfPartIIRecordTest["Planar.SearchesCompleteQ",
    planar["Summary", "AllCandidateSearchesCompleteQ"], True],
  hrfPartIIRecordTest["Planar.PhysicalHRs",
    planar["Summary", "DistinctPhysicalHRCount"], 25],
  hrfPartIIRecordTest["Planar.InteriorBoundarySplit",
    Lookup[planar["Summary"], {"InteriorPhysicalHRCount",
      "CodimensionOnePhysicalHRCount"}], {13, 12}],
  hrfPartIIRecordTest["SamePath.StagedCandidates",
    samePath["Summary", "StagedCandidateCount"], 8],
  hrfPartIIRecordTest["SamePath.CertifiedCandidates",
    samePath["Summary", "CandidatesWithAtLeastOneCertificate"], 4],
  hrfPartIIRecordTest["SamePath.SearchesCompleteQ",
    samePath["Summary", "AllCandidateSearchesCompleteQ"], True],
  hrfPartIIRecordTest["SamePath.PhysicalHRs",
    samePath["Summary", "DistinctPhysicalHRCount"], 9],
  hrfPartIIRecordTest["SamePath.InteriorBoundarySplit",
    Lookup[samePath["Summary"], {"InteriorPhysicalHRCount",
      "CodimensionOnePhysicalHRCount"}], {3, 6}],
  hrfPartIIRecordTest["SeparatePath.StagedCandidates",
    separatePath["Summary", "StagedCandidateCount"], 0],
  hrfPartIIRecordTest["Comparison.PhysicalHRCounts",
    Lookup[comparison["TopologyComparison"], "PhysicalHRs"], {25, 9, 0}]
};

summary = <|
  "Passed" -> Count[rows, row_ /; TrueQ[row["PassQ"]]],
  "Failed" -> Count[rows, row_ /; ! TrueQ[row["PassQ"]]],
  "Total" -> Length[rows]
|>;

Print[InputForm[summary]];
If[summary["Failed"] > 0,
  Print[InputForm[Select[rows, ! TrueQ[#1["PassQ"]] &]]];
  Exit[1]
];
