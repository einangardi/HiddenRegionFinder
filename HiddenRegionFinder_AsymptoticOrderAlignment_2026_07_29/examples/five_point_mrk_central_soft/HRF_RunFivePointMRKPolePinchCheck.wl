(* Coefficient-level l^+ pole-pinch certificate for the representative
   central-soft five-point MRK hidden region. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
Get[FileNameJoin[{base, "HRF_LightConePolePinch.wl"}]];
edgeResult = Get[FileNameJoin[{base,
  "five_point_mrk_pinch_momentum_result.wl"}]];

(* Exact momentum routing.  p1 and p2 are incoming; p3,p4,p5 are outgoing.
   The original chord basis is (q0,q3).  The mode-adapted affine basis is
       r=q0,  ell=q0-q4=q3+p3-p2.
*)
r = hrfLCMomentum[rPlus, rMinus, {rX, rY}];
ell = hrfLCMomentum[ellPlus, ellMinus, {ellX, ellY}];
p1v = hrfLCMomentum[0, p1Minus, {0, 0}];
p2v = hrfLCMomentum[p2Plus, 0, {0, 0}];
p3v = hrfLCMomentum[p3Plus, p3Minus, {p3X, p3Y}];
p5v = hrfLCMomentum[p5Plus, p5Minus, {p5X, p5Y}];

momenta = <|
  x0 -> r,
  x1 -> p1v - r,
  x2 -> p3v - ell,
  x3 -> ell + p2v - p3v,
  x4 -> r - ell,
  x5 -> p5v - r + ell
|>;
denominators = Map[hrfLCPropagator[#, eta] &, momenta];
poles = Map[hrfLCPole[#, ellPlus, eta] &, denominators];
rPlusPoles = Map[hrfLCPole[#, rPlus, eta] &, denominators];

(* Complete edge valuations from the certified total LP vector. *)
componentPowers = edgeResult["EdgeComponentPowers"];
virtualityPowers = edgeResult["PropagatorVirtualityPowers"];

(* q4 and q5 have minus components of order delta^-2 and virtualities of
   order delta^4.  Their approaching poles therefore restrict the local
   ell^+ width to delta^(4-(-2))=delta^6. *)
ellPlusWidth = virtualityPowers[x4] - componentPowers[x4][[2]];
rPlusWidth = virtualityPowers[x0] - componentPowers[x0][[2]];
sensitivityRows = Table[
  If[TrueQ[poles[edge]["DependsOnComponentQ"]],
    hrfLCPoleSensitivityRow[
      edge, componentPowers[edge][[2]], ellPlusWidth,
      virtualityPowers[edge]],
    <|
      "Edge" -> edge,
      "DependsOnEllPlusQ" -> False,
      "LeadingPinchSensitiveQ" -> False
    |>
  ],
  {edge, {x0, x1, x2, x3, x4, x5}}
];
activeEdges = Lookup[
  Select[sensitivityRows, TrueQ[# ["LeadingPinchSensitiveQ"]] &],
  "Edge"];

(* From q2=p3-ell, the resolved q2^- and q2_perp powers give the widths
   transverse to the l^+ contour pinch: Delta ell^-~delta^3 and
   Delta ell_perp~delta^2.  The central value of ell remains
   (delta^2,delta^2,1); the local widths are a different object. *)
ellCentralPowers = {2, 2, 0};
ellLocalWidths = {ellPlusWidth, componentPowers[x2][[2]],
  componentPowers[x2][[3]]};
rLocalWidths = componentPowers[x0];

rMeasurePower = hrfLCDimensionalMeasurePower[rLocalWidths, D];
ellMeasurePower = hrfLCDimensionalMeasurePower[ellLocalWidths, D];
totalMeasurePower = Expand[rMeasurePower + ellMeasurePower];
propagatorPower = Total[Values[virtualityPowers]];
momentumIntegralPower = Expand[totalMeasurePower - propagatorPower];

(* The two pole formulae are kept exactly.  On the physical positive-flow
   branch q4^-=r^--ell^->0 and q5^-=p5^--r^-+ell^->0.  Therefore the q4
   coefficient of ell^+ is negative and its pole is above the real axis;
   the q5 coefficient is positive and its pole is below. *)
polePair = <|
  "UpperHalfPlaneEdge" -> x4,
  "UpperPole" -> poles[x4]["Pole"],
  "LowerHalfPlaneEdge" -> x5,
  "LowerPole" -> poles[x5]["Pole"],
  "PhysicalSignAssumptions" ->
    {rMinus - ellMinus > 0, p5Minus - rMinus + ellMinus > 0},
  "PoleSeparationPower" -> ellPlusWidth
|>;
physicalHalfPlaneQ = FullSimplify[
  poles[x4]["ImaginaryCoefficient"] > 0 &&
    poles[x5]["ImaginaryCoefficient"] < 0,
  {rMinus - ellMinus > 0, p5Minus - rMinus + ellMinus > 0}
];
otherPolePair = <|
  "LowerHalfPlaneEdge" -> x0,
  "LowerPole" -> rPlusPoles[x0]["Pole"],
  "UpperHalfPlaneEdge" -> x1,
  "UpperPole" -> rPlusPoles[x1]["Pole"],
  "PhysicalSignAssumptions" ->
    {rMinus > 0, p1Minus - rMinus > 0},
  "PoleSeparationPower" -> rPlusWidth
|>;
otherHalfPlaneQ = FullSimplify[
  rPlusPoles[x0]["ImaginaryCoefficient"] < 0 &&
    rPlusPoles[x1]["ImaginaryCoefficient"] > 0,
  {rMinus > 0, p1Minus - rMinus > 0}
];

checks = <|
  "ExactlyTwoLeadingEllPlusPropagatorsQ" -> activeEdges === {x4, x5},
  "OppositeHalfPlanesOnPositiveFlowBranchQ" ->
    TrueQ[physicalHalfPlaneQ],
  "OtherLoopRPlusPinchQ" -> TrueQ[otherHalfPlaneQ] && rPlusWidth === 6,
  "EllPlusPinchWidthQ" -> ellPlusWidth === 6,
  "LocalGlauberWidthQ" -> ellLocalWidths === {6, 3, 2} &&
    ellLocalWidths[[1]] + ellLocalWidths[[2]] >
      2 ellLocalWidths[[3]],
  "MomentumMeasurePowerQ" -> totalMeasurePower === 5 + 4 D,
  "MomentumIntegralMatchesParameterPowerQ" ->
    momentumIntegralPower === -16 + 4 D
|>;

result = <|
  "Status" -> If[And @@ Values[checks], "Passed", "Failed"],
  "Checks" -> checks,
  "LoopRouting" -> <|
    "IndependentVariables" -> {"r=q0", "ell=q0-q4"},
    "EdgeMomenta" -> momenta
  |>,
  "Propagators" -> denominators,
  "EllPlusPoles" -> poles,
  "RPlusPoles" -> rPlusPoles,
  "EllPlusSensitivityRows" -> sensitivityRows,
  "LeadingEllPlusPinchEdges" -> activeEdges,
  "PolePair" -> polePair,
  "OtherLoopPolePair" -> otherPolePair,
  "EllCentralValuePowers" -> ellCentralPowers,
  "EllLocalFluctuationWidths" -> ellLocalWidths,
  "OtherLoopLocalFluctuationWidths" -> rLocalWidths,
  "OtherLoopMeasurePower" -> rMeasurePower,
  "GlauberLoopMeasurePower" -> ellMeasurePower,
  "TotalMomentumMeasurePower" -> totalMeasurePower,
  "PropagatorDenominatorPower" -> propagatorPower,
  "MomentumIntegralPower" -> momentumIntegralPower,
  "PowerAtD4Minus2Eps" ->
    Expand[momentumIntegralPower /. D -> 4 - 2 eps],
  "Conclusion" ->
    "The q4 and q5 poles pinch ell^+ with local width delta^6.  Together with the q2 residual constraints, ell has local widths (6,3,2) and is one genuine Glauber loop.  The other loop has widths (6,-2,2)."
|>;

Export[FileNameJoin[{base, "five_point_mrk_pole_pinch_result.wl"}],
  result, "Package"];
Print[InputForm[result]];
If[result["Status"] =!= "Passed", Exit[1]];
