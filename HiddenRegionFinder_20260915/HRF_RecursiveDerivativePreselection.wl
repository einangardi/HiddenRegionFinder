(* ::Package:: *)
(* HRF_RecursiveDerivativePreselection.wl

   Boundary-aware derivative preselection for the complete integral lists.

   This is deliberately looser than the strict interior derivative scan in
   HRF_InteriorDerivativePreselection.wl.  It applies the recursive pinch-style
   rule: if an active derivative has monomial coefficients of only one sign in
   the spacelike-collinear domain, the corresponding Feynman parameter must be
   zero on any candidate stratum.  Those variables are set to zero and the test
   is repeated on the restricted F_0.
*)

$HRFRecursiveDerivativePreselectionDirectory = Which[
  StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName],
    DirectoryName[$InputFileName],
  ValueQ[hrfPackageDirectory],
    hrfPackageDirectory[],
  True,
    Quiet @ Check[NotebookDirectory[], Directory[]]
];

If[! ValueQ[hrfInteriorGraphF0Data],
  Get[FileNameJoin[{$HRFRecursiveDerivativePreselectionDirectory, "HRF_InteriorDerivativePreselection.wl"}]]
];
If[! ValueQ[hrfPinchPreselectSingleInvariant],
  Get[FileNameJoin[{$HRFRecursiveDerivativePreselectionDirectory, "HRF_PinchPreselection.wl"}]]
];

ClearAll[
  hrfRecursiveExternalConventionQ, hrfRecursiveInputConventionSummary,
  hrfRecursiveIncidentHalfEdges, hrfRecursivePairings4,
  hrfRecursiveSplitFourPointVertex, hrfRecursiveSplitOneFourPointVertexGraphs,
  hrfRecursiveVertexValences, hrfRecursiveFourValentVertices,
  hrfRecursiveSplitTwoFourPointVertexGraphsDynamic,
  hrfRecursiveInternalNeighbours, hrfRecursiveExternalAttachmentVertex,
  hrfRecursiveSplitChannelFromPair, hrfRecursiveOpeningChannelForExternalLeg,
  hrfRecursiveTopologyNameForGraph, hrfRecursiveExample03ReferenceGraphs,
  hrfRecursiveExternalLabelledGraphKey, hrfRecursiveSwapExternalLabels,
  hrfRecursiveGeneric45GraphKey, hrfRecursiveAnnotateExample03Rows,
  hrfRecursiveMarkExample03PrimaryRows, hrfRecursiveCandidateSortKey,
  hrfRecursiveOrderedCandidateRows, hrfRecursiveCandidateTopologyKey,
  hrfRecursiveDeduplicateCandidateRows, hrfRecursiveDuplicateCandidateGroups,
  hrfRecursiveReferenceRows, hrfRecursiveReferenceMatchRows,
  hrfRecursiveDerivativeGraphScanRow, hrfRunRecursiveDerivativePreselection,
  hrfRecursiveDerivativeStatusRows, hrfRecursiveDerivativeSummaryString,
  hrfRecursiveWideDisplayRow, hrfRecursiveCSVTable,
  hrfRecursiveZeroVarIndex, hrfRecursiveContractionLabelRules,
  hrfRecursiveBoundaryEdgeData, hrfRecursiveBoundaryInternalLines,
  hrfRecursiveBoundaryExternalLines,
  hrfRecursiveDrawBoundaryGraph, hrfRecursiveDrawOriginalGraph,
  hrfRecursiveCandidateDrawingPanel,
  hrfRecursiveCandidateDrawingGrid, hrfRecursiveCandidateHandoffRows
];

hrfRecursiveExternalConventionQ[diagram_] :=
  diagram[[2]] === {{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}, {p5, 5}};

hrfRecursiveInputConventionSummary[diagramsByFamily_Association] := Association @ KeyValueMap[
  #1 -> Counts[hrfRecursiveExternalConventionQ /@ #2] &,
  diagramsByFamily
];

hrfRecursiveIncidentHalfEdges[internalLines_, externalLines_, v_] := Join[
  Table[If[MemberQ[internalLines[[i, 2]], v], {"Internal", i}, Nothing], {i, Length[internalLines]}],
  Table[If[externalLines[[i, 2]] === v, {"External", i}, Nothing], {i, Length[externalLines]}]
];

