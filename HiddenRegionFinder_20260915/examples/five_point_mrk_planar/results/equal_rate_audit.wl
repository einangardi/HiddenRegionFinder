<|"Rates" -> <|"PlanarityRateA" -> 1, "MRKRateB" -> 1|>, 
 "ExternalOrderAtVertices" -> {1, 2, 3, 5, 4}, 
 "KinematicRules" -> {s12 -> (Kp*Mm)/delta + (Mm*Pp)/delta^2 + 2*Q2 + 
     (Pp*Q2)/(delta*Kp) + (delta*Q2^2)/(Kp*Mm) + 2*Q2*(delta^2/4 + xi^(-2)) + 
     (delta*Kp*Q2*(delta^2/4 + xi^(-2)))/Pp + 
     (delta*Q2^2*(delta^2/4 + xi^(-2)))/(Kp*Mm) + 
     (delta^2*Q2^2*(delta^2/4 + xi^(-2)))/(Mm*Pp) + 
     (delta^2*Q2^2*(delta^2/4 + xi^(-2))^2)/(Mm*Pp) + (2*Q2)/xi + 
     (2*delta*Q2^2)/(Kp*Mm*xi) + (2*delta^2*Q2^2*(delta^2/4 + xi^(-2)))/
      (Mm*Pp*xi), s23 -> -(Q2*(delta^2/4 + xi^(-2))) - 
     (delta*Kp*Q2*(delta^2/4 + xi^(-2)))/Pp - 
     (delta^2*Q2^2*(delta^2/4 + xi^(-2)))/(Mm*Pp) - 
     (delta^2*Q2^2*(delta^2/4 + xi^(-2))^2)/(Mm*Pp) - 
     (2*delta^2*Q2^2*(delta^2/4 + xi^(-2)))/(Mm*Pp*xi), 
   s34 -> (Pp*Q2)/(delta*Kp) + (delta*Kp*Q2*(delta^2/4 + xi^(-2)))/Pp - 
     (2*Q2)/xi, s45 -> (Kp*Mm)/delta + 2*Q2 + (delta*Q2^2)/(Kp*Mm) + 
     (delta*Q2^2*(delta^2/4 + xi^(-2)))/(Kp*Mm) + (2*Q2)/xi + 
     (2*delta*Q2^2)/(Kp*Mm*xi), s15 -> -Q2 - (delta*Q2^2)/(Kp*Mm) - 
     Q2*(delta^2/4 + xi^(-2)) - (delta*Q2^2*(delta^2/4 + xi^(-2)))/(Kp*Mm) - 
     (delta^2*Q2^2*(delta^2/4 + xi^(-2)))/(Mm*Pp) - 
     (delta^2*Q2^2*(delta^2/4 + xi^(-2))^2)/(Mm*Pp) - (2*Q2)/xi - 
     (2*delta*Q2^2)/(Kp*Mm*xi) - (2*delta^2*Q2^2*(delta^2/4 + xi^(-2)))/
      (Mm*Pp*xi)}, "PositiveParameterAssumptions" -> 
  Pp > 0 && Kp > 0 && Mm > 0 && Q2 > 0 && xi > 0 && delta > 0, 
 "StandardMRKStatement" -> 
  "Both rapidity gaps grow as delta^(-b), with fixed transverse scales.", 
 "PlanarityStatement" -> 
  "w-wbar=i delta^a and Gamma5/s12^2=-Q2^2 delta^(2a).", 
 "InvariantCoefficients" -> <|"qAB" -> s12 - s34 - s45, 
   "qBC" -> -s12 - s23 + s45, "qCA" -> s23|>, 
 "StationaryRatios" -> 
  <|"rhoA" -> -1/2*(-(s12*s15) + s12*s23 - s23*s34 + s15*s45 - 2*s23*s45 - 
       s34*s45)/(s23*(s12 - s34 - s45)), 
   "rhoB" -> -1/2*(-(s12*s15) + s12*s23 - s23*s34 - 2*s12*s45 + s15*s45 - 
       2*s23*s45 + s34*s45 + 2*s45^2)/((s12 + s23 - s45)*(s12 - s34 - s45)), 
   "rhoC" -> -1/2*(-(s12*s15) + s12*s23 - 2*s15*s23 + 2*s23^2 + s23*s34 + 
       s15*s45 - 2*s23*s45 - s34*s45)/(s23*(s12 + s23 - s45))|>, 
 "StationaryRatioPowers" -> {0, 1, 0}, 
 "StationaryRatioLeadingCoefficients" -> {xi, Kp/Pp, xi}, 
 "QCoefficientPowers" -> {-2, -2, 0}, "QCoefficientLeadingCoefficients" -> 
  {Mm*Pp, -(Mm*Pp), -(Q2/xi^2)}, "Gamma5InChart" -> 
  -1/256*(Q2^2*(4*delta^2*Q2 + 8*delta^2*Q2*xi + 4*delta*Kp*Mm*xi^2 + 
       4*Mm*Pp*xi^2 + 4*delta^2*Q2*xi^2 + delta^4*Q2*xi^2)^2*
     (4*delta^2*Kp*Q2 + 4*Kp*Mm*Pp*xi^2 + delta^4*Kp*Q2*xi^2 + 
       4*delta*Pp*Q2*xi^2)^2)/(delta^2*Kp^2*Mm^2*Pp^2*xi^8), 
 "Gamma5IdentityQ" -> True, "InvariantStationaryDecompositionIdentityQ" -> 
  True, "LocalCoordinateRules" -> 
  {x0 -> nA - ((-(s12*s15) + s12*s23 - s23*s34 + s15*s45 - 2*s23*s45 - 
        s34*s45)*uA)/(2*s23*(s12 - s34 - s45)), x1 -> uA, 
   x2 -> nB - ((-(s12*s15) + s12*s23 - s23*s34 - 2*s12*s45 + s15*s45 - 
        2*s23*s45 + s34*s45 + 2*s45^2)*uB)/(2*(s12 + s23 - s45)*
       (s12 - s34 - s45)), x3 -> uB, 
   x4 -> nC - ((-(s12*s15) + s12*s23 - 2*s15*s23 + 2*s23^2 + s23*s34 + 
        s15*s45 - 2*s23*s45 - s34*s45)*uC)/(2*s23*(s12 + s23 - s45)), 
   x5 -> uC}, "OriginalCoordinateRegionVector" -> 
  {-2, -2, -1, -2, -2, -2, 1}, "LocalCoordinateRegionVector" -> 
  {-2, -2, -2, -1, 1, -1, 1}, "AlignmentVector" -> {-1, -1, 0, -1, -1, -1}, 
 "RelativeVectorOnAlignedFace" -> {-1, -1, -1, -1, -1, -1}, 
 "CompositionIdentityQ" -> True, "LayerWeights" -> 
  <|"ABAndBCBeforeCancellation" -> -7, "ACBeforeCancellation" -> -6, 
   "ResolvedHR" -> -4, "U" -> -4, "GramNormalTerm" -> -4|>, 
 "LeadingLocalLPPolynomial" -> 
  -1/4*(4*nA*nC*Q2*uB + 4*Mm*nB*nC*Pp*uA*xi^2 - 4*uA*uB*xi^2 - 
     4*Mm*nA*nB*Pp*uC*xi^2 - 4*uA*uC*xi^2 - 4*uB*uC*xi^2 - 4*uA*uB*xi^3 - 
     8*uA*uC*xi^3 - 4*uB*uC*xi^3 - 4*uA*uC*xi^4 + Q2*uA*uB*uC*xi^4)/xi^2, 
 "LeadingMonomialCount" -> 7, "LeadingAffineRank" -> 6, 
 "FullLowerFacetCertificateQ" -> True, "LocalMeasureWeight" -> -7, 
 "ScalarIntegralWeightBeforeSettingD" -> -7 + 2*dim, 
 "ScalarIntegralWeightAtD4Minus2Epsilon" -> 1 - 4*eps|>
