(* Scalar power counting for the certified representative central-soft MRK
   region, with the hard invariant s12 factored out.  This is the
   dimensionless convention in which the HRF vector diagnoses infrared
   virtualities relative to the growing hard scale. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
target = Import[FileNameJoin[{base,
  "targeted_seed_2_exact-soft-plus_1_2.wl"}], "WL"];
row = First[target["Scan", "HiddenRegionRows"]];
audit = row["TotalScalingAudit"];

vars = {x0, x1, x2, x3, x4, x5};
totalVector = Lookup[audit["TotalScaling"], vars];

(* Local cancellation coordinates in the original exact chart.  For
     A = P x2-K delta^3 x3,  B=x1 x4-x0 x5,
   the generic weights are wt(A)=-1 and wt(B)=-8.  The HRF gap restricts A
   by one additional power, wt(A)=0.  Solving for (x2,x5) gives Jacobian
   -1/(P x0), of weight +4 for the certified vector. *)
aNormalWeight = 0;
bNormalWeight = -8;
localTangentialWeights = {-4, -4, -4, -4};
localJacobianWeight = 4;
parameterMeasurePower = Total[localTangentialWeights] +
  aNormalWeight + bNormalWeight + localJacobianWeight;
lpWeight = audit["WHR"];
parameterIntegralPower = Expand[parameterMeasurePower - D lpWeight/2];

(* Exact routing used in the central-soft notebook:
     q0=r, q1=p1-r, q2=p3-ell, q3=ell+p2-p3,
     q4=r-ell, q5=p5-r+ell.
   The entries are powers of (q^+,q^-,|q_perp|). *)
edgeComponentPowers = <|
  x0 -> {4, 0, 2},
  x1 -> {4, 0, 2},
  x2 -> {0, 1, 2},
  x3 -> {3, 1, 2},
  x4 -> {4, 0, 2},
  x5 -> {4, 0, 2}
|>;
virtualityPower[{a_, b_, c_}] := Min[a + b, 2 c];
virtualityPowers = virtualityPower /@ edgeComponentPowers;

(* Local contour widths.  q0/q1 pinch r^+ at delta^2.  q4/q5 pinch
   ell^+ at delta^4.  q2/q3 pinch ell^- at delta^1.  Both transverse
   widths scale as delta^2 in hard-scale-normalized momenta. *)
rWidths = {4, 0, 2};
ellWidths = {4, 1, 2};
loopMeasurePower[{a_, b_, c_}] := a + b + (D - 2) c;
momentumMeasurePower = Expand[
  loopMeasurePower[rWidths] + loopMeasurePower[ellWidths]];
momentumIntegralPower = Expand[
  momentumMeasurePower - Total[Values[virtualityPowers]]];

checks = <|
  "IRVectorQ" -> totalVector === {-4, -4, -1, -4, -4, -4},
  "WeightsQ" -> audit["WSL"] === -9 && audit["WHR"] === -8,
  "ParameterMeasureQ" -> parameterMeasurePower === -20,
  "VirtualityPowersQ" -> Values[virtualityPowers] === {4, 4, 1, 4, 4, 4},
  "MomentumMeasureQ" -> momentumMeasurePower === 1 + 4 D,
  "CountsAgreeQ" -> parameterIntegralPower === -20 + 4 D &&
    momentumIntegralPower === -20 + 4 D
|>;

result = <|
  "Status" -> If[And @@ Values[checks], "Passed", "Failed"],
  "Checks" -> checks,
  "HardScaleNormalizedIRVector" -> totalVector,
  "Weights" -> {audit["WSL"], audit["WHR"]},
  "LocalCancellationCoordinates" -> <|
    "A" -> P x2 - K delta^3 x3,
    "B" -> x1 x4 - x0 x5,
    "Weights" -> <|"A" -> aNormalWeight, "B" -> bNormalWeight|>,
    "Jacobian" -> -1/(P x0),
    "JacobianWeight" -> localJacobianWeight
  |>,
  "ParameterMeasurePower" -> parameterMeasurePower,
  "ParameterIntegralPower" -> parameterIntegralPower,
  "EdgeComponentPowers" -> edgeComponentPowers,
  "PropagatorVirtualityPowers" -> virtualityPowers,
  "LoopWidths" -> <|"r=q0" -> rWidths, "ell" -> ellWidths|>,
  "Pinches" -> {
    <|"Component" -> "r+", "Edges" -> {x0, x1}, "Width" -> 4|>,
    <|"Component" -> "ell+", "Edges" -> {x4, x5}, "Width" -> 4|>,
    <|"Component" -> "ell-", "Edges" -> {x2, x3}, "Width" -> 1|>
  },
  "MomentumMeasurePower" -> momentumMeasurePower,
  "MomentumIntegralPower" -> momentumIntegralPower,
  "PowerAtD4Minus2Epsilon" ->
    Expand[momentumIntegralPower /. D -> 4 - 2 epsilon],
  "DimensionfulOverallS12Factor" -> s12^(D - 6),
  "FullDimensionfulPathPower" -> 4
|>;

Export[FileNameJoin[{base,
  "five_point_mrk_corrected_power_counting_result.wl"}], result, "Package"];
Print[InputForm[result]];
If[result["Status"] =!= "Passed", Exit[1]];
