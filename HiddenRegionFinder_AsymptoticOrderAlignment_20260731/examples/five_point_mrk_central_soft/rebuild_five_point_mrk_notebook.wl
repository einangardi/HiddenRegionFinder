$HistoryLength = 0;
base = DirectoryName[$InputFileName];
repo = DirectoryName[DirectoryName[base]];
$HRF5MRKRepoDirectory = repo;
$HRF5MRKLibraryOnly = True;
Get[FileNameJoin[{base, "HRF_FivePointMRKExploratory.wl"}]];
summary = Get[FileNameJoin[{base, "certified_summary.wl"}]];
correctedPowerResult = Get[FileNameJoin[{base,
  "five_point_mrk_corrected_power_counting_result.wl"}]];
(* Loaded only so that the commented regression block near the end of this
   builder remains syntactically evaluable; these superseded results are not
   emitted into the notebook. *)
pinchMomentumResult = Get[FileNameJoin[{base,
  "five_point_mrk_pinch_momentum_result.wl"}]];
polePinchResult = Get[FileNameJoin[{base,
  "five_point_mrk_pole_pinch_result.wl"}]];
powerResult = Get[FileNameJoin[{base,
  "spacelike_mrk_power_counting_result.wl"}]]["CentralSoftMRK"];

ClearAll[
  inCell, outCell, txt, sec, subsec, displayCell, saveNotebook,
  inlineTableValue, readableTable
];
inCell[code_String, label_String] := Cell[
  BoxData @ ToExpression[
    StringReplace[StringTrim[code], RegularExpression["\r\n|\r|\n"] -> "; "],
    InputForm, MakeBoxes
  ],
  "Input", CellLabel -> label
];
outCell[expr_, label_String:""] := Cell[BoxData @ ToBoxes[expr], "Output",
  Sequence @@ If[label === "", {}, {CellLabel -> label}]];
displayCell[expr_] := Cell[BoxData @ ToBoxes[TraditionalForm[expr]], "Output"];
txt[s_String] := Cell[s, "Text"];
sec[s_String] := Cell[s, "Section"];
subsec[s_String] := Cell[s, "Subsection"];

(* Dataset turns Lists and Associations inside table cells into drill-down
   objects.  That is useful interactively, but it hides vectors and rules in
   a saved audit notebook.  These static grids keep every such value on one
   visible line; a wide table may extend horizontally, but no click is needed
   to read it. *)
inlineTableValue[value_] := If[
  ListQ[value] || AssociationQ[value] || MatchQ[value, _Rule | _RuleDelayed],
  Style[
    ToString[value, InputForm, PageWidth -> Infinity],
    FontFamily -> "Source Code Pro"
  ],
  value
];

