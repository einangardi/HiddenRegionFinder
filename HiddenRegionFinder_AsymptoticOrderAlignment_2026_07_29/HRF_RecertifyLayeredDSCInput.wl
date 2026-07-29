$HistoryLength = 0;

repoDirectory = DirectoryName[$InputFileName];
SetDirectory[repoDirectory];
$HRFQuietReports = True;
Get[FileNameJoin[{repoDirectory, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{repoDirectory, "HRF_AsymptoticOrderAlignment.wl"}]];

graphName = If[Length[$ScriptCommandLine] >= 2,
  $ScriptCommandLine[[2]], "hexbox"
];
inputFile = FileNameJoin[{
  repoDirectory, "results",
  "layered_recertification_input_DSC_" <> graphName <> ".wl"
}];
If[! FileExistsQ[inputFile], Print["Missing ", inputFile]; Exit[1]];

input = Import[inputFile, "WL"];
vars = input["Variables"];
termData = input["TermData"];
rows = input["Representatives"];
uPoly = SymanzikUF[
  input["Graph"]["InternalLines"], input["Graph"]["ExternalLines"]
]["U"];

compactAudit[row_Association, audit_Association] := Join[
  KeyTake[row, {"Scaling", "Weight", "EtaPowers", "Support",
    "PreselectionZeroVars"}],
  <|
    "Generators" -> Lookup[row["HRFSummary"], "Generators", {}],
    "CancellationFactors" ->
      Lookup[row["HRFSummary"], "CancellationFactors", {}],
    "FinalHiddenRegionQ" -> TrueQ[audit["TotalLowerFacetQ"]],
    "TotalScalingAudit" -> KeyTake[audit, {
      "AuditStatus", "TotalLowerFacetQ", "ScalelessRejectedQ",
      "TotalScaling", "RelativeTotalScaling", "WSL", "WHR",
      "HierarchyGap", "WHROnlyLowerFacetQ", "WHRAffineRank",
      "ResolvedWHRAffineRank", "RequiredFacetRank",
      "NormalizedInwardNormal", "CandidateNormal",
      "ResidualMonomialRescalingQ", "MonomialRescalingNullSpace",
      "CertificationVectorSource", "StagedComposedScaling",
      "StagedCompositionSupersededQ", "UniqueIdealJetSolutionQ",
      "IdealLayerCertification", "LayeredDissectionCertification"
    }]
  |>
];

Print["[layered recertify] graph=", graphName,
  ", representatives=", Length[rows]];
{elapsed, audited} = AbsoluteTiming[
  MapIndexed[
    Function[{row, index},
      Print["[layered recertify] row ", First[index], "/", Length[rows]];
      audit = hrfAsymptoticOrderAlignmentTotalLowerFacetAudit[
        row, termData, vars, uPoly, Factor, input["EtaSymbol"]
      ];
      compactAudit[row, audit]
    ],
    rows
  ]
];

accepted = Select[audited, TrueQ[#1["FinalHiddenRegionQ"]] &];
summary = <|
  "GraphName" -> graphName,
  "StagedPresentationCount" -> input["StagedPresentationCount"],
  "AuditedStructuralRepresentativeCount" -> Length[rows],
  "AcceptedStructuralRepresentativeCount" -> Length[accepted],
  "RejectedStructuralRepresentativeCount" -> Length[rows] - Length[accepted],
  "AuditStatusCounts" -> Counts[
    Lookup[Lookup[audited, "TotalScalingAudit"], "AuditStatus"]
  ],
  "ElapsedSeconds" -> elapsed
|>;

output = <|
  "Summary" -> summary,
  "FinalRepresentatives" -> accepted,
  "AuditedRepresentatives" -> audited
|>;
outputFile = FileNameJoin[{
  repoDirectory, "results", "facet_recertified_DSC_" <> graphName <> ".wl"
}];
Export[outputFile, output, "Package"];
Print["[layered recertify] summary=", InputForm[summary]];
Print["[layered recertify] output=", outputFile];
