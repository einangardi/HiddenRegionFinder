(* HRF_Example02Reporting.wl
   Reporting for Example 02: massless wide-angle vs three Regge channels. *)

ClearAll[
  hrfEx02Compact, hrfEx02HiddenQ, hrfEx02DecompositionOKQ, hrfEx02GeneratorsDifferQ, hrfEx02TrivialBoundaryQ,
  hrfEx02StudyRow, hrfEx02ComparisonRow, hrfEx02InteriorComparisonTable,
  hrfEx02BoundaryComparisonTable, hrfEx02ReggeOnlyFlagsTable, hrfEx02DiagramStudyTable,
  hrfEx02Narrative, hrfEx02ChannelLegend, hrfEx02ComparisonDisplayColumns,
  hrfEx02DisplayComparisonTable, hrfEx02InteriorComparisonDisplay,
  hrfEx02BoundaryComparisonDisplay, hrfEx02BoundaryChannelDetailRow,
  hrfEx02BoundaryChannelDetailTable, hrfEx02SuperCrownReggeChannelSummary,
  hrfEx02SuperCrownBoundaryNarrative, hrfEx02SuperCrownBoundaryInspect,
  hrfEx02HRBasisLabel, hrfEx02HRConfidenceRow, hrfEx02BoundaryHRConfidenceTable,
  hrfEx02DiagramBoundaryInspect, hrfEx02HRBasisLabel, hrfEx02HRConfidenceRow,
  hrfEx02BoundaryHRConfidenceTable, hrfEx02PostLoadCheck, hrfEx02RequireLoad, hrfEx02ShowDiagram,
  hrfEx02CrownSanityColumns, hrfEx02CrownSanityDisplay, hrfEx02GraphDrawReadyQ,
  hrfEx02ChannelCase, hrfEx02CasePopulatedQ, hrfEx02CaseExtract, hrfEx02CaseIngredients,
  hrfEx02CaseFromBoundaryRow, hrfEx02CaseFromCrownSanity, hrfEx02ReggeChannelDisplay,
  hrfEx02CrownSanityChannelDisplay, hrfEx02HyperCrownBoundaryDisplay
];

hrfEx02Compact[x_] := If[ValueQ[hrfCompact], hrfCompact[x], ToString[InputForm[x]]];

(* DownValue-defined reporting symbols are not ValueQ-True; use DownValues instead. *)
hrfEx02PolynomialFactorReportingLoadedQ[] :=
  Length[DownValues[hrfEx04ScanPrimaryIngredients]] > 0;

hrfEx02EnsurePolynomialFactorReporting[] := Module[{dir},
  If[hrfEx02PolynomialFactorReportingLoadedQ[], Return[True]];
  dir = Which[
    ValueQ[$HRFExample02Directory] && StringQ[$HRFExample02Directory], $HRFExample02Directory,
    StringQ[$InputFileName] && $InputFileName =!= "", DirectoryName[$InputFileName],
    True, Directory[]
  ];
  Get[FileNameJoin[{dir, "HRF_PolynomialFactorReporting.wl"}]];
  hrfEx02PolynomialFactorReportingLoadedQ[]
];

hrfEx02HiddenQ[scan_, scaling_: Automatic, zeroVars_: {}, configuration_: ""] := Module[{row},
  If[! AssociationQ[scan], Return[False]];
  row = hrfHiddenSummaryRow["probe", configuration, zeroVars, {}, scan, scaling];
  TrueQ[row["Hidden region identified?"] === "Yes"]
];

(* Match hrfHiddenSummaryRow decompOK: successful obstruction decomposition with admissible generators. *)
hrfEx02DecompositionOKQ[scan_] := Module[{gens, admQ, hasGeneratorsQ},
  If[! AssociationQ[scan], Return[False]];
  gens = Lookup[scan, "Generators", {}];
  hasGeneratorsQ = ListQ[gens] && Length[gens] > 0;
  admQ = TrueQ[Lookup[scan, "AdmissibleGeneratorSetQ", False]];
  hrfSuccessfulObstructionDecompositionQ[scan] && admQ && hasGeneratorsQ
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
  row = If[Length[DownValues[hrfEx01RegionStudyRow]] > 0,
    hrfEx01RegionStudyRow[diagram, config, zeroVars, activeVars, scan, U, scaling, maxAbs],
    hrfHiddenSummaryRow[diagram, config, zeroVars, activeVars, scan, hrfScalingDataAssoc[scaling]]
  ];
  Join[row, <|
    "Diagram" -> diagram,
    "Kinematic regime" -> channel,
    "Regge channel detail" -> If[channel === "Wide",
      "wide-angle massless: both s12 and s23 active",
      hrfReggeChannelDescription[channel]
    ],
    "Boundary variables set to zero" -> hrfEx02Compact[zeroVars],
    "Region vector" -> hrfEx02Compact[activeVars],
    "Exact reduction?" -> If[ValueQ[hrfExactReductionQ], hrfExactReductionQ[scan], False],
    "Obstruction decomposition OK?" -> hrfEx02DecompositionOKQ[scan],
    "Generator set admissible?" -> TrueQ[Lookup[scan, "AdmissibleGeneratorSetQ", False]],
    "Cancellation factor count" -> Length[Lookup[scan, "CancellationFactors", {}]],
    "Generator count" -> Length[Lookup[scan, "Generators", {}]]
  |>]
];

