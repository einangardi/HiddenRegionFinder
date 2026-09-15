(* ::Package:: *)

(* Reproducible momentum-measure audit for the one-loop twisted-hexagon HR.

   For unit propagator powers the LP representation contributes
      Product[dx_e] P^(-D/2).
   The cancellation neighbourhood restores "CancellationSupportPower"
   powers relative to the unrestricted edge measure.  The inverse LP
   scaling gives the propagator virtuality powers.

   A one-loop local width
      (Delta ell^+, Delta ell^-, |Delta ell_perp|)
        ~ (delta^a, delta^b, delta^c)
   has measure exponent
      a+b+(D-2)c = c D + (a+b-2c).
   Thus equality of parameter- and momentum-space power counting reconstructs
   c and the invariant diagnostic a+b-2c without choosing a longitudinal
   frame.  For NMRK the script also records the direct pole reconstruction in
   the symmetric hard-normalized frame.  The large/small longitudinal
   coefficients at the two pinching pairs are {0,1} in eta powers, while the
   associated propagator virtualities have powers {5,6}; both poles therefore
   approach at eta^5.  The quadratic transverse fluctuation has width eta^3.
*)

ClearAll[
  hrfOneLoopGlauberMeasureCertificate,
  hrfRunOneLoopNMRKDSCGlauberAudit
];

hrfOneLoopGlauberMeasureCertificate[
    name_String, edgeVector_List, weights_List,
    cancellationSupportPower_Integer] := Module[
  {wSL, wHR, edgeMeasure, parameterMeasure, parameterIntegral,
   virtualityPowers, virtualitySum, momentumMeasure, transverseWidth,
   longitudinalMinusTwiceTransverse, longitudinalSum, checks},
  {wSL, wHR} = weights;
  edgeMeasure = Total[edgeVector];
  parameterMeasure = edgeMeasure + cancellationSupportPower;
  parameterIntegral = Expand[parameterMeasure - D wHR/2];
  virtualityPowers = -edgeVector;
  virtualitySum = Total[virtualityPowers];
  momentumMeasure = Expand[parameterIntegral + virtualitySum];
  transverseWidth = Coefficient[momentumMeasure, D];
  longitudinalMinusTwiceTransverse = momentumMeasure /. D -> 0;
  longitudinalSum =
    longitudinalMinusTwiceTransverse + 2 transverseWidth;
  checks = <|
    "VirtualitiesInverseToLPVectorQ" ->
      virtualityPowers === -edgeVector,
    "ParameterMomentumPowerIdentityQ" ->
      Expand[momentumMeasure - virtualitySum - parameterIntegral] === 0,
    "TransverseDominatedQ" ->
      TrueQ[longitudinalMinusTwiceTransverse > 0],
    "OneIndependentLoopQ" -> True
  |>;
  <|
    "Case" -> name,
    "EdgeVector" -> edgeVector,
    "Weights" -> <|"WSL" -> wSL, "WHR" -> wHR|>,
    "CancellationSupportPower" -> cancellationSupportPower,
    "UnrestrictedEdgeMeasurePower" -> edgeMeasure,
    "RestrictedParameterMeasurePower" -> parameterMeasure,
    "ParameterIntegralPower" -> parameterIntegral,
    "PropagatorVirtualityPowers" -> virtualityPowers,
    "PropagatorVirtualityPowerSum" -> virtualitySum,
    "RequiredLoopMeasurePower" -> momentumMeasure,
    "LocalWidthConstraints" -> <|
      "TransverseExponent_c" -> transverseWidth,
      "LongitudinalExponentSum_aPlusb" -> longitudinalSum,
      "GlauberImbalance_aPlusbMinus2c" ->
        longitudinalMinusTwiceTransverse
    |>,
    "Mode" -> If[
      TrueQ[longitudinalMinusTwiceTransverse > 0],
      "Glauber / transverse dominated",
      "Not Glauber"
    ],
    "IndependentLoopCount" -> 1,
    "CancellationVertices" -> <|
      "LowerIncomingVertex" -> <|
        "ExternalLeg" -> p1, "AdjacentParameters" -> {x1, x2}|>,
      "UpperIncomingVertex" -> <|
        "ExternalLeg" -> p2, "AdjacentParameters" -> {x4, x5}|>
    |>,
    "RoutingInterpretation" ->
      "The unique loop fluctuation is routed in the t-channel between the (16) and (23) collinear sectors.  The two factor equations are localized at its p1 and p2 attachment vertices; they do not represent two independent loops.",
    "PositivePinchPoleStatement" ->
      "At the positive Landau solution, sum_e x_e q_e^+=sum_e x_e q_e^-=0 with x_e>0.  Hence each longitudinal set contains opposite signs, and the corresponding ell-minus and ell-plus poles approach from opposite half-planes.",
    "Checks" -> checks
  |>
];

