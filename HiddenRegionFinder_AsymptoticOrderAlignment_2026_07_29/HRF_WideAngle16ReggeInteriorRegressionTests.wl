(* Regression tests for the cap-independent Regge interior audit. *)

$HRFWA16ReggeInteriorRegressionDirectory = Which[
  StringQ[$InputFileName] && $InputFileName =!= "" &&
      FileExistsQ[$InputFileName],
    DirectoryName[ExpandFileName[$InputFileName]],
  True,
    Directory[]
];

If[Length[DownValues[hrfWA16ReggeInteriorAudit]] == 0,
  Get[FileNameJoin[{$HRFWA16ReggeInteriorRegressionDirectory,
    "HRF_WideAngle16ReggeInteriorAudit.wl"}]]
];

ClearAll[hrfWA16ReggeTestRow, hrfRunWA16ReggeInteriorRegressionTests];

hrfWA16ReggeTestRow[name_, pass_, detail_: ""] := <|
  "Test" -> name,
  "PassQ" -> TrueQ[pass],
  "Detail" -> detail
|>;

hrfRunWA16ReggeInteriorRegressionTests[] := Module[
  {rows = {}, crownRec, crownAudits, summary, permutationClasses},
  crownRec = <|
    "ID" -> "Crown",
    "F0" -> F0Crown,
    "U" -> CrownData["UF"]["U"],
    "Vars" -> VarsCrown
  |>;
  crownAudits = hrfWA16ReggeInteriorAudit[crownRec, #] & /@
    {"T23", "T12", "T13"};
  AppendTo[rows, hrfWA16ReggeTestRow[
    "Crown.AllThreeChannelsHidden",
    AllTrue[crownAudits,
      TrueQ[Lookup[#, "HiddenRegionQ", False]] &&
        Lookup[#, "PositivePinchFaceCount", 0] === 1 &],
    "Each Regge channel has exactly one accepted Crown face"
  ]];
  AppendTo[rows, hrfWA16ReggeTestRow[
    "Crown.AllThreeChannelsResolved",
    Total[Lookup[crownAudits, "UnresolvedFaceCount", -1]] === 0,
    "The positive control contains no unresolved face"
  ]];
  AppendTo[rows, hrfWA16ReggeTestRow[
    "Crown.HierarchyGapOne",
    AllTrue[crownAudits,
      Lookup[
        Lookup[
          First[Lookup[#, "PositiveOrUnresolvedFaces", {<||>}]],
          "HierarchyAudit", <||>
        ],
        "MaxGap", Missing["Absent"]
      ] === 1 &],
    "The suppressed Regge layer fixes the accepted hierarchy gap to one"
  ]];

  summary = Get[FileNameJoin[{$HRFWA16ReggeInteriorRegressionDirectory, "results",
    "wa16_regge_interior_v1_summary.wl"}]];
  permutationClasses = Get[FileNameJoin[{$HRFWA16ReggeInteriorRegressionDirectory,
    "results", "wa16_regge_interior_v1_permutation_classes.wl"}]];
  AppendTo[rows, hrfWA16ReggeTestRow[
    "NoCrown.All48Complete",
    summary["GraphChannelCount"] === 48 &&
      summary["StatusCounts"] === <|"Complete" -> 48|>,
    "All sixteen graphs in all three Regge channels are covered"
  ]];
  AppendTo[rows, hrfWA16ReggeTestRow[
    "NoCrown.NoHiddenOrUnresolved",
    summary["PositivePinchFaceCount"] === 0 &&
      summary["UnresolvedFaceCount"] === 0 &&
      summary["HiddenRegionGraphChannelCount"] === 0,
    "Every Regge-leading face is excluded exactly"
  ]];
  AppendTo[rows, hrfWA16ReggeTestRow[
    "NoCrown.SixPermutationClasses",
    summary["ExactAuditClassCount"] === 12 &&
      summary["PermutationAuditClassCount"] === 6 &&
      Sort[Lookup[permutationClasses, "Multiplicity", {}]] ===
        {1, 1, 2, 2, 3, 3},
    "Explicit variable permutations reduce twelve exact triples to six audits"
  ]];
  AppendTo[rows, hrfWA16ReggeTestRow[
    "NoCrown.AllLeadingPolynomialsIrreducible",
    summary["IrreducibleReggeLeadingCount"] === 48,
    "No No-Crown interior has the Crown factorized Regge-leading polynomial"
  ]];
  <|
    "Rows" -> rows,
    "Summary" -> <|
      "Total" -> Length[rows],
      "Passed" -> Count[rows, r_ /; TrueQ[r["PassQ"]]],
      "Failed" -> Count[rows, r_ /; ! TrueQ[r["PassQ"]]]
    |>,
    "CrownAudits" -> crownAudits,
    "NoCrownSummary" -> summary
  |>
];
