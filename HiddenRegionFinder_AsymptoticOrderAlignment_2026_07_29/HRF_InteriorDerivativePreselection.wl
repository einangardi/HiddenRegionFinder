(* ::Package:: *)
(* HRF_InteriorDerivativePreselection.wl

   Interior-only preselection for a complete list of required integrals.

   This does not search boundary strata or subtopologies.  For each listed
   graph it computes F_0, the leading-delta limit of the second Symanzik
   polynomial in the Example 03 spacelike-collinear kinematics, and checks
   whether every derivative dF_0/dx_i has both positive and negative
   Feynman-parameter monomials in the domain

      x_i > 0,  -1 < x < 0,  z > 1,  s > 0.

   Load and run:
     Get["HRF_InteriorDerivativePreselection.wl"];
     res = hrfRunInteriorDerivativePreselection[];
     res["Summary"]
*)

$HRFInteriorDerivativePreselectionDirectory = Which[
  StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName],
    DirectoryName[$InputFileName],
  ValueQ[hrfPackageDirectory],
    hrfPackageDirectory[],
  True,
    Quiet @ Check[NotebookDirectory[], Directory[]]
];

If[! ValueQ[SymanzikUF],
  Get[FileNameJoin[{$HRFInteriorDerivativePreselectionDirectory, "HiddenRegionFinder.wl"}]]
];
If[! ValueQ[hrfEx03LeadingDeltaPolynomial],
  Get[FileNameJoin[{$HRFInteriorDerivativePreselectionDirectory, "HRF_Example03CollinearCore.wl"}]]
];

ClearAll[
  hrfInteriorDiagramFiles, hrfInteriorImportDiagramList,
  hrfInteriorSignLabel, hrfInteriorCoefficientSign,
  hrfInteriorMonomialSignRows, hrfInteriorMixedSignQ,
  hrfInteriorGraphF0Data, hrfInteriorDerivativeRows,
  hrfInteriorGraphScanRow, hrfRunInteriorDerivativePreselection,
  hrfInteriorDisplayRow, hrfInteriorCSVTable,
  hrfInteriorDerivativeSignSummaryString,
  hrfInteriorDerivativeSummaryAssociation,
  hrfInteriorWideDisplayRow,
  hrfInteriorDerivativeSignDisplayRows,
  hrfInteriorCandidateDerivativeSignRows,
  hrfInteriorDrawGraph, hrfInteriorCandidateDrawingPanel,
  hrfInteriorCandidateDrawingGrid,
  hrfInteriorPythonString, hrfInteriorPythonListString,
  hrfInteriorPySecDecInputString, hrfInteriorCandidateHandoffRows
];

hrfInteriorDiagramFiles[] := <|
  "planar" -> FileNameJoin[{$HRFInteriorDerivativePreselectionDirectory, "planarDiagram.txt"}],
  "nonplanar" -> FileNameJoin[{$HRFInteriorDerivativePreselectionDirectory, "nonplanarDiagram.txt"}]
|>;

hrfInteriorImportDiagramList[path_String] :=
  ToExpression[Import[path, "Text"], InputForm];

hrfInteriorSignLabel[1] := "positive";
hrfInteriorSignLabel[-1] := "negative";
hrfInteriorSignLabel[0] := "zero";
hrfInteriorSignLabel[_] := "undetermined";

Options[hrfInteriorCoefficientSign] = {"Assumptions" -> Automatic};
hrfInteriorCoefficientSign[coeff_, OptionsPattern[]] := Module[
  {ass, factored, sgn},
  ass = Replace[OptionValue["Assumptions"], Automatic :> KinAssump];
  factored = FullSimplify[Factor[coeff], ass];
  sgn = Quiet @ Check[Sign[factored], Indeterminate];
  Which[
    TrueQ[sgn > 0], 1,
    TrueQ[sgn < 0], -1,
    TrueQ[sgn === 0], 0,
    TrueQ[FullSimplify[factored > 0, ass]], 1,
    TrueQ[FullSimplify[factored < 0, ass]], -1,
    TrueQ[FullSimplify[factored == 0, ass]], 0,
    True, Indeterminate
  ]
];

