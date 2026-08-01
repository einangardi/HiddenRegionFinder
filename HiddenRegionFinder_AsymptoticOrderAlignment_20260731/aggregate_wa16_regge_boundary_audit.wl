(* Aggregate the six representative boundary scans and expand them through
   the exact graph/channel and Schwinger-permutation maps to all 48 cases. *)

SetDirectory[DirectoryName[$InputFileName]];

ClearAll[hrfScaleCountAssociation, hrfMergeCountAssociations];
hrfScaleCountAssociation[a_Association, n_Integer] := Association @
  KeyValueMap[#1 -> n #2 &, a];
hrfMergeCountAssociations[list_List] := If[
  list === {}, <||>, Merge[list, Total]
];

permutationClasses = Get[
  "results/wa16_regge_interior_v1_permutation_classes.wl"
];
exactClasses = Get["results/wa16_regge_interior_v1_exact_classes.wl"];
interiorSummary = Get["results/wa16_regge_interior_v1_summary.wl"];

fullMultiplicity = Association @ Table[
  i -> Total[
    Length[Lookup[#, "Members", {}]] & /@
      Select[exactClasses, Lookup[#, "PermutationAuditClass", 0] === i &]
  ],
  {i, Length[permutationClasses]}
];

classCodimRows = Flatten @ Table[
  e = If[i <= 2, 12, 13];
  Table[
    Get[
      "results/wa16_regge_boundary_v1_class" <> ToString[i] <>
        "_codim" <> ToString[k] <> "_summary.wl"
    ],
    {k, 1, e - 2}
  ],
  {i, Length[permutationClasses]}
];

classRows = Table[
  rows = Select[classCodimRows, #["PermutationClass"] === i &];
  <|
    "PermutationClass" -> i,
    "Representative" -> permutationClasses[[i, "Representative"]],
    "GraphChannelMultiplicity" -> fullMultiplicity[i],
    "PropagatorCount" -> First[rows]["PropagatorCount"],
    "CodimensionRange" -> {1, First[rows]["PropagatorCount"] - 2},
    "RepresentativeBoundaryCount" -> Total[Lookup[rows, "ScanCount", 0]],
    "ExpandedBoundaryCount" ->
      fullMultiplicity[i] Total[Lookup[rows, "ScanCount", 0]],
    "RepresentativeStatusCounts" -> hrfMergeCountAssociations[
      Lookup[rows, "StatusCounts", <||>]
    ],
    "RepresentativeCertificateCounts" -> hrfMergeCountAssociations[
      Lookup[rows, "CertificateCounts", <||>]
    ],
    "RepresentativeLeadingEtaCounts" -> hrfMergeCountAssociations[
      Lookup[rows, "LeadingReggeEtaCounts", <||>]
    ],
    "PositivePinchFaceCount" -> Total[
      Lookup[rows, "PositivePinchFaceCount", 0]
    ],
    "UnresolvedFaceCount" -> Total[Lookup[rows, "UnresolvedFaceCount", 0]],
    "HiddenRegionStratumCount" -> Total[
      Lookup[rows, "HiddenRegionStratumCount", 0]
    ]
  |>,
  {i, Length[permutationClasses]}
];

expandedStatusCounts = hrfMergeCountAssociations @ Table[
  hrfScaleCountAssociation[
    classRows[[i, "RepresentativeStatusCounts"]],
    classRows[[i, "GraphChannelMultiplicity"]]
  ],
  {i, Length[classRows]}
];
expandedCertificateCounts = hrfMergeCountAssociations @ Table[
  hrfScaleCountAssociation[
    classRows[[i, "RepresentativeCertificateCounts"]],
    classRows[[i, "GraphChannelMultiplicity"]]
  ],
  {i, Length[classRows]}
];
expandedLeadingEtaCounts = hrfMergeCountAssociations @ Table[
  hrfScaleCountAssociation[
    classRows[[i, "RepresentativeLeadingEtaCounts"]],
    classRows[[i, "GraphChannelMultiplicity"]]
  ],
  {i, Length[classRows]}
];

(* Attach the parent class to each of the 48 exact graph/channel cases. *)
allCases = Flatten @ Map[
  Function[exact,
    Append[#, "PermutationClass" -> exact["PermutationAuditClass"]] & /@
      exact["Members"]
  ],
  exactClasses
];
channelRows = Table[
  cases = Select[allCases, #["Channel"] === channel &];
  perCase = Table[
    class = classRows[[cases[[j, "PermutationClass"]]]];
    <|
      "BoundaryCount" -> class["RepresentativeBoundaryCount"],
      "CertificateCounts" -> class["RepresentativeCertificateCounts"],
      "HiddenRegionStratumCount" -> class["HiddenRegionStratumCount"],
      "UnresolvedFaceCount" -> class["UnresolvedFaceCount"]
    |>,
    {j, Length[cases]}
  ];
  <|
    "Channel" -> channel,
    "GraphCount" -> Length[cases],
    "BoundaryCount" -> Total[Lookup[perCase, "BoundaryCount", 0]],
    "CertificateCounts" -> hrfMergeCountAssociations[
      Lookup[perCase, "CertificateCounts", <||>]
    ],
    "HiddenRegionStratumCount" -> Total[
      Lookup[perCase, "HiddenRegionStratumCount", 0]
    ],
    "UnresolvedFaceCount" -> Total[
      Lookup[perCase, "UnresolvedFaceCount", 0]
    ]
  |>,
  {channel, {"T23", "T12", "T13"}}
];

summary = <|
  "GraphCount" -> 16,
  "ChannelCount" -> 3,
  "GraphChannelCount" -> 48,
  "PermutationClassCount" -> Length[classRows],
  "RepresentativeBoundaryCount" -> Total[
    Lookup[classRows, "RepresentativeBoundaryCount", 0]
  ],
  "ExpandedBoundaryCount" -> Total[
    Lookup[classRows, "ExpandedBoundaryCount", 0]
  ],
  "ExpectedExpandedBoundaryCount" ->
    3 (4 (2^12 - 1 - 12 - 1) + 12 (2^13 - 1 - 13 - 1)),
  "ExpandedStatusCounts" -> expandedStatusCounts,
  "ExpandedCertificateCounts" -> expandedCertificateCounts,
  "ExpandedLeadingEtaCounts" -> expandedLeadingEtaCounts,
  "PositivePinchFaceCount" -> Total[
    Lookup[classRows, "PositivePinchFaceCount", 0]
  ],
  "UnresolvedFaceCount" -> Total[
    Lookup[classRows, "UnresolvedFaceCount", 0]
  ],
  "HiddenRegionStratumCount" -> Total[
    Lookup[classRows, "HiddenRegionStratumCount", 0]
  ],
  "InteriorHiddenRegionGraphChannelCount" ->
    interiorSummary["HiddenRegionGraphChannelCount"],
  "InteriorUnresolvedFaceCount" -> interiorSummary["UnresolvedFaceCount"],
  "FullReggeNoCrownHiddenRegionQ" -> False,
  "ParentFaceClosureStatement" ->
    "When the restricted delta^0 coefficient is nonzero, it is a coordinate face of the already-complete parent Regge-leading Newton polytope; every face of that restriction was therefore already excluded by the parent interior audit.",
  "ExceptionalLayerStatement" ->
    "Whenever the delta^0 coefficient vanishes on a contraction, the first nonzero delta^1 coefficient is subtraction-free up to one overall sign.",
  "Scope" ->
    "All nonempty contraction sets through E-2 for all 16 graphs and T23, T12, T13, expanded exactly from six permutation classes."
|>;

Export[
  "results/wa16_regge_boundary_v1_class_codim_summary.wl",
  classCodimRows, "Package"
];
Export["results/wa16_regge_boundary_v1_class_summary.wl", classRows, "Package"];
Export[
  "results/wa16_regge_boundary_v1_channel_summary.wl",
  channelRows, "Package"
];
Export["results/wa16_regge_boundary_v1_summary.wl", summary, "Package"];
Print[InputForm[summary]];
Print["CLASS SUMMARY"];
Print[InputForm[classRows]];
Print["CHANNEL SUMMARY"];
Print[InputForm[channelRows]];
