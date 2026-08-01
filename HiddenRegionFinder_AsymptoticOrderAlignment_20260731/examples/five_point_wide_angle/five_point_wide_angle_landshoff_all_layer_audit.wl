(* Created with the Wolfram Language : www.wolfram.com *)
<|"KinematicLimit" -> <|"OffShellness" -> p[i]^2 == lambdaOS, 
   "Limit" -> lambdaOS -> 0, "PhysicalInvariantDomain" -> 
    s12 > 0 && s34 > 0 && s45 > 0 && s23 < 0 && s15 < 0 && 
     s12 - s34 - s45 > 0 && -s12 - s23 + s45 < 0 && s15 - s23 - s34 < 0 && 
     -s15 + s23 - s45 < 0 && -s12 - s15 + s34 < 0, 
   "PhysicalInteriorGramSign" -> s12^2*s15^2 - 2*s12^2*s15*s23 + 
      s12^2*s23^2 + 2*s12*s15*s23*s34 - 2*s12*s23^2*s34 + s23^2*s34^2 - 
      2*s12*s15^2*s45 + 2*s12*s15*s23*s45 + 2*s12*s15*s34*s45 + 
      2*s12*s23*s34*s45 + 2*s15*s23*s34*s45 - 2*s23*s34^2*s45 + s15^2*s45^2 - 
      2*s15*s34*s45^2 + s34^2*s45^2 < 0, "ParityOddConvention" -> 
    epsilon5 == (4*I)*LeviCivita[p1, p2, p3, p4], 
   "GramConvention" -> s12^2*s15^2 - 2*s12^2*s15*s23 + s12^2*s23^2 + 
      2*s12*s15*s23*s34 - 2*s12*s23^2*s34 + s23^2*s34^2 - 2*s12*s15^2*s45 + 
      2*s12*s15*s23*s45 + 2*s12*s15*s34*s45 + 2*s12*s23*s34*s45 + 
      2*s15*s23*s34*s45 - 2*s23*s34^2*s45 + s15^2*s45^2 - 2*s15*s34*s45^2 + 
      s34^2*s45^2 == epsilon5^2, "PhysicalOrientationBranch" -> 
    (-I)*epsilon5 > 0, "EndpointCondition" -> 
    s12^2*s15^2 - 2*s12^2*s15*s23 + s12^2*s23^2 + 2*s12*s15*s23*s34 - 
      2*s12*s23^2*s34 + s23^2*s34^2 - 2*s12*s15^2*s45 + 2*s12*s15*s23*s45 + 
      2*s12*s15*s34*s45 + 2*s12*s23*s34*s45 + 2*s15*s23*s34*s45 - 
      2*s23*s34^2*s45 + s15^2*s45^2 - 2*s15*s34*s45^2 + s34^2*s45^2 == 0, 
   "PhysicalCoplanarBranch" -> qk2 == 2*kTrans*qTrans|>, 
 "Graph" -> <|"ExternalOrderAtVertices" -> {1, 2, 3, 5, 4}, 
   "InternalLines" -> {{"0", {1, 3}}, {"0", {1, 5}}, {"0", {2, 3}}, 
     {"0", {2, 5}}, {"0", {3, 4}}, {"0", {4, 5}}}, 
   "ExternalLines" -> {{p1, 1}, {p2, 2}, {p3, 3}, {p5, 4}, {p4, 5}}, 
   "Variables" -> {x0, x1, x2, x3, x4, x5}, 
   "U" -> x0*x2 + x1*x2 + x0*x3 + x1*x3 + x0*x4 + x1*x4 + x2*x4 + x3*x4 + 
     x0*x5 + x1*x5 + x2*x5 + x3*x5, "FOffShell" -> 
    lambdaOS*x0*x1*x2 + lambdaOS*x0*x1*x3 + lambdaOS*x0*x2*x3 + 
     lambdaOS*x1*x2*x3 + lambdaOS*x0*x1*x4 + lambdaOS*x0*x2*x4 + 
     3*lambdaOS*x1*x2*x4 - s12*x1*x2*x4 - s23*x1*x2*x4 + s45*x1*x2*x4 + 
     s23*x0*x3*x4 + s45*x1*x3*x4 + lambdaOS*x2*x3*x4 + lambdaOS*x0*x1*x5 + 
     3*lambdaOS*x0*x2*x5 + s12*x0*x2*x5 - s34*x0*x2*x5 - s45*x0*x2*x5 + 
     3*lambdaOS*x1*x2*x5 + s15*x1*x2*x5 - s23*x1*x2*x5 - s34*x1*x2*x5 + 
     3*lambdaOS*x0*x3*x5 - s15*x0*x3*x5 + s23*x0*x3*x5 - s45*x0*x3*x5 + 
     lambdaOS*x1*x3*x5 + lambdaOS*x2*x3*x5 + lambdaOS*x0*x4*x5 + 
     lambdaOS*x1*x4*x5 + lambdaOS*x2*x4*x5 + lambdaOS*x3*x4*x5, 
   "F0" -> -(s12*x1*x2*x4) - s23*x1*x2*x4 + s45*x1*x2*x4 + s23*x0*x3*x4 + 
     s45*x1*x3*x4 + s12*x0*x2*x5 - s34*x0*x2*x5 - s45*x0*x2*x5 + 
     s15*x1*x2*x5 - s23*x1*x2*x5 - s34*x1*x2*x5 - s15*x0*x3*x5 + 
     s23*x0*x3*x5 - s45*x0*x3*x5|>, "LandauLocus" -> 
  <|"LocalCoordinateRules" -> 
    {x0 -> (aPlus*kTrans*(kTrans^2 + bPlus*mMinus + kTrans*qTrans)*x1)/
        (bPlus*qTrans*(aPlus*mMinus + kTrans*qTrans + qTrans^2)) + y0, 
     x2 -> ((kTrans^2 + bPlus*mMinus + kTrans*qTrans)*x3)/
        (aPlus*mMinus + kTrans*qTrans + qTrans^2) + y2, 
     x4 -> (kTrans*x5)/qTrans + y4}, "InternalCoordinates" -> {x1, x3, x5}, 
   "NormalCoordinates" -> {y0, y2, y4}, "ClearedOriginalNormalPolynomials" -> 
    {aPlus*bPlus*mMinus*qTrans*x0 + bPlus*kTrans*qTrans^2*x0 + 
      bPlus*qTrans^3*x0 - aPlus*kTrans^3*x1 - aPlus*bPlus*kTrans*mMinus*x1 - 
      aPlus*kTrans^2*qTrans*x1, aPlus*mMinus*x2 + kTrans*qTrans*x2 + 
      qTrans^2*x2 - kTrans^2*x3 - bPlus*mMinus*x3 - kTrans*qTrans*x3, 
     qTrans*x4 - kTrans*x5}, "NormalPolynomialPullback" -> 
    {bPlus*qTrans*(aPlus*mMinus + kTrans*qTrans + qTrans^2)*y0, 
     (aPlus*mMinus + kTrans*qTrans + qTrans^2)*y2, qTrans*y4}, 
   "NormalClearingFactors" -> {bPlus*qTrans*(aPlus*mMinus + kTrans*qTrans + 
       qTrans^2), aPlus*mMinus + kTrans*qTrans + qTrans^2, qTrans}, 
   "LandauIdeal" -> {y0, y2, y4}, "PositiveLandauSolution" -> 
    <|"ExternalOrderAtVertices" -> {1, 2, 3, 5, 4}, 
     "CoplanarLightConeChart" -> 
      {s12 -> 2*kTrans^2 + (aPlus*kTrans^2)/bPlus + kTrans^4/(bPlus*mMinus) + 
         aPlus*mMinus + bPlus*mMinus + 2*kTrans*qTrans + 
         (2*kTrans^3*qTrans)/(bPlus*mMinus) + 2*qTrans^2 + 
         (bPlus*qTrans^2)/aPlus + (kTrans^2*qTrans^2)/(aPlus*mMinus) + 
         (kTrans^2*qTrans^2)/(bPlus*mMinus) + (2*kTrans*qTrans^3)/
          (aPlus*mMinus) + qTrans^4/(aPlus*mMinus), 
       s23 -> -qTrans^2 - (bPlus*qTrans^2)/aPlus - (kTrans^2*qTrans^2)/
          (aPlus*mMinus) - (2*kTrans*qTrans^3)/(aPlus*mMinus) - 
         qTrans^4/(aPlus*mMinus), s34 -> (aPlus*kTrans^2)/bPlus - 
         2*kTrans*qTrans + (bPlus*qTrans^2)/aPlus, 
       s45 -> 2*kTrans^2 + kTrans^4/(bPlus*mMinus) + bPlus*mMinus + 
         2*kTrans*qTrans + (2*kTrans^3*qTrans)/(bPlus*mMinus) + 
         (kTrans^2*qTrans^2)/(bPlus*mMinus), 
       s15 -> -kTrans^2 - kTrans^4/(bPlus*mMinus) - 2*kTrans*qTrans - 
         (2*kTrans^3*qTrans)/(bPlus*mMinus) - qTrans^2 - 
         (kTrans^2*qTrans^2)/(aPlus*mMinus) - (kTrans^2*qTrans^2)/
          (bPlus*mMinus) - (2*kTrans*qTrans^3)/(aPlus*mMinus) - 
         qTrans^4/(aPlus*mMinus)}, "LandauSolution" -> 
      {x0 -> (aPlus*kTrans*(kTrans^2 + bPlus*mMinus + kTrans*qTrans)*x1)/
         (bPlus*qTrans*(aPlus*mMinus + kTrans*qTrans + qTrans^2)), 
       x2 -> ((kTrans^2 + bPlus*mMinus + kTrans*qTrans)*x3)/
         (aPlus*mMinus + kTrans*qTrans + qTrans^2), x4 -> kTrans/qTrans, 
       x5 -> 1}, "PositiveParameterAssumptions" -> aPlus > 0 && bPlus > 0 && 
       mMinus > 0 && qTrans > 0 && kTrans > 0 && x1 > 0 && x3 > 0, 
     "F0OnSolution" -> 0, "GradientOnSolution" -> {0, 0, 0, 0, 0, 0}, 
     "LandauIdentityQ" -> True|>, "Jacobian" -> 1|>, 
 "AllLayerDecomposition" -> 
  <|"F0Local" -> (aPlus^2*bPlus*mMinus^2*x5*y0*y2 + 2*aPlus*bPlus*kTrans*
       mMinus*qTrans*x5*y0*y2 + bPlus*kTrans^2*qTrans^2*x5*y0*y2 + 
      2*aPlus*bPlus*mMinus*qTrans^2*x5*y0*y2 + 2*bPlus*kTrans*qTrans^3*x5*y0*
       y2 + bPlus*qTrans^4*x5*y0*y2 - bPlus*kTrans^2*qTrans^2*x3*y0*y4 - 
      aPlus*bPlus*mMinus*qTrans^2*x3*y0*y4 - bPlus^2*mMinus*qTrans^2*x3*y0*
       y4 - 2*bPlus*kTrans*qTrans^3*x3*y0*y4 - bPlus*qTrans^4*x3*y0*y4 - 
      aPlus^2*kTrans^2*mMinus*x1*y2*y4 - aPlus^2*bPlus*mMinus^2*x1*y2*y4 - 
      aPlus*bPlus*mMinus*qTrans^2*x1*y2*y4)/(aPlus*bPlus*mMinus), 
   "F0NormalDegreeSupport" -> {2}, "F0InSquareOfLandauIdealQ" -> True, 
   "PairProductCoefficients" -> 
    <|"y0 y2" -> ((aPlus*mMinus + kTrans*qTrans + qTrans^2)^2*x5)/
       (aPlus*mMinus), "y0 y4" -> 
      -((qTrans^2*(kTrans^2 + aPlus*mMinus + bPlus*mMinus + 2*kTrans*qTrans + 
          qTrans^2)*x3)/(aPlus*mMinus)), "y2 y4" -> 
      -(((aPlus*kTrans^2 + aPlus*bPlus*mMinus + bPlus*qTrans^2)*x1)/bPlus)|>, 
   "FactorizedLocalHRFGenerators" -> {y0*y2, y0*y4, y2*y4}, 
   "FactorizedOriginalHRFGenerators" -> 
    {-((aPlus*bPlus*mMinus*qTrans*x0 + bPlus*kTrans*qTrans^2*x0 + 
        bPlus*qTrans^3*x0 - aPlus*kTrans^3*x1 - aPlus*bPlus*kTrans*mMinus*
         x1 - aPlus*kTrans^2*qTrans*x1)*(-(aPlus*mMinus*x2) - 
        kTrans*qTrans*x2 - qTrans^2*x2 + kTrans^2*x3 + bPlus*mMinus*x3 + 
        kTrans*qTrans*x3)), (aPlus*bPlus*mMinus*qTrans*x0 + 
       bPlus*kTrans*qTrans^2*x0 + bPlus*qTrans^3*x0 - aPlus*kTrans^3*x1 - 
       aPlus*bPlus*kTrans*mMinus*x1 - aPlus*kTrans^2*qTrans*x1)*
      (qTrans*x4 - kTrans*x5), -((aPlus*mMinus*x2 + kTrans*qTrans*x2 + 
        qTrans^2*x2 - kTrans^2*x3 - bPlus*mMinus*x3 - kTrans*qTrans*x3)*
       (-(qTrans*x4) + kTrans*x5))}, "OriginalGeneratorMultipliers" -> 
    {x5/(aPlus*bPlus*mMinus*qTrans), 
     -(((kTrans^2 + aPlus*mMinus + bPlus*mMinus + 2*kTrans*qTrans + qTrans^2)*
        x3)/(aPlus*bPlus*mMinus*(aPlus*mMinus + kTrans*qTrans + qTrans^2))), 
     -(((aPlus*kTrans^2 + aPlus*bPlus*mMinus + bPlus*qTrans^2)*x1)/
       (bPlus*qTrans*(aPlus*mMinus + kTrans*qTrans + qTrans^2)))}, 
   "OriginalGeneratorDecompositionIdentityQ" -> True, 
   "OriginalF0MultiAffineQ" -> True, "DressedWideAngleBinomial" -> 
    (kTrans*(aPlus*kTrans^2*x1*x4 + aPlus*bPlus*mMinus*x1*x4 + 
       aPlus*kTrans*qTrans*x1*x4 - aPlus*bPlus*mMinus*x0*x5 - 
       bPlus*kTrans*qTrans*x0*x5 - bPlus*qTrans^2*x0*x5))/
     (bPlus*qTrans*(aPlus*mMinus + kTrans*qTrans + qTrans^2)), 
   "DressedWideAngleBinomialPullback" -> 
    -((kTrans*(aPlus*bPlus*mMinus*x5*y0 + bPlus*kTrans*qTrans*x5*y0 + 
        bPlus*qTrans^2*x5*y0 - aPlus*kTrans^2*x1*y4 - aPlus*bPlus*mMinus*x1*
         y4 - aPlus*kTrans*qTrans*x1*y4))/(bPlus*qTrans*
       (aPlus*mMinus + kTrans*qTrans + qTrans^2))), 
   "ULocal" -> (aPlus*kTrans^5*qTrans*x1*x3 + aPlus^2*kTrans^3*mMinus*qTrans*
       x1*x3 + 2*aPlus*bPlus*kTrans^3*mMinus*qTrans*x1*x3 + 
      aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1*x3 + aPlus*bPlus^2*kTrans*
       mMinus^2*qTrans*x1*x3 + 3*aPlus*kTrans^4*qTrans^2*x1*x3 + 
      aPlus^2*kTrans^2*mMinus*qTrans^2*x1*x3 + 4*aPlus*bPlus*kTrans^2*mMinus*
       qTrans^2*x1*x3 + aPlus^2*bPlus*mMinus^2*qTrans^2*x1*x3 + 
      aPlus*bPlus^2*mMinus^2*qTrans^2*x1*x3 + 3*aPlus*kTrans^3*qTrans^3*x1*
       x3 + bPlus*kTrans^3*qTrans^3*x1*x3 + 4*aPlus*bPlus*kTrans*mMinus*
       qTrans^3*x1*x3 + bPlus^2*kTrans*mMinus*qTrans^3*x1*x3 + 
      aPlus*kTrans^2*qTrans^4*x1*x3 + 3*bPlus*kTrans^2*qTrans^4*x1*x3 + 
      2*aPlus*bPlus*mMinus*qTrans^4*x1*x3 + bPlus^2*mMinus*qTrans^4*x1*x3 + 
      3*bPlus*kTrans*qTrans^5*x1*x3 + bPlus*qTrans^6*x1*x3 + 
      aPlus^2*kTrans^4*mMinus*x1*x5 + aPlus^2*bPlus*kTrans^2*mMinus^2*x1*x5 + 
      aPlus*kTrans^5*qTrans*x1*x5 + 2*aPlus^2*kTrans^3*mMinus*qTrans*x1*x5 + 
      aPlus*bPlus*kTrans^3*mMinus*qTrans*x1*x5 + 2*aPlus^2*bPlus*kTrans*
       mMinus^2*qTrans*x1*x5 + 3*aPlus*kTrans^4*qTrans^2*x1*x5 + 
      aPlus^2*kTrans^2*mMinus*qTrans^2*x1*x5 + 4*aPlus*bPlus*kTrans^2*mMinus*
       qTrans^2*x1*x5 + aPlus^2*bPlus*mMinus^2*qTrans^2*x1*x5 + 
      3*aPlus*kTrans^3*qTrans^3*x1*x5 + bPlus*kTrans^3*qTrans^3*x1*x5 + 
      5*aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*x5 + aPlus*kTrans^2*qTrans^4*x1*
       x5 + 3*bPlus*kTrans^2*qTrans^4*x1*x5 + 2*aPlus*bPlus*mMinus*qTrans^4*
       x1*x5 + 3*bPlus*kTrans*qTrans^5*x1*x5 + bPlus*qTrans^6*x1*x5 + 
      aPlus*bPlus*kTrans^3*mMinus*qTrans*x3*x5 + aPlus^2*bPlus*kTrans*
       mMinus^2*qTrans*x3*x5 + aPlus*bPlus^2*kTrans*mMinus^2*qTrans*x3*x5 + 
      bPlus*kTrans^4*qTrans^2*x3*x5 + 4*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*
       x3*x5 + bPlus^2*kTrans^2*mMinus*qTrans^2*x3*x5 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*x3*x5 + aPlus*bPlus^2*mMinus^2*qTrans^2*
       x3*x5 + 4*bPlus*kTrans^3*qTrans^3*x3*x5 + 5*aPlus*bPlus*kTrans*mMinus*
       qTrans^3*x3*x5 + 2*bPlus^2*kTrans*mMinus*qTrans^3*x3*x5 + 
      6*bPlus*kTrans^2*qTrans^4*x3*x5 + 2*aPlus*bPlus*mMinus*qTrans^4*x3*x5 + 
      bPlus^2*mMinus*qTrans^4*x3*x5 + 4*bPlus*kTrans*qTrans^5*x3*x5 + 
      bPlus*qTrans^6*x3*x5 + aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x3*y0 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*x3*y0 + aPlus*bPlus^2*mMinus^2*qTrans^2*
       x3*y0 + bPlus*kTrans^3*qTrans^3*x3*y0 + 3*aPlus*bPlus*kTrans*mMinus*
       qTrans^3*x3*y0 + bPlus^2*kTrans*mMinus*qTrans^3*x3*y0 + 
      3*bPlus*kTrans^2*qTrans^4*x3*y0 + 2*aPlus*bPlus*mMinus*qTrans^4*x3*y0 + 
      bPlus^2*mMinus*qTrans^4*x3*y0 + 3*bPlus*kTrans*qTrans^5*x3*y0 + 
      bPlus*qTrans^6*x3*y0 + aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x5*y0 + 
      2*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x5*y0 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*x5*y0 + bPlus*kTrans^3*qTrans^3*x5*y0 + 
      4*aPlus*bPlus*kTrans*mMinus*qTrans^3*x5*y0 + 3*bPlus*kTrans^2*qTrans^4*
       x5*y0 + 2*aPlus*bPlus*mMinus*qTrans^4*x5*y0 + 
      3*bPlus*kTrans*qTrans^5*x5*y0 + bPlus*qTrans^6*x5*y0 + 
      aPlus^2*kTrans^3*mMinus*qTrans*x1*y2 + aPlus^2*bPlus*kTrans*mMinus^2*
       qTrans*x1*y2 + aPlus*kTrans^4*qTrans^2*x1*y2 + 
      aPlus^2*kTrans^2*mMinus*qTrans^2*x1*y2 + aPlus*bPlus*kTrans^2*mMinus*
       qTrans^2*x1*y2 + aPlus^2*bPlus*mMinus^2*qTrans^2*x1*y2 + 
      2*aPlus*kTrans^3*qTrans^3*x1*y2 + 3*aPlus*bPlus*kTrans*mMinus*qTrans^3*
       x1*y2 + aPlus*kTrans^2*qTrans^4*x1*y2 + bPlus*kTrans^2*qTrans^4*x1*
       y2 + 2*aPlus*bPlus*mMinus*qTrans^4*x1*y2 + 2*bPlus*kTrans*qTrans^5*x1*
       y2 + bPlus*qTrans^6*x1*y2 + aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x5*
       y2 + 2*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x5*y2 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*x5*y2 + bPlus*kTrans^3*qTrans^3*x5*y2 + 
      4*aPlus*bPlus*kTrans*mMinus*qTrans^3*x5*y2 + 3*bPlus*kTrans^2*qTrans^4*
       x5*y2 + 2*aPlus*bPlus*mMinus*qTrans^4*x5*y2 + 
      3*bPlus*kTrans*qTrans^5*x5*y2 + bPlus*qTrans^6*x5*y2 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*y0*y2 + 2*aPlus*bPlus*kTrans*mMinus*
       qTrans^3*y0*y2 + bPlus*kTrans^2*qTrans^4*y0*y2 + 
      2*aPlus*bPlus*mMinus*qTrans^4*y0*y2 + 2*bPlus*kTrans*qTrans^5*y0*y2 + 
      bPlus*qTrans^6*y0*y2 + aPlus^2*kTrans^3*mMinus*qTrans*x1*y4 + 
      aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1*y4 + aPlus*kTrans^4*qTrans^2*x1*
       y4 + aPlus^2*kTrans^2*mMinus*qTrans^2*x1*y4 + 
      aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1*y4 + aPlus^2*bPlus*mMinus^2*
       qTrans^2*x1*y4 + 2*aPlus*kTrans^3*qTrans^3*x1*y4 + 
      3*aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*y4 + aPlus*kTrans^2*qTrans^4*x1*
       y4 + bPlus*kTrans^2*qTrans^4*x1*y4 + 2*aPlus*bPlus*mMinus*qTrans^4*x1*
       y4 + 2*bPlus*kTrans*qTrans^5*x1*y4 + bPlus*qTrans^6*x1*y4 + 
      aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x3*y4 + aPlus^2*bPlus*mMinus^2*
       qTrans^2*x3*y4 + aPlus*bPlus^2*mMinus^2*qTrans^2*x3*y4 + 
      bPlus*kTrans^3*qTrans^3*x3*y4 + 3*aPlus*bPlus*kTrans*mMinus*qTrans^3*x3*
       y4 + bPlus^2*kTrans*mMinus*qTrans^3*x3*y4 + 3*bPlus*kTrans^2*qTrans^4*
       x3*y4 + 2*aPlus*bPlus*mMinus*qTrans^4*x3*y4 + 
      bPlus^2*mMinus*qTrans^4*x3*y4 + 3*bPlus*kTrans*qTrans^5*x3*y4 + 
      bPlus*qTrans^6*x3*y4 + aPlus^2*bPlus*mMinus^2*qTrans^2*y0*y4 + 
      2*aPlus*bPlus*kTrans*mMinus*qTrans^3*y0*y4 + bPlus*kTrans^2*qTrans^4*y0*
       y4 + 2*aPlus*bPlus*mMinus*qTrans^4*y0*y4 + 2*bPlus*kTrans*qTrans^5*y0*
       y4 + bPlus*qTrans^6*y0*y4 + aPlus^2*bPlus*mMinus^2*qTrans^2*y2*y4 + 
      2*aPlus*bPlus*kTrans*mMinus*qTrans^3*y2*y4 + bPlus*kTrans^2*qTrans^4*y2*
       y4 + 2*aPlus*bPlus*mMinus*qTrans^4*y2*y4 + 2*bPlus*kTrans*qTrans^5*y2*
       y4 + bPlus*qTrans^6*y2*y4)/(bPlus*qTrans^2*
      (aPlus*mMinus + kTrans*qTrans + qTrans^2)^2), 
   "F1Local" -> (aPlus*kTrans^5*qTrans*x1^2*x3 + aPlus^2*kTrans^3*mMinus*
       qTrans*x1^2*x3 + 2*aPlus*bPlus*kTrans^3*mMinus*qTrans*x1^2*x3 + 
      aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1^2*x3 + 
      aPlus*bPlus^2*kTrans*mMinus^2*qTrans*x1^2*x3 + 
      3*aPlus*kTrans^4*qTrans^2*x1^2*x3 + aPlus^2*kTrans^2*mMinus*qTrans^2*
       x1^2*x3 + 3*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1^2*x3 + 
      3*aPlus*kTrans^3*qTrans^3*x1^2*x3 + aPlus*bPlus*kTrans*mMinus*qTrans^3*
       x1^2*x3 + aPlus*kTrans^2*qTrans^4*x1^2*x3 + aPlus*kTrans^5*qTrans*x1*
       x3^2 + 2*aPlus*bPlus*kTrans^3*mMinus*qTrans*x1*x3^2 + 
      aPlus*bPlus^2*kTrans*mMinus^2*qTrans*x1*x3^2 + 
      2*aPlus*kTrans^4*qTrans^2*x1*x3^2 + 3*aPlus*bPlus*kTrans^2*mMinus*
       qTrans^2*x1*x3^2 + aPlus*bPlus^2*mMinus^2*qTrans^2*x1*x3^2 + 
      aPlus*kTrans^3*qTrans^3*x1*x3^2 + bPlus*kTrans^3*qTrans^3*x1*x3^2 + 
      aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*x3^2 + bPlus^2*kTrans*mMinus*
       qTrans^3*x1*x3^2 + 2*bPlus*kTrans^2*qTrans^4*x1*x3^2 + 
      bPlus^2*mMinus*qTrans^4*x1*x3^2 + bPlus*kTrans*qTrans^5*x1*x3^2 + 
      aPlus^2*kTrans^4*mMinus*x1^2*x5 + aPlus^2*bPlus*kTrans^2*mMinus^2*x1^2*
       x5 + aPlus*kTrans^5*qTrans*x1^2*x5 + 2*aPlus^2*kTrans^3*mMinus*qTrans*
       x1^2*x5 + aPlus*bPlus*kTrans^3*mMinus*qTrans*x1^2*x5 + 
      aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1^2*x5 + 
      3*aPlus*kTrans^4*qTrans^2*x1^2*x5 + aPlus^2*kTrans^2*mMinus*qTrans^2*
       x1^2*x5 + 2*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1^2*x5 + 
      3*aPlus*kTrans^3*qTrans^3*x1^2*x5 + aPlus*bPlus*kTrans*mMinus*qTrans^3*
       x1^2*x5 + aPlus*kTrans^2*qTrans^4*x1^2*x5 + aPlus*kTrans^6*x1*x3*x5 + 
      2*aPlus*bPlus*kTrans^4*mMinus*x1*x3*x5 + aPlus*bPlus^2*kTrans^2*
       mMinus^2*x1*x3*x5 + 5*aPlus*kTrans^5*qTrans*x1*x3*x5 + 
      3*aPlus^2*kTrans^3*mMinus*qTrans*x1*x3*x5 + 11*aPlus*bPlus*kTrans^3*
       mMinus*qTrans*x1*x3*x5 + 3*aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1*x3*
       x5 + 6*aPlus*bPlus^2*kTrans*mMinus^2*qTrans*x1*x3*x5 + 
      10*aPlus*kTrans^4*qTrans^2*x1*x3*x5 + 3*bPlus*kTrans^4*qTrans^2*x1*x3*
       x5 + 3*aPlus^2*kTrans^2*mMinus*qTrans^2*x1*x3*x5 + 
      15*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1*x3*x5 + 
      3*bPlus^2*kTrans^2*mMinus*qTrans^2*x1*x3*x5 + aPlus^2*bPlus*mMinus^2*
       qTrans^2*x1*x3*x5 + 3*aPlus*bPlus^2*mMinus^2*qTrans^2*x1*x3*x5 + 
      9*aPlus*kTrans^3*qTrans^3*x1*x3*x5 + 9*bPlus*kTrans^3*qTrans^3*x1*x3*
       x5 + 8*aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*x3*x5 + 
      6*bPlus^2*kTrans*mMinus*qTrans^3*x1*x3*x5 + 3*aPlus*kTrans^2*qTrans^4*
       x1*x3*x5 + 10*bPlus*kTrans^2*qTrans^4*x1*x3*x5 + 
      2*aPlus*bPlus*mMinus*qTrans^4*x1*x3*x5 + 3*bPlus^2*mMinus*qTrans^4*x1*
       x3*x5 + 5*bPlus*kTrans*qTrans^5*x1*x3*x5 + bPlus*qTrans^6*x1*x3*x5 + 
      aPlus*bPlus*kTrans^3*mMinus*qTrans*x3^2*x5 + aPlus*bPlus^2*kTrans*
       mMinus^2*qTrans*x3^2*x5 + bPlus*kTrans^4*qTrans^2*x3^2*x5 + 
      2*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x3^2*x5 + 
      bPlus^2*kTrans^2*mMinus*qTrans^2*x3^2*x5 + aPlus*bPlus^2*mMinus^2*
       qTrans^2*x3^2*x5 + 3*bPlus*kTrans^3*qTrans^3*x3^2*x5 + 
      aPlus*bPlus*kTrans*mMinus*qTrans^3*x3^2*x5 + 2*bPlus^2*kTrans*mMinus*
       qTrans^3*x3^2*x5 + 3*bPlus*kTrans^2*qTrans^4*x3^2*x5 + 
      bPlus^2*mMinus*qTrans^4*x3^2*x5 + bPlus*kTrans*qTrans^5*x3^2*x5 + 
      aPlus^2*kTrans^4*mMinus*x1*x5^2 + aPlus^2*bPlus*kTrans^2*mMinus^2*x1*
       x5^2 + aPlus*kTrans^5*qTrans*x1*x5^2 + aPlus^2*kTrans^3*mMinus*qTrans*
       x1*x5^2 + aPlus*bPlus*kTrans^3*mMinus*qTrans*x1*x5^2 + 
      aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1*x5^2 + 
      2*aPlus*kTrans^4*qTrans^2*x1*x5^2 + 3*aPlus*bPlus*kTrans^2*mMinus*
       qTrans^2*x1*x5^2 + aPlus*kTrans^3*qTrans^3*x1*x5^2 + 
      bPlus*kTrans^3*qTrans^3*x1*x5^2 + 2*aPlus*bPlus*kTrans*mMinus*qTrans^3*
       x1*x5^2 + 2*bPlus*kTrans^2*qTrans^4*x1*x5^2 + bPlus*kTrans*qTrans^5*x1*
       x5^2 + aPlus*bPlus*kTrans^3*mMinus*qTrans*x3*x5^2 + 
      aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x3*x5^2 + 
      aPlus*bPlus^2*kTrans*mMinus^2*qTrans*x3*x5^2 + 
      bPlus*kTrans^4*qTrans^2*x3*x5^2 + 3*aPlus*bPlus*kTrans^2*mMinus*
       qTrans^2*x3*x5^2 + bPlus^2*kTrans^2*mMinus*qTrans^2*x3*x5^2 + 
      3*bPlus*kTrans^3*qTrans^3*x3*x5^2 + 2*aPlus*bPlus*kTrans*mMinus*
       qTrans^3*x3*x5^2 + bPlus^2*kTrans*mMinus*qTrans^3*x3*x5^2 + 
      3*bPlus*kTrans^2*qTrans^4*x3*x5^2 + bPlus*kTrans*qTrans^5*x3*x5^2 + 
      aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1*x3*y0 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*x1*x3*y0 + aPlus*bPlus^2*mMinus^2*
       qTrans^2*x1*x3*y0 + bPlus*kTrans^3*qTrans^3*x1*x3*y0 + 
      3*aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*x3*y0 + 
      bPlus^2*kTrans*mMinus*qTrans^3*x1*x3*y0 + 3*bPlus*kTrans^2*qTrans^4*x1*
       x3*y0 + 2*aPlus*bPlus*mMinus*qTrans^4*x1*x3*y0 + 
      bPlus^2*mMinus*qTrans^4*x1*x3*y0 + 3*bPlus*kTrans*qTrans^5*x1*x3*y0 + 
      bPlus*qTrans^6*x1*x3*y0 + aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x3^2*
       y0 + aPlus*bPlus^2*mMinus^2*qTrans^2*x3^2*y0 + 
      bPlus*kTrans^3*qTrans^3*x3^2*y0 + aPlus*bPlus*kTrans*mMinus*qTrans^3*
       x3^2*y0 + bPlus^2*kTrans*mMinus*qTrans^3*x3^2*y0 + 
      2*bPlus*kTrans^2*qTrans^4*x3^2*y0 + bPlus^2*mMinus*qTrans^4*x3^2*y0 + 
      bPlus*kTrans*qTrans^5*x3^2*y0 + aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1*
       x5*y0 + 2*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1*x5*y0 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*x1*x5*y0 + bPlus*kTrans^3*qTrans^3*x1*
       x5*y0 + 4*aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*x5*y0 + 
      3*bPlus*kTrans^2*qTrans^4*x1*x5*y0 + 2*aPlus*bPlus*mMinus*qTrans^4*x1*
       x5*y0 + 3*bPlus*kTrans*qTrans^5*x1*x5*y0 + bPlus*qTrans^6*x1*x5*y0 + 
      aPlus*bPlus*kTrans^3*mMinus*qTrans*x3*x5*y0 + aPlus*bPlus^2*kTrans*
       mMinus^2*qTrans*x3*x5*y0 + bPlus*kTrans^4*qTrans^2*x3*x5*y0 + 
      4*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x3*x5*y0 + 
      bPlus^2*kTrans^2*mMinus*qTrans^2*x3*x5*y0 + 3*aPlus^2*bPlus*mMinus^2*
       qTrans^2*x3*x5*y0 + 3*aPlus*bPlus^2*mMinus^2*qTrans^2*x3*x5*y0 + 
      5*bPlus*kTrans^3*qTrans^3*x3*x5*y0 + 9*aPlus*bPlus*kTrans*mMinus*
       qTrans^3*x3*x5*y0 + 4*bPlus^2*kTrans*mMinus*qTrans^3*x3*x5*y0 + 
      10*bPlus*kTrans^2*qTrans^4*x3*x5*y0 + 6*aPlus*bPlus*mMinus*qTrans^4*x3*
       x5*y0 + 3*bPlus^2*mMinus*qTrans^4*x3*x5*y0 + 9*bPlus*kTrans*qTrans^5*
       x3*x5*y0 + 3*bPlus*qTrans^6*x3*x5*y0 + aPlus^2*bPlus*kTrans*mMinus^2*
       qTrans*x5^2*y0 + 2*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x5^2*y0 + 
      bPlus*kTrans^3*qTrans^3*x5^2*y0 + 2*aPlus*bPlus*kTrans*mMinus*qTrans^3*
       x5^2*y0 + 2*bPlus*kTrans^2*qTrans^4*x5^2*y0 + 
      bPlus*kTrans*qTrans^5*x5^2*y0 + aPlus^2*kTrans^3*mMinus*qTrans*x1^2*
       y2 + aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1^2*y2 + 
      aPlus*kTrans^4*qTrans^2*x1^2*y2 + aPlus^2*kTrans^2*mMinus*qTrans^2*x1^2*
       y2 + aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1^2*y2 + 
      2*aPlus*kTrans^3*qTrans^3*x1^2*y2 + aPlus*bPlus*kTrans*mMinus*qTrans^3*
       x1^2*y2 + aPlus*kTrans^2*qTrans^4*x1^2*y2 + aPlus^2*kTrans^3*mMinus*
       qTrans*x1*x3*y2 + aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1*x3*y2 + 
      aPlus*kTrans^4*qTrans^2*x1*x3*y2 + aPlus^2*kTrans^2*mMinus*qTrans^2*x1*
       x3*y2 + aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1*x3*y2 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*x1*x3*y2 + 2*aPlus*kTrans^3*qTrans^3*x1*
       x3*y2 + 3*aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*x3*y2 + 
      aPlus*kTrans^2*qTrans^4*x1*x3*y2 + bPlus*kTrans^2*qTrans^4*x1*x3*y2 + 
      2*aPlus*bPlus*mMinus*qTrans^4*x1*x3*y2 + 2*bPlus*kTrans*qTrans^5*x1*x3*
       y2 + bPlus*qTrans^6*x1*x3*y2 + aPlus^2*kTrans^4*mMinus*x1*x5*y2 + 
      aPlus^2*bPlus*kTrans^2*mMinus^2*x1*x5*y2 + aPlus*kTrans^5*qTrans*x1*x5*
       y2 + 4*aPlus^2*kTrans^3*mMinus*qTrans*x1*x5*y2 + 
      aPlus*bPlus*kTrans^3*mMinus*qTrans*x1*x5*y2 + 6*aPlus^2*bPlus*kTrans*
       mMinus^2*qTrans*x1*x5*y2 + 5*aPlus*kTrans^4*qTrans^2*x1*x5*y2 + 
      3*aPlus^2*kTrans^2*mMinus*qTrans^2*x1*x5*y2 + 10*aPlus*bPlus*kTrans^2*
       mMinus*qTrans^2*x1*x5*y2 + 3*aPlus^2*bPlus*mMinus^2*qTrans^2*x1*x5*
       y2 + 7*aPlus*kTrans^3*qTrans^3*x1*x5*y2 + 3*bPlus*kTrans^3*qTrans^3*x1*
       x5*y2 + 15*aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*x5*y2 + 
      3*aPlus*kTrans^2*qTrans^4*x1*x5*y2 + 9*bPlus*kTrans^2*qTrans^4*x1*x5*
       y2 + 6*aPlus*bPlus*mMinus*qTrans^4*x1*x5*y2 + 
      9*bPlus*kTrans*qTrans^5*x1*x5*y2 + 3*bPlus*qTrans^6*x1*x5*y2 + 
      aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x3*x5*y2 + 
      2*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x3*x5*y2 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*x3*x5*y2 + bPlus*kTrans^3*qTrans^3*x3*
       x5*y2 + 4*aPlus*bPlus*kTrans*mMinus*qTrans^3*x3*x5*y2 + 
      3*bPlus*kTrans^2*qTrans^4*x3*x5*y2 + 2*aPlus*bPlus*mMinus*qTrans^4*x3*
       x5*y2 + 3*bPlus*kTrans*qTrans^5*x3*x5*y2 + bPlus*qTrans^6*x3*x5*y2 + 
      aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x5^2*y2 + 
      2*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x5^2*y2 + 
      bPlus*kTrans^3*qTrans^3*x5^2*y2 + 2*aPlus*bPlus*kTrans*mMinus*qTrans^3*
       x5^2*y2 + 2*bPlus*kTrans^2*qTrans^4*x5^2*y2 + 
      bPlus*kTrans*qTrans^5*x5^2*y2 + aPlus^2*bPlus*mMinus^2*qTrans^2*x1*y0*
       y2 + 2*aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*y0*y2 + 
      bPlus*kTrans^2*qTrans^4*x1*y0*y2 + 2*aPlus*bPlus*mMinus*qTrans^4*x1*y0*
       y2 + 2*bPlus*kTrans*qTrans^5*x1*y0*y2 + bPlus*qTrans^6*x1*y0*y2 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*x3*y0*y2 + 2*aPlus*bPlus*kTrans*mMinus*
       qTrans^3*x3*y0*y2 + bPlus*kTrans^2*qTrans^4*x3*y0*y2 + 
      2*aPlus*bPlus*mMinus*qTrans^4*x3*y0*y2 + 2*bPlus*kTrans*qTrans^5*x3*y0*
       y2 + bPlus*qTrans^6*x3*y0*y2 + aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x5*
       y0*y2 + 2*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x5*y0*y2 + 
      3*aPlus^2*bPlus*mMinus^2*qTrans^2*x5*y0*y2 + bPlus*kTrans^3*qTrans^3*x5*
       y0*y2 + 8*aPlus*bPlus*kTrans*mMinus*qTrans^3*x5*y0*y2 + 
      5*bPlus*kTrans^2*qTrans^4*x5*y0*y2 + 6*aPlus*bPlus*mMinus*qTrans^4*x5*
       y0*y2 + 7*bPlus*kTrans*qTrans^5*x5*y0*y2 + 3*bPlus*qTrans^6*x5*y0*y2 + 
      aPlus^2*kTrans^3*mMinus*qTrans*x1^2*y4 + aPlus^2*bPlus*kTrans*mMinus^2*
       qTrans*x1^2*y4 + aPlus*kTrans^4*qTrans^2*x1^2*y4 + 
      aPlus^2*kTrans^2*mMinus*qTrans^2*x1^2*y4 + aPlus*bPlus*kTrans^2*mMinus*
       qTrans^2*x1^2*y4 + 2*aPlus*kTrans^3*qTrans^3*x1^2*y4 + 
      aPlus*bPlus*kTrans*mMinus*qTrans^3*x1^2*y4 + aPlus*kTrans^2*qTrans^4*
       x1^2*y4 + aPlus*kTrans^5*qTrans*x1*x3*y4 + 2*aPlus*bPlus*kTrans^3*
       mMinus*qTrans*x1*x3*y4 + aPlus*bPlus^2*kTrans*mMinus^2*qTrans*x1*x3*
       y4 + 2*aPlus*kTrans^4*qTrans^2*x1*x3*y4 + 5*aPlus*bPlus*kTrans^2*
       mMinus*qTrans^2*x1*x3*y4 + 3*aPlus*bPlus^2*mMinus^2*qTrans^2*x1*x3*
       y4 + aPlus*kTrans^3*qTrans^3*x1*x3*y4 + 3*bPlus*kTrans^3*qTrans^3*x1*
       x3*y4 + 3*aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*x3*y4 + 
      3*bPlus^2*kTrans*mMinus*qTrans^3*x1*x3*y4 + 6*bPlus*kTrans^2*qTrans^4*
       x1*x3*y4 + 3*bPlus^2*mMinus*qTrans^4*x1*x3*y4 + 
      3*bPlus*kTrans*qTrans^5*x1*x3*y4 + aPlus*bPlus*kTrans^2*mMinus*qTrans^2*
       x3^2*y4 + aPlus*bPlus^2*mMinus^2*qTrans^2*x3^2*y4 + 
      bPlus*kTrans^3*qTrans^3*x3^2*y4 + aPlus*bPlus*kTrans*mMinus*qTrans^3*
       x3^2*y4 + bPlus^2*kTrans*mMinus*qTrans^3*x3^2*y4 + 
      2*bPlus*kTrans^2*qTrans^4*x3^2*y4 + bPlus^2*mMinus*qTrans^4*x3^2*y4 + 
      bPlus*kTrans*qTrans^5*x3^2*y4 + aPlus^2*kTrans^3*mMinus*qTrans*x1*x5*
       y4 + aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1*x5*y4 + 
      aPlus*kTrans^4*qTrans^2*x1*x5*y4 + aPlus^2*kTrans^2*mMinus*qTrans^2*x1*
       x5*y4 + aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1*x5*y4 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*x1*x5*y4 + 2*aPlus*kTrans^3*qTrans^3*x1*
       x5*y4 + 3*aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*x5*y4 + 
      aPlus*kTrans^2*qTrans^4*x1*x5*y4 + bPlus*kTrans^2*qTrans^4*x1*x5*y4 + 
      2*aPlus*bPlus*mMinus*qTrans^4*x1*x5*y4 + 2*bPlus*kTrans*qTrans^5*x1*x5*
       y4 + bPlus*qTrans^6*x1*x5*y4 + aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x3*
       x5*y4 + aPlus^2*bPlus*mMinus^2*qTrans^2*x3*x5*y4 + 
      aPlus*bPlus^2*mMinus^2*qTrans^2*x3*x5*y4 + bPlus*kTrans^3*qTrans^3*x3*
       x5*y4 + 3*aPlus*bPlus*kTrans*mMinus*qTrans^3*x3*x5*y4 + 
      bPlus^2*kTrans*mMinus*qTrans^3*x3*x5*y4 + 3*bPlus*kTrans^2*qTrans^4*x3*
       x5*y4 + 2*aPlus*bPlus*mMinus*qTrans^4*x3*x5*y4 + 
      bPlus^2*mMinus*qTrans^4*x3*x5*y4 + 3*bPlus*kTrans*qTrans^5*x3*x5*y4 + 
      bPlus*qTrans^6*x3*x5*y4 + aPlus^2*bPlus*mMinus^2*qTrans^2*x1*y0*y4 + 
      2*aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*y0*y4 + 
      bPlus*kTrans^2*qTrans^4*x1*y0*y4 + 2*aPlus*bPlus*mMinus*qTrans^4*x1*y0*
       y4 + 2*bPlus*kTrans*qTrans^5*x1*y0*y4 + bPlus*qTrans^6*x1*y0*y4 + 
      aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x3*y0*y4 + 
      aPlus*bPlus^2*mMinus^2*qTrans^2*x3*y0*y4 + bPlus*kTrans^3*qTrans^3*x3*
       y0*y4 + aPlus*bPlus*kTrans*mMinus*qTrans^3*x3*y0*y4 + 
      bPlus^2*kTrans*mMinus*qTrans^3*x3*y0*y4 + 2*bPlus*kTrans^2*qTrans^4*x3*
       y0*y4 + bPlus^2*mMinus*qTrans^4*x3*y0*y4 + bPlus*kTrans*qTrans^5*x3*y0*
       y4 + aPlus^2*bPlus*mMinus^2*qTrans^2*x5*y0*y4 + 
      2*aPlus*bPlus*kTrans*mMinus*qTrans^3*x5*y0*y4 + 
      bPlus*kTrans^2*qTrans^4*x5*y0*y4 + 2*aPlus*bPlus*mMinus*qTrans^4*x5*y0*
       y4 + 2*bPlus*kTrans*qTrans^5*x5*y0*y4 + bPlus*qTrans^6*x5*y0*y4 + 
      aPlus^2*kTrans^3*mMinus*qTrans*x1*y2*y4 + aPlus^2*bPlus*kTrans*mMinus^2*
       qTrans*x1*y2*y4 + aPlus*kTrans^4*qTrans^2*x1*y2*y4 + 
      aPlus^2*kTrans^2*mMinus*qTrans^2*x1*y2*y4 + aPlus*bPlus*kTrans^2*mMinus*
       qTrans^2*x1*y2*y4 + 3*aPlus^2*bPlus*mMinus^2*qTrans^2*x1*y2*y4 + 
      2*aPlus*kTrans^3*qTrans^3*x1*y2*y4 + 7*aPlus*bPlus*kTrans*mMinus*
       qTrans^3*x1*y2*y4 + aPlus*kTrans^2*qTrans^4*x1*y2*y4 + 
      3*bPlus*kTrans^2*qTrans^4*x1*y2*y4 + 6*aPlus*bPlus*mMinus*qTrans^4*x1*
       y2*y4 + 6*bPlus*kTrans*qTrans^5*x1*y2*y4 + 3*bPlus*qTrans^6*x1*y2*y4 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*x3*y2*y4 + 2*aPlus*bPlus*kTrans*mMinus*
       qTrans^3*x3*y2*y4 + bPlus*kTrans^2*qTrans^4*x3*y2*y4 + 
      2*aPlus*bPlus*mMinus*qTrans^4*x3*y2*y4 + 2*bPlus*kTrans*qTrans^5*x3*y2*
       y4 + bPlus*qTrans^6*x3*y2*y4 + aPlus^2*bPlus*mMinus^2*qTrans^2*x5*y2*
       y4 + 2*aPlus*bPlus*kTrans*mMinus*qTrans^3*x5*y2*y4 + 
      bPlus*kTrans^2*qTrans^4*x5*y2*y4 + 2*aPlus*bPlus*mMinus*qTrans^4*x5*y2*
       y4 + 2*bPlus*kTrans*qTrans^5*x5*y2*y4 + bPlus*qTrans^6*x5*y2*y4 + 
      aPlus^2*bPlus*mMinus^2*qTrans^2*y0*y2*y4 + 2*aPlus*bPlus*kTrans*mMinus*
       qTrans^3*y0*y2*y4 + bPlus*kTrans^2*qTrans^4*y0*y2*y4 + 
      2*aPlus*bPlus*mMinus*qTrans^4*y0*y2*y4 + 2*bPlus*kTrans*qTrans^5*y0*y2*
       y4 + bPlus*qTrans^6*y0*y2*y4)/(bPlus*qTrans^2*
      (aPlus*mMinus + kTrans*qTrans + qTrans^2)^2), 
   "UOnLandauLocus" -> ((kTrans + qTrans)*(aPlus*kTrans^4*qTrans*x1*x3 + 
       aPlus^2*kTrans^2*mMinus*qTrans*x1*x3 + 2*aPlus*bPlus*kTrans^2*mMinus*
        qTrans*x1*x3 + aPlus^2*bPlus*mMinus^2*qTrans*x1*x3 + 
       aPlus*bPlus^2*mMinus^2*qTrans*x1*x3 + 2*aPlus*kTrans^3*qTrans^2*x1*
        x3 + 2*aPlus*bPlus*kTrans*mMinus*qTrans^2*x1*x3 + 
       aPlus*kTrans^2*qTrans^3*x1*x3 + bPlus*kTrans^2*qTrans^3*x1*x3 + 
       2*aPlus*bPlus*mMinus*qTrans^3*x1*x3 + bPlus^2*mMinus*qTrans^3*x1*x3 + 
       2*bPlus*kTrans*qTrans^4*x1*x3 + bPlus*qTrans^5*x1*x3 + 
       aPlus^2*kTrans^3*mMinus*x1*x5 + aPlus^2*bPlus*kTrans*mMinus^2*x1*x5 + 
       aPlus*kTrans^4*qTrans*x1*x5 + aPlus^2*kTrans^2*mMinus*qTrans*x1*x5 + 
       aPlus*bPlus*kTrans^2*mMinus*qTrans*x1*x5 + aPlus^2*bPlus*mMinus^2*
        qTrans*x1*x5 + 2*aPlus*kTrans^3*qTrans^2*x1*x5 + 
       3*aPlus*bPlus*kTrans*mMinus*qTrans^2*x1*x5 + aPlus*kTrans^2*qTrans^3*
        x1*x5 + bPlus*kTrans^2*qTrans^3*x1*x5 + 2*aPlus*bPlus*mMinus*qTrans^3*
        x1*x5 + 2*bPlus*kTrans*qTrans^4*x1*x5 + bPlus*qTrans^5*x1*x5 + 
       aPlus*bPlus*kTrans^2*mMinus*qTrans*x3*x5 + aPlus^2*bPlus*mMinus^2*
        qTrans*x3*x5 + aPlus*bPlus^2*mMinus^2*qTrans*x3*x5 + 
       bPlus*kTrans^3*qTrans^2*x3*x5 + 3*aPlus*bPlus*kTrans*mMinus*qTrans^2*
        x3*x5 + bPlus^2*kTrans*mMinus*qTrans^2*x3*x5 + 
       3*bPlus*kTrans^2*qTrans^3*x3*x5 + 2*aPlus*bPlus*mMinus*qTrans^3*x3*
        x5 + bPlus^2*mMinus*qTrans^3*x3*x5 + 3*bPlus*kTrans*qTrans^4*x3*x5 + 
       bPlus*qTrans^5*x3*x5))/(bPlus*qTrans^2*
      (aPlus*mMinus + kTrans*qTrans + qTrans^2)^2), 
   "F1OnLandauLocus" -> (aPlus*kTrans^5*qTrans*x1^2*x3 + 
      aPlus^2*kTrans^3*mMinus*qTrans*x1^2*x3 + 2*aPlus*bPlus*kTrans^3*mMinus*
       qTrans*x1^2*x3 + aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1^2*x3 + 
      aPlus*bPlus^2*kTrans*mMinus^2*qTrans*x1^2*x3 + 
      3*aPlus*kTrans^4*qTrans^2*x1^2*x3 + aPlus^2*kTrans^2*mMinus*qTrans^2*
       x1^2*x3 + 3*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1^2*x3 + 
      3*aPlus*kTrans^3*qTrans^3*x1^2*x3 + aPlus*bPlus*kTrans*mMinus*qTrans^3*
       x1^2*x3 + aPlus*kTrans^2*qTrans^4*x1^2*x3 + aPlus*kTrans^5*qTrans*x1*
       x3^2 + 2*aPlus*bPlus*kTrans^3*mMinus*qTrans*x1*x3^2 + 
      aPlus*bPlus^2*kTrans*mMinus^2*qTrans*x1*x3^2 + 
      2*aPlus*kTrans^4*qTrans^2*x1*x3^2 + 3*aPlus*bPlus*kTrans^2*mMinus*
       qTrans^2*x1*x3^2 + aPlus*bPlus^2*mMinus^2*qTrans^2*x1*x3^2 + 
      aPlus*kTrans^3*qTrans^3*x1*x3^2 + bPlus*kTrans^3*qTrans^3*x1*x3^2 + 
      aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*x3^2 + bPlus^2*kTrans*mMinus*
       qTrans^3*x1*x3^2 + 2*bPlus*kTrans^2*qTrans^4*x1*x3^2 + 
      bPlus^2*mMinus*qTrans^4*x1*x3^2 + bPlus*kTrans*qTrans^5*x1*x3^2 + 
      aPlus^2*kTrans^4*mMinus*x1^2*x5 + aPlus^2*bPlus*kTrans^2*mMinus^2*x1^2*
       x5 + aPlus*kTrans^5*qTrans*x1^2*x5 + 2*aPlus^2*kTrans^3*mMinus*qTrans*
       x1^2*x5 + aPlus*bPlus*kTrans^3*mMinus*qTrans*x1^2*x5 + 
      aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1^2*x5 + 
      3*aPlus*kTrans^4*qTrans^2*x1^2*x5 + aPlus^2*kTrans^2*mMinus*qTrans^2*
       x1^2*x5 + 2*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1^2*x5 + 
      3*aPlus*kTrans^3*qTrans^3*x1^2*x5 + aPlus*bPlus*kTrans*mMinus*qTrans^3*
       x1^2*x5 + aPlus*kTrans^2*qTrans^4*x1^2*x5 + aPlus*kTrans^6*x1*x3*x5 + 
      2*aPlus*bPlus*kTrans^4*mMinus*x1*x3*x5 + aPlus*bPlus^2*kTrans^2*
       mMinus^2*x1*x3*x5 + 5*aPlus*kTrans^5*qTrans*x1*x3*x5 + 
      3*aPlus^2*kTrans^3*mMinus*qTrans*x1*x3*x5 + 11*aPlus*bPlus*kTrans^3*
       mMinus*qTrans*x1*x3*x5 + 3*aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1*x3*
       x5 + 6*aPlus*bPlus^2*kTrans*mMinus^2*qTrans*x1*x3*x5 + 
      10*aPlus*kTrans^4*qTrans^2*x1*x3*x5 + 3*bPlus*kTrans^4*qTrans^2*x1*x3*
       x5 + 3*aPlus^2*kTrans^2*mMinus*qTrans^2*x1*x3*x5 + 
      15*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1*x3*x5 + 
      3*bPlus^2*kTrans^2*mMinus*qTrans^2*x1*x3*x5 + aPlus^2*bPlus*mMinus^2*
       qTrans^2*x1*x3*x5 + 3*aPlus*bPlus^2*mMinus^2*qTrans^2*x1*x3*x5 + 
      9*aPlus*kTrans^3*qTrans^3*x1*x3*x5 + 9*bPlus*kTrans^3*qTrans^3*x1*x3*
       x5 + 8*aPlus*bPlus*kTrans*mMinus*qTrans^3*x1*x3*x5 + 
      6*bPlus^2*kTrans*mMinus*qTrans^3*x1*x3*x5 + 3*aPlus*kTrans^2*qTrans^4*
       x1*x3*x5 + 10*bPlus*kTrans^2*qTrans^4*x1*x3*x5 + 
      2*aPlus*bPlus*mMinus*qTrans^4*x1*x3*x5 + 3*bPlus^2*mMinus*qTrans^4*x1*
       x3*x5 + 5*bPlus*kTrans*qTrans^5*x1*x3*x5 + bPlus*qTrans^6*x1*x3*x5 + 
      aPlus*bPlus*kTrans^3*mMinus*qTrans*x3^2*x5 + aPlus*bPlus^2*kTrans*
       mMinus^2*qTrans*x3^2*x5 + bPlus*kTrans^4*qTrans^2*x3^2*x5 + 
      2*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x3^2*x5 + 
      bPlus^2*kTrans^2*mMinus*qTrans^2*x3^2*x5 + aPlus*bPlus^2*mMinus^2*
       qTrans^2*x3^2*x5 + 3*bPlus*kTrans^3*qTrans^3*x3^2*x5 + 
      aPlus*bPlus*kTrans*mMinus*qTrans^3*x3^2*x5 + 2*bPlus^2*kTrans*mMinus*
       qTrans^3*x3^2*x5 + 3*bPlus*kTrans^2*qTrans^4*x3^2*x5 + 
      bPlus^2*mMinus*qTrans^4*x3^2*x5 + bPlus*kTrans*qTrans^5*x3^2*x5 + 
      aPlus^2*kTrans^4*mMinus*x1*x5^2 + aPlus^2*bPlus*kTrans^2*mMinus^2*x1*
       x5^2 + aPlus*kTrans^5*qTrans*x1*x5^2 + aPlus^2*kTrans^3*mMinus*qTrans*
       x1*x5^2 + aPlus*bPlus*kTrans^3*mMinus*qTrans*x1*x5^2 + 
      aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1*x5^2 + 
      2*aPlus*kTrans^4*qTrans^2*x1*x5^2 + 3*aPlus*bPlus*kTrans^2*mMinus*
       qTrans^2*x1*x5^2 + aPlus*kTrans^3*qTrans^3*x1*x5^2 + 
      bPlus*kTrans^3*qTrans^3*x1*x5^2 + 2*aPlus*bPlus*kTrans*mMinus*qTrans^3*
       x1*x5^2 + 2*bPlus*kTrans^2*qTrans^4*x1*x5^2 + bPlus*kTrans*qTrans^5*x1*
       x5^2 + aPlus*bPlus*kTrans^3*mMinus*qTrans*x3*x5^2 + 
      aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x3*x5^2 + 
      aPlus*bPlus^2*kTrans*mMinus^2*qTrans*x3*x5^2 + 
      bPlus*kTrans^4*qTrans^2*x3*x5^2 + 3*aPlus*bPlus*kTrans^2*mMinus*
       qTrans^2*x3*x5^2 + bPlus^2*kTrans^2*mMinus*qTrans^2*x3*x5^2 + 
      3*bPlus*kTrans^3*qTrans^3*x3*x5^2 + 2*aPlus*bPlus*kTrans*mMinus*
       qTrans^3*x3*x5^2 + bPlus^2*kTrans*mMinus*qTrans^3*x3*x5^2 + 
      3*bPlus*kTrans^2*qTrans^4*x3*x5^2 + bPlus*kTrans*qTrans^5*x3*x5^2)/
     (bPlus*qTrans^2*(aPlus*mMinus + kTrans*qTrans + qTrans^2)^2), 
   "FullLocalLP" -> (aPlus^2*kTrans^5*mMinus*qTrans*x1*x3 + 
      aPlus^3*kTrans^3*mMinus^2*qTrans*x1*x3 + 2*aPlus^2*bPlus*kTrans^3*
       mMinus^2*qTrans*x1*x3 + aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x1*x3 + 
      aPlus^2*bPlus^2*kTrans*mMinus^3*qTrans*x1*x3 + 
      3*aPlus^2*kTrans^4*mMinus*qTrans^2*x1*x3 + aPlus^3*kTrans^2*mMinus^2*
       qTrans^2*x1*x3 + 4*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x1*x3 + 
      aPlus^3*bPlus*mMinus^3*qTrans^2*x1*x3 + aPlus^2*bPlus^2*mMinus^3*
       qTrans^2*x1*x3 + 3*aPlus^2*kTrans^3*mMinus*qTrans^3*x1*x3 + 
      aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x1*x3 + 4*aPlus^2*bPlus*kTrans*
       mMinus^2*qTrans^3*x1*x3 + aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x1*
       x3 + aPlus^2*kTrans^2*mMinus*qTrans^4*x1*x3 + 
      3*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x1*x3 + 2*aPlus^2*bPlus*mMinus^2*
       qTrans^4*x1*x3 + aPlus*bPlus^2*mMinus^2*qTrans^4*x1*x3 + 
      3*aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*x3 + aPlus*bPlus*mMinus*
       qTrans^6*x1*x3 + aPlus^2*kTrans^5*lambdaOS*mMinus*qTrans*x1^2*x3 + 
      aPlus^3*kTrans^3*lambdaOS*mMinus^2*qTrans*x1^2*x3 + 
      2*aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x1^2*x3 + 
      aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1^2*x3 + 
      aPlus^2*bPlus^2*kTrans*lambdaOS*mMinus^3*qTrans*x1^2*x3 + 
      3*aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1^2*x3 + 
      aPlus^3*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1^2*x3 + 
      3*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1^2*x3 + 
      3*aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1^2*x3 + 
      aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1^2*x3 + 
      aPlus^2*kTrans^2*lambdaOS*mMinus*qTrans^4*x1^2*x3 + 
      aPlus^2*kTrans^5*lambdaOS*mMinus*qTrans*x1*x3^2 + 
      2*aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x3^2 + 
      aPlus^2*bPlus^2*kTrans*lambdaOS*mMinus^3*qTrans*x1*x3^2 + 
      2*aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*x3^2 + 
      3*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x3^2 + 
      aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x1*x3^2 + 
      aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x3^2 + 
      aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x3^2 + 
      aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3^2 + 
      aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3^2 + 
      2*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x3^2 + 
      aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x1*x3^2 + 
      aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*x3^2 + 
      aPlus^3*kTrans^4*mMinus^2*x1*x5 + aPlus^3*bPlus*kTrans^2*mMinus^3*x1*
       x5 + aPlus^2*kTrans^5*mMinus*qTrans*x1*x5 + 2*aPlus^3*kTrans^3*
       mMinus^2*qTrans*x1*x5 + aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x1*x5 + 
      2*aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x1*x5 + 
      3*aPlus^2*kTrans^4*mMinus*qTrans^2*x1*x5 + aPlus^3*kTrans^2*mMinus^2*
       qTrans^2*x1*x5 + 4*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x1*x5 + 
      aPlus^3*bPlus*mMinus^3*qTrans^2*x1*x5 + 3*aPlus^2*kTrans^3*mMinus*
       qTrans^3*x1*x5 + aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x1*x5 + 
      5*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x1*x5 + 
      aPlus^2*kTrans^2*mMinus*qTrans^4*x1*x5 + 3*aPlus*bPlus*kTrans^2*mMinus*
       qTrans^4*x1*x5 + 2*aPlus^2*bPlus*mMinus^2*qTrans^4*x1*x5 + 
      3*aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*x5 + aPlus*bPlus*mMinus*
       qTrans^6*x1*x5 + aPlus^3*kTrans^4*lambdaOS*mMinus^2*x1^2*x5 + 
      aPlus^3*bPlus*kTrans^2*lambdaOS*mMinus^3*x1^2*x5 + 
      aPlus^2*kTrans^5*lambdaOS*mMinus*qTrans*x1^2*x5 + 
      2*aPlus^3*kTrans^3*lambdaOS*mMinus^2*qTrans*x1^2*x5 + 
      aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x1^2*x5 + 
      aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1^2*x5 + 
      3*aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1^2*x5 + 
      aPlus^3*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1^2*x5 + 
      2*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1^2*x5 + 
      3*aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1^2*x5 + 
      aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1^2*x5 + 
      aPlus^2*kTrans^2*lambdaOS*mMinus*qTrans^4*x1^2*x5 + 
      aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x3*x5 + 
      aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x3*x5 + aPlus^2*bPlus^2*kTrans*
       mMinus^3*qTrans*x3*x5 + aPlus*bPlus*kTrans^4*mMinus*qTrans^2*x3*x5 + 
      4*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x3*x5 + 
      aPlus*bPlus^2*kTrans^2*mMinus^2*qTrans^2*x3*x5 + 
      aPlus^3*bPlus*mMinus^3*qTrans^2*x3*x5 + aPlus^2*bPlus^2*mMinus^3*
       qTrans^2*x3*x5 + 4*aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x3*x5 + 
      5*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x3*x5 + 
      2*aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x3*x5 + 
      6*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x3*x5 + 2*aPlus^2*bPlus*mMinus^2*
       qTrans^4*x3*x5 + aPlus*bPlus^2*mMinus^2*qTrans^4*x3*x5 + 
      4*aPlus*bPlus*kTrans*mMinus*qTrans^5*x3*x5 + aPlus*bPlus*mMinus*
       qTrans^6*x3*x5 + aPlus^2*kTrans^6*lambdaOS*mMinus*x1*x3*x5 + 
      2*aPlus^2*bPlus*kTrans^4*lambdaOS*mMinus^2*x1*x3*x5 + 
      aPlus^2*bPlus^2*kTrans^2*lambdaOS*mMinus^3*x1*x3*x5 + 
      5*aPlus^2*kTrans^5*lambdaOS*mMinus*qTrans*x1*x3*x5 + 
      3*aPlus^3*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x3*x5 + 
      11*aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x3*x5 + 
      3*aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1*x3*x5 + 
      6*aPlus^2*bPlus^2*kTrans*lambdaOS*mMinus^3*qTrans*x1*x3*x5 + 
      10*aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*x3*x5 + 
      3*aPlus*bPlus*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*x3*x5 + 
      3*aPlus^3*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x3*x5 + 
      15*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x3*x5 + 
      3*aPlus*bPlus^2*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x3*x5 + 
      aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x1*x3*x5 + 
      3*aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x1*x3*x5 + 
      9*aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x3*x5 + 
      9*aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x3*x5 + 
      8*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3*x5 + 
      6*aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3*x5 + 
      3*aPlus^2*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x3*x5 + 
      10*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x3*x5 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x1*x3*x5 + 
      3*aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x1*x3*x5 + 
      5*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*x3*x5 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x1*x3*x5 + 
      aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x3^2*x5 + 
      aPlus^2*bPlus^2*kTrans*lambdaOS*mMinus^3*qTrans*x3^2*x5 + 
      aPlus*bPlus*kTrans^4*lambdaOS*mMinus*qTrans^2*x3^2*x5 + 
      2*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3^2*x5 + 
      aPlus*bPlus^2*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3^2*x5 + 
      aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x3^2*x5 + 
      3*aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x3^2*x5 + 
      aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x3^2*x5 + 
      2*aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x3^2*x5 + 
      3*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x3^2*x5 + 
      aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x3^2*x5 + 
      aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x3^2*x5 + 
      aPlus^3*kTrans^4*lambdaOS*mMinus^2*x1*x5^2 + aPlus^3*bPlus*kTrans^2*
       lambdaOS*mMinus^3*x1*x5^2 + aPlus^2*kTrans^5*lambdaOS*mMinus*qTrans*x1*
       x5^2 + aPlus^3*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x5^2 + 
      aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x5^2 + 
      aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1*x5^2 + 
      2*aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*x5^2 + 
      3*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x5^2 + 
      aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x5^2 + 
      aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x5^2 + 
      2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x5^2 + 
      2*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x5^2 + 
      aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*x5^2 + 
      aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x3*x5^2 + 
      aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x3*x5^2 + 
      aPlus^2*bPlus^2*kTrans*lambdaOS*mMinus^3*qTrans*x3*x5^2 + 
      aPlus*bPlus*kTrans^4*lambdaOS*mMinus*qTrans^2*x3*x5^2 + 
      3*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3*x5^2 + 
      aPlus*bPlus^2*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3*x5^2 + 
      3*aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x3*x5^2 + 
      2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*x5^2 + 
      aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*x5^2 + 
      3*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x3*x5^2 + 
      aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x3*x5^2 + 
      aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x3*y0 + 
      aPlus^3*bPlus*mMinus^3*qTrans^2*x3*y0 + aPlus^2*bPlus^2*mMinus^3*
       qTrans^2*x3*y0 + aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x3*y0 + 
      3*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x3*y0 + 
      aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x3*y0 + 
      3*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x3*y0 + 2*aPlus^2*bPlus*mMinus^2*
       qTrans^4*x3*y0 + aPlus*bPlus^2*mMinus^2*qTrans^4*x3*y0 + 
      3*aPlus*bPlus*kTrans*mMinus*qTrans^5*x3*y0 + aPlus*bPlus*mMinus*
       qTrans^6*x3*y0 + aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*
       x3*y0 + aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x1*x3*y0 + 
      aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x1*x3*y0 + 
      aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x3*y0 + 
      3*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3*y0 + 
      aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3*y0 + 
      3*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x3*y0 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x1*x3*y0 + 
      aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x1*x3*y0 + 
      3*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*x3*y0 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x1*x3*y0 + 
      aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3^2*y0 + 
      aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x3^2*y0 + 
      aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x3^2*y0 + 
      aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x3^2*y0 + 
      aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x3^2*y0 + 
      2*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x3^2*y0 + 
      aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x3^2*y0 + 
      aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x3^2*y0 + 
      aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x5*y0 + 2*aPlus^2*bPlus*kTrans^2*
       mMinus^2*qTrans^2*x5*y0 + aPlus^3*bPlus*mMinus^3*qTrans^2*x5*y0 + 
      aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x5*y0 + 4*aPlus^2*bPlus*kTrans*
       mMinus^2*qTrans^3*x5*y0 + 3*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x5*
       y0 + 2*aPlus^2*bPlus*mMinus^2*qTrans^4*x5*y0 + 
      3*aPlus*bPlus*kTrans*mMinus*qTrans^5*x5*y0 + aPlus*bPlus*mMinus*
       qTrans^6*x5*y0 + aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1*x5*
       y0 + 2*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x5*y0 + 
      aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x1*x5*y0 + 
      aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x5*y0 + 
      4*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x5*y0 + 
      3*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x5*y0 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x1*x5*y0 + 
      3*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*x5*y0 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x1*x5*y0 + 
      aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x3*x5*y0 + 
      aPlus^2*bPlus^2*kTrans*lambdaOS*mMinus^3*qTrans*x3*x5*y0 + 
      aPlus*bPlus*kTrans^4*lambdaOS*mMinus*qTrans^2*x3*x5*y0 + 
      4*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3*x5*y0 + 
      aPlus*bPlus^2*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3*x5*y0 + 
      3*aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x3*x5*y0 + 
      3*aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x3*x5*y0 + 
      5*aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x3*x5*y0 + 
      9*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*x5*y0 + 
      4*aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*x5*y0 + 
      10*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x3*x5*y0 + 
      6*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x3*x5*y0 + 
      3*aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x3*x5*y0 + 
      9*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x3*x5*y0 + 
      3*aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x3*x5*y0 + 
      aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x5^2*y0 + 
      2*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x5^2*y0 + 
      aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x5^2*y0 + 
      2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x5^2*y0 + 
      2*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x5^2*y0 + 
      aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x5^2*y0 + 
      aPlus^3*kTrans^3*mMinus^2*qTrans*x1*y2 + aPlus^3*bPlus*kTrans*mMinus^3*
       qTrans*x1*y2 + aPlus^2*kTrans^4*mMinus*qTrans^2*x1*y2 + 
      aPlus^3*kTrans^2*mMinus^2*qTrans^2*x1*y2 + aPlus^2*bPlus*kTrans^2*
       mMinus^2*qTrans^2*x1*y2 + aPlus^3*bPlus*mMinus^3*qTrans^2*x1*y2 + 
      2*aPlus^2*kTrans^3*mMinus*qTrans^3*x1*y2 + 3*aPlus^2*bPlus*kTrans*
       mMinus^2*qTrans^3*x1*y2 + aPlus^2*kTrans^2*mMinus*qTrans^4*x1*y2 + 
      aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x1*y2 + 2*aPlus^2*bPlus*mMinus^2*
       qTrans^4*x1*y2 + 2*aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*y2 + 
      aPlus*bPlus*mMinus*qTrans^6*x1*y2 + aPlus^3*kTrans^3*lambdaOS*mMinus^2*
       qTrans*x1^2*y2 + aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1^2*
       y2 + aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1^2*y2 + 
      aPlus^3*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1^2*y2 + 
      aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1^2*y2 + 
      2*aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1^2*y2 + 
      aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1^2*y2 + 
      aPlus^2*kTrans^2*lambdaOS*mMinus*qTrans^4*x1^2*y2 + 
      aPlus^3*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x3*y2 + 
      aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1*x3*y2 + 
      aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*x3*y2 + 
      aPlus^3*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x3*y2 + 
      aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x3*y2 + 
      aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x1*x3*y2 + 
      2*aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x3*y2 + 
      3*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3*y2 + 
      aPlus^2*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x3*y2 + 
      aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x3*y2 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x1*x3*y2 + 
      2*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*x3*y2 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x1*x3*y2 + 
      aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x5*y2 + 2*aPlus^2*bPlus*kTrans^2*
       mMinus^2*qTrans^2*x5*y2 + aPlus^3*bPlus*mMinus^3*qTrans^2*x5*y2 + 
      aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x5*y2 + 4*aPlus^2*bPlus*kTrans*
       mMinus^2*qTrans^3*x5*y2 + 3*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x5*
       y2 + 2*aPlus^2*bPlus*mMinus^2*qTrans^4*x5*y2 + 
      3*aPlus*bPlus*kTrans*mMinus*qTrans^5*x5*y2 + aPlus*bPlus*mMinus*
       qTrans^6*x5*y2 + aPlus^3*kTrans^4*lambdaOS*mMinus^2*x1*x5*y2 + 
      aPlus^3*bPlus*kTrans^2*lambdaOS*mMinus^3*x1*x5*y2 + 
      aPlus^2*kTrans^5*lambdaOS*mMinus*qTrans*x1*x5*y2 + 
      4*aPlus^3*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x5*y2 + 
      aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x5*y2 + 
      6*aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1*x5*y2 + 
      5*aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*x5*y2 + 
      3*aPlus^3*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x5*y2 + 
      10*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x5*y2 + 
      3*aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x1*x5*y2 + 
      7*aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x5*y2 + 
      3*aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x5*y2 + 
      15*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x5*y2 + 
      3*aPlus^2*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x5*y2 + 
      9*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x5*y2 + 
      6*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x1*x5*y2 + 
      9*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*x5*y2 + 
      3*aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x1*x5*y2 + 
      aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x3*x5*y2 + 
      2*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3*x5*y2 + 
      aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x3*x5*y2 + 
      aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x3*x5*y2 + 
      4*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*x5*y2 + 
      3*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x3*x5*y2 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x3*x5*y2 + 
      3*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x3*x5*y2 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x3*x5*y2 + 
      aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x5^2*y2 + 
      2*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x5^2*y2 + 
      aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x5^2*y2 + 
      2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x5^2*y2 + 
      2*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x5^2*y2 + 
      aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x5^2*y2 + 
      aPlus^3*bPlus*mMinus^3*qTrans^2*y0*y2 + 2*aPlus^2*bPlus*kTrans*mMinus^2*
       qTrans^3*y0*y2 + aPlus*bPlus*kTrans^2*mMinus*qTrans^4*y0*y2 + 
      2*aPlus^2*bPlus*mMinus^2*qTrans^4*y0*y2 + 2*aPlus*bPlus*kTrans*mMinus*
       qTrans^5*y0*y2 + aPlus*bPlus*mMinus*qTrans^6*y0*y2 + 
      aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x1*y0*y2 + 
      2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*y0*y2 + 
      aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*y0*y2 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x1*y0*y2 + 
      2*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*y0*y2 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x1*y0*y2 + 
      aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x3*y0*y2 + 
      2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*y0*y2 + 
      aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x3*y0*y2 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x3*y0*y2 + 
      2*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x3*y0*y2 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x3*y0*y2 + 
      aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x5*y0*y2 + 
      2*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x5*y0*y2 + 
      3*aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x5*y0*y2 + 
      aPlus^4*bPlus*mMinus^4*qTrans^2*x5*y0*y2 + aPlus*bPlus*kTrans^3*
       lambdaOS*mMinus*qTrans^3*x5*y0*y2 + 8*aPlus^2*bPlus*kTrans*lambdaOS*
       mMinus^2*qTrans^3*x5*y0*y2 + 4*aPlus^3*bPlus*kTrans*mMinus^3*qTrans^3*
       x5*y0*y2 + 5*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x5*y0*y2 + 
      6*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^4*x5*y0*y2 + 
      6*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x5*y0*y2 + 
      4*aPlus^3*bPlus*mMinus^3*qTrans^4*x5*y0*y2 + 4*aPlus*bPlus*kTrans^3*
       mMinus*qTrans^5*x5*y0*y2 + 7*aPlus*bPlus*kTrans*lambdaOS*mMinus*
       qTrans^5*x5*y0*y2 + 12*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^5*x5*y0*
       y2 + bPlus*kTrans^4*qTrans^6*x5*y0*y2 + 12*aPlus*bPlus*kTrans^2*mMinus*
       qTrans^6*x5*y0*y2 + 3*aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x5*y0*y2 + 
      6*aPlus^2*bPlus*mMinus^2*qTrans^6*x5*y0*y2 + 4*bPlus*kTrans^3*qTrans^7*
       x5*y0*y2 + 12*aPlus*bPlus*kTrans*mMinus*qTrans^7*x5*y0*y2 + 
      6*bPlus*kTrans^2*qTrans^8*x5*y0*y2 + 4*aPlus*bPlus*mMinus*qTrans^8*x5*
       y0*y2 + 4*bPlus*kTrans*qTrans^9*x5*y0*y2 + bPlus*qTrans^10*x5*y0*y2 + 
      aPlus^3*kTrans^3*mMinus^2*qTrans*x1*y4 + aPlus^3*bPlus*kTrans*mMinus^3*
       qTrans*x1*y4 + aPlus^2*kTrans^4*mMinus*qTrans^2*x1*y4 + 
      aPlus^3*kTrans^2*mMinus^2*qTrans^2*x1*y4 + aPlus^2*bPlus*kTrans^2*
       mMinus^2*qTrans^2*x1*y4 + aPlus^3*bPlus*mMinus^3*qTrans^2*x1*y4 + 
      2*aPlus^2*kTrans^3*mMinus*qTrans^3*x1*y4 + 3*aPlus^2*bPlus*kTrans*
       mMinus^2*qTrans^3*x1*y4 + aPlus^2*kTrans^2*mMinus*qTrans^4*x1*y4 + 
      aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x1*y4 + 2*aPlus^2*bPlus*mMinus^2*
       qTrans^4*x1*y4 + 2*aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*y4 + 
      aPlus*bPlus*mMinus*qTrans^6*x1*y4 + aPlus^3*kTrans^3*lambdaOS*mMinus^2*
       qTrans*x1^2*y4 + aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1^2*
       y4 + aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1^2*y4 + 
      aPlus^3*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1^2*y4 + 
      aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1^2*y4 + 
      2*aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1^2*y4 + 
      aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1^2*y4 + 
      aPlus^2*kTrans^2*lambdaOS*mMinus*qTrans^4*x1^2*y4 + 
      aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x3*y4 + 
      aPlus^3*bPlus*mMinus^3*qTrans^2*x3*y4 + aPlus^2*bPlus^2*mMinus^3*
       qTrans^2*x3*y4 + aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x3*y4 + 
      3*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x3*y4 + 
      aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x3*y4 + 
      3*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x3*y4 + 2*aPlus^2*bPlus*mMinus^2*
       qTrans^4*x3*y4 + aPlus*bPlus^2*mMinus^2*qTrans^4*x3*y4 + 
      3*aPlus*bPlus*kTrans*mMinus*qTrans^5*x3*y4 + aPlus*bPlus*mMinus*
       qTrans^6*x3*y4 + aPlus^2*kTrans^5*lambdaOS*mMinus*qTrans*x1*x3*y4 + 
      2*aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x3*y4 + 
      aPlus^2*bPlus^2*kTrans*lambdaOS*mMinus^3*qTrans*x1*x3*y4 + 
      2*aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*x3*y4 + 
      5*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x3*y4 + 
      3*aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x1*x3*y4 + 
      aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x3*y4 + 
      3*aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x3*y4 + 
      3*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3*y4 + 
      3*aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3*y4 + 
      6*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x3*y4 + 
      3*aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x1*x3*y4 + 
      3*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*x3*y4 + 
      aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3^2*y4 + 
      aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x3^2*y4 + 
      aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x3^2*y4 + 
      aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x3^2*y4 + 
      aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x3^2*y4 + 
      2*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x3^2*y4 + 
      aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x3^2*y4 + 
      aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x3^2*y4 + 
      aPlus^3*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x5*y4 + 
      aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1*x5*y4 + 
      aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*x5*y4 + 
      aPlus^3*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x5*y4 + 
      aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x5*y4 + 
      aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x1*x5*y4 + 
      2*aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x5*y4 + 
      3*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x5*y4 + 
      aPlus^2*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x5*y4 + 
      aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x5*y4 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x1*x5*y4 + 
      2*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*x5*y4 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x1*x5*y4 + 
      aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3*x5*y4 + 
      aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x3*x5*y4 + 
      aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x3*x5*y4 + 
      aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x3*x5*y4 + 
      3*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*x5*y4 + 
      aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*x5*y4 + 
      3*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x3*x5*y4 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x3*x5*y4 + 
      aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x3*x5*y4 + 
      3*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x3*x5*y4 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x3*x5*y4 + 
      aPlus^3*bPlus*mMinus^3*qTrans^2*y0*y4 + 2*aPlus^2*bPlus*kTrans*mMinus^2*
       qTrans^3*y0*y4 + aPlus*bPlus*kTrans^2*mMinus*qTrans^4*y0*y4 + 
      2*aPlus^2*bPlus*mMinus^2*qTrans^4*y0*y4 + 2*aPlus*bPlus*kTrans*mMinus*
       qTrans^5*y0*y4 + aPlus*bPlus*mMinus*qTrans^6*y0*y4 + 
      aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x1*y0*y4 + 
      2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*y0*y4 + 
      aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*y0*y4 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x1*y0*y4 + 
      2*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*y0*y4 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x1*y0*y4 + 
      aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3*y0*y4 + 
      aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x3*y0*y4 + 
      aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x3*y0*y4 + 
      aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*y0*y4 + 
      aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*y0*y4 + 
      2*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x3*y0*y4 - 
      aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^4*x3*y0*y4 + 
      aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x3*y0*y4 - 
      aPlus^3*bPlus*mMinus^3*qTrans^4*x3*y0*y4 - aPlus^2*bPlus^2*mMinus^3*
       qTrans^4*x3*y0*y4 - 2*aPlus*bPlus*kTrans^3*mMinus*qTrans^5*x3*y0*y4 + 
      aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x3*y0*y4 - 
      4*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^5*x3*y0*y4 - 
      2*aPlus*bPlus^2*kTrans*mMinus^2*qTrans^5*x3*y0*y4 - 
      bPlus*kTrans^4*qTrans^6*x3*y0*y4 - 7*aPlus*bPlus*kTrans^2*mMinus*
       qTrans^6*x3*y0*y4 - bPlus^2*kTrans^2*mMinus*qTrans^6*x3*y0*y4 - 
      3*aPlus^2*bPlus*mMinus^2*qTrans^6*x3*y0*y4 - 2*aPlus*bPlus^2*mMinus^2*
       qTrans^6*x3*y0*y4 - 4*bPlus*kTrans^3*qTrans^7*x3*y0*y4 - 
      8*aPlus*bPlus*kTrans*mMinus*qTrans^7*x3*y0*y4 - 
      2*bPlus^2*kTrans*mMinus*qTrans^7*x3*y0*y4 - 6*bPlus*kTrans^2*qTrans^8*
       x3*y0*y4 - 3*aPlus*bPlus*mMinus*qTrans^8*x3*y0*y4 - 
      bPlus^2*mMinus*qTrans^8*x3*y0*y4 - 4*bPlus*kTrans*qTrans^9*x3*y0*y4 - 
      bPlus*qTrans^10*x3*y0*y4 + aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x5*
       y0*y4 + 2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x5*y0*y4 + 
      aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x5*y0*y4 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x5*y0*y4 + 
      2*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x5*y0*y4 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x5*y0*y4 + 
      aPlus^3*bPlus*mMinus^3*qTrans^2*y2*y4 + 2*aPlus^2*bPlus*kTrans*mMinus^2*
       qTrans^3*y2*y4 + aPlus*bPlus*kTrans^2*mMinus*qTrans^4*y2*y4 + 
      2*aPlus^2*bPlus*mMinus^2*qTrans^4*y2*y4 + 2*aPlus*bPlus*kTrans*mMinus*
       qTrans^5*y2*y4 + aPlus*bPlus*mMinus*qTrans^6*y2*y4 + 
      aPlus^3*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*y2*y4 + 
      aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1*y2*y4 + 
      aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*y2*y4 + 
      aPlus^3*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*y2*y4 + 
      aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*y2*y4 - 
      aPlus^4*kTrans^2*mMinus^3*qTrans^2*x1*y2*y4 + 3*aPlus^3*bPlus*lambdaOS*
       mMinus^3*qTrans^2*x1*y2*y4 - aPlus^4*bPlus*mMinus^4*qTrans^2*x1*y2*
       y4 + 2*aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*y2*y4 - 
      2*aPlus^3*kTrans^3*mMinus^2*qTrans^3*x1*y2*y4 + 
      7*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*y2*y4 - 
      2*aPlus^3*bPlus*kTrans*mMinus^3*qTrans^3*x1*y2*y4 - 
      aPlus^2*kTrans^4*mMinus*qTrans^4*x1*y2*y4 + aPlus^2*kTrans^2*lambdaOS*
       mMinus*qTrans^4*x1*y2*y4 + 3*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*
       qTrans^4*x1*y2*y4 - 2*aPlus^3*kTrans^2*mMinus^2*qTrans^4*x1*y2*y4 - 
      aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^4*x1*y2*y4 + 
      6*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x1*y2*y4 - 
      3*aPlus^3*bPlus*mMinus^3*qTrans^4*x1*y2*y4 - 2*aPlus^2*kTrans^3*mMinus*
       qTrans^5*x1*y2*y4 + 6*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*
       y2*y4 - 4*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^5*x1*y2*y4 - 
      aPlus^2*kTrans^2*mMinus*qTrans^6*x1*y2*y4 - aPlus*bPlus*kTrans^2*mMinus*
       qTrans^6*x1*y2*y4 + 3*aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x1*y2*y4 - 
      3*aPlus^2*bPlus*mMinus^2*qTrans^6*x1*y2*y4 - 2*aPlus*bPlus*kTrans*
       mMinus*qTrans^7*x1*y2*y4 - aPlus*bPlus*mMinus*qTrans^8*x1*y2*y4 + 
      aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x3*y2*y4 + 
      2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*y2*y4 + 
      aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x3*y2*y4 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x3*y2*y4 + 
      2*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x3*y2*y4 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x3*y2*y4 + 
      aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x5*y2*y4 + 
      2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x5*y2*y4 + 
      aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x5*y2*y4 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x5*y2*y4 + 
      2*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x5*y2*y4 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x5*y2*y4 + 
      aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*y0*y2*y4 + 
      2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*y0*y2*y4 + 
      aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*y0*y2*y4 + 
      2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*y0*y2*y4 + 
      2*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*y0*y2*y4 + 
      aPlus*bPlus*lambdaOS*mMinus*qTrans^6*y0*y2*y4)/
     (aPlus*bPlus*mMinus*qTrans^2*(aPlus*mMinus + kTrans*qTrans + qTrans^2)^
       2), "CommonKinematicDenominator" -> aPlus*bPlus*mMinus*qTrans^2*
     (aPlus*mMinus + kTrans*qTrans + qTrans^2)^2, 
   "LeadingDissectedPolynomial" -> aPlus^2*kTrans^5*mMinus*qTrans*x1*x3 + 
     aPlus^3*kTrans^3*mMinus^2*qTrans*x1*x3 + 2*aPlus^2*bPlus*kTrans^3*
      mMinus^2*qTrans*x1*x3 + aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x1*x3 + 
     aPlus^2*bPlus^2*kTrans*mMinus^3*qTrans*x1*x3 + 
     3*aPlus^2*kTrans^4*mMinus*qTrans^2*x1*x3 + aPlus^3*kTrans^2*mMinus^2*
      qTrans^2*x1*x3 + 4*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x1*x3 + 
     aPlus^3*bPlus*mMinus^3*qTrans^2*x1*x3 + aPlus^2*bPlus^2*mMinus^3*
      qTrans^2*x1*x3 + 3*aPlus^2*kTrans^3*mMinus*qTrans^3*x1*x3 + 
     aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x1*x3 + 4*aPlus^2*bPlus*kTrans*
      mMinus^2*qTrans^3*x1*x3 + aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x1*
      x3 + aPlus^2*kTrans^2*mMinus*qTrans^4*x1*x3 + 
     3*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x1*x3 + 
     2*aPlus^2*bPlus*mMinus^2*qTrans^4*x1*x3 + aPlus*bPlus^2*mMinus^2*
      qTrans^4*x1*x3 + 3*aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*x3 + 
     aPlus*bPlus*mMinus*qTrans^6*x1*x3 + aPlus^2*kTrans^5*lambdaOS*mMinus*
      qTrans*x1^2*x3 + aPlus^3*kTrans^3*lambdaOS*mMinus^2*qTrans*x1^2*x3 + 
     2*aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x1^2*x3 + 
     aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1^2*x3 + 
     aPlus^2*bPlus^2*kTrans*lambdaOS*mMinus^3*qTrans*x1^2*x3 + 
     3*aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1^2*x3 + 
     aPlus^3*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1^2*x3 + 
     3*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1^2*x3 + 
     3*aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1^2*x3 + 
     aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1^2*x3 + 
     aPlus^2*kTrans^2*lambdaOS*mMinus*qTrans^4*x1^2*x3 + 
     aPlus^2*kTrans^5*lambdaOS*mMinus*qTrans*x1*x3^2 + 
     2*aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x3^2 + 
     aPlus^2*bPlus^2*kTrans*lambdaOS*mMinus^3*qTrans*x1*x3^2 + 
     2*aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*x3^2 + 
     3*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x3^2 + 
     aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x1*x3^2 + 
     aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x3^2 + 
     aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x3^2 + 
     aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3^2 + 
     aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3^2 + 
     2*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x3^2 + 
     aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x1*x3^2 + 
     aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*x3^2 + 
     aPlus^3*kTrans^4*mMinus^2*x1*x5 + aPlus^3*bPlus*kTrans^2*mMinus^3*x1*
      x5 + aPlus^2*kTrans^5*mMinus*qTrans*x1*x5 + 2*aPlus^3*kTrans^3*mMinus^2*
      qTrans*x1*x5 + aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x1*x5 + 
     2*aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x1*x5 + 
     3*aPlus^2*kTrans^4*mMinus*qTrans^2*x1*x5 + aPlus^3*kTrans^2*mMinus^2*
      qTrans^2*x1*x5 + 4*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x1*x5 + 
     aPlus^3*bPlus*mMinus^3*qTrans^2*x1*x5 + 3*aPlus^2*kTrans^3*mMinus*
      qTrans^3*x1*x5 + aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x1*x5 + 
     5*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x1*x5 + 
     aPlus^2*kTrans^2*mMinus*qTrans^4*x1*x5 + 3*aPlus*bPlus*kTrans^2*mMinus*
      qTrans^4*x1*x5 + 2*aPlus^2*bPlus*mMinus^2*qTrans^4*x1*x5 + 
     3*aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*x5 + aPlus*bPlus*mMinus*qTrans^6*
      x1*x5 + aPlus^3*kTrans^4*lambdaOS*mMinus^2*x1^2*x5 + 
     aPlus^3*bPlus*kTrans^2*lambdaOS*mMinus^3*x1^2*x5 + 
     aPlus^2*kTrans^5*lambdaOS*mMinus*qTrans*x1^2*x5 + 
     2*aPlus^3*kTrans^3*lambdaOS*mMinus^2*qTrans*x1^2*x5 + 
     aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x1^2*x5 + 
     aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1^2*x5 + 
     3*aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1^2*x5 + 
     aPlus^3*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1^2*x5 + 
     2*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1^2*x5 + 
     3*aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1^2*x5 + 
     aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1^2*x5 + 
     aPlus^2*kTrans^2*lambdaOS*mMinus*qTrans^4*x1^2*x5 + 
     aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x3*x5 + 
     aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x3*x5 + aPlus^2*bPlus^2*kTrans*
      mMinus^3*qTrans*x3*x5 + aPlus*bPlus*kTrans^4*mMinus*qTrans^2*x3*x5 + 
     4*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x3*x5 + 
     aPlus*bPlus^2*kTrans^2*mMinus^2*qTrans^2*x3*x5 + 
     aPlus^3*bPlus*mMinus^3*qTrans^2*x3*x5 + aPlus^2*bPlus^2*mMinus^3*
      qTrans^2*x3*x5 + 4*aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x3*x5 + 
     5*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x3*x5 + 
     2*aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x3*x5 + 
     6*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x3*x5 + 
     2*aPlus^2*bPlus*mMinus^2*qTrans^4*x3*x5 + aPlus*bPlus^2*mMinus^2*
      qTrans^4*x3*x5 + 4*aPlus*bPlus*kTrans*mMinus*qTrans^5*x3*x5 + 
     aPlus*bPlus*mMinus*qTrans^6*x3*x5 + aPlus^2*kTrans^6*lambdaOS*mMinus*x1*
      x3*x5 + 2*aPlus^2*bPlus*kTrans^4*lambdaOS*mMinus^2*x1*x3*x5 + 
     aPlus^2*bPlus^2*kTrans^2*lambdaOS*mMinus^3*x1*x3*x5 + 
     5*aPlus^2*kTrans^5*lambdaOS*mMinus*qTrans*x1*x3*x5 + 
     3*aPlus^3*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x3*x5 + 
     11*aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x3*x5 + 
     3*aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1*x3*x5 + 
     6*aPlus^2*bPlus^2*kTrans*lambdaOS*mMinus^3*qTrans*x1*x3*x5 + 
     10*aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*x3*x5 + 
     3*aPlus*bPlus*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*x3*x5 + 
     3*aPlus^3*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x3*x5 + 
     15*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x3*x5 + 
     3*aPlus*bPlus^2*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x3*x5 + 
     aPlus^3*bPlus*lambdaOS*mMinus^3*qTrans^2*x1*x3*x5 + 
     3*aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x1*x3*x5 + 
     9*aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x3*x5 + 
     9*aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x3*x5 + 
     8*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3*x5 + 
     6*aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x3*x5 + 
     3*aPlus^2*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x3*x5 + 
     10*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x3*x5 + 
     2*aPlus^2*bPlus*lambdaOS*mMinus^2*qTrans^4*x1*x3*x5 + 
     3*aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x1*x3*x5 + 
     5*aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*x3*x5 + 
     aPlus*bPlus*lambdaOS*mMinus*qTrans^6*x1*x3*x5 + 
     aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x3^2*x5 + 
     aPlus^2*bPlus^2*kTrans*lambdaOS*mMinus^3*qTrans*x3^2*x5 + 
     aPlus*bPlus*kTrans^4*lambdaOS*mMinus*qTrans^2*x3^2*x5 + 
     2*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3^2*x5 + 
     aPlus*bPlus^2*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3^2*x5 + 
     aPlus^2*bPlus^2*lambdaOS*mMinus^3*qTrans^2*x3^2*x5 + 
     3*aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x3^2*x5 + 
     aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x3^2*x5 + 
     2*aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x3^2*x5 + 
     3*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x3^2*x5 + 
     aPlus*bPlus^2*lambdaOS*mMinus^2*qTrans^4*x3^2*x5 + 
     aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x3^2*x5 + 
     aPlus^3*kTrans^4*lambdaOS*mMinus^2*x1*x5^2 + aPlus^3*bPlus*kTrans^2*
      lambdaOS*mMinus^3*x1*x5^2 + aPlus^2*kTrans^5*lambdaOS*mMinus*qTrans*x1*
      x5^2 + aPlus^3*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x5^2 + 
     aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x1*x5^2 + 
     aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x1*x5^2 + 
     2*aPlus^2*kTrans^4*lambdaOS*mMinus*qTrans^2*x1*x5^2 + 
     3*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x1*x5^2 + 
     aPlus^2*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x5^2 + 
     aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x1*x5^2 + 
     2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x1*x5^2 + 
     2*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x1*x5^2 + 
     aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x1*x5^2 + 
     aPlus^2*bPlus*kTrans^3*lambdaOS*mMinus^2*qTrans*x3*x5^2 + 
     aPlus^3*bPlus*kTrans*lambdaOS*mMinus^3*qTrans*x3*x5^2 + 
     aPlus^2*bPlus^2*kTrans*lambdaOS*mMinus^3*qTrans*x3*x5^2 + 
     aPlus*bPlus*kTrans^4*lambdaOS*mMinus*qTrans^2*x3*x5^2 + 
     3*aPlus^2*bPlus*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3*x5^2 + 
     aPlus*bPlus^2*kTrans^2*lambdaOS*mMinus^2*qTrans^2*x3*x5^2 + 
     3*aPlus*bPlus*kTrans^3*lambdaOS*mMinus*qTrans^3*x3*x5^2 + 
     2*aPlus^2*bPlus*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*x5^2 + 
     aPlus*bPlus^2*kTrans*lambdaOS*mMinus^2*qTrans^3*x3*x5^2 + 
     3*aPlus*bPlus*kTrans^2*lambdaOS*mMinus*qTrans^4*x3*x5^2 + 
     aPlus*bPlus*kTrans*lambdaOS*mMinus*qTrans^5*x3*x5^2 + 
     aPlus^4*bPlus*mMinus^4*qTrans^2*x5*y0*y2 + 4*aPlus^3*bPlus*kTrans*
      mMinus^3*qTrans^3*x5*y0*y2 + 6*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^4*
      x5*y0*y2 + 4*aPlus^3*bPlus*mMinus^3*qTrans^4*x5*y0*y2 + 
     4*aPlus*bPlus*kTrans^3*mMinus*qTrans^5*x5*y0*y2 + 
     12*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^5*x5*y0*y2 + 
     bPlus*kTrans^4*qTrans^6*x5*y0*y2 + 12*aPlus*bPlus*kTrans^2*mMinus*
      qTrans^6*x5*y0*y2 + 6*aPlus^2*bPlus*mMinus^2*qTrans^6*x5*y0*y2 + 
     4*bPlus*kTrans^3*qTrans^7*x5*y0*y2 + 12*aPlus*bPlus*kTrans*mMinus*
      qTrans^7*x5*y0*y2 + 6*bPlus*kTrans^2*qTrans^8*x5*y0*y2 + 
     4*aPlus*bPlus*mMinus*qTrans^8*x5*y0*y2 + 4*bPlus*kTrans*qTrans^9*x5*y0*
      y2 + bPlus*qTrans^10*x5*y0*y2 - aPlus^2*bPlus*kTrans^2*mMinus^2*
      qTrans^4*x3*y0*y4 - aPlus^3*bPlus*mMinus^3*qTrans^4*x3*y0*y4 - 
     aPlus^2*bPlus^2*mMinus^3*qTrans^4*x3*y0*y4 - 2*aPlus*bPlus*kTrans^3*
      mMinus*qTrans^5*x3*y0*y4 - 4*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^5*x3*
      y0*y4 - 2*aPlus*bPlus^2*kTrans*mMinus^2*qTrans^5*x3*y0*y4 - 
     bPlus*kTrans^4*qTrans^6*x3*y0*y4 - 7*aPlus*bPlus*kTrans^2*mMinus*
      qTrans^6*x3*y0*y4 - bPlus^2*kTrans^2*mMinus*qTrans^6*x3*y0*y4 - 
     3*aPlus^2*bPlus*mMinus^2*qTrans^6*x3*y0*y4 - 2*aPlus*bPlus^2*mMinus^2*
      qTrans^6*x3*y0*y4 - 4*bPlus*kTrans^3*qTrans^7*x3*y0*y4 - 
     8*aPlus*bPlus*kTrans*mMinus*qTrans^7*x3*y0*y4 - 
     2*bPlus^2*kTrans*mMinus*qTrans^7*x3*y0*y4 - 6*bPlus*kTrans^2*qTrans^8*x3*
      y0*y4 - 3*aPlus*bPlus*mMinus*qTrans^8*x3*y0*y4 - 
     bPlus^2*mMinus*qTrans^8*x3*y0*y4 - 4*bPlus*kTrans*qTrans^9*x3*y0*y4 - 
     bPlus*qTrans^10*x3*y0*y4 - aPlus^4*kTrans^2*mMinus^3*qTrans^2*x1*y2*y4 - 
     aPlus^4*bPlus*mMinus^4*qTrans^2*x1*y2*y4 - 2*aPlus^3*kTrans^3*mMinus^2*
      qTrans^3*x1*y2*y4 - 2*aPlus^3*bPlus*kTrans*mMinus^3*qTrans^3*x1*y2*y4 - 
     aPlus^2*kTrans^4*mMinus*qTrans^4*x1*y2*y4 - 2*aPlus^3*kTrans^2*mMinus^2*
      qTrans^4*x1*y2*y4 - aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^4*x1*y2*y4 - 
     3*aPlus^3*bPlus*mMinus^3*qTrans^4*x1*y2*y4 - 2*aPlus^2*kTrans^3*mMinus*
      qTrans^5*x1*y2*y4 - 4*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^5*x1*y2*y4 - 
     aPlus^2*kTrans^2*mMinus*qTrans^6*x1*y2*y4 - aPlus*bPlus*kTrans^2*mMinus*
      qTrans^6*x1*y2*y4 - 3*aPlus^2*bPlus*mMinus^2*qTrans^6*x1*y2*y4 - 
     2*aPlus*bPlus*kTrans*mMinus*qTrans^7*x1*y2*y4 - 
     aPlus*bPlus*mMinus*qTrans^8*x1*y2*y4|>, "InvariantSymmetricForm" -> 
  <|"PathEdgePairs" -> <|"A" -> {x0, x1}, "B" -> {x2, x3}, "C" -> {x4, x5}|>, 
   "PathScaleVariables" -> {x1, x3, x5}, "PathRatioDefinitions" -> 
    {rA == x0/x1, rB == x2/x3, rC == x4/x5}, "QuadraticCoefficients" -> 
    <|qAB -> s12 - s34 - s45, qBC -> -s12 - s23 + s45, qCA -> s23|>, 
   "LinearCoefficients" -> <|ellA -> -s15 + s23 - s45, 
     ellB -> s15 - s23 - s34, ellC -> s45|>, "RatioPolynomial" -> 
    rA*rB*s12 - rB*rC*s12 - rA*s15 + rB*s15 + rA*s23 - rB*s23 + rA*rC*s23 - 
     rB*rC*s23 - rB*s34 - rA*rB*s34 - rA*s45 - rA*rB*s45 + rC*s45 + 
     rB*rC*s45, "StationarityMatrix" -> {{0, s12 - s34 - s45, s23}, 
     {s12 - s34 - s45, 0, -s12 - s23 + s45}, {s23, -s12 - s23 + s45, 0}}, 
   "StationaryRatioVector" -> 
    {-1/2*(-(s12*s15) + s12*s23 - s23*s34 + s15*s45 - 2*s23*s45 - s34*s45)/
       (s23*(s12 - s34 - s45)), -1/2*(-(s12*s15) + s12*s23 - s23*s34 - 
        2*s12*s45 + s15*s45 - 2*s23*s45 + s34*s45 + 2*s45^2)/
       ((s12 + s23 - s45)*(s12 - s34 - s45)), 
     -1/2*(-(s12*s15) + s12*s23 - 2*s15*s23 + 2*s23^2 + s23*s34 + s15*s45 - 
        2*s23*s45 - s34*s45)/(s23*(s12 + s23 - s45))}, 
   "StationaryValue" -> -1/4*(s12^2*s15^2 - 2*s12^2*s15*s23 + s12^2*s23^2 + 
       2*s12*s15*s23*s34 - 2*s12*s23^2*s34 + s23^2*s34^2 - 2*s12*s15^2*s45 + 
       2*s12*s15*s23*s45 + 2*s12*s15*s34*s45 + 2*s12*s23*s34*s45 + 
       2*s15*s23*s34*s45 - 2*s23*s34^2*s45 + s15^2*s45^2 - 2*s15*s34*s45^2 + 
       s34^2*s45^2)/(s23*(s12 + s23 - s45)*(s12 - s34 - s45)), 
   "StationaryValueAsGram" -> (s12^2*s15^2 - 2*s12^2*s15*s23 + s12^2*s23^2 + 
      2*s12*s15*s23*s34 - 2*s12*s23^2*s34 + s23^2*s34^2 - 2*s12*s15^2*s45 + 
      2*s12*s15*s23*s45 + 2*s12*s15*s34*s45 + 2*s12*s23*s34*s45 + 
      2*s15*s23*s34*s45 - 2*s23*s34^2*s45 + s15^2*s45^2 - 2*s15*s34*s45^2 + 
      s34^2*s45^2)/(4*s23*(s12 - s34 - s45)*(-s12 - s23 + s45)), 
   "GramDeterminantConvention" -> Gamma5 == epsilon5^2 == 
     s12^2*s15^2 - 2*s12^2*s15*s23 + s12^2*s23^2 + 2*s12*s15*s23*s34 - 
      2*s12*s23^2*s34 + s23^2*s34^2 - 2*s12*s15^2*s45 + 2*s12*s15*s23*s45 + 
      2*s12*s15*s34*s45 + 2*s12*s23*s34*s45 + 2*s15*s23*s34*s45 - 
      2*s23*s34^2*s45 + s15^2*s45^2 - 2*s15*s34*s45^2 + s34^2*s45^2, 
   "PhysicalInteriorBranch" -> Gamma5 < 0 && (-I)*epsilon5 == Sqrt[-Gamma5], 
   "PhysicalBoundaryApproach" -> {Gamma5 -> 0, (-I)*epsilon5 -> 0}, 
   "OriginalNormalPolynomials" -> 
    {(2*s12*s23*x0 - 2*s23*s34*x0 - 2*s23*s45*x0 - s12*s15*x1 + s12*s23*x1 - 
       s23*s34*x1 + s15*s45*x1 - 2*s23*s45*x1 - s34*s45*x1)/
      (2*s23*(s12 - s34 - s45)), (2*s12^2*x2 + 2*s12*s23*x2 - 2*s12*s34*x2 - 
       2*s23*s34*x2 - 4*s12*s45*x2 - 2*s23*s45*x2 + 2*s34*s45*x2 + 
       2*s45^2*x2 - s12*s15*x3 + s12*s23*x3 - s23*s34*x3 - 2*s12*s45*x3 + 
       s15*s45*x3 - 2*s23*s45*x3 + s34*s45*x3 + 2*s45^2*x3)/
      (2*(s12 + s23 - s45)*(s12 - s34 - s45)), 
     (2*s12*s23*x4 + 2*s23^2*x4 - 2*s23*s45*x4 - s12*s15*x5 + s12*s23*x5 - 
       2*s15*s23*x5 + 2*s23^2*x5 + s23*s34*x5 + s15*s45*x5 - 2*s23*s45*x5 - 
       s34*s45*x5)/(2*s23*(s12 + s23 - s45))}, 
   "OriginalFactorizedGenerators" -> 
    {((2*s12*s23*x0 - 2*s23*s34*x0 - 2*s23*s45*x0 - s12*s15*x1 + s12*s23*x1 - 
        s23*s34*x1 + s15*s45*x1 - 2*s23*s45*x1 - s34*s45*x1)*
       (2*s12^2*x2 + 2*s12*s23*x2 - 2*s12*s34*x2 - 2*s23*s34*x2 - 
        4*s12*s45*x2 - 2*s23*s45*x2 + 2*s34*s45*x2 + 2*s45^2*x2 - 
        s12*s15*x3 + s12*s23*x3 - s23*s34*x3 - 2*s12*s45*x3 + s15*s45*x3 - 
        2*s23*s45*x3 + s34*s45*x3 + 2*s45^2*x3))/(4*s23*(s12 + s23 - s45)*
       (s12 - s34 - s45)^2), ((2*s12^2*x2 + 2*s12*s23*x2 - 2*s12*s34*x2 - 
        2*s23*s34*x2 - 4*s12*s45*x2 - 2*s23*s45*x2 + 2*s34*s45*x2 + 
        2*s45^2*x2 - s12*s15*x3 + s12*s23*x3 - s23*s34*x3 - 2*s12*s45*x3 + 
        s15*s45*x3 - 2*s23*s45*x3 + s34*s45*x3 + 2*s45^2*x3)*
       (2*s12*s23*x4 + 2*s23^2*x4 - 2*s23*s45*x4 - s12*s15*x5 + s12*s23*x5 - 
        2*s15*s23*x5 + 2*s23^2*x5 + s23*s34*x5 + s15*s45*x5 - 2*s23*s45*x5 - 
        s34*s45*x5))/(4*s23*(s12 + s23 - s45)^2*(s12 - s34 - s45)), 
     ((2*s12*s23*x0 - 2*s23*s34*x0 - 2*s23*s45*x0 - s12*s15*x1 + s12*s23*x1 - 
        s23*s34*x1 + s15*s45*x1 - 2*s23*s45*x1 - s34*s45*x1)*
       (2*s12*s23*x4 + 2*s23^2*x4 - 2*s23*s45*x4 - s12*s15*x5 + s12*s23*x5 - 
        2*s15*s23*x5 + 2*s23^2*x5 + s23*s34*x5 + s15*s45*x5 - 2*s23*s45*x5 - 
        s34*s45*x5))/(4*s23^2*(s12 + s23 - s45)*(s12 - s34 - s45))}, 
   "OriginalF0GeneratorDecomposition" -> 
    -1/4*(4*s12^3*s23*x1*x2*x4 + 8*s12^2*s23^2*x1*x2*x4 + 
       4*s12*s23^3*x1*x2*x4 - 4*s12^2*s23*s34*x1*x2*x4 - 
       8*s12*s23^2*s34*x1*x2*x4 - 4*s23^3*s34*x1*x2*x4 - 
       12*s12^2*s23*s45*x1*x2*x4 - 16*s12*s23^2*s45*x1*x2*x4 - 
       4*s23^3*s45*x1*x2*x4 + 8*s12*s23*s34*s45*x1*x2*x4 + 
       8*s23^2*s34*s45*x1*x2*x4 + 12*s12*s23*s45^2*x1*x2*x4 + 
       8*s23^2*s45^2*x1*x2*x4 - 4*s23*s34*s45^2*x1*x2*x4 - 
       4*s23*s45^3*x1*x2*x4 - 4*s12^2*s23^2*x0*x3*x4 - 4*s12*s23^3*x0*x3*x4 + 
       4*s12*s23^2*s34*x0*x3*x4 + 4*s23^3*s34*x0*x3*x4 + 
       8*s12*s23^2*s45*x0*x3*x4 + 4*s23^3*s45*x0*x3*x4 - 
       4*s23^2*s34*s45*x0*x3*x4 - 4*s23^2*s45^2*x0*x3*x4 - 
       4*s12^2*s23*s45*x1*x3*x4 - 4*s12*s23^2*s45*x1*x3*x4 + 
       4*s12*s23*s34*s45*x1*x3*x4 + 4*s23^2*s34*s45*x1*x3*x4 + 
       8*s12*s23*s45^2*x1*x3*x4 + 4*s23^2*s45^2*x1*x3*x4 - 
       4*s23*s34*s45^2*x1*x3*x4 - 4*s23*s45^3*x1*x3*x4 - 
       4*s12^3*s23*x0*x2*x5 - 4*s12^2*s23^2*x0*x2*x5 + 
       8*s12^2*s23*s34*x0*x2*x5 + 8*s12*s23^2*s34*x0*x2*x5 - 
       4*s12*s23*s34^2*x0*x2*x5 - 4*s23^2*s34^2*x0*x2*x5 + 
       12*s12^2*s23*s45*x0*x2*x5 + 8*s12*s23^2*s45*x0*x2*x5 - 
       16*s12*s23*s34*s45*x0*x2*x5 - 8*s23^2*s34*s45*x0*x2*x5 + 
       4*s23*s34^2*s45*x0*x2*x5 - 12*s12*s23*s45^2*x0*x2*x5 - 
       4*s23^2*s45^2*x0*x2*x5 + 8*s23*s34*s45^2*x0*x2*x5 + 
       4*s23*s45^3*x0*x2*x5 - 4*s12^2*s15*s23*x1*x2*x5 + 
       4*s12^2*s23^2*x1*x2*x5 - 4*s12*s15*s23^2*x1*x2*x5 + 
       4*s12*s23^3*x1*x2*x5 + 4*s12^2*s23*s34*x1*x2*x5 + 
       4*s12*s15*s23*s34*x1*x2*x5 + 4*s15*s23^2*s34*x1*x2*x5 - 
       4*s23^3*s34*x1*x2*x5 - 4*s12*s23*s34^2*x1*x2*x5 - 
       4*s23^2*s34^2*x1*x2*x5 + 8*s12*s15*s23*s45*x1*x2*x5 - 
       8*s12*s23^2*s45*x1*x2*x5 + 4*s15*s23^2*s45*x1*x2*x5 - 
       4*s23^3*s45*x1*x2*x5 - 8*s12*s23*s34*s45*x1*x2*x5 - 
       4*s15*s23*s34*s45*x1*x2*x5 + 4*s23*s34^2*s45*x1*x2*x5 - 
       4*s15*s23*s45^2*x1*x2*x5 + 4*s23^2*s45^2*x1*x2*x5 + 
       4*s23*s34*s45^2*x1*x2*x5 + 4*s12^2*s15*s23*x0*x3*x5 - 
       4*s12^2*s23^2*x0*x3*x5 + 4*s12*s15*s23^2*x0*x3*x5 - 
       4*s12*s23^3*x0*x3*x5 - 4*s12*s15*s23*s34*x0*x3*x5 + 
       4*s12*s23^2*s34*x0*x3*x5 - 4*s15*s23^2*s34*x0*x3*x5 + 
       4*s23^3*s34*x0*x3*x5 + 4*s12^2*s23*s45*x0*x3*x5 - 
       8*s12*s15*s23*s45*x0*x3*x5 + 12*s12*s23^2*s45*x0*x3*x5 - 
       4*s15*s23^2*s45*x0*x3*x5 + 4*s23^3*s45*x0*x3*x5 - 
       4*s12*s23*s34*s45*x0*x3*x5 + 4*s15*s23*s34*s45*x0*x3*x5 - 
       8*s23^2*s34*s45*x0*x3*x5 - 8*s12*s23*s45^2*x0*x3*x5 + 
       4*s15*s23*s45^2*x0*x3*x5 - 8*s23^2*s45^2*x0*x3*x5 + 
       4*s23*s34*s45^2*x0*x3*x5 + 4*s23*s45^3*x0*x3*x5 - 
       s12^2*s15^2*x1*x3*x5 + 2*s12^2*s15*s23*x1*x3*x5 - 
       s12^2*s23^2*x1*x3*x5 - 2*s12*s15*s23*s34*x1*x3*x5 + 
       2*s12*s23^2*s34*x1*x3*x5 - s23^2*s34^2*x1*x3*x5 + 
       2*s12*s15^2*s45*x1*x3*x5 - 2*s12*s15*s23*s45*x1*x3*x5 - 
       2*s12*s15*s34*s45*x1*x3*x5 - 2*s12*s23*s34*s45*x1*x3*x5 - 
       2*s15*s23*s34*s45*x1*x3*x5 + 2*s23*s34^2*s45*x1*x3*x5 - 
       s15^2*s45^2*x1*x3*x5 + 2*s15*s34*s45^2*x1*x3*x5 - 
       s34^2*s45^2*x1*x3*x5)/(s23*(s12 + s23 - s45)*(s12 - s34 - s45)), 
   "OffGramRemainder" -> -1/4*((s12^2*s15^2 - 2*s12^2*s15*s23 + s12^2*s23^2 + 
        2*s12*s15*s23*s34 - 2*s12*s23^2*s34 + s23^2*s34^2 - 2*s12*s15^2*s45 + 
        2*s12*s15*s23*s45 + 2*s12*s15*s34*s45 + 2*s12*s23*s34*s45 + 
        2*s15*s23*s34*s45 - 2*s23*s34^2*s45 + s15^2*s45^2 - 2*s15*s34*s45^2 + 
        s34^2*s45^2)*x1*x3*x5)/(s23*(s12 + s23 - s45)*(s12 - s34 - s45)), 
   "RemainderEqualsGramTermQ" -> True, "InvariantPositiveWitness" -> 
    {s12 -> 45, s23 -> -3, s34 -> 9/2, s45 -> 27, s15 -> -45/2}, 
   "WitnessRatios" -> {4, 1, 2}, "WitnessGram" -> 0, 
   "WitnessInFullPhysicalSignDomainQ" -> True, 
   "ParityOddOrientationAffectsF0Q" -> False|>, 
 "Scaling" -> <|"OriginalVariables" -> {-1, -1, -1, -1, -1, -1, 1}, 
   "LocalVariableOrder" -> {x1, x3, x5, y0, y2, y4}, 
   "LocalDissectedScaling" -> {-1, -1, -1, -1/2, -1/2, -1/2, 1}, 
   "WSLOriginalCoordinates" -> -3, "WHR" -> -2, "HierarchyGap" -> 1|>, 
 "AllLayerFacetCertificate" -> <|"MinimumWeight" -> -2, 
   "WeightCountsBySource" -> <|"F0" -> <|-2 -> 3|>, 
     "U" -> <|-2 -> 3, -3/2 -> 6, -1 -> 3|>, "lambda F1" -> 
      <|-2 -> 7, -3/2 -> 15, -1 -> 9, -1/2 -> 1|>|>, 
   "LeadingTermCountsBySource" -> <|"F0" -> 3, "U" -> 3, "lambda F1" -> 7|>, 
   "LeadingAugmentedRows" -> {{2, 1, 0, 0, 0, 0, 1}, {2, 0, 1, 0, 0, 0, 1}, 
    {1, 2, 0, 0, 0, 0, 1}, {1, 1, 1, 0, 0, 0, 1}, {1, 1, 0, 0, 0, 0, 0}, {1, 
    0, 2, 0, 0, 0, 1}, {1, 0, 1, 0, 0, 0, 0}, {1, 0, 0, 0, 1, 1, 0}, {0, 2, 
    1, 0, 0, 0, 1}, {0, 1, 2, 0, 0, 0, 1}, {0, 1, 1, 0, 0, 0, 0}, {0, 1, 0, 
    1, 0, 1, 0}, {0, 0, 1, 1, 1, 0, 0}}, "LeadingPointCount" -> 13, 
   "AffineRank" -> 6, "RequiredRank" -> 6, "NormalSpaceDimension" -> 1, 
   "NormalizedInwardNormal" -> {-1, -1, -1, -1/2, -1/2, -1/2, 1}, 
   "CandidateNormal" -> {-1, -1, -1, -1/2, -1/2, -1/2, 1}, 
   "NormalAgreementQ" -> True, "AllTermsAtOrAboveFacetQ" -> True, 
   "LowerFacetCertifiedQ" -> True|>, "PowerCounting" -> 
  <|"MeasureWeight" -> -9/2, "LPPolynomialWeight" -> -2, 
   "ScalarUnitIndexIntegralPower" -> -9/2 + D, "AtD4Minus2Epsilon" -> 
    -1/2 - 2*epsilon, "MomentumSpace" -> 
    <|"PathMomentumDefinitions" -> {qA, -p1 + qA, qB, -p2 + qB, qC, 
       -p5 + qC}, "HardVertexConstraint" -> qA + qB + qC == -p3, 
     "LandauFractions" -> {xiA == (2*s23*(s12 - s34 - s45))/
         (s12*s15 + s12*s23 - s23*s34 - s15*s45 + s34*s45), 
       xiB == (2*(s12 + s23 - s45)*(s12 - s34 - s45))/(2*s12^2 + s12*s15 + 
          s12*s23 - 2*s12*s34 - s23*s34 - 2*s12*s45 - s15*s45 + s34*s45), 
       xiC == (2*s23*(s12 + s23 - s45))/(s12*s15 + s12*s23 + 2*s15*s23 - 
          s23*s34 - s15*s45 + s34*s45)}, "LeadingLandauMomenta" -> 
      {qA == p1*xiA, qB == p2*xiB, qC == p5*xiC}, "WitnessFractions" -> 
      {1/5, 1/2, 1/3}, "IndependentLoopCount" -> 2, 
     "CollinearMeasureWeightPerLoop" -> D/2, 
     "RestrictedLongitudinalSupportWeight" -> 3/2, 
     "MeasureWeight" -> 3/2 + D, "SixUnitPropagatorWeight" -> -6, 
     "ScalarUnitIndexIntegralPower" -> -9/2 + D, "AtD4Minus2Epsilon" -> 
      -1/2 - 2*epsilon, "MatchesParameterSpaceQ" -> True|>|>, 
 "NearPlanarOnShell" -> <|"KinematicLimit" -> 
    <|"ExternalMasses" -> {p[1]^2 == 0, p[2]^2 == 0, p[3]^2 == 0, 
       p[4]^2 == 0, p[5]^2 == 0}, "PrimitiveParameter" -> lambdaPlanar, 
     "ParityOddScaling" -> (-I)*epsilon5 == cEpsilon*lambdaPlanar, 
     "GramScaling" -> Gamma5 == -(cEpsilon^2*lambdaPlanar^2), 
     "MandelstamLeadingPoint" -> Gamma5 == 0, "LPExpansion" -> 
      scriptP == U + remainder[lambdaPlanar^4] + Subscript[F, cop] + 
        lambdaPlanar^2*Subscript[F, perpendicular]|>, 
   "Scaling" -> <|"OriginalVariables" -> {-2, -2, -2, -2, -2, -2, 1}, 
     "LocalVariableOrder" -> {x1, x3, x5, y0, y2, y4}, 
     "LocalDissectedScaling" -> {-2, -2, -2, -1, -1, -1, 1}, 
     "WSLOriginalCoordinates" -> -6, "WHR" -> -4, "HierarchyGap" -> 2|>, 
   "LocalPolynomial" -> <|"Fcop" -> (aPlus^2*bPlus*mMinus^2*x5*y0*y2 + 
        2*aPlus*bPlus*kTrans*mMinus*qTrans*x5*y0*y2 + bPlus*kTrans^2*qTrans^2*
         x5*y0*y2 + 2*aPlus*bPlus*mMinus*qTrans^2*x5*y0*y2 + 
        2*bPlus*kTrans*qTrans^3*x5*y0*y2 + bPlus*qTrans^4*x5*y0*y2 - 
        bPlus*kTrans^2*qTrans^2*x3*y0*y4 - aPlus*bPlus*mMinus*qTrans^2*x3*y0*
         y4 - bPlus^2*mMinus*qTrans^2*x3*y0*y4 - 2*bPlus*kTrans*qTrans^3*x3*
         y0*y4 - bPlus*qTrans^4*x3*y0*y4 - aPlus^2*kTrans^2*mMinus*x1*y2*y4 - 
        aPlus^2*bPlus*mMinus^2*x1*y2*y4 - aPlus*bPlus*mMinus*qTrans^2*x1*y2*
         y4)/(aPlus*bPlus*mMinus), 
     "U" -> (aPlus*kTrans^5*qTrans*x1*x3 + aPlus^2*kTrans^3*mMinus*qTrans*x1*
         x3 + 2*aPlus*bPlus*kTrans^3*mMinus*qTrans*x1*x3 + 
        aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1*x3 + aPlus*bPlus^2*kTrans*
         mMinus^2*qTrans*x1*x3 + 3*aPlus*kTrans^4*qTrans^2*x1*x3 + 
        aPlus^2*kTrans^2*mMinus*qTrans^2*x1*x3 + 4*aPlus*bPlus*kTrans^2*
         mMinus*qTrans^2*x1*x3 + aPlus^2*bPlus*mMinus^2*qTrans^2*x1*x3 + 
        aPlus*bPlus^2*mMinus^2*qTrans^2*x1*x3 + 3*aPlus*kTrans^3*qTrans^3*x1*
         x3 + bPlus*kTrans^3*qTrans^3*x1*x3 + 4*aPlus*bPlus*kTrans*mMinus*
         qTrans^3*x1*x3 + bPlus^2*kTrans*mMinus*qTrans^3*x1*x3 + 
        aPlus*kTrans^2*qTrans^4*x1*x3 + 3*bPlus*kTrans^2*qTrans^4*x1*x3 + 
        2*aPlus*bPlus*mMinus*qTrans^4*x1*x3 + bPlus^2*mMinus*qTrans^4*x1*x3 + 
        3*bPlus*kTrans*qTrans^5*x1*x3 + bPlus*qTrans^6*x1*x3 + 
        aPlus^2*kTrans^4*mMinus*x1*x5 + aPlus^2*bPlus*kTrans^2*mMinus^2*x1*
         x5 + aPlus*kTrans^5*qTrans*x1*x5 + 2*aPlus^2*kTrans^3*mMinus*qTrans*
         x1*x5 + aPlus*bPlus*kTrans^3*mMinus*qTrans*x1*x5 + 
        2*aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x1*x5 + 
        3*aPlus*kTrans^4*qTrans^2*x1*x5 + aPlus^2*kTrans^2*mMinus*qTrans^2*x1*
         x5 + 4*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x1*x5 + 
        aPlus^2*bPlus*mMinus^2*qTrans^2*x1*x5 + 3*aPlus*kTrans^3*qTrans^3*x1*
         x5 + bPlus*kTrans^3*qTrans^3*x1*x5 + 5*aPlus*bPlus*kTrans*mMinus*
         qTrans^3*x1*x5 + aPlus*kTrans^2*qTrans^4*x1*x5 + 
        3*bPlus*kTrans^2*qTrans^4*x1*x5 + 2*aPlus*bPlus*mMinus*qTrans^4*x1*
         x5 + 3*bPlus*kTrans*qTrans^5*x1*x5 + bPlus*qTrans^6*x1*x5 + 
        aPlus*bPlus*kTrans^3*mMinus*qTrans*x3*x5 + aPlus^2*bPlus*kTrans*
         mMinus^2*qTrans*x3*x5 + aPlus*bPlus^2*kTrans*mMinus^2*qTrans*x3*x5 + 
        bPlus*kTrans^4*qTrans^2*x3*x5 + 4*aPlus*bPlus*kTrans^2*mMinus*
         qTrans^2*x3*x5 + bPlus^2*kTrans^2*mMinus*qTrans^2*x3*x5 + 
        aPlus^2*bPlus*mMinus^2*qTrans^2*x3*x5 + aPlus*bPlus^2*mMinus^2*
         qTrans^2*x3*x5 + 4*bPlus*kTrans^3*qTrans^3*x3*x5 + 
        5*aPlus*bPlus*kTrans*mMinus*qTrans^3*x3*x5 + 2*bPlus^2*kTrans*mMinus*
         qTrans^3*x3*x5 + 6*bPlus*kTrans^2*qTrans^4*x3*x5 + 
        2*aPlus*bPlus*mMinus*qTrans^4*x3*x5 + bPlus^2*mMinus*qTrans^4*x3*x5 + 
        4*bPlus*kTrans*qTrans^5*x3*x5 + bPlus*qTrans^6*x3*x5 + 
        aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x3*y0 + aPlus^2*bPlus*mMinus^2*
         qTrans^2*x3*y0 + aPlus*bPlus^2*mMinus^2*qTrans^2*x3*y0 + 
        bPlus*kTrans^3*qTrans^3*x3*y0 + 3*aPlus*bPlus*kTrans*mMinus*qTrans^3*
         x3*y0 + bPlus^2*kTrans*mMinus*qTrans^3*x3*y0 + 
        3*bPlus*kTrans^2*qTrans^4*x3*y0 + 2*aPlus*bPlus*mMinus*qTrans^4*x3*
         y0 + bPlus^2*mMinus*qTrans^4*x3*y0 + 3*bPlus*kTrans*qTrans^5*x3*y0 + 
        bPlus*qTrans^6*x3*y0 + aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x5*y0 + 
        2*aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x5*y0 + aPlus^2*bPlus*mMinus^2*
         qTrans^2*x5*y0 + bPlus*kTrans^3*qTrans^3*x5*y0 + 
        4*aPlus*bPlus*kTrans*mMinus*qTrans^3*x5*y0 + 3*bPlus*kTrans^2*
         qTrans^4*x5*y0 + 2*aPlus*bPlus*mMinus*qTrans^4*x5*y0 + 
        3*bPlus*kTrans*qTrans^5*x5*y0 + bPlus*qTrans^6*x5*y0 + 
        aPlus^2*kTrans^3*mMinus*qTrans*x1*y2 + aPlus^2*bPlus*kTrans*mMinus^2*
         qTrans*x1*y2 + aPlus*kTrans^4*qTrans^2*x1*y2 + 
        aPlus^2*kTrans^2*mMinus*qTrans^2*x1*y2 + aPlus*bPlus*kTrans^2*mMinus*
         qTrans^2*x1*y2 + aPlus^2*bPlus*mMinus^2*qTrans^2*x1*y2 + 
        2*aPlus*kTrans^3*qTrans^3*x1*y2 + 3*aPlus*bPlus*kTrans*mMinus*
         qTrans^3*x1*y2 + aPlus*kTrans^2*qTrans^4*x1*y2 + 
        bPlus*kTrans^2*qTrans^4*x1*y2 + 2*aPlus*bPlus*mMinus*qTrans^4*x1*y2 + 
        2*bPlus*kTrans*qTrans^5*x1*y2 + bPlus*qTrans^6*x1*y2 + 
        aPlus^2*bPlus*kTrans*mMinus^2*qTrans*x5*y2 + 2*aPlus*bPlus*kTrans^2*
         mMinus*qTrans^2*x5*y2 + aPlus^2*bPlus*mMinus^2*qTrans^2*x5*y2 + 
        bPlus*kTrans^3*qTrans^3*x5*y2 + 4*aPlus*bPlus*kTrans*mMinus*qTrans^3*
         x5*y2 + 3*bPlus*kTrans^2*qTrans^4*x5*y2 + 2*aPlus*bPlus*mMinus*
         qTrans^4*x5*y2 + 3*bPlus*kTrans*qTrans^5*x5*y2 + 
        bPlus*qTrans^6*x5*y2 + aPlus^2*bPlus*mMinus^2*qTrans^2*y0*y2 + 
        2*aPlus*bPlus*kTrans*mMinus*qTrans^3*y0*y2 + bPlus*kTrans^2*qTrans^4*
         y0*y2 + 2*aPlus*bPlus*mMinus*qTrans^4*y0*y2 + 
        2*bPlus*kTrans*qTrans^5*y0*y2 + bPlus*qTrans^6*y0*y2 + 
        aPlus^2*kTrans^3*mMinus*qTrans*x1*y4 + aPlus^2*bPlus*kTrans*mMinus^2*
         qTrans*x1*y4 + aPlus*kTrans^4*qTrans^2*x1*y4 + 
        aPlus^2*kTrans^2*mMinus*qTrans^2*x1*y4 + aPlus*bPlus*kTrans^2*mMinus*
         qTrans^2*x1*y4 + aPlus^2*bPlus*mMinus^2*qTrans^2*x1*y4 + 
        2*aPlus*kTrans^3*qTrans^3*x1*y4 + 3*aPlus*bPlus*kTrans*mMinus*
         qTrans^3*x1*y4 + aPlus*kTrans^2*qTrans^4*x1*y4 + 
        bPlus*kTrans^2*qTrans^4*x1*y4 + 2*aPlus*bPlus*mMinus*qTrans^4*x1*y4 + 
        2*bPlus*kTrans*qTrans^5*x1*y4 + bPlus*qTrans^6*x1*y4 + 
        aPlus*bPlus*kTrans^2*mMinus*qTrans^2*x3*y4 + aPlus^2*bPlus*mMinus^2*
         qTrans^2*x3*y4 + aPlus*bPlus^2*mMinus^2*qTrans^2*x3*y4 + 
        bPlus*kTrans^3*qTrans^3*x3*y4 + 3*aPlus*bPlus*kTrans*mMinus*qTrans^3*
         x3*y4 + bPlus^2*kTrans*mMinus*qTrans^3*x3*y4 + 
        3*bPlus*kTrans^2*qTrans^4*x3*y4 + 2*aPlus*bPlus*mMinus*qTrans^4*x3*
         y4 + bPlus^2*mMinus*qTrans^4*x3*y4 + 3*bPlus*kTrans*qTrans^5*x3*y4 + 
        bPlus*qTrans^6*x3*y4 + aPlus^2*bPlus*mMinus^2*qTrans^2*y0*y4 + 
        2*aPlus*bPlus*kTrans*mMinus*qTrans^3*y0*y4 + bPlus*kTrans^2*qTrans^4*
         y0*y4 + 2*aPlus*bPlus*mMinus*qTrans^4*y0*y4 + 
        2*bPlus*kTrans*qTrans^5*y0*y4 + bPlus*qTrans^6*y0*y4 + 
        aPlus^2*bPlus*mMinus^2*qTrans^2*y2*y4 + 2*aPlus*bPlus*kTrans*mMinus*
         qTrans^3*y2*y4 + bPlus*kTrans^2*qTrans^4*y2*y4 + 
        2*aPlus*bPlus*mMinus*qTrans^4*y2*y4 + 2*bPlus*kTrans*qTrans^5*y2*y4 + 
        bPlus*qTrans^6*y2*y4)/(bPlus*qTrans^2*(aPlus*mMinus + kTrans*qTrans + 
          qTrans^2)^2), "TransverseGramLayer" -> cGram*x1*x3*x5, 
     "FullLP" -> (aPlus^2*kTrans^5*mMinus*qTrans*x1*x3 + 
        aPlus^3*kTrans^3*mMinus^2*qTrans*x1*x3 + 2*aPlus^2*bPlus*kTrans^3*
         mMinus^2*qTrans*x1*x3 + aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x1*x3 + 
        aPlus^2*bPlus^2*kTrans*mMinus^3*qTrans*x1*x3 + 
        3*aPlus^2*kTrans^4*mMinus*qTrans^2*x1*x3 + aPlus^3*kTrans^2*mMinus^2*
         qTrans^2*x1*x3 + 4*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x1*x3 + 
        aPlus^3*bPlus*mMinus^3*qTrans^2*x1*x3 + aPlus^2*bPlus^2*mMinus^3*
         qTrans^2*x1*x3 + 3*aPlus^2*kTrans^3*mMinus*qTrans^3*x1*x3 + 
        aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x1*x3 + 4*aPlus^2*bPlus*kTrans*
         mMinus^2*qTrans^3*x1*x3 + aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x1*
         x3 + aPlus^2*kTrans^2*mMinus*qTrans^4*x1*x3 + 3*aPlus*bPlus*kTrans^2*
         mMinus*qTrans^4*x1*x3 + 2*aPlus^2*bPlus*mMinus^2*qTrans^4*x1*x3 + 
        aPlus*bPlus^2*mMinus^2*qTrans^4*x1*x3 + 3*aPlus*bPlus*kTrans*mMinus*
         qTrans^5*x1*x3 + aPlus*bPlus*mMinus*qTrans^6*x1*x3 + 
        aPlus^3*kTrans^4*mMinus^2*x1*x5 + aPlus^3*bPlus*kTrans^2*mMinus^3*x1*
         x5 + aPlus^2*kTrans^5*mMinus*qTrans*x1*x5 + 2*aPlus^3*kTrans^3*
         mMinus^2*qTrans*x1*x5 + aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x1*
         x5 + 2*aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x1*x5 + 
        3*aPlus^2*kTrans^4*mMinus*qTrans^2*x1*x5 + aPlus^3*kTrans^2*mMinus^2*
         qTrans^2*x1*x5 + 4*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x1*x5 + 
        aPlus^3*bPlus*mMinus^3*qTrans^2*x1*x5 + 3*aPlus^2*kTrans^3*mMinus*
         qTrans^3*x1*x5 + aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x1*x5 + 
        5*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x1*x5 + 
        aPlus^2*kTrans^2*mMinus*qTrans^4*x1*x5 + 3*aPlus*bPlus*kTrans^2*
         mMinus*qTrans^4*x1*x5 + 2*aPlus^2*bPlus*mMinus^2*qTrans^4*x1*x5 + 
        3*aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*x5 + aPlus*bPlus*mMinus*
         qTrans^6*x1*x5 + aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x3*x5 + 
        aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x3*x5 + aPlus^2*bPlus^2*kTrans*
         mMinus^3*qTrans*x3*x5 + aPlus*bPlus*kTrans^4*mMinus*qTrans^2*x3*x5 + 
        4*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x3*x5 + 
        aPlus*bPlus^2*kTrans^2*mMinus^2*qTrans^2*x3*x5 + 
        aPlus^3*bPlus*mMinus^3*qTrans^2*x3*x5 + aPlus^2*bPlus^2*mMinus^3*
         qTrans^2*x3*x5 + 4*aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x3*x5 + 
        5*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x3*x5 + 
        2*aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x3*x5 + 
        6*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x3*x5 + 
        2*aPlus^2*bPlus*mMinus^2*qTrans^4*x3*x5 + aPlus*bPlus^2*mMinus^2*
         qTrans^4*x3*x5 + 4*aPlus*bPlus*kTrans*mMinus*qTrans^5*x3*x5 + 
        aPlus*bPlus*mMinus*qTrans^6*x3*x5 + aPlus^3*bPlus*cGram*
         lambdaPlanar^2*mMinus^3*qTrans^2*x1*x3*x5 + 2*aPlus^2*bPlus*cGram*
         kTrans*lambdaPlanar^2*mMinus^2*qTrans^3*x1*x3*x5 + 
        aPlus*bPlus*cGram*kTrans^2*lambdaPlanar^2*mMinus*qTrans^4*x1*x3*x5 + 
        2*aPlus^2*bPlus*cGram*lambdaPlanar^2*mMinus^2*qTrans^4*x1*x3*x5 + 
        2*aPlus*bPlus*cGram*kTrans*lambdaPlanar^2*mMinus*qTrans^5*x1*x3*x5 + 
        aPlus*bPlus*cGram*lambdaPlanar^2*mMinus*qTrans^6*x1*x3*x5 + 
        aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x3*y0 + 
        aPlus^3*bPlus*mMinus^3*qTrans^2*x3*y0 + aPlus^2*bPlus^2*mMinus^3*
         qTrans^2*x3*y0 + aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x3*y0 + 
        3*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x3*y0 + 
        aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x3*y0 + 3*aPlus*bPlus*kTrans^2*
         mMinus*qTrans^4*x3*y0 + 2*aPlus^2*bPlus*mMinus^2*qTrans^4*x3*y0 + 
        aPlus*bPlus^2*mMinus^2*qTrans^4*x3*y0 + 3*aPlus*bPlus*kTrans*mMinus*
         qTrans^5*x3*y0 + aPlus*bPlus*mMinus*qTrans^6*x3*y0 + 
        aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x5*y0 + 2*aPlus^2*bPlus*kTrans^2*
         mMinus^2*qTrans^2*x5*y0 + aPlus^3*bPlus*mMinus^3*qTrans^2*x5*y0 + 
        aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x5*y0 + 4*aPlus^2*bPlus*kTrans*
         mMinus^2*qTrans^3*x5*y0 + 3*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x5*
         y0 + 2*aPlus^2*bPlus*mMinus^2*qTrans^4*x5*y0 + 
        3*aPlus*bPlus*kTrans*mMinus*qTrans^5*x5*y0 + aPlus*bPlus*mMinus*
         qTrans^6*x5*y0 + aPlus^3*kTrans^3*mMinus^2*qTrans*x1*y2 + 
        aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x1*y2 + aPlus^2*kTrans^4*mMinus*
         qTrans^2*x1*y2 + aPlus^3*kTrans^2*mMinus^2*qTrans^2*x1*y2 + 
        aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x1*y2 + 
        aPlus^3*bPlus*mMinus^3*qTrans^2*x1*y2 + 2*aPlus^2*kTrans^3*mMinus*
         qTrans^3*x1*y2 + 3*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x1*y2 + 
        aPlus^2*kTrans^2*mMinus*qTrans^4*x1*y2 + aPlus*bPlus*kTrans^2*mMinus*
         qTrans^4*x1*y2 + 2*aPlus^2*bPlus*mMinus^2*qTrans^4*x1*y2 + 
        2*aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*y2 + aPlus*bPlus*mMinus*
         qTrans^6*x1*y2 + aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x5*y2 + 
        2*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x5*y2 + 
        aPlus^3*bPlus*mMinus^3*qTrans^2*x5*y2 + aPlus*bPlus*kTrans^3*mMinus*
         qTrans^3*x5*y2 + 4*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x5*y2 + 
        3*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x5*y2 + 
        2*aPlus^2*bPlus*mMinus^2*qTrans^4*x5*y2 + 3*aPlus*bPlus*kTrans*mMinus*
         qTrans^5*x5*y2 + aPlus*bPlus*mMinus*qTrans^6*x5*y2 + 
        aPlus^3*bPlus*mMinus^3*qTrans^2*y0*y2 + 2*aPlus^2*bPlus*kTrans*
         mMinus^2*qTrans^3*y0*y2 + aPlus*bPlus*kTrans^2*mMinus*qTrans^4*y0*
         y2 + 2*aPlus^2*bPlus*mMinus^2*qTrans^4*y0*y2 + 
        2*aPlus*bPlus*kTrans*mMinus*qTrans^5*y0*y2 + aPlus*bPlus*mMinus*
         qTrans^6*y0*y2 + aPlus^4*bPlus*mMinus^4*qTrans^2*x5*y0*y2 + 
        4*aPlus^3*bPlus*kTrans*mMinus^3*qTrans^3*x5*y0*y2 + 
        6*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^4*x5*y0*y2 + 
        4*aPlus^3*bPlus*mMinus^3*qTrans^4*x5*y0*y2 + 4*aPlus*bPlus*kTrans^3*
         mMinus*qTrans^5*x5*y0*y2 + 12*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^5*
         x5*y0*y2 + bPlus*kTrans^4*qTrans^6*x5*y0*y2 + 
        12*aPlus*bPlus*kTrans^2*mMinus*qTrans^6*x5*y0*y2 + 
        6*aPlus^2*bPlus*mMinus^2*qTrans^6*x5*y0*y2 + 4*bPlus*kTrans^3*
         qTrans^7*x5*y0*y2 + 12*aPlus*bPlus*kTrans*mMinus*qTrans^7*x5*y0*y2 + 
        6*bPlus*kTrans^2*qTrans^8*x5*y0*y2 + 4*aPlus*bPlus*mMinus*qTrans^8*x5*
         y0*y2 + 4*bPlus*kTrans*qTrans^9*x5*y0*y2 + bPlus*qTrans^10*x5*y0*
         y2 + aPlus^3*kTrans^3*mMinus^2*qTrans*x1*y4 + aPlus^3*bPlus*kTrans*
         mMinus^3*qTrans*x1*y4 + aPlus^2*kTrans^4*mMinus*qTrans^2*x1*y4 + 
        aPlus^3*kTrans^2*mMinus^2*qTrans^2*x1*y4 + aPlus^2*bPlus*kTrans^2*
         mMinus^2*qTrans^2*x1*y4 + aPlus^3*bPlus*mMinus^3*qTrans^2*x1*y4 + 
        2*aPlus^2*kTrans^3*mMinus*qTrans^3*x1*y4 + 3*aPlus^2*bPlus*kTrans*
         mMinus^2*qTrans^3*x1*y4 + aPlus^2*kTrans^2*mMinus*qTrans^4*x1*y4 + 
        aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x1*y4 + 2*aPlus^2*bPlus*mMinus^2*
         qTrans^4*x1*y4 + 2*aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*y4 + 
        aPlus*bPlus*mMinus*qTrans^6*x1*y4 + aPlus^2*bPlus*kTrans^2*mMinus^2*
         qTrans^2*x3*y4 + aPlus^3*bPlus*mMinus^3*qTrans^2*x3*y4 + 
        aPlus^2*bPlus^2*mMinus^3*qTrans^2*x3*y4 + aPlus*bPlus*kTrans^3*mMinus*
         qTrans^3*x3*y4 + 3*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x3*y4 + 
        aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x3*y4 + 3*aPlus*bPlus*kTrans^2*
         mMinus*qTrans^4*x3*y4 + 2*aPlus^2*bPlus*mMinus^2*qTrans^4*x3*y4 + 
        aPlus*bPlus^2*mMinus^2*qTrans^4*x3*y4 + 3*aPlus*bPlus*kTrans*mMinus*
         qTrans^5*x3*y4 + aPlus*bPlus*mMinus*qTrans^6*x3*y4 + 
        aPlus^3*bPlus*mMinus^3*qTrans^2*y0*y4 + 2*aPlus^2*bPlus*kTrans*
         mMinus^2*qTrans^3*y0*y4 + aPlus*bPlus*kTrans^2*mMinus*qTrans^4*y0*
         y4 + 2*aPlus^2*bPlus*mMinus^2*qTrans^4*y0*y4 + 
        2*aPlus*bPlus*kTrans*mMinus*qTrans^5*y0*y4 + aPlus*bPlus*mMinus*
         qTrans^6*y0*y4 - aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^4*x3*y0*y4 - 
        aPlus^3*bPlus*mMinus^3*qTrans^4*x3*y0*y4 - aPlus^2*bPlus^2*mMinus^3*
         qTrans^4*x3*y0*y4 - 2*aPlus*bPlus*kTrans^3*mMinus*qTrans^5*x3*y0*
         y4 - 4*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^5*x3*y0*y4 - 
        2*aPlus*bPlus^2*kTrans*mMinus^2*qTrans^5*x3*y0*y4 - 
        bPlus*kTrans^4*qTrans^6*x3*y0*y4 - 7*aPlus*bPlus*kTrans^2*mMinus*
         qTrans^6*x3*y0*y4 - bPlus^2*kTrans^2*mMinus*qTrans^6*x3*y0*y4 - 
        3*aPlus^2*bPlus*mMinus^2*qTrans^6*x3*y0*y4 - 2*aPlus*bPlus^2*mMinus^2*
         qTrans^6*x3*y0*y4 - 4*bPlus*kTrans^3*qTrans^7*x3*y0*y4 - 
        8*aPlus*bPlus*kTrans*mMinus*qTrans^7*x3*y0*y4 - 
        2*bPlus^2*kTrans*mMinus*qTrans^7*x3*y0*y4 - 6*bPlus*kTrans^2*qTrans^8*
         x3*y0*y4 - 3*aPlus*bPlus*mMinus*qTrans^8*x3*y0*y4 - 
        bPlus^2*mMinus*qTrans^8*x3*y0*y4 - 4*bPlus*kTrans*qTrans^9*x3*y0*y4 - 
        bPlus*qTrans^10*x3*y0*y4 + aPlus^3*bPlus*mMinus^3*qTrans^2*y2*y4 + 
        2*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*y2*y4 + 
        aPlus*bPlus*kTrans^2*mMinus*qTrans^4*y2*y4 + 2*aPlus^2*bPlus*mMinus^2*
         qTrans^4*y2*y4 + 2*aPlus*bPlus*kTrans*mMinus*qTrans^5*y2*y4 + 
        aPlus*bPlus*mMinus*qTrans^6*y2*y4 - aPlus^4*kTrans^2*mMinus^3*
         qTrans^2*x1*y2*y4 - aPlus^4*bPlus*mMinus^4*qTrans^2*x1*y2*y4 - 
        2*aPlus^3*kTrans^3*mMinus^2*qTrans^3*x1*y2*y4 - 
        2*aPlus^3*bPlus*kTrans*mMinus^3*qTrans^3*x1*y2*y4 - 
        aPlus^2*kTrans^4*mMinus*qTrans^4*x1*y2*y4 - 2*aPlus^3*kTrans^2*
         mMinus^2*qTrans^4*x1*y2*y4 - aPlus^2*bPlus*kTrans^2*mMinus^2*
         qTrans^4*x1*y2*y4 - 3*aPlus^3*bPlus*mMinus^3*qTrans^4*x1*y2*y4 - 
        2*aPlus^2*kTrans^3*mMinus*qTrans^5*x1*y2*y4 - 4*aPlus^2*bPlus*kTrans*
         mMinus^2*qTrans^5*x1*y2*y4 - aPlus^2*kTrans^2*mMinus*qTrans^6*x1*y2*
         y4 - aPlus*bPlus*kTrans^2*mMinus*qTrans^6*x1*y2*y4 - 
        3*aPlus^2*bPlus*mMinus^2*qTrans^6*x1*y2*y4 - 2*aPlus*bPlus*kTrans*
         mMinus*qTrans^7*x1*y2*y4 - aPlus*bPlus*mMinus*qTrans^8*x1*y2*y4)/
       (aPlus*bPlus*mMinus*qTrans^2*(aPlus*mMinus + kTrans*qTrans + qTrans^2)^
         2), "CommonKinematicDenominator" -> aPlus*bPlus*mMinus*qTrans^2*
       (aPlus*mMinus + kTrans*qTrans + qTrans^2)^2|>, 
   "FacetCertificate" -> <|"MinimumWeight" -> -4, "WeightCountsBySource" -> 
      <|"Fcop" -> <|-4 -> 3|>, "U" -> <|-4 -> 3, -3 -> 6, -2 -> 3|>, 
       "lambdaPlanar^2 Fperp" -> <|-4 -> 1|>|>, 
     "LeadingTermCountsBySource" -> <|"Fcop" -> 3, "U" -> 3, 
       "lambdaPlanar^2 Fperp" -> 1|>, "LeadingAugmentedRows" -> {{1, 1, 1, 0, 
      0, 0, 2}, {1, 1, 0, 0, 0, 0, 0}, {1, 0, 1, 0, 0, 0, 0}, {1, 0, 0, 0, 1, 
      1, 0}, {0, 1, 1, 0, 0, 0, 0}, {0, 1, 0, 1, 0, 1, 0}, {0, 0, 1, 1, 1, 0, 
      0}}, "LeadingPointCount" -> 7, "AffineRank" -> 6, "RequiredRank" -> 6, 
     "NormalSpaceDimension" -> 1, "NormalizedInwardNormal" -> 
      {-2, -2, -2, -1, -1, -1, 1}, "CandidateNormal" -> 
      {-2, -2, -2, -1, -1, -1, 1}, "NormalAgreementQ" -> True, 
     "AllTermsAtOrAboveFacetQ" -> True, "LowerFacetCertifiedQ" -> True|>, 
   "PowerCounting" -> <|"ParameterSpaceMeasureWeight" -> -9, 
     "LPPolynomialWeight" -> -4, "ScalarUnitIndexIntegralPower" -> -9 + 2*D, 
     "AtD4Minus2Epsilon" -> -1 - 4*epsilon, "MomentumSpace" -> 
      <|"VirtualityWeight" -> 2, "TwoCollinearLoopMeasureWeight" -> 2*D, 
       "RestrictedLongitudinalSupportWeight" -> 3, "MeasureWeight" -> 
        3 + 2*D, "SixUnitPropagatorWeight" -> -12, 
       "ScalarUnitIndexIntegralPower" -> -9 + 2*D, "AtD4Minus2Epsilon" -> 
        -1 - 4*epsilon, "MatchesParameterSpaceQ" -> True|>|>|>|>
