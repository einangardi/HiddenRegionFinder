$HistoryLength = 0;
base = DirectoryName[$InputFileName];
$HRF5WALandshoffAuditLibraryOnly = True;
Get[FileNameJoin[{base, "HRF_FivePointWideAngleLandshoffAllLayerAudit.wl"}]];
audit = hrf5WALandshoffAllLayerAudit[];
$HRF5WANearPlanarAlgorithmAuditLibraryOnly = True;
Get[FileNameJoin[{base, "HRF_FivePointNearPlanarAlgorithmAudit.wl"}]];
algorithmAudit = hrf5WANearPlanarAlgorithmAudit[];
algorithmSummary = algorithmAudit["Summary"];
$HRF5ComparisonLibraryOnly = True;
Get[FileNameJoin[{base, "HRF_FivePointWideAngleCentralSoftComparison.wl"}]];
centralSoftAudit = hrf5ComparisonCentralSoftAudit[];
centralSoftDirectory = FileNameJoin[{DirectoryName[base],
  "five_point_mrk_central_soft"}];
centralSoftTarget = Import[FileNameJoin[{centralSoftDirectory,
  "targeted_seed_2_exact-soft-plus_1_2.wl"}], "WL"];
centralSoftRow = First[centralSoftTarget["Scan", "HiddenRegionRows"]];
centralSoftCertificate = centralSoftRow["TotalScalingAudit"];
centralSoftPower = Import[FileNameJoin[{centralSoftDirectory,
  "five_point_mrk_corrected_power_counting_result.wl"}], "WL"];

ClearAll[txt, sec, subsec, outCell, displayCell, inCell, readableTable,
  inlineValue, saveNotebook, makeSeedAttachmentGraph];
txt[s_String] := Cell[s, "Text"];
sec[s_String] := Cell[s, "Section"];
subsec[s_String] := Cell[s, "Subsection"];
outCell[expr_] := Cell[BoxData @ ToBoxes[expr], "Output"];
displayCell[expr_] := Cell[BoxData @ ToBoxes[TraditionalForm[expr]], "Output"];
inCell[code_String] := Cell[
  BoxData @ ToExpression[code, InputForm, MakeBoxes], "Input"];
inlineValue[value_] := If[ListQ[value] || AssociationQ[value],
  Style[ToString[value, InputForm, PageWidth -> Infinity],
    FontFamily -> "Source Code Pro"], value];
