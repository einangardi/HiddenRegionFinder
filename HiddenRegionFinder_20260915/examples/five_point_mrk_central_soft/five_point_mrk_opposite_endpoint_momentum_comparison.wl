(* Created with the Wolfram Language : www.wolfram.com *)
<|"Status" -> "Passed", "Checks" -> <|"RepresentativeFacetQ" -> True, 
   "OppositeFacetQ" -> True, "PolynomialReflectionQ" -> True, 
   "TotalVectorReflectionQ" -> True, "VirtualityReflectionQ" -> True, 
   "RepresentativeLocalVirtualitiesQ" -> True, 
   "OppositeLocalVirtualitiesQ" -> True, 
   "RepresentativeVertexConservationQ" -> True, 
   "OppositeVertexConservationQ" -> True, "OneGlauberLoopEachQ" -> True, 
   "TwoTChannelGlauberVerticesEachQ" -> True, "MomentumPowerAgreementQ" -> 
    True|>, "GraphReflection" -> <|"VertexMap" -> "3<->5", 
   "EdgeMap" -> {x0 -> x1, x1 -> x0, x2 -> x3, x3 -> x2, x4 -> x5, x5 -> x4}, 
   "PhysicalInterpretation" -> "The longitudinal-dominated edge and the two \
affine t-channel presentations of the single Glauber loop exchange endpoints; \
the number and local widths of independent modes do not change."|>, 
 "Representative" -> <|"Name" -> "p4 at endpoint 5", 
   "ExternalOrderAtVertices" -> {1, 2, 3, 5, 4}, 
   "TotalRegionVector" -> {-4, -4, -1, -4, -4, -4, 1}, 
   "PropagatorVirtualityPowers" -> <|x0 -> 4, x1 -> 4, x2 -> 1, x3 -> 4, 
     x4 -> 4, x5 -> 4|>, "CentralEdgeComponentPowers" -> 
    <|x0 -> {6, -2, 2}, x1 -> {6, -2, 2}, x2 -> {-2, 3, 2}, x3 -> {1, 3, 2}, 
     x4 -> {2, -2, 0}, x5 -> {4, -2, 1}|>, 
   "ModeAdaptedEdgeComponentPowers" -> <|x0 -> {4, 0, 2}, x1 -> {4, 0, 2}, 
     x2 -> {0, 1, 2}, x3 -> {3, 1, 2}, x4 -> {4, 0, 2}, x5 -> {4, 0, 2}|>, 
   "ExactRouting" -> <|x0 -> "r", x1 -> "p1-r", x2 -> "p3-ell", 
     x3 -> "ell+p2-p3", x4 -> "r-ell", x5 -> "p5-r+ell"|>, 
   "LoopModes" -> <|"OrdinaryLoop" -> <|"Definition" -> "r=q0", 
       "LocalWidths" -> {4, 0, 2}|>, "GlauberLoop" -> 
      <|"Definition" -> "ell=q0-q4", "LocalWidths" -> {4, 1, 2}|>, 
     "SecondTChannelGlauberRouting" -> 
      <|"Definition" -> "ell5=q1-q5=p4-q3=p1-p5-ell", 
       "CentralPowers" -> {4, 1, 1}, "LocalWidths" -> {4, 1, 2}, 
       "FluctuationRelation" -> "Delta ell5=-Delta ell"|>, 
     "Pinches" -> {<|"Component" -> "r+", "Edges" -> {x0, x1}, 
        "Width" -> 4|>, <|"Component" -> "ell+", "Edges" -> {x4, x5}, 
        "Width" -> 4|>, <|"Component" -> "ell-", "Edges" -> {x2, x3}, 
        "Width" -> 1|>}|>, "GlauberLoopCount" -> 1, 
   "LocalCancellationCoordinates" -> <|"A" -> P*x2 - delta^3*K*x3, 
     "B" -> x1*x4 - x0*x5, "Jacobian" -> -(1/(P*x0)), 
     "MeasurePower" -> -20|>, "ParameterMeasurePower" -> -20, 
   "MomentumMeasurePower" -> 9 + 4*(-2 + D), "ScalarIntegralPower" -> 
    -20 + 4*D, "PowerAtD4Minus2Epsilon" -> -4 - 8*epsilon, 
   "VertexFeasibility" -> <|"1:plus" -> True, "1:minus" -> True, 
     "1:perp" -> True, "2:plus" -> True, "2:minus" -> True, "2:perp" -> True, 
     "3:plus" -> True, "3:minus" -> True, "3:perp" -> True, "4:plus" -> True, 
     "4:minus" -> True, "4:perp" -> True, "5:plus" -> True, 
     "5:minus" -> True, "5:perp" -> True|>|>, 
 "OppositeEndpoint" -> <|"Name" -> "p4 at endpoint 3", 
   "ExternalOrderAtVertices" -> {1, 2, 4, 5, 3}, 
   "TotalRegionVector" -> {-4, -4, -4, -1, -4, -4, 1}, 
   "PropagatorVirtualityPowers" -> <|x0 -> 4, x1 -> 4, x2 -> 4, x3 -> 1, 
     x4 -> 4, x5 -> 4|>, "CentralEdgeComponentPowers" -> 
    <|x0 -> {6, -2, 2}, x1 -> {6, -2, 2}, x2 -> {1, 3, 2}, x3 -> {-2, 3, 2}, 
     x4 -> {4, -2, 1}, x5 -> {2, -2, 0}|>, 
   "ModeAdaptedEdgeComponentPowers" -> <|x0 -> {4, 0, 2}, x1 -> {4, 0, 2}, 
     x2 -> {3, 1, 2}, x3 -> {0, 1, 2}, x4 -> {4, 0, 2}, x5 -> {4, 0, 2}|>, 
   "ExactRouting" -> <|x0 -> "p1-r", x1 -> "r", x2 -> "ell+p2-p3", 
     x3 -> "p3-ell", x4 -> "p5-r+ell", x5 -> "r-ell"|>, 
   "LoopModes" -> <|"OrdinaryLoop" -> <|"Definition" -> "r=q1", 
       "LocalWidths" -> {4, 0, 2}|>, "GlauberLoop" -> 
      <|"Definition" -> "ell=q1-q5", "LocalWidths" -> {4, 1, 2}|>, 
     "SecondTChannelGlauberRouting" -> 
      <|"Definition" -> "ell3=q0-q4=p4-q2=p1-p5-ell", 
       "CentralPowers" -> {4, 1, 1}, "LocalWidths" -> {4, 1, 2}, 
       "FluctuationRelation" -> "Delta ell3=-Delta ell"|>, 
     "Pinches" -> {<|"Component" -> "r+", "Edges" -> {x1, x0}, 
        "Width" -> 4|>, <|"Component" -> "ell+", "Edges" -> {x5, x4}, 
        "Width" -> 4|>, <|"Component" -> "ell-", "Edges" -> {x3, x2}, 
        "Width" -> 1|>}|>, "GlauberLoopCount" -> 1, 
   "LocalCancellationCoordinates" -> <|"A" -> delta^3*K*x2 - P*x3, 
     "B" -> x1*x4 - x0*x5, "Jacobian" -> 1/(P*x0), "MeasurePower" -> -20|>, 
   "ParameterMeasurePower" -> -20, "MomentumMeasurePower" -> 9 + 4*(-2 + D), 
   "ScalarIntegralPower" -> -20 + 4*D, "PowerAtD4Minus2Epsilon" -> 
    -4 - 8*epsilon, "VertexFeasibility" -> <|"1:plus" -> True, 
     "1:minus" -> True, "1:perp" -> True, "2:plus" -> True, 
     "2:minus" -> True, "2:perp" -> True, "3:plus" -> True, 
     "3:minus" -> True, "3:perp" -> True, "4:plus" -> True, 
     "4:minus" -> True, "4:perp" -> True, "5:plus" -> True, 
     "5:minus" -> True, "5:perp" -> True|>|>, 
 "Comparison" -> <|"SameModeContentQ" -> True, 
   "RepresentativeExceptionalPropagator" -> x2, 
   "OppositeExceptionalPropagator" -> x3, 
   "RepresentativeGlauberCombination" -> "q0-q4", 
   "OppositeGlauberCombination" -> "q1-q5", 
   "RepresentativeSecondTChannelRouting" -> "q1-q5", 
   "OppositeSecondTChannelRouting" -> "q0-q4", "Conclusion" -> "The two \
fixed-label regions differ, but their momentum regions are related exactly by \
endpoint reflection: one ordinary on-shell-balanced loop and one Glauber loop \
in each case.  The same Glauber loop has two affine t-channel routings, so \
both four-valent endpoints are Glauber vertices."|>|>
