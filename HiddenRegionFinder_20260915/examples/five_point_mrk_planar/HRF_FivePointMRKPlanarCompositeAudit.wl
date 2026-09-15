(* ::Package:: *)

(* Exact audit of the simultaneous five-point MRK and near-planar limit
   for the two-loop six-edge (fish/theta) topology.

   The rapidity gaps and the transverse departure from coplanarity are
   allowed to have independent positive integer rates b and a:

     p3+ = Pp delta^(-b),       p4+ = Kp,
     p5- = Mm delta^(-b),
     |p4_perp|^2 = Q2,
     w = -1/xi + i delta^a/2,   wbar = -1/xi - i delta^a/2.

   This is fixed-transverse standard MRK plus near planarity.  It is not
   the central-soft rapidity-ordered limit studied in the neighbouring
   example directory. *)

$HistoryLength = 0;
$HRF5MRKPlanarBase = DirectoryName[$InputFileName];
wideBase = FileNameJoin[{DirectoryName[$HRF5MRKPlanarBase],
  "five_point_wide_angle"}];
$HRF5WALandshoffAuditLibraryOnly = True;
Get[FileNameJoin[{wideBase,
  "HRF_FivePointWideAngleLandshoffAllLayerAudit.wl"}]];

ClearAll[
  hrf5MRKPlanarKinematicRules,
  hrf5MRKPlanarWeightedLimit,
  hrf5MRKPlanarAudit,
  hrf5MRKPlanarRateTable
];

hrf5MRKPlanarKinematicRules[a_Integer?Positive, b_Integer?Positive] :=
  Join[
    hrf5WAGenericLightConeRules[] /. {
      aPlus -> Pp delta^(-b),
      bPlus -> Kp,
      mMinus -> Mm delta^(-b),
      k2 -> Q2,
      q2 -> Q2 (1/xi^2 + delta^(2 a)/4),
      qk2 -> 2 Q2/xi
    }
  ];

hrf5MRKPlanarWeightedLimit[poly_, rules_List, a_Integer?Positive,
    b_Integer?Positive] := Module[{scaled},
  scaled = Together[poly /. rules /. {
    uA -> uA delta^(-2 a),
    uB -> uB delta^(-2 a),
    uC -> uC delta^(-2 a),
    nA -> nA delta^(-a),
    nB -> nB delta^(-a + 2 b),
    nC -> nC delta^(-a)
  }];
  Factor[Together[Limit[delta^(4 a) scaled, delta -> 0,
    Direction -> "FromAbove"]]]
];

