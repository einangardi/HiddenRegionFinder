(* Exact HRF audit of the wide-angle self-crossing boundary of the
   one-loop twisted hexagon.

   The physical path is the 2->4 double-parton-scattering configuration of
   Dixon and Esterlis, arXiv:1602.02107, mapped to the external ordering of
   the twisted hexagon used in the HRF paper.  All momenta are outgoing.

   This file is a library by default when
     $HRF6SelfCrossingAuditLibraryOnly = True
   is set before loading it. *)

$HistoryLength = 0;

auditDirectory = DirectoryName[$InputFileName];
repoDirectory = Which[
  FileExistsQ[FileNameJoin[{auditDirectory, "..", "..", "HiddenRegionFinder.wl"}]],
    ExpandFileName[FileNameJoin[{auditDirectory, "..", ".."}]],
  FileExistsQ[FileNameJoin[{auditDirectory, "..", "HiddenRegionFinder.wl"}]],
    ExpandFileName[FileNameJoin[{auditDirectory, ".."}]],
  True,
    ExpandFileName[FileNameJoin[{auditDirectory, "..", ".."}]]
];

$HRFQuietReports = True;
$HRFScalingReport = False;
$HRFUsePolynomialCancellationFactors = True;
$HRFPolynomialRequireKinematicDomainQ = True;
Get[FileNameJoin[{repoDirectory, "HiddenRegionFinder.wl"}]];

ClearAll[
  hrf6SCMinkowskiSquare,
  hrf6SCInvariant,
  hrf6SCWeightedTermRows,
  hrf6SCFacetCertificate,
  hrf6SCLeadingEtaTerm,
  hrf6SelfCrossingAudit
];

hrf6SCMinkowskiSquare[v_List] :=
  Expand[v[[1]]^2 - Total[Rest[v]^2]];

hrf6SCInvariant[momenta_Association, labels__Integer] :=
  FullSimplify[
    hrf6SCMinkowskiSquare[Total[Lookup[momenta, {labels}]]],
    Assumptions -> 0 <= beta < 1
  ];

