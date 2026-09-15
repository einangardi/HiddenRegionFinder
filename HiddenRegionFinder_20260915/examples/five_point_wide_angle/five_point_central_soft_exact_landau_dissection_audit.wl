(* Created with the Wolfram Language : www.wolfram.com *)
<|"KinematicPath" -> <|"a" -> 1, "b" -> 2, "sigma" -> 1|>, 
 "PhysicalAssumptions" -> P > 0 && M > 0 && K > 0 && R > 0 && T > 0 && 
   C > 0 && C^2 < 4*R*T, "MovingStationaryRatios" -> 
  {(delta*P*(C*K*M^2*P + C*delta^3*M*P*R + C*delta^4*K*M*T + 
      2*C*delta^7*R*T + 2*delta^5*K*M*R*T + 2*delta^2*M*P*R*T + 
      2*delta^8*R^2*T + 2*delta^6*R*T^2))/
    (2*K*T*(C*delta^5*M*P + M^2*P^2 + C*delta^9*T + 2*delta^4*M*P*T + 
      delta^10*R*T + delta^8*T^2)), 
   (delta^3*(C^2*delta^7 + C*delta^5*K*M + C*delta^2*M*P + 2*K*M^2*P + 
      C*delta^8*R + 2*delta^3*M*P*R + C*delta^6*T + 2*delta^4*K*M*T))/
    (2*(C*delta^5*M*P + M^2*P^2 + C*delta^9*T + 2*delta^4*M*P*T + 
      delta^10*R*T + delta^8*T^2)), (C*delta)/(2*T)}, 
 "MovingStationaryRatioLeadingOrders" -> {1, 3, 1}, 
 "LocalVariables" -> {x1, x3, x5, yA, yB, yC}, 
 "LocalRules" -> 
  {x0 -> (delta*P*(C*K*M^2*P + C*delta^3*M*P*R + C*delta^4*K*M*T + 
        2*C*delta^7*R*T + 2*delta^5*K*M*R*T + 2*delta^2*M*P*R*T + 
        2*delta^8*R^2*T + 2*delta^6*R*T^2)*x1)/
      (2*K*T*(C*delta^5*M*P + M^2*P^2 + C*delta^9*T + 2*delta^4*M*P*T + 
        delta^10*R*T + delta^8*T^2)) + yA, 
   x2 -> (delta^3*(C^2*delta^7 + C*delta^5*K*M + C*delta^2*M*P + 2*K*M^2*P + 
        C*delta^8*R + 2*delta^3*M*P*R + C*delta^6*T + 2*delta^4*K*M*T)*x3)/
      (2*(C*delta^5*M*P + M^2*P^2 + C*delta^9*T + 2*delta^4*M*P*T + 
        delta^10*R*T + delta^8*T^2)) + yB, x4 -> (C*delta*x5)/(2*T) + yC}, 
 "LocalF" -> (C^3*delta^11*K*M^2*P^2*x1*x3*x5 + C^2*delta^9*K^2*M^3*P^2*x1*x3*
     x5 + C^2*delta^6*K*M^3*P^3*x1*x3*x5 + C^3*delta^14*M*P^2*R*x1*x3*x5 + 
    2*C^2*delta^12*K*M^2*P^2*R*x1*x3*x5 + C^2*delta^9*M^2*P^3*R*x1*x3*x5 + 
    C^2*delta^15*M*P^2*R^2*x1*x3*x5 + C^3*delta^15*K*M*P*T*x1*x3*x5 + 
    C^2*delta^13*K^2*M^2*P*T*x1*x3*x5 + 2*C^2*delta^10*K*M^2*P^2*T*x1*x3*x5 + 
    C^2*delta^16*K*M*P*R*T*x1*x3*x5 + C^2*delta^13*M*P^2*R*T*x1*x3*x5 - 
    4*C*delta^11*K*M^2*P^2*R*T*x1*x3*x5 - 4*delta^9*K^2*M^3*P^2*R*T*x1*x3*
     x5 - 4*delta^6*K*M^3*P^3*R*T*x1*x3*x5 - 4*C*delta^14*M*P^2*R^2*T*x1*x3*
     x5 - 8*delta^12*K*M^2*P^2*R^2*T*x1*x3*x5 - 4*delta^9*M^2*P^3*R^2*T*x1*x3*
     x5 - 4*delta^15*M*P^2*R^3*T*x1*x3*x5 + C^2*delta^14*K*M*P*T^2*x1*x3*x5 - 
    4*C*delta^15*K*M*P*R*T^2*x1*x3*x5 - 4*delta^13*K^2*M^2*P*R*T^2*x1*x3*x5 - 
    8*delta^10*K*M^2*P^2*R*T^2*x1*x3*x5 - 4*delta^16*K*M*P*R^2*T^2*x1*x3*x5 - 
    4*delta^13*M*P^2*R^2*T^2*x1*x3*x5 - 4*delta^14*K*M*P*R*T^3*x1*x3*x5 + 
    4*C^2*delta^10*K*M^2*P^2*T*x5*yA*yB + 8*C*delta^5*K*M^3*P^3*T*x5*yA*yB + 
    4*K*M^4*P^4*T*x5*yA*yB + 8*C^2*delta^14*K*M*P*T^2*x5*yA*yB + 
    24*C*delta^9*K*M^2*P^2*T^2*x5*yA*yB + 16*delta^4*K*M^3*P^3*T^2*x5*yA*yB + 
    8*C*delta^15*K*M*P*R*T^2*x5*yA*yB + 8*delta^10*K*M^2*P^2*R*T^2*x5*yA*yB + 
    4*C^2*delta^18*K*T^3*x5*yA*yB + 24*C*delta^13*K*M*P*T^3*x5*yA*yB + 
    24*delta^8*K*M^2*P^2*T^3*x5*yA*yB + 8*C*delta^19*K*R*T^3*x5*yA*yB + 
    16*delta^14*K*M*P*R*T^3*x5*yA*yB + 4*delta^20*K*R^2*T^3*x5*yA*yB + 
    8*C*delta^17*K*T^4*x5*yA*yB + 16*delta^12*K*M*P*T^4*x5*yA*yB + 
    8*delta^18*K*R*T^4*x5*yA*yB + 4*delta^16*K*T^5*x5*yA*yB - 
    4*C^2*delta^14*K*M*P*T^2*x3*yA*yC - 4*C*delta^12*K^2*M^2*P*T^2*x3*yA*yC - 
    8*C*delta^9*K*M^2*P^2*T^2*x3*yA*yC - 4*delta^7*K^2*M^3*P^2*T^2*x3*yA*yC - 
    4*delta^4*K*M^3*P^3*T^2*x3*yA*yC - 4*C*delta^15*K*M*P*R*T^2*x3*yA*yC - 
    4*delta^10*K*M^2*P^2*R*T^2*x3*yA*yC - 4*C^2*delta^18*K*T^3*x3*yA*yC - 
    4*C*delta^16*K^2*M*T^3*x3*yA*yC - 16*C*delta^13*K*M*P*T^3*x3*yA*yC - 
    8*delta^11*K^2*M^2*P*T^3*x3*yA*yC - 12*delta^8*K*M^2*P^2*T^3*x3*yA*yC - 
    8*C*delta^19*K*R*T^3*x3*yA*yC - 4*delta^17*K^2*M*R*T^3*x3*yA*yC - 
    12*delta^14*K*M*P*R*T^3*x3*yA*yC - 4*delta^20*K*R^2*T^3*x3*yA*yC - 
    8*C*delta^17*K*T^4*x3*yA*yC - 4*delta^15*K^2*M*T^4*x3*yA*yC - 
    12*delta^12*K*M*P*T^4*x3*yA*yC - 8*delta^18*K*R*T^4*x3*yA*yC - 
    4*delta^16*K*T^5*x3*yA*yC - 4*C*delta^5*K*M^3*P^3*T*x1*yB*yC - 
    4*K*M^4*P^4*T*x1*yB*yC - 4*C*delta^8*M^2*P^3*R*T*x1*yB*yC - 
    4*delta^3*M^3*P^4*R*T*x1*yB*yC - 8*C*delta^9*K*M^2*P^2*T^2*x1*yB*yC - 
    12*delta^4*K*M^3*P^3*T^2*x1*yB*yC - 4*C*delta^12*M*P^2*R*T^2*x1*yB*yC - 
    4*delta^10*K*M^2*P^2*R*T^2*x1*yB*yC - 8*delta^7*M^2*P^3*R*T^2*x1*yB*yC - 
    4*delta^13*M*P^2*R^2*T^2*x1*yB*yC - 4*C*delta^13*K*M*P*T^3*x1*yB*yC - 
    12*delta^8*K*M^2*P^2*T^3*x1*yB*yC - 4*delta^14*K*M*P*R*T^3*x1*yB*yC - 
    4*delta^11*M*P^2*R*T^3*x1*yB*yC - 4*delta^12*K*M*P*T^4*x1*yB*yC)/
   (4*delta^4*K*M*P*T*(C*delta^5*M*P + M^2*P^2 + C*delta^9*T + 
     2*delta^4*M*P*T + delta^10*R*T + delta^8*T^2)), 
 "LocalU" -> (C^3*delta^11*K*M^2*P^2*T*x1*x3 + C^2*delta^9*K^2*M^3*P^2*T*x1*
     x3 + 3*C^2*delta^6*K*M^3*P^3*T*x1*x3 + 2*C*delta^4*K^2*M^4*P^3*T*x1*x3 + 
    2*C*delta*K*M^4*P^4*T*x1*x3 + C^3*delta^14*M*P^2*R*T*x1*x3 + 
    2*C^2*delta^12*K*M^2*P^2*R*T*x1*x3 + 3*C^2*delta^9*M^2*P^3*R*T*x1*x3 + 
    4*C*delta^7*K*M^3*P^3*R*T*x1*x3 + 2*C*delta^4*M^3*P^4*R*T*x1*x3 + 
    C^2*delta^15*M*P^2*R^2*T*x1*x3 + 2*C*delta^10*M^2*P^3*R^2*T*x1*x3 + 
    3*C^3*delta^15*K*M*P*T^2*x1*x3 + 3*C^2*delta^13*K^2*M^2*P*T^2*x1*x3 + 
    14*C^2*delta^10*K*M^2*P^2*T^2*x1*x3 + 10*C*delta^8*K^2*M^3*P^2*T^2*x1*
     x3 + 16*C*delta^5*K*M^3*P^3*T^2*x1*x3 + 4*delta^3*K^2*M^4*P^3*T^2*x1*
     x3 + 4*K*M^4*P^4*T^2*x1*x3 + 2*C^3*delta^18*P*R*T^2*x1*x3 + 
    7*C^2*delta^16*K*M*P*R*T^2*x1*x3 + 2*C*delta^14*K^2*M^2*P*R*T^2*x1*x3 + 
    11*C^2*delta^13*M*P^2*R*T^2*x1*x3 + 24*C*delta^11*K*M^2*P^2*R*T^2*x1*x3 + 
    4*delta^9*K^2*M^3*P^2*R*T^2*x1*x3 + 14*C*delta^8*M^2*P^3*R*T^2*x1*x3 + 
    12*delta^6*K*M^3*P^3*R*T^2*x1*x3 + 4*delta^3*M^3*P^4*R*T^2*x1*x3 + 
    4*C^2*delta^19*P*R^2*T^2*x1*x3 + 4*C*delta^17*K*M*P*R^2*T^2*x1*x3 + 
    14*C*delta^14*M*P^2*R^2*T^2*x1*x3 + 8*delta^12*K*M^2*P^2*R^2*T^2*x1*x3 + 
    8*delta^9*M^2*P^3*R^2*T^2*x1*x3 + 2*C*delta^20*P*R^3*T^2*x1*x3 + 
    4*delta^15*M*P^2*R^3*T^2*x1*x3 + 2*C^3*delta^19*K*T^3*x1*x3 + 
    2*C^2*delta^17*K^2*M*T^3*x1*x3 + 19*C^2*delta^14*K*M*P*T^3*x1*x3 + 
    14*C*delta^12*K^2*M^2*P*T^3*x1*x3 + 36*C*delta^9*K*M^2*P^2*T^3*x1*x3 + 
    12*delta^7*K^2*M^3*P^2*T^3*x1*x3 + 16*delta^4*K*M^3*P^3*T^3*x1*x3 + 
    4*C^2*delta^20*K*R*T^3*x1*x3 + 2*C*delta^18*K^2*M*R*T^3*x1*x3 + 
    8*C^2*delta^17*P*R*T^3*x1*x3 + 32*C*delta^15*K*M*P*R*T^3*x1*x3 + 
    8*delta^13*K^2*M^2*P*R*T^3*x1*x3 + 22*C*delta^12*M*P^2*R*T^3*x1*x3 + 
    32*delta^10*K*M^2*P^2*R*T^3*x1*x3 + 12*delta^7*M^2*P^3*R*T^3*x1*x3 + 
    2*C*delta^21*K*R^2*T^3*x1*x3 + 12*C*delta^18*P*R^2*T^3*x1*x3 + 
    12*delta^16*K*M*P*R^2*T^3*x1*x3 + 16*delta^13*M*P^2*R^2*T^3*x1*x3 + 
    4*delta^19*P*R^3*T^3*x1*x3 + 8*C^2*delta^18*K*T^4*x1*x3 + 
    6*C*delta^16*K^2*M*T^4*x1*x3 + 32*C*delta^13*K*M*P*T^4*x1*x3 + 
    12*delta^11*K^2*M^2*P*T^4*x1*x3 + 24*delta^8*K*M^2*P^2*T^4*x1*x3 + 
    12*C*delta^19*K*R*T^4*x1*x3 + 4*delta^17*K^2*M*R*T^4*x1*x3 + 
    10*C*delta^16*P*R*T^4*x1*x3 + 28*delta^14*K*M*P*R*T^4*x1*x3 + 
    12*delta^11*M*P^2*R*T^4*x1*x3 + 4*delta^20*K*R^2*T^4*x1*x3 + 
    8*delta^17*P*R^2*T^4*x1*x3 + 10*C*delta^17*K*T^5*x1*x3 + 
    4*delta^15*K^2*M*T^5*x1*x3 + 16*delta^12*K*M*P*T^5*x1*x3 + 
    8*delta^18*K*R*T^5*x1*x3 + 4*delta^15*P*R*T^5*x1*x3 + 
    4*delta^16*K*T^6*x1*x3 + C^3*delta^7*K*M^3*P^3*x1*x5 + 
    C^2*delta^2*K*M^4*P^4*x1*x5 + C^3*delta^10*M^2*P^3*R*x1*x5 + 
    C^2*delta^5*M^3*P^4*R*x1*x5 + 4*C^3*delta^11*K*M^2*P^2*T*x1*x5 + 
    9*C^2*delta^6*K*M^3*P^3*T*x1*x5 + 4*C*delta*K*M^4*P^4*T*x1*x5 + 
    3*C^3*delta^14*M*P^2*R*T*x1*x5 + 3*C^2*delta^12*K*M^2*P^2*R*T*x1*x5 + 
    8*C^2*delta^9*M^2*P^3*R*T*x1*x5 + 2*C*delta^7*K*M^3*P^3*R*T*x1*x5 + 
    4*C*delta^4*M^3*P^4*R*T*x1*x5 + 3*C^2*delta^15*M*P^2*R^2*T*x1*x5 + 
    2*C*delta^10*M^2*P^3*R^2*T*x1*x5 + 5*C^3*delta^15*K*M*P*T^2*x1*x5 + 
    23*C^2*delta^10*K*M^2*P^2*T^2*x1*x5 + 22*C*delta^5*K*M^3*P^3*T^2*x1*x5 + 
    4*K*M^4*P^4*T^2*x1*x5 + 2*C^3*delta^18*P*R*T^2*x1*x5 + 
    7*C^2*delta^16*K*M*P*R*T^2*x1*x5 + 15*C^2*delta^13*M*P^2*R*T^2*x1*x5 + 
    14*C*delta^11*K*M^2*P^2*R*T^2*x1*x5 + 18*C*delta^8*M^2*P^3*R*T^2*x1*x5 + 
    4*delta^6*K*M^3*P^3*R*T^2*x1*x5 + 4*delta^3*M^3*P^4*R*T^2*x1*x5 + 
    4*C^2*delta^19*P*R^2*T^2*x1*x5 + 2*C*delta^17*K*M*P*R^2*T^2*x1*x5 + 
    12*C*delta^14*M*P^2*R^2*T^2*x1*x5 + 4*delta^9*M^2*P^3*R^2*T^2*x1*x5 + 
    2*C*delta^20*P*R^3*T^2*x1*x5 + 2*C^3*delta^19*K*T^3*x1*x5 + 
    23*C^2*delta^14*K*M*P*T^3*x1*x5 + 42*C*delta^9*K*M^2*P^2*T^3*x1*x5 + 
    16*delta^4*K*M^3*P^3*T^3*x1*x5 + 4*C^2*delta^20*K*R*T^3*x1*x5 + 
    8*C^2*delta^17*P*R*T^3*x1*x5 + 24*C*delta^15*K*M*P*R*T^3*x1*x5 + 
    24*C*delta^12*M*P^2*R*T^3*x1*x5 + 16*delta^10*K*M^2*P^2*R*T^3*x1*x5 + 
    12*delta^7*M^2*P^3*R*T^3*x1*x5 + 2*C*delta^21*K*R^2*T^3*x1*x5 + 
    12*C*delta^18*P*R^2*T^3*x1*x5 + 4*delta^16*K*M*P*R^2*T^3*x1*x5 + 
    12*delta^13*M*P^2*R^2*T^3*x1*x5 + 4*delta^19*P*R^3*T^3*x1*x5 + 
    8*C^2*delta^18*K*T^4*x1*x5 + 34*C*delta^13*K*M*P*T^4*x1*x5 + 
    24*delta^8*K*M^2*P^2*T^4*x1*x5 + 12*C*delta^19*K*R*T^4*x1*x5 + 
    10*C*delta^16*P*R*T^4*x1*x5 + 20*delta^14*K*M*P*R*T^4*x1*x5 + 
    12*delta^11*M*P^2*R*T^4*x1*x5 + 4*delta^20*K*R^2*T^4*x1*x5 + 
    8*delta^17*P*R^2*T^4*x1*x5 + 10*C*delta^17*K*T^5*x1*x5 + 
    16*delta^12*K*M*P*T^5*x1*x5 + 8*delta^18*K*R*T^5*x1*x5 + 
    4*delta^15*P*R*T^5*x1*x5 + 4*delta^16*K*T^6*x1*x5 + 
    C^4*delta^16*K*M*P*T*x3*x5 + C^3*delta^14*K^2*M^2*P*T*x3*x5 + 
    4*C^3*delta^11*K*M^2*P^2*T*x3*x5 + 3*C^2*delta^9*K^2*M^3*P^2*T*x3*x5 + 
    5*C^2*delta^6*K*M^3*P^3*T*x3*x5 + 2*C*delta^4*K^2*M^4*P^3*T*x3*x5 + 
    2*C*delta*K*M^4*P^4*T*x3*x5 + C^3*delta^17*K*M*P*R*T*x3*x5 + 
    3*C^2*delta^12*K*M^2*P^2*R*T*x3*x5 + 2*C*delta^7*K*M^3*P^3*R*T*x3*x5 + 
    C^4*delta^20*K*T^2*x3*x5 + C^3*delta^18*K^2*M*T^2*x3*x5 + 
    10*C^3*delta^15*K*M*P*T^2*x3*x5 + 8*C^2*delta^13*K^2*M^2*P*T^2*x3*x5 + 
    23*C^2*delta^10*K*M^2*P^2*T^2*x3*x5 + 12*C*delta^8*K^2*M^3*P^2*T^2*x3*
     x5 + 18*C*delta^5*K*M^3*P^3*T^2*x3*x5 + 4*delta^3*K^2*M^4*P^3*T^2*x3*
     x5 + 4*K*M^4*P^4*T^2*x3*x5 + 2*C^3*delta^21*K*R*T^2*x3*x5 + 
    C^2*delta^19*K^2*M*R*T^2*x3*x5 + 11*C^2*delta^16*K*M*P*R*T^2*x3*x5 + 
    2*C*delta^14*K^2*M^2*P*R*T^2*x3*x5 + 14*C*delta^11*K*M^2*P^2*R*T^2*x3*
     x5 + 4*delta^6*K*M^3*P^3*R*T^2*x3*x5 + C^2*delta^22*K*R^2*T^2*x3*x5 + 
    2*C*delta^17*K*M*P*R^2*T^2*x3*x5 + 6*C^3*delta^19*K*T^3*x3*x5 + 
    5*C^2*delta^17*K^2*M*T^3*x3*x5 + 31*C^2*delta^14*K*M*P*T^3*x3*x5 + 
    18*C*delta^12*K^2*M^2*P*T^3*x3*x5 + 42*C*delta^9*K*M^2*P^2*T^3*x3*x5 + 
    12*delta^7*K^2*M^3*P^2*T^3*x3*x5 + 16*delta^4*K*M^3*P^3*T^3*x3*x5 + 
    10*C^2*delta^20*K*R*T^3*x3*x5 + 4*C*delta^18*K^2*M*R*T^3*x3*x5 + 
    28*C*delta^15*K*M*P*R*T^3*x3*x5 + 4*delta^13*K^2*M^2*P*R*T^3*x3*x5 + 
    16*delta^10*K*M^2*P^2*R*T^3*x3*x5 + 4*C*delta^21*K*R^2*T^3*x3*x5 + 
    4*delta^16*K*M*P*R^2*T^3*x3*x5 + 13*C^2*delta^18*K*T^4*x3*x5 + 
    8*C*delta^16*K^2*M*T^4*x3*x5 + 38*C*delta^13*K*M*P*T^4*x3*x5 + 
    12*delta^11*K^2*M^2*P*T^4*x3*x5 + 24*delta^8*K*M^2*P^2*T^4*x3*x5 + 
    16*C*delta^19*K*R*T^4*x3*x5 + 4*delta^17*K^2*M*R*T^4*x3*x5 + 
    20*delta^14*K*M*P*R*T^4*x3*x5 + 4*delta^20*K*R^2*T^4*x3*x5 + 
    12*C*delta^17*K*T^5*x3*x5 + 4*delta^15*K^2*M*T^5*x3*x5 + 
    16*delta^12*K*M*P*T^5*x3*x5 + 8*delta^18*K*R*T^5*x3*x5 + 
    4*delta^16*K*T^6*x3*x5 + 2*C^3*delta^15*K*M*P*T^2*x3*yA + 
    2*C^2*delta^13*K^2*M^2*P*T^2*x3*yA + 8*C^2*delta^10*K*M^2*P^2*T^2*x3*yA + 
    6*C*delta^8*K^2*M^3*P^2*T^2*x3*yA + 10*C*delta^5*K*M^3*P^3*T^2*x3*yA + 
    4*delta^3*K^2*M^4*P^3*T^2*x3*yA + 4*K*M^4*P^4*T^2*x3*yA + 
    2*C^2*delta^16*K*M*P*R*T^2*x3*yA + 6*C*delta^11*K*M^2*P^2*R*T^2*x3*yA + 
    4*delta^6*K*M^3*P^3*R*T^2*x3*yA + 2*C^3*delta^19*K*T^3*x3*yA + 
    2*C^2*delta^17*K^2*M*T^3*x3*yA + 16*C^2*delta^14*K*M*P*T^3*x3*yA + 
    12*C*delta^12*K^2*M^2*P*T^3*x3*yA + 30*C*delta^9*K*M^2*P^2*T^3*x3*yA + 
    12*delta^7*K^2*M^3*P^2*T^3*x3*yA + 16*delta^4*K*M^3*P^3*T^3*x3*yA + 
    4*C^2*delta^20*K*R*T^3*x3*yA + 2*C*delta^18*K^2*M*R*T^3*x3*yA + 
    18*C*delta^15*K*M*P*R*T^3*x3*yA + 4*delta^13*K^2*M^2*P*R*T^3*x3*yA + 
    16*delta^10*K*M^2*P^2*R*T^3*x3*yA + 2*C*delta^21*K*R^2*T^3*x3*yA + 
    4*delta^16*K*M*P*R^2*T^3*x3*yA + 8*C^2*delta^18*K*T^4*x3*yA + 
    6*C*delta^16*K^2*M*T^4*x3*yA + 30*C*delta^13*K*M*P*T^4*x3*yA + 
    12*delta^11*K^2*M^2*P*T^4*x3*yA + 24*delta^8*K*M^2*P^2*T^4*x3*yA + 
    12*C*delta^19*K*R*T^4*x3*yA + 4*delta^17*K^2*M*R*T^4*x3*yA + 
    20*delta^14*K*M*P*R*T^4*x3*yA + 4*delta^20*K*R^2*T^4*x3*yA + 
    10*C*delta^17*K*T^5*x3*yA + 4*delta^15*K^2*M*T^5*x3*yA + 
    16*delta^12*K*M*P*T^5*x3*yA + 8*delta^18*K*R*T^5*x3*yA + 
    4*delta^16*K*T^6*x3*yA + 2*C^3*delta^11*K*M^2*P^2*T*x5*yA + 
    4*C^2*delta^6*K*M^3*P^3*T*x5*yA + 2*C*delta*K*M^4*P^4*T*x5*yA + 
    4*C^3*delta^15*K*M*P*T^2*x5*yA + 16*C^2*delta^10*K*M^2*P^2*T^2*x5*yA + 
    16*C*delta^5*K*M^3*P^3*T^2*x5*yA + 4*K*M^4*P^4*T^2*x5*yA + 
    4*C^2*delta^16*K*M*P*R*T^2*x5*yA + 4*C*delta^11*K*M^2*P^2*R*T^2*x5*yA + 
    2*C^3*delta^19*K*T^3*x5*yA + 20*C^2*delta^14*K*M*P*T^3*x5*yA + 
    36*C*delta^9*K*M^2*P^2*T^3*x5*yA + 16*delta^4*K*M^3*P^3*T^3*x5*yA + 
    4*C^2*delta^20*K*R*T^3*x5*yA + 16*C*delta^15*K*M*P*R*T^3*x5*yA + 
    8*delta^10*K*M^2*P^2*R*T^3*x5*yA + 2*C*delta^21*K*R^2*T^3*x5*yA + 
    8*C^2*delta^18*K*T^4*x5*yA + 32*C*delta^13*K*M*P*T^4*x5*yA + 
    24*delta^8*K*M^2*P^2*T^4*x5*yA + 12*C*delta^19*K*R*T^4*x5*yA + 
    16*delta^14*K*M*P*R*T^4*x5*yA + 4*delta^20*K*R^2*T^4*x5*yA + 
    10*C*delta^17*K*T^5*x5*yA + 16*delta^12*K*M*P*T^5*x5*yA + 
    8*delta^18*K*R*T^5*x5*yA + 4*delta^16*K*T^6*x5*yA + 
    2*C^2*delta^6*K*M^3*P^3*T*x1*yB + 2*C*delta*K*M^4*P^4*T*x1*yB + 
    2*C^2*delta^9*M^2*P^3*R*T*x1*yB + 2*C*delta^4*M^3*P^4*R*T*x1*yB + 
    8*C^2*delta^10*K*M^2*P^2*T^2*x1*yB + 14*C*delta^5*K*M^3*P^3*T^2*x1*yB + 
    4*K*M^4*P^4*T^2*x1*yB + 6*C^2*delta^13*M*P^2*R*T^2*x1*yB + 
    6*C*delta^11*K*M^2*P^2*R*T^2*x1*yB + 12*C*delta^8*M^2*P^3*R*T^2*x1*yB + 
    4*delta^6*K*M^3*P^3*R*T^2*x1*yB + 4*delta^3*M^3*P^4*R*T^2*x1*yB + 
    6*C*delta^14*M*P^2*R^2*T^2*x1*yB + 4*delta^9*M^2*P^3*R^2*T^2*x1*yB + 
    10*C^2*delta^14*K*M*P*T^3*x1*yB + 30*C*delta^9*K*M^2*P^2*T^3*x1*yB + 
    16*delta^4*K*M^3*P^3*T^3*x1*yB + 4*C^2*delta^17*P*R*T^3*x1*yB + 
    14*C*delta^15*K*M*P*R*T^3*x1*yB + 18*C*delta^12*M*P^2*R*T^3*x1*yB + 
    16*delta^10*K*M^2*P^2*R*T^3*x1*yB + 12*delta^7*M^2*P^3*R*T^3*x1*yB + 
    8*C*delta^18*P*R^2*T^3*x1*yB + 4*delta^16*K*M*P*R^2*T^3*x1*yB + 
    12*delta^13*M*P^2*R^2*T^3*x1*yB + 4*delta^19*P*R^3*T^3*x1*yB + 
    4*C^2*delta^18*K*T^4*x1*yB + 26*C*delta^13*K*M*P*T^4*x1*yB + 
    24*delta^8*K*M^2*P^2*T^4*x1*yB + 8*C*delta^19*K*R*T^4*x1*yB + 
    8*C*delta^16*P*R*T^4*x1*yB + 20*delta^14*K*M*P*R*T^4*x1*yB + 
    12*delta^11*M*P^2*R*T^4*x1*yB + 4*delta^20*K*R^2*T^4*x1*yB + 
    8*delta^17*P*R^2*T^4*x1*yB + 8*C*delta^17*K*T^5*x1*yB + 
    16*delta^12*K*M*P*T^5*x1*yB + 8*delta^18*K*R*T^5*x1*yB + 
    4*delta^15*P*R*T^5*x1*yB + 4*delta^16*K*T^6*x1*yB + 
    2*C^3*delta^11*K*M^2*P^2*T*x5*yB + 4*C^2*delta^6*K*M^3*P^3*T*x5*yB + 
    2*C*delta*K*M^4*P^4*T*x5*yB + 4*C^3*delta^15*K*M*P*T^2*x5*yB + 
    16*C^2*delta^10*K*M^2*P^2*T^2*x5*yB + 16*C*delta^5*K*M^3*P^3*T^2*x5*yB + 
    4*K*M^4*P^4*T^2*x5*yB + 4*C^2*delta^16*K*M*P*R*T^2*x5*yB + 
    4*C*delta^11*K*M^2*P^2*R*T^2*x5*yB + 2*C^3*delta^19*K*T^3*x5*yB + 
    20*C^2*delta^14*K*M*P*T^3*x5*yB + 36*C*delta^9*K*M^2*P^2*T^3*x5*yB + 
    16*delta^4*K*M^3*P^3*T^3*x5*yB + 4*C^2*delta^20*K*R*T^3*x5*yB + 
    16*C*delta^15*K*M*P*R*T^3*x5*yB + 8*delta^10*K*M^2*P^2*R*T^3*x5*yB + 
    2*C*delta^21*K*R^2*T^3*x5*yB + 8*C^2*delta^18*K*T^4*x5*yB + 
    32*C*delta^13*K*M*P*T^4*x5*yB + 24*delta^8*K*M^2*P^2*T^4*x5*yB + 
    12*C*delta^19*K*R*T^4*x5*yB + 16*delta^14*K*M*P*R*T^4*x5*yB + 
    4*delta^20*K*R^2*T^4*x5*yB + 10*C*delta^17*K*T^5*x5*yB + 
    16*delta^12*K*M*P*T^5*x5*yB + 8*delta^18*K*R*T^5*x5*yB + 
    4*delta^16*K*T^6*x5*yB + 4*C^2*delta^10*K*M^2*P^2*T^2*yA*yB + 
    8*C*delta^5*K*M^3*P^3*T^2*yA*yB + 4*K*M^4*P^4*T^2*yA*yB + 
    8*C^2*delta^14*K*M*P*T^3*yA*yB + 24*C*delta^9*K*M^2*P^2*T^3*yA*yB + 
    16*delta^4*K*M^3*P^3*T^3*yA*yB + 8*C*delta^15*K*M*P*R*T^3*yA*yB + 
    8*delta^10*K*M^2*P^2*R*T^3*yA*yB + 4*C^2*delta^18*K*T^4*yA*yB + 
    24*C*delta^13*K*M*P*T^4*yA*yB + 24*delta^8*K*M^2*P^2*T^4*yA*yB + 
    8*C*delta^19*K*R*T^4*yA*yB + 16*delta^14*K*M*P*R*T^4*yA*yB + 
    4*delta^20*K*R^2*T^4*yA*yB + 8*C*delta^17*K*T^5*yA*yB + 
    16*delta^12*K*M*P*T^5*yA*yB + 8*delta^18*K*R*T^5*yA*yB + 
    4*delta^16*K*T^6*yA*yB + 2*C^2*delta^6*K*M^3*P^3*T*x1*yC + 
    2*C*delta*K*M^4*P^4*T*x1*yC + 2*C^2*delta^9*M^2*P^3*R*T*x1*yC + 
    2*C*delta^4*M^3*P^4*R*T*x1*yC + 8*C^2*delta^10*K*M^2*P^2*T^2*x1*yC + 
    14*C*delta^5*K*M^3*P^3*T^2*x1*yC + 4*K*M^4*P^4*T^2*x1*yC + 
    6*C^2*delta^13*M*P^2*R*T^2*x1*yC + 6*C*delta^11*K*M^2*P^2*R*T^2*x1*yC + 
    12*C*delta^8*M^2*P^3*R*T^2*x1*yC + 4*delta^6*K*M^3*P^3*R*T^2*x1*yC + 
    4*delta^3*M^3*P^4*R*T^2*x1*yC + 6*C*delta^14*M*P^2*R^2*T^2*x1*yC + 
    4*delta^9*M^2*P^3*R^2*T^2*x1*yC + 10*C^2*delta^14*K*M*P*T^3*x1*yC + 
    30*C*delta^9*K*M^2*P^2*T^3*x1*yC + 16*delta^4*K*M^3*P^3*T^3*x1*yC + 
    4*C^2*delta^17*P*R*T^3*x1*yC + 14*C*delta^15*K*M*P*R*T^3*x1*yC + 
    18*C*delta^12*M*P^2*R*T^3*x1*yC + 16*delta^10*K*M^2*P^2*R*T^3*x1*yC + 
    12*delta^7*M^2*P^3*R*T^3*x1*yC + 8*C*delta^18*P*R^2*T^3*x1*yC + 
    4*delta^16*K*M*P*R^2*T^3*x1*yC + 12*delta^13*M*P^2*R^2*T^3*x1*yC + 
    4*delta^19*P*R^3*T^3*x1*yC + 4*C^2*delta^18*K*T^4*x1*yC + 
    26*C*delta^13*K*M*P*T^4*x1*yC + 24*delta^8*K*M^2*P^2*T^4*x1*yC + 
    8*C*delta^19*K*R*T^4*x1*yC + 8*C*delta^16*P*R*T^4*x1*yC + 
    20*delta^14*K*M*P*R*T^4*x1*yC + 12*delta^11*M*P^2*R*T^4*x1*yC + 
    4*delta^20*K*R^2*T^4*x1*yC + 8*delta^17*P*R^2*T^4*x1*yC + 
    8*C*delta^17*K*T^5*x1*yC + 16*delta^12*K*M*P*T^5*x1*yC + 
    8*delta^18*K*R*T^5*x1*yC + 4*delta^15*P*R*T^5*x1*yC + 
    4*delta^16*K*T^6*x1*yC + 2*C^3*delta^15*K*M*P*T^2*x3*yC + 
    2*C^2*delta^13*K^2*M^2*P*T^2*x3*yC + 8*C^2*delta^10*K*M^2*P^2*T^2*x3*yC + 
    6*C*delta^8*K^2*M^3*P^2*T^2*x3*yC + 10*C*delta^5*K*M^3*P^3*T^2*x3*yC + 
    4*delta^3*K^2*M^4*P^3*T^2*x3*yC + 4*K*M^4*P^4*T^2*x3*yC + 
    2*C^2*delta^16*K*M*P*R*T^2*x3*yC + 6*C*delta^11*K*M^2*P^2*R*T^2*x3*yC + 
    4*delta^6*K*M^3*P^3*R*T^2*x3*yC + 2*C^3*delta^19*K*T^3*x3*yC + 
    2*C^2*delta^17*K^2*M*T^3*x3*yC + 16*C^2*delta^14*K*M*P*T^3*x3*yC + 
    12*C*delta^12*K^2*M^2*P*T^3*x3*yC + 30*C*delta^9*K*M^2*P^2*T^3*x3*yC + 
    12*delta^7*K^2*M^3*P^2*T^3*x3*yC + 16*delta^4*K*M^3*P^3*T^3*x3*yC + 
    4*C^2*delta^20*K*R*T^3*x3*yC + 2*C*delta^18*K^2*M*R*T^3*x3*yC + 
    18*C*delta^15*K*M*P*R*T^3*x3*yC + 4*delta^13*K^2*M^2*P*R*T^3*x3*yC + 
    16*delta^10*K*M^2*P^2*R*T^3*x3*yC + 2*C*delta^21*K*R^2*T^3*x3*yC + 
    4*delta^16*K*M*P*R^2*T^3*x3*yC + 8*C^2*delta^18*K*T^4*x3*yC + 
    6*C*delta^16*K^2*M*T^4*x3*yC + 30*C*delta^13*K*M*P*T^4*x3*yC + 
    12*delta^11*K^2*M^2*P*T^4*x3*yC + 24*delta^8*K*M^2*P^2*T^4*x3*yC + 
    12*C*delta^19*K*R*T^4*x3*yC + 4*delta^17*K^2*M*R*T^4*x3*yC + 
    20*delta^14*K*M*P*R*T^4*x3*yC + 4*delta^20*K*R^2*T^4*x3*yC + 
    10*C*delta^17*K*T^5*x3*yC + 4*delta^15*K^2*M*T^5*x3*yC + 
    16*delta^12*K*M*P*T^5*x3*yC + 8*delta^18*K*R*T^5*x3*yC + 
    4*delta^16*K*T^6*x3*yC + 4*C^2*delta^10*K*M^2*P^2*T^2*yA*yC + 
    8*C*delta^5*K*M^3*P^3*T^2*yA*yC + 4*K*M^4*P^4*T^2*yA*yC + 
    8*C^2*delta^14*K*M*P*T^3*yA*yC + 24*C*delta^9*K*M^2*P^2*T^3*yA*yC + 
    16*delta^4*K*M^3*P^3*T^3*yA*yC + 8*C*delta^15*K*M*P*R*T^3*yA*yC + 
    8*delta^10*K*M^2*P^2*R*T^3*yA*yC + 4*C^2*delta^18*K*T^4*yA*yC + 
    24*C*delta^13*K*M*P*T^4*yA*yC + 24*delta^8*K*M^2*P^2*T^4*yA*yC + 
    8*C*delta^19*K*R*T^4*yA*yC + 16*delta^14*K*M*P*R*T^4*yA*yC + 
    4*delta^20*K*R^2*T^4*yA*yC + 8*C*delta^17*K*T^5*yA*yC + 
    16*delta^12*K*M*P*T^5*yA*yC + 8*delta^18*K*R*T^5*yA*yC + 
    4*delta^16*K*T^6*yA*yC + 4*C^2*delta^10*K*M^2*P^2*T^2*yB*yC + 
    8*C*delta^5*K*M^3*P^3*T^2*yB*yC + 4*K*M^4*P^4*T^2*yB*yC + 
    8*C^2*delta^14*K*M*P*T^3*yB*yC + 24*C*delta^9*K*M^2*P^2*T^3*yB*yC + 
    16*delta^4*K*M^3*P^3*T^3*yB*yC + 8*C*delta^15*K*M*P*R*T^3*yB*yC + 
    8*delta^10*K*M^2*P^2*R*T^3*yB*yC + 4*C^2*delta^18*K*T^4*yB*yC + 
    24*C*delta^13*K*M*P*T^4*yB*yC + 24*delta^8*K*M^2*P^2*T^4*yB*yC + 
    8*C*delta^19*K*R*T^4*yB*yC + 16*delta^14*K*M*P*R*T^4*yB*yC + 
    4*delta^20*K*R^2*T^4*yB*yC + 8*C*delta^17*K*T^5*yB*yC + 
    16*delta^12*K*M*P*T^5*yB*yC + 8*delta^18*K*R*T^5*yB*yC + 
    4*delta^16*K*T^6*yB*yC)/(4*K*T^2*(C*delta^5*M*P + M^2*P^2 + C*delta^9*T + 
      2*delta^4*M*P*T + delta^10*R*T + delta^8*T^2)^2), 
 "LocalLPDenominator" -> 4*delta^4*K*M*P*T^2*
   (C*delta^5*M*P + M^2*P^2 + C*delta^9*T + 2*delta^4*M*P*T + delta^10*R*T + 
     delta^8*T^2)^2, "LocalLPPolynomial" -> C^3*delta^15*K*M^3*P^3*T*x1*x3 + 
   C^2*delta^13*K^2*M^4*P^3*T*x1*x3 + 3*C^2*delta^10*K*M^4*P^4*T*x1*x3 + 
   2*C*delta^8*K^2*M^5*P^4*T*x1*x3 + 2*C*delta^5*K*M^5*P^5*T*x1*x3 + 
   C^3*delta^18*M^2*P^3*R*T*x1*x3 + 2*C^2*delta^16*K*M^3*P^3*R*T*x1*x3 + 
   3*C^2*delta^13*M^3*P^4*R*T*x1*x3 + 4*C*delta^11*K*M^4*P^4*R*T*x1*x3 + 
   2*C*delta^8*M^4*P^5*R*T*x1*x3 + C^2*delta^19*M^2*P^3*R^2*T*x1*x3 + 
   2*C*delta^14*M^3*P^4*R^2*T*x1*x3 + 3*C^3*delta^19*K*M^2*P^2*T^2*x1*x3 + 
   3*C^2*delta^17*K^2*M^3*P^2*T^2*x1*x3 + 14*C^2*delta^14*K*M^3*P^3*T^2*x1*
    x3 + 10*C*delta^12*K^2*M^4*P^3*T^2*x1*x3 + 16*C*delta^9*K*M^4*P^4*T^2*x1*
    x3 + 4*delta^7*K^2*M^5*P^4*T^2*x1*x3 + 4*delta^4*K*M^5*P^5*T^2*x1*x3 + 
   2*C^3*delta^22*M*P^2*R*T^2*x1*x3 + 7*C^2*delta^20*K*M^2*P^2*R*T^2*x1*x3 + 
   2*C*delta^18*K^2*M^3*P^2*R*T^2*x1*x3 + 11*C^2*delta^17*M^2*P^3*R*T^2*x1*
    x3 + 24*C*delta^15*K*M^3*P^3*R*T^2*x1*x3 + 4*delta^13*K^2*M^4*P^3*R*T^2*
    x1*x3 + 14*C*delta^12*M^3*P^4*R*T^2*x1*x3 + 12*delta^10*K*M^4*P^4*R*T^2*
    x1*x3 + 4*delta^7*M^4*P^5*R*T^2*x1*x3 + 4*C^2*delta^23*M*P^2*R^2*T^2*x1*
    x3 + 4*C*delta^21*K*M^2*P^2*R^2*T^2*x1*x3 + 14*C*delta^18*M^2*P^3*R^2*T^2*
    x1*x3 + 8*delta^16*K*M^3*P^3*R^2*T^2*x1*x3 + 8*delta^13*M^3*P^4*R^2*T^2*
    x1*x3 + 2*C*delta^24*M*P^2*R^3*T^2*x1*x3 + 4*delta^19*M^2*P^3*R^3*T^2*x1*
    x3 + 2*C^3*delta^23*K*M*P*T^3*x1*x3 + 2*C^2*delta^21*K^2*M^2*P*T^3*x1*
    x3 + 19*C^2*delta^18*K*M^2*P^2*T^3*x1*x3 + 14*C*delta^16*K^2*M^3*P^2*T^3*
    x1*x3 + 36*C*delta^13*K*M^3*P^3*T^3*x1*x3 + 12*delta^11*K^2*M^4*P^3*T^3*
    x1*x3 + 16*delta^8*K*M^4*P^4*T^3*x1*x3 + 4*C^2*delta^24*K*M*P*R*T^3*x1*
    x3 + 2*C*delta^22*K^2*M^2*P*R*T^3*x1*x3 + 8*C^2*delta^21*M*P^2*R*T^3*x1*
    x3 + 32*C*delta^19*K*M^2*P^2*R*T^3*x1*x3 + 8*delta^17*K^2*M^3*P^2*R*T^3*
    x1*x3 + 22*C*delta^16*M^2*P^3*R*T^3*x1*x3 + 32*delta^14*K*M^3*P^3*R*T^3*
    x1*x3 + 12*delta^11*M^3*P^4*R*T^3*x1*x3 + 2*C*delta^25*K*M*P*R^2*T^3*x1*
    x3 + 12*C*delta^22*M*P^2*R^2*T^3*x1*x3 + 12*delta^20*K*M^2*P^2*R^2*T^3*x1*
    x3 + 16*delta^17*M^2*P^3*R^2*T^3*x1*x3 + 4*delta^23*M*P^2*R^3*T^3*x1*x3 + 
   8*C^2*delta^22*K*M*P*T^4*x1*x3 + 6*C*delta^20*K^2*M^2*P*T^4*x1*x3 + 
   32*C*delta^17*K*M^2*P^2*T^4*x1*x3 + 12*delta^15*K^2*M^3*P^2*T^4*x1*x3 + 
   24*delta^12*K*M^3*P^3*T^4*x1*x3 + 12*C*delta^23*K*M*P*R*T^4*x1*x3 + 
   4*delta^21*K^2*M^2*P*R*T^4*x1*x3 + 10*C*delta^20*M*P^2*R*T^4*x1*x3 + 
   28*delta^18*K*M^2*P^2*R*T^4*x1*x3 + 12*delta^15*M^2*P^3*R*T^4*x1*x3 + 
   4*delta^24*K*M*P*R^2*T^4*x1*x3 + 8*delta^21*M*P^2*R^2*T^4*x1*x3 + 
   10*C*delta^21*K*M*P*T^5*x1*x3 + 4*delta^19*K^2*M^2*P*T^5*x1*x3 + 
   16*delta^16*K*M^2*P^2*T^5*x1*x3 + 8*delta^22*K*M*P*R*T^5*x1*x3 + 
   4*delta^19*M*P^2*R*T^5*x1*x3 + 4*delta^20*K*M*P*T^6*x1*x3 + 
   C^3*delta^11*K*M^4*P^4*x1*x5 + C^2*delta^6*K*M^5*P^5*x1*x5 + 
   C^3*delta^14*M^3*P^4*R*x1*x5 + C^2*delta^9*M^4*P^5*R*x1*x5 + 
   4*C^3*delta^15*K*M^3*P^3*T*x1*x5 + 9*C^2*delta^10*K*M^4*P^4*T*x1*x5 + 
   4*C*delta^5*K*M^5*P^5*T*x1*x5 + 3*C^3*delta^18*M^2*P^3*R*T*x1*x5 + 
   3*C^2*delta^16*K*M^3*P^3*R*T*x1*x5 + 8*C^2*delta^13*M^3*P^4*R*T*x1*x5 + 
   2*C*delta^11*K*M^4*P^4*R*T*x1*x5 + 4*C*delta^8*M^4*P^5*R*T*x1*x5 + 
   3*C^2*delta^19*M^2*P^3*R^2*T*x1*x5 + 2*C*delta^14*M^3*P^4*R^2*T*x1*x5 + 
   5*C^3*delta^19*K*M^2*P^2*T^2*x1*x5 + 23*C^2*delta^14*K*M^3*P^3*T^2*x1*x5 + 
   22*C*delta^9*K*M^4*P^4*T^2*x1*x5 + 4*delta^4*K*M^5*P^5*T^2*x1*x5 + 
   2*C^3*delta^22*M*P^2*R*T^2*x1*x5 + 7*C^2*delta^20*K*M^2*P^2*R*T^2*x1*x5 + 
   15*C^2*delta^17*M^2*P^3*R*T^2*x1*x5 + 14*C*delta^15*K*M^3*P^3*R*T^2*x1*
    x5 + 18*C*delta^12*M^3*P^4*R*T^2*x1*x5 + 4*delta^10*K*M^4*P^4*R*T^2*x1*
    x5 + 4*delta^7*M^4*P^5*R*T^2*x1*x5 + 4*C^2*delta^23*M*P^2*R^2*T^2*x1*x5 + 
   2*C*delta^21*K*M^2*P^2*R^2*T^2*x1*x5 + 12*C*delta^18*M^2*P^3*R^2*T^2*x1*
    x5 + 4*delta^13*M^3*P^4*R^2*T^2*x1*x5 + 2*C*delta^24*M*P^2*R^3*T^2*x1*
    x5 + 2*C^3*delta^23*K*M*P*T^3*x1*x5 + 23*C^2*delta^18*K*M^2*P^2*T^3*x1*
    x5 + 42*C*delta^13*K*M^3*P^3*T^3*x1*x5 + 16*delta^8*K*M^4*P^4*T^3*x1*x5 + 
   4*C^2*delta^24*K*M*P*R*T^3*x1*x5 + 8*C^2*delta^21*M*P^2*R*T^3*x1*x5 + 
   24*C*delta^19*K*M^2*P^2*R*T^3*x1*x5 + 24*C*delta^16*M^2*P^3*R*T^3*x1*x5 + 
   16*delta^14*K*M^3*P^3*R*T^3*x1*x5 + 12*delta^11*M^3*P^4*R*T^3*x1*x5 + 
   2*C*delta^25*K*M*P*R^2*T^3*x1*x5 + 12*C*delta^22*M*P^2*R^2*T^3*x1*x5 + 
   4*delta^20*K*M^2*P^2*R^2*T^3*x1*x5 + 12*delta^17*M^2*P^3*R^2*T^3*x1*x5 + 
   4*delta^23*M*P^2*R^3*T^3*x1*x5 + 8*C^2*delta^22*K*M*P*T^4*x1*x5 + 
   34*C*delta^17*K*M^2*P^2*T^4*x1*x5 + 24*delta^12*K*M^3*P^3*T^4*x1*x5 + 
   12*C*delta^23*K*M*P*R*T^4*x1*x5 + 10*C*delta^20*M*P^2*R*T^4*x1*x5 + 
   20*delta^18*K*M^2*P^2*R*T^4*x1*x5 + 12*delta^15*M^2*P^3*R*T^4*x1*x5 + 
   4*delta^24*K*M*P*R^2*T^4*x1*x5 + 8*delta^21*M*P^2*R^2*T^4*x1*x5 + 
   10*C*delta^21*K*M*P*T^5*x1*x5 + 16*delta^16*K*M^2*P^2*T^5*x1*x5 + 
   8*delta^22*K*M*P*R*T^5*x1*x5 + 4*delta^19*M*P^2*R*T^5*x1*x5 + 
   4*delta^20*K*M*P*T^6*x1*x5 + C^4*delta^20*K*M^2*P^2*T*x3*x5 + 
   C^3*delta^18*K^2*M^3*P^2*T*x3*x5 + 4*C^3*delta^15*K*M^3*P^3*T*x3*x5 + 
   3*C^2*delta^13*K^2*M^4*P^3*T*x3*x5 + 5*C^2*delta^10*K*M^4*P^4*T*x3*x5 + 
   2*C*delta^8*K^2*M^5*P^4*T*x3*x5 + 2*C*delta^5*K*M^5*P^5*T*x3*x5 + 
   C^3*delta^21*K*M^2*P^2*R*T*x3*x5 + 3*C^2*delta^16*K*M^3*P^3*R*T*x3*x5 + 
   2*C*delta^11*K*M^4*P^4*R*T*x3*x5 + C^4*delta^24*K*M*P*T^2*x3*x5 + 
   C^3*delta^22*K^2*M^2*P*T^2*x3*x5 + 10*C^3*delta^19*K*M^2*P^2*T^2*x3*x5 + 
   8*C^2*delta^17*K^2*M^3*P^2*T^2*x3*x5 + 23*C^2*delta^14*K*M^3*P^3*T^2*x3*
    x5 + 12*C*delta^12*K^2*M^4*P^3*T^2*x3*x5 + 18*C*delta^9*K*M^4*P^4*T^2*x3*
    x5 + 4*delta^7*K^2*M^5*P^4*T^2*x3*x5 + 4*delta^4*K*M^5*P^5*T^2*x3*x5 + 
   2*C^3*delta^25*K*M*P*R*T^2*x3*x5 + C^2*delta^23*K^2*M^2*P*R*T^2*x3*x5 + 
   11*C^2*delta^20*K*M^2*P^2*R*T^2*x3*x5 + 2*C*delta^18*K^2*M^3*P^2*R*T^2*x3*
    x5 + 14*C*delta^15*K*M^3*P^3*R*T^2*x3*x5 + 4*delta^10*K*M^4*P^4*R*T^2*x3*
    x5 + C^2*delta^26*K*M*P*R^2*T^2*x3*x5 + 2*C*delta^21*K*M^2*P^2*R^2*T^2*x3*
    x5 + 6*C^3*delta^23*K*M*P*T^3*x3*x5 + 5*C^2*delta^21*K^2*M^2*P*T^3*x3*
    x5 + 31*C^2*delta^18*K*M^2*P^2*T^3*x3*x5 + 18*C*delta^16*K^2*M^3*P^2*T^3*
    x3*x5 + 42*C*delta^13*K*M^3*P^3*T^3*x3*x5 + 12*delta^11*K^2*M^4*P^3*T^3*
    x3*x5 + 16*delta^8*K*M^4*P^4*T^3*x3*x5 + 10*C^2*delta^24*K*M*P*R*T^3*x3*
    x5 + 4*C*delta^22*K^2*M^2*P*R*T^3*x3*x5 + 28*C*delta^19*K*M^2*P^2*R*T^3*
    x3*x5 + 4*delta^17*K^2*M^3*P^2*R*T^3*x3*x5 + 16*delta^14*K*M^3*P^3*R*T^3*
    x3*x5 + 4*C*delta^25*K*M*P*R^2*T^3*x3*x5 + 4*delta^20*K*M^2*P^2*R^2*T^3*
    x3*x5 + 13*C^2*delta^22*K*M*P*T^4*x3*x5 + 8*C*delta^20*K^2*M^2*P*T^4*x3*
    x5 + 38*C*delta^17*K*M^2*P^2*T^4*x3*x5 + 12*delta^15*K^2*M^3*P^2*T^4*x3*
    x5 + 24*delta^12*K*M^3*P^3*T^4*x3*x5 + 16*C*delta^23*K*M*P*R*T^4*x3*x5 + 
   4*delta^21*K^2*M^2*P*R*T^4*x3*x5 + 20*delta^18*K*M^2*P^2*R*T^4*x3*x5 + 
   4*delta^24*K*M*P*R^2*T^4*x3*x5 + 12*C*delta^21*K*M*P*T^5*x3*x5 + 
   4*delta^19*K^2*M^2*P*T^5*x3*x5 + 16*delta^16*K*M^2*P^2*T^5*x3*x5 + 
   8*delta^22*K*M*P*R*T^5*x3*x5 + 4*delta^20*K*M*P*T^6*x3*x5 + 
   C^4*delta^16*K*M^3*P^3*T*x1*x3*x5 + C^3*delta^14*K^2*M^4*P^3*T*x1*x3*x5 + 
   2*C^3*delta^11*K*M^4*P^4*T*x1*x3*x5 + C^2*delta^9*K^2*M^5*P^4*T*x1*x3*x5 + 
   C^2*delta^6*K*M^5*P^5*T*x1*x3*x5 + C^4*delta^19*M^2*P^3*R*T*x1*x3*x5 + 
   2*C^3*delta^17*K*M^3*P^3*R*T*x1*x3*x5 + 2*C^3*delta^14*M^3*P^4*R*T*x1*x3*
    x5 + 2*C^2*delta^12*K*M^4*P^4*R*T*x1*x3*x5 + C^2*delta^9*M^4*P^5*R*T*x1*
    x3*x5 + C^3*delta^20*M^2*P^3*R^2*T*x1*x3*x5 + 
   C^2*delta^15*M^3*P^4*R^2*T*x1*x3*x5 + 2*C^4*delta^20*K*M^2*P^2*T^2*x1*x3*
    x5 + 2*C^3*delta^18*K^2*M^3*P^2*T^2*x1*x3*x5 + 
   6*C^3*delta^15*K*M^3*P^3*T^2*x1*x3*x5 + 3*C^2*delta^13*K^2*M^4*P^3*T^2*x1*
    x3*x5 + 4*C^2*delta^10*K*M^4*P^4*T^2*x1*x3*x5 + 
   C^4*delta^23*M*P^2*R*T^2*x1*x3*x5 + 4*C^3*delta^21*K*M^2*P^2*R*T^2*x1*x3*
    x5 + C^2*delta^19*K^2*M^3*P^2*R*T^2*x1*x3*x5 + 
   4*C^3*delta^18*M^2*P^3*R*T^2*x1*x3*x5 + 2*C^2*delta^16*K*M^3*P^3*R*T^2*x1*
    x3*x5 - 4*C*delta^14*K^2*M^4*P^3*R*T^2*x1*x3*x5 + 
   3*C^2*delta^13*M^3*P^4*R*T^2*x1*x3*x5 - 8*C*delta^11*K*M^4*P^4*R*T^2*x1*x3*
    x5 - 4*delta^9*K^2*M^5*P^4*R*T^2*x1*x3*x5 - 4*delta^6*K*M^5*P^5*R*T^2*x1*
    x3*x5 + 2*C^3*delta^24*M*P^2*R^2*T^2*x1*x3*x5 + 
   2*C^2*delta^22*K*M^2*P^2*R^2*T^2*x1*x3*x5 - C^2*delta^19*M^2*P^3*R^2*T^2*
    x1*x3*x5 - 8*C*delta^17*K*M^3*P^3*R^2*T^2*x1*x3*x5 - 
   8*C*delta^14*M^3*P^4*R^2*T^2*x1*x3*x5 - 8*delta^12*K*M^4*P^4*R^2*T^2*x1*x3*
    x5 - 4*delta^9*M^4*P^5*R^2*T^2*x1*x3*x5 + C^2*delta^25*M*P^2*R^3*T^2*x1*
    x3*x5 - 4*C*delta^20*M^2*P^3*R^3*T^2*x1*x3*x5 - 
   4*delta^15*M^3*P^4*R^3*T^2*x1*x3*x5 + C^4*delta^24*K*M*P*T^3*x1*x3*x5 + 
   C^3*delta^22*K^2*M^2*P*T^3*x1*x3*x5 + 6*C^3*delta^19*K*M^2*P^2*T^3*x1*x3*
    x5 + 3*C^2*delta^17*K^2*M^3*P^2*T^3*x1*x3*x5 + 
   6*C^2*delta^14*K*M^3*P^3*T^3*x1*x3*x5 + 2*C^3*delta^25*K*M*P*R*T^3*x1*x3*
    x5 + C^2*delta^23*K^2*M^2*P*R*T^3*x1*x3*x5 + 2*C^3*delta^22*M*P^2*R*T^3*
    x1*x3*x5 - 2*C^2*delta^20*K*M^2*P^2*R*T^3*x1*x3*x5 - 
   8*C*delta^18*K^2*M^3*P^2*R*T^3*x1*x3*x5 + 3*C^2*delta^17*M^2*P^3*R*T^3*x1*
    x3*x5 - 24*C*delta^15*K*M^3*P^3*R*T^3*x1*x3*x5 - 
   12*delta^13*K^2*M^4*P^3*R*T^3*x1*x3*x5 - 16*delta^10*K*M^4*P^4*R*T^3*x1*x3*
    x5 + C^2*delta^26*K*M*P*R^2*T^3*x1*x3*x5 - 2*C^2*delta^23*M*P^2*R^2*T^3*
    x1*x3*x5 - 16*C*delta^21*K*M^2*P^2*R^2*T^3*x1*x3*x5 - 
   4*delta^19*K^2*M^3*P^2*R^2*T^3*x1*x3*x5 - 16*C*delta^18*M^2*P^3*R^2*T^3*x1*
    x3*x5 - 24*delta^16*K*M^3*P^3*R^2*T^3*x1*x3*x5 - 
   12*delta^13*M^3*P^4*R^2*T^3*x1*x3*x5 - 8*C*delta^24*M*P^2*R^3*T^3*x1*x3*
    x5 - 8*delta^22*K*M^2*P^2*R^3*T^3*x1*x3*x5 - 12*delta^19*M^2*P^3*R^3*T^3*
    x1*x3*x5 - 4*delta^25*M*P^2*R^4*T^3*x1*x3*x5 + 
   2*C^3*delta^23*K*M*P*T^4*x1*x3*x5 + C^2*delta^21*K^2*M^2*P*T^4*x1*x3*x5 + 
   4*C^2*delta^18*K*M^2*P^2*T^4*x1*x3*x5 - 2*C^2*delta^24*K*M*P*R*T^4*x1*x3*
    x5 - 4*C*delta^22*K^2*M^2*P*R*T^4*x1*x3*x5 + C^2*delta^21*M*P^2*R*T^4*x1*
    x3*x5 - 24*C*delta^19*K*M^2*P^2*R*T^4*x1*x3*x5 - 
   12*delta^17*K^2*M^3*P^2*R*T^4*x1*x3*x5 - 24*delta^14*K*M^3*P^3*R*T^4*x1*x3*
    x5 - 8*C*delta^25*K*M*P*R^2*T^4*x1*x3*x5 - 4*delta^23*K^2*M^2*P*R^2*T^4*
    x1*x3*x5 - 8*C*delta^22*M*P^2*R^2*T^4*x1*x3*x5 - 
   24*delta^20*K*M^2*P^2*R^2*T^4*x1*x3*x5 - 12*delta^17*M^2*P^3*R^2*T^4*x1*x3*
    x5 - 4*delta^26*K*M*P*R^3*T^4*x1*x3*x5 - 8*delta^23*M*P^2*R^3*T^4*x1*x3*
    x5 + C^2*delta^22*K*M*P*T^5*x1*x3*x5 - 8*C*delta^23*K*M*P*R*T^5*x1*x3*
    x5 - 4*delta^21*K^2*M^2*P*R*T^5*x1*x3*x5 - 16*delta^18*K*M^2*P^2*R*T^5*x1*
    x3*x5 - 8*delta^24*K*M*P*R^2*T^5*x1*x3*x5 - 4*delta^21*M*P^2*R^2*T^5*x1*
    x3*x5 - 4*delta^22*K*M*P*R*T^6*x1*x3*x5 + 2*C^3*delta^19*K*M^2*P^2*T^2*x3*
    yA + 2*C^2*delta^17*K^2*M^3*P^2*T^2*x3*yA + 8*C^2*delta^14*K*M^3*P^3*T^2*
    x3*yA + 6*C*delta^12*K^2*M^4*P^3*T^2*x3*yA + 10*C*delta^9*K*M^4*P^4*T^2*
    x3*yA + 4*delta^7*K^2*M^5*P^4*T^2*x3*yA + 4*delta^4*K*M^5*P^5*T^2*x3*yA + 
   2*C^2*delta^20*K*M^2*P^2*R*T^2*x3*yA + 6*C*delta^15*K*M^3*P^3*R*T^2*x3*
    yA + 4*delta^10*K*M^4*P^4*R*T^2*x3*yA + 2*C^3*delta^23*K*M*P*T^3*x3*yA + 
   2*C^2*delta^21*K^2*M^2*P*T^3*x3*yA + 16*C^2*delta^18*K*M^2*P^2*T^3*x3*yA + 
   12*C*delta^16*K^2*M^3*P^2*T^3*x3*yA + 30*C*delta^13*K*M^3*P^3*T^3*x3*yA + 
   12*delta^11*K^2*M^4*P^3*T^3*x3*yA + 16*delta^8*K*M^4*P^4*T^3*x3*yA + 
   4*C^2*delta^24*K*M*P*R*T^3*x3*yA + 2*C*delta^22*K^2*M^2*P*R*T^3*x3*yA + 
   18*C*delta^19*K*M^2*P^2*R*T^3*x3*yA + 4*delta^17*K^2*M^3*P^2*R*T^3*x3*yA + 
   16*delta^14*K*M^3*P^3*R*T^3*x3*yA + 2*C*delta^25*K*M*P*R^2*T^3*x3*yA + 
   4*delta^20*K*M^2*P^2*R^2*T^3*x3*yA + 8*C^2*delta^22*K*M*P*T^4*x3*yA + 
   6*C*delta^20*K^2*M^2*P*T^4*x3*yA + 30*C*delta^17*K*M^2*P^2*T^4*x3*yA + 
   12*delta^15*K^2*M^3*P^2*T^4*x3*yA + 24*delta^12*K*M^3*P^3*T^4*x3*yA + 
   12*C*delta^23*K*M*P*R*T^4*x3*yA + 4*delta^21*K^2*M^2*P*R*T^4*x3*yA + 
   20*delta^18*K*M^2*P^2*R*T^4*x3*yA + 4*delta^24*K*M*P*R^2*T^4*x3*yA + 
   10*C*delta^21*K*M*P*T^5*x3*yA + 4*delta^19*K^2*M^2*P*T^5*x3*yA + 
   16*delta^16*K*M^2*P^2*T^5*x3*yA + 8*delta^22*K*M*P*R*T^5*x3*yA + 
   4*delta^20*K*M*P*T^6*x3*yA + 2*C^3*delta^15*K*M^3*P^3*T*x5*yA + 
   4*C^2*delta^10*K*M^4*P^4*T*x5*yA + 2*C*delta^5*K*M^5*P^5*T*x5*yA + 
   4*C^3*delta^19*K*M^2*P^2*T^2*x5*yA + 16*C^2*delta^14*K*M^3*P^3*T^2*x5*yA + 
   16*C*delta^9*K*M^4*P^4*T^2*x5*yA + 4*delta^4*K*M^5*P^5*T^2*x5*yA + 
   4*C^2*delta^20*K*M^2*P^2*R*T^2*x5*yA + 4*C*delta^15*K*M^3*P^3*R*T^2*x5*
    yA + 2*C^3*delta^23*K*M*P*T^3*x5*yA + 20*C^2*delta^18*K*M^2*P^2*T^3*x5*
    yA + 36*C*delta^13*K*M^3*P^3*T^3*x5*yA + 16*delta^8*K*M^4*P^4*T^3*x5*yA + 
   4*C^2*delta^24*K*M*P*R*T^3*x5*yA + 16*C*delta^19*K*M^2*P^2*R*T^3*x5*yA + 
   8*delta^14*K*M^3*P^3*R*T^3*x5*yA + 2*C*delta^25*K*M*P*R^2*T^3*x5*yA + 
   8*C^2*delta^22*K*M*P*T^4*x5*yA + 32*C*delta^17*K*M^2*P^2*T^4*x5*yA + 
   24*delta^12*K*M^3*P^3*T^4*x5*yA + 12*C*delta^23*K*M*P*R*T^4*x5*yA + 
   16*delta^18*K*M^2*P^2*R*T^4*x5*yA + 4*delta^24*K*M*P*R^2*T^4*x5*yA + 
   10*C*delta^21*K*M*P*T^5*x5*yA + 16*delta^16*K*M^2*P^2*T^5*x5*yA + 
   8*delta^22*K*M*P*R*T^5*x5*yA + 4*delta^20*K*M*P*T^6*x5*yA + 
   2*C^2*delta^10*K*M^4*P^4*T*x1*yB + 2*C*delta^5*K*M^5*P^5*T*x1*yB + 
   2*C^2*delta^13*M^3*P^4*R*T*x1*yB + 2*C*delta^8*M^4*P^5*R*T*x1*yB + 
   8*C^2*delta^14*K*M^3*P^3*T^2*x1*yB + 14*C*delta^9*K*M^4*P^4*T^2*x1*yB + 
   4*delta^4*K*M^5*P^5*T^2*x1*yB + 6*C^2*delta^17*M^2*P^3*R*T^2*x1*yB + 
   6*C*delta^15*K*M^3*P^3*R*T^2*x1*yB + 12*C*delta^12*M^3*P^4*R*T^2*x1*yB + 
   4*delta^10*K*M^4*P^4*R*T^2*x1*yB + 4*delta^7*M^4*P^5*R*T^2*x1*yB + 
   6*C*delta^18*M^2*P^3*R^2*T^2*x1*yB + 4*delta^13*M^3*P^4*R^2*T^2*x1*yB + 
   10*C^2*delta^18*K*M^2*P^2*T^3*x1*yB + 30*C*delta^13*K*M^3*P^3*T^3*x1*yB + 
   16*delta^8*K*M^4*P^4*T^3*x1*yB + 4*C^2*delta^21*M*P^2*R*T^3*x1*yB + 
   14*C*delta^19*K*M^2*P^2*R*T^3*x1*yB + 18*C*delta^16*M^2*P^3*R*T^3*x1*yB + 
   16*delta^14*K*M^3*P^3*R*T^3*x1*yB + 12*delta^11*M^3*P^4*R*T^3*x1*yB + 
   8*C*delta^22*M*P^2*R^2*T^3*x1*yB + 4*delta^20*K*M^2*P^2*R^2*T^3*x1*yB + 
   12*delta^17*M^2*P^3*R^2*T^3*x1*yB + 4*delta^23*M*P^2*R^3*T^3*x1*yB + 
   4*C^2*delta^22*K*M*P*T^4*x1*yB + 26*C*delta^17*K*M^2*P^2*T^4*x1*yB + 
   24*delta^12*K*M^3*P^3*T^4*x1*yB + 8*C*delta^23*K*M*P*R*T^4*x1*yB + 
   8*C*delta^20*M*P^2*R*T^4*x1*yB + 20*delta^18*K*M^2*P^2*R*T^4*x1*yB + 
   12*delta^15*M^2*P^3*R*T^4*x1*yB + 4*delta^24*K*M*P*R^2*T^4*x1*yB + 
   8*delta^21*M*P^2*R^2*T^4*x1*yB + 8*C*delta^21*K*M*P*T^5*x1*yB + 
   16*delta^16*K*M^2*P^2*T^5*x1*yB + 8*delta^22*K*M*P*R*T^5*x1*yB + 
   4*delta^19*M*P^2*R*T^5*x1*yB + 4*delta^20*K*M*P*T^6*x1*yB + 
   2*C^3*delta^15*K*M^3*P^3*T*x5*yB + 4*C^2*delta^10*K*M^4*P^4*T*x5*yB + 
   2*C*delta^5*K*M^5*P^5*T*x5*yB + 4*C^3*delta^19*K*M^2*P^2*T^2*x5*yB + 
   16*C^2*delta^14*K*M^3*P^3*T^2*x5*yB + 16*C*delta^9*K*M^4*P^4*T^2*x5*yB + 
   4*delta^4*K*M^5*P^5*T^2*x5*yB + 4*C^2*delta^20*K*M^2*P^2*R*T^2*x5*yB + 
   4*C*delta^15*K*M^3*P^3*R*T^2*x5*yB + 2*C^3*delta^23*K*M*P*T^3*x5*yB + 
   20*C^2*delta^18*K*M^2*P^2*T^3*x5*yB + 36*C*delta^13*K*M^3*P^3*T^3*x5*yB + 
   16*delta^8*K*M^4*P^4*T^3*x5*yB + 4*C^2*delta^24*K*M*P*R*T^3*x5*yB + 
   16*C*delta^19*K*M^2*P^2*R*T^3*x5*yB + 8*delta^14*K*M^3*P^3*R*T^3*x5*yB + 
   2*C*delta^25*K*M*P*R^2*T^3*x5*yB + 8*C^2*delta^22*K*M*P*T^4*x5*yB + 
   32*C*delta^17*K*M^2*P^2*T^4*x5*yB + 24*delta^12*K*M^3*P^3*T^4*x5*yB + 
   12*C*delta^23*K*M*P*R*T^4*x5*yB + 16*delta^18*K*M^2*P^2*R*T^4*x5*yB + 
   4*delta^24*K*M*P*R^2*T^4*x5*yB + 10*C*delta^21*K*M*P*T^5*x5*yB + 
   16*delta^16*K*M^2*P^2*T^5*x5*yB + 8*delta^22*K*M*P*R*T^5*x5*yB + 
   4*delta^20*K*M*P*T^6*x5*yB + 4*C^2*delta^14*K*M^3*P^3*T^2*yA*yB + 
   8*C*delta^9*K*M^4*P^4*T^2*yA*yB + 4*delta^4*K*M^5*P^5*T^2*yA*yB + 
   8*C^2*delta^18*K*M^2*P^2*T^3*yA*yB + 24*C*delta^13*K*M^3*P^3*T^3*yA*yB + 
   16*delta^8*K*M^4*P^4*T^3*yA*yB + 8*C*delta^19*K*M^2*P^2*R*T^3*yA*yB + 
   8*delta^14*K*M^3*P^3*R*T^3*yA*yB + 4*C^2*delta^22*K*M*P*T^4*yA*yB + 
   24*C*delta^17*K*M^2*P^2*T^4*yA*yB + 24*delta^12*K*M^3*P^3*T^4*yA*yB + 
   8*C*delta^23*K*M*P*R*T^4*yA*yB + 16*delta^18*K*M^2*P^2*R*T^4*yA*yB + 
   4*delta^24*K*M*P*R^2*T^4*yA*yB + 8*C*delta^21*K*M*P*T^5*yA*yB + 
   16*delta^16*K*M^2*P^2*T^5*yA*yB + 8*delta^22*K*M*P*R*T^5*yA*yB + 
   4*delta^20*K*M*P*T^6*yA*yB + 4*C^3*delta^15*K*M^3*P^3*T^2*x5*yA*yB + 
   12*C^2*delta^10*K*M^4*P^4*T^2*x5*yA*yB + 12*C*delta^5*K*M^5*P^5*T^2*x5*yA*
    yB + 4*K*M^6*P^6*T^2*x5*yA*yB + 12*C^3*delta^19*K*M^2*P^2*T^3*x5*yA*yB + 
   48*C^2*delta^14*K*M^3*P^3*T^3*x5*yA*yB + 60*C*delta^9*K*M^4*P^4*T^3*x5*yA*
    yB + 24*delta^4*K*M^5*P^5*T^3*x5*yA*yB + 12*C^2*delta^20*K*M^2*P^2*R*T^3*
    x5*yA*yB + 24*C*delta^15*K*M^3*P^3*R*T^3*x5*yA*yB + 
   12*delta^10*K*M^4*P^4*R*T^3*x5*yA*yB + 12*C^3*delta^23*K*M*P*T^4*x5*yA*
    yB + 72*C^2*delta^18*K*M^2*P^2*T^4*x5*yA*yB + 
   120*C*delta^13*K*M^3*P^3*T^4*x5*yA*yB + 60*delta^8*K*M^4*P^4*T^4*x5*yA*
    yB + 24*C^2*delta^24*K*M*P*R*T^4*x5*yA*yB + 72*C*delta^19*K*M^2*P^2*R*T^4*
    x5*yA*yB + 48*delta^14*K*M^3*P^3*R*T^4*x5*yA*yB + 
   12*C*delta^25*K*M*P*R^2*T^4*x5*yA*yB + 12*delta^20*K*M^2*P^2*R^2*T^4*x5*yA*
    yB + 4*C^3*delta^27*K*T^5*x5*yA*yB + 48*C^2*delta^22*K*M*P*T^5*x5*yA*yB + 
   120*C*delta^17*K*M^2*P^2*T^5*x5*yA*yB + 80*delta^12*K*M^3*P^3*T^5*x5*yA*
    yB + 12*C^2*delta^28*K*R*T^5*x5*yA*yB + 72*C*delta^23*K*M*P*R*T^5*x5*yA*
    yB + 72*delta^18*K*M^2*P^2*R*T^5*x5*yA*yB + 12*C*delta^29*K*R^2*T^5*x5*yA*
    yB + 24*delta^24*K*M*P*R^2*T^5*x5*yA*yB + 4*delta^30*K*R^3*T^5*x5*yA*yB + 
   12*C^2*delta^26*K*T^6*x5*yA*yB + 60*C*delta^21*K*M*P*T^6*x5*yA*yB + 
   60*delta^16*K*M^2*P^2*T^6*x5*yA*yB + 24*C*delta^27*K*R*T^6*x5*yA*yB + 
   48*delta^22*K*M*P*R*T^6*x5*yA*yB + 12*delta^28*K*R^2*T^6*x5*yA*yB + 
   12*C*delta^25*K*T^7*x5*yA*yB + 24*delta^20*K*M*P*T^7*x5*yA*yB + 
   12*delta^26*K*R*T^7*x5*yA*yB + 4*delta^24*K*T^8*x5*yA*yB + 
   2*C^2*delta^10*K*M^4*P^4*T*x1*yC + 2*C*delta^5*K*M^5*P^5*T*x1*yC + 
   2*C^2*delta^13*M^3*P^4*R*T*x1*yC + 2*C*delta^8*M^4*P^5*R*T*x1*yC + 
   8*C^2*delta^14*K*M^3*P^3*T^2*x1*yC + 14*C*delta^9*K*M^4*P^4*T^2*x1*yC + 
   4*delta^4*K*M^5*P^5*T^2*x1*yC + 6*C^2*delta^17*M^2*P^3*R*T^2*x1*yC + 
   6*C*delta^15*K*M^3*P^3*R*T^2*x1*yC + 12*C*delta^12*M^3*P^4*R*T^2*x1*yC + 
   4*delta^10*K*M^4*P^4*R*T^2*x1*yC + 4*delta^7*M^4*P^5*R*T^2*x1*yC + 
   6*C*delta^18*M^2*P^3*R^2*T^2*x1*yC + 4*delta^13*M^3*P^4*R^2*T^2*x1*yC + 
   10*C^2*delta^18*K*M^2*P^2*T^3*x1*yC + 30*C*delta^13*K*M^3*P^3*T^3*x1*yC + 
   16*delta^8*K*M^4*P^4*T^3*x1*yC + 4*C^2*delta^21*M*P^2*R*T^3*x1*yC + 
   14*C*delta^19*K*M^2*P^2*R*T^3*x1*yC + 18*C*delta^16*M^2*P^3*R*T^3*x1*yC + 
   16*delta^14*K*M^3*P^3*R*T^3*x1*yC + 12*delta^11*M^3*P^4*R*T^3*x1*yC + 
   8*C*delta^22*M*P^2*R^2*T^3*x1*yC + 4*delta^20*K*M^2*P^2*R^2*T^3*x1*yC + 
   12*delta^17*M^2*P^3*R^2*T^3*x1*yC + 4*delta^23*M*P^2*R^3*T^3*x1*yC + 
   4*C^2*delta^22*K*M*P*T^4*x1*yC + 26*C*delta^17*K*M^2*P^2*T^4*x1*yC + 
   24*delta^12*K*M^3*P^3*T^4*x1*yC + 8*C*delta^23*K*M*P*R*T^4*x1*yC + 
   8*C*delta^20*M*P^2*R*T^4*x1*yC + 20*delta^18*K*M^2*P^2*R*T^4*x1*yC + 
   12*delta^15*M^2*P^3*R*T^4*x1*yC + 4*delta^24*K*M*P*R^2*T^4*x1*yC + 
   8*delta^21*M*P^2*R^2*T^4*x1*yC + 8*C*delta^21*K*M*P*T^5*x1*yC + 
   16*delta^16*K*M^2*P^2*T^5*x1*yC + 8*delta^22*K*M*P*R*T^5*x1*yC + 
   4*delta^19*M*P^2*R*T^5*x1*yC + 4*delta^20*K*M*P*T^6*x1*yC + 
   2*C^3*delta^19*K*M^2*P^2*T^2*x3*yC + 2*C^2*delta^17*K^2*M^3*P^2*T^2*x3*
    yC + 8*C^2*delta^14*K*M^3*P^3*T^2*x3*yC + 6*C*delta^12*K^2*M^4*P^3*T^2*x3*
    yC + 10*C*delta^9*K*M^4*P^4*T^2*x3*yC + 4*delta^7*K^2*M^5*P^4*T^2*x3*yC + 
   4*delta^4*K*M^5*P^5*T^2*x3*yC + 2*C^2*delta^20*K*M^2*P^2*R*T^2*x3*yC + 
   6*C*delta^15*K*M^3*P^3*R*T^2*x3*yC + 4*delta^10*K*M^4*P^4*R*T^2*x3*yC + 
   2*C^3*delta^23*K*M*P*T^3*x3*yC + 2*C^2*delta^21*K^2*M^2*P*T^3*x3*yC + 
   16*C^2*delta^18*K*M^2*P^2*T^3*x3*yC + 12*C*delta^16*K^2*M^3*P^2*T^3*x3*
    yC + 30*C*delta^13*K*M^3*P^3*T^3*x3*yC + 12*delta^11*K^2*M^4*P^3*T^3*x3*
    yC + 16*delta^8*K*M^4*P^4*T^3*x3*yC + 4*C^2*delta^24*K*M*P*R*T^3*x3*yC + 
   2*C*delta^22*K^2*M^2*P*R*T^3*x3*yC + 18*C*delta^19*K*M^2*P^2*R*T^3*x3*yC + 
   4*delta^17*K^2*M^3*P^2*R*T^3*x3*yC + 16*delta^14*K*M^3*P^3*R*T^3*x3*yC + 
   2*C*delta^25*K*M*P*R^2*T^3*x3*yC + 4*delta^20*K*M^2*P^2*R^2*T^3*x3*yC + 
   8*C^2*delta^22*K*M*P*T^4*x3*yC + 6*C*delta^20*K^2*M^2*P*T^4*x3*yC + 
   30*C*delta^17*K*M^2*P^2*T^4*x3*yC + 12*delta^15*K^2*M^3*P^2*T^4*x3*yC + 
   24*delta^12*K*M^3*P^3*T^4*x3*yC + 12*C*delta^23*K*M*P*R*T^4*x3*yC + 
   4*delta^21*K^2*M^2*P*R*T^4*x3*yC + 20*delta^18*K*M^2*P^2*R*T^4*x3*yC + 
   4*delta^24*K*M*P*R^2*T^4*x3*yC + 10*C*delta^21*K*M*P*T^5*x3*yC + 
   4*delta^19*K^2*M^2*P*T^5*x3*yC + 16*delta^16*K*M^2*P^2*T^5*x3*yC + 
   8*delta^22*K*M*P*R*T^5*x3*yC + 4*delta^20*K*M*P*T^6*x3*yC + 
   4*C^2*delta^14*K*M^3*P^3*T^2*yA*yC + 8*C*delta^9*K*M^4*P^4*T^2*yA*yC + 
   4*delta^4*K*M^5*P^5*T^2*yA*yC + 8*C^2*delta^18*K*M^2*P^2*T^3*yA*yC + 
   24*C*delta^13*K*M^3*P^3*T^3*yA*yC + 16*delta^8*K*M^4*P^4*T^3*yA*yC + 
   8*C*delta^19*K*M^2*P^2*R*T^3*yA*yC + 8*delta^14*K*M^3*P^3*R*T^3*yA*yC + 
   4*C^2*delta^22*K*M*P*T^4*yA*yC + 24*C*delta^17*K*M^2*P^2*T^4*yA*yC + 
   24*delta^12*K*M^3*P^3*T^4*yA*yC + 8*C*delta^23*K*M*P*R*T^4*yA*yC + 
   16*delta^18*K*M^2*P^2*R*T^4*yA*yC + 4*delta^24*K*M*P*R^2*T^4*yA*yC + 
   8*C*delta^21*K*M*P*T^5*yA*yC + 16*delta^16*K*M^2*P^2*T^5*yA*yC + 
   8*delta^22*K*M*P*R*T^5*yA*yC + 4*delta^20*K*M*P*T^6*yA*yC - 
   4*C^3*delta^19*K*M^2*P^2*T^3*x3*yA*yC - 4*C^2*delta^17*K^2*M^3*P^2*T^3*x3*
    yA*yC - 12*C^2*delta^14*K*M^3*P^3*T^3*x3*yA*yC - 
   8*C*delta^12*K^2*M^4*P^3*T^3*x3*yA*yC - 12*C*delta^9*K*M^4*P^4*T^3*x3*yA*
    yC - 4*delta^7*K^2*M^5*P^4*T^3*x3*yA*yC - 4*delta^4*K*M^5*P^5*T^3*x3*yA*
    yC - 4*C^2*delta^20*K*M^2*P^2*R*T^3*x3*yA*yC - 
   8*C*delta^15*K*M^3*P^3*R*T^3*x3*yA*yC - 4*delta^10*K*M^4*P^4*R*T^3*x3*yA*
    yC - 8*C^3*delta^23*K*M*P*T^4*x3*yA*yC - 8*C^2*delta^21*K^2*M^2*P*T^4*x3*
    yA*yC - 36*C^2*delta^18*K*M^2*P^2*T^4*x3*yA*yC - 
   24*C*delta^16*K^2*M^3*P^2*T^4*x3*yA*yC - 48*C*delta^13*K*M^3*P^3*T^4*x3*yA*
    yC - 16*delta^11*K^2*M^4*P^3*T^4*x3*yA*yC - 20*delta^8*K*M^4*P^4*T^4*x3*
    yA*yC - 16*C^2*delta^24*K*M*P*R*T^4*x3*yA*yC - 
   8*C*delta^22*K^2*M^2*P*R*T^4*x3*yA*yC - 40*C*delta^19*K*M^2*P^2*R*T^4*x3*
    yA*yC - 8*delta^17*K^2*M^3*P^2*R*T^4*x3*yA*yC - 
   24*delta^14*K*M^3*P^3*R*T^4*x3*yA*yC - 8*C*delta^25*K*M*P*R^2*T^4*x3*yA*
    yC - 8*delta^20*K*M^2*P^2*R^2*T^4*x3*yA*yC - 4*C^3*delta^27*K*T^5*x3*yA*
    yC - 4*C^2*delta^25*K^2*M*T^5*x3*yA*yC - 36*C^2*delta^22*K*M*P*T^5*x3*yA*
    yC - 24*C*delta^20*K^2*M^2*P*T^5*x3*yA*yC - 72*C*delta^17*K*M^2*P^2*T^5*
    x3*yA*yC - 24*delta^15*K^2*M^3*P^2*T^5*x3*yA*yC - 
   40*delta^12*K*M^3*P^3*T^5*x3*yA*yC - 12*C^2*delta^28*K*R*T^5*x3*yA*yC - 
   8*C*delta^26*K^2*M*R*T^5*x3*yA*yC - 56*C*delta^23*K*M*P*R*T^5*x3*yA*yC - 
   16*delta^21*K^2*M^2*P*R*T^5*x3*yA*yC - 48*delta^18*K*M^2*P^2*R*T^5*x3*yA*
    yC - 12*C*delta^29*K*R^2*T^5*x3*yA*yC - 4*delta^27*K^2*M*R^2*T^5*x3*yA*
    yC - 20*delta^24*K*M*P*R^2*T^5*x3*yA*yC - 4*delta^30*K*R^3*T^5*x3*yA*yC - 
   12*C^2*delta^26*K*T^6*x3*yA*yC - 8*C*delta^24*K^2*M*T^6*x3*yA*yC - 
   48*C*delta^21*K*M*P*T^6*x3*yA*yC - 16*delta^19*K^2*M^2*P*T^6*x3*yA*yC - 
   40*delta^16*K*M^2*P^2*T^6*x3*yA*yC - 24*C*delta^27*K*R*T^6*x3*yA*yC - 
   8*delta^25*K^2*M*R*T^6*x3*yA*yC - 40*delta^22*K*M*P*R*T^6*x3*yA*yC - 
   12*delta^28*K*R^2*T^6*x3*yA*yC - 12*C*delta^25*K*T^7*x3*yA*yC - 
   4*delta^23*K^2*M*T^7*x3*yA*yC - 20*delta^20*K*M*P*T^7*x3*yA*yC - 
   12*delta^26*K*R*T^7*x3*yA*yC - 4*delta^24*K*T^8*x3*yA*yC + 
   4*C^2*delta^14*K*M^3*P^3*T^2*yB*yC + 8*C*delta^9*K*M^4*P^4*T^2*yB*yC + 
   4*delta^4*K*M^5*P^5*T^2*yB*yC + 8*C^2*delta^18*K*M^2*P^2*T^3*yB*yC + 
   24*C*delta^13*K*M^3*P^3*T^3*yB*yC + 16*delta^8*K*M^4*P^4*T^3*yB*yC + 
   8*C*delta^19*K*M^2*P^2*R*T^3*yB*yC + 8*delta^14*K*M^3*P^3*R*T^3*yB*yC + 
   4*C^2*delta^22*K*M*P*T^4*yB*yC + 24*C*delta^17*K*M^2*P^2*T^4*yB*yC + 
   24*delta^12*K*M^3*P^3*T^4*yB*yC + 8*C*delta^23*K*M*P*R*T^4*yB*yC + 
   16*delta^18*K*M^2*P^2*R*T^4*yB*yC + 4*delta^24*K*M*P*R^2*T^4*yB*yC + 
   8*C*delta^21*K*M*P*T^5*yB*yC + 16*delta^16*K*M^2*P^2*T^5*yB*yC + 
   8*delta^22*K*M*P*R*T^5*yB*yC + 4*delta^20*K*M*P*T^6*yB*yC - 
   4*C^2*delta^10*K*M^4*P^4*T^2*x1*yB*yC - 8*C*delta^5*K*M^5*P^5*T^2*x1*yB*
    yC - 4*K*M^6*P^6*T^2*x1*yB*yC - 4*C^2*delta^13*M^3*P^4*R*T^2*x1*yB*yC - 
   8*C*delta^8*M^4*P^5*R*T^2*x1*yB*yC - 4*delta^3*M^5*P^6*R*T^2*x1*yB*yC - 
   12*C^2*delta^14*K*M^3*P^3*T^3*x1*yB*yC - 32*C*delta^9*K*M^4*P^4*T^3*x1*yB*
    yC - 20*delta^4*K*M^5*P^5*T^3*x1*yB*yC - 8*C^2*delta^17*M^2*P^3*R*T^3*x1*
    yB*yC - 8*C*delta^15*K*M^3*P^3*R*T^3*x1*yB*yC - 
   24*C*delta^12*M^3*P^4*R*T^3*x1*yB*yC - 8*delta^10*K*M^4*P^4*R*T^3*x1*yB*
    yC - 16*delta^7*M^4*P^5*R*T^3*x1*yB*yC - 8*C*delta^18*M^2*P^3*R^2*T^3*x1*
    yB*yC - 8*delta^13*M^3*P^4*R^2*T^3*x1*yB*yC - 
   12*C^2*delta^18*K*M^2*P^2*T^4*x1*yB*yC - 48*C*delta^13*K*M^3*P^3*T^4*x1*yB*
    yC - 40*delta^8*K*M^4*P^4*T^4*x1*yB*yC - 4*C^2*delta^21*M*P^2*R*T^4*x1*yB*
    yC - 16*C*delta^19*K*M^2*P^2*R*T^4*x1*yB*yC - 
   24*C*delta^16*M^2*P^3*R*T^4*x1*yB*yC - 24*delta^14*K*M^3*P^3*R*T^4*x1*yB*
    yC - 24*delta^11*M^3*P^4*R*T^4*x1*yB*yC - 8*C*delta^22*M*P^2*R^2*T^4*x1*
    yB*yC - 4*delta^20*K*M^2*P^2*R^2*T^4*x1*yB*yC - 
   16*delta^17*M^2*P^3*R^2*T^4*x1*yB*yC - 4*delta^23*M*P^2*R^3*T^4*x1*yB*yC - 
   4*C^2*delta^22*K*M*P*T^5*x1*yB*yC - 32*C*delta^17*K*M^2*P^2*T^5*x1*yB*yC - 
   40*delta^12*K*M^3*P^3*T^5*x1*yB*yC - 8*C*delta^23*K*M*P*R*T^5*x1*yB*yC - 
   8*C*delta^20*M*P^2*R*T^5*x1*yB*yC - 24*delta^18*K*M^2*P^2*R*T^5*x1*yB*yC - 
   16*delta^15*M^2*P^3*R*T^5*x1*yB*yC - 4*delta^24*K*M*P*R^2*T^5*x1*yB*yC - 
   8*delta^21*M*P^2*R^2*T^5*x1*yB*yC - 8*C*delta^21*K*M*P*T^6*x1*yB*yC - 
   20*delta^16*K*M^2*P^2*T^6*x1*yB*yC - 8*delta^22*K*M*P*R*T^6*x1*yB*yC - 
   4*delta^19*M*P^2*R*T^6*x1*yB*yC - 4*delta^20*K*M*P*T^7*x1*yB*yC, 
 "ExponentPointCount" -> 319, "AffineDimension" -> 7, 
 "QHullFacetCount" -> 25, "LowerFacetCandidateCount" -> 7, 
 "FullLowerFacetCount" -> 7, "LandauRestrictedLowerFacetCount" -> 0, 
 "HiddenPullbackFacetCount" -> 5, "FullLowerFacets" -> 
  {<|"LocalNormal" -> {-2, -2, -2, -1, 3, -1, 1}, "LeadingWeight" -> 0, 
    "LeadingPointCount" -> 7, "AffineRank" -> 6, "LowerFacetQ" -> True, 
    "PathWeights" -> {-2, -2, -2}, "MovingLandauRatioOrders" -> {1, 3, 1}, 
    "NormalWeights" -> {-1, 3, -1}, "RestrictedNormalMask" -> 
     {False, True, False}, "AtLeastOneNormalRestrictedQ" -> True, 
    "AllThreeNormalsRestrictedQ" -> False, "PulledBackOriginalWeights" -> 
     {-1, -2, 1, -2, -1, -2}, "OriginalCoordinateLeadingPointCount" -> 4, 
    "OriginalCoordinateAffineRank" -> 2, "OriginalCoordinateLowerFacetQ" -> 
     False, "HiddenAfterPullbackQ" -> True, "LeadingPoints" -> {{1, 1, 1, 0, 
     0, 0, 6}, {1, 1, 0, 0, 0, 0, 4}, {1, 0, 1, 0, 0, 0, 4}, {1, 0, 0, 0, 1, 
     1, 0}, {0, 1, 1, 0, 0, 0, 4}, {0, 1, 0, 1, 0, 1, 4}, {0, 0, 1, 1, 1, 0, 
     0}}|>, <|"LocalNormal" -> {-2, -2, -2, -2, 4, 0, 1}, 
    "LeadingWeight" -> 0, "LeadingPointCount" -> 8, "AffineRank" -> 6, 
    "LowerFacetQ" -> True, "PathWeights" -> {-2, -2, -2}, 
    "MovingLandauRatioOrders" -> {1, 3, 1}, "NormalWeights" -> {-2, 4, 0}, 
    "RestrictedNormalMask" -> {False, True, True}, 
    "AtLeastOneNormalRestrictedQ" -> True, "AllThreeNormalsRestrictedQ" -> 
     False, "PulledBackOriginalWeights" -> {-2, -2, 1, -2, -1, -2}, 
    "OriginalCoordinateLeadingPointCount" -> 2, 
    "OriginalCoordinateAffineRank" -> 1, "OriginalCoordinateLowerFacetQ" -> 
     False, "HiddenAfterPullbackQ" -> True, "LeadingPoints" -> {{1, 1, 1, 0, 
     0, 0, 6}, {1, 1, 0, 0, 0, 0, 4}, {1, 0, 1, 0, 0, 0, 4}, {0, 1, 1, 0, 0, 
     0, 4}, {0, 1, 0, 1, 0, 1, 4}, {0, 1, 0, 1, 0, 0, 4}, {0, 0, 1, 1, 1, 0, 
     0}, {0, 0, 1, 1, 0, 0, 4}}|>, <|"LocalNormal" -> {0, 0, 0, 0, 4, 0, 1}, 
    "LeadingWeight" -> 4, "LeadingPointCount" -> 11, "AffineRank" -> 6, 
    "LowerFacetQ" -> True, "PathWeights" -> {0, 0, 0}, 
    "MovingLandauRatioOrders" -> {1, 3, 1}, "NormalWeights" -> {0, 4, 0}, 
    "RestrictedNormalMask" -> {False, True, False}, 
    "AtLeastOneNormalRestrictedQ" -> True, "AllThreeNormalsRestrictedQ" -> 
     False, "PulledBackOriginalWeights" -> {0, 0, 3, 0, 0, 0}, 
    "OriginalCoordinateLeadingPointCount" -> 4, 
    "OriginalCoordinateAffineRank" -> 2, "OriginalCoordinateLowerFacetQ" -> 
     False, "HiddenAfterPullbackQ" -> True, "LeadingPoints" -> {{1, 1, 0, 0, 
     0, 0, 4}, {1, 0, 1, 0, 0, 0, 4}, {1, 0, 0, 0, 1, 1, 0}, {1, 0, 0, 0, 0, 
     1, 4}, {0, 1, 1, 0, 0, 0, 4}, {0, 1, 0, 1, 0, 1, 4}, {0, 1, 0, 1, 0, 0, 
     4}, {0, 1, 0, 0, 0, 1, 4}, {0, 0, 1, 1, 1, 0, 0}, {0, 0, 1, 1, 0, 0, 4}, 
     {0, 0, 0, 1, 0, 1, 4}}|>, <|"LocalNormal" -> {4, 4, 4, 4, 4, 4, 1}, 
    "LeadingWeight" -> 12, "LeadingPointCount" -> 14, "AffineRank" -> 6, 
    "LowerFacetQ" -> True, "PathWeights" -> {4, 4, 4}, 
    "MovingLandauRatioOrders" -> {1, 3, 1}, "NormalWeights" -> {4, 4, 4}, 
    "RestrictedNormalMask" -> {False, False, False}, 
    "AtLeastOneNormalRestrictedQ" -> False, "AllThreeNormalsRestrictedQ" -> 
     False, "PulledBackOriginalWeights" -> {4, 4, 4, 4, 4, 4}, 
    "OriginalCoordinateLeadingPointCount" -> 14, 
    "OriginalCoordinateAffineRank" -> 6, "OriginalCoordinateLowerFacetQ" -> 
     True, "HiddenAfterPullbackQ" -> False, "LeadingPoints" -> {{1, 1, 0, 0, 
     0, 0, 4}, {1, 0, 1, 0, 0, 0, 4}, {1, 0, 0, 0, 1, 1, 0}, {1, 0, 0, 0, 1, 
     0, 4}, {1, 0, 0, 0, 0, 1, 4}, {0, 1, 1, 0, 0, 0, 4}, {0, 1, 0, 1, 0, 0, 
     4}, {0, 1, 0, 0, 0, 1, 4}, {0, 0, 1, 1, 1, 0, 0}, {0, 0, 1, 1, 0, 0, 4}, 
     {0, 0, 1, 0, 1, 0, 4}, {0, 0, 0, 1, 1, 0, 4}, {0, 0, 0, 1, 0, 1, 4}, {0, 
     0, 0, 0, 1, 1, 4}}|>, <|"LocalNormal" -> {-2, -2, -2, 0, 4, -2, 1}, 
    "LeadingWeight" -> 0, "LeadingPointCount" -> 8, "AffineRank" -> 6, 
    "LowerFacetQ" -> True, "PathWeights" -> {-2, -2, -2}, 
    "MovingLandauRatioOrders" -> {1, 3, 1}, "NormalWeights" -> {0, 4, -2}, 
    "RestrictedNormalMask" -> {True, True, False}, 
    "AtLeastOneNormalRestrictedQ" -> True, "AllThreeNormalsRestrictedQ" -> 
     False, "PulledBackOriginalWeights" -> {-1, -2, 1, -2, -2, -2}, 
    "OriginalCoordinateLeadingPointCount" -> 2, 
    "OriginalCoordinateAffineRank" -> 1, "OriginalCoordinateLowerFacetQ" -> 
     False, "HiddenAfterPullbackQ" -> True, "LeadingPoints" -> {{1, 1, 1, 0, 
     0, 0, 6}, {1, 1, 0, 0, 0, 0, 4}, {1, 0, 1, 0, 0, 0, 4}, {1, 0, 0, 0, 1, 
     1, 0}, {1, 0, 0, 0, 0, 1, 4}, {0, 1, 1, 0, 0, 0, 4}, {0, 1, 0, 1, 0, 1, 
     4}, {0, 1, 0, 0, 0, 1, 4}}|>, <|"LocalNormal" -> {-2, -2, -2, 4, -2, 4, 
     1}, "LeadingWeight" -> 0, "LeadingPointCount" -> 8, "AffineRank" -> 6, 
    "LowerFacetQ" -> True, "PathWeights" -> {-2, -2, -2}, 
    "MovingLandauRatioOrders" -> {1, 3, 1}, "NormalWeights" -> {4, -2, 4}, 
    "RestrictedNormalMask" -> {True, False, True}, 
    "AtLeastOneNormalRestrictedQ" -> True, "AllThreeNormalsRestrictedQ" -> 
     False, "PulledBackOriginalWeights" -> {-1, -2, -2, -2, -1, -2}, 
    "OriginalCoordinateLeadingPointCount" -> 2, 
    "OriginalCoordinateAffineRank" -> 1, "OriginalCoordinateLowerFacetQ" -> 
     False, "HiddenAfterPullbackQ" -> True, "LeadingPoints" -> {{1, 1, 1, 0, 
     0, 0, 6}, {1, 1, 0, 0, 0, 0, 4}, {1, 0, 1, 0, 0, 0, 4}, {1, 0, 0, 0, 1, 
     1, 0}, {1, 0, 0, 0, 1, 0, 4}, {0, 1, 1, 0, 0, 0, 4}, {0, 0, 1, 1, 1, 0, 
     0}, {0, 0, 1, 0, 1, 0, 4}}|>, <|"LocalNormal" -> {4, 0, 4, 0, 0, 0, 1}, 
    "LeadingWeight" -> 4, "LeadingPointCount" -> 8, "AffineRank" -> 6, 
    "LowerFacetQ" -> True, "PathWeights" -> {4, 0, 4}, 
    "MovingLandauRatioOrders" -> {1, 3, 1}, "NormalWeights" -> {0, 0, 0}, 
    "RestrictedNormalMask" -> {False, False, False}, 
    "AtLeastOneNormalRestrictedQ" -> False, "AllThreeNormalsRestrictedQ" -> 
     False, "PulledBackOriginalWeights" -> {0, 4, 0, 0, 0, 4}, 
    "OriginalCoordinateLeadingPointCount" -> 8, 
    "OriginalCoordinateAffineRank" -> 6, "OriginalCoordinateLowerFacetQ" -> 
     True, "HiddenAfterPullbackQ" -> False, "LeadingPoints" -> {{1, 0, 0, 0, 
     1, 1, 0}, {0, 1, 0, 1, 0, 1, 4}, {0, 1, 0, 1, 0, 0, 4}, {0, 1, 0, 0, 0, 
     1, 4}, {0, 0, 1, 1, 1, 0, 0}, {0, 0, 0, 1, 1, 0, 4}, {0, 0, 0, 1, 0, 1, 
     4}, {0, 0, 0, 0, 1, 1, 4}}|>}, "LandauRestrictedLowerFacets" -> {}, 
 "HiddenPullbackFacets" -> {<|"LocalNormal" -> {-2, -2, -2, -1, 3, -1, 1}, 
    "LeadingWeight" -> 0, "LeadingPointCount" -> 7, "AffineRank" -> 6, 
    "LowerFacetQ" -> True, "PathWeights" -> {-2, -2, -2}, 
    "MovingLandauRatioOrders" -> {1, 3, 1}, "NormalWeights" -> {-1, 3, -1}, 
    "RestrictedNormalMask" -> {False, True, False}, 
    "AtLeastOneNormalRestrictedQ" -> True, "AllThreeNormalsRestrictedQ" -> 
     False, "PulledBackOriginalWeights" -> {-1, -2, 1, -2, -1, -2}, 
    "OriginalCoordinateLeadingPointCount" -> 4, 
    "OriginalCoordinateAffineRank" -> 2, "OriginalCoordinateLowerFacetQ" -> 
     False, "HiddenAfterPullbackQ" -> True, "LeadingPoints" -> {{1, 1, 1, 0, 
     0, 0, 6}, {1, 1, 0, 0, 0, 0, 4}, {1, 0, 1, 0, 0, 0, 4}, {1, 0, 0, 0, 1, 
     1, 0}, {0, 1, 1, 0, 0, 0, 4}, {0, 1, 0, 1, 0, 1, 4}, {0, 0, 1, 1, 1, 0, 
     0}}|>, <|"LocalNormal" -> {-2, -2, -2, -2, 4, 0, 1}, 
    "LeadingWeight" -> 0, "LeadingPointCount" -> 8, "AffineRank" -> 6, 
    "LowerFacetQ" -> True, "PathWeights" -> {-2, -2, -2}, 
    "MovingLandauRatioOrders" -> {1, 3, 1}, "NormalWeights" -> {-2, 4, 0}, 
    "RestrictedNormalMask" -> {False, True, True}, 
    "AtLeastOneNormalRestrictedQ" -> True, "AllThreeNormalsRestrictedQ" -> 
     False, "PulledBackOriginalWeights" -> {-2, -2, 1, -2, -1, -2}, 
    "OriginalCoordinateLeadingPointCount" -> 2, 
    "OriginalCoordinateAffineRank" -> 1, "OriginalCoordinateLowerFacetQ" -> 
     False, "HiddenAfterPullbackQ" -> True, "LeadingPoints" -> {{1, 1, 1, 0, 
     0, 0, 6}, {1, 1, 0, 0, 0, 0, 4}, {1, 0, 1, 0, 0, 0, 4}, {0, 1, 1, 0, 0, 
     0, 4}, {0, 1, 0, 1, 0, 1, 4}, {0, 1, 0, 1, 0, 0, 4}, {0, 0, 1, 1, 1, 0, 
     0}, {0, 0, 1, 1, 0, 0, 4}}|>, <|"LocalNormal" -> {0, 0, 0, 0, 4, 0, 1}, 
    "LeadingWeight" -> 4, "LeadingPointCount" -> 11, "AffineRank" -> 6, 
    "LowerFacetQ" -> True, "PathWeights" -> {0, 0, 0}, 
    "MovingLandauRatioOrders" -> {1, 3, 1}, "NormalWeights" -> {0, 4, 0}, 
    "RestrictedNormalMask" -> {False, True, False}, 
    "AtLeastOneNormalRestrictedQ" -> True, "AllThreeNormalsRestrictedQ" -> 
     False, "PulledBackOriginalWeights" -> {0, 0, 3, 0, 0, 0}, 
    "OriginalCoordinateLeadingPointCount" -> 4, 
    "OriginalCoordinateAffineRank" -> 2, "OriginalCoordinateLowerFacetQ" -> 
     False, "HiddenAfterPullbackQ" -> True, "LeadingPoints" -> {{1, 1, 0, 0, 
     0, 0, 4}, {1, 0, 1, 0, 0, 0, 4}, {1, 0, 0, 0, 1, 1, 0}, {1, 0, 0, 0, 0, 
     1, 4}, {0, 1, 1, 0, 0, 0, 4}, {0, 1, 0, 1, 0, 1, 4}, {0, 1, 0, 1, 0, 0, 
     4}, {0, 1, 0, 0, 0, 1, 4}, {0, 0, 1, 1, 1, 0, 0}, {0, 0, 1, 1, 0, 0, 4}, 
     {0, 0, 0, 1, 0, 1, 4}}|>, <|"LocalNormal" -> {-2, -2, -2, 0, 4, -2, 1}, 
    "LeadingWeight" -> 0, "LeadingPointCount" -> 8, "AffineRank" -> 6, 
    "LowerFacetQ" -> True, "PathWeights" -> {-2, -2, -2}, 
    "MovingLandauRatioOrders" -> {1, 3, 1}, "NormalWeights" -> {0, 4, -2}, 
    "RestrictedNormalMask" -> {True, True, False}, 
    "AtLeastOneNormalRestrictedQ" -> True, "AllThreeNormalsRestrictedQ" -> 
     False, "PulledBackOriginalWeights" -> {-1, -2, 1, -2, -2, -2}, 
    "OriginalCoordinateLeadingPointCount" -> 2, 
    "OriginalCoordinateAffineRank" -> 1, "OriginalCoordinateLowerFacetQ" -> 
     False, "HiddenAfterPullbackQ" -> True, "LeadingPoints" -> {{1, 1, 1, 0, 
     0, 0, 6}, {1, 1, 0, 0, 0, 0, 4}, {1, 0, 1, 0, 0, 0, 4}, {1, 0, 0, 0, 1, 
     1, 0}, {1, 0, 0, 0, 0, 1, 4}, {0, 1, 1, 0, 0, 0, 4}, {0, 1, 0, 1, 0, 1, 
     4}, {0, 1, 0, 0, 0, 1, 4}}|>, <|"LocalNormal" -> {-2, -2, -2, 4, -2, 4, 
     1}, "LeadingWeight" -> 0, "LeadingPointCount" -> 8, "AffineRank" -> 6, 
    "LowerFacetQ" -> True, "PathWeights" -> {-2, -2, -2}, 
    "MovingLandauRatioOrders" -> {1, 3, 1}, "NormalWeights" -> {4, -2, 4}, 
    "RestrictedNormalMask" -> {True, False, True}, 
    "AtLeastOneNormalRestrictedQ" -> True, "AllThreeNormalsRestrictedQ" -> 
     False, "PulledBackOriginalWeights" -> {-1, -2, -2, -2, -1, -2}, 
    "OriginalCoordinateLeadingPointCount" -> 2, 
    "OriginalCoordinateAffineRank" -> 1, "OriginalCoordinateLowerFacetQ" -> 
     False, "HiddenAfterPullbackQ" -> True, "LeadingPoints" -> {{1, 1, 1, 0, 
     0, 0, 6}, {1, 1, 0, 0, 0, 0, 4}, {1, 0, 1, 0, 0, 0, 4}, {1, 0, 0, 0, 1, 
     1, 0}, {1, 0, 0, 0, 1, 0, 4}, {0, 1, 1, 0, 0, 0, 4}, {0, 0, 1, 1, 1, 0, 
     0}, {0, 0, 1, 0, 1, 0, 4}}|>}|>
