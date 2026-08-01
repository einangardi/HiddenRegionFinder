(* Five-point equal-off-shellness wide-angle study of the two-loop
   six-propagator seed.

   All momenta are outgoing and obey Sum_i p_i=0.  We define
     s_ij=(p_i+p_j)^2
   for the five adjacent pairs and take p_i^2=lambda>0 before sending
   lambda -> 0.  The substitution below obeys momentum conservation at
   every nonzero lambda; it is not the massless relation with p_i^2 merely
   appended afterward.
*)

$HistoryLength = 0;

base = DirectoryName[$InputFileName];
repo = DirectoryName[DirectoryName[base]];
$HRFPackageDirectory = repo;
$HRFQuietReports = True;
$HRFScalingReport = False;
$HRFUsePolynomialCancellationFactors = True;
$HRFPolynomialRequireKinematicDomainQ = True;

Get[FileNameJoin[{repo, "HiddenRegionFinder.wl"}]];

ClearAll[
  hrf5WASpRules, hrf5WAToInvariants, hrf5WASeedData,
  hrf5WACyclicOrders, hrf5WARunSeed, hrf5WACompactResult,
  hrf5WAManualGeneratorTrial, hrf5WAExhaustiveGeneratorIdealAudit,
  hrf5WAGramMatrix, hrf5WAGramDeterminant,
  hrf5WALandshoffPairDiscriminant, hrf5WACoplanarWitnessAudit,
  hrf5WAGenericLightConeRules, hrf5WAGramLightConeFactorization,
  hrf5WARepresentativeCoplanarLandauSolution,
  hrf5WACoplanarLocalSLDecomposition
];

hrf5WASpRules[lam_] := {
  sp[p1, p1] -> lam, sp[p2, p2] -> lam, sp[p3, p3] -> lam,
  sp[p4, p4] -> lam, sp[p5, p5] -> lam,

  sp[p1, p2] -> (s12 - 2 lam)/2,
  sp[p2, p3] -> (s23 - 2 lam)/2,
  sp[p3, p4] -> (s34 - 2 lam)/2,
  sp[p4, p5] -> (s45 - 2 lam)/2,
  sp[p1, p5] -> (s15 - 2 lam)/2,

  sp[p1, p3] -> (s45 - s12 - s23 + lam)/2,
  sp[p2, p4] -> (s15 - s23 - s34 + lam)/2,
  sp[p3, p5] -> (s12 - s34 - s45 + lam)/2,
  sp[p1, p4] -> (s23 - s45 - s15 + lam)/2,
  sp[p2, p5] -> (s34 - s15 - s12 + lam)/2
};

hrf5WAToInvariants[expr_, lam_] := Expand[
  spExpand[expr] //.
    {sp[a_, b_] /; OrderedQ[{b, a}] :> sp[b, a]} /.
    hrf5WASpRules[lam]
];

