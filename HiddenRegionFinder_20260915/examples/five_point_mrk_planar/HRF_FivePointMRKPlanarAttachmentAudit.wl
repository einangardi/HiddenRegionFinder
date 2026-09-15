(* Attachment audit for simultaneous fixed-transverse MRK plus planarity.

   The theta graph has four-valent endpoints 3 and 5 and trivalent path
   vertices 1,2,4.  ExternalOrderAtVertices={a,b,c,d,e} means that p_a,
   ...,p_e are attached to graph vertices 1,...,5. *)

$HistoryLength = 0;
$HRF5MRKPlanarAttachmentBase = DirectoryName[$InputFileName];
$HRF5MRKPlanarLibraryOnly = True;
Get[FileNameJoin[{$HRF5MRKPlanarAttachmentBase,
  "HRF_FivePointMRKPlanarCompositeAudit.wl"}]];

ClearAll[
  hrf5MRKPlanarDeltaValuation,
  hrf5MRKPlanarLeadingCoefficient,
  hrf5MRKPlanarAttachmentRow,
  hrf5MRKPlanarAttachmentAudit
];

hrf5MRKPlanarDeltaValuation[expr_] := Module[{rat},
  rat = Together[expr];
  Exponent[Numerator[rat], delta, Min] -
    Exponent[Denominator[rat], delta, Min]
];

hrf5MRKPlanarLeadingCoefficient[expr_] := Module[{v},
  v = hrf5MRKPlanarDeltaValuation[expr];
  Factor[Limit[delta^(-v) expr, delta -> 0,
    Direction -> "FromAbove"]]
];

hrf5MRKPlanarAttachmentRow[order_List] :=
  hrf5MRKPlanarAttachmentRow[order, 1, 1];

hrf5MRKPlanarAttachmentRow[order_List,
    a_Integer?Positive, b_Integer?Positive] := Module[
  {data, f0, ratioPolynomial, ratioVariables, ratioMatrix,
   ratioLinearTerm, ratios, rules, powers, leading, assumptions,
   positiveQ, p4Vertex},

  data = hrf5WASeedData[order];
  f0 = data["F0"];
  ratioVariables = {rA, rB, rC};
  ratioPolynomial = Factor[Together[
    (f0 /. {x0 -> rA x1, x2 -> rB x3, x4 -> rC x5})/
      (x1 x3 x5)
  ]];
  ratioMatrix = Table[
    D[ratioPolynomial, ratioVariables[[i]], ratioVariables[[j]]],
    {i, 3}, {j, 3}
  ];
  ratioLinearTerm = (D[ratioPolynomial, #] & /@ ratioVariables) /.
    Thread[ratioVariables -> 0];
  ratios = Factor /@ Together[
    LinearSolve[ratioMatrix, -ratioLinearTerm]
  ];
  rules = hrf5MRKPlanarKinematicRules[a, b];
  powers = hrf5MRKPlanarDeltaValuation /@ (ratios /. rules);
  leading = hrf5MRKPlanarLeadingCoefficient /@ (ratios /. rules);
  assumptions = Pp > 0 && Kp > 0 && Mm > 0 && Q2 > 0 && xi > 0;
  positiveQ = TrueQ[FullSimplify[And @@ Thread[leading > 0], assumptions]];
  p4Vertex = First @ FirstPosition[order, 4];

  <|
    "ExternalOrderAtVertices" -> order,
    "FourValentEndpointPartons" -> order[[{3, 5}]],
    "TrivalentPathPartons" -> order[[{1, 2, 4}]],
    "CentralPartonP4Vertex" -> p4Vertex,
    "P4AtFourValentEndpointQ" -> MemberQ[{3, 5}, p4Vertex],
    "StationaryRatioPowers" -> powers,
    "StationaryRatioLeadingCoefficients" -> leading,
    "PositiveFirstSheetStationaryPointQ" -> positiveQ
  |>
];

hrf5MRKPlanarAttachmentAudit[] := Module[{rows, positiveRows},
  rows = hrf5MRKPlanarAttachmentRow /@ hrf5WACyclicOrders[];
  positiveRows = Select[rows,
    TrueQ[# ["PositiveFirstSheetStationaryPointQ"]] &];
  <|
    "GraphFourValentEndpoints" -> {3, 5},
    "GraphTrivalentPathVertices" -> {1, 2, 4},
    "Rows" -> rows,
    "PositiveRows" -> positiveRows,
    "PositiveOrders" -> Lookup[positiveRows, "ExternalOrderAtVertices"],
    "PositiveOrderCount" -> Length[positiveRows],
    "RapiditySymmetricOrder" -> {1, 2, 3, 4, 5},
    "RapiditySymmetricOrderPositiveQ" -> TrueQ[
      Lookup[First[rows], "PositiveFirstSheetStationaryPointQ"]
    ],
    "Conclusion" ->
      "Only the endpoint-reflected pair with p4 at a four-valent endpoint has a positive stationary point.  The rapidity-symmetric p3/p5-endpoint attachment is a negative first-sheet control."
  |>
];

If[!TrueQ[$HRF5MRKPlanarAttachmentLibraryOnly],
  attachmentAudit = hrf5MRKPlanarAttachmentAudit[];
  Put[attachmentAudit, FileNameJoin[{$HRF5MRKPlanarAttachmentBase,
    "results", "attachment_audit.wl"}]];
  Print[KeyTake[attachmentAudit, {
    "PositiveOrders", "PositiveOrderCount",
    "RapiditySymmetricOrder", "RapiditySymmetricOrderPositiveQ",
    "Conclusion"
  }]];
  Print[Dataset[Lookup[attachmentAudit, "Rows"]]];
];
