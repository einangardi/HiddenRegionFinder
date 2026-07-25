(* HRF_GeneratorPhysicsFilter.wl
   Generator combinatorics for polynomial f_k:

   1. Kin-mixed f_k may pair only with kin-free f_l of x-degree <= deg(F) - deg(f_k).
   2. Paired factors must have disjoint x-support.
   3. Kin-mixed f_k whose x-parts lie in the span of kin-free f_k are dropped
      (kin-embedded factors are kinematic linear combinations of kin-free ones).
   4. Pair generators are quotiented modulo span{ B, s_a * B } with B a Q-basis of
      kin-free pair generators and s_a in kinVars.  Cancellation factors are linear
      in Mandelstams (at most one s_a per term); nonlinear kin monomials cannot
      appear in f_k and are not used to justify keeping redundant generators.
*)

(* Load after HiddenRegionFinder.wl *)

If[! ValueQ[$HRFUseGeneratorPhysicsFilterQ], $HRFUseGeneratorPhysicsFilterQ = True];

ClearAll[
  hrfFactorContainsKinVarsQ, hrfFactorXSupport, hrfFactorKinMonomialXContent,
  hrfSquareFreeHomogeneousPositiveZeroQ,
  hrfDisjointSquareFreePairPositiveQ,
  hrfQLinearSystemConsistentQ, hrfQPolynomialInModuleSpanQ,
  hrfMaximalIndependentPolynomials, hrfKinematicSectorModuleBasis,
  hrfFactorMandelstamLinearQ, hrfKinMonomialExponentLinearQ,
  hrfKinMixedFactorSpanRedundantQ, hrfGeneratorPairPhysicsAdmissibleQ,
  hrfKinMonomialKeyToPoly,
  hrfKinFreePairProducts, hrfGeneratorPairSectorRedundantQ,
  hrfGeneratorSectorModuleRedundantQ,
  hrfGeneratorPairModuleRedundantQ, hrfCanonicalizeGeneratorsModKinSectors,
  hrfFilterAdmissiblePairsModuleDedup,
  hrfFilterFactorsForGeneratorPhysics, hrfFilterGeneratorPairPhysics,
  hrfGeneratorPhysicsPairRow, hrfGeneratorPhysicsPairTable,
  hrfFactorKinVarsPresent, hrfGeneratorPairKinPrefilterQ,
  hrfOrderCancellationPairByXDegree
];

hrfFactorContainsKinVarsQ[f_, kinVars_] := Module[{ff = Expand[f]},
  If[kinVars === {}, False, ! FreeQ[ff, Alternatives @@ kinVars]]
];

