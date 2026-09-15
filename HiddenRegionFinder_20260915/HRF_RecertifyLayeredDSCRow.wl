$HistoryLength = 0;
repoDirectory = DirectoryName[$InputFileName];
SetDirectory[repoDirectory];
$HRFQuietReports = True;
Get[FileNameJoin[{repoDirectory, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{repoDirectory, "HRF_AsymptoticOrderAlignment.wl"}]];

graphName = $ScriptCommandLine[[2]];
rowIndex = ToExpression[$ScriptCommandLine[[3]]];
input = Import[FileNameJoin[{
  repoDirectory, "results",
  "layered_recertification_input_DSC_" <> graphName <> ".wl"
}], "WL"];
row = input["Representatives"][[rowIndex]];
vars = input["Variables"];
uPoly = SymanzikUF[
  input["Graph"]["InternalLines"], input["Graph"]["ExternalLines"]
]["U"];
audit = hrfAsymptoticOrderAlignmentTotalLowerFacetAudit[
  row, input["TermData"], vars, uPoly, Factor, input["EtaSymbol"]
];
compact = Join[
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
outputFile = FileNameJoin[{
  repoDirectory, "results", "layered_rows_" <> graphName,
  "row_" <> IntegerString[rowIndex, 10, 3] <> ".wl"
}];
If[! DirectoryQ[DirectoryName[outputFile]],
  CreateDirectory[DirectoryName[outputFile]]
];
Export[outputFile, compact, "Package"];
Print["ROW ", rowIndex, " ", audit["AuditStatus"], " ",
  InputForm[audit["TotalScaling"]]];
