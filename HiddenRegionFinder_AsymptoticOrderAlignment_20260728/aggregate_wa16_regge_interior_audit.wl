(* Expand the representative Regge interior audits to all 48 graph/channel
   cases using exact equality of {FRegge0, DeltaLayers, U}. *)

SetDirectory[DirectoryName[$InputFileName]];
$HRFRunWideAngle16NoCrownAuditOnLoad = False;
Get["HRF_WideAngle16ReggeInteriorAudit.wl"];

ClearAll[hrfWA16ReggeExactAuditClasses];

hrfWA16ReggeExactAuditClasses[] := Module[
  {rawRecords, triples = {}, members = {}, rec, triple, position, class},
  rawRecords = hrfWA16ParseDiagramRecords[hrfWA16InputFile[]];
  Do[
    rec = hrfWA16BuildData[raw];
    Do[
      triple = {
        Expand[hrfWA16ReggeLeadingPolynomial[rec["F0"], channel]],
        hrfWA16ReggeLayers[rec["F0"], channel],
        Expand[rec["U"]]
      };
      position = FirstPosition[triples, t_ /; SameQ[t, triple],
        Missing["NewClass"]];
      If[MissingQ[position],
        AppendTo[triples, triple];
        AppendTo[members, {}];
        class = Length[triples],
        class = First[position]
      ];
      AppendTo[members[[class]], <|
        "ID" -> rec["ID"],
        "Channel" -> channel,
        "PropagatorCount" -> Length[rec["Vars"]]
      |>],
      {channel, {"T23", "T12", "T13"}}
    ];
    Clear[rec, triple],
    {raw, rawRecords}
  ];
  MapIndexed[
    <|
      "Class" -> First[#2],
      "Representative" -> First[#1],
      "Members" -> #1,
      "Multiplicity" -> Length[#1]
    |> &,
    members
  ]
];

classes = hrfWA16ReggeExactAuditClasses[];
permutationClasses = Get[
  "results/wa16_regge_interior_v1_permutation_classes.wl"
];
auditedRows = Flatten @ Table[
  base = "results/wa16_regge_interior_v1_" <> ToLowerCase[channel];
  completed = If[FileExistsQ[base <> "_rows.wl"],
    Get[base <> "_rows.wl"], {}];
  partial = If[FileExistsQ[base <> "_partial_rows.wl"],
    Get[base <> "_partial_rows.wl"], {}];
  Values @ Association @ Map[
    {#ID, #Channel} -> # &,
    Join[completed, partial]
  ],
  {channel, {"T23", "T12", "T13"}}
];

classRows = Table[
  exactRepresentative = KeyTake[
    classes[[i, "Representative"]], {"ID", "Channel"}
  ];
  permutationClass = SelectFirst[
    permutationClasses,
    AnyTrue[
      Lookup[#, "Members", {}],
      SameQ[KeyTake[#, {"ID", "Channel"}], exactRepresentative] &
    ] &,
    Missing["PermutationClassNotFound", i]
  ];
  If[MissingQ[permutationClass],
    audited = permutationClass,
    auditSource = permutationClass["Representative"];
    audited = SelectFirst[
      auditedRows,
      SameQ[KeyTake[#, {"ID", "Channel"}], auditSource] &,
      Missing["PermutationRepresentativeNotAudited",
        permutationClass["PermutationClass"]]
    ]
  ];
  <|
    "Class" -> i,
    "Multiplicity" -> classes[[i, "Multiplicity"]],
    "Representative" -> classes[[i, "Representative"]],
    "Members" -> classes[[i, "Members"]],
    "PermutationAuditClass" -> If[AssociationQ[permutationClass],
      permutationClass["PermutationClass"], permutationClass],
    "AuditSource" -> If[AssociationQ[permutationClass],
      permutationClass["Representative"], Missing["Absent"]],
    "Audit" -> audited
  |>,
  {i, Length[classes]}
];

If[AnyTrue[classRows, MissingQ[Lookup[#, "Audit", Missing[]]] &],
  Print["INCOMPLETE: one or more exact audit classes have not been run."];
  Print[InputForm @ Select[classRows, MissingQ[Lookup[#, "Audit", Missing[]]] &]];
  Exit[3]
];

expandedRows = Flatten @ Table[
  audit = classRows[[i, "Audit"]];
  Join[
    KeyDrop[audit, {"ID", "Channel"}],
    member,
    <|
      "ExactAuditClass" -> i,
      "PermutationAuditClass" -> classRows[[i, "PermutationAuditClass"]],
      "AuditReusedQ" -> ! SameQ[
        KeyTake[member, {"ID", "Channel"}],
        classRows[[i, "AuditSource"]]
      ],
      "AuditSource" -> classRows[[i, "AuditSource"]]
    |>
  ],
  {i, Length[classRows]}, {member, classRows[[i, "Members"]]}
];

summary = Join[
  <|
    "GraphCount" -> 16,
    "ChannelCount" -> 3,
    "GraphChannelCount" -> Length[expandedRows],
    "ExactAuditClassCount" -> Length[classRows],
    "PermutationAuditClassCount" -> Length[permutationClasses],
    "DirectAuditCount" -> Count[expandedRows,
      r_ /; ! TrueQ[Lookup[r, "AuditReusedQ", True]]],
    "ReusedAuditCount" -> Count[expandedRows,
      r_ /; TrueQ[Lookup[r, "AuditReusedQ", False]]],
    "ExactReuseCriterion" -> "SameQ[{FRegge0, DeltaLayers, U}]",
    "PermutationReuseCriterion" ->
      "FRegge0 equal up to overall sign; DeltaLayers and U have identical exponent supports under an explicit Schwinger-variable permutation"
  |>,
  hrfWA16ReggeCompactSummary[expandedRows]
];

Export["results/wa16_regge_interior_v1_exact_classes.wl", classRows,
  "Package"];
Export["results/wa16_regge_interior_v1_all_48_rows.wl", expandedRows,
  "Package"];
Export["results/wa16_regge_interior_v1_summary.wl", summary, "Package"];
Print[InputForm[summary]];