hrfFactorXSupport[f_, vars_] := Module[{ex},
  ex = hrfExponentListInVars[f, vars];
  If[! ListQ[ex] || Length[ex] =!= Length[vars], Return[{}]];
  Pick[vars, ex, _?(# > 0 &)]
];

(* Exact positive-orthant certificate for the massless factors occurring in
   the wide-angle problem.  A homogeneous square-free polynomial has 0/1
   exponent vectors of one fixed Hamming weight.  No such vector can be a
   convex combination of the other distinct 0/1 vectors, so every monomial is
   a Newton-polytope vertex.  If coefficients of both signs occur, a positive
   monomial and a negative monomial can each be made uniquely dominant along
   suitable rays in log(x); continuity then gives a zero with every x_i>0. *)
hrfSquareFreeHomogeneousPositiveZeroQ[f_, vars_, kinVars_: {}] := Module[
  {rules, exponents, coefficients, degrees},
  If[hrfFactorContainsKinVarsQ[f, kinVars] || ! PolynomialQ[f, vars],
    Return[False]
  ];
  rules = CoefficientRules[Expand[f], vars];
  If[Length[rules] < 2, Return[False]];
  exponents = First /@ rules;
  coefficients = Last /@ rules;
  degrees = Total /@ exponents;
  And[
    And @@ Flatten[Map[MemberQ[{0, 1}, #] &, exponents, {2}]],
    Length[DeleteDuplicates[degrees]] == 1,
    AnyTrue[coefficients, TrueQ[# > 0] &],
    AnyTrue[coefficients, TrueQ[# < 0] &]
  ]
];

hrfDisjointSquareFreePairPositiveQ[{f1_, f2_}, vars_, kinVars_: {}] :=
  Length[Intersection[
    hrfFactorXSupport[f1, vars], hrfFactorXSupport[f2, vars]
  ]] == 0 &&
    hrfSquareFreeHomogeneousPositiveZeroQ[f1, vars, kinVars] &&
    hrfSquareFreeHomogeneousPositiveZeroQ[f2, vars, kinVars];

(* Decompose f into kinematic-monomial * (x-polynomial) pieces. *)
hrfFactorKinMonomialXContent[f_, vars_, kinVars_] := Module[
  {rules, out = <||>, kinKey},
  If[kinVars === {}, Return[<|"0" -> Expand[f]|>]];
  rules = Cases[Flatten[{CoefficientRules[Expand[f], kinVars]}], _Rule];
  Do[
    kinKey = StringRiffle[ToString /@ rules[[i, 1]], ","];
    out[kinKey] = Expand[rules[[i, 2]]],
    {i, Length[rules]}
  ];
  KeySelect[out, ! TrueQ[Expand[out[#]] === 0] &]
];

hrfQLinearSystemConsistentQ[mat_, vec_] := Module[{aug},
  If[mat === {} || vec === {}, Return[False]];
  aug = Transpose @ Append[Transpose @ Rationalize[mat, 0], Rationalize[vec, 0]];
  MatrixRank[aug, Modulus -> 0] === MatrixRank[Transpose @ Rationalize[mat, 0], Modulus -> 0]
];

hrfQPolynomialInModuleSpanQ[poly_, basis_List, allVars_] := Module[
  {coefficientRuleLists, exponentKeys, mat, vec, cleanBasis, p},
  cleanBasis = Select[Expand /@ basis, ! TrueQ[# === 0] &];
  p = Expand[poly];
  If[TrueQ[p === 0], Return[True]];
  If[cleanBasis === {}, Return[False]];
  coefficientRuleLists = CoefficientRules[#, allVars] & /@
    Join[cleanBasis, {p}];
  exponentKeys = DeleteDuplicates @ Flatten[
    First /@ # & /@ coefficientRuleLists, 1
  ];
  If[exponentKeys === {}, Return[False]];
  mat = Transpose @ (
    (Lookup[Association[#], exponentKeys, 0] &) /@ Most[coefficientRuleLists]
  );
  vec = Lookup[Association[Last[coefficientRuleLists]], exponentKeys, 0];
  hrfQLinearSystemConsistentQ[mat, vec]
];

hrfMaximalIndependentPolynomials[polys_List, allVars_] := Module[
  {clean, coefficientRuleLists, exponentKeys, matrix, reducedTranspose,
   pivotPositions},
  clean = DeleteDuplicates @ Select[Expand /@ polys, ! TrueQ[# === 0] &];
  If[clean === {}, Return[{}]];
  coefficientRuleLists = CoefficientRules[#, allVars] & /@ clean;
  exponentKeys = DeleteDuplicates @ Flatten[First /@ # & /@ coefficientRuleLists, 1];
  If[exponentKeys === {}, Return[{}]];
  matrix = Rationalize[
    (Lookup[Association[#], exponentKeys, 0] &) /@ coefficientRuleLists,
    0
  ];
  (* Independent input polynomials are independent rows of matrix, hence
     pivot columns of Transpose[matrix].  One exact row reduction replaces the
     former incremental sequence of augmented MatrixRank computations and
     retains the earliest independent input columns. *)
  reducedTranspose = RowReduce[Transpose[matrix]];
  pivotPositions = DeleteDuplicates @ Cases[
    Function[row,
      SelectFirst[
        Range[Length[row]],
        Function[j, ! TrueQ[PossibleZeroQ[row[[j]]]]],
        Missing["ZeroRow"]
      ]
    ] /@ reducedTranspose,
    _Integer
  ];
  clean[[pivotPositions]]
];

(* Module span{B, s_a * B | s_a in kinVars}.  Linear in Mandelstams only. *)
hrfKinematicSectorModuleBasis[kinFreeGenerators_List, kinVars_List] := Module[
  {xBasis},
  xBasis = kinFreeGenerators;
  DeleteDuplicates @ Join[
    xBasis,
    Flatten @ Table[Expand[(kin #) & /@ xBasis, {kin, kinVars}]]
  ]
];

(* Each term of f carries at most one Mandelstam to the first power (F is linear in kin). *)
hrfKinMonomialExponentLinearQ[key_String] := Module[{pow},
  pow = ToExpression @ StringSplit[key, ","];
  ListQ[pow] && And @@ (0 <= # <= 1 & /@ pow) && Total[pow] <= 1
];

hrfFactorMandelstamLinearQ[f_, kinVars_] := Module[{decomp},
  If[kinVars === {} || ! hrfFactorContainsKinVarsQ[f, kinVars], Return[True]];
  decomp = hrfFactorKinMonomialXContent[f, {}, kinVars];
  And @@ (hrfKinMonomialExponentLinearQ[#] & /@ Keys[decomp])
];

hrfKinMixedFactorSpanRedundantQ[f_, kinFreeFactors_List, vars_, kinVars_] := Module[
  {decomp, xPolys, rem},
  If[! hrfFactorContainsKinVarsQ[f, kinVars], Return[False]];
  If[kinFreeFactors === {}, Return[False]];
  decomp = hrfFactorKinMonomialXContent[f, vars, kinVars];
  xPolys = Values[decomp];
  If[xPolys === {}, Return[True]];
  And @@ (
    Module[{rem = Quiet @ PolynomialReduce[Expand[#], kinFreeFactors, vars][[2]]},
      TrueQ[Expand[rem] === 0]
    ] & /@ xPolys
  )
];

hrfFactorKinVarsPresent[f_, kinVars_] := Select[kinVars, ! FreeQ[Expand[f], #] &];

(* Reject g = f1*f2 when a kin-dependent factor is squared, or when two distinct
   factors share the same kinematic variable (product is nonlinear in that kin). *)
hrfGeneratorPairKinPrefilterQ[f1_, f2_, kinVars_] := Module[{k1, k2},
  If[kinVars === {}, Return[True]];
  k1 = hrfFactorKinVarsPresent[f1, kinVars];
  k2 = hrfFactorKinVarsPresent[f2, kinVars];
  If[k1 === {} || k2 === {}, Return[True]];
  If[TrueQ[Expand[f1 - f2] === 0], Return[False]];
  Intersection[k1, k2] === {}
];

hrfOrderCancellationPairByXDegree[f1_, f2_, vars_] := Module[{d1, d2, key},
  key[f_] := ToString[InputForm[Expand[f]]];
  d1 = hrfPolynomialTotalDegreeInVars[f1, vars];
  d2 = hrfPolynomialTotalDegreeInVars[f2, vars];
  If[d1 < d2 || (d1 === d2 && Order[key[f1], key[f2]] <= 0), {f1, f2}, {f2, f1}]
];

hrfGeneratorPairPhysicsAdmissibleQ[f1_, f2_, bounds_Association, vars_, kinVars_] := Module[
  {dF, d1, d2, k1, k2, xs1, xs2, prod},
  If[! hrfGeneratorPairKinPrefilterQ[f1, f2, kinVars], Return[False]];
  dF = Lookup[bounds, "MaxGeneratorTotalDegree", Infinity];
  d1 = hrfPolynomialTotalDegreeInVars[f1, vars];
  d2 = hrfPolynomialTotalDegreeInVars[f2, vars];
  k1 = hrfFactorContainsKinVarsQ[f1, kinVars];
  k2 = hrfFactorContainsKinVarsQ[f2, kinVars];
  xs1 = hrfFactorXSupport[f1, vars];
  xs2 = hrfFactorXSupport[f2, vars];
  prod = Expand[f1 f2];
  Which[
    k1 && k2, False,
    k1 && ! k2,
      d2 <= dF - d1 &&
        Length[Intersection[xs1, xs2]] === 0 &&
        hrfGeneratorProductDegreeAdmissibleQ[prod, bounds, vars],
    ! k1 && k2,
      d1 <= dF - d2 &&
        Length[Intersection[xs1, xs2]] === 0 &&
        hrfGeneratorProductDegreeAdmissibleQ[prod, bounds, vars],
    True,
      Length[Intersection[xs1, xs2]] === 0 &&
        hrfGeneratorProductDegreeAdmissibleQ[prod, bounds, vars]
  ]
];

(* Kin-free pair products and their s12/s23 multiples span kin-mixed pair generators.
   Sector form: if f_m = sum_a s12^i s23^j h_ij(x) with h_ij in span(kin-free f_k),
   then g = f_m * f_l is redundant when each h_ij * f_l lies in span(kin-free pair products). *)
hrfKinFreePairProducts[kinFreePairs_List] := Expand[Times @@ #] & /@ kinFreePairs;

hrfGeneratorPairSectorRedundantQ[pair_List, kinFreePairs_List, vars_, kinVars_] := Module[
  {g, xBasis, allVars},
  If[Length[pair] =!= 2, Return[False]];
  If[! Or @@ (hrfFactorContainsKinVarsQ[#, kinVars] & /@ pair), Return[False]];
  If[kinFreePairs === {}, Return[False]];
  allVars = DeleteDuplicates @ Join[vars, kinVars];
  xBasis = hrfKinFreePairProducts[kinFreePairs];
  xBasis = hrfMaximalIndependentPolynomials[xBasis, vars];
  g = Expand[Times @@ pair];
  hrfGeneratorSectorModuleRedundantQ[g, xBasis, vars, kinVars]
];

hrfKinMonomialKeyToPoly[key_String, kinVars_] := Module[{pow},
  pow = ToExpression @ StringSplit[key, ","];
  If[! ListQ[pow] || Length[pow] =!= Length[kinVars], Return[1]];
  Times @@ MapThread[Power, {kinVars, pow}]
];

(* g = sum_kinMonomial h_k(x); redundant when every h_k lies in span(xBasis). *)
hrfGeneratorSectorModuleRedundantQ[g_, xBasis_List, vars_, kinVars_] := Module[
  {decomp, parts},
  decomp = hrfFactorKinMonomialXContent[g, vars, kinVars];
  parts = Values[decomp];
  If[parts === {}, Return[False]];
  And @@ (
    hrfQPolynomialInModuleSpanQ[Expand[#], xBasis, vars] & /@ parts
  )
];

hrfGeneratorPairModuleRedundantQ[pair_List, kinFreePairs_List, kinFreeFactors_List, kinMixedPairs_List, vars_, kinVars_] :=
  hrfGeneratorPairSectorRedundantQ[pair, kinFreePairs, vars, kinVars];

(* Quotient candidate pair generators modulo the kinematic sector module.
   Returns a Q-basis of kin-free pair generators plus any kin-mixed generators
   that are not in span{B, s_a*B}. *)
hrfCanonicalizeGeneratorsModKinSectors[candidateGens_List, kinFreePairGens_List, vars_, kinVars_] := Module[
  {allVars, xBasis, moduleBasis, canonical, redundant, kinFreeCandidates,
   kinMixedCandidates, g},
  allVars = DeleteDuplicates @ Join[vars, kinVars];
  xBasis = hrfMaximalIndependentPolynomials[kinFreePairGens, vars];
  moduleBasis = hrfKinematicSectorModuleBasis[xBasis, kinVars];
  kinFreeCandidates = Select[
    Expand /@ candidateGens, ! hrfFactorContainsKinVarsQ[#, kinVars] &
  ];
  kinMixedCandidates = Select[
    Expand /@ candidateGens, hrfFactorContainsKinVarsQ[#, kinVars] &
  ];
  canonical = xBasis;
  (* xBasis was computed from the complete kin-free candidate pool, so every
     remaining kin-free candidate is already certified to lie in its span. *)
  redundant = Select[kinFreeCandidates, ! MemberQ[xBasis, #] &];
  Do[
    g = kinMixedCandidates[[i]];
    (* F linear in Mandelstams: test whole g in span{B, s12*B, s23*B}. *)
    If[hrfQPolynomialInModuleSpanQ[g, moduleBasis, allVars],
      AppendTo[redundant, g],
      AppendTo[canonical, g]
    ],
    {i, Length[kinMixedCandidates]}
  ];
  <|
    "KinFreeBasis" -> xBasis,
    "ModuleBasis" -> moduleBasis,
    "Canonical" -> DeleteDuplicates[canonical],
    "Redundant" -> DeleteDuplicates[redundant],
    "CanonicalCount" -> Length[DeleteDuplicates[canonical]],
    "RedundantCount" -> Length[DeleteDuplicates[redundant]]
  |>
];

hrfFilterAdmissiblePairsModuleDedup[admissiblePairs_List, kinFreeFactors_List, vars_, kinVars_] := Module[
  {kinFreePairs, kinMixedPairs, keptMixed, redundantMixed},
  kinFreePairs = Select[admissiblePairs,
    ! hrfFactorContainsKinVarsQ[#[[1]], kinVars] &&
      ! hrfFactorContainsKinVarsQ[#[[2]], kinVars] &
  ];
  kinMixedPairs = Complement[admissiblePairs, kinFreePairs];
  redundantMixed = Select[kinMixedPairs,
    hrfGeneratorPairModuleRedundantQ[#, kinFreePairs, kinFreeFactors, kinMixedPairs, vars, kinVars] &
  ];
  keptMixed = Complement[kinMixedPairs, redundantMixed];
  <|
    "KinFreePairs" -> kinFreePairs,
    "KinMixedPairs" -> kinMixedPairs,
    "ModuleRedundantKinMixedPairs" -> redundantMixed,
    "Pairs" -> Join[kinFreePairs, keptMixed]
  |>
];

hrfFilterFactorsForGeneratorPhysics[factors_List, vars_, kinVars_, bounds_] := Module[
  {kinFree, kinMixed, redundant, kept, dropped},
  kinFree = Select[factors, ! hrfFactorContainsKinVarsQ[#, kinVars] &];
  kinMixed = Select[factors, hrfFactorContainsKinVarsQ[#, kinVars] &];
  redundant = Select[kinMixed, hrfKinMixedFactorSpanRedundantQ[#, kinFree, vars, kinVars] &];
  kept = Join[kinFree, Complement[kinMixed, redundant]];
  dropped = Complement[factors, kept];
  <|
    "KinFreeFactors" -> kinFree,
    "KinMixedFactors" -> kinMixed,
    "SpanRedundantKinMixed" -> redundant,
    "Factors" -> kept,
    "DroppedFactors" -> dropped,
    "DroppedFactorCount" -> Length[dropped]
  |>
];

hrfFilterGeneratorPairPhysics[{f1_, f2_}, bounds_, vars_, kinVars_] :=
  hrfGeneratorPairPhysicsAdmissibleQ[f1, f2, bounds, vars, kinVars];

hrfGeneratorPhysicsPairRow[f1_, f2_, bounds_, vars_, kinAssump_, kinVars_] := Module[
  {dF, d1, d2, k1, k2, xs1, xs2, prod},
  dF = Lookup[bounds, "MaxGeneratorTotalDegree", "--"];
  d1 = hrfPolynomialTotalDegreeInVars[f1, vars];
  d2 = hrfPolynomialTotalDegreeInVars[f2, vars];
  k1 = hrfFactorContainsKinVarsQ[f1, kinVars];
  k2 = hrfFactorContainsKinVarsQ[f2, kinVars];
  xs1 = hrfFactorXSupport[f1, vars];
  xs2 = hrfFactorXSupport[f2, vars];
  prod = Expand[f1 f2];
  <|
    "Factor1" -> hrfPolynomialCompact[f1],
    "Factor2" -> hrfPolynomialCompact[f2],
    "Factor1KinQ" -> k1,
    "Factor2KinQ" -> k2,
    "Factor1XDegree" -> d1,
    "Factor2XDegree" -> d2,
    "MaxPartnerXDegree1" -> If[k1, dF - d1, "--"],
    "MaxPartnerXDegree2" -> If[k2, dF - d2, "--"],
    "DisjointXSupportQ" -> Length[Intersection[xs1, xs2]] === 0,
    "ProductXDegree" -> hrfPolynomialTotalDegreeInVars[prod, vars],
    "PhysicsAdmissibleQ" -> hrfGeneratorPairPhysicsAdmissibleQ[f1, f2, bounds, vars, kinVars],
    "SimultaneouslyAdmissibleQ" -> simultaneouslyAdmissibleSubsetQ[{f1, f2}, vars, kinAssump, kinVars],
    "PairGenerator" -> hrfPolynomialCompact[prod]
  |>
];

hrfGeneratorPhysicsPairTable[factors_List, vars_, kinAssump_, kinVars_, bounds_] := Module[
  {physFF, pairs, rows},
  physFF = If[TrueQ[$HRFUseGeneratorPhysicsFilterQ],
    hrfFilterFactorsForGeneratorPhysics[factors, vars, kinVars, bounds]["Factors"],
    factors
  ];
  If[Length[physFF] < 2, Return[Dataset[{}]]];
  pairs = Subsets[physFF, {2}];
  rows = hrfGeneratorPhysicsPairRow[#[[1]], #[[2]], bounds, vars, kinAssump, kinVars] & /@ pairs;
  Dataset[rows]
];

If[! TrueQ[$HRFGeneratorPhysicsFilterLoadedQ] && ! TrueQ[$HRFQuietReports],
  Print["[loaded] generator physics filter (kin pairing + sector quotient)."]
];
$HRFGeneratorPhysicsFilterLoadedQ = True;
