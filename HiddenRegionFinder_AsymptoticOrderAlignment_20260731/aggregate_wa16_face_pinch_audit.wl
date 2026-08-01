(* Aggregate the exact higher-codimension face/pinch checkpoints. *)

SetDirectory[DirectoryName[$InputFileName]];
Get["HRF_WideAngle16NoCrownAudit.wl"];

rawRecords = hrfWA16ParseDiagramRecords[hrfWA16InputFile[]];
rows = Flatten @ Table[
  e = Length[raw["InternalLines"]];
  Table[
    path = "results/wa16_face_pinch_v1_id" <> ToString[raw["ID"]] <>
      "_codim" <> ToString[codim] <> "_summary.wl";
    If[FileExistsQ[path],
      Join[<|"ExpectedScanCount" -> Binomial[e, codim],
        "ResultFile" -> path|>, Get[path]],
      <|
        "ID" -> raw["ID"], "PropagatorCount" -> e,
        "Codimension" -> codim,
        "ExpectedScanCount" -> Binomial[e, codim],
        "ResultFile" -> path, "Status" -> "MissingResult"
      |>
    ],
    {codim, 4, e - 2}
  ],
  {raw, rawRecords}
];

completeRows = Select[rows,
  IntegerQ[Lookup[#, "ScanCount", Missing[]]] &&
    Lookup[#, "ScanCount"] === Lookup[#, "ExpectedScanCount"] &&
    Lookup[#, "UnresolvedFaceCount", 1] === 0 &
];

summary = <|
  "Method" -> "exact F0 face lattice, positive pinch equations, and oriented hierarchy LP",
  "CodimensionRange" -> "4 through E-2 for every graph",
  "ExpectedSummaryRowCount" -> Length[rows],
  "CompleteSummaryRowCount" -> Length[completeRows],
  "CompleteQ" -> (Length[completeRows] === Length[rows]),
  "ExpectedStratumCount" -> Total[Lookup[rows, "ExpectedScanCount", 0]],
  "ScannedStratumCount" -> Total[Lookup[rows, "ScanCount", 0]],
  "PositivePinchFaceCount" -> Total[Lookup[rows, "PositivePinchFaceCount", 0]],
  "HiddenRegionStratumCount" -> Total[Lookup[rows, "HiddenRegionStratumCount", 0]],
  "UnresolvedFaceCount" -> Total[Lookup[rows, "UnresolvedFaceCount", 0]],
  "Rows" -> rows
|>;

Export["results/wide_angle_16_face_pinch_higher_codim_summary.wl", summary, "Package"];
Print[InputForm[KeyDrop[summary, "Rows"]]];
