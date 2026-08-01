(* Full-depth edge-flow valuation audit for the representative central-soft
   five-point MRK hidden region.  This is not yet a mode-complete momentum
   certificate because the coefficient-level fluctuation widths remain to
   be derived.  The important distinction is between the
   final one-power HRF hierarchy gap and the total cancellation depth after
   the preceding asymptotic-order alignment. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
$HRF5MRKRepoDirectory = DirectoryName[DirectoryName[base]];
$HRF5MRKLibraryOnly = True;
Get[FileNameJoin[{base, "HRF_FivePointMRKExploratory.wl"}]];
Get[FileNameJoin[{base, "HRF_MomentumScalingReconstruction.wl"}]];

data = hrf5MRKSeedData[{1, 2, 3, 5, 4}];
summary = Get[FileNameJoin[{base, "certified_summary.wl"}]];
certificate = summary["RepresentativeCertificate"];
edgeVariables = data["Variables"];
totalScaling = Lookup[certificate["TotalScaling"], edgeVariables];
targetVirtualities = -totalScaling;

externalPowers = <|
  p1 -> {Infinity, -2, Infinity},
  p2 -> {-2, Infinity, Infinity},
  p3 -> {-2, 2, 0},
  p4 -> {1, 1, 1},
  p5 -> {2, -2, 0}
|>;

(* Verify the raw, pre-cancellation layer directly in the original exact
   kinematic chart. *)
fChart = Expand[data["F"] /. hrf5MRKExactCentralSoftRules[1, 2, 1]];
scaledF = Expand[fChart /. Thread[
  edgeVariables -> edgeVariables delta^totalScaling]];
termPowers = Exponent[#, delta, Min] & /@ (List @@ scaledF);
rawSuperleadingPower = Min[termPowers];
rawSuperleadingCoefficient = Factor[
  Coefficient[scaledF, delta, rawSuperleadingPower]];
scalefulLPWeight = certificate["WHR"];
totalCancellationDepth = scalefulLPWeight - rawSuperleadingPower;
finalHRFGap = certificate["HierarchyGap"];
alignmentDepth = totalCancellationDepth - finalHRFGap;

(* A vertex-feasible component assignment realizing the absolute propagator
   virtualities (4,4,1,4,4,4).  Lines x4 and x5 are near-on-shell enhanced:
   their component products cancel beyond the valuation visible before the
   coefficient-level pinch conditions are imposed. *)
edgePowerLists = {
  {6, -2, 2}, {6, -2, 2}, {-2, 3, 2},
  {1, 3, 2}, {2, -2, 0}, {4, -2, 1}
};
branch = <|
  "EdgeComponentPowers" ->
    AssociationThread[edgeVariables, edgePowerLists],
  "VirtualityPowers" ->
    AssociationThread[edgeVariables, targetVirtualities],
  "VirtualityTypes" -> AssociationThread[
    edgeVariables,
    MapThread[hrfMomentumVirtualityRealizationType,
      {edgePowerLists, targetVirtualities}]],
  "ComponentBalanceTypes" -> AssociationThread[
    edgeVariables, hrfMomentumVirtualityType /@ edgePowerLists]
|>;

vertexComponentFeasibleQ[vertex_, component_] := Module[
  {incident, attached, powers, minimum},
  incident = Flatten @ Position[
    data["InternalLines"], {_, endpoints_} /; MemberQ[endpoints, vertex],
    {1}, Heads -> False];
  attached = Cases[data["ExternalLines"], {p_, vertex} :> p];
  powers = Join[
    Lookup[branch["EdgeComponentPowers"], edgeVariables[[incident]]][[All,
      component]],
    Select[Lookup[externalPowers, attached][[All, component]],
      # =!= Infinity &]
  ];
  minimum = Min[powers];
  Count[powers, minimum] >= 2
];

vertexFeasibility = Association @ Flatten @ Table[
  (ToString[vertex] <> ":" <> {"plus", "minus", "perp"}[[component]]) ->
    vertexComponentFeasibleQ[vertex, component],
  {vertex, 1, 5}, {component, 1, 3}
];

combinationAudit = hrfMomentumLoopCombinationAudit[
  data["InternalLines"], data["ExternalLines"], edgeVariables,
  branch, externalPowers, {p1, p2},
  "RelationCoefficientRange" -> 2];
glauberWitness = FirstCase[
  combinationAudit["GlauberCombinationRows"],
  row_ /; Values[row["TargetInternalCoefficients"]] ===
    {1, 0, 0, 0, -1, 0},
  Missing["NoFullDepthGlauberWitness"]
];

checks = <|
  "TotalScalingMatchesCertificateQ" ->
    totalScaling === {-4, -4, -1, -4, -4, -4},
  "RawSuperleadingPowerQ" -> rawSuperleadingPower === -13,
  "ScalefulLPWeightQ" -> scalefulLPWeight === -8,
  "TotalCancellationDepthQ" -> totalCancellationDepth === 5,
  "DepthDecompositionQ" ->
    alignmentDepth === 4 && finalHRFGap === 1,
  "TargetVirtualitiesQ" ->
    targetVirtualities === {4, 4, 1, 4, 4, 4},
  "VertexFeasibleQ" -> And @@ Values[vertexFeasibility],
  "CandidateGlauberReroutingFoundQ" -> AssociationQ[glauberWitness],
  "CandidateGlauberCentralValueQ" -> AssociationQ[glauberWitness] &&
    glauberWitness["OptimizedComponentPowers"] === {2, 2, 0},
  "ContourPinchDepthVisibleQ" -> AssociationQ[glauberWitness] &&
    glauberWitness["NaiveComponentPowers"] === {2, -2, 0} &&
    glauberWitness["ForcedCancellationComponents"] === {"minus"}
|>;

result = <|
  "Status" -> If[And @@ Values[checks], "Passed", "Failed"],
  "CertificationLevel" -> "ValuationLevelEdgeFlowCandidate",
  "Checks" -> checks,
  "TotalScaling" -> AssociationThread[edgeVariables, totalScaling],
  "RawSuperleadingPower" -> rawSuperleadingPower,
  "RawSuperleadingCoefficient" -> rawSuperleadingCoefficient,
  "ScalefulLPWeight" -> scalefulLPWeight,
  "TotalCancellationDepth" -> totalCancellationDepth,
  "AlignmentDepth" -> alignmentDepth,
  "FinalHRFGap" -> finalHRFGap,
  "PropagatorVirtualityPowers" ->
    AssociationThread[edgeVariables, targetVirtualities],
  "EdgeComponentPowers" -> branch["EdgeComponentPowers"],
  "VirtualityRealizationTypes" -> branch["VirtualityTypes"],
  "IndependentEdgeBasisChoice" -> {x0, x3},
  "IndependentEdgeBasisPowers" -> <|
    x0 -> branch["EdgeComponentPowers"][x0],
    x3 -> branch["EdgeComponentPowers"][x3]
  |>,
  "VertexFeasibility" -> vertexFeasibility,
  "CandidateGlauberRerouting" -> <|
    "Combination" -> "q0-q4",
    "NaiveComponentPowers" ->
      If[AssociationQ[glauberWitness],
        glauberWitness["NaiveComponentPowers"], Missing["NoWitness"]],
    "PinchedComponentPowers" ->
      If[AssociationQ[glauberWitness],
        glauberWitness["OptimizedComponentPowers"], Missing["NoWitness"]],
    "ForcedCancellationComponents" ->
      If[AssociationQ[glauberWitness],
        glauberWitness["ForcedCancellationComponents"],
        Missing["NoWitness"]],
    "Interpretation" ->
      "The central value of the minus component improves from delta^-2 to delta^2.  This identifies a transverse-dominated affine rerouting, but does not yet determine its local fluctuation width."
  |>,
  "MethodologicalConclusion" ->
    "The total aligned-plus-HRF vector is required for the complete edge-flow table.  A mode-complete momentum region additionally requires coefficient-level local coordinates that distinguish the central value of a rerouted loop momentum from its integration widths."
|>;

Export[FileNameJoin[{base, "five_point_mrk_pinch_momentum_result.wl"}],
  result, "Package"];
Print[InputForm[result]];
If[result["Status"] =!= "Passed", Exit[1]];
