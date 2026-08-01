(* HRF_LightConePolePinch.wl

   Coefficient-level light-cone pole audit for a resolved momentum routing.
   The routines distinguish three pieces of data which must not be conflated:

     (1) the central value of a loop momentum;
     (2) its local integration widths about that value;
     (3) the propagators which depend on a selected component at leading
         power and therefore generate its contour pinch.

   Light-cone convention: q^2 = q^+ q^- - |q_perp|^2 and every Feynman
   denominator is q^2+i eta, eta->0^+.
*)

ClearAll[
  hrfLCMomentum, hrfLCPropagator, hrfLCPole,
  hrfLCPoleSensitivityRow, hrfLCDimensionalMeasurePower
];

hrfLCMomentum[plus_, minus_, transverse_List] :=
  {plus, minus, transverse};

hrfLCPropagator[{plus_, minus_, transverse_List}, eta_:eta] :=
  Expand[plus minus - transverse . transverse + I eta];

hrfLCPole[denominator_, variable_, eta_:eta] := Module[
  {coefficient, realPart, pole, imaginaryCoefficient},
  coefficient = Factor[Coefficient[denominator, variable]];
  If[TrueQ[coefficient === 0],
    Return[<|
      "DependsOnComponentQ" -> False,
      "Coefficient" -> 0,
      "Pole" -> Missing["NoPole"]
    |>]
  ];
  realPart = Expand[(denominator /. eta -> 0) /. variable -> 0];
  pole = Factor[-(realPart + I eta)/coefficient];
  imaginaryCoefficient = Factor[Coefficient[pole, eta]/I];
  <|
    "DependsOnComponentQ" -> True,
    "Coefficient" -> coefficient,
    "Pole" -> pole,
    "ImaginaryCoefficient" -> imaginaryCoefficient,
    "HalfPlaneRule" ->
      "For eta>0 the pole is upper if Coefficient<0 and lower if Coefficient>0."
  |>
];

(* If the coefficient of the selected loop component has valuation c, a
   local fluctuation of weight w enters the denominator with weight c+w.
   It is leading precisely when c+w equals the certified virtuality weight.
*)
hrfLCPoleSensitivityRow[
    edge_, coefficientPower_, fluctuationPower_, virtualityPower_] := Module[
  {inducedPower = coefficientPower + fluctuationPower},
  <|
    "Edge" -> edge,
    "CoefficientPower" -> coefficientPower,
    "LoopFluctuationPower" -> fluctuationPower,
    "InducedDenominatorPower" -> inducedPower,
    "VirtualityPower" -> virtualityPower,
    "LeadingPinchSensitiveQ" -> inducedPower === virtualityPower,
    "SubleadingInThisFluctuationQ" -> inducedPower > virtualityPower
  |>
];

hrfLCDimensionalMeasurePower[{plus_, minus_, transverse_}, dimension_] :=
  plus + minus + (dimension - 2) transverse;

