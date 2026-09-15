(* Complete all-layer audit of the five-point coplanar Landshoff region
   reached from the wide-angle on-shell expansion.

   Kinematic path:
     p_i^2 = lambdaOS -> 0,
   with fixed wide-angle adjacent invariants whose massless endpoint lies on
   the physical coplanar (Gram=0) branch.  The graph is the two-loop
   six-propagator seed with attachment order {1,2,3,5,4}.

   The audit is performed after the exact local change to three coordinates
   normal to the positive Landau locus.  It includes the complete F0, U and
   lambdaOS F1 polynomials, not only their restrictions to the locus. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
$HRF5WALibraryOnly = True;
Get[FileNameJoin[{base, "HRF_FivePointWideAngleSeedStudy.wl"}]];

ClearAll[
  hrf5WALandshoffWeightedTermRows,
  hrf5WALandshoffAllLayerAudit
];

hrf5WALandshoffWeightedTermRows[
    poly_, vars_List, parameter_, scaling_List, source_String] := Module[
  {allVars, rules, exponents, coefficients, terms, rows, powers, weights},
  If[Expand[poly] === 0, Return[{}]];
  allVars = Append[vars, parameter];
  rules = CoefficientRules[Expand[poly], allVars];
  exponents = First /@ rules;
  coefficients = Last /@ rules;
  rows = Most /@ exponents;
  powers = Last /@ exponents;
  terms = MapThread[
    #1 Times @@ MapThread[Power, {allVars, #2}] &,
    {coefficients, exponents}
  ];
  weights = MapThread[#1.scaling + #2 &, {rows, powers}];
  MapThread[
    <|"Source" -> source, "Term" -> #1, "XRow" -> #2,
      "LambdaPower" -> #3, "Weight" -> #4,
      "AugmentedRow" -> Append[#2, #3]|> &,
    {terms, rows, powers, weights}
  ]
];

hrf5WALandshoffAllLayerAudit[] := Module[
  {data, local, chart, localRules, f0Local, uLocal, f1Local,
   fullLocal, commonDenominator, fullNumerator, uNumerator, f0Numerator,
   f1Numerator, localVars, localScaling, fullRows, uRows, f0Rows, f1Rows,
   minWeight, leadingRows, leadingAugmentedRows, differences, affineRank,
   normalSpace, rawNormal, orientedNormal, normalizedNormal, candidateNormal,
   normalAgreementQ, lowerFacetQ, coeff, normalDegrees, Nkin, Dkin,
   clearedNormals, normalPullback, normalClearingFactors,
   factorizedLocalGenerators, factorizedOriginalGenerators,
   factorizedGeneratorMultipliers, originalGeneratorIdentityQ,
   originalF0MultiAffineQ, dressedBinomial, dressedBinomialPullback,
   qABSym, qBCSym, qCASym, ellASym, ellBSym, ellCSym,
   ratioMatrix, stationaryRatios, ratioPolynomial, stationaryValue,
   invariantNormals, invariantGenerators, invariantDecomposition,
   invariantRemainder, invariantIdentityQ, invariantWitness,
   jacobian, leadingPolynomial, sourceCounts, measureWeight, integralPower,
   landauFractions, momentumMeasureWeight, momentumPropagatorWeight,
   momentumIntegralPower, planarParameter, planarGramLayer,
   planarFullLocal, planarDenominator, planarNumerator,
   planarF0Numerator, planarUNumerator, planarGramNumerator,
   planarScaling, planarRows, planarF0Rows, planarURows, planarGramRows,
   planarMinWeight, planarLeadingRows, planarLeadingAugmentedRows,
   planarDifferences, planarAffineRank, planarNormalSpace,
   planarRawNormal, planarOrientedNormal, planarNormalizedNormal,
   planarCandidateNormal, planarNormalAgreementQ, planarLowerFacetQ,
   planarSourceCounts, planarMeasureWeight, planarIntegralPower,
   planarMomentumMeasureWeight, planarMomentumPropagatorWeight,
   planarMomentumIntegralPower},

  data = hrf5WASeedData[{1, 2, 3, 5, 4}];
  local = hrf5WACoplanarLocalSLDecomposition[];
  chart = hrf5WAGenericLightConeRules[] /.
    {q2 -> qTrans^2, k2 -> kTrans^2,
      qk2 -> 2 qTrans kTrans};
  localRules = local["LocalCoordinateRules"];

  f0Local = Factor[Together[data["F0"] /. chart /. localRules]];
  uLocal = Factor[Together[data["U"] /. localRules]];
  f1Local = Factor[Together[
    Coefficient[data["FOffShell"], lambdaOS, 1] /. chart /. localRules
  ]];
  fullLocal = Together[uLocal + f0Local + lambdaOS f1Local];
  commonDenominator = Factor[Denominator[fullLocal]];
  fullNumerator = Expand[Numerator[fullLocal]];
  uNumerator = Expand[Together[commonDenominator uLocal]];
  f0Numerator = Expand[Together[commonDenominator f0Local]];
  f1Numerator = Expand[Together[commonDenominator lambdaOS f1Local]];

  localVars = {x1, x3, x5, y0, y2, y4};
  localScaling = {-1, -1, -1, -1/2, -1/2, -1/2};
  fullRows = hrf5WALandshoffWeightedTermRows[
    fullNumerator, localVars, lambdaOS, localScaling, "FullLP"
  ];
  uRows = hrf5WALandshoffWeightedTermRows[
    uNumerator, localVars, lambdaOS, localScaling, "U"
  ];
  f0Rows = hrf5WALandshoffWeightedTermRows[
    f0Numerator, localVars, lambdaOS, localScaling, "F0"
  ];
  f1Rows = hrf5WALandshoffWeightedTermRows[
    f1Numerator, localVars, lambdaOS, localScaling, "lambda F1"
  ];

  minWeight = Min[Lookup[fullRows, "Weight"]];
  leadingRows = Select[fullRows, Lookup[#, "Weight"] === minWeight &];
  leadingAugmentedRows = DeleteDuplicates[
    Lookup[leadingRows, "AugmentedRow"]
  ];
  differences = If[Length[leadingAugmentedRows] <= 1, {},
    (# - First[leadingAugmentedRows]) & /@ Rest[leadingAugmentedRows]
  ];
  affineRank = If[differences === {}, 0, MatrixRank[differences]];
  normalSpace = If[differences === {}, {}, NullSpace[differences]];
  rawNormal = If[Length[normalSpace] === 1, First[normalSpace],
    Missing["NonUniqueNormal"]];
  orientedNormal = If[ListQ[rawNormal] && Last[rawNormal] < 0,
    -rawNormal, rawNormal];
  normalizedNormal = If[ListQ[orientedNormal] && Last[orientedNormal] > 0,
    Together[orientedNormal/Last[orientedNormal]],
    Missing["NoPositiveLambdaNormal"]
  ];
  candidateNormal = Append[localScaling, 1];
  normalAgreementQ = ListQ[normalizedNormal] &&
    TrueQ[And @@ Thread[Together[normalizedNormal-candidateNormal] == 0]];
  lowerFacetQ = TrueQ[
    affineRank === Length[localVars] && Length[normalSpace] === 1 &&
    normalAgreementQ && And @@ Thread[Lookup[fullRows, "Weight"] >= minWeight]
  ];

  coeff = local["PairProductCoefficients"];
  normalDegrees = Sort @ DeleteDuplicates[
    Total[Table[Exponent[#, y], {y, {y0, y2, y4}}]] & /@
      (List @@ Expand[f0Local])
  ];
  leadingPolynomial = Factor[Total[Lookup[leadingRows, "Term"]]];

  Nkin = kTrans^2 + bPlus mMinus + kTrans qTrans;
  Dkin = aPlus mMinus + kTrans qTrans + qTrans^2;
  clearedNormals = {
    bPlus qTrans Dkin x0 - aPlus kTrans Nkin x1,
    Dkin x2 - Nkin x3,
    qTrans x4 - kTrans x5
  };
  normalPullback = Factor /@ Together[
    clearedNormals /. localRules
  ];
  normalClearingFactors = {bPlus qTrans Dkin, Dkin, qTrans};
  factorizedLocalGenerators = {y0 y2, y0 y4, y2 y4};
  factorizedOriginalGenerators = Factor /@ {
    clearedNormals[[1]] clearedNormals[[2]],
    clearedNormals[[1]] clearedNormals[[3]],
    clearedNormals[[2]] clearedNormals[[3]]
  };
  factorizedGeneratorMultipliers = Factor /@ {
    (coeff["y0 y2"]/x5) x5/
      (normalClearingFactors[[1]] normalClearingFactors[[2]]),
    (coeff["y0 y4"]/x3) x3/
      (normalClearingFactors[[1]] normalClearingFactors[[3]]),
    (coeff["y2 y4"]/x1) x1/
      (normalClearingFactors[[2]] normalClearingFactors[[3]])
  };
  originalGeneratorIdentityQ = TrueQ[Factor[Together[
    local["FSLOriginal"] -
      factorizedGeneratorMultipliers.factorizedOriginalGenerators
  ]] === 0];
  originalF0MultiAffineQ = TrueQ[
    And @@ Flatten@Table[
      Exponent[local["FSLOriginal"], xe] <= 1,
      {xe, data["Variables"]}
    ]
  ];
  (* The ordinary central-soft binomial x1 x4-x0 x5 is recovered only
     after the Landau ratios of x0/x1 and x4/x5 coincide.  At generic wide
     angle its exact pullback is the kinematically dressed binomial below. *)
  dressedBinomial = Factor[
    (aPlus kTrans Nkin/(bPlus qTrans Dkin)) x1 x4 -
      (kTrans/qTrans) x0 x5
  ];
  dressedBinomialPullback = Factor[Together[dressedBinomial /. localRules]];

  (* Manifestly symmetric invariant description.  The graph is a theta
     graph with three two-edge paths A=(x0,x1), B=(x2,x3), C=(x4,x5).
     The endpoint ratios are rA=x0/x1, rB=x2/x3, rC=x4/x5. *)
  qABSym = s12 - s34 - s45;
  qBCSym = -s12 - s23 + s45;
  qCASym = s23;
  ellASym = -s15 + s23 - s45;
  ellBSym = s15 - s23 - s34;
  ellCSym = s45;
  ratioMatrix = {
    {0, qABSym, qCASym},
    {qABSym, 0, qBCSym},
    {qCASym, qBCSym, 0}
  };
  stationaryRatios = Factor /@ Together[
    LinearSolve[ratioMatrix, -{ellASym, ellBSym, ellCSym}]
  ];
  ratioPolynomial = Expand[
    qABSym rA rB + qBCSym rB rC + qCASym rC rA +
      ellASym rA + ellBSym rB + ellCSym rC
  ];
  stationaryValue = Factor[Together[
    ratioPolynomial /. Thread[{rA, rB, rC} -> stationaryRatios]
  ]];
  invariantNormals = Factor /@ {
    x0 - stationaryRatios[[1]] x1,
    x2 - stationaryRatios[[2]] x3,
    x4 - stationaryRatios[[3]] x5
  };
  invariantGenerators = Factor /@ {
    invariantNormals[[1]] invariantNormals[[2]],
    invariantNormals[[2]] invariantNormals[[3]],
    invariantNormals[[3]] invariantNormals[[1]]
  };
  invariantDecomposition = Factor[Together[
    qABSym x5 invariantGenerators[[1]] +
      qBCSym x1 invariantGenerators[[2]] +
      qCASym x3 invariantGenerators[[3]]
  ]];
  invariantRemainder = Factor[Together[
    data["F0"] - invariantDecomposition
  ]];
  invariantIdentityQ = TrueQ[Factor[Together[
    invariantRemainder -
      x1 x3 x5 hrf5WAGramDeterminant[]/
        (4 qABSym qBCSym qCASym)
  ]] === 0];
  invariantWitness = {
    s12 -> 45, s23 -> -3, s34 -> 9/2,
    s45 -> 27, s15 -> -45/2
  };

  jacobian = Det[Outer[D,
    {x0, x2, x4, x1, x3, x5} /. localRules,
    {y0, y2, y4, x1, x3, x5}
  ]];
  sourceCounts = <|
    "F0" -> Count[Lookup[f0Rows, "Weight"], minWeight],
    "U" -> Count[Lookup[uRows, "Weight"], minWeight],
    "lambda F1" -> Count[Lookup[f1Rows, "Weight"], minWeight]
  |>;
  measureWeight = Total[localScaling];
  integralPower = measureWeight + (-2) (-D/2);
  landauFractions = Factor /@ (1/(1 + stationaryRatios));
  momentumMeasureWeight = 2 (D/2) + 3/2;
  momentumPropagatorWeight = -6;
  momentumIntegralPower =
    momentumMeasureWeight + momentumPropagatorWeight;

  (* Exactly on-shell near-planar expansion.  The primitive parameter is
     lambdaPlanar proportional to epsilon5/i, hence Gamma5 is quadratic in
     lambdaPlanar.  Locally transverse to the Gram surface, changes of the
     stationary ratios are absorbed into the normal coordinates; the one
     invariant deformation is therefore represented by
       lambdaPlanar^2 cGram x1 x3 x5.
     The nonzero kinematic coefficient cGram does not affect exponent data. *)
  planarParameter = lambdaPlanar;
  planarGramLayer = cGram x1 x3 x5;
  planarFullLocal = Together[
    uLocal + f0Local + planarParameter^2 planarGramLayer
  ];
  planarDenominator = Factor[Denominator[planarFullLocal]];
  planarNumerator = Expand[Numerator[planarFullLocal]];
  planarF0Numerator = Expand[Together[planarDenominator f0Local]];
  planarUNumerator = Expand[Together[planarDenominator uLocal]];
  planarGramNumerator = Expand[Together[
    planarDenominator planarParameter^2 planarGramLayer
  ]];
  planarScaling = {-2, -2, -2, -1, -1, -1};
  planarRows = hrf5WALandshoffWeightedTermRows[
    planarNumerator, localVars, planarParameter, planarScaling, "FullLP"
  ];
  planarF0Rows = hrf5WALandshoffWeightedTermRows[
    planarF0Numerator, localVars, planarParameter, planarScaling, "Fcop"
  ];
  planarURows = hrf5WALandshoffWeightedTermRows[
    planarUNumerator, localVars, planarParameter, planarScaling, "U"
  ];
  planarGramRows = hrf5WALandshoffWeightedTermRows[
    planarGramNumerator, localVars, planarParameter, planarScaling,
    "lambdaPlanar^2 Fperp"
  ];
  planarMinWeight = Min[Lookup[planarRows, "Weight"]];
  planarLeadingRows = Select[planarRows,
    Lookup[#, "Weight"] === planarMinWeight &];
  planarLeadingAugmentedRows = DeleteDuplicates[
    Lookup[planarLeadingRows, "AugmentedRow"]];
  planarDifferences = If[Length[planarLeadingAugmentedRows] <= 1, {},
    (# - First[planarLeadingAugmentedRows]) & /@
      Rest[planarLeadingAugmentedRows]];
  planarAffineRank = If[planarDifferences === {}, 0,
    MatrixRank[planarDifferences]];
  planarNormalSpace = If[planarDifferences === {}, {},
    NullSpace[planarDifferences]];
  planarRawNormal = If[Length[planarNormalSpace] === 1,
    First[planarNormalSpace], Missing["NonUniqueNormal"]];
  planarOrientedNormal = If[ListQ[planarRawNormal] &&
      Last[planarRawNormal] < 0, -planarRawNormal, planarRawNormal];
  planarNormalizedNormal = If[ListQ[planarOrientedNormal] &&
      Last[planarOrientedNormal] > 0,
    Together[planarOrientedNormal/Last[planarOrientedNormal]],
    Missing["NoPositiveLambdaNormal"]];
  planarCandidateNormal = Append[planarScaling, 1];
  planarNormalAgreementQ = ListQ[planarNormalizedNormal] &&
    TrueQ[And @@ Thread[Together[
      planarNormalizedNormal - planarCandidateNormal] == 0]];
  planarLowerFacetQ = TrueQ[
    planarAffineRank === Length[localVars] &&
    Length[planarNormalSpace] === 1 && planarNormalAgreementQ &&
    And @@ Thread[Lookup[planarRows, "Weight"] >= planarMinWeight]
  ];
  planarSourceCounts = <|
    "Fcop" -> Count[Lookup[planarF0Rows, "Weight"], planarMinWeight],
    "U" -> Count[Lookup[planarURows, "Weight"], planarMinWeight],
    "lambdaPlanar^2 Fperp" ->
      Count[Lookup[planarGramRows, "Weight"], planarMinWeight]
  |>;
  planarMeasureWeight = Total[planarScaling];
  planarIntegralPower = planarMeasureWeight + (-4) (-D/2);
  planarMomentumMeasureWeight = 2 D + 3;
  planarMomentumPropagatorWeight = -12;
  planarMomentumIntegralPower =
    planarMomentumMeasureWeight + planarMomentumPropagatorWeight;

  <|
    "KinematicLimit" -> <|
      "OffShellness" -> p[i]^2 == lambdaOS,
      "Limit" -> lambdaOS -> 0,
      "PhysicalInvariantDomain" -> $HRF5WAPhysicalPairSignDomain,
      "PhysicalInteriorGramSign" -> hrf5WAGramDeterminant[] < 0,
      "ParityOddConvention" ->
        epsilon5 == 4 I LeviCivita[p1, p2, p3, p4],
      "GramConvention" -> hrf5WAGramDeterminant[] == epsilon5^2,
      "PhysicalOrientationBranch" -> epsilon5/I > 0,
      "EndpointCondition" -> hrf5WAGramDeterminant[] == 0,
      "PhysicalCoplanarBranch" -> qk2 == 2 qTrans kTrans
    |>,
    "Graph" -> KeyTake[data,
      {"ExternalOrderAtVertices", "InternalLines", "ExternalLines",
       "Variables", "U", "FOffShell", "F0"}],
    "LandauLocus" -> <|
      "LocalCoordinateRules" -> localRules,
      "InternalCoordinates" -> {x1, x3, x5},
      "NormalCoordinates" -> {y0, y2, y4},
      "ClearedOriginalNormalPolynomials" -> Factor /@ clearedNormals,
      "NormalPolynomialPullback" -> normalPullback,
      "NormalClearingFactors" -> normalClearingFactors,
      "LandauIdeal" -> {y0, y2, y4},
      "PositiveLandauSolution" ->
        hrf5WARepresentativeCoplanarLandauSolution[],
      "Jacobian" -> Factor[jacobian]
    |>,
    "AllLayerDecomposition" -> <|
      "F0Local" -> f0Local,
      "F0NormalDegreeSupport" -> normalDegrees,
      "F0InSquareOfLandauIdealQ" -> (normalDegrees === {2}),
      "PairProductCoefficients" -> coeff,
      "FactorizedLocalHRFGenerators" -> factorizedLocalGenerators,
      "FactorizedOriginalHRFGenerators" -> factorizedOriginalGenerators,
      "OriginalGeneratorMultipliers" -> factorizedGeneratorMultipliers,
      "OriginalGeneratorDecompositionIdentityQ" ->
        originalGeneratorIdentityQ,
      "OriginalF0MultiAffineQ" -> originalF0MultiAffineQ,
      "DressedWideAngleBinomial" -> dressedBinomial,
      "DressedWideAngleBinomialPullback" -> dressedBinomialPullback,
      "ULocal" -> uLocal,
      "F1Local" -> f1Local,
      "UOnLandauLocus" -> local["UAtWHROnCancellationLocus"],
      "F1OnLandauLocus" -> local["OffShellF1AtWHROnCancellationLocus"],
      "FullLocalLP" -> fullLocal,
      "CommonKinematicDenominator" -> commonDenominator,
      "LeadingDissectedPolynomial" -> leadingPolynomial
    |>,
    "InvariantSymmetricForm" -> <|
      "PathEdgePairs" -> <|"A" -> {x0, x1}, "B" -> {x2, x3},
        "C" -> {x4, x5}|>,
      "PathScaleVariables" -> {x1, x3, x5},
      "PathRatioDefinitions" -> {rA == x0/x1, rB == x2/x3,
        rC == x4/x5},
      "QuadraticCoefficients" -> <|
        qAB -> qABSym, qBC -> qBCSym, qCA -> qCASym|>,
      "LinearCoefficients" -> <|
        ellA -> ellASym, ellB -> ellBSym, ellC -> ellCSym|>,
      "RatioPolynomial" -> ratioPolynomial,
      "StationarityMatrix" -> ratioMatrix,
      "StationaryRatioVector" -> stationaryRatios,
      "StationaryValue" -> stationaryValue,
      "StationaryValueAsGram" ->
        hrf5WAGramDeterminant[]/(4 qABSym qBCSym qCASym),
      "GramDeterminantConvention" ->
        Gamma5 == epsilon5^2 == hrf5WAGramDeterminant[],
      "PhysicalInteriorBranch" ->
        Gamma5 < 0 && epsilon5/I == Sqrt[-Gamma5],
      "PhysicalBoundaryApproach" ->
        {Gamma5 -> 0, epsilon5/I -> 0},
      "OriginalNormalPolynomials" -> invariantNormals,
      "OriginalFactorizedGenerators" -> invariantGenerators,
      "OriginalF0GeneratorDecomposition" -> invariantDecomposition,
      "OffGramRemainder" -> invariantRemainder,
      "RemainderEqualsGramTermQ" -> invariantIdentityQ,
      "InvariantPositiveWitness" -> invariantWitness,
      "WitnessRatios" -> Factor[
        stationaryRatios /. invariantWitness],
      "WitnessGram" -> hrf5WAGramDeterminant[] /. invariantWitness,
      "WitnessInFullPhysicalSignDomainQ" -> TrueQ[
        $HRF5WAPhysicalPairSignDomain /. invariantWitness],
      "ParityOddOrientationAffectsF0Q" -> False
    |>,
    "Scaling" -> <|
      "OriginalVariables" -> {-1, -1, -1, -1, -1, -1, 1},
      "LocalVariableOrder" -> localVars,
      "LocalDissectedScaling" -> Append[localScaling, 1],
      "WSLOriginalCoordinates" -> -3,
      "WHR" -> -2,
      "HierarchyGap" -> 1
    |>,
    "AllLayerFacetCertificate" -> <|
      "MinimumWeight" -> minWeight,
      "WeightCountsBySource" -> <|
        "F0" -> Counts[Lookup[f0Rows, "Weight"]],
        "U" -> Counts[Lookup[uRows, "Weight"]],
        "lambda F1" -> Counts[Lookup[f1Rows, "Weight"]]
      |>,
      "LeadingTermCountsBySource" -> sourceCounts,
      "LeadingAugmentedRows" -> leadingAugmentedRows,
      "LeadingPointCount" -> Length[leadingAugmentedRows],
      "AffineRank" -> affineRank,
      "RequiredRank" -> Length[localVars],
      "NormalSpaceDimension" -> Length[normalSpace],
      "NormalizedInwardNormal" -> normalizedNormal,
      "CandidateNormal" -> candidateNormal,
      "NormalAgreementQ" -> normalAgreementQ,
      "AllTermsAtOrAboveFacetQ" ->
        TrueQ[And @@ Thread[Lookup[fullRows, "Weight"] >= minWeight]],
      "LowerFacetCertifiedQ" -> lowerFacetQ
    |>,
    "PowerCounting" -> <|
      "MeasureWeight" -> measureWeight,
      "LPPolynomialWeight" -> -2,
      "ScalarUnitIndexIntegralPower" -> integralPower,
      "AtD4Minus2Epsilon" ->
        Expand[integralPower /. D -> 4 - 2 epsilon],
      "MomentumSpace" -> <|
        "PathMomentumDefinitions" -> {
          qA, qA - p1, qB, qB - p2, qC, qC - p5},
        "HardVertexConstraint" -> qA + qB + qC == -p3,
        "LandauFractions" -> {
          xiA == landauFractions[[1]],
          xiB == landauFractions[[2]],
          xiC == landauFractions[[3]]},
        "LeadingLandauMomenta" -> {
          qA == xiA p1, qB == xiB p2, qC == xiC p5},
        "WitnessFractions" ->
          Factor[landauFractions /. invariantWitness],
        "IndependentLoopCount" -> 2,
        "CollinearMeasureWeightPerLoop" -> D/2,
        "RestrictedLongitudinalSupportWeight" -> 3/2,
        "MeasureWeight" -> momentumMeasureWeight,
        "SixUnitPropagatorWeight" -> momentumPropagatorWeight,
        "ScalarUnitIndexIntegralPower" -> momentumIntegralPower,
        "AtD4Minus2Epsilon" ->
          Expand[momentumIntegralPower /. D -> 4 - 2 epsilon],
        "MatchesParameterSpaceQ" ->
          TrueQ[Together[momentumIntegralPower - integralPower] == 0]
      |>
    |>,
    "NearPlanarOnShell" -> <|
      "KinematicLimit" -> <|
        "ExternalMasses" -> Table[p[i]^2 == 0, {i, 1, 5}],
        "PrimitiveParameter" -> lambdaPlanar,
        "ParityOddScaling" -> epsilon5/I == cEpsilon lambdaPlanar,
        "GramScaling" -> Gamma5 == -cEpsilon^2 lambdaPlanar^2,
        "MandelstamLeadingPoint" -> Gamma5 == 0,
        "LPExpansion" ->
          scriptP == U + Subscript[F, cop] +
            lambdaPlanar^2 Subscript[F, perpendicular] +
            remainder[lambdaPlanar^4]
      |>,
      "Scaling" -> <|
        "OriginalVariables" -> {-2, -2, -2, -2, -2, -2, 1},
        "LocalVariableOrder" -> localVars,
        "LocalDissectedScaling" -> Append[planarScaling, 1],
        "WSLOriginalCoordinates" -> -6,
        "WHR" -> -4,
        "HierarchyGap" -> 2
      |>,
      "LocalPolynomial" -> <|
        "Fcop" -> f0Local,
        "U" -> uLocal,
        "TransverseGramLayer" -> planarGramLayer,
        "FullLP" -> planarFullLocal,
        "CommonKinematicDenominator" -> planarDenominator
      |>,
      "FacetCertificate" -> <|
        "MinimumWeight" -> planarMinWeight,
        "WeightCountsBySource" -> <|
          "Fcop" -> Counts[Lookup[planarF0Rows, "Weight"]],
          "U" -> Counts[Lookup[planarURows, "Weight"]],
          "lambdaPlanar^2 Fperp" ->
            Counts[Lookup[planarGramRows, "Weight"]]
        |>,
        "LeadingTermCountsBySource" -> planarSourceCounts,
        "LeadingAugmentedRows" -> planarLeadingAugmentedRows,
        "LeadingPointCount" -> Length[planarLeadingAugmentedRows],
        "AffineRank" -> planarAffineRank,
        "RequiredRank" -> Length[localVars],
        "NormalSpaceDimension" -> Length[planarNormalSpace],
        "NormalizedInwardNormal" -> planarNormalizedNormal,
        "CandidateNormal" -> planarCandidateNormal,
        "NormalAgreementQ" -> planarNormalAgreementQ,
        "AllTermsAtOrAboveFacetQ" -> TrueQ[
          And @@ Thread[Lookup[planarRows, "Weight"] >= planarMinWeight]],
        "LowerFacetCertifiedQ" -> planarLowerFacetQ
      |>,
      "PowerCounting" -> <|
        "ParameterSpaceMeasureWeight" -> planarMeasureWeight,
        "LPPolynomialWeight" -> -4,
        "ScalarUnitIndexIntegralPower" -> planarIntegralPower,
        "AtD4Minus2Epsilon" ->
          Expand[planarIntegralPower /. D -> 4 - 2 epsilon],
        "MomentumSpace" -> <|
          "VirtualityWeight" -> 2,
          "TwoCollinearLoopMeasureWeight" -> 2 D,
          "RestrictedLongitudinalSupportWeight" -> 3,
          "MeasureWeight" -> planarMomentumMeasureWeight,
          "SixUnitPropagatorWeight" -> planarMomentumPropagatorWeight,
          "ScalarUnitIndexIntegralPower" -> planarMomentumIntegralPower,
          "AtD4Minus2Epsilon" -> Expand[
            planarMomentumIntegralPower /. D -> 4 - 2 epsilon],
          "MatchesParameterSpaceQ" -> TrueQ[Together[
            planarMomentumIntegralPower - planarIntegralPower] == 0]
        |>
      |>
    |>
  |>
];

If[! TrueQ[ValueQ[$HRF5WALandshoffAuditLibraryOnly] &&
    $HRF5WALandshoffAuditLibraryOnly],
  audit = hrf5WALandshoffAllLayerAudit[];
  Print[InputForm[<|
    "FcopInSquareOfLandauIdealQ" ->
      audit["AllLayerDecomposition", "F0InSquareOfLandauIdealQ"],
    "NearPlanarScaling" -> audit["NearPlanarOnShell", "Scaling"],
    "NearPlanarFacetCertificate" ->
      audit["NearPlanarOnShell", "FacetCertificate"],
    "NearPlanarPowerCounting" ->
      audit["NearPlanarOnShell", "PowerCounting"]
  |>]];
  Export[FileNameJoin[{base,
    "five_point_wide_angle_landshoff_all_layer_audit.wl"}],
    audit, "Package"];
];
