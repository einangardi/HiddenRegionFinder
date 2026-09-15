(* Created with the Wolfram Language : www.wolfram.com *)
<|"Status" -> "Passed", "Checks" -> 
  <|"ExactlyTwoLeadingEllPlusPropagatorsQ" -> True, 
   "OppositeHalfPlanesOnPositiveFlowBranchQ" -> True, 
   "OtherLoopRPlusPinchQ" -> True, "EllPlusPinchWidthQ" -> True, 
   "LocalGlauberWidthQ" -> True, "MomentumMeasurePowerQ" -> True, 
   "MomentumIntegralMatchesParameterPowerQ" -> True|>, 
 "LoopRouting" -> <|"IndependentVariables" -> {"r=q0", "ell=q0-q4"}, 
   "EdgeMomenta" -> <|x0 -> {rPlus, rMinus, {rX, rY}}, 
     x1 -> {-rPlus, p1Minus - rMinus, {-rX, -rY}}, 
     x2 -> {-ellPlus + p3Plus, -ellMinus + p3Minus, 
       {-ellX + p3X, -ellY + p3Y}}, x3 -> {ellPlus + p2Plus - p3Plus, 
       ellMinus - p3Minus, {ellX - p3X, ellY - p3Y}}, 
     x4 -> {-ellPlus + rPlus, -ellMinus + rMinus, {-ellX + rX, -ellY + rY}}, 
     x5 -> {ellPlus + p5Plus - rPlus, ellMinus + p5Minus - rMinus, 
       {ellX + p5X - rX, ellY + p5Y - rY}}|>|>, 
 "Propagators" -> <|x0 -> I*eta + rMinus*rPlus - rX^2 - rY^2, 
   x1 -> I*eta - p1Minus*rPlus + rMinus*rPlus - rX^2 - rY^2, 
   x2 -> ellMinus*ellPlus - ellX^2 - ellY^2 + I*eta - ellPlus*p3Minus - 
     ellMinus*p3Plus + p3Minus*p3Plus + 2*ellX*p3X - p3X^2 + 2*ellY*p3Y - 
     p3Y^2, x3 -> ellMinus*ellPlus - ellX^2 - ellY^2 + I*eta + 
     ellMinus*p2Plus - ellPlus*p3Minus - p2Plus*p3Minus - ellMinus*p3Plus + 
     p3Minus*p3Plus + 2*ellX*p3X - p3X^2 + 2*ellY*p3Y - p3Y^2, 
   x4 -> ellMinus*ellPlus - ellX^2 - ellY^2 + I*eta - ellPlus*rMinus - 
     ellMinus*rPlus + rMinus*rPlus + 2*ellX*rX - rX^2 + 2*ellY*rY - rY^2, 
   x5 -> ellMinus*ellPlus - ellX^2 - ellY^2 + I*eta + ellPlus*p5Minus + 
     ellMinus*p5Plus + p5Minus*p5Plus - 2*ellX*p5X - p5X^2 - 2*ellY*p5Y - 
     p5Y^2 - ellPlus*rMinus - p5Plus*rMinus - ellMinus*rPlus - 
     p5Minus*rPlus + rMinus*rPlus + 2*ellX*rX + 2*p5X*rX - rX^2 + 2*ellY*rY + 
     2*p5Y*rY - rY^2|>, "EllPlusPoles" -> 
  <|x0 -> <|"DependsOnComponentQ" -> False, "Coefficient" -> 0, 
     "Pole" -> Missing["NoPole"]|>, x1 -> <|"DependsOnComponentQ" -> False, 
     "Coefficient" -> 0, "Pole" -> Missing["NoPole"]|>, 
   x2 -> <|"DependsOnComponentQ" -> True, "Coefficient" -> 
      ellMinus - p3Minus, "Pole" -> (ellX^2 + ellY^2 - I*eta + 
        ellMinus*p3Plus - p3Minus*p3Plus - 2*ellX*p3X + p3X^2 - 2*ellY*p3Y + 
        p3Y^2)/(ellMinus - p3Minus), "ImaginaryCoefficient" -> 
      -(ellMinus - p3Minus)^(-1), "HalfPlaneRule" -> "For eta>0 the pole is \
upper if Coefficient<0 and lower if Coefficient>0."|>, 
   x3 -> <|"DependsOnComponentQ" -> True, "Coefficient" -> 
      ellMinus - p3Minus, "Pole" -> 
      -((-ellX^2 - ellY^2 + I*eta + ellMinus*p2Plus - p2Plus*p3Minus - 
         ellMinus*p3Plus + p3Minus*p3Plus + 2*ellX*p3X - p3X^2 + 2*ellY*p3Y - 
         p3Y^2)/(ellMinus - p3Minus)), "ImaginaryCoefficient" -> 
      -(ellMinus - p3Minus)^(-1), "HalfPlaneRule" -> "For eta>0 the pole is \
upper if Coefficient<0 and lower if Coefficient>0."|>, 
   x4 -> <|"DependsOnComponentQ" -> True, "Coefficient" -> ellMinus - rMinus, 
     "Pole" -> (ellX^2 + ellY^2 - I*eta + ellMinus*rPlus - rMinus*rPlus - 
        2*ellX*rX + rX^2 - 2*ellY*rY + rY^2)/(ellMinus - rMinus), 
     "ImaginaryCoefficient" -> -(ellMinus - rMinus)^(-1), 
     "HalfPlaneRule" -> "For eta>0 the pole is upper if Coefficient<0 and \
lower if Coefficient>0."|>, x5 -> <|"DependsOnComponentQ" -> True, 
     "Coefficient" -> ellMinus + p5Minus - rMinus, 
     "Pole" -> -((-ellX^2 - ellY^2 + I*eta + ellMinus*p5Plus + 
         p5Minus*p5Plus - 2*ellX*p5X - p5X^2 - 2*ellY*p5Y - p5Y^2 - 
         p5Plus*rMinus - ellMinus*rPlus - p5Minus*rPlus + rMinus*rPlus + 
         2*ellX*rX + 2*p5X*rX - rX^2 + 2*ellY*rY + 2*p5Y*rY - rY^2)/
        (ellMinus + p5Minus - rMinus)), "ImaginaryCoefficient" -> 
      -(ellMinus + p5Minus - rMinus)^(-1), "HalfPlaneRule" -> "For eta>0 the \
pole is upper if Coefficient<0 and lower if Coefficient>0."|>|>, 
 "RPlusPoles" -> <|x0 -> <|"DependsOnComponentQ" -> True, 
     "Coefficient" -> rMinus, "Pole" -> ((-I)*eta + rX^2 + rY^2)/rMinus, 
     "ImaginaryCoefficient" -> -rMinus^(-1), "HalfPlaneRule" -> "For eta>0 \
the pole is upper if Coefficient<0 and lower if Coefficient>0."|>, 
   x1 -> <|"DependsOnComponentQ" -> True, "Coefficient" -> -p1Minus + rMinus, 
     "Pole" -> (I*(eta + I*rX^2 + I*rY^2))/(p1Minus - rMinus), 
     "ImaginaryCoefficient" -> (p1Minus - rMinus)^(-1), 
     "HalfPlaneRule" -> "For eta>0 the pole is upper if Coefficient<0 and \
lower if Coefficient>0."|>, x2 -> <|"DependsOnComponentQ" -> False, 
     "Coefficient" -> 0, "Pole" -> Missing["NoPole"]|>, 
   x3 -> <|"DependsOnComponentQ" -> False, "Coefficient" -> 0, 
     "Pole" -> Missing["NoPole"]|>, x4 -> <|"DependsOnComponentQ" -> True, 
     "Coefficient" -> -ellMinus + rMinus, 
     "Pole" -> (ellMinus*ellPlus - ellX^2 - ellY^2 + I*eta - ellPlus*rMinus + 
        2*ellX*rX - rX^2 + 2*ellY*rY - rY^2)/(ellMinus - rMinus), 
     "ImaginaryCoefficient" -> (ellMinus - rMinus)^(-1), 
     "HalfPlaneRule" -> "For eta>0 the pole is upper if Coefficient<0 and \
lower if Coefficient>0."|>, x5 -> <|"DependsOnComponentQ" -> True, 
     "Coefficient" -> -ellMinus - p5Minus + rMinus, 
     "Pole" -> (ellMinus*ellPlus - ellX^2 - ellY^2 + I*eta + 
        ellPlus*p5Minus + ellMinus*p5Plus + p5Minus*p5Plus - 2*ellX*p5X - 
        p5X^2 - 2*ellY*p5Y - p5Y^2 - ellPlus*rMinus - p5Plus*rMinus + 
        2*ellX*rX + 2*p5X*rX - rX^2 + 2*ellY*rY + 2*p5Y*rY - rY^2)/
       (ellMinus + p5Minus - rMinus), "ImaginaryCoefficient" -> 
      (ellMinus + p5Minus - rMinus)^(-1), "HalfPlaneRule" -> "For eta>0 the \
pole is upper if Coefficient<0 and lower if Coefficient>0."|>|>, 
 "EllPlusSensitivityRows" -> {<|"Edge" -> x0, "DependsOnEllPlusQ" -> False, 
    "LeadingPinchSensitiveQ" -> False|>, <|"Edge" -> x1, 
    "DependsOnEllPlusQ" -> False, "LeadingPinchSensitiveQ" -> False|>, 
   <|"Edge" -> x2, "CoefficientPower" -> 3, "LoopFluctuationPower" -> 6, 
    "InducedDenominatorPower" -> 9, "VirtualityPower" -> 1, 
    "LeadingPinchSensitiveQ" -> False, "SubleadingInThisFluctuationQ" -> 
     True|>, <|"Edge" -> x3, "CoefficientPower" -> 3, 
    "LoopFluctuationPower" -> 6, "InducedDenominatorPower" -> 9, 
    "VirtualityPower" -> 4, "LeadingPinchSensitiveQ" -> False, 
    "SubleadingInThisFluctuationQ" -> True|>, 
   <|"Edge" -> x4, "CoefficientPower" -> -2, "LoopFluctuationPower" -> 6, 
    "InducedDenominatorPower" -> 4, "VirtualityPower" -> 4, 
    "LeadingPinchSensitiveQ" -> True, "SubleadingInThisFluctuationQ" -> 
     False|>, <|"Edge" -> x5, "CoefficientPower" -> -2, 
    "LoopFluctuationPower" -> 6, "InducedDenominatorPower" -> 4, 
    "VirtualityPower" -> 4, "LeadingPinchSensitiveQ" -> True, 
    "SubleadingInThisFluctuationQ" -> False|>}, 
 "LeadingEllPlusPinchEdges" -> {x4, x5}, 
 "PolePair" -> <|"UpperHalfPlaneEdge" -> x4, 
   "UpperPole" -> (ellX^2 + ellY^2 - I*eta + ellMinus*rPlus - rMinus*rPlus - 
      2*ellX*rX + rX^2 - 2*ellY*rY + rY^2)/(ellMinus - rMinus), 
   "LowerHalfPlaneEdge" -> x5, "LowerPole" -> 
    -((-ellX^2 - ellY^2 + I*eta + ellMinus*p5Plus + p5Minus*p5Plus - 
       2*ellX*p5X - p5X^2 - 2*ellY*p5Y - p5Y^2 - p5Plus*rMinus - 
       ellMinus*rPlus - p5Minus*rPlus + rMinus*rPlus + 2*ellX*rX + 2*p5X*rX - 
       rX^2 + 2*ellY*rY + 2*p5Y*rY - rY^2)/(ellMinus + p5Minus - rMinus)), 
   "PhysicalSignAssumptions" -> {-ellMinus + rMinus > 0, 
     ellMinus + p5Minus - rMinus > 0}, "PoleSeparationPower" -> 6|>, 
 "OtherLoopPolePair" -> <|"LowerHalfPlaneEdge" -> x0, 
   "LowerPole" -> ((-I)*eta + rX^2 + rY^2)/rMinus, 
   "UpperHalfPlaneEdge" -> x1, "UpperPole" -> (I*(eta + I*rX^2 + I*rY^2))/
     (p1Minus - rMinus), "PhysicalSignAssumptions" -> 
    {rMinus > 0, p1Minus - rMinus > 0}, "PoleSeparationPower" -> 6|>, 
 "EllCentralValuePowers" -> {2, 2, 0}, "EllLocalFluctuationWidths" -> 
  {6, 3, 2}, "OtherLoopLocalFluctuationWidths" -> {6, -2, 2}, 
 "OtherLoopMeasurePower" -> 4 + 2*(-2 + D), "GlauberLoopMeasurePower" -> 
  9 + 2*(-2 + D), "TotalMomentumMeasurePower" -> 5 + 4*D, 
 "PropagatorDenominatorPower" -> 21, "MomentumIntegralPower" -> -16 + 4*D, 
 "PowerAtD4Minus2Eps" -> -8*eps, "Conclusion" -> "The q4 and q5 poles pinch \
ell^+ with local width delta^6.  Together with the q2 residual constraints, \
ell has local widths (6,3,2) and is one genuine Glauber loop.  The other loop \
has widths (6,-2,2)."|>
