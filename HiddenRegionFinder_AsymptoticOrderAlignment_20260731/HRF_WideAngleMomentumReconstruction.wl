(* ::Package:: *)

(* HRF_WideAngleMomentumReconstruction.wl

   Constructive parameter-space -> momentum-space certificates for the
   wide-angle Crown interior and the established HyperCrown boundary orbits.

   The component powers are quoted as (+,-,perp), with p1 the large-minus
   direction and p2 the large-plus direction.  A jet
   parallel to p3 or p4 therefore has component powers {0,0,0}; its small
   virtuality is a coefficient-level near-on-shell cancellation, not a hard
   propagator.  The association "JetDirection" records this information.
*)

If[Length[DownValues[hrfMomentumVirtualityRealizationType]] == 0,
  Get[FileNameJoin[{
    DirectoryName[$InputFileName], "HRF_MomentumScalingReconstruction.wl"
  }]]
];

ClearAll[
  hrfWideAngleContractBoundaryEdge,
  hrfWideAngleExplicitBranch,
  hrfWideAngleVertexValuationAudit,
  hrfWideAngleMomentumTable,
  hrfWideAngleLoopBasisQ,
  hrfWideAngleCrownMomentumCertificate,
  hrfWideAngleHyperCrownX11MomentumCertificate,
  hrfWideAngleContractBoundaryEdges,
  hrfWideAngleHyperCrownPositiveMomentumCertificate,
  hrfWideAngleHyperCrownPositiveMomentumCertificates,
  hrfWideAngleMomentumCertificateSummary
];

hrfWideAngleContractBoundaryEdge[
    internalLines_List, externalLines_List, edgeVariables_List,
    zeroVariable_] := Module[
  {position, endpoints, keep, retainedInternal, retainedVariables,
   retainedExternal, representative, contracted},
  position = FirstPosition[edgeVariables, zeroVariable];
  If[MissingQ[position],
    Return[<|"Status" -> "BoundaryVariableNotFound"|>]
  ];
  position = First[position];
  endpoints = internalLines[[position, 2]];
  representative = First[endpoints];
  contracted = Last[endpoints];
  keep = Delete[Range[Length[internalLines]], position];
  retainedInternal = internalLines[[keep]] /. contracted -> representative;
  retainedExternal = externalLines /. contracted -> representative;
  retainedVariables = edgeVariables[[keep]];
  <|
    "Status" -> "Contracted",
    "ContractedVariable" -> zeroVariable,
    "ContractedEndpoints" -> endpoints,
    "RepresentativeVertex" -> representative,
    "InternalLines" -> retainedInternal,
    "ExternalLines" -> retainedExternal,
    "Variables" -> retainedVariables
  |>
];

hrfWideAngleContractBoundaryEdges[
    internalLines_List, externalLines_List, edgeVariables_List,
    zeroVariables_List] := Fold[
  Function[{state, z},
    If[Lookup[state, "Status", "Contracted"] =!= "Contracted", state,
      hrfWideAngleContractBoundaryEdge[
        state["InternalLines"], state["ExternalLines"], state["Variables"], z]
    ]
  ],
  <|"Status" -> "Contracted", "InternalLines" -> internalLines,
    "ExternalLines" -> externalLines, "Variables" -> edgeVariables|>,
  zeroVariables
];

hrfWideAngleExplicitBranch[
    edgeVariables_List, componentPowers_List, virtualityPowers_List] := <|
  "EdgeComponentPowers" -> AssociationThread[
    edgeVariables, componentPowers],
  "VirtualityPowers" -> AssociationThread[
    edgeVariables, virtualityPowers],
  "VirtualityTypes" -> AssociationThread[
    edgeVariables,
    MapThread[hrfMomentumVirtualityRealizationType,
      {componentPowers, virtualityPowers}]
  ],
  "ComponentBalanceTypes" -> AssociationThread[
    edgeVariables, hrfMomentumVirtualityType /@ componentPowers]
|>;

