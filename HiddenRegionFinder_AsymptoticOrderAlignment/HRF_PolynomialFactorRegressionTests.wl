(* ::Package:: *)

(* HRF_PolynomialFactorRegressionTests.wl
   Regression checks for polynomial f_k factors, generator physics filter,
   and obstruction stability on Crown + Seed5pt.

   Run from Ex04 notebook (recommended) or:
     Get[FileNameJoin[{$HRFTestDirectory, "HRF_PolynomialFactorRegressionTests.wl"}]]
     hrfRunPolynomialFactorRegressionTests[] *)

$HRFTestDirectory = Which[
  StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName],
    DirectoryName[$InputFileName],
  ValueQ[hrfPackageDirectory],
    hrfPackageDirectory[],
  True,
    Quiet @ Check[NotebookDirectory[], Directory[]]
];

If[! TrueQ[$HRFFinderCoreLoadedQ],
  Get[FileNameJoin[{$HRFTestDirectory, "HiddenRegionFinder.wl"}]]
];
If[Length[DownValues[hrfInstallPolynomialCancellationPatch]] === 0,
  Get[FileNameJoin[{$HRFTestDirectory, "HRF_PolynomialCancellationFactors.wl"}]]
];
If[Length[DownValues[hrfSuccessfulObstructionDecompositionQ]] === 0,
  Get[FileNameJoin[{$HRFTestDirectory, "HRF_FinalLogicPatch.wl"}]]
];
If[Length[DownValues[hrfRegressionLoadCrown]] === 0,
  Get[FileNameJoin[{$HRFTestDirectory, "HRF_RegressionFixtures.wl"}]]
];

ClearAll[
  hrfRegressionAssert, hrfRegressionRow, hrfRegressionSLInIdealQ,
  hrfRegressionExpectedSeedGenerator, hrfRunPolynomialFactorRegressionTests
];

hrfRegressionAssert[name_, condition_, detail_: ""] :=
  <|"Test" -> name, "PassQ" -> TrueQ[condition], "Detail" -> detail|>;

hrfRegressionRow[name_, value_, expected_, detail_: ""] :=
  <|"Test" -> name, "Value" -> value, "Expected" -> expected,
    "PassQ" -> (value === expected), "Detail" -> detail|>;

hrfRegressionSLInIdealQ[scan_] := Module[{od, gens, rem, allVars},
  od = Lookup[scan, "ObstructionData", Missing["NoData"]];
  gens = Lookup[scan, "Generators", {}];
  If[! AssociationQ[od] || ! KeyExistsQ[od, "Superleading"] || gens === {},
    Return[False]
  ];
  allVars = Join[Lookup[scan, "Vars", {}], Lookup[scan, "KinVars", {}]];
  If[allVars === {}, Return[False]];
  rem = Quiet @ PolynomialReduce[Expand[od["Superleading"]], gens, allVars][[2]];
  TrueQ[Expand[rem] === 0]
];

hrfRegressionExpectedSeedGenerator = (x1*x4 + x*x0*x5)*(-x2 - x3 + x2*z);

