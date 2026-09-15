(* Created with the Wolfram Language : www.wolfram.com *)
<|"GeneratedOn" -> "2026-09-12T10:27:25", "GraphKey" -> "nonplanar-hexbox", 
 "GraphDisplayName" -> 
  "same-path hexagon--pentagon (legacy key nonplanar-hexbox)", 
 "Implementation" -> <|"Core" -> "HiddenRegionFinder.wl", 
   "Alignment" -> "HRF_AsymptoticOrderAlignment.wl", 
   "Dissection" -> "HRF_SourceAwareDissectionCertification.wl", 
   "DissectionEntryPoint" -> "hrfSourceAwareAlignedDissectionCertificate", 
   "Options" -> {"MaxPivotChoices" -> 64, "MaxSolveBranches" -> 16, 
     "MaxSignSectors" -> 64, "MaxPointCount" -> 20000, 
     "SolveTimeLimit" -> 60, "CDDTimeLimit" -> 120}|>, 
 "Summary" -> <|"StagedCandidateCount" -> 8, 
   "CandidatesWithAtLeastOneCertificate" -> 4, 
   "CandidatesWithCompleteSearch" -> 8, "AllCandidateSearchesCompleteQ" -> 
    True, "AllCertificatesScalefulQ" -> True, "RawCertificateCount" -> 9, 
   "DistinctPullbackVectorCount" -> 9, 
   "InteriorDistinctPullbackVectorCount" -> 3, 
   "CodimensionOneDistinctPullbackVectorCount" -> 6, 
   "VectorClassesWithMultiplePresentations" -> 0, 
   "DistinctPhysicalHRCount" -> 9, "InteriorPhysicalHRCount" -> 3, 
   "CodimensionOnePhysicalHRCount" -> 6, "DistinctCancellationFactorCount" -> 
    18, "DistinctGeneratorCount" -> 6, 
   "PullbackVectorsSharedAcrossGeneratorFamilies" -> 0, 
   "BoundaryVectorsWithInteriorExtension" -> 0, 
   "BoundaryVectorsWithoutInteriorExtension" -> 6, 
   "StrictCertificatePresentationCount" -> 9, 
   "DistinctPinchIdealAndWeightRegionCount" -> 9, 
   "InteriorCertifiedRegionCount" -> 3, 
   "CodimensionOneCertifiedRegionCount" -> 6, 
   "RegionClassesWithMultiplePresentations" -> 0, "PreviousTableCount" -> 3, 
   "PreviousTableInteriorCount" -> 1, "PreviousTableBoundaryCount" -> 2, 
   "CountAgreesWithPreviousTableQ" -> False|>, 
 "Candidates" -> {<|"candidate" -> 1, "boundary" -> {x7}, 
    "face scaling" -> {-2, -1, -2, -2, -1, -2, -1, 0, -1}, 
    "cancellation factors" -> {Kz*x1*x3*X56h - x2*X34h*x6 - x3*X34h*x6 - 
       x2*X34h*X45*x6 + Kz*x1*X34h*X45*X56h*x6, x0*x3 + x3*x5 + 
       x0*X34h*X45*x6 - X34h*X45*x5*x8, x0*x6 - x5*x8, 
      -(Kz*x0*x1*X56h) - Kz*x1*x5*X56h + x0*X34h*x6 - X34h*x5*x8, 
      -(Kz*x1*x3*X56h) - x2*X34h*x8 - x3*X34h*x8 - x2*X34h*X45*x8 + 
       Kz*x1*X34h*X45*X56h*x8, -x2 - x3 - x2*X45 + Kz*x1*X45*X56h}, 
    "old status" -> "ResolvedWHRFaceNotFacet", "old rank/required" -> {6, 8}, 
    "old gap" -> 1, "positive-pinch obstruction" -> Kz*x1*x3*X56h, 
    "certified facets" -> 0, "complete search" -> True, 
    "all returned facets scaleful" -> False|>, <|"candidate" -> 2, 
    "boundary" -> {}, "face scaling" -> {-2, -1, -2, -1, -2, -2, -2, 0, -2}, 
    "cancellation factors" -> {-x2 - x2*X45 + Kz*x1*X45*X56h, x0*x6 - x5*x8}, 
    "old status" -> "ResolvedWHRFaceNotFacet", "old rank/required" -> {8, 9}, 
    "old gap" -> 1, "positive-pinch obstruction" -> Missing[], 
    "certified facets" -> 2, "complete search" -> True, 
    "all returned facets scaleful" -> True|>, <|"candidate" -> 3, 
    "boundary" -> {}, "face scaling" -> {-2, -1, -2, -1, -1, -1, -1, 0, -2}, 
    "cancellation factors" -> {-(x2*X34h*x6) - x2*X34h*X45*x6 + 
       Kz*x1*X34h*X45*X56h*x6 + Kz*x2*x8, x0*x6 - x5*x8, 
      x0*X34h*x6 + x0*X34h*X45*x6 - Kz*x0*x8 - X34h*x5*x8 - X34h*X45*x5*x8, 
      -x2 - x2*X45 + Kz*x1*X45*X56h, -(Kz*x0*x2) - x2*X34h*x5 - 
       x2*X34h*X45*x5 + Kz*x1*X34h*X45*x5*X56h}, 
    "old status" -> "NoHiddenHierarchy", "old rank/required" -> {4, 9}, 
    "old gap" -> 0, "positive-pinch obstruction" -> Kz*x5*x8^2, 
    "certified facets" -> 0, "complete search" -> True, 
    "all returned facets scaleful" -> False|>, <|"candidate" -> 4, 
    "boundary" -> {}, "face scaling" -> {-2, -1, -1, -2, -2, -2, -2, 0, -2}, 
    "cancellation factors" -> {-x3 + Kz*x1*X45*X56h, x0*x6 - x5*x8}, 
    "old status" -> "ResolvedWHRFaceNotFacet", "old rank/required" -> {8, 9}, 
    "old gap" -> 1, "positive-pinch obstruction" -> Missing[], 
    "certified facets" -> 0, "complete search" -> True, 
    "all returned facets scaleful" -> False|>, <|"candidate" -> 5, 
    "boundary" -> {x7}, "face scaling" -> {-1, -1, -2, -1, -2, -2, -1, 0, 
      -1}, "cancellation factors" -> {-x4 - x4*X45 + X34h*X45*x8, 
      -x2 - x2*X45 + Kz*x1*X45*X56h}, "old status" -> "AcceptedLowerFacet", 
    "old rank/required" -> {8, 8}, "old gap" -> 1, 
    "positive-pinch obstruction" -> Missing[], "certified facets" -> 4, 
    "complete search" -> True, "all returned facets scaleful" -> True|>, 
   <|"candidate" -> 6, "boundary" -> {}, "face scaling" -> 
     {-1, -1, -2, -1, -2, -1, -1, 0, -2}, "cancellation factors" -> 
     {-x4 - x4*X45 + X34h*X45*x5, -x2 - x2*X45 + Kz*x1*X45*X56h}, 
    "old status" -> "AcceptedLowerFacet", "old rank/required" -> {9, 9}, 
    "old gap" -> 1, "positive-pinch obstruction" -> Missing[], 
    "certified facets" -> 1, "complete search" -> True, 
    "all returned facets scaleful" -> True|>, <|"candidate" -> 7, 
    "boundary" -> {x7}, "face scaling" -> {-1, -1, -2, -2, -1, -1, -2, 0, 
      -2}, "cancellation factors" -> {-x2 - x3 - x2*X45 + Kz*x1*X45*X56h, 
      x3*x6 + x0*X34h*X45*x6 + x3*x8 - X34h*X45*x5*x8, x0*x6 - x5*x8, 
      x0*X34h*x6 - Kz*x1*X56h*x6 - X34h*x5*x8 - Kz*x1*X56h*x8, 
      -(x0*x2*X34h) - x0*x3*X34h - x0*x2*X34h*X45 + Kz*x1*x3*X56h + 
       Kz*x0*x1*X34h*X45*X56h, -(x2*X34h*x5) - x3*X34h*x5 - x2*X34h*X45*x5 - 
       Kz*x1*x3*X56h + Kz*x1*X34h*X45*x5*X56h}, 
    "old status" -> "ResolvedWHRFaceNotFacet", "old rank/required" -> {6, 8}, 
    "old gap" -> 1, "positive-pinch obstruction" -> Kz*x1*x3*X56h, 
    "certified facets" -> 0, "complete search" -> True, 
    "all returned facets scaleful" -> False|>, <|"candidate" -> 8, 
    "boundary" -> {x7}, "face scaling" -> {0, -1, -2, -1, -1, -2, -2, 0, -1}, 
    "cancellation factors" -> {-x6 - X45*x6 + X34h*X45*x8, 
      -x2 - x2*X45 + Kz*x1*X45*X56h}, "old status" -> "AcceptedLowerFacet", 
    "old rank/required" -> {8, 8}, "old gap" -> 1, 
    "positive-pinch obstruction" -> Missing[], "certified facets" -> 2, 
    "complete search" -> True, "all returned facets scaleful" -> True|>}, 
 "Certificates" -> {<|"Candidate" -> 2, "LocalFacet" -> 1, 
    "BoundaryZeroVariables" -> {}, "PullbackVector" -> 
     {-4, -3, -4, -4, -6, -6, -6, 0, -4}, "WSL" -> -13, "WHR" -> -12, 
    "CancellationDepth" -> 1, "TransverseSuppressions" -> 
     <|-x2 - x2*X45 + Kz*x1*X45*X56h -> 2, x0*x6 - x5*x8 -> 1|>, 
    "LeadingFacetSourceCounts" -> <|"U" -> 3, "FOutside" -> 14|>, 
    "ScalefulQ" -> True|>, <|"Candidate" -> 2, "LocalFacet" -> 2, 
    "BoundaryZeroVariables" -> {}, "PullbackVector" -> 
     {-4, -3, -4, -3, -4, -5, -5, 0, -4}, "WSL" -> -12, "WHR" -> -10, 
    "CancellationDepth" -> 2, "TransverseSuppressions" -> 
     <|-x2 - x2*X45 + Kz*x1*X45*X56h -> 2, x0*x6 - x5*x8 -> 1|>, 
    "LeadingFacetSourceCounts" -> <|"U" -> 1, "FOutside" -> 10|>, 
    "ScalefulQ" -> True|>, <|"Candidate" -> 5, "LocalFacet" -> 1, 
    "BoundaryZeroVariables" -> {x7}, "PullbackVector" -> 
     {-4, -5, -6, -2, -6, -7, -4, "boundary", -5}, "WSL" -> -17, 
    "WHR" -> -13, "CancellationDepth" -> 4, "TransverseSuppressions" -> 
     <|-x4 - x4*X45 + X34h*X45*x8 -> 2, -x2 - x2*X45 + Kz*x1*X45*X56h -> 2|>, 
    "LeadingFacetSourceCounts" -> <|"FOutside" -> 11, "FSL" -> 1, "U" -> 2|>, 
    "ScalefulQ" -> True|>, <|"Candidate" -> 5, "LocalFacet" -> 2, 
    "BoundaryZeroVariables" -> {x7}, "PullbackVector" -> 
     {-4, -4, -5, -2, -5, -6, -3, "boundary", -4}, "WSL" -> -14, 
    "WHR" -> -11, "CancellationDepth" -> 3, "TransverseSuppressions" -> 
     <|-x4 - x4*X45 + X34h*X45*x8 -> 2, -x2 - x2*X45 + Kz*x1*X45*X56h -> 1|>, 
    "LeadingFacetSourceCounts" -> <|"FOutside" -> 8, "FSL" -> 1, "U" -> 2|>, 
    "ScalefulQ" -> True|>, <|"Candidate" -> 5, "LocalFacet" -> 3, 
    "BoundaryZeroVariables" -> {x7}, "PullbackVector" -> 
     {-3, -4, -5, -2, -5, -5, -4, "boundary", -4}, "WSL" -> -13, 
    "WHR" -> -10, "CancellationDepth" -> 3, "TransverseSuppressions" -> 
     <|-x4 - x4*X45 + X34h*X45*x8 -> 1, -x2 - x2*X45 + Kz*x1*X45*X56h -> 2|>, 
    "LeadingFacetSourceCounts" -> <|"FOutside" -> 11, "FSL" -> 1, "U" -> 2|>, 
    "ScalefulQ" -> True|>, <|"Candidate" -> 5, "LocalFacet" -> 4, 
    "BoundaryZeroVariables" -> {x7}, "PullbackVector" -> 
     {-3, -3, -4, -2, -4, -4, -3, "boundary", -3}, "WSL" -> -10, "WHR" -> -8, 
    "CancellationDepth" -> 2, "TransverseSuppressions" -> 
     <|-x4 - x4*X45 + X34h*X45*x8 -> 1, -x2 - x2*X45 + Kz*x1*X45*X56h -> 1|>, 
    "LeadingFacetSourceCounts" -> <|"FOutside" -> 9, "FSL" -> 1, "U" -> 2|>, 
    "ScalefulQ" -> True|>, <|"Candidate" -> 6, "LocalFacet" -> 1, 
    "BoundaryZeroVariables" -> {}, "PullbackVector" -> 
     {-2, -5, -6, -2, -6, -5, -5, -2, -7}, "WSL" -> -17, "WHR" -> -13, 
    "CancellationDepth" -> 4, "TransverseSuppressions" -> 
     <|-x4 - x4*X45 + X34h*X45*x5 -> 2, -x2 - x2*X45 + Kz*x1*X45*X56h -> 2|>, 
    "LeadingFacetSourceCounts" -> <|"FSL" -> 1, "U" -> 2, "FOutside" -> 15|>, 
    "ScalefulQ" -> True|>, <|"Candidate" -> 8, "LocalFacet" -> 1, 
    "BoundaryZeroVariables" -> {x7}, "PullbackVector" -> 
     {-5, -5, -6, -2, -6, -8, -8, "boundary", -7}, "WSL" -> -20, 
    "WHR" -> -16, "CancellationDepth" -> 4, "TransverseSuppressions" -> 
     <|-x6 - X45*x6 + X34h*X45*x8 -> 2, -x2 - x2*X45 + Kz*x1*X45*X56h -> 2|>, 
    "LeadingFacetSourceCounts" -> <|"FSL" -> 1, "U" -> 1, "FOutside" -> 11|>, 
    "ScalefulQ" -> True|>, <|"Candidate" -> 8, "LocalFacet" -> 2, 
    "BoundaryZeroVariables" -> {x7}, "PullbackVector" -> 
     {-3, -5, -6, -2, -4, -6, -6, "boundary", -5}, "WSL" -> -16, 
    "WHR" -> -12, "CancellationDepth" -> 4, "TransverseSuppressions" -> 
     <|-x6 - X45*x6 + X34h*X45*x8 -> 2, -x2 - x2*X45 + Kz*x1*X45*X56h -> 2|>, 
    "LeadingFacetSourceCounts" -> <|"FSL" -> 1, "U" -> 3, "FOutside" -> 12|>, 
    "ScalefulQ" -> True|>}, "CancellationFactorClasses" -> 
  {<|"FactorFamily" -> 1, "CancellationFactor" -> 
     Kz*x1*x3*X56h - x2*X34h*x6 - x3*X34h*x6 - x2*X34h*X45*x6 + 
      Kz*x1*X34h*X45*X56h*x6, "Candidates" -> {1}|>, 
   <|"FactorFamily" -> 2, "CancellationFactor" -> 
     x0*x3 + x3*x5 + x0*X34h*X45*x6 - X34h*X45*x5*x8, "Candidates" -> {1}|>, 
   <|"FactorFamily" -> 3, "CancellationFactor" -> x0*x6 - x5*x8, 
    "Candidates" -> {1, 2, 3, 4, 7}|>, <|"FactorFamily" -> 4, 
    "CancellationFactor" -> -(Kz*x0*x1*X56h) - Kz*x1*x5*X56h + x0*X34h*x6 - 
      X34h*x5*x8, "Candidates" -> {1}|>, <|"FactorFamily" -> 5, 
    "CancellationFactor" -> -(Kz*x1*x3*X56h) - x2*X34h*x8 - x3*X34h*x8 - 
      x2*X34h*X45*x8 + Kz*x1*X34h*X45*X56h*x8, "Candidates" -> {1}|>, 
   <|"FactorFamily" -> 6, "CancellationFactor" -> -x2 - x3 - x2*X45 + 
      Kz*x1*X45*X56h, "Candidates" -> {1, 7}|>, <|"FactorFamily" -> 7, 
    "CancellationFactor" -> -x2 - x2*X45 + Kz*x1*X45*X56h, 
    "Candidates" -> {2, 3, 5, 6, 8}|>, <|"FactorFamily" -> 8, 
    "CancellationFactor" -> -(x2*X34h*x6) - x2*X34h*X45*x6 + 
      Kz*x1*X34h*X45*X56h*x6 + Kz*x2*x8, "Candidates" -> {3}|>, 
   <|"FactorFamily" -> 9, "CancellationFactor" -> 
     x0*X34h*x6 + x0*X34h*X45*x6 - Kz*x0*x8 - X34h*x5*x8 - X34h*X45*x5*x8, 
    "Candidates" -> {3}|>, <|"FactorFamily" -> 10, 
    "CancellationFactor" -> -(Kz*x0*x2) - x2*X34h*x5 - x2*X34h*X45*x5 + 
      Kz*x1*X34h*X45*x5*X56h, "Candidates" -> {3}|>, 
   <|"FactorFamily" -> 11, "CancellationFactor" -> -x3 + Kz*x1*X45*X56h, 
    "Candidates" -> {4}|>, <|"FactorFamily" -> 12, 
    "CancellationFactor" -> -x4 - x4*X45 + X34h*X45*x8, 
    "Candidates" -> {5}|>, <|"FactorFamily" -> 13, 
    "CancellationFactor" -> -x4 - x4*X45 + X34h*X45*x5, 
    "Candidates" -> {6}|>, <|"FactorFamily" -> 14, 
    "CancellationFactor" -> x3*x6 + x0*X34h*X45*x6 + x3*x8 - X34h*X45*x5*x8, 
    "Candidates" -> {7}|>, <|"FactorFamily" -> 15, 
    "CancellationFactor" -> x0*X34h*x6 - Kz*x1*X56h*x6 - X34h*x5*x8 - 
      Kz*x1*X56h*x8, "Candidates" -> {7}|>, <|"FactorFamily" -> 16, 
    "CancellationFactor" -> -(x0*x2*X34h) - x0*x3*X34h - x0*x2*X34h*X45 + 
      Kz*x1*x3*X56h + Kz*x0*x1*X34h*X45*X56h, "Candidates" -> {7}|>, 
   <|"FactorFamily" -> 17, "CancellationFactor" -> 
     -(x2*X34h*x5) - x3*X34h*x5 - x2*X34h*X45*x5 - Kz*x1*x3*X56h + 
      Kz*x1*X34h*X45*x5*X56h, "Candidates" -> {7}|>, 
   <|"FactorFamily" -> 18, "CancellationFactor" -> 
     -x6 - X45*x6 + X34h*X45*x8, "Candidates" -> {8}|>}, 
 "GeneratorClasses" -> {<|"GeneratorFamily" -> 1, "CancellationFactorPair" -> 
     {Kz*x1*x3*X56h - x2*X34h*x6 - x3*X34h*x6 - x2*X34h*X45*x6 + 
       Kz*x1*X34h*X45*X56h*x6, x0*x3 + x3*x5 + x0*X34h*X45*x6 - 
       X34h*X45*x5*x8, x0*x6 - x5*x8, -(Kz*x0*x1*X56h) - Kz*x1*x5*X56h + 
       x0*X34h*x6 - X34h*x5*x8, -(Kz*x1*x3*X56h) - x2*X34h*x8 - x3*X34h*x8 - 
       x2*X34h*X45*x8 + Kz*x1*X34h*X45*X56h*x8, -x2 - x3 - x2*X45 + 
       Kz*x1*X45*X56h}, "Generator" -> -((x2 + x3 + x2*X45 - Kz*x1*X45*X56h)*
       (x0*x6 - x5*x8)), "Candidates" -> {1, 7}, "DistinctPullbackVectors" -> 
     0, "InteriorVectors" -> 0, "CodimensionOneVectors" -> 0|>, 
   <|"GeneratorFamily" -> 2, "CancellationFactorPair" -> 
     {-x2 - x2*X45 + Kz*x1*X45*X56h, x0*x6 - x5*x8}, 
    "Generator" -> -((x2 + x2*X45 - Kz*x1*X45*X56h)*(x0*x6 - x5*x8)), 
    "Candidates" -> {2, 3}, "DistinctPullbackVectors" -> 2, 
    "InteriorVectors" -> 2, "CodimensionOneVectors" -> 0|>, 
   <|"GeneratorFamily" -> 3, "CancellationFactorPair" -> 
     {-x3 + Kz*x1*X45*X56h, x0*x6 - x5*x8}, "Generator" -> 
     -((x3 - Kz*x1*X45*X56h)*(x0*x6 - x5*x8)), "Candidates" -> {4}, 
    "DistinctPullbackVectors" -> 0, "InteriorVectors" -> 0, 
    "CodimensionOneVectors" -> 0|>, <|"GeneratorFamily" -> 4, 
    "CancellationFactorPair" -> {-x4 - x4*X45 + X34h*X45*x8, 
      -x2 - x2*X45 + Kz*x1*X45*X56h}, "Generator" -> 
     (x2 + x2*X45 - Kz*x1*X45*X56h)*(x4 + x4*X45 - X34h*X45*x8), 
    "Candidates" -> {5}, "DistinctPullbackVectors" -> 4, 
    "InteriorVectors" -> 0, "CodimensionOneVectors" -> 4|>, 
   <|"GeneratorFamily" -> 5, "CancellationFactorPair" -> 
     {-x4 - x4*X45 + X34h*X45*x5, -x2 - x2*X45 + Kz*x1*X45*X56h}, 
    "Generator" -> (x4 + x4*X45 - X34h*X45*x5)*(x2 + x2*X45 - 
       Kz*x1*X45*X56h), "Candidates" -> {6}, "DistinctPullbackVectors" -> 1, 
    "InteriorVectors" -> 1, "CodimensionOneVectors" -> 0|>, 
   <|"GeneratorFamily" -> 6, "CancellationFactorPair" -> 
     {-x6 - X45*x6 + X34h*X45*x8, -x2 - x2*X45 + Kz*x1*X45*X56h}, 
    "Generator" -> (x2 + x2*X45 - Kz*x1*X45*X56h)*
      (x6 + X45*x6 - X34h*X45*x8), "Candidates" -> {8}, 
    "DistinctPullbackVectors" -> 2, "InteriorVectors" -> 0, 
    "CodimensionOneVectors" -> 2|>}, "BoundaryInteriorRelations" -> {}, 
 "CertifiedHRClasses" -> {<|"HR" -> 1, "BoundaryZeroVariables" -> {}, 
    "PullbackVector" -> {-4, -3, -4, -4, -6, -6, -6, 0, -4}, "WHR" -> -12, 
    "WSLPresentations" -> {-13}, "CancellationDepthPresentations" -> {1}, 
    "SourcePresentations" -> {{2, 1}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"HR" -> 2, "BoundaryZeroVariables" -> {}, 
    "PullbackVector" -> {-4, -3, -4, -3, -4, -5, -5, 0, -4}, "WHR" -> -10, 
    "WSLPresentations" -> {-12}, "CancellationDepthPresentations" -> {2}, 
    "SourcePresentations" -> {{2, 2}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"HR" -> 3, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-4, -5, -6, -2, -6, -7, -4, "boundary", -5}, 
    "WHR" -> -13, "WSLPresentations" -> {-17}, 
    "CancellationDepthPresentations" -> {4}, "SourcePresentations" -> 
     {{5, 1}}, "PresentationMultiplicity" -> 1, "ScalefulQ" -> True|>, 
   <|"HR" -> 4, "BoundaryZeroVariables" -> {x7}, "PullbackVector" -> 
     {-4, -4, -5, -2, -5, -6, -3, "boundary", -4}, "WHR" -> -11, 
    "WSLPresentations" -> {-14}, "CancellationDepthPresentations" -> {3}, 
    "SourcePresentations" -> {{5, 2}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"HR" -> 5, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-3, -4, -5, -2, -5, -5, -4, "boundary", -4}, 
    "WHR" -> -10, "WSLPresentations" -> {-13}, 
    "CancellationDepthPresentations" -> {3}, "SourcePresentations" -> 
     {{5, 3}}, "PresentationMultiplicity" -> 1, "ScalefulQ" -> True|>, 
   <|"HR" -> 6, "BoundaryZeroVariables" -> {x7}, "PullbackVector" -> 
     {-3, -3, -4, -2, -4, -4, -3, "boundary", -3}, "WHR" -> -8, 
    "WSLPresentations" -> {-10}, "CancellationDepthPresentations" -> {2}, 
    "SourcePresentations" -> {{5, 4}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"HR" -> 7, "BoundaryZeroVariables" -> {}, 
    "PullbackVector" -> {-2, -5, -6, -2, -6, -5, -5, -2, -7}, "WHR" -> -13, 
    "WSLPresentations" -> {-17}, "CancellationDepthPresentations" -> {4}, 
    "SourcePresentations" -> {{6, 1}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"HR" -> 8, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-5, -5, -6, -2, -6, -8, -8, "boundary", -7}, 
    "WHR" -> -16, "WSLPresentations" -> {-20}, 
    "CancellationDepthPresentations" -> {4}, "SourcePresentations" -> 
     {{8, 1}}, "PresentationMultiplicity" -> 1, "ScalefulQ" -> True|>, 
   <|"HR" -> 9, "BoundaryZeroVariables" -> {x7}, "PullbackVector" -> 
     {-3, -5, -6, -2, -4, -6, -6, "boundary", -5}, "WHR" -> -12, 
    "WSLPresentations" -> {-16}, "CancellationDepthPresentations" -> {4}, 
    "SourcePresentations" -> {{8, 2}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>}, "StrictCertificatePresentationClasses" -> 
  {<|"Region" -> 1, "BoundaryZeroVariables" -> {}, 
    "PullbackVector" -> {-4, -3, -4, -4, -6, -6, -6, 0, -4}, "WSL" -> -13, 
    "WHR" -> -12, "CancellationDepth" -> 1, "SourcePresentations" -> 
     {{2, 1}}, "PresentationMultiplicity" -> 1, "ScalefulQ" -> True|>, 
   <|"Region" -> 2, "BoundaryZeroVariables" -> {}, 
    "PullbackVector" -> {-4, -3, -4, -3, -4, -5, -5, 0, -4}, "WSL" -> -12, 
    "WHR" -> -10, "CancellationDepth" -> 2, "SourcePresentations" -> 
     {{2, 2}}, "PresentationMultiplicity" -> 1, "ScalefulQ" -> True|>, 
   <|"Region" -> 3, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-4, -5, -6, -2, -6, -7, -4, "boundary", -5}, 
    "WSL" -> -17, "WHR" -> -13, "CancellationDepth" -> 4, 
    "SourcePresentations" -> {{5, 1}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"Region" -> 4, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-4, -4, -5, -2, -5, -6, -3, "boundary", -4}, 
    "WSL" -> -14, "WHR" -> -11, "CancellationDepth" -> 3, 
    "SourcePresentations" -> {{5, 2}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"Region" -> 5, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-3, -4, -5, -2, -5, -5, -4, "boundary", -4}, 
    "WSL" -> -13, "WHR" -> -10, "CancellationDepth" -> 3, 
    "SourcePresentations" -> {{5, 3}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"Region" -> 6, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-3, -3, -4, -2, -4, -4, -3, "boundary", -3}, 
    "WSL" -> -10, "WHR" -> -8, "CancellationDepth" -> 2, 
    "SourcePresentations" -> {{5, 4}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"Region" -> 7, "BoundaryZeroVariables" -> {}, 
    "PullbackVector" -> {-2, -5, -6, -2, -6, -5, -5, -2, -7}, "WSL" -> -17, 
    "WHR" -> -13, "CancellationDepth" -> 4, "SourcePresentations" -> 
     {{6, 1}}, "PresentationMultiplicity" -> 1, "ScalefulQ" -> True|>, 
   <|"Region" -> 8, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-5, -5, -6, -2, -6, -8, -8, "boundary", -7}, 
    "WSL" -> -20, "WHR" -> -16, "CancellationDepth" -> 4, 
    "SourcePresentations" -> {{8, 1}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"Region" -> 9, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-3, -5, -6, -2, -4, -6, -6, "boundary", -5}, 
    "WSL" -> -16, "WHR" -> -12, "CancellationDepth" -> 4, 
    "SourcePresentations" -> {{8, 2}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>}, "PresentationSplitsWithinHRs" -> {}, 
 "CertifiedRegionClasses" -> {<|"Region" -> 1, "BoundaryZeroVariables" -> {}, 
    "PullbackVector" -> {-4, -3, -4, -4, -6, -6, -6, 0, -4}, "WSL" -> -13, 
    "WHR" -> -12, "CancellationDepth" -> 1, "SourcePresentations" -> 
     {{2, 1}}, "PresentationMultiplicity" -> 1, "ScalefulQ" -> True|>, 
   <|"Region" -> 2, "BoundaryZeroVariables" -> {}, 
    "PullbackVector" -> {-4, -3, -4, -3, -4, -5, -5, 0, -4}, "WSL" -> -12, 
    "WHR" -> -10, "CancellationDepth" -> 2, "SourcePresentations" -> 
     {{2, 2}}, "PresentationMultiplicity" -> 1, "ScalefulQ" -> True|>, 
   <|"Region" -> 3, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-4, -5, -6, -2, -6, -7, -4, "boundary", -5}, 
    "WSL" -> -17, "WHR" -> -13, "CancellationDepth" -> 4, 
    "SourcePresentations" -> {{5, 1}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"Region" -> 4, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-4, -4, -5, -2, -5, -6, -3, "boundary", -4}, 
    "WSL" -> -14, "WHR" -> -11, "CancellationDepth" -> 3, 
    "SourcePresentations" -> {{5, 2}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"Region" -> 5, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-3, -4, -5, -2, -5, -5, -4, "boundary", -4}, 
    "WSL" -> -13, "WHR" -> -10, "CancellationDepth" -> 3, 
    "SourcePresentations" -> {{5, 3}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"Region" -> 6, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-3, -3, -4, -2, -4, -4, -3, "boundary", -3}, 
    "WSL" -> -10, "WHR" -> -8, "CancellationDepth" -> 2, 
    "SourcePresentations" -> {{5, 4}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"Region" -> 7, "BoundaryZeroVariables" -> {}, 
    "PullbackVector" -> {-2, -5, -6, -2, -6, -5, -5, -2, -7}, "WSL" -> -17, 
    "WHR" -> -13, "CancellationDepth" -> 4, "SourcePresentations" -> 
     {{6, 1}}, "PresentationMultiplicity" -> 1, "ScalefulQ" -> True|>, 
   <|"Region" -> 8, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-5, -5, -6, -2, -6, -8, -8, "boundary", -7}, 
    "WSL" -> -20, "WHR" -> -16, "CancellationDepth" -> 4, 
    "SourcePresentations" -> {{8, 1}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>, <|"Region" -> 9, "BoundaryZeroVariables" -> {x7}, 
    "PullbackVector" -> {-3, -5, -6, -2, -4, -6, -6, "boundary", -5}, 
    "WSL" -> -16, "WHR" -> -12, "CancellationDepth" -> 4, 
    "SourcePresentations" -> {{8, 2}}, "PresentationMultiplicity" -> 1, 
    "ScalefulQ" -> True|>}, "RepeatedVectorClasses" -> {}|>
