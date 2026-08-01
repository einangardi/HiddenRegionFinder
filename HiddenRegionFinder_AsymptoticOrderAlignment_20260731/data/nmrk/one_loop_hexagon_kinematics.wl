(* Created with the Wolfram Language : www.wolfram.com *)
<|"InvariantRules" ->
  <|s12 -> (q1*q1b*(1 + X56 + X45*X56 + X34*X45*X56)*
      (w*wb + w*wb*X34 - w*wb*z - w*wb*zb + w*wb*z*zb + X34*X45*z*zb +
       X34*X45*X56*z*zb - w*X34*X45*X56*z*zb - wb*X34*X45*X56*z*zb +
       w*wb*X34*X45*X56*z*zb))/(w*wb*X34*X45*X56*(-1 + z)*(-1 + zb)),
   s13 -> -((q1*q1b*(w*wb + w*wb*X34 - w*wb*z - w*wb*zb + w*wb*z*zb +
        X34*X45*z*zb + X34*X45*X56*z*zb - w*X34*X45*X56*z*zb -
        wb*X34*X45*X56*z*zb + w*wb*X34*X45*X56*z*zb))/
      (w*wb*(-1 + z)*(-1 + zb))),
   s14 -> -((q1*q1b*(w*wb + w*wb*X34 - w*wb*z - w*wb*zb + w*wb*z*zb +
        X34*X45*z*zb + X34*X45*X56*z*zb - w*X34*X45*X56*z*zb -
        wb*X34*X45*X56*z*zb + w*wb*X34*X45*X56*z*zb))/
      (w*wb*X34*(-1 + z)*(-1 + zb))),
   s15 -> -((q1*q1b*(w*wb + w*wb*X34 - w*wb*z - w*wb*zb + w*wb*z*zb +
        X34*X45*z*zb + X34*X45*X56*z*zb - w*X34*X45*X56*z*zb -
        wb*X34*X45*X56*z*zb + w*wb*X34*X45*X56*z*zb))/
      (w*wb*X34*X45*(-1 + z)*(-1 + zb))),
   s16 -> -((q1*q1b*(w*wb + w*wb*X34 - w*wb*z - w*wb*zb + w*wb*z*zb +
        X34*X45*z*zb + X34*X45*X56*z*zb - w*X34*X45*X56*z*zb -
        wb*X34*X45*X56*z*zb + w*wb*X34*X45*X56*z*zb))/
      (w*wb*X34*X45*X56*(-1 + z)*(-1 + zb))),
   s23 -> -((q1*q1b*(1 + X56 + X45*X56 + X34*X45*X56))/(X34*X45*X56)),
   s24 -> -((q1*q1b*(1 + X56 + X45*X56 + X34*X45*X56))/
      (X45*X56*(-1 + z)*(-1 + zb))),
   s25 -> -((q1*q1b*(1 + X56 + X45*X56 + X34*X45*X56)*z*zb)/
      (w*wb*X56*(-1 + z)*(-1 + zb))),
   s26 -> -((q1*q1b*(-1 + w)*(-1 + wb)*(1 + X56 + X45*X56 + X34*X45*X56)*z*
       zb)/(w*wb*(-1 + z)*(-1 + zb))),
   s34 -> (q1*q1b*(1 + X34 - z)*(1 + X34 - zb))/(X34*(-1 + z)*(-1 + zb)),
   s35 -> (q1*q1b*(-w + w*z + X34*X45*z)*(-wb + wb*zb + X34*X45*zb))/
     (w*wb*X34*X45*(-1 + z)*(-1 + zb)),
   s36 -> (q1*q1b*(-w + w*z - X34*X45*X56*z + w*X34*X45*X56*z)*
      (-wb + wb*zb - X34*X45*X56*zb + wb*X34*X45*X56*zb))/
     (w*wb*X34*X45*X56*(-1 + z)*(-1 + zb)),
   s45 -> (q1*q1b*(w + X45*z)*(wb + X45*zb))/(w*wb*X45*(-1 + z)*(-1 + zb)),
   s46 -> (q1*q1b*(w - X45*X56*z + w*X45*X56*z)*(wb - X45*X56*zb +
       wb*X45*X56*zb))/(w*wb*X45*X56*(-1 + z)*(-1 + zb)),
   s56 -> (q1*q1b*(-1 - X56 + w*X56)*(-1 - X56 + wb*X56)*z*zb)/
     (w*wb*X56*(-1 + z)*(-1 + zb))|>, "HexagonVariables" ->
  {x0, x1, x2, x3, x4, x5}, "U" -> x0 + x1 + x2 + x3 + x4 + x5,
 "FAllPairMandelstam" -> s12*x0*x1 + s13*x0*x1 + s14*x0*x1 + s15*x0*x1 +
   s23*x0*x1 + s24*x0*x1 + s25*x0*x1 + s34*x0*x1 + s35*x0*x1 + s45*x0*x1 +
   s23*x0*x2 + s24*x0*x2 + s25*x0*x2 + s34*x0*x2 + s35*x0*x2 + s45*x0*x2 +
   s23*x1*x2 + s24*x1*x2 + s25*x1*x2 + s26*x1*x2 + s34*x1*x2 + s35*x1*x2 +
   s36*x1*x2 + s45*x1*x2 + s46*x1*x2 + s56*x1*x2 + s15*x0*x3 + s16*x0*x3 +
   s56*x0*x3 + s23*x1*x3 + s24*x1*x3 + s26*x1*x3 + s34*x1*x3 + s36*x1*x3 +
   s46*x1*x3 + s12*x2*x3 + s13*x2*x3 + s14*x2*x3 + s16*x2*x3 + s23*x2*x3 +
   s24*x2*x3 + s26*x2*x3 + s34*x2*x3 + s36*x2*x3 + s46*x2*x3 + s14*x0*x4 +
   s15*x0*x4 + s16*x0*x4 + s45*x0*x4 + s46*x0*x4 + s56*x0*x4 + s14*x1*x4 +
   s15*x1*x4 + s45*x1*x4 + s12*x2*x4 + s13*x2*x4 + s16*x2*x4 + s23*x2*x4 +
   s26*x2*x4 + s36*x2*x4 + s12*x3*x4 + s13*x3*x4 + s15*x3*x4 + s16*x3*x4 +
   s23*x3*x4 + s25*x3*x4 + s26*x3*x4 + s35*x3*x4 + s36*x3*x4 + s56*x3*x4 +
   s12*x0*x5 + s14*x0*x5 + s15*x0*x5 + s16*x0*x5 + s24*x0*x5 + s25*x0*x5 +
   s26*x0*x5 + s45*x0*x5 + s46*x0*x5 + s56*x0*x5 + s12*x1*x5 + s14*x1*x5 +
   s15*x1*x5 + s24*x1*x5 + s25*x1*x5 + s45*x1*x5 + s13*x2*x5 + s16*x2*x5 +
   s36*x2*x5 + s13*x3*x5 + s15*x3*x5 + s16*x3*x5 + s35*x3*x5 + s36*x3*x5 +
   s56*x3*x5 + s13*x4*x5 + s14*x4*x5 + s15*x4*x5 + s16*x4*x5 + s34*x4*x5 +
   s35*x4*x5 + s36*x4*x5 + s45*x4*x5 + s46*x4*x5 + s56*x4*x5,
 "DependentMandelstamRules" -> {s13 -> -s12 - s23 + s45 + s46 + s56,
   s15 -> -s14 - s16 + s23 - s45 - s46 - s56, s24 -> -s14 - s34 - s45 - s46,
   s25 -> s14 + s16 - s23 - s35 + s46, s26 -> -s12 - s16 + s34 + s35 + s45,
   s36 -> s12 - s34 - s35 - s45 - s46 - s56},
 "FGenericInvariants" -> s16*x0*x2 - s14*x0*x3 + s23*x0*x3 - s45*x0*x3 -
   s46*x0*x3 - s14*x1*x3 - s16*x1*x3 + s23*x1*x3 - s45*x1*x3 - s46*x1*x3 -
   s56*x1*x3 + s23*x0*x4 - s16*x1*x4 + s23*x1*x4 - s46*x1*x4 - s56*x1*x4 +
   s45*x2*x4 + s12*x1*x5 - s34*x1*x5 - s35*x1*x5 - s45*x1*x5 - s46*x1*x5 -
   s56*x1*x5 + s16*x2*x5 - s23*x2*x5 - s34*x2*x5 - s35*x2*x5 - s14*x3*x5 -
   s34*x3*x5 - s45*x3*x5 - s46*x3*x5, "FMinimalSet" ->
  (q1*q1b*(-(w*wb*x0*x2) - w*wb*x0*x3 - w*wb*x0*x2*X34 - w*wb*x0*x3*X34 -
     w*wb*x0*x4 + w*wb*x1*x5 - w*wb*x2*X34*x5 - w*wb*x3*X34*x5 -
     w*wb*x0*x3*X56 - w*wb*x1*x3*X56 - w*wb*x0*x3*X34*X56 -
     w*wb*x1*x3*X34*X56 - w*wb*x0*x4*X56 - w*wb*x1*x4*X56 +
     w*wb*x2*X34*x4*X56 - w*wb*x0*x4*X45*X56 - w*wb*x1*x4*X45*X56 -
     w*wb*x0*X34*x4*X45*X56 - w*wb*x1*X34*x4*X45*X56 - w*wb*x3*X34*x5*X56 -
     w*wb*x2*X34*X45*x5*X56 - w*wb*x3*X34*X45*x5*X56 -
     w*wb*x2*X34^2*X45*x5*X56 - w*wb*x3*X34^2*X45*x5*X56 + w*wb*x0*x2*z +
     w*wb*x0*x3*z + w*wb*x0*x4*z - w*wb*x1*x5*z + w*wb*x0*x3*X56*z +
     w*wb*x1*x3*X56*z + w*wb*x0*x4*X56*z + w*wb*x1*x4*X56*z +
     w*wb*x0*x4*X45*X56*z + w*wb*x1*x4*X45*X56*z + w*wb*x0*X34*x4*X45*X56*z +
     wb*x1*X34*x4*X45*X56*z + wb*x2*X34*x4*X45*X56*z +
     wb*x1*X34*X45*x5*X56*z - w*wb*x1*X34*X45*x5*X56*z +
     wb*x2*X34*X45*x5*X56*z + w*wb*x0*x2*zb + w*wb*x0*x3*zb + w*wb*x0*x4*zb -
     w*wb*x1*x5*zb + w*wb*x0*x3*X56*zb + w*wb*x1*x3*X56*zb +
     w*wb*x0*x4*X56*zb + w*wb*x1*x4*X56*zb + w*wb*x0*x4*X45*X56*zb +
     w*wb*x1*x4*X45*X56*zb + w*wb*x0*X34*x4*X45*X56*zb +
     w*x1*X34*x4*X45*X56*zb + w*x2*X34*x4*X45*X56*zb +
     w*x1*X34*X45*x5*X56*zb - w*wb*x1*X34*X45*x5*X56*zb +
     w*x2*X34*X45*x5*X56*zb - w*wb*x0*x2*z*zb - w*wb*x0*x3*z*zb -
     w*wb*x0*x4*z*zb - x0*x2*X34*X45*z*zb + w*wb*x1*x5*z*zb -
     x2*X34*X45*x5*z*zb - w*wb*x0*x3*X56*z*zb - w*wb*x1*x3*X56*z*zb -
     w*wb*x0*x4*X56*z*zb - w*wb*x1*x4*X56*z*zb - x0*x2*X34*X45*X56*z*zb +
     w*x0*x2*X34*X45*X56*z*zb + wb*x0*x2*X34*X45*X56*z*zb -
     w*wb*x0*x2*X34*X45*X56*z*zb - w*wb*x0*x3*X34*X45*X56*z*zb -
     x1*x3*X34*X45*X56*z*zb - w*wb*x0*x4*X45*X56*z*zb -
     w*wb*x1*x4*X45*X56*z*zb - w*wb*x0*X34*x4*X45*X56*z*zb -
     x1*X34*x4*X45*X56*z*zb + x2*X34*x4*X45^2*X56*z*zb -
     w*x1*X34*X45*x5*X56*z*zb - wb*x1*X34*X45*x5*X56*z*zb +
     2*w*wb*x1*X34*X45*x5*X56*z*zb - x2*X34*X45*x5*X56*z*zb -
     x2*X34^2*X45^2*x5*X56*z*zb - x1*x3*X34*X45*X56^2*z*zb +
     w*x1*x3*X34*X45*X56^2*z*zb + wb*x1*x3*X34*X45*X56^2*z*zb -
     w*wb*x1*x3*X34*X45*X56^2*z*zb - x1*X34*x4*X45*X56^2*z*zb +
     w*x1*X34*x4*X45*X56^2*z*zb + wb*x1*X34*x4*X45*X56^2*z*zb -
     w*wb*x1*X34*x4*X45*X56^2*z*zb - x1*X34*x4*X45^2*X56^2*z*zb +
     w*x1*X34*x4*X45^2*X56^2*z*zb + wb*x1*X34*x4*X45^2*X56^2*z*zb -
     w*wb*x1*X34*x4*X45^2*X56^2*z*zb + x1*X34^2*X45^2*x5*X56^2*z*zb -
     w*x1*X34^2*X45^2*x5*X56^2*z*zb - wb*x1*X34^2*X45^2*x5*X56^2*z*zb +
     w*wb*x1*X34^2*X45^2*x5*X56^2*z*zb))/(w*wb*X34*X45*X56*(-1 + z)*
    (-1 + zb)), "StandardNMRKRules" -> {X34 -> X34h/eta, X56 -> X56h/eta},
 "StandardNMRKLeadingData" -> <|"EtaPower" -> -2,
   "Coefficient" -> (q1*q1b*(-1 + w)*(-1 + wb)*x1*X34h*X45*x5*X56h*z*zb)/
     (w*wb*(-1 + z)*(-1 + zb))|>|>