hrfRecursivePairings4[list_] := {
  {list[[{1, 2}]], list[[{3, 4}]]},
  {list[[{1, 3}]], list[[{2, 4}]]},
  {list[[{1, 4}]], list[[{2, 3}]]}
};

hrfRecursiveSplitFourPointVertex[internalLines_, externalLines_, v_, sideB_] := Module[
  {vertices, newV, newInternal, newExternal, h, edge, ends},
  vertices = DeleteDuplicates[Join[Flatten[internalLines[[All, 2]]], externalLines[[All, 2]]]];
  newV = Max[vertices] + 1;
  newInternal = internalLines;
  newExternal = externalLines;
  Do[
    h = sideB[[i]];
    If[h[[1]] === "Internal",
      edge = newInternal[[h[[2]]]];
      ends = edge[[2]];
      newInternal[[h[[2]]]] = {edge[[1]], ends /. v -> newV}
    ];
    If[h[[1]] === "External",
      newExternal[[h[[2]]]] = {newExternal[[h[[2]], 1]], newV}
    ],
    {i, Length[sideB]}
  ];
  <|
    "InternalLines" -> Append[newInternal, {"0", {v, newV}}],
    "ExternalLines" -> newExternal
  |>
];

hrfRecursiveSplitOneFourPointVertexGraphs[internalLines_, externalLines_, verticesToSplit_] := Flatten[
  Table[
    With[{inc = hrfRecursiveIncidentHalfEdges[internalLines, externalLines, v]},
      If[Length[inc] == 4,
        Table[
          hrfRecursiveSplitFourPointVertex[internalLines, externalLines, v, hrfRecursivePairings4[inc][[p, 2]]],
          {p, 3}
        ],
        {}
      ]
    ],
    {v, verticesToSplit}
  ],
  1
];

hrfRecursiveVertexValences[internalLines_, externalLines_] := Module[{verts, assoc, edge, v},
  verts = DeleteDuplicates[Join[Flatten[internalLines[[All, 2]]], externalLines[[All, 2]]]];
  assoc = AssociationThread[verts -> ConstantArray[0, Length[verts]]];
  Do[Do[assoc[v] = assoc[v] + 1, {v, edge[[2]]}], {edge, internalLines}];
  Do[assoc[edge[[2]]] = assoc[edge[[2]]] + 1, {edge, externalLines}];
  assoc
];

