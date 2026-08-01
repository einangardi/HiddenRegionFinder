(* Side-by-side F-polynomial audit for the representative two-loop
   six-propagator five-point graph with external order {1,2,3,5,4}.

   The wide-angle expansion is regulated by p_i^2=lambdaOS -> 0 and has a
   coplanar massless endpoint.  The central-soft MRK expansion uses the exact
   light-cone chart with (a,b)=(1,2).  Both descriptions use the same graph
   and edge labels. *)

$HistoryLength = 0;

base = DirectoryName[$InputFileName];
repo = DirectoryName[DirectoryName[base]];
mrkBase = FileNameJoin[{DirectoryName[base], "five_point_mrk_central_soft"}];

$HRF5WALibraryOnly = True;
Get[FileNameJoin[{base, "HRF_FivePointWideAngleSeedStudy.wl"}]];
$HRF5MRKRepoDirectory = repo;
$HRF5MRKLibraryOnly = True;
Get[FileNameJoin[{mrkBase, "HRF_FivePointMRKExploratory.wl"}]];

ClearAll[
  hrf5ComparisonLayerAssociation,
  hrf5ComparisonCentralSoftAudit,
  hrf5WideAngleCentralSoftComparison
];

hrf5ComparisonLayerAssociation[poly_, parameter_] := Module[
  {terms, powers, distinct},
  terms = List @@ Expand[poly];
  powers = Exponent[#, parameter] & /@ terms;
  distinct = Sort @ DeleteDuplicates[powers];
  Association @ Table[
    power -> Factor[Total[Pick[terms, powers, power]]/parameter^power],
    {power, distinct}
  ]
];

hrf5ComparisonCentralSoftAudit[] := Module[
  {data, fNative, faceRules, totalRules, faceF, totalF, totalScaled,
   nativeLayers, faceLayers, totalLayers, uTotal, uLayers,
   leadingWeight, scalefulWeight, leadingFactor, nextObstruction,
   combinedAlignedPolynomial, combinedGradient},
  data = hrf5MRKSeedData[{1, 2, 3, 5, 4}];
  fNative = Expand[
    data["F"] /. hrf5MRKExactCentralSoftRules[1, 2, 1]
  ];
  faceRules = {
    x0 -> delta^-3 x0, x1 -> delta^-3 x1, x2 -> x2,
    x3 -> delta^-3 x3, x4 -> delta^-3 x4, x5 -> delta^-3 x5
  };
  totalRules = {
    x0 -> delta^-4 x0, x1 -> delta^-4 x1, x2 -> delta^-1 x2,
    x3 -> delta^-4 x3, x4 -> delta^-4 x4, x5 -> delta^-4 x5
  };
  faceF = Expand[fNative /. faceRules];
  totalF = Expand[fNative /. totalRules];
  nativeLayers = hrf5ComparisonLayerAssociation[fNative, delta];
  faceLayers = hrf5ComparisonLayerAssociation[faceF, delta];
  totalLayers = hrf5ComparisonLayerAssociation[totalF, delta];
  uTotal = Expand[data["U"] /. totalRules];
  uLayers = hrf5ComparisonLayerAssociation[uTotal, delta];
  leadingWeight = First[Keys[totalLayers]];
  scalefulWeight = First[Keys[uLayers]];
  totalScaled = Expand[delta^-leadingWeight totalF];
  leadingFactor = Factor[First[Values[totalLayers]]];
  nextObstruction = Factor[totalLayers[-12]];
  combinedAlignedPolynomial =
    -M (P x2 - K x3) (x1 x4 - x0 x5) - T x0 x3 x4;
  combinedGradient = Factor /@
    (D[combinedAlignedPolynomial, #] & /@ data["Variables"]);
  <|
    "ExternalOrderAtVertices" -> {1, 2, 3, 5, 4},
    "ExactKinematicRules" -> hrf5MRKExactCentralSoftRules[1, 2, 1],
    "AlignmentScaling" -> {-3, -3, 0, -3, -3, -3, 1},
    "HRFScalingOnAlignedFace" -> {-1, -1, -1, -1, -1, -1, 1},
    "TotalScaling" -> {-4, -4, -1, -4, -4, -4, 1},
    "NativeFLayers" -> nativeLayers,
    "AlignedFaceFLayers" -> faceLayers,
    "TotalFLayers" -> totalLayers,
    "TotalULayers" -> uLayers,
    "RawSuperleadingWeight" -> leadingWeight,
    "UWeightUnderWouldBeVector" -> scalefulWeight,
    "LeadingAlignedFactorization" -> leadingFactor,
    "CancellationFactors" -> {P x2 - K x3, x1 x4 - x0 x5},
    "LeadingCancellationLocus" ->
      {P x2 - K x3 == 0, x1 x4 - x0 x5 == 0},
    "FirstAlignedObstruction" -> nextObstruction,
    "FirstAlignedObstructionOnLeadingLocus" -> -T x0 x3 x4,
    "FirstAlignedObstructionNonzeroInPositiveInteriorQ" -> True,
    "CombinedFirstTwoAlignedLayers" -> combinedAlignedPolynomial,
    "CombinedFirstTwoLayerGradient" -> combinedGradient,
    "PositiveStationaryPinchQ" -> False,
    "StationarityContradiction" ->
      "d/dx1 and d/dx2 force both leading factors to vanish; d/dx0 then " <>
      "equals -T x3 x4, which cannot vanish for T,x3,x4>0.",
    "ScaledFWithLeadingWeightRemoved" -> totalScaled,
    "HypersurfaceJetThroughOrder4" ->
      Factor[Sum[Coefficient[totalScaled, delta, n] delta^n, {n, 0, 4}]],
    "FirstScalefulOrderCoefficientBeforeIdealReduction" ->
      Factor[Coefficient[totalScaled, delta, 5]],
    "CertifiedOutsideSupportAtScalefulOrder" -> x0 x3 x4,
    "WouldBeFinalHRFHierarchyGap" -> 1,
    "CandidateStatus" -> "RejectedByFirstAlignedObstruction",
    "Interpretation" ->
      "After asymptotic-order alignment the very next layer is the genuine " <>
      "obstruction -T x0 x3 x4.  It is nonzero on the leading two-factor " <>
      "locus and the combined polynomial has no positive stationary pinch. " <>
      "The previously reported total vector is therefore a rejected " <>
      "would-be vector, not a certified central-soft MRK hidden region."
  |>
];

hrf5WideAngleCentralSoftComparison[] := <|
  "WideAngleCoplanarOnShell" -> hrf5WACoplanarLocalSLDecomposition[],
  "CentralSoftMRK" -> hrf5ComparisonCentralSoftAudit[],
  "CommonGraph" -> <|
    "ExternalOrderAtVertices" -> {1, 2, 3, 5, 4},
    "Variables" -> {x0, x1, x2, x3, x4, x5}
  |>
|>;

If[! TrueQ[ValueQ[$HRF5ComparisonLibraryOnly] && $HRF5ComparisonLibraryOnly],
  comparison = hrf5WideAngleCentralSoftComparison[];
  Print[InputForm[comparison]];
  Export[
    FileNameJoin[{base, "five_point_wide_angle_central_soft_comparison.wl"}],
    comparison,
    "Package"
  ];
];
