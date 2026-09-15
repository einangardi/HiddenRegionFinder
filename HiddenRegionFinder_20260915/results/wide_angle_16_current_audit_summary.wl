(* Current-HRF audit summary, 2026-07-22.
   Generated from graph-derived Symanzik polynomials in 16_examples_diagrams.txt.
   Graph/polynomial construction is in HRF_WideAngle16NoCrownAudit.wl;
   the completed higher-codimension certificate is in
   HRF_WideAngle16FacePinchAudit.wl and its checkpointed runner. *)
<|
  "ThreeLoopCrownControl" -> <|
    "HiddenRegionQ" -> True,
    "HierarchyGap" -> 1,
    "MixedSignFactorCount" -> 14,
    "FactorPairCount" -> 91,
    "DisjointSupportPairCount" -> 3,
    "CandidateGeneratorCount" -> 3,
    "ValidObstructionTrialCount" -> 3
  |>,
  "FourLoop16Interior" -> <|
    "DiagramCount" -> 16,
    "PairSectorStatusCounts" -> <|"OK" -> 16|>,
    "MixedSignFactorPairCount" -> 180,
    "SimultaneouslyAdmissiblePairCount" -> 180,
    "DisjointSupportPairCount" -> 0,
    "CandidateGeneratorCount" -> 0,
    "ValidObstructionTrialCount" -> 0,
    "HiddenRegionCount" -> 0,
    "CandidateLimitReachedCount" -> 0,
    "StressModeScanCount" -> 48,
    "StressModeHiddenRegionCount" -> 0,
    "StressModes" -> {"WideAnglePairSectors", "Adaptive", "SingleProduct"}
  |>,
  "Codim3_x3_x5_x8" -> <|
    "DiagramCount" -> 16,
    "TwelvePropagatorDiagramCount" -> 4,
    "TwelvePropagatorCandidateGeneratorCount" -> 0,
    "ThirteenPropagatorDiagramCount" -> 12,
    "ThirteenPropagatorCandidateGeneratorCount" -> 20,
    "ThirteenPropagatorValidObstructionTrialCount" -> 20,
    "ExactScalingAcceptedCount" -> 0,
    "RelaxedHierarchyPositiveGapCount" -> 0,
    "RelaxedHierarchyZeroMaxGapCount" -> 20,
    "HiddenRegionCount" -> 0,
    "TimedOutCount" -> 0,
    "CandidateLimitReachedCount" -> 0,
    "Rejection" -> "No exact rational scaling satisfies F_SL homogeneity, W_HR>W_SL, post-face inequalities, sign constraints, and coverage"
  |>,
  "AllCodim3Prefilter" -> <|
    "GraphCount" -> 16,
    "ScanCount" -> 4312,
    "ResolvedCount" -> 4312,
    "UnresolvedCount" -> 0,
    "UpperBoundCandidateRowCount" -> 12,
    "SurvivorZeroSets" -> {{x3, x5, x8}},
    "TwelvePropagatorSurvivorCount" -> 0,
    "ThirteenPropagatorSurvivorCount" -> 12,
    "PermissiveDisjointSupportPairCount" -> 24
  |>,
  "AllCodim4Prefilter" -> <|
    "HistoricalQ" -> True,
    "SupersededBy" -> "wide_angle_16_face_pinch_higher_codim_summary.wl",
    "GraphCount" -> 16,
    "ScanCount" -> 10560,
    "ResolvedCount" -> 10560,
    "UnresolvedCount" -> 0,
    "UpperBoundCandidateRowCount" -> 0,
    "DisjointSupportPairCount" -> 0,
    "FailureStageCounts" -> <|
      "FewerThanTwoFactors" -> 3612,
      "TrivialRestrictedPolynomial" -> 396,
      "NoDisjointSupportPair" -> 6552
    |>
  |>,
  "Scope" -> <|
    "InteriorConclusion" -> "Certified within the current HRF generator construction: no admissible generator exists in any of the 16 interiors.",
    "Codim3Conclusion" -> "All 4312 codimension-three strata are resolved. The only permissive survivors form the {x3,x5,x8} orbit in the 12 thirteen-propagator graphs; all 20 exact obstruction trials have maximal hierarchy gap zero.",
    "Codim4Conclusion" -> "The earlier factor-presentation prefilter is retained only as historical evidence. The cap-independent F0 face/pinch audit supersedes it at codimension four and above.",
    "RemainingWork" -> "The cap-independent audit is complete for all 108736 strata from codimension four through E-2. Lower codimensions retain their separately stated HRF evidence; the codimension-two record is the selected x8 near-miss sector, not an all-face codimension-two enumeration."
  |>
|>
