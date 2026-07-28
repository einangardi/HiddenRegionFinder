$HistoryLength = 0;

repoDirectory = DirectoryName[$InputFileName];
SetDirectory[repoDirectory];

$HRFQuietReports = True;
Get[FileNameJoin[{repoDirectory, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{repoDirectory, "HRF_AsymptoticOrderAlignment.wl"}]];

graphName = If[Length[$ScriptCommandLine] >= 2, $ScriptCommandLine[[2]], "hexagon"];
fullFile = FileNameJoin[{
  repoDirectory, "results", "generated",
  "dsc_" <> graphName <> "_alignment_scan.wl"
}];
If[! FileExistsQ[fullFile], Print["Missing ", fullFile]; Exit[1]];

result = Import[fullFile, "WL"];
scan = result["Scan"];
vars = scan["Variables"];
termData = scan["TermData"];
uPoly = SymanzikUF[
  result["Graph"]["InternalLines"], result["Graph"]["ExternalLines"]
]["U"];
allStagedRows = Lookup[scan, "StagedHiddenRegionRows", Missing["OldScan"]];
If[MissingQ[allStagedRows],
  allStagedRows = Lookup[scan, "HiddenRegionRows", {}]
];
storedGroups = Lookup[
  scan,
  "StagedDeduplicatedHiddenRegionGroups",
  Lookup[scan, "DeduplicatedHiddenRegionGroups", Missing["NoStoredGroups"]]
];
If[ListQ[storedGroups],
  stagedRows = Lookup[storedGroups, "Representative", {}],
  stagedRows = allStagedRows
];

Print["[recertify] graph=", graphName,
  ", staged presentations=", Length[allStagedRows],
  ", structural representatives=", Length[stagedRows]];
{elapsed, auditedRows} = AbsoluteTiming[
  MapIndexed[
    Function[{row, index},
      If[Mod[First[index], 25] == 1 || First[index] == Length[stagedRows],
        Print["[recertify] row ", First[index], "/", Length[stagedRows]]
      ];
      hrfAsymptoticOrderAlignmentApplyTotalLowerFacetAudit[
        row, termData, vars, uPoly, Factor, True, scan["EtaSymbol"]
      ]
    ],
    stagedRows
  ]
];

finalRows = Select[
  auditedRows, TrueQ[Lookup[#["HRFSummary"], "HiddenRegionQ", False]] &
];
stagedGroups = hrfAsymptoticOrderAlignmentStructuralDeduplicateRows[auditedRows, vars];
finalGroups = hrfAsymptoticOrderAlignmentStructuralDeduplicateRows[finalRows, vars];

compactAudit[row_Association] := Join[
  KeyTake[row, {"Scaling", "Weight", "EtaPowers", "Support",
    "PreselectionZeroVars"}],
  <|
    "Generators" -> Lookup[row["HRFSummary"], "Generators", {}],
    "FinalHiddenRegionQ" -> Lookup[row["HRFSummary"], "HiddenRegionQ", False],
    "TotalScalingAudit" -> KeyTake[Lookup[row, "TotalScalingAudit", <||>], {
      "AuditStatus", "TotalLowerFacetQ", "ScalelessRejectedQ",
      "TotalScaling", "RelativeTotalScaling", "WSL", "WHR",
      "WHROnlyLowerFacetQ", "WHRAffineRank", "ResolvedWHRAffineRank",
      "WHRNormalizedInwardNormal", "WHRPositiveEtaNormalQ",
      "RequiredFacetRank", "WHRSourceCounts", "ResolvedWHRSourceCounts",
      "NormalizedInwardNormal", "CandidateNormal",
      "ResidualMonomialRescalingQ", "MonomialRescalingNullSpace",
      "CertificationVectorSource", "StagedComposedScaling",
      "StagedCompositionSupersededQ", "UniqueIdealJetSolutionQ",
      "IdealLayerCertification", "LayeredDissectionCertification"
    }]
  |>
];

summary = <|
  "GraphName" -> graphName,
  "StagedPresentationCount" -> Length[allStagedRows],
  "AuditedStructuralRepresentativeCount" -> Length[stagedRows],
  "FinalPresentationCount" -> Missing["NotReexpandedFromStructuralGroups"],
  "FinalStructuralRepresentativeCount" -> Length[finalRows],
  "ScalelessRejectedStructuralCount" -> Length[stagedRows] - Length[finalRows],
  "StagedUniqueCount" -> Length[stagedGroups],
  "FinalUniqueCount" -> Length[finalGroups],
  "AuditStatusCounts" -> If[auditedRows === {}, <||>, Counts[
    Lookup[Lookup[auditedRows, "TotalScalingAudit", <||>], "AuditStatus", "Missing"]
  ]],
  "ElapsedSeconds" -> elapsed
|>;

compactResult = <|
  "Summary" -> summary,
  "FinalRepresentatives" -> (compactAudit[#["Representative"]] & /@ finalGroups),
  "StagedRepresentatives" -> (compactAudit[#["Representative"]] & /@ stagedGroups),
  "AuditedPresentations" -> (compactAudit /@ auditedRows)
|>;
outputFile = FileNameJoin[{
  repoDirectory, "results", "facet_recertified_DSC_" <> graphName <> ".wl"
}];
Export[outputFile, compactResult, "Package"];
Print["[recertify] summary=", InputForm[summary]];
Print["[recertify] output=", outputFile];
