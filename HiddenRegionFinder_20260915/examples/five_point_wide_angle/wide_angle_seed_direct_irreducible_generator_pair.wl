(* Created with the Wolfram Language : www.wolfram.com *)
<|"Data" -> <|"ExternalOrderAtVertices" -> {1, 2, 3, 4, 5}, 
   "InternalLines" -> {{"0", {1, 3}}, {"0", {1, 5}}, {"0", {2, 3}}, 
     {"0", {2, 5}}, {"0", {3, 4}}, {"0", {4, 5}}}, 
   "ExternalLines" -> {{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}, {p5, 5}}, 
   "U" -> x0*x2 + x1*x2 + x0*x3 + x1*x3 + x0*x4 + x1*x4 + x2*x4 + x3*x4 + 
     x0*x5 + x1*x5 + x2*x5 + x3*x5, "FOffShell" -> 
    lambdaOS*x0*x1*x2 + lambdaOS*x0*x1*x3 + lambdaOS*x0*x2*x3 + 
     lambdaOS*x1*x2*x3 + lambdaOS*x0*x1*x4 + lambdaOS*x0*x2*x4 + 
     3*lambdaOS*x1*x2*x4 - s12*x1*x2*x4 - s23*x1*x2*x4 + s45*x1*x2*x4 + 
     s23*x0*x3*x4 + s45*x1*x3*x4 + lambdaOS*x2*x3*x4 + lambdaOS*x0*x1*x5 + 
     s34*x0*x2*x5 + 3*lambdaOS*x1*x2*x5 - s12*x1*x2*x5 - s15*x1*x2*x5 + 
     s34*x1*x2*x5 + s15*x0*x3*x5 + lambdaOS*x1*x3*x5 + lambdaOS*x2*x3*x5 + 
     lambdaOS*x0*x4*x5 + lambdaOS*x1*x4*x5 + lambdaOS*x2*x4*x5 + 
     lambdaOS*x3*x4*x5, "F0" -> -(s12*x1*x2*x4) - s23*x1*x2*x4 + 
     s45*x1*x2*x4 + s23*x0*x3*x4 + s45*x1*x3*x4 + s34*x0*x2*x5 - 
     s12*x1*x2*x5 - s15*x1*x2*x5 + s34*x1*x2*x5 + s15*x0*x3*x5, 
   "Variables" -> {x0, x1, x2, x3, x4, x5}|>, 
 "Generators" -> {s23*x3*x4 + s34*x2*x5 + s15*x3*x5, 
   s12*x2*x4 + s23*x2*x4 - s45*x2*x4 - s45*x3*x4 + s12*x2*x5 + s15*x2*x5 - 
    s34*x2*x5}, "ObstructionData" -> <|"Indices" -> {}, 
   "ObstructionTerms" -> {}, "Obstruction" -> 0, 
   "Superleading" -> -(s12*x1*x2*x4) - s23*x1*x2*x4 + s45*x1*x2*x4 + 
     s23*x0*x3*x4 + s45*x1*x3*x4 + s34*x0*x2*x5 - s12*x1*x2*x5 - 
     s15*x1*x2*x5 + s34*x1*x2*x5 + s15*x0*x3*x5, 
   "Complement" -> -(s12*x1*x2*x4) - s23*x1*x2*x4 + s45*x1*x2*x4 + 
     s23*x0*x3*x4 + s45*x1*x3*x4 + s34*x0*x2*x5 - s12*x1*x2*x5 - 
     s15*x1*x2*x5 + s34*x1*x2*x5 + s15*x0*x3*x5, 
   "Generators" -> {s23*x3*x4 + s34*x2*x5 + s15*x3*x5, 
     s12*x2*x4 + s23*x2*x4 - s45*x2*x4 - s45*x3*x4 + s12*x2*x5 + s15*x2*x5 - 
      s34*x2*x5}, "InIdealQ" -> True, "IdealMembershipRemainder" -> 0, 
   "DerivativeConsistentQ" -> True, "SearchMethod" -> 
    "AllInGeneratorIdeal"|>, "Evaluation" -> 
  <|"Trial" -> <|"Generators" -> {s23*x3*x4 + s34*x2*x5 + s15*x3*x5, 
       s12*x2*x4 + s23*x2*x4 - s45*x2*x4 - s45*x3*x4 + s12*x2*x5 + 
        s15*x2*x5 - s34*x2*x5}, "AdmissibleSLSectorQ" -> True, 
     "ObstructionData" -> <|"Indices" -> {}, "ObstructionTerms" -> {}, 
       "Obstruction" -> 0, "Superleading" -> -(s12*x1*x2*x4) - s23*x1*x2*x4 + 
         s45*x1*x2*x4 + s23*x0*x3*x4 + s45*x1*x3*x4 + s34*x0*x2*x5 - 
         s12*x1*x2*x5 - s15*x1*x2*x5 + s34*x1*x2*x5 + s15*x0*x3*x5, 
       "Complement" -> -(s12*x1*x2*x4) - s23*x1*x2*x4 + s45*x1*x2*x4 + 
         s23*x0*x3*x4 + s45*x1*x3*x4 + s34*x0*x2*x5 - s12*x1*x2*x5 - 
         s15*x1*x2*x5 + s34*x1*x2*x5 + s15*x0*x3*x5, 
       "Generators" -> {s23*x3*x4 + s34*x2*x5 + s15*x3*x5, 
         s12*x2*x4 + s23*x2*x4 - s45*x2*x4 - s45*x3*x4 + s12*x2*x5 + 
          s15*x2*x5 - s34*x2*x5}, "InIdealQ" -> True, 
       "IdealMembershipRemainder" -> 0, "DerivativeConsistentQ" -> True, 
       "SearchMethod" -> "AllInGeneratorIdeal"|>, "GeneratorFactorData" -> 
      {}, "GeneratorSetFactorUnion" -> {s23*x3*x4 + s34*x2*x5 + s15*x3*x5, 
       s12*x2*x4 + s23*x2*x4 - s45*x2*x4 - s45*x3*x4 + s12*x2*x5 + 
        s15*x2*x5 - s34*x2*x5}, "GeneratorSetFactorCount" -> 2, 
     "PerGeneratorAdmissibleQ" -> True, 
     "SimultaneouslyAdmissibleGeneratorSetQ" -> True, 
     "SLSectorGenerators" -> {s23*x3*x4 + s34*x2*x5 + s15*x3*x5, 
       s12*x2*x4 + s23*x2*x4 - s45*x2*x4 - s45*x3*x4 + s12*x2*x5 + 
        s15*x2*x5 - s34*x2*x5}, "SLSectorFactorUnion" -> 
      {s23*x3*x4 + s34*x2*x5 + s15*x3*x5, s12*x2*x4 + s23*x2*x4 - s45*x2*x4 - 
        s45*x3*x4 + s12*x2*x5 + s15*x2*x5 - s34*x2*x5}, 
     "SLSectorFactorCount" -> 2, "SimultaneouslyAdmissibleSLSectorQ" -> 
      True|>, "TrialIndex" -> Missing["NotAvailable"], 
   "Generators" -> {s23*x3*x4 + s34*x2*x5 + s15*x3*x5, 
     s12*x2*x4 + s23*x2*x4 - s45*x2*x4 - s45*x3*x4 + s12*x2*x5 + s15*x2*x5 - 
      s34*x2*x5}, "ScalingData" -> <|"Scaling" -> {-1, -1, -1, -1, -1, -1}, 
     "RationalScaling" -> {-1, -1, -1, -1, -1, -1}, 
     "PrimitiveScaling" -> {-1, -1, -1, -1, -1, -1}, 
     "RationalScalingWithUnitGap" -> {-1, -1, -1, -1, -1, -1}, 
     "PrimitiveHierarchyGap" -> Missing["NotHomogeneous"], 
     "UnitGapNormalizationQ" -> False, "ExplicitDeltaWeightsRestoredQ" -> 
      True, "CandidateGenerationMethod" -> "ExactLayeredCoverageBranchLP", 
     "AcceptedCount" -> 1, "ScalingStatus" -> "Found", 
     "ScalingStatusMessage" -> 
      "Exact layered lower-face coverage scaling found", 
     "ScalingSearchCompleteQ" -> True, "SelectedCandidateDiagnostic" -> 
      <|"ScalingVector" -> {-1, -1, -1, -1, -1, -1}, "VariableScaling" -> 
        <|x0 -> -1, x1 -> -1, x2 -> -1, x3 -> -1, x4 -> -1, x5 -> -1|>, 
       "WSL" -> -3, "WHR" -> -2, "FSLWeight" -> -3, 
       "PostCancellationLeadingWeight" -> -2, "HierarchyGapPostLPminusFSL" -> 
        1, "HiddenDominatesPostCancellationLPQ" -> True, 
       "VariablesCoveredByFSLAtWSL" -> {x0, x1, x2, x3, x4, x5}, 
       "VariablesInPostCancellationLeadingSupport" -> {x0, x1, x2, x3, x4, 
         x5}, "VariablesCoveredByLeadingRegionMonomials" -> 
        {x0, x1, x2, x3, x4, x5}, 
       "VariablesMissingFromLeadingRegionCoverage" -> {}, 
       "LeadingRegionCoverageQ" -> True|>, "Diagnostics" -> 
      <|"ScalingVector" -> {-1, -1, -1, -1, -1, -1}, "VariableScaling" -> 
        <|x0 -> -1, x1 -> -1, x2 -> -1, x3 -> -1, x4 -> -1, x5 -> -1|>, 
       "WSL" -> -3, "WHR" -> -2, "FSLWeight" -> -3, 
       "PostCancellationLeadingWeight" -> -2, "HierarchyGapPostLPminusFSL" -> 
        1, "HiddenDominatesPostCancellationLPQ" -> True, 
       "VariablesCoveredByFSLAtWSL" -> {x0, x1, x2, x3, x4, x5}, 
       "VariablesInPostCancellationLeadingSupport" -> {x0, x1, x2, x3, x4, 
         x5}, "VariablesCoveredByLeadingRegionMonomials" -> 
        {x0, x1, x2, x3, x4, x5}, 
       "VariablesMissingFromLeadingRegionCoverage" -> {}, 
       "LeadingRegionCoverageQ" -> True|>, "CoverageChoiceCount" -> 1, 
     "LPCheckCount" -> 1, "FSLFaceIndicesUnitGap" -> {1, 2, 3, 4, 5, 6}, 
     "PostFaceChoiceIndicesUnitGap" -> {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 
       12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29}, 
     "VariableScaling" -> <|x0 -> -1, x1 -> -1, x2 -> -1, x3 -> -1, x4 -> -1, 
       x5 -> -1|>, "RationalVariableScaling" -> <|x0 -> -1, x1 -> -1, 
       x2 -> -1, x3 -> -1, x4 -> -1, x5 -> -1|>, 
     "RationalVariableScalingWithUnitGap" -> <|x0 -> -1, x1 -> -1, x2 -> -1, 
       x3 -> -1, x4 -> -1, x5 -> -1|>, "FSLWeightPrimitive" -> -3, 
     "PostCancellationLeadingWeightPrimitive" -> -2, 
     "HierarchyGapPostLPminusFSL" -> 1, "FSLWeightUnitGap" -> -3, 
     "PostCancellationLeadingWeightUnitGap" -> -2, "FSLExponentRows" -> {{1, 
      0, 1, 0, 0, 1}, {1, 0, 0, 1, 1, 0}, {1, 0, 0, 1, 0, 1}, {0, 1, 1, 0, 1, 
      0}, {0, 1, 1, 0, 0, 1}, {0, 1, 0, 1, 1, 0}}, 
     "FSLLeadingExponentRows" -> {{1, 0, 1, 0, 0, 1}, {1, 0, 0, 1, 1, 0}, {1, 
      0, 0, 1, 0, 1}, {0, 1, 1, 0, 1, 0}, {0, 1, 1, 0, 0, 1}, {0, 1, 0, 1, 1, 
      0}}, "FSLHigherLayerExponentRows" -> {}, 
     "PostCancellationExponentRowCount" -> 29, 
     "PostCancellationLeadingRows" -> {<|"Row" -> {1, 0, 1, 0, 0, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {1, 0, 0, 1, 0, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {1, 0, 0, 0, 1, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {1, 0, 0, 0, 0, 1}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 1, 1, 0, 0, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 1, 0, 1, 0, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 1, 0, 0, 1, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 1, 0, 0, 0, 1}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 0, 1, 0, 1, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 0, 1, 0, 0, 1}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 0, 0, 1, 1, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 0, 0, 1, 0, 1}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {1, 1, 1, 0, 0, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {1, 1, 0, 1, 0, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {1, 1, 0, 0, 1, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {1, 1, 0, 0, 0, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {1, 0, 1, 1, 0, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {1, 0, 1, 0, 1, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {1, 0, 0, 0, 1, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 1, 1, 1, 0, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 1, 1, 0, 1, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 1, 1, 0, 0, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 1, 0, 1, 0, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 1, 0, 0, 1, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 0, 1, 1, 1, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 0, 1, 1, 0, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 0, 1, 0, 1, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 0, 0, 1, 1, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>}, 
     "PostCancellationLeadingPowers" -> {0, 1}, 
     "PostCancellationLeadingSources" -> {{"U", 12}, {"FDelta", 16}}, 
     "VariablesCoveredByFSLAtWSL" -> {x0, x1, x2, x3, x4, x5}, 
     "VariablesInPostCancellationLeadingSupport" -> {x0, x1, x2, x3, x4, x5}, 
     "VariablesCoveredByLeadingRegionMonomials" -> {x0, x1, x2, x3, x4, x5}, 
     "VariablesMissingFromLeadingRegionCoverage" -> {}, 
     "LeadingRegionCoverageQ" -> True, "Criteria" -> 
      <|"FSLCancellation" -> "a nontrivial lower face of F_SL has weight \
W_SL; every remaining F_SL monomial lies at or above W_HR", 
       "HiddenHierarchy" -> "W_HR>W_SL", "PostFace" -> 
        "U, F_obs, and higher F_SL layers have weight at least W_HR", 
       "Coverage" -> "active variables occur on the W_SL or W_HR layers", 
       "Sign" -> "NonPositive"|>|>, "CoverageScalingData" -> 
    <|"Scaling" -> {-1, -1, -1, -1, -1, -1}, "RationalScaling" -> 
      {-1, -1, -1, -1, -1, -1}, "PrimitiveScaling" -> 
      {-1, -1, -1, -1, -1, -1}, "RationalScalingWithUnitGap" -> 
      {-1, -1, -1, -1, -1, -1}, "PrimitiveHierarchyGap" -> 
      Missing["NotHomogeneous"], "UnitGapNormalizationQ" -> False, 
     "ExplicitDeltaWeightsRestoredQ" -> True, "CandidateGenerationMethod" -> 
      "ExactLayeredCoverageBranchLP", "AcceptedCount" -> 1, 
     "ScalingStatus" -> "Found", "ScalingStatusMessage" -> 
      "Exact layered lower-face coverage scaling found", 
     "ScalingSearchCompleteQ" -> True, "SelectedCandidateDiagnostic" -> 
      <|"ScalingVector" -> {-1, -1, -1, -1, -1, -1}, "VariableScaling" -> 
        <|x0 -> -1, x1 -> -1, x2 -> -1, x3 -> -1, x4 -> -1, x5 -> -1|>, 
       "WSL" -> -3, "WHR" -> -2, "FSLWeight" -> -3, 
       "PostCancellationLeadingWeight" -> -2, "HierarchyGapPostLPminusFSL" -> 
        1, "HiddenDominatesPostCancellationLPQ" -> True, 
       "VariablesCoveredByFSLAtWSL" -> {x0, x1, x2, x3, x4, x5}, 
       "VariablesInPostCancellationLeadingSupport" -> {x0, x1, x2, x3, x4, 
         x5}, "VariablesCoveredByLeadingRegionMonomials" -> 
        {x0, x1, x2, x3, x4, x5}, 
       "VariablesMissingFromLeadingRegionCoverage" -> {}, 
       "LeadingRegionCoverageQ" -> True|>, "Diagnostics" -> 
      <|"ScalingVector" -> {-1, -1, -1, -1, -1, -1}, "VariableScaling" -> 
        <|x0 -> -1, x1 -> -1, x2 -> -1, x3 -> -1, x4 -> -1, x5 -> -1|>, 
       "WSL" -> -3, "WHR" -> -2, "FSLWeight" -> -3, 
       "PostCancellationLeadingWeight" -> -2, "HierarchyGapPostLPminusFSL" -> 
        1, "HiddenDominatesPostCancellationLPQ" -> True, 
       "VariablesCoveredByFSLAtWSL" -> {x0, x1, x2, x3, x4, x5}, 
       "VariablesInPostCancellationLeadingSupport" -> {x0, x1, x2, x3, x4, 
         x5}, "VariablesCoveredByLeadingRegionMonomials" -> 
        {x0, x1, x2, x3, x4, x5}, 
       "VariablesMissingFromLeadingRegionCoverage" -> {}, 
       "LeadingRegionCoverageQ" -> True|>, "CoverageChoiceCount" -> 1, 
     "LPCheckCount" -> 1, "FSLFaceIndicesUnitGap" -> {1, 2, 3, 4, 5, 6}, 
     "PostFaceChoiceIndicesUnitGap" -> {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 
       12, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29}, 
     "VariableScaling" -> <|x0 -> -1, x1 -> -1, x2 -> -1, x3 -> -1, x4 -> -1, 
       x5 -> -1|>, "RationalVariableScaling" -> <|x0 -> -1, x1 -> -1, 
       x2 -> -1, x3 -> -1, x4 -> -1, x5 -> -1|>, 
     "RationalVariableScalingWithUnitGap" -> <|x0 -> -1, x1 -> -1, x2 -> -1, 
       x3 -> -1, x4 -> -1, x5 -> -1|>, "FSLWeightPrimitive" -> -3, 
     "PostCancellationLeadingWeightPrimitive" -> -2, 
     "HierarchyGapPostLPminusFSL" -> 1, "FSLWeightUnitGap" -> -3, 
     "PostCancellationLeadingWeightUnitGap" -> -2, "FSLExponentRows" -> {{1, 
      0, 1, 0, 0, 1}, {1, 0, 0, 1, 1, 0}, {1, 0, 0, 1, 0, 1}, {0, 1, 1, 0, 1, 
      0}, {0, 1, 1, 0, 0, 1}, {0, 1, 0, 1, 1, 0}}, 
     "FSLLeadingExponentRows" -> {{1, 0, 1, 0, 0, 1}, {1, 0, 0, 1, 1, 0}, {1, 
      0, 0, 1, 0, 1}, {0, 1, 1, 0, 1, 0}, {0, 1, 1, 0, 0, 1}, {0, 1, 0, 1, 1, 
      0}}, "FSLHigherLayerExponentRows" -> {}, 
     "PostCancellationExponentRowCount" -> 29, 
     "PostCancellationLeadingRows" -> {<|"Row" -> {1, 0, 1, 0, 0, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {1, 0, 0, 1, 0, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {1, 0, 0, 0, 1, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {1, 0, 0, 0, 0, 1}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 1, 1, 0, 0, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 1, 0, 1, 0, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 1, 0, 0, 1, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 1, 0, 0, 0, 1}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 0, 1, 0, 1, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 0, 1, 0, 0, 1}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 0, 0, 1, 1, 0}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {0, 0, 0, 1, 0, 1}, 
        "Power" -> 0, "Source" -> "U"|>, <|"Row" -> {1, 1, 1, 0, 0, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {1, 1, 0, 1, 0, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {1, 1, 0, 0, 1, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {1, 1, 0, 0, 0, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {1, 0, 1, 1, 0, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {1, 0, 1, 0, 1, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {1, 0, 0, 0, 1, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 1, 1, 1, 0, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 1, 1, 0, 1, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 1, 1, 0, 0, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 1, 0, 1, 0, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 1, 0, 0, 1, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 0, 1, 1, 1, 0}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 0, 1, 1, 0, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 0, 1, 0, 1, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>, <|"Row" -> {0, 0, 0, 1, 1, 1}, 
        "Power" -> 1, "Source" -> "FDelta"|>}, 
     "PostCancellationLeadingPowers" -> {0, 1}, 
     "PostCancellationLeadingSources" -> {{"U", 12}, {"FDelta", 16}}, 
     "VariablesCoveredByFSLAtWSL" -> {x0, x1, x2, x3, x4, x5}, 
     "VariablesInPostCancellationLeadingSupport" -> {x0, x1, x2, x3, x4, x5}, 
     "VariablesCoveredByLeadingRegionMonomials" -> {x0, x1, x2, x3, x4, x5}, 
     "VariablesMissingFromLeadingRegionCoverage" -> {}, 
     "LeadingRegionCoverageQ" -> True, "Criteria" -> 
      <|"FSLCancellation" -> "a nontrivial lower face of F_SL has weight \
W_SL; every remaining F_SL monomial lies at or above W_HR", 
       "HiddenHierarchy" -> "W_HR>W_SL", "PostFace" -> 
        "U, F_obs, and higher F_SL layers have weight at least W_HR", 
       "Coverage" -> "active variables occur on the W_SL or W_HR layers", 
       "Sign" -> "NonPositive"|>|>, "ValidScalingQ" -> True, 
   "HiddenRegionQ" -> True, "ExactReductionQ" -> False|>|>
