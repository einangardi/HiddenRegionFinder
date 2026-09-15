(* Created with the Wolfram Language : www.wolfram.com *)
<|"Rows" -> {<|"Test" -> "Crown.PositivePinchFaceCount", "PassQ" -> True,
    "Detail" ->
     "Known positive control has exactly one pure-F0 pinch face"|>,
   <|"Test" -> "Crown.NoUnresolvedFaces", "PassQ" -> True,
    "Detail" -> "Exact face/pinch audit is complete"|>,
   <|"Test" -> "Crown.PositiveWitness", "PassQ" -> True,
    "Detail" ->
     "Positive witness survives without a generator presentation"|>,
   <|"Test" -> "NoCrown85774.GlobalSubtractionFreeCertificate",
    "PassQ" -> True, "Detail" ->
     "A subtraction-free restricted F0 rejects every possible face at once"|>\
, <|"Test" -> "NoCrown85774.LogDerivativeFarkasCertificate", "PassQ" -> True,
    "Detail" -> "Mixed derivative faces are rejected by an exact \
subtraction-free linear combination of x_i d_i F_SL"|>,
   <|"Test" -> "NoCrown105232.MixedF0FaceLatticeCount", "PassQ" -> True,
    "Detail" ->
     "Complete exact F0 face lattice for a mixed-sign near-miss"|>,
   <|"Test" -> "NoCrown105232.AllFacesRejected", "PassQ" -> True,
    "Detail" -> "Every F0 face violates the positive pinch equations"|>,
   <|"Test" -> "NoCrown105232.NoUnresolvedFaces", "PassQ" -> True,
    "Detail" ->
     "Negative certificate contains no timed-out or failed solve"|>},
 "Summary" -> <|"Total" -> 8, "Passed" -> 8, "Failed" -> 0|>,
 "CrownAudit" -> <|"ID" -> "Crown", "ZeroVars" -> {}, "ActiveVarCount" -> 8,
   "F0PointCount" -> 6, "F0FacetCount" -> 13, "FaceCount" -> 27,
   "PureF0FaceCount" -> 27, "FaceStatusCounts" ->
    <|"PositivePinchAndHierarchy" -> 1, "RejectedBySignDefiniteDerivative" ->
      26|>, "PositivePinchFaceCount" -> 1, "UnresolvedFaceCount" -> 0,
   "Status" -> "Complete", "HiddenRegionQ" -> True,
   "RepresentativeDerivativeCombinationFaces" -> {},
   "PositiveOrUnresolvedFaces" ->
    {<|"FaceVertexIndices" -> {1, 2, 3, 4, 5, 6}, "FacePointCount" -> 6,
      "FSL" -> s12*x1*x3*x4*x6 - s12*x1*x2*x5*x6 - s23*x1*x2*x5*x6 +
        s23*x0*x3*x5*x6 + s23*x1*x2*x4*x7 - s12*x0*x3*x4*x7 -
        s23*x0*x3*x4*x7 + s12*x0*x2*x5*x7, "DerivativeCount" -> 8,
      "Status" -> "PositivePinchAndHierarchy", "PositivePinchQ" -> True,
      "PinchWitness" -> {x0 -> 1, hrfWA16A -> 1, hrfWA16B -> 1, x1 -> 1,
        x2 -> 1, x3 -> 1, x4 -> 1, x5 -> 1, x6 -> 1, x7 -> 1},
      "HierarchyAudit" -> <|"HierarchyFeasibleQ" -> True,
        "HierarchyStatus" -> "PositiveGap", "MaxGap" -> 1,
        "Scaling" -> {x0 -> -1, x1 -> -1, x2 -> -1, x3 -> -1, x4 -> -1,
          x5 -> -1, x6 -> -1, x7 -> -1}, "FSLWeight" -> -4,
        "FSLExponentRowCount" -> 6, "PostExponentRowCount" -> 96,
        "ActivePostRowCount" -> 96, "ActivePostSourceCounts" ->
         <|"U" -> 32, "FDelta[1]" -> 64|>, "ActivePostRows" ->
         {{{1, 0, 1, 0, 1, 0, 0, 0}, 0, "U"}, {{1, 0, 1, 0, 0, 1, 0, 0}, 0,
           "U"}, {{1, 0, 1, 0, 0, 0, 1, 0}, 0, "U"},
          {{1, 0, 1, 0, 0, 0, 0, 1}, 0, "U"}, {{1, 0, 0, 1, 1, 0, 0, 0}, 0,
           "U"}, {{1, 0, 0, 1, 0, 1, 0, 0}, 0, "U"},
          {{1, 0, 0, 1, 0, 0, 1, 0}, 0, "U"}, {{1, 0, 0, 1, 0, 0, 0, 1}, 0,
           "U"}, {{1, 0, 0, 0, 1, 0, 1, 0}, 0, "U"},
          {{1, 0, 0, 0, 1, 0, 0, 1}, 0, "U"}, {{1, 0, 0, 0, 0, 1, 1, 0}, 0,
           "U"}, {{1, 0, 0, 0, 0, 1, 0, 1}, 0, "U"},
          {{0, 1, 1, 0, 1, 0, 0, 0}, 0, "U"}, {{0, 1, 1, 0, 0, 1, 0, 0}, 0,
           "U"}, {{0, 1, 1, 0, 0, 0, 1, 0}, 0, "U"},
          {{0, 1, 1, 0, 0, 0, 0, 1}, 0, "U"}, {{0, 1, 0, 1, 1, 0, 0, 0}, 0,
           "U"}, {{0, 1, 0, 1, 0, 1, 0, 0}, 0, "U"},
          {{0, 1, 0, 1, 0, 0, 1, 0}, 0, "U"}, {{0, 1, 0, 1, 0, 0, 0, 1}, 0,
           "U"}, {{0, 1, 0, 0, 1, 0, 1, 0}, 0, "U"},
          {{0, 1, 0, 0, 1, 0, 0, 1}, 0, "U"}, {{0, 1, 0, 0, 0, 1, 1, 0}, 0,
           "U"}, {{0, 1, 0, 0, 0, 1, 0, 1}, 0, "U"},
          {{0, 0, 1, 0, 1, 0, 1, 0}, 0, "U"}, {{0, 0, 1, 0, 1, 0, 0, 1}, 0,
           "U"}, {{0, 0, 1, 0, 0, 1, 1, 0}, 0, "U"},
          {{0, 0, 1, 0, 0, 1, 0, 1}, 0, "U"}, {{0, 0, 0, 1, 1, 0, 1, 0}, 0,
           "U"}, {{0, 0, 0, 1, 1, 0, 0, 1}, 0, "U"},
          {{0, 0, 0, 1, 0, 1, 1, 0}, 0, "U"}, {{0, 0, 0, 1, 0, 1, 0, 1}, 0,
           "U"}, {{1, 1, 1, 0, 1, 0, 0, 0}, 1, "FDelta[1]"},
          {{1, 1, 1, 0, 0, 1, 0, 0}, 1, "FDelta[1]"},
          {{1, 1, 1, 0, 0, 0, 1, 0}, 1, "FDelta[1]"},
          {{1, 1, 1, 0, 0, 0, 0, 1}, 1, "FDelta[1]"},
          {{1, 1, 0, 1, 1, 0, 0, 0}, 1, "FDelta[1]"},
          {{1, 1, 0, 1, 0, 1, 0, 0}, 1, "FDelta[1]"},
          {{1, 1, 0, 1, 0, 0, 1, 0}, 1, "FDelta[1]"},
          {{1, 1, 0, 1, 0, 0, 0, 1}, 1, "FDelta[1]"},
          {{1, 1, 0, 0, 1, 0, 1, 0}, 1, "FDelta[1]"},
          {{1, 1, 0, 0, 1, 0, 0, 1}, 1, "FDelta[1]"},
          {{1, 1, 0, 0, 0, 1, 1, 0}, 1, "FDelta[1]"},
          {{1, 1, 0, 0, 0, 1, 0, 1}, 1, "FDelta[1]"},
          {{1, 0, 1, 1, 1, 0, 0, 0}, 1, "FDelta[1]"},
          {{1, 0, 1, 1, 0, 1, 0, 0}, 1, "FDelta[1]"},
          {{1, 0, 1, 1, 0, 0, 1, 0}, 1, "FDelta[1]"},
          {{1, 0, 1, 1, 0, 0, 0, 1}, 1, "FDelta[1]"},
          {{1, 0, 1, 0, 1, 1, 0, 0}, 1, "FDelta[1]"},
          {{1, 0, 1, 0, 1, 0, 1, 0}, 1, "FDelta[1]"},
          {{1, 0, 1, 0, 1, 0, 0, 1}, 1, "FDelta[1]"},
          {{1, 0, 1, 0, 0, 1, 1, 0}, 1, "FDelta[1]"},
          {{1, 0, 1, 0, 0, 1, 0, 1}, 1, "FDelta[1]"},
          {{1, 0, 1, 0, 0, 0, 1, 1}, 1, "FDelta[1]"},
          {{1, 0, 0, 1, 1, 1, 0, 0}, 1, "FDelta[1]"},
          {{1, 0, 0, 1, 1, 0, 1, 0}, 1, "FDelta[1]"},
          {{1, 0, 0, 1, 1, 0, 0, 1}, 1, "FDelta[1]"},
          {{1, 0, 0, 1, 0, 1, 1, 0}, 1, "FDelta[1]"},
          {{1, 0, 0, 1, 0, 1, 0, 1}, 1, "FDelta[1]"},
          {{1, 0, 0, 1, 0, 0, 1, 1}, 1, "FDelta[1]"},
          {{1, 0, 0, 0, 1, 1, 1, 0}, 1, "FDelta[1]"},
          {{1, 0, 0, 0, 1, 1, 0, 1}, 1, "FDelta[1]"},
          {{1, 0, 0, 0, 1, 0, 1, 1}, 1, "FDelta[1]"},
          {{1, 0, 0, 0, 0, 1, 1, 1}, 1, "FDelta[1]"},
          {{0, 1, 1, 1, 1, 0, 0, 0}, 1, "FDelta[1]"},
          {{0, 1, 1, 1, 0, 1, 0, 0}, 1, "FDelta[1]"},
          {{0, 1, 1, 1, 0, 0, 1, 0}, 1, "FDelta[1]"},
          {{0, 1, 1, 1, 0, 0, 0, 1}, 1, "FDelta[1]"},
          {{0, 1, 1, 0, 1, 1, 0, 0}, 1, "FDelta[1]"},
          {{0, 1, 1, 0, 1, 0, 1, 0}, 1, "FDelta[1]"},
          {{0, 1, 1, 0, 1, 0, 0, 1}, 1, "FDelta[1]"},
          {{0, 1, 1, 0, 0, 1, 1, 0}, 1, "FDelta[1]"},
          {{0, 1, 1, 0, 0, 1, 0, 1}, 1, "FDelta[1]"},
          {{0, 1, 1, 0, 0, 0, 1, 1}, 1, "FDelta[1]"},
          {{0, 1, 0, 1, 1, 1, 0, 0}, 1, "FDelta[1]"},
          {{0, 1, 0, 1, 1, 0, 1, 0}, 1, "FDelta[1]"},
          {{0, 1, 0, 1, 1, 0, 0, 1}, 1, "FDelta[1]"},
          {{0, 1, 0, 1, 0, 1, 1, 0}, 1, "FDelta[1]"},
          {{0, 1, 0, 1, 0, 1, 0, 1}, 1, "FDelta[1]"},
          {{0, 1, 0, 1, 0, 0, 1, 1}, 1, "FDelta[1]"},
          {{0, 1, 0, 0, 1, 1, 1, 0}, 1, "FDelta[1]"},
          {{0, 1, 0, 0, 1, 1, 0, 1}, 1, "FDelta[1]"},
          {{0, 1, 0, 0, 1, 0, 1, 1}, 1, "FDelta[1]"},
          {{0, 1, 0, 0, 0, 1, 1, 1}, 1, "FDelta[1]"},
          {{0, 0, 1, 1, 1, 0, 1, 0}, 1, "FDelta[1]"},
          {{0, 0, 1, 1, 1, 0, 0, 1}, 1, "FDelta[1]"},
          {{0, 0, 1, 1, 0, 1, 1, 0}, 1, "FDelta[1]"},
          {{0, 0, 1, 1, 0, 1, 0, 1}, 1, "FDelta[1]"},
          {{0, 0, 1, 0, 1, 1, 1, 0}, 1, "FDelta[1]"},
          {{0, 0, 1, 0, 1, 1, 0, 1}, 1, "FDelta[1]"},
          {{0, 0, 1, 0, 1, 0, 1, 1}, 1, "FDelta[1]"},
          {{0, 0, 1, 0, 0, 1, 1, 1}, 1, "FDelta[1]"},
          {{0, 0, 0, 1, 1, 1, 1, 0}, 1, "FDelta[1]"},
          {{0, 0, 0, 1, 1, 1, 0, 1}, 1, "FDelta[1]"},
          {{0, 0, 0, 1, 1, 0, 1, 1}, 1, "FDelta[1]"},
          {{0, 0, 0, 1, 0, 1, 1, 1}, 1, "FDelta[1]"}}|>|>}|>,
 "SubtractionFreeNoCrownAudit" -> <|"ID" -> 85774,
   "ZeroVars" -> {x0, x3, x4, x9}, "ActiveVarCount" -> 8,
   "Status" -> "Complete", "Certificate" -> "GlobalSubtractionFreeF0",
   "HiddenRegionQ" -> False, "PositivePinchFaceCount" -> 0,
   "UnresolvedFaceCount" -> 0, "PositiveOrUnresolvedFaces" -> {}|>,
 "FarkasNoCrownAudit" -> <|"ID" -> 85774, "ZeroVars" -> {x0, x3, x5, x6},
   "ActiveVarCount" -> 8, "F0PointCount" -> 12, "F0FacetCount" -> 13,
   "FaceCount" -> 525, "PureF0FaceCount" -> 525,
   "FaceStatusCounts" -> <|"RejectedByPositiveDerivativeCombination" -> 16,
     "RejectedBySignDefiniteDerivative" -> 509|>,
   "PositivePinchFaceCount" -> 0, "UnresolvedFaceCount" -> 0,
   "Status" -> "Complete", "HiddenRegionQ" -> False,
   "RepresentativeDerivativeCombinationFaces" ->
    {<|"FaceVertexIndices" -> {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
      "FacePointCount" -> 12, "FSL" -> -(s12*x1*x10*x11*x2*x7) -
        s23*x1*x10*x11*x2*x7 - s12*x1*x10*x11*x2*x8 - s23*x1*x10*x11*x2*x8 -
        s12*x1*x11*x2*x7*x8 - s23*x1*x11*x2*x7*x8 - s12*x10*x11*x2*x7*x8 -
        s23*x10*x11*x2*x7*x8 - s12*x11*x2*x4*x7*x8 - s23*x11*x2*x4*x7*x8 -
        s12*x1*x10*x11*x2*x9 - s23*x1*x10*x11*x2*x9 + s12*x1*x10*x4*x7*x9 +
        s12*x10*x2*x4*x7*x9 + s12*x1*x10*x4*x8*x9 + s12*x1*x11*x4*x8*x9 +
        s12*x1*x4*x7*x8*x9 + s12*x10*x4*x7*x8*x9, "DerivativeCount" -> 8,
      "Status" -> "RejectedByPositiveDerivativeCombination",
      "PositivePinchQ" -> False, "DerivativeCombinationCertificate" ->
       <|"CombinationCoefficients" -> {1/50, 1/50, 1/50, -2/25, 1/50, 1/50,
          1/50, 1/50}, "CoefficientVector" -> {0, 0, 0, 1/10, 1/10, 1/10,
          1/10, 0, 1/10, 1/10, 1/10, 1/10, 0, 0, 0, 1/10, 1/10, 0},
        "CombinationPolynomial" -> (hrfWA16A*x1*x10*x4*x7*x9)/10 +
          (hrfWA16B*x1*x10*x4*x7*x9)/10 + (hrfWA16A*x1*x10*x4*x8*x9)/10 +
          (hrfWA16B*x1*x10*x4*x8*x9)/10 + (hrfWA16A*x1*x11*x4*x8*x9)/10 +
          (hrfWA16B*x1*x11*x4*x8*x9)/10 + (hrfWA16A*x1*x4*x7*x8*x9)/10 +
          (hrfWA16B*x1*x4*x7*x8*x9)/10 + (hrfWA16A*x10*x4*x7*x8*x9)/10 +
          (hrfWA16B*x10*x4*x7*x8*x9)/10|>|>,
     <|"FaceVertexIndices" -> {2, 3, 4, 5, 6, 8, 9, 10, 11, 12},
      "FacePointCount" -> 10, "FSL" -> -(s12*x1*x10*x11*x2*x8) -
        s23*x1*x10*x11*x2*x8 - s12*x1*x11*x2*x7*x8 - s23*x1*x11*x2*x7*x8 -
        s12*x10*x11*x2*x7*x8 - s23*x10*x11*x2*x7*x8 - s12*x11*x2*x4*x7*x8 -
        s23*x11*x2*x4*x7*x8 - s12*x1*x10*x11*x2*x9 - s23*x1*x10*x11*x2*x9 +
        s12*x10*x2*x4*x7*x9 + s12*x1*x10*x4*x8*x9 + s12*x1*x11*x4*x8*x9 +
        s12*x1*x4*x7*x8*x9 + s12*x10*x4*x7*x8*x9, "DerivativeCount" -> 8,
      "Status" -> "RejectedByPositiveDerivativeCombination",
      "PositivePinchQ" -> False, "DerivativeCombinationCertificate" ->
       <|"CombinationCoefficients" -> {0, 0, -1/8, 1/16, 0, 0, 1/16, 1/16},
        "CoefficientVector" -> {0, 0, 1/8, 1/8, 0, 0, 0, 1/8, 1/8, 0, 1/8,
          1/8, 1/8, 1/8, 0}, "CombinationPolynomial" ->
         (hrfWA16A*x10*x2*x4*x7*x9)/8 + (hrfWA16B*x10*x2*x4*x7*x9)/8 +
          (hrfWA16A*x1*x10*x4*x8*x9)/8 + (hrfWA16B*x1*x10*x4*x8*x9)/8 +
          (hrfWA16A*x1*x4*x7*x8*x9)/8 + (hrfWA16B*x1*x4*x7*x8*x9)/8 +
          (hrfWA16A*x10*x4*x7*x8*x9)/8 + (hrfWA16B*x10*x4*x7*x8*x9)/8|>|>,
     <|"FaceVertexIndices" -> {1, 3, 4, 5, 6, 7, 8, 10, 11, 12},
      "FacePointCount" -> 10, "FSL" -> -(s12*x1*x10*x11*x2*x7) -
        s23*x1*x10*x11*x2*x7 - s12*x1*x11*x2*x7*x8 - s23*x1*x11*x2*x7*x8 -
        s12*x10*x11*x2*x7*x8 - s23*x10*x11*x2*x7*x8 - s12*x11*x2*x4*x7*x8 -
        s23*x11*x2*x4*x7*x8 - s12*x1*x10*x11*x2*x9 - s23*x1*x10*x11*x2*x9 +
        s12*x1*x10*x4*x7*x9 + s12*x10*x2*x4*x7*x9 + s12*x1*x11*x4*x8*x9 +
        s12*x1*x4*x7*x8*x9 + s12*x10*x4*x7*x8*x9, "DerivativeCount" -> 8,
      "Status" -> "RejectedByPositiveDerivativeCombination",
      "PositivePinchQ" -> False, "DerivativeCombinationCertificate" ->
       <|"CombinationCoefficients" -> {0, 0, -1/16, 0, 0, 1/16, 0, 1/16},
        "CoefficientVector" -> {0, 0, 1/8, 1/8, 0, 0, 0, 1/8, 1/8, 0, 1/8,
          1/8, 1/8, 1/8, 0}, "CombinationPolynomial" ->
         (hrfWA16A*x1*x10*x4*x7*x9)/8 + (hrfWA16B*x1*x10*x4*x7*x9)/8 +
          (hrfWA16A*x10*x2*x4*x7*x9)/8 + (hrfWA16B*x10*x2*x4*x7*x9)/8 +
          (hrfWA16A*x1*x4*x7*x8*x9)/8 + (hrfWA16B*x1*x4*x7*x8*x9)/8 +
          (hrfWA16A*x10*x4*x7*x8*x9)/8 + (hrfWA16B*x10*x4*x7*x8*x9)/8|>|>},
   "PositiveOrUnresolvedFaces" -> {}|>, "MixedNoCrownAudit" ->
  <|"ID" -> 105232, "ZeroVars" -> {x0, x1, x3, x5}, "ActiveVarCount" -> 9,
   "F0PointCount" -> 14, "F0FacetCount" -> 15, "FaceCount" -> 1207,
   "PureF0FaceCount" -> 1207, "FaceStatusCounts" ->
    <|"RejectedBySignDefiniteDerivative" -> 1207|>,
   "PositivePinchFaceCount" -> 0, "UnresolvedFaceCount" -> 0,
   "Status" -> "Complete", "HiddenRegionQ" -> False,
   "RepresentativeDerivativeCombinationFaces" -> {},
   "PositiveOrUnresolvedFaces" -> {}|>|>
