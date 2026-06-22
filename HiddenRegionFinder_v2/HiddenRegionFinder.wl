(* ::Package:: *)
(* HiddenRegionFinder.wl
   Development source-library version.
   IMPORTANT: this is intentionally not a formal Mathematica package yet.
   All definitions are evaluated in the current context to avoid Private` context
   issues with symbolic heads such as sp.

   Load with:
       Get["/path/to/HiddenRegionFinder.wl"]

   Main public routines:
       SymanzikUF
       drawGraphFromPySecDecInput
       toCyclicMandelstams4ptMassless / toCyclicMandelstams4ptMassive
       safeCancellationFactors / safeCancellationFactorsExtended
       kinematicallyHomogeneousQ
       simultaneouslyAdmissibleSubsetQ
       findObstructions
       obstructionGeneratorDiagnostic
       findMinimalLPScaling
       findObstructionsOnBoundaries4pt / scanInterestingBoundariesOnly4pt
*)


(* ---------------------------------------------------------------------- *)
(* Lightweight runtime debugging utilities                                 *)
(* ---------------------------------------------------------------------- *)

If[! ValueQ[$HRFDebugTiming], $HRFDebugTiming = False];
If[! ValueQ[$HRFDebugProgressEvery], $HRFDebugProgressEvery = 25];
(* Polynomial mode can produce thousands of pair-sector generator trials on 4pt
   Crown (36 f_k).  Cap by default so findObstructions does not run for hours. *)
If[! ValueQ[$HRFCandidateGeneratorSetLimit], $HRFCandidateGeneratorSetLimit = 64];
If[! ValueQ[$HRFMaxProductSubsetSize], $HRFMaxProductSubsetSize = 3];
If[! ValueQ[$HRFMaxTwoGeneratorUnionTrials], $HRFMaxTwoGeneratorUnionTrials = 48];
If[! ValueQ[$HRFFindObstructionsStopOnFirstAdmissibleQ], $HRFFindObstructionsStopOnFirstAdmissibleQ = False];
If[! ValueQ[$HRFFindObstructionsStoreAllTrialsQ], $HRFFindObstructionsStoreAllTrialsQ = True];
If[! ValueQ[$HRFFindObstructionsRequireValidScalingQ], $HRFFindObstructionsRequireValidScalingQ = Automatic];

ClearAll[hrfPackageDirectory];
hrfPackageDirectory[] := Module[{nb, inp},
  nb = Quiet @ Check[NotebookDirectory[], $Failed];
  If[StringQ[nb] && nb =!= "" && DirectoryQ[nb], Return[nb]];
  inp = Quiet @ Check[$InputFileName, ""];
  If[StringQ[inp] && inp =!= "" && FileExistsQ[inp], Return[DirectoryName[inp]]];
  If[StringQ[inp] && inp =!= "" && DirectoryQ[inp], Return[inp]];
  Directory[]
];

ClearAll[hrfDebugSay, hrfDebugTimed, hrfObstructionProgressQ, hrfObstructionProgressTag];
hrfDebugSay[msg_] := If[TrueQ[$HRFDebugTiming], Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <> "  " <> ToString[msg]]];
hrfObstructionProgressQ[] := TrueQ[$HRFExample04Report] || TrueQ[$HRFEx04ObstructionProgressQ] ||
  TrueQ[$HRFExample02Report] || TrueQ[$HRFEx02ObstructionProgressQ] ||
  TrueQ[$HRFEx03ObstructionProgressQ] || TrueQ[$HRFExampleVerbose];
hrfObstructionProgressTag[] := Which[
  TrueQ[$HRFExample02Report] && ! TrueQ[$HRFExample04Report], "[Example 02]",
  TrueQ[$HRFExample04Report], "[Example 04]",
  TrueQ[$HRFEx03ObstructionProgressQ] || TrueQ[$HRFExampleVerbose], "[Example 03]",
  True, "[HRF]"
];
hrfDebugTimed[label_, expr_] := Module[{t, r},
  If[TrueQ[$HRFDebugTiming], Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <> "  [start] " <> ToString[label]]];
  {t, r} = AbsoluteTiming[expr];
  If[TrueQ[$HRFDebugTiming], Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <> "  [done]  " <> ToString[label] <> "  (" <> ToString[NumberForm[t, {8, 3}]] <> " s)"]];
  r
];

(* ---------------------------------------------------------------------- *)
(* Graph and Symanzik-polynomial utilities                                *)
(* ---------------------------------------------------------------------- *)

ClearAll[
  makeEdges, allVertices, edgeVariable, graphFromEdgeIndices,
  drawGraphFromPySecDecInput, spanningTreeIndexSets, twoForestIndexSets, externalMomentumAtVertex,
  momentumSquare, SymanzikUF
];

(* edgeVariable[i] gives the Lee--Pomeransky variable attached to internal
   edge i. The convention is x0 for the first edge, x1 for the second, etc. *)
edgeVariable[i_Integer] := Symbol["x" <> ToString[i - 1]];

(* Convert PySecDec-style internal line data {mass,{v1,v2}} to an edge list. *)
makeEdges[internalLines_] := Module[{edges = {}, i},
  For[i = 1, i <= Length[internalLines], i++,
   AppendTo[edges,
    <|
     "Index" -> i,
     "Mass" -> ToExpression[internalLines[[i, 1]]],
     "Ends" -> internalLines[[i, 2]],
     "X" -> edgeVariable[i]
     |>
    ];
   ];
  edges
  ];

(* Return all vertices appearing either in internal or external lines. *)
allVertices[internalLines_, externalLines_] :=
  DeleteDuplicates[
   Join[Flatten[internalLines[[All, 2]]], externalLines[[All, 2]]]
   ];

(* Build a graph from a subset of internal edge indices. *)
graphFromEdgeIndices[edges_, vertices_, inds_] :=
 Module[{edgeRules = {}, j, endpoints},
  For[j = 1, j <= Length[inds], j++,
   endpoints = edges[[inds[[j]], "Ends"]];
   AppendTo[edgeRules, UndirectedEdge[endpoints[[1]], endpoints[[2]]]];
   ];
  Graph[vertices, edgeRules]
  ];


(* Draw a PySecDec-style graph with internal edge labels x0,x1,... and
   external edges labelled by their momentum symbols.  This is useful in the
   examples because the x_i labels are exactly the Lee--Pomeransky parameters
   used in the scaling vectors. *)
ClearAll[drawGraphFromPySecDecInput];
drawGraphFromPySecDecInput[internalLines_, externalLines_] := Module[
  {internalEdges, externalEdges, externalVertices, allEdges, internalLabels, externalLabels},
  internalEdges = Table[UndirectedEdge @@ internalLines[[i, 2]], {i, Length[internalLines]}];
  externalVertices = Table["ext" <> ToString[i], {i, Length[externalLines]}];
  externalEdges = Table[UndirectedEdge[externalLines[[i, 2]], externalVertices[[i]]], {i, Length[externalLines]}];
  allEdges = Join[internalEdges, externalEdges];
  internalLabels = Table[internalEdges[[i]] -> ("x" <> ToString[i - 1]), {i, Length[internalEdges]}];
  externalLabels = Table[externalEdges[[i]] -> ToString[externalLines[[i, 1]]], {i, Length[externalEdges]}];
  Graph[allEdges,
    EdgeLabels -> Join[internalLabels, externalLabels],
    VertexLabels -> "Name",
    GraphLayout -> {"SpringElectricalEmbedding"},
    ImageSize -> Large
  ]
];

(* Enumerate spanning trees as index sets of internal edges. *)
spanningTreeIndexSets[edges_, vertices_] :=
 Module[{subsets, good = {}, i, g, nV},
  nV = Length[vertices];
  subsets = Subsets[Range[Length[edges]], {nV - 1}];
  For[i = 1, i <= Length[subsets], i++,
   g = graphFromEdgeIndices[edges, vertices, subsets[[i]]];
   If[ConnectedGraphQ[g], AppendTo[good, subsets[[i]]]];
   ];
  good
  ];

(* Enumerate spanning two-forests as index sets of internal edges. *)
twoForestIndexSets[edges_, vertices_] :=
 Module[{subsets, good = {}, i, g, nV},
  nV = Length[vertices];
  subsets = Subsets[Range[Length[edges]], {nV - 2}];
  For[i = 1, i <= Length[subsets], i++,
   g = graphFromEdgeIndices[edges, vertices, subsets[[i]]];
   If[Length[ConnectedComponents[g]] == 2 && AcyclicGraphQ[g],
    AppendTo[good, subsets[[i]]]
    ];
   ];
  good
  ];

(* Association: vertex -> total external momentum entering that vertex. *)
externalMomentumAtVertex[externalLines_] :=
 Module[{assoc = <||>, i, mom, vert},
  For[i = 1, i <= Length[externalLines], i++,
   mom = externalLines[[i, 1]];
   vert = externalLines[[i, 2]];
   If[KeyExistsQ[assoc, vert], assoc[vert] = assoc[vert] + mom,
    assoc[vert] = mom]
   ];
  assoc
  ];

(* momentumSquare uses the symbolic scalar-product head sp. *)
momentumSquare[q_] := Expand[sp[q, q]];

(* SymanzikUF[internalLines, externalLines]
   Input:
     internalLines = {{mass,{v1,v2}}, ...}
     externalLines = {{p1,v1}, {p2,v2}, ...}
   Output: Association with keys
     "U", "F", "Variables", "Edges", "Vertices", "SpanningTrees", "TwoForests". *)
SymanzikUF[internalLines_, externalLines_] :=
 Module[{edges, vertices, xs, allEdgeIndices, trees, forests, U = 0,
   Fkin = 0, Fmass = 0, i, j, tree, forest, complement, g, comps,
   comp, vertexMom, q},
  edges = makeEdges[internalLines];
  vertices = allVertices[internalLines, externalLines];
  xs = Table[edges[[i, "X"]], {i, Length[edges]}];
  allEdgeIndices = Range[Length[edges]];
  vertexMom = externalMomentumAtVertex[externalLines];

  trees = spanningTreeIndexSets[edges, vertices];
  For[i = 1, i <= Length[trees], i++,
   tree = trees[[i]];
   complement = Complement[allEdgeIndices, tree];
   U = U + Times @@ xs[[complement]];
   ];

  forests = twoForestIndexSets[edges, vertices];
  For[i = 1, i <= Length[forests], i++,
   forest = forests[[i]];
   complement = Complement[allEdgeIndices, forest];
   g = graphFromEdgeIndices[edges, vertices, forest];
   comps = ConnectedComponents[g];
   comp = comps[[1]];
   q = 0;
   For[j = 1, j <= Length[comp], j++,
    If[KeyExistsQ[vertexMom, comp[[j]]], q = q + vertexMom[comp[[j]]]]
    ];
   Fkin = Fkin + momentumSquare[q] Times @@ xs[[complement]];
   ];

  For[i = 1, i <= Length[edges], i++,
   Fmass = Fmass + xs[[i]] edges[[i, "Mass"]]^2
   ];
  Fmass = U Fmass;

  <|
   "U" -> Expand[U],
   "F" -> Expand[Fkin + Fmass],
   "Variables" -> xs,
   "Edges" -> edges,
   "Vertices" -> vertices,
   "SpanningTrees" -> trees,
   "TwoForests" -> forests
   |>
  ];

(* ---------------------------------------------------------------------- *)
(* Scalar products and kinematic substitutions                             *)
(* ---------------------------------------------------------------------- *)

ClearAll[spExpand, toCyclicMandelstams, toCyclicMandelstams4ptMassless,
  toCyclicMandelstams4ptMassive];

(* Expand linearity of the symbolic scalar product sp. *)
spExpand[expr_] := FixedPoint[
   Expand[# /. sp[a_ + b_, c_] :> sp[a, c] + sp[b, c] /. 
       sp[a_, b_ + c_] :> sp[a, b] + sp[a, c]] &,
   expr
   ];

(* Five-point cyclic massless kinematics. *)
toCyclicMandelstams[expr_] := Module[{rules},
  rules = {
    sp[p1, p1] -> 0, sp[p2, p2] -> 0, sp[p3, p3] -> 0,
    sp[p4, p4] -> 0, sp[p5, p5] -> 0,
    sp[p1, p2] -> s12/2, sp[p2, p3] -> s23/2,
    sp[p3, p4] -> s34/2, sp[p4, p5] -> s45/2,
    sp[p1, p5] -> s15/2,
    sp[p1, p3] -> (s45 - s12 - s23)/2,
    sp[p2, p4] -> (s15 - s23 - s34)/2,
    sp[p3, p5] -> (s12 - s34 - s45)/2,
    sp[p1, p4] -> (s23 - s45 - s15)/2,
    sp[p2, p5] -> (s34 - s15 - s12)/2
    };
  Expand[spExpand[expr] //. {sp[a_, b_] /; OrderedQ[{b, a}] :> sp[b, a]} /. rules]
  ];

(* Four-point massless kinematics. Uses s13 = -s12 - s23. *)
toCyclicMandelstams4ptMassless[expr_] := Module[{rules},
  rules = {
      sp[p1, p1] -> 0, sp[p2, p2] -> 0,
      sp[p3, p3] -> 0, sp[p4, p4] -> 0,
      sp[p1, p2] -> s12/2, sp[p1, p3] -> s13/2,
      sp[p1, p4] -> s23/2, sp[p2, p3] -> s23/2,
      sp[p2, p4] -> s13/2, sp[p3, p4] -> s12/2
      } /. {s13 -> -s12 - s23};
  Expand[spExpand[expr] //. sp[a_, b_] /; ! OrderedQ[{a, b}] :> sp[b, a] /. rules]
  ];

(* Four-point kinematics with p_i^2 left as p1sq,...,p4sq. *)
toCyclicMandelstams4ptMassive[expr_] := Module[{rules},
  rules = {
      sp[p1, p1] -> p1sq, sp[p2, p2] -> p2sq,
      sp[p3, p3] -> p3sq, sp[p4, p4] -> p4sq,
      sp[p1, p2] -> s12/2, sp[p1, p3] -> s13/2,
      sp[p1, p4] -> s23/2, sp[p2, p3] -> s23/2,
      sp[p2, p4] -> s13/2, sp[p3, p4] -> s12/2
      } /. {s13 -> -s12 - s23};
  Expand[spExpand[expr] //. sp[a_, b_] /; ! OrderedQ[{a, b}] :> sp[b, a] /. rules]
  ];

(* ---------------------------------------------------------------------- *)
(* Cancellation-factor discovery                                           *)
(* ---------------------------------------------------------------------- *)

ClearAll[monomialQ, binomialQ, derivativeFactors,
  primitiveChannelDirections, resolveDimensionfulKinVars, kinematicallyHomogeneousQ,
  channelDirectionFactors, kinematicCoefficientFactors, derivativeFactorsExtended,
  hrfKinDomainCompatibleQ, positiveCompatibleQ, simultaneouslyAdmissibleSubsetQ];
Quiet @ Check[Unprotect[safeCancellationFactors, safeCancellationFactorsExtended], Null];
ClearAll[safeCancellationFactors, safeCancellationFactorsExtended];

If[! ValueQ[$HRFChannelDirectionMaxCoeff], $HRFChannelDirectionMaxCoeff = 1];

monomialQ[p_, vars_] := Length[MonomialList[Expand[p], vars]] == 1;

binomialQ[p_, vars_] := Length[MonomialList[Expand[p], vars]] == 2;

(* Factors obtained from complete derivative polynomials. *)
derivativeFactors[F_, vars_] := AssociationThread[
   vars,
   Table[
    DeleteDuplicates[
     Select[FactorList[Factor[D[F, v]]][[All, 1]],
      # =!= 1 && # =!= -1 && ! monomialQ[#, vars] &]
     ],
    {v, vars}
    ]
   ];

(* Primitive projective integer directions in kinematic-coefficient space.
   For massless examples the default max coefficient is 1, so for two
   channels this tests s12, s23 and s12 +/- s23.  This removes the
   basis-dependence of searching only individual Mandelstam coefficients. *)
primitiveChannelDirections[n_Integer, maxCoeff_:Automatic] := Module[
  {m, raw, primitive, canonical},
  m = Replace[maxCoeff, Automatic :> $HRFChannelDirectionMaxCoeff];
  If[n <= 0, Return[{}]];
  raw = DeleteCases[Tuples[Range[-m, m], n], ConstantArray[0, n]];
  primitive = Select[raw, GCD @@ DeleteCases[Abs[#], 0] == 1 &];
  canonical[v_] := Module[{w = v, first},
    first = FirstCase[w, a_ /; a != 0, 0];
    If[first < 0, -w, w]
    ];
  DeleteDuplicates[canonical /@ primitive]
  ];

(* After a kinematic parametrization, extended channel-direction factors can
   mix dimensionful and dimensionless kinematic parameters inside one binomial.
   By default Automatic treats every kinVar as dimensionful (Mandelstam-native
   wide-angle use).  For spacelike collinear five-point kinematics pass e.g.
   DimensionfulKinVars -> {s} while x and z remain dimensionless ratios. *)
resolveDimensionfulKinVars[kinVars_, Automatic] := kinVars;
resolveDimensionfulKinVars[kinVars_, None] := {};
resolveDimensionfulKinVars[kinVars_, spec_List] := Intersection[kinVars, spec];

kinematicallyHomogeneousQ[p_, vars_, kinVars_, dimensionfulSpec_: Automatic] := Module[
  {df = resolveDimensionfulKinVars[kinVars, dimensionfulSpec], ml, degs},
  If[df === {}, Return[True]];
  ml = MonomialList[Expand[p], DeleteDuplicates@Join[vars, kinVars]];
  degs = Total[hrfExponentListInVars[#, df]] & /@ ml;
  Length[DeleteDuplicates[degs]] <= 1
  ];

channelDirectionFactors[derivative_, vars_, kinVars_, maxCoeff_:Automatic,
   dimensionfulSpec_:Automatic] := Module[
  {d, coeffs, dirs, df},
  d = Expand[derivative];
  coeffs = Coefficient[d, #] & /@ kinVars;
  dirs = primitiveChannelDirections[Length[kinVars], maxCoeff];
  df = resolveDimensionfulKinVars[kinVars, dimensionfulSpec];
  DeleteDuplicates @ Flatten[
    Table[
      Module[{lin, fl},
        lin = Expand[Total[dirs[[j]]*coeffs]];
        If[lin === 0,
          {},
          fl = FactorList[Factor[lin]][[All, 1]];
          Select[fl,
            # =!= 1 && # =!= -1 && ! monomialQ[#, vars] &&
              kinematicallyHomogeneousQ[#, vars, kinVars, df] &
            ]
          ]
        ],
      {j, Length[dirs]}
      ],
    1]
  ];

(* Additional factors obtained from primitive linear combinations of the
   independent kinematic coefficients of derivative polynomials.  Searching
   coefficient combinations, rather than only individual coefficients, is
   necessary after momentum conservation has eliminated one Mandelstam channel. *)
kinematicCoefficientFactors[F_, vars_, kinVars_, maxCoeff_:Automatic,
   dimensionfulSpec_:Automatic] := Association[
   Table[
    v -> channelDirectionFactors[D[F, v], vars, kinVars, maxCoeff, dimensionfulSpec],
    {v, vars}
    ]
   ];

(* Union of derivative factors and kinematic-coefficient factors. *)
derivativeFactorsExtended[F_, vars_, kinVars_, dimensionfulSpec_:Automatic] := Module[
  {ordinary, byKin},
  ordinary = derivativeFactors[F, vars];
  byKin = kinematicCoefficientFactors[F, vars, kinVars, Automatic, dimensionfulSpec];
  Association[
   Table[
    v -> DeleteDuplicates[Join[Lookup[ordinary, v, {}], Lookup[byKin, v, {}]]],
    {v, vars}
    ]
   ]
  ];

(* Feasibility test: does there exist kinematics in the prescribed domain and
   positive Lee--Pomeransky parameters with C == 0?  Uses FindInstance so
   acceptance is monotone under domain restriction (stronger domain subset of
   weaker cannot admit more factors). *)
hrfKinDomainCompatibleQ[C_, vars_, kinAssumptions_, kinVars_] := Module[{inst, allVars,
    timeLimit = If[ValueQ[$HRFKinDomainFindInstanceTimeLimit], $HRFKinDomainFindInstanceTimeLimit, 5]},
  allVars = DeleteDuplicates @ Join[kinVars, vars];
  inst = TimeConstrained[
    Quiet @ FindInstance[
      kinAssumptions && Expand[C] == 0 && And @@ Thread[vars > 0],
      allVars,
      Reals
    ],
    timeLimit,
    {}
  ];
  ListQ[inst] && inst =!= {} && inst =!= $Failed
];

positiveCompatibleQ[C_, vars_, kinAssumptions_, kinVars_] :=
  hrfKinDomainCompatibleQ[C, vars, kinAssumptions, kinVars];

(* PDF (5.12): a subset S = {f1,...,fr} is admissible when all factors can
   vanish simultaneously with positive Lee--Pomeransky parameters and s in K. *)
simultaneouslyAdmissibleSubsetQ[factors_List, vars_, kinAssumptions_, kinVars_] := Module[
  {ff = DeleteDuplicates[Flatten[{factors}]], inst, allVars},
  Which[
    ff === {}, True,
    Length[ff] == 1, positiveCompatibleQ[First[ff], vars, kinAssumptions, kinVars],
    True,
    allVars = DeleteDuplicates @ Join[kinVars, vars];
    inst = TimeConstrained[
      Quiet @ FindInstance[
        kinAssumptions &&
          And @@ Thread[vars > 0] &&
          And @@ (Expand[#] == 0 & /@ ff),
        allVars,
        Reals
      ],
      If[ValueQ[$HRFKinDomainFindInstanceTimeLimit], $HRFKinDomainFindInstanceTimeLimit, 5],
      {}
    ];
    ListQ[inst] && inst =!= {} && inst =!= $Failed
  ]
];

(* Return {safeFactors, factorsByDerivative}. Only binomial factors are kept. *)
safeCancellationFactors[F_, vars_, kinAssumptions_, kinVars_] :=
 Module[{factorsByDerivative, allFactors, safeFactors},
  factorsByDerivative = derivativeFactors[F, vars];
  allFactors = DeleteDuplicates[Flatten[Values[factorsByDerivative]]];
  safeFactors = Select[allFactors,
    binomialQ[#, vars] && positiveCompatibleQ[#, vars, kinAssumptions, kinVars] &
    ];
  {safeFactors, factorsByDerivative}
  ];

(* Extended version including kinematic-sector derivative factors. *)
safeCancellationFactorsExtended[F_, vars_, kinAssumptions_, kinVars_,
   dimensionfulSpec_:Automatic] :=
 Module[{factorsByDerivative, allFactors, safeFactors},
  factorsByDerivative = derivativeFactorsExtended[F, vars, kinVars, dimensionfulSpec];
  allFactors = DeleteDuplicates[Flatten[Values[factorsByDerivative]]];
  safeFactors = Select[allFactors,
    binomialQ[#, vars] && positiveCompatibleQ[#, vars, kinAssumptions, kinVars] &
    ];
  {safeFactors, factorsByDerivative}
  ];

(* ---------------------------------------------------------------------- *)
(* Obstruction finding and generator-set scans                             *)
(* ---------------------------------------------------------------------- *)

ClearAll[hrfObstructionRemainderCoefficients, hrfObstructionTermCount,
  hrfGeneratorMonomialCountInVars, hrfResolveMaxObstructionSize,
  hrfGeneratorPolynomialFactors, hrfRestrictPolynomialModFactors,
  hrfObstructionDerivativeConsistentQ, hrfObstructionQuotientFsl,
  hrfObstructionTermIndicesFromObs, hrfObstructionFromGeneratorVanishing,
  hrfObstructionAlgebraicSearch,
  hrfObstructionBinarySearchInstance,
  hrfObstructionApplyBinarySolution, hrfObstructionSuperleadingRemainder,
  hrfObstructionSuperleadingInIdealQ,
  obstructionByOriginalTermsGeneral, pairSectorGenerators,
  factorsDividingGenerator, generatorSetFactorUnion, generatorSetAdmissibilityData,
  hrfFactorizeGeneratorForOutput, hrfFormatGeneratorsForOutput,
  slSectorAdmissibilityData, hrfPolynomialTotalDegreeInVars, hrfPolynomialMaxVarExponentInVars,
  hrfInferGeneratorDegreeBoundsFromF, hrfResolveGeneratorDegreeBounds,
  hrfGeneratorDegreeAdmissibleQ, hrfGeneratorSetDegreeAdmissibleQ,
  hrfCancellationFactorDegreeAdmissibleQ, hrfGeneratorProductDegreeAdmissibleQ,
  hrfFilterFactorsForGenerators,
  candidateGeneratorSets, candidateGeneratorSetsDiagnostic, candidateGeneratorSetsAdaptive,
  generatorFactorData, admissibleGeneratorSetQ, generatorUseData, generatorSetScore,
  hrfObstructionTrialRank, hrfValidObstructionTrialQ, hrfWideAngleKinSectorPresentationTrialQ,
  hrfResolveRequireValidScalingForHiddenRegionQ, hrfResolveEnumerateHiddenRegionsQ,
  hrfTrialEffectiveSuperleading, hrfTrialObstructionForScaling, hrfMiniScanFromTrial,
  hrfTrialCoverageFoundQ, hrfTrialCoverageScalingData, hrfEvaluateValidTrialScaling,
  hrfHiddenRegionScanFromTrial,
  findObstructions, findObstructionsDebug,
  obstructionGeneratorDiagnostic];

(* Coefficients of the obstruction remainder w.r.t. Symanzik variables only.
   Kinematic parameters (s12, s23, ...) stay inside the coefficients.  A candidate
   bb[i] selection is accepted only after PolynomialReduce[F_SL, generators] gives
   remainder == 0 exactly (see obstructionByOriginalTermsGeneral). *)
hrfObstructionRemainderCoefficients[rem_, vars_] := Module[{cr},
  cr = CoefficientRules[Expand[rem], vars];
  If[cr === {}, {0}, DeleteDuplicates @ Flatten @ Values[cr]]
];

hrfObstructionSuperleadingRemainder[fsl_, generators_, allVars_] := Module[{rem},
  rem = PolynomialReduce[Expand[fsl], generators, allVars][[2]];
  Expand[rem]
];

hrfObstructionSuperleadingInIdealQ[fsl_, generators_, allVars_] := Module[{rem},
  If[generators === {} || MatchQ[fsl, _Missing], Return[False]];
  rem = hrfObstructionSuperleadingRemainder[fsl, generators, allVars];
  TrueQ[rem === 0]
];

(* Symanzik-polynomial factors of a generator (drop numeric/content pieces). *)
hrfGeneratorPolynomialFactors[g_, vars_] := Module[{factors},
  factors = FactorList[g][[All, 1]];
  factors = DeleteCases[factors, _?NumericQ];
  factors = Select[factors, ! FreeQ[#, Alternatives @@ vars] &];
  DeleteDuplicates[Expand /@ factors]
];

(* Restrict p to the common vanishing locus f_k = 0 (sequential remainder mod each f_k). *)
hrfRestrictPolynomialModFactors[p_, factors_List, allVars_] :=
  Fold[Function[{r, f}, PolynomialReduce[Expand[r], {f}, allVars][[2]]], Expand[p], factors];

(* On {f_k = 0}, F_SL terms from the generator ideal vanish; the surviving
   derivative equations D[F,x_i] = D[Obs,x_i] must hold modulo all f_k. *)
hrfObstructionDerivativeConsistentQ[F_, obs_, factors_List, vars_List, allVars_] := Module[
  {restrict},
  restrict[p_] := hrfRestrictPolynomialModFactors[p, factors, allVars];
  And @@ Table[
    TrueQ[restrict[Expand[D[F, v] - D[obs, v]]] === 0],
    {v, vars}
  ]
];

hrfObstructionQuotientFsl[F_, generators_, allVars_] := Module[{gs, pr, quo, obs, fsl},
  gs = DeleteCases[Expand /@ generators, 0];
  pr = PolynomialReduce[Expand[F], gs, allVars];
  quo = pr[[1]];
  obs = Expand[pr[[2]]];
  fsl = Expand @ Which[
    ListQ[quo] && Length[quo] === Length[gs], Total @ MapThread[Times, {quo, gs}],
    ListQ[quo] && Length[gs] === 1, First[quo]*First[gs],
    True, quo*First[gs]
  ];
  {fsl, obs, gs}
];

hrfObstructionTermIndicesFromObs[F_, obs_] := Module[{terms, obsterms, pos},
  terms = List @@ Expand[F];
  obsterms = DeleteCases[List @@ Expand[obs], 0];
  If[obsterms === {}, Return[{}]];
  pos = Flatten @ Table[
    FirstCase[Position[terms, t], {i_} :> i, Nothing],
    {t, obsterms}
  ];
  DeleteDuplicates @ Sort[pos]
];

(* Obstruction from F = F_SL + Obs with F_SL in the generator ideal.  Equivalently
   Obs is the remainder of F modulo ⟨g⟩; on the generator vanishing locus only Obs
   survives and its derivatives satisfy the restricted Landau system. *)
hrfObstructionFromGeneratorVanishing[F_, generators_, vars_, kinVars_] := Module[
  {allVars, fsl, obs, gs, factors, derivQ, indices, terms, obsterms},
  allVars = DeleteDuplicates @ Join[vars, kinVars];
  If[generators === {}, Return[Missing["NoGenerators"]]];
  If[Expand[F] === 0, Return[Missing["ZeroOrUndefinedPolynomial"]]];
  {fsl, obs, gs} = hrfObstructionQuotientFsl[F, generators, allVars];
  If[! TrueQ[Expand[fsl + obs] === Expand[F]], Return[Missing["QuotientDecompositionFailed"]]];
  If[TrueQ[obs === 0], Return[Missing["NoObstructionAllInIdeal"]]];
  If[! hrfObstructionSuperleadingInIdealQ[fsl, gs, allVars], Return[Missing["QuotientFSLNotInIdeal"]]];
  factors = DeleteDuplicates @ Flatten[hrfGeneratorPolynomialFactors[#, vars] & /@ gs];
  derivQ = If[factors === {}, True, hrfObstructionDerivativeConsistentQ[F, obs, factors, vars, allVars]];
  terms = List @@ Expand[F];
  indices = hrfObstructionTermIndicesFromObs[F, obs];
  obsterms = If[indices =!= {}, terms[[indices]], DeleteCases[List @@ Expand[obs], 0]];
  <|
   "Indices" -> indices,
   "ObstructionTerms" -> obsterms,
   "Obstruction" -> Factor[obs],
   "Superleading" -> Factor[fsl],
   "Complement" -> Factor[fsl],
   "Generators" -> hrfFormatGeneratorsForOutput[generators, {}, vars, kinVars],
   "InIdealQ" -> True,
   "IdealMembershipRemainder" -> 0,
   "DerivativeConsistentQ" -> derivQ,
   "SearchMethod" -> "GeneratorVanishingIdealQuotient"
   |>
];

(* Fast obstruction search for single-generator principal ideals.
   If generators == {g} and g factors as product of polynomials f_k, then
   F_SL ∈ ⟨g⟩ implies F_SL ≡ 0 (mod f_k) for all k.  We search for a subset of
   original monomials whose sum satisfies these modular constraints using a
   meet-in-the-middle subset-sum over polynomial remainders. *)
hrfObstructionAlgebraicSearchPrincipalMeetInMiddle[F_, g_, vars_, kinVars_, maxSize_: Automatic] := Module[
  {terms, n, allVars, maxSizeEff, maxK, factors, polyFactors, consCount,
   half, idxA, idxB, remsA, remsB, dict, nodesVisited = 0,
   subsetMasksA, subsetMasksB, mask, sumRem, sumSize, key, negKey, best,
   addVec, mkKey, candidateA, slIdx, obsIdx, fsl},
  terms = List @@ Expand[F];
  If[terms === {} || terms === {0}, Return[{Missing["ZeroOrUndefinedPolynomial"], 0}]];
  n = Length[terms];
  If[n <= 1, Return[{Missing["NoObstructionFound", 0], 0}]];
  allVars = DeleteDuplicates @ Join[vars, kinVars];
  maxSizeEff = hrfResolveMaxObstructionSize[F, {g}, vars, maxSize];
  maxK = Min[maxSizeEff, n - 1];

  factors = FactorList[g][[All, 1]];
  polyFactors = DeleteCases[factors, _?NumericQ];
  polyFactors = Select[polyFactors, ! FreeQ[#, Alternatives @@ vars] &];
  polyFactors = DeleteDuplicates @ (Expand /@ polyFactors);
  consCount = Length[polyFactors];
  If[consCount === 0, Return[{Missing["NotApplicable"], 0}]];

  half = Floor[n/2];
  idxA = Range[half];
  idxB = Range[half + 1, n];

  addVec[v1_, v2_] := MapThread[Expand[#1 + #2] &, {v1, v2}];
  mkKey[v_] := ToString[InputForm[CoefficientRules[#, vars]]] & /@ v;

  remsA = Table[
    Table[
      PolynomialReduce[Expand[terms[[j]]], {polyFactors[[k]]}, allVars][[2]] // Expand,
      {k, consCount}
    ],
    {j, idxA}
  ];
  remsB = Table[
    Table[
      PolynomialReduce[Expand[terms[[j]]], {polyFactors[[k]]}, allVars][[2]] // Expand,
      {k, consCount}
    ],
    {j, idxB}
  ];

  dict = <||>;
  subsetMasksA = Range[0, 2^Length[idxA] - 1];
  Do[
    mask = subsetMasksA[[i]];
    sumRem = ConstantArray[0, consCount];
    sumSize = 0;
    Do[
      If[BitGet[mask, j - 1] === 1,
        sumRem = addVec[sumRem, remsA[[j]]];
        sumSize++;
      ],
      {j, Length[idxA]}
    ];
    nodesVisited++;
    key = mkKey[sumRem];
    best = Lookup[dict, key, {-1, -1}];
    If[sumSize > best[[1]], dict[key] = {sumSize, mask}],
    {i, Length[subsetMasksA]}
  ];

  subsetMasksB = Range[0, 2^Length[idxB] - 1];
  best = {-1, -1, -1}; (* totalSize, maskA, maskB *)
  Do[
    mask = subsetMasksB[[i]];
    sumRem = ConstantArray[0, consCount];
    sumSize = 0;
    Do[
      If[BitGet[mask, j - 1] === 1,
        sumRem = addVec[sumRem, remsB[[j]]];
        sumSize++;
      ],
      {j, Length[idxB]}
    ];
    nodesVisited++;
    negKey = mkKey[Map[Expand[-#] &, sumRem]];
    If[KeyExistsQ[dict, negKey],
      candidateA = dict[negKey];
      If[candidateA[[1]] + sumSize > best[[1]],
        best = {candidateA[[1]] + sumSize, candidateA[[2]], mask};
      ]
    ],
    {i, Length[subsetMasksB]}
  ];

  If[best[[1]] < 1, Return[{Missing["NoObstructionFound", maxK], nodesVisited}]];

  slIdx = {};
  Do[
    If[BitGet[best[[2]], j - 1] === 1, AppendTo[slIdx, idxA[[j]]]],
    {j, Length[idxA]}
  ];
  Do[
    If[BitGet[best[[3]], j - 1] === 1, AppendTo[slIdx, idxB[[j]]]],
    {j, Length[idxB]}
  ];
  slIdx = Sort @ DeleteDuplicates @ slIdx;
  obsIdx = Complement[Range[n], slIdx];

  If[Length[obsIdx] > maxK || slIdx === {} || Length[slIdx] === n,
    Return[{Missing["NoObstructionFound", maxK], nodesVisited}]
  ];

  fsl = Expand[Total[terms[[slIdx]]]];
  If[hrfObstructionSuperleadingInIdealQ[fsl, {g}, allVars],
    {obsIdx, nodesVisited},
    {Missing["NoObstructionFound", maxK], nodesVisited}
  ]
];

(* Monomial terms of F used by the binary obstruction selector (bb[i]). *)
hrfObstructionTermCount[F_] := Module[{terms = List @@ Expand[F]},
  If[terms === {0}, 0, Length @ DeleteCases[terms, 0]]
];

(* Sum of x-monomial counts in each generator (pair-sector g = product of f_k). *)
hrfGeneratorMonomialCountInVars[generators_List, vars_] := Module[{gs},
  gs = DeleteCases[Expand /@ generators, 0];
  If[gs === {}, 0, Total[Length[MonomialList[#, vars]] & /@ gs]]
];

(* Maximum obstruction terms for binary subset selection bb[i] on F.
   Only requirement: at least one F monomial remains for F_SL (|Obs| <= |F|-1).
   Generator monomial count does NOT cap this — ideal membership is checked after selection. *)
hrfResolveMaxObstructionSize[F_, generators_, vars_, maxSize_:Automatic] := Module[
  {n = hrfObstructionTermCount[F], bound},
  If[n === 0, Return[0]];
  bound = Max[1, n - 1];
  Which[
    maxSize === Automatic || maxSize === Infinity, bound,
    IntegerQ[maxSize] && maxSize > 0, Max[bound, maxSize],
    True, bound
  ]
];

(* Enumerate obstruction subsets by increasing size k = |Obs|, testing whether
   F_SL = F - sum of removed monomials lies in the generator ideal. *)
hrfObstructionAlgebraicSearch[F_, generators_, vars_, kinVars_, maxSize_: Automatic,
   kinAssumptions_: True] := Module[
  {terms, allVars, n, maxSizeEff, maxK, limit, nodesVisited, k, obs, slSet, Fsl},
  terms = List @@ Expand[F];
  If[terms === {} || terms === {0}, Return[{Missing["ZeroOrUndefinedPolynomial"], 0}]];
  If[generators === {}, Return[{Missing["NoGenerators"], 0}]];
  n = Length[terms];
  allVars = DeleteDuplicates @ Join[vars, kinVars];
  maxSizeEff = hrfResolveMaxObstructionSize[F, generators, vars, maxSize];
  maxK = Min[maxSizeEff, n - 1];

  If[Length[generators] === 1,
    Module[{fast},
      fast = hrfObstructionAlgebraicSearchPrincipalMeetInMiddle[F, First[generators], vars, kinVars, maxSize];
      If[! MatchQ[First[fast], Missing["NotApplicable"]], Return[fast]];
    ]
  ];

  limit = If[ValueQ[$HRFObstructionAlgebraicSearchLimit], $HRFObstructionAlgebraicSearchLimit, 500000];
  nodesVisited = 0;
  Catch[
    Do[
      Do[
        slSet = Complement[Range[n], obs];
        If[slSet === {}, Continue[]];
        Fsl = Expand[Total[terms[[slSet]]]];
        nodesVisited++;
        If[nodesVisited > limit,
          Throw[{Missing["NoObstructionFound", maxK], nodesVisited}, "hrfObstructionAlgebraicSearch"]
        ];
        If[hrfObstructionSuperleadingInIdealQ[Fsl, generators, allVars],
          Throw[{obs, nodesVisited}, "hrfObstructionAlgebraicSearch"]
        ],
        {obs, Subsets[Range[n], {k}]}
      ],
      {k, 0, maxK}
    ];
    {Missing["NoObstructionFound", maxK], nodesVisited},
    "hrfObstructionAlgebraicSearch"
  ]
];

hrfObstructionBinarySearchInstance[coeffs_, b_, kinVars_, kinAssumptions_, maxSize_] := Module[
  {unk, kinC, eqs, timeLimit = If[ValueQ[$HRFObstructionFindInstanceTimeLimit], $HRFObstructionFindInstanceTimeLimit, 20]},
  unk = If[kinVars === {}, b, Join[b, kinVars]];
  kinC = Which[
    kinAssumptions === True, {},
    kinAssumptions === {}, {},
    True, {kinAssumptions}
  ];
  eqs = Join[
    Thread[Expand /@ coeffs == 0],
    Thread[0 <= b <= 1],
    {Element[b, Integers], Total[b] <= maxSize},
    kinC
  ];
  TimeConstrained[
    If[kinVars === {},
      Quiet @ FindInstance[eqs, b, Integers],
      Quiet @ FindInstance[eqs, unk, Reals]
    ],
    timeLimit,
    {}
  ]
];

hrfObstructionApplyBinarySolution[b_, sol_] := Module[{bbRules},
  If[! ListQ[sol] || sol === {}, Return[b]];
  bbRules = Select[First[sol], MatchQ[First[#], bb[_]] &];
  b /. bbRules
];

(* obstructionByOriginalTermsGeneral[F, generators, vars, kinVars, maxSize, kinAssumptions]
   searches for a subset of original monomials of F whose removal makes the
   remainder lie in the ideal generated by 'generators'.
   Acceptance requires PolynomialReduce[F_SL, generators] remainder == 0 exactly.
   Returns an Association with keys "Obstruction", "Superleading", etc.,
   or Missing[...] if none is found. *)
obstructionByOriginalTermsGeneral[F_, generators_, vars_, kinVars_, maxSize_ : Automatic,
   kinAssumptions_: True] :=
 Module[{terms, allVars, vanish, search, selected, Fobst, Fsl, remSL, maxSizeEff},
  terms = List @@ Expand[F];
  If[terms === {} || terms === {0}, Return[Missing["ZeroOrUndefinedPolynomial"]]];
  If[generators === {}, Return[Missing["NoGenerators"]]];

  maxSizeEff = hrfResolveMaxObstructionSize[F, generators, vars, maxSize];
  allVars = DeleteDuplicates@Join[vars, kinVars];

  vanish = hrfObstructionFromGeneratorVanishing[F, generators, vars, kinVars];
  If[! MatchQ[vanish, _Missing], Return[vanish]];

  search = hrfObstructionAlgebraicSearch[F, generators, vars, kinVars, maxSize, kinAssumptions];
  selected = First[search];

  If[MatchQ[selected, _Missing], Return[selected]];

  Fobst = Factor[Total[terms[[selected]]]];
  Fsl = Expand[F - Total[terms[[selected]]]];
  remSL = hrfObstructionSuperleadingRemainder[Fsl, generators, allVars];

  If[! TrueQ[remSL === 0],
    Return[Missing["NoObstructionFound", "Superleading not in generator ideal", maxSizeEff]]
  ];

  <|
   "Indices" -> selected,
   "ObstructionTerms" -> terms[[selected]],
   "Obstruction" -> Fobst,
   "Superleading" -> Factor[Fsl],
   "Complement" -> Factor[Fsl],
   "Generators" -> hrfFormatGeneratorsForOutput[generators, {}, vars, kinVars],
   "InIdealQ" -> True,
   "IdealMembershipRemainder" -> 0
   |>
  ];


(* Diagnostic variant of obstructionByOriginalTermsGeneral.  It returns both the
   usual result and compact information about why a generator set was accepted
   or rejected by the obstruction search.  This does not change the mathematics;
   it only exposes the intermediate data. *)
obstructionByOriginalTermsGeneralDiagnosticCore[F_, generators_, vars_, kinVars_, maxSize_ : Automatic,
   channelTag_ : "OriginalChannelBasis", backRules_ : {}, kinAssumptions_: True] :=
 Module[{terms, allVars, rem, vanish, selected, Fobst, Fsl, result, remSL, maxSizeEff,
   genMonoCount, termCount, search, nodesVisited},
  terms = List @@ Expand[F];
  termCount = If[terms === {} || terms === {0}, 0, Length[terms]];
  genMonoCount = hrfGeneratorMonomialCountInVars[generators, vars];
  maxSizeEff = hrfResolveMaxObstructionSize[F, generators, vars, maxSize];
  If[terms === {} || terms === {0},
   Return[<|
     "Result" -> Missing["ZeroOrUndefinedPolynomial"],
     "AttemptData" -> <|
       "GeneratorSet" -> Factor /@ generators,
       "GeneratorCount" -> Length[generators],
       "TermCount" -> 0,
       "MaxObstructionTerms" -> maxSizeEff,
       "ChannelBasis" -> channelTag,
       "AcceptedQ" -> False,
       "RejectedReason" -> "ZeroOrUndefinedPolynomial"
       |>
     |>]
   ];
  If[generators === {},
   Return[<|
     "Result" -> Missing["NoGenerators"],
     "AttemptData" -> <|
       "GeneratorSet" -> {},
       "GeneratorCount" -> 0,
       "TermCount" -> Length[terms],
       "MaxObstructionTerms" -> maxSizeEff,
       "GeneratorMonomialCount" -> genMonoCount,
       "ChannelBasis" -> channelTag,
       "AcceptedQ" -> False,
       "RejectedReason" -> "NoGenerators"
       |>
     |>]
   ];

  allVars = DeleteDuplicates@Join[vars, kinVars];
  rem = PolynomialReduce[Expand[F], generators, allVars][[2]];

  vanish = hrfObstructionFromGeneratorVanishing[F, generators, vars, kinVars];
  If[! MatchQ[vanish, _Missing],
   Return[<|
     "Result" -> vanish,
     "AttemptData" -> <|
       "GeneratorSet" -> Factor /@ generators,
       "GeneratorCount" -> Length[generators],
       "TermCount" -> termCount,
       "GeneratorMonomialCount" -> genMonoCount,
       "MaxObstructionTerms" -> maxSizeEff,
       "MaxObstructionTermsComputedQ" -> True,
       "ChannelBasis" -> channelTag,
       "SearchMethod" -> Lookup[vanish, "SearchMethod", "GeneratorVanishingIdealQuotient"],
       "DerivativeConsistentQ" -> Lookup[vanish, "DerivativeConsistentQ", Missing["NotChecked"]],
       "NodesVisited" -> 0,
       "GenericRemainderTermCount" -> Length[List @@ Expand[rem]],
       "SelectedTermIndices" -> Lookup[vanish, "Indices", {}],
       "SelectedTermCount" -> Length[Lookup[vanish, "Indices", {}]],
       "Obstruction" -> Lookup[vanish, "Obstruction", Missing[]],
       "Superleading" -> Lookup[vanish, "Superleading", Missing[]],
       "AcceptedQ" -> True,
       "RejectedReason" -> "--"
       |>
     |>]
  ];

  search = hrfObstructionAlgebraicSearch[F, generators, vars, kinVars, maxSize, kinAssumptions];
  selected = First[search];
  nodesVisited = Last[search];

  If[MatchQ[selected, _Missing],
   Return[<|
     "Result" -> selected,
     "AttemptData" -> <|
       "GeneratorSet" -> Factor /@ generators,
       "GeneratorCount" -> Length[generators],
       "TermCount" -> termCount,
       "GeneratorMonomialCount" -> genMonoCount,
       "MaxObstructionTerms" -> maxSizeEff,
       "MaxObstructionTermsComputedQ" -> True,
       "ChannelBasis" -> channelTag,
       "SearchMethod" -> "AlgebraicIdealMembership",
       "NodesVisited" -> nodesVisited,
       "GenericRemainderTermCount" -> Length[List @@ Expand[rem]],
       "SelectedTermIndices" -> {},
       "AcceptedQ" -> False,
       "RejectedReason" -> "No obstruction subset found by algebraic ideal-membership search within max size / node limit"
       |>
     |>]
   ];

  Fobst = Factor[Total[terms[[selected]]] /. backRules];
  Fsl = Expand[(F - Total[terms[[selected]]]) /. backRules];
  remSL = hrfObstructionSuperleadingRemainder[Fsl, generators, allVars];

  If[! TrueQ[remSL === 0],
   Return[<|
     "Result" -> Missing["NoObstructionFound", maxSizeEff],
     "AttemptData" -> <|
       "GeneratorSet" -> Factor /@ generators,
       "GeneratorCount" -> Length[generators],
       "TermCount" -> termCount,
       "GeneratorMonomialCount" -> genMonoCount,
       "MaxObstructionTerms" -> maxSizeEff,
       "MaxObstructionTermsComputedQ" -> True,
       "ChannelBasis" -> channelTag,
       "SearchMethod" -> "AlgebraicIdealMembership",
       "NodesVisited" -> nodesVisited,
       "GenericRemainderTermCount" -> Length[List @@ Expand[rem]],
       "SelectedTermIndices" -> selected,
       "SelectedTermCount" -> Length[selected],
       "Obstruction" -> Fobst,
       "Superleading" -> Factor[Fsl],
       "IdealMembershipRemainder" -> remSL,
       "AcceptedQ" -> False,
       "RejectedReason" -> "Candidate obstruction failed exact ideal membership: PolynomialReduce[F_SL, generators] remainder is nonzero"
       |>
     |>]
   ];

  result = <|
    "Indices" -> selected,
    "ObstructionTerms" -> terms[[selected]],
    "Obstruction" -> Fobst,
    "Superleading" -> Factor[Fsl],
    "Complement" -> Factor[Fsl],
    "Generators" -> hrfFormatGeneratorsForOutput[generators, {}, vars, kinVars],
    "InIdealQ" -> True,
    "IdealMembershipRemainder" -> 0
    |>;
  <|
   "Result" -> result,
   "AttemptData" -> <|
     "GeneratorSet" -> Factor /@ generators,
     "GeneratorCount" -> Length[generators],
     "TermCount" -> termCount,
     "GeneratorMonomialCount" -> genMonoCount,
     "MaxObstructionTerms" -> maxSizeEff,
     "MaxObstructionTermsComputedQ" -> True,
     "ChannelBasis" -> channelTag,
     "SearchMethod" -> "AlgebraicIdealMembership",
     "NodesVisited" -> nodesVisited,
     "GenericRemainderTermCount" -> Length[List @@ Expand[rem]],
     "SelectedTermIndices" -> selected,
     "SelectedTermCount" -> Length[selected],
     "Obstruction" -> Fobst,
     "Superleading" -> Fsl,
     "AcceptedQ" -> True,
     "RejectedReason" -> "--"
     |>
   |>
  ];


(* Channel-aware diagnostic obstruction search.  The default search in the
   explicit independent Mandelstam basis can be basis-dependent after momentum
   conservation.  For two-channel four-point kinematics we also test the crossed
   primitive basis {s12, s12+s23}, implemented by substituting
   s23 -> eta - s12, and then mapping eta back to s12+s23 for reporting. *)
ClearAll[hrfNonzeroObstructionResultQ, hrfExactReductionObstructionResultQ,
  hrfValidObstructionResultQ, obstructionByOriginalTermsGeneralDiagnostic];
hrfNonzeroObstructionResultQ[res_] := AssociationQ[res] &&
  KeyExistsQ[res, "Superleading"] &&
  Expand[Lookup[res, "Superleading", 0]] =!= 0;

(* Regge / exact-reduction limit: F = Obstruction with F_SL = 0 in the generator ideal. *)
hrfExactReductionObstructionResultQ[res_, generators_, vars_, kinVars_] := Module[{sl, obst},
  If[! (AssociationQ[res] && KeyExistsQ[res, "Superleading"]), Return[False]];
  sl = Expand[Lookup[res, "Superleading", $Failed]];
  If[sl =!= 0, Return[False]];
  obst = Expand[Lookup[res, "Obstruction", 0]];
  If[obst === 0, Return[False]];
  If[KeyExistsQ[res, "InIdealQ"],
    TrueQ[res["InIdealQ"]],
    True
  ]
];

hrfValidObstructionResultQ[res_, generators_, vars_, kinVars_] := Module[{allVars},
  If[hrfExactReductionObstructionResultQ[res, generators, vars, kinVars], Return[True]];
  If[! hrfNonzeroObstructionResultQ[res], Return[False]];
  allVars = DeleteDuplicates @ Join[vars, kinVars];
  If[KeyExistsQ[res, "InIdealQ"],
    TrueQ[res["InIdealQ"]],
    hrfObstructionSuperleadingInIdealQ[res["Superleading"], generators, allVars]
  ]
];

obstructionByOriginalTermsGeneralDiagnostic[F_, generators_, vars_, kinVars_, maxSize_ : Automatic,
   kinAssumptions_: True] :=
 Module[{attempts, eta, k1, k2, best, accepted},
  attempts = {obstructionByOriginalTermsGeneralDiagnosticCore[F, generators, vars, kinVars, maxSize,
      "OriginalChannelBasis", {}, kinAssumptions]};
  If[Length[kinVars] == 2,
   {k1, k2} = kinVars;

   (* Test the two crossed two-channel bases associated with the three
      four-point channels.  The auxiliary eta represents k1+k2 = -s13
      up to the chosen sign convention.  This keeps the obstruction
      decomposition from depending on which Mandelstam variable was
      eliminated by momentum conservation. *)
   eta = Unique["hrfChannelSum$"];
   AppendTo[attempts,
    obstructionByOriginalTermsGeneralDiagnosticCore[
     Expand[F /. k2 -> eta - k1], generators, vars, {k1, eta}, maxSize,
     ToString[{k1, k1 + k2}, InputForm], {eta -> k1 + k2}, kinAssumptions]
    ];

   eta = Unique["hrfChannelSum$"];
   AppendTo[attempts,
    obstructionByOriginalTermsGeneralDiagnosticCore[
     Expand[F /. k1 -> eta - k2], generators, vars, {k2, eta}, maxSize,
     ToString[{k2, k1 + k2}, InputForm], {eta -> k1 + k2}, kinAssumptions]
    ];
   ];
  accepted = Select[attempts,
    Module[{res = Lookup[#, "Result", Missing[]], gens},
      If[! AssociationQ[res], False,
        gens = Lookup[res, "Generators", generators];
        hrfValidObstructionResultQ[res, gens, vars, kinVars]
      ]
    ] &
  ];
  best = If[accepted =!= {}, First[accepted], First[attempts]];
  If[Length[attempts] > 1,
   best = Join[best, <|"ChannelObstructionAttempts" -> (Lookup[#, "AttemptData", <||>] & /@ attempts)|>]
   ];
  best
  ];

pairSectorGenerators[factors_] := Times @@@ Subsets[factors, {2}];

(* Exponent[constant, vars] and Exponent[{}, vars] can return {} or stay unevaluated;
   always return a length-|vars| exponent list for Pick / dot products. *)
If[! ValueQ[hrfExponentListInVars],
  hrfExponentListInVars[p_, vars_List] := Module[{ep, ex},
    Which[
      vars === {}, {},
      True,
        ep = Quiet @ Check[Expand[p], p];
        ex = Quiet @ Check[Exponent[ep, vars], $Failed];
        Which[
          ListQ[ex] && Length[ex] === Length[vars], ex,
          True, ConstantArray[0, Length[vars]]
        ]
    ]
  ]
];

hrfVarsWithPositiveExponent[term_, vars_List] :=
  Pick[vars, hrfExponentListInVars[term, vars], _?(# > 0 &)];

hrfPolynomialTotalDegreeInVars[p_, vars_] := Module[{ml, degs},
  ml = MonomialList[Expand[p], vars];
  If[ml === {}, Return[0]];
  degs = Total[hrfExponentListInVars[#, vars]] & /@ ml;
  Max[degs]
];

(* Max exponent of any single x_i in the polynomial. *)
hrfPolynomialMaxVarExponentInVars[p_, vars_] := Module[{ml, ex},
  ml = MonomialList[Expand[p], vars];
  If[ml === {}, Return[0]];
  ex = hrfExponentListInVars[#, vars] & /@ ml;
  Max[Max /@ ex]
];

(* For Symanzik F: total degree equals loop order + 1.  Generators must not exceed
   this total degree.  Per-variable exponent cap is 1 (massless) or 2 (massive). *)
hrfInferGeneratorDegreeBoundsFromF[F_, vars_] := Module[{fDeg, fMaxVar},
  fDeg = hrfPolynomialTotalDegreeInVars[F, vars];
  fMaxVar = hrfPolynomialMaxVarExponentInVars[F, vars];
  <|
    "MaxGeneratorTotalDegree" -> fDeg,
    "MaxGeneratorVarExponent" -> If[fMaxVar <= 1, 1, 2],
    "FTotalDegree" -> fDeg,
    "LoopOrder" -> Max[0, fDeg - 1],
    "FMaxVarExponent" -> fMaxVar,
    "InferredKinematicType" -> If[fMaxVar <= 1, "Massless", "Massive"]
  |>
];

hrfResolveGeneratorDegreeBounds[F_, vars_, opts_Association] := Module[{inf},
  inf = hrfInferGeneratorDegreeBoundsFromF[F, vars];
  <|
    "MaxGeneratorTotalDegree" -> Replace[
      Lookup[opts, "MaxGeneratorTotalDegree", Automatic],
      Automatic :> inf["MaxGeneratorTotalDegree"]
    ],
    "MaxGeneratorVarExponent" -> Replace[
      Lookup[opts, "MaxGeneratorVarExponent", Automatic],
      Automatic :> inf["MaxGeneratorVarExponent"]
    ],
    "FTotalDegree" -> inf["FTotalDegree"],
    "LoopOrder" -> inf["LoopOrder"],
    "FMaxVarExponent" -> inf["FMaxVarExponent"],
    "InferredKinematicType" -> inf["InferredKinematicType"],
    "RelaxSingleProductDegreeQ" -> TrueQ[Lookup[opts, "RelaxSingleProductDegreeQ", False]],
    "SkipPDFFindInstanceQ" -> TrueQ[Lookup[opts, "SkipPDFFindInstanceQ", False]]
  |>
];

hrfSkipPDFFindInstanceQ[bounds_Association] := TrueQ[Lookup[bounds, "SkipPDFFindInstanceQ", False]];
hrfCollinearSingleProductLegacyQ[bounds_Association] := TrueQ[Lookup[bounds, "RelaxSingleProductDegreeQ", False]];

hrfCancellationFactorDegreeAdmissibleQ[fac_, bounds_Association, vars_] := Module[
  {tot, maxVar, maxTot, maxVE},
  tot = hrfPolynomialTotalDegreeInVars[fac, vars];
  maxVar = hrfPolynomialMaxVarExponentInVars[fac, vars];
  maxTot = Lookup[bounds, "MaxGeneratorTotalDegree", Infinity];
  maxVE = Lookup[bounds, "MaxGeneratorVarExponent", Infinity];
  tot <= maxTot && maxVar <= maxVE
];

(* Generator products must satisfy total degree <= deg(F).  For massless F0,
   every monomial of the expanded generator must have each x_i exponent in {0,1}. *)
hrfGeneratorMasslessMonomialAdmissibleQ[gen_, bounds_Association, vars_] := Module[
  {maxVE, ml, maxPerMono},
  maxVE = Lookup[bounds, "MaxGeneratorVarExponent", Infinity];
  If[Lookup[bounds, "InferredKinematicType", "Massless"] =!= "Massless", Return[True]];
  ml = MonomialList[Expand[gen], vars];
  If[ml === {}, Return[True]];
  maxPerMono = Max /@ (hrfExponentListInVars[#, vars] & /@ ml);
  Max[maxPerMono] <= maxVE
];

hrfGeneratorProductDegreeAdmissibleQ[gen_, bounds_Association, vars_] := Module[
  {tot, maxTot},
  tot = hrfPolynomialTotalDegreeInVars[gen, vars];
  maxTot = Lookup[bounds, "MaxGeneratorTotalDegree", Infinity];
  tot <= maxTot
];

hrfGeneratorDegreeAdmissibleQ[gen_, bounds_Association, vars_, F0_: None, kinVars_: {}] :=
  hrfGeneratorProductDegreeAdmissibleQ[gen, bounds, vars] &&
    hrfGeneratorMasslessMonomialAdmissibleQ[gen, bounds, vars] &&
    hrfGeneratorF0SupportAdmissibleQ[gen, F0, vars, kinVars, Automatic];

hrfGeneratorSetDegreeAdmissibleQ[generators_List, bounds_Association, vars_, F0_: None, kinVars_: {}] :=
  And @@ (hrfGeneratorDegreeAdmissibleQ[#, bounds, vars, F0, kinVars] & /@ generators) &&
    hrfGeneratorSetMonomialsInF0Q[generators, F0, vars, kinVars];

hrfFilterFactorsForGenerators[factors_, vars_, F_, opts_: <||>] := Module[
  {allFF, bounds, ff, kinVars = Lookup[opts, "KinVars", {}]},
  allFF = DeleteDuplicates @ If[
    kinVars =!= {} && ValueQ[hrfCanonicalCancellationFactor],
    (hrfCanonicalCancellationFactor[#, vars, kinVars] & /@ factors),
    (Factor /@ factors)
  ];
  bounds = hrfResolveGeneratorDegreeBounds[F, vars, opts];
  ff = Select[allFF, hrfCancellationFactorDegreeAdmissibleQ[#, bounds, vars] &];
  <|
    "Bounds" -> bounds,
    "Factors" -> ff,
    "RejectedFactors" -> Complement[allFF, ff],
    "RejectedFactorCount" -> Length[allFF] - Length[ff]
  |>
];

hrfFactorDividesGeneratorQ[gen_, f_, allVars_, vars_: {}, kinVars_: {}] := Module[{fac = f},
  If[kinVars =!= {} && ValueQ[hrfCanonicalCancellationFactor],
    fac = hrfCanonicalCancellationFactor[f, vars, kinVars]
  ];
  TrueQ[Quiet[PolynomialReduce[Expand[gen], {fac}, allVars][[2]]] === 0]
];

factorsDividingGenerator[gen_, ff_, allVars_, vars_: {}, kinVars_: {}] :=
  Select[ff, hrfFactorDividesGeneratorQ[gen, #, allVars, vars, kinVars] &];

(* Prefer an explicit product of cancellation factors f_k when reporting generators. *)
hrfFactorizeGeneratorForOutput[gen_, cancellationFactors_: {}, vars_: {}, kinVars_: {}] := Module[
  {allVars, ff, fac, expanded = Expand[gen], minimal, legacy},
  If[cancellationFactors =!= {} && vars =!= {},
    allVars = DeleteDuplicates@Join[vars, kinVars];
    ff = DeleteDuplicates @ If[kinVars =!= {} && ValueQ[hrfCanonicalCancellationFactor],
      (hrfCanonicalCancellationFactor[#, vars, kinVars] & /@ cancellationFactors),
      (Factor /@ cancellationFactors)
    ];
    fac = factorsDividingGenerator[gen, ff, allVars, vars, kinVars];
    minimal = Select[
      Subsets[fac, {2, Min[Length[fac], 4]}],
      TrueQ[Expand[Times @@ #] === expanded] &
    ];
    If[minimal =!= {},
      Return[Times @@ (Factor /@ First @ MinimalBy[minimal, Length])]
    ];
    legacy = Select[fac, binomialQ[#, vars] &];
    minimal = Select[
      Subsets[legacy, {2, Min[Length[legacy], 3]}],
      TrueQ[Expand[Times @@ #] === expanded] &
    ];
    If[minimal =!= {},
      Return[Times @@ (Factor /@ First @ MinimalBy[minimal, Length])]
    ];
    If[Length[fac] >= 2, Return[Times @@ (Factor /@ Take[fac, 2])]]
  ];
  Factor[expanded]
];

hrfFormatGeneratorsForOutput[generators_List, cancellationFactors_: {}, vars_: {}, kinVars_: {}] :=
  hrfFactorizeGeneratorForOutput[#, cancellationFactors, vars, kinVars] & /@ generators;

(* Stub until HRF_PolynomialCancellationFactors.wl loads the real F0-support checks. *)
If[! ValueQ[hrfGeneratorF0SupportAdmissibleQ],
  hrfGeneratorF0SupportAdmissibleQ[___] := True
];
If[! ValueQ[hrfGeneratorSetMonomialsInF0Q],
  hrfGeneratorSetMonomialsInF0Q[___] := True
];
If[! ValueQ[hrfGeneratorMonomialsInF0Q],
  hrfGeneratorMonomialsInF0Q[___] := True
];

(* Massless admissibility rule.  In a multilinear/massless F polynomial a
   generator made from a single cancellation factor f_k cannot satisfy the
   positive-Landau stationary condition.  Therefore every ideal generator used
   by the obstruction finder must contain at least two f_k factors.  The massive
   quadratic-threshold extension should relax this rule only for genuine
   repeated quadratic factors, e.g. f_k^2 from a mass term.

   PDF (5.12) adds simultaneous-admissibility requirements at two stages:
   1. per generator: the f_k entering each g_k must vanish together;
   2. per confirmed superleading sector: once F_SL is found, the union of f_k
      from all generators that actually enter F_SL must vanish together (e.g.
      four factors when two pair-sector generators both enter F_SL in Crown).
      This second check is NOT applied when merely listing candidate generators. *)
Quiet @ Check[
  If[! TrueQ[$HRFGeneratorPhysicsFilterLoadedQ],
    Quiet @ Get[FileNameJoin[{
      If[StringQ[$InputFileName] && $InputFileName =!= "", DirectoryName[$InputFileName], Directory[]],
      "HRF_GeneratorPhysicsFilter.wl"
    }]]
  ],
  Null
];
(* Legacy Ex03/share1 binomial pool: ordinary derivative factorization only. *)
hrfLegacyBinomialSafeFactors[F_, vars_, kinAssumptions_, kinVars_] := Module[
  {allFactors},
  allFactors = DeleteDuplicates @ Flatten @ Values[derivativeFactors[F, vars]];
  allFactors = Select[allFactors, binomialQ[#, vars] &];
  If[ValueQ[hrfNormalizeCancellationCandidates],
    hrfNormalizeCancellationCandidates[allFactors, vars, kinVars],
    allFactors
  ]
];

ClearAll[candidateGeneratorSets, candidateGeneratorSetsDiagnostic, candidateGeneratorSetsAdaptive,
  hrfResolveSingleProductGeneratorFactors];

(* Collinear SingleProduct (RelaxSingleProductDegreeQ): build g from the legacy
   binomial pool. Polynomial safe factors may be a larger pool for audits only. *)
hrfResolveSingleProductGeneratorFactors[ff_List, vars_, kinAssumptions_, kinVars_, F_: None,
   opts_: <||>] := Module[{legacyQ, canonicalFF, chosen, bin, bounds, skipPDFQ, legacyProduct,
   pickPair, admissiblePairs, matched},
  canonicalFF = If[ValueQ[hrfCanonicalCancellationFactor],
    DeleteDuplicates[hrfCanonicalCancellationFactor[#, vars, kinVars] & /@ ff],
    DeleteDuplicates[Factor /@ ff]
  ];
  pickPair[pairList_] := Module[{},
    If[pairList === {}, Return[{}]];
    legacyProduct = If[F =!= None && F =!= Automatic,
      Module[{leg = hrfLegacyBinomialSafeFactors[F, vars, kinAssumptions, kinVars]},
        If[Length[leg] >= 2, Expand[Times @@ leg], None]
      ],
      None
    ];
    matched = If[legacyProduct =!= None,
      Select[pairList, TrueQ[Expand[Times @@ #] === legacyProduct] &],
      {}
    ];
    If[matched =!= {}, First[matched],
      First @ MinimalBy[pairList, Total[hrfPolynomialMonomialCount[#, vars] & /@ #] &]
    ]
  ];
  If[Length[canonicalFF] < 2 && !(F =!= None && TrueQ[Lookup[opts, "RelaxSingleProductDegreeQ", False]]),
    Return[{}]
  ];
  legacyQ = TrueQ[Lookup[opts, "RelaxSingleProductDegreeQ", False]];
  If[legacyQ && F =!= None,
    bin = hrfLegacyBinomialSafeFactors[F, vars, kinAssumptions, kinVars];
    If[Length[bin] >= 2, Return[bin]];
    Return[{}]
  ];
  If[Length[canonicalFF] < 2, Return[{}]];
  bounds = If[F =!= None && F =!= Automatic,
    hrfResolveGeneratorDegreeBounds[F, vars, opts],
    Lookup[opts, "Bounds", <||>]
  ];
  skipPDFQ = TrueQ[Lookup[opts, "SkipPDFFindInstanceQ", False]];
  chosen = canonicalFF;
  If[! skipPDFQ && ! simultaneouslyAdmissibleSubsetQ[chosen, vars, kinAssumptions, kinVars],
    bin = Select[canonicalFF, binomialQ[#, vars] &];
    If[Length[bin] >= 2 && simultaneouslyAdmissibleSubsetQ[bin, vars, kinAssumptions, kinVars],
      chosen = bin,
      Module[{},
        admissiblePairs = Select[Subsets[canonicalFF, {2}],
          (Length[DownValues[hrfGeneratorPairKinPrefilterQ]] === 0 ||
              hrfGeneratorPairKinPrefilterQ[#[[1]], #[[2]], kinVars]) &&
            simultaneouslyAdmissibleSubsetQ[#, vars, kinAssumptions, kinVars] &&
            (F === None || F === Automatic || AssociationQ[bounds] === False ||
              hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ #], bounds, vars, F, kinVars]) &
        ];
        chosen = pickPair[admissiblePairs];
        If[chosen === {}, Return[{}]]
      ]
    ]
  ];
  If[Length[chosen] > 2,
    admissiblePairs = Select[Subsets[chosen, {2}],
      (Length[DownValues[hrfGeneratorPairKinPrefilterQ]] === 0 ||
          hrfGeneratorPairKinPrefilterQ[#[[1]], #[[2]], kinVars]) &&
        (skipPDFQ || simultaneouslyAdmissibleSubsetQ[#, vars, kinAssumptions, kinVars]) &&
        (F === None || F === Automatic || ! AssociationQ[bounds] ||
          hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ #], bounds, vars, F, kinVars]) &
    ];
    If[admissiblePairs =!= {}, chosen = pickPair[admissiblePairs]]
  ];
  If[Length[chosen] === 2,
    If[! ((Length[DownValues[hrfGeneratorPairKinPrefilterQ]] === 0 ||
            hrfGeneratorPairKinPrefilterQ[chosen[[1]], chosen[[2]], kinVars]) &&
          (skipPDFQ || simultaneouslyAdmissibleSubsetQ[chosen, vars, kinAssumptions, kinVars]) &&
          (F === None || F === Automatic || ! AssociationQ[bounds] ||
            hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ chosen], bounds, vars, F, kinVars])),
      Return[{}]
    ]
  ];
  chosen
];

(* Default/collinear generator choice: one generator equal to product of all
   factors, but only when at least two f_k factors are present and the full
   subset is simultaneously admissible. *)
candidateGeneratorSets[factors_, vars_, kinAssumptions_, kinVars_, F_,
   opts_: <||>] := Module[{pack, ff, bounds, genFF, fullGen, relaxQ, genOpts},
  genOpts = Join[opts, <|"KinVars" -> kinVars|>];
  pack = hrfFilterFactorsForGenerators[factors, vars, F, genOpts];
  ff = pack["Factors"];
  bounds = pack["Bounds"];
  genFF = hrfResolveSingleProductGeneratorFactors[ff, vars, kinAssumptions, kinVars, F, genOpts];
  If[genFF === {}, Return[{}]];
  relaxQ = TrueQ[Lookup[opts, "RelaxSingleProductDegreeQ", False]] ||
    TrueQ[Lookup[bounds, "RelaxSingleProductDegreeQ", False]];
  skipPDFQ = TrueQ[Lookup[opts, "SkipPDFFindInstanceQ", False]] ||
    TrueQ[Lookup[bounds, "SkipPDFFindInstanceQ", False]] || relaxQ;
  fullGen = Expand[Times @@ genFF];
  If[(skipPDFQ || simultaneouslyAdmissibleSubsetQ[genFF, vars, kinAssumptions, kinVars]) &&
      (relaxQ || hrfGeneratorDegreeAdmissibleQ[fullGen, bounds, vars, F, kinVars]),
    {{fullGen}},
    {}
  ]
];

(* Diagnostic/crown-like generator sets: full product, all pair products, and
   collections of pair products up to maxGenerators.  Degree bounds (total and
   per-x_i) are enforced before simultaneous-admissibility tests. *)
candidateGeneratorSetsDiagnostic[factors_, maxGenerators_ : 2, vars_, kinAssumptions_, kinVars_, F_,
   opts_: <||>] := Module[
  {pack, ff, bounds, admissiblePairs, pairGens, fullGen, fullSet, pairSingles,
   pairSubsets, sets, limit},
  pack = hrfFilterFactorsForGenerators[factors, vars, F, opts];
  ff = pack["Factors"];
  bounds = pack["Bounds"];
  If[TrueQ[$HRFUseGeneratorPhysicsFilterQ],
    ff = hrfFilterFactorsForGeneratorPhysics[ff, vars, kinVars, bounds]["Factors"]
  ];
  If[Length[ff] < 2, Return[{}]];
  limit = Which[
    KeyExistsQ[opts, "CandidateGeneratorSetLimit"], opts["CandidateGeneratorSetLimit"],
    ValueQ[$HRFCandidateGeneratorSetLimit], $HRFCandidateGeneratorSetLimit,
    True, Infinity
  ];
  admissiblePairs = Select[Subsets[ff, {2}],
    simultaneouslyAdmissibleSubsetQ[#, vars, kinAssumptions, kinVars] &&
      If[TrueQ[$HRFUseGeneratorPhysicsFilterQ],
        hrfGeneratorPairPhysicsAdmissibleQ[#[[1]], #[[2]], bounds, vars, kinVars],
        True
      ] &&
      hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ #], bounds, vars, F, kinVars] &
  ];
  If[TrueQ[$HRFUseGeneratorPhysicsFilterQ] && ValueQ[hrfFilterAdmissiblePairsModuleDedup],
    admissiblePairs = hrfFilterAdmissiblePairsModuleDedup[
      admissiblePairs,
      Select[ff, ! hrfFactorContainsKinVarsQ[#, kinVars] &],
      vars,
      kinVars
    ]["Pairs"]
  ];
  pairGens = Times @@@ admissiblePairs;
  If[TrueQ[$HRFUseGeneratorPhysicsFilterQ] && ValueQ[hrfCanonicalizeGeneratorsModKinSectors],
    Module[{kinFreePairGens = Expand[Times @@@ Select[admissiblePairs,
        ! hrfFactorContainsKinVarsQ[#[[1]], kinVars] &&
          ! hrfFactorContainsKinVarsQ[#[[2]], kinVars] &]],
      quot = hrfCanonicalizeGeneratorsModKinSectors[pairGens, kinFreePairGens, vars, kinVars]},
      hrfDebugSay["candidateGeneratorSetsDiagnostic: sector quotient " <>
        ToString[Length[pairGens]] <> " -> " <> ToString[quot["CanonicalCount"]] <>
        " generators (" <> ToString[quot["RedundantCount"]] <> " redundant)"];
      pairGens = quot["Canonical"]
    ]
  ];
  fullGen = Times @@ ff;
  fullSet = If[simultaneouslyAdmissibleSubsetQ[ff, vars, kinAssumptions, kinVars] &&
      hrfGeneratorDegreeAdmissibleQ[fullGen, bounds, vars, F, kinVars],
    {{fullGen}}, {}];
  If[IntegerQ[limit] && limit > 0 && Length[pairGens] > Max[0, limit - Length[fullSet]],
    hrfDebugSay["candidateGeneratorSetsDiagnostic: capping pair products " <>
      ToString[Length[pairGens]] <> " -> " <> ToString[Max[0, limit - Length[fullSet]]]];
    pairGens = Take[pairGens, Max[0, limit - Length[fullSet]]]
  ];
  pairSingles = List /@ pairGens;
  (* Two-generator unions {g1,g2} are required for Crown (F_SL = s12 g1 + s23 g2).
     Build them from kin-free pair generators (x-sector sectors); cap trial count. *)
  pairSubsets = If[maxGenerators >= 2,
    Module[{kinFreeGens, base, subs, cap},
      kinFreeGens = Select[pairGens, ! hrfFactorContainsKinVarsQ[#, kinVars] &];
      base = If[kinFreeGens === {}, pairGens, kinFreeGens];
      subs = Select[Subsets[base, {2, maxGenerators}],
        hrfGeneratorSetDegreeAdmissibleQ[#, bounds, vars, F, kinVars] &];
      cap = If[ValueQ[$HRFMaxTwoGeneratorUnionTrials], $HRFMaxTwoGeneratorUnionTrials, 48];
      If[IntegerQ[cap] && cap > 0 && Length[subs] > cap, Take[subs, cap], subs]
    ],
    {}
  ];
  sets = DeleteDuplicates @ Join[fullSet, pairSubsets, pairSingles];
  If[IntegerQ[limit] && limit > 0 && Length[sets] > limit,
    Module[{multi = Select[sets, Length[#] > 1 &], single = Select[sets, Length[#] === 1 &]},
      Take[Join[multi, single], limit]
    ],
    sets
  ]
];

(* Adaptive generator candidates: try single coupled generators (products of
   admissible factor subsets) and multi-generator pair-sector sets.  The
   obstruction search picks what works; no a priori SingleProduct vs PairSectors. *)
candidateGeneratorSetsAdaptive[factors_, vars_, kinAssumptions_, kinVars_, F_,
   opts_: <||>] := Module[
  {pack, ff, bounds, limit, maxGens, maxSubset, singleSets, multiSets, allSets,
   fullGen, fullSingle},
  pack = hrfFilterFactorsForGenerators[factors, vars, F, opts];
  ff = pack["Factors"];
  bounds = pack["Bounds"];
  If[TrueQ[$HRFUseGeneratorPhysicsFilterQ],
    ff = hrfFilterFactorsForGeneratorPhysics[ff, vars, kinVars, bounds]["Factors"]
  ];
  If[Length[ff] < 2, Return[{}]];
  limit = Which[
    KeyExistsQ[opts, "CandidateGeneratorSetLimit"], opts["CandidateGeneratorSetLimit"],
    ValueQ[$HRFCandidateGeneratorSetLimit], $HRFCandidateGeneratorSetLimit,
    True, Infinity
  ];
  maxGens = Which[
    KeyExistsQ[opts, "MaxGenerators"], opts["MaxGenerators"],
    True, 2
  ];
  maxSubset = Which[
    KeyExistsQ[opts, "MaxProductSubsetSize"], opts["MaxProductSubsetSize"],
    ValueQ[$HRFMaxProductSubsetSize], $HRFMaxProductSubsetSize,
    True, 3
  ];
  fullGen = Expand[Times @@ ff];
  fullSingle = If[simultaneouslyAdmissibleSubsetQ[ff, vars, kinAssumptions, kinVars] &&
      hrfGeneratorDegreeAdmissibleQ[fullGen, bounds, vars, F, kinVars],
    {{fullGen}},
    {}
  ];
  singleSets = Join @@ Table[
    Module[{subs = Select[Subsets[ff, {k}],
      (k < 2 || Length[DownValues[hrfGeneratorPairKinPrefilterQ]] === 0 ||
          hrfGeneratorPairKinPrefilterQ[#[[1]], #[[2]], kinVars]) &&
        simultaneouslyAdmissibleSubsetQ[#, vars, kinAssumptions, kinVars] &&
        hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ #], bounds, vars, F, kinVars] &
    ]},
      {Expand[Times @@ #]} & /@ subs
    ],
    {k, 2, Min[maxSubset, Length[ff]]}
  ];
  multiSets = If[maxGens >= 2,
    Select[
      candidateGeneratorSetsDiagnostic[factors, maxGens, vars, kinAssumptions, kinVars, F, opts],
      Length[#] > 1 &
    ],
    {}
  ];
  allSets = DeleteDuplicates @ Join[multiSets, fullSingle];
  If[!(IntegerQ[limit] && limit > 0 && Length[allSets] >= limit),
    allSets = DeleteDuplicates @ Join[allSets, singleSets]
  ];
  hrfDebugSay["candidateGeneratorSetsAdaptive: single=" <> ToString[Length[singleSets]] <>
    " multi=" <> ToString[Length[multiSets]] <> " total=" <> ToString[Length[allSets]] <>
    " (trial order: multi-sector sets before coupled singles)"];
  If[IntegerQ[limit] && limit > 0 && Length[allSets] > limit,
    Take[allSets, limit],
    allSets
  ]
];


(* Recover, for reporting, which cancellation factors divide each constructed
   generator and whether that factor subset satisfies the per-generator rules. *)
generatorFactorData[generators_, factors_, vars_, kinVars_, kinAssumptions_: True, bounds_: Automatic, F0_: None] := Module[{allVars, ff},
  allVars = DeleteDuplicates@Join[vars, kinVars];
  ff = DeleteDuplicates @ If[ValueQ[hrfCanonicalCancellationFactor],
    (hrfCanonicalCancellationFactor[#, vars, kinVars] & /@ factors),
    (Factor /@ factors)
  ];
  Table[
    Module[{fac = factorsDividingGenerator[gen, ff, allVars, vars, kinVars], simQ, degQ, f0Q, relaxQ, skipPDFQ},
      simQ = simultaneouslyAdmissibleSubsetQ[fac, vars, kinAssumptions, kinVars];
      degQ = If[AssociationQ[bounds],
        hrfGeneratorDegreeAdmissibleQ[gen, bounds, vars, F0, kinVars],
        True
      ];
      f0Q = hrfGeneratorF0SupportAdmissibleQ[gen, F0, vars, kinVars, Automatic];
      relaxQ = AssociationQ[bounds] && TrueQ[Lookup[bounds, "RelaxSingleProductDegreeQ", False]];
      skipPDFQ = (AssociationQ[bounds] && TrueQ[Lookup[bounds, "SkipPDFFindInstanceQ", False]]) || relaxQ;
      <|
        "Generator" -> hrfFactorizeGeneratorForOutput[gen, factors, vars, kinVars],
        "TotalDegree" -> hrfPolynomialTotalDegreeInVars[gen, vars],
        "MaxVarExponent" -> hrfPolynomialMaxVarExponentInVars[gen, vars],
        "MasslessMonomialAdmissibleQ" -> hrfGeneratorMasslessMonomialAdmissibleQ[gen, bounds, vars],
        "DegreeAdmissibleQ" -> degQ,
        "GeneratorMonomialsInF0Q" -> f0Q,
        "FactorDegreeAdmissibleQ" -> If[AssociationQ[bounds],
          hrfCancellationFactorDegreeAdmissibleQ[gen, bounds, vars],
          True
        ],
        "GeneratorFactors" -> Factor /@ fac,
        "GeneratorFactorCount" -> Length[fac],
        "IndividuallyPositiveCompatibleQ" -> If[skipPDFQ, True,
          And @@ (positiveCompatibleQ[#, vars, kinAssumptions, kinVars] & /@ fac)],
        "SimultaneouslyAdmissibleSubsetQ" -> If[skipPDFQ, True, simQ],
        "AdmissibleGeneratorQ" -> (Length[fac] >= 2 && (skipPDFQ || simQ) && (relaxQ || degQ) && f0Q),
        "AdmissibilityRule" -> If[skipPDFQ,
          "Collinear SingleProduct legacy: >=2 f_k, F0 support; no FindInstance PDF",
          "Massless: >=2 f_k, degree bounds, F0 monomial support (kin sector), PDF (5.12) per-generator simultaneous admissibility"]
      |>
    ],
    {gen, generators}
  ]
];

generatorSetFactorUnion[generators_, factors_, vars_, kinVars_] := Module[
  {allVars = DeleteDuplicates@Join[vars, kinVars],
   ff = DeleteDuplicates @ If[ValueQ[hrfCanonicalCancellationFactor],
     (hrfCanonicalCancellationFactor[#, vars, kinVars] & /@ factors),
     (Factor /@ factors)
   ]},
  DeleteDuplicates @ Flatten[
    factorsDividingGenerator[#, ff, allVars, vars, kinVars] & /@ generators
  ]
];

generatorSetAdmissibilityData[generators_, factors_, vars_, kinVars_, kinAssumptions_: True, bounds_: Automatic, F0_: None] := Module[
  {gd, unionFac, perGenQ, setQ, setF0Q, skipPDFQ},
  gd = generatorFactorData[generators, factors, vars, kinVars, kinAssumptions, bounds, F0];
  unionFac = generatorSetFactorUnion[generators, factors, vars, kinVars];
  perGenQ = gd =!= {} && AllTrue[gd, TrueQ[Lookup[#, "AdmissibleGeneratorQ", False]] &];
  setF0Q = hrfGeneratorSetMonomialsInF0Q[generators, F0, vars, kinVars];
  skipPDFQ = hrfSkipPDFFindInstanceQ[bounds] || hrfCollinearSingleProductLegacyQ[bounds];
  setQ = skipPDFQ || simultaneouslyAdmissibleSubsetQ[unionFac, vars, kinAssumptions, kinVars];
  <|
    "GeneratorFactorData" -> gd,
    "GeneratorSetFactorUnion" -> Factor /@ unionFac,
    "GeneratorSetFactorCount" -> Length[unionFac],
    "GeneratorSetMonomialsInF0Q" -> setF0Q,
    "PerGeneratorAdmissibleQ" -> perGenQ && setF0Q,
    "SimultaneouslyAdmissibleGeneratorSetQ" -> setQ,
    "AdmissibleGeneratorSetQ" -> perGenQ && setF0Q,
    "GeneratorSetAdmissibilityRule" -> If[skipPDFQ,
      "Collinear SingleProduct legacy: no FindInstance PDF at candidate stage",
      "Candidate stage: degree bounds, F0 monomial support, each generator has >=2 f_k and PDF (5.12) individually"]
  |>
];

(* PDF (5.12) at SL-sector confirmation: only the generators that actually
   enter the confirmed F_SL are required to have jointly admissible f_k. *)
slSectorAdmissibilityData[FSL_, generators_, factors_, vars_, kinVars_, kinAssumptions_: True,
   bounds_: Automatic, F0_: None] := Module[
  {use, usedGens, usedData, unionFac, perGenQ, setQ, idealQ, allVars = DeleteDuplicates@Join[vars, kinVars],
   skipPDFQ},
  skipPDFQ = hrfSkipPDFFindInstanceQ[bounds] || hrfCollinearSingleProductLegacyQ[bounds];
  use = generatorUseData[FSL, generators, vars, kinVars];
  If[TrueQ[Expand[FSL] === 0],
    usedGens = generators;
    usedData = generatorFactorData[usedGens, factors, vars, kinVars, kinAssumptions, bounds, F0];
    unionFac = generatorSetFactorUnion[usedGens, factors, vars, kinVars];
    perGenQ = usedData =!= {} && AllTrue[usedData, TrueQ[Lookup[#, "AdmissibleGeneratorQ", False]] &];
    setQ = skipPDFQ || (Length[usedGens] >= 1 && simultaneouslyAdmissibleSubsetQ[unionFac, vars, kinAssumptions, kinVars]);
    idealQ = True;
    Return[<|
      "GeneratorUseData" -> use,
      "SLSectorGenerators" -> Factor /@ usedGens,
      "SLSectorGeneratorCount" -> Length[usedGens],
      "SLSectorGeneratorFactorData" -> usedData,
      "SLSectorFactorUnion" -> Factor /@ unionFac,
      "SLSectorFactorCount" -> Length[unionFac],
      "PerGeneratorSLSectorAdmissibleQ" -> perGenQ,
      "SimultaneouslyAdmissibleSLSectorQ" -> setQ,
      "SuperleadingInIdealQ" -> idealQ,
      "AdmissibleSLSectorQ" -> (perGenQ && setQ && idealQ),
      "SLSectorAdmissibilityRule" -> "Exact reduction (F_SL=0): PDF (5.12) on full generator set"
    |>]
  ];
  usedGens = Lookup[use, "UsedGenerators", {}];
  usedData = generatorFactorData[usedGens, factors, vars, kinVars, kinAssumptions, bounds, F0];
  unionFac = generatorSetFactorUnion[usedGens, factors, vars, kinVars];
  perGenQ = usedData =!= {} && AllTrue[usedData, TrueQ[Lookup[#, "AdmissibleGeneratorQ", False]] &];
  setQ = skipPDFQ || (Length[usedGens] >= 1 && simultaneouslyAdmissibleSubsetQ[unionFac, vars, kinAssumptions, kinVars]);
  idealQ = hrfObstructionSuperleadingInIdealQ[FSL, generators, allVars];
  <|
    "GeneratorUseData" -> use,
    "SLSectorGenerators" -> Factor /@ usedGens,
    "SLSectorGeneratorCount" -> Length[usedGens],
    "SLSectorGeneratorFactorData" -> usedData,
    "SLSectorFactorUnion" -> Factor /@ unionFac,
    "SLSectorFactorCount" -> Length[unionFac],
    "PerGeneratorSLSectorAdmissibleQ" -> perGenQ,
    "SimultaneouslyAdmissibleSLSectorQ" -> setQ,
    "SuperleadingInIdealQ" -> idealQ,
    "AdmissibleSLSectorQ" -> (perGenQ && setQ && idealQ),
    "SLSectorAdmissibilityRule" -> "PDF (5.12) on generators entering F_SL and exact F_SL in generator ideal"
  |>
];

admissibleGeneratorSetQ[generators_, factors_, vars_, kinVars_, kinAssumptions_: True, FSL_: None] := Which[
  FSL === None,
    TrueQ @ Lookup[
      generatorSetAdmissibilityData[generators, factors, vars, kinVars, kinAssumptions],
      "PerGeneratorAdmissibleQ",
      False
    ],
  True,
    TrueQ @ Lookup[
      slSectorAdmissibilityData[FSL, generators, factors, vars, kinVars, kinAssumptions],
      "AdmissibleSLSectorQ",
      False
    ]
  ];

(* Determine which generators are actually used in a given superleading polynomial. *)
generatorUseData[FSL_, generators_, vars_, kinVars_] :=
 Module[{allVars, quotients, remainder, used},
  allVars = DeleteDuplicates@Join[vars, kinVars];
  {quotients, remainder} = PolynomialReduce[Expand[FSL], generators, allVars];
  used = Pick[generators,
    Unitize[Table[If[Expand[quotients[[i]]] === 0, 0, 1], {i, Length[quotients]}]],
    1];
  <|
   "Quotients" -> quotients,
   "Remainder" -> Factor[remainder],
   "UsedGenerators" -> Factor /@ used
   |>
  ];

generatorSetScore[res_] := Module[{obs},
  If[! AssociationQ[res], Return[Infinity]];
  obs = res["Obstruction"];
  If[Head[obs] === Missing, Infinity, Length[List @@ Expand[obs]]]
  ];

(* Regge / single-channel kinematics: one Mandelstam invariant survives, so the
   physical generator is typically a single kin-independent product g(x). *)
hrfResolvePreferFewerGeneratorsQ[kinVars_, preferFewerOpt_] := Which[
  preferFewerOpt === Automatic, Length[kinVars] <= 1,
  TrueQ[preferFewerOpt], True,
  True, False
];

(* Rank admissible trials.  Wide-angle: prefer more generators (Crown F_SL = s12 g1 + s23 g2).
   Regge / single kin var: prefer exact reduction, then fewer generators, then smaller obstruction. *)
hrfObstructionTrialRank[trial_, preferFewerQ_: False] := Module[{gens, od, sl, exactBonus, obsScore},
  gens = Lookup[trial, "Generators", {}];
  od = Lookup[trial, "ObstructionData", Missing[]];
  sl = If[AssociationQ[od], Lookup[od, "Superleading", $Failed], $Failed];
  exactBonus = If[AssociationQ[od] && sl =!= $Failed && TrueQ[Expand[sl] === 0], 0, 1];
  obsScore = If[AssociationQ[od], generatorSetScore[od], Infinity];
  If[preferFewerQ,
    {exactBonus, Length[gens], obsScore},
    {exactBonus, -Length[gens], obsScore}
  ]
];

(* Wide-angle 4pt: prefer kin-free x-sector generators (Crown / HyperCrown sector form). *)
hrfWideAngleTrialSelectionRank[trial_, kinVars_, preferFewerQ_: False] := Module[{gens},
  gens = Lookup[trial, "Generators", {}];
  Join[
    {If[gens =!= {} && And @@ (FreeQ[Expand[#], s12 | s23] & /@ gens), 0, 1]},
    hrfObstructionTrialRank[trial, preferFewerQ]
  ]
];

(* Wide-angle 4pt: F_SL must be s_a * g_a with kin-free sector generators g_a.
   Rejects spurious decompositions such as {s23, s12*x10} that pass ideal membership
   but are not the physical two-channel sector presentation. *)
If[! ValueQ[$HRFRequireWideAngleKinSectorPresentationQ],
  $HRFRequireWideAngleKinSectorPresentationQ = True
];

hrfWideAngleSLQuotientQ[q_, kinVars_List] := Module[{e = Expand[q]},
  Or @@ Flatten @ Table[e === k || e === -k, {k, kinVars}]
];

hrfWideAngleKinSectorPresentationQ[trial_Association, vars_, kinVars_List] := Module[
  {gens, od, fsl, allVars, quot, rem, active, qActive, kinUsed},
  If[Length[kinVars] =!= 2, Return[True]];
  If[! TrueQ[$HRFRequireWideAngleKinSectorPresentationQ], Return[True]];
  gens = Lookup[trial, "Generators", {}];
  If[gens === {}, Return[False]];
  If[! And @@ (FreeQ[Expand[#], Alternatives @@ kinVars] & /@ gens), Return[False]];
  od = Lookup[trial, "ObstructionData", Missing[]];
  If[! AssociationQ[od], Return[False]];
  fsl = Lookup[od, "Superleading", Lookup[od, "Complement", Missing[]]];
  If[MatchQ[fsl, _Missing], Return[False]];
  If[TrueQ[Expand[fsl] === 0], Return[True]];
  allVars = DeleteDuplicates @ Join[vars, kinVars];
  {quot, rem} = PolynomialReduce[Expand[fsl], gens, allVars];
  If[! TrueQ[Expand[rem] === 0], Return[False]];
  quot = If[ListQ[quot], quot, {quot}];
  If[Length[quot] =!= Length[gens], Return[False]];
  active = Pick[gens,
    Unitize @ Table[If[TrueQ[Expand[quot[[i]]] === 0], 0, 1], {i, Length[gens]}],
    1];
  qActive = Pick[quot,
    Unitize @ Table[If[TrueQ[Expand[quot[[i]]] === 0], 0, 1], {i, Length[gens]}],
    1];
  If[Length[active] < 2, Return[False]];
  If[! And @@ (hrfWideAngleSLQuotientQ[#, kinVars] & /@ qActive), Return[False]];
  kinUsed = DeleteDuplicates @ Flatten @ Table[
    Select[kinVars, ! FreeQ[Expand[qActive[[i]]], #] &],
    {i, Length[qActive]}
  ];
  Sort[kinUsed] === Sort[kinVars]
];

hrfValidObstructionTrialQ[trial_, vars_, kinVars_] := Module[{od, gens},
  od = Lookup[trial, "ObstructionData", Missing[]];
  gens = Lookup[trial, "Generators", {}];
  TrueQ[Lookup[trial, "AdmissibleSLSectorQ", False]] &&
    AssociationQ[od] && hrfValidObstructionResultQ[od, gens, vars, kinVars]
];

(* Stricter wide-angle check: F_SL = +/- s_a g_a with kin-free sector generators. *)
hrfWideAngleKinSectorPresentationTrialQ[trial_, vars_, kinVars_] :=
  hrfValidObstructionTrialQ[trial, vars, kinVars] &&
    hrfWideAngleKinSectorPresentationQ[trial, vars, kinVars];

ClearAll[hrfTrialObstructionForScaling, hrfTrialEffectiveSuperleading, hrfMiniScanFromTrial,
  hrfTrialCoverageScalingData, hrfTrialCoverageFoundQ, hrfEvaluateValidTrialScaling,
  hrfHiddenRegionScanFromTrial, hrfResolveRequireValidScalingForHiddenRegionQ,
  hrfResolveEnumerateHiddenRegionsQ, hrfCompactGeneratorsForSummary,
  hrfBuildGeneratorSetScalingSummary];

hrfTrialObstructionForScaling[trial_] := Module[{od, obst},
  od = Lookup[trial, "ObstructionData", Missing[]];
  If[! AssociationQ[od], Return[None]];
  obst = Lookup[od, "Obstruction", None];
  If[MatchQ[obst, None | Missing] || TrueQ[Expand[obst] === 0], None, obst]
];

hrfTrialEffectiveSuperleading[trial_] := Module[{od, sl},
  od = Lookup[trial, "ObstructionData", Missing[]];
  If[! AssociationQ[od], Return[Missing["NoObstructionData"]]];
  sl = Lookup[od, "Superleading", Lookup[od, "Complement", Missing["NoSuperleading"]]];
  If[MatchQ[sl, _Missing], Missing["NoSuperleadingSector"], sl]
];

hrfMiniScanFromTrial[trial_] := <|
  "Generators" -> Lookup[trial, "Generators", {}],
  "GeneratorFactorData" -> Lookup[trial, "GeneratorFactorData", {}],
  "GeneratorSetFactorUnion" -> Lookup[trial, "GeneratorSetFactorUnion", {}],
  "GeneratorSetFactorCount" -> Lookup[trial, "GeneratorSetFactorCount", 0],
  "ObstructionData" -> Lookup[trial, "ObstructionData", Missing[]],
  "AdmissibleSLSectorQ" -> TrueQ[Lookup[trial, "AdmissibleSLSectorQ", False]],
  "AdmissibleGeneratorSetQ" -> TrueQ[Lookup[trial, "AdmissibleSLSectorQ", False]]
|>;

hrfTrialCoverageScalingData[trial_, U_, vars_, maxAbs_, fObs_:Automatic] := Module[{fsl, fObsVal},
  If[MatchQ[U, None | Automatic | Missing], Return[Missing["NoU"]]];
  fsl = hrfTrialEffectiveSuperleading[trial];
  If[MatchQ[fsl, _Missing] || TrueQ[Expand[fsl] === 0],
    Return[hrfExactReductionCoverageScalingData[]]
  ];
  fObsVal = Which[
    fObs === Automatic, hrfTrialObstructionForScaling[trial],
    TrueQ[fObs === None], None,
    True, fObs
  ];
  findCoverageLPScaling[fsl, Expand[U], vars, maxAbs, fObsVal]
];

hrfTrialCoverageFoundQ[cov_] := Module[{diag},
  If[ValueQ[hrfCoverageFoundQ] && Length[DownValues[hrfCoverageFoundQ]] > 0,
    Return[hrfCoverageFoundQ[cov]]
  ];
  If[! AssociationQ[cov], Return[False]];
  If[MatchQ[Lookup[cov, "Scaling", Missing[]], _Missing], Return[False]];
  If[! ListQ[cov["Scaling"]], Return[False]];
  If[KeyExistsQ[cov, "AcceptedCount"], Return[TrueQ[Lookup[cov, "AcceptedCount", 0] >= 1]]];
  diag = Which[
    AssociationQ[Lookup[cov, "SelectedCandidateDiagnostic", Missing[]]], cov["SelectedCandidateDiagnostic"],
    AssociationQ[Lookup[cov, "Diagnostics", Missing[]]], cov["Diagnostics"],
    True, <||>
  ];
  TrueQ[Lookup[diag, "HiddenDominatesPostCancellationLPQ", False]] &&
    TrueQ[Lookup[diag, "LeadingRegionCoverageQ", False]]
];

hrfEvaluateValidTrialScaling[trial_, U_, vars_, maxAbs_, fObs_:Automatic] := Module[{cov, sl, exactQ, foundQ},
  cov = hrfTrialCoverageScalingData[trial, U, vars, maxAbs, fObs];
  sl = hrfTrialEffectiveSuperleading[trial];
  exactQ = ! MatchQ[sl, _Missing] && TrueQ[Expand[sl] === 0];
  foundQ = Which[
    MatchQ[cov, _Missing], exactQ,
    True, hrfTrialCoverageFoundQ[cov] || exactQ
  ];
  <|
    "Trial" -> trial,
    "TrialIndex" -> Lookup[Lookup[trial, "ObstructionAttemptData", <||>], "Attempt", Missing["NotAvailable"]],
    "Generators" -> Lookup[trial, "Generators", {}],
    "ScalingData" -> cov,
    "CoverageScalingData" -> cov,
    "ValidScalingQ" -> foundQ,
    "HiddenRegionQ" -> foundQ,
    "ExactReductionQ" -> exactQ
  |>
];

hrfHiddenRegionScanFromTrial[trial_, covData_, baseMeta_Association, hiddenQ_:Automatic] := Join[
  baseMeta,
  hrfMiniScanFromTrial[trial],
  <|
    "PerGeneratorAdmissibleQ" -> Lookup[trial, "PerGeneratorAdmissibleQ", False],
    "SimultaneouslyAdmissibleGeneratorSetQ" -> Lookup[trial, "SimultaneouslyAdmissibleGeneratorSetQ", False],
    "SLSectorGenerators" -> Lookup[trial, "SLSectorGenerators", {}],
    "SLSectorFactorUnion" -> Lookup[trial, "SLSectorFactorUnion", {}],
    "SLSectorFactorCount" -> Lookup[trial, "SLSectorFactorCount", 0],
    "SimultaneouslyAdmissibleSLSectorQ" -> Lookup[trial, "SimultaneouslyAdmissibleSLSectorQ", False],
    "ObstructionAttemptData" -> Lookup[trial, "ObstructionAttemptData", trial],
    "CoverageScalingData" -> hrfScalingDataAssoc[covData],
    "HiddenRegionQ" -> If[hiddenQ === Automatic, hrfTrialCoverageFoundQ[covData], TrueQ[hiddenQ]],
    "GeneratorUseData" -> If[AssociationQ[Lookup[trial, "ObstructionData", Missing[]]] &&
        KeyExistsQ[trial["ObstructionData"], "Superleading"],
      generatorUseData[trial["ObstructionData", "Superleading"], trial["Generators"],
        Lookup[baseMeta, "ActiveVars", {}], Lookup[baseMeta, "KinVars", {}]],
      Missing["NoUseData"]
    ]
  |>
];

hrfResolveRequireValidScalingForHiddenRegionQ[explicitValue_, U_] := Which[
  explicitValue === Automatic,
    Which[
      ValueQ[$HRFFindObstructionsRequireValidScalingQ],
        If[$HRFFindObstructionsRequireValidScalingQ === Automatic,
          ! MatchQ[U, None | Automatic | Missing],
          TrueQ[$HRFFindObstructionsRequireValidScalingQ]
        ],
      True, ! MatchQ[U, None | Automatic | Missing]
    ],
  True, TrueQ[explicitValue]
];

hrfResolveEnumerateHiddenRegionsQ[explicitValue_, U_] := Which[
  explicitValue === Automatic, ! MatchQ[U, None | Automatic | Missing],
  True, TrueQ[explicitValue]
];

hrfCompactGeneratorsForSummary[gens_List, cancellationFactors_: {}, vars_: {}, kinVars_: {}] := Which[
  gens === {}, "--",
  ValueQ[hrfPolynomialCompact],
    hrfPolynomialCompact @ hrfFormatGeneratorsForOutput[gens, cancellationFactors, vars, kinVars],
  True, StringRiffle[ToString[InputForm[#]] & /@ hrfFormatGeneratorsForOutput[gens, cancellationFactors, vars, kinVars], ", "]
];

hrfBuildGeneratorSetScalingSummary[trials_List, scalingEvaluations_List, vars_, kinVars_,
   cancellationFactors_: {}] := Module[
  {evalByIdx, rowForTrial, baseMeta = <|
    "ActiveVars" -> vars,
    "KinVars" -> kinVars,
    "CancellationFactors" -> cancellationFactors
  |>},
  evalByIdx = Association @ Map[
    Lookup[#, "TrialIndex", Missing["NotAvailable"]] -> # &,
    scalingEvaluations
  ];
  rowForTrial[trial_] := Module[
    {idx, ev, cov, validObsQ, admSLQ, perGenQ, scalingQ},
    idx = Lookup[Lookup[trial, "ObstructionAttemptData", <||>], "Attempt", Missing["NotAvailable"]];
    ev = Lookup[evalByIdx, idx, Missing["NoScalingEval"]];
    cov = If[AssociationQ[ev], hrfEvalScalingData[ev], <||>];
    validObsQ = hrfValidObstructionTrialQ[trial, vars, kinVars];
    admSLQ = TrueQ[Lookup[trial, "AdmissibleSLSectorQ", False]];
    perGenQ = TrueQ[Lookup[trial, "PerGeneratorAdmissibleQ", False]];
    scalingQ = Which[
      MatchQ[ev, _Missing], Missing["NotEvaluated"],
      ! validObsQ, Missing["NoValidObstruction"],
      True, TrueQ[Lookup[ev, "ValidScalingQ", False]]
    ];
    Module[{diag = If[AssociationQ[cov] && Length[DownValues[hrfSelectedDiagnostic]] > 0,
      hrfSelectedDiagnostic[cov], <||>], sv, vs},
      sv = If[AssociationQ[cov] && ListQ[Lookup[cov, "Scaling", {}]], cov["Scaling"], Missing["NotAvailable"]];
      vs = Lookup[diag, "VariableScaling", Missing["NotAvailable"]];
      <|
        "TrialIndex" -> idx,
        "GeneratorCount" -> Length[Lookup[trial, "Generators", {}]],
        "Generators" -> hrfCompactGeneratorsForSummary[
          Lookup[trial, "Generators", {}],
          Lookup[baseMeta, "CancellationFactors", {}],
          Lookup[baseMeta, "ActiveVars", {}],
          Lookup[baseMeta, "KinVars", {}]
        ],
        "GeneratorsSymbolic" -> Lookup[trial, "Generators", {}],
        "RegionVariables" -> vars,
        "PerGeneratorAdmissibleQ" -> perGenQ,
        "AdmissibleSLSectorQ" -> admSLQ,
        "ValidObstructionQ" -> validObsQ,
        "KinSectorPresentationQ" -> If[Length[kinVars] === 2,
          hrfWideAngleKinSectorPresentationQ[trial, vars, kinVars], Missing["NotApplicable"]],
        "ValidScalingQ" -> scalingQ,
        "HiddenRegionQ" -> If[MatchQ[ev, _Missing], False, TrueQ[Lookup[ev, "HiddenRegionQ", False]]],
        "ExactReductionQ" -> If[MatchQ[ev, _Missing], False, TrueQ[Lookup[ev, "ExactReductionQ", False]]],
        "ScalingStatus" -> Which[
          ! perGenQ, "N/A (per-generator inadmissible)",
          ! admSLQ, "N/A (SL sector inadmissible)",
          ! validObsQ, "N/A (no valid obstruction)",
          MatchQ[ev, _Missing], "Not evaluated (no U or scaling skipped)",
          TrueQ[Lookup[ev, "ExactReductionQ", False]],
            "Exact reduction (F_SL=0; no LP scaling vector required)",
          ! AssociationQ[cov] || cov === <||>, "Not evaluated (no U or scaling skipped)",
          True, Lookup[cov, "ScalingStatusMessage",
            Lookup[cov, "ScalingStatus", Missing["NotAvailable"]]]
        ],
        "ScalingVector" -> sv,
        "ScalingVectorInputForm" -> Which[
          ListQ[sv], ToString[InputForm[sv]],
          MatchQ[sv, _Missing], "--",
          True, ToString[InputForm[sv]]
        ],
        "VariableScaling" -> vs,
        "VariableScalingInputForm" -> Which[
          AssociationQ[vs], ToString[InputForm[Normal[vs]]],
          MatchQ[vs, _Missing], "--",
          True, ToString[InputForm[vs]]
        ],
        "W_SL" -> Lookup[diag, "WSL", Lookup[diag, "FSLWeight", Missing["NotAvailable"]]],
        "W_HR" -> Lookup[diag, "WHR", Lookup[diag, "PostCancellationLeadingWeight", Missing["NotAvailable"]]],
        "VariablesAtWSL" -> Lookup[diag, "VariablesCoveredByFSLAtWSL", Missing["NotAvailable"]],
        "VariablesAtWHR" -> Lookup[diag, "VariablesInPostCancellationLeadingSupport", Missing["NotAvailable"]]
      |>
    ]
  ];
  If[! ListQ[trials] || trials === {}, {}, Table[rowForTrial[trial], {trial, trials}]]
];

Options[findObstructions] = {
   "GeneratorMode" -> "PairSectors",
   "MaxGenerators" -> 2,
   "MaxProductSubsetSize" -> Automatic,
   "UseExtendedFactors" -> False,
   "CancellationFactorOverride" -> Automatic,
   "DimensionfulKinVars" -> Automatic,
   "MaxGeneratorTotalDegree" -> Automatic,
   "MaxGeneratorVarExponent" -> Automatic,
   "RelaxSingleProductDegreeQ" -> Automatic,
   "SkipPDFFindInstanceQ" -> Automatic,
   "StopOnFirstAdmissible" -> Automatic,
   "PreferFewerGenerators" -> Automatic,
   "CandidateGeneratorSetLimit" -> Automatic,
   "StoreAllObstructionTrialsQ" -> Automatic,
   "U" -> Automatic,
   "MaxScalingAbs" -> 5,
   "FObsForScaling" -> Automatic,
   "RequireValidScalingForHiddenRegionQ" -> Automatic,
   "EnumerateHiddenRegionsQ" -> Automatic
   };

(* Debug version: shows which factor finder is being used and what it returns. *)
findObstructionsDebug[F_, vars_, kinAssumptions_, kinVars_, maxSize_ : Automatic,
   OptionsPattern[findObstructions]] :=
 <|
  "UseExtendedFactors" -> OptionValue["UseExtendedFactors"],
  "DimensionfulKinVars" -> OptionValue["DimensionfulKinVars"],
  "GeneratorMode" -> OptionValue["GeneratorMode"],
  "MaxGenerators" -> OptionValue["MaxGenerators"],
  "FactorData" -> If[TrueQ[OptionValue["UseExtendedFactors"]],
    safeCancellationFactorsExtended[F, vars, kinAssumptions, kinVars,
      OptionValue["DimensionfulKinVars"]],
    safeCancellationFactors[F, vars, kinAssumptions, kinVars]]
  |>;

(* Main obstruction finder.
   Output Association keys:
     "CancellationFactors", "AppearsInDerivatives", "Generators",
     "ObstructionData", "GeneratorUseData". *)
findObstructions[F_, vars_, kinAssumptions_, kinVars_, maxSize_ : Automatic,
   OptionsPattern[]] :=
 Module[{factorData, safeFactors, factorsByDerivative, appearsIn,
   generatorSets, trials, admissibleTrials, validTrials, best, use,
   degreeOpts, degreeBounds, factorFilter, stopOnFirstQ, genLimit, preferFewerQ,
   storeAllTrialsQ, allCandidatesTriedQ, limitReachedQ, attemptSummary, storedTrials,
   UOpt, maxScalingAbs, fObsScaling, enumerateQ, requireScalingQ,
   scalingEvaluations, hiddenRegionTrials, hiddenRegionScans, baseScanMeta,
   generatorSetScalingSummary},

  preferFewerQ = hrfResolvePreferFewerGeneratorsQ[kinVars, OptionValue["PreferFewerGenerators"]];
  hrfDebugSay["findObstructions: start; vars=" <> ToString[Length[vars]] <>
    ", maxSize=" <> ToString[maxSize] <> ", mode=" <> ToString[OptionValue["GeneratorMode"]] <>
    ", extended=" <> ToString[OptionValue["UseExtendedFactors"]] <>
    ", preferFewerGens=" <> ToString[preferFewerQ]];

  stopOnFirstQ = Which[
    OptionValue["StopOnFirstAdmissible"] === Automatic,
      TrueQ[$HRFFindObstructionsStopOnFirstAdmissibleQ],
    True, TrueQ[OptionValue["StopOnFirstAdmissible"]]
  ];
  genLimit = Which[
    OptionValue["CandidateGeneratorSetLimit"] === Automatic,
      If[ValueQ[$HRFCandidateGeneratorSetLimit], $HRFCandidateGeneratorSetLimit, Infinity],
    True, OptionValue["CandidateGeneratorSetLimit"]
  ];
  storeAllTrialsQ = Which[
    OptionValue["StoreAllObstructionTrialsQ"] === Automatic,
      TrueQ[$HRFFindObstructionsStoreAllTrialsQ],
    True, TrueQ[OptionValue["StoreAllObstructionTrialsQ"]]
  ];
  UOpt = OptionValue["U"];
  maxScalingAbs = OptionValue["MaxScalingAbs"];
  fObsScaling = OptionValue["FObsForScaling"];
  enumerateQ = hrfResolveEnumerateHiddenRegionsQ[OptionValue["EnumerateHiddenRegionsQ"], UOpt];
  requireScalingQ = hrfResolveRequireValidScalingForHiddenRegionQ[
    OptionValue["RequireValidScalingForHiddenRegionQ"], UOpt
  ];

  degreeOpts = <|
    "MaxGeneratorTotalDegree" -> OptionValue["MaxGeneratorTotalDegree"],
    "MaxGeneratorVarExponent" -> OptionValue["MaxGeneratorVarExponent"],
    "CandidateGeneratorSetLimit" -> genLimit,
    "MaxGenerators" -> OptionValue["MaxGenerators"],
    "RelaxSingleProductDegreeQ" -> Which[
      OptionValue["RelaxSingleProductDegreeQ"] === Automatic, False,
      True, TrueQ[OptionValue["RelaxSingleProductDegreeQ"]]
    ],
    "SkipPDFFindInstanceQ" -> Which[
      OptionValue["SkipPDFFindInstanceQ"] === Automatic, False,
      True, TrueQ[OptionValue["SkipPDFFindInstanceQ"]]
    ],
    "MaxProductSubsetSize" -> Which[
      OptionValue["MaxProductSubsetSize"] === Automatic,
        If[ValueQ[$HRFMaxProductSubsetSize], $HRFMaxProductSubsetSize, 3],
      True, OptionValue["MaxProductSubsetSize"]
    ]
  |>;
  degreeBounds = hrfResolveGeneratorDegreeBounds[F, vars, degreeOpts];

  If[TrueQ[hrfObstructionProgressQ[]],
    Print[hrfObstructionProgressTag[], " finding cancellation factors (", Length[vars], " vars, maxSize ", maxSize, ")..."]
  ];
  factorData = hrfDebugTimed["findObstructions/factor finder",
    Module[{override = OptionValue["CancellationFactorOverride"], dimSpec},
      dimSpec = OptionValue["DimensionfulKinVars"];
      Which[
        override =!= Automatic && ListQ[override],
          {DeleteDuplicates[override],
           If[TrueQ[OptionValue["UseExtendedFactors"]],
             derivativeFactorsExtended[F, vars, kinVars, dimSpec],
             derivativeFactors[F, vars]
           ]},
        TrueQ[OptionValue["UseExtendedFactors"]],
          safeCancellationFactorsExtended[F, vars, kinAssumptions, kinVars, dimSpec],
        True,
          safeCancellationFactors[F, vars, kinAssumptions, kinVars]
      ]
    ]
  ];

  {safeFactors, factorsByDerivative} = factorData;
  factorFilter = hrfFilterFactorsForGenerators[safeFactors, vars, F, degreeOpts];
  hrfDebugSay["findObstructions: cancellation factors=" <> ToString[Length[safeFactors]] <>
    " (degree-admissible for generators: " <> ToString[Length[factorFilter["Factors"]]] <> ")"];

  If[TrueQ[hrfObstructionProgressQ[]],
    Print[hrfObstructionProgressTag[], " ", Length[safeFactors], " cancellation factors; building generator trials (mode ",
      OptionValue["GeneratorMode"], ")..."]
  ];

  appearsIn = Association[
    Table[C -> Select[Keys[factorsByDerivative], MemberQ[factorsByDerivative[#], C] &],
     {C, safeFactors}]
    ];

  generatorSets = hrfDebugTimed["findObstructions/generator-set construction",
    Switch[OptionValue["GeneratorMode"],
      "SingleProduct", candidateGeneratorSets[safeFactors, vars, kinAssumptions, kinVars, F, degreeOpts],
      "PairSectors", candidateGeneratorSetsDiagnostic[safeFactors, OptionValue["MaxGenerators"], vars, kinAssumptions, kinVars, F, degreeOpts],
      "Adaptive", candidateGeneratorSetsAdaptive[safeFactors, vars, kinAssumptions, kinVars, F, degreeOpts],
      _, candidateGeneratorSetsAdaptive[safeFactors, vars, kinAssumptions, kinVars, F, degreeOpts]
    ]
  ];
  hrfDebugSay["findObstructions: generator sets=" <> ToString[Length[generatorSets]]];
  If[TrueQ[hrfObstructionProgressQ[]],
    Print[hrfObstructionProgressTag[], " obstruction search: ", Length[generatorSets],
      " generator trials (cap ", genLimit, "); max obstruction size computed per set from |F| - sum|monomials(g_i)|"]
  ];

  trials = {};
  Module[{lengthLevels, levelIdx, len, validAtLen, stoppedAtLen = Missing[], kinFreeCount, trialOrder, j, i},
   kinFreeCount[gens_] := Count[gens, _?(FreeQ[Expand[#], Alternatives @@ kinVars] &)];
   lengthLevels = If[preferFewerQ,
     Sort @ DeleteDuplicates[Length /@ generatorSets],
     Reverse @ Sort @ DeleteDuplicates[Length /@ generatorSets]
   ];
   Do[
    len = lengthLevels[[levelIdx]];
    validAtLen = {};
    trialOrder = SortBy[
      Select[Range[Length[generatorSets]], Length[generatorSets[[#]]] == len &],
      {-kinFreeCount[generatorSets[[#]]] &, # &}
    ];
    Do[
     i = trialOrder[[j]];
     If[TrueQ[$HRFDebugTiming] && (j == 1 || j == Length[trialOrder] || Mod[j, $HRFDebugProgressEvery] == 0),
       hrfDebugSay["findObstructions: trial " <> ToString[j] <> "/" <> ToString[Length[trialOrder]] <>
         " (|gens|=" <> ToString[len] <> ", idx=" <> ToString[i] <> ")"]
     ];
     If[TrueQ[hrfObstructionProgressQ[]] && (j == 1 || Mod[j, 5] == 0),
       Print[hrfObstructionProgressTag[], " trial ", j, "/", Length[trialOrder],
         " (|gens|=", len, ", kin-free=", kinFreeCount[generatorSets[[i]]], ")"]
     ];
     Module[{obsDiag, obs, setData, slData, perGenQ, setUnionQ, admissibleQ, attemptData, trial},
      setData = generatorSetAdmissibilityData[generatorSets[[i]], safeFactors, vars, kinVars, kinAssumptions, degreeBounds, F];
      perGenQ = TrueQ[Lookup[setData, "PerGeneratorAdmissibleQ", False]];
      setUnionQ = TrueQ[Lookup[setData, "SimultaneouslyAdmissibleGeneratorSetQ", False]];
      obsDiag = If[perGenQ,
        hrfDebugTimed["findObstructions/trial " <> ToString[i] <> " obstruction test",
          obstructionByOriginalTermsGeneralDiagnostic[F, generatorSets[[i]], vars, kinVars, maxSize, kinAssumptions]
        ],
        <|
         "Result" -> Missing["InadmissibleGeneratorSet"],
         "AttemptData" -> <|
           "GeneratorSet" -> Factor /@ generatorSets[[i]],
           "GeneratorCount" -> Length[generatorSets[[i]]],
           "AcceptedQ" -> False,
           "RejectedReason" -> "InadmissibleGeneratorSet: per-generator rule failed"
           |>
         |>
        ];
      obs = Lookup[obsDiag, "Result", Missing["NoObstructionDiagnosticResult"]];
      slData = If[hrfValidObstructionResultQ[obs, generatorSets[[i]], vars, kinVars],
        slSectorAdmissibilityData[obs["Superleading"], generatorSets[[i]], safeFactors, vars, kinVars, kinAssumptions, degreeBounds, F],
        <|
         "SLSectorGenerators" -> {},
         "SLSectorFactorUnion" -> {},
         "SLSectorFactorCount" -> 0,
         "PerGeneratorSLSectorAdmissibleQ" -> False,
         "SimultaneouslyAdmissibleSLSectorQ" -> False,
         "AdmissibleSLSectorQ" -> False,
         "SLSectorAdmissibilityRule" -> "No confirmed superleading sector"
         |>
        ];
      admissibleQ = TrueQ[Lookup[slData, "AdmissibleSLSectorQ", False]];
      attemptData = Join[
        <|"Attempt" -> i|>,
        KeyDrop[setData, {"GeneratorFactorData"}],
        <|"GeneratorFactorData" -> setData["GeneratorFactorData"],
          "PerGeneratorAdmissibleQ" -> perGenQ,
          "AdmissibleGeneratorSetQ" -> admissibleQ|>,
        KeyDrop[slData, {"GeneratorUseData", "SLSectorGeneratorFactorData"}],
        <|"SLSectorGeneratorFactorData" -> Lookup[slData, "SLSectorGeneratorFactorData", {}],
          "AdmissibleSLSectorQ" -> admissibleQ|>,
        Join[Lookup[obsDiag, "AttemptData", <||>],
         Which[
           ! perGenQ, <|"RejectedReason" -> "InadmissibleGeneratorSet: per-generator rule failed"|>,
           ! setUnionQ, <|"CandidateUnionPDFNote" -> "factor union failed simultaneous PDF (5.12) at candidate stage; obstruction still tested"|>,
           hrfValidObstructionResultQ[obs, generatorSets[[i]], vars, kinVars] && ! admissibleQ,
             <|"RejectedReason" -> "Confirmed F_SL failed PDF (5.12) or exact ideal membership on generators entering the sector"|>,
           MatchQ[obs, _Association] && KeyExistsQ[obs, "Superleading"] && ! hrfValidObstructionResultQ[obs, generatorSets[[i]], vars, kinVars],
             <|"RejectedReason" -> "Obstruction candidate failed exact ideal membership or zero superleading sector"|>,
           True, <||>
         ],
         If[KeyExistsQ[obsDiag, "ChannelObstructionAttempts"], <|"ChannelObstructionAttempts" -> obsDiag["ChannelObstructionAttempts"]|>, <||>]]
        ];
      trial = <|"Generators" -> generatorSets[[i]],
        "GeneratorFactorData" -> setData["GeneratorFactorData"],
        "GeneratorSetFactorUnion" -> setData["GeneratorSetFactorUnion"],
        "GeneratorSetFactorCount" -> setData["GeneratorSetFactorCount"],
        "PerGeneratorAdmissibleQ" -> perGenQ,
        "SimultaneouslyAdmissibleGeneratorSetQ" -> setUnionQ,
        "SLSectorGenerators" -> Lookup[slData, "SLSectorGenerators", {}],
        "SLSectorFactorUnion" -> Lookup[slData, "SLSectorFactorUnion", {}],
        "SLSectorFactorCount" -> Lookup[slData, "SLSectorFactorCount", 0],
        "SimultaneouslyAdmissibleSLSectorQ" -> Lookup[slData, "SimultaneouslyAdmissibleSLSectorQ", False],
        "AdmissibleSLSectorQ" -> admissibleQ,
        "AdmissibleGeneratorSetQ" -> admissibleQ,
        "ObstructionData" -> obs,
        "ObstructionAttemptData" -> attemptData,
        "GeneratorAdmissibility" -> If[admissibleQ,
          slData["SLSectorAdmissibilityRule"],
          If[perGenQ, setData["GeneratorSetAdmissibilityRule"], "Per-generator admissibility failed"]
        ]|>;
      AppendTo[trials, trial];
      If[hrfValidObstructionTrialQ[trial, vars, kinVars], AppendTo[validAtLen, trial]];
     ],
     {j, Length[trialOrder]}
    ];
    If[stopOnFirstQ && validAtLen =!= {},
     stoppedAtLen = len;
     hrfDebugSay["findObstructions: stop after |gens|=" <> ToString[len] <>
       " bucket with " <> ToString[Length[validAtLen]] <> " valid trial(s); rank=" <>
       If[preferFewerQ, "exact reduction, min |gens|, min obstruction", "max |gens|, min obstruction"]];
     Break[]
    ];
    ,
    {levelIdx, Length[lengthLevels]}
   ];
  ];

  admissibleTrials = Select[trials,
    TrueQ[Lookup[#, "AdmissibleSLSectorQ", False]] &
    ];
  hrfDebugSay["findObstructions: SL-sector admissible trials=" <> ToString[Length[admissibleTrials]]];

  validTrials = Select[admissibleTrials, hrfValidObstructionTrialQ[#, vars, kinVars] &];
  hrfDebugSay["findObstructions: obstruction trials=" <> ToString[Length[validTrials]]];

  scalingEvaluations = If[enumerateQ && validTrials =!= {} && ! MatchQ[UOpt, None | Automatic | Missing],
    hrfEvaluateValidTrialScaling[#, UOpt, vars, maxScalingAbs, fObsScaling] & /@ validTrials,
    {}
  ];
  hiddenRegionTrials = Select[scalingEvaluations, TrueQ[Lookup[#, "ValidScalingQ", False]] &];
  baseScanMeta = <|
    "InputPolynomial" -> F,
    "ActiveVars" -> vars,
    "KinVars" -> kinVars
  |>;
  hiddenRegionScans = If[hiddenRegionTrials =!= {},
    Table[
      hrfHiddenRegionScanFromTrial[
        eval["Trial"], eval["ScalingData"], baseScanMeta, eval["ValidScalingQ"]
      ],
      {eval, hiddenRegionTrials}
    ],
    {}
  ];

  generatorSetScalingSummary = hrfBuildGeneratorSetScalingSummary[
    trials, scalingEvaluations, vars, kinVars, safeFactors
  ];

  best = Which[
    requireScalingQ && hiddenRegionTrials =!= {},
      Module[{ranked, ev, trial},
        ranked = SortBy[hiddenRegionTrials,
          If[! preferFewerQ && Length[kinVars] === 2,
            hrfWideAngleTrialSelectionRank[Lookup[#, "Trial"], kinVars, preferFewerQ] &,
            hrfObstructionTrialRank[Lookup[#, "Trial"], preferFewerQ] &
          ]
        ];
        ev = ranked[[1]];
        trial = ev["Trial"];
        Join[trial, <|
          "CoverageScalingData" -> hrfScalingDataAssoc @ ev["ScalingData"],
          "HiddenRegionQ" -> ev["ValidScalingQ"]
        |>]
      ],
    requireScalingQ && ! MatchQ[UOpt, None | Automatic | Missing] && validTrials =!= {} && hiddenRegionTrials === {},
      <|
        "Generators" -> {}, "GeneratorFactorData" -> {}, "GeneratorSetFactorUnion" -> {},
        "GeneratorSetFactorCount" -> 0, "PerGeneratorAdmissibleQ" -> False,
        "SimultaneouslyAdmissibleGeneratorSetQ" -> False,
        "SLSectorGenerators" -> {}, "SLSectorFactorUnion" -> {}, "SLSectorFactorCount" -> 0,
        "SimultaneouslyAdmissibleSLSectorQ" -> False,
        "AdmissibleSLSectorQ" -> False, "AdmissibleGeneratorSetQ" -> False,
        "ObstructionData" -> Missing["NoHiddenRegionWithValidScaling",
          "Valid obstruction(s) found but none passed coverage scaling"],
        "ObstructionAttemptData" -> <||>,
        "CoverageScalingData" -> Missing["NoHiddenRegionWithValidScaling"]
      |>,
    validTrials =!= {},
      Module[{ranked, eval},
        ranked = First @ SortBy[validTrials,
          If[! preferFewerQ && Length[kinVars] === 2 && Length[validTrials] > 1,
            hrfWideAngleTrialSelectionRank[#, kinVars, preferFewerQ] &,
            hrfObstructionTrialRank[#, preferFewerQ] &
          ]
        ];
        eval = FirstCase[scalingEvaluations, e_ /; SameQ[Lookup[e, "Trial", Null], ranked], <||>];
        If[AssociationQ[eval] && KeyExistsQ[eval, "ScalingData"] &&
            AssociationQ[hrfScalingDataAssoc @ eval["ScalingData"]],
          Join[ranked, <|
            "CoverageScalingData" -> hrfScalingDataAssoc @ eval["ScalingData"],
            "HiddenRegionQ" -> Lookup[eval, "ValidScalingQ", False]
          |>],
          ranked
        ]
      ],
    True,
      Module[{perGenTrials = Select[trials, TrueQ[Lookup[#, "PerGeneratorAdmissibleQ", False]] &]},
        If[perGenTrials =!= {},
          Join[First[perGenTrials], <|
            "ObstructionData" -> Missing["NoObstructionFound", maxSize],
            "AdmissibleSLSectorQ" -> False,
            "AdmissibleGeneratorSetQ" -> False
          |>],
          <|"Generators" -> {}, "GeneratorFactorData" -> {}, "PerGeneratorAdmissibleQ" -> False,
            "AdmissibleSLSectorQ" -> False, "AdmissibleGeneratorSetQ" -> False,
            "ObstructionData" -> Missing["NoObstructionFound", maxSize]|>
        ]
      ]
    ];

  use = If[AssociationQ[best["ObstructionData"]] &&
      KeyExistsQ[best["ObstructionData"], "Superleading"],
    generatorUseData[best["ObstructionData", "Superleading"], best["Generators"], vars, kinVars],
    Missing["NoUseData"]
    ];

  allCandidatesTriedQ = Length[trials] === Length[generatorSets] && Length[generatorSets] > 0;
  limitReachedQ = IntegerQ[genLimit] && genLimit < Infinity && Length[generatorSets] >= genLimit;
  attemptSummary = Module[{perGenCount = 0, unionCount = 0, findInstanceCount = 0, t},
    Do[
      t = trials[[i]];
      If[TrueQ[Lookup[t, "PerGeneratorAdmissibleQ", False]], perGenCount++];
      If[TrueQ[Lookup[t, "SimultaneouslyAdmissibleGeneratorSetQ", False]], unionCount++];
      If[TrueQ[Lookup[t, "PerGeneratorAdmissibleQ", False]] &&
          ! MatchQ[Lookup[t, "ObstructionData", Missing[]], Missing["InadmissibleGeneratorSet"]],
        findInstanceCount++
      ],
      {i, Length[trials]}
    ];
    <|
      "TrialCount" -> Length[trials],
      "CandidateGeneratorCount" -> Length[generatorSets],
      "PerGeneratorAdmissibleCount" -> perGenCount,
      "CandidateUnionPDFAdmissibleCount" -> unionCount,
      "ObstructionFindInstanceCount" -> findInstanceCount,
      "AdmissibleSLSectorCount" -> Length[admissibleTrials],
      "ValidObstructionCount" -> Length[validTrials],
      "HiddenRegionWithValidScalingCount" -> Length[hiddenRegionTrials],
      "ScalingEvaluatedOnValidTrialsQ" -> (scalingEvaluations =!= {}),
      "GeneratorCountHistogram" -> Counts[Length /@ Lookup[trials, "Generators", {}]],
      "StopOnFirstValidObstructionQ" -> stopOnFirstQ,
      "StoppedEarlyOnValidObstructionQ" -> (stopOnFirstQ && validTrials =!= {} &&
        Length[trials] < Length[generatorSets])
    |>
  ];
  storedTrials = If[storeAllTrialsQ,
    trials,
    If[validTrials =!= {},
      {First @ SortBy[validTrials,
        If[! preferFewerQ && Length[kinVars] === 2 && Length[validTrials] > 1,
          hrfWideAngleTrialSelectionRank[#, kinVars, preferFewerQ] &,
          hrfObstructionTrialRank[#, preferFewerQ] &
        ]
      ]},
      If[admissibleTrials =!= {},
        {First[admissibleTrials]},
        If[trials =!= {}, {Last[trials]}, {}]
      ]
    ]
  ];

  <|
   "CancellationFactors" -> safeFactors,
   "AppearsInDerivatives" -> appearsIn,
   "ActiveVars" -> vars,
   "KinVars" -> kinVars,
   "CandidateGeneratorSets" -> If[storeAllTrialsQ, generatorSets, {}],
   "CandidateGeneratorCount" -> Length[generatorSets],
   "CandidateGeneratorSetLimit" -> genLimit,
   "CandidateGeneratorSetLimitReachedQ" -> limitReachedQ,
   "CandidateGeneratorFactorData" -> If[storeAllTrialsQ,
     (generatorSetAdmissibilityData[#, safeFactors, vars, kinVars, kinAssumptions, degreeBounds, F] & /@ generatorSets),
     {}
   ],
   "GeneratorDegreeBounds" -> degreeBounds,
   "DegreeFilteredGeneratorFactorCount" -> Lookup[factorFilter, "RejectedFactorCount", 0],
   "DegreeAdmissibleGeneratorFactors" -> factorFilter["Factors"],
   "AdmissibleCandidateGeneratorSetQ" -> (admissibleTrials =!= {}),
   "AdmissibleCandidateGeneratorSets" -> (Lookup[#, "Generators", {}] & /@ admissibleTrials),
   "AdmissibleCandidateGeneratorFactorData" -> (Lookup[#, "GeneratorFactorData", {}] & /@ admissibleTrials),
   "AdmissibleCandidateGeneratorSetFactorUnions" -> (Lookup[#, "SLSectorFactorUnion", {}] & /@ admissibleTrials),
   "ObstructionAttemptData" -> storedTrials,
   "ObstructionAttemptSummary" -> attemptSummary,
   "AdmissibleObstructionAttemptData" -> If[storeAllTrialsQ, admissibleTrials, Take[admissibleTrials, UpTo[1]]],
   "AcceptedObstructionAttemptData" -> Lookup[best, "ObstructionAttemptData", <||>],
   "ObstructionAttemptCount" -> Length[trials],
   "AllCandidateGeneratorSetsTriedQ" -> allCandidatesTriedQ,
   "ObstructionSearchCompleteQ" -> True,
   "ValidObstructionTrialCount" -> Length[validTrials],
   "NoObstructionWithinSearchBoundsQ" -> (validTrials === {} && allCandidatesTriedQ &&
     Lookup[attemptSummary, "ObstructionFindInstanceCount", 0] ===
       Lookup[attemptSummary, "PerGeneratorAdmissibleCount", 0]),
   "StoreAllObstructionTrialsQ" -> storeAllTrialsQ,
   "Generators" -> hrfFormatGeneratorsForOutput[Lookup[best, "Generators", {}], safeFactors, vars, kinVars],
   "GeneratorFactorData" -> Lookup[best, "GeneratorFactorData", {}],
   "GeneratorSetFactorUnion" -> Lookup[best, "GeneratorSetFactorUnion", {}],
   "GeneratorSetFactorCount" -> Lookup[best, "GeneratorSetFactorCount", 0],
   "PerGeneratorAdmissibleQ" -> Lookup[best, "PerGeneratorAdmissibleQ", False],
   "SimultaneouslyAdmissibleGeneratorSetQ" -> Lookup[best, "SimultaneouslyAdmissibleGeneratorSetQ", False],
   "SLSectorGenerators" -> Lookup[best, "SLSectorGenerators", {}],
   "SLSectorFactorUnion" -> Lookup[best, "SLSectorFactorUnion", {}],
   "SLSectorFactorCount" -> Lookup[best, "SLSectorFactorCount", 0],
   "SimultaneouslyAdmissibleSLSectorQ" -> Lookup[best, "SimultaneouslyAdmissibleSLSectorQ", False],
   "AdmissibleSLSectorQ" -> Lookup[best, "AdmissibleSLSectorQ", False],
   "AdmissibleGeneratorSetQ" -> TrueQ[Lookup[best, "AdmissibleSLSectorQ", False]],
   "AcceptedObstructionGeneratorSetQ" -> TrueQ[Lookup[best, "AdmissibleSLSectorQ", False]],
   "HiddenRegionQ" -> TrueQ[Lookup[best, "HiddenRegionQ", Length[hiddenRegionScans] > 0]],
   "HiddenRegionCount" -> Length[hiddenRegionScans],
   "HiddenRegionScans" -> hiddenRegionScans,
   "ValidTrialScalingEvaluations" -> scalingEvaluations,
   "GeneratorSetScalingSummary" -> generatorSetScalingSummary,
   "CoverageScalingData" -> Lookup[best, "CoverageScalingData", Missing["NotEvaluated"]],
   "ObstructionData" -> best["ObstructionData"],
   "GeneratorUseData" -> use,
   "GeneratorAdmissibility" -> If[Length[safeFactors] < 2,
     "Rejected: fewer than two cancellation factors available",
     "Per-generator PDF (5.12) at candidate stage; cross-generator PDF (5.12) enforced only after F_SL is confirmed"]
   |>
  ];

(* Diagnostic scan over generator-set candidates. *)
obstructionGeneratorDiagnostic[F_, vars_, kinAssumptions_, kinVars_,
   maxSize_ : 8, maxGenerators_ : 2, dimensionfulSpec_: Automatic] :=
 Module[{safeFactors, factorsByDerivative, appearsIn, generatorSets, trials, degreeBounds, degreeOpts},
  degreeOpts = <||>;
  degreeBounds = hrfResolveGeneratorDegreeBounds[F, vars, degreeOpts];
  {safeFactors, factorsByDerivative} =
   safeCancellationFactorsExtended[F, vars, kinAssumptions, kinVars, dimensionfulSpec];
  appearsIn = Association[
    Table[C -> Select[Keys[factorsByDerivative], MemberQ[factorsByDerivative[#], C] &],
     {C, safeFactors}]
    ];
  generatorSets = candidateGeneratorSetsDiagnostic[safeFactors, maxGenerators, vars, kinAssumptions, kinVars, F, degreeOpts];
  trials = Table[
    Module[{obs, use, setData, slData, perGenQ, admissibleQ},
     setData = generatorSetAdmissibilityData[generatorSets[[i]], safeFactors, vars, kinVars, kinAssumptions, degreeBounds, F];
     perGenQ = TrueQ[Lookup[setData, "PerGeneratorAdmissibleQ", False]];
     obs = If[perGenQ,
       obstructionByOriginalTermsGeneral[F, generatorSets[[i]], vars, kinVars, maxSize, kinAssumptions],
       Missing["InadmissibleGeneratorSet"]
       ];
     slData = If[AssociationQ[obs] && hrfValidObstructionResultQ[obs, generatorSets[[i]], vars, kinVars],
       slSectorAdmissibilityData[obs["Superleading"], generatorSets[[i]], safeFactors, vars, kinVars, kinAssumptions, degreeBounds, F],
       <|
        "SLSectorGenerators" -> {},
        "SLSectorFactorUnion" -> {},
        "SLSectorFactorCount" -> 0,
        "SimultaneouslyAdmissibleSLSectorQ" -> False,
        "AdmissibleSLSectorQ" -> False
        |>
       ];
     admissibleQ = TrueQ[Lookup[slData, "AdmissibleSLSectorQ", False]];
     use = If[AssociationQ[obs] && KeyExistsQ[obs, "Superleading"],
       Lookup[slData, "GeneratorUseData", generatorUseData[obs["Superleading"], generatorSets[[i]], vars, kinVars]],
       Missing["NoUseData"]];
     <|
      "GeneratorSetIndex" -> i,
      "Generators" -> Factor /@ generatorSets[[i]],
      "GeneratorFactorData" -> setData["GeneratorFactorData"],
      "GeneratorSetFactorUnion" -> setData["GeneratorSetFactorUnion"],
      "GeneratorSetFactorCount" -> setData["GeneratorSetFactorCount"],
      "PerGeneratorAdmissibleQ" -> perGenQ,
      "SimultaneouslyAdmissibleGeneratorSetQ" -> setData["SimultaneouslyAdmissibleGeneratorSetQ"],
      "SLSectorGenerators" -> Lookup[slData, "SLSectorGenerators", {}],
      "SLSectorFactorUnion" -> Lookup[slData, "SLSectorFactorUnion", {}],
      "SLSectorFactorCount" -> Lookup[slData, "SLSectorFactorCount", 0],
      "SimultaneouslyAdmissibleSLSectorQ" -> Lookup[slData, "SimultaneouslyAdmissibleSLSectorQ", False],
      "AdmissibleSLSectorQ" -> admissibleQ,
      "AdmissibleGeneratorSetQ" -> admissibleQ,
      "ObstructionData" -> obs,
      "GeneratorUseData" -> use
      |>
     ],
    {i, Length[generatorSets]}
    ];
  <|
   "SafeFactors" -> safeFactors,
   "AppearsInDerivatives" -> appearsIn,
   "CandidateGeneratorSets" -> generatorSets,
   "CandidateGeneratorCount" -> Length[generatorSets],
   "GeneratorDegreeBounds" -> degreeBounds,
   "CandidateGeneratorFactorData" -> (generatorSetAdmissibilityData[#, safeFactors, vars, kinVars, kinAssumptions, degreeBounds, F] & /@ generatorSets),
   "Trials" -> trials
   |>
  ];

(* ---------------------------------------------------------------------- *)
(* Scaling utilities                                                       *)
(* ---------------------------------------------------------------------- *)

If[! ValueQ[$HRFVerboseScaling], $HRFVerboseScaling = False];

ClearAll[monomialWeight, leadingWeight, allTermsSameWeightQ,
  leadingTerms, leadingVariables, scalingDiagnostic,
  coverageScalingQ, findCoverageLPScaling, findMinimalLPScaling,
  polynomialExponentRows, leadingRowsFromExponentRows, variablesFromExponentRows,
  coverageConstraintDiagnosticFromRows, coverageFailureList];

monomialWeight[term_, vars_, v_] := hrfExponentListInVars[term, vars].v;

leadingWeight[p_, vars_, v_] := Module[{terms = List @@ Expand[p]},
  If[p === 0 || terms === {0}, Infinity,
   Min[monomialWeight[#, vars, v] & /@ terms]]
  ];

allTermsSameWeightQ[p_, vars_, v_] := Module[{terms, weights},
  terms = List @@ Expand[p];
  If[p === 0 || terms === {0}, Return[False]];
  weights = monomialWeight[#, vars, v] & /@ terms;
  Length[DeleteDuplicates[weights]] == 1
  ];

leadingTerms[p_, vars_, v_] := Module[{terms, weights, wmin},
  terms = List @@ Expand[p];
  If[p === 0 || terms === {0}, Return[{}]];
  weights = monomialWeight[#, vars, v] & /@ terms;
  wmin = Min[weights];
  Pick[terms, weights, wmin]
  ];

leadingVariables[polys_, vars_, v_] := Module[{terms},
  terms = Flatten[leadingTerms[#, vars, v] & /@ DeleteCases[Flatten[{polys}], 0]];
  DeleteDuplicates@Flatten[Table[hrfVarsWithPositiveExponent[t, vars], {t, terms}]]
  ];

scalingDiagnostic[fSL_, U_, vars_, v_, fObs_ : None] := Module[
  {fSLList, fObsList, wSL, wU, wObs, wLP, lpPolys, lpTerms,
   lpVars, fSLVars, fSLTerms, UTerms, fObsTerms},
  fSLList = DeleteCases[Flatten[{fSL}], 0];
  fObsList = If[fObs === None, {}, DeleteCases[Flatten[{fObs}], 0]];
  fSLTerms = If[fSLList === {}, {}, List @@ Expand[Total[fSLList]]];
  UTerms = If[U === 0, {}, List @@ Expand[U]];
  fObsTerms = If[fObsList === {}, {}, List @@ Expand[Total[fObsList]]];
  wSL = If[fSLTerms === {} || fSLTerms === {0}, Missing["NoFSL"],
    Sort@DeleteDuplicates[monomialWeight[#, vars, v] & /@ fSLTerms]];
  wU = leadingWeight[U, vars, v];
  wObs = leadingWeight[#, vars, v] & /@ fObsList;
  wLP = Min[DeleteCases[Join[{wU}, wObs], Infinity]];
  lpPolys = Join[{U}, fObsList];
  lpTerms = Select[Flatten[Table[leadingTerms[p, vars, v], {p, lpPolys}]],
    monomialWeight[#, vars, v] == wLP &];
  lpVars = DeleteDuplicates@Flatten[Table[hrfVarsWithPositiveExponent[t, vars], {t, lpTerms}]];
  fSLVars = DeleteDuplicates@Flatten[Table[hrfVarsWithPositiveExponent[t, vars], {t, fSLTerms}]];
  <|
   "ScalingVector" -> v,
   "VariableScaling" -> AssociationThread[vars, v],
   "FSLMonomialWeights" -> wSL,
   "FSLUniformWeightQ" -> (ListQ[wSL] && Length[wSL] == 1),
   "FSLWeight" -> If[ListQ[wSL] && Length[wSL] == 1, First[wSL], Missing["NonUniformFSL"]],
   "FSLTerms" -> fSLTerms,
   "FSLSupport" -> fSLVars,
   "ULeadingWeight" -> wU,
   "UWeights" -> If[UTerms === {}, {}, Sort@DeleteDuplicates[monomialWeight[#, vars, v] & /@ UTerms]],
   "ULeadingTermsAtPostCancellationOrder" -> Select[UTerms, monomialWeight[#, vars, v] == wLP &],
   "FObsLeadingWeights" -> wObs,
   "FObsTermsAtPostCancellationOrder" -> Select[fObsTerms, monomialWeight[#, vars, v] == wLP &],
   "PostCancellationLeadingWeight" -> wLP,
   "PostCancellationLeadingTerms" -> lpTerms,
   "VariablesInPostCancellationLeadingSupport" -> lpVars,
   "VariablesCoveredByFSLAtWSL" -> fSLVars,
   "VariablesCoveredByLeadingRegionMonomials" -> Union[fSLVars, lpVars],
   "VariablesMissingFromLeadingRegionCoverage" -> Complement[vars, Union[fSLVars, lpVars]],
   "VariablesMissingFromPostCancellationLeadingSupport" -> Complement[vars, lpVars]
   |>
  ];

(* Exponent-support utilities.  The scaling search works with exponent rows
   rather than repeatedly expanding polynomials for every candidate vector. *)
polynomialExponentRows[p_, vars_] := Module[{rules},
  If[p === 0, Return[{}]];
  rules = CoefficientRules[Expand[p], vars];
  If[rules === {}, {}, Keys[rules]]
  ];

leadingRowsFromExponentRows[rows_, v_] := Module[{weights, wmin},
  If[rows === {}, Return[{}]];
  weights = rows.v;
  wmin = Min[weights];
  Pick[rows, weights, wmin]
  ];

rowsAtWeight[rows_, v_, w_] := Module[{weights},
  If[rows === {}, Return[{}]];
  weights = rows.v;
  Pick[rows, weights, w]
  ];

variablesFromExponentRows[rows_, vars_] := Module[{coveredPositions},
  If[rows === {}, Return[{}]];
  coveredPositions = Flatten[Position[Total[Unitize[rows]], _?(# > 0 &)]];
  vars[[coveredPositions]]
  ];

coverageFailureList[diag_Association] := Module[{fail = {}},
  If[! TrueQ[diag["FSLUniformWeightQ"]], AppendTo[fail, "FSL monomials do not have a common cancellation weight"]];
  If[! TrueQ[diag["HiddenDominatesPostCancellationLPQ"]], AppendTo[fail, "FSL is not more singular than the post-cancellation LP polynomial"]];
  If[! TrueQ[diag["LeadingRegionCoverageQ"]], AppendTo[fail, "not all active variables are covered by F_SL monomials at W_SL or surviving LP monomials at W_HR"]];
  fail
  ];

coverageConstraintDiagnosticFromRows[v_, fSLRows_, URows_, fObsRows_, vars_] := Module[
  {fSLRowsFlat, fSLWeights, fSLUniform, wSL, uWeights, wU,
   obsWeightsByComponent, wObs, wLP, postRows, postRowsU, postRowsObs,
   postVars, fSLVarsAtWSL, coveredVars, hiddenLP, coverage, unitGap, diag},
  fSLRowsFlat = Join @@ fSLRows;
  fSLWeights = Sort@DeleteDuplicates[fSLRowsFlat.v];
  fSLUniform = Length[fSLWeights] == 1;
  wSL = If[fSLUniform, First[fSLWeights], Missing["NoCommonFSLWeight"]];
  uWeights = URows.v;
  wU = Min[uWeights];
  obsWeightsByComponent = fObsRows.v & /@ fObsRows;
  wObs = If[fObsRows === {}, {}, Min /@ obsWeightsByComponent];
  wLP = Min[DeleteCases[Join[{wU}, wObs], Infinity]];
  postRowsU = rowsAtWeight[URows, v, wLP];
  postRowsObs = Join @@ (rowsAtWeight[#, v, wLP] & /@ fObsRows);
  postRows = Join[postRowsU, postRowsObs];
  postVars = variablesFromExponentRows[postRows, vars];
  fSLVarsAtWSL = If[fSLUniform, variablesFromExponentRows[fSLRowsFlat, vars], {}];
  coveredVars = Union[fSLVarsAtWSL, postVars];
  hiddenLP = fSLUniform && wSL < wLP;
  coverage = Complement[vars, coveredVars] === {};
  unitGap = fSLUniform && (wLP - wSL == 1);
  diag = <|
    "ScalingVector" -> v,
    "VariableScaling" -> AssociationThread[vars, v],
    "FSLMonomialWeights" -> fSLWeights,
    "FSLUniformWeightQ" -> fSLUniform,
    "FSLWeight" -> wSL,
    "ULeadingWeight" -> wU,
    "UWeights" -> Sort@DeleteDuplicates[uWeights],
    "FObsLeadingWeights" -> wObs,
    "PostCancellationLeadingWeight" -> wLP,
    "HierarchyGapPostLPminusFSL" -> If[fSLUniform, wLP - wSL, Missing["Undefined"]],
    "UnitGapQ" -> unitGap,
    "HiddenDominatesPostCancellationLPQ" -> hiddenLP,
    "PostCancellationLeadingUSupport" -> variablesFromExponentRows[postRowsU, vars],
    "PostCancellationLeadingFObsSupport" -> variablesFromExponentRows[postRowsObs, vars],
    "VariablesInPostCancellationLeadingSupport" -> postVars,
    "VariablesCoveredByFSLAtWSL" -> fSLVarsAtWSL,
    "VariablesCoveredByLeadingRegionMonomials" -> coveredVars,
    "VariablesMissingFromLeadingRegionCoverage" -> Complement[vars, coveredVars],
    "LeadingRegionCoverageQ" -> coverage,
    "PostCancellationLeadingCoverageQ" -> (Complement[vars, postVars] === {})
    |>;
  Join[diag, <|"AcceptedQ" -> (fSLUniform && hiddenLP && coverage),
    "FailedConditions" -> coverageFailureList[diag]|>]
  ];

coverageScalingQ[fSL_, U_, vars_, v_, fObs_ : None] := Module[
  {fSLList, fObsList, fSLRows, URows, fObsRows, diag},
  fSLList = DeleteCases[Flatten[{fSL}], 0];
  If[fSLList === {} || U === 0, Return[False]];
  fObsList = If[fObs === None, {}, DeleteCases[Flatten[{fObs}], 0]];
  fSLRows = polynomialExponentRows[#, vars] & /@ fSLList;
  URows = polynomialExponentRows[U, vars];
  fObsRows = polynomialExponentRows[#, vars] & /@ fObsList;
  If[MemberQ[fSLRows, {}] || URows === {}, Return[False]];
  diag = coverageConstraintDiagnosticFromRows[v, fSLRows, URows, fObsRows, vars];
  TrueQ[diag["AcceptedQ"]]
  ];

(* Post-cancellation Lee--Pomeransky scaling search.  F_SL monomials must
   have a common pre-cancellation weight, because otherwise they cannot cancel.
   The coverage test is applied at the monomial-constraint level: every active
   variable must appear either in an F_SL monomial at W_SL or in a surviving
   leading monomial of U + F_obs at W_HR.  The unit gap is reported but not imposed. *)
(* Fast post-cancellation Lee--Pomeransky scaling search.  The search first
   enforces the necessary F_SL homogeneity equations and only then tests
   hierarchy and leading-support coverage.  This replaces the old exhaustive
   tuple scan, which is retained below only as findCoverageLPScalingScan. *)
ClearAll[hrfNormalizeScalingVector, hrfFSLUniformScalingQ, hrfScalingVectorInBoundsQ,
  hrfScalingIntegerNullspaceBasis, hrfScalingRayCandidatesFromBasis,
  hrfHomogeneousScalingCandidates, hrfScalingSearchMeta, hrfAssocMerge];

hrfNormalizeScalingVector[v_List] := Module[{g = GCD @@ DeleteCases[Abs[v], 0]},
  If[g === 0 || g === GCD[], v, v/g]
];

hrfFSLUniformScalingQ[rows_List, v_List] := Module[{weights},
  If[rows === {} || ! VectorQ[v, IntegerQ], Return[False]];
  weights = DeleteDuplicates[rows.v];
  Length[weights] == 1
];

hrfScalingVectorInBoundsQ[v_List, maxAbs_Integer] := VectorQ[v, IntegerQ] &&
  Length[v] > 0 && Min[v] < 0 && And @@ Thread[-maxAbs <= v <= 0];

hrfScalingIntegerNullspaceBasis[mat_] := Module[{ns, vec, den, g},
  ns = NullSpace[mat];
  DeleteDuplicatesBy[
    Select[
      Table[
        vec = Rationalize[ns[[i]], 0];
        den = LCM @@ Denominator[vec];
        vec = Round[vec den];
        g = GCD @@ DeleteCases[Abs[vec], 0];
        If[g =!= 0 && g =!= GCD[], vec = vec/g];
        vec,
        {i, Length[ns]}
      ],
      (* Zero entries are allowed in scaling vectors; only reject the zero vector. *)
      VectorQ[#, IntegerQ] && ! AllTrue[#, # == 0 &] &
    ],
    hrfNormalizeScalingVector
  ]
];

(* 1D integer rays along nullspace basis directions (used only when the
   coefficient box (maxAbs+1)^dim is too large to enumerate exhaustively). *)
hrfScalingRayCandidatesFromBasis[basis_List, nvars_Integer, maxAbs_Integer] := Module[
  {candidates = {}, v, ks, j, c, sym = ConstantArray[-1, nvars]},
  If[hrfScalingVectorInBoundsQ[sym, maxAbs], AppendTo[candidates, sym]];
  Do[
    ks = Select[Range[-maxAbs, 0],
      hrfScalingVectorInBoundsQ[# basis[[j]], maxAbs] &
    ];
    Do[AppendTo[candidates, c basis[[j]]], {c, ks}],
    {j, Length[basis]}
  ];
  DeleteDuplicatesBy[candidates, hrfNormalizeScalingVector]
];

hrfHomogeneousScalingCandidates[fSLRows_, nvars_Integer, maxAbs_Integer] := Module[
  {rows, mat, rank, basis, dim, limit, tupleCount, coeffs, candidates,
   exhaustiveQ, method, normCandidates},
  rows = DeleteDuplicates[Join @@ fSLRows];
  If[rows === {}, Return[<| "Candidates" -> {}, "ExhaustiveQ" -> True, "Method" -> "EmptyFSL" |>]];
  mat = If[Length[rows] <= 1, {}, (# - First[rows]) & /@ Rest[rows]];
  rank = If[mat === {}, 0, MatrixRank[mat]];
  limit = If[ValueQ[$HRFScalingFreeTupleEnumerationLimit], $HRFScalingFreeTupleEnumerationLimit, 2000000];
  basis = If[mat === {},
    (* Vacuous homogeneity: all F_SL monomials share one exponent pattern. *)
    Table[UnitVector[nvars, i], {i, nvars}],
    hrfScalingIntegerNullspaceBasis[mat]
  ];
  dim = Length[basis];
  tupleCount = If[dim == 0, 0, (2 maxAbs + 1)^dim - 1];
  exhaustiveQ = False;
  method = "FSLNullspaceCoefficients";

  Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
    "  [coverage candidate generation] method=nullspace vars=" <> ToString[nvars] <>
    " maxAbs=" <> ToString[maxAbs] <> " monomialRows=" <> ToString[Length[rows]] <>
    " homogeneityRank=" <> ToString[rank] <> " nullspaceDim=" <> ToString[dim] <>
    " coeffBox=" <> ToString[tupleCount]];

  candidates = {};
  Which[
    dim == 0,
      method = "FSLNullspaceDetermined";
      candidates = hrfScalingRayCandidatesFromBasis[{{ConstantArray[-1, nvars]}}, nvars, maxAbs];
      exhaustiveQ = True,
    tupleCount <= limit,
      method = "FSLNullspaceCoefficients";
      (* Integer coordinates on a nullspace basis; the result v must lie in
         [-maxAbs,0]^n, not each coordinate k_i. *)
      coeffs = Select[Tuples[Range[-maxAbs, maxAbs], dim], ! AllTrue[#, # == 0 &] &];
      candidates = Select[
        Table[
          Total @ Table[coeffs[[k, j]] * basis[[j]], {j, dim}],
          {k, Length[coeffs]}
        ],
        hrfScalingVectorInBoundsQ[#, maxAbs] &
      ];
      exhaustiveQ = True,
    True,
      method = "FSLNullspaceRays";
      candidates = hrfScalingRayCandidatesFromBasis[basis, nvars, maxAbs];
      exhaustiveQ = False
  ];
  normCandidates = DeleteDuplicatesBy[
    Select[candidates, hrfFSLUniformScalingQ[rows, #] &],
    hrfNormalizeScalingVector
  ];
  normCandidates = hrfNormalizeScalingVector /@ normCandidates;
  Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
    "  [coverage candidates] method=" <> method <>
    " candidateCount=" <> ToString[Length[normCandidates]] <>
    " exhaustiveQ=" <> ToString[exhaustiveQ]];
  <|"Candidates" -> normCandidates, "ExhaustiveQ" -> exhaustiveQ, "Method" -> method,
    "NullspaceDim" -> dim, "CoefficientBoxSize" -> tupleCount|>
];

hrfScalingSearchMeta[acceptedCount_Integer, exhaustiveQ_, candidateCount_Integer] := Module[
  {status, message, exhaustive = TrueQ[exhaustiveQ]},
  Which[
    acceptedCount >= 1,
      status = "Found";
      message = "Scaling vector determined",
    exhaustive && acceptedCount == 0,
      status = "NoValidScaling";
      message = "No scaling vector exists under LP constraints (uniform F_SL, W_SL<W_HR, variable coverage) within the searched nullspace box",
    True,
      status = "NotDetermined";
      message = "HR decomposition found but scaling vector not determined (nullspace coefficient search incomplete; increase $HRFScalingFreeTupleEnumerationLimit or maxAbs)"
  ];
  <|"ScalingStatus" -> status, "ScalingStatusMessage" -> message,
    "ScalingSearchExhaustiveQ" -> exhaustive,
    "ScalingSearchCompleteQ" -> exhaustive|>
];

hrfAssocMerge[a_, b_] := Module[{aa, bb},
  aa = If[AssociationQ[a], a, <||>];
  bb = If[AssociationQ[b], b, <||>];
  Association @ Join[Normal[aa], Normal[bb]]
];

findCoverageLPScaling[fSL_, U_, vars_, maxAbs_ : 5, fObs_ : None] := Module[
  {fSLList, fObsList, fSLRows, URows, fObsRows, candidateInfo, candidates, exhaustiveQ,
   genMethod, bruteCount, accepted, nearMisses, best, nvars, diag, sortKey, maxReport = 20,
   searchMeta},
  fSLList = DeleteCases[Flatten[{fSL}], 0];
  If[fSLList === {} || U === 0,
   Return[<|"Scaling" -> Missing["NoFSLOrU"], "CandidateGenerationMethod" -> "FSLNullspaceRREF", "Diagnostics" -> {}|>]
  ];
  fObsList = If[fObs === None, {}, DeleteCases[Flatten[{fObs}], 0]];
  fSLRows = polynomialExponentRows[#, vars] & /@ fSLList;
  URows = polynomialExponentRows[U, vars];
  fObsRows = polynomialExponentRows[#, vars] & /@ fObsList;
  If[MemberQ[fSLRows, {}] || URows === {},
   Return[<|"Scaling" -> Missing["EmptyExponentSupport"], "CandidateGenerationMethod" -> "FSLNullspaceRREF", "Diagnostics" -> {}|>]
  ];
  nvars = Length[vars];
  bruteCount = (maxAbs + 1)^nvars - 1;
  Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
    "  [coverage routine] findCoverageLPScaling FAST entered vars=" <> ToString[nvars] <>
    " maxAbs=" <> ToString[maxAbs] <> " bruteBox=" <> ToString[bruteCount]];
  candidates = hrfHomogeneousScalingCandidates[fSLRows, nvars, maxAbs];
  If[AssociationQ[candidates],
    candidateInfo = candidates;
    candidates = Lookup[candidateInfo, "Candidates", {}];
    exhaustiveQ = TrueQ[Lookup[candidateInfo, "ExhaustiveQ", False]];
    genMethod = Lookup[candidateInfo, "Method", "FSLNullspaceCoefficients"],
    candidateInfo = <||>;
    exhaustiveQ = False;
    genMethod = "FSLNullspaceCoefficients"
  ];
  If[! ListQ[candidates],
    Return[hrfAssocMerge[<|
      "Scaling" -> candidates,
      "CandidateGenerationMethod" -> genMethod,
      "CandidateCount" -> Missing["NotGenerated"],
      "BackupBruteForceCandidateCount" -> bruteCount,
      "AcceptedCount" -> 0,
      "UniqueAcceptedScalingQ" -> False,
      "AcceptedScalingVectors" -> {},
      "Status" -> "CandidateGenerationDidNotComplete",
      "Diagnostics" -> {}
    |>, hrfScalingSearchMeta[0, False, 0]]]
  ];
  Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
    "  [coverage candidate testing start] candidates=" <> ToString[Length[candidates]]];
  sortKey[a_Association] := With[{v = a["ScalingVector"], gap = a["HierarchyGapPostLPminusFSL"]},
    {If[TrueQ[a["UnitGapQ"]], 0, 1], Total[Abs[v]], Max[Abs[v]], -Replace[gap, _Missing -> -10^6], v}
  ];
  accepted = {};
  nearMisses = {};
  Do[
    If[Mod[ii, If[ValueQ[$HRFScalingProgressEvery], $HRFScalingProgressEvery, 1000]] == 0,
      Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
        "  [coverage candidate testing progress] " <> ToString[ii] <> "/" <> ToString[Length[candidates]]]
    ];
    v = candidates[[ii]];
    diag = coverageConstraintDiagnosticFromRows[v, fSLRows, URows, fObsRows, vars];
    If[TrueQ[diag["AcceptedQ"]],
      AppendTo[accepted, diag],
      If[Length[diag["FailedConditions"]] <= 1, AppendTo[nearMisses, diag]]
    ],
    {ii, Length[candidates]}
  ];
  Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
    "  [coverage candidate testing end] accepted=" <> ToString[Length[accepted]]];
  accepted = SortBy[accepted, sortKey];
  nearMisses = SortBy[nearMisses, {Length[Lookup[#, "FailedConditions", {}]] &, Total[Abs[Lookup[#, "ScalingVector", {}]]] &, Max[Abs[Lookup[#, "ScalingVector", {0}]]] &}];
  If[accepted === {},
   If[bruteCount > If[ValueQ[$HRFScalingBruteForceLimit], $HRFScalingBruteForceLimit, 1000000],
    Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
      "  [coverage fallback skipped] bruteBox=" <> ToString[bruteCount] <>
      " exceeds limit=" <> ToString[If[ValueQ[$HRFScalingBruteForceLimit], $HRFScalingBruteForceLimit, 1000000]]];
    Return[hrfAssocMerge[<|
      "Scaling" -> Missing["BruteForceTooLarge"],
      "CandidateGenerationMethod" -> genMethod,
      "CandidateCount" -> Length[candidates],
      "BackupBruteForceCandidateCount" -> bruteCount,
      "AcceptedCount" -> 0,
      "UniqueAcceptedScalingQ" -> False,
      "AcceptedScalingVectors" -> {},
      "Status" -> "FastNullspaceFoundNoAcceptance;BruteForceSkipped",
      "FastNearMissDiagnostics" -> Take[nearMisses, UpTo[maxReport]],
      "Diagnostics" -> {}
    |>, hrfScalingSearchMeta[0, exhaustiveQ, Length[candidates]]]],
    Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
      "  [coverage fallback] fast nullspace accepted=0 candidates=" <> ToString[Length[candidates]] <>
      "; running brute-force scan"];
    Return @ Join[
      findCoverageLPScalingScan[fSL, U, vars, maxAbs, fObs],
      <|
        "FastNullspaceCandidateCount" -> Length[candidates],
        "FastNearMissDiagnostics" -> Take[nearMisses, UpTo[maxReport]]
      |>
    ]
   ],
   best = First[accepted];
   If[TrueQ[$HRFScalingReport],
     Print["coverage scaling: accepted=", Length[accepted], "/", Length[candidates],
       " selected=", best["ScalingVector"],
       " wFSL=", best["FSLWeight"],
       " wLP=", best["PostCancellationLeadingWeight"],
       " gap=", best["HierarchyGapPostLPminusFSL"],
       " missing=", best["VariablesMissingFromLeadingRegionCoverage"]]
   ];
   hrfAssocMerge[<|
     "Scaling" -> best["ScalingVector"],
     "CandidateGenerationMethod" -> genMethod,
     "CandidateCount" -> Length[candidates],
     "BackupBruteForceCandidateCount" -> bruteCount,
     "AcceptedCount" -> Length[accepted],
     "AcceptedScalingVectors" -> Take[Lookup[accepted, "ScalingVector", {}], UpTo[maxReport]],
     "AcceptedScalingVectorCount" -> Length[accepted],
     "UniqueAcceptedScalingQ" -> (Length[DeleteDuplicates[Lookup[accepted, "ScalingVector", {}]]] == 1),
     "SelectedCandidateDiagnostic" -> Join[best, <|"WSL" -> best["FSLWeight"], "WHR" -> best["PostCancellationLeadingWeight"]|>],
     "Criteria" -> <|
       "FSLCancellation" -> "all monomials in F_SL must have a common weight before cancellation",
       "HiddenHierarchy" -> "that common F_SL weight must be more singular than the first surviving weight of U + F_obs",
       "Coverage" -> "active variables must be covered by F_SL monomials at W_SL or surviving monomials of U + F_obs at W_HR",
       "UnitGap" -> "reported but not imposed"|>,
     "AcceptedCandidateDiagnostics" -> Take[accepted, UpTo[maxReport]],
     "NearMissDiagnostics" -> Take[nearMisses, UpTo[maxReport]],
     "Diagnostics" -> scalingDiagnostic[fSL, U, vars, best["ScalingVector"], fObs]
   |>, hrfScalingSearchMeta[Length[accepted], exhaustiveQ, Length[candidates]]]
   ]
  ];

findCoverageLPScalingScan[fSL_, U_, vars_, maxAbs_ : 5, fObs_ : None] := Module[
  {fSLList, fObsList, fSLRows, URows, fObsRows, candidates, accepted,
   nearMisses, best, nvars, diag, sortKey, maxReport = 20},
  fSLList = DeleteCases[Flatten[{fSL}], 0];
  If[fSLList === {} || U === 0,
   Return[<|"Scaling" -> Missing["NoFSLOrU"], "CandidateGenerationMethod" -> "BruteForceScan", "Diagnostics" -> {}|>]
  ];
  fObsList = If[fObs === None, {}, DeleteCases[Flatten[{fObs}], 0]];
  fSLRows = polynomialExponentRows[#, vars] & /@ fSLList;
  URows = polynomialExponentRows[U, vars];
  fObsRows = polynomialExponentRows[#, vars] & /@ fObsList;
  If[MemberQ[fSLRows, {}] || URows === {},
   Return[<|"Scaling" -> Missing["EmptyExponentSupport"], "CandidateGenerationMethod" -> "BruteForceScan", "Diagnostics" -> {}|>]
  ];
  nvars = Length[vars];
  candidates = Select[Tuples[Range[-maxAbs, 0], nvars], Min[#] < 0 &];
  sortKey[a_Association] := With[{v = a["ScalingVector"], gap = a["HierarchyGapPostLPminusFSL"]},
    {If[TrueQ[a["UnitGapQ"]], 0, 1], Total[Abs[v]], Max[Abs[v]], -Replace[gap, _Missing -> -10^6], v}
  ];
  accepted = {}; nearMisses = {};
  Do[
    diag = coverageConstraintDiagnosticFromRows[v, fSLRows, URows, fObsRows, vars];
    If[TrueQ[diag["AcceptedQ"]], AppendTo[accepted, diag], If[Length[diag["FailedConditions"]] <= 1, AppendTo[nearMisses, diag]]],
    {v, candidates}
  ];
  accepted = SortBy[accepted, sortKey];
  If[accepted === {},
    hrfAssocMerge[<|
      "Scaling" -> Missing["NoPostCancellationCoverageScalingFoundUpTo", maxAbs],
      "CandidateGenerationMethod" -> "BruteForceScan", "CandidateCount" -> Length[candidates],
      "AcceptedCount" -> 0, "AcceptedCandidateDiagnostics" -> {},
      "NearMissDiagnostics" -> Take[nearMisses, UpTo[maxReport]], "Diagnostics" -> {}
    |>, hrfScalingSearchMeta[0, True, Length[candidates]]],
    best = First[accepted];
    hrfAssocMerge[<|
      "Scaling" -> best["ScalingVector"], "CandidateGenerationMethod" -> "BruteForceScan",
      "CandidateCount" -> Length[candidates], "AcceptedCount" -> Length[accepted],
      "AcceptedScalingVectors" -> Take[Lookup[accepted, "ScalingVector", {}], UpTo[maxReport]],
      "AcceptedScalingVectorCount" -> Length[accepted],
      "UniqueAcceptedScalingQ" -> (Length[DeleteDuplicates[Lookup[accepted, "ScalingVector", {}]]] == 1),
      "SelectedCandidateDiagnostic" -> Join[best, <|"WSL" -> best["FSLWeight"], "WHR" -> best["PostCancellationLeadingWeight"]|>],
      "AcceptedCandidateDiagnostics" -> Take[accepted, UpTo[maxReport]],
      "NearMissDiagnostics" -> Take[nearMisses, UpTo[maxReport]],
      "Diagnostics" -> scalingDiagnostic[fSL, U, vars, best["ScalingVector"], fObs]
    |>, hrfScalingSearchMeta[Length[accepted], True, Length[candidates]]]
  ]
];

(* Historical brute-force search, retained for old examples only.  The 5-point
   collinear example no longer calls this routine. *)
findMinimalLPScaling[obstruction_, complement_, U_, vars_, maxAbs_ : 5] :=
 Module[{candidates, good, wComp, wObs, wU},
  candidates = Select[Tuples[Range[-maxAbs, 0], Length[vars]], Min[#] < 0 &];
  good = Select[candidates,
    Function[v,
     wComp = leadingWeight[complement, vars, v];
     wObs = leadingWeight[obstruction, vars, v];
     wU = leadingWeight[U, vars, v];
     allTermsSameWeightQ[complement, vars, v] && wObs == wComp + 1 && wU == wObs
     ]
    ];
  If[good === {}, Missing["NoLPScalingFoundUpTo", maxAbs],
   First@SortBy[good, {Total[Abs[#]] &, Max[Abs[#]] &, Identity}]]
  ];

(* ---------------------------------------------------------------------- *)
(* Boundary scans                                                          *)
(* ---------------------------------------------------------------------- *)

ClearAll[boundarySubsets, restrictPolynomialToBoundary, hrfAttachBoundaryScanContext,
  hrfObstructionDecompositionConsistentQ, findObstructionsOnBoundary,
  findObstructionsOnBoundaries4pt, interestingBoundaryQ4pt,
  summarizeBoundaryScan4pt, scanInterestingBoundariesOnly4pt];

boundarySubsets[vars_, maxCodim_] :=
 Join[{{}}, Flatten[Table[Subsets[vars, {k}], {k, 1, maxCodim}], 1]];

restrictPolynomialToBoundary[F_, vars_, zeroVars_] := Module[{remainingVars, Frestricted},
  remainingVars = Complement[vars, zeroVars];
  Frestricted = Expand[F /. Thread[zeroVars -> 0]];
  If[Frestricted =!= 0, Frestricted = Factor[Frestricted]];
  <|"ZeroVars" -> zeroVars, "RemainingVars" -> remainingVars,
   "FRestricted" -> Frestricted|>
  ];

(* Record the polynomial and active variables used for an obstruction scan.
   On boundaries this is always the restricted F after x_i -> 0, never the
   ambient interior F0. *)
hrfAttachBoundaryScanContext[scan_, F_, activeVars_, zeroVars_: {}] := If[
  ! AssociationQ[scan], scan,
  Join[scan, <|
    "ZeroVars" -> zeroVars,
    "InputPolynomial" -> Expand[F],
    "ActiveVars" -> activeVars,
    "BoundaryRestrictedQ" -> (zeroVars =!= {})
  |>]
];

hrfObstructionDecompositionConsistentQ[scan_, F_] := Module[{od, obst, sl},
  If[! AssociationQ[scan], Return[False]];
  od = Lookup[scan, "ObstructionData", Missing[]];
  If[! AssociationQ[od], Return[False]];
  obst = Lookup[od, "Obstruction", 0];
  sl = Lookup[od, "Superleading", Lookup[od, "Complement", 0]];
  TrueQ[Expand[obst + sl - Expand[F]] === 0]
];

findObstructionsOnBoundary[F_, vars_, zeroVars_, kinAssumptions_, kinVars_,
   maxSize_ : 8, opts___] := Module[{res, scan},
  res = restrictPolynomialToBoundary[F, vars, zeroVars];
  If[res["FRestricted"] === 0 || res["RemainingVars"] === {},
   Return[Join[res, <|"ObstructionScan" -> Missing["TrivialBoundary"]|>]]
  ];
  scan = findObstructions[
    res["FRestricted"], res["RemainingVars"], kinAssumptions, kinVars, maxSize, opts
  ];
  scan = hrfAttachBoundaryScanContext[scan, res["FRestricted"], res["RemainingVars"], zeroVars];
  scan = Join[scan, <|"KinVars" -> kinVars|>];
  Join[res, <|"ObstructionScan" -> scan|>]
];

findObstructionsOnBoundaries4pt[F_, vars_, kinAssumptions_, kinVars_,
   maxCodim_ : 2, maxSize_ : 8, maxGenerators_ : 2] :=
 Module[{strata},
  strata = boundarySubsets[vars, maxCodim];
  Table[
   findObstructionsOnBoundary[F, vars, strata[[i]], kinAssumptions, kinVars, maxSize,
    "GeneratorMode" -> "PairSectors", "UseExtendedFactors" -> True,
    "MaxGenerators" -> maxGenerators],
   {i, Length[strata]}
   ]
  ];

interestingBoundaryQ4pt[stratum_] := Module[{obs, obsData},
  obs = stratum["ObstructionScan"];
  If[! AssociationQ[obs], Return[False]];
  obsData = obs["ObstructionData"];
  AssociationQ[obsData] && KeyExistsQ[obsData, "Superleading"] &&
   obsData["Superleading"] =!= 0 && Length[obs["CancellationFactors"]] >= 2 &&
   Length[obs["Generators"]] >= 1
  ];

summarizeBoundaryScan4pt[scan_] := Table[
   Module[{obs, obsData},
    obs = scan[[i, "ObstructionScan"]];
    If[! AssociationQ[obs], Nothing,
     obsData = obs["ObstructionData"];
     <|
      "Index" -> i,
      "ZeroVars" -> scan[[i, "ZeroVars"]],
      "Codimension" -> Length[scan[[i, "ZeroVars"]]],
      "RemainingVars" -> scan[[i, "RemainingVars"]],
      "CancellationFactors" -> obs["CancellationFactors"],
      "Generators" -> obs["Generators"],
      "Obstruction" -> If[AssociationQ[obsData] && KeyExistsQ[obsData, "Obstruction"],
        obsData["Obstruction"], Missing["NoObstruction"]],
      "Superleading" -> If[AssociationQ[obsData] && KeyExistsQ[obsData, "Superleading"],
        obsData["Superleading"], Missing["NoSuperleading"]],
      "FRestricted" -> scan[[i, "FRestricted"]]
      |>
     ]
    ],
   {i, Length[scan]}
   ];

(* Memory-friendlier boundary scan: stores only interesting strata. *)
scanInterestingBoundariesOnly4pt[F_, vars_, kinAssumptions_, kinVars_,
   maxCodim_ : 3, maxSize_ : 12, maxGenerators_ : 2] :=
 Module[{strata, out = {}, entry},
  strata = boundarySubsets[vars, maxCodim];
  Do[
   entry = Join[
     <|"Index" -> i, "Codimension" -> Length[strata[[i]]]|>,
     findObstructionsOnBoundary[F, vars, strata[[i]], kinAssumptions, kinVars, maxSize,
      "GeneratorMode" -> "PairSectors", "UseExtendedFactors" -> True,
      "MaxGenerators" -> maxGenerators]
   ];
   If[interestingBoundaryQ4pt[entry], AppendTo[out, entry]];,
   {i, Length[strata]}
   ];
  out
  ];

(* ---------------------------------------------------------------------- *)
(* Miscellaneous comparison helpers                                        *)
(* ---------------------------------------------------------------------- *)

ClearAll[canonFac2, facSetEq2];

canonFac2[expr_] := Module[{g, sp1, sm1},
  g = Factor[expr];
  sp1 = ToString[InputForm[g]];
  sm1 = ToString[InputForm[-g]];
  If[OrderedQ[{sm1, sp1}], -g, g]
  ];

facSetEq2[listA_, listB_] := Module[{sa, sb},
  sa = ToString[InputForm[#]] & /@ (canonFac2 /@ listA);
  sb = ToString[InputForm[#]] & /@ (canonFac2 /@ listB);
  Sort[sa] === Sort[sb]
  ];

Quiet @ Check[Get[FileNameJoin[{hrfPackageDirectory[], "HRF_KinematicGeneratorPresets.wl"}]], Null];

$HRFFinderCoreLoadedQ = True;
If[! TrueQ[$HRFWideAngleBoundaryDiagnosticLoadedQ],
  Quiet @ Check[Get[FileNameJoin[{hrfPackageDirectory[], "HRF_WideAngleBoundaryDiagnostic.wl"}]], Null]
];
