(* Mathematica 13.3 algebraic check. *)

ClearAll["Global`*"];

rho1234 = s12 s34/(s13 s24);
rho1432 = s14 s23/(s13 s24);

softDoubleCollinear = {
   s12 -> S,
   s13 -> xi S,
   s24 -> chi S,
   s14 -> chi S r e,
   s23 -> xi S (z zb/r) e,
   s34 -> xi chi S (1 - z e) (1 - zb e)
   };

softRhos = FullSimplify[
  {rho1234, rho1432} /. softDoubleCollinear
  ];

resolvedSum = FullSimplify[
  -Limit[(softRhos[[1]] - 1)/e, e -> 0]
  ];
resolvedProduct = FullSimplify[
  Limit[softRhos[[2]]/e^2, e -> 0]
  ];

sixPointLimitingRatios = {
   1/((1 - z) (1 - zb)),
   z zb/((1 - z) (1 - zb))
   };

reconstructedFromSoftNormalData = {
   1/(1 - resolvedSum + resolvedProduct),
   resolvedProduct/(1 - resolvedSum + resolvedProduct)
   };

reconstructionCheck = FullSimplify[
  sixPointLimitingRatios - reconstructedFromSoftNormalData
  ];

(*
  The same conformal path can be lifted to a single-collinear configuration.
  This records the different scaling of the two small-invariant factors.
*)
softSingleCollinear = {
   s12 -> S,
   s13 -> xi S,
   s24 -> chi S,
   s14 -> T,
   s23 -> xi chi S^2 (z zb/T) e^2,
   s34 -> xi chi S (1 - z e) (1 - zb e)
   };

singleRhos = FullSimplify[
  {rho1234, rho1432} /. softSingleCollinear
  ];

report = <|
  "KernelVersion" -> $Version,
  "SoftDoubleCollinearRhos" -> softRhos,
  "ResolvedSum" -> resolvedSum,
  "ResolvedProduct" -> resolvedProduct,
  "SixPointLimitingRatios" -> sixPointLimitingRatios,
  "ReconstructedFromSoftNormalData" -> reconstructedFromSoftNormalData,
  "ReconstructionCheck" -> reconstructionCheck,
  "SoftSingleCollinearRhos" -> singleRhos,
  "SameConformalPathQ" -> FullSimplify[singleRhos == softRhos],
  "InvariantScalingSingle" -> {s14 -> 0, s23 -> 2},
  "InvariantScalingDouble" -> {s14 -> 1, s23 -> 1}
  |>;

Print[InputForm[report]];

If[
  reconstructionCheck === {0, 0} &&
   TrueQ[FullSimplify[singleRhos == softRhos]],
  Exit[0],
  Exit[2]
  ];
