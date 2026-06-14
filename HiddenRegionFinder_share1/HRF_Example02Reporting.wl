(* HRF_Example02Reporting.wl
   Reporting for Example 02: massless wide-angle vs three Regge channels. *)

ClearAll[
  hrfEx02Compact, hrfEx02HiddenQ, hrfEx02GeneratorsDifferQ, hrfEx02TrivialBoundaryQ,
  hrfEx02StudyRow, hrfEx02ComparisonRow, hrfEx02InteriorComparisonTable,
  hrfEx02BoundaryComparisonTable, hrfEx02ReggeOnlyFlagsTable, hrfEx02DiagramStudyTable,
  hrfEx02Narrative, hrfEx02ChannelLegend, hrfEx02ComparisonDisplayColumns,
  hrfEx02DisplayComparisonTable, hrfEx02InteriorComparisonDisplay,
  hrfEx02BoundaryComparisonDisplay
];

hrfEx02Compact[x_] := If[ValueQ[hrfCompact], hrfCompact[x], ToString[InputForm[x]]];

hrfEx02HiddenQ[scan_, scaling_: Automatic, zeroVars_: {}, configuration_: ""] := Module[{row},
  If[! AssociationQ[scan], Return[False]];
  row = hrfHiddenSummaryRow["probe", configuration, zeroVars, {}, scan, scaling];
  TrueQ[row["Hidden region identified?"] === "Yes"]
];

hrfEx02GeneratorsDifferQ[wideRow_, reggeRow_] := Module[{wg, rg},
  wg = Lookup[wideRow, "Generators", Missing["Absent"]];
  rg = Lookup[reggeRow, "Generators", Missing["Absent"]];
  ! MatchQ[wg, _Missing] && ! MatchQ[rg, _Missing] && wg =!= rg
];

hrfEx02TrivialBoundaryQ[boundaryRow_: <||>, wideRow_: <||>, reggeRow_: <||>] := Or[
  TrueQ[Lookup[boundaryRow, "Status", ""] === "TrivialBoundary"],
  TrueQ[Lookup[boundaryRow, "FRestricted", 1] === 0],
  StringContainsQ[ToString[Lookup[wideRow, "Comment", ""]], "trivial: restricted F is zero"],
  StringContainsQ[ToString[Lookup[reggeRow, "Comment", ""]], "trivial: restricted F is zero"]
];

hrfEx02StudyRow[diagram_, configuration_, channel_, zeroVars_, activeVars_, scan_, U_, scaling_: Automatic, maxAbs_: 5] := Module[
  {config, row},
  config = configuration;
  row = If[ValueQ[hrfEx01RegionStudyRow],
    hrfEx01RegionStudyRow[diagram, config, zeroVars, activeVars, scan, U, scaling, maxAbs],
    hrfHiddenSummaryRow[diagram, config, zeroVars, activeVars, scan, scaling]
  ];
  Join[row, <|
    "Diagram" -> diagram,
    "Kinematic regime" -> channel,
    "Regge channel detail" -> If[channel === "Wide",
      "wide-angle massless: both s12 and s23 active",
      hrfReggeChannelDescription[channel]
    ],
    "Boundary variables set to zero" -> hrfEx02Compact[zeroVars],
    "Region vector" -> hrfEx02Compact[activeVars]
  |>]
];