readableTable[rows_List] := Module[{headers, body},
  headers = DeleteDuplicates @ Flatten[Keys /@ rows];
  body = (inlineValue /@ Lookup[#, headers, ""]) & /@ rows;
  Grid[Prepend[body, Style[#, Bold] & /@ headers], Frame -> All,
    Alignment -> Left, Spacings -> {1.0, 0.65},
    Background -> {None, {RGBColor[0.94, 0.96, 0.99], None}}]
];
saveNotebook[path_, nb_] := If[$FrontEnd =!= Null,
  obj = NotebookPut[nb, Visible -> False]; NotebookSave[obj, path];
  NotebookClose[obj, SaveRemaining -> False],
  Export[path, nb, "Notebook"]
];

makeSeedAttachmentGraph[swappedQ_, edgeNames_] := Graph[
  Join[
    {v1 <-> v3, v1 <-> v5, v2 <-> v3, v2 <-> v5,
      v3 <-> v4, v4 <-> v5, ep1 <-> v1, ep2 <-> v2,
      v3 <-> ep3},
    If[TrueQ[swappedQ], {v4 <-> ep5, v5 <-> ep4},
      {v4 <-> ep4, v5 <-> ep5}]
  ],
  VertexCoordinates -> {
    v1 -> {-1.15, -0.72}, v2 -> {-1.15, 0.72},
    v3 -> {0.25, 1.02}, v5 -> {0.25, -1.02},
    v4 -> {1.30, 0.0},
    ep1 -> {-2.35, -1.00}, ep2 -> {-2.35, 1.00},
    ep3 -> {1.42, 1.58}, ep4 -> {2.45, 0.0},
    ep5 -> {1.42, -1.58}
  },
  VertexLabels -> {
    ep1 -> Placed[Style[Subscript[p, 1], 14], Left],
    ep2 -> Placed[Style[Subscript[p, 2], 14], Left],
    ep3 -> Placed[Style[Subscript[p, 3], 14], Right],
    ep4 -> Placed[Style[Subscript[p, 4], 14], Right],
    ep5 -> Placed[Style[Subscript[p, 5], 14], Right]
  },
  EdgeLabels -> {
    (v1 <-> v3) -> Placed[Style[edgeNames[[1]], 13], 0.48],
    (v1 <-> v5) -> Placed[Style[edgeNames[[2]], 13], 0.25],
    (v2 <-> v3) -> Placed[Style[edgeNames[[3]], 13], 0.25],
    (v2 <-> v5) -> Placed[Style[edgeNames[[4]], 13], 0.48],
    (v3 <-> v4) -> Placed[Style[edgeNames[[5]], 13], 0.52],
    (v4 <-> v5) -> Placed[Style[edgeNames[[6]], 13], 0.52]
  },
  VertexSize -> {v1 -> .10, v2 -> .10, v3 -> .10, v4 -> .10, v5 -> .10,
    ep1 -> 0, ep2 -> 0, ep3 -> 0, ep4 -> 0, ep5 -> 0},
  EdgeStyle -> Directive[Black, Thick], ImageSize -> 430
];

canonicalGraph = makeSeedAttachmentGraph[False,
  Subscript[x, #] & /@ Range[6]];
analysisGraph = makeSeedAttachmentGraph[True, {x0, x1, x2, x3, x4, x5}];
graph = GraphicsRow[{
    Labeled[canonicalGraph,
      Style["Fig. 3 attachment  (1,2,3,4,5)", 13, Bold], Bottom],
    Labeled[analysisGraph,
      Style["near-planar / central-soft  (1,2,3,5,4)", 13, Bold], Bottom]
  }, ImageSize -> 980, Spacings -> 18];

local = audit["AllLayerDecomposition"];
locus = audit["LandauLocus"];
nearPlanar = audit["NearPlanarOnShell"];
scaling = nearPlanar["Scaling"];
facet = nearPlanar["FacetCertificate"];
power = nearPlanar["PowerCounting"];
momentum = power["MomentumSpace"];
coeff = local["PairProductCoefficients"];
symmetric = audit["InvariantSymmetricForm"];
fLocalSimple = qAB x5 yA yB + qBC x1 yB yC + qCA x3 yC yA;

pathRows = {
  <|"path" -> "A", "edge pair" -> "(x0,x1)",
    "middle external leg" -> "p1", "ratio" -> "rA=x0/x1"|>,
  <|"path" -> "B", "edge pair" -> "(x2,x3)",
    "middle external leg" -> "p2", "ratio" -> "rB=x2/x3"|>,
  <|"path" -> "C", "edge pair" -> "(x4,x5)",
    "middle external leg" -> "p5", "ratio" -> "rC=x4/x5"|>
};
attachmentRows = {
  <|"use" -> "spacelike-collinear / Fig. 3",
    "external labels at vertices (1,2,3,4,5)" -> "(1,2,3,4,5)"|>,
  <|"use" -> "near-planar and representative central-soft",
    "external labels at vertices (1,2,3,4,5)" -> "(1,2,3,5,4)"|>
};
edgeConventionRows = MapThread[
  <|"internal edge" -> #1, "Fig. 3 / paper label" -> #2,
    "code / this notebook" -> #3|> &,
  {{"(1,3)", "(1,5)", "(2,3)", "(2,5)", "(3,4)", "(4,5)"},
   {"x1", "x2", "x3", "x4", "x5", "x6"},
   {"x0", "x1", "x2", "x3", "x4", "x5"}}
];
physicalDomainRows = {
  <|"class" -> "incoming-incoming", "invariants" -> "s12", "sign" -> ">0"|>,
  <|"class" -> "outgoing-outgoing", "invariants" -> "s34, s45, s35", "sign" -> ">0"|>,
  <|"class" -> "incoming-outgoing", "invariants" ->
      "s23, s15, s13, s14, s24, s25", "sign" -> "<0"|>,
  <|"class" -> "non-coplanar interior", "invariants" -> "Gamma5=epsilon5^2",
    "sign" -> "Gamma5<0"|>,
  <|"class" -> "chosen orientation", "invariants" -> "epsilon5/i",
    "sign" -> ">0"|>
};
kinematicCoefficientRows = {
  <|"coefficient" -> qAB, "invariants" ->
      symmetric["QuadraticCoefficients", qAB]|>,
  <|"coefficient" -> qBC, "invariants" ->
      symmetric["QuadraticCoefficients", qBC]|>,
  <|"coefficient" -> qCA, "invariants" ->
      symmetric["QuadraticCoefficients", qCA]|>,
  <|"coefficient" -> ellA, "invariants" ->
      symmetric["LinearCoefficients", ellA]|>,
  <|"coefficient" -> ellB, "invariants" ->
      symmetric["LinearCoefficients", ellB]|>,
  <|"coefficient" -> ellC, "invariants" ->
      symmetric["LinearCoefficients", ellC]|>
};
factorizedGeneratorRows = {
  <|"generator" -> Subscript[G, AB], "factorized form" -> fA fB,
    "multiplier in F0" -> qAB x5|>,
  <|"generator" -> Subscript[G, BC], "factorized form" -> fB fC,
    "multiplier in F0" -> qBC x1|>,
  <|"generator" -> Subscript[G, CA], "factorized form" -> fC fA,
    "multiplier in F0" -> qCA x3|>
};
algorithmRows = {
  <|"certificate" -> "normal factors recovered",
    "value" -> algorithmSummary["CandidateSpecificNormalFactorCount"]|>,
  <|"certificate" -> "candidate generator-set histogram",
    "value" -> algorithmSummary["CandidateGeneratorCountHistogram"]|>,
  <|"certificate" -> "valid decompositions",
    "value" -> algorithmSummary["ValidDecompositionCount"]|>,
  <|"certificate" -> "generators in surviving set",
    "value" -> algorithmSummary["SelectedGeneratorCount"]|>,
  <|"certificate" -> "region vector (v0,...,v5)",
    "value" -> algorithmSummary["RegionVector"]|>,
  <|"certificate" -> "weights (WSL,WHR)",
    "value" -> {algorithmSummary["WSL"], algorithmSummary["WHR"]}|>,
  <|"certificate" -> "hidden region / truncated",
    "value" -> {algorithmSummary["HiddenRegionQ"],
      algorithmSummary["SearchTruncatedQ"]}|>
};
scalingRows = {
  <|"coordinates" -> "original (x0,x1,x2,x3,x4,x5; lambda)",
    "weights" -> "(-2,-2,-2,-2,-2,-2;1)"|>,
  <|"coordinates" -> "internal (x1,x3,x5)",
    "weights" -> "(-2,-2,-2)"|>,
  <|"coordinates" -> "path normals (fA,fB,fC)",
    "weights" -> "(-1,-1,-1)"|>,
  <|"coordinates" -> "raw F0 before cancellation", "weights" -> "W_SL=-6"|>,
  <|"coordinates" -> "resolved F0, U and lambda^2 Fperp",
    "weights" -> "W_HR=-4"|>
};
weightRows = {
  <|"source" -> "F0", "weight multiplicities" ->
      facet["WeightCountsBySource", "Fcop"],
    "terms on leading facet" -> facet["LeadingTermCountsBySource", "Fcop"]|>,
  <|"source" -> "U", "weight multiplicities" ->
      facet["WeightCountsBySource", "U"],
    "terms on leading facet" -> facet["LeadingTermCountsBySource", "U"]|>,
  <|"source" -> "lambda^2 Fperp", "weight multiplicities" ->
      facet["WeightCountsBySource", "lambdaPlanar^2 Fperp"],
    "terms on leading facet" ->
      facet["LeadingTermCountsBySource", "lambdaPlanar^2 Fperp"]|>
};
facetRows = {
  <|"test" -> "leading augmented points", "result" -> facet["LeadingPointCount"]|>,
  <|"test" -> "affine rank", "result" -> facet["AffineRank"],
    "required" -> facet["RequiredRank"]|>,
  <|"test" -> "normal-space dimension", "result" -> facet["NormalSpaceDimension"],
    "required" -> 1|>,
  <|"test" -> "inward normal", "result" -> facet["NormalizedInwardNormal"],
    "required" -> facet["CandidateNormal"]|>,
  <|"test" -> "all remaining monomials above or on facet",
    "result" -> facet["AllTermsAtOrAboveFacetQ"], "required" -> True|>,
  <|"test" -> "complete lower-facet certificate",
    "result" -> facet["LowerFacetCertifiedQ"], "required" -> True|>
};
momentumEdgeRows = {
  <|"edge" -> x0, "momentum" -> qA,
    "leading flow" -> xiA p1, "virtuality" -> "O(lambda^2 Q^2)"|>,
  <|"edge" -> x1, "momentum" -> qA - p1,
    "leading flow" -> -(1 - xiA) p1,
    "virtuality" -> "O(lambda^2 Q^2)"|>,
  <|"edge" -> x2, "momentum" -> qB,
    "leading flow" -> xiB p2, "virtuality" -> "O(lambda^2 Q^2)"|>,
  <|"edge" -> x3, "momentum" -> qB - p2,
    "leading flow" -> -(1 - xiB) p2,
    "virtuality" -> "O(lambda^2 Q^2)"|>,
  <|"edge" -> x4, "momentum" -> qC,
    "leading flow" -> xiC p5, "virtuality" -> "O(lambda^2 Q^2)"|>,
  <|"edge" -> x5, "momentum" -> qC - p5,
    "leading flow" -> -(1 - xiC) p5,
    "virtuality" -> "O(lambda^2 Q^2)"|>
};
powerComparisonRows = {
  <|"representation" -> "parameter space",
    "measure" -> "lambda^(-6) lambda^(-3)",
    "integrand" -> "P^(-D/2) ~ lambda^(2D)",
    "total" -> "lambda^(2D-9)"|>,
  <|"representation" -> "momentum space",
    "measure" -> "lambda^(2D) lambda^3",
    "integrand" -> "six propagators ~ lambda^(-12)",
    "total" -> "lambda^(2D-9)"|>
};
centralSoftMomentumRows = Map[
  Function[edge, <|
    "edge" -> edge,
    "(q+,q-,q_perp) powers" ->
      centralSoftPower["EdgeComponentPowers", edge],
    "q^2 power" ->
      centralSoftPower["PropagatorVirtualityPowers", edge]
  |>],
  {x0, x1, x2, x3, x4, x5}
];
centralSoftPowerRows = {
  <|"representation" -> "parameter space",
    "measure" -> "delta^(-20)",
    "integrand" -> "P^(-D/2) ~ delta^(4D)",
    "total" -> "delta^(4D-20)"|>,
  <|"representation" -> "momentum space",
    "measure" -> "delta^(4D+1)",
    "integrand" -> "1/Product(q_e^2) ~ delta^(-21)",
    "total" -> "delta^(4D-20)"|>
};
commonVariableRows = {
  <|"variable" -> w, "exact definition" -> "-p3_perp/p4_perp"|>,
  <|"variable" -> "wbar",
    "exact definition" -> "-p3bar_perp/p4bar_perp"|>,
  <|"variable" -> "zeta=-1/w",
    "exact definition" -> "p4_perp/p3_perp"|>,
  <|"variable" -> "zetabar=-1/wbar",
    "exact definition" -> "p4bar_perp/p3bar_perp"|>,
  <|"variable" -> X34, "exact definition" -> "p3+/p4+"|>,
  <|"variable" -> X45, "exact definition" -> "p4+/p5+"|>,
  <|"variable" -> Subscript[Q, 4]^2,
    "exact definition" -> "|p4_perp|^2 (overall scale)"|>
};
limitComparisonRows = {
  <|"quantity" -> "|p4_perp|^2", "near-planar wide angle" -> "fixed",
    "central-soft MRK" -> "R delta^(2a)"|>,
  <|"quantity" -> "zeta, zetabar",
    "near-planar wide angle" -> "xi/(1 -/+ i xi lambda/2)",
    "central-soft MRK" -> "delta^a {zetahat, zetabarhat}"|>,
  <|"quantity" -> "X34", "near-planar wide angle" -> "fixed",
    "central-soft MRK" -> "X34hat delta^(-(a+b))"|>,
  <|"quantity" -> "X45", "near-planar wide angle" -> "fixed",
    "central-soft MRK" -> "X45hat delta^(a-b)"|>,
  <|"quantity" -> "MRK gap x", "near-planar wide angle" -> "not taken",
    "central-soft MRK" -> "delta^b, 0<a<b"|>,
  <|"quantity" -> "|p4_perp|^2 (zeta-zetabar)/(zeta zetabar)",
    "near-planar wide angle" -> "O(lambda)",
    "central-soft MRK" -> "O(delta^a)"|>
};
symmetricVariableRows = {
  <|"quantity" -> R34,
    "definition" -> "X34 |p4_perp|/|p3_perp| = exp(y3-y4)",
    "central-soft scaling" -> "delta^(-b)"|>,
  <|"quantity" -> R45,
    "definition" -> "X45 |p5_perp|/|p4_perp| = exp(y4-y5)",
    "central-soft scaling" -> "delta^(-b)"|>,
  <|"quantity" -> kappa,
    "definition" -> "|p4_perp|/Q_perp",
    "central-soft scaling" -> "delta^a"|>
};
centralSoftStatusRows = {
  <|"item" -> "alignment vector",
    "value" -> Values[centralSoftCertificate["FaceScaling"]]|>,
  <|"item" -> "relative HRF vector",
    "value" -> Values[centralSoftCertificate["HRFScaling"]]|>,
  <|"item" -> "hard-scale-normalized total vector",
    "value" -> Values[centralSoftCertificate["TotalScaling"]]|>,
  <|"item" -> "physical weights (W_SL,W_HR)",
    "value" -> {centralSoftCertificate["WSL"], centralSoftCertificate["WHR"]}|>,
  <|"item" -> "current status",
    "value" -> centralSoftCertificate["AuditStatus"]|>
};
centralSoftWeightRows = {
  <|"stage" -> "absolute layers after alignment vector",
    "leading factor" -> -10, "next nonzero F layer" -> -9,
    "leading U" -> -6|>,
  <|"stage" -> "contribution of relative uniform HRF vector",
    "leading factor" -> -3, "next nonzero F layer" -> -3,
    "leading U" -> -2|>,
  <|"stage" -> "composed vector",
    "leading factor" -> -13, "next nonzero F layer" -> -12,
    "leading U" -> -8|>,
  <|"stage" -> "after imposing the two-factor locus",
    "leading factor" -> "promoted to -8", "next nonzero F layer" -> -8,
    "leading U" -> -8|>
};

nb = Notebook[{
  Cell["Five-point near-planar Landshoff region and central-soft MRK",
    "Title"],
  txt["Outcome. For the topology below, generic non-coplanar five-particle wide-angle kinematics has no positive Landau pinch. A hidden region appears instead in the exactly massless, near-planar limit Gamma5=epsilon5^2 -> 0. Its invariant description, factorized cancellation ideal, lower-facet certificate and power counting are established in Part I. Part II then uses one exact set of dimensionless variables to compare this angular approach to planarity with the central-soft MRK approach. Both limits have a certified HR, but their cancellation ideals, physical region vectors, momentum modes and scalar powers are different. No off-shell regulator and no MRK hierarchy are used in Part I."],

  sec["1. Reproducible setup and graph"],
  inCell["$HRF5WALandshoffAuditLibraryOnly=True; Get[FileNameJoin[{NotebookDirectory[],\"HRF_FivePointWideAngleLandshoffAllLayerAudit.wl\"}]]; landshoffAudit=hrf5WALandshoffAllLayerAudit[];"],
  outCell[graph],
  txt["Both panels keep exactly the internal vertex positions and topology of Fig. 3. Incoming p2 and p1 enter from the upper- and lower-left, while p3,p4,p5 end at the upper, middle and lower right. The left panel is the canonical spacelike-collinear attachment. The near-planar and representative central-soft calculation instead interchanges the external attachments p4 and p5 without moving the internal vertices; consequently their two external lines cross in this physical layout. The crossing is not a vertex."],
  outCell[readableTable[attachmentRows]],
  txt["The earlier paper figure is one-based, whereas the executable notebooks are zero-based. The following map is used everywhere below:"],
  outCell[readableTable[edgeConventionRows]],
  txt["Abstractly, the internal graph is a theta graph: three equivalent two-edge paths connect the four-valent vertices carrying p3 and, in the second panel, p4. Its path-permutation symmetry remains exact."],
  outCell[readableTable[pathRows]],
  txt["The common endpoints carry p3 and p4. The middle vertices of paths A,B,C carry p1,p2,p5, respectively. All internal propagators are massless, so U and F are multilinear in every original edge variable."],

  Cell["Part I. Invariant Mandelstam analysis", "Chapter"],

  sec["2. Exactly massless five-point kinematics"],
  txt["All momenta are written in the all-outgoing convention, with p1 and p2 incoming physically. Throughout Part I, p_i^2=0 exactly. Five adjacent Mandelstam invariants may be used as coordinates; all remain of the same wide-angle order. The full physical sign domain is:"],
  outCell[readableTable[physicalDomainRows]],
  displayCell[{s13 == -s12 - s23 + s45,
    s14 == -s15 + s23 - s45,
    s24 == s15 - s23 - s34,
    s25 == -s12 - s15 + s34,
    s35 == s12 - s34 - s45}],
  txt["To avoid a convention clash with the parity-odd square root, denote the real Gram determinant by Gamma5:"],
  displayCell[Gamma5 == Det[hrf5WAGramMatrix[]] == epsilon5^2],
  displayCell[epsilon5 == 4 I LeviCivita[p1, p2, p3, p4]],
  txt["For real physical momenta epsilon5 is purely imaginary. Our orientation is epsilon5/i=+Sqrt[-Gamma5], so Gamma5<0 in the non-coplanar interior. The Landau surface is the coplanar boundary Gamma5=0, approached physically as Gamma5->0 from below and epsilon5/i->0 from above. This statement is entirely invariant."],
  displayCell[hrf5WAGramMatrix[]],
  displayCell[hrf5WAGramDeterminant[] == 0],
  txt["In this notebook F denotes the complete massless on-shell second Symanzik polynomial. For the chosen near-planar expansion, F0=F|_(Gamma5=0) is the leading polynomial and the normal correction begins at Gamma5=O(lambda^2). No external off-shell regulator is introduced."],
  subsec["2.1 Manifestly symmetric graph polynomials"],
  displayCell[U == (x0 + x1) (x2 + x3) +
    (x2 + x3) (x4 + x5) + (x4 + x5) (x0 + x1)],
  txt["Introduce one dimensionless ratio on each path:"],
  displayCell[{rA == x0/x1, rB == x2/x3, rC == x4/x5}],
  displayCell[\[CapitalPhi][rA, rB, rC] ==
    qAB rA rB + qBC rB rC + qCA rC rA +
      ellA rA + ellB rB + ellC rC],
  displayCell[F == x1 x3 x5 \[CapitalPhi][rA, rB, rC]],
  txt["The function \[CapitalPhi] is only a convenient dimensionless ratio polynomial obtained by factoring x1 x3 x5 out of F. It is not another graph polynomial."],
  txt["All kinematic dependence is contained in six coefficients expressed only through adjacent invariants:"],
  outCell[readableTable[kinematicCoefficientRows]],
  txt["Only their ratios matter. If a dimensionless parametrization is preferred, divide all six coefficients and all s_ij by the common scale s12; none of the stationary equations or generator statements changes."],
  txt["The form of U and \[CapitalPhi] is covariant under permutations of A,B,C. Relabelling the corresponding external legs simply permutes the q and ell coefficients."],
  Cell[CellGroupData[{
    subsec["Expanded on-shell F, if required"],
    displayCell[audit["Graph", "F0"]]
  }, Closed]],

  sec["3. Positive Landau locus in invariant variables"],
  txt["The variables x1,x3,x5 are convenient positive coordinates for the common magnitude on each two-edge path: x0=rA x1, x2=rB x3 and x4=rC x5. They are not fixed overall constants; together with the ratios they form six independent coordinates on the positive Schwinger orthant. Since F=x1 x3 x5 \[CapitalPhi](r), the ratio part of the Landau equations is grad_r \[CapitalPhi]=0. Explicit differentiation gives grad_r \[CapitalPhi]=K.r+ell: for example, d\[CapitalPhi]/drA=qAB rB+qCA rC+ellA. Therefore at the stationary ratio r=rho one obtains K.rho=-ell."],
  displayCell[K == {{0, qAB, qCA}, {qAB, 0, qBC},
    {qCA, qBC, 0}}],
  displayCell[K . {rhoA, rhoB, rhoC} == -{ellA, ellB, ellC}],
  txt["This linear system determines rho uniquely whenever qAB qBC qCA is nonzero. There is no advantage in displaying the lengthy components of K^(-1) ell individually."],
  txt["At this generic kinematic point, before imposing any coplanar or MRK limit, define the three normal polynomials"],
  displayCell[{fA == x0 - rhoA x1, fB == x2 - rhoB x3,
    fC == x4 - rhoC x5}],
  displayCell[\[CapitalPhi][rhoA, rhoB, rhoC] ==
    Gamma5/(4 qAB qBC qCA)],
  txt["This is not a second \[CapitalPhi]: it is the same function evaluated at its stationary point r=rho. Completing the quadratic form about rho gives an exact identity for the full massless F at generic five-point kinematics:"],
  displayCell[F == qAB x5 fA fB + qBC x1 fB fC +
    qCA x3 fC fA + Gamma5 x1 x3 x5/(4 qAB qBC qCA)],
  subsec["Analytic check from the Mandelstam polynomial"],
  txt["The following executable check starts from the usual expanded on-shell Symanzik polynomial in the adjacent Mandelstam invariants, stored under Graph/F0 and displayed in the closed subsection of Sec. 2. It then substitutes the explicit invariant q coefficients, the exact solution rho=-K^(-1).ell, the definitions of fA,fB,fC, and the Gram polynomial. No use is made of the ratio-form identity being tested."],
  inCell["Fmandelstam=Expand[landshoffAudit[\"Graph\",\"F0\"]]; qRules=Normal[landshoffAudit[\"InvariantSymmetricForm\",\"QuadraticCoefficients\"]]; rhoRules=Thread[{rhoA,rhoB,rhoC}->landshoffAudit[\"InvariantSymmetricForm\",\"StationaryRatioVector\"]]; fRules={fA->x0-rhoA x1,fB->x2-rhoB x3,fC->x4-rhoC x5}; gammaRule=Gamma5->hrf5WAGramDeterminant[]; rhs=qAB x5 fA fB+qBC x1 fB fC+qCA x3 fC fA+Gamma5 x1 x3 x5/(4 qAB qBC qCA); Factor[Together[Fmandelstam-(rhs/.fRules/.rhoRules/.qRules/.gammaRule)]]"],
  outCell[0],
  txt["The zero is an exact symbolic identity for generic adjacent Mandelstam invariants; no numerical kinematic point or coplanar restriction has been used."],
  subsec["What the derivative harvester sees"],
  txt["The compact factorized identity must not be confused with the algorithmic input. Starting from the usual Mandelstam polynomial, the raw first derivative is"],
  displayCell[Subscript[D, 0] == qAB x2 x5 + qCA x3 x4 + ellA x3 x5],
  txt["Literal collection in qAB, qCA and ellA exposes only monomials. The first component of K.rho=-ell gives ellA=-qAB rhoB-qCA rhoC, and only then can the same derivative be reorganized as"],
  displayCell[Subscript[D, 0] == qAB x5 (x2 - rhoB x3) +
    qCA x3 (x4 - rhoC x5) == qAB x5 fB + qCA x3 fC],
  txt["Thus the simple appearance of fB and fC has already used the stationary reorganisation. On Gamma5=0 the complete leading polynomial is the selected cancellation sector, so its candidate-specific saturated gradient ideal may derive this consequence of the raw derivatives after localising away from the nonzero determinant, without supplying rho in advance. This would not be a valid pre-decomposition operation on a polynomial that still contained an obstruction."],
  txt["The Gamma5 remainder is independent of x0,x2,x4. Hence three derivatives of the full F, with no restriction to Gamma5=0, are"],
  displayCell[{Inactive[D][F, x0] == qAB x5 fB + qCA x3 fC,
    Inactive[D][F, x2] == qAB x5 fA + qBC x1 fC,
    Inactive[D][F, x4] == qBC x1 fB + qCA x3 fA}],
  txt["Their coefficient matrix in (fA,fB,fC) has determinant 2 qAB qBC qCA x1 x3 x5. In the interior positive orthant it therefore forces fA=fB=fC=0. On that locus the remaining derivatives are Gamma5 (x3 x5,x1 x5,x1 x3)/(4 qAB qBC qCA), and F itself is Gamma5 x1 x3 x5/(4 qAB qBC qCA). Thus the full derivative system first exposes the candidate normal ideal and then requires Gamma5=0 for an actual pinch."],
  txt["First-sheet Schwinger positivity selects rhoA,rhoB,rhoC>0. The orientation sign of epsilon5 does not enter F, but the physical boundary must be reachable from the domain epsilon5/i>0. For example, the following invariant point lies on that boundary and satisfies every two-particle sign condition:"],
  displayCell[{s12, s23, s34, s45, s15} ==
    {45, -3, 9/2, 27, -45/2}],
  displayCell[{rhoA, rhoB, rhoC} == {4, 1, 2}],
  displayCell[Gamma5 == epsilon5 == 0],
  Cell[CellGroupData[{
    subsec["Exact positive Landau check"],
    txt["The stored invariant construction verifies the stationary equations, the Gram identity and positivity without exposing any dimensionful light-cone parametrization."],
    inCell["landshoffAudit[\"InvariantSymmetricForm\"]"]
  }, Closed]],

  sec["4. Coplanar leading sector and factorized generators"],
  txt["Only now specialise the generic construction to the coplanar boundary. The cancellation structure remains in the original edge variables and is defined before dissection."],
  subsec["Compact form in the exact dimensionless variables"],
  txt["Define zeta=-1/w and zetabar=-1/wbar. On the coplanar boundary zeta=zetabar=xi>0, with X34=p3+/p4+ and X45=p4+/p5+. The three stationary ratios then have a particularly transparent form:"],
  displayCell[R ==
    (xi + X45 (xi + 1))/(1 + X34 X45 (xi + 1))],
  displayCell[{rhoA == X34 xi R, rhoB == R, rhoC == xi}],
  displayCell[{fA == x0 - X34 xi R x1,
    fB == x2 - R x3, fC == x4 - xi x5}],
  txt["For the physical positive-Landau branch X34>0, X45>0 and xi>0. Therefore R>0 and rhoA,rhoB,rhoC are all positive. These expressions are exactly the invariant solution K.rho=-ell rewritten in the common five-point variables; no MRK hierarchy has been taken."],
  txt["The f_i define the Landau locus but are not HRF generators individually: a generator must have the factorized structure needed by the Landau equations. The three generators are their pairwise products:"],
  outCell[readableTable[factorizedGeneratorRows]],
  txt["Using kappa for four coordinates tangent to the Gram surface and Gamma5 as a local normal coordinate, the chosen kinematic expansion is"],
  displayCell[F[Gamma5, kappa] == Subscript[F, 0][kappa] +
    Gamma5 Subscript[F, Gamma5][kappa] + remainder[Gamma5^2]],
  txt["There is no conflict between the nonlinear-looking exact decomposition and the linearity of F in Mandelstam invariants. Gamma5 is itself a nonlinear polynomial in those invariants. Replacing one Mandelstam variable by Gamma5 is a nonlinear change of kinematic coordinates, so F_Gamma5=(dF/dGamma5)_kappa contains the corresponding nonlinear Jacobian. Equivalently, the rational kinematic dependence of rho=-K^(-1).ell cancels between the separate terms of the exact decomposition, restoring the original Mandelstam-linear polynomial."],
  txt["Away from the stationary locus the complete F_Gamma5 depends on the choice of tangent coordinates kappa. Its restriction to fA=fB=fC=0 is invariantly fixed by the exact decomposition to x1 x3 x5/(4 qAB qBC qCA). This is not an obstruction in the technical HRF sense, because it is absent from F0 by the definition of the expansion rather than being demoted by the HR scaling. Since Gamma5=O(lambda^2), this contribution first appears two powers beyond F0. Its precise weight relative to the cancelled leading sector and to U follows only after the region vector has been determined below."],
  displayCell[Subscript[F, 0] == qAB x5 fA fB +
    qBC x1 fB fC + qCA x3 fC fA],
  subsec["Recovering the path normals from derivatives"],
  txt["The stationary-adapted derivatives displayed in Sec. 3 recover the three normals after the raw derivatives of the selected Gamma5=0 leading sector have been completed inside its saturated gradient ideal. Since qAB=s35, qBC=s13 and qCA=s23, the resulting outer sectors expose the normals directly up to positive monomial factors. For example, the two sectors in the first derivative expose fB and fC. In the Crown this sector form is available directly; here the f_i contain kinematic stationary ratios, so the reorganisation itself must first be derived."],
  txt["After saturation by the nonzero determinant, the ideal of these three derivatives is <fA,fB,fC>. The remaining derivatives select Gamma5=0. Only there does substitution into F0 reconstruct the HR generator ideal <fA fB,fB fC,fC fA>. Each term contains three distinct edge variables, so the original F remains cubic and multi-affine; no x_e^2 occurs. Quadratic powers of local variables may arise only after changing coordinates."],
  subsec["End-to-end HRF run in the original variables"],
  txt["The following run implements the same logic without supplying the three normals or their pairwise products. The expansion is first fixed on Gamma5=0; there the complete supplied leading polynomial equals the cancellation sector, and HRF is explicitly authorised to saturate its gradient ideal. Kinematic prefactors that are nonzero in the stated domain are treated as units: polynomial division is in the Schwinger variables, with rational functions of the Mandelstams as coefficients. The Gram equation certifies that the remainder is absent from the leading kinematic surface; its physical order lambda^2 is restored separately in the scaling step. This special use of saturation is not the general derivative-harvest step for a polynomial containing an obstruction."],
  inCell["$HRF5WANearPlanarAlgorithmAuditLibraryOnly=True; Get[FileNameJoin[{NotebookDirectory[],\"HRF_FivePointNearPlanarAlgorithmAudit.wl\"}]]; algorithmResult=hrf5WANearPlanarAlgorithmAudit[]; algorithmResult[\"Summary\"]"],
  outCell[readableTable[algorithmRows]],
  txt["Exactly one decomposition survives: the set of all three pairwise generators. Every candidate containing only one or two of them leaves a nonzero remainder on Gamma5=0. Exact coverage then recovers the primitive physical vector and the gap quoted in Sec. 5. The search is uncapped and untruncated."],
  Cell[CellGroupData[{
    subsec["Recovered factors and generators"],
    inCell["KeyTake[algorithmResult[\"Scan\"],{\"CancellationFactors\",\"Generators\",\"ObstructionData\",\"CoverageScalingData\"}]"],
    outCell[KeyTake[algorithmAudit["Scan"], {
      "CancellationFactors", "Generators", "ObstructionData",
      "CoverageScalingData"}]]
  }, Closed]],
  subsec["Relation to x1 x4-x0 x5"],
  displayCell[x1 x4 - x0 x5 == x1 fC - x5 fA +
    (rhoC - rhoA) x1 x5],
  txt["The undressed binomial x1 x4-x0 x5 vanishes on the Landau locus only when rhoA=rhoC. That equality is imposed by the more special central-soft kinematics, but not by generic wide-angle kinematics. The symmetric generic description therefore uses the three path normals fA,fB,fC and their pairwise products."],

  sec["5. Near-planar expansion and scaling"],
  txt["Use a primitive real parameter lambda for the physical angular distance from the coplanar boundary:"],
  displayCell[{epsilon5 == I cEpsilon \[Lambda], Gamma5 == -cEpsilon^2 \[Lambda]^2,
    cEpsilon > 0}],
  txt["Because the scalar graph polynomial is parity even, its first transverse correction is quadratic:"],
  displayCell[F == Subscript[F, 0] + \[Lambda]^2 Subscript[F, perpendicular] +
    remainder[\[Lambda]^4]],
  txt["Tangential changes of the Mandelstam invariants may be absorbed into the coordinates along the Gram surface. The displayed lambda^2 term is the normal deformation relevant to the lower-facet test."],
  outCell[readableTable[scalingRows]],
  txt["The scaling vector now fixes the comparison announced above. With lambda assigned weight +1, the pullback to the original edge variables is (-2,-2,-2,-2,-2,-2;1). Every cubic monomial in F0 has raw weight W_SL=-6. The factor Gamma5=O(lambda^2) raises Gamma5 F_Gamma5 to weight -4, while the quadratic polynomial U also has weight -4. Cancellation on the singular locus promotes F0 to the same resolved weight W_HR=-4: each path scale has weight -2 and each normal has weight -1. Thus the cancelled leading sector, the first Gram-normal correction and U enter the resolved LP polynomial together."],
  displayCell[Subscript[scriptP, lead] ==
    fLocalSimple + Subscript[U, Landau] +
      \[Lambda]^2 Subscript[F, perpendicular]],
  outCell[readableTable[weightRows]],
  txt["This table is produced from the complete transformed F0 and U and the leading, generically nonzero normal unfolding of F. Tangential kinematic changes contribute only above the certified face. Kinematic coefficients are kept as coefficients, so the multiplicities count distinct monomials in the six local integration variables and lambda."],

  sec["6. Dissection: the ordinary lower-facet description"],
  txt["Choose local coordinates proportional to fA,fB,fC. The Lee-Pomeransky polynomial is then an ordinary polynomial in the three path scales, the three normal coordinates and lambda. Its leading augmented exponent points have full affine rank six and a one-dimensional normal space. The unique inward normal agrees with the proposed scaling, and every other monomial lies on or above the same face."],
  outCell[readableTable[facetRows]],
  txt["After dissection the hidden cancellation has become an ordinary facet problem. The local vector is (-2,-2,-2,-1,-1,-1;1) in the ordered variables (x1,x3,x5,fA,fB,fC;lambda). Pulling it back gives the uniform original-coordinate vector (-2,-2,-2,-2,-2,-2;1). The hierarchy gap is the fixed integer W_HR-W_SL=2."],
  Cell[CellGroupData[{
    subsec["Exact augmented exponent rows"],
    inCell["landshoffAudit[\"NearPlanarOnShell\",\"FacetCertificate\",\"LeadingAugmentedRows\"]"],
    outCell[facet["LeadingAugmentedRows"]]
  }, Closed]],

  Cell["Part II. Exact common variables and the two limits", "Chapter"],

  sec["7. Exact variables before either limit"],
  txt["For comparing with the central-soft MRK analysis, introduce the exact transverse ratios and longitudinal ratios in the (p1,p2) light-cone frame:"],
  outCell[readableTable[commonVariableRows]],
  displayCell[{w == -p3perp/p4perp,
    wb == -p3barperp/p4barperp,
    zeta == -1/w, zetab == -1/wb,
    X34 == p3plus/p4plus, X45 == p4plus/p5plus}],
  txt["These four ratios together with |p4_perp|^2 provide a convenient exact chart. They are introduced only after the invariant construction, so the existence of the near-planar region does not depend on this choice. In the convention of the five-point MRK paper q2_perp=p3_perp, not p4_perp, and therefore"],
  displayCell[Abs[q2perp]^2 == w wb Abs[p4perp]^2],
  txt["Up to the fixed orientation convention for epsilon5, the parity-odd invariant has the exact factorized form"],
  displayCell[epsilon5 == s12 Abs[p4perp]^2 (w - wb) ==
    s12 Abs[p4perp]^2 (zeta - zetab)/(zeta zetab)],
  txt["This is the generic five-point chart before either expansion is taken. The two limits below are independent paths from this same domain. Near-planar wide angle sends the angular difference zeta-zetabar to zero at fixed |p4_perp|^2. Central-soft MRK instead sends |p4_perp|^2 to zero while zeta/zetabar remains generic. It is not obtained by first imposing coplanarity and then taking a soft MRK sublimit."],
  subsec["7.1 Symmetric variables for physical interpretation"],
  txt["The exact X variables use plus components on both sides of the central emission. This is algebraically convenient but not symmetric under exchanging the forward and backward rapidity sectors. Introduce instead"],
  displayCell[{R34 == X34 Abs[p4perp]/Abs[p3perp],
    R45 == X45 Abs[p5perp]/Abs[p4perp]}],
  displayCell[{R34 == Exp[y3 - y4], R45 == Exp[y4 - y5]}],
  txt["These quantities measure only the two rapidity gaps. The independent variable kappa=|p4_perp|/Q_perp measures the softness of the central emission. If a rational parametrization is required, use the squares"],
  displayCell[{R34^2 == X34^2 Abs[p4perp]^2/Abs[p3perp]^2,
    R45^2 == X45^2 Abs[p5perp]^2/Abs[p4perp]^2}],

  sec["8. Angular near-planar wide-angle limit"],
  txt["Keep |p4_perp|^2, X34, X45 and the remaining wide-angle ratios finite. The physical approach from one orientation is"],
  displayCell[{w == -1/xi + I \[Lambda]/2,
    wb == -1/xi - I \[Lambda]/2,
    zeta == xi/(1 - I xi \[Lambda]/2),
    zetab == xi/(1 + I xi \[Lambda]/2), xi > 0, \[Lambda] > 0}],
  txt["Thus zeta and zetabar are complex conjugates in the physical non-coplanar region and become equal to the positive real number xi at the coplanar boundary. Equivalently w=wbar=-1/xi there. This makes epsilon5=O(i lambda) and Gamma5=O(-lambda^2). It is an angular approach to planarity; no rapidity hierarchy and no soft external momentum are taken."],

  sec["9. Central-soft MRK in the same variables"],
  txt["Starting again from the generic chart, let delta be the MRK parameter, with p4_perp~delta^a and x_MRK~delta^b for 0<a<b. The following independent rate-resolved path is exactly on shell, not merely a list of leading valuations:"],
  displayCell[{zeta == zetaHat \[Delta]^a,
    zetab == zetaBarHat \[Delta]^a,
    Abs[p4perp]^2 == Q4hat2 \[Delta]^(2 a),
    X34 == X34hat \[Delta]^(-(a + b)),
    X45 == X45hat \[Delta]^(a - b)/
      ((1 + zetaHat \[Delta]^a) (1 + zetaBarHat \[Delta]^a))}],
  txt["All hatted quantities are fixed and nonzero; in the physical region zetaBarHat is the complex conjugate of zetaHat. The denominator in X45 is required for exact on-shell equivalence."],
  txt["The exact variables then scale as follows:"],
  outCell[readableTable[limitComparisonRows]],
  txt["The visibly different powers of X34 and X45 do not represent asymmetric rapidity gaps: each X also contains a different power of the soft transverse momentum. In the symmetric variables the two physical gaps and the softness separate cleanly:"],
  outCell[readableTable[symmetricVariableRows]],
  displayCell[{scalesAs[R34/R45] == 1,
    scalesAs[kappa] == \[Delta]^a,
    scalesAs[R34] == \[Delta]^(-b),
    scalesAs[R45] == \[Delta]^(-b)}],
  txt["For the representative choice a=1,b=2 the powers of (|p4_perp|^2,zeta,X34,X45) are (2,1,-3,-1). The normalized parity-odd quantity tends to zero:"],
  displayCell[scalesAs[epsilon5/s12] ==
    scalesAs[Abs[p4perp]^2 (zeta - zetab)/(zeta zetab)] == \[Delta]^a],
  txt["The dimensionful epsilon5 itself need not tend to zero because s12 grows in MRK. At the central-soft endpoint the transverse transfers obey q1_perp=-q2_perp and hence t1=t2."],
  subsec["9.1 Exact equivalence with the earlier light-cone audit"],
  txt["The existing all-layer audit used finite coefficients P,K,M,R,T,C. It set"],
  displayCell[{p3plus == P \[Delta]^(-b),
    p4plus == K \[Delta]^a, p5minus == M \[Delta]^(-b),
    Abs[p3perp]^2 == T, Abs[p4perp]^2 == R \[Delta]^(2 a)}],
  txt["The two descriptions are exactly the same path under"],
  displayCell[{Q4hat2 == R, X34hat == P/K, X45hat == K M/T,
    zetaHat zetaBarHat == R/T,
    zetaHat + zetaBarHat == sigma C/T}],
  displayCell[{R34 == (P/K) Sqrt[R/T] \[Delta]^(-b),
    R45 == (K M/Sqrt[R T]) \[Delta]^(-b) +
      subleading[\[Delta]],
    kappa == Sqrt[R/T] \[Delta]^a}],
  txt["Substitution reproduces all five exact adjacent invariants, including their subleading layers. Here Q_perp=|p3_perp| was chosen in kappa. Thus the old coefficients do not define a different kinematic limit; they are retained only as an executable equivalence and positivity audit."],
  subsec["9.2 Full-layer hidden-region certificate"],
  txt["For a=1,b=2 the aligned leading polynomial factorizes and defines a two-factor cancellation locus:"],
  displayCell[Subscript[F, -10]^align ==
    -(X45hat Q4hat2/(zetaHat zetaBarHat))
      (X34hat x2 - x3) (x1 x4 - x0 x5)],
  displayCell[{X34hat x2 - x3 == 0, x1 x4 - x0 x5 == 0}],
  txt["The displayed factor is the coefficient of the delta^(-10) layer after asymptotic-order alignment alone. It is not a polynomial assigned only to the relative HRF stage. The relative HRF vector is uniform, so it contributes -3 to every cubic F term and -2 to every quadratic U term. Consequently"],
  outCell[readableTable[centralSoftWeightRows]],
  txt["The sum of the alignment and HRF vectors is (-4,-4,-1,-4,-4,-4;1). This is the HRF region vector in the dimensionless convention where the growing hard invariant s12 has been factored out. Adding +4 uniformly would convert back to dimensionful Schwinger parameters while s12 itself varies, but that non-negative representative is not the infrared region vector and is not used for the MoR power count."],
  txt["The immediately following aligned F layer contains"],
  displayCell[Subscript[F, -9]^align ==
    -(Q4hat2/(zetaHat zetaBarHat)) x0 x3 x4],
  txt["On the two-factor locus this remains finite and nonzero. It has weight -8, exactly the leading U weight. The cancelled factorized sector is promoted from W_SL=-9 to the same W_HR=-8 layer. The resolved augmented support has full affine rank, and the current audit therefore accepts the region."],
  outCell[readableTable[centralSoftStatusRows]],

  sec["10. What is common and what is distinct"],
  txt["The two limits reach the normalized planar hypersurface through different factors of the same exact expression. Near-planar wide angle keeps |p4_perp| finite and sends zeta-zetabar to zero at zeta=zetabar=xi>0. Central-soft MRK sends |p4_perp|,zeta and zetabar to zero together. Both possess an HR, but they are not two coordinate descriptions of one region."],
  txt["Their limiting ideals are nevertheless related; this comparison does not construct either limit as a sublimit of the other. On the aligned central-soft face the two corresponding path ratios coincide, so x1 x4-x0 x5=x1 fC-x5 fA. The other central-soft factor X34hat x2-x3 equals X34hat fB in the aligned variables. Their product therefore belongs to the limiting near-planar ideal generated by fA fB and fB fC; the third product fA fC is kinematically suppressed on this MRK face. The region vector (-4,-4,-1,-4,-4,-4;1) and momentum scaling remain distinct from the uniform near-planar vector (-2,-2,-2,-2,-2,-2;1)."],

  Cell["Part III. Momentum-space interpretation and power counting", "Chapter"],

  sec["11. Complete edge-flow configuration"],
  txt["Orient qA,qB,qC from the common vertex carrying p3 towards the common vertex carrying p4. Momentum conservation gives qA+qB+qC=-p3. Along path A the two edge momenta are qA and qA-p1; paths B and C are analogous with p2 and p5. All momenta use the all-outgoing convention."],
  outCell[readableTable[momentumEdgeRows]],
  txt["The two independent loop Landau equations say that the weighted momentum transported by each path is the same:"],
  displayCell[(x0 + x1) qA - x1 p1 ==
    (x2 + x3) qB - x3 p2 ==
    (x4 + x5) qC - x5 p5],
  txt["At a positive Landau point all six propagators are on shell. Each pair differs by a massless external momentum, so real first-sheet kinematics makes the pair collinear to that external direction. Since p1,p2,p5 are not mutually collinear, the common weighted vector above must vanish. The loop Landau equations therefore fix"],
  displayCell[{qA == xiA p1, qB == xiB p2, qC == xiC p5}],
  displayCell[{xiA == 1/(1 + rhoA), xiB == 1/(1 + rhoB),
    xiC == 1/(1 + rhoC)}],
  txt["The hard-vertex equation xiA p1+xiB p2+xiC p5=-p3 is soluble precisely on the Gram surface Gamma5=0. This is the momentum-space reason the region disappears at a generic non-coplanar wide-angle point. At the invariant witness used above the fractions are (xiA,xiB,xiC)=(1/5,1/2,1/3)."],
  subsec["11.1 Modes and restricted longitudinal support"],
  txt["For each path introduce light-cone vectors v_i and bar(v)_i along and opposite to its external direction, an in-plane transverse direction u_i, and D-3 transverse directions orthogonal to the scattering plane. Near the pinch,"],
  displayCell[q[i] == Q (xi[i] v[i] + \[Lambda]^2 kappa[i] barv[i] +
    \[Lambda] tau[i] u[i] + \[Lambda] boldv[i])],
  txt["so q_i^2 and (q_i-p_i)^2 are both O(lambda^2 Q^2). Only two loop momenta are independent; take qA and qB, with qC=-p3-qA-qB. An unrestricted collinear loop measure scales as lambda^D, hence the two base measures give lambda^(2D)."],
  txt["The dependent momentum qC must simultaneously remain collinear to p5. The two independent longitudinal variations delta xiA and delta xiB are confined by the in-plane and conjugate light-cone projections, with widths O(lambda) and O(lambda^2), respectively. The wide-angle Jacobian is nonzero. Consequently"],
  displayCell[Subscript[J, 5] == Det[{{u5 . p1, u5 . p2},
    {v5 . p1, v5 . p2}}] != 0],
  displayCell[scalesAs[DifferentialD[xiA] DifferentialD[xiB]] ==
    \[Lambda]^3],
  txt["This restricted support is the momentum-space image of the depth of the parameter-space cancellation. It is essential: counting two ordinary collinear loop measures without it misses lambda^3."],

  sec["12. Matching parameter- and momentum-space power counting"],
  txt["In parameter space, the three path-scale coordinates contribute lambda^(-6) and the three normal coordinates contribute lambda^(-3). The resolved LP polynomial has weight -4, so P^(-D/2) contributes lambda^(2D). In momentum space, the two collinear loop measures and their restricted longitudinal support contribute lambda^(2D+3), while six unit propagators contribute lambda^(-12)."],
  outCell[readableTable[powerComparisonRows]],
  displayCell[\[Lambda]^(2 D - 9)],
  txt["At D=4-2 epsilon both descriptions give lambda^(-1-4 epsilon). Numerators can change the integer power, but equality of the two scalar countings independently certifies the translation between parameter and momentum space."],

  sec["13. Central-soft MRK momentum flow and scalar power"],
  txt["For the representative a=1,b=2 path, the hard-scale-normalized LP vector is (-4,-4,-1,-4,-4,-4;1). The associated propagator virtualities and one consistent component assignment are:"],
  outCell[readableTable[centralSoftMomentumRows]],
  txt["Use r=q0 and ell=q0-q4 in hard-scale-normalized momenta. The q0/q1 poles pinch r-plus with width delta^4; q4/q5 pinch ell-plus with width delta^4; and q2/q3 pinch ell-minus with width delta. Both transverse widths scale as delta^2. Thus r has local widths (4,0,2) and ell has widths (4,1,2). The two-loop measure has power 4D+1. The six denominator powers sum to 21, so their reciprocals contribute delta^(-21)."],
  txt["In parameter space define A=x2-X34hat^(-1) delta^3 x3 and B=x1 x4-x0 x5. The generic A weight is -1, and the HRF gap restricts it to weight 0; B has weight -8. Four tangential coordinates contribute -16, while the Jacobian -1/x0 contributes +4. The parameter measure is therefore delta^(-20), while the resolved LP polynomial of weight -8 contributes delta^(4D)."],
  outCell[readableTable[centralSoftPowerRows]],
  displayCell[Subscript[I, CS]^(scalar) == \[Delta]^(4 D - 20) == \[Delta]^(-4 - 8 epsilon)],
  txt["This is the dimensionless integral with s12 factored out, which is the convention relevant for identifying an infrared region. Restoring the engineering-dimension factor s12^(D-6), with s12~delta^(-4), gives an additional overall delta^(-4D+24); this trivial conversion should not be confused with the HRF region vector."],

  sec["14. Conclusions and scope"],
  txt["The exactly on-shell near-planar Landshoff region has a positive Landau solution on Gamma5=0, three independent normal equations, the pair-product generator ideal, hierarchy gap two, and matching scalar power lambda^(-1-4 epsilon) in parameter and momentum space. The central-soft MRK degeneration has a two-factor ideal, requires asymptotic-order alignment, and has the distinct hard-scale-normalized vector (-4,-4,-1,-4,-4,-4;1) and scalar power delta^(-4-8 epsilon). The two regions are related through the same path-normal geometry and the same unlabeled seed topology, but they are physically different regions in different expansions."],

  Cell[CellGroupData[{
    sec["Appendix: implementation chart and complete exact expressions"],
    txt["These commands expose the invariant construction and the executable near-planar certificate. The audit retains an older off-shell calculation internally as a regression reference, but it is not part of the notebook's physical definition."],
    inCell["landshoffAudit[\"InvariantSymmetricForm\"]"],
    inCell["landshoffAudit[\"NearPlanarOnShell\"]"],
    inCell["landshoffAudit[\"NearPlanarOnShell\",\"FacetCertificate\",\"LeadingAugmentedRows\"]"],
    inCell["$HRF5ComparisonLibraryOnly=True; Get[FileNameJoin[{NotebookDirectory[],\"HRF_FivePointWideAngleCentralSoftComparison.wl\"}]]; hrf5ComparisonCentralSoftAudit[]"]
  }, Closed]]
}, WindowTitle -> "Five-point near-planar Landshoff and central-soft MRK",
  StyleDefinitions -> "Default.nb"];

out = FileNameJoin[{base, "FivePoint_WideAngle_Landshoff_AllLayers.nb"}];
saveNotebook[out, nb];
Print["Wrote ", out];