hrfWideAngleVertexValuationAudit[
    internalLines_List, externalLines_List, edgeVariables_List,
    branch_Association, externalPowers_Association] := Module[
  {vertices, componentNames, rows},
  vertices = Sort @ DeleteDuplicates @ Join[
    Flatten[internalLines[[All, 2]]], externalLines[[All, 2]]];
  componentNames = {"plus", "minus", "perp"};
  rows = Flatten @ Table[
    Module[{incident, attached, powers, minimum, multiplicity},
      incident = Flatten @ Position[
        internalLines, {_, endpoints_} /; MemberQ[endpoints, vertex],
        {1}, Heads -> False];
      attached = Cases[externalLines, {momentum_, vertex} :> momentum];
      powers = Join[
        Lookup[branch["EdgeComponentPowers"],
          edgeVariables[[incident]]][[All, component]],
        Select[Lookup[externalPowers, attached][[All, component]],
          hrfMomentumFiniteExponentQ]
      ];
      minimum = If[powers === {}, Infinity, Min[powers]];
      multiplicity = Count[powers, minimum];
      <|
        "Vertex" -> vertex,
        "Component" -> componentNames[[component]],
        "IncidentPowers" -> powers,
        "MinimumPower" -> minimum,
        "MinimumMultiplicity" -> multiplicity,
        "ConservationCompatibleQ" -> multiplicity >= 2
      |>
    ],
    {vertex, vertices}, {component, 3}
  ];
  <|
    "Rows" -> rows,
    "AllVertexComponentsCompatibleQ" ->
      AllTrue[rows, TrueQ[# ["ConservationCompatibleQ"]] &]
  |>
];

hrfWideAngleMomentumTable[
    edgeVariables_List, branch_Association, jetDirections_Association,
    modeLabels_Association] := Dataset @ Map[
  Function[edge,
    <|
      "Edge" -> edge,
      "q+ power" -> branch["EdgeComponentPowers"][edge][[1]],
      "q- power" -> branch["EdgeComponentPowers"][edge][[2]],
      "qPerp power" -> branch["EdgeComponentPowers"][edge][[3]],
      "q^2 power" -> branch["VirtualityPowers"][edge],
      "Virtuality realization" -> branch["VirtualityTypes"][edge],
      "Mode" -> Lookup[modeLabels, edge, "--"],
      "Jet direction" -> Lookup[jetDirections, edge, "--"]
    |>
  ],
  edgeVariables
];

hrfWideAngleLoopBasisQ[
    internalLines_List, edgeVariables_List, proposedEdges_List] := Module[
  {trees, proposedIndices},
  proposedIndices = Flatten[FirstPosition[edgeVariables, #] & /@
    proposedEdges];
  trees = hrfMomentumSpanningTreeEdgeSets[internalLines];
  MemberQ[Complement[Range[Length[internalLines]], #] & /@ trees,
    proposedIndices]
];

hrfWideAngleCrownMomentumCertificate[] := Module[
  {variables, lpScaling, virtualities, externalPowers, componentPowers,
   branch, jetDirections, modeLabels, vertexAudit, loopBasis},
  variables = VarsCrown;
  lpScaling = AssociationThread[variables, ConstantArray[-1, Length[variables]]];
  virtualities = -Lookup[lpScaling, variables];
  externalPowers = <|
    p1 -> {1, 0, 1/2}, p2 -> {0, 1, 1/2},
    p3 -> {0, 0, 0}, p4 -> {0, 0, 0}
  |>;
  componentPowers = {
    {1, 0, 1/2}, {1, 0, 1/2},
    {0, 1, 1/2}, {0, 1, 1/2},
    {0, 0, 0}, {0, 0, 0},
    {0, 0, 0}, {0, 0, 0}
  };
  branch = hrfWideAngleExplicitBranch[
    variables, componentPowers, virtualities];
  jetDirections = AssociationThread[variables,
    {p1, p1, p2, p2, p3, p3, p4, p4}];
  modeLabels = AssociationThread[variables, ConstantArray["jet", 8]];
  vertexAudit = hrfWideAngleVertexValuationAudit[
    CrownInternalEdges, CrownExternalEdges, variables, branch,
    externalPowers];
  loopBasis = {x0, x2, x4};
  <|
    "Case" -> "Crown interior",
    "ExpansionParameter" -> \[Delta],
    "ScalingVectorWithDelta" -> Append[Lookup[lpScaling, variables], 1],
    "LPScaling" -> lpScaling,
    "VirtualityPowers" -> branch["VirtualityPowers"],
    "ExternalComponentPowers" -> externalPowers,
    "Branch" -> branch,
    "JetDirections" -> jetDirections,
    "ModeLabels" -> modeLabels,
    "MomentumTable" -> hrfWideAngleMomentumTable[
      variables, branch, jetDirections, modeLabels],
    "VertexAudit" -> vertexAudit,
    "IndependentLoopEdges" -> loopBasis,
    "IndependentLoopBasisValidQ" -> hrfWideAngleLoopBasisQ[
      CrownInternalEdges, variables, loopBasis],
    "MomentumRelations" -> {
      "q0=k1", "q1=p1-k1", "q2=k2", "q3=p2-k2",
      "q4=k3", "q5=p3-k3", "q6=k4", "q7=p4-k4",
      "k1+k2=k3+k4"
    },
    "Interpretation" ->
      "Landshoff region: four external-direction jets join two disconnected hard vertices.  There is no Glauber loop at generic scattering angle."
  |>
];

hrfWideAngleHyperCrownX11MomentumCertificate[] := Module[
  {contracted, variables, lpScaling, virtualities, externalPowers,
   componentPowers, branch, jetDirections, modeLabels, vertexAudit,
   loopBasis},
  contracted = hrfWideAngleContractBoundaryEdge[
    HyperCrownInternalEdges, HyperCrownExternalEdges, VarsHyperCrown, x11];
  If[contracted["Status"] =!= "Contracted", Return[contracted]];
  variables = contracted["Variables"];
  lpScaling = AssociationThread[variables,
    (If[# === x10, -2, -1] &) /@ variables];
  virtualities = -Lookup[lpScaling, variables];
  externalPowers = <|
    p1 -> {1, 0, 1/2}, p2 -> {0, 1, 1/2},
    p3 -> {0, 0, 0}, p4 -> {0, 0, 0}
  |>;
  componentPowers = Lookup[<|
    x0 -> {1, 0, 1/2}, x1 -> {1, 0, 1/2},
    x2 -> {0, 0, 0}, x3 -> {0, 0, 0},
    x4 -> {0, 1, 1/2}, x5 -> {0, 1, 1/2},
    x6 -> {0, 0, 0}, x7 -> {0, 0, 0},
    x8 -> {0, 0, 0}, x9 -> {0, 0, 0},
    x10 -> {1, 1, 1}
  |>, variables];
  branch = hrfWideAngleExplicitBranch[
    variables, componentPowers, virtualities];
  jetDirections = <|
    x0 -> p1, x1 -> p1, x4 -> p2, x5 -> p2,
    x6 -> p3, x7 -> p3, x9 -> p3,
    x2 -> p4, x3 -> p4, x8 -> p4,
    x10 -> "--"
  |>;
  modeLabels = AssociationThread[variables,
    (If[# === x10, "soft", "jet"] &) /@ variables];
  vertexAudit = hrfWideAngleVertexValuationAudit[
    contracted["InternalLines"], contracted["ExternalLines"],
    variables, branch, externalPowers];
  loopBasis = {x0, x4, x6, x10};
  <|
    "Case" -> "HyperCrown boundary x11=0",
    "BoundaryContraction" -> KeyTake[contracted,
      {"ContractedVariable", "ContractedEndpoints",
       "RepresentativeVertex"}],
    "ContractedInternalLines" -> contracted["InternalLines"],
    "ContractedExternalLines" -> contracted["ExternalLines"],
    "ActiveVariables" -> variables,
    "ExpansionParameter" -> \[Delta],
    "ScalingVectorWithDelta" -> Append[Lookup[lpScaling, variables], 1],
    "LPScaling" -> lpScaling,
    "VirtualityPowers" -> branch["VirtualityPowers"],
    "ExternalComponentPowers" -> externalPowers,
    "Branch" -> branch,
    "JetDirections" -> jetDirections,
    "ModeLabels" -> modeLabels,
    "MomentumTable" -> hrfWideAngleMomentumTable[
      variables, branch, jetDirections, modeLabels],
    "VertexAudit" -> vertexAudit,
    "IndependentLoopEdges" -> loopBasis,
    "IndependentLoopBasisValidQ" -> hrfWideAngleLoopBasisQ[
      contracted["InternalLines"], variables, loopBasis],
    "MomentumRelations" -> {
      "q0=k1", "q1=p1-k1", "q4=k2", "q5=p2-k2",
      "q6=k3", "q7=p3-k3", "q10=s",
      "q9=k3+s", "q2=k4=k1+k2-k3", "q8=k4-s",
      "q3=p4-k4", "k1+k2=k3+k4"
    },
    "Interpretation" ->
      "Landshoff descendant with four external-direction jets and one additional soft loop s=q10.  The soft exchange joins the p3 and p4 jet lines attached to the same hard component; it does not turn the generic-angle region into a Glauber region."
  |>
];

hrfWideAngleHyperCrownPositiveMomentumCertificate[zeroVariables_List] := Module[
  {z = SortBy[zeroVariables,
      ToExpression[StringDrop[SymbolName[Unevaluated[#]], 1]] &],
   contracted, variables, softEdge, directionRules,
   lpScaling, virtualities, externalPowers, componentByDirection,
   componentPowers, branch, jetDirections, modeLabels, vertexAudit,
   trees, loopBasis, interpretation},
  contracted = hrfWideAngleContractBoundaryEdges[
    HyperCrownInternalEdges, HyperCrownExternalEdges, VarsHyperCrown, z];
  If[Lookup[contracted, "Status", "Failed"] =!= "Contracted", Return[contracted]];
  variables = contracted["Variables"];
  {softEdge, directionRules, interpretation} = Switch[z,
    {x8},
      {x9, {x0 -> p1, x1 -> p1, x4 -> p2, x5 -> p2, x11 -> p2,
          x6 -> p3, x7 -> p3, x10 -> p3, x2 -> p4, x3 -> p4},
       "D4 image of the x9=0 certificate: a Landshoff descendant with a soft x9 loop; the remaining lines form four external-direction jets."},
    {x9},
      {x8, {x0 -> p1, x1 -> p1, x11 -> p1, x4 -> p2, x5 -> p2,
          x6 -> p3, x7 -> p3, x2 -> p4, x3 -> p4, x10 -> p4},
       "Landshoff descendant with a soft x8 loop; the remaining lines form four external-direction jets."},
    {x10},
      {x11, {x0 -> p1, x1 -> p1, x8 -> p1, x4 -> p2, x5 -> p2,
          x9 -> p2, x6 -> p3, x7 -> p3, x2 -> p4, x3 -> p4},
       "Landshoff descendant with a soft x11 loop; the remaining lines form four external-direction jets."},
    {x11},
      {x10, {x0 -> p1, x1 -> p1, x4 -> p2, x5 -> p2,
          x6 -> p3, x7 -> p3, x9 -> p3, x2 -> p4, x3 -> p4, x8 -> p4},
       "Landshoff descendant with a soft x10 loop; the remaining lines form four external-direction jets."},
    {x8, x10},
      {None, {x0 -> p1, x1 -> p1, x4 -> p2, x5 -> p2, x9 -> p2,
          x11 -> p2, x6 -> p3, x7 -> p3, x2 -> p4, x3 -> p4},
       "Uniform Landshoff descendant.  The parallel x9/x11 lines form an additional p2-collinear loop; there is no soft or Glauber virtuality."},
    {x8, x11},
      {None, {x0 -> p1, x1 -> p1, x4 -> p2, x5 -> p2,
          x6 -> p3, x7 -> p3, x9 -> p3, x10 -> p3, x2 -> p4, x3 -> p4},
       "Uniform Landshoff descendant.  The parallel x9/x10 lines form an additional p3-collinear loop; there is no soft or Glauber virtuality."},
    {x9, x10},
      {None, {x0 -> p1, x1 -> p1, x8 -> p1, x11 -> p1,
          x4 -> p2, x5 -> p2, x6 -> p3, x7 -> p3, x2 -> p4, x3 -> p4},
       "D4 image of an established adjacent-pair certificate.  The parallel x8/x11 lines form an additional p1-collinear loop; there is no soft or Glauber virtuality."},
    {x9, x11},
      {None, {x0 -> p1, x1 -> p1, x4 -> p2, x5 -> p2,
          x6 -> p3, x7 -> p3, x2 -> p4, x3 -> p4, x8 -> p4, x10 -> p4},
       "D4 image of an established adjacent-pair certificate.  The parallel x8/x10 lines form an additional p4-collinear loop; there is no soft or Glauber virtuality."},
    _, Return[<|"Status" -> "UnsupportedPositiveHyperCrownStratum",
        "ZeroVariables" -> z|>]
  ];
  lpScaling = AssociationThread[variables,
    (If[softEdge =!= None && # === softEdge, -2, -1] &) /@ variables];
  virtualities = -Lookup[lpScaling, variables];
  externalPowers = <|p1 -> {1, 0, 1/2}, p2 -> {0, 1, 1/2},
    p3 -> {0, 0, 0}, p4 -> {0, 0, 0}|>;
  componentByDirection = externalPowers;
  jetDirections = Association[directionRules];
  If[softEdge =!= None, jetDirections[softEdge] = "--"];
  componentPowers = (If[softEdge =!= None && # === softEdge,
      {1, 1, 1}, componentByDirection[jetDirections[#]]] &) /@ variables;
  branch = hrfWideAngleExplicitBranch[variables, componentPowers, virtualities];
  modeLabels = AssociationThread[variables,
    (If[softEdge =!= None && # === softEdge, "soft", "jet"] &) /@ variables];
  vertexAudit = hrfWideAngleVertexValuationAudit[
    contracted["InternalLines"], contracted["ExternalLines"], variables,
    branch, externalPowers];
  trees = hrfMomentumSpanningTreeEdgeSets[contracted["InternalLines"]];
  loopBasis = If[trees === {}, {},
    variables[[Complement[Range[Length[variables]], First[trees]]]]];
  <|
    "Case" -> "HyperCrown boundary " <> ToString[InputForm[z]],
    "ZeroVariables" -> z, "ActiveVariables" -> variables,
    "ContractedInternalLines" -> contracted["InternalLines"],
    "ContractedExternalLines" -> contracted["ExternalLines"],
    "ExpansionParameter" -> \[Delta],
    "ScalingVectorWithDelta" -> Append[Lookup[lpScaling, variables], 1],
    "LPScaling" -> lpScaling, "VirtualityPowers" -> branch["VirtualityPowers"],
    "ExternalComponentPowers" -> externalPowers, "Branch" -> branch,
    "JetDirections" -> jetDirections, "ModeLabels" -> modeLabels,
    "MomentumTable" -> hrfWideAngleMomentumTable[
      variables, branch, jetDirections, modeLabels],
    "VertexAudit" -> vertexAudit, "IndependentLoopEdges" -> loopBasis,
    "IndependentLoopBasisValidQ" -> hrfWideAngleLoopBasisQ[
      contracted["InternalLines"], variables, loopBasis],
    "Interpretation" -> interpretation
  |>
];

hrfWideAngleHyperCrownPositiveMomentumCertificates[] := Association @ Table[
  ToString[InputForm[z]] -> hrfWideAngleHyperCrownPositiveMomentumCertificate[z],
  {z, {{x8}, {x9}, {x10}, {x11},
       {x8, x10}, {x8, x11}, {x9, x10}, {x9, x11}}}
];

hrfWideAngleMomentumCertificateSummary[certificate_Association] := <|
  "Case" -> certificate["Case"],
  "ScalingVectorWithDelta" -> certificate["ScalingVectorWithDelta"],
  "VirtualityPowers" -> certificate["VirtualityPowers"],
  "AllVertexComponentsCompatibleQ" ->
    certificate["VertexAudit", "AllVertexComponentsCompatibleQ"],
  "IndependentLoopEdges" -> certificate["IndependentLoopEdges"],
  "IndependentLoopBasisValidQ" ->
    certificate["IndependentLoopBasisValidQ"],
  "Interpretation" -> certificate["Interpretation"]
|>;
