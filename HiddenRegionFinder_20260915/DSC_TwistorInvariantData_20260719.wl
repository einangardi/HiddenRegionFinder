(* Created with the Wolfram Language : www.wolfram.com *)
<|"DuhrTwistorParameters" -> {eps, tau1, tau2, zc, zbc, a}, 
 "PhysicalToNativeLabelMap" -> <|1 -> 1, 2 -> 3, 3 -> 4, 4 -> 5, 5 -> 6, 
   6 -> 2|>, "PhysicalPairInvariants" -> 
  <|s12 -> (tau2*(-(eps^2*tau1) + zbc + eps^2*tau1*zbc + eps*tau2*zbc)*
      (-(a*eps^2*tau1) + eps^3*tau1 + eps^4*tau1*tau2 - a*eps^4*tau1*tau2 + 
       a*zbc - a*eps^2*zbc + eps*tau1*zbc - eps^3*tau1*zbc + a*eps*tau2*zbc - 
       a*eps^3*tau2*zbc + eps^2*tau1*tau2*zbc - a*eps^2*tau1*tau2*zbc - 
       eps^4*tau1*tau2*zbc + a*eps^4*tau1*tau2*zbc + a*eps^2*tau1*zc - 
       eps^3*tau1*zc - 2*eps^4*tau1*tau2*zc + 2*a*eps^4*tau1*tau2*zc + 
       a*eps^2*zbc*zc + eps^3*tau1*zbc*zc - a*eps*tau2*zbc*zc + 
       2*a*eps^3*tau2*zbc*zc - eps^2*tau1*tau2*zbc*zc + 
       a*eps^2*tau1*tau2*zbc*zc + 2*eps^4*tau1*tau2*zbc*zc - 
       2*a*eps^4*tau1*tau2*zbc*zc + eps^4*tau1*tau2*zc^2 - 
       a*eps^4*tau1*tau2*zc^2 - a*eps^3*tau2*zbc*zc^2 - 
       eps^4*tau1*tau2*zbc*zc^2 + a*eps^4*tau1*tau2*zbc*zc^2))/
     ((-(eps*tau1) + a*zbc + eps*tau1*zbc + a*tau2*zbc)*
      (-1 - tau1 - eps*tau2 + eps*tau2*zc)*(a*eps^2*tau1 - eps^3*tau1 - 
       eps^4*tau1*tau2 + a*eps^4*tau1*tau2 - a*zbc + a*eps^2*zbc - 
       eps*tau1*zbc + eps^3*tau1*zbc - a*eps*tau2*zbc + a*eps^3*tau2*zbc - 
       eps^2*tau1*tau2*zbc + a*eps^2*tau1*tau2*zbc + eps^4*tau1*tau2*zbc - 
       a*eps^4*tau1*tau2*zbc + eps^4*tau1*tau2*zc - a*eps^4*tau1*tau2*zc + 
       a*eps^2*tau2*zbc*zc - a*eps^3*tau2*zbc*zc - eps^4*tau1*tau2*zbc*zc + 
       a*eps^4*tau1*tau2*zbc*zc)), 
   s13 -> -((-(eps*tau1) - eps^2*tau1*tau2 + a*eps^2*tau1*tau2 + a*zbc + 
       eps*tau1*zbc + a*eps*tau2*zbc + eps^2*tau1*tau2*zbc - 
       a*eps^2*tau1*tau2*zbc + eps^2*tau1*tau2*zc - a*eps^2*tau1*tau2*zc - 
       a*eps*tau2*zbc*zc - eps^2*tau1*tau2*zbc*zc + a*eps^2*tau1*tau2*zbc*zc)/
      (a*(-(eps*tau1) + a*zbc + eps*tau1*zbc + a*tau2*zbc)*
       (-1 - tau1 - eps*tau2 + eps*tau2*zc))), 
   s14 -> (1 + eps*tau2 - a*eps*tau2 - eps*tau2*zc + a*eps*tau2*zc)/
     ((-1 + a)*a*(1 + tau1 + eps*tau2 - eps*tau2*zc)), 
   s15 -> -(1/((-1 + a)*(1 + tau1 + eps*tau2 - eps*tau2*zc))), 
   s16 -> (eps^2*tau2*zbc*zc)/(a*eps^2*tau1 - eps^3*tau1 - eps^4*tau1*tau2 + 
      a*eps^4*tau1*tau2 - a*zbc + a*eps^2*zbc - eps*tau1*zbc + 
      eps^3*tau1*zbc - a*eps*tau2*zbc + a*eps^3*tau2*zbc - 
      eps^2*tau1*tau2*zbc + a*eps^2*tau1*tau2*zbc + eps^4*tau1*tau2*zbc - 
      a*eps^4*tau1*tau2*zbc + eps^4*tau1*tau2*zc - a*eps^4*tau1*tau2*zc + 
      a*eps^2*tau2*zbc*zc - a*eps^3*tau2*zbc*zc - eps^4*tau1*tau2*zbc*zc + 
      a*eps^4*tau1*tau2*zbc*zc), 
   s23 -> (eps^2*tau1)/(a*eps^2*tau1 - eps^3*tau1 - eps^4*tau1*tau2 + 
      a*eps^4*tau1*tau2 - a*zbc + a*eps^2*zbc - eps*tau1*zbc + 
      eps^3*tau1*zbc - a*eps*tau2*zbc + a*eps^3*tau2*zbc - 
      eps^2*tau1*tau2*zbc + a*eps^2*tau1*tau2*zbc + eps^4*tau1*tau2*zbc - 
      a*eps^4*tau1*tau2*zbc + eps^4*tau1*tau2*zc - a*eps^4*tau1*tau2*zc + 
      a*eps^2*tau2*zbc*zc - a*eps^3*tau2*zbc*zc - eps^4*tau1*tau2*zbc*zc + 
      a*eps^4*tau1*tau2*zbc*zc), 
   s24 -> ((eps^2*tau1 - a*eps^2*tau1 + a*zbc - a*eps*zbc - eps^2*tau1*zbc + 
       a*eps^2*tau1*zbc)*(-(eps*tau1) + a*tau2*zbc - a*eps^2*tau2*zbc + 
       a*eps^2*tau2*zbc*zc))/((-1 + a)*(-(eps*tau1) + a*zbc + eps*tau1*zbc + 
       a*tau2*zbc)*(a*eps^2*tau1 - eps^3*tau1 - eps^4*tau1*tau2 + 
       a*eps^4*tau1*tau2 - a*zbc + a*eps^2*zbc - eps*tau1*zbc + 
       eps^3*tau1*zbc - a*eps*tau2*zbc + a*eps^3*tau2*zbc - 
       eps^2*tau1*tau2*zbc + a*eps^2*tau1*tau2*zbc + eps^4*tau1*tau2*zbc - 
       a*eps^4*tau1*tau2*zbc + eps^4*tau1*tau2*zc - a*eps^4*tau1*tau2*zc + 
       a*eps^2*tau2*zbc*zc - a*eps^3*tau2*zbc*zc - eps^4*tau1*tau2*zbc*zc + 
       a*eps^4*tau1*tau2*zbc*zc)), 
   s25 -> -(((-1 + a*eps - eps*tau2 + a*eps*tau2)*zbc*
       (a*eps*tau1 - eps^3*tau1*tau2 + a*eps^3*tau1*tau2 - a*tau2*zbc + 
        a*eps^2*tau2*zbc - eps*tau1*tau2*zbc + a*eps*tau1*tau2*zbc + 
        eps^3*tau1*tau2*zbc - a*eps^3*tau1*tau2*zbc + eps^3*tau1*tau2*zc - 
        a*eps^3*tau1*tau2*zc - a*eps^2*tau2*zbc*zc - eps^3*tau1*tau2*zbc*zc + 
        a*eps^3*tau1*tau2*zbc*zc))/((-1 + a)*(-(eps*tau1) + a*zbc + 
        eps*tau1*zbc + a*tau2*zbc)*(a*eps^2*tau1 - eps^3*tau1 - 
        eps^4*tau1*tau2 + a*eps^4*tau1*tau2 - a*zbc + a*eps^2*zbc - 
        eps*tau1*zbc + eps^3*tau1*zbc - a*eps*tau2*zbc + a*eps^3*tau2*zbc - 
        eps^2*tau1*tau2*zbc + a*eps^2*tau1*tau2*zbc + eps^4*tau1*tau2*zbc - 
        a*eps^4*tau1*tau2*zbc + eps^4*tau1*tau2*zc - a*eps^4*tau1*tau2*zc + 
        a*eps^2*tau2*zbc*zc - a*eps^3*tau2*zbc*zc - eps^4*tau1*tau2*zbc*zc + 
        a*eps^4*tau1*tau2*zbc*zc))), 
   s26 -> -((tau1*tau2*(eps^2 + zbc - eps^2*zbc - eps^2*zc + eps^2*zbc*zc))/
      ((-(eps*tau1) + a*zbc + eps*tau1*zbc + a*tau2*zbc)*
       (-1 - tau1 - eps*tau2 + eps*tau2*zc))), 
   s34 -> -((a*zbc)/((-1 + a)*(-(eps*tau1) + a*zbc + eps*tau1*zbc + 
        a*tau2*zbc))), 
   s35 -> -((eps*tau1 - a*eps*tau1 - a*zbc - eps*tau1*zbc + a*eps*tau1*zbc)/
      ((-1 + a)*a*(-(eps*tau1) + a*zbc + eps*tau1*zbc + a*tau2*zbc))), 
   s36 -> (tau1*(-a - eps*tau1 - a*eps^2*tau2 + a*eps^2*tau2*zc)*
      (eps^3*tau1 + eps^4*tau1*tau2 - a*eps^4*tau1*tau2 - a*eps^2*zbc + 
       eps*tau1*zbc - 2*eps^3*tau1*zbc - a*eps^3*tau2*zbc + 
       eps^2*tau1*tau2*zbc - a*eps^2*tau1*tau2*zbc - 2*eps^4*tau1*tau2*zbc + 
       2*a*eps^4*tau1*tau2*zbc - a*zbc^2 + a*eps^2*zbc^2 - eps*tau1*zbc^2 + 
       eps^3*tau1*zbc^2 - a*eps*tau2*zbc^2 + a*eps^3*tau2*zbc^2 - 
       eps^2*tau1*tau2*zbc^2 + a*eps^2*tau1*tau2*zbc^2 + 
       eps^4*tau1*tau2*zbc^2 - a*eps^4*tau1*tau2*zbc^2 - eps^4*tau1*tau2*zc + 
       a*eps^4*tau1*tau2*zc - a*eps^2*tau2*zbc*zc + a*eps^3*tau2*zbc*zc + 
       2*eps^4*tau1*tau2*zbc*zc - 2*a*eps^4*tau1*tau2*zbc*zc + 
       a*eps^2*tau2*zbc^2*zc - a*eps^3*tau2*zbc^2*zc - 
       eps^4*tau1*tau2*zbc^2*zc + a*eps^4*tau1*tau2*zbc^2*zc))/
     (a*(-(eps*tau1) + a*zbc + eps*tau1*zbc + a*tau2*zbc)*
      (-1 - tau1 - eps*tau2 + eps*tau2*zc)*(a*eps^2*tau1 - eps^3*tau1 - 
       eps^4*tau1*tau2 + a*eps^4*tau1*tau2 - a*zbc + a*eps^2*zbc - 
       eps*tau1*zbc + eps^3*tau1*zbc - a*eps*tau2*zbc + a*eps^3*tau2*zbc - 
       eps^2*tau1*tau2*zbc + a*eps^2*tau1*tau2*zbc + eps^4*tau1*tau2*zbc - 
       a*eps^4*tau1*tau2*zbc + eps^4*tau1*tau2*zc - a*eps^4*tau1*tau2*zc + 
       a*eps^2*tau2*zbc*zc - a*eps^3*tau2*zbc*zc - eps^4*tau1*tau2*zbc*zc + 
       a*eps^4*tau1*tau2*zbc*zc)), s45 -> a^(-1), 
   s46 -> ((-a + a*eps - eps*tau1 + a*eps*tau1)*(-(eps^2*tau1) - 
       eps^3*tau1*tau2 + a*eps^3*tau1*tau2 - tau1*zbc + eps^2*tau1*zbc - 
       eps*tau1*tau2*zbc + a*eps*tau1*tau2*zbc + eps^3*tau1*tau2*zbc - 
       a*eps^3*tau1*tau2*zbc + eps^3*tau1*tau2*zc - a*eps^3*tau1*tau2*zc + 
       a*eps*tau2*zbc*zc - eps^3*tau1*tau2*zbc*zc + a*eps^3*tau1*tau2*zbc*
        zc))/((-1 + a)*a*(-1 - tau1 - eps*tau2 + eps*tau2*zc)*
      (a*eps^2*tau1 - eps^3*tau1 - eps^4*tau1*tau2 + a*eps^4*tau1*tau2 - 
       a*zbc + a*eps^2*zbc - eps*tau1*zbc + eps^3*tau1*zbc - a*eps*tau2*zbc + 
       a*eps^3*tau2*zbc - eps^2*tau1*tau2*zbc + a*eps^2*tau1*tau2*zbc + 
       eps^4*tau1*tau2*zbc - a*eps^4*tau1*tau2*zbc + eps^4*tau1*tau2*zc - 
       a*eps^4*tau1*tau2*zc + a*eps^2*tau2*zbc*zc - a*eps^3*tau2*zbc*zc - 
       eps^4*tau1*tau2*zbc*zc + a*eps^4*tau1*tau2*zbc*zc)), 
   s56 -> ((-a + eps + eps^2*tau2 - a*eps^2*tau2 - eps^2*tau2*zc + 
       a*eps^2*tau2*zc)*(-(eps^2*tau1) - tau1*zbc + eps^2*tau1*zbc + 
       eps*tau2*zbc*zc))/((-1 + a)*(1 + tau1 + eps*tau2 - eps*tau2*zc)*
      (a*eps^2*tau1 - eps^3*tau1 - eps^4*tau1*tau2 + a*eps^4*tau1*tau2 - 
       a*zbc + a*eps^2*zbc - eps*tau1*zbc + eps^3*tau1*zbc - a*eps*tau2*zbc + 
       a*eps^3*tau2*zbc - eps^2*tau1*tau2*zbc + a*eps^2*tau1*tau2*zbc + 
       eps^4*tau1*tau2*zbc - a*eps^4*tau1*tau2*zbc + eps^4*tau1*tau2*zc - 
       a*eps^4*tau1*tau2*zc + a*eps^2*tau2*zbc*zc - a*eps^3*tau2*zbc*zc - 
       eps^4*tau1*tau2*zbc*zc + a*eps^4*tau1*tau2*zbc*zc))|>, 
 "PhysicalPairLeadingPowers" -> <|s12 -> 0, s13 -> 0, s14 -> 0, s15 -> 0, 
   s16 -> 2, s23 -> 2, s24 -> 0, s25 -> 0, s26 -> 0, s34 -> 0, s35 -> 0, 
   s36 -> 0, s45 -> 0, s46 -> 0, s56 -> 0|>, "PhysicalPairLeadingData" -> 
  <|s12 -> <|"Power" -> 0, "LeadingCoefficient" -> 
      tau2/(a*(1 + tau1)*(1 + tau2))|>, 
   s13 -> <|"Power" -> 0, "LeadingCoefficient" -> 
      1/(a*(1 + tau1)*(1 + tau2))|>, 
   s14 -> <|"Power" -> 0, "LeadingCoefficient" -> 
      1/((-1 + a)*a*(1 + tau1))|>, 
   s15 -> <|"Power" -> 0, "LeadingCoefficient" -> 
      -(1/((-1 + a)*(1 + tau1)))|>, 
   s16 -> <|"Power" -> 2, "LeadingCoefficient" -> -((tau2*zc)/a)|>, 
   s23 -> <|"Power" -> 2, "LeadingCoefficient" -> -(tau1/(a*zbc))|>, 
   s24 -> <|"Power" -> 0, "LeadingCoefficient" -> 
      -(tau2/((-1 + a)*(1 + tau2)))|>, 
   s25 -> <|"Power" -> 0, "LeadingCoefficient" -> 
      tau2/((-1 + a)*a*(1 + tau2))|>, 
   s26 -> <|"Power" -> 0, "LeadingCoefficient" -> 
      (tau1*tau2)/(a*(1 + tau1)*(1 + tau2))|>, 
   s34 -> <|"Power" -> 0, "LeadingCoefficient" -> 
      -(1/((-1 + a)*(1 + tau2)))|>, 
   s35 -> <|"Power" -> 0, "LeadingCoefficient" -> 
      1/((-1 + a)*a*(1 + tau2))|>, 
   s36 -> <|"Power" -> 0, "LeadingCoefficient" -> 
      tau1/(a*(1 + tau1)*(1 + tau2))|>, 
   s45 -> <|"Power" -> 0, "LeadingCoefficient" -> a^(-1)|>, 
   s46 -> <|"Power" -> 0, "LeadingCoefficient" -> 
      tau1/((-1 + a)*a*(1 + tau1))|>, 
   s56 -> <|"Power" -> 0, "LeadingCoefficient" -> 
      -(tau1/((-1 + a)*(1 + tau1)))|>|>, "SmallPhysicalPairs" -> {s16, s23}, 
 "MREVInvariantCoordinateMap" -> 
  <|"X34" -> ((-1 + a)*(-(eps*tau1) - eps^2*tau1*tau2 + a*eps^2*tau1*tau2 + 
       a*zbc + eps*tau1*zbc + a*eps*tau2*zbc + eps^2*tau1*tau2*zbc - 
       a*eps^2*tau1*tau2*zbc + eps^2*tau1*tau2*zc - a*eps^2*tau1*tau2*zc - 
       a*eps*tau2*zbc*zc - eps^2*tau1*tau2*zbc*zc + a*eps^2*tau1*tau2*zbc*
        zc))/((-(eps*tau1) + a*zbc + eps*tau1*zbc + a*tau2*zbc)*
      (1 + eps*tau2 - a*eps*tau2 - eps*tau2*zc + a*eps*tau2*zc)), 
   "X45" -> -((1 + eps*tau2 - a*eps*tau2 - eps*tau2*zc + a*eps*tau2*zc)/a), 
   "X56" -> (a*eps^2*tau1 - eps^3*tau1 - eps^4*tau1*tau2 + 
      a*eps^4*tau1*tau2 - a*zbc + a*eps^2*zbc - eps*tau1*zbc + 
      eps^3*tau1*zbc - a*eps*tau2*zbc + a*eps^3*tau2*zbc - 
      eps^2*tau1*tau2*zbc + a*eps^2*tau1*tau2*zbc + eps^4*tau1*tau2*zbc - 
      a*eps^4*tau1*tau2*zbc + eps^4*tau1*tau2*zc - a*eps^4*tau1*tau2*zc + 
      a*eps^2*tau2*zbc*zc - a*eps^3*tau2*zbc*zc - eps^4*tau1*tau2*zbc*zc + 
      a*eps^4*tau1*tau2*zbc*zc)/((-1 + a)*eps^2*tau2*zbc*zc*
      (-1 - tau1 - eps*tau2 + eps*tau2*zc)), 
   "Q" -> -((eps^2*tau1*(-(eps*tau1) - eps^2*tau1*tau2 + a*eps^2*tau1*tau2 + 
        a*zbc + eps*tau1*zbc + a*eps*tau2*zbc + eps^2*tau1*tau2*zbc - 
        a*eps^2*tau1*tau2*zbc + eps^2*tau1*tau2*zc - a*eps^2*tau1*tau2*zc - 
        a*eps*tau2*zbc*zc - eps^2*tau1*tau2*zbc*zc + a*eps^2*tau1*tau2*zbc*
         zc))/(a*tau2*(-(eps^2*tau1) + zbc + eps^2*tau1*zbc + eps*tau2*zbc)*
       (-(a*eps^2*tau1) + eps^3*tau1 + eps^4*tau1*tau2 - a*eps^4*tau1*tau2 + 
        a*zbc - a*eps^2*zbc + eps*tau1*zbc - eps^3*tau1*zbc + 
        a*eps*tau2*zbc - a*eps^3*tau2*zbc + eps^2*tau1*tau2*zbc - 
        a*eps^2*tau1*tau2*zbc - eps^4*tau1*tau2*zbc + a*eps^4*tau1*tau2*zbc + 
        a*eps^2*tau1*zc - eps^3*tau1*zc - 2*eps^4*tau1*tau2*zc + 
        2*a*eps^4*tau1*tau2*zc + a*eps^2*zbc*zc + eps^3*tau1*zbc*zc - 
        a*eps*tau2*zbc*zc + 2*a*eps^3*tau2*zbc*zc - eps^2*tau1*tau2*zbc*zc + 
        a*eps^2*tau1*tau2*zbc*zc + 2*eps^4*tau1*tau2*zbc*zc - 
        2*a*eps^4*tau1*tau2*zbc*zc + eps^4*tau1*tau2*zc^2 - 
        a*eps^4*tau1*tau2*zc^2 - a*eps^3*tau2*zbc*zc^2 - 
        eps^4*tau1*tau2*zbc*zc^2 + a*eps^4*tau1*tau2*zbc*zc^2))), 
   "L" -> -(((-(eps^2*tau1) + zbc + eps^2*tau1*zbc + eps*tau2*zbc)*
       (-(a*eps^2*tau1) + eps^3*tau1 + eps^4*tau1*tau2 - a*eps^4*tau1*tau2 + 
        a*zbc - a*eps^2*zbc + eps*tau1*zbc - eps^3*tau1*zbc + 
        a*eps*tau2*zbc - a*eps^3*tau2*zbc + eps^2*tau1*tau2*zbc - 
        a*eps^2*tau1*tau2*zbc - eps^4*tau1*tau2*zbc + a*eps^4*tau1*tau2*zbc + 
        a*eps^2*tau1*zc - eps^3*tau1*zc - 2*eps^4*tau1*tau2*zc + 
        2*a*eps^4*tau1*tau2*zc + a*eps^2*zbc*zc + eps^3*tau1*zbc*zc - 
        a*eps*tau2*zbc*zc + 2*a*eps^3*tau2*zbc*zc - eps^2*tau1*tau2*zbc*zc + 
        a*eps^2*tau1*tau2*zbc*zc + 2*eps^4*tau1*tau2*zbc*zc - 
        2*a*eps^4*tau1*tau2*zbc*zc + eps^4*tau1*tau2*zc^2 - 
        a*eps^4*tau1*tau2*zc^2 - a*eps^3*tau2*zbc*zc^2 - 
        eps^4*tau1*tau2*zbc*zc^2 + a*eps^4*tau1*tau2*zbc*zc^2))/
      (eps^2*zbc*(-(eps*tau1) + a*zbc + eps*tau1*zbc + a*tau2*zbc)*zc*
       (-1 - tau1 - eps*tau2 + eps*tau2*zc))), 
   "zShiftProduct" -> ((-1 + a)^2*eps^2*tau1*(-(eps*tau1) - eps^2*tau1*tau2 + 
       a*eps^2*tau1*tau2 + a*zbc + eps*tau1*zbc + a*eps*tau2*zbc + 
       eps^2*tau1*tau2*zbc - a*eps^2*tau1*tau2*zbc + eps^2*tau1*tau2*zc - 
       a*eps^2*tau1*tau2*zc - a*eps*tau2*zbc*zc - eps^2*tau1*tau2*zbc*zc + 
       a*eps^2*tau1*tau2*zbc*zc))/((eps^2*tau1 - a*eps^2*tau1 + a*zbc - 
       a*eps*zbc - eps^2*tau1*zbc + a*eps^2*tau1*zbc)*
      (1 + eps*tau2 - a*eps*tau2 - eps*tau2*zc + a*eps*tau2*zc)*
      (-(eps*tau1) + a*tau2*zbc - a*eps^2*tau2*zbc + a*eps^2*tau2*zbc*zc)), 
   "zShiftSum" -> -(((-1 + a)*eps*(2*eps^2*tau1^2 - a*eps^2*tau1^2 + 
        2*eps^3*tau1^2*tau2 - 3*a*eps^3*tau1^2*tau2 + a^2*eps^3*tau1^2*tau2 + 
        a*tau1*zbc - 2*a*eps*tau1*zbc - 2*eps^2*tau1^2*zbc + 
        a*eps^2*tau1^2*zbc - a^2*eps*tau1*tau2*zbc - 2*a*eps^2*tau1*tau2*
         zbc + a^2*eps^2*tau1*tau2*zbc + a*eps^3*tau1*tau2*zbc - 
        2*eps^3*tau1^2*tau2*zbc + 3*a*eps^3*tau1^2*tau2*zbc - 
        a^2*eps^3*tau1^2*tau2*zbc - a*eps^2*tau1*tau2^2*zbc + 
        a^2*eps^2*tau1*tau2^2*zbc + a*eps^4*tau1*tau2^2*zbc - 
        a^2*eps^4*tau1*tau2^2*zbc + a^2*tau2*zbc^2 - a^2*eps^2*tau2*zbc^2 + 
        a*eps*tau1*tau2*zbc^2 - a*eps^3*tau1*tau2*zbc^2 + 
        a^2*eps*tau2^2*zbc^2 - a^2*eps^3*tau2^2*zbc^2 + 
        a*eps^2*tau1*tau2^2*zbc^2 - a^2*eps^2*tau1*tau2^2*zbc^2 - 
        a*eps^4*tau1*tau2^2*zbc^2 + a^2*eps^4*tau1*tau2^2*zbc^2 - 
        2*eps^3*tau1^2*tau2*zc + 3*a*eps^3*tau1^2*tau2*zc - 
        a^2*eps^3*tau1^2*tau2*zc - a*eps*tau1*tau2*zbc*zc + 
        a^2*eps*tau1*tau2*zbc*zc + 2*a*eps^2*tau1*tau2*zbc*zc - 
        a^2*eps^2*tau1*tau2*zbc*zc - a*eps^3*tau1*tau2*zbc*zc + 
        2*eps^3*tau1^2*tau2*zbc*zc - 3*a*eps^3*tau1^2*tau2*zbc*zc + 
        a^2*eps^3*tau1^2*tau2*zbc*zc + a*eps^2*tau1*tau2^2*zbc*zc - 
        a^2*eps^2*tau1*tau2^2*zbc*zc - 2*a*eps^4*tau1*tau2^2*zbc*zc + 
        2*a^2*eps^4*tau1*tau2^2*zbc*zc + a^2*eps^2*tau2*zbc^2*zc + 
        a*eps^3*tau1*tau2*zbc^2*zc - a^2*eps*tau2^2*zbc^2*zc + 
        2*a^2*eps^3*tau2^2*zbc^2*zc - a*eps^2*tau1*tau2^2*zbc^2*zc + 
        a^2*eps^2*tau1*tau2^2*zbc^2*zc + 2*a*eps^4*tau1*tau2^2*zbc^2*zc - 
        2*a^2*eps^4*tau1*tau2^2*zbc^2*zc + a*eps^4*tau1*tau2^2*zbc*zc^2 - 
        a^2*eps^4*tau1*tau2^2*zbc*zc^2 - a^2*eps^3*tau2^2*zbc^2*zc^2 - 
        a*eps^4*tau1*tau2^2*zbc^2*zc^2 + a^2*eps^4*tau1*tau2^2*zbc^2*zc^2))/
      ((eps^2*tau1 - a*eps^2*tau1 + a*zbc - a*eps*zbc - eps^2*tau1*zbc + 
        a*eps^2*tau1*zbc)*(1 + eps*tau2 - a*eps*tau2 - eps*tau2*zc + 
        a*eps*tau2*zc)*(-(eps*tau1) + a*tau2*zbc - a*eps^2*tau2*zbc + 
        a*eps^2*tau2*zbc*zc))), "zProduct" -> 
    (a^2*zbc*(1 - a*eps + eps*tau2 - a*eps*tau2 - eps*tau2*zc + 
       a*eps*tau2*zc)*(-(eps*tau1) + tau2*zbc - eps^2*tau2*zbc + 
       eps^2*tau2*zbc*zc))/((eps^2*tau1 - a*eps^2*tau1 + a*zbc - a*eps*zbc - 
       eps^2*tau1*zbc + a*eps^2*tau1*zbc)*(1 + eps*tau2 - a*eps*tau2 - 
       eps*tau2*zc + a*eps*tau2*zc)*(-(eps*tau1) + a*tau2*zbc - 
       a*eps^2*tau2*zbc + a*eps^2*tau2*zbc*zc)), 
   "wProduct" -> (a*(1 - a*eps + eps*tau2 - a*eps*tau2 - eps*tau2*zc + 
       a*eps*tau2*zc)*(-(eps*tau1) + tau2*zbc - eps^2*tau2*zbc + 
       eps^2*tau2*zbc*zc))/((-1 + a*eps - eps*tau2 + a*eps*tau2)*
      (a*eps*tau1 - eps^3*tau1*tau2 + a*eps^3*tau1*tau2 - a*tau2*zbc + 
       a*eps^2*tau2*zbc - eps*tau1*tau2*zbc + a*eps*tau1*tau2*zbc + 
       eps^3*tau1*tau2*zbc - a*eps^3*tau1*tau2*zbc + eps^3*tau1*tau2*zc - 
       a*eps^3*tau1*tau2*zc - a*eps^2*tau2*zbc*zc - eps^3*tau1*tau2*zbc*zc + 
       a*eps^3*tau1*tau2*zbc*zc)), "wShiftProduct" -> 
    ((-1 + a)^2*eps^2*tau1*tau2^2*zc*(eps^2 + zbc - eps^2*zbc - eps^2*zc + 
       eps^2*zbc*zc))/((-1 + a*eps - eps*tau2 + a*eps*tau2)*
      (a*eps*tau1 - eps^3*tau1*tau2 + a*eps^3*tau1*tau2 - a*tau2*zbc + 
       a*eps^2*tau2*zbc - eps*tau1*tau2*zbc + a*eps*tau1*tau2*zbc + 
       eps^3*tau1*tau2*zbc - a*eps^3*tau1*tau2*zbc + eps^3*tau1*tau2*zc - 
       a*eps^3*tau1*tau2*zc - a*eps^2*tau2*zbc*zc - eps^3*tau1*tau2*zbc*zc + 
       a*eps^3*tau1*tau2*zbc*zc)), "wShiftSum" -> 
    -(((-1 + a)*eps*tau2*(-(eps^2*tau1) + a*eps^3*tau1 - eps^3*tau1*tau2 + 
        a*eps^3*tau1*tau2 - tau1*zbc + a*eps*tau1*zbc + eps^2*tau1*zbc - 
        a*eps^3*tau1*zbc - eps*tau1*tau2*zbc + a*eps*tau1*tau2*zbc + 
        eps^3*tau1*tau2*zbc - a*eps^3*tau1*tau2*zbc + a*eps*tau1*zc + 
        eps^2*tau1*zc - a*eps^3*tau1*zc - eps^2*tau1*zbc*zc + 
        a*eps^3*tau1*zbc*zc - a*tau2*zbc*zc + a*eps^2*tau2*zbc*zc - 
        eps*tau1*tau2*zbc*zc + a*eps*tau1*tau2*zbc*zc + 
        eps^3*tau1*tau2*zc^2 - a*eps^3*tau1*tau2*zc^2 - 
        a*eps^2*tau2*zbc*zc^2 - eps^3*tau1*tau2*zbc*zc^2 + 
        a*eps^3*tau1*tau2*zbc*zc^2))/((-1 + a*eps - eps*tau2 + a*eps*tau2)*
       (a*eps*tau1 - eps^3*tau1*tau2 + a*eps^3*tau1*tau2 - a*tau2*zbc + 
        a*eps^2*tau2*zbc - eps*tau1*tau2*zbc + a*eps*tau1*tau2*zbc + 
        eps^3*tau1*tau2*zbc - a*eps^3*tau1*tau2*zbc + eps^3*tau1*tau2*zc - 
        a*eps^3*tau1*tau2*zc - a*eps^2*tau2*zbc*zc - eps^3*tau1*tau2*zbc*zc + 
        a*eps^3*tau1*tau2*zbc*zc)))|>, 
 "MREVInvariantCoordinateLeadingData" -> 
  <|"X34" -> <|"Power" -> 0, "LeadingCoefficient" -> (-1 + a)/(1 + tau2)|>, 
   "X45" -> <|"Power" -> 0, "LeadingCoefficient" -> -a^(-1)|>, 
   "X56" -> <|"Power" -> -2, "LeadingCoefficient" -> 
      a/((-1 + a)*(1 + tau1)*tau2*zc)|>, 
   "Q" -> <|"Power" -> 2, "LeadingCoefficient" -> -(tau1/(a*tau2*zbc))|>, 
   "L" -> <|"Power" -> -2, "LeadingCoefficient" -> 
      1/((1 + tau1)*(1 + tau2)*zc)|>, "zShiftProduct" -> 
    <|"Power" -> 2, "LeadingCoefficient" -> ((-1 + a)^2*tau1)/(a*tau2*zbc)|>, 
   "zShiftSum" -> <|"Power" -> 1, "LeadingCoefficient" -> 
      -(((-1 + a)*(tau1 + a*tau2*zbc))/(a*tau2*zbc))|>, 
   "zProduct" -> <|"Power" -> 0, "LeadingCoefficient" -> 1|>, 
   "wProduct" -> <|"Power" -> 0, "LeadingCoefficient" -> 1|>, 
   "wShiftProduct" -> <|"Power" -> 2, "LeadingCoefficient" -> 
      ((-1 + a)^2*tau1*tau2*zc)/a|>, "wShiftSum" -> 
    <|"Power" -> 1, "LeadingCoefficient" -> ((-1 + a)*(tau1 + a*tau2*zc))/
       a|>|>, "Definitions" -> <|"X34" -> "s13/s14", "X45" -> "s14/s15", 
   "X56" -> "s15/s16", "Q" -> "-s23 X34 X45 X56/(1+X56+X45 X56+X34 X45 X56)", 
   "zShiftProduct" -> "(z-1)(zb-1)", "zShiftSum" -> "(z-1)+(zb-1)", 
   "wProduct" -> "w wb", "wShiftProduct" -> "(w-1)(wb-1)", 
   "wShiftSum" -> "(w-1)+(wb-1)"|>|>