hrfEx02HRBasisLabel[studyRow_Association] := Module[{hiddenQ, exactQ, scalingStatus},
  hiddenQ = TrueQ[Lookup[studyRow, "Hidden region identified?", "No"] === "Yes"];
  If[! hiddenQ, Return["not hidden"]];
  exactQ = TrueQ[Lookup[studyRow, "Exact reduction?", False]];
  scalingStatus = Lookup[studyRow, "Scaling status", "--"];
  Which[
    StringContainsQ[ToString[scalingStatus], "determined"], "scaling vector",
    exactQ, "exact reduction (F_SL=0; no scaling vector required)",
    True, "unclassified"
  ]
];

hrfEx02HRConfidenceRow[studyRow_Association, regionLabel_:Automatic, channel_:Automatic] := Module[
  {hiddenQ},
  hiddenQ = TrueQ[Lookup[studyRow, "Hidden region identified?", "No"] === "Yes"];
  <|
    "Region" -> If[regionLabel === Automatic, Lookup[studyRow, "Configuration", "--"], regionLabel],
    "Channel" -> If[channel === Automatic, Lookup[studyRow, "Kinematic regime", "--"], channel],
    "Boundary zero vars" -> Lookup[studyRow, "Boundary variables set to zero", "--"],
    "Region vector" -> Lookup[studyRow, "Region vector", "--"],
    "Hidden region identified?" -> Lookup[studyRow, "Hidden region identified?", "No"],
    "HR basis" -> hrfEx02HRBasisLabel[studyRow],
    "Obstruction decomposition OK?" -> Lookup[studyRow, "Obstruction decomposition OK?", "--"],
    "Obstruction + F_SL = F_0^restricted?" -> Lookup[studyRow, "Obstruction + F_SL = F_0^restricted?", "--"],
    "F_SL in generator ideal?" -> Lookup[studyRow, "F_SL in generator ideal?", "--"],
    "Generators" -> Lookup[studyRow, "Generators", "--"],
    "Generator count" -> Lookup[studyRow, "Generator count", "--"],
    "Obstruction" -> Lookup[studyRow, "Obstruction (F_0^restricted terms not in F_SL ideal)", 
      Lookup[studyRow, "Obstruction", "--"]],
    "F_SL" -> Lookup[studyRow, "F_SL (= F_0^restricted - Obstruction)", Lookup[studyRow, "F_SL sector", "--"]],
    "Scaling status" -> Lookup[studyRow, "Scaling status", "--"],
    "Scaling vector" -> Lookup[studyRow, "Scaling vector", "--"],
    "Variable scaling by region variable" -> Lookup[studyRow, "Variable scaling by region variable", "--"],
    "W_SL" -> Lookup[studyRow, "W_SL", "--"],
    "W_HR" -> Lookup[studyRow, "W_HR", "--"],
    "Variables at W_SL" -> Lookup[studyRow, "Variables at W_SL", "--"],
    "Variables at W_HR" -> Lookup[studyRow, "Variables at W_HR", "--"],
    "Comment" -> Lookup[studyRow, "Comment", "--"]
  |>
];

