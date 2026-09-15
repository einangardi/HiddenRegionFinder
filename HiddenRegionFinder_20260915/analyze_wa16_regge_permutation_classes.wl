(* Find audit-invariant Schwinger-variable permutation classes of the Regge
   triples {FRegge0, DeltaLayers, U}.  A colored incidence graph proposes a
   permutation.  The final certificate verifies FRegge0 exactly up to one
   overall sign and verifies the exponent supports of every suppressed layer
   and U exactly; these are precisely the data used by the face/pinch and
   hierarchy audit. *)

SetDirectory[DirectoryName[$InputFileName]];
$HRFRunWideAngle16NoCrownAuditOnLoad = False;
Get["HRF_WideAngle16ReggeInteriorAudit.wl"];

ClearAll[
  hrfReggeAuditTriple, hrfReggeTripleTermRecords,
  hrfReggeTripleIncidenceGraph, hrfReggeTriplePermutation,
  hrfReggeTriplePermutationClasses
];

hrfReggeAuditTriple[rec_Association, channel_String] := {
  Expand[hrfWA16ReggeLeadingPolynomial[rec["F0"], channel]],
  hrfWA16ReggeLayers[rec["F0"], channel],
  Expand[rec["U"]]
};

hrfReggeTripleTermRecords[triple_List, vars_List] := Module[
  {polys, records = {}, source, rules, coefficient, f0Rules, f0Sign},
  f0Rules = CoefficientRules[Expand[triple[[1]]], vars];
  f0Sign = Sign[Last[First[f0Rules]]];
  polys = Join[
    {{"F0", Expand[f0Sign triple[[1]]]}},
    KeyValueMap[{"Delta[" <> ToString[#1] <> "]", #2} &, triple[[2]]],
    {{"U", triple[[3]]}}
  ];
  Do[
    source = polys[[i, 1]];
    rules = CoefficientRules[Expand[polys[[i, 2]]], vars];
    Do[
      coefficient = If[source === "F0", Last[rule], 1];
      AppendTo[records, <|
        "Source" -> source,
        "Exponents" -> First[rule],
        "Coefficient" -> coefficient
      |>],
      {rule, rules}
    ],
    {i, Length[polys]}
  ];
  records
];

hrfReggeTripleIncidenceGraph[triple_List, vars_List] := Module[
  {records, keys, keyIndex, edges = {}, vertices, term, anchor, leaves},
  records = hrfReggeTripleTermRecords[triple, vars];
  keys = Sort @ DeleteDuplicates[
    {#Source, #Coefficient} & /@ records
  ];
  keyIndex = AssociationThread[keys, Range[Length[keys]]];
  Do[
    term = "term:" <> ToString[i];
    anchor = "anchor:" <> ToString[keyIndex[{records[[i, "Source"]],
      records[[i, "Coefficient"]]}]];
    AppendTo[edges, term <-> anchor];
    Do[
      If[records[[i, "Exponents", j]] > 0,
        AppendTo[edges, term <-> ("var:" <> ToString[j])]
      ],
      {j, Length[vars]}
    ],
    {i, Length[records]}
  ];
  Do[
    anchor = "anchor:" <> ToString[i];
    leaves = 20 + i;
    Do[
      AppendTo[edges, anchor <-> ("leaf:" <> ToString[i] <> ":" <>
        ToString[j])],
      {j, leaves}
    ],
    {i, Length[keys]}
  ];
  vertices = DeleteDuplicates[Flatten[List @@@ edges]];
  Graph[vertices, edges]
];

hrfReggeTriplePermutation[
    triple1_List, vars1_List, triple2_List, vars2_List] := Module[
  {g1, g2, iso, rules, variableRules, mapped, f0Q, layerQ, uQ,
   supportRows},
  If[Length[vars1] =!= Length[vars2], Return[Missing["DifferentVariableCount"]]];
  g1 = hrfReggeTripleIncidenceGraph[triple1, vars1];
  g2 = hrfReggeTripleIncidenceGraph[triple2, vars2];
  iso = Quiet @ Check[FindGraphIsomorphism[g1, g2], $Failed];
  If[iso === $Failed || iso === {}, Return[Missing["NotIsomorphic"]]];
  rules = Normal[First[iso]];
  variableRules = Table[
    With[{target = Replace["var:" <> ToString[i], rules]},
      If[! StringStartsQ[target, "var:"],
        Return[Missing["VariableMappedOutsideVariableSet"]]
      ];
      vars1[[i]] -> vars2[[ToExpression[StringDrop[target, 4]]]]
    ],
    {i, Length[vars1]}
  ];
  mapped = triple1 /. variableRules;
  supportRows[p_, vars_] := Sort[hrfWA16ExponentRows[p, vars]];
  f0Q = SameQ[Expand[mapped[[1]]], Expand[triple2[[1]]]] ||
    SameQ[Expand[mapped[[1]]], Expand[-triple2[[1]]]];
  layerQ = SameQ[
    Map[supportRows[#, vars2] &, mapped[[2]]],
    Map[supportRows[#, vars2] &, triple2[[2]]]
  ];
  uQ = SameQ[
    supportRows[mapped[[3]], vars2],
    supportRows[triple2[[3]], vars2]
  ];
  If[TrueQ[f0Q && layerQ && uQ],
    variableRules,
    Missing["IncidenceIsomorphismFailedExactPolynomialCheck"]
  ]
];

hrfReggeTriplePermutationClasses[cases_List] := Module[
  {classes = {}, representatives = {}, triples = {}, recs, rec, triple,
   found, permutation},
  recs = Association @ Map[
    #ID -> hrfWA16BuildData[#] &,
    hrfWA16ParseDiagramRecords[hrfWA16InputFile[]]
  ];
  Do[
    rec = recs[cases[[i, "ID"]]];
    triple = hrfReggeAuditTriple[rec, cases[[i, "Channel"]]];
    found = False;
    Do[
      permutation = hrfReggeTriplePermutation[
        triple, rec["Vars"], triples[[j]], representatives[[j, "Vars"]]
      ];
      If[ListQ[permutation],
        AppendTo[classes[[j]], Join[cases[[i]], <|
          "PermutationToRepresentative" -> permutation
        |>]];
        found = True;
        Break[]
      ],
      {j, Length[triples]}
    ];
    If[! found,
      AppendTo[triples, triple];
      AppendTo[representatives, Join[cases[[i]], <|"Vars" -> rec["Vars"]|>]];
      AppendTo[classes, {Join[cases[[i]], <|
        "PermutationToRepresentative" -> Thread[rec["Vars"] -> rec["Vars"]]
      |>]}]
    ],
    {i, Length[cases]}
  ];
  MapIndexed[<|
    "PermutationClass" -> First[#2],
    "Representative" -> KeyDrop[First[#1], "PermutationToRepresentative"],
    "Multiplicity" -> Length[#1],
    "Members" -> #1
  |> &, classes]
];

cases = {
  <|"ID" -> 85774, "Channel" -> "T23"|>,
  <|"ID" -> 85774, "Channel" -> "T12"|>,
  <|"ID" -> 85774, "Channel" -> "T13"|>,
  <|"ID" -> 85775, "Channel" -> "T12"|>,
  <|"ID" -> 85776, "Channel" -> "T23"|>,
  <|"ID" -> 85776, "Channel" -> "T12"|>,
  <|"ID" -> 105230, "Channel" -> "T23"|>,
  <|"ID" -> 105230, "Channel" -> "T12"|>,
  <|"ID" -> 105230, "Channel" -> "T13"|>,
  <|"ID" -> 105231, "Channel" -> "T12"|>,
  <|"ID" -> 105232, "Channel" -> "T23"|>,
  <|"ID" -> 105232, "Channel" -> "T12"|>
};

classes = hrfReggeTriplePermutationClasses[cases];
Export["results/wa16_regge_interior_v1_permutation_classes.wl", classes,
  "Package"];
Print[InputForm[KeyDrop[#, "Members"] & /@ classes]];
Print["CLASS MEMBERS"];
Print[InputForm[classes]];