Options[hrfInteriorMonomialSignRows] = {"Assumptions" -> Automatic};
hrfInteriorMonomialSignRows[poly_, vars_List, OptionsPattern[]] := Module[
  {ass, rules, monomialFor, coeff, factored, sign},
  ass = Replace[OptionValue["Assumptions"], Automatic :> KinAssump];
  rules = CoefficientRules[Expand[poly], vars];
  monomialFor[powers_List] := Times @@ MapThread[Power, {vars, powers}];
  Table[
    coeff = rules[[i, 2]];
    factored = FullSimplify[Factor[coeff], ass];
    sign = hrfInteriorCoefficientSign[factored, "Assumptions" -> ass];
    <|
      "Exponents" -> rules[[i, 1]],
      "Monomial" -> monomialFor[rules[[i, 1]]],
      "Coefficient" -> coeff,
      "FactoredCoefficient" -> factored,
      "Sign" -> sign,
      "SignLabel" -> hrfInteriorSignLabel[sign],
      "Term" -> Expand[coeff monomialFor[rules[[i, 1]]]]
    |>,
    {i, Length[rules]}
  ]
];

hrfInteriorMixedSignQ[signRows_List] := Module[{labels},
  labels = Lookup[signRows, "SignLabel", {}];
  MemberQ[labels, "positive"] && MemberQ[labels, "negative"]
];

hrfInteriorGraphF0Data[internalLines_, externalLines_] := Module[
  {uf, vars, F, Fcol, F0},
  uf = SymanzikUF[internalLines, externalLines];
  vars = uf["Variables"];
  F = toCyclicMandelstams[uf["F"]];
  Fcol = Expand[F /. collPar1];
  F0 = hrfEx03LeadingDeltaPolynomial[Fcol];
  <|
    "U" -> uf["U"],
    "F" -> F,
    "FCollinear" -> Fcol,
    "F0" -> F0,
    "Variables" -> vars
  |>
];

Options[hrfInteriorDerivativeRows] = {"Assumptions" -> Automatic};
hrfInteriorDerivativeRows[F0_, vars_List, OptionsPattern[]] := Module[
  {ass},
  ass = Replace[OptionValue["Assumptions"], Automatic :> KinAssump];
  Table[
    Module[{derivative, signRows, labels, counts, mixedQ, problemQ},
      derivative = Expand[D[F0, vars[[i]]]];
      signRows = hrfInteriorMonomialSignRows[derivative, vars, "Assumptions" -> ass];
      labels = Lookup[signRows, "SignLabel", {}];
      counts = Counts[labels];
      mixedQ = hrfInteriorMixedSignQ[signRows];
      problemQ = MemberQ[labels, "undetermined"];
      <|
        "Variable" -> vars[[i]],
        "Derivative" -> derivative,
        "MixedSignQ" -> mixedQ,
        "SignCheckProblemQ" -> problemQ,
        "SignCounts" -> counts,
        "PositiveTermCount" -> Lookup[counts, "positive", 0],
        "NegativeTermCount" -> Lookup[counts, "negative", 0],
        "ZeroTermCount" -> Lookup[counts, "zero", 0],
        "UndeterminedTermCount" -> Lookup[counts, "undetermined", 0],
        "SignRows" -> signRows
      |>
    ],
    {i, Length[vars]}
  ]
];