readableTable[rows_List] := Module[{assocRows, headers, body},
  assocRows = Replace[rows, row_ /; ! AssociationQ[row] :> <|"value" -> row|>, {1}];
  headers = DeleteDuplicates @ Flatten[Keys /@ assocRows];
  body = (inlineTableValue /@ Lookup[#, headers, ""]) & /@ assocRows;
  Grid[
    Prepend[body, Style[#, Bold] & /@ headers],
    Frame -> All,
    Alignment -> Left,
    Spacings -> {1.1, 0.65},
    Background -> {None, {RGBColor[0.94, 0.96, 0.99], None}}
  ]
];

saveNotebook[path_, nb_] := If[$FrontEnd =!= Null,
  obj = NotebookPut[nb, Visible -> False]; NotebookSave[obj, path];
  NotebookClose[obj, SaveRemaining -> False],
  Export[path, nb, "Notebook"]
];

ClearAll[edgeLabelPoint, makeGraphDiagram, particleColor];
particleColor[p_] := Which[
  p === p4, RGBColor[0.82, 0.10, 0.10],
  MemberQ[{p2, p3}, p], RGBColor[0.42, 0.56, 0.14],
  MemberQ[{p1, p5}, p], RGBColor[0.00, 0.55, 0.25],
  True, GrayLevel[0.35]
];
edgeLabelPoint[a_, b_, sign_:1, fraction_:1/2] := Module[{d = b - a, n},
  n = If[Norm[d] == 0, {0, 0}, Normalize[{-d[[2]], d[[1]]}]];
  (1 - fraction) a + fraction b + sign 0.09 n
];
makeGraphDiagram[coords_Association, internal_List, external_List,
    extEnds_Association, title_String, edgeSigns_List, edgeFractions_List] := Labeled[
  Graphics[
    {
      {GrayLevel[0.25], AbsoluteThickness[2.2],
        Map[Line[{coords[#[[2, 1]]], coords[#[[2, 2]]]}] &, internal]},
      MapIndexed[
        With[{a = coords[#1[[2, 1]]], b = coords[#1[[2, 2]]],
          lab = "x" <> ToString[First[#2] - 1], sg = edgeSigns[[First[#2]]]},
          Text[
            Framed[
              Style[lab, 15, Black],
              Background -> White, FrameStyle -> None, FrameMargins -> 1
            ],
            edgeLabelPoint[a, b, sg, edgeFractions[[First[#2]]]]]
        ] &,
        internal
      ],
      {White, AbsoluteThickness[5.0],
        Map[Line[{coords[#[[2]]], extEnds[#[[2]]]}] &, external]},
      Map[
        With[{p = #[[1]], v = #[[2]]},
          {particleColor[p], AbsoluteThickness[1.8], Arrowheads[0.035],
            If[MemberQ[{p1, p2}, p],
              Arrow[{extEnds[v], coords[v]}],
              Arrow[{coords[v], extEnds[v]}]
            ]}
        ] &,
        external
      ],
      Map[
        With[{p = #[[1]], v = #[[2]], e = extEnds[#[[2]]]},
          Text[Style[ToString[p, InputForm], 15, particleColor[p]],
            e + 0.13 Normalize[e - coords[v]]]
        ] &,
        external
      ],
      {RGBColor[0.36, 0.64, 0.94], EdgeForm[{GrayLevel[0.2], AbsoluteThickness[1.5]}],
        Map[Disk[#, 0.075] &, Values[coords]]},
      KeyValueMap[Text[Style[ToString[#1], 13, Black], #2 + {0.11, 0.11}] &, coords]
    },
    PlotRange -> All, PlotRangePadding -> Scaled[0.12], ImageSize -> 420,
    Background -> White
  ],
  Style[title, 16, Black], Bottom
];

ordersTable = Map[
  Function[r, <|
    "attachment labels at vertices 1,...,5" ->
      ToString[r["ExternalOrderAtVertices"], InputForm],
    "vertex carrying p4" -> r["CentralGluonVertex"],
    "p4 at four-valent vertex?" -> r["CentralGluonAtFourValentVertexQ"],
    "one-loop composite HRs" -> r["OneLoopCompositeHiddenRegions"],
    "two-loop generic-MRK HRs" -> r["TwoLoopGenericMRKHiddenRegions"],
    "two-loop composite HRs" -> r["TwoLoopCompositeHiddenRegions"]
  |>],
  summary["OrderRows"]
];

rep = summary["RepresentativeCertificate"];
repTable = Dataset @ {
  <|"quantity" -> "external order at vertices", "value" ->
    ToString[rep["ExternalOrderAtVertices"], InputForm]|>,
  <|"quantity" -> "aligned superleading polynomial", "value" ->
    -(X45hat Q4hat2/(zetaHat zetaBarHat))
      (X34hat x2 - x3) (x1 x4 - x0 x5)|>,
  <|"quantity" -> "cancellation generator", "value" ->
    (X34hat x2 - x3) (x1 x4 - x0 x5)|>,
  <|"quantity" -> "alignment scaling", "value" -> rep["FaceScaling"]|>,
  <|"quantity" -> "HRF scaling", "value" -> rep["HRFScaling"]|>,
  <|"quantity" -> "total scaling", "value" -> rep["TotalScaling"]|>,
  <|"quantity" -> "relative total scaling", "value" -> rep["RelativeTotalScaling"]|>,
  <|"quantity" -> "raw superleading weight W_SL", "value" -> rep["WSL"]|>,
  <|"quantity" -> "resolved physical weight W_HR", "value" -> rep["WHR"]|>,
  <|"quantity" -> "weight gap", "value" -> rep["HierarchyGap"]|>,
  <|"quantity" -> "resolved facet rank / required", "value" ->
    {rep["ResolvedFacetRank"], rep["RequiredFacetRank"]}|>,
  <|"quantity" -> "final audit", "value" -> rep["AuditStatus"]|>
};

correctedMomentumTable = readableTable @ Map[
  Function[edge, <|
    "edge" -> edge,
    "(q+,q-,q_perp) powers" ->
      correctedPowerResult["EdgeComponentPowers", edge],
    "q^2 power" ->
      correctedPowerResult["PropagatorVirtualityPowers", edge]
  |>],
  {x0, x1, x2, x3, x4, x5}
];
correctedPowerTable = readableTable @ {
  <|"representation" -> "parameter space", "measure power" -> -20,
    "LP factor" -> "delta^(4D)", "integral power" -> "4D-20"|>,
  <|"representation" -> "momentum space", "measure power" -> "4D+1",
    "denominator reciprocal power" -> -21, "integral power" -> "4D-20"|>
};

seedVariables = {x0, x1, x2, x3, x4, x5};
pinchMomentumTable = readableTable @ Map[
  Function[edge, <|
    "edge momentum" -> edge,
    "(q+,q-,q_perp) powers in the full-depth region" ->
      pinchMomentumResult["EdgeComponentPowers"][edge],
    "virtuality realization" ->
      pinchMomentumResult["VirtualityRealizationTypes"][edge],
    "q^2 power" ->
      pinchMomentumResult["PropagatorVirtualityPowers"][edge]
  |>],
  seedVariables
];
pinchCheckTable = readableTable @ {pinchMomentumResult["Checks"]};
fullDepthTable = readableTable @ {KeyTake[pinchMomentumResult,
  {"CertificationLevel", "TotalScaling", "RawSuperleadingPower", "ScalefulLPWeight",
   "AlignmentDepth", "FinalHRFGap", "TotalCancellationDepth",
   "IndependentEdgeBasisChoice", "CandidateGlauberRerouting"}]};
poleSensitivityTable = readableTable @ polePinchResult["EllPlusSensitivityRows"];
polePairTable = readableTable @ {
  <|
    "pinching edge" -> x4,
    "ell-plus coefficient" -> "-q4^-",
    "physical half-plane" -> "upper",
    "pole-neighbourhood power" ->
      polePinchResult["PolePair"]["PoleSeparationPower"]
  |>,
  <|
    "pinching edge" -> x5,
    "ell-plus coefficient" -> "+q5^-",
    "physical half-plane" -> "lower",
    "pole-neighbourhood power" ->
      polePinchResult["PolePair"]["PoleSeparationPower"]
  |>
};
loopWidthTable = readableTable @ {
  <|
    "loop coordinate" -> "r=q0",
    "central powers" -> pinchMomentumResult["EdgeComponentPowers"][x0],
    "local fluctuation widths" ->
      polePinchResult["OtherLoopLocalFluctuationWidths"],
    "measure power" -> polePinchResult["OtherLoopMeasurePower"],
    "mode" -> "homogeneous"
  |>,
  <|
    "loop coordinate" -> "ell=q0-q4",
    "central powers" -> polePinchResult["EllCentralValuePowers"],
    "local fluctuation widths" ->
      polePinchResult["EllLocalFluctuationWidths"],
    "measure power" -> polePinchResult["GlauberLoopMeasurePower"],
    "mode" -> "Glauber"
  |>
};
powerCountingTable = Dataset @ {
  <|
    "representation" -> "parameter space",
    "measure power" -> powerResult["ParameterMeasurePower"],
    "integrand power" ->
      powerResult["ParameterIntegralPower"] -
        powerResult["ParameterMeasurePower"],
    "total scalar power" -> powerResult["ParameterIntegralPower"],
    "status" -> "certified"
  |>,
  <|
    "representation" -> "momentum space",
    "measure power" -> powerResult["MomentumMeasurePower"],
    "integrand power" -> -Total[powerResult["PropagatorVirtualityPowers"]],
    "total scalar power" -> powerResult["MomentumIntegralPower"],
    "status" -> powerResult["MomentumPowerStatus"]
  |>
};
pent = hrf5MRKPentagonData[{1, 2, 3, 4, 5}];
seedNoHR = hrf5MRKSeedData[{1, 2, 3, 4, 5}];
seed = hrf5MRKSeedData[{1, 2, 3, 5, 4}];
(* Standard physical scattering frame used throughout the comparison:
   p2 enters upper-left, p1 enters lower-left; p3,p4,p5 leave on the
   right in decreasing rapidity order. *)
pentCoords = <|1 -> {-0.9, -0.75}, 2 -> {-0.9, 0.75}, 3 -> {0.7, 0.75},
  4 -> {0.95, 0.0}, 5 -> {0.7, -0.75}|>;
pentEnds = <|1 -> {-1.9, -0.95}, 2 -> {-1.9, 0.95}, 3 -> {1.9, 1.0},
  4 -> {1.9, 0.0}, 5 -> {1.9, -1.0}|>;

seedNoHRCoords = <|1 -> {-0.9, -0.75}, 2 -> {-0.9, 0.75},
  3 -> {0.65, 0.75}, 4 -> {0.95, 0.0}, 5 -> {0.65, -0.75}|>;
seedNoHREnds = <|1 -> {-1.9, -0.95}, 2 -> {-1.9, 0.95}, 3 -> {1.9, 1.0},
  4 -> {1.9, 0.0}, 5 -> {1.9, -1.0}|>;

(* Keep the internal vertices fixed in the same canonical geometry as the
   spacelike-collinear seed.  Only the external attachments change. *)
seedCoords = seedNoHRCoords;
seedEnds = <|1 -> {-1.9, -0.95}, 2 -> {-1.9, 0.95}, 3 -> {1.9, 1.0},
  5 -> {1.9, 0.0}, 4 -> {1.9, -1.0}|>;
graphPanel = GraphicsRow[
  {
    makeGraphDiagram[pentCoords, pent["InternalLines"], pent["ExternalLines"],
      pentEnds, "one-loop pentagon: no HR", {1, 1, 1, 1, 1},
      ConstantArray[1/2, 5]],
    makeGraphDiagram[seedNoHRCoords, seedNoHR["InternalLines"], seedNoHR["ExternalLines"],
      seedNoHREnds, "two-loop seed: p4 at vertex 4, no HR",
      {1, 1, -1, -1, 1, -1}, {0.28, 0.5, 0.5, 0.28, 0.5, 0.5}],
    makeGraphDiagram[seedCoords, seed["InternalLines"], seed["ExternalLines"],
      seedEnds, "two-loop seed: p4 at four-valent vertex 5, HR",
      {1, 1, -1, -1, 1, -1}, {0.3, 0.48, 0.5, 0.3, 0.35, 0.5}]
  }, ImageSize -> 1100, Spacings -> 12
];

(* Draw every HR-positive attachment labeling in one common physical frame.
   The internal vertex positions, vertex numbers and x_e labels remain fixed
   in the canonical seed geometry.  The external endpoints alone follow the
   physical order p2,p1 on the left and p3,p4,p5 on the right. *)
hrOrders = Lookup[
  Select[
    summary["OrderRows"],
    Lookup[#, "TwoLoopCompositeHiddenRegions", 0] > 0 &
  ],
  "ExternalOrderAtVertices"
];

physicalParticleCoords = <|
  1 -> {-0.9, -0.75}, 2 -> {-0.9, 0.75}, 3 -> {0.65, 0.75},
  4 -> {0.95, 0.0}, 5 -> {0.65, -0.75}
|>;
physicalParticleEnds = <|
  1 -> {-1.9, -0.95}, 2 -> {-1.9, 0.95}, 3 -> {1.9, 1.0},
  4 -> {1.9, 0.0}, 5 -> {1.9, -1.0}
|>;

hrGraphPanel = GraphicsGrid[
  Partition[
    Map[
      Function[order,
        Module[{data, coords, ends, p4Vertex},
          data = hrf5MRKSeedData[order];
          coords = seedNoHRCoords;
          ends = AssociationThread[Range[5], Lookup[physicalParticleEnds, order]];
          p4Vertex = First @ FirstPosition[order, 4];
          makeGraphDiagram[
            coords, data["InternalLines"], data["ExternalLines"], ends,
            "attachments " <> ToString[order, InputForm] <>
              ";  p4 at vertex " <> ToString[p4Vertex],
            {1, 1, -1, -1, 1, -1},
            {0.30, 0.42, 0.58, 0.70, 0.38, 0.62}
          ]
        ]
      ],
      hrOrders
    ],
    2
  ],
  ImageSize -> 1100,
  Spacings -> {16, 22}
];

exactRules = hrf5MRKExactCentralSoftRules[1, 2, 1];
leadingChecks = {
  HoldForm[s12] -> P M/delta^4,
  HoldForm[s34] -> P R/(K delta),
  HoldForm[s45] -> K M/delta,
  HoldForm[s23] -> -T,
  HoldForm[s15] -> -(T + C delta + R delta^2),
  HoldForm[Abs[p4perp]^2] -> R delta^2
};

rapidityScalingTable = Dataset @ {
  <|"particle" -> "p3", "p+" -> "delta^(-b)", "p-" -> "delta^b",
    "|p_perp|" -> "order 1", "rapidity" -> "-b log(delta)"|>,
  <|"particle" -> "p4", "p+" -> "delta^a", "p-" -> "delta^a",
    "|p_perp|" -> "delta^a", "rapidity" -> "order 1"|>,
  <|"particle" -> "p5", "p+" -> "delta^b", "p-" -> "delta^(-b)",
    "|p_perp|" -> "order 1", "rapidity" -> "b log(delta)"|>
};

invariantComparisonTable = Dataset @ {
  <|"limit" -> "ordinary MRK: x=delta^2; s1,s2 fixed",
    "s12" -> "delta^(-4)", "s34" -> "delta^(-2)",
    "s45" -> "delta^(-2)", "s23,s15" -> "order 1"|>,
  <|"limit" -> "central-soft composite: x=delta^2; s1,s2~delta",
    "s12" -> "delta^(-4)", "s34" -> "delta^(-1)",
    "s45" -> "delta^(-1)", "s23,s15" -> "order 1"|>
};

setupCode = "$HRF5MRKNotebookDirectory = NotebookDirectory[]\n$HRF5MRKSupportDirectory = If[FileExistsQ[FileNameJoin[{$HRF5MRKNotebookDirectory, \"HRF_FivePointMRKExploratory.wl\"}]], $HRF5MRKNotebookDirectory, FileNameJoin[{$HRF5MRKNotebookDirectory, \"examples\", \"five_point_mrk_central_soft\"}]]\n$HRF5MRKRepoDirectory = If[FileExistsQ[FileNameJoin[{$HRF5MRKNotebookDirectory, \"HiddenRegionFinder.wl\"}]], $HRF5MRKNotebookDirectory, DirectoryName[DirectoryName[$HRF5MRKSupportDirectory]]]\n$HRF5MRKLibraryOnly = True\nGet[FileNameJoin[{$HRF5MRKSupportDirectory, \"HRF_FivePointMRKExploratory.wl\"}]]\nFivePointMRKSummary = Get[FileNameJoin[{$HRF5MRKSupportDirectory, \"certified_summary.wl\"}]]";

cells = {
  Cell["Five-point MRK with a central-soft composite limit", "Title"],
  txt["Exact-kinematics asymptotic-order-alignment audit. Evaluate cells in order in a fresh Mathematica 15.0.1 kernel. The compact outputs below are saved so that the physics conclusion can be read without rerunning the scans."],

  sec["1. Result at a glance"],
  txt["Generic five-point MRK and the composite limit p4_perp -> 0 are not the same expansion. In the scan recorded here, all inequivalent one-loop pentagon attachment labelings have no hidden region. The two-loop six-propagator seed has no certified hidden region in generic MRK, but has one in the composite limit for six of the twelve inequivalent graph attachment labelings. Those six are exactly the labelings in which the central gluon p4 is attached to internal vertex 3 or 5, the two four-valent vertices of the seed graph. These graph labelings are not alternative rapidity orderings: every row uses y3 >> y4 >> y5."],
  outCell[Dataset @ {KeyTake[summary, {"MathematicaVersion", "OrderCount",
    "OneLoopCompositeHROrderCount", "TwoLoopGenericMRKHROrderCount",
    "TwoLoopCompositeHROrderCount", "TopologyCriterionObserved"}]}],

  sec["2. Five-point MRK kinematics"],
  txt["We use the all-outgoing convention -p1,-p2 -> p3,p4,p5. The physical region has s12,s34,s45>0 and s23,s15<0. Ordinary MRK is p3+ >> p4+ >> p5+ and p3- << p4- << p5-, with transverse momenta of the same parametric size. Section 2 of NNLL exploration of the high-energy limit of QCD 2->3 scattering amplitudes writes s12=s/x^2, s34=s2/x, s45=s1/x, s23=t2 and s15=t1."],
  txt["At leading MRK order, p3_perp=-z p4_perp and p5_perp=-(1-z)p4_perp, while |p4_perp|^2=s1 s2/s. Therefore p4_perp -> 0 at fixed momentum transfers is correlated: z and zbar diverge, p3_perp=-p5_perp at the limiting surface, and t1=t2 there."],

  subsec["Exact common chart"],
  txt["Use w=-p3_perp/p4_perp and define zeta=-1/w=p4_perp/p3_perp, together with its barred partner. Let Q4^2=|p4_perp|^2, X34=p3+/p4+ and X45=p4+/p5+. For 0<a<b the central-soft MRK path is"],
  displayCell[{zeta == zetaHat delta^a,
    zetab == zetaBarHat delta^a,
    Subscript[Q, 4]^2 == Q4hat2 delta^(2 a),
    X34 == X34hat delta^(-(a + b)),
    X45 == X45hat delta^(a - b)/
      ((1 + zetaHat delta^a) (1 + zetaBarHat delta^a))}],
  txt["All hatted quantities are fixed and nonzero; zetaBarHat is the complex conjugate of zetaHat in the physical domain. In particular, zetaHat and zetaBarHat need not be equal, so zeta/zetabar remains generic. The denominator in X45 preserves the exact on-shell path. The parity-odd invariant is epsilon5=s12 Q4^2 (zeta-zetabar)/(zeta zetabar), so its normalized value tends to zero as delta^a."],
  txt["This limit starts directly from generic five-point kinematics. It does not first impose the coplanar condition zeta=zetabar. Near-planar wide-angle scattering instead sends zeta-zetabar to zero at fixed Q4^2; central-soft MRK sends Q4^2 to zero at fixed transverse angle while maintaining the rapidity hierarchy. The two limiting algebraic structures may be compared, but neither limit is a sublimit of the other."],
  subsec["Physical rapidity and softness scaling"],
  txt["The rapidity hierarchy is transparent in the light-cone components. Since delta tends to zero and 0<a<b, p3 is forward, p5 is backward and p4 remains at finite central rapidity:"],
  outCell[rapidityScalingTable],
  txt["For the representative choice (a,b)=(1,2), y3=-2 log(delta), y4=O(1), and y5=2 log(delta). Thus y3 >> y4 >> y5. At the same time p4 is genuinely soft: both of its light-cone components and its transverse momentum vanish as delta. This violates the generic-MRK condition that all three transverse momenta be comparable, while preserving the multi-Regge rapidity ordering."],
  txt["The leading terms reproduce the Section-2 MRK variables with s=P M, s2=(P R/K) delta^a, s1=(K M) delta^a and s1 s2/s=R delta^(2a). Unlike a leading-only substitution, this exact chart retains every subleading layer that asymptotic-order alignment may promote."],
  displayCell[leadingChecks],
  txt["The apparently unusual invariant powers follow immediately. In ordinary MRK with x=delta^2, s1 and s2 are fixed and s34,s45 scale as delta^(-2). In the central-soft path, s1 and s2 themselves scale as delta, so s34=s2/x and s45=s1/x scale only as delta^(-1). The transfers s23 and s15 remain finite; s15 is not a large subenergy."],
  outCell[invariantComparisonTable],
  Cell[CellGroupData[{
    subsec["Exact equivalence with the earlier light-cone audit"],
    txt["The certified runs were originally expressed with finite coefficients P,K,M,R,T,C. They are exactly the same path under Q4hat2=R, X34hat=P/K, X45hat=K M/T, zetaHat zetaBarHat=R/T and zetaHat+zetaBarHat=sigma C/T. The physical domain P,M,K,R,T,C>0 and C^2<4 R T, with both transverse signs sigma checked, supplies an explicit positivity realization. This section is retained as an equivalence audit, not as a second definition of the limit."],
    inCell["hrf5MRKExactCentralSoftRules[1, 2, 1]", "In[1]:="],
    outCell[exactRules, "Out[1]="],
    displayCell[{Q4hat2 == R, X34hat == P/K, X45hat == K M/T,
      zetaHat zetaBarHat == R/T,
      zetaHat + zetaBarHat == sigma C/T}]
  }, Closed]],

  sec["3. Graphs and edge variables"],
  txt["Every diagram is drawn in the same physical scattering frame: p2 and p1 enter from the upper- and lower-left; p3, p4 and p5 emerge on the right in decreasing rapidity order. The internal vertices remain fixed in the canonical geometry of the spacelike-collinear seed; crossed external lines are crossings, not vertices. The first two diagrams are negative controls. The last two have the same internal two-loop topology but different external attachment labelings: moving the central emission p4 from vertex 4 to the four-valent vertex 5 changes the result from no HR to HR. Edge parameters x0,x1,... follow the order of InternalLines printed below."],
  outCell[graphPanel],
  subsec["Why the four-valent attachment is special"],
  txt["The distinction is already visible on the leading face exposed by the natural alignment phi=(-3,-3,0,-3,-3,-3). When p4 is emitted from the trivalent middle vertex 4, the aligned face is"],
  displayCell[Subscript[F, mid]^align ==
    -(X45hat Q4hat2/(zetaHat zetaBarHat)) x1
      ((X34hat x2 - x3) x4 + X34hat x2 x5)],
  txt["The bracket may vanish for positive parameters, but its x5 derivative is X34hat x2>0. Hence the zero is not stationary and is not a positive Landau pinch. The unmatched term X34hat x2 x5 records that the soft leg was inserted in the middle of one particular theta path."],
  txt["When p4 is attached instead to the four-valent theta endpoint 5, the corresponding face factorizes:"],
  displayCell[Subscript[F, end]^align ==
    -(X45hat Q4hat2/(zetaHat zetaBarHat))
      (X34hat x2 - x3) (x1 x4 - x0 x5)],
  txt["The simultaneous zero of the two routing differences is stationary: for a product A B, d(A B)=B dA+A dB vanishes when A=B=0. At the endpoint all three theta paths remain available, so the two-loop flow can rebalance in two independent ways. Inserting p4 in the middle of a path distinguishes that path and prevents the second rebalancing. The full twelve-attachment scan confirms that no alternative aligned face restores a pinch for a trivalent attachment."],
  inCell["hrf5MRKPentagonData[{1,2,3,4,5}][\"InternalLines\"]", "In[2]:="],
  outCell[pent["InternalLines"], "Out[2]="],
  inCell["hrf5MRKSeedData[{1,2,3,5,4}][\"InternalLines\"]", "In[3]:="],
  outCell[seed["InternalLines"], "Out[3]="],

  sec["4. Scan over inequivalent graph attachment labelings"],
  txt["The rapidity hierarchy is always p3 forward, p4 central, p5 backward. Only their attachment to the fixed internal graph is varied. Rotations and reversal of the internal graph are quotiented out by fixing p1 at vertex 1. The table is an interior-plus-recursive-boundary scan: the pinch preselection is allowed to force Schwinger parameters to zero. A zero therefore means that no certified interior or induced boundary HR was found within the enumerated asymptotic faces."],
  outCell[Dataset[ordersTable]],
  subsec["The six attachment labelings with a hidden region"],
  txt["The following are precisely the six rows for which the composite central-soft limit has a certified HR. In each caption the attachment vector lists the external-particle labels carried by internal vertices 1,...,5, in that order. Every panel uses the same physical orientation: p2 and p1 enter from the left, while p3, p4 and p5 leave on the right in decreasing rapidity order. Internal vertex labels are fixed. In every panel the Schwinger parameters are x0:(1,3), x1:(1,5), x2:(2,3), x3:(2,5), x4:(3,4), x5:(4,5); only the external-particle attachments change."],
  outCell[hrGraphPanel],
  txt["The composite result is unchanged between the two transverse sign charts sigma=+1 and sigma=-1. It is also unchanged for (a,b)=(1,2),(1,3),(2,3), covering approach-rate ratios a/b=1/2,1/3,2/3."],
  outCell[readableTable[summary["TransverseSignChecks"]]],
  outCell[readableTable[summary["RateChecks"]]],

  sec["5. Representative hidden-region certificate"],
  txt["For the two-loop seed with external order {1,2,3,5,4} and (a,b)=(1,2), asymptotic-order alignment exposes the factorised superleading polynomial shown below. The singular locus is the simultaneous pair of polynomial conditions X34hat x2-x3=0 and x1 x4-x0 x5=0, with positive solutions. It is not the statement that either monomial vanishes."],
  outCell[repTable],
  txt["The displayed polynomial is the coefficient of the delta^(-10) layer after alignment alone. The immediately following layer remains nonzero on the cancellation locus:"],
  displayCell[Subscript[F, -9]^align ==
    -(Q4hat2/(zetaHat zetaBarHat)) x0 x3 x4],
  txt["The alignment vector is phi=(-3,-3,0,-3,-3,-3), and the second-stage HRF vector is rho=(-1,-1,-1,-1,-1,-1). Their composition gives the hard-scale-normalized region vector (x0,x1,x2,x3,x4,x5;delta)=(-4,-4,-1,-4,-4,-4;1), with (W_SL,W_HR)=(-9,-8). Factoring out the growing hard scale s12 defines this dimensionless convention. Adding +4 uniformly converts to dimensionful Schwinger parameters while s12 varies, but that non-negative representative is not the infrared HRF vector. The resolved support has affine rank 6, equal to the required rank, so this is one scaleful lower facet. The other two staged presentations fail that final test."],

  sec["6. Momentum-space reconstruction and scalar power counting"],
  txt["The hard-scale-normalized vector gives propagator virtuality powers (4,4,1,4,4,4). A component assignment compatible with every vertex is:"],
  outCell[correctedMomentumTable],
  txt["With r=q0 and ell=q0-q4, q0/q1 pinch r-plus with width delta^4, q4/q5 pinch ell-plus with width delta^4, and q2/q3 pinch ell-minus with width delta. Both transverse widths scale as delta^2. Thus r has local widths (4,0,2) and ell has widths (4,1,2), giving two-loop measure power 4D+1. The denominator powers sum to 21."],
  txt["In parameter space use A=x2-X34hat^(-1) delta^3 x3 and B=x1 x4-x0 x5. The HRF gap gives wt(A)=0 while wt(B)=-8. Four tangential coordinates contribute -16 and the Jacobian -1/x0 contributes +4, so the measure has power -20. The resolved LP polynomial of weight -8 contributes delta^(4D)."],
  outCell[correctedPowerTable],
  displayCell[Subscript[I, CS]^(scalar) == delta^(4 D - 20) == delta^(-4 - 8 epsilon)],
  txt["The two representations therefore agree for the dimensionless integral with s12 factored out. Restoring the overall engineering-dimension factor s12^(D-6) is a separate conversion and must not be used to redefine the infrared region vector."],

(* Superseded momentum reconstruction and power count.  Retained in the
   builder temporarily as a regression record, but excluded from the
   generated notebook until it is rederived from W_SL=-9, W_HR=-8. *)
(*
  sec["Previous momentum-space reconstruction of the hidden region"],
  txt["For each edge write (q_e^+,q_e^-,q_e_perp)~(delta^a_e,delta^b_e,delta^c_e). Momentum conservation is imposed component by component at every vertex. The propagator virtualities are read from the inverse of the full LP scaling, not from the uniformly shifted relative vector. The relevant total aligned-plus-HRF vector is (-4,-4,-1,-4,-4,-4), hence q_e^2 has powers (4,4,1,4,4,4). Near-on-shell cancellation between longitudinal and transverse terms is retained where required."],

  subsec["Algorithm and assumptions"],
  txt["For an ordinary facet, the procedure is: fix an exact light-cone chart for the external momenta; infer every propagator virtuality inversely from the facet vector; solve the virtuality and tropical vertex-conservation constraints for all edges; prefer branches with direct homogeneous on-shell realization; then choose an independent chord basis and power count its fluctuation widths. This is calibrated by the spacelike-collinear facet below."],
  txt["For a hidden region these steps are only necessary. One must use the total aligned-plus-HRF vector, impose the positive cancellation ideal at coefficient level, and determine the widths transverse to the pinch. All independent loop bases and affine reroutings must then be tested. For a selected light-cone component, write every Feynman denominator in the adapted loop basis, retain the propagators whose dependence on that component is leading, and solve for their poles including the i0 prescription. A pair approaching from opposite half-planes fixes the local integration width. Power counting uses this width, not merely the central edge valuation."],

  subsec["Calibration on the five-point spacelike-collinear example"],
  txt["Before interpreting this MRK solution, the same routine was tested on the published two-loop five-point spacelike-collinear graph. For the facet vector (-2,0,-2,-2,-2,0;1), it gives two ordinary collinear loop modes and no transverse-dominated rerouting. For the hidden-region vector (-2,-1,-2,-2,-2,-1;1), the individual edge momenta q0 and q4 are soft, but momentum conservation forces their difference q0-q4 to scale as (delta,delta^2,delta). This is precisely the Glauber loop shown in Fig. 1(c) of the paper; after the split in Fig. 1(d), it is carried by a propagator. Thus the test correctly detects a Glauber loop that is absent from the list of individual propagator modes. Absence of a Glauber propagator is not an absence test for a Glauber loop."],

  subsec["Complete edge-flow table and its certification level"],
  txt["The relative vector (-3,-3,0,-3,-3,-3) records the non-uniform direction of the final facet, but it is insufficient for absolute momentum reconstruction. In the original exact chart the total vector is (-4,-4,-1,-4,-4,-4), so the target propagator virtualities are (4,4,1,4,4,4). The following table reports every edge, not only a selected loop basis. It is a valuation-level solution of the virtuality and tropical vertex constraints; near-on-shell enhanced entries still require coefficient-level control."],
  outCell[fullDepthTable],
  outCell[pinchMomentumTable],
  outCell[pinchCheckTable],
  txt["The edge momenta q0 and q3 are one convenient independent chord basis. Neither is Glauber. Introduce instead r=q0 and ell=q0-q4. Momentum conservation gives q2=p3-ell, q3=ell+p2-p3, q4=r-ell and q5=p5-r+ell. The central value of ell scales as (delta^2,delta^2,1), but the local widths must be obtained separately."],

  subsec["The ell-plus pole pinch"],
  txt["Four propagators depend algebraically on ell-plus. At a local fluctuation Delta ell-plus~delta^6, however, the q2 and q3 dependence is subleading: their ell-plus coefficients have power 3 and would enter only at power 9. The q4 and q5 coefficients have power -2, so their variation enters at power 4, exactly their certified virtuality power. Thus precisely q4 and q5 participate in the leading ell-plus pinch."],
  outCell[poleSensitivityTable],
  txt["With q4^-=r^--ell^->0 and q5^-=p5^--r^-+ell^->0 on the physical positive-flow branch, the Feynman +i0 prescription puts the q4 pole above and the q5 pole below the real ell-plus axis. Both poles approach the same real value within delta^6. Equivalently, virtuality power 4 minus slope power -2 gives Delta ell-plus~delta^6."],
  outCell[polePairTable],
  txt["The residual q2=p3-ell fixes Delta ell-minus~delta^3 and Delta ell-perp~delta^2. Consequently ell has local widths (6,3,2). Since 6+3>2*2, this is a genuine transverse-dominated Glauber integration mode. There is one Glauber loop, not two. Its central powers (2,2,0) and its fluctuation widths (6,3,2) are deliberately shown in separate columns. For the other loop, q0 and q1=p1-r analogously pinch r-plus between opposite half-planes and confirm Delta r-plus~delta^6."],
  outCell[loopWidthTable],
  outCell[readableTable @ {polePinchResult["Checks"]}],

  sec["7. Independent parameter- and momentum-space power certificates"],
  txt["Parameter space gives the cleanest absolute count. For the total graph-edge vector v=(-4,-4,-1,-4,-4,-4), Sum_e v_e=-21. Restriction to the simultaneous cancellation neighbourhood restores five powers of delta, so the effective measure power is -21+5=-16. The scaleful LP polynomial has weight -8 and therefore P^(-D/2) contributes delta^(4D). The unit-numerator scalar integral consequently scales as delta^(4D-16)=delta^(-8 epsilon) for D=4-2 epsilon."],
  txt["Momentum space now gives the same result independently. The r widths (6,-2,2) give measure power 2D. The pinched Glauber widths (6,3,2) give 2D+5. The two-loop measure is therefore 4D+5. The six propagator powers sum to 21, so the scalar integral scales as delta^(4D+5-21)=delta^(4D-16)=delta^(-8 epsilon). No additional cancellation-depth factor is inserted in momentum space: its effect is already encoded in the restricted local loop widths."],
  outCell[powerCountingTable],
  outCell[KeyTake[powerResult,
    {"TotalGraphEdgeVector", "RawSuperleadingFPower",
     "ScalefulLPWeight", "AlignmentDepth", "FinalHRFGap",
     "TotalCancellationDepth", "PropagatorVirtualityPowers",
     "GlauberCentralValue", "GlauberLocalFluctuationWidths",
     "OtherLoopLocalFluctuationWidths", "LeadingEllPlusPinchEdges",
     "EllPlusPoleSeparationPower", "PowerAtD4Minus2Eps",
     "MomentumPowerCertifiedQ", "MomentumPowerStatus"}]],
*)

  sec["7. Negative controls and interpretation"],
  txt["All twelve one-loop pentagon labelings fail already at the recursive mixed-derivative pinch preselection for each of the three tested rates. Generic MRK gives no certified HR for any labeling of the two-loop seed: six labelings produce staged near-misses, but the lower-facet audit rejects them. The exact central-soft corrections change the occupied layers and turn one of the three staged presentations into a full facet precisely when p4 is attached to a four-valent seed vertex."],
  txt["This establishes that the earlier blanket statement 'there is no HR in five-point MRK' is not correct once the central-soft composite limit is included. What is established here is narrower: one specific two-loop seed family and all its inequivalent external labelings. A topology scan of its vertex-split descendants is the natural next step."],

  sec["8. Reproduction"],
  inCell[setupCode, "In[4]:="],
  txt["Run one targeted certificate with the command below in a terminal from this directory. The last arguments are order index, chart, a, b, topology."],
  Cell["wolframscript -file HRF_FivePointMRKTargetedRun.wl 2 exact-soft-plus 1 2 seed", "Program"],
  Cell["wolframscript -file HRF_RunFivePointMRKAllLabelFullLayerAudit.wl 1 2 plus", "Program"],
  txt["Rebuild the compact summary and this notebook with:"],
  Cell["wolframscript -file HRF_FivePointMRKBuildSummary.wl\nwolframscript -file rebuild_five_point_mrk_notebook.wl", "Program"]
};

nb = Notebook[
  cells,
  WindowSize -> {1280, 900},
  StyleDefinitions -> "Default.nb",
  WindowTitle -> "FivePoint_MRK_CentralSoft_AsymptoticAlignment",
  CellLabelAutoDelete -> False,
  ShowCellTags -> False
];

out = FileNameJoin[{base, "FivePoint_MRK_CentralSoft_AsymptoticAlignment.nb"}];
saveNotebook[out, nb];
Print["Exported ", out];

topOut = FileNameJoin[{repo, "08_Current_5pt_MRK_CentralSoft.nb"}];
saveNotebook[topOut, nb];
Print["Exported ", topOut];
