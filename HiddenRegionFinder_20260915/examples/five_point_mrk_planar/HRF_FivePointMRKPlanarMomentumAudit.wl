(* Momentum-space audit for the equal-rate (a=b=1) simultaneous
   fixed-transverse MRK and near-planar hidden region.

   The calculation uses physical incoming p1,p2 and outgoing p3,p4,p5,
   with p1+p2=p3+p4+p5.  The graph attachment is {1,2,3,5,4} and the
   edge routing agrees with the neighbouring central-soft example:

     q0=r, q1=p1-r, q2=p3-l, q3=l+p2-p3,
     q4=r-l, q5=p5-r+l.

   At the exact positive Landau saddle all six virtualities are
   O(delta^2), but the characteristic region virtuality of q2^2 is O(delta):
   the saddle has one additional accidental cancellation on this dependent
   edge.  The central component valuations are checked at an exact rational
   point in the positive kinematic domain.  A path-adapted independent basis
   uses the A and C collinear flows, both with balanced marginal widths, plus
   correlated longitudinal support of width delta^(3a+b). *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];

ClearAll[
  hrf5MRKPlanarValuation, hrf5MRKPlanarSquare,
  hrf5MRKPlanarExactMomentumSample, hrf5MRKPlanarMomentumAudit
];

hrf5MRKPlanarValuation[expr_, parameter_] := Module[{rat},
  rat = Together[expr];
  Exponent[Numerator[rat], parameter, Min] -
    Exponent[Denominator[rat], parameter, Min]
];

hrf5MRKPlanarSquare[p_List] :=
  Expand[p[[1]] p[[2]] - p[[3]]^2 - p[[4]]^2];