hrfEx02ComparisonRow[diagram_, regionLabel_, zeroVars_, wideRow_, reggeRow_, boundaryRow_: <||>] := Module[
  {wideHidden, reggeHidden, trivialQ, genDiffer, flag, note},
  wideHidden = TrueQ[Lookup[wideRow, "Hidden region identified?", "No"] === "Yes"];
  reggeHidden = TrueQ[Lookup[reggeRow, "Hidden region identified?", "No"] === "Yes"];
  trivialQ = hrfEx02TrivialBoundaryQ[boundaryRow, wideRow, reggeRow];
  genDiffer = hrfEx02GeneratorsDifferQ[wideRow, reggeRow];
  flag = Which[
    trivialQ, "Trivial boundary (F=0)",
    reggeHidden && ! wideHidden, "Regge-only hidden region",
    wideHidden && ! reggeHidden, "Wide-only hidden region",
    reggeHidden && wideHidden && genDiffer, "Hidden in both (different generators)",
    reggeHidden && wideHidden, "Hidden in both",
    True, "Hidden in neither"
  ];
  note = Which[
    trivialQ, "restricted F vanishes on this stratum; no propagator contraction",
    reggeHidden && wideHidden && genDiffer,
      "both regimes show a hidden region but with different generator sets",
    True, "--"
  ];
  <|
    "Diagram" -> diagram,
    "Region" -> regionLabel,
    "Boundary variables set to zero" -> hrfEx02Compact[zeroVars],
    "Wide hidden?" -> If[wideHidden, "Yes", "No"],
    "Regge channel" -> Lookup[reggeRow, "Kinematic regime", "--"],
    "Regge hidden?" -> If[reggeHidden, "Yes", "No"],
    "Comparison flag" -> flag,
    "Structural note" -> note,
    "Wide comment" -> Lookup[wideRow, "Comment", "--"],
    "Regge comment" -> Lookup[reggeRow, "Comment", "--"],
    "Wide generators" -> Lookup[wideRow, "Generators", "--"],
    "Regge generators" -> Lookup[reggeRow, "Generators", "--"]
  |>
];

hrfEx02InteriorComparisonTable[diagramStudy_Association] := Module[{rows = {}, wide, reg},
  wide = Lookup[diagramStudy, "Wide", Missing[]];
  If[AssociationQ[wide],
    Do[
      reg = Lookup[diagramStudy, regCh, Missing[]];
      If[AssociationQ[reg],
        AppendTo[rows, hrfEx02ComparisonRow[diagramStudy["Diagram"], "Interior", {}, wide, reg]]
      ],
      {regCh, hrfReggeChannels[]}
    ]
  ];
  Dataset[rows]
];

hrfEx02BoundaryComparisonTable[boundaryRows_List] := Dataset[
  Flatten @ Map[
    Function[row,
      If[! KeyExistsQ[row, "Wide"], Return[{}]];
      Map[
        Function[regCh,
          If[KeyExistsQ[row, regCh],
            hrfEx02ComparisonRow[row["Diagram"], row["Region"], row["ZeroVars"], row["Wide"], row[regCh], row],
            Nothing
          ]
        ],
        hrfReggeChannels[]
      ]
    ],
    boundaryRows
  ]
];

hrfEx02ReggeOnlyFlagsTable[interiorStudies_List, boundaryRows_List] := Module[{rows = {}},
  Do[
    Module[{study = interiorStudies[[i]]},
      Do[
        If[AssociationQ[study] && KeyExistsQ[study, regCh],
          Module[{cmp},
            cmp = hrfEx02ComparisonRow[study["Diagram"], "Interior", {}, study["Wide"], study[regCh]];
            If[cmp["Comparison flag"] =!= "Hidden in neither",
              AppendTo[rows, cmp]
            ]
          ]
        ],
        {regCh, hrfReggeChannels[]}
      ]
    ],
    {i, Length[interiorStudies]}
  ];
  Do[
    Module[{row = boundaryRows[[i]]},
      Do[
        If[KeyExistsQ[row, regCh],
          Module[{cmp},
            cmp = hrfEx02ComparisonRow[row["Diagram"], row["Region"], row["ZeroVars"], row["Wide"], row[regCh], row];
            If[cmp["Comparison flag"] =!= "Hidden in neither",
              AppendTo[rows, cmp]
            ]
          ]
        ],
        {regCh, hrfReggeChannels[]}
      ]
    ],
    {i, Length[boundaryRows]}
  ];
  Dataset[rows]
];

hrfEx02DiagramStudyTable[rows_List] := Dataset[rows];

hrfEx02ComparisonDisplayColumns[] := {
  "Diagram", "Region", "Regge channel", "Wide hidden?", "Regge hidden?",
  "Comparison flag", "Structural note", "Wide comment", "Regge comment"
};