hrfEx02BoundaryHRConfidenceTable[diagram_String] := Module[{rows, conf},
  rows = Select[Ex02BoundaryRows, Lookup[#, "Diagram", ""] === diagram &];
  conf = Flatten @ Map[
    Function[bndRow,
      Module[{channels = Prepend[hrfReggeChannels[], "Wide"]},
        Select[
          hrfEx02HRConfidenceRow[bndRow[#], bndRow["Region"], #] & /@ channels,
          TrueQ[Lookup[#, "Hidden region identified?", "No"] === "Yes"] &
        ]
      ]
    ],
    rows
  ];
  Dataset[conf]
];

hrfEx02DiagramBoundaryInspect[diagram_String] := Module[{rows, detail, hr, cmp, narrative},
  rows = Select[Ex02BoundaryRows, Lookup[#, "Diagram", ""] === diagram &];
  If[rows === {},
    Return[<|"Error" -> "No boundary rows for diagram " <> diagram|>]
  ];
  detail = hrfEx02BoundaryChannelDetailTable[diagram];
  hr = hrfEx02BoundaryHRConfidenceTable[diagram];
  cmp = hrfEx02BoundaryComparisonDisplay[diagram];
  narrative = If[diagram === "SuperCrown",
    hrfEx02SuperCrownBoundaryNarrative[rows],
    StringRiffle[{
      diagram <> " boundary study (Example 02).",
      "Strata: " <> StringRiffle[Lookup[#, "Region"] & /@ rows, ", "],
      "HR confidence rows (hidden=Yes only): " <> ToString[Length[Normal @ hr]]
    }, "\n"]
  ];
  Print[narrative];
  <|
    "Narrative" -> narrative,
    "ComparisonTable" -> cmp,
    "HRConfidenceTable" -> hr,
    "ChannelDetailTable" -> detail,
    "ReggeChannelSummary" -> If[diagram === "SuperCrown",
      hrfEx02SuperCrownReggeChannelSummary[rows],
      Missing["SuperCrownOnly"]
    ]
  |>
];

hrfEx02RequireLoad[] := If[
  ! TrueQ[Ex02LoadCompleteQ] || ! ValueQ[CrownInternalEdges],
  (
    Print["Example 02 is not loaded. Evaluate the setup cell (In[1]) and wait for:"];
    Print["  === Example 02 LOAD COMPLETE ==="];
    Abort[]
  )
];

hrfEx02ShowDiagram[internalEdges_, externalEdges_] := Module[{g},
  hrfEx02RequireLoad[];
  g = drawGraphFromPySecDecInput[internalEdges, externalEdges];
  If[! MatchQ[g, _Graph | _Legended],
    Print["drawGraphFromPySecDecInput did not return a Graph: ", g];
    Return[$Failed]
  ];
  g
];

hrfEx02GraphDrawReadyQ[] := TrueQ[$HRFFinderCoreLoadedQ] ||
  Length[DownValues[drawGraphFromPySecDecInput]] > 0;

hrfEx02PostLoadCheck[] := Module[{ok, nBnd, coreOnly},
  nBnd = If[ListQ[Ex02BoundaryRows], Length[Ex02BoundaryRows], 0];
  coreOnly = TrueQ[Ex02LoadCompleteQ] && nBnd === 0;
  ok = TrueQ[Ex02LoadCompleteQ] && Length[OwnValues[CrownInternalEdges]] > 0 &&
    hrfEx02GraphDrawReadyQ[] && (nBnd > 0 || coreOnly);
  Print["Package directory: ", If[ValueQ[$HRFExample02Directory], $HRFExample02Directory, "--"]];
  Print["Ex02LoadCompleteQ: ", TrueQ[Ex02LoadCompleteQ]];
  Print["CrownInternalEdges defined: ", Length[OwnValues[CrownInternalEdges]] > 0];
  Print["Boundary rows computed: ", nBnd];
  Print["Ex02BoundaryRows diagrams: ", If[nBnd > 0, DeleteDuplicates[Lookup[Ex02BoundaryRows, "Diagram", {}]], "(none — run boundary cells)"]];
  If[! ok,
    Print["*** STOP: Example 02 did not finish loading. Re-evaluate the setup cell (In[1]) and wait for '=== Example 02 CORE LOAD COMPLETE ===' or 'LOAD COMPLETE' before other cells. ***"];
    Return[False]
  ];
  If[nBnd === 0,
    Print["OK: core loaded.", Which[
      MatchQ[Ex02CrownSanityRow, _Dataset],
        " Crown Regge sanity: " <> StringRiffle[
          (Lookup[#, "Kinematic regime", "--"] <> " HR=" <> Lookup[#, "Hidden region identified?", "--"]) & /@ Normal[Ex02CrownSanityRow],
          "; "
        ],
      AssociationQ[Ex02CrownSanityRow],
        " Crown sanity HR=" <> ToString[Lookup[Ex02CrownSanityRow, "Hidden region identified?", "--"]] <>
          ", region vector=" <> ToString[Lookup[Ex02CrownSanityRow, "Region vector", "--"]],
      True, ""
    ]];
    Print["Run hrfEx02RunSuperCrownBoundary[] or hrfEx02RunHyperCrownBoundary[] (one per fresh kernel)."];
    Return[True]
  ];
  Print["OK: safe to evaluate diagram and boundary cells."];
  True
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
    "Region vector" -> Lookup[wideRow, "Region vector", hrfEx02Compact[Lookup[boundaryRow, "RemainingVars", {}]]],
    "Wide hidden?" -> If[wideHidden, "Yes", "No"],
    "Regge channel" -> Lookup[reggeRow, "Kinematic regime", "--"],
    "Regge hidden?" -> If[reggeHidden, "Yes", "No"],
    "Wide scaling status" -> Lookup[wideRow, "Scaling status", "--"],
    "Regge scaling status" -> Lookup[reggeRow, "Scaling status", "--"],
    "Wide exact reduction?" -> Lookup[wideRow, "Exact reduction?", False],
    "Regge exact reduction?" -> Lookup[reggeRow, "Exact reduction?", False],
    "Wide HR basis" -> If[wideHidden, hrfEx02HRBasisLabel[wideRow], "--"],
    "Regge HR basis" -> If[reggeHidden, hrfEx02HRBasisLabel[reggeRow], "--"],
    "Wide scaling vector" -> Lookup[wideRow, "Scaling vector", "--"],
    "Regge scaling vector" -> Lookup[reggeRow, "Scaling vector", "--"],
    "Wide variable scaling" -> Lookup[wideRow, "Variable scaling by region variable", "--"],
    "Regge variable scaling" -> Lookup[reggeRow, "Variable scaling by region variable", "--"],
    "Wide decomposition OK?" -> Lookup[wideRow, "Obstruction decomposition OK?", False],
    "Regge decomposition OK?" -> Lookup[reggeRow, "Obstruction decomposition OK?", False],
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
  "Diagram", "Region", "Regge channel", "Region vector",
  "Wide hidden?", "Regge hidden?", "Wide HR basis", "Regge HR basis",
  "Wide scaling status", "Regge scaling status",
  "Wide scaling vector", "Regge scaling vector",
  "Wide variable scaling", "Regge variable scaling",
  "Wide decomposition OK?", "Regge decomposition OK?",
  "Comparison flag", "Structural note",
  "Wide generators", "Regge generators",
  "Wide comment", "Regge comment"
};

hrfEx02CrownSanityColumns[] := {
  "Diagram", "Kinematic regime", "Region vector", "Hidden region identified?",
  "Obstruction decomposition OK?", "Obstruction + F_SL = F_0^restricted?", "Generators", "Scaling status",
  "Scaling vector", "Variable scaling by region variable",
  "Variables at W_SL", "Variables at W_HR", "Comment"
};

hrfEx02CrownSanityDisplay[] := Module[{rows},
  hrfEx02RequireLoad[];
  If[! ValueQ[Ex02CrownSanityRow],
    Return @ Dataset @ {<|
      "Message" -> "Crown sanity not run. Re-evaluate setup In[1] ($HRFRunEx02CrownSanityOnLoad=True) or hrfEx02RunCrownSanityCheck[]."
    |>}
  ];
  rows = Which[
    MatchQ[Ex02CrownSanityRow, _Dataset], Normal[Ex02CrownSanityRow],
    AssociationQ[Ex02CrownSanityRow], {Ex02CrownSanityRow},
    True, {<|"Message" -> "Crown sanity data has unexpected form."|>}
  ];
  Dataset[KeyTake[#, hrfEx02CrownSanityColumns[]] & /@ rows]
];

hrfEx02BoundaryChannelDetailRow[boundaryRow_Association, channel_String] := Module[
  {study, chMeta},
  study = Lookup[boundaryRow, channel, <||>];
  chMeta = Lookup[Lookup[boundaryRow, "ChannelMeta", <||>], channel, <||>];
  <|
    "Diagram" -> Lookup[boundaryRow, "Diagram", "--"],
    "Region" -> Lookup[boundaryRow, "Region", "--"],
    "Boundary zero vars" -> hrfEx02Compact[Lookup[boundaryRow, "ZeroVars", {}]],
    "Codimension" -> Length[Lookup[boundaryRow, "ZeroVars", {}]],
    "Channel" -> channel,
    "Regge limit" -> If[channel === "Wide",
      "wide-angle: s12 and s23 active",
      hrfReggeChannelDescription[channel]
    ],
    "F monomials" -> Lookup[chMeta, "FMonomialCount", "--"],
    "Factor pool size" -> Lookup[chMeta, "FactorPoolSize", "--"],
    "Generator mode" -> Lookup[chMeta, "GeneratorMode", "--"],
    "Region vector" -> Lookup[study, "Region vector", hrfEx02Compact[Lookup[boundaryRow, "RemainingVars", {}]]],
    "Hidden region identified?" -> Lookup[study, "Hidden region identified?", "No"],
    "HR basis" -> hrfEx02HRBasisLabel[study],
    "Exact reduction?" -> Lookup[study, "Exact reduction?", Lookup[chMeta, "ExactReductionQ", False]],
    "Obstruction decomposition OK?" -> Lookup[study, "Obstruction decomposition OK?", False],
    "F_SL in generator ideal?" -> Lookup[study, "F_SL in generator ideal?", "--"],
    "Obstruction + F_SL = F_0^restricted?" -> Lookup[study, "Obstruction + F_SL = F_0^restricted?", "--"],
    "Generator set admissible?" -> Lookup[study, "Generator set admissible?", False],
    "Generator count" -> Lookup[study, "Generator count", "--"],
    "Generators" -> Lookup[study, "Generators", "--"],
    "Scaling status" -> Lookup[study, "Scaling status", "--"],
    "Scaling vector" -> Lookup[study, "Scaling vector", "--"],
    "W_SL" -> Lookup[study, "W_SL", "--"],
    "W_HR" -> Lookup[study, "W_HR", "--"],
    "Variables at W_SL" -> Lookup[study, "Variables at W_SL", "--"],
    "Variables at W_HR" -> Lookup[study, "Variables at W_HR", "--"],
    "Comment" -> Lookup[study, "Comment", "--"]
  |>
];

hrfEx02BoundaryChannelDetailTable[diagram_String] := Module[{rows},
  rows = Select[Ex02BoundaryRows, Lookup[#, "Diagram", ""] === diagram &];
  If[rows === {}, Dataset[{}],
    Dataset @ Flatten @ Map[
      Function[bndRow,
        hrfEx02BoundaryChannelDetailRow[bndRow, #] & /@ Prepend[hrfReggeChannels[], "Wide"]
      ],
      rows
    ]
  ]
];

hrfEx02SuperCrownReggeChannelSummary[boundaryRows_: Automatic] := Module[{rows, scRows},
  rows = Which[
    boundaryRows === Automatic,
      Select[Ex02BoundaryRows, Lookup[#, "Diagram", ""] === "SuperCrown" &],
    ListQ[boundaryRows], boundaryRows,
    True, {}
  ];
  scRows = Flatten @ Map[
    Function[bndRow,
      Module[{wideHidden, regStudy, regHidden},
        wideHidden = TrueQ[Lookup[bndRow["Wide"], "Hidden region identified?", "No"] === "Yes"];
        Map[
          Function[ch,
            regStudy = bndRow[ch];
            regHidden = TrueQ[Lookup[regStudy, "Hidden region identified?", "No"] === "Yes"];
            <|
              "Region" -> bndRow["Region"],
              "Boundary zero vars" -> hrfEx02Compact[bndRow["ZeroVars"]],
              "Region vector" -> Lookup[bndRow["Wide"], "Region vector",
                hrfEx02Compact[Lookup[bndRow, "RemainingVars", {}]]],
              "Regge channel" -> ch,
              "Regge limit (t,s)" -> hrfReggeChannelDescription[ch],
              "Wide hidden on stratum?" -> If[wideHidden, "Yes", "No"],
              "Regge hidden?" -> If[regHidden, "Yes", "No"],
              "Regge exact reduction?" -> Lookup[regStudy, "Exact reduction?", False],
              "Regge scaling status" -> Lookup[regStudy, "Scaling status", "--"],
              "Regge scaling vector" -> Lookup[regStudy, "Scaling vector", "--"],
              "Regge variable scaling" -> Lookup[regStudy, "Variable scaling by region variable", "--"],
              "Regge generators" -> Lookup[regStudy, "Generators", "--"],
              "Regge comment" -> Lookup[regStudy, "Comment", "--"],
              "Factor pool size" -> Lookup[Lookup[bndRow, "ChannelMeta", <||>], ch, <||>]["FactorPoolSize", "--"]
            |>
          ],
          hrfReggeChannels[]
        ]
      ]
    ],
    rows
  ];
  Dataset[scRows]
];

hrfEx02SuperCrownBoundaryNarrative[boundaryRows_: Automatic] := Module[
  {rows, summary, reggeHits, wideHits, perRegion},
  rows = Which[
    boundaryRows === Automatic,
      Select[Ex02BoundaryRows, Lookup[#, "Diagram", ""] === "SuperCrown" &],
    ListQ[boundaryRows], boundaryRows,
    True, {}
  ];
  If[rows === {}, Return["No SuperCrown boundary rows. Set $HRFRunEx02SuperCrownBoundary=True and reload Example 02."]];
  summary = Normal @ hrfEx02SuperCrownReggeChannelSummary[rows];
  reggeHits = Select[summary, TrueQ[Lookup[#, "Regge hidden?", "No"] === "Yes"] &];
  wideHits = Select[summary, TrueQ[Lookup[#, "Wide hidden on stratum?", "No"] === "Yes"] &];
  perRegion = GroupBy[summary, Lookup[#, "Region", "--"] &];
  StringRiffle[Flatten[{
    "SuperCrown boundary study (Example 02).",
    "Physics expectation: no interior wide-angle HR; boundary strata may show Regge HR in one or more of T23/T12/T13 (channel-dependent Regge limit).",
    "Boundary strata scanned: " <> ToString[Length[rows]] <> " (" <>
      StringRiffle[ToString[InputForm[#["ZeroVars"]]] & /@ rows, ", "] <> ").",
    "Wide-angle HR on boundary (any channel row): " <> ToString[Length[wideHits]] <> " channel-rows.",
    "Regge HR on boundary: " <> ToString[Length[reggeHits]] <> " channel-rows.",
    If[reggeHits =!= {},
      "Regge HR found in: " <> StringRiffle[
        Lookup[#, "Region"] <> " / " <> Lookup[#, "Regge channel"] & /@ reggeHits, ", "
      ],
      "Regge HR found in: (none in current scan). Inspect per-channel scaling status and factor pool sizes below; HR may appear in only one Regge channel if the active t-channel does not match the boundary geometry."
    ],
    KeyValueMap[
      Function[{region, chRows},
        region <> ": " <> StringRiffle[
          Lookup[#, "Regge channel"] <> " -> Regge hidden=" <> Lookup[#, "Regge hidden?"] <>
            ", scaling=" <> ToString[InputForm[Lookup[#, "Regge scaling status"]]] <>
            ", exact red=" <> ToString[Lookup[#, "Regge exact reduction?"]] & /@ chRows,
          " | "
        ]
      ],
      perRegion
    ]
  }], "\n"]
];

hrfEx02SuperCrownBoundaryInspect[] := hrfEx02DiagramBoundaryInspect["SuperCrown"];

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

hrfEx02InteriorComparisonDisplay[diagram_String] := Module[{tbl},
  If[! ValueQ[Ex02InteriorComparisonTables] || ! AssociationQ[Ex02InteriorComparisonTables] ||
      ! KeyExistsQ[Ex02InteriorComparisonTables, diagram],
    Return @ Dataset @ {<|
      "Message" -> "Interior studies not run. Evaluate hrfEx02BuildInteriorStudies[] (optional In[8]) first."
    |>}
  ];
  tbl = Ex02InteriorComparisonTables[diagram];
  hrfEx02DisplayComparisonTable[tbl]
];

hrfEx02BoundaryComparisonDisplay[diagram_String] := Module[{tbl},
  hrfEx02RequireLoad[];
  tbl = Lookup[Ex02BoundaryComparisonTables, diagram, Dataset[{}]];
  If[Normal[tbl] === {} || tbl === Dataset[{}],
    Print["No boundary rows for ", diagram, ". Re-run setup In[1] if needed."];
  ];
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

(* ---------------------------------------------------------------------- *)
(* Extract / Ingredients reporting (mirrors Ex04 hrfEx04CaseExtract pattern) *)
(* ---------------------------------------------------------------------- *)

hrfEx02ChannelCase[scan_, vars_, zeroVars_, label_, U_:Automatic] := <|
  "Label" -> label,
  "ZeroVars" -> zeroVars,
  "RemainingVars" -> vars,
  "PolynomialScan" -> scan,
  "URestricted" -> If[! MatchQ[U, Automatic | Missing], U, Missing["NotSupplied"]]
|>;

hrfEx02CasePopulatedQ[case_] := AssociationQ[case] && KeyExistsQ[case, "PolynomialScan"] &&
  AssociationQ[Lookup[case, "PolynomialScan", None]];

hrfEx02CaseExtract[case_Association] := Module[
  {scan, activeVars, zeroVars, label, trialRows, admRows, hrScans},
  If[! hrfEx02CasePopulatedQ[case], Return[Missing["NotRun", "No PolynomialScan in case association."]]];
  scan = case["PolynomialScan"];
  activeVars = Which[
    KeyExistsQ[case, "RemainingVars"], case["RemainingVars"],
    KeyExistsQ[scan, "ActiveVars"], scan["ActiveVars"],
    True, {}
  ];
  zeroVars = Lookup[case, "ZeroVars", Lookup[scan, "ZeroVars", {}]];
  label = Lookup[case, "Label", "case"];
  trialRows = If[hrfEx02EnsurePolynomialFactorReporting[],
    hrfPolyGeneratorSetScalingRows[scan, activeVars],
    {}
  ];
  admRows = Select[trialRows,
    TrueQ[Lookup[#, "AdmissibleSLSectorQ", False]] &&
      TrueQ[Lookup[#, "PerGeneratorAdmissibleQ", False]] &
  ];
  hrScans = Lookup[scan, "HiddenRegionScans", {}];
  <|
    "Primary" -> If[hrfEx02EnsurePolynomialFactorReporting[],
      hrfEx04ScanPrimaryIngredients[scan, activeVars, zeroVars, label],
      Missing["ReportingNotLoaded", "Load HRF_PolynomialFactorReporting.wl"]
    ],
    "TrialRows" -> trialRows,
    "AdmissibleTrialRows" -> admRows,
    "HiddenRegionCount" -> Lookup[scan, "HiddenRegionCount", Length[hrScans]],
    "HiddenRegionScans" -> hrScans,
    "HiddenRegionIngredients" -> Table[
      If[hrfEx02EnsurePolynomialFactorReporting[],
        hrfEx04ScanPrimaryIngredients[hrScans[[i]], activeVars, zeroVars, label <> " / HR " <> ToString[i]],
        Missing["ReportingNotLoaded"]
      ],
      {i, Length[hrScans]}
    ],
    "Scan" -> scan,
    "Case" -> case
  |>
];

hrfEx02CaseIngredients[case_Association] := Module[{ex, primary, hrPos},
  ex = hrfEx02CaseExtract[case];
  If[MatchQ[ex, _Missing], Return[ex]];
  primary = ex["Primary"];
  If[MatchQ[primary, _Missing], Return[primary]];
  hrPos = Select[ex["TrialRows"], TrueQ[Lookup[#, "HiddenRegionQ", False]] &];
  <|
    "Case" -> Lookup[primary, "Case", "case"],
    "RegionVariables" -> Lookup[primary, "RegionVariables", {}],
    "BoundaryZeroVariables" -> Lookup[primary, "BoundaryZeroVariables", {}],
    "Generators" -> Lookup[primary, "Generators", {}],
    "ScalingVector" -> Lookup[primary, "ScalingVector", Missing["NotAvailable"]],
    "VariableScaling" -> Lookup[primary, "VariableScaling", Missing["NotAvailable"]],
    "VariablesAtWSL" -> Lookup[primary, "VariablesAtWSL", Missing["NotAvailable"]],
    "VariablesAtWHR" -> Lookup[primary, "VariablesAtWHR", Missing["NotAvailable"]],
    "HiddenRegionQ" -> Lookup[primary, "HiddenRegionQ", False],
    "Obstruction" -> Lookup[primary, "Obstruction", Missing["NotAvailable"]],
    "FSL" -> Lookup[primary, "FSL", Missing["NotAvailable"]],
    "ScalingStatus" -> Lookup[primary, "ScalingStatus", "--"],
    "HiddenRegionTrialRows" -> hrPos,
    "AllTrialScalingVectors" -> Lookup[#, "ScalingVector", Missing[]] & /@ ex["TrialRows"]
  |>
];

hrfEx02CaseFromBoundaryRow[bndRow_Association, channel_String] := Module[{scan, vars, zv, label, u},
  If[! AssociationQ[bndRow] || ! KeyExistsQ[bndRow, "ChannelScans"] ||
      ! KeyExistsQ[bndRow["ChannelScans"], channel],
    Return[Missing["NoScan", "Channel " <> channel <>
      " scan not stored. Re-run boundary study (hrfEx02Run*Boundary[]) with updated Ex02."]]
  ];
  scan = bndRow["ChannelScans"][channel];
  vars = Lookup[bndRow, "RemainingVars", {}];
  zv = Lookup[bndRow, "ZeroVars", {}];
  u = Lookup[bndRow, "URestricted", Automatic];
  label = Lookup[bndRow, "Diagram", "diagram"] <> " " <> Lookup[bndRow, "Region", "region"] <> " / " <> channel;
  hrfEx02ChannelCase[scan, vars, zv, label, u]
];

hrfEx02CaseFromCrownSanity[channel_String] := Module[{scan, data, vars, u},
  If[! ValueQ[Ex02CrownSanityScans] || ! AssociationQ[Ex02CrownSanityScans] ||
      ! KeyExistsQ[Ex02CrownSanityScans, channel],
    Return[Missing["NoScan", "Crown sanity for " <> channel <>
      " not run. Re-evaluate setup In[1] or hrfEx02RunCrownSanityCheck[]."]]
  ];
  scan = Ex02CrownSanityScans[channel];
  data = Ex02Diagrams["Crown"];
  vars = data["Vars"];
  u = data["UF"]["U"];
  hrfEx02ChannelCase[scan, vars, {}, "Crown interior Regge " <> channel, u]
];

hrfEx02ReggeChannelDisplay[diagram_String, regionLabel_String, channel_String] := Module[
  {bndRow, case, studyRow, cols, scalingTable, admTable, extract, ingredients, label},
  hrfEx02RequireLoad[];
  bndRow = FirstCase[Ex02BoundaryRows,
    r_ /; Lookup[r, "Diagram", ""] === diagram && Lookup[r, "Region", ""] === regionLabel,
    Missing["NoBoundaryRow", diagram, regionLabel]
  ];
  If[MatchQ[bndRow, _Missing],
    Return[<|"Error" -> "No boundary row for " <> diagram <> " / " <> regionLabel <>
      ". Run the matching hrfEx02Run*Boundary[] cell first."|>]
  ];
  case = hrfEx02CaseFromBoundaryRow[bndRow, channel];
  If[MatchQ[case, _Missing], Return[<|"Error" -> case|>]];
  studyRow = Lookup[bndRow, channel, <||>];
  label = Lookup[case, "Label", diagram <> " / " <> channel];
  cols = {"Region vector", "Hidden region identified?", "Generators", "Scaling status",
    "Scaling vector", "Variable scaling by region variable", "W_SL", "W_HR",
    "Variables at W_SL", "Variables at W_HR", "Comment"};
  scalingTable = If[hrfEx02EnsurePolynomialFactorReporting[],
    hrfPolyGeneratorSetScalingTable[case["PolynomialScan"], label <> " / all valid trials"],
    Dataset[{}]
  ];
  admTable = If[hrfEx02EnsurePolynomialFactorReporting[],
    hrfPolyAdmissibleGeneratorSetTable[case["PolynomialScan"], label <> " / admissible"],
    Dataset[{}]
  ];
  extract = hrfEx02CaseExtract[case];
  ingredients = hrfEx02CaseIngredients[case];
  If[TrueQ[$HRFExample02Report],
    Print["[Example 02] ", label, ": primary row uses coverage scaling (not first obstruction winner). ",
      "Assign report = hrfEx02ReggeChannelDisplay[...]; then report[\"Ingredients\"][\"ScalingVector\"], etc."]
  ];
  <|
    "Diagram" -> diagram,
    "Region" -> regionLabel,
    "Channel" -> channel,
    "Summary" -> Dataset[{KeyTake[studyRow, Intersection[cols, Keys[studyRow]]]}],
    "AllValidTrialsScaling" -> scalingTable,
    "AdmissibleGeneratorSets" -> admTable,
    "Extract" -> extract,
    "Ingredients" -> ingredients,
    "Case" -> case
  |>
];

hrfEx02CrownSanityChannelDisplay[channel_String:"T23"] := Module[
  {case, studyRow, cols, scalingTable, admTable, extract, ingredients, label},
  hrfEx02RequireLoad[];
  case = hrfEx02CaseFromCrownSanity[channel];
  If[MatchQ[case, _Missing], Return[<|"Error" -> case|>]];
  studyRow = Which[
    MatchQ[Ex02CrownSanityRow, _Dataset],
      FirstCase[Normal[Ex02CrownSanityRow], r_ /; Lookup[r, "Kinematic regime", ""] === channel, <||>],
    AssociationQ[Ex02CrownSanityRow] && Lookup[Ex02CrownSanityRow, "Kinematic regime", ""] === channel,
      Ex02CrownSanityRow,
    True, <||>
  ];
  label = "Crown interior Regge " <> channel;
  cols = {"Region vector", "Hidden region identified?", "Generators", "Scaling status",
    "Scaling vector", "Variable scaling by region variable", "W_SL", "W_HR",
    "Variables at W_SL", "Variables at W_HR", "Comment"};
  scalingTable = If[hrfEx02EnsurePolynomialFactorReporting[],
    hrfPolyGeneratorSetScalingTable[case["PolynomialScan"], label <> " / all valid trials"],
    Dataset[{}]
  ];
  admTable = If[hrfEx02EnsurePolynomialFactorReporting[],
    hrfPolyAdmissibleGeneratorSetTable[case["PolynomialScan"], label <> " / admissible"],
    Dataset[{}]
  ];
  extract = hrfEx02CaseExtract[case];
  ingredients = hrfEx02CaseIngredients[case];
  <|
    "Channel" -> channel,
    "Summary" -> Dataset[{KeyTake[studyRow, Intersection[cols, Keys[studyRow]]]}],
    "AllValidTrialsScaling" -> scalingTable,
    "AdmissibleGeneratorSets" -> admTable,
    "Extract" -> extract,
    "Ingredients" -> ingredients,
    "Case" -> case
  |>
];

hrfEx02HyperCrownBoundaryDisplay[channel_String:"Wide"] :=
  hrfEx02ReggeChannelDisplay["HyperCrown", "Boundary {x11}", channel];

Print["[loaded] Example 02 reporting. Try hrfEx02ReggeChannelDisplay[\"HyperCrown\", \"Boundary {x11}\", \"T23\"] after boundary runs."];
