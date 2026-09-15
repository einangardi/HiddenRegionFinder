(* Regression tests for the complete No-Crown Regge boundary audit. *)

$HRFWA16ReggeBoundaryRegressionDirectory = Which[
  StringQ[$InputFileName] && $InputFileName =!= "" &&
      FileExistsQ[$InputFileName],
    DirectoryName[ExpandFileName[$InputFileName]],
  True,
    Directory[]
];

If[Length[DownValues[hrfWA16ReggeBoundaryAudit]] == 0,
  Get[FileNameJoin[{$HRFWA16ReggeBoundaryRegressionDirectory,
    "HRF_WideAngle16ReggeBoundaryAudit.wl"}]]
];

ClearAll[hrfWA16ReggeBoundaryTestRow, hrfRunWA16ReggeBoundaryRegressionTests];
hrfWA16ReggeBoundaryTestRow[name_, pass_, detail_: ""] := <|
  "Test" -> name, "PassQ" -> TrueQ[pass], "Detail" -> detail
|>;

hrfRunWA16ReggeBoundaryRegressionTests[] := Module[
  {rows = {}, summary, classRows, channelRows, interior, raw, recs,
   q0Inherited, q0Direct, q1Direct, hyperCrown, certificateTotal},
  summary = Get[FileNameJoin[{$HRFWA16ReggeBoundaryRegressionDirectory, "results",
    "wa16_regge_boundary_v1_summary.wl"}]];
  classRows = Get[FileNameJoin[{$HRFWA16ReggeBoundaryRegressionDirectory, "results",
    "wa16_regge_boundary_v1_class_summary.wl"}]];
  channelRows = Get[FileNameJoin[{$HRFWA16ReggeBoundaryRegressionDirectory, "results",
    "wa16_regge_boundary_v1_channel_summary.wl"}]];
  interior = Get[FileNameJoin[{$HRFWA16ReggeBoundaryRegressionDirectory, "results",
    "wa16_regge_interior_v1_summary.wl"}]];

  AppendTo[rows, hrfWA16ReggeBoundaryTestRow[
    "Coverage.All343356Boundaries",
    summary["ExpandedBoundaryCount"] === 343356 &&
      summary["ExpectedExpandedBoundaryCount"] === 343356,
    "All nonempty contraction sets through E-2 in 48 graph/channel cases"
  ]];
  AppendTo[rows, hrfWA16ReggeBoundaryTestRow[
    "Coverage.SixParentClasses",
    Length[classRows] === 6 &&
      summary["RepresentativeBoundaryCount"] === 40872,
    "The exact channel/graph maps reduce the direct scan to six parents"
  ]];
  AppendTo[rows, hrfWA16ReggeBoundaryTestRow[
    "Channels.EqualCompleteCoverage",
    Lookup[channelRows, "BoundaryCount", {}] ===
      {114452, 114452, 114452} &&
      Total[Lookup[channelRows, "HiddenRegionStratumCount", -1]] === 0,
    "T23, T12 and T13 have identical expanded certificate totals"
  ]];
  certificateTotal = Total[Values[summary["ExpandedCertificateCounts"]]];
  AppendTo[rows, hrfWA16ReggeBoundaryTestRow[
    "Certificates.PartitionAllBoundaries",
    certificateTotal === summary["ExpandedBoundaryCount"] &&
      Sort[Keys[summary["ExpandedCertificateCounts"]]] === Sort[{
        "InheritedParentInteriorFaceClosure",
        "GlobalSubtractionFreeFirstNonzeroReggeLayer",
        "TrivialRestrictedReggePolynomial"
      }],
    "Every boundary has exactly one of the three complete certificates"
  ]];
  AppendTo[rows, hrfWA16ReggeBoundaryTestRow[
    "Conclusion.NoHiddenOrUnresolvedBoundary",
    summary["PositivePinchFaceCount"] === 0 &&
      summary["HiddenRegionStratumCount"] === 0 &&
      summary["UnresolvedFaceCount"] === 0,
    "No No-Crown boundary survives the necessary pinch test"
  ]];
  AppendTo[rows, hrfWA16ReggeBoundaryTestRow[
    "Conclusion.FullReggeNoCrown",
    interior["HiddenRegionGraphChannelCount"] === 0 &&
      interior["UnresolvedFaceCount"] === 0 &&
      summary["FullReggeNoCrownHiddenRegionQ"] === False,
    "Interior and every contraction boundary are both closed"
  ]];

  raw = hrfWA16ParseDiagramRecords[hrfWA16InputFile[]];
  recs = Association[Map[#ID -> hrfWA16BuildData[#] &, raw]];
  q0Inherited = hrfWA16ReggeBoundaryAudit[
    recs[85774], "T23", {x0, x1, x2, x3, x5, x6, x11}, True
  ];
  q0Direct = hrfWA16ReggeBoundaryAudit[
    recs[85774], "T23", {x0, x1, x2, x3, x5, x6, x11}, False
  ];
  AppendTo[rows, hrfWA16ReggeBoundaryTestRow[
    "ParentFaceClosure.DirectSpotCheck",
    q0Inherited["Certificate"] === "InheritedParentInteriorFaceClosure" &&
      q0Direct["HiddenRegionQ"] === False &&
      q0Direct["UnresolvedFaceCount"] === 0,
    "A small inherited coordinate-face certificate agrees with direct enumeration"
  ]];

  q1Direct = hrfWA16ReggeBoundaryAudit[
    recs[85774], "T23", {x1, x7}, False
  ];
  AppendTo[rows, hrfWA16ReggeBoundaryTestRow[
    "ExceptionalLayer.AbsoluteEtaOne",
    q1Direct["LeadingReggeEta"] === 1 &&
      q1Direct["Certificate"] ===
        "GlobalSubtractionFreeFirstNonzeroReggeLayer" &&
      q1Direct["HiddenRegionQ"] === False,
    "A vanishing delta^0 contraction is retained at delta^1 and rejected exactly"
  ]];

  hyperCrown = hrfWA16ReggeBoundaryAudit[
    <|
      "ID" -> "HyperCrown", "F0" -> F0HyperCrown,
      "U" -> HyperCrownData["UF"]["U"], "Vars" -> VarsHyperCrown
    |>,
    "T12", {x11}, False
  ];
  AppendTo[rows, hrfWA16ReggeBoundaryTestRow[
    "PositiveControl.HyperCrownBoundary",
    hyperCrown["HiddenRegionQ"] === True &&
      hyperCrown["PositivePinchFaceCount"] > 0 &&
      hyperCrown["UnresolvedFaceCount"] === 0,
    "The known boundary seed is not removed by the negative certificates"
  ]];

  <|
    "Rows" -> rows,
    "Summary" -> <|
      "Total" -> Length[rows],
      "Passed" -> Count[rows, r_ /; TrueQ[r["PassQ"]]],
      "Failed" -> Count[rows, r_ /; ! TrueQ[r["PassQ"]]]
    |>,
    "HyperCrownControl" -> KeyTake[
      hyperCrown,
      {"ID", "Channel", "ZeroVars", "LeadingReggeEta", "FaceCount",
       "PositivePinchFaceCount", "UnresolvedFaceCount", "HiddenRegionQ"}
    ],
    "ExceptionalEtaOneControl" -> KeyTake[
      q1Direct,
      {"ID", "Channel", "ZeroVars", "LeadingReggeEta", "Certificate",
       "HiddenRegionQ", "UnresolvedFaceCount"}
    ]
  |>
];
