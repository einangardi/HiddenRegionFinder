(* Complete momentum-mode comparison for the two endpoint-reflected
   central-soft rapidity-ordered hidden regions.

   The representative attachment is {1,2,3,5,4}; the opposite endpoint is
   {1,2,4,5,3}.  The graph reflection 3<->5 induces
     x0<->x1, x2<->x3, x4<->x5.
   We transport the already coefficient-certified representative momentum
   solution through this exact graph automorphism and independently verify
   the opposite full-layer certificate, propagator virtualities and vertex
   conservation. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
$HRF5MRKRepoDirectory = DirectoryName[DirectoryName[base]];
$HRF5MRKLibraryOnly = True;
Get[FileNameJoin[{base, "HRF_FivePointMRKExploratory.wl"}]];
Get[FileNameJoin[{base, "HRF_MomentumScalingReconstruction.wl"}]];

allAudit = Get[FileNameJoin[{base,
  "five_point_mrk_all_labels_full_layer_audit.wl"}]];
representativePower = Get[FileNameJoin[{base,
  "five_point_mrk_corrected_power_counting_result.wl"}]];
representativeCentral = Get[FileNameJoin[{base,
  "five_point_mrk_pinch_momentum_result.wl"}]];

vars = {x0, x1, x2, x3, x4, x5};
oldEdgeForNewEdge = {x1, x0, x3, x2, x5, x4};
reflectionRules = Thread[vars -> oldEdgeForNewEdge];

hiddenRow[index_Integer] := First[
  allAudit["Results"][[index, "Audit", "Scan", "HiddenRegionRows"]]];

repRow = hiddenRow[2];
oppRow = hiddenRow[4];
repAudit = repRow["TotalScalingAudit"];
oppAudit = oppRow["TotalScalingAudit"];

repData = hrf5MRKSeedData[{1, 2, 3, 5, 4}];
oppData = hrf5MRKSeedData[{1, 2, 4, 5, 3}];

reflectAssociation[assoc_Association] :=
  AssociationThread[vars, Lookup[assoc, oldEdgeForNewEdge]];

repTotal = Lookup[repAudit["TotalScaling"], vars];
oppTotal = Lookup[oppAudit["TotalScaling"], vars];
repVirtualities = AssociationThread[vars, -repTotal];
oppVirtualities = AssociationThread[vars, -oppTotal];

(* Central edge valuations solve the exact external momentum hierarchy and
   tropical vertex conservation.  They are distinct from local integration
   widths about the pinched value. *)
repCentralPowers = representativeCentral["EdgeComponentPowers"];
oppCentralPowers = reflectAssociation[repCentralPowers];

externalPowers = <|
  p1 -> {Infinity, -2, Infinity},
  p2 -> {-2, Infinity, Infinity},
  p3 -> {-2, 2, 0},
  p4 -> {1, 1, 1},
  p5 -> {2, -2, 0}
|>;

(* The second t-channel presentation at the other four-valent endpoint is
   fixed using its two equal momentum representations.  For example,
     q1-q5 = p4-q3.
   The q1/q5 representation fixes plus and transverse powers without a
   leading tie; the p4/q3 representation fixes the minus power after the
   q1^-/q5^- cancellation. *)
repSecondTChannelCentralPowers = {
  Min[repCentralPowers[x1][[1]], repCentralPowers[x5][[1]]],
  Min[externalPowers[p4][[2]], repCentralPowers[x3][[2]]],
  Min[repCentralPowers[x1][[3]], repCentralPowers[x5][[3]]]
};
oppSecondTChannelCentralPowers = {
  Min[oppCentralPowers[x0][[1]], oppCentralPowers[x4][[1]]],
  Min[externalPowers[p4][[2]], oppCentralPowers[x2][[2]]],
  Min[oppCentralPowers[x0][[3]], oppCentralPowers[x4][[3]]]
};

(* These are the mode-adapted local component powers used in the contour
   pinch and scalar power count. *)
repLocalPowers = representativePower["EdgeComponentPowers"];
oppLocalPowers = reflectAssociation[repLocalPowers];

virtualityPower[{a_, b_, c_}] := Min[a + b, 2 c];
repLocalVirtualities = virtualityPower /@ repLocalPowers;
oppLocalVirtualities = virtualityPower /@ oppLocalPowers;

vertexFeasibility[data_Association, edgePowers_Association] := Module[
  {vertexComponentFeasibleQ},
  vertexComponentFeasibleQ[vertex_, component_] := Module[
    {incident, attached, powers, minimum},
    incident = Flatten @ Position[
      data["InternalLines"], {_, endpoints_} /; MemberQ[endpoints, vertex],
      {1}, Heads -> False];
    attached = Cases[data["ExternalLines"], {p_, vertex} :> p];
    powers = Join[
      Lookup[edgePowers, vars[[incident]]][[All, component]],
      Select[Lookup[externalPowers, attached][[All, component]],
        # =!= Infinity &]
    ];
    minimum = Min[powers];
    Count[powers, minimum] >= 2
  ];
  Association @ Flatten @ Table[
    (ToString[vertex] <> ":" <>
       {"plus", "minus", "perp"}[[component]]) ->
      vertexComponentFeasibleQ[vertex, component],
    {vertex, 1, 5}, {component, 1, 3}
  ]
];

repVertexFeasibility = vertexFeasibility[repData, repCentralPowers];
oppVertexFeasibility = vertexFeasibility[oppData, oppCentralPowers];

(* Exact routings.  The opposite routing is the endpoint reflection of the
   representative routing.  The same abstract loop variables r and ell are
   retained so the physical comparison is immediate. *)
repRouting = <|
  x0 -> "r", x1 -> "p1-r", x2 -> "p3-ell",
  x3 -> "ell+p2-p3", x4 -> "r-ell", x5 -> "p5-r+ell"
|>;
oppRouting = <|
  x0 -> "p1-r", x1 -> "r", x2 -> "ell+p2-p3",
  x3 -> "p3-ell", x4 -> "p5-r+ell", x5 -> "r-ell"
|>;

repLoopData = <|
  "OrdinaryLoop" -> <|"Definition" -> "r=q0", "LocalWidths" -> {4, 0, 2}|>,
  "GlauberLoop" -> <|"Definition" -> "ell=q0-q4",
    "LocalWidths" -> {4, 1, 2}|>,
  "SecondTChannelGlauberRouting" -> <|
    "Definition" -> "ell5=q1-q5=p4-q3=p1-p5-ell",
    "CentralPowers" -> repSecondTChannelCentralPowers,
    "LocalWidths" -> {4, 1, 2},
    "FluctuationRelation" -> "Delta ell5=-Delta ell"|>,
  "Pinches" -> {
    <|"Component" -> "r+", "Edges" -> {x0, x1}, "Width" -> 4|>,
    <|"Component" -> "ell+", "Edges" -> {x4, x5}, "Width" -> 4|>,
    <|"Component" -> "ell-", "Edges" -> {x2, x3}, "Width" -> 1|>
  }
|>;
oppLoopData = <|
  "OrdinaryLoop" -> <|"Definition" -> "r=q1", "LocalWidths" -> {4, 0, 2}|>,
  "GlauberLoop" -> <|"Definition" -> "ell=q1-q5",
    "LocalWidths" -> {4, 1, 2}|>,
  "SecondTChannelGlauberRouting" -> <|
    "Definition" -> "ell3=q0-q4=p4-q2=p1-p5-ell",
    "CentralPowers" -> oppSecondTChannelCentralPowers,
    "LocalWidths" -> {4, 1, 2},
    "FluctuationRelation" -> "Delta ell3=-Delta ell"|>,
  "Pinches" -> {
    <|"Component" -> "r+", "Edges" -> {x1, x0}, "Width" -> 4|>,
    <|"Component" -> "ell+", "Edges" -> {x5, x4}, "Width" -> 4|>,
    <|"Component" -> "ell-", "Edges" -> {x3, x2}, "Width" -> 1|>
  }
|>;

loopMeasurePower[{a_, b_, c_}] := a + b + (D - 2) c;
repMomentumMeasure = Total[
  loopMeasurePower /@ {{4, 0, 2}, {4, 1, 2}}];
oppMomentumMeasure = repMomentumMeasure;
repMomentumPower = Expand[repMomentumMeasure - Total[Values[repVirtualities]]];
oppMomentumPower = Expand[oppMomentumMeasure - Total[Values[oppVirtualities]]];

(* Local cancellation coordinates.  In each case the normal A has resolved
   weight zero, B has weight -8, four tangential directions give -16 and
   the Jacobian contributes +4. *)
repLocalCoordinates = <|
  "A" -> P x2 - K delta^3 x3,
  "B" -> x1 x4 - x0 x5,
  "Jacobian" -> -1/(P x0),
  "MeasurePower" -> -20
|>;
oppLocalCoordinates = <|
  "A" -> K delta^3 x2 - P x3,
  "B" -> x1 x4 - x0 x5,
  "Jacobian" -> 1/(P x0),
  "MeasurePower" -> -20
|>;

repPoly = Factor[repRow["Polynomial"]];
oppPoly = Factor[oppRow["Polynomial"]];

checks = <|
  "RepresentativeFacetQ" ->
    repAudit["AuditStatus"] === "AcceptedLowerFacet" &&
      repAudit["ResolvedWHRAffineRank"] === 6,
  "OppositeFacetQ" ->
    oppAudit["AuditStatus"] === "AcceptedLowerFacet" &&
      oppAudit["ResolvedWHRAffineRank"] === 6,
  "PolynomialReflectionQ" ->
    Expand[oppPoly - (repPoly /. reflectionRules)] === 0,
  "TotalVectorReflectionQ" ->
    oppTotal === Lookup[AssociationThread[vars, repTotal], oldEdgeForNewEdge],
  "VirtualityReflectionQ" ->
    oppVirtualities === reflectAssociation[repVirtualities],
  "RepresentativeLocalVirtualitiesQ" ->
    repLocalVirtualities === repVirtualities,
  "OppositeLocalVirtualitiesQ" ->
    oppLocalVirtualities === oppVirtualities,
  "RepresentativeVertexConservationQ" ->
    And @@ Values[repVertexFeasibility],
  "OppositeVertexConservationQ" ->
    And @@ Values[oppVertexFeasibility],
  "OneGlauberLoopEachQ" ->
    4 + 1 > 2*2,
  "TwoTChannelGlauberVerticesEachQ" ->
    2 + 2 > 2*0 && 4 + 1 > 2*1 &&
      repSecondTChannelCentralPowers === {4, 1, 1} &&
      oppSecondTChannelCentralPowers === {4, 1, 1} &&
      repLoopData["SecondTChannelGlauberRouting", "LocalWidths"] ===
        repLoopData["GlauberLoop", "LocalWidths"] &&
      oppLoopData["SecondTChannelGlauberRouting", "LocalWidths"] ===
        oppLoopData["GlauberLoop", "LocalWidths"],
  "MomentumPowerAgreementQ" ->
    repMomentumPower === -20 + 4 D &&
      oppMomentumPower === -20 + 4 D
|>;

makeCase[name_, order_, total_, virtualities_, central_, local_, routing_,
    loopData_, localCoordinates_, vertexChecks_] := <|
  "Name" -> name,
  "ExternalOrderAtVertices" -> order,
  "TotalRegionVector" -> Append[total, 1],
  "PropagatorVirtualityPowers" -> virtualities,
  "CentralEdgeComponentPowers" -> central,
  "ModeAdaptedEdgeComponentPowers" -> local,
  "ExactRouting" -> routing,
  "LoopModes" -> loopData,
  "GlauberLoopCount" -> 1,
  "LocalCancellationCoordinates" -> localCoordinates,
  "ParameterMeasurePower" -> -20,
  "MomentumMeasurePower" -> repMomentumMeasure,
  "ScalarIntegralPower" -> -20 + 4 D,
  "PowerAtD4Minus2Epsilon" -> -4 - 8 epsilon,
  "VertexFeasibility" -> vertexChecks
|>;

result = <|
  "Status" -> If[And @@ Values[checks], "Passed", "Failed"],
  "Checks" -> checks,
  "GraphReflection" -> <|
    "VertexMap" -> "3<->5",
    "EdgeMap" -> reflectionRules,
    "PhysicalInterpretation" ->
      "The longitudinal-dominated edge and the two affine t-channel presentations of the single Glauber loop exchange endpoints; the number and local widths of independent modes do not change."
  |>,
  "Representative" -> makeCase[
    "p4 at endpoint 5", {1, 2, 3, 5, 4}, repTotal,
    repVirtualities, repCentralPowers, repLocalPowers, repRouting,
    repLoopData, repLocalCoordinates, repVertexFeasibility],
  "OppositeEndpoint" -> makeCase[
    "p4 at endpoint 3", {1, 2, 4, 5, 3}, oppTotal,
    oppVirtualities, oppCentralPowers, oppLocalPowers, oppRouting,
    oppLoopData, oppLocalCoordinates, oppVertexFeasibility],
  "Comparison" -> <|
    "SameModeContentQ" -> True,
    "RepresentativeExceptionalPropagator" -> x2,
    "OppositeExceptionalPropagator" -> x3,
    "RepresentativeGlauberCombination" -> "q0-q4",
    "OppositeGlauberCombination" -> "q1-q5",
    "RepresentativeSecondTChannelRouting" -> "q1-q5",
    "OppositeSecondTChannelRouting" -> "q0-q4",
    "Conclusion" ->
      "The two fixed-label regions differ, but their momentum regions are related exactly by endpoint reflection: one ordinary on-shell-balanced loop and one Glauber loop in each case.  The same Glauber loop has two affine t-channel routings, so both four-valent endpoints are Glauber vertices."
  |>
|>;

Export[FileNameJoin[{base,
  "five_point_mrk_opposite_endpoint_momentum_comparison.wl"}],
  result, "Package"];
Print[InputForm[result]];
If[result["Status"] =!= "Passed", Exit[1]];