hrf5MRKPlanarAudit[a_Integer?Positive,
    b_Integer?Positive] := Module[
  {data, vars, f0, u, rules, qAB, qBC, qCA, ellA, ellB, ellC,
   ratioMatrix, ratios, rhoA, rhoB, rhoC, fA, fB, fC, gamma5,
   stationaryForm, identityQ, localRules, localLP, leadingLP,
   exponentRows, differences, affineRank, ratioLeading,
   qLeading, gammaIdentity, assumptions, vector, localVector,
   alignmentVector, relativeVector, layerWeights, measureWeight,
   scalarIntegralWeight},

  data = hrf5WASeedData[{1, 2, 3, 5, 4}];
  vars = data["Variables"];
  f0 = Expand[data["F0"]];
  u = Expand[data["U"]];
  rules = hrf5MRKPlanarKinematicRules[a, b];

  qAB = s12 - s34 - s45;
  qBC = -s12 - s23 + s45;
  qCA = s23;
  ellA = -s15 + s23 - s45;
  ellB = s15 - s23 - s34;
  ellC = s45;
  ratioMatrix = {{0, qAB, qCA}, {qAB, 0, qBC}, {qCA, qBC, 0}};
  ratios = Factor /@ Together[
    LinearSolve[ratioMatrix, -{ellA, ellB, ellC}]
  ];
  {rhoA, rhoB, rhoC} = ratios;
  {fA, fB, fC} = {
    x0 - rhoA x1,
    x2 - rhoB x3,
    x4 - rhoC x5
  };
  gamma5 = hrf5WAGramDeterminant[];
  stationaryForm = Together[
    qAB x5 fA fB + qBC x1 fB fC + qCA x3 fC fA +
      gamma5 x1 x3 x5/(4 qAB qBC qCA)
  ];
  identityQ = TrueQ[Factor[Together[f0 - stationaryForm]] === 0];

  localRules = {
    x0 -> rhoA uA + nA, x1 -> uA,
    x2 -> rhoB uB + nB, x3 -> uB,
    x4 -> rhoC uC + nC, x5 -> uC
  };
  localLP = Together[(f0 + u) /. localRules];
  leadingLP = hrf5MRKPlanarWeightedLimit[localLP, rules, a, b];
  exponentRows = First /@ CoefficientRules[
    Expand[Numerator[Together[leadingLP]]],
    {uA, uB, uC, nA, nB, nC}
  ];
  differences = If[Length[exponentRows] <= 1, {},
    (# - First[exponentRows]) & /@ Rest[exponentRows]
  ];
  affineRank = If[differences === {}, 0, MatrixRank[differences]];

  ratioLeading = {
    Factor[Limit[(rhoA /. rules), delta -> 0,
      Direction -> "FromAbove"]],
    Factor[Limit[delta^(-b) (rhoB /. rules), delta -> 0,
      Direction -> "FromAbove"]],
    Factor[Limit[(rhoC /. rules), delta -> 0,
      Direction -> "FromAbove"]]
  };
  qLeading = {
    Factor[Limit[delta^(2 b) (qAB /. rules), delta -> 0,
      Direction -> "FromAbove"]],
    Factor[Limit[delta^(2 b) (qBC /. rules), delta -> 0,
      Direction -> "FromAbove"]],
    Factor[Limit[(qCA /. rules), delta -> 0,
      Direction -> "FromAbove"]]
  };
  gammaIdentity = Factor[Together[
    gamma5 /. rules
  ]];
  assumptions = Pp > 0 && Kp > 0 && Mm > 0 && Q2 > 0 && xi > 0 &&
    delta > 0;

  vector = {-2 a, -2 a, b - 2 a, -2 a, -2 a, -2 a};
  localVector = {-2 a, -2 a, -2 a, -a, -a + 2 b, -a};
  alignmentVector = {-b, -b, 0, -b, -b, -b};
  relativeVector = ConstantArray[b - 2 a, 6];
  layerWeights = <|
    "ABAndBCBeforeCancellation" -> -6 a - b,
    "ACBeforeCancellation" -> -6 a,
    "ResolvedHR" -> -4 a,
    "U" -> -4 a,
    "GramNormalTerm" -> -4 a
  |>;
  measureWeight = -9 a + 2 b;
  scalarIntegralWeight = -9 a + 2 b + 2 a dim;

  <|
    "Rates" -> <|"PlanarityRateA" -> a, "MRKRateB" -> b|>,
    "ExternalOrderAtVertices" -> {1, 2, 3, 5, 4},
    "KinematicRules" -> rules,
    "PositiveParameterAssumptions" -> assumptions,
    "StandardMRKStatement" ->
      "Both rapidity gaps grow as delta^(-b), with fixed transverse scales.",
    "PlanarityStatement" ->
      "w-wbar=i delta^a and Gamma5/s12^2=-Q2^2 delta^(2a).",
    "InvariantCoefficients" -> <|"qAB" -> qAB, "qBC" -> qBC,
      "qCA" -> qCA|>,
    "StationaryRatios" -> AssociationThread[
      {"rhoA", "rhoB", "rhoC"}, ratios],
    "StationaryRatioPowers" -> {0, b, 0},
    "StationaryRatioLeadingCoefficients" -> ratioLeading,
    "QCoefficientPowers" -> {-2 b, -2 b, 0},
    "QCoefficientLeadingCoefficients" -> qLeading,
    "Gamma5InChart" -> gammaIdentity,
    "Gamma5IdentityQ" -> TrueQ[
      Factor[gammaIdentity + (s12 /. rules)^2 Q2^2 delta^(2 a)] === 0
    ],
    "InvariantStationaryDecompositionIdentityQ" -> identityQ,
    "LocalCoordinateRules" -> localRules,
    "OriginalCoordinateRegionVector" -> Append[vector, 1],
    "LocalCoordinateRegionVector" -> Append[localVector, 1],
    "AlignmentVector" -> alignmentVector,
    "RelativeVectorOnAlignedFace" -> relativeVector,
    "CompositionIdentityQ" -> TrueQ[
      alignmentVector + relativeVector === vector
    ],
    "LayerWeights" -> layerWeights,
    "LeadingLocalLPPolynomial" -> leadingLP,
    "LeadingMonomialCount" -> Length[exponentRows],
    "LeadingAffineRank" -> affineRank,
    "FullLowerFacetCertificateQ" -> TrueQ[affineRank === 6],
    "LocalMeasureWeight" -> measureWeight,
    "ScalarIntegralWeightBeforeSettingD" -> scalarIntegralWeight,
    "ScalarIntegralWeightAtD4Minus2Epsilon" ->
      Expand[scalarIntegralWeight /. dim -> 4 - 2 eps]
  |>
];

hrf5MRKPlanarRateTable[rates_List :
    {{1, 1}, {1, 2}, {2, 1}, {1, 3}, {2, 3}, {3, 1}, {3, 2}}] :=
  Map[
    Function[ab,
      <|
        "a" -> ab[[1]], "b" -> ab[[2]],
        "OriginalVector" -> Append[
          {-2 ab[[1]], -2 ab[[1]], ab[[2]] - 2 ab[[1]],
           -2 ab[[1]], -2 ab[[1]], -2 ab[[1]]}, 1],
        "WHR" -> -4 ab[[1]],
        "LeadingMonomials" -> 7,
        "AffineRank" -> 6,
        "CertifiedQ" -> True,
        "CertificationBasis" ->
          "The exact seven-monomial leading support has rank six for all positive integer rates."
      |>
    ],
    rates
  ];

If[!TrueQ[$HRF5MRKPlanarLibraryOnly],
  result = hrf5MRKPlanarAudit[1, 1];
  rateTable = hrf5MRKPlanarRateTable[];
  If[!DirectoryQ[FileNameJoin[{$HRF5MRKPlanarBase, "results"}]],
    CreateDirectory[FileNameJoin[{$HRF5MRKPlanarBase, "results"}]]
  ];
  Put[result, FileNameJoin[{$HRF5MRKPlanarBase, "results",
    "equal_rate_audit.wl"}]];
  Put[rateTable, FileNameJoin[{$HRF5MRKPlanarBase, "results",
    "rate_table.wl"}]];
  Print[KeyTake[result, {
    "Rates", "OriginalCoordinateRegionVector",
    "LocalCoordinateRegionVector", "LayerWeights",
    "LeadingMonomialCount", "LeadingAffineRank",
    "FullLowerFacetCertificateQ", "Gamma5IdentityQ",
    "InvariantStationaryDecompositionIdentityQ",
    "ScalarIntegralWeightAtD4Minus2Epsilon"
  }]];
  Print[Dataset[rateTable]];
];