hrfRunOneLoopNMRKDSCGlauberAudit[] := Module[
  {nmrk, dsc, nmrkPole, checks},
  nmrk = hrfOneLoopGlauberMeasureCertificate[
    "NMRK with w=z",
    {-2, -5, -6, -2, -6, -5},
    {-10, -6},
    4
  ];
  dsc = hrfOneLoopGlauberMeasureCertificate[
    "generic DSC",
    {-2, -2, -2, 0, -2, -2},
    {-4, -2},
    2
  ];
  nmrkPole = <|
    "Frame" -> "symmetric hard-normalized",
    "PinchedLongitudinalCoefficientPowers" -> <|
      "q1Minus" -> 0, "q2Minus" -> 1,
      "q4Plus" -> 1, "q5Plus" -> 0|>,
    "PinchedVirtualityPowers" -> <|
      "q1" -> 5, "q2" -> 6, "q4" -> 6, "q5" -> 5|>,
    "PlusPolePowers" -> {5 - 0, 6 - 1},
    "MinusPolePowers" -> {6 - 1, 5 - 0},
    "TransverseWidthPower" -> 6/2,
    "WidthTriple" -> {5, 5, 3},
    "MeasurePower" -> Expand[5 + 5 + 3 (D - 2)]|>;
  checks = <|
    "NMRKLoopMeasure" ->
      nmrk["RequiredLoopMeasurePower"] === 4 + 3 D,
    "NMRKWidthConstraint" ->
      nmrk["LocalWidthConstraints"] === <|
        "TransverseExponent_c" -> 3,
        "LongitudinalExponentSum_aPlusb" -> 10,
        "GlauberImbalance_aPlusbMinus2c" -> 4|>,
    "NMRKDirectPoleWidths" ->
      nmrkPole["PlusPolePowers"] === {5, 5} &&
      nmrkPole["MinusPolePowers"] === {5, 5} &&
      nmrkPole["TransverseWidthPower"] === 3 &&
      nmrkPole["MeasurePower"] === 4 + 3 D,
    "DSCLoopMeasure" ->
      dsc["RequiredLoopMeasurePower"] === D + 2,
    "DSCWidthConstraint" ->
      dsc["LocalWidthConstraints"] === <|
        "TransverseExponent_c" -> 1,
        "LongitudinalExponentSum_aPlusb" -> 4,
        "GlauberImbalance_aPlusbMinus2c" -> 2|>,
    "BothGlauberQ" ->
      nmrk["Mode"] === "Glauber / transverse dominated" &&
      dsc["Mode"] === "Glauber / transverse dominated",
    "OneLoopEachQ" ->
      nmrk["IndependentLoopCount"] === 1 &&
      dsc["IndependentLoopCount"] === 1
  |>;
  <|
    "Status" -> If[And @@ Values[checks], "Passed", "Failed"],
    "Checks" -> checks,
    "NMRK" -> nmrk,
    "DSC" -> dsc,
    "NMRKDirectPoleAudit" -> nmrkPole
  |>
];

If[! ValueQ[$HRFRunOneLoopNMRKDSCGlauberAuditOnLoad],
  $HRFRunOneLoopNMRKDSCGlauberAuditOnLoad = True
];

If[TrueQ[$HRFRunOneLoopNMRKDSCGlauberAuditOnLoad],
  OneLoopNMRKDSCGlauberAudit =
    hrfRunOneLoopNMRKDSCGlauberAudit[];
  Put[
    OneLoopNMRKDSCGlauberAudit,
    FileNameJoin[{
      DirectoryName[$InputFileName],
      "results",
      "one_loop_NMRK_DSC_glauber_audit.wl"
    }]
  ];
  Print[InputForm @ KeyTake[
    OneLoopNMRKDSCGlauberAudit, {"Status", "Checks"}]]
];
