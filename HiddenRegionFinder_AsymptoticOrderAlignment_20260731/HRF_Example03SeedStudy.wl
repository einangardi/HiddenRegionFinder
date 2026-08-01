(* HRF_Example03SeedStudy.wl
   Seed-diagram diagnostic for Example 03 (six-propagator collinear interior).

   Matches the working binomial Example 03 path: SingleProduct generator,
   UseExtendedFactors -> False, polynomial f_k kin-normalized and Mandelstam-linear.

   Load:
     hrfEx03SeedStudyLoad[]
     hrfEx03SeedFactorTable[]
     hrfEx03SeedGeneratorAudit[]
     hrfEx03SeedRouteComparison[]
     Ex03SeedObstruction = hrfEx03RunSeedObstruction[];
*)

$HRFEx03SeedStudyDirectory = If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName],
  Quiet[Check[NotebookDirectory[], Directory[]]]
];

ClearAll[
  hrfEx03SeedStudyLoad, hrfEx03SeedSay, hrfEx03SeedObstructionOptions,
  hrfEx03SeedCollinearGeneratorOpts,
  hrfEx03SeedObstructionSafeFactors, hrfEx03SeedFactorAudit, hrfEx03SeedFactorTable,
  hrfEx03SeedGeneratorEligibleFactors, hrfEx03SeedSingleProductSets,
  hrfEx03SeedGeneratorAudit, hrfEx03SeedLeadingU, hrfEx03RunSeedObstruction, hrfEx03RunVertexObstruction,
  hrfEx03SeedExpectedGeneratorFactors, hrfEx03SeedRouteComparison,
  hrfEx03SeedRouteComparisonTable, hrfEx03SeedRouteComparisonCondensedTable,
  hrfEx03SeedGeneratorSelectionTable, hrfEx03SeedRouteComparisonSummary,
  hrfEx03SeedLegacyBinomialSafeFactors, hrfEx03SeedPolynomialSafeFactors,
  hrfEx03SeedRouteSingleProductDiag,   hrfEx03SeedCanonicalClassIndex,
  hrfFivePointCompact, hrfFivePointCanonicalKey, hrfFivePointCanonicalFactorTable,
  hrfFivePointGeneratorPairAuditTable, hrfFivePointObstructionTrialTable,
  hrfFivePointGeneratorStudy, hrfFivePointRouteStudy, hrfEx03SeedFivePointRouteStudy,
  hrfPolynomialCompactAvailableQ
];

hrfEx03SeedSay[msg_] := If[! TrueQ[$HRFQuietReports], Print["[Example 03 seed] ", msg]];

hrfEx03SeedObstructionOptions[] := Join[
  hrfKinematicLimitObstructionOptions["Collinear5pt"],
  {
    "UseExtendedFactors" -> False,
    "DimensionfulKinVars" -> CollinearDimensionfulKinVars,
    "StopOnFirstAdmissible" -> False,
    "U" -> hrfEx03SeedLeadingU[]
  }
];

(* Same call chain as findObstructions with UseExtendedFactors -> False. *)
hrfPolynomialCompactAvailableQ[] := Length[DownValues[hrfPolynomialCompact]] > 0;