hrfRunPolynomialFactorRegressionTests[] := Module[
  {rows = {}, obs, ff, bin, bounds, phys, rem, genSeed, ffSeed, binSeed,
   factorPack, channelCoefficients, directPairs, crossedPairs, crossedExtras,
   oldLimit = $HRFCandidateGeneratorSetLimit, oldPoly = $HRFUsePolynomialCancellationFactors,
   oldStop = $HRFFindObstructionsStopOnFirstAdmissibleQ, seedSL, expectedSeedSL},

  $HRFCandidateGeneratorSetLimit = 256;
  $HRFFindObstructionsStopOnFirstAdmissibleQ = False;

  (* --- Seed5pt first (isolated fixture; avoid Example 01 session effects) --- *)
  hrfRegressionLoadSeed5pt[];
  hrfInstallPolynomialCancellationPatch[];
  $HRFUsePolynomialCancellationFactors = True;

  genSeed = findObstructions[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars, 20,
    "GeneratorMode" -> "Adaptive", "UseExtendedFactors" -> False,
    "DimensionfulKinVars" -> CollinearDimensionfulKinVars,
    "StopOnFirstAdmissible" -> False, "CandidateGeneratorSetLimit" -> 128
  ];
  AppendTo[rows, hrfRegressionRow["Seed5pt.Adaptive.GeneratorCount",
    Length[genSeed["Generators"]], 1, "Example 03 coupled single generator"]];
  AppendTo[rows, hrfRegressionAssert["Seed5pt.Adaptive.HasObstructionQ",
    ! MatchQ[genSeed["ObstructionData"], _Missing], "Interior hidden region"]];
  AppendTo[rows, hrfRegressionAssert["Seed5pt.Adaptive.SLInIdealQ",
    hrfRegressionSLInIdealQ[<|
      "ObstructionData" -> genSeed["ObstructionData"],
      "Generators" -> genSeed["Generators"],
      "Vars" -> VarsSeed5pt,
      "KinVars" -> KinVars
    |>], "F_SL in generator ideal"]];
  seedSL = If[! MatchQ[genSeed["ObstructionData"], _Missing],
    Expand[genSeed["ObstructionData"]["Superleading"]], $Failed];
  expectedSeedSL = Expand[-(s*(x1*x4 + x*x0*x5)*(-x2 - x3 + x2*z))];
  AppendTo[rows, hrfRegressionAssert["Seed5pt.Adaptive.ExpectedSuperleadingQ",
    ! MatchQ[seedSL, $Failed] && TrueQ[seedSL === expectedSeedSL],
    "Example 03 superleading sector"]];

  ffSeed = safeCancellationFactorsExtended[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars,
    CollinearDimensionfulKinVars][[1]];
  binSeed = hrfBinomialOnlySafeFactorsExtended[F0Seed5pt, VarsSeed5pt, KinAssump, KinVars,
    CollinearDimensionfulKinVars][[1]];
  AppendTo[rows, hrfRegressionAssert["Seed5pt.PolynomialFactorPoolMixedSignQ",
    ffSeed === {} || And @@ (hrfMixedSignQ[#, VarsSeed5pt] & /@ ffSeed), ""]];
  AppendTo[rows, hrfRegressionAssert["Seed5pt.PolynomialFactorCountPositiveQ",
    Length[ffSeed] > 0, "Collinear pool still nonempty after mixed-sign filter"]];
  AppendTo[rows, hrfRegressionRow["Seed5pt.BinomialFactorCount", Length[binSeed], 6,
    "Collinear derivative-only pool remains binomial in the current filter"]];
  AppendTo[rows, hrfRegressionRow["Seed5pt.KinFreeFactors",
    Length@Select[ffSeed, ! hrfFactorContainsKinVarsQ[#, KinVars] &], 0,
    "All polynomial factors kin-mixed"]];
  AppendTo[rows, hrfRegressionRow["Seed5pt.NonMandelstamRawFactors",
    Length@Select[ffSeed, ! hrfFactorMandelstamLinearQ[#, KinVars] &], 0,
    "Collinear derivative-only pool has no nonlinear Mandelstam factors after filtering"]];

  (* --- Crown (minimal fixture) --- *)
  hrfRegressionLoadCrown[];

  (* Binomial extended reference (Example 01 PairSectors recipe, no polynomial factors) *)
  $HRFUsePolynomialCancellationFactors = False;
  hrfInstallPolynomialCancellationPatch[];
  obs = findObstructions[F0Crown, VarsCrown, KinAssump4ptOnShell, KinVars4pt, 20,
    "GeneratorMode" -> "PairSectors", "UseExtendedFactors" -> True, "MaxGenerators" -> 2,
    "DimensionfulKinVars" -> {},
    "StopOnFirstAdmissible" -> False, "CandidateGeneratorSetLimit" -> 256
  ];
  AppendTo[rows, hrfRegressionRow["Crown.PairSectors.GeneratorCount",
    Length[obs["Generators"]], 2, "Two pair-sector generators (s12 and s23 sectors)"]];
  AppendTo[rows, hrfRegressionAssert["Crown.PairSectors.HasObstructionQ",
    ! MatchQ[obs["ObstructionData"], _Missing], "Obstruction record present"]];
  AppendTo[rows, hrfRegressionAssert["Crown.PairSectors.SLInIdealQ",
    hrfRegressionSLInIdealQ[<|
      "ObstructionData" -> obs["ObstructionData"],
      "Generators" -> obs["Generators"],
      "Vars" -> VarsCrown,
      "KinVars" -> KinVars4pt
    |>], "F_SL lies in two-generator ideal"]];
  AppendTo[rows, hrfRegressionAssert["Crown.PairSectors.DecompositionQ",
    hrfSuccessfulObstructionDecompositionQ[
      Join[obs, <|"ActiveVars" -> VarsCrown, "KinVars" -> KinVars4pt, "InputPolynomial" -> F0Crown|>]
    ],
    "Obstruction + F_SL = F_0 and F_SL in ideal"]];
  rem = If[! MatchQ[obs["ObstructionData"], _Missing],
    PolynomialReduce[obs["ObstructionData"]["Superleading"], obs["Generators"],
      Join[VarsCrown, KinVars4pt]], {}];
  AppendTo[rows, hrfRegressionAssert["Crown.PairSectors.TwoSectorCoefficientsQ",
    MatchQ[rem, {_List, 0}] &&
      MemberQ[
        {Sort[{s12, -s23}], Sort[{-s12, s23}]},
        Sort[Expand /@ First[rem]]
      ],
    "The two exact Crown quotients are the two Mandelstam channels, up to generator order and signs"]];

  (* Polynomial f_k audit --- *)
  $HRFUsePolynomialCancellationFactors = True;
  hrfInstallPolynomialCancellationPatch[];
  ff = safeCancellationFactorsExtended[F0Crown, VarsCrown, KinAssump4ptOnShell, KinVars4pt, {}][[1]];
  bin = hrfBinomialOnlySafeFactorsExtended[F0Crown, VarsCrown, KinAssump4ptOnShell, KinVars4pt, {}][[1]];
  AppendTo[rows, hrfRegressionAssert["Crown.PolynomialFactorPoolMixedSignKinFreeQ",
    ff =!= {} &&
      And @@ (hrfMixedSignQ[#, VarsCrown] & /@ ff) &&
      And @@ (! hrfFactorContainsKinQ[#, KinVars4pt] & /@ ff),
    "Wide-angle pool: mixed-sign kin-free f_k only"]];
  AppendTo[rows, hrfRegressionAssert["Crown.PolynomialFactorPoolNonemptyQ",
    Length[ff] >= 10, "Uncapped crossed-channel pool remains nonempty"]];
  factorPack = hrfRawPolynomialCandidates[
    F0Crown, VarsCrown, KinAssump4ptOnShell, KinVars4pt, {}
  ];
  channelCoefficients = Expand[Coefficient[F0Crown, #]] & /@ KinVars4pt;
  directPairs = hrfLightNormalizeCancellationCandidates[
    Flatten[hrfSignedMonomialPairFactors[#, VarsCrown] & /@ channelCoefficients],
    VarsCrown, KinVars4pt
  ];
  crossedPairs = hrfLightNormalizeCancellationCandidates[
    Flatten[
      hrfSignedMonomialPairFactors[#, VarsCrown] & /@
        {Total[channelCoefficients], channelCoefficients[[1]] - channelCoefficients[[2]]}
    ],
    VarsCrown, KinVars4pt
  ];
  crossedExtras = Select[
    crossedPairs,
    ! hrfMemberCanonicalCancellationFactorQ[
      directPairs, #, VarsCrown, KinVars4pt
    ] &
  ];
  AppendTo[rows, hrfRegressionAssert["Crown.CrossedChannelSignedPairHarvestQ",
    crossedExtras =!= {} && And @@ (
      hrfMemberCanonicalCancellationFactorQ[
        factorPack["FromSignedMonomialPairs"], #, VarsCrown, KinVars4pt
      ] & /@ crossedExtras
    ),
    "A+B and A-B signed pairs are included, not only A and B"]];
  AppendTo[rows, hrfRegressionRow["PolynomialFactor.DerivativePairCap",
    $HRFPolynomialMaxDerivativeMonomials, Infinity,
    "historical length cap is a non-operative compatibility symbol"]];
  AppendTo[rows, hrfRegressionAssert["Crown.BinomialFactorPoolMixedSignKinFreeQ",
    bin =!= {} &&
      And @@ (hrfMixedSignQ[#, VarsCrown] & /@ bin) &&
      And @@ (! hrfFactorContainsKinQ[#, KinVars4pt] & /@ bin),
    "Binomial-mode filter uses same acceptance rules"]];
  bounds = hrfResolveGeneratorDegreeBounds[F0Crown, VarsCrown, <||>];
  phys = hrfFilterFactorsForGeneratorPhysics[ff, VarsCrown, KinVars4pt, bounds];
  AppendTo[rows, hrfRegressionRow["Crown.PhysicsSpanDropped", Length[phys["SpanRedundantKinMixed"]], 0,
    "kin-mixed already removed at cancellation stage"]];
  AppendTo[rows, hrfRegressionRow["Crown.PhysicsEligibleFactors", Length[phys["Factors"]], Length[ff],
    "physics pool equals cancellation pool for kin-free f_k"]];
  AppendTo[rows, hrfRegressionAssert["Crown.AllFactorsKinFreeQ",
    And @@ (! hrfFactorContainsKinQ[#, KinVars4pt] & /@ ff), ""]];
  AppendTo[rows, hrfRegressionAssert["Crown.KinFreePairDisjointXSupportRequiredQ",
    Module[{kf = phys["Factors"], overlapping},
      overlapping = Select[Subsets[kf, {2}],
        Length[Intersection[
          hrfFactorXSupport[#[[1]], VarsCrown],
          hrfFactorXSupport[#[[2]], VarsCrown]
        ]] > 0 &
      ];
      overlapping === {} ||
        And @@ (! hrfGeneratorPairPhysicsAdmissibleQ[#[[1]], #[[2]], bounds, VarsCrown, KinVars4pt] & /@ overlapping)
    ],
    "kin-free x-overlap pairs rejected by physics filter"]];
  AppendTo[rows, hrfRegressionAssert["Crown.KinFreePairDisjointXSupportAllowsQ",
    Module[{kf = phys["Factors"], disjoint},
      disjoint = Select[Subsets[kf, {2}],
        Length[Intersection[
          hrfFactorXSupport[#[[1]], VarsCrown],
          hrfFactorXSupport[#[[2]], VarsCrown]
        ]] === 0 &
      ];
      disjoint === {} ||
        And @@ (hrfGeneratorPairPhysicsAdmissibleQ[#[[1]], #[[2]], bounds, VarsCrown, KinVars4pt] & /@ disjoint)
    ],
    "disjoint kin-free pairs remain physics-admissible when degree bounds hold"]];
  AppendTo[rows, hrfRegressionAssert["Crown.SpuriousPairProductNotF0Q",
    ! hrfGeneratorF0SupportAdmissibleQ[
      Expand[(x1*x4 - x0*x5)*(x3*x6 - x2*x7)], F0Crown, VarsCrown, KinVars4pt, Automatic],
    "Mixed-sector binomial pair product is not an F0-supported generator"]];
  AppendTo[rows, hrfRegressionAssert["Crown.S23HomogeneousGeneratorF0Q",
    hrfGeneratorMonomialsInF0Q[
      Expand[(x1*x2 - x0*x3)*(x5*x6 - x4*x7)], F0Crown, VarsCrown, KinVars4pt, s23],
    "Example s23-sector generator monomials match F0 terms"]];

  obs = findObstructions[F0Crown, VarsCrown, KinAssump4ptOnShell, KinVars4pt, 20,
    "GeneratorMode" -> "Adaptive", "UseExtendedFactors" -> True, "MaxGenerators" -> 2,
    "DimensionfulKinVars" -> {},
    "StopOnFirstAdmissible" -> False, "CandidateGeneratorSetLimit" -> 256
  ];
  AppendTo[rows, hrfRegressionAssert["Crown.Adaptive.TwoSectorQ",
    Length[obs["Generators"]] >= 2 &&
      hrfRegressionSLInIdealQ[<|
        "ObstructionData" -> obs["ObstructionData"],
        "Generators" -> obs["Generators"],
        "Vars" -> VarsCrown,
        "KinVars" -> KinVars4pt
      |>],
    "Adaptive finds two-sector Crown presentation"]];

  AppendTo[rows, hrfRegressionAssert["Patch.ObstructionForCoverageScalingDefinedQ",
    Length[DownValues[hrfObstructionForCoverageScaling]] >= 1,
    "Coverage scaling must resolve F_obs from scan (not leave symbol unevaluated)"]];

  AppendTo[rows, hrfRegressionAssert["Scaling.NullspaceCandidateHelpersQ",
    Length[DownValues[hrfScalingIntegerNullspaceBasis]] >= 1 &&
      Length[DownValues[hrfHomogeneousScalingCandidates]] >= 1 &&
      With[{info = hrfHomogeneousScalingCandidates[{{{1, 0}, {0, 1}}}, 2, 5]},
        AssociationQ[info] && ListQ[Lookup[info, "Candidates", {}]] &&
          MemberQ[Lookup[info, "Candidates", {}], {-1, -1}]
      ],
    "FSL homogeneity candidates generated from nullspace, not ad hoc seeds"]];

  $HRFCandidateGeneratorSetLimit = oldLimit;
  $HRFUsePolynomialCancellationFactors = oldPoly;
  $HRFFindObstructionsStopOnFirstAdmissibleQ = oldStop;

  <|
    "Summary" -> <|
      "Total" -> Length[rows],
      "Passed" -> Count[rows, _?(TrueQ[Lookup[#, "PassQ", False]] &)],
      "Failed" -> Count[rows, _?(Not @ TrueQ @ Lookup[#, "PassQ", False] &)]
    |>,
    "Rows" -> Dataset[rows]
  |>
];

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] polynomial factor regression tests. Evaluate hrfRunPolynomialFactorRegressionTests[]."]
];