hrfEx02DisplayComparisonTable[data_] := Module[{rows, cols},
  rows = Which[
    Head[data] === Dataset, Normal[data],
    ListQ[data], data,
    AssociationQ[data] && VectorQ[Values[data], AssociationQ], Values[data],
    True, {}
  ];
  cols = hrfEx02ComparisonDisplayColumns[];
  If[rows === {}, Dataset[{}], Dataset @ (KeyTake[#, cols] & /@ rows)]
];

hrfEx02InteriorComparisonDisplay[diagram_String] :=
  hrfEx02DisplayComparisonTable[Ex02InteriorComparisonTables[diagram]];

hrfEx02BoundaryComparisonDisplay[diagram_String] := Module[{tbl},
  tbl = Lookup[Ex02BoundaryComparisonTables, diagram, Dataset[{}]];
  hrfEx02DisplayComparisonTable[tbl]
];

hrfEx02ChannelLegend[] := Dataset[
  Map[
    Function[ch, <|
      "Regge channel" -> ch,
      "Description" -> hrfReggeChannelDescription[ch],
      "Kin vars" -> hrfEx02Compact[hrfReggeKinVars[ch]],
      "Assumptions" -> hrfEx02Compact[hrfReggeKinAssumptions[ch]]
    |>],
    hrfReggeChannels[]
  ]
];

hrfEx02Narrative[reggeOnlyTable_] := Module[
  {rows, reggeOnly, wideOnly, both, bothDiff, trivial},
  rows = If[Head[reggeOnlyTable] === Dataset, Normal[reggeOnlyTable], reggeOnlyTable];
  reggeOnly = Select[rows, Lookup[#, "Comparison flag", ""] === "Regge-only hidden region" &];
  wideOnly = Select[rows, Lookup[#, "Comparison flag", ""] === "Wide-only hidden region" &];
  both = Select[rows, Lookup[#, "Comparison flag", ""] === "Hidden in both" &];
  bothDiff = Select[rows, Lookup[#, "Comparison flag", ""] === "Hidden in both (different generators)" &];
  trivial = Select[rows, Lookup[#, "Comparison flag", ""] === "Trivial boundary (F=0)" &];
  StringRiffle[Flatten[{
    "Example 02 Regge vs wide-angle comparison summary.",
    "Convention: delta = -t/s > 0; leading Regge polynomial sets the small invariant to zero.",
    "Regge-only hidden regions (present in Regge, absent wide): " <> ToString[Length[reggeOnly]],
    If[reggeOnly =!= {},
      "  " <> StringRiffle[
        Lookup[#, "Diagram"] <> " " <> Lookup[#, "Region"] <> " (" <> Lookup[#, "Regge channel", "--"] <> ")" & /@ reggeOnly,
        ", "
      ],
      Nothing
    ],
    "Wide-only hidden regions (present wide, absent in that Regge channel): " <> ToString[Length[wideOnly]],
    If[wideOnly =!= {},
      "  " <> StringRiffle[
        Lookup[#, "Diagram"] <> " " <> Lookup[#, "Region"] <> " (" <> Lookup[#, "Regge channel", "--"] <> ")" & /@ wideOnly,
        ", "
      ],
      Nothing
    ],
    "Hidden in both (same generators): " <> ToString[Length[both]],
    "Hidden in both (different generators): " <> ToString[Length[bothDiff]],
    If[bothDiff =!= {},
      "  " <> StringRiffle[
        Lookup[#, "Diagram"] <> " " <> Lookup[#, "Region"] <> " (" <> Lookup[#, "Regge channel", "--"] <> ")" & /@ bothDiff,
        ", "
      ],
      Nothing
    ],
    "Trivial boundary strata (F=0 on restriction): " <> ToString[Length[trivial]],
    If[trivial =!= {},
      "  " <> StringRiffle[
        Lookup[#, "Diagram"] <> " " <> Lookup[#, "Region"] <> " (" <> Lookup[#, "Regge channel", "--"] <> ")" & /@ trivial,
        ", "
      ],
      Nothing
    ]
  }], "\n"]
];

Print["[loaded] Example 02 reporting. Try hrfEx02ReggeOnlyFlagsTable data after loading 02_Forward_Regge_2to2_Massless.wl."];
