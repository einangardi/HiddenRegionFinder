$HistoryLength = 0;
repoDirectory = DirectoryName[$InputFileName];
SetDirectory[repoDirectory];

graphName = If[Length[$ScriptCommandLine] >= 2,
  $ScriptCommandLine[[2]], "hexbox"
];
sourceFile = FileNameJoin[{
  repoDirectory, "results", "generated",
  "dsc_" <> graphName <> "_alignment_scan.wl"
}];
If[! FileExistsQ[sourceFile], Print["Missing ", sourceFile]; Exit[1]];

result = Import[sourceFile, "WL"];
scan = result["Scan"];
groups = Lookup[
  scan,
  "StagedDeduplicatedHiddenRegionGroups",
  Lookup[scan, "DeduplicatedHiddenRegionGroups", {}]
];
presentations = Lookup[
  scan,
  "StagedHiddenRegionRows",
  Lookup[scan, "HiddenRegionRows", {}]
];
compact = <|
  "Graph" -> result["Graph"],
  "EtaSymbol" -> scan["EtaSymbol"],
  "Variables" -> scan["Variables"],
  "TermData" -> scan["TermData"],
  "Representatives" -> Lookup[groups, "Representative", {}],
  "StagedPresentationCount" -> Length[presentations]
|>;
outputFile = FileNameJoin[{
  repoDirectory, "results",
  "layered_recertification_input_DSC_" <> graphName <> ".wl"
}];
Export[outputFile, compact, "Package"];
Print["Prepared ", outputFile, " with ",
  Length[compact["Representatives"]], " structural representatives."];
