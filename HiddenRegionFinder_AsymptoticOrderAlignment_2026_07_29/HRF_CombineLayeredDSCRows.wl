$HistoryLength = 0;
repoDirectory = DirectoryName[$InputFileName];
SetDirectory[repoDirectory];
graphName = $ScriptCommandLine[[2]];

input = Import[FileNameJoin[{
  repoDirectory, "results",
  "layered_recertification_input_DSC_" <> graphName <> ".wl"
}], "WL"];
files = Sort @ FileNames[
  "row_*.wl",
  FileNameJoin[{repoDirectory, "results", "layered_rows_" <> graphName}]
];
rows = Import[#, "WL"] & /@ files;
accepted = Select[rows, TrueQ[Lookup[#, "FinalHiddenRegionQ", False]] &];
statuses = Lookup[Lookup[rows, "TotalScalingAudit"], "AuditStatus"];
summary = <|
  "GraphName" -> graphName,
  "StagedPresentationCount" -> input["StagedPresentationCount"],
  "AuditedStructuralRepresentativeCount" -> Length[rows],
  "AcceptedStructuralRepresentativeCount" -> Length[accepted],
  "RejectedStructuralRepresentativeCount" -> Length[rows] - Length[accepted],
  "AuditStatusCounts" -> Counts[statuses]
|>;
outputFile = FileNameJoin[{
  repoDirectory, "results", "facet_recertified_DSC_" <> graphName <> ".wl"
}];
Export[outputFile, <|
  "Summary" -> summary,
  "FinalRepresentatives" -> accepted,
  "AuditedRepresentatives" -> rows
|>, "Package"];
Print[InputForm[summary]];
