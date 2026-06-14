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

ClearAll[hrfDebugSay, hrfDebugTimed];
hrfDebugSay[msg_] := If[TrueQ[$HRFDebugTiming], Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <> "  " <> ToString[msg]]];
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
  positiveCompatibleQ, simultaneouslyAdmissibleSubsetQ];
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
  degs = Total[Exponent[#, df]] & /@ ml;
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

(* Feasibility test: can C == 0 be solved with all x_i > 0 and kinematics? *)
positiveCompatibleQ[C_, vars_, kinAssumptions_, kinVars_] := Module[{test},
  test = Reduce[
    kinAssumptions && C == 0 && And @@ Thread[vars > 0],
    Join[vars, kinVars],
    Reals
    ];
  test =!= False
  ];

(* PDF (5.12): a subset S = {f1,...,fr} is admissible when all factors can
   vanish simultaneously with positive Lee--Pomeransky parameters and s in K.
   Individual positiveCompatibleQ tests are necessary but not sufficient. *)
simultaneouslyAdmissibleSubsetQ[factors_List, vars_, kinAssumptions_, kinVars_] := Module[
  {ff = DeleteDuplicates[Flatten[{factors}]], test},
  Which[
    ff === {}, True,
    Length[ff] == 1, positiveCompatibleQ[First[ff], vars, kinAssumptions, kinVars],
    True,
    test = Quiet[
      Reduce[
        kinAssumptions &&
          And @@ Thread[vars > 0] &&
          And @@ (Expand[#] == 0 & /@ ff),
        Join[vars, kinVars],
        Reals
      ],
      {Reduce::ratnz, Reduce::inex, Reduce::na}
    ];
    test =!= False
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

ClearAll[obstructionByOriginalTermsGeneral, pairSectorGenerators,
  factorsDividingGenerator, generatorSetFactorUnion, generatorSetAdmissibilityData,
  slSectorAdmissibilityData, candidateGeneratorSets, candidateGeneratorSetsDiagnostic,
  generatorFactorData, admissibleGeneratorSetQ, generatorUseData, generatorSetScore, findObstructions, findObstructionsDebug,
  obstructionGeneratorDiagnostic];

(* obstructionByOriginalTermsGeneral[F, generators, vars, kinVars, maxSize]
   searches for a subset of original monomials of F whose removal makes the
   remainder lie in the ideal generated by 'generators'.
   Returns an Association with keys "Obstruction", "Superleading", etc.,
   or Missing[...] if none is found. *)
obstructionByOriginalTermsGeneral[F_, generators_, vars_, kinVars_, maxSize_ : 8] :=
 Module[{terms, allVars, b, rem, coeffs, sol, selected, Fobst, Fsl},
  terms = List @@ Expand[F];
  If[terms === {} || terms === {0}, Return[Missing["ZeroOrUndefinedPolynomial"]]];
  If[generators === {}, Return[Missing["NoGenerators"]]];

  allVars = DeleteDuplicates@Join[vars, kinVars];
  b = Array[bb, Length[terms]];

  rem = PolynomialReduce[Expand[F - Total[b terms]], generators, allVars][[2]];
  coeffs = Values[CoefficientRules[Expand[rem], allVars]];

  sol = FindInstance[
    Join[Thread[coeffs == 0], Thread[0 <= b <= 1],
     {Element[b, Integers], Total[b] <= maxSize}],
    b,
    Integers
    ];

  If[sol === {}, Return[Missing["NoObstructionFound", maxSize]]];

  selected = Flatten@Position[b /. First[sol], 1];
  Fobst = Factor[Total[terms[[selected]]] /. backRules];
  Fsl = Factor[Expand[(F - Total[terms[[selected]]]) /. backRules]];

  <|
   "Indices" -> selected,
   "ObstructionTerms" -> terms[[selected]],
   "Obstruction" -> Fobst,
   "Superleading" -> Fsl,
   "Complement" -> Fsl,
   "Generators" -> Factor /@ generators
   |>
  ];


(* Diagnostic variant of obstructionByOriginalTermsGeneral.  It returns both the
   usual result and compact information about why a generator set was accepted
   or rejected by the obstruction search.  This does not change the mathematics;
   it only exposes the intermediate data. *)
obstructionByOriginalTermsGeneralDiagnosticCore[F_, generators_, vars_, kinVars_, maxSize_ : 8, channelTag_ : "OriginalChannelBasis", backRules_ : {}] :=
 Module[{terms, allVars, b, rem, coeffs, sol, selected, Fobst, Fsl, result, reason},
  terms = List @@ Expand[F];
  If[terms === {} || terms === {0},
   Return[<|
     "Result" -> Missing["ZeroOrUndefinedPolynomial"],
     "AttemptData" -> <|
       "GeneratorSet" -> Factor /@ generators,
       "GeneratorCount" -> Length[generators],
       "TermCount" -> 0,
       "MaxObstructionTerms" -> maxSize,
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
       "MaxObstructionTerms" -> maxSize,
       "ChannelBasis" -> channelTag,
       "AcceptedQ" -> False,
       "RejectedReason" -> "NoGenerators"
       |>
     |>]
   ];

  allVars = DeleteDuplicates@Join[vars, kinVars];
  b = Array[bb, Length[terms]];
  rem = PolynomialReduce[Expand[F - Total[b terms]], generators, allVars][[2]];
  coeffs = Values[CoefficientRules[Expand[rem], allVars]];

  sol = FindInstance[
    Join[Thread[coeffs == 0], Thread[0 <= b <= 1],
     {Element[b, Integers], Total[b] <= maxSize}],
    b,
    Integers
    ];

  If[sol === {},
   Return[<|
     "Result" -> Missing["NoObstructionFound", maxSize],
     "AttemptData" -> <|
       "GeneratorSet" -> Factor /@ generators,
       "GeneratorCount" -> Length[generators],
       "TermCount" -> Length[terms],
       "MaxObstructionTerms" -> maxSize,
       "ChannelBasis" -> channelTag,
       "GenericRemainderTermCount" -> Length[List @@ Expand[rem]],
       "CoefficientEquationCount" -> Length[coeffs],
       "SelectedTermIndices" -> {},
       "AcceptedQ" -> False,
       "RejectedReason" -> "No binary obstruction subset solves the remainder equations within maxSize"
       |>
     |>]
   ];

  selected = Flatten@Position[b /. First[sol], 1];
  Fobst = Factor[Total[terms[[selected]]] /. backRules];
  Fsl = Factor[Expand[(F - Total[terms[[selected]]]) /. backRules]];
  result = <|
    "Indices" -> selected,
    "ObstructionTerms" -> terms[[selected]],
    "Obstruction" -> Fobst,
    "Superleading" -> Fsl,
    "Complement" -> Fsl,
    "Generators" -> Factor /@ generators
    |>;
  <|
   "Result" -> result,
   "AttemptData" -> <|
     "GeneratorSet" -> Factor /@ generators,
     "GeneratorCount" -> Length[generators],
     "TermCount" -> Length[terms],
     "MaxObstructionTerms" -> maxSize,
     "ChannelBasis" -> channelTag,
     "GenericRemainderTermCount" -> Length[List @@ Expand[rem]],
     "CoefficientEquationCount" -> Length[coeffs],
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
ClearAll[hrfNonzeroObstructionResultQ, obstructionByOriginalTermsGeneralDiagnostic];
hrfNonzeroObstructionResultQ[res_] := AssociationQ[res] &&
  KeyExistsQ[res, "Superleading"] &&
  Expand[Lookup[res, "Superleading", 0]] =!= 0;

obstructionByOriginalTermsGeneralDiagnostic[F_, generators_, vars_, kinVars_, maxSize_ : 8] :=
 Module[{attempts, eta, k1, k2, best, accepted},
  attempts = {obstructionByOriginalTermsGeneralDiagnosticCore[F, generators, vars, kinVars, maxSize,
      "OriginalChannelBasis", {}]};
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
     ToString[{k1, k1 + k2}, InputForm], {eta -> k1 + k2}]
    ];

   eta = Unique["hrfChannelSum$"];
   AppendTo[attempts,
    obstructionByOriginalTermsGeneralDiagnosticCore[
     Expand[F /. k1 -> eta - k2], generators, vars, {k2, eta}, maxSize,
     ToString[{k2, k1 + k2}, InputForm], {eta -> k1 + k2}]
    ];
   ];
  accepted = Select[attempts, hrfNonzeroObstructionResultQ[Lookup[#, "Result", Missing[]]] &];
  best = If[accepted =!= {}, First[accepted], First[attempts]];
  If[Length[attempts] > 1,
   best = Join[best, <|"ChannelObstructionAttempts" -> (Lookup[#, "AttemptData", <||>] & /@ attempts)|>]
   ];
  best
  ];

pairSectorGenerators[factors_] := Times @@@ Subsets[factors, {2}];

factorsDividingGenerator[gen_, ff_, allVars_] :=
  Select[ff, Quiet[PolynomialReduce[Expand[gen], {#}, allVars][[2]] === 0] &];

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
ClearAll[candidateGeneratorSets, candidateGeneratorSetsDiagnostic];

(* Default/collinear generator choice: one generator equal to product of all
   factors, but only when at least two f_k factors are present and the full
   subset is simultaneously admissible. *)
candidateGeneratorSets[factors_, vars_, kinAssumptions_, kinVars_] := Module[
  {ff = DeleteDuplicates[Factor /@ factors]},
  If[Length[ff] < 2, Return[{}]];
  If[simultaneouslyAdmissibleSubsetQ[ff, vars, kinAssumptions, kinVars],
    {{Times @@ ff}},
    {}
  ]
  ];

(* Diagnostic/crown-like generator sets: full product, all pair products, and
   collections of pair products up to maxGenerators.  Each pair product is kept
   only when its own two f_k are simultaneously admissible (per-generator
   rule).  Multi-generator combinations are NOT filtered by cross-generator
   union compatibility; that check is deferred to SL-sector confirmation. *)
candidateGeneratorSetsDiagnostic[factors_, maxGenerators_ : 2, vars_, kinAssumptions_, kinVars_] := Module[
  {ff, admissiblePairs, pairGens},
  ff = DeleteDuplicates[Factor /@ factors];
  If[Length[ff] < 2, Return[{}]];
  admissiblePairs = Select[Subsets[ff, {2}], simultaneouslyAdmissibleSubsetQ[#, vars, kinAssumptions, kinVars] &];
  pairGens = Times @@@ admissiblePairs;
  DeleteDuplicates @ Join[
    If[simultaneouslyAdmissibleSubsetQ[ff, vars, kinAssumptions, kinVars], {{Times @@ ff}}, {}],
    List /@ pairGens,
    Subsets[pairGens, {2, maxGenerators}]
  ]
  ];


(* Recover, for reporting, which cancellation factors divide each constructed
   generator and whether that factor subset satisfies the per-generator rules. *)
generatorFactorData[generators_, factors_, vars_, kinVars_, kinAssumptions_: True] := Module[{allVars, ff},
  allVars = DeleteDuplicates@Join[vars, kinVars];
  ff = DeleteDuplicates[Factor /@ factors];
  Table[
    Module[{fac = factorsDividingGenerator[gen, ff, allVars], simQ},
      simQ = simultaneouslyAdmissibleSubsetQ[fac, vars, kinAssumptions, kinVars];
      <|
        "Generator" -> Factor[gen],
        "GeneratorFactors" -> Factor /@ fac,
        "GeneratorFactorCount" -> Length[fac],
        "IndividuallyPositiveCompatibleQ" -> And @@ (positiveCompatibleQ[#, vars, kinAssumptions, kinVars] & /@ fac),
        "SimultaneouslyAdmissibleSubsetQ" -> simQ,
        "AdmissibleGeneratorQ" -> (Length[fac] >= 2 && simQ),
        "AdmissibilityRule" -> "Massless: >=2 f_k per generator and PDF (5.12) per-generator simultaneous admissibility"
      |>
    ],
    {gen, generators}
  ]
];

generatorSetFactorUnion[generators_, factors_, vars_, kinVars_] := Module[
  {allVars = DeleteDuplicates@Join[vars, kinVars], ff = DeleteDuplicates[Factor /@ factors]},
  DeleteDuplicates @ Flatten[
    factorsDividingGenerator[#, ff, allVars] & /@ generators
  ]
];

generatorSetAdmissibilityData[generators_, factors_, vars_, kinVars_, kinAssumptions_: True] := Module[
  {gd, unionFac, perGenQ, setQ},
  gd = generatorFactorData[generators, factors, vars, kinVars, kinAssumptions];
  unionFac = generatorSetFactorUnion[generators, factors, vars, kinVars];
  perGenQ = gd =!= {} && AllTrue[gd, TrueQ[Lookup[#, "AdmissibleGeneratorQ", False]] &];
  setQ = simultaneouslyAdmissibleSubsetQ[unionFac, vars, kinAssumptions, kinVars];
  <|
    "GeneratorFactorData" -> gd,
    "GeneratorSetFactorUnion" -> Factor /@ unionFac,
    "GeneratorSetFactorCount" -> Length[unionFac],
    "PerGeneratorAdmissibleQ" -> perGenQ,
    "SimultaneouslyAdmissibleGeneratorSetQ" -> setQ,
    "AdmissibleGeneratorSetQ" -> perGenQ,
    "GeneratorSetAdmissibilityRule" -> "Candidate stage: each generator has >=2 f_k and satisfies PDF (5.12) individually"
  |>
];

(* PDF (5.12) at SL-sector confirmation: only the generators that actually
   enter the confirmed F_SL are required to have jointly admissible f_k. *)
slSectorAdmissibilityData[FSL_, generators_, factors_, vars_, kinVars_, kinAssumptions_: True] := Module[
  {use, usedGens, usedData, unionFac, perGenQ, setQ},
  use = generatorUseData[FSL, generators, vars, kinVars];
  usedGens = Lookup[use, "UsedGenerators", {}];
  usedData = generatorFactorData[usedGens, factors, vars, kinVars, kinAssumptions];
  unionFac = generatorSetFactorUnion[usedGens, factors, vars, kinVars];
  perGenQ = usedData =!= {} && AllTrue[usedData, TrueQ[Lookup[#, "AdmissibleGeneratorQ", False]] &];
  setQ = Length[usedGens] >= 1 && simultaneouslyAdmissibleSubsetQ[unionFac, vars, kinAssumptions, kinVars];
  <|
    "GeneratorUseData" -> use,
    "SLSectorGenerators" -> Factor /@ usedGens,
    "SLSectorGeneratorCount" -> Length[usedGens],
    "SLSectorGeneratorFactorData" -> usedData,
    "SLSectorFactorUnion" -> Factor /@ unionFac,
    "SLSectorFactorCount" -> Length[unionFac],
    "PerGeneratorSLSectorAdmissibleQ" -> perGenQ,
    "SimultaneouslyAdmissibleSLSectorQ" -> setQ,
    "AdmissibleSLSectorQ" -> (perGenQ && setQ),
    "SLSectorAdmissibilityRule" -> "PDF (5.12): union of f_k in generators entering F_SL must be simultaneously admissible"
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

Options[findObstructions] = {
   "GeneratorMode" -> "SingleProduct",
   "MaxGenerators" -> 2,
   "UseExtendedFactors" -> False,
   "DimensionfulKinVars" -> Automatic
   };

(* Debug version: shows which factor finder is being used and what it returns. *)
findObstructionsDebug[F_, vars_, kinAssumptions_, kinVars_, maxSize_ : 8,
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
findObstructions[F_, vars_, kinAssumptions_, kinVars_, maxSize_ : 8,
   OptionsPattern[]] :=
 Module[{factorData, safeFactors, factorsByDerivative, appearsIn,
   generatorSets, trials, admissibleTrials, validTrials, best, use},

  hrfDebugSay["findObstructions: start; vars=" <> ToString[Length[vars]] <>
    ", maxSize=" <> ToString[maxSize] <> ", mode=" <> ToString[OptionValue["GeneratorMode"]] <>
    ", extended=" <> ToString[OptionValue["UseExtendedFactors"]]];

  factorData = hrfDebugTimed["findObstructions/factor finder",
    If[TrueQ[OptionValue["UseExtendedFactors"]],
      safeCancellationFactorsExtended[F, vars, kinAssumptions, kinVars,
        OptionValue["DimensionfulKinVars"]],
      safeCancellationFactors[F, vars, kinAssumptions, kinVars]
    ]
  ];

  {safeFactors, factorsByDerivative} = factorData;
  hrfDebugSay["findObstructions: cancellation factors=" <> ToString[Length[safeFactors]]];

  appearsIn = Association[
    Table[C -> Select[Keys[factorsByDerivative], MemberQ[factorsByDerivative[#], C] &],
     {C, safeFactors}]
    ];

  generatorSets = hrfDebugTimed["findObstructions/generator-set construction",
    Switch[OptionValue["GeneratorMode"],
      "SingleProduct", candidateGeneratorSets[safeFactors, vars, kinAssumptions, kinVars],
      "PairSectors", candidateGeneratorSetsDiagnostic[safeFactors, OptionValue["MaxGenerators"], vars, kinAssumptions, kinVars],
      _, candidateGeneratorSets[safeFactors, vars, kinAssumptions, kinVars]
    ]
  ];
  hrfDebugSay["findObstructions: generator sets=" <> ToString[Length[generatorSets]]];

  trials = Table[
    If[TrueQ[$HRFDebugTiming] && (i == 1 || i == Length[generatorSets] || Mod[i, $HRFDebugProgressEvery] == 0),
      hrfDebugSay["findObstructions: trial " <> ToString[i] <> "/" <> ToString[Length[generatorSets]]]
    ];
    Module[{obsDiag, obs, setData, slData, perGenQ, admissibleQ, attemptData},
     setData = generatorSetAdmissibilityData[generatorSets[[i]], safeFactors, vars, kinVars, kinAssumptions];
     perGenQ = TrueQ[Lookup[setData, "PerGeneratorAdmissibleQ", False]];
     obsDiag = If[perGenQ,
       hrfDebugTimed["findObstructions/trial " <> ToString[i] <> " obstruction test",
         obstructionByOriginalTermsGeneralDiagnostic[F, generatorSets[[i]], vars, kinVars, maxSize]
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
     slData = If[hrfNonzeroObstructionResultQ[obs],
       slSectorAdmissibilityData[obs["Superleading"], generatorSets[[i]], safeFactors, vars, kinVars, kinAssumptions],
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
          hrfNonzeroObstructionResultQ[obs] && ! admissibleQ,
            <|"RejectedReason" -> "Confirmed F_SL failed PDF (5.12) on generators entering the sector"|>,
          True, <||>
        ],
        If[KeyExistsQ[obsDiag, "ChannelObstructionAttempts"], <|"ChannelObstructionAttempts" -> obsDiag["ChannelObstructionAttempts"]|>, <||>]]
       ];
     <|"Generators" -> generatorSets[[i]],
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
       "ObstructionAttemptData" -> attemptData,
       "GeneratorAdmissibility" -> If[admissibleQ,
         slData["SLSectorAdmissibilityRule"],
         If[perGenQ, setData["GeneratorSetAdmissibilityRule"], "Per-generator admissibility failed"]
       ]|>
     ],
    {i, Length[generatorSets]}
    ];

  admissibleTrials = Select[trials,
    TrueQ[Lookup[#, "AdmissibleSLSectorQ", False]] &
    ];
  hrfDebugSay["findObstructions: SL-sector admissible trials=" <> ToString[Length[admissibleTrials]]];

  validTrials = Select[admissibleTrials,
      AssociationQ[# ["ObstructionData"]] &&
      KeyExistsQ[# ["ObstructionData"], "Superleading"] &&
      Expand[Lookup[# ["ObstructionData"], "Superleading", 0]] =!= 0 &
    ];
  hrfDebugSay["findObstructions: obstruction trials=" <> ToString[Length[validTrials]]];

  best = Which[
    validTrials =!= {},
      First@SortBy[validTrials, generatorSetScore[# ["ObstructionData"]] &],
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

  <|
   "CancellationFactors" -> safeFactors,
   "AppearsInDerivatives" -> appearsIn,
   "CandidateGeneratorSets" -> generatorSets,
   "CandidateGeneratorCount" -> Length[generatorSets],
   "CandidateGeneratorFactorData" -> (generatorSetAdmissibilityData[#, safeFactors, vars, kinVars, kinAssumptions] & /@ generatorSets),
   "AdmissibleCandidateGeneratorSetQ" -> (admissibleTrials =!= {}),
   "AdmissibleCandidateGeneratorSets" -> (Lookup[#, "Generators", {}] & /@ admissibleTrials),
   "AdmissibleCandidateGeneratorFactorData" -> (Lookup[#, "GeneratorFactorData", {}] & /@ admissibleTrials),
   "AdmissibleCandidateGeneratorSetFactorUnions" -> (Lookup[#, "SLSectorFactorUnion", {}] & /@ admissibleTrials),
   "ObstructionAttemptData" -> (Lookup[#, "ObstructionAttemptData", <||>] & /@ trials),
   "AdmissibleObstructionAttemptData" -> (Lookup[#, "ObstructionAttemptData", <||>] & /@ admissibleTrials),
   "AcceptedObstructionAttemptData" -> Lookup[best, "ObstructionAttemptData", <||>],
   "ObstructionAttemptCount" -> Length[trials],
   "Generators" -> best["Generators"],
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
 Module[{safeFactors, factorsByDerivative, appearsIn, generatorSets, trials},
  {safeFactors, factorsByDerivative} =
   safeCancellationFactorsExtended[F, vars, kinAssumptions, kinVars, dimensionfulSpec];
  appearsIn = Association[
    Table[C -> Select[Keys[factorsByDerivative], MemberQ[factorsByDerivative[#], C] &],
     {C, safeFactors}]
    ];
  generatorSets = candidateGeneratorSetsDiagnostic[safeFactors, maxGenerators, vars, kinAssumptions, kinVars];
  trials = Table[
    Module[{obs, use, setData, slData, perGenQ, admissibleQ},
     setData = generatorSetAdmissibilityData[generatorSets[[i]], safeFactors, vars, kinVars, kinAssumptions];
     perGenQ = TrueQ[Lookup[setData, "PerGeneratorAdmissibleQ", False]];
     obs = If[perGenQ,
       obstructionByOriginalTermsGeneral[F, generatorSets[[i]], vars, kinVars, maxSize],
       Missing["InadmissibleGeneratorSet"]
       ];
     slData = If[hrfNonzeroObstructionResultQ[obs],
       slSectorAdmissibilityData[obs["Superleading"], generatorSets[[i]], safeFactors, vars, kinVars, kinAssumptions],
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
   "CandidateGeneratorFactorData" -> (generatorSetAdmissibilityData[#, safeFactors, vars, kinVars, kinAssumptions] & /@ generatorSets),
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

monomialWeight[term_, vars_, v_] := Exponent[term, vars].v;

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
  DeleteDuplicates@Flatten[Table[Pick[vars, Exponent[t, vars], _?(# > 0 &)], {t, terms}]]
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
  lpVars = DeleteDuplicates@Flatten[Table[Pick[vars, Exponent[t, vars], _?(# > 0 &)], {t, lpTerms}]];
  fSLVars = DeleteDuplicates@Flatten[Table[Pick[vars, Exponent[t, vars], _?(# > 0 &)], {t, fSLTerms}]];
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
ClearAll[hrfNormalizeScalingVector, hrfHomogeneousScalingCandidates];

hrfNormalizeScalingVector[v_List] := Module[{g = GCD @@ DeleteCases[Abs[v], 0]},
  If[g === 0 || g === GCD[], v, v/g]
];

hrfHomogeneousScalingCandidates[fSLRows_, nvars_Integer, maxAbs_Integer] := Module[
  {rows, base, mat, rr, nzRows, pivotCols, freeCols, d, freeTuples, tupleCount,
   bruteCount, freeVarsLimit, candidates, makeVector, normCandidates},
  rows = DeleteDuplicates[Join @@ fSLRows];
  If[rows === {}, Return[{}]];
  base = First[rows];
  mat = ((# - base) & /@ Rest[rows]);
  bruteCount = (maxAbs + 1)^nvars - 1;
  freeVarsLimit = If[ValueQ[$HRFScalingFreeTupleEnumerationLimit], $HRFScalingFreeTupleEnumerationLimit, 2000000];

  Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
    "  [coverage candidate generation start] method=FSLNullspaceRREF vars=" <> ToString[nvars] <>
    " maxAbs=" <> ToString[maxAbs] <>
    " monomialRows=" <> ToString[Length[rows]] <>
    " equations=" <> ToString[Length[mat]] <>
    " bruteBox=" <> ToString[bruteCount]];

  (* Risk-free reduction: row-reduce the linear homogeneity equations
     (m_i-m_1).alpha=0.  We enumerate only the free ORIGINAL coordinates,
     each of which is genuinely bounded by -maxAbs <= alpha_i <= 0, and then
     reconstruct the pivot coordinates.  This is equivalent to the full box
     scan but avoids materialising (maxAbs+1)^n candidates. *)
  rr = If[mat === {}, {}, RowReduce[mat]];
  nzRows = Select[rr, ! AllTrue[#, PossibleZeroQ] &];
  pivotCols = If[nzRows === {}, {},
    (First@FirstPosition[#, x_ /; ! PossibleZeroQ[x], Missing["NoPivot"]] &) /@ nzRows
  ];
  pivotCols = DeleteCases[pivotCols, _Missing];
  freeCols = Complement[Range[nvars], pivotCols];
  d = Length[freeCols];
  tupleCount = (maxAbs + 1)^d - 1;

  Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
    "  [coverage nullspace rref] rank=" <> ToString[Length[pivotCols]] <>
    " freeCoordinates=" <> ToString[d] <>
    " freeTupleBox=" <> ToString[tupleCount]];

  If[tupleCount > freeVarsLimit,
    Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
      "  [coverage candidate generation large] free tuple box=" <> ToString[tupleCount] <>
      " exceeds limit=" <> ToString[freeVarsLimit] <>
      "; testing universal all-minus-one candidate first"];
    (* Do not abort outright.  The Crown and several inherited massless regions
       have the symmetric scaling alpha_i=-1 for all active variables.  Returning
       this seed keeps the scaling test informative even when the full free-coordinate
       box would be too large to enumerate.  Larger searches can still be enabled by
       increasing $HRFScalingFreeTupleEnumerationLimit. *)
    Return[{ConstantArray[-1, nvars]}]
  ];

  makeVector[freeVals_List] := Module[{v, row, pc, rhs},
    v = ConstantArray[0, nvars];
    Do[v[[freeCols[[j]]]] = freeVals[[j]], {j, Length[freeCols]}];
    Do[
      row = nzRows[[i]];
      pc = pivotCols[[i]];
      rhs = -Total[row[[freeCols]]*v[[freeCols]]]/row[[pc]];
      v[[pc]] = rhs,
      {i, Length[nzRows]}
    ];
    v
  ];

  freeTuples = If[d == 0, {{}}, Select[Tuples[Range[-maxAbs, 0], d], Min[#] < 0 &]];
  candidates = makeVector /@ freeTuples;
  candidates = Select[candidates,
    VectorQ[#, IntegerQ] && Length[#] == nvars && Min[#] < 0 &&
      (And @@ Thread[-maxAbs <= #]) && (And @@ Thread[# <= 0]) &
  ];
  (* When every FSL-homogeneity coordinate is determined (d=0), do not assume the
     Crown symmetric seed {-1,...,-1}.  Five-point hidden regions need heterogeneous
     vectors such as {-2,-1,-2,-2,-2,-1,-2}; enumerate the actual nullspace line. *)
  If[d == 0 && mat =!= {},
    Module[{ns, dir, den, ks},
      ns = NullSpace[mat];
      If[ns =!= {},
        dir = Rationalize[First[ns], 0];
        den = LCM @@ Denominator[dir];
        dir = Round[dir den];
        dir = If[GCD @@ DeleteCases[Abs[dir], 0] === 0, dir, dir/GCD @@ DeleteCases[Abs[dir], 0]];
        If[VectorQ[dir, IntegerQ] && Min[dir] < 0,
          ks = Select[Range[-maxAbs, 0],
            VectorQ[# dir, IntegerQ] && Min[# dir] < 0 &&
              And @@ Thread[-maxAbs <= # dir <= 0] &
          ];
          candidates = Union[candidates, DeleteDuplicates[# dir & /@ ks]]
        ]
      ]
    ]
  ];
  (* Retain the symmetric massless seed as an extra candidate for 2-to-2 examples. *)
  candidates = Join[{ConstantArray[-1, nvars]}, candidates];
  normCandidates = DeleteDuplicatesBy[candidates, hrfNormalizeScalingVector];

  Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
    "  [coverage candidates] method=FSLNullspaceRREF candidateCount=" <> ToString[Length[normCandidates]] <>
    " rawCandidateCount=" <> ToString[Length[candidates]] <>
    " bruteBox=" <> ToString[bruteCount]];
  normCandidates
];

findCoverageLPScaling[fSL_, U_, vars_, maxAbs_ : 5, fObs_ : None] := Module[
  {fSLList, fObsList, fSLRows, URows, fObsRows, candidates, bruteCount,
   accepted, nearMisses, best, nvars, diag, sortKey, maxReport = 20},
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
  If[! ListQ[candidates],
    Return[<|"Scaling" -> candidates,
      "CandidateGenerationMethod" -> "FSLNullspaceRREF",
      "CandidateCount" -> Missing["NotGenerated"],
      "BackupBruteForceCandidateCount" -> bruteCount,
      "AcceptedCount" -> 0,
      "UniqueAcceptedScalingQ" -> False,
      "AcceptedScalingVectors" -> {},
      "Status" -> "CandidateGenerationDidNotComplete",
      "Diagnostics" -> {}|>]
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
   Print[DateString[{"Hour", ":", "Minute", ":", "Second"}] <>
     "  [coverage fallback] fast nullspace accepted=0 candidates=" <> ToString[Length[candidates]] <>
     "; running brute-force scan"];
   Return @ Join[
     findCoverageLPScalingScan[fSL, U, vars, maxAbs, fObs],
     <|
       "FastNullspaceCandidateCount" -> Length[candidates],
       "FastNearMissDiagnostics" -> Take[nearMisses, UpTo[maxReport]]
     |>
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
   <|"Scaling" -> best["ScalingVector"],
     "CandidateGenerationMethod" -> "FSLNullspaceRREF",
     "CandidateCount" -> Length[candidates],
     "BackupBruteForceCandidateCount" -> bruteCount,
     "AcceptedCount" -> Length[accepted],
     "AcceptedScalingVectors" -> Lookup[accepted, "ScalingVector", {}],
     "UniqueAcceptedScalingQ" -> (Length[DeleteDuplicates[Lookup[accepted, "ScalingVector", {}]]] == 1),
     "SelectedCandidateDiagnostic" -> Join[best, <|"WSL" -> best["FSLWeight"], "WHR" -> best["PostCancellationLeadingWeight"]|>],
     "Criteria" -> <|
       "FSLCancellation" -> "all monomials in F_SL must have a common weight before cancellation",
       "HiddenHierarchy" -> "that common F_SL weight must be more singular than the first surviving weight of U + F_obs",
       "Coverage" -> "active variables must be covered by F_SL monomials at W_SL or surviving monomials of U + F_obs at W_HR",
       "UnitGap" -> "reported but not imposed"|>,
     "AcceptedCandidateDiagnostics" -> Take[accepted, UpTo[maxReport]],
     "NearMissDiagnostics" -> Take[nearMisses, UpTo[maxReport]],
     "Diagnostics" -> scalingDiagnostic[fSL, U, vars, best["ScalingVector"], fObs]|>
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
    <|"Scaling" -> Missing["NoPostCancellationCoverageScalingFoundUpTo", maxAbs], "CandidateGenerationMethod" -> "BruteForceScan", "CandidateCount" -> Length[candidates], "AcceptedCount" -> 0, "AcceptedCandidateDiagnostics" -> {}, "NearMissDiagnostics" -> Take[nearMisses, UpTo[maxReport]], "Diagnostics" -> {}|>,
    best = First[accepted];
    <|"Scaling" -> best["ScalingVector"], "CandidateGenerationMethod" -> "BruteForceScan", "CandidateCount" -> Length[candidates], "AcceptedCount" -> Length[accepted], "AcceptedScalingVectors" -> Lookup[accepted, "ScalingVector", {}], "UniqueAcceptedScalingQ" -> (Length[DeleteDuplicates[Lookup[accepted, "ScalingVector", {}]]] == 1), "SelectedCandidateDiagnostic" -> Join[best, <|"WSL" -> best["FSLWeight"], "WHR" -> best["PostCancellationLeadingWeight"]|>], "AcceptedCandidateDiagnostics" -> Take[accepted, UpTo[maxReport]], "NearMissDiagnostics" -> Take[nearMisses, UpTo[maxReport]], "Diagnostics" -> scalingDiagnostic[fSL, U, vars, best["ScalingVector"], fObs]|>
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

ClearAll[boundarySubsets, restrictPolynomialToBoundary,
  findObstructionsOnBoundaries4pt, interestingBoundaryQ4pt,
  summarizeBoundaryScan4pt, scanInterestingBoundariesOnly4pt];

boundarySubsets[vars_, maxCodim_] :=
 Join[{{}}, Flatten[Table[Subsets[vars, {k}], {k, 1, maxCodim}], 1]];

restrictPolynomialToBoundary[F_, vars_, zeroVars_] := Module[{remainingVars, Frestricted},
  remainingVars = Complement[vars, zeroVars];
  Frestricted = Factor[Expand[F /. Thread[zeroVars -> 0]]];
  <|"ZeroVars" -> zeroVars, "RemainingVars" -> remainingVars,
   "FRestricted" -> Frestricted|>
  ];

findObstructionsOnBoundaries4pt[F_, vars_, kinAssumptions_, kinVars_,
   maxCodim_ : 2, maxSize_ : 8, maxGenerators_ : 2] :=
 Module[{strata},
  strata = boundarySubsets[vars, maxCodim];
  Table[
   Module[{res, obs},
    res = restrictPolynomialToBoundary[F, vars, strata[[i]]];
    obs = If[res["FRestricted"] === 0 || Length[res["RemainingVars"]] == 0,
      Missing["TrivialBoundary"],
      findObstructions[res["FRestricted"], res["RemainingVars"],
       kinAssumptions, kinVars, maxSize,
       "GeneratorMode" -> "PairSectors", "UseExtendedFactors" -> True,
       "MaxGenerators" -> maxGenerators]
      ];
    <|
     "ZeroVars" -> res["ZeroVars"],
     "RemainingVars" -> res["RemainingVars"],
     "FRestricted" -> res["FRestricted"],
     "ObstructionScan" -> obs
     |>
    ],
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
 Module[{strata, out = {}, res, obs, entry},
  strata = boundarySubsets[vars, maxCodim];
  Do[
   res = restrictPolynomialToBoundary[F, vars, strata[[i]]];
   If[res["FRestricted"] =!= 0 && Length[res["RemainingVars"]] > 0,
    obs = findObstructions[res["FRestricted"], res["RemainingVars"],
      kinAssumptions, kinVars, maxSize,
      "GeneratorMode" -> "PairSectors", "UseExtendedFactors" -> True,
      "MaxGenerators" -> maxGenerators];
    entry = <|
      "Index" -> i,
      "ZeroVars" -> res["ZeroVars"],
      "Codimension" -> Length[res["ZeroVars"]],
      "RemainingVars" -> res["RemainingVars"],
      "FRestricted" -> res["FRestricted"],
      "ObstructionScan" -> obs
      |>;
    If[interestingBoundaryQ4pt[entry], AppendTo[out, entry]];
    ];,
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
