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
   "Variables" -> {x0, x1, x2, x3, x4, x5}|>, "Mode" -> "Adaptive", 
 "Scan" -> <|"CancellationFactors" -> {s23*x3*x4 + s34*x2*x5 + s15*x3*x5, 
     s12*x2*x4 + s23*x2*x4 - s45*x2*x4 - s45*x3*x4 + s12*x2*x5 + s15*x2*x5 - 
      s34*x2*x5, s12*x1*x4 + s23*x1*x4 - s45*x1*x4 - s34*x0*x5 + s12*x1*x5 + 
      s15*x1*x5 - s34*x1*x5, s23*x0*x4 + s45*x1*x4 + s15*x0*x5, 
     s12*x1*x2 + s23*x1*x2 - s45*x1*x2 - s23*x0*x3 - s45*x1*x3, 
     s34*x0*x2 - s12*x1*x2 - s15*x1*x2 + s34*x1*x2 + s15*x0*x3}, 
   "AppearsInDerivatives" -> <|s23*x3*x4 + s34*x2*x5 + s15*x3*x5 -> {x0}, 
     s12*x2*x4 + s23*x2*x4 - s45*x2*x4 - s45*x3*x4 + s12*x2*x5 + s15*x2*x5 - 
       s34*x2*x5 -> {x1}, s12*x1*x4 + s23*x1*x4 - s45*x1*x4 - s34*x0*x5 + 
       s12*x1*x5 + s15*x1*x5 - s34*x1*x5 -> {x2}, 
     s23*x0*x4 + s45*x1*x4 + s15*x0*x5 -> {x3}, 
     s12*x1*x2 + s23*x1*x2 - s45*x1*x2 - s23*x0*x3 - s45*x1*x3 -> {x4}, 
     s34*x0*x2 - s12*x1*x2 - s15*x1*x2 + s34*x1*x2 + s15*x0*x3 -> {x5}|>, 
   "ActiveVars" -> {x0, x1, x2, x3, x4, x5}, 
   "KinVars" -> {s12, s23, s34, s45, s15}, "CandidateGeneratorSets" -> {}, 
   "CandidateGeneratorCount" -> 0, "CompletedGeneratorCount" -> 0, 
   "CompletedGeneratorSets" -> {}, "CompletedCancellationFactors" -> {}, 
   "CompletedGeneratorRows" -> {}, "CandidateGeneratorSetLimit" -> Infinity, 
   "CandidateGeneratorSetLimitReachedQ" -> False, 
   "EffectiveSearchConfiguration" -> <|"CandidateGeneratorSetLimit" -> 
      Infinity, "MaxTwoGeneratorUnionTrials" -> Infinity, 
     "PolynomialMaxMonomials" -> Automatic, "EnableSignedMonomialPairs" -> 
      False, "KinDomainFindInstanceTimeLimit" -> 5, 
     "ObstructionFindInstanceTimeLimit" -> 20, "MaxGenerators" -> 2, 
     "MaxProductSubsetSize" -> 3, "MaxScalingAbs" -> 5, 
     "CoverageScalingMethod" -> "ExactCoverage", "StopOnFirstAdmissible" -> 
      False|>, "GeneratorConstructionAudit" -> 
    <|"PairGeneratorCountBeforeLimit" -> 15, "PairGeneratorCountUsed" -> 15, 
     "PairGeneratorLimitReachedQ" -> False, "TwoGeneratorUnionCountUsed" -> 
      0, "MaxTwoGeneratorUnionTrials" -> Infinity, 
     "TwoGeneratorUnionLimitReachedQ" -> False, 
     "CandidateGeneratorSetLimit" -> Infinity, 
     "CandidateGeneratorSetLimitReachedQ" -> False, 
     "SearchTruncatedQ" -> False|>, "PolynomialFactorHarvestAudit" -> 
    <|"Mode" -> "Polynomial", "RawCount" -> 6, "EffectiveMaxMonomials" -> 3, 
     "AcceptedCount" -> 6, "PreNormalizeAcceptedCount" -> 6, 
     "RejectedCount" -> 0, "AuditRows" -> 
      {<|"Factor" -> s23*x3*x4 + s34*x2*x5 + s15*x3*x5, 
        "Class" -> "polynomial mixed-sign", "MonomialCount" -> 3, 
        "MixedSignQ" -> True, "ContainsKinVarsQ" -> True, 
        "KinFreePoolRequiredQ" -> False, 
        "KinematicDomainDecisionUnresolvedQ" -> False, 
        "PositiveZeroMethod" -> "FindInstanceWitness", "AcceptedQ" -> True, 
        "RejectReason" -> "--"|>, <|"Factor" -> s12*x2*x4 + s23*x2*x4 - 
          s45*x2*x4 - s45*x3*x4 + s12*x2*x5 + s15*x2*x5 - s34*x2*x5, 
        "Class" -> "polynomial mixed-sign", "MonomialCount" -> 3, 
        "MixedSignQ" -> True, "ContainsKinVarsQ" -> True, 
        "KinFreePoolRequiredQ" -> False, 
        "KinematicDomainDecisionUnresolvedQ" -> False, 
        "PositiveZeroMethod" -> "FindInstanceWitness", "AcceptedQ" -> True, 
        "RejectReason" -> "--"|>, <|"Factor" -> s12*x1*x4 + s23*x1*x4 - 
          s45*x1*x4 - s34*x0*x5 + s12*x1*x5 + s15*x1*x5 - s34*x1*x5, 
        "Class" -> "polynomial mixed-sign", "MonomialCount" -> 3, 
        "MixedSignQ" -> True, "ContainsKinVarsQ" -> True, 
        "KinFreePoolRequiredQ" -> False, 
        "KinematicDomainDecisionUnresolvedQ" -> False, 
        "PositiveZeroMethod" -> "FindInstanceWitness", "AcceptedQ" -> True, 
        "RejectReason" -> "--"|>, <|"Factor" -> s23*x0*x4 + s45*x1*x4 + 
          s15*x0*x5, "Class" -> "polynomial mixed-sign", 
        "MonomialCount" -> 3, "MixedSignQ" -> True, "ContainsKinVarsQ" -> 
         True, "KinFreePoolRequiredQ" -> False, 
        "KinematicDomainDecisionUnresolvedQ" -> False, 
        "PositiveZeroMethod" -> "FindInstanceWitness", "AcceptedQ" -> True, 
        "RejectReason" -> "--"|>, <|"Factor" -> s12*x1*x2 + s23*x1*x2 - 
          s45*x1*x2 - s23*x0*x3 - s45*x1*x3, "Class" -> 
         "polynomial mixed-sign", "MonomialCount" -> 3, "MixedSignQ" -> True, 
        "ContainsKinVarsQ" -> True, "KinFreePoolRequiredQ" -> False, 
        "KinematicDomainDecisionUnresolvedQ" -> False, 
        "PositiveZeroMethod" -> "FindInstanceWitness", "AcceptedQ" -> True, 
        "RejectReason" -> "--"|>, <|"Factor" -> s34*x0*x2 - s12*x1*x2 - 
          s15*x1*x2 + s34*x1*x2 + s15*x0*x3, "Class" -> 
         "polynomial mixed-sign", "MonomialCount" -> 3, "MixedSignQ" -> True, 
        "ContainsKinVarsQ" -> True, "KinFreePoolRequiredQ" -> False, 
        "KinematicDomainDecisionUnresolvedQ" -> False, 
        "PositiveZeroMethod" -> "FindInstanceWitness", "AcceptedQ" -> True, 
        "RejectReason" -> "--"|>}, "SourceCounts" -> 
      <|"Factorization" -> 6, "WholeDerivatives" -> 0, 
       "CompleteChannelPolynomials" -> 0, "SignedMonomialPairs" -> 0|>, 
     "UnresolvedKinematicDomainDecisionCount" -> 0|>, 
   "PolynomialMaxMonomialsLimitReachedQ" -> False, 
   "UnresolvedPositivityCount" -> 0, 
   "UnresolvedKinematicDomainDecisionCount" -> 0, 
   "SearchTruncatedQ" -> False, "CandidateGeneratorFactorData" -> {}, 
   "GeneratorDegreeBounds" -> <|"MaxGeneratorTotalDegree" -> 3, 
     "MaxGeneratorVarExponent" -> 1, "FTotalDegree" -> 3, "LoopOrder" -> 2, 
     "FMaxVarExponent" -> 1, "InferredKinematicType" -> "Massless", 
     "RelaxSingleProductDegreeQ" -> False, "SkipPDFFindInstanceQ" -> False|>, 
   "DegreeFilteredGeneratorFactorCount" -> 0, 
   "DegreeAdmissibleGeneratorFactors" -> {s23*x3*x4 + s34*x2*x5 + s15*x3*x5, 
     s12*x2*x4 + s23*x2*x4 - s45*x2*x4 - s45*x3*x4 + s12*x2*x5 + s15*x2*x5 - 
      s34*x2*x5, s12*x1*x4 + s23*x1*x4 - s45*x1*x4 - s34*x0*x5 + s12*x1*x5 + 
      s15*x1*x5 - s34*x1*x5, s23*x0*x4 + s45*x1*x4 + s15*x0*x5, 
     s12*x1*x2 + s23*x1*x2 - s45*x1*x2 - s23*x0*x3 - s45*x1*x3, 
     s34*x0*x2 - s12*x1*x2 - s15*x1*x2 + s34*x1*x2 + s15*x0*x3}, 
   "AdmissibleCandidateGeneratorSetQ" -> False, 
   "AdmissibleCandidateGeneratorSets" -> {}, 
   "AdmissibleCandidateGeneratorFactorData" -> {}, 
   "AdmissibleCandidateGeneratorSetFactorUnions" -> {}, 
   "ObstructionAttemptData" -> {}, "ObstructionAttemptSummary" -> 
    <|"TrialCount" -> 0, "CandidateGeneratorCount" -> 0, 
     "PerGeneratorAdmissibleCount" -> 0, 
     "CandidateUnionPDFAdmissibleCount" -> 0, 
     "ObstructionFindInstanceCount" -> 0, "AdmissibleSLSectorCount" -> 0, 
     "ValidObstructionCount" -> 0, "HiddenRegionWithValidScalingCount" -> 0, 
     "ScalingEvaluatedOnValidTrialsQ" -> False, "GeneratorCountHistogram" -> 
      <||>, "StopOnFirstValidObstructionQ" -> False, 
     "StoppedEarlyOnValidObstructionQ" -> False|>, 
   "AdmissibleObstructionAttemptData" -> {}, 
   "AcceptedObstructionAttemptData" -> <||>, "ObstructionAttemptCount" -> 0, 
   "AllCandidateGeneratorSetsTriedQ" -> True, "ObstructionSearchCompleteQ" -> 
    True, "HiddenRegionSearchCompleteQ" -> True, 
   "ValidObstructionTrialCount" -> 0, "NoObstructionWithinSearchBoundsQ" -> 
    True, "NoHiddenRegionWithinSearchBoundsQ" -> True, 
   "StoreAllObstructionTrialsQ" -> True, "Generators" -> {}, 
   "GeneratorFactorData" -> {}, "GeneratorSetFactorUnion" -> {}, 
   "GeneratorSetFactorCount" -> 0, "PerGeneratorAdmissibleQ" -> False, 
   "SimultaneouslyAdmissibleGeneratorSetQ" -> False, 
   "SLSectorGenerators" -> {}, "SLSectorFactorUnion" -> {}, 
   "SLSectorFactorCount" -> 0, "SimultaneouslyAdmissibleSLSectorQ" -> False, 
   "AdmissibleSLSectorQ" -> False, "AdmissibleGeneratorSetQ" -> False, 
   "AcceptedObstructionGeneratorSetQ" -> False, "HiddenRegionQ" -> False, 
   "HiddenRegionCount" -> 0, "HiddenRegionScans" -> {}, 
   "ValidTrialScalingEvaluations" -> {}, "GeneratorSetScalingSummary" -> {}, 
   "CoverageScalingData" -> Missing["NotEvaluated"], 
   "ObstructionData" -> Missing["NoObstructionFound", Automatic], 
   "GeneratorUseData" -> Missing["NoUseData"], "GeneratorAdmissibility" -> "P\
er-generator PDF (5.12) at candidate stage; cross-generator PDF (5.12) \
enforced only after F_SL is confirmed"|>|>