Options[hrfInteriorGraphScanRow] = {
  "Assumptions" -> Automatic,
  "StorePolynomials" -> False
};
hrfInteriorGraphScanRow[diagram_, family_String, index_Integer, OptionsPattern[]] := Module[
  {internalLines, externalLines, data, vars, derivativeRows, candidateQ,
   problemQ, failedVars, row},
  internalLines = diagram[[1]];
  externalLines = diagram[[2]];
  data = hrfInteriorGraphF0Data[internalLines, externalLines];
  vars = data["Variables"];
  derivativeRows = hrfInteriorDerivativeRows[
    data["F0"],
    vars,
    "Assumptions" -> OptionValue["Assumptions"]
  ];
  problemQ = AnyTrue[derivativeRows, TrueQ[#["SignCheckProblemQ"]] &];
  candidateQ = AllTrue[
    derivativeRows,
    TrueQ[#["MixedSignQ"]] && ! TrueQ[#["SignCheckProblemQ"]] &
  ];
  failedVars = Lookup[Select[derivativeRows, ! TrueQ[#["MixedSignQ"]] &], "Variable", {}];
  row = <|
    "Family" -> family,
    "DiagramIndex" -> index,
    "PropagatorCount" -> Length[internalLines],
    "VariableCount" -> Length[vars],
    "CandidateQ" -> candidateQ,
    "SignCheckProblemQ" -> problemQ,
    "FailedVariables" -> failedVars,
    "Variables" -> vars,
    "F0TermCount" -> Length[CoefficientRules[Expand[data["F0"]], vars]],
    "DerivativeRows" -> derivativeRows,
    "InternalLines" -> internalLines,
    "ExternalLines" -> externalLines
  |>;
  If[TrueQ[OptionValue["StorePolynomials"]],
    Join[row, KeyTake[data, {"U", "F", "FCollinear", "F0"}]],
    row
  ]
];

Options[hrfRunInteriorDerivativePreselection] = {
  "DiagramFiles" -> Automatic,
  "MaxGraphs" -> All,
  "Assumptions" -> Automatic,
  "StorePolynomials" -> False
};
hrfRunInteriorDerivativePreselection[OptionsPattern[]] := Module[
  {files, diagramsByFamily, max, allRows, rows, candidates},
  files = Replace[OptionValue["DiagramFiles"], Automatic :> hrfInteriorDiagramFiles[]];
  diagramsByFamily = Association @ KeyValueMap[
    #1 -> hrfInteriorImportDiagramList[#2] &,
    files
  ];
  max = OptionValue["MaxGraphs"];
  allRows = Flatten[
    KeyValueMap[
      Function[{family, diagrams},
        Table[
          hrfInteriorGraphScanRow[
            diagrams[[i]],
            family,
            i,
            "Assumptions" -> OptionValue["Assumptions"],
            "StorePolynomials" -> OptionValue["StorePolynomials"]
          ],
          {i, If[IntegerQ[max], Min[max, Length[diagrams]], Length[diagrams]]}
        ]
      ],
      diagramsByFamily
    ],
    1
  ];
  rows = allRows;
  candidates = Select[rows, TrueQ[#["CandidateQ"]] &];
  <|
    "Summary" -> <|
      "TotalGraphs" -> Length[rows],
      "GraphsByFamily" -> Counts[Lookup[rows, "Family", {}]],
      "GraphsByPropagatorCount" -> Counts[Lookup[rows, "PropagatorCount", {}]],
      "CandidateCount" -> Length[candidates],
      "CandidatesByFamily" -> Counts[Lookup[candidates, "Family", {}]],
      "CandidatesByPropagatorCount" -> Counts[Lookup[candidates, "PropagatorCount", {}]],
      "ExcludedCount" -> Count[rows, r_ /; TrueQ[! r["CandidateQ"]]],
      "SignCheckProblemCount" -> Count[rows, r_ /; TrueQ[r["SignCheckProblemQ"]]]
    |>,
    "Rows" -> rows,
    "Dataset" -> Dataset[hrfInteriorWideDisplayRow /@ rows],
    "CandidateRows" -> candidates,
    "CandidateDataset" -> Dataset[hrfInteriorWideDisplayRow /@ candidates],
    "CandidateHandoffRows" -> hrfInteriorCandidateHandoffRows[candidates]
  |>
];

hrfInteriorDisplayRow[row_Association] := <|
  "Family" -> row["Family"],
  "DiagramIndex" -> row["DiagramIndex"],
  "PropagatorCount" -> row["PropagatorCount"],
  "CandidateQ" -> row["CandidateQ"],
  "FailedVariables" -> row["FailedVariables"],
  "F0TermCount" -> row["F0TermCount"],
  "InternalLines" -> row["InternalLines"],
  "ExternalLines" -> row["ExternalLines"]
|>;

hrfInteriorDerivativeSignSummaryString[drow_Association] := Module[
  {pos, neg, zero, problem, base},
  pos = Lookup[drow, "PositiveTermCount", 0];
  neg = Lookup[drow, "NegativeTermCount", 0];
  zero = Lookup[drow, "ZeroTermCount", 0];
  problem = Lookup[drow, "UndeterminedTermCount", 0];
  base = "+" <> ToString[pos] <> " / -" <> ToString[neg];
  If[zero > 0, base = base <> " / 0:" <> ToString[zero]];
  If[problem > 0, base = base <> " / ?: " <> ToString[problem]];
  base
];

hrfInteriorDerivativeSummaryAssociation[row_Association] := Association[
  Table[
    SymbolName[row["DerivativeRows"][[i]]["Variable"]] ->
      hrfInteriorDerivativeSignSummaryString[row["DerivativeRows"][[i]]],
    {i, Length[row["DerivativeRows"]]}
  ]
];

hrfInteriorWideDisplayRow[row_Association] := Join[
  <|
    "Family" -> row["Family"],
    "DiagramIndex" -> row["DiagramIndex"],
    "PropagatorCount" -> row["PropagatorCount"],
    "CandidateQ" -> row["CandidateQ"],
    "FailedVariables" -> row["FailedVariables"],
    "F0TermCount" -> row["F0TermCount"]
  |>,
  KeyMap["d_" <> # &, hrfInteriorDerivativeSummaryAssociation[row]]
];

hrfInteriorCSVTable[rows_List] := Module[{keys},
  If[rows === {}, Return[{}]];
  keys = DeleteDuplicates[Flatten[Keys /@ rows]];
  Prepend[
    Table[
      If[KeyExistsQ[rows[[i]], #],
        ToString[InputForm[Lookup[rows[[i]], #]]],
        ""
      ] & /@ keys,
      {i, Length[rows]}
    ],
    ToString /@ keys
  ]
];

hrfInteriorDerivativeSignDisplayRows[row_Association] := Flatten[
  Table[
    Module[{drow = row["DerivativeRows"][[i]], signRows},
      signRows = drow["SignRows"];
      <|
        "Family" -> row["Family"],
        "DiagramIndex" -> row["DiagramIndex"],
        "PropagatorCount" -> row["PropagatorCount"],
        "DerivativeVariable" -> drow["Variable"],
        "DerivativeMixedSignQ" -> drow["MixedSignQ"],
        "Monomial" -> #["Monomial"],
        "FactoredCoefficient" -> #["FactoredCoefficient"],
        "SignLabel" -> #["SignLabel"]
      |> & /@ signRows
    ],
    {i, Length[row["DerivativeRows"]]}
  ],
  1
];

hrfInteriorCandidateDerivativeSignRows[rows_List] :=
  Flatten[hrfInteriorDerivativeSignDisplayRows /@ rows, 1];

hrfInteriorDrawGraph[internalLines_, externalLines_, layout_ : "SpringEmbedding",
   imageSize_ : Medium] := Module[
  {internalEdges, externalVertices, externalEdges, allEdges, internalLabels, externalLabels},
  internalEdges = Table[UndirectedEdge @@ internalLines[[i, 2]], {i, Length[internalLines]}];
  externalVertices = Table["ext" <> ToString[i], {i, Length[externalLines]}];
  externalEdges = Table[UndirectedEdge[externalLines[[i, 2]], externalVertices[[i]]], {i, Length[externalLines]}];
  allEdges = Join[internalEdges, externalEdges];
  internalLabels = Table[internalEdges[[i]] -> ("x" <> ToString[i - 1]), {i, Length[internalEdges]}];
  externalLabels = Table[externalEdges[[i]] -> ToString[externalLines[[i, 1]]], {i, Length[externalLines]}];
  Graph[
    allEdges,
    EdgeLabels -> Join[internalLabels, externalLabels],
    VertexLabels -> "Name",
    GraphLayout -> layout,
    ImageSize -> imageSize
  ]
];

hrfInteriorCandidateDrawingPanel[row_Association] := Column[
  {
    Style[
      row["Family"] <> "   index " <> ToString[row["DiagramIndex"]] <>
        "   props " <> ToString[row["PropagatorCount"]],
      Bold
    ],
    hrfInteriorDrawGraph[row["InternalLines"], row["ExternalLines"], "SpringEmbedding"]
  },
  Spacings -> 0.5
];

hrfInteriorCandidateDrawingGrid[rows_List, ncols_Integer : 2] := Grid[
  Partition[hrfInteriorCandidateDrawingPanel /@ rows, UpTo[ncols]],
  Alignment -> Top,
  Spacings -> {2, 2}
];

hrfInteriorPythonString[s_String] := "\"" <> StringReplace[s, "\"" -> "\\\""] <> "\"";
hrfInteriorPythonString[s_Symbol] := hrfInteriorPythonString[SymbolName[s]];
hrfInteriorPythonString[n_Integer] := ToString[n];
hrfInteriorPythonString[x_List] := hrfInteriorPythonListString[x];
hrfInteriorPythonString[x_] := hrfInteriorPythonString[ToString[InputForm[x]]];

hrfInteriorPythonListString[list_List] :=
  "[" <> StringRiffle[hrfInteriorPythonString /@ list, ", "] <> "]";

hrfInteriorPySecDecInputString[internalLines_, externalLines_] := StringRiffle[
  {
    "internal_lines = " <> hrfInteriorPythonListString[internalLines],
    "external_lines = " <> hrfInteriorPythonListString[externalLines]
  },
  "\n"
];

hrfInteriorCandidateHandoffRows[rows_List] := (
  <|
    "Family" -> #["Family"],
    "DiagramIndex" -> #["DiagramIndex"],
    "PropagatorCount" -> #["PropagatorCount"],
    "CandidateQ" -> #["CandidateQ"],
    "InternalLines" -> #["InternalLines"],
    "ExternalLines" -> #["ExternalLines"],
    "PySecDecInput" -> hrfInteriorPySecDecInputString[#["InternalLines"], #["ExternalLines"]]
  |> & /@ rows
);

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] interior derivative preselection. Evaluate hrfRunInteriorDerivativePreselection[]."]
];
