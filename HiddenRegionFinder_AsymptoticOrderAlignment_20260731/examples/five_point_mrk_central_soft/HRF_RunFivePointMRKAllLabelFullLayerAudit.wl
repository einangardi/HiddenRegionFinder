(* One-kernel audit of all inequivalent external label orders in the exact
   central-soft chart. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
$HRF5MRKTargetedLibraryOnly = True;
Get[FileNameJoin[{base, "HRF_FivePointMRKTargetedRun.wl"}]];

orders = hrf5MRKCyclicOrders[];
softA = If[Length[$ScriptCommandLine] >= 2,
  ToExpression[$ScriptCommandLine[[2]]], 1];
softB = If[Length[$ScriptCommandLine] >= 3,
  ToExpression[$ScriptCommandLine[[3]]], 2];
sigma = If[Length[$ScriptCommandLine] >= 4,
  Switch[$ScriptCommandLine[[4]], "minus", -1, "plus", 1,
    _, ToExpression[$ScriptCommandLine[[4]]]], 1];
If[! (IntegerQ[softA] && IntegerQ[softB] && 0 < softA < softB &&
    MemberQ[{-1, 1}, sigma]),
  Print["Usage: ... [a b sigma], with 0<a<b and sigma=+/-1"]; Exit[2]
];
rules = hrf5MRKExactCentralSoftRules[softA, softB, sigma];
kinVars = {P, M, K, R, T, C};
assumptions = P > 0 && M > 0 && K > 0 && R > 0 && T > 0 && C > 0 &&
  C^2 < 4 R T;

results = MapIndexed[
  Function[{order, index},
    Module[{data, audit},
      data = hrf5MRKSeedData[order];
      audit = targetedRun[data,
        If[sigma == 1, "exact-soft-plus", "exact-soft-minus"], rules,
        Range[-(softA + softB), 0],
        kinVars, assumptions];
      <|"OrderIndex" -> First[index], "ExternalOrder" -> order,
        "Audit" -> audit|>
    ]
  ],
  orders
];

summaryRows = Map[
  Function[row,
    With[{scan = row["Audit", "Scan"]},
      <|
        "OrderIndex" -> row["OrderIndex"],
        "ExternalOrder" -> row["ExternalOrder"],
        "PreselectionSurvivorCount" ->
          row["Audit", "PreselectionSurvivorCount"],
        "StagedCandidateCount" -> If[AssociationQ[scan],
          Lookup[scan["Summary"], "StagedHiddenRegionCount", 0], 0],
        "FullLayerAcceptedCount" -> If[AssociationQ[scan],
          Lookup[scan["Summary"], "TotalLowerFacetAcceptedCount", 0], 0]
      |>
    ]
  ],
  results
];

result = <|
  "Chart" -> StringJoin["exact central-soft a:b=", ToString[softA], ":",
    ToString[softB], ", sigma=", If[sigma == 1, "+1", "-1"]],
  "a" -> softA, "b" -> softB, "sigma" -> sigma,
  "Results" -> results,
  "SummaryRows" -> summaryRows,
  "TotalFullLayerAcceptedCount" ->
    Total[Lookup[summaryRows, "FullLayerAcceptedCount", 0]]
|>;

Print[InputForm[summaryRows]];
Print["total full-layer accepted = ", result["TotalFullLayerAcceptedCount"]];
out = FileNameJoin[{base, StringJoin[
  "five_point_mrk_all_labels_full_layer_audit_", ToString[softA], "_",
  ToString[softB], "_", If[sigma == 1, "plus", "minus"], ".wl"]}];
Export[out, result, "Package"];
If[{softA, softB, sigma} === {1, 2, 1},
  Export[FileNameJoin[{base,
    "five_point_mrk_all_labels_full_layer_audit.wl"}], result, "Package"]
];