hrfEx03SeedLegacyBinomialSafeFactors[] := Module[{},
  hrfEx03SeedStudyLoad[];
  Select[
    hrfLegacyBinomialSafeFactors[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars],
    positiveCompatibleQ[#, VarsSeed5pt, KinAssump, KinVars] &
  ]
];

hrfEx03SeedObstructionSafeFactors[] := Module[{},
  hrfEx03SeedStudyLoad[];
  safeCancellationFactors[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars][[1]]
];

hrfEx03SeedPolynomialSafeFactors[] := Module[{},
  hrfEx03SeedStudyLoad[];
  hrfSafeCancellationFactorsPolynomial[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars][[1]]
];

hrfEx03SeedCanonicalKey[f_] := Module[{c},
  c = hrfCanonicalCancellationFactor[f, VarsSeed5pt, KinVars];
  If[TrueQ[c === 0], "--", ToString[InputForm[c]]]
];

hrfEx03SeedCanonicalClassIndex[factors_List] := Module[{keys, reps, i},
  keys = hrfEx03SeedCanonicalKey /@ factors;
  keys = Select[keys, StringQ[#] && # =!= "--" &];
  reps = Table[
    First @ Select[factors, hrfEx03SeedCanonicalKey[#] === keys[[i]] &],
    {i, Length[keys]}
  ];
  AssociationThread[keys -> reps]
];

hrfEx03SeedPoolHasCanonicalKeyQ[pool_List, key_String] :=
  MemberQ[hrfEx03SeedCanonicalKey /@ pool, key];

hrfEx03SeedSelectedKeys[route_Association] :=
  hrfEx03SeedCanonicalKey /@ Lookup[route, "SelectedFactors", {}];

hrfFivePointCompact[f_, vars_, kinVars_] := Module[{c},
  If[Length[DownValues[hrfFormatCancellationFactorDisplay]] > 0,
    Return[hrfFormatCancellationFactorDisplay[f, vars, kinVars]]
  ];
  c = If[ValueQ[hrfCanonicalCancellationFactor],
    hrfCanonicalCancellationFactor[f, vars, kinVars],
    Factor[f]
  ];
  If[TrueQ[c === 0], "--", ToString[InputForm[c]]]
];

hrfFivePointCanonicalKey[f_, vars_, kinVars_] := hrfFivePointCompact[f, vars, kinVars];

hrfFivePointCanonicalFactorTable[F0_, vars_, kinAssump_, kinVars_, label_String] := Module[
  {binSafe, polySafe, binKeys, polyKeys, allKeys, chosenKeys, expectedKeys, rows, key, rep},
  hrfEx03SeedStudyLoad[];
  polySafe = Select[
    hrfSafeCancellationFactorsPolynomial[F0, vars, kinAssump, kinVars][[1]],
    hrfCancellationFactorAdmissibleShapeQ[#, vars] &
  ];
  binSafe = Select[
    hrfLegacyBinomialSafeFactors[F0, vars, kinAssump, kinVars],
    positiveCompatibleQ[#, vars, kinAssump, kinVars] &&
      hrfCancellationFactorAdmissibleShapeQ[#, vars] &
  ];
  chosenKeys = hrfFivePointCanonicalKey @@@ (
    hrfResolveSingleProductGeneratorFactors[
      hrfFilterFactorsForGenerators[polySafe, vars, F0, <|"KinVars" -> kinVars|>]["Factors"],
      vars, kinAssump, kinVars, F0, hrfEx03SeedCollinearGeneratorOpts[]
    ]
  );
  expectedKeys = hrfFivePointCanonicalKey @@@ (
    Module[{bin = Select[hrfLegacyBinomialSafeFactors[F0, vars, kinAssump, kinVars], binomialQ[#, vars] &]},
      If[Length[bin] >= 2, Take[bin, 2], bin]
    ]
  );
  allKeys = Union[
    hrfFivePointCanonicalKey[#, vars, kinVars] & /@ Join[binSafe, polySafe],
    chosenKeys,
    expectedKeys
  ];
  allKeys = Select[allKeys, StringQ[#] && # =!= "--" &];
  rows = Flatten @ Table[
    key = allKeys[[i]];
    rep = Module[{m = Select[Join[binSafe, polySafe],
        hrfFivePointCanonicalKey[#, vars, kinVars] === key &
      ]},
      If[m === {}, Missing["NotFound"], First[m]]
    ];
    If[! MatchQ[rep, _Missing], <|
      "Topology" -> label,
      "Canonical" -> hrfFivePointCompact[rep, vars, kinVars],
      "BinomialSafePoolQ" -> MemberQ[hrfFivePointCanonicalKey[#, vars, kinVars] & /@ binSafe, key],
      "PolynomialSafePoolQ" -> MemberQ[hrfFivePointCanonicalKey[#, vars, kinVars] & /@ polySafe, key],
      "PolynomialOnlyQ" -> MemberQ[hrfFivePointCanonicalKey[#, vars, kinVars] & /@ polySafe, key] &&
        ! MemberQ[hrfFivePointCanonicalKey[#, vars, kinVars] & /@ binSafe, key],
      "ChosenForGeneratorQ" -> MemberQ[chosenKeys, key],
      "ExpectedGeneratorFactorQ" -> MemberQ[expectedKeys, key],
      "FactorClass" -> If[ValueQ[hrfClassifyCancellationFactor],
        hrfClassifyCancellationFactor[rep, vars],
        If[binomialQ[rep, vars], "binomial", "other"]
      ]
    |>, {}],
    {i, Length[allKeys]}
  ];
  Dataset @ SortBy[rows, {-TrueQ[Lookup[#, "ChosenForGeneratorQ", False]] &,
    -TrueQ[Lookup[#, "ExpectedGeneratorFactorQ", False]] &,
    -TrueQ[Lookup[#, "PolynomialSafePoolQ", False]] &, Lookup[#, "Canonical", ""] &}]
];

hrfFivePointGeneratorPairAuditTable[F0_, vars_, kinAssump_, kinVars_, safe_List, label_String,
   opts_: <||>] := Module[
  {genOpts, eligible, bounds, skipPDFQ, allPairs, pairs, kinFilteredCount,
   includeKinFilteredQ, chosen, chosenGen, chosenKey, resolverRank, rows, i, fac, gen,
   pdfQ, degQ, f0Q, linQ, kinQ, pairQ, rank, d1, d2, kinPrefilterLoadedQ, orderPairLoadedQ},
  hrfEx03SeedStudyLoad[];
  genOpts = Join[hrfEx03SeedCollinearGeneratorOpts[], <|"KinVars" -> kinVars|>, opts];
  includeKinFilteredQ = TrueQ[Lookup[genOpts, "IncludeKinFilteredPairs", False]];
  eligible = hrfFilterFactorsForGenerators[safe, vars, F0, genOpts]["Factors"];
  bounds = hrfResolveGeneratorDegreeBounds[F0, vars, genOpts];
  skipPDFQ = hrfSkipPDFFindInstanceQ[bounds] || TrueQ[Lookup[genOpts, "SkipPDFFindInstanceQ", False]];
  allPairs = Subsets[eligible, {2}];
  kinPrefilterLoadedQ = Length[DownValues[hrfGeneratorPairKinPrefilterQ]] > 0;
  orderPairLoadedQ = Length[DownValues[hrfOrderCancellationPairByXDegree]] > 0;
  pairs = If[includeKinFilteredQ || ! kinPrefilterLoadedQ,
    allPairs,
    Select[allPairs, hrfGeneratorPairKinPrefilterQ[#[[1]], #[[2]], kinVars] &]
  ];
  kinFilteredCount = If[kinPrefilterLoadedQ,
    Length[allPairs] - Length[Select[allPairs, hrfGeneratorPairKinPrefilterQ[#[[1]], #[[2]], kinVars] &]],
    0
  ];
  chosen = hrfResolveSingleProductGeneratorFactors[eligible, vars, kinAssump, kinVars, F0, genOpts];
  chosenGen = If[chosen === {}, 0, Expand[Times @@ chosen]];
  chosenKey = If[chosen === {}, "--",
    Module[{ord},
      ord = If[orderPairLoadedQ,
        hrfOrderCancellationPairByXDegree[chosen[[1]], chosen[[2]], vars],
        chosen
      ];
      StringRiffle[hrfFivePointCanonicalKey[#, vars, kinVars] & /@ ord, " * "]
    ]
  ];
  resolverRank[pair_List] := Total[hrfPolynomialMonomialCount[#, vars] & /@ pair];
  rows = Table[
    fac = If[orderPairLoadedQ,
      hrfOrderCancellationPairByXDegree[pairs[[i, 1]], pairs[[i, 2]], vars],
      pairs[[i]]
    ];
    gen = Expand[Times @@ fac];
    kinQ = ! kinPrefilterLoadedQ || hrfGeneratorPairKinPrefilterQ[fac[[1]], fac[[2]], kinVars];
    pdfQ = skipPDFQ || simultaneouslyAdmissibleSubsetQ[fac, vars, kinAssump, kinVars];
    degQ = hrfGeneratorDegreeAdmissibleQ[gen, bounds, vars, F0, kinVars];
    f0Q = hrfGeneratorF0SupportAdmissibleQ[gen, F0, vars, kinVars, Automatic];
    linQ = kinVars === {} || Length[DownValues[hrfFactorMandelstamLinearQ]] === 0 ||
      And @@ (hrfFactorMandelstamLinearQ[#, kinVars] & /@ fac);
    pairQ = kinQ && pdfQ && degQ && f0Q && linQ;
    rank = resolverRank[fac];
    d1 = hrfPolynomialTotalDegreeInVars[fac[[1]], vars];
    d2 = hrfPolynomialTotalDegreeInVars[fac[[2]], vars];
    <|
      "Topology" -> label,
      "PairIndex" -> i,
      "Factor1" -> hrfFivePointCanonicalKey[fac[[1]], vars, kinVars],
      "Factor2" -> hrfFivePointCanonicalKey[fac[[2]], vars, kinVars],
      "Factor1XDegree" -> d1,
      "Factor2XDegree" -> d2,
      "FactorizedGenerator" -> If[ValueQ[hrfFactorizeGeneratorForOutput],
        ToString[InputForm[hrfFactorizeGeneratorForOutput[gen, safe, vars, kinVars]]],
        ToString[InputForm[Factor[gen]]]
      ],
      "KinPrefilterQ" -> kinQ,
      "JointPDFQ" -> pdfQ,
      "DegreeAdmissibleQ" -> degQ,
      "F0SupportQ" -> f0Q,
      "MandelstamLinearQ" -> linQ,
      "PairAdmissibleQ" -> pairQ,
      "ResolverMonomialRank" -> rank,
      "ChosenByResolverQ" -> chosenGen =!= 0 && TrueQ[Expand[gen - chosenGen] === 0],
      "RejectionReason" -> Which[
        ! kinQ, If[TrueQ[Expand[fac[[1]] - fac[[2]]] === 0],
          "kin-dependent factor squared",
          "shared kinematic variable"
        ],
        pairQ && chosenGen =!= 0 && TrueQ[Expand[gen - chosenGen] === 0], "chosen",
        ! pdfQ, "joint PDF (5.12) fails",
        ! degQ, "degree / massless monomial bound",
        ! f0Q, "F0 monomial support",
        ! linQ, "nonlinear in Mandelstam vars (individual f_k)",
        pairQ, "admissible but not chosen (resolver rank)",
        True, "multiple failures"
      ]
    |>,
    {i, Length[pairs]}
  ];
  <|
    "Table" -> Dataset @ SortBy[rows, {-TrueQ[Lookup[#, "ChosenByResolverQ", False]] &,
      -TrueQ[Lookup[#, "PairAdmissibleQ", False]] &, Lookup[#, "ResolverMonomialRank", Infinity] &}],
    "Summary" -> <|
      "EligibleFactorCount" -> Length[eligible],
      "TotalPairCount" -> Length[allPairs],
      "KinPrefilteredOutCount" -> kinFilteredCount,
      "ListedPairCount" -> Length[pairs]
    |>
  |>
];

hrfFivePointObstructionTrialTable[scan_Association, safe_, vars_, kinVars_, label_String] := Module[
  {trials, rows, i, t, od, reason},
  trials = Lookup[scan, "ObstructionAttemptData", {}];
  If[! ListQ[trials] || trials === {}, Return[Dataset[{}]]];
  rows = Table[
    t = trials[[i]];
    od = Lookup[t, "ObstructionData", Missing[]];
    reason = Lookup[t, "ObstructionAttemptData", <||>]["RejectedReason"];
    If[! StringQ[reason],
      reason = Which[
        ! TrueQ[Lookup[t, "PerGeneratorAdmissibleQ", False]], "per-generator admissibility",
        MatchQ[od, _Missing], ToString[od],
        AssociationQ[od] && KeyExistsQ[od, "Superleading"] &&
            ! hrfValidObstructionResultQ[od, Lookup[t, "Generators", {}], vars, kinVars],
          "no exact SL obstruction",
        TrueQ[Lookup[t, "AdmissibleSLSectorQ", False]] &&
            hrfValidObstructionTrialQ[t, vars, kinVars], "valid obstruction (pre-scaling)",
        TrueQ[Lookup[t, "AdmissibleSLSectorQ", False]], "SL sector admissible",
        True, "failed SL-sector PDF / ideal check"
      ]
    ];
    <|
      "Topology" -> label,
      "TrialIndex" -> i,
      "GeneratorCount" -> Length[Lookup[t, "Generators", {}]],
      "FactorizedGenerator" -> If[Lookup[t, "Generators", {}] =!= {},
        ToString[InputForm[hrfFactorizeGeneratorForOutput[First[t["Generators"]], safe, vars, kinVars]]],
        "--"
      ],
      "PerGeneratorAdmissibleQ" -> Lookup[t, "PerGeneratorAdmissibleQ", False],
      "CandidateUnionPDFQ" -> Lookup[t, "SimultaneouslyAdmissibleGeneratorSetQ", False],
      "SLDecompositionFoundQ" -> AssociationQ[od] && ! MatchQ[od, _Missing] &&
        KeyExistsQ[od, "Superleading"] &&
        hrfValidObstructionResultQ[od, Lookup[t, "Generators", {}], vars, kinVars],
      "AdmissibleSLSectorQ" -> Lookup[t, "AdmissibleSLSectorQ", False],
      "ValidObstructionTrialQ" -> hrfValidObstructionTrialQ[t, vars, kinVars],
      "HiddenRegionQ" -> Lookup[t, "HiddenRegionQ", Missing["NotEvaluated"]],
      "ValidScalingQ" -> Lookup[t, "ValidScalingQ", Missing["NotEvaluated"]],
      "Outcome" -> reason
    |>,
    {i, Length[trials]}
  ];
  Dataset[rows]
];

hrfFivePointGeneratorStudy[F0_, vars_, kinAssump_, kinVars_, label_String, opts_: <||>] := Module[
  {polySafe, binSafe, genOpts, binRoute, polyRoute, scan, scanOpts, pairAudit, skipObstructionQ},
  hrfEx03SeedStudyLoad[];
  skipObstructionQ = TrueQ[Lookup[opts, "SkipObstructionScans", False]];
  polySafe = hrfSafeCancellationFactorsPolynomial[F0, vars, kinAssump, kinVars][[1]];
  binSafe = Select[
    hrfLegacyBinomialSafeFactors[F0, vars, kinAssump, kinVars],
    positiveCompatibleQ[#, vars, kinAssump, kinVars] &
  ];
  genOpts = Join[hrfEx03SeedCollinearGeneratorOpts[], <|"KinVars" -> kinVars|>, opts];
  binRoute = Module[{eligible, genFF, bounds, skipPDFQ, admissiblePairs},
    eligible = hrfFilterFactorsForGenerators[binSafe, vars, F0, genOpts]["Factors"];
    bounds = hrfResolveGeneratorDegreeBounds[F0, vars, genOpts];
    genFF = hrfResolveSingleProductGeneratorFactors[eligible, vars, kinAssump, kinVars, F0, genOpts];
    skipPDFQ = hrfSkipPDFFindInstanceQ[bounds] || TrueQ[Lookup[genOpts, "SkipPDFFindInstanceQ", False]];
    admissiblePairs = Select[Subsets[eligible, {2}],
      (skipPDFQ || simultaneouslyAdmissibleSubsetQ[#, vars, kinAssump, kinVars]) &&
        hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ #], bounds, vars, F0, kinVars] &
    ];
    <|
      "Route" -> "BinomialSafePool",
      "SafeCount" -> Length[binSafe],
      "EligibleCount" -> Length[eligible],
      "AdmissiblePairCount" -> Length[admissiblePairs],
      "SelectedFactorCount" -> Length[genFF],
      "SelectedFactors" -> genFF,
      "SelectedFactorKeys" -> hrfFivePointCanonicalKey[#, vars, kinVars] & /@ genFF,
      "SelectedFactorsDisplay" -> If[hrfPolynomialCompactAvailableQ[],
        hrfPolynomialCompact /@ genFF, InputForm /@ genFF],
      "FullGenerator" -> If[genFF === {}, 0, Expand[Times @@ genFF]],
      "UsesLegacyBinomialSelectionQ" -> Length[genFF] <= 2 &&
        SubsetQ[binSafe, genFF] && Length[Select[genFF, binomialQ[#, vars] &]] === Length[genFF]
    |>
  ];
  polyRoute = Module[{eligible, genFF, bounds, skipPDFQ, admissiblePairs},
    eligible = hrfFilterFactorsForGenerators[polySafe, vars, F0, genOpts]["Factors"];
    bounds = hrfResolveGeneratorDegreeBounds[F0, vars, genOpts];
    genFF = hrfResolveSingleProductGeneratorFactors[eligible, vars, kinAssump, kinVars, F0, genOpts];
    skipPDFQ = hrfSkipPDFFindInstanceQ[bounds] || TrueQ[Lookup[genOpts, "SkipPDFFindInstanceQ", False]];
    admissiblePairs = Select[Subsets[eligible, {2}],
      (skipPDFQ || simultaneouslyAdmissibleSubsetQ[#, vars, kinAssump, kinVars]) &&
        hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ #], bounds, vars, F0, kinVars] &
    ];
    <|
      "Route" -> "PolynomialSafePool",
      "SafeCount" -> Length[polySafe],
      "EligibleCount" -> Length[eligible],
      "AdmissiblePairCount" -> Length[admissiblePairs],
      "SelectedFactorCount" -> Length[genFF],
      "SelectedFactors" -> genFF,
      "SelectedFactorKeys" -> hrfFivePointCanonicalKey[#, vars, kinVars] & /@ genFF,
      "SelectedFactorsDisplay" -> If[hrfPolynomialCompactAvailableQ[],
        hrfPolynomialCompact /@ genFF, InputForm /@ genFF],
      "FullGenerator" -> If[genFF === {}, 0, Expand[Times @@ genFF]],
      "UsesLegacyBinomialSelectionQ" -> False
    |>
  ];
  scan = If[skipObstructionQ, <||>,
    scanOpts = Join[
      {
        "GeneratorMode" -> "SingleProduct",
        "UseExtendedFactors" -> False,
        "DimensionfulKinVars" -> CollinearDimensionfulKinVars,
        "RelaxSingleProductDegreeQ" -> False,
        "SkipPDFFindInstanceQ" -> False,
        "StopOnFirstAdmissible" -> False,
        "StoreAllObstructionTrialsQ" -> True
      },
      Normal @ KeyDrop[Join[<||>, opts], {"SkipObstructionScans", "SkipVertexObstructionScans"}]
    ];
    findObstructions[F0, vars, kinAssump, kinVars, Automatic, Sequence @@ scanOpts]
  ];
  pairAudit = hrfFivePointGeneratorPairAuditTable[F0, vars, kinAssump, kinVars, polySafe, label, opts];
  <|
    "Topology" -> label,
    "BinomialSafeFactors" -> binSafe,
    "PolynomialSafeFactors" -> polySafe,
    "BinomialRoute" -> binRoute,
    "PolynomialRoute" -> polyRoute,
    "GeneratorRoutes" -> {binRoute, polyRoute},
    "NonBinomialGeneratorSelectedQ" -> polyRoute["SelectedFactorCount"] > 0 &&
      ! TrueQ[polyRoute["UsesLegacyBinomialSelectionQ"]],
    "BinomialRouteMatchesPolynomialQ" -> binRoute["SelectedFactorCount"] === polyRoute["SelectedFactorCount"] &&
      binRoute["SelectedFactorCount"] > 0 &&
      Expand[binRoute["FullGenerator"] - polyRoute["FullGenerator"]] === 0,
    "GeneratorSelectionTable" -> Dataset @ {
      <|
        "Topology" -> label,
        "Route" -> "BinomialSafePool",
        "SafePoolCount" -> binRoute["SafeCount"],
        "EligibleCount" -> binRoute["EligibleCount"],
        "AdmissiblePairCount" -> binRoute["AdmissiblePairCount"],
        "SelectedFactorCount" -> binRoute["SelectedFactorCount"],
        "SelectedFactors" -> StringRiffle[binRoute["SelectedFactorsDisplay"], " * "],
        "UsesLegacyBinomialSelectionQ" -> binRoute["UsesLegacyBinomialSelectionQ"]
      |>,
      <|
        "Topology" -> label,
        "Route" -> "PolynomialSafePool",
        "SafePoolCount" -> polyRoute["SafeCount"],
        "EligibleCount" -> polyRoute["EligibleCount"],
        "AdmissiblePairCount" -> polyRoute["AdmissiblePairCount"],
        "SelectedFactorCount" -> polyRoute["SelectedFactorCount"],
        "SelectedFactors" -> StringRiffle[polyRoute["SelectedFactorsDisplay"], " * "],
        "UsesLegacyBinomialSelectionQ" -> polyRoute["UsesLegacyBinomialSelectionQ"]
      |>
    },
    "CanonicalFactorTable" -> hrfFivePointCanonicalFactorTable[F0, vars, kinAssump, kinVars, label],
    "GeneratorPairAuditTable" -> pairAudit["Table"],
    "GeneratorPairAuditSummary" -> pairAudit["Summary"],
    "ObstructionTrialTable" -> If[scan === <||>, Dataset[{}],
      hrfFivePointObstructionTrialTable[scan, polySafe, vars, kinVars, label]
    ],
    "Scan" -> scan,
    "HiddenRegionQ" -> If[scan === <||>, Missing["Skipped"], hrfFPObstructionRegionPresentQ[scan]],
    "AttemptSummary" -> If[scan === <||>, Missing["Skipped"], Lookup[scan, "ObstructionAttemptSummary", <||>]]
  |>
];

hrfEx03RunVertexObstruction[] := Module[{study},
  hrfEx03SeedStudyLoad[];
  study = hrfFivePointGeneratorStudy[
    F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars, "ThreeLoopVertex",
    <|"U" -> hrfEx03LeadingDeltaPolynomial[Expand[UThreeLoopVertex5pt /. collPar1]]|>
  ];
  Ex03VertexObstruction = study;
  hrfEx03SeedSay["ThreeLoopVertex obstruction: HiddenRegionQ=" <> ToString[study["HiddenRegionQ"]] <>
    " generators=" <> ToString[Length[Lookup[study["Scan"], "Generators", {}]]] <>
    " (pair audit + trial log in study association)"];
  study
];

hrfEx03SeedGeneratorEligibleFactors[safe_List] :=
  hrfFilterFactorsForGenerators[safe, VarsSeed5pt, F0Seed5pt, <||>]["Factors"];

hrfEx03SeedFactorAudit[] := Module[{pack, filtered, safe, audit},
  hrfEx03SeedStudyLoad[];
  pack = hrfRawPolynomialCandidates[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars, Automatic];
  filtered = hrfFilterPolynomialCandidates[pack["Raw"], VarsSeed5pt, KinAssump, KinVars, "Polynomial"];
  safe = hrfEx03SeedObstructionSafeFactors[];
  audit = If[ValueQ[$HRFPolynomialLastFactorAudit], $HRFPolynomialLastFactorAudit, <||>];
  <|
    "HarvestRaw" -> pack["Raw"],
    "PreNormalizeAccepted" -> filtered["Accepted"],
    "SafeFactors" -> safe,
    "GeneratorEligibleFactors" -> hrfEx03SeedGeneratorEligibleFactors[safe],
    "HarvestRawCount" -> Length[pack["Raw"]],
    "PreNormalizeCount" -> Length[filtered["Accepted"]],
    "SafeCount" -> Length[safe],
    "GeneratorEligibleCount" -> Length[hrfEx03SeedGeneratorEligibleFactors[safe]],
    "RejectedCount" -> Length[filtered["Rejected"]],
    "PolynomialAudit" -> audit
  |>
];

hrfEx03SeedFactorTable[] := Module[{audit, rows, i, raw, canon, shellRemoved},
  audit = hrfEx03SeedFactorAudit[];
  rows = Table[
    raw = audit["PreNormalizeAccepted"][[i]];
    canon = hrfCanonicalCancellationFactor[raw, VarsSeed5pt, KinVars];
    shellRemoved = hrfCanonicalCancellationFactorShellRemoved[raw, VarsSeed5pt, KinVars];
    <|
      "Index" -> i,
      "PreNormalize" -> hrfPolynomialCompact[raw],
      "Canonical" -> If[Length[DownValues[hrfPolynomialCompactDisplay]] > 0,
        hrfPolynomialCompactDisplay[canon, VarsSeed5pt, KinVars],
        hrfPolynomialCompact[canon]
      ],
      "ShellRemoved" -> shellRemoved,
      "EquivalenceClass" -> hrfCanonicalCancellationFactorKey[raw, VarsSeed5pt, KinVars],
      "InSafePoolQ" -> hrfMemberCanonicalCancellationFactorQ[audit["SafeFactors"], raw, VarsSeed5pt, KinVars],
      "MandelstamLinearQ" -> If[Length[DownValues[hrfFactorMandelstamLinearQ]] > 0,
        hrfFactorMandelstamLinearQ[canon, KinVars],
        True
      ]
    |>,
    {i, Length[audit["PreNormalizeAccepted"]]}
  ];
  Dataset[rows]
];

hrfEx03SeedCollinearGeneratorOpts[] := <|
  "RelaxSingleProductDegreeQ" -> False,
  "SkipPDFFindInstanceQ" -> False
|>;

hrfEx03SeedGeneratorAudit[] := Module[
  {audit, safe, eligible, opts, genFF, binFF, safeSets, simLegacyQ, bounds, fullGen, skipPDFQ},
  audit = hrfEx03SeedFactorAudit[];
  safe = audit["SafeFactors"];
  eligible = audit["GeneratorEligibleFactors"];
  opts = hrfEx03SeedCollinearGeneratorOpts[];
  bounds = hrfResolveGeneratorDegreeBounds[F0Seed5pt, VarsSeed5pt, opts];
  skipPDFQ = hrfSkipPDFFindInstanceQ[bounds];
  binFF = hrfLegacyBinomialSafeFactors[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars];
  genFF = hrfResolveSingleProductGeneratorFactors[
    eligible, VarsSeed5pt, KinAssump, KinVars, F0Seed5pt, opts
  ];
  simLegacyQ = If[skipPDFQ, True,
    Length[binFF] >= 2 &&
      simultaneouslyAdmissibleSubsetQ[binFF, VarsSeed5pt, KinAssump, KinVars]
  ];
  fullGen = If[genFF === {}, 0, Expand[Times @@ genFF]];
  safeSets = hrfEx03SeedSingleProductSets[safe];
  <|
    "GeneratorMode" -> "SingleProduct",
    "UseExtendedFactors" -> False,
    "RelaxSingleProductDegreeQ" -> False,
    "SkipPDFFindInstanceQ" -> False,
    "SafeFactorCount" -> Length[safe],
    "GeneratorEligibleFactorCount" -> Length[eligible],
    "BinomialEligibleFactorCount" -> Length[binFF],
    "SingleProductGeneratorFactorCount" -> Length[genFF],
    "SimultaneouslyAdmissibleLegacyBinomialPoolQ" -> simLegacyQ,
    "SafeSingleProductSets" -> safeSets,
    "SafeSingleProductSetCount" -> Length[safeSets],
    "SimultaneouslyAdmissibleGeneratorPoolQ" -> simLegacyQ,
    "FullProductDegreeAdmissibleQ" -> genFF =!= {} &&
      hrfGeneratorDegreeAdmissibleQ[fullGen, bounds, VarsSeed5pt, F0Seed5pt, KinVars],
    "NonlinearSafeFactors" -> Select[safe,
      Length[DownValues[hrfFactorMandelstamLinearQ]] > 0 && ! hrfFactorMandelstamLinearQ[#, KinVars] &
    ]
  |>
];

hrfEx03SeedSingleProductSets[factors_List] := candidateGeneratorSets[
  factors, VarsSeed5pt, KinAssump, KinVars, F0Seed5pt, hrfEx03SeedCollinearGeneratorOpts[]
];

hrfEx03SeedLeadingU[] := hrfEx03LeadingDeltaPolynomial[Expand[USeed5pt /. collPar1]];

(* Reference coupled generator and its two binomial f_k factors (up to normalization). *)
hrfEx03SeedExpectedGeneratorFactors[] := Module[{f1, f2, gen},
  hrfEx03SeedStudyLoad[];
  f1 = Select[hrfLegacyBinomialSafeFactors[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars],
    FreeQ[Expand[#], z] &];
  f2 = Select[hrfLegacyBinomialSafeFactors[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars],
    ! FreeQ[Expand[#], z] &];
  If[Length[f1] >= 1 && Length[f2] >= 1,
    {First[f1], First[f2]},
    Module[{bin = hrfLegacyBinomialSafeFactors[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars]},
      If[Length[bin] >= 2, Take[bin, 2], bin]
    ]
  ]
];

hrfEx03SeedRouteSingleProductDiag[safe_List, label_String, opts_Association] := Module[
  {eligible, bounds, genFF, fullGen, sets, setData, allVars, dividers, simPoolQ, simGenQ,
   degQ, skipPDFQ, relaxQ, admissiblePairs},
  eligible = hrfFilterFactorsForGenerators[safe, VarsSeed5pt, F0Seed5pt, opts]["Factors"];
  bounds = hrfResolveGeneratorDegreeBounds[F0Seed5pt, VarsSeed5pt, opts];
  genFF = hrfResolveSingleProductGeneratorFactors[
    eligible, VarsSeed5pt, KinAssump, KinVars, F0Seed5pt, opts
  ];
  fullGen = If[genFF === {}, 0, Expand[Times @@ genFF]];
  sets = candidateGeneratorSets[safe, VarsSeed5pt, KinAssump, KinVars, F0Seed5pt, opts];
  setData = If[sets =!= {},
    generatorSetAdmissibilityData[First[sets], safe, VarsSeed5pt, KinVars, KinAssump, bounds, F0Seed5pt],
    <||>
  ];
  allVars = DeleteDuplicates @ Join[VarsSeed5pt, KinVars];
  dividers = If[sets =!= {},
    factorsDividingGenerator[First[First[sets]], safe, allVars, VarsSeed5pt, KinVars],
    {}
  ];
  skipPDFQ = hrfSkipPDFFindInstanceQ[bounds] || TrueQ[Lookup[opts, "SkipPDFFindInstanceQ", False]];
  relaxQ = hrfCollinearSingleProductLegacyQ[bounds] || TrueQ[Lookup[opts, "RelaxSingleProductDegreeQ", False]];
  simPoolQ = If[genFF === {}, False, simultaneouslyAdmissibleSubsetQ[genFF, VarsSeed5pt, KinAssump, KinVars]];
  simGenQ = If[dividers === {}, False, simultaneouslyAdmissibleSubsetQ[dividers, VarsSeed5pt, KinAssump, KinVars]];
  degQ = genFF =!= {} && hrfGeneratorDegreeAdmissibleQ[fullGen, bounds, VarsSeed5pt, F0Seed5pt, KinVars];
  admissiblePairs = Select[Subsets[eligible, {2}],
    (skipPDFQ || simultaneouslyAdmissibleSubsetQ[#, VarsSeed5pt, KinAssump, KinVars]) &&
      hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ #], bounds, VarsSeed5pt, F0Seed5pt, KinVars] &
  ];
  <|
    "Route" -> label,
    "SafeCount" -> Length[safe],
    "EligibleCount" -> Length[eligible],
    "AdmissiblePairCount" -> Length[admissiblePairs],
    "SelectedFactorCount" -> Length[genFF],
    "SelectedFactors" -> genFF,
    "SelectedFactorKeys" -> hrfEx03SeedCanonicalKey /@ genFF,
    "SelectedFactorsDisplay" -> If[hrfPolynomialCompactAvailableQ[],
      hrfPolynomialCompact /@ genFF, InputForm /@ genFF],
    "FullGenerator" -> If[genFF === {}, 0, fullGen],
    "FullGeneratorFactorized" -> If[sets =!= {},
      hrfFactorizeGeneratorForOutput[First[First[sets]], safe, VarsSeed5pt, KinVars],
      "--"],
    "FullGeneratorFactorizedDisplay" -> If[sets =!= {},
      If[hrfPolynomialCompactAvailableQ[],
        hrfPolynomialCompact[
          hrfFactorizeGeneratorForOutput[First[First[sets]], safe, VarsSeed5pt, KinVars]
        ],
        ToString[InputForm[
          hrfFactorizeGeneratorForOutput[First[First[sets]], safe, VarsSeed5pt, KinVars]
        ]]
      ],
      "--"],
    "CandidateSetCount" -> Length[sets],
    "PerGeneratorAdmissibleQ" -> TrueQ[Lookup[setData, "PerGeneratorAdmissibleQ", False]],
    "SetUnionPDFQ" -> TrueQ[Lookup[setData, "SimultaneouslyAdmissibleGeneratorSetQ", False]],
    "DividingFactorCount" -> Length[dividers],
    "DividingFactors" -> dividers,
    "SimultaneousOnSelectedQ" -> simPoolQ,
    "SimultaneousOnDividersQ" -> simGenQ,
    "FullProductDegreeAdmissibleQ" -> degQ,
    "SkipPDFFindInstanceQ" -> skipPDFQ,
    "RelaxSingleProductDegreeQ" -> relaxQ,
    "UsesLegacyBinomialSelectionQ" -> relaxQ && Length[genFF] <= 2 &&
      SubsetQ[hrfLegacyBinomialSafeFactors[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars], genFF]
  |>
];

hrfEx03SeedRouteComparisonTable[comparison_Association] := Module[
  {expected = Lookup[comparison, "ExpectedFactors", {}],
   rawDeriv = Lookup[comparison, "RawDerivativeFactors", {}],
   binSafe = Lookup[comparison, "BinomialSafeFactors", {}],
   polySafeCanon = Lookup[comparison, "PolynomialSafeCanonicalFactors",
     Lookup[comparison, "PolynomialSafeFactors", {}]],
   polySafeRaw = Lookup[comparison, "PolynomialSafeRawFactors", {}],
   binSel = Lookup[comparison, {"BinomialRoute", "SelectedFactors"}, {}],
   polySel = Lookup[comparison, {"PolynomialRouteStrict", "SelectedFactors"},
     Lookup[comparison, {"PolynomialRoute", "SelectedFactors"}, {}]],
   binSelKeys, polySelKeys, expectedKeys, unionFactors, rows, i, f, canon, shellRemoved},
  binSelKeys = hrfEx03SeedCanonicalKey /@ binSel;
  polySelKeys = hrfEx03SeedCanonicalKey /@ polySel;
  expectedKeys = hrfEx03SeedCanonicalKey /@ expected;
  unionFactors = Select[
    DeleteDuplicates @ Join[
      hrfNormalizeCancellationCandidates[rawDeriv, VarsSeed5pt, KinVars],
      hrfNormalizeCancellationCandidates[binSafe, VarsSeed5pt, KinVars],
      polySafeCanon,
      hrfNormalizeCancellationCandidates[polySafeRaw, VarsSeed5pt, KinVars],
      hrfNormalizeCancellationCandidates[expected, VarsSeed5pt, KinVars]
    ],
    hrfCancellationFactorAdmissibleShapeQ[#, VarsSeed5pt] &
  ];
  rows = Table[
    f = unionFactors[[i]];
    canon = hrfCanonicalCancellationFactor[f, VarsSeed5pt, KinVars];
    shellRemoved = hrfCanonicalCancellationFactorShellRemoved[f, VarsSeed5pt, KinVars];
    <|
      "Index" -> i,
      "Raw" -> If[hrfPolynomialCompactAvailableQ[], hrfPolynomialCompact[f], ToString[InputForm[f]]],
      "Canonical" -> If[Length[DownValues[hrfPolynomialCompactDisplay]] > 0,
        hrfPolynomialCompactDisplay[canon, VarsSeed5pt, KinVars],
        hrfPolynomialCompact[canon]
      ],
      "ShellRemoved" -> shellRemoved,
      "InRawDerivativeQ" -> hrfEx03SeedPoolHasCanonicalKeyQ[rawDeriv, hrfEx03SeedCanonicalKey[f]],
      "InBinomialSafePoolQ" -> hrfEx03SeedPoolHasCanonicalKeyQ[binSafe, hrfEx03SeedCanonicalKey[f]],
      "InPolynomialSafePoolQ" -> hrfEx03SeedPoolHasCanonicalKeyQ[polySafeCanon, hrfEx03SeedCanonicalKey[f]],
      "BinomialRouteSelectedQ" -> MemberQ[binSelKeys, hrfEx03SeedCanonicalKey[f]],
      "PolynomialRouteSelectedQ" -> MemberQ[polySelKeys, hrfEx03SeedCanonicalKey[f]],
      "ExpectedGeneratorFactorQ" -> MemberQ[expectedKeys, hrfEx03SeedCanonicalKey[f]]
    |>,
    {i, Length[unionFactors]}
  ];
  Dataset[rows]
];

(* One row per canonical f_k class. Default: generator-relevant classes only. *)
hrfEx03SeedRouteComparisonCondensedTable[comparison_Association, scope_: "Generator"] := Module[
  {binSafe = Lookup[comparison, "BinomialSafeFactors", {}],
   polySafe = Lookup[comparison, "PolynomialSafeCanonicalFactors",
     Lookup[comparison, "PolynomialSafeFactors", {}]],
   expected = Lookup[comparison, "ExpectedFactors", {}],
   binRoute = Lookup[comparison, "BinomialRoute", <||>],
   polyRoute = Lookup[comparison, "PolynomialRouteStrict",
     Lookup[comparison, "PolynomialRoute", <||>]],
   binSelKeys, polySelKeys, expectedKeys, classIndex, allKeys, rows, key},
  binSelKeys = Lookup[binRoute, "SelectedFactorKeys",
    hrfEx03SeedCanonicalKey /@ Lookup[binRoute, "SelectedFactors", {}]];
  polySelKeys = Lookup[polyRoute, "SelectedFactorKeys",
    hrfEx03SeedCanonicalKey /@ Lookup[polyRoute, "SelectedFactors", {}]];
  expectedKeys = hrfEx03SeedCanonicalKey /@ expected;
  classIndex = Join[
    hrfEx03SeedCanonicalClassIndex[binSafe],
    hrfEx03SeedCanonicalClassIndex[polySafe],
    hrfEx03SeedCanonicalClassIndex[expected],
    hrfEx03SeedCanonicalClassIndex[Lookup[binRoute, "SelectedFactors", {}]],
    hrfEx03SeedCanonicalClassIndex[Lookup[polyRoute, "SelectedFactors", {}]]
  ];
  allKeys = Keys[classIndex];
  rows = Table[
    key = allKeys[[i]];
    <|
      "Canonical" -> key,
      "BinomialSafePoolQ" -> hrfEx03SeedPoolHasCanonicalKeyQ[binSafe, key],
      "PolynomialSafePoolQ" -> hrfEx03SeedPoolHasCanonicalKeyQ[polySafe, key],
      "BinomialRouteSelectedQ" -> MemberQ[binSelKeys, key],
      "PolynomialRouteSelectedQ" -> MemberQ[polySelKeys, key],
      "ExpectedGeneratorFactorQ" -> MemberQ[expectedKeys, key],
      "EntersGeneratorQ" -> MemberQ[binSelKeys, key] || MemberQ[polySelKeys, key]
    |>,
    {i, Length[allKeys]}
  ];
  rows = Switch[scope,
    "All", rows,
    "Pool", Select[rows, TrueQ[Lookup[#, "BinomialSafePoolQ", False]] ||
      TrueQ[Lookup[#, "PolynomialSafePoolQ", False]] &],
    _, Select[rows, TrueQ[Lookup[#, "EntersGeneratorQ", False]] ||
      TrueQ[Lookup[#, "ExpectedGeneratorFactorQ", False]] &]
  ];
  Dataset @ SortBy[rows, {-TrueQ[Lookup[#, "EntersGeneratorQ", False]] &,
    -TrueQ[Lookup[#, "ExpectedGeneratorFactorQ", False]] &, Lookup[#, "Canonical", ""] &}]
];

hrfEx03SeedGeneratorSelectionTable[comparison_Association] := Module[
  {routes, scan, rows},
  routes = Lookup[comparison, "GeneratorRoutes", {}];
  If[! ListQ[routes] || routes === {} || ! AssociationQ[First[routes]],
    routes = {
      Lookup[comparison, "BinomialRoute", <||>],
      Lookup[comparison, "PolynomialRouteStrict", Lookup[comparison, "PolynomialRoute", <||>]]
    }
  ];
  scan = Lookup[comparison, "ObstructionScan", <||>];
  rows = Table[
    <|
      "Route" -> routes[[i]]["Route"],
      "SafePoolCount" -> Lookup[routes[[i]], "SafeCount", 0],
      "EligibleCount" -> Lookup[routes[[i]], "EligibleCount", 0],
      "AdmissiblePairCount" -> Lookup[routes[[i]], "AdmissiblePairCount", 0],
      "SelectedFactorCount" -> Lookup[routes[[i]], "SelectedFactorCount", 0],
      "SelectedFactors" -> StringRiffle[Lookup[routes[[i]], "SelectedFactorsDisplay", {}], " * "],
      "FactorizedGenerator" -> Lookup[routes[[i]], "FullGeneratorFactorizedDisplay", "--"],
      "CandidateSetCount" -> Lookup[routes[[i]], "CandidateSetCount", 0],
      "PerGeneratorAdmissibleQ" -> Lookup[routes[[i]], "PerGeneratorAdmissibleQ", False],
      "JointPDFOnSelectedQ" -> Lookup[routes[[i]], "SimultaneousOnSelectedQ", False],
      "DegreeAdmissibleQ" -> Lookup[routes[[i]], "FullProductDegreeAdmissibleQ", False],
      "ObstructionHiddenRegionQ" -> If[i === Length[routes],
        Lookup[scan, "HiddenRegionQ", Missing["NotRun"]],
        Missing["UsePolynomialRouteScan"]
      ]
    |>,
    {i, Length[routes]}
  ];
  Dataset[rows]
];

hrfEx03SeedRouteComparisonSummary[comparison_Association] := Module[
  {bin = Lookup[comparison, "BinomialRoute", <||>],
   poly = Lookup[comparison, "PolynomialRouteStrict", Lookup[comparison, "PolynomialRoute", <||>]],
   scan = Lookup[comparison, "ObstructionScanPolynomial",
     Lookup[comparison, "ObstructionScan", <||>]],
   notes = {}},
  If[Length[Lookup[comparison, "PolynomialOnlyFactors", {}]] > 0,
    AppendTo[notes,
      "Polynomial safe pool adds " <> ToString[Length[comparison["PolynomialOnlyFactors"]]] <>
        " canonical classes beyond the legacy binomial pool (non-binomial derivative factors)."]
  ];
  If[Lookup[bin, "SelectedFactorCount", 0] === 2 && Lookup[poly, "SelectedFactorCount", 0] === 2 &&
      TrueQ[Lookup[comparison, "StrictSelectedMatchesExpectedQ", False]],
    AppendTo[notes,
      "Both routes select the same 2 canonical f_k after cleanup; polynomial pool is a superset for this seed."]
  ];
  If[Lookup[poly, "CandidateSetCount", 0] === 0,
    AppendTo[notes,
      "Polynomial route fails generator construction: selected count=" <>
        ToString[Lookup[poly, "SelectedFactorCount", 0]] <> ", admissible pairs=" <>
        ToString[Lookup[poly, "AdmissiblePairCount", 0]] <> "."]
  ];
  If[TrueQ[Lookup[comparison, "Line4Line15EquivalentQ", False]],
    AppendTo[notes,
      "Raw (1-z)-shelled and core f_k are one canonical class after Factor stripping of non-x_i shells."]
  ];
  <|
    "RootCauseSummary" -> If[notes === {}, {"Binomial and polynomial routes agree on generator factors."}, notes],
    "Counts" -> <|
      "LegacyBinomialSafe" -> Length[Lookup[comparison, "BinomialSafeFactors", {}]],
      "PolynomialSafeCanonical" -> Length[Lookup[comparison, "PolynomialSafeFactors", {}]],
      "BinomialRouteSelected" -> Lookup[bin, "SelectedFactorCount", 0],
      "PolynomialRouteSelected" -> Lookup[poly, "SelectedFactorCount", 0],
      "PolynomialAdmissiblePairs" -> Lookup[poly, "AdmissiblePairCount", 0]
    |>,
    "HiddenRegionQ" -> <|
      "PolynomialObstructionScan" -> Lookup[scan, "HiddenRegionQ", Missing["NotRun"]]
    |>,
    "ColumnGuide" -> {
      "CanonicalFactorTable / FactorTable: one row per canonical f_k (all safe-pool classes).",
      "ChosenForGeneratorQ: picked by SingleProduct resolver on polynomial pool (not all admissible pairs).",
      "GeneratorPairAuditTable: kin-prefiltered pairs g=f1*f2 (no kin-square / shared kin var); Factor1 has lower x-degree.",
      "ObstructionTrialTable: after generator fixed, SL decomposition, sector PDF, scaling / HiddenRegionQ.",
      "Selected in route comparison = resolver choice for that safe pool, not the only admissible generator."
    }
  |>
];

hrfEx03SeedRouteComparison[opts_: <||>] := Module[
  {rawDeriv, binSafe, polySafe, polySafeRaw, expected, optsStrict,
   binRoute, polyStrictRoute, scanPoly, expectedGen, pack, filtered, pairAudit},
  hrfEx03SeedStudyLoad[];
  $HRFPolynomialRequireKinematicDomainQ = False;
  rawDeriv = DeleteDuplicates @ Flatten @ Values[derivativeFactors[F0Seed5pt, VarsSeed5pt]];
  binSafe = hrfEx03SeedLegacyBinomialSafeFactors[];
  pack = hrfRawPolynomialCandidates[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars, Automatic];
  filtered = hrfFilterPolynomialCandidates[pack["Raw"], VarsSeed5pt, KinAssump, KinVars, "Polynomial"];
  polySafeRaw = filtered["Accepted"];
  polySafe = hrfSafeCancellationFactorsPolynomial[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars][[1]];
  expected = hrfEx03SeedExpectedGeneratorFactors[];
  expectedGen = If[Length[expected] >= 2, Expand[Times @@ expected], 0];
  optsStrict = <|"RelaxSingleProductDegreeQ" -> False, "SkipPDFFindInstanceQ" -> False|>;
  binRoute = hrfEx03SeedRouteSingleProductDiag[binSafe, "BinomialSafePool", optsStrict];
  polyStrictRoute = hrfEx03SeedRouteSingleProductDiag[polySafe, "PolynomialSafePool", optsStrict];
  scanPoly = If[TrueQ[Lookup[opts, "SkipObstructionScans", False]], <||>,
    Module[{scan},
      scan = findObstructions[
        F0Seed5pt, VarsSeed5pt, KinAssump, KinVars, Automatic,
        Sequence @@ Join[hrfEx03SeedObstructionOptions[], {"GeneratorMode" -> "SingleProduct"}]
      ];
      <|
        "HiddenRegionQ" -> hrfFPObstructionRegionPresentQ[scan],
        "Generators" -> Lookup[scan, "Generators", {}],
        "GeneratorsFactorized" -> hrfFormatGeneratorsForOutput[
          Lookup[scan, "Generators", {}], polySafe, VarsSeed5pt, KinVars],
        "GeneratorsDisplay" -> If[hrfPolynomialCompactAvailableQ[],
          hrfPolynomialCompact /@ hrfFormatGeneratorsForOutput[
            Lookup[scan, "Generators", {}], polySafe, VarsSeed5pt, KinVars],
          ToString[InputForm[#]] & /@ hrfFormatGeneratorsForOutput[
            Lookup[scan, "Generators", {}], polySafe, VarsSeed5pt, KinVars]],
        "PerGeneratorAdmissibleQ" -> Lookup[scan, "PerGeneratorAdmissibleQ", False],
        "CandidateGeneratorCount" -> Lookup[scan, "CandidateGeneratorCount", 0]
      |>
    ]
  ];
  pairAudit = hrfFivePointGeneratorPairAuditTable[
    F0Seed5pt, VarsSeed5pt, KinAssump, KinVars, polySafe, "Seed5pt"
  ];
  comparisonCore = <|
    "RawDerivativeFactors" -> rawDeriv,
    "BinomialSafeFactors" -> binSafe,
    "PolynomialSafeFactors" -> polySafe,
    "PolynomialSafeRawFactors" -> polySafeRaw,
    "BinomialOnlyFactors" -> Complement[binSafe, polySafe],
    "PolynomialOnlyFactors" -> Complement[polySafe, binSafe],
    "ExpectedFactors" -> expected,
    "ExpectedGenerator" -> expectedGen,
    "ExpectedGeneratorMatchesBinomialProductQ" -> expectedGen =!= 0 &&
      Expand[Times @@ Lookup[binRoute, "SelectedFactors", {}]] === expectedGen,
    "Line4Line15EquivalentQ" -> hrfCancellationFactorsEquivalentQ[
      x1*x4 + x*x0*x5,
      -((x1*x4 + x*x0*x5)*(-1 + z)),
      VarsSeed5pt,
      KinVars
    ],
    "StrictSelectedMatchesExpectedQ" -> expectedGen =!= 0 &&
      Expand[Times @@ Lookup[polyStrictRoute, "SelectedFactors", {}]] === expectedGen,
    "BinomialRoute" -> binRoute,
    "PolynomialRoute" -> polyStrictRoute,
    "PolynomialRouteStrict" -> polyStrictRoute,
    "GeneratorRoutes" -> {binRoute, polyStrictRoute},
    "ObstructionScan" -> scanPoly,
    "ObstructionScanPolynomial" -> scanPoly,
    "FactorTableVerbose" -> hrfEx03SeedRouteComparisonTable[<|
      "RawDerivativeFactors" -> rawDeriv,
      "BinomialSafeFactors" -> binSafe,
      "PolynomialSafeCanonicalFactors" -> polySafe,
      "PolynomialSafeRawFactors" -> polySafeRaw,
      "ExpectedFactors" -> expected,
      "BinomialRoute" -> binRoute,
      "PolynomialRouteStrict" -> polyStrictRoute
    |>],
    "FactorTable" -> hrfEx03SeedRouteComparisonCondensedTable[<|
      "BinomialSafeFactors" -> binSafe,
      "PolynomialSafeCanonicalFactors" -> polySafe,
      "ExpectedFactors" -> expected,
      "BinomialRoute" -> binRoute,
      "PolynomialRouteStrict" -> polyStrictRoute
    |>, "All"],
    "CondensedFactorTable" -> hrfEx03SeedRouteComparisonCondensedTable[<|
      "BinomialSafeFactors" -> binSafe,
      "PolynomialSafeCanonicalFactors" -> polySafe,
      "ExpectedFactors" -> expected,
      "BinomialRoute" -> binRoute,
      "PolynomialRouteStrict" -> polyStrictRoute
    |>, "All"],
    "CanonicalFactorTable" -> hrfFivePointCanonicalFactorTable[
      F0Seed5pt, VarsSeed5pt, KinAssump, KinVars, "Seed5pt"
    ],
    "GeneratorPairAuditTable" -> pairAudit["Table"],
    "GeneratorPairAuditSummary" -> pairAudit["Summary"],
    "GeneratorSelectionTable" -> hrfEx03SeedGeneratorSelectionTable[<|
      "GeneratorRoutes" -> {binRoute, polyStrictRoute},
      "ObstructionScan" -> scanPoly
    |>],
    "Summary" -> hrfEx03SeedRouteComparisonSummary[<|
      "RawDerivativeFactors" -> rawDeriv,
      "BinomialSafeFactors" -> binSafe,
      "PolynomialSafeFactors" -> polySafe,
      "BinomialOnlyFactors" -> Complement[binSafe, polySafe],
      "PolynomialOnlyFactors" -> Complement[polySafe, binSafe],
      "ExpectedFactors" -> expected,
      "Line4Line15EquivalentQ" -> hrfCancellationFactorsEquivalentQ[
        x1*x4 + x*x0*x5,
        -((x1*x4 + x*x0*x5)*(-1 + z)),
        VarsSeed5pt,
        KinVars
      ],
      "StrictSelectedMatchesExpectedQ" -> expectedGen =!= 0 &&
        Expand[Times @@ Lookup[polyStrictRoute, "SelectedFactors", {}]] === expectedGen,
      "BinomialRoute" -> binRoute,
      "PolynomialRouteStrict" -> polyStrictRoute,
      "PolynomialRoute" -> polyStrictRoute,
      "ObstructionScanPolynomial" -> scanPoly
    |>]
  |>
];

(* Generic five-point route study (Seed5pt, ThreeLoopVertex, ...). *)
hrfFivePointRouteStudy[F0_, vars_, kinAssump_, kinVars_, label_String, opts_: <||>] := Module[
  {rawDeriv, binSafe, polySafe, polySafeRaw, expected, genOpts, binRoute, polyRoute, scan,
   localKey, localPoolHasKeyQ, localClassIndex, localExpectedFactors},
  hrfEx03SeedStudyLoad[];
  $HRFPolynomialRequireKinematicDomainQ = False;
  localKey[f_] := Module[{c},
    c = hrfCanonicalCancellationFactor[f, vars, kinVars];
    If[TrueQ[c === 0], "--", ToString[InputForm[c]]]
  ];
  localPoolHasKeyQ[pool_List, key_String] := MemberQ[localKey /@ pool, key];
  localClassIndex[factors_List] := Module[{keys, reps, i},
    keys = localKey /@ factors;
    keys = Select[keys, StringQ[#] && # =!= "--" &];
    reps = Table[
      First @ Select[factors, localKey[#] === keys[[i]] &],
      {i, Length[keys]}
    ];
    AssociationThread[keys -> reps]
  ];
  localExpectedFactors[] := Module[{bin},
    bin = Select[hrfLegacyBinomialSafeFactors[F0, vars, kinAssump, kinVars], binomialQ[#, vars] &];
    If[Length[bin] >= 2, Take[bin, 2], bin]
  ];
  rawDeriv = DeleteDuplicates @ Flatten @ Values[derivativeFactors[F0, vars]];
  binSafe = Select[
    hrfLegacyBinomialSafeFactors[F0, vars, kinAssump, kinVars],
    positiveCompatibleQ[#, vars, kinAssump, kinVars] &
  ];
  polySafeRaw = hrfFilterPolynomialCandidates[
    hrfRawPolynomialCandidates[F0, vars, kinAssump, kinVars, Automatic]["Raw"],
    vars, kinAssump, kinVars, "Polynomial"
  ]["Accepted"];
  polySafe = hrfSafeCancellationFactorsPolynomial[F0, vars, kinAssump, kinVars][[1]];
  expected = localExpectedFactors[];
  genOpts = Join[hrfEx03SeedCollinearGeneratorOpts[], opts];
  binRoute = Module[{eligible, bounds, genFF, fullGen, sets, setData, skipPDFQ, admissiblePairs},
    eligible = hrfFilterFactorsForGenerators[binSafe, vars, F0, genOpts]["Factors"];
    bounds = hrfResolveGeneratorDegreeBounds[F0, vars, genOpts];
    genFF = hrfResolveSingleProductGeneratorFactors[eligible, vars, kinAssump, kinVars, F0, genOpts];
    fullGen = If[genFF === {}, 0, Expand[Times @@ genFF]];
    sets = candidateGeneratorSets[binSafe, vars, kinAssump, kinVars, F0, genOpts];
    setData = If[sets =!= {},
      generatorSetAdmissibilityData[First[sets], binSafe, vars, kinVars, kinAssump, bounds, F0], <||>];
    skipPDFQ = hrfSkipPDFFindInstanceQ[bounds] || TrueQ[Lookup[genOpts, "SkipPDFFindInstanceQ", False]];
    admissiblePairs = Select[Subsets[eligible, {2}],
      (skipPDFQ || simultaneouslyAdmissibleSubsetQ[#, vars, kinAssump, kinVars]) &&
        hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ #], bounds, vars, F0, kinVars] &
    ];
    <|
      "Route" -> "BinomialSafePool",
      "Topology" -> label,
      "SafeCount" -> Length[binSafe],
      "EligibleCount" -> Length[eligible],
      "AdmissiblePairCount" -> Length[admissiblePairs],
      "SelectedFactorCount" -> Length[genFF],
      "SelectedFactors" -> genFF,
      "SelectedFactorKeys" -> localKey /@ genFF,
      "SelectedFactorsDisplay" -> If[hrfPolynomialCompactAvailableQ[],
        hrfPolynomialCompact /@ genFF, InputForm /@ genFF],
      "FullGeneratorFactorizedDisplay" -> If[sets =!= {},
        If[hrfPolynomialCompactAvailableQ[],
          hrfPolynomialCompact[hrfFactorizeGeneratorForOutput[First[First[sets]], binSafe, vars, kinVars]],
          ToString[InputForm[hrfFactorizeGeneratorForOutput[First[First[sets]], binSafe, vars, kinVars]]]],
        "--"],
      "CandidateSetCount" -> Length[sets],
      "PerGeneratorAdmissibleQ" -> TrueQ[Lookup[setData, "PerGeneratorAdmissibleQ", False]],
      "SimultaneousOnSelectedQ" -> genFF =!= {} && simultaneouslyAdmissibleSubsetQ[genFF, vars, kinAssump, kinVars],
      "FullProductDegreeAdmissibleQ" -> genFF =!= {} &&
        hrfGeneratorDegreeAdmissibleQ[fullGen, bounds, vars, F0, kinVars]
    |>
  ];
  polyRoute = Module[{eligible, bounds, genFF, fullGen, sets, setData, skipPDFQ, admissiblePairs},
    eligible = hrfFilterFactorsForGenerators[polySafe, vars, F0, genOpts]["Factors"];
    bounds = hrfResolveGeneratorDegreeBounds[F0, vars, genOpts];
    genFF = hrfResolveSingleProductGeneratorFactors[eligible, vars, kinAssump, kinVars, F0, genOpts];
    fullGen = If[genFF === {}, 0, Expand[Times @@ genFF]];
    sets = candidateGeneratorSets[polySafe, vars, kinAssump, kinVars, F0, genOpts];
    setData = If[sets =!= {},
      generatorSetAdmissibilityData[First[sets], polySafe, vars, kinVars, kinAssump, bounds, F0], <||>];
    skipPDFQ = hrfSkipPDFFindInstanceQ[bounds] || TrueQ[Lookup[genOpts, "SkipPDFFindInstanceQ", False]];
    admissiblePairs = Select[Subsets[eligible, {2}],
      (skipPDFQ || simultaneouslyAdmissibleSubsetQ[#, vars, kinAssump, kinVars]) &&
        hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ #], bounds, vars, F0, kinVars] &
    ];
    <|
      "Route" -> "PolynomialSafePool",
      "Topology" -> label,
      "SafeCount" -> Length[polySafe],
      "EligibleCount" -> Length[eligible],
      "AdmissiblePairCount" -> Length[admissiblePairs],
      "SelectedFactorCount" -> Length[genFF],
      "SelectedFactors" -> genFF,
      "SelectedFactorKeys" -> localKey /@ genFF,
      "SelectedFactorsDisplay" -> If[hrfPolynomialCompactAvailableQ[],
        hrfPolynomialCompact /@ genFF, InputForm /@ genFF],
      "FullGeneratorFactorizedDisplay" -> If[sets =!= {},
        If[hrfPolynomialCompactAvailableQ[],
          hrfPolynomialCompact[hrfFactorizeGeneratorForOutput[First[First[sets]], polySafe, vars, kinVars]],
          ToString[InputForm[hrfFactorizeGeneratorForOutput[First[First[sets]], polySafe, vars, kinVars]]]],
        "--"],
      "CandidateSetCount" -> Length[sets],
      "PerGeneratorAdmissibleQ" -> TrueQ[Lookup[setData, "PerGeneratorAdmissibleQ", False]],
      "SimultaneousOnSelectedQ" -> genFF =!= {} && simultaneouslyAdmissibleSubsetQ[genFF, vars, kinAssump, kinVars],
      "FullProductDegreeAdmissibleQ" -> genFF =!= {} &&
        hrfGeneratorDegreeAdmissibleQ[fullGen, bounds, vars, F0, kinVars]
    |>
  ];
  scan = If[TrueQ[Lookup[opts, "SkipObstructionScans", False]], <||>,
    Module[{s},
      s = findObstructions[F0, vars, kinAssump, kinVars, Automatic,
        "GeneratorMode" -> "SingleProduct",
        "UseExtendedFactors" -> False,
        "DimensionfulKinVars" -> CollinearDimensionfulKinVars,
        "RelaxSingleProductDegreeQ" -> False,
        "SkipPDFFindInstanceQ" -> False,
        Sequence @@ Normal @ KeyDrop[Join[<||>, opts], "SkipObstructionScans"]
      ];
      s
    ]
  ];
  <|
    "Topology" -> label,
    "BinomialSafeFactors" -> binSafe,
    "PolynomialSafeFactors" -> polySafe,
    "BinomialRoute" -> binRoute,
    "PolynomialRoute" -> polyRoute,
    "GeneratorRoutes" -> {binRoute, polyRoute},
    "ObstructionScan" -> scan,
    "CondensedFactorTable" -> Module[{classIndex, allKeys, binSelKeys, polySelKeys, expectedKeys, rows, i, key},
      classIndex = Join[
        localClassIndex[binSafe], localClassIndex[polySafe], localClassIndex[expected],
        localClassIndex[Lookup[binRoute, "SelectedFactors", {}]],
        localClassIndex[Lookup[polyRoute, "SelectedFactors", {}]]
      ];
      allKeys = Keys[classIndex];
      binSelKeys = Lookup[binRoute, "SelectedFactorKeys", localKey /@ Lookup[binRoute, "SelectedFactors", {}]];
      polySelKeys = Lookup[polyRoute, "SelectedFactorKeys", localKey /@ Lookup[polyRoute, "SelectedFactors", {}]];
      expectedKeys = localKey /@ expected;
      rows = Table[
        key = allKeys[[i]];
        <|
          "Topology" -> label,
          "Canonical" -> key,
          "BinomialSafePoolQ" -> localPoolHasKeyQ[binSafe, key],
          "PolynomialSafePoolQ" -> localPoolHasKeyQ[polySafe, key],
          "BinomialRouteSelectedQ" -> MemberQ[binSelKeys, key],
          "PolynomialRouteSelectedQ" -> MemberQ[polySelKeys, key],
          "ExpectedGeneratorFactorQ" -> MemberQ[expectedKeys, key],
          "EntersGeneratorQ" -> MemberQ[binSelKeys, key] || MemberQ[polySelKeys, key]
        |>,
        {i, Length[allKeys]}
      ];
      rows = Select[rows, TrueQ[Lookup[#, "EntersGeneratorQ", False]] ||
        TrueQ[Lookup[#, "ExpectedGeneratorFactorQ", False]] &];
      Dataset @ SortBy[rows, {Lookup[#, "Canonical", ""] &}]
    ],
    "GeneratorSelectionTable" -> Dataset @ Table[
      <|
        "Topology" -> label,
        "Route" -> {binRoute, polyRoute}[[i]]["Route"],
        "SafePoolCount" -> {binRoute, polyRoute}[[i]]["SafeCount"],
        "EligibleCount" -> {binRoute, polyRoute}[[i]]["EligibleCount"],
        "AdmissiblePairCount" -> {binRoute, polyRoute}[[i]]["AdmissiblePairCount"],
        "SelectedFactorCount" -> {binRoute, polyRoute}[[i]]["SelectedFactorCount"],
        "SelectedFactors" -> StringRiffle[{binRoute, polyRoute}[[i]]["SelectedFactorsDisplay"], " * "],
        "FactorizedGenerator" -> {binRoute, polyRoute}[[i]]["FullGeneratorFactorizedDisplay"],
        "CandidateSetCount" -> {binRoute, polyRoute}[[i]]["CandidateSetCount"],
        "PerGeneratorAdmissibleQ" -> {binRoute, polyRoute}[[i]]["PerGeneratorAdmissibleQ"],
        "JointPDFOnSelectedQ" -> {binRoute, polyRoute}[[i]]["SimultaneousOnSelectedQ"],
        "DegreeAdmissibleQ" -> {binRoute, polyRoute}[[i]]["FullProductDegreeAdmissibleQ"],
        "ObstructionHiddenRegionQ" -> If[i === 2, Lookup[scan, "HiddenRegionQ", Missing["NotRun"]], Missing["BinomialPoolOnly"]]
      |>,
      {i, 2}
    ]
  |>
];

hrfEx03SeedFivePointRouteStudy[opts_: <||>] := Module[{seed, vertex, vertexOpts},
  hrfEx03SeedStudyLoad[];
  seed = hrfFivePointGeneratorStudy[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars, "Seed5pt",
    Join[<|"U" -> hrfEx03SeedLeadingU[]|>, opts]
  ];
  vertexOpts = Join[
    opts,
    <|
      "SkipObstructionScans" -> TrueQ[
        Lookup[opts, "SkipVertexObstructionScans",
          Lookup[opts, "SkipObstructionScans", True]
        ]
      ]
    |>
  ];
  vertex = hrfFivePointGeneratorStudy[
    F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars, "ThreeLoopVertex",
    vertexOpts
  ];
  <|
    "Seed5pt" -> seed,
    "ThreeLoopVertex" -> vertex,
    "CanonicalFactorTable" -> Dataset @ Join[
      Normal @ seed["CanonicalFactorTable"], Normal @ vertex["CanonicalFactorTable"]],
    "GeneratorPairAuditTable" -> Dataset @ Join[
      Normal @ seed["GeneratorPairAuditTable"], Normal @ vertex["GeneratorPairAuditTable"]],
    "GeneratorPairAuditSummary" -> <|
      "Seed5pt" -> seed["GeneratorPairAuditSummary"],
      "ThreeLoopVertex" -> vertex["GeneratorPairAuditSummary"]
    |>,
    "GeneratorSelectionTable" -> Dataset @ Join[
      Normal @ seed["GeneratorSelectionTable"], Normal @ vertex["GeneratorSelectionTable"]],
    "ObstructionTrialTable" -> Dataset @ Join[
      Normal @ seed["ObstructionTrialTable"], Normal @ vertex["ObstructionTrialTable"]],
    "HiddenRegionQ" -> <|
      "Seed5pt" -> seed["HiddenRegionQ"],
      "ThreeLoopVertex" -> vertex["HiddenRegionQ"]
    |>,
    "ColumnGuide" -> {
      "CanonicalFactorTable: one row per canonical f_k (mixed-sign, non-monomial); x_i factored per term.",
      "GeneratorPairAuditTable: kin-prefiltered pairs g=f1*f2; Factor1 has lower x-degree.",
      "In[4]-In[5] tables are Seed5pt only. For ThreeLoopVertex use In[5c] or In[14].",
      "GeneratorSelectionTable: binomial vs polynomial SingleProduct resolver on each topology.",
      "Topology column distinguishes Seed5pt from ThreeLoopVertex.",
      "NonBinomialGeneratorSelectedQ (per topology): polynomial route picked non-legacy factors.",
      "Full vertex obstruction: hrfEx03SeedFivePointRouteStudy[<|\"SkipVertexObstructionScans\" -> False|>] (slow)."
    }
  |>
];

hrfEx03RunSeedObstruction[] := Module[{audit, genAudit, study, result},
  hrfEx03SeedStudyLoad[];
  audit = hrfEx03SeedFactorAudit[];
  genAudit = hrfEx03SeedGeneratorAudit[];
  study = hrfFivePointGeneratorStudy[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars, "Seed5pt",
    <|"U" -> hrfEx03SeedLeadingU[]|>
  ];
  result = <|
    "Scan" -> study["Scan"],
    "FactorAudit" -> audit,
    "GeneratorAudit" -> genAudit,
    "CanonicalFactorTable" -> study["CanonicalFactorTable"],
    "GeneratorPairAuditTable" -> study["GeneratorPairAuditTable"],
    "GeneratorPairAuditSummary" -> study["GeneratorPairAuditSummary"],
    "GeneratorSelectionTable" -> study["GeneratorSelectionTable"],
    "NonBinomialGeneratorSelectedQ" -> study["NonBinomialGeneratorSelectedQ"],
    "ObstructionTrialTable" -> study["ObstructionTrialTable"],
    "AttemptSummary" -> study["AttemptSummary"],
    "HiddenRegionQ" -> study["HiddenRegionQ"],
    "Generators" -> Lookup[study["Scan"], "Generators", {}],
    "GeneratorMode" -> Lookup[study["Scan"], "GeneratorMode", "SingleProduct"],
    "CancellationFactorCounts" -> <|
      "Safe" -> audit["SafeCount"],
      "GeneratorEligible" -> audit["GeneratorEligibleCount"]
    |>,
    "SimultaneouslyAdmissibleGeneratorPoolQ" ->
      genAudit["SimultaneouslyAdmissibleLegacyBinomialPoolQ"],
    "LeadingU" -> hrfEx03SeedLeadingU[]
  |>;
  Ex03SeedObstruction = result;
  hrfEx03SeedSay["seed obstruction: Safe=" <> ToString[audit["SafeCount"]] <>
    " eligible=" <> ToString[audit["GeneratorEligibleCount"]] <>
    " simultaneous=" <> ToString[genAudit["SimultaneouslyAdmissibleGeneratorPoolQ"]] <>
    " SingleProductSets=" <> ToString[genAudit["SafeSingleProductSetCount"]] <>
    " HiddenRegionQ=" <> ToString[result["HiddenRegionQ"]] <>
    " (ThreeLoopVertex: evaluate In[5c] or In[14a]-[14b])"];
  result
];

hrfEx03SeedStudyLoad[] := Module[{},
  If[! TrueQ[$HRFFinderCoreLoadedQ],
    Get[FileNameJoin[{$HRFEx03SeedStudyDirectory, "HiddenRegionFinder.wl"}]]
  ];
  If[! ValueQ[F0Seed5pt],
    Get[FileNameJoin[{$HRFEx03SeedStudyDirectory, "HRF_Example03CollinearCore.wl"}]]
  ];
  If[! ValueQ[hrfInstallPolynomialCancellationPatch],
    Get[FileNameJoin[{$HRFEx03SeedStudyDirectory, "HRF_PolynomialCancellationFactors.wl"}]]
  ];
  If[! ValueQ[$HRFPolynomialRequireKinematicDomainQ], $HRFPolynomialRequireKinematicDomainQ = False];
  If[! ValueQ[$HRFUsePolynomialCancellationFactors], $HRFUsePolynomialCancellationFactors = True];
  If[! ValueQ[$HRFCandidateGeneratorSetLimit], $HRFCandidateGeneratorSetLimit = 64];
  If[Length[DownValues[hrfFPObstructionRegionPresentQ]] === 0,
    Get[FileNameJoin[{$HRFEx03SeedStudyDirectory, "HRF_FivePointReporting.wl"}]]
  ];
  hrfInstallPolynomialCancellationPatch[];
  True
];

hrfEx03SeedSay["loaded. Evaluate hrfEx03SeedRouteComparison[], hrfEx03SeedFivePointRouteStudy[], hrfEx03RunSeedObstruction[]."];