hrf6SCWeightedTermRows[
    poly_, vars_List, parameter_, scaling_List, source_String] := Module[
  {allVars, rules, exponents, coefficients, rows, powers, terms, weights},
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

hrf6SCFacetCertificate[rows_List, localVars_List, localScaling_List] := Module[
  {minWeight, leadingRows, points, differences, rank, normalSpace,
   rawNormal, orientedNormal, normalizedNormal, candidateNormal},
  minWeight = Min[Lookup[rows, "Weight"]];
  leadingRows = Select[rows, Lookup[#, "Weight"] === minWeight &];
  points = DeleteDuplicates[Lookup[leadingRows, "AugmentedRow"]];
  differences = If[Length[points] <= 1, {},
    (# - First[points]) & /@ Rest[points]];
  rank = If[differences === {}, 0, MatrixRank[differences]];
  normalSpace = If[differences === {}, {}, NullSpace[differences]];
  rawNormal = If[Length[normalSpace] === 1, First[normalSpace],
    Missing["NonUniqueNormal"]];
  orientedNormal = If[ListQ[rawNormal] && Last[rawNormal] < 0,
    -rawNormal, rawNormal];
  normalizedNormal = If[ListQ[orientedNormal] && Last[orientedNormal] > 0,
    Together[orientedNormal/Last[orientedNormal]],
    Missing["NoPositiveParameterNormal"]];
  candidateNormal = Append[localScaling, 1];
  <|
    "MinimumWeight" -> minWeight,
    "LeadingRows" -> leadingRows,
    "LeadingAugmentedRows" -> points,
    "LeadingPointCount" -> Length[points],
    "AffineRank" -> rank,
    "RequiredRank" -> Length[localVars],
    "NormalSpaceDimension" -> Length[normalSpace],
    "NormalizedInwardNormal" -> normalizedNormal,
    "CandidateNormal" -> candidateNormal,
    "NormalAgreementQ" -> TrueQ[normalizedNormal === candidateNormal],
    "AllTermsAtOrAboveFacetQ" ->
      TrueQ[And @@ Thread[Lookup[rows, "Weight"] >= minWeight]],
    "LowerFacetCertifiedQ" -> TrueQ[
      rank === Length[localVars] && Length[normalSpace] === 1 &&
      normalizedNormal === candidateNormal &&
      And @@ Thread[Lookup[rows, "Weight"] >= minWeight]
    ]
  |>
];

hrf6SCLeadingEtaTerm[expr_, parameter_, order_Integer : 6] := Module[
  {series, terms, powers, minimum},
  series = Expand[Normal[Series[expr, {parameter, 0, order}]]];
  terms = If[Head[series] === Plus, List @@ series, {series}];
  powers = Exponent[#, parameter] & /@ terms;
  minimum = Min[powers];
  Factor[Coefficient[series, parameter, minimum]] parameter^minimum
];

hrf6SelfCrossingAudit[] := Module[
  {gamma, momenta, massShell, conservation, invariantNames,
   invariantLabels, invariantsBeta, invariantsEta, invariantRulesEta,
   crossRatios, crossRatiosEta, endpointInvariantRules,
   physicalEndpointRules, endpointSigns,
   fullF, fullU, boundaryF, boundaryCondition, boundaryFactorization,
   positiveParameterWitness, boundaryGradient, coreF, coreU, coreScan,
   coreSummary, fEta, f0, f1, boundaryF0, localRulesA, localRulesB,
   localVars, localScalingA, localScalingB, localPA, localPB,
   rowsA, rowsB, facetA, facetB, originalVector, parameterPower,
   nmrkData, nmrkRules, nmrkSubstitution, nmrkAlignment,
   s245N, s145N, fWide1N, fWide2N, leadWide1N, leadWide2N,
   expectedN1, expectedN2, nmrkIdentity1, nmrkIdentity2,
   dscData, dscRules, dscAlignment, s245D, s145D,
   fWide1D, fWide2D, leadWide1D, leadWide2D,
   expectedD1, expectedD2, dscIdentity1, dscIdentity2},

  (* Exact physical 2->4 path.  In the cyclic notation of
     arXiv:1602.02107, (k1,...,k6)=(p3,p6,p1,p5,p4,p2), so k3 and k6,
     equivalently p1 and p2, are incoming.  beta is a transverse recoil;
     eta=beta^2 is the invariant small parameter. *)
  gamma = 1/Sqrt[1 - beta^2];
  momenta = <|
    1 -> {-gamma, 0, 0, -gamma},
    2 -> {-gamma, 0, 0, gamma},
    3 -> {gamma/2, 1/2, gamma beta/2, 0},
    6 -> {gamma/2, -1/2, gamma beta/2, 0},
    5 -> {gamma/2, 3/10, -gamma beta/2, 2/5},
    4 -> {gamma/2, -3/10, -gamma beta/2, -2/5}
  |>;
  massShell = AssociationMap[
    FullSimplify[hrf6SCMinkowskiSquare[momenta[#]],
      Assumptions -> 0 <= beta < 1] &,
    Keys[momenta]
  ];
  conservation = FullSimplify[Total[Values[momenta]],
    Assumptions -> 0 <= beta < 1];

  invariantNames = {s16, s156, s23, s15, s145, s36, s45, s245, s24};
  invariantLabels = {
    {1, 6}, {1, 5, 6}, {2, 3}, {1, 5}, {1, 4, 5},
    {3, 6}, {4, 5}, {2, 4, 5}, {2, 4}
  };
  invariantsBeta = AssociationThread[
    invariantNames,
    Map[hrf6SCInvariant[momenta, Sequence @@ #] &, invariantLabels]
  ];
  invariantsEta = AssociationMap[
    FullSimplify[# /. beta -> Sqrt[eta], Assumptions -> 0 <= eta < 1] &,
    invariantsBeta
  ];
  invariantRulesEta = Normal[invariantsEta];

  crossRatios = <|
    uA -> s36 s45/(s145 s245),
    vA -> s16 s24/(s156 s245),
    wA -> s15 s23/(s145 s156)
  |>;
  crossRatiosEta = AssociationMap[
    FullSimplify[# /. invariantRulesEta, Assumptions -> 0 <= eta < 1] &,
    crossRatios
  ];
  endpointInvariantRules =
    Thread[invariantNames -> (Values[invariantsEta] /. eta -> 0)];
  physicalEndpointRules = Join[
    endpointInvariantRules,
    {x0 -> 0, x1 -> 1, x2 -> 1, x3 -> 0, x4 -> 1, x5 -> 1}
  ];
  endpointSigns = AssociationMap[Sign[# /. physicalEndpointRules] &,
    invariantNames];

  fullF = Expand[
    s16 x0 x2 + s156 x0 x3 + s23 x0 x4 +
    s15 x1 x3 + s145 x1 x4 + s36 x1 x5 +
    s45 x2 x4 + s245 x2 x5 + s24 x3 x5
  ];
  fullU = x0 + x1 + x2 + x3 + x4 + x5;
  boundaryF = Expand[fullF /. {x0 -> 0, x3 -> 0}];
  boundaryCondition = s36 s45 == s145 s245;
  boundaryFactorization =
    (s36 x1 + s245 x2) (s145 x4 + s36 x5)/s36;

  positiveParameterWitness = {x1 -> 1, x2 -> 1, x4 -> 1, x5 -> 1};
  boundaryGradient = D[boundaryF, #] & /@ {x1, x2, x4, x5};

  (* Core HRF run at the exact rational physical endpoint.  Neither the
     cancellation factors nor their product is supplied to the code.  The
     explicit full-coordinate dissection certificate is performed below. *)
  coreF = Expand[boundaryF /. endpointInvariantRules];
  coreU = x1 + x2 + x4 + x5;
  coreScan = findObstructions[
    coreF, {x1, x2, x4, x5}, True, {}, Automatic,
    "UseExtendedFactors" -> True,
    "GeneratorMode" -> "Adaptive",
    "MaxGenerators" -> 1,
    "EnableSignedMonomialPairs" -> False,
    "StopOnFirstAdmissible" -> False,
    "CandidateGeneratorSetLimit" -> Infinity,
    "MaxTwoGeneratorUnionTrials" -> Infinity,
    "PolynomialMaxMonomials" -> Automatic,
    "StoreAllObstructionTrialsQ" -> True,
    "U" -> coreU,
    "FObsForScaling" -> <|
      "DeltaLayers" -> <|1 -> -2 (x1 x4 + x2 x5)|>
    |>,
    "CoverageScalingMethod" -> "ExactCoverage",
    "OrdinaryDissectionMode" -> "Off",
    "RequireValidScalingForHiddenRegionQ" -> True
  ];
  coreSummary = <|
    "CancellationFactors" -> Lookup[coreScan, "CancellationFactors", {}],
    "Generator" -> First[Lookup[coreScan, "Generators", {Missing["Absent"]}]],
    "HiddenRegionQ" -> Lookup[coreScan, "HiddenRegionQ", False],
    "HiddenRegionCount" -> Lookup[coreScan, "HiddenRegionCount", 0],
    "Scaling" -> Lookup[Lookup[coreScan, "CoverageScalingData", <||>],
      "Scaling", Missing["Absent"]],
    "WSL" -> Lookup[Lookup[coreScan, "CoverageScalingData", <||>],
      "FSLWeightPrimitive", Missing["Absent"]],
    "WHR" -> Lookup[Lookup[coreScan, "CoverageScalingData", <||>],
      "PostCancellationLeadingWeightPrimitive", Missing["Absent"]],
    "SearchCompleteQ" -> Lookup[coreScan,
      "HiddenRegionSearchCompleteQ", False],
    "SearchTruncatedQ" -> Lookup[coreScan, "SearchTruncatedQ", True]
  |>;

  (* Expand the complete physical polynomial through the first lifting
     layer in eta=beta^2. *)
  fEta = Together[fullF /. invariantRulesEta];
  f0 = Expand[FullSimplify[Limit[fEta, eta -> 0]]];
  f1 = Expand[FullSimplify[Limit[(fEta - f0)/eta, eta -> 0]]];
  boundaryF0 = Factor[f0 /. {x0 -> 0, x3 -> 0}];

  localRulesA = {x1 -> x2 + t1, x5 -> x4 + t2};
  localRulesB = localRulesA;
  localVars = {x2, x4, t1, t2};
  localScalingA = {-1, -1, 0, -1};
  localScalingB = {-1, -1, -1, 0};
  localPA = Expand[(fullU + f0 + eta f1) /.
    {x0 -> 0, x3 -> 0} /. localRulesA];
  localPB = Expand[(fullU + f0 + eta f1) /.
    {x0 -> 0, x3 -> 0} /. localRulesB];
  rowsA = hrf6SCWeightedTermRows[
    localPA, localVars, eta, localScalingA, "P through eta^1"];
  rowsB = hrf6SCWeightedTermRows[
    localPB, localVars, eta, localScalingB, "P through eta^1"];
  facetA = hrf6SCFacetCertificate[rowsA, localVars, localScalingA];
  facetB = hrf6SCFacetCertificate[rowsB, localVars, localScalingB];
  originalVector = {0, -1, -1, 0, -1, -1, 1};
  parameterPower = Ddim/2 - 3;

  (* The two wide-angle normal factors reduce exactly to the NMRK factors
     after the published alignment. *)
  nmrkData = Import[
    FileNameJoin[{repoDirectory, "data", "nmrk",
      "one_loop_hexagon_kinematics.wl"}], "WL"];
  nmrkRules = Normal[nmrkData["InvariantRules"]];
  nmrkSubstitution = {
    X34 -> X34h/etaN, X56 -> X56h/etaN, w -> z, wb -> zb
  };
  nmrkAlignment = {
    x1 -> etaN^-1 y1, x2 -> etaN^-2 y2,
    x4 -> etaN^-2 y4, x5 -> etaN^-1 y5
  };
  s245N = Expand[(s24 + s25 + s45) /. nmrkRules];
  s145N = Expand[(s14 + s15 + s45) /. nmrkRules];
  fWide1N = Together[
    (s36 x1 + s245N x2) /. nmrkRules /. nmrkSubstitution /. nmrkAlignment];
  fWide2N = Together[
    (s145N x4 + s36 x5) /. nmrkRules /. nmrkSubstitution /. nmrkAlignment];
  leadWide1N = hrf6SCLeadingEtaTerm[fWide1N, etaN];
  leadWide2N = hrf6SCLeadingEtaTerm[fWide2N, etaN];
  expectedN1 = -q1 q1b X34h/
    (etaN^3 (1 - z) (1 - zb)) *
    ((1 + X45) y2 - (1 - z) (1 - zb) X45 X56h y1);
  expectedN2 = -q1 q1b X56h/etaN^3 *
    ((1 + X45) y4 - X34h X45 y5);
  nmrkIdentity1 = TrueQ[Factor[Together[leadWide1N - expectedN1]] === 0];
  nmrkIdentity2 = TrueQ[Factor[Together[leadWide2N - expectedN2]] === 0];

  (* The same wide-angle factors reduce to the DSC factors after its
     alignment. *)
  dscData = Import[
    FileNameJoin[{repoDirectory, "DSC_TwistorInvariantData_20260719.wl"}],
    "WL"];
  dscRules = KeyValueMap[
    #1 -> -(#2 /. {zc -> zD, zbc -> zbD}) &,
    dscData["PhysicalPairInvariants"]
  ];
  dscAlignment = {
    x1 -> eps^-2 y1, x2 -> eps^-2 y2,
    x4 -> eps^-2 y4, x5 -> eps^-2 y5
  };
  s245D = Expand[(s24 + s25 + s45) /. dscRules];
  s145D = Expand[(s14 + s15 + s45) /. dscRules];
  fWide1D = Together[(s36 x1 + s245D x2) /. dscRules /. dscAlignment];
  fWide2D = Together[(s145D x4 + s36 x5) /. dscRules /. dscAlignment];
  leadWide1D = hrf6SCLeadingEtaTerm[fWide1D, eps];
  leadWide2D = hrf6SCLeadingEtaTerm[fWide2D, eps];
  expectedD1 = -1/(a eps^2 (1 + tau1) (1 + tau2)) *
    (tau1 y1 + (1 + tau1) y2);
  expectedD2 = -tau1/(a eps^2 (1 + tau1) (1 + tau2)) *
    ((1 + tau2) y4 + y5);
  dscIdentity1 = TrueQ[Factor[Together[leadWide1D - expectedD1]] === 0];
  dscIdentity2 = TrueQ[Factor[Together[leadWide2D - expectedD2]] === 0];

  <|
    "PhysicalKinematics" -> <|
      "AllOutgoingMomenta" -> momenta,
      "MassShellValues" -> massShell,
      "AllMasslessQ" -> TrueQ[And @@ Thread[Values[massShell] == 0]],
      "MomentumSum" -> conservation,
      "MomentumConservationQ" -> TrueQ[conservation === ConstantArray[0, 4]],
      "InvariantRulesInEta" -> invariantRulesEta,
      "CrossRatios" -> crossRatiosEta,
      "SelfCrossingPathQ" -> TrueQ[
        FullSimplify[crossRatiosEta[vA] - crossRatiosEta[wA],
          Assumptions -> 0 <= eta < 1] === 0 &&
        Limit[crossRatiosEta[uA], eta -> 0] === 1
      ],
      "EndpointInvariantSigns" -> endpointSigns,
      "EndpointRules" -> physicalEndpointRules
    |>,
    "BoundaryLandauLocus" -> <|
      "ContractedParameters" -> {x0, x3},
      "BoundaryPolynomial" -> boundaryF,
      "SelfCrossingCondition" -> boundaryCondition,
      "FactorizedBoundaryPolynomial" -> boundaryFactorization,
      "FactorizationIdentityQ" -> TrueQ[Factor[Together[
        (boundaryF - boundaryFactorization) /.
          s45 -> s145 s245/s36]] === 0],
      "PositiveParameterWitness" -> positiveParameterWitness,
      "BoundaryGradientAtPhysicalWitness" ->
        Expand[boundaryGradient /. physicalEndpointRules],
      "PositiveStationaryPinchQ" -> TrueQ[
        Expand[boundaryGradient /. physicalEndpointRules] ===
          ConstantArray[0, 4] &&
        And @@ Thread[({x1, x2, x4, x5} /. positiveParameterWitness) > 0]
      ]
    |>,
    "CoreHRF" -> coreSummary,
    "PhysicalExpansion" -> <|
      "Parameter" -> eta == beta^2,
      "F0" -> f0,
      "F1" -> f1,
      "BoundaryF0" -> boundaryF0,
      "NormalCoordinates" -> {t1 == x1 - x2, t2 == x5 - x4},
      "OriginalRegionVector" -> originalVector,
      "WSL" -> -2,
      "WHR" -> -1,
      "ChartA" -> <|
        "LocalVariableOrder" -> localVars,
        "LocalNormal" -> Append[localScalingA, 1],
        "FacetCertificate" -> facetA|>,
      "ChartB" -> <|
        "LocalVariableOrder" -> localVars,
        "LocalNormal" -> Append[localScalingB, 1],
        "FacetCertificate" -> facetB|>,
      "BothDissectionChartsCertifiedQ" -> TrueQ[
        facetA["LowerFacetCertifiedQ"] && facetB["LowerFacetCertifiedQ"]],
      "HigherEtaLayersCannotUndercutFacetQ" -> True,
      "HigherEtaLayerReason" ->
        "The LP polynomial is at most quadratic in edge parameters; every eta^n layer with n>=2 has weight at least zero for either chart, above WHR=-1.",
      "ScalarUnitIndexPower" -> parameterPower,
      "AtD4Minus2Epsilon" ->
        Expand[parameterPower /. Ddim -> 4 - 2 epsilon]
    |>,
    "Inheritance" -> <|
      "WideAngleFactors" -> {
        s36 x1 + s245 x2,
        s145 x4 + s36 x5
      },
      "NMRKLeadingFactors" -> {leadWide1N, leadWide2N},
      "NMRKExpectedFactors" -> {expectedN1, expectedN2},
      "NMRKFactorIdentitiesQ" -> {nmrkIdentity1, nmrkIdentity2},
      "DSCLeadingFactors" -> {leadWide1D, leadWide2D},
      "DSCExpectedFactors" -> {expectedD1, expectedD2},
      "DSCFactorIdentitiesQ" -> {dscIdentity1, dscIdentity2},
      "BothLimitsInheritWideAngleFactorsQ" -> TrueQ[
        And[nmrkIdentity1, nmrkIdentity2, dscIdentity1, dscIdentity2]]
    |>,
    "Conclusion" -> <|
      "WideAngleBoundaryHiddenRegionQ" -> TrueQ[
        coreSummary["HiddenRegionQ"] &&
        facetA["LowerFacetCertifiedQ"] && facetB["LowerFacetCertifiedQ"] &&
        TrueQ[Expand[boundaryGradient /. physicalEndpointRules] ===
          ConstantArray[0, 4]]
      ],
      "CommonWideAngleSeedQ" -> TrueQ[
        And[nmrkIdentity1, nmrkIdentity2, dscIdentity1, dscIdentity2]]
    |>
  |>
];

If[! TrueQ[ValueQ[$HRF6SelfCrossingAuditLibraryOnly] &&
    $HRF6SelfCrossingAuditLibraryOnly],
  audit = hrf6SelfCrossingAudit[];
  Print[InputForm[<|
    "AllMasslessQ" -> audit["PhysicalKinematics", "AllMasslessQ"],
    "MomentumConservationQ" ->
      audit["PhysicalKinematics", "MomentumConservationQ"],
    "SelfCrossingPathQ" ->
      audit["PhysicalKinematics", "SelfCrossingPathQ"],
    "PositiveStationaryPinchQ" ->
      audit["BoundaryLandauLocus", "PositiveStationaryPinchQ"],
    "CoreHRF" -> audit["CoreHRF"],
    "BothDissectionChartsCertifiedQ" ->
      audit["PhysicalExpansion", "BothDissectionChartsCertifiedQ"],
    "BothLimitsInheritWideAngleFactorsQ" ->
      audit["Inheritance", "BothLimitsInheritWideAngleFactorsQ"],
    "Conclusion" -> audit["Conclusion"]
  |>]];
  Export[FileNameJoin[{auditDirectory,
    "six_point_wide_angle_self_crossing_audit.wl"}], audit, "Package"];
];
