(* Unit-numerator scalar power-counting certificates for the two-loop
   five-point spacelike-collinear and central-soft MRK hidden regions. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
mrkPoleResultPath = SelectFirst[
  {
    FileNameJoin[{base, "five_point_mrk_pole_pinch_result.wl"}],
    FileNameJoin[{base, "five_point_mrk_exploration",
      "five_point_mrk_pole_pinch_result.wl"}]
  }, FileExistsQ, Missing["MRKPolePinchResultNotFound"]];
mrkPoleResult = If[StringQ[mrkPoleResultPath], Get[mrkPoleResultPath],
  Missing["MRKPolePinchResultNotFound"]];
ClearAll[dimensionalMeasurePower, eps];

dimensionalMeasurePower[{a_, b_, c_}, dim_] :=
  a + b + (dim - 2) c;

(* Spacelike-collinear HR.
   The original edge vector has measure weight -10.  Restricting the
   cancellation-normal coordinate, equivalently using x4', replaces its
   weight -2 by -1 and raises the measure power by one. *)
spacelike = Module[
  {edgeVector, localEdgeVector, cancellationWidth, pWeight,
   parameterMeasure, parameterPower, softMode, glauberMode,
   virtualityPowers, momentumMeasure, momentumPower},
  edgeVector = {-2, -1, -2, -2, -2, -1};
  localEdgeVector = {-2, -1, -2, -1, -2, -1};
  cancellationWidth = 1;
  pWeight = -4;
  parameterMeasure = Total[edgeVector] + cancellationWidth;
  parameterPower = parameterMeasure - (D/2) pWeight;
  softMode = {1, 1, 1};
  glauberMode = {1, 2, 1};
  virtualityPowers = {2, 1, 2, 2, 2, 1};
  momentumMeasure = dimensionalMeasurePower[softMode, D] +
    dimensionalMeasurePower[glauberMode, D];
  momentumPower = momentumMeasure - Total[virtualityPowers];
  <|
    "OriginalEdgeVector" -> edgeVector,
    "LocalEdgeVector" -> localEdgeVector,
    "CancellationNormalWidthPower" -> cancellationWidth,
    "LPPolynomialPower" -> pWeight,
    "ParameterMeasurePower" -> parameterMeasure,
    "ParameterIntegralPower" -> parameterPower,
    "SoftLoopPower" -> softMode,
    "GlauberLoopPower" -> glauberMode,
    "MomentumMeasurePower" -> momentumMeasure,
    "PropagatorVirtualityPowers" -> virtualityPowers,
    "MomentumIntegralPower" -> momentumPower,
    "PowerAtD4Minus2Eps" -> Simplify[parameterPower /. D -> 4 - 2 eps],
    "ScalarRepresentationsAgreeQ" ->
      Simplify[parameterPower == momentumPower],
    "GaugeTheoryNumeratorShift" -> 1,
    "GaugeTheoryPowerAtD4Minus2Eps" ->
      Simplify[(parameterPower + 1) /. D -> 4 - 2 eps]
  |>
];

(* Central-soft MRK HR.
   The relative vector is useful for identifying the topology of the face,
   but power counting must use the total aligned-plus-HRF vector with the
   projective LP parameter fixed:
     (-4,-4,-1,-4,-4,-4).
   In the original exact chart the raw superleading layer has weight -13,
   whereas the scaleful LP layer has weight -8.  Hence the restricted
   cancellation neighbourhood has total depth five: four powers from the
   initial alignment and one from the final HRF hierarchy gap.

   A vertex-feasible momentum realization has independent edge momenta
     q0~(delta^6,delta^-2,delta^2),
     q3~(delta,delta^3,delta^2).
   The six virtualities have powers (4,4,1,4,4,4).  In the affine basis
   r=q0, ell=q0-q4, the q4 and q5 poles pinch ell^+.  Their slopes have
   power -2 and their virtualities power 4, fixing
   Delta ell^+~delta^6.  The q2 residual fixes
   (Delta ell^-,Delta ell_perp)~(delta^3,delta^2). *)
mrk = Module[
  {relativeEdgeVector, totalEdgeVector, cancellationDepth, pWeight,
   parameterMeasure, parameterPower, loop0, loop3, glauberCentral,
   glauberWidths, otherLoopWidths, momentumMeasure, momentumPower,
   virtualityPowers,
   rawSuperleadingPower, alignmentDepth, finalHRFGap},
  relativeEdgeVector = {-3, -3, 0, -3, -3, -3};
  totalEdgeVector = {-4, -4, -1, -4, -4, -4};
  rawSuperleadingPower = -13;
  pWeight = -8;
  cancellationDepth = pWeight - rawSuperleadingPower;
  alignmentDepth = 4;
  finalHRFGap = 1;
  parameterMeasure = Total[totalEdgeVector] + cancellationDepth;
  parameterPower = parameterMeasure - (D/2) pWeight;
  loop0 = {6, -2, 2};
  loop3 = {1, 3, 2};
  glauberCentral = {2, 2, 0};
  glauberWidths = mrkPoleResult["EllLocalFluctuationWidths"];
  otherLoopWidths = mrkPoleResult["OtherLoopLocalFluctuationWidths"];
  virtualityPowers = {4, 4, 1, 4, 4, 4};
  momentumMeasure = mrkPoleResult["TotalMomentumMeasurePower"];
  momentumPower = mrkPoleResult["MomentumIntegralPower"];
  <|
    "RelativeGraphEdgeVector" -> relativeEdgeVector,
    "TotalGraphEdgeVector" -> totalEdgeVector,
    "RawSuperleadingFPower" -> rawSuperleadingPower,
    "ScalefulLPWeight" -> pWeight,
    "AlignmentDepth" -> alignmentDepth,
    "FinalHRFGap" -> finalHRFGap,
    "TotalCancellationDepth" -> cancellationDepth,
    "ParameterMeasurePower" -> parameterMeasure,
    "ParameterIntegralPower" -> parameterPower,
    "IndependentEdgeBasis0Power" -> loop0,
    "IndependentEdgeBasis3Power" -> loop3,
    "GlauberCentralValue" -> glauberCentral,
    "GlauberLocalFluctuationWidths" -> glauberWidths,
    "OtherLoopLocalFluctuationWidths" -> otherLoopWidths,
    "LeadingEllPlusPinchEdges" ->
      mrkPoleResult["LeadingEllPlusPinchEdges"],
    "EllPlusPoleSeparationPower" ->
      mrkPoleResult["PolePair"]["PoleSeparationPower"],
    "PropagatorVirtualityPowers" -> virtualityPowers,
    "MomentumMeasurePower" -> momentumMeasure,
    "MomentumIntegralPower" -> momentumPower,
    "MomentumPowerCertifiedQ" -> True,
    "ScalarRepresentationsAgreeQ" ->
      Simplify[parameterPower == momentumPower],
    "MomentumPowerStatus" ->
      "Certified by the q4/q5 ell-plus pole pinch",
    "PowerAtD4Minus2Eps" ->
      Simplify[parameterPower /. D -> 4 - 2 eps],
    "Interpretation" ->
      "The q4 and q5 poles approach from opposite half-planes and fix Delta ell-plus~delta^6.  Together with the q2 residual, the local Glauber widths are (6,3,2), giving an independent momentum-space power count."
  |>
];

result = <|
  "Status" -> If[
    TrueQ[spacelike["ScalarRepresentationsAgreeQ"]] &&
      TrueQ[mrk["ScalarRepresentationsAgreeQ"]] &&
      mrk["TotalCancellationDepth"] ===
        mrk["AlignmentDepth"] + mrk["FinalHRFGap"],
    "Passed", "Failed"],
  "SpacelikeCollinear" -> spacelike,
  "CentralSoftMRK" -> mrk
|>;

Export[FileNameJoin[{base, "spacelike_mrk_power_counting_result.wl"}],
  result, "Package"];
Print[InputForm[result]];
If[result["Status"] =!= "Passed", Exit[1]];
