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
       findObstructions
       obstructionGeneratorDiagnostic
       findMinimalLPScaling
       findObstructionsOnBoundaries4pt / scanInterestingBoundariesOnly4pt
*)

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
  kinematicCoefficientFactors, derivativeFactorsExtended,
  positiveCompatibleQ, safeCancellationFactors, safeCancellationFactorsExtended];

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

(* Additional factors obtained from coefficients of independent kinematic
   variables in derivative polynomials. This is needed for crown-like cases. *)
kinematicCoefficientFactors[F_, vars_, kinVars_] := Association[
   Table[
    v -> DeleteDuplicates[
      Flatten[
       Table[
        Module[{coeff, fl},
         coeff = Coefficient[Expand[D[F, v]], k];
         If[coeff === 0,
          {},
          fl = FactorList[Factor[coeff]][[All, 1]];
          Select[fl, # =!= 1 && # =!= -1 && ! monomialQ[#, vars] &]
          ]
         ],
        {k, kinVars}
        ]
       ]
      ],
    {v, vars}
    ]
   ];

(* Union of derivative factors and kinematic-coefficient factors. *)
derivativeFactorsExtended[F_, vars_, kinVars_] := Module[{ordinary, byKin},
  ordinary = derivativeFactors[F, vars];
  byKin = kinematicCoefficientFactors[F, vars, kinVars];
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
safeCancellationFactorsExtended[F_, vars_, kinAssumptions_, kinVars_] :=
 Module[{factorsByDerivative, allFactors, safeFactors},
  factorsByDerivative = derivativeFactorsExtended[F, vars, kinVars];
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
  candidateGeneratorSets, candidateGeneratorSetsDiagnostic,
  generatorUseData, generatorSetScore, findObstructions, findObstructionsDebug,
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
  Fobst = Factor[Total[terms[[selected]]]];
  Fsl = Factor[Expand[F - Total[terms[[selected]]]]];

  <|
   "Indices" -> selected,
   "ObstructionTerms" -> terms[[selected]],
   "Obstruction" -> Fobst,
   "Superleading" -> Fsl,
   "Complement" -> Fsl,
   "Generators" -> Factor /@ generators
   |>
  ];

pairSectorGenerators[factors_] := Times @@@ Subsets[factors, {2}];

(* Default/collinear generator choice: one generator equal to product of all factors. *)
candidateGeneratorSets[factors_] := Module[{oldStyle},
  If[factors === {}, Return[{}]];
  oldStyle = {Times @@ factors};
  {oldStyle}
  ];

(* Diagnostic/crown-like generator sets: full product, all pair products, and
   collections of pair products up to maxGenerators. *)
candidateGeneratorSetsDiagnostic[factors_, maxGenerators_ : 2] := Module[{pairs},
  If[factors === {}, Return[{}]];
  pairs = pairSectorGenerators[factors];
  DeleteDuplicates[Join[{{Times @@ factors}}, List /@ pairs,
    Subsets[pairs, {2, maxGenerators}]]]
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
   "UseExtendedFactors" -> False
   };

(* Debug version: shows which factor finder is being used and what it returns. *)
findObstructionsDebug[F_, vars_, kinAssumptions_, kinVars_, maxSize_ : 8,
   OptionsPattern[findObstructions]] :=
 <|
  "UseExtendedFactors" -> OptionValue["UseExtendedFactors"],
  "GeneratorMode" -> OptionValue["GeneratorMode"],
  "MaxGenerators" -> OptionValue["MaxGenerators"],
  "FactorData" -> If[TrueQ[OptionValue["UseExtendedFactors"]],
    safeCancellationFactorsExtended[F, vars, kinAssumptions, kinVars],
    safeCancellationFactors[F, vars, kinAssumptions, kinVars]]
  |>;

(* Main obstruction finder.
   Output Association keys:
     "CancellationFactors", "AppearsInDerivatives", "Generators",
     "ObstructionData", "GeneratorUseData". *)
findObstructions[F_, vars_, kinAssumptions_, kinVars_, maxSize_ : 8,
   OptionsPattern[]] :=
 Module[{factorData, safeFactors, factorsByDerivative, appearsIn,
   generatorSets, trials, validTrials, best, use},

  factorData = If[TrueQ[OptionValue["UseExtendedFactors"]],
    safeCancellationFactorsExtended[F, vars, kinAssumptions, kinVars],
    safeCancellationFactors[F, vars, kinAssumptions, kinVars]
    ];

  {safeFactors, factorsByDerivative} = factorData;

  appearsIn = Association[
    Table[C -> Select[Keys[factorsByDerivative], MemberQ[factorsByDerivative[#], C] &],
     {C, safeFactors}]
    ];

  generatorSets = Switch[OptionValue["GeneratorMode"],
    "SingleProduct", candidateGeneratorSets[safeFactors],
    "PairSectors", candidateGeneratorSetsDiagnostic[safeFactors, OptionValue["MaxGenerators"]],
    _, candidateGeneratorSets[safeFactors]
    ];

  trials = Table[
    Module[{obs},
     obs = obstructionByOriginalTermsGeneral[F, generatorSets[[i]], vars, kinVars, maxSize];
     <|"Generators" -> generatorSets[[i]], "ObstructionData" -> obs|>
     ],
    {i, Length[generatorSets]}
    ];

  validTrials = Select[trials,
    AssociationQ[# ["ObstructionData"]] &&
      KeyExistsQ[# ["ObstructionData"], "Superleading"] &&
      # ["ObstructionData", "Superleading"] =!= 0 &
    ];

  best = If[validTrials === {},
    <|"Generators" -> {}, "ObstructionData" -> Missing["NoObstructionFound", maxSize]|>,
    First@SortBy[validTrials, generatorSetScore[# ["ObstructionData"]] &]
    ];

  use = If[AssociationQ[best["ObstructionData"]] &&
      KeyExistsQ[best["ObstructionData"], "Superleading"],
    generatorUseData[best["ObstructionData", "Superleading"], best["Generators"], vars, kinVars],
    Missing["NoUseData"]
    ];

  <|
   "CancellationFactors" -> safeFactors,
   "AppearsInDerivatives" -> appearsIn,
   "Generators" -> best["Generators"],
   "ObstructionData" -> best["ObstructionData"],
   "GeneratorUseData" -> use
   |>
  ];

(* Diagnostic scan over generator-set candidates. *)
obstructionGeneratorDiagnostic[F_, vars_, kinAssumptions_, kinVars_,
   maxSize_ : 8, maxGenerators_ : 2] :=
 Module[{safeFactors, factorsByDerivative, appearsIn, generatorSets, trials},
  {safeFactors, factorsByDerivative} =
   safeCancellationFactorsExtended[F, vars, kinAssumptions, kinVars];
  appearsIn = Association[
    Table[C -> Select[Keys[factorsByDerivative], MemberQ[factorsByDerivative[#], C] &],
     {C, safeFactors}]
    ];
  generatorSets = candidateGeneratorSetsDiagnostic[safeFactors, maxGenerators];
  trials = Table[
    Module[{obs, use},
     obs = obstructionByOriginalTermsGeneral[F, generatorSets[[i]], vars, kinVars, maxSize];
     use = If[AssociationQ[obs] && KeyExistsQ[obs, "Superleading"],
       generatorUseData[obs["Superleading"], generatorSets[[i]], vars, kinVars],
       Missing["NoUseData"]];
     <|
      "GeneratorSetIndex" -> i,
      "Generators" -> Factor /@ generatorSets[[i]],
      "ObstructionData" -> obs,
      "GeneratorUseData" -> use
      |>
     ],
    {i, Length[generatorSets]}
    ];
  <|
   "SafeFactors" -> safeFactors,
   "AppearsInDerivatives" -> appearsIn,
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
findCoverageLPScaling[fSL_, U_, vars_, maxAbs_ : 5, fObs_ : None] := Module[
  {fSLList, fObsList, fSLRows, URows, fObsRows, candidates, accepted,
   nearMisses, best, nvars, diag, sortKey, maxReport = 20},
  fSLList = DeleteCases[Flatten[{fSL}], 0];
  If[fSLList === {} || U === 0,
   Return[<|"Scaling" -> Missing["NoFSLOrU"], "Diagnostics" -> {}|>]
  ];
  fObsList = If[fObs === None, {}, DeleteCases[Flatten[{fObs}], 0]];
  fSLRows = polynomialExponentRows[#, vars] & /@ fSLList;
  URows = polynomialExponentRows[U, vars];
  fObsRows = polynomialExponentRows[#, vars] & /@ fObsList;
  If[MemberQ[fSLRows, {}] || URows === {},
   Return[<|"Scaling" -> Missing["EmptyExponentSupport"], "Diagnostics" -> {}|>]
  ];
  nvars = Length[vars];
  candidates = Select[Tuples[Range[-maxAbs, 0], nvars], Min[#] < 0 &];
  sortKey[a_Association] := With[{v = a["ScalingVector"], gap = a["HierarchyGapPostLPminusFSL"]},
    {If[TrueQ[a["UnitGapQ"]], 0, 1], Total[Abs[v]], Max[Abs[v]], -Replace[gap, _Missing -> -10^6], v}
  ];
  accepted = {};
  nearMisses = {};
  Do[
    diag = coverageConstraintDiagnosticFromRows[v, fSLRows, URows, fObsRows, vars];
    If[TrueQ[diag["AcceptedQ"]],
      AppendTo[accepted, diag],
      If[Length[diag["FailedConditions"]] <= 1, AppendTo[nearMisses, diag]]
    ],
    {v, candidates}
  ];
  accepted = SortBy[accepted, sortKey];
  nearMisses = SortBy[nearMisses, {Length[Lookup[#, "FailedConditions", {}]] &, Total[Abs[Lookup[#, "ScalingVector", {}]]] &, Max[Abs[Lookup[#, "ScalingVector", {0}]]] &}];
  If[accepted === {},
   <|"Scaling" -> Missing["NoPostCancellationCoverageScalingFoundUpTo", maxAbs],
     "CandidateCount" -> Length[candidates],
     "AcceptedCount" -> 0,
     "Criteria" -> <|
       "FSLCancellation" -> "all monomials in F_SL must have a common weight before cancellation",
       "HiddenHierarchy" -> "that common F_SL weight must be more singular than the first surviving weight of U + F_obs",
       "Coverage" -> "active variables must be covered by F_SL monomials at W_SL or surviving monomials of U + F_obs at W_HR",
       "UnitGap" -> "reported but not imposed"|>,
     "AcceptedCandidateDiagnostics" -> {},
     "NearMissDiagnostics" -> Take[nearMisses, UpTo[maxReport]],
     "Diagnostics" -> {}|>,
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
     "CandidateCount" -> Length[candidates],
     "AcceptedCount" -> Length[accepted],
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