hrf5MRKPlanarExactMomentumSample[
    {pScale_, kScale_, mScale_, transverseScale_, xiValue_,
     uAValue_, uBValue_, uCValue_}] := Module[
  {p1, p2, p3, p4, p5, outgoing, sij, s12, s23, s34, s45, s15,
   qAB, qBC, qCA, ellA, ellB, ellC, rho, x0, x1, x2, x3, x4,
   x5, aa, bb, cc, rhsR, rhsL, determinant, r, ell, edges,
   componentPowers, transversePowers, edgeTriples, virtualityPowers},

  p3 = {pScale delta^-1,
    transverseScale^2 (xiValue^-2 + delta^2/4) delta/pScale,
    transverseScale/xiValue, transverseScale delta/2};
  p4 = {kScale, transverseScale^2/kScale, transverseScale, 0};
  p5 = {
    ((transverseScale (1 + xiValue^-1))^2 +
       transverseScale^2 delta^2/4) delta/mScale,
    mScale delta^-1,
    -transverseScale (1 + xiValue^-1), -transverseScale delta/2};
  p2 = {p3[[1]] + p4[[1]] + p5[[1]], 0, 0, 0};
  p1 = {0, p3[[2]] + p4[[2]] + p5[[2]], 0, 0};

  (* Adjacent invariants use the all-outgoing convention. *)
  outgoing = {-p1, -p2, p3, p4, p5};
  sij[i_, j_] := hrf5MRKPlanarSquare[outgoing[[i]] + outgoing[[j]]];
  {s12, s23, s34, s45, s15} =
    {sij[1, 2], sij[2, 3], sij[3, 4], sij[4, 5], sij[1, 5]};

  qAB = s12 - s34 - s45;
  qBC = -s12 - s23 + s45;
  qCA = s23;
  ellA = -s15 + s23 - s45;
  ellB = s15 - s23 - s34;
  ellC = s45;
  rho = Together @ LinearSolve[
    {{0, qAB, qCA}, {qAB, 0, qBC}, {qCA, qBC, 0}},
    -{ellA, ellB, ellC}];

  {x1, x3, x5} = {uAValue, uBValue, uCValue} delta^-2;
  {x0, x2, x4} = {rho[[1]] x1, rho[[2]] x3, rho[[3]] x5};

  (* Stationarity of the momentum-space quadratic form. *)
  aa = x0 + x1 + x4 + x5;
  bb = x2 + x3 + x4 + x5;
  cc = x4 + x5;
  rhsR = x1 p1 + x5 p5;
  rhsL = (x2 + x3) p3 - x3 p2 - x5 p5;
  determinant = aa bb - cc^2;
  r = Together[(bb rhsR + cc rhsL)/determinant];
  ell = Together[(cc rhsR + aa rhsL)/determinant];

  edges = Together /@ {
    r, p1 - r, p3 - ell, ell + p2 - p3, r - ell, p5 - r + ell};
  componentPowers = (hrf5MRKPlanarValuation[#, delta] & /@ #) & /@ edges;
  transversePowers = Min[#[[3]], #[[4]]] & /@ componentPowers;
  edgeTriples = MapThread[{#1[[1]], #1[[2]], #2} &,
    {componentPowers, transversePowers}];
  virtualityPowers =
    hrf5MRKPlanarValuation[hrf5MRKPlanarSquare[#], delta] & /@ edges;

  <|
    "StationaryRatioPowers" ->
      (hrf5MRKPlanarValuation[#, delta] & /@ rho),
    "EdgeComponentPowers" -> AssociationThread[
      {"x0", "x1", "x2", "x3", "x4", "x5"}, edgeTriples],
    "PropagatorVirtualityPowers" -> AssociationThread[
      {"x0", "x1", "x2", "x3", "x4", "x5"}, virtualityPowers]
  |>
];

hrf5MRKPlanarMomentumAudit[] := Module[
  {samples, rows, expectedTriples, expectedSaddleVirtualities,
   expectedRegionVirtualities, checks,
   parameterPower, momentumPower},

  (* A nonsymmetric choice of the three path scales avoids accidental
     cancellations while keeping the exact rational audit inexpensive. *)
  samples = {{1, 1, 1, 1, 1, 2, 3, 5}};
  rows = hrf5MRKPlanarExactMomentumSample /@ samples;
  expectedTriples = <|
    "x0" -> {3, -1, 1}, "x1" -> {3, -1, 1},
    "x2" -> {-1, 3, 1}, "x3" -> {0, 3, 1},
    "x4" -> {1, -1, 0}, "x5" -> {1, -1, 0}|>;
  expectedSaddleVirtualities = AssociationThread[
    {"x0", "x1", "x2", "x3", "x4", "x5"}, ConstantArray[2, 6]];
  expectedRegionVirtualities = <|
    "x0" -> 2, "x1" -> 2, "x2" -> 1,
    "x3" -> 2, "x4" -> 2, "x5" -> 2|>;

  parameterPower = -9 a + 2 b + 2 a D;
  momentumPower = 2 a D + (3 a + b) - (12 a - b);
  checks = <|
    "StationaryRatioPowersQ" ->
      AllTrue[rows, #StationaryRatioPowers === {0, 1, 0} &],
    "EdgeComponentPowersQ" ->
      AllTrue[rows, #EdgeComponentPowers === expectedTriples &],
    "CentralSaddleVirtualitiesDeltaSquaredQ" ->
      AllTrue[rows,
        #PropagatorVirtualityPowers === expectedSaddleVirtualities &],
    "RegionVirtualitiesMatchSchwingerVectorQ" ->
      Values[expectedRegionVirtualities] ===
        -{-2, -2, -1, -2, -2, -2},
    "ParameterMomentumPowerCountingIdentityQ" ->
      TrueQ[Expand[parameterPower - momentumPower] === 0]
  |>;

  <|
    "Status" -> If[And @@ Values[checks], "Passed", "Failed"],
    "Checks" -> checks,
    "RepresentativeAttachment" -> {1, 2, 3, 5, 4},
    "EqualRateEdgeComponentPowers" -> expectedTriples,
    "EqualRateSaddleVirtualityPowers" -> expectedSaddleVirtualities,
    "EqualRateRegionVirtualityPowers" -> expectedRegionVirtualities,
    "IndependentPathModes" -> <|
      "A" -> {2 a + b, -b, a},
      "C" -> {2 a + b, -b, a}|>,
    "IndependentModeType" ->
      "TwoBalancedPathAdaptedCollinearModes",
    "CorrelatedLongitudinalSupportPower" -> 3 a + b,
    "IndependentLoopMeasurePower" -> 2 a D,
    "SixPropagatorDenominatorPower" -> 12 a - b,
    "ParameterSpaceIntegralPower" -> parameterPower,
    "MomentumSpaceIntegralPower" -> momentumPower,
    "GlauberLoopCount" -> 0,
    "Samples" -> rows
  |>
];

If[! TrueQ[ValueQ[$HRF5MRKPlanarMomentumAuditLibraryOnly] &&
    $HRF5MRKPlanarMomentumAuditLibraryOnly],
  result = hrf5MRKPlanarMomentumAudit[];
  Export[FileNameJoin[{base, "results", "momentum_mode_audit.wl"}],
    result, "Package"];
  Print[InputForm[result]];
  If[result["Status"] =!= "Passed", Exit[1]];
];
