(* Created with the Wolfram Language : www.wolfram.com *)
<|"PhysicalKinematics" -> <|"AllOutgoingMomenta" -> 
    <|1 -> {-(1/Sqrt[1 - beta^2]), 0, 0, -(1/Sqrt[1 - beta^2])}, 
     2 -> {-(1/Sqrt[1 - beta^2]), 0, 0, 1/Sqrt[1 - beta^2]}, 
     3 -> {1/(2*Sqrt[1 - beta^2]), 1/2, beta/(2*Sqrt[1 - beta^2]), 0}, 
     6 -> {1/(2*Sqrt[1 - beta^2]), -1/2, beta/(2*Sqrt[1 - beta^2]), 0}, 
     5 -> {1/(2*Sqrt[1 - beta^2]), 3/10, -1/2*beta/Sqrt[1 - beta^2], 2/5}, 
     4 -> {1/(2*Sqrt[1 - beta^2]), -3/10, -1/2*beta/Sqrt[1 - beta^2], 
       -2/5}|>, "MassShellValues" -> <|1 -> 0, 2 -> 0, 3 -> 0, 6 -> 0, 
     5 -> 0, 4 -> 0|>, "AllMasslessQ" -> True, "MomentumSum" -> {0, 0, 0, 0}, 
   "MomentumConservationQ" -> True, "InvariantRulesInEta" -> 
    {s16 -> (-1 + eta)^(-1), s156 -> -1/5*(-6 + 4*Sqrt[1 - eta] + eta)/
        (-1 + eta), s23 -> (-1 + eta)^(-1), 
     s15 -> (5 - 4*Sqrt[1 - eta])/(5*(-1 + eta)), 
     s145 -> (1 + eta)/(-1 + eta), s36 -> 1, s45 -> 1, 
     s245 -> (1 + eta)/(-1 + eta), s24 -> (5 - 4*Sqrt[1 - eta])/
       (5*(-1 + eta))}, "CrossRatios" -> <|uA -> (-1 + eta)^2/(1 + eta)^2, 
     vA -> (-5 + 4*Sqrt[1 - eta])/((1 + eta)*(-6 + 4*Sqrt[1 - eta] + eta)), 
     wA -> (-5 + 4*Sqrt[1 - eta])/((1 + eta)*(-6 + 4*Sqrt[1 - eta] + eta))|>, 
   "SelfCrossingPathQ" -> True, "EndpointInvariantSigns" -> 
    <|s16 -> -1, s156 -> -1, s23 -> -1, s15 -> -1, s145 -> -1, s36 -> 1, 
     s45 -> 1, s245 -> -1, s24 -> -1|>, "EndpointRules" -> 
    {s16 -> -1, s156 -> -2/5, s23 -> -1, s15 -> -1/5, s145 -> -1, s36 -> 1, 
     s45 -> 1, s245 -> -1, s24 -> -1/5, x0 -> 0, x1 -> 1, x2 -> 1, x3 -> 0, 
     x4 -> 1, x5 -> 1}|>, "BoundaryLandauLocus" -> 
  <|"ContractedParameters" -> {x0, x3}, "BoundaryPolynomial" -> 
    s145*x1*x4 + s45*x2*x4 + s36*x1*x5 + s245*x2*x5, 
   "SelfCrossingCondition" -> s36*s45 == s145*s245, 
   "FactorizedBoundaryPolynomial" -> ((s36*x1 + s245*x2)*(s145*x4 + s36*x5))/
     s36, "FactorizationIdentityQ" -> True, "PositiveParameterWitness" -> 
    {x1 -> 1, x2 -> 1, x4 -> 1, x5 -> 1}, 
   "BoundaryGradientAtPhysicalWitness" -> {0, 0, 0, 0}, 
   "PositiveStationaryPinchQ" -> True|>, 
 "CoreHRF" -> <|"CancellationFactors" -> {x4 - x5, x1 - x2}, 
   "Generator" -> (x1 - x2)*(x4 - x5), "HiddenRegionQ" -> True, 
   "HiddenRegionCount" -> 1, "Scaling" -> {-1, -1, -1, -1}, "WSL" -> -2, 
   "WHR" -> -1, "SearchCompleteQ" -> True, "SearchTruncatedQ" -> False|>, 
 "PhysicalExpansion" -> <|"Parameter" -> eta == beta^2, 
   "F0" -> -(x0*x2) - (2*x0*x3)/5 - (x1*x3)/5 - x0*x4 - x1*x4 + x2*x4 + 
     x1*x5 - x2*x5 - (x3*x5)/5, "F1" -> -(x0*x2) - (3*x0*x3)/5 - 
     (3*x1*x3)/5 - x0*x4 - 2*x1*x4 - 2*x2*x5 - (3*x3*x5)/5, 
   "BoundaryF0" -> -((x1 - x2)*(x4 - x5)), "NormalCoordinates" -> 
    {t1 == x1 - x2, t2 == -x4 + x5}, "OriginalRegionVector" -> 
    {0, -1, -1, 0, -1, -1, 1}, "WSL" -> -2, "WHR" -> -1, 
   "ChartA" -> <|"LocalVariableOrder" -> {x0, x3, x2, x4, t1, t2}, 
     "LocalNormal" -> {0, 0, -1, -1, 0, -1, 1}, "FacetCertificate" -> 
      <|"MinimumWeight" -> -1, "LeadingRows" -> 
        {<|"Source" -> "P through eta^1", "Term" -> -(x0*x2), 
          "XRow" -> {1, 0, 1, 0, 0, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {1, 0, 1, 0, 0, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> -(x0*x4), 
          "XRow" -> {1, 0, 0, 1, 0, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {1, 0, 0, 1, 0, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> -1/5*(x2*x3), 
          "XRow" -> {0, 1, 1, 0, 0, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 1, 1, 0, 0, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> -1/5*(x3*x4), 
          "XRow" -> {0, 1, 0, 1, 0, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 1, 0, 1, 0, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> -1/5*(t2*x3), 
          "XRow" -> {0, 1, 0, 0, 0, 1}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 1, 0, 0, 0, 1, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> -4*eta*x2*x4, 
          "XRow" -> {0, 0, 1, 1, 0, 0}, "LambdaPower" -> 1, "Weight" -> -1, 
          "AugmentedRow" -> {0, 0, 1, 1, 0, 0, 1}|>, 
         <|"Source" -> "P through eta^1", "Term" -> -2*eta*t2*x2, 
          "XRow" -> {0, 0, 1, 0, 0, 1}, "LambdaPower" -> 1, "Weight" -> -1, 
          "AugmentedRow" -> {0, 0, 1, 0, 0, 1, 1}|>, 
         <|"Source" -> "P through eta^1", "Term" -> 2*x2, 
          "XRow" -> {0, 0, 1, 0, 0, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 0, 1, 0, 0, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> 2*x4, 
          "XRow" -> {0, 0, 0, 1, 0, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 0, 0, 1, 0, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> t1*t2, 
          "XRow" -> {0, 0, 0, 0, 1, 1}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 0, 0, 0, 1, 1, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> t2, 
          "XRow" -> {0, 0, 0, 0, 0, 1}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 0, 0, 0, 0, 1, 0}|>}, 
       "LeadingAugmentedRows" -> {{1, 0, 1, 0, 0, 0, 0}, {1, 0, 0, 1, 0, 0, 
        0}, {0, 1, 1, 0, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 0}, {0, 1, 0, 0, 0, 1, 
        0}, {0, 0, 1, 1, 0, 0, 1}, {0, 0, 1, 0, 0, 1, 1}, {0, 0, 1, 0, 0, 0, 
        0}, {0, 0, 0, 1, 0, 0, 0}, {0, 0, 0, 0, 1, 1, 0}, {0, 0, 0, 0, 0, 1, 
        0}}, "LeadingPointCount" -> 11, "AffineRank" -> 6, 
       "RequiredRank" -> 6, "NormalSpaceDimension" -> 1, 
       "NormalizedInwardNormal" -> {0, 0, -1, -1, 0, -1, 1}, 
       "CandidateNormal" -> {0, 0, -1, -1, 0, -1, 1}, "NormalAgreementQ" -> 
        True, "AllTermsAtOrAboveFacetQ" -> True, "LowerFacetCertifiedQ" -> 
        True|>|>, "ChartB" -> <|"LocalVariableOrder" -> 
      {x0, x3, x2, x4, t1, t2}, "LocalNormal" -> {0, 0, -1, -1, -1, 0, 1}, 
     "FacetCertificate" -> <|"MinimumWeight" -> -1, "LeadingRows" -> 
        {<|"Source" -> "P through eta^1", "Term" -> -(x0*x2), 
          "XRow" -> {1, 0, 1, 0, 0, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {1, 0, 1, 0, 0, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> -(x0*x4), 
          "XRow" -> {1, 0, 0, 1, 0, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {1, 0, 0, 1, 0, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> -1/5*(x2*x3), 
          "XRow" -> {0, 1, 1, 0, 0, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 1, 1, 0, 0, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> -1/5*(x3*x4), 
          "XRow" -> {0, 1, 0, 1, 0, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 1, 0, 1, 0, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> -1/5*(t1*x3), 
          "XRow" -> {0, 1, 0, 0, 1, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 1, 0, 0, 1, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> -4*eta*x2*x4, 
          "XRow" -> {0, 0, 1, 1, 0, 0}, "LambdaPower" -> 1, "Weight" -> -1, 
          "AugmentedRow" -> {0, 0, 1, 1, 0, 0, 1}|>, 
         <|"Source" -> "P through eta^1", "Term" -> 2*x2, 
          "XRow" -> {0, 0, 1, 0, 0, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 0, 1, 0, 0, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> -2*eta*t1*x4, 
          "XRow" -> {0, 0, 0, 1, 1, 0}, "LambdaPower" -> 1, "Weight" -> -1, 
          "AugmentedRow" -> {0, 0, 0, 1, 1, 0, 1}|>, 
         <|"Source" -> "P through eta^1", "Term" -> 2*x4, 
          "XRow" -> {0, 0, 0, 1, 0, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 0, 0, 1, 0, 0, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> t1*t2, 
          "XRow" -> {0, 0, 0, 0, 1, 1}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 0, 0, 0, 1, 1, 0}|>, 
         <|"Source" -> "P through eta^1", "Term" -> t1, 
          "XRow" -> {0, 0, 0, 0, 1, 0}, "LambdaPower" -> 0, "Weight" -> -1, 
          "AugmentedRow" -> {0, 0, 0, 0, 1, 0, 0}|>}, 
       "LeadingAugmentedRows" -> {{1, 0, 1, 0, 0, 0, 0}, {1, 0, 0, 1, 0, 0, 
        0}, {0, 1, 1, 0, 0, 0, 0}, {0, 1, 0, 1, 0, 0, 0}, {0, 1, 0, 0, 1, 0, 
        0}, {0, 0, 1, 1, 0, 0, 1}, {0, 0, 1, 0, 0, 0, 0}, {0, 0, 0, 1, 1, 0, 
        1}, {0, 0, 0, 1, 0, 0, 0}, {0, 0, 0, 0, 1, 1, 0}, {0, 0, 0, 0, 1, 0, 
        0}}, "LeadingPointCount" -> 11, "AffineRank" -> 6, 
       "RequiredRank" -> 6, "NormalSpaceDimension" -> 1, 
       "NormalizedInwardNormal" -> {0, 0, -1, -1, -1, 0, 1}, 
       "CandidateNormal" -> {0, 0, -1, -1, -1, 0, 1}, "NormalAgreementQ" -> 
        True, "AllTermsAtOrAboveFacetQ" -> True, "LowerFacetCertifiedQ" -> 
        True|>|>, "BothDissectionChartsCertifiedQ" -> True, 
   "HigherEtaLayersCannotUndercutFacetQ" -> True, 
   "HigherEtaLayerReason" -> "The LP polynomial is at most quadratic in edge \
parameters; every eta^n layer with n>=2 has weight at least zero for either \
chart, above WHR=-1.", "ScalarUnitIndexPower" -> -3 + Ddim/2, 
   "AtD4Minus2Epsilon" -> -1 - epsilon|>, 
 "Inheritance" -> <|"WideAngleFactors" -> {s36*x1 + s245*x2, 
     s145*x4 + s36*x5}, "NMRKLeadingFactors" -> 
    {(q1*q1b*X34h*(X45*X56h*y1 - y2 - X45*y2 - X45*X56h*y1*z - 
        X45*X56h*y1*zb + X45*X56h*y1*z*zb))/(etaN^3*(-1 + z)*(-1 + zb)), 
     -((q1*q1b*X56h*(y4 + X45*y4 - X34h*X45*y5))/etaN^3)}, 
   "NMRKExpectedFactors" -> 
    {-((q1*q1b*X34h*((1 + X45)*y2 - X45*X56h*y1*(1 - z)*(1 - zb)))/
       (etaN^3*(1 - z)*(1 - zb))), 
     -((q1*q1b*X56h*((1 + X45)*y4 - X34h*X45*y5))/etaN^3)}, 
   "NMRKFactorIdentitiesQ" -> {True, True}, "DSCLeadingFactors" -> 
    {-((tau1*y1 + y2 + tau1*y2)/(a*eps^2*(1 + tau1)*(1 + tau2))), 
     -((tau1*(y4 + tau2*y4 + y5))/(a*eps^2*(1 + tau1)*(1 + tau2)))}, 
   "DSCExpectedFactors" -> {-((tau1*y1 + (1 + tau1)*y2)/
       (a*eps^2*(1 + tau1)*(1 + tau2))), -((tau1*((1 + tau2)*y4 + y5))/
       (a*eps^2*(1 + tau1)*(1 + tau2)))}, "DSCFactorIdentitiesQ" -> 
    {True, True}, "BothLimitsInheritWideAngleFactorsQ" -> True|>, 
 "Conclusion" -> <|"WideAngleBoundaryHiddenRegionQ" -> True, 
   "CommonWideAngleSeedQ" -> True|>|>