hrf5WACyclicOrders[] := Module[{perms, canon},
  perms = ({1} ~Join~ #) & /@ Permutations[{2, 3, 4, 5}];
  canon[ord_] := First @ Sort[{ord, Prepend[Reverse[Rest[ord]], 1]}];
  DeleteDuplicates[canon /@ perms]
];

hrf5WASeedData[order_List] := Module[{internal, external, uf, fFull},
  internal = {
    {"0", {1, 3}}, {"0", {1, 5}}, {"0", {2, 3}},
    {"0", {2, 5}}, {"0", {3, 4}}, {"0", {4, 5}}
  };
  external = MapIndexed[{Symbol["p" <> ToString[#1]], First[#2]} &, order];
  uf = SymanzikUF[internal, external];
  fFull = hrf5WAToInvariants[uf["F"], lambdaOS];
  <|
    "ExternalOrderAtVertices" -> order,
    "InternalLines" -> internal,
    "ExternalLines" -> external,
    "U" -> uf["U"],
    "FOffShell" -> fFull,
    "F0" -> Expand[fFull /. lambdaOS -> 0],
    "Variables" -> uf["Variables"]
  |>
];

$HRF5WAKinematicVariables = {s12, s23, s34, s45, s15};
$HRF5WASignDomain = s12 > 0 && s34 > 0 && s45 > 0 && s23 < 0 && s15 < 0;

(* Gram matrix of 2 p_i.p_j for the independent momenta p1,...,p4 at the
   massless endpoint.  With signature (+---), real physical five-point
   kinematics has Det[G]<=0; the generic interior has Det[G]<0 and Det[G]=0
   is the coplanar boundary. *)
hrf5WAGramMatrix[] := {
  {0, s12, s45 - s12 - s23, s23 - s45 - s15},
  {s12, 0, s23, s15 - s23 - s34},
  {s45 - s12 - s23, s23, 0, s34},
  {s23 - s45 - s15, s15 - s23 - s34, s34, 0}
};
hrf5WAGramDeterminant[] := Factor[Det[hrf5WAGramMatrix[]]];

(* Exact on-shell light-cone chart, using the same coordinates as the MRK
   analysis but without taking an MRK limit.  The transverse momenta are

     p3_perp = q,   p4_perp = k,   p5_perp = -q-k,

   with q2=|q|^2, k2=|k|^2 and qk2=2 q.k.  The independent positive
   longitudinal components are p3+=aPlus, p4+=bPlus and p5-=mMinus; all
   conjugate components follow from on-shellness.  Momentum conservation
   fixes the two incoming momenta.  No rapidity or invariant hierarchy is
   assumed in this chart. *)
hrf5WAGenericLightConeRules[] := Module[
  {p3Plus, p3Minus, p4Plus, p4Minus, p5Plus, p5Minus,
   incomingPlus, incomingMinus},
  p3Plus = aPlus;
  p3Minus = q2/aPlus;
  p4Plus = bPlus;
  p4Minus = k2/bPlus;
  p5Minus = mMinus;
  p5Plus = (q2 + qk2 + k2)/mMinus;
  incomingPlus = p3Plus + p4Plus + p5Plus;
  incomingMinus = p3Minus + p4Minus + p5Minus;
  {
    s12 -> Expand[incomingPlus incomingMinus],
    s23 -> Expand[-incomingPlus p3Minus],
    s34 -> Expand[p3Plus p4Minus + p3Minus p4Plus - qk2],
    s45 -> Expand[p4Plus p5Minus + p4Minus p5Plus + qk2 + 2 k2],
    s15 -> Expand[-incomingMinus p5Plus]
  }
];

(* In this chart the entire five-point Gram condition is the transverse
   non-coplanarity condition.  Cauchy--Schwarz gives qk2^2<=4 q2 k2.
   Away from degenerate longitudinal endpoints the prefactor below is
   strictly positive, so Det[G]=0 iff q and k are collinear in the
   transverse plane. *)
hrf5WAGramLightConeFactorization[] := Module[{computed, expected},
  computed = Factor[
    hrf5WAGramDeterminant[] /. hrf5WAGenericLightConeRules[]
  ];
  expected = Factor[
    ((qk2 + aPlus mMinus + bPlus mMinus + k2 + q2)^2
       (aPlus bPlus mMinus + aPlus k2 + bPlus q2)^2 /
       (aPlus^2 bPlus^2 mMinus^2))
      (qk2^2 - 4 q2 k2)
  ];
  <|
    "InvariantRules" -> hrf5WAGenericLightConeRules[],
    "GramDeterminantInLightConeChart" -> computed,
    "PositiveLongitudinalPrefactor" -> Factor[
      expected/(qk2^2 - 4 q2 k2)
    ],
    "TransverseGramFactor" -> qk2^2 - 4 q2 k2,
    "IdentityQ" -> TrueQ[Factor[computed - expected] === 0],
    "CoplanarCondition" -> qk2^2 == 4 q2 k2
  |>
];

(* Exact positive Landau family for the representative attachment order that
   also has the central-soft MRK hidden region.  We take the positive
   coplanar branch qk2=2 q k, write q2=q^2 and k2=k^2, and fix the irrelevant
   projective normalization x5=1.  x1 and x3 remain arbitrary positive
   internal coordinates on the pinch surface. *)
hrf5WARepresentativeCoplanarLandauSolution[] := Module[
  {data, chart, solution, gradient, fAtSolution},
  data = hrf5WASeedData[{1, 2, 3, 5, 4}];
  chart = hrf5WAGenericLightConeRules[] /.
    {q2 -> qTrans^2, k2 -> kTrans^2,
      qk2 -> 2 qTrans kTrans};
  solution = {
    x0 -> (aPlus kTrans
       (kTrans^2 + bPlus mMinus + kTrans qTrans) x1)/
      (bPlus qTrans
       (aPlus mMinus + kTrans qTrans + qTrans^2)),
    x2 -> ((kTrans^2 + bPlus mMinus + kTrans qTrans) x3)/
      (aPlus mMinus + kTrans qTrans + qTrans^2),
    x4 -> kTrans/qTrans,
    x5 -> 1
  };
  gradient = Factor /@ Together[
    (D[data["F0"], #] & /@ data["Variables"]) /. chart /. solution
  ];
  fAtSolution = Factor[Together[data["F0"] /. chart /. solution]];
  <|
    "ExternalOrderAtVertices" -> {1, 2, 3, 5, 4},
    "CoplanarLightConeChart" -> chart,
    "LandauSolution" -> solution,
    "PositiveParameterAssumptions" ->
      aPlus > 0 && bPlus > 0 && mMinus > 0 &&
      qTrans > 0 && kTrans > 0 && x1 > 0 && x3 > 0,
    "F0OnSolution" -> fAtSolution,
    "GradientOnSolution" -> gradient,
    "LandauIdentityQ" -> TrueQ[
      fAtSolution === 0 && gradient === ConstantArray[0, 6]
    ]
  |>
];

(* Local normal form of the wide-angle superleading polynomial around the
   same positive coplanar Landau family.  The three y variables are normal
   coordinates; x1,x3,x5 are internal coordinates along the pinch surface.
   The absence of constant, linear and cubic y terms is exact. *)
hrf5WACoplanarLocalSLDecomposition[] := Module[
  {data, chart, numeratorRatio, denominatorRatio, ratio0, ratio2, ratio4,
   localRules, localF, coefficientData, uOnLocus, f1OnLocus},
  data = hrf5WASeedData[{1, 2, 3, 5, 4}];
  chart = hrf5WAGenericLightConeRules[] /.
    {q2 -> qTrans^2, k2 -> kTrans^2,
      qk2 -> 2 qTrans kTrans};
  numeratorRatio = kTrans^2 + bPlus mMinus + kTrans qTrans;
  denominatorRatio = aPlus mMinus + kTrans qTrans + qTrans^2;
  ratio0 = aPlus kTrans numeratorRatio/
    (bPlus qTrans denominatorRatio);
  ratio2 = numeratorRatio/denominatorRatio;
  ratio4 = kTrans/qTrans;
  localRules = {
    x0 -> ratio0 x1 + y0,
    x2 -> ratio2 x3 + y2,
    x4 -> ratio4 x5 + y4
  };
  localF = Factor[Together[data["F0"] /. chart /. localRules]];
  coefficientData = <|
    "y0 y2" -> Factor[Coefficient[localF, y0 y2]],
    "y0 y4" -> Factor[Coefficient[localF, y0 y4]],
    "y2 y4" -> Factor[Coefficient[localF, y2 y4]]
  |>;
  uOnLocus = Factor[Together[
    data["U"] /. localRules /. {y0 -> 0, y2 -> 0, y4 -> 0}
  ]];
  f1OnLocus = Factor[Together[
    Coefficient[data["FOffShell"], lambdaOS, 1] /. chart /. localRules /.
      {y0 -> 0, y2 -> 0, y4 -> 0}
  ]];
  <|
    "ExternalOrderAtVertices" -> {1, 2, 3, 5, 4},
    "CoplanarCondition" -> w == wbar,
    "CoplanarBranchInThisChart" -> w == wbar == -qTrans/kTrans,
    "InternalCoordinates" -> {x1, x3, x5},
    "NormalCoordinates" -> {y0, y2, y4},
    "CancellationLocus" -> {y0 == 0, y2 == 0, y4 == 0},
    "LocalCoordinateRules" -> localRules,
    "FSLOriginal" -> Factor[Together[data["F0"] /. chart]],
    "FSLLocal" -> localF,
    "PairProductCoefficients" -> coefficientData,
    "UAtWHROnCancellationLocus" -> uOnLocus,
    "OffShellF1AtWHROnCancellationLocus" -> f1OnLocus,
    "LeadingLocalLPPolynomial" -> Factor[localF + uOnLocus + f1OnLocus],
    "OriginalRegionVector" -> {-1, -1, -1, -1, -1, -1, 1},
    "InternalCoordinateWeights" -> <|x1 -> -1, x3 -> -1, x5 -> -1|>,
    "SymmetricNormalCoordinateWeights" ->
      <|y0 -> -1/2, y2 -> -1/2, y4 -> -1/2|>,
    "WSL" -> -3,
    "WHR" -> -2,
    "HierarchyGap" -> 1,
    "ExactQuadraticNormalFormQ" -> TrueQ[
      Expand[localF - Total[MapThread[Times,
        {Values[coefficientData], {y0 y2, y0 y4, y2 y4}}]]] === 0
    ]
  |>
];

$HRF5WAPhysicalPairSignDomain =
  $HRF5WASignDomain &&
  s12 - s34 - s45 > 0 &&
  s45 - s12 - s23 < 0 &&
  s15 - s23 - s34 < 0 &&
  s23 - s45 - s15 < 0 &&
  s34 - s15 - s12 < 0;
$HRF5WAPhysicalInteriorDomain =
  $HRF5WAPhysicalPairSignDomain && hrf5WAGramDeterminant[] < 0;
$HRF5WAPhysicalClosedDomain =
  $HRF5WAPhysicalPairSignDomain && hrf5WAGramDeterminant[] <= 0;
$HRF5WAPhysicalCoplanarDomain =
  $HRF5WAPhysicalPairSignDomain && hrf5WAGramDeterminant[] == 0;

(* For the first of the three complementary full-F0 derivative pairs, set
     t=x2/x3, r=x5/x4.
   Eliminating r gives a quadratic in t.  Its discriminant is exactly the
   five-point Gram determinant.  The other two complementary pairs give the
   same identity by the graph symmetry (and by direct resultant checks). *)
hrf5WALandshoffPairDiscriminant[] := Module[{a, b, c},
  a = (s12 + s23 - s45) s34;
  b = (s12 + s23 - s45) s15 - s45 s34 -
    s23 (s12 + s15 - s34);
  c = -s45 s15;
  <|
    "QuadraticCoefficients" -> {a, b, c},
    "Discriminant" -> Factor[b^2 - 4 a c],
    "GramDeterminant" -> hrf5WAGramDeterminant[],
    "IdentityQ" -> TrueQ[Factor[b^2 - 4 a c - hrf5WAGramDeterminant[]] === 0]
  |>
];

(* Exact positive Landau witness on the coplanar surface.  All adjacent and
   crossed two-particle invariants retain the 2->3 physical signs and s35>0;
   no soft or collinear two-particle invariant is required. *)
hrf5WACoplanarWitnessAudit[] := Module[{data, rules, gradient},
  data = hrf5WASeedData[{1, 2, 3, 4, 5}];
  rules = {
    x0 -> 1, x1 -> 3/5, x2 -> 1/2, x3 -> 1, x4 -> 1, x5 -> 1,
    s12 -> 1, s23 -> -3/28, s34 -> 1/2, s45 -> 5/12, s15 -> -1/7
  };
  gradient = Expand[(D[data["F0"], #] & /@ data["Variables"]) /. rules];
  <|
    "Rules" -> rules,
    "AllSchwingerParametersPositiveQ" ->
      And @@ Thread[(data["Variables"] /. rules) > 0],
    "F0" -> Expand[data["F0"] /. rules],
    "Gradient" -> gradient,
    "LandauEquationsQ" -> TrueQ[gradient === ConstantArray[0, Length[gradient]]],
    "GramDeterminant" -> Expand[hrf5WAGramDeterminant[] /. rules],
    "s35" -> Expand[(s12 - s34 - s45) /. rules],
    "OtherInitialFinalInvariants" ->
      Expand[{s45 - s12 - s23, s15 - s23 - s34,
        s23 - s45 - s15, s34 - s15 - s12} /. rules],
    "LandshoffScalingWithLambda" -> {-1, -1, -1, -1, -1, -1, 1},
    "WSL" -> -3,
    "WHR" -> -2
  |>
];

hrf5WARunSeed[order_List, mode_String : "Adaptive"] := Module[{data, scan},
  data = hrf5WASeedData[order];
  scan = findObstructions[
    data["F0"], data["Variables"],
    $HRF5WAPhysicalClosedDomain, $HRF5WAKinematicVariables, Automatic,
    "UseExtendedFactors" -> True,
    "GeneratorMode" -> mode,
    "MaxGenerators" -> 2,
    "EnableSignedMonomialPairs" -> False,
    "StopOnFirstAdmissible" -> False,
    "CandidateGeneratorSetLimit" -> Infinity,
    "MaxTwoGeneratorUnionTrials" -> Infinity,
    "PolynomialMaxMonomials" -> Automatic,
    "StoreAllObstructionTrialsQ" -> True,
    "U" -> data["U"],
    "FObsForScaling" -> <|
      "DeltaLayers" -> hrfDeltaLayerAssociation[data["FOffShell"], lambdaOS]
    |>,
    "CoverageScalingMethod" -> "ExactCoverage",
    "RequireValidScalingForHiddenRegionQ" -> True
  ];
  <|"Data" -> data, "Mode" -> mode, "Scan" -> scan|>
];

hrf5WACompactResult[result_Association] := Module[{scan = result["Scan"]},
  <|
    "ExternalOrderAtVertices" -> result["Data", "ExternalOrderAtVertices"],
    "Mode" -> result["Mode"],
    "HiddenRegionQ" -> Lookup[scan, "HiddenRegionQ", Missing["Absent"]],
    "HiddenRegionCount" -> Lookup[scan, "HiddenRegionCount", Missing["Absent"]],
    "SearchTruncatedQ" -> Lookup[scan, "SearchTruncatedQ", Missing["Absent"]],
    "SearchCompleteQ" -> Lookup[scan, "HiddenRegionSearchCompleteQ", Missing["Absent"]],
    "CandidateGeneratorCount" -> Lookup[
      Lookup[scan, "GeneratorConstructionAudit", <||>],
      "CandidateGeneratorCount", Missing["Absent"]
    ],
    "Generators" -> Lookup[scan, "Generators", {}],
    "RegionVectors" -> Lookup[scan, "RegionVectors", {}],
    "ObstructionData" -> Lookup[scan, "ObstructionData", Missing["Absent"]]
  |>
];

(* Completeness cross-check for the present small seed.  The optimized HRF
   candidate constructor encodes coupled factors through products and applies
   degree/support filters.  Here we instead enumerate all nonempty subsets of
   the six accepted derivative polynomials as literal ideal generators.  This
   is inexpensive (2^6-1=63 trials) and avoids assuming disjoint x support. *)
hrf5WAManualGeneratorTrial[data_Association, safe_List, generators_List,
    kinAssumptions_] := Module[
  {vars, kinVars, bounds, setData, obs, slData, trial},
  vars = data["Variables"];
  kinVars = $HRF5WAKinematicVariables;
  bounds = hrfResolveGeneratorDegreeBounds[data["F0"], vars, <||>];
  setData = generatorSetAdmissibilityData[
    generators, safe, vars, kinVars, kinAssumptions, bounds, data["F0"]
  ];
  obs = obstructionByOriginalTermsGeneral[
    data["F0"], generators, vars, kinVars, Automatic, kinAssumptions
  ];
  slData = If[AssociationQ[obs] &&
      hrfValidObstructionResultQ[obs, generators, vars, kinVars],
    slSectorAdmissibilityData[
      obs["Superleading"], generators, safe, vars, kinVars,
      kinAssumptions, bounds, data["F0"]
    ],
    <|"AdmissibleSLSectorQ" -> False|>
  ];
  trial = <|
    "Generators" -> generators,
    "GeneratorFactorData" -> Lookup[setData, "GeneratorFactorData", {}],
    "GeneratorSetFactorUnion" -> Lookup[setData, "GeneratorSetFactorUnion", {}],
    "GeneratorSetFactorCount" -> Lookup[setData, "GeneratorSetFactorCount", 0],
    "PerGeneratorAdmissibleQ" -> Lookup[setData, "PerGeneratorAdmissibleQ", False],
    "SimultaneouslyAdmissibleGeneratorSetQ" ->
      Lookup[setData, "SimultaneouslyAdmissibleGeneratorSetQ", False],
    "SLSectorGenerators" -> Lookup[slData, "SLSectorGenerators", {}],
    "SLSectorFactorUnion" -> Lookup[slData, "SLSectorFactorUnion", {}],
    "SLSectorFactorCount" -> Lookup[slData, "SLSectorFactorCount", 0],
    "SimultaneouslyAdmissibleSLSectorQ" ->
      Lookup[slData, "SimultaneouslyAdmissibleSLSectorQ", False],
    "AdmissibleSLSectorQ" -> Lookup[slData, "AdmissibleSLSectorQ", False],
    "AdmissibleGeneratorSetQ" -> Lookup[slData, "AdmissibleSLSectorQ", False],
    "ObstructionData" -> obs
  |>;
  trial
];

hrf5WAExhaustiveGeneratorIdealAudit[order_List : {1, 2, 3, 4, 5},
    kinAssumptions_ : Automatic] := Module[
  {data, assumptions, safe, sets, trials, valid, scaling, hidden},
  data = hrf5WASeedData[order];
  assumptions = Replace[kinAssumptions,
    Automatic -> $HRF5WAPhysicalClosedDomain];
  safe = hrfSafeCancellationFactorsPolynomial[
    data["F0"], data["Variables"], assumptions, $HRF5WAKinematicVariables
  ][[1]];
  sets = Join @@ Table[Subsets[safe, {k}], {k, 1, Length[safe]}];
  trials = hrf5WAManualGeneratorTrial[data, safe, #, assumptions] & /@ sets;
  valid = Select[trials,
    hrfValidObstructionTrialQ[#, data["Variables"], $HRF5WAKinematicVariables] &
  ];
  scaling = hrfEvaluateValidTrialScaling[
      #, data["U"], data["Variables"], 5,
      <|"DeltaLayers" -> hrfDeltaLayerAssociation[data["FOffShell"], lambdaOS]|>,
      "ExactCoverage"
    ] & /@ valid;
  hidden = Select[scaling, TrueQ[Lookup[#, "ValidScalingQ", False]] &];
  <|
    "ExternalOrderAtVertices" -> order,
    "SafeFactorCount" -> Length[safe],
    "GeneratorSubsetCount" -> Length[sets],
    "ValidObstructionTrialCount" -> Length[valid],
    "ScalingEvaluationCount" -> Length[scaling],
    "HiddenRegionCount" -> Length[hidden],
    "HiddenRegionQ" -> (hidden =!= {}),
    "HiddenRegionEvaluations" -> hidden,
    "ValidTrials" -> valid
  |>
];

If[! TrueQ[ValueQ[$HRF5WALibraryOnly] && $HRF5WALibraryOnly],
  orderIndex = If[Length[$ScriptCommandLine] >= 2,
    ToExpression[$ScriptCommandLine[[2]]], 1];
  mode = If[Length[$ScriptCommandLine] >= 3,
    $ScriptCommandLine[[3]], "Adaptive"];
  orders = hrf5WACyclicOrders[];
  If[! IntegerQ[orderIndex] || ! 1 <= orderIndex <= Length[orders],
    Print["order index must lie in 1..", Length[orders]]; Exit[2]
  ];
  result = hrf5WARunSeed[orders[[orderIndex]], mode];
  compact = hrf5WACompactResult[result];
  Print[InputForm[compact]];
  out = FileNameJoin[{base,
    "wide_angle_seed_order_" <> IntegerString[orderIndex, 10, 2] <>
      "_" <> ToLowerCase[mode] <> ".wl"}];
  Export[out, result, "Package"];
  Print["Exported ", out];
];