hrfRecursiveFourValentVertices[internalLines_, externalLines_] :=
  Keys @ Select[hrfRecursiveVertexValences[internalLines, externalLines], # == 4 &];

hrfRecursiveSplitTwoFourPointVertexGraphsDynamic[internalLines_, externalLines_] := Module[
  {graphs = {}, firstSplits, g, remainingFourVerts, secondSplits},
  firstSplits = hrfRecursiveSplitOneFourPointVertexGraphs[
    internalLines, externalLines, hrfRecursiveFourValentVertices[internalLines, externalLines]
  ];
  Do[
    g = firstSplits[[i]];
    remainingFourVerts = hrfRecursiveFourValentVertices[g["InternalLines"], g["ExternalLines"]];
    Do[
      secondSplits = hrfRecursiveSplitOneFourPointVertexGraphs[
        g["InternalLines"], g["ExternalLines"], {remainingFourVerts[[j]]}
      ];
      graphs = Join[graphs, secondSplits],
      {j, Length[remainingFourVerts]}
    ],
    {i, Length[firstSplits]}
  ];
  graphs[[1 ;; ;; 2]]
];

hrfRecursiveInternalNeighbours[internalLines_, v_] := DeleteDuplicates @ Cases[
  internalLines,
  {_, ends_} /; MemberQ[ends, v] :> First[DeleteCases[ends, v]]
];

hrfRecursiveExternalAttachmentVertex[externalLines_, p_] := First[
  Cases[externalLines, {p, v_} :> v],
  Missing["ExternalLegNotFound", p]
];

hrfRecursiveSplitChannelFromPair[pair_] := Switch[Sort[pair],
  {1, 2}, "s",
  {1, 4}, "t",
  {2, 4}, "u",
  _, Missing["UnknownOpeningPair", pair]
];

hrfRecursiveOpeningChannelForExternalLeg[internalLines_, externalLines_, p_] := Module[
  {extV, splitPartnerCandidates, pair},
  extV = hrfRecursiveExternalAttachmentVertex[externalLines, p];
  If[MatchQ[extV, _Missing], Return[extV]];
  splitPartnerCandidates = Select[
    hrfRecursiveInternalNeighbours[internalLines, extV],
    ! MemberQ[{1, 2, 4}, #] &
  ];
  If[splitPartnerCandidates === {}, Return["bullet"]];
  pair = Sort @ Intersection[
    hrfRecursiveInternalNeighbours[internalLines, First[splitPartnerCandidates]],
    {1, 2, 4}
  ];
  If[Length[pair] == 2,
    hrfRecursiveSplitChannelFromPair[pair],
    Missing["CannotClassifyOpening", pair]
  ]
];

hrfRecursiveTopologyNameForGraph[internalLines_, externalLines_] :=
  "G_" <> StringJoin[
    ToString /@ {
      hrfRecursiveOpeningChannelForExternalLeg[internalLines, externalLines, p3],
      hrfRecursiveOpeningChannelForExternalLeg[internalLines, externalLines, p5]
    }
  ];

hrfRecursiveExample03ReferenceGraphs[] := hrfRecursiveExample03ReferenceGraphs[] = Module[
  {seven, eight, rows},
  seven = hrfRecursiveSplitOneFourPointVertexGraphs[seedInternalLines, seedExternalLines, {3, 5}];
  eight = hrfRecursiveSplitTwoFourPointVertexGraphsDynamic[seedInternalLines, seedExternalLines];
  rows = Join[
    {<|
      "Example03Group" -> "03 seed",
      "Example03Order" -> 1,
      "Example03GraphIndex" -> 0,
      "Example03Topology" -> "G_bulletbullet",
      "InternalLines" -> seedInternalLines,
      "ExternalLines" -> seedExternalLines
    |>
    },
    Table[
      <|
        "Example03Group" -> "03 seven",
        "Example03Order" -> 1 + i,
        "Example03GraphIndex" -> i,
        "Example03Topology" -> hrfRecursiveTopologyNameForGraph[seven[[i, "InternalLines"]], seven[[i, "ExternalLines"]]],
        "InternalLines" -> seven[[i, "InternalLines"]],
        "ExternalLines" -> seven[[i, "ExternalLines"]]
      |>,
      {i, Length[seven]}
    ],
    Table[
      <|
        "Example03Group" -> "03 eight",
        "Example03Order" -> 1 + Length[seven] + i,
        "Example03GraphIndex" -> i,
        "Example03Topology" -> hrfRecursiveTopologyNameForGraph[eight[[i, "InternalLines"]], eight[[i, "ExternalLines"]]],
        "InternalLines" -> eight[[i, "InternalLines"]],
        "ExternalLines" -> eight[[i, "ExternalLines"]]
      |>,
      {i, Length[eight]}
    ]
  ];
  Append[#, "Example03Key" -> hrfRecursiveExternalLabelledGraphKey[#["InternalLines"], #["ExternalLines"]]] & /@ rows
];

hrfRecursiveExternalLabelledGraphKey[internalLines_, externalLines_] := Module[
  {vertices, extByVertex, movable, fixedToken, tokens, keys},
  vertices = DeleteDuplicates[Join[Flatten[internalLines[[All, 2]]], externalLines[[All, 2]]]];
  extByVertex[v_] := Sort @ Cases[externalLines, {p_Symbol, vv_} /; vv === v :> SymbolName[p]];
  movable = Select[vertices, extByVertex[#] === {} &];
  fixedToken[v_] := "E:" <> StringRiffle[extByVertex[v], ","];
  keys = Table[
    tokens = Association@Join[
      Table[v -> fixedToken[v], {v, Complement[vertices, movable]}],
      Table[movable[[i]] -> ("I" <> ToString[perm[[i]]]), {i, Length[movable]}]
    ];
    {
      Sort[Sort /@ (internalLines[[All, 2]] /. Normal[tokens])],
      Sort[Table[
        SymbolName[externalLines[[i, 1]]] -> (externalLines[[i, 2]] /. Normal[tokens]),
        {i, Length[externalLines]}
      ]]
    },
    {perm, Permutations[Range[Length[movable]]]}
  ];
  First[Sort[keys]]
];

hrfRecursiveSwapExternalLabels[externalLines_, swaps_List] :=
  externalLines /. {p_, v_} :> {Replace[p, swaps], v};

hrfRecursiveGeneric45GraphKey[internalLines_, externalLines_] := First @ Sort[
  {
    hrfRecursiveExternalLabelledGraphKey[internalLines, externalLines],
    hrfRecursiveExternalLabelledGraphKey[
      internalLines,
      hrfRecursiveSwapExternalLabels[externalLines, {p4 -> p5, p5 -> p4}]
    ]
  }
];

hrfRecursiveAnnotateExample03Rows[rows_List] := Module[
  {refs, byKey, key, hit},
  refs = hrfRecursiveExample03ReferenceGraphs[];
  byKey = GroupBy[refs, #["Example03Key"] &];
  Table[
    key = hrfRecursiveExternalLabelledGraphKey[rows[[i, "InternalLines"]], rows[[i, "ExternalLines"]]];
    hit = Lookup[byKey, Key[key], {}];
    If[hit === {},
      Join[rows[[i]], <|
        "Example03Group" -> "other",
        "Example03Topology" -> "",
        "Example03GraphIndex" -> "",
        "Example03Order" -> Infinity
      |>],
      Join[rows[[i]], KeyTake[First[hit], {
        "Example03Group", "Example03Topology", "Example03GraphIndex", "Example03Order"
      }]]
    ],
    {i, Length[rows]}
  ]
];

hrfRecursiveMarkExample03PrimaryRows[rows_List] := Module[
  {refRows, primaryPositions},
  refRows = Select[Range[Length[rows]], Lookup[rows[[#]], "Example03Group", "other"] =!= "other" &];
  primaryPositions = Values @ GroupBy[
    refRows,
    Lookup[rows[[#]], "Example03Order", Infinity] &,
    Function[group,
      First @ SortBy[
        group,
        Function[pos, {
          If[TrueQ[rows[[pos, "CandidateQ"]]], 0, 1],
          If[Lookup[rows[[pos]], "Family", ""] === "nonplanar", 0, 1],
          Lookup[rows[[pos]], "DiagramIndex", Infinity]
        }]
      ]
    ]
  ];
  Table[
    Append[
      rows[[i]],
      "Example03PrimaryQ" -> MemberQ[primaryPositions, i]
    ],
    {i, Length[rows]}
  ]
];

hrfRecursiveCandidateSortKey[row_Association] := Module[
  {group = Lookup[row, "Example03Group", "other"], fam = Lookup[row, "Family", ""], order},
  order = If[TrueQ[Lookup[row, "Example03PrimaryQ", False]],
    Switch[group,
      "03 seed", 0,
      "03 seven", 1,
      "03 eight", 2,
      _, If[fam === "planar", 3, 4]
    ],
    If[fam === "planar", 3, 4]
  ];
  {
    order,
    Lookup[row, "Example03Order", Infinity],
    If[fam === "planar", 0, 1],
    Lookup[row, "PropagatorCount", Infinity],
    Lookup[row, "DiagramIndex", Infinity]
  }
];

hrfRecursiveOrderedCandidateRows[rows_List] := SortBy[rows, hrfRecursiveCandidateSortKey];

hrfRecursiveCandidateTopologyKey[row_Association] :=
  hrfRecursiveGeneric45GraphKey[row["InternalLines"], row["ExternalLines"]];

hrfRecursiveDeduplicateCandidateRows[rows_List] := Module[
  {ordered},
  ordered = hrfRecursiveOrderedCandidateRows[rows];
  First /@ GatherBy[ordered, hrfRecursiveCandidateTopologyKey]
];

hrfRecursiveDuplicateCandidateGroups[rows_List] := Select[
  GatherBy[hrfRecursiveOrderedCandidateRows[rows], hrfRecursiveCandidateTopologyKey],
  Length[#] > 1 &
];

hrfRecursiveReferenceRows[rows_List] := SortBy[
  Select[rows, TrueQ[Lookup[#, "Example03PrimaryQ", False]] &],
  Lookup[#, "Example03Order", Infinity] &
];

hrfRecursiveReferenceMatchRows[rows_List] := SortBy[
  Select[rows, Lookup[#, "Example03Group", "other"] =!= "other" &],
  {Lookup[#, "Example03Order", Infinity] &, Lookup[#, "DiagramIndex", Infinity] &}
];

Options[hrfRecursiveDerivativeGraphScanRow] = {"Assumptions" -> Automatic};
hrfRecursiveDerivativeGraphScanRow[diagram_, family_String, index_Integer, OptionsPattern[]] := Module[
  {internalLines, externalLines, data, vars, scan, candidateQ, ambiguousQ},
  internalLines = diagram[[1]];
  externalLines = diagram[[2]];
  data = hrfInteriorGraphF0Data[internalLines, externalLines];
  vars = data["Variables"];
  scan = hrfPinchPreselectSingleInvariant[
    data["F0"],
    vars,
    "Assumptions" -> Replace[OptionValue["Assumptions"], Automatic :> KinAssump]
  ];
  candidateQ = TrueQ[scan["PotentialPinchQ"] === True];
  ambiguousQ = MatchQ[scan["PotentialPinchQ"], _Missing];
  <|
    "Family" -> family,
    "DiagramIndex" -> index,
    "PropagatorCount" -> Length[internalLines],
    "VariableCount" -> Length[vars],
    "CandidateQ" -> candidateQ,
    "AmbiguousQ" -> ambiguousQ,
    "ZeroVars" -> Lookup[scan, "ZeroVars", {}],
    "RemainingVars" -> Lookup[scan, "RemainingVars", {}],
    "ActiveRemainingVars" -> Lookup[scan, "ActiveRemainingVars", {}],
    "EffectivePropagatorCount" -> Length[internalLines] - Length[Lookup[scan, "ZeroVars", {}]],
    "ExitReason" -> Lookup[scan, "ExitReason", ""],
    "F0TermCount" -> Length[CoefficientRules[Expand[data["F0"]], vars]],
    "Variables" -> vars,
    "PinchScan" -> scan,
    "InternalLines" -> internalLines,
    "ExternalLines" -> externalLines
  |>
];

Options[hrfRunRecursiveDerivativePreselection] = {
  "DiagramFiles" -> Automatic,
  "MaxGraphs" -> All,
  "Assumptions" -> Automatic
};
hrfRunRecursiveDerivativePreselection[OptionsPattern[]] := Module[
  {files, diagramsByFamily, conventionSummary, max, rows, rawCandidates,
   candidates, duplicateCandidateGroups, referenceRows, referenceMatchRows},
  files = Replace[OptionValue["DiagramFiles"], Automatic :> hrfInteriorDiagramFiles[]];
  diagramsByFamily = Association @ KeyValueMap[
    #1 -> hrfInteriorImportDiagramList[#2] &,
    files
  ];
  conventionSummary = hrfRecursiveInputConventionSummary[diagramsByFamily];
  max = OptionValue["MaxGraphs"];
  rows = Flatten[
    KeyValueMap[
      Function[{family, diagrams},
        Table[
          hrfRecursiveDerivativeGraphScanRow[
            diagrams[[i]], family, i,
            "Assumptions" -> OptionValue["Assumptions"]
          ],
          {i, If[IntegerQ[max], Min[max, Length[diagrams]], Length[diagrams]]}
        ]
      ],
      diagramsByFamily
    ],
    1
  ];
  rows = hrfRecursiveMarkExample03PrimaryRows[hrfRecursiveAnnotateExample03Rows[rows]];
  rawCandidates = hrfRecursiveOrderedCandidateRows[Select[rows, TrueQ[#["CandidateQ"]] &]];
  duplicateCandidateGroups = hrfRecursiveDuplicateCandidateGroups[rawCandidates];
  candidates = hrfRecursiveDeduplicateCandidateRows[rawCandidates];
  referenceRows = hrfRecursiveReferenceRows[rows];
  referenceMatchRows = hrfRecursiveReferenceMatchRows[rows];
  <|
    "Summary" -> <|
      "TotalGraphs" -> Length[rows],
      "ExternalConventionCounts" -> conventionSummary,
      "GraphsByFamily" -> Counts[Lookup[rows, "Family", {}]],
      "GraphsByPropagatorCount" -> Counts[Lookup[rows, "PropagatorCount", {}]],
      "RawCandidateCount" -> Length[rawCandidates],
      "CandidateCount" -> Length[candidates],
      "DuplicateGenericP4P5OrInternalNameCandidatesRemoved" -> Length[rawCandidates] - Length[candidates],
      "DuplicateGenericP4P5OrInternalNameGroups" -> Length[duplicateCandidateGroups],
      "CandidatesByFamily" -> Counts[Lookup[candidates, "Family", {}]],
      "CandidatesByPropagatorCount" -> Counts[Lookup[candidates, "PropagatorCount", {}]],
      "CandidatesByEffectivePropagatorCount" -> Counts[Lookup[candidates, "EffectivePropagatorCount", {}]],
      "CandidatesByCodimension" -> Counts[Length /@ Lookup[candidates, "ZeroVars", {}]],
      "Example03PrimaryReferenceRowsFound" -> Length[referenceRows],
      "Example03ReferenceMatchRowsFound" -> Length[referenceMatchRows],
      "Example03ReferenceCandidates" -> Count[referenceRows, r_ /; TrueQ[r["CandidateQ"]]],
      "ExcludedCount" -> Count[rows, r_ /; ! TrueQ[r["CandidateQ"]] && ! TrueQ[r["AmbiguousQ"]]],
      "AmbiguousCount" -> Count[rows, r_ /; TrueQ[r["AmbiguousQ"]]]
    |>,
    "Rows" -> rows,
    "Dataset" -> Dataset[hrfRecursiveWideDisplayRow /@ rows],
    "RawCandidateRows" -> rawCandidates,
    "RawCandidateDataset" -> Dataset[hrfRecursiveWideDisplayRow /@ rawCandidates],
    "DuplicateCandidateGroups" -> duplicateCandidateGroups,
    "CandidateRows" -> candidates,
    "CandidateDataset" -> Dataset[hrfRecursiveWideDisplayRow /@ candidates],
    "ReferenceRows" -> referenceRows,
    "ReferenceDataset" -> Dataset[hrfRecursiveWideDisplayRow /@ referenceRows],
    "ReferenceMatchRows" -> referenceMatchRows,
    "ReferenceMatchDataset" -> Dataset[hrfRecursiveWideDisplayRow /@ referenceMatchRows],
    "CandidateHandoffRows" -> hrfRecursiveCandidateHandoffRows[candidates]
  |>
];

hrfRecursiveDerivativeSummaryString[dr_Association] := Module[
  {labels, counts},
  labels = Lookup[Lookup[dr, "SignRows", {}], "SignLabel", {}];
  counts = Counts[labels];
  "+" <> ToString[Lookup[counts, "positive", 0]] <>
    " / -" <> ToString[Lookup[counts, "negative", 0]] <>
    If[Lookup[counts, "zero", 0] > 0, " / 0:" <> ToString[Lookup[counts, "zero", 0]], ""] <>
    If[Lookup[counts, "ambiguous", 0] > 0, " / ?:" <> ToString[Lookup[counts, "ambiguous", 0]], ""]
];

hrfRecursiveDerivativeStatusRows[row_Association] := Module[
  {scan, iterations, zeroVars, vars, final, finalRows, derivativeDataFor, rowForVar},
  scan = Lookup[row, "PinchScan", <||>];
  If[! AssociationQ[scan] || ! KeyExistsQ[scan, "Iterations"], Return[{}]];
  iterations = scan["Iterations"];
  zeroVars = Lookup[scan, "ZeroVars", {}];
  vars = Lookup[row, "Variables", DeleteDuplicates@Join[zeroVars, Lookup[Last[iterations], "ActiveVars", {}]]];
  final = Last[iterations];
  finalRows = Lookup[final, "DerivativeRows", {}];
  derivativeDataFor[v_] := Module[{hit},
    hit = FirstCase[
      iterations,
      it_ /; MemberQ[Lookup[it, "OneSidedDerivativeVars", {}], v] :>
        <|"Iteration" -> it["Iteration"],
          "DerivativeRow" -> FirstCase[Lookup[it, "DerivativeRows", {}], d_ /; d["Variable"] === v, <||>]|>,
      Missing["NotSetToZero"]
    ];
    If[! MatchQ[hit, _Missing], Return[hit]];
    <|"Iteration" -> Lookup[final, "Iteration", Missing["NoIteration"]],
      "DerivativeRow" -> FirstCase[finalRows, d_ /; d["Variable"] === v, <||>]|>
  ];
  rowForVar[v_] := Module[{data, dr, dp, dm, status},
    data = derivativeDataFor[v];
    dr = Lookup[data, "DerivativeRow", <||>];
    dp = If[AssociationQ[dr], Lookup[dr, "DPositive", 0], 0];
    dm = If[AssociationQ[dr], Lookup[dr, "DNegative", 0], 0];
    status = Which[
      MemberQ[zeroVars, v], "set to zero",
      MemberQ[Lookup[final, "ActiveVars", {}], v], "active final derivative",
      True, "inactive"
    ];
    <|
      "Variable" -> v,
      "Status" -> status,
      "Iteration" -> Lookup[data, "Iteration", Missing["NoIteration"]],
      "SignSummary" -> If[AssociationQ[dr], hrfRecursiveDerivativeSummaryString[dr], ""],
      "DPositive" -> dp,
      "DNegative" -> dm,
      "DTotal" -> If[AssociationQ[dr], Lookup[dr, "DTotal", Expand[dp + dm]], Expand[dp + dm]]
    |>
  ];
  rowForVar /@ vars
];

hrfRecursiveWideDisplayRow[row_Association] := Join[
  <|
    "Family" -> row["Family"],
    "DiagramIndex" -> row["DiagramIndex"],
    "Example03Group" -> Lookup[row, "Example03Group", "other"],
    "Example03Topology" -> Lookup[row, "Example03Topology", ""],
    "Example03GraphIndex" -> Lookup[row, "Example03GraphIndex", ""],
    "Example03PrimaryQ" -> Lookup[row, "Example03PrimaryQ", False],
    "PropagatorCount" -> row["PropagatorCount"],
    "CandidateQ" -> row["CandidateQ"],
    "PreselectionZeroVars" -> row["ZeroVars"],
    "PreselectionEffectivePropagatorCount" -> row["EffectivePropagatorCount"],
    "ExitReason" -> row["ExitReason"],
    "F0TermCount" -> row["F0TermCount"]
  |>,
  Association[
    ("d_" <> SymbolName[#["Variable"]]) -> (#["Status"] <> ": " <> #["SignSummary"]) & /@
      hrfRecursiveDerivativeStatusRows[row]
  ]
];

hrfRecursiveCSVTable[rows_List] := hrfInteriorCSVTable[rows];

hrfRecursiveZeroVarIndex[x_Symbol] := ToExpression[StringDrop[SymbolName[x], 1]] + 1;

hrfRecursiveContractionLabelRules[internalLines_, externalLines_, zeroPositions_List] := Module[
  {verts, zeroEdges, comps, internalCount = 0, extLabels, label},
  verts = Sort @ DeleteDuplicates @ Join[Flatten[internalLines[[All, 2]]], externalLines[[All, 2]]];
  zeroEdges = If[zeroPositions === {}, {}, UndirectedEdge @@@ (internalLines[[zeroPositions, 2]])];
  comps = SortBy[Sort /@ ConnectedComponents[Graph[verts, zeroEdges]], Min];
  extLabels[comp_] := Sort @ Cases[externalLines, {p_, v_} /; MemberQ[comp, v] :> SymbolName[p]];
  label[comp_] := Module[{ext = extLabels[comp]},
    Which[
      Length[ext] == 1, ToExpression[StringDrop[First[ext], 1]],
      Length[ext] > 1, StringRiffle[StringDrop[#, 1] & /@ ext, "/"],
      True,
        internalCount++;
        5 + internalCount
    ]
  ];
  Flatten[Table[Thread[comps[[i]] -> label[comps[[i]]]], {i, Length[comps]}]]
];

hrfRecursiveBoundaryEdgeData[row_Association] := Module[
  {zeroPositions, activePositions, rules},
  zeroPositions = hrfRecursiveZeroVarIndex /@ Lookup[row, "ZeroVars", {}];
  activePositions = Complement[Range[Length[row["InternalLines"]]], zeroPositions];
  rules = hrfRecursiveContractionLabelRules[row["InternalLines"], row["ExternalLines"], zeroPositions];
  Table[
    <|
      "OriginalPosition" -> activePositions[[i]],
      "Variable" -> ToExpression["x" <> ToString[activePositions[[i]] - 1]],
      "Line" -> row["InternalLines"][[activePositions[[i]]]] /. rules
    |>,
    {i, Length[activePositions]}
  ]
];

hrfRecursiveBoundaryInternalLines[row_Association] := Module[
  {edgeData},
  edgeData = hrfRecursiveBoundaryEdgeData[row];
  Lookup[edgeData, "Line", {}]
];

hrfRecursiveBoundaryExternalLines[row_Association] := Module[
  {zeroPositions, rules},
  zeroPositions = hrfRecursiveZeroVarIndex /@ Lookup[row, "ZeroVars", {}];
  rules = hrfRecursiveContractionLabelRules[row["InternalLines"], row["ExternalLines"], zeroPositions];
  row["ExternalLines"] /. rules
];

hrfRecursiveDrawBoundaryGraph[row_Association, imageSize_ : Medium] := Module[
  {edgeData, internalLines, externalLines, internalEdges, externalVertices,
   externalEdges, internalLabels, externalLabels},
  edgeData = hrfRecursiveBoundaryEdgeData[row];
  internalLines = Lookup[edgeData, "Line", {}];
  externalLines = hrfRecursiveBoundaryExternalLines[row];
  internalEdges = Table[UndirectedEdge @@ internalLines[[i, 2]], {i, Length[internalLines]}];
  externalVertices = Table["ext" <> ToString[i], {i, Length[externalLines]}];
  externalEdges = Table[UndirectedEdge[externalLines[[i, 2]], externalVertices[[i]]], {i, Length[externalLines]}];
  internalLabels = Table[
    internalEdges[[i]] -> SymbolName[edgeData[[i, "Variable"]]],
    {i, Length[internalEdges]}
  ];
  externalLabels = Table[externalEdges[[i]] -> ToString[externalLines[[i, 1]]], {i, Length[externalLines]}];
  Graph[
    Join[internalEdges, externalEdges],
    EdgeLabels -> Join[internalLabels, externalLabels],
    VertexLabels -> "Name",
    GraphLayout -> "SpringEmbedding",
    ImageSize -> imageSize
  ]
];

hrfRecursiveDrawOriginalGraph[row_Association, imageSize_ : Medium] := Module[
  {internalLines, externalLines, internalEdges, externalVertices,
   externalEdges, internalLabels, externalLabels},
  internalLines = row["InternalLines"];
  externalLines = row["ExternalLines"];
  internalEdges = Table[UndirectedEdge @@ internalLines[[i, 2]], {i, Length[internalLines]}];
  externalVertices = Table["ext" <> ToString[i], {i, Length[externalLines]}];
  externalEdges = Table[UndirectedEdge[externalLines[[i, 2]], externalVertices[[i]]], {i, Length[externalLines]}];
  internalLabels = Table[
    internalEdges[[i]] -> ("x" <> ToString[i - 1]),
    {i, Length[internalEdges]}
  ];
  externalLabels = Table[externalEdges[[i]] -> ToString[externalLines[[i, 1]]], {i, Length[externalLines]}];
  Graph[
    Join[internalEdges, externalEdges],
    EdgeLabels -> Join[internalLabels, externalLabels],
    VertexLabels -> "Name",
    GraphLayout -> "SpringEmbedding",
    ImageSize -> imageSize
  ]
];

hrfRecursiveCandidateDrawingPanel[row_Association] := Column[
  {
    Style[
      row["Family"] <> " index " <> ToString[row["DiagramIndex"]] <>
        " props " <> ToString[row["PropagatorCount"]] <>
        " preselection zero " <> ToString[InputForm[row["ZeroVars"]]],
      Bold
    ],
    hrfRecursiveDrawOriginalGraph[row]
  },
  Spacings -> 0.5
];

hrfRecursiveCandidateDrawingGrid[rows_List, ncols_Integer : 2] := Grid[
  Partition[hrfRecursiveCandidateDrawingPanel /@ rows, UpTo[ncols]],
  Alignment -> Top,
  Spacings -> {2, 2}
];

hrfRecursiveCandidateHandoffRows[rows_List] := (
  <|
    "Family" -> #["Family"],
    "DiagramIndex" -> #["DiagramIndex"],
    "Example03Group" -> Lookup[#, "Example03Group", "other"],
    "Example03Topology" -> Lookup[#, "Example03Topology", ""],
    "Example03GraphIndex" -> Lookup[#, "Example03GraphIndex", ""],
    "Example03PrimaryQ" -> Lookup[#, "Example03PrimaryQ", False],
    "PropagatorCount" -> #["PropagatorCount"],
    "PreselectionZeroVars" -> #["ZeroVars"],
    "PreselectionEffectivePropagatorCount" -> #["EffectivePropagatorCount"],
    "InternalLines" -> #["InternalLines"],
    "ExternalLines" -> #["ExternalLines"],
    "PySecDecInput" -> hrfInteriorPySecDecInputString[#["InternalLines"], #["ExternalLines"]]
  |> & /@ rows
);

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] recursive derivative preselection. Evaluate hrfRunRecursiveDerivativePreselection[]."]
];
