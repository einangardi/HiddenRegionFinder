(* Created with the Wolfram Language : www.wolfram.com *)
<|"WideAngleCoplanarOnShell" -> <|"ExternalOrderAtVertices" -> 
    {1, 2, 3, 5, 4}, "CoplanarCondition" -> w == wbar, 
   "CoplanarBranchInThisChart" -> w == wbar == -(qTrans/kTrans), 
   "InternalCoordinates" -> {x1, x3, x5}, "NormalCoordinates" -> 
    {y0, y2, y4}, "CancellationLocus" -> {y0 == 0, y2 == 0, y4 == 0}, 
   "LocalCoordinateRules" -> 
    {x0 -> (aPlus*kTrans*(kTrans^2 + bPlus*mMinus + kTrans*qTrans)*x1)/
        (bPlus*qTrans*(aPlus*mMinus + kTrans*qTrans + qTrans^2)) + y0, 
     x2 -> ((kTrans^2 + bPlus*mMinus + kTrans*qTrans)*x3)/
        (aPlus*mMinus + kTrans*qTrans + qTrans^2) + y2, 
     x4 -> (kTrans*x5)/qTrans + y4}, "FSLOriginal" -> 
    -((aPlus^2*kTrans^2*mMinus*x1*x2*x4 + aPlus^2*bPlus*mMinus^2*x1*x2*x4 + 
       aPlus*bPlus*mMinus*qTrans^2*x1*x2*x4 + bPlus*kTrans^2*qTrans^2*x0*x3*
        x4 + aPlus*bPlus*mMinus*qTrans^2*x0*x3*x4 + bPlus^2*mMinus*qTrans^2*
        x0*x3*x4 + 2*bPlus*kTrans*qTrans^3*x0*x3*x4 + 
       bPlus*qTrans^4*x0*x3*x4 - aPlus*kTrans^4*x1*x3*x4 - 
       2*aPlus*bPlus*kTrans^2*mMinus*x1*x3*x4 - aPlus*bPlus^2*mMinus^2*x1*x3*
        x4 - 2*aPlus*kTrans^3*qTrans*x1*x3*x4 - 2*aPlus*bPlus*kTrans*mMinus*
        qTrans*x1*x3*x4 - aPlus*kTrans^2*qTrans^2*x1*x3*x4 - 
       aPlus^2*bPlus*mMinus^2*x0*x2*x5 - 2*aPlus*bPlus*kTrans*mMinus*qTrans*
        x0*x2*x5 - bPlus*kTrans^2*qTrans^2*x0*x2*x5 - 
       2*aPlus*bPlus*mMinus*qTrans^2*x0*x2*x5 - 2*bPlus*kTrans*qTrans^3*x0*x2*
        x5 - bPlus*qTrans^4*x0*x2*x5 + aPlus*kTrans^4*x1*x2*x5 + 
       aPlus^2*kTrans^2*mMinus*x1*x2*x5 + aPlus*bPlus*kTrans^2*mMinus*x1*x2*
        x5 + 2*aPlus*kTrans^3*qTrans*x1*x2*x5 + aPlus*kTrans^2*qTrans^2*x1*x2*
        x5 + aPlus*bPlus*kTrans^2*mMinus*x0*x3*x5 + aPlus*bPlus^2*mMinus^2*x0*
        x3*x5 + bPlus^2*mMinus*qTrans^2*x0*x3*x5)/(aPlus*bPlus*mMinus)), 
   "FSLLocal" -> (aPlus^2*bPlus*mMinus^2*x5*y0*y2 + 2*aPlus*bPlus*kTrans*
       mMinus*qTrans*x5*y0*y2 + bPlus*kTrans^2*qTrans^2*x5*y0*y2 + 
      2*aPlus*bPlus*mMinus*qTrans^2*x5*y0*y2 + 2*bPlus*kTrans*qTrans^3*x5*y0*
       y2 + bPlus*qTrans^4*x5*y0*y2 - bPlus*kTrans^2*qTrans^2*x3*y0*y4 - 
      aPlus*bPlus*mMinus*qTrans^2*x3*y0*y4 - bPlus^2*mMinus*qTrans^2*x3*y0*
       y4 - 2*bPlus*kTrans*qTrans^3*x3*y0*y4 - bPlus*qTrans^4*x3*y0*y4 - 
      aPlus^2*kTrans^2*mMinus*x1*y2*y4 - aPlus^2*bPlus*mMinus^2*x1*y2*y4 - 
      aPlus*bPlus*mMinus*qTrans^2*x1*y2*y4)/(aPlus*bPlus*mMinus), 
   "PairProductCoefficients" -> 
    <|"y0 y2" -> ((aPlus*mMinus + kTrans*qTrans + qTrans^2)^2*x5)/
       (aPlus*mMinus), "y0 y4" -> 
      -((qTrans^2*(kTrans^2 + aPlus*mMinus + bPlus*mMinus + 2*kTrans*qTrans + 
          qTrans^2)*x3)/(aPlus*mMinus)), "y2 y4" -> 
      -(((aPlus*kTrans^2 + aPlus*bPlus*mMinus + bPlus*qTrans^2)*x1)/bPlus)|>, 
   "UAtWHROnCancellationLocus" -> 
    ((kTrans + qTrans)*(aPlus*kTrans^4*qTrans*x1*x3 + aPlus^2*kTrans^2*mMinus*
        qTrans*x1*x3 + 2*aPlus*bPlus*kTrans^2*mMinus*qTrans*x1*x3 + 
       aPlus^2*bPlus*mMinus^2*qTrans*x1*x3 + aPlus*bPlus^2*mMinus^2*qTrans*x1*
        x3 + 2*aPlus*kTrans^3*qTrans^2*x1*x3 + 2*aPlus*bPlus*kTrans*mMinus*
        qTrans^2*x1*x3 + aPlus*kTrans^2*qTrans^3*x1*x3 + 
       bPlus*kTrans^2*qTrans^3*x1*x3 + 2*aPlus*bPlus*mMinus*qTrans^3*x1*x3 + 
       bPlus^2*mMinus*qTrans^3*x1*x3 + 2*bPlus*kTrans*qTrans^4*x1*x3 + 
       bPlus*qTrans^5*x1*x3 + aPlus^2*kTrans^3*mMinus*x1*x5 + 
       aPlus^2*bPlus*kTrans*mMinus^2*x1*x5 + aPlus*kTrans^4*qTrans*x1*x5 + 
       aPlus^2*kTrans^2*mMinus*qTrans*x1*x5 + aPlus*bPlus*kTrans^2*mMinus*
        qTrans*x1*x5 + aPlus^2*bPlus*mMinus^2*qTrans*x1*x5 + 
       2*aPlus*kTrans^3*qTrans^2*x1*x5 + 3*aPlus*bPlus*kTrans*mMinus*qTrans^2*
        x1*x5 + aPlus*kTrans^2*qTrans^3*x1*x5 + bPlus*kTrans^2*qTrans^3*x1*
        x5 + 2*aPlus*bPlus*mMinus*qTrans^3*x1*x5 + 2*bPlus*kTrans*qTrans^4*x1*
        x5 + bPlus*qTrans^5*x1*x5 + aPlus*bPlus*kTrans^2*mMinus*qTrans*x3*
        x5 + aPlus^2*bPlus*mMinus^2*qTrans*x3*x5 + aPlus*bPlus^2*mMinus^2*
        qTrans*x3*x5 + bPlus*kTrans^3*qTrans^2*x3*x5 + 
       3*aPlus*bPlus*kTrans*mMinus*qTrans^2*x3*x5 + bPlus^2*kTrans*mMinus*
        qTrans^2*x3*x5 + 3*bPlus*kTrans^2*qTrans^3*x3*x5 + 
       2*aPlus*bPlus*mMinus*qTrans^3*x3*x5 + bPlus^2*mMinus*qTrans^3*x3*x5 + 
       3*bPlus*kTrans*qTrans^4*x3*x5 + bPlus*qTrans^5*x3*x5))/
     (bPlus*qTrans^2*(aPlus*mMinus + kTrans*qTrans + qTrans^2)^2), 
   "OffShellF1AtWHROnCancellationLocus" -> 
    (aPlus*kTrans^5*qTrans*x1^2*x3 + aPlus^2*kTrans^3*mMinus*qTrans*x1^2*x3 + 
      2*aPlus*bPlus*kTrans^3*mMinus*qTrans*x1^2*x3 + 
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
      3*bPlus*kTrans^2*qTrans^4*x3*x5^2 + bPlus*kTrans*qTrans^5*x3*x5^2)/
     (bPlus*qTrans^2*(aPlus*mMinus + kTrans*qTrans + qTrans^2)^2), 
   "LeadingLocalLPPolynomial" -> 
    -((-(aPlus^2*kTrans^5*mMinus*qTrans*x1*x3) - aPlus^3*kTrans^3*mMinus^2*
        qTrans*x1*x3 - 2*aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x1*x3 - 
       aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x1*x3 - aPlus^2*bPlus^2*kTrans*
        mMinus^3*qTrans*x1*x3 - 3*aPlus^2*kTrans^4*mMinus*qTrans^2*x1*x3 - 
       aPlus^3*kTrans^2*mMinus^2*qTrans^2*x1*x3 - 4*aPlus^2*bPlus*kTrans^2*
        mMinus^2*qTrans^2*x1*x3 - aPlus^3*bPlus*mMinus^3*qTrans^2*x1*x3 - 
       aPlus^2*bPlus^2*mMinus^3*qTrans^2*x1*x3 - 3*aPlus^2*kTrans^3*mMinus*
        qTrans^3*x1*x3 - aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x1*x3 - 
       4*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x1*x3 - 
       aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x1*x3 - aPlus^2*kTrans^2*mMinus*
        qTrans^4*x1*x3 - 3*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x1*x3 - 
       2*aPlus^2*bPlus*mMinus^2*qTrans^4*x1*x3 - aPlus*bPlus^2*mMinus^2*
        qTrans^4*x1*x3 - 3*aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*x3 - 
       aPlus*bPlus*mMinus*qTrans^6*x1*x3 - aPlus^2*kTrans^5*mMinus*qTrans*
        x1^2*x3 - aPlus^3*kTrans^3*mMinus^2*qTrans*x1^2*x3 - 
       2*aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x1^2*x3 - 
       aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x1^2*x3 - aPlus^2*bPlus^2*kTrans*
        mMinus^3*qTrans*x1^2*x3 - 3*aPlus^2*kTrans^4*mMinus*qTrans^2*x1^2*
        x3 - aPlus^3*kTrans^2*mMinus^2*qTrans^2*x1^2*x3 - 
       3*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x1^2*x3 - 
       3*aPlus^2*kTrans^3*mMinus*qTrans^3*x1^2*x3 - aPlus^2*bPlus*kTrans*
        mMinus^2*qTrans^3*x1^2*x3 - aPlus^2*kTrans^2*mMinus*qTrans^4*x1^2*
        x3 - aPlus^2*kTrans^5*mMinus*qTrans*x1*x3^2 - 
       2*aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x1*x3^2 - 
       aPlus^2*bPlus^2*kTrans*mMinus^3*qTrans*x1*x3^2 - 
       2*aPlus^2*kTrans^4*mMinus*qTrans^2*x1*x3^2 - 3*aPlus^2*bPlus*kTrans^2*
        mMinus^2*qTrans^2*x1*x3^2 - aPlus^2*bPlus^2*mMinus^3*qTrans^2*x1*
        x3^2 - aPlus^2*kTrans^3*mMinus*qTrans^3*x1*x3^2 - 
       aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x1*x3^2 - 
       aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x1*x3^2 - 
       aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x1*x3^2 - 
       2*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x1*x3^2 - 
       aPlus*bPlus^2*mMinus^2*qTrans^4*x1*x3^2 - aPlus*bPlus*kTrans*mMinus*
        qTrans^5*x1*x3^2 - aPlus^3*kTrans^4*mMinus^2*x1*x5 - 
       aPlus^3*bPlus*kTrans^2*mMinus^3*x1*x5 - aPlus^2*kTrans^5*mMinus*qTrans*
        x1*x5 - 2*aPlus^3*kTrans^3*mMinus^2*qTrans*x1*x5 - 
       aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x1*x5 - 2*aPlus^3*bPlus*kTrans*
        mMinus^3*qTrans*x1*x5 - 3*aPlus^2*kTrans^4*mMinus*qTrans^2*x1*x5 - 
       aPlus^3*kTrans^2*mMinus^2*qTrans^2*x1*x5 - 4*aPlus^2*bPlus*kTrans^2*
        mMinus^2*qTrans^2*x1*x5 - aPlus^3*bPlus*mMinus^3*qTrans^2*x1*x5 - 
       3*aPlus^2*kTrans^3*mMinus*qTrans^3*x1*x5 - aPlus*bPlus*kTrans^3*mMinus*
        qTrans^3*x1*x5 - 5*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x1*x5 - 
       aPlus^2*kTrans^2*mMinus*qTrans^4*x1*x5 - 3*aPlus*bPlus*kTrans^2*mMinus*
        qTrans^4*x1*x5 - 2*aPlus^2*bPlus*mMinus^2*qTrans^4*x1*x5 - 
       3*aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*x5 - aPlus*bPlus*mMinus*
        qTrans^6*x1*x5 - aPlus^3*kTrans^4*mMinus^2*x1^2*x5 - 
       aPlus^3*bPlus*kTrans^2*mMinus^3*x1^2*x5 - aPlus^2*kTrans^5*mMinus*
        qTrans*x1^2*x5 - 2*aPlus^3*kTrans^3*mMinus^2*qTrans*x1^2*x5 - 
       aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x1^2*x5 - 
       aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x1^2*x5 - 
       3*aPlus^2*kTrans^4*mMinus*qTrans^2*x1^2*x5 - aPlus^3*kTrans^2*mMinus^2*
        qTrans^2*x1^2*x5 - 2*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x1^2*
        x5 - 3*aPlus^2*kTrans^3*mMinus*qTrans^3*x1^2*x5 - 
       aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x1^2*x5 - 
       aPlus^2*kTrans^2*mMinus*qTrans^4*x1^2*x5 - aPlus^2*bPlus*kTrans^3*
        mMinus^2*qTrans*x3*x5 - aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x3*x5 - 
       aPlus^2*bPlus^2*kTrans*mMinus^3*qTrans*x3*x5 - 
       aPlus*bPlus*kTrans^4*mMinus*qTrans^2*x3*x5 - 4*aPlus^2*bPlus*kTrans^2*
        mMinus^2*qTrans^2*x3*x5 - aPlus*bPlus^2*kTrans^2*mMinus^2*qTrans^2*x3*
        x5 - aPlus^3*bPlus*mMinus^3*qTrans^2*x3*x5 - aPlus^2*bPlus^2*mMinus^3*
        qTrans^2*x3*x5 - 4*aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x3*x5 - 
       5*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x3*x5 - 
       2*aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x3*x5 - 
       6*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x3*x5 - 
       2*aPlus^2*bPlus*mMinus^2*qTrans^4*x3*x5 - aPlus*bPlus^2*mMinus^2*
        qTrans^4*x3*x5 - 4*aPlus*bPlus*kTrans*mMinus*qTrans^5*x3*x5 - 
       aPlus*bPlus*mMinus*qTrans^6*x3*x5 - aPlus^2*kTrans^6*mMinus*x1*x3*x5 - 
       2*aPlus^2*bPlus*kTrans^4*mMinus^2*x1*x3*x5 - aPlus^2*bPlus^2*kTrans^2*
        mMinus^3*x1*x3*x5 - 5*aPlus^2*kTrans^5*mMinus*qTrans*x1*x3*x5 - 
       3*aPlus^3*kTrans^3*mMinus^2*qTrans*x1*x3*x5 - 
       11*aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x1*x3*x5 - 
       3*aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x1*x3*x5 - 
       6*aPlus^2*bPlus^2*kTrans*mMinus^3*qTrans*x1*x3*x5 - 
       10*aPlus^2*kTrans^4*mMinus*qTrans^2*x1*x3*x5 - 3*aPlus*bPlus*kTrans^4*
        mMinus*qTrans^2*x1*x3*x5 - 3*aPlus^3*kTrans^2*mMinus^2*qTrans^2*x1*x3*
        x5 - 15*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x1*x3*x5 - 
       3*aPlus*bPlus^2*kTrans^2*mMinus^2*qTrans^2*x1*x3*x5 - 
       aPlus^3*bPlus*mMinus^3*qTrans^2*x1*x3*x5 - 3*aPlus^2*bPlus^2*mMinus^3*
        qTrans^2*x1*x3*x5 - 9*aPlus^2*kTrans^3*mMinus*qTrans^3*x1*x3*x5 - 
       9*aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x1*x3*x5 - 
       8*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x1*x3*x5 - 
       6*aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x1*x3*x5 - 
       3*aPlus^2*kTrans^2*mMinus*qTrans^4*x1*x3*x5 - 10*aPlus*bPlus*kTrans^2*
        mMinus*qTrans^4*x1*x3*x5 - 2*aPlus^2*bPlus*mMinus^2*qTrans^4*x1*x3*
        x5 - 3*aPlus*bPlus^2*mMinus^2*qTrans^4*x1*x3*x5 - 
       5*aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*x3*x5 - 
       aPlus*bPlus*mMinus*qTrans^6*x1*x3*x5 - aPlus^2*bPlus*kTrans^3*mMinus^2*
        qTrans*x3^2*x5 - aPlus^2*bPlus^2*kTrans*mMinus^3*qTrans*x3^2*x5 - 
       aPlus*bPlus*kTrans^4*mMinus*qTrans^2*x3^2*x5 - 
       2*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x3^2*x5 - 
       aPlus*bPlus^2*kTrans^2*mMinus^2*qTrans^2*x3^2*x5 - 
       aPlus^2*bPlus^2*mMinus^3*qTrans^2*x3^2*x5 - 3*aPlus*bPlus*kTrans^3*
        mMinus*qTrans^3*x3^2*x5 - aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x3^2*
        x5 - 2*aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x3^2*x5 - 
       3*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x3^2*x5 - 
       aPlus*bPlus^2*mMinus^2*qTrans^4*x3^2*x5 - aPlus*bPlus*kTrans*mMinus*
        qTrans^5*x3^2*x5 - aPlus^3*kTrans^4*mMinus^2*x1*x5^2 - 
       aPlus^3*bPlus*kTrans^2*mMinus^3*x1*x5^2 - aPlus^2*kTrans^5*mMinus*
        qTrans*x1*x5^2 - aPlus^3*kTrans^3*mMinus^2*qTrans*x1*x5^2 - 
       aPlus^2*bPlus*kTrans^3*mMinus^2*qTrans*x1*x5^2 - 
       aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x1*x5^2 - 
       2*aPlus^2*kTrans^4*mMinus*qTrans^2*x1*x5^2 - 3*aPlus^2*bPlus*kTrans^2*
        mMinus^2*qTrans^2*x1*x5^2 - aPlus^2*kTrans^3*mMinus*qTrans^3*x1*
        x5^2 - aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x1*x5^2 - 
       2*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x1*x5^2 - 
       2*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x1*x5^2 - 
       aPlus*bPlus*kTrans*mMinus*qTrans^5*x1*x5^2 - aPlus^2*bPlus*kTrans^3*
        mMinus^2*qTrans*x3*x5^2 - aPlus^3*bPlus*kTrans*mMinus^3*qTrans*x3*
        x5^2 - aPlus^2*bPlus^2*kTrans*mMinus^3*qTrans*x3*x5^2 - 
       aPlus*bPlus*kTrans^4*mMinus*qTrans^2*x3*x5^2 - 
       3*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^2*x3*x5^2 - 
       aPlus*bPlus^2*kTrans^2*mMinus^2*qTrans^2*x3*x5^2 - 
       3*aPlus*bPlus*kTrans^3*mMinus*qTrans^3*x3*x5^2 - 
       2*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^3*x3*x5^2 - 
       aPlus*bPlus^2*kTrans*mMinus^2*qTrans^3*x3*x5^2 - 
       3*aPlus*bPlus*kTrans^2*mMinus*qTrans^4*x3*x5^2 - 
       aPlus*bPlus*kTrans*mMinus*qTrans^5*x3*x5^2 - aPlus^4*bPlus*mMinus^4*
        qTrans^2*x5*y0*y2 - 4*aPlus^3*bPlus*kTrans*mMinus^3*qTrans^3*x5*y0*
        y2 - 6*aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^4*x5*y0*y2 - 
       4*aPlus^3*bPlus*mMinus^3*qTrans^4*x5*y0*y2 - 4*aPlus*bPlus*kTrans^3*
        mMinus*qTrans^5*x5*y0*y2 - 12*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^5*
        x5*y0*y2 - bPlus*kTrans^4*qTrans^6*x5*y0*y2 - 12*aPlus*bPlus*kTrans^2*
        mMinus*qTrans^6*x5*y0*y2 - 6*aPlus^2*bPlus*mMinus^2*qTrans^6*x5*y0*
        y2 - 4*bPlus*kTrans^3*qTrans^7*x5*y0*y2 - 12*aPlus*bPlus*kTrans*
        mMinus*qTrans^7*x5*y0*y2 - 6*bPlus*kTrans^2*qTrans^8*x5*y0*y2 - 
       4*aPlus*bPlus*mMinus*qTrans^8*x5*y0*y2 - 4*bPlus*kTrans*qTrans^9*x5*y0*
        y2 - bPlus*qTrans^10*x5*y0*y2 + aPlus^2*bPlus*kTrans^2*mMinus^2*
        qTrans^4*x3*y0*y4 + aPlus^3*bPlus*mMinus^3*qTrans^4*x3*y0*y4 + 
       aPlus^2*bPlus^2*mMinus^3*qTrans^4*x3*y0*y4 + 2*aPlus*bPlus*kTrans^3*
        mMinus*qTrans^5*x3*y0*y4 + 4*aPlus^2*bPlus*kTrans*mMinus^2*qTrans^5*
        x3*y0*y4 + 2*aPlus*bPlus^2*kTrans*mMinus^2*qTrans^5*x3*y0*y4 + 
       bPlus*kTrans^4*qTrans^6*x3*y0*y4 + 7*aPlus*bPlus*kTrans^2*mMinus*
        qTrans^6*x3*y0*y4 + bPlus^2*kTrans^2*mMinus*qTrans^6*x3*y0*y4 + 
       3*aPlus^2*bPlus*mMinus^2*qTrans^6*x3*y0*y4 + 2*aPlus*bPlus^2*mMinus^2*
        qTrans^6*x3*y0*y4 + 4*bPlus*kTrans^3*qTrans^7*x3*y0*y4 + 
       8*aPlus*bPlus*kTrans*mMinus*qTrans^7*x3*y0*y4 + 
       2*bPlus^2*kTrans*mMinus*qTrans^7*x3*y0*y4 + 6*bPlus*kTrans^2*qTrans^8*
        x3*y0*y4 + 3*aPlus*bPlus*mMinus*qTrans^8*x3*y0*y4 + 
       bPlus^2*mMinus*qTrans^8*x3*y0*y4 + 4*bPlus*kTrans*qTrans^9*x3*y0*y4 + 
       bPlus*qTrans^10*x3*y0*y4 + aPlus^4*kTrans^2*mMinus^3*qTrans^2*x1*y2*
        y4 + aPlus^4*bPlus*mMinus^4*qTrans^2*x1*y2*y4 + 
       2*aPlus^3*kTrans^3*mMinus^2*qTrans^3*x1*y2*y4 + 
       2*aPlus^3*bPlus*kTrans*mMinus^3*qTrans^3*x1*y2*y4 + 
       aPlus^2*kTrans^4*mMinus*qTrans^4*x1*y2*y4 + 2*aPlus^3*kTrans^2*
        mMinus^2*qTrans^4*x1*y2*y4 + aPlus^2*bPlus*kTrans^2*mMinus^2*qTrans^4*
        x1*y2*y4 + 3*aPlus^3*bPlus*mMinus^3*qTrans^4*x1*y2*y4 + 
       2*aPlus^2*kTrans^3*mMinus*qTrans^5*x1*y2*y4 + 4*aPlus^2*bPlus*kTrans*
        mMinus^2*qTrans^5*x1*y2*y4 + aPlus^2*kTrans^2*mMinus*qTrans^6*x1*y2*
        y4 + aPlus*bPlus*kTrans^2*mMinus*qTrans^6*x1*y2*y4 + 
       3*aPlus^2*bPlus*mMinus^2*qTrans^6*x1*y2*y4 + 2*aPlus*bPlus*kTrans*
        mMinus*qTrans^7*x1*y2*y4 + aPlus*bPlus*mMinus*qTrans^8*x1*y2*y4)/
      (aPlus*bPlus*mMinus*qTrans^2*(aPlus*mMinus + kTrans*qTrans + qTrans^2)^
        2)), "OriginalRegionVector" -> {-1, -1, -1, -1, -1, -1, 1}, 
   "InternalCoordinateWeights" -> <|x1 -> -1, x3 -> -1, x5 -> -1|>, 
   "SymmetricNormalCoordinateWeights" -> <|y0 -> -1/2, y2 -> -1/2, 
     y4 -> -1/2|>, "WSL" -> -3, "WHR" -> -2, "HierarchyGap" -> 1, 
   "ExactQuadraticNormalFormQ" -> True|>, "CentralSoftMRK" -> 
  <|"ExternalOrderAtVertices" -> {1, 2, 3, 5, 4}, 
   "ExactKinematicRules" -> {s12 -> C*delta + (K*M)/delta + (M*P)/delta^4 + 
       2*delta^2*R + (C*delta^4*R)/(K*M) + (P*R)/(delta*K) + 
       (delta^5*R^2)/(K*M) + 2*T + (delta^3*K*T)/P + (C*delta^5*T)/(M*P) + 
       (delta^3*R*T)/(K*M) + (delta^6*R*T)/(M*P) + (delta^4*T^2)/(M*P), 
     s23 -> -T - (delta^3*K*T)/P - (C*delta^5*T)/(M*P) - 
       (delta^6*R*T)/(M*P) - (delta^4*T^2)/(M*P), 
     s34 -> -(C*delta) + (P*R)/(delta*K) + (delta^3*K*T)/P, 
     s45 -> C*delta + (K*M)/delta + 2*delta^2*R + (C*delta^4*R)/(K*M) + 
       (delta^5*R^2)/(K*M) + (delta^3*R*T)/(K*M), 
     s15 -> -(C*delta) - delta^2*R - (C*delta^4*R)/(K*M) - 
       (delta^5*R^2)/(K*M) - T - (C*delta^5*T)/(M*P) - (delta^3*R*T)/(K*M) - 
       (delta^6*R*T)/(M*P) - (delta^4*T^2)/(M*P)}, 
   "AlignmentScaling" -> {-3, -3, 0, -3, -3, -3, 1}, 
   "HRFScalingOnAlignedFace" -> {-1, -1, -1, -1, -1, -1, 1}, 
   "TotalScaling" -> {-4, -4, -1, -4, -4, -4, 1}, 
   "NativeFLayers" -> <|-4 -> -(M*P*x2*(x1*x4 - x0*x5)), 
     -1 -> (-(P*R*x1*x2*x4) + K^2*M*x1*x3*x4 - P*R*x1*x2*x5 - K^2*M*x0*x3*x5)/
       K, 0 -> -(T*(x1*x2*x4 + x0*x3*x4 - 2*x0*x2*x5)), 
     1 -> C*(x1*x3*x4 + x0*x2*x5), 2 -> R*(2*x1*x3*x4 - x1*x2*x5 - x0*x3*x5), 
     3 -> -((T*(K^2*M*x0*x3*x4 - P*R*x1*x3*x4 + P*R*x1*x2*x5 + 
          K^2*M*x0*x3*x5))/(K*M*P)), 
     4 -> ((-(K*T^2*x0) + C*P*R*x1)*(x3*x4 - x2*x5))/(K*M*P), 
     5 -> -(((C*K*T*x0 - P*R^2*x1)*(x3*x4 - x2*x5))/(K*M*P)), 
     6 -> -((R*T*x0*(x3*x4 - x2*x5))/(M*P))|>, "AlignedFaceFLayers" -> 
    <|-10 -> -(M*(P*x2 - K*x3)*(x1*x4 - x0*x5)), -9 -> -(T*x0*x3*x4), 
     -8 -> C*x1*x3*x4, -7 -> (R*(-(P*x1*x2*x4) + 2*K*x1*x3*x4 - P*x1*x2*x5 - 
         K*x0*x3*x5))/K, 
     -6 -> -((T*(K*M*P*x1*x2*x4 + K^2*M*x0*x3*x4 - P*R*x1*x3*x4 - 
          2*K*M*P*x0*x2*x5 + K^2*M*x0*x3*x5))/(K*M*P)), 
     -5 -> (-(K*T^2*x0*x3*x4) + C*P*R*x1*x3*x4 + C*K*M*P*x0*x2*x5)/(K*M*P), 
     -4 -> -((C*K*T*x0*x3*x4 - P*R^2*x1*x3*x4 + K*M*P*R*x1*x2*x5)/(K*M*P)), 
     -3 -> -((R*T*(K*x0*x3*x4 + P*x1*x2*x5))/(K*M*P)), 
     -2 -> -(((-(K*T^2*x0) + C*P*R*x1)*x2*x5)/(K*M*P)), 
     -1 -> ((C*K*T*x0 - P*R^2*x1)*x2*x5)/(K*M*P), 
     0 -> (R*T*x0*x2*x5)/(M*P)|>, "TotalFLayers" -> 
    <|-13 -> -(M*(P*x2 - K*x3)*(x1*x4 - x0*x5)), -12 -> -(T*x0*x3*x4), 
     -11 -> C*x1*x3*x4, -10 -> (R*(-(P*x1*x2*x4) + 2*K*x1*x3*x4 - 
         P*x1*x2*x5 - K*x0*x3*x5))/K, 
     -9 -> -((T*(K*M*P*x1*x2*x4 + K^2*M*x0*x3*x4 - P*R*x1*x3*x4 - 
          2*K*M*P*x0*x2*x5 + K^2*M*x0*x3*x5))/(K*M*P)), 
     -8 -> (-(K*T^2*x0*x3*x4) + C*P*R*x1*x3*x4 + C*K*M*P*x0*x2*x5)/(K*M*P), 
     -7 -> -((C*K*T*x0*x3*x4 - P*R^2*x1*x3*x4 + K*M*P*R*x1*x2*x5)/(K*M*P)), 
     -6 -> -((R*T*(K*x0*x3*x4 + P*x1*x2*x5))/(K*M*P)), 
     -5 -> -(((-(K*T^2*x0) + C*P*R*x1)*x2*x5)/(K*M*P)), 
     -4 -> ((C*K*T*x0 - P*R^2*x1)*x2*x5)/(K*M*P), 
     -3 -> (R*T*x0*x2*x5)/(M*P)|>, "TotalULayers" -> 
    <|-8 -> x0*x3 + x1*x3 + x0*x4 + x1*x4 + x3*x4 + x0*x5 + x1*x5 + x3*x5, 
     -5 -> x2*(x0 + x1 + x4 + x5)|>, "RawSuperleadingWeight" -> -13, 
   "UWeightUnderWouldBeVector" -> -8, "LeadingAlignedFactorization" -> 
    -(M*(P*x2 - K*x3)*(x1*x4 - x0*x5)), "CancellationFactors" -> 
    {P*x2 - K*x3, x1*x4 - x0*x5}, "LeadingCancellationLocus" -> 
    {P*x2 - K*x3 == 0, x1*x4 - x0*x5 == 0}, "FirstAlignedObstruction" -> 
    -(T*x0*x3*x4), "FirstAlignedObstructionOnLeadingLocus" -> -(T*x0*x3*x4), 
   "FirstAlignedObstructionNonzeroInPositiveInteriorQ" -> True, 
   "CombinedFirstTwoAlignedLayers" -> -(T*x0*x3*x4) - 
     M*(P*x2 - K*x3)*(x1*x4 - x0*x5), "CombinedFirstTwoLayerGradient" -> 
    {-(T*x3*x4) + M*P*x2*x5 - K*M*x3*x5, -(M*(P*x2 - K*x3)*x4), 
     -(M*P*(x1*x4 - x0*x5)), -(T*x0*x4) + K*M*x1*x4 - K*M*x0*x5, 
     -(M*P*x1*x2) - T*x0*x3 + K*M*x1*x3, M*x0*(P*x2 - K*x3)}, 
   "PositiveStationaryPinchQ" -> False, "StationarityContradiction" -> "d/dx1 \
and d/dx2 force both leading factors to vanish; d/dx0 then equals -T x3 x4, \
which cannot vanish for T,x3,x4>0.", "ScaledFWithLeadingWeightRemoved" -> 
    -(M*P*x1*x2*x4) - (delta^3*P*R*x1*x2*x4)/K - delta^4*T*x1*x2*x4 - 
     delta*T*x0*x3*x4 - (delta^4*K*T*x0*x3*x4)/P - (C*delta^6*T*x0*x3*x4)/
      (M*P) - (delta^7*R*T*x0*x3*x4)/(M*P) - (delta^5*T^2*x0*x3*x4)/(M*P) + 
     C*delta^2*x1*x3*x4 + K*M*x1*x3*x4 + 2*delta^3*R*x1*x3*x4 + 
     (C*delta^5*R*x1*x3*x4)/(K*M) + (delta^6*R^2*x1*x3*x4)/(K*M) + 
     (delta^4*R*T*x1*x3*x4)/(K*M) + C*delta^5*x0*x2*x5 + M*P*x0*x2*x5 + 
     2*delta^4*T*x0*x2*x5 + (C*delta^9*T*x0*x2*x5)/(M*P) + 
     (delta^10*R*T*x0*x2*x5)/(M*P) + (delta^8*T^2*x0*x2*x5)/(M*P) - 
     delta^6*R*x1*x2*x5 - (C*delta^8*R*x1*x2*x5)/(K*M) - 
     (delta^3*P*R*x1*x2*x5)/K - (delta^9*R^2*x1*x2*x5)/(K*M) - 
     (delta^7*R*T*x1*x2*x5)/(K*M) - K*M*x0*x3*x5 - delta^3*R*x0*x3*x5 - 
     (delta^4*K*T*x0*x3*x5)/P, "HypersurfaceJetThroughOrder4" -> 
    -((K*M^2*P^2*x1*x2*x4 + delta^3*M*P^2*R*x1*x2*x4 + 
       delta^4*K*M*P*T*x1*x2*x4 + delta^4*K^2*M*T*x0*x3*x4 + 
       delta*K*M*P*T*x0*x3*x4 - C*delta^2*K*M*P*x1*x3*x4 - 
       K^2*M^2*P*x1*x3*x4 - 2*delta^3*K*M*P*R*x1*x3*x4 - 
       delta^4*P*R*T*x1*x3*x4 - K*M^2*P^2*x0*x2*x5 - 2*delta^4*K*M*P*T*x0*x2*
        x5 + delta^3*M*P^2*R*x1*x2*x5 + K^2*M^2*P*x0*x3*x5 + 
       delta^3*K*M*P*R*x0*x3*x5 + delta^4*K^2*M*T*x0*x3*x5)/(K*M*P)), 
   "FirstScalefulOrderCoefficientBeforeIdealReduction" -> 
    (-(K*T^2*x0*x3*x4) + C*P*R*x1*x3*x4 + C*K*M*P*x0*x2*x5)/(K*M*P), 
   "CertifiedOutsideSupportAtScalefulOrder" -> x0*x3*x4, 
   "WouldBeFinalHRFHierarchyGap" -> 1, "CandidateStatus" -> 
    "RejectedByFirstAlignedObstruction", "Interpretation" -> "After \
asymptotic-order alignment the very next layer is the genuine obstruction -T \
x0 x3 x4.  It is nonzero on the leading two-factor locus and the combined \
polynomial has no positive stationary pinch. The previously reported total \
vector is therefore a rejected would-be vector, not a certified central-soft \
MRK hidden region."|>, "CommonGraph" -> 
  <|"ExternalOrderAtVertices" -> {1, 2, 3, 5, 4}, 
   "Variables" -> {x0, x1, x2, x3, x4, x5}|>|>
