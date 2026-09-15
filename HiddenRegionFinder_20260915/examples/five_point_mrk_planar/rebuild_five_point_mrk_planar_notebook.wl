(* Rebuild the readable simultaneous-MRK-plus-planarity notebook. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
result = Get[FileNameJoin[{base, "results", "equal_rate_audit.wl"}]];
rateTable = Get[FileNameJoin[{base, "results", "rate_table.wl"}]];
attachmentAudit = Get[FileNameJoin[{base, "results", "attachment_audit.wl"}]];
momentumAudit = Get[FileNameJoin[{base, "results", "momentum_mode_audit.wl"}]];

ClearAll[titleCell, sectionCell, subCell, textCell, inputCell, formulaCell];
titleCell[s_] := Cell[s, "Title"];
sectionCell[s_] := Cell[s, "Section", CellGroupingRules -> {"SectionGrouping", 50}];
subCell[s_] := Cell[s, "Subsection"];
textCell[s_] := Cell[s, "Text"];
inputCell[s_] := Cell[s, "Input", InitializationCell -> False];
formulaCell[expr_] := Cell[BoxData @ ToBoxes[TraditionalForm[expr]],
  "DisplayFormula"];

fishGraphic = Graphics[
  {
    AbsoluteThickness[2], Black,
    Line[{{-1.2, 1.0}, {1.0, 0.75}}],
    Line[{{-1.2, 1.0}, {1.0, -0.75}}],
    Line[{{-1.2, -0.9}, {1.0, 0.75}}],
    Line[{{-1.2, -0.9}, {1.0, -0.75}}],
    Line[{{1.0, 0.75}, {0.0, -1.65}}],
    Line[{{0.0, -1.65}, {1.0, -0.75}}],
    AbsolutePointSize[7], Point[{{-1.2, 1.0}, {-1.2, -0.9},
      {1.0, 0.75}, {0.0, -1.65}, {1.0, -0.75}}],
    AbsoluteThickness[1.7],
    Line[{{-1.2, 1.0}, {-2.1, 1.35}}],
    Line[{{-1.2, -0.9}, {-2.1, -1.25}}],
    Line[{{1.0, 0.75}, {2.0, 1.15}}],
    Line[{{1.0, -0.75}, {2.0, -0.55}}],
    Line[{{0.0, -1.65}, {0.55, -2.3}}],
    Text[Style["x0", 13], {-0.05, 1.06}],
    Text[Style["x1", 13], {-0.02, 0.02}],
    Text[Style["x2", 13], {-0.35, -0.02}],
    Text[Style["x3", 13], {0.15, -0.72}],
    Text[Style["x4", 13], {0.72, -0.38}],
    Text[Style["x5", 13], {0.38, -1.27}],
    Text[Style["p1", 14], {-2.25, 1.48}],
    Text[Style["p2", 14], {-2.25, -1.38}],
    Text[Style["p3", 14], {2.12, 1.23}],
    Text[Style["p4", 14], {2.12, -0.48}],
    Text[Style["p5", 14], {0.65, -2.42}]
  }, PlotRange -> {{-2.55, 2.4}, {-2.6, 1.65}}, ImageSize -> 500
];

modeGraphic = Graphics[
  {
    AbsoluteThickness[4], Darker[Green, .18],
    BezierCurve[{{5, 8}, {3.25, 7.0}, {2, 3}}],
    BezierCurve[{{5, 2}, {3.25, 3.0}, {2, 3}}],
    AbsoluteThickness[4], RGBColor[.45, .5, .1],
    BezierCurve[{{5, 8}, {3.2, 8.0}, {2, 7}}],
    BezierCurve[{{5, 2}, {3.2, 4.2}, {2, 7}}],
    AbsoluteThickness[4], Teal,
    BezierCurve[{{5, 8}, {7.1, 7.5}, {8, 5}}],
    BezierCurve[{{5, 2}, {7.1, 2.5}, {8, 5}}],

    AbsoluteThickness[2], Darker[Green, .18], Arrow[{{0, 2}, {2, 3}}],
    AbsoluteThickness[2], RGBColor[.45, .5, .1], Arrow[{{0, 8}, {2, 7}}],
    AbsoluteThickness[2], RGBColor[.45, .5, .1], Arrow[{{5, 8}, {7, 9}}],
    AbsoluteThickness[2], Teal,
    Arrow[BezierCurve[{{8, 5}, {9.3, 3.2}, {10, 1}}]],
    AbsoluteThickness[6], White,
    BezierCurve[{{5, 2}, {7.3, 3.0}, {10.3, 5.2}}],
    AbsoluteThickness[2], Blue,
    Arrow[BezierCurve[{{5, 2}, {7.3, 3.0}, {10.3, 5.2}}]],

    Black, PointSize[.018], Point[{{2, 3}, {2, 7}, {8, 5}}],
    Blue, PointSize[.026], Point[{{5, 8}, {5, 2}}],
    Text[Style["p1", 13, Darker[Green, .18]], {-.25, 1.65}],
    Text[Style["p2", 13, RGBColor[.45, .5, .1]], {-.25, 8.35}],
    Text[Style["p3", 13, RGBColor[.45, .5, .1]], {7.15, 9.18}],
    Text[Style["p4", 13, Blue], {10.45, 5.55}],
    Text[Style["p5", 13, Teal], {10.15, .62}],

    Text[Style["q0: (3,-1,1)", 11, Background -> White], {3.5, 6.25}],
    Text[Style["q1: (3,-1,1)", 11, Background -> White], {3.3, 2.15}],
    Text[Style["q2: (-1,3,1)", 11, Background -> White], {3.35, 8.2}],
    Text[Style["q3: (0,3,1)", 11, Background -> White], {3.35, 4.45}],
    Text[Style["q4: (1,-1,0)", 11, Background -> White], {6.8, 7.45}],
    Text[Style["q5: (1,-1,0)", 11, Background -> White], {6.8, 2.55}]
  }, PlotRange -> {{-.7, 10.6}, {.25, 9.55}}, ImageSize -> 620
];

modeGrid = Grid[
  Prepend[
    KeyValueMap[{#1, Row[#2, "  "], 2,
        momentumAudit["EqualRateRegionVirtualityPowers"][#1]} &,
      momentumAudit["EqualRateEdgeComponentPowers"]],
    {"edge", "central (plus, minus, transverse)",
     "saddle q_e^2 power", "region q_e^2 power"}
  ], Frame -> All, Alignment -> Left,
  Background -> {None, {Lighter[Gray, .88], None}}
];

comparison = Grid[
  Prepend[
    {
      {"Near-planar wide angle", "fixed wide-angle invariants",
       "(0,0,0)", "(-2,-2,-2,-2,-2,-2;1)",
       "one symmetric cancellation level: -6 -> -4"},
      {"MRK plus planarity (a=b=1)",
       "two standard MRK gaps; fixed transverse scales",
       "(0,1,0)", "(-2,-2,-1,-2,-2,-2;1)",
       "two levels: -7,-6 -> -4"},
      {"Central-soft rapidity ordered",
       "soft p4 transverse scale and asymmetric rapidity ordering",
       "different two-factor locus", "(-4,-4,-1,-4,-4,-4;1)",
       "-9 -> -8"}
    },
    {"Expansion", "Kinematic path", "powers of (rhoA,rhoB,rhoC)",
     "original-coordinate vector", "cancellation weights"}
  ],
  Frame -> All, Alignment -> Left, Spacings -> {1.1, 0.8},
  Background -> {None, {Lighter[Gray, .88], None, None, None}}
];

attachmentGrid = Grid[
  {
    {"attachment order at vertices 1,...,5", "four-valent endpoints",
     "location of p4", "positive stationary point?"},
    {"{1,2,3,5,4} (representative)", "{p3,p4}",
     "endpoint 5", "yes"},
    {"{1,2,4,5,3} (endpoint reflection)", "{p4,p3}",
     "endpoint 3", "yes"},
    {"{1,2,3,4,5} (rapidity symmetric)", "{p3,p5}",
     "trivalent path vertex 4", "no"}
  }, Frame -> All, Alignment -> Left, Spacings -> {1.1, 0.8},
  Background -> {None, {Lighter[Gray, .88], None, None, None}}
];

rateGrid = Grid[
  Prepend[
    ({#a, #b, Row[#OriginalVector, "  "], #WHR, #AffineRank,
        #CertifiedQ} & /@ rateTable),
    {"a", "b", "v=(v0,...,v5;1)", "WHR", "rank", "facet?"}
  ], Frame -> All, Alignment -> Left,
  Background -> {None, {Lighter[Gray, .88], None}}
];

nb = Notebook[
  {
    titleCell["Five-point MRK plus near-planarity"],
    Cell["A simultaneous fixed-transverse multi-Regge and coplanar-limit audit",
      "Subtitle"],
    textCell["This notebook studies the two-loop six-edge fish topology in a composite limit in which both rapidity gaps become large while the transverse configuration approaches the coplanar boundary.  It places this limit on the same footing as the wide-angle near-planar and central-soft rapidity-ordered expansions.  All vectors are displayed as (v0,...,v5;1), including the expansion-parameter component."],

    sectionCell["1. Definition of the composite limit"],
    textCell["We start from the exact on-shell light-cone chart used for general five-point kinematics.  The outgoing transverse momenta are p3_perp=q, p4_perp=k and p5_perp=-q-k.  Pp, Kp, Mm, Q2 and xi are fixed and positive.  Two independent positive integers a and b control the approach to planarity and the MRK rapidity growth, respectively."],
    formulaCell[HoldForm[{p3plus, p4plus, p5minus} ==
      {Pp delta^(-b), Kp, Mm delta^(-b)}]],
    formulaCell[HoldForm[{k2, q2, twoqdotk} ==
      {Q2, Q2 (1/xi^2 + delta^(2 a)/4), 2 Q2/xi}]],
    formulaCell[HoldForm[{w, wbar} ==
      {-1/xi + I delta^a/2, -1/xi - I delta^a/2}]],
    textCell["Both rapidity gaps therefore scale in the standard fixed-transverse MRK manner.  Planarity is projective: the dimensionful Gram determinant contains the growing hard scale, but exactly Gamma5/s12^2=-Q2^2 delta^(2a).  It is this normalized quantity that tends to zero."],

    sectionCell["2. Topology, attachment and invariant stationary form"],
    textCell["The graph is a theta graph with paths A=(x0,x1), B=(x2,x3), C=(x4,x5).  Its four-valent endpoint vertices are 3 and 5; vertices 1, 2 and 4 lie in the interiors of the three paths and are trivalent after attaching an external leg.  The calculation below uses external attachment order {1,2,3,5,4}: p3 and p4 occupy the four-valent endpoints, while the backward extremal parton p5 is attached to the trivalent vertex 4.  It is therefore not the rapidity-symmetric attachment."],
    Cell[BoxData @ ToBoxes[fishGraphic], "Output"],
    Cell[BoxData @ ToBoxes[attachmentGrid], "Output"],
    textCell["The distinction is dynamical, not presentational.  An exact scan of the twelve inequivalent attachment orders finds a positive stationary point only for the representative order and its endpoint reflection.  In the superficially natural rapidity-symmetric order {1,2,3,4,5}, the extremal partons p3 and p5 occupy the four-valent endpoints and p4 is emitted from the trivalent path vertex.  Its stationary ratios instead behave as"],
    formulaCell[HoldForm[{rhoA, rhoB, rhoC} ∼
      {-(Kp Mm xi/Q2) delta^(-b),
       (Kp (1 + xi)/(Pp xi)) delta^b, -(1 + xi)}]],
    textCell["Two ratios are negative for all positive physical parameters, so this attachment has no positive first-sheet pinch on the coplanar MRK path.  The endpoint-reflected positive order has the same facet after x0<->x1, x2<->x3 and x4<->x5; its exceptional component is v3=b-2a rather than v2=b-2a."],
    textCell["Define qAB=s12-s34-s45, qBC=-s12-s23+s45 and qCA=s23.  The three stationary ratios rho solve the invariant linear system K rho=-ell.  With fA=x0-rhoA x1 and cyclic analogues, the exact massless polynomial is"],
    formulaCell[HoldForm[F == qAB x5 fA fB + qBC x1 fB fC +
      qCA x3 fC fA + Gamma5 x1 x3 x5/(4 qAB qBC qCA)]],
    textCell["The audit verifies this identity directly against the Symanzik polynomial in adjacent Mandelstam invariants."],

    sectionCell["3. The moving positive Landau locus"],
    textCell["In this composite limit the stationary point is not fixed in projective Schwinger space.  Its ratios behave as"],
    formulaCell[HoldForm[{rhoA, rhoB, rhoC} ∼
      {xi, (Kp/Pp) delta^b, xi}]],
    textCell["All three leading coefficients are positive for the physical parameter domain.  The middle ratio approaches a boundary at the MRK rate.  This moving Landau locus is the origin of the unequal x2 component in the final vector."],

    sectionCell["4. Local facet and cancellation layers"],
    textCell["Introduce tangential coordinates uI and normal coordinates nI by"],
    formulaCell[HoldForm[{x0, x1, x2, x3, x4, x5} ==
      {rhoA uA + nA, uA, rhoB uB + nB, uB, rhoC uC + nC, uC}]],
    textCell["The exact lower-facet scaling in these coordinates is"],
    formulaCell[HoldForm[{uA, uB, uC, nA, nB, nC} ∼
      {delta^(-2 a), delta^(-2 a), delta^(-2 a),
       delta^(-a), delta^(-a + 2 b), delta^(-a)}]],
    textCell["Pulling this back to the original variables gives"],
    formulaCell[HoldForm[vMRKPlanar ==
      {-2 a, -2 a, b - 2 a, -2 a, -2 a, -2 a, 1}]],
    textCell["The qAB and qBC sectors occur first at W=-6a-b and lose 2a+b powers through cancellation.  The qCA sector occurs at W=-6a and loses 2a powers.  Both reach WHR=-4a, where U and the Gram-normal term also enter.  Thus the equal-rate path has two cancellation layers, -7 and -6, before the resolved weight -4."],
    subCell["Exact equal-rate certificate"],
    Cell[BoxData @ ToBoxes @ Grid[
      {
        {"original vector", Row[result["OriginalCoordinateRegionVector"], "  "]},
        {"local vector", Row[result["LocalCoordinateRegionVector"], "  "]},
        {"leading monomials", result["LeadingMonomialCount"]},
        {"affine rank", result["LeadingAffineRank"]},
        {"full lower facet", result["FullLowerFacetCertificateQ"]},
        {"Gamma identity", result["Gamma5IdentityQ"]},
        {"invariant decomposition", result["InvariantStationaryDecompositionIdentityQ"]}
      }, Frame -> All, Alignment -> Left], "Output"],
    textCell["The seven leading monomials span affine rank six in the six local variables.  This is the necessary full-dimensional lower-facet certificate; the result is not inferred merely from a candidate scaling vector."],
    subCell["Parameter-space power count"],
    textCell["For unit propagator powers, the six local measures contribute delta^(-9a+2b).  Since the resolved Lee-Pomeransky polynomial has weight -4a, its power -D/2 contributes delta^(2a D).  Therefore"],
    formulaCell[HoldForm[IntegralScaling == delta^(-9 a + 2 b + 2 a D)]],
    textCell["At equal rates and D=4-2 epsilon this is delta^(1-4 epsilon).  The epsilon-dependent exponent confirms that this is an infrared region even though the scalar integral is power suppressed in this dimensionful MRK chart."],
    subCell["Momentum-space mode reconstruction"],
    textCell["For the positive representative attachment the equal-rate Landau saddle has the following component valuations.  Exactly at the saddle every propagator has virtuality O(delta^2).  The Schwinger vector nevertheless requires q2^2=O(delta) across the local integration region, so this dependent edge has one additional cancellation precisely at the saddle; that fact alone does not compare a mode-adapted independent loop momentum with its width."],
    Cell[BoxData @ ToBoxes[modeGrid], "Output"],
    Cell[BoxData @ ToBoxes[modeGraphic], "Output"],
    textCell["Dark green, olive and teal distinguish the three theta-path collinear flows A, B and C.  The displayed edge triples are central saddle values; the table separately records the region virtualities.  The blue external line is the fixed-transverse central parton p4, while the blue discs mark the two hard four-valent vertices that delimit the collinear paths.  Each collinear path mode keeps one shade throughout: A/p1 is dark green, B/p2,p3 is olive, and C/p5 is teal.  Although p1 and p5 approach the same backward direction in MRK, the A- and C-path momenta have distinct global-frame component scalings and are separated by hard interactions; they are therefore not assigned the same mode colour.  The outgoing legs are arranged top-to-bottom in their MRK rapidity order p3,p4,p5.  The crossing of the two lower external lines changes only the drawing, not the graph attachment.  There is no independent Glauber loop and therefore no Glauber vertex marker.  A path-adapted independent basis uses the A and C flows.  In their respective local lightcone frames both central values and marginal widths scale as (2a+b,-b,a), and each loop measure contributes delta^(a D).  Momentum conservation restricts their correlated longitudinal support by delta^(3a+b)."],
    formulaCell[HoldForm[MomentumScaling ==
      delta^(a D) delta^(a D) delta^(3 a + b)
        delta^(-(12 a - b)) ==
      delta^(-9 a + 2 b + 2 a D)]],
    textCell["This exactly reproduces the parameter-space count.  The endpoint-reflected positive attachment is obtained by x0<->x1, x2<->x3 and x4<->x5; the path colours and absence of a Glauber loop are unchanged."],

    sectionCell["5. Dependence on the relative rates"],
    textCell["The formula is stable when the two rates are varied.  The table evaluates the analytic support formula; the exact equal-rate row is independently reconstructed from the complete local Lee-Pomeransky polynomial above."],
    Cell[BoxData @ ToBoxes[rateGrid], "Output"],

    sectionCell["6. Comparison of the three five-point paths"],
    Cell[BoxData @ ToBoxes[comparison], "Output"],
    textCell["For the representative attachment, the simultaneous MRK-plus-planarity region is best viewed as a kinematic degeneration and reweighting of the same three-normal coplanar Landau family that produces its wide-angle Landshoff region.  It is not the central-soft region: the latter uses a different kinematic path and a different factorized cancellation locus.  Nor does the result extend to the rapidity-symmetric attachment, which fails positivity before the facet analysis."],

    sectionCell["7. Relation to the current HRF wrapper"],
    textCell["The generic asymptotic-alignment scan exposes the relevant face, but presently harvests only a single product factor there.  Its staged composition then fails the facet test.  The exact three-normal local audit proves that this is a limitation of that wrapper, not absence of the region.  This notebook is therefore also a regression target for extending the general alignment-plus-harvest interface."],

    sectionCell["8. Reproducibility"],
    textCell["The following cells load the stored exact results.  The second cell reruns the full symbolic equal-rate parameter audit; on Mathematica 15.0 it takes roughly one minute on the development machine.  The third reruns the exact momentum-mode and power-counting audit."],
    inputCell["result = Get[FileNameJoin[{NotebookDirectory[], \"results\", \"equal_rate_audit.wl\"}]];\nKeyTake[result, {\"OriginalCoordinateRegionVector\", \"LayerWeights\", \"LeadingMonomialCount\", \"LeadingAffineRank\", \"FullLowerFacetCertificateQ\"}]"],
    inputCell["$HRF5MRKPlanarLibraryOnly = True;\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_FivePointMRKPlanarCompositeAudit.wl\"}]];\nexactEqualRateAudit = hrf5MRKPlanarAudit[1, 1];"],
    inputCell["$HRF5MRKPlanarMomentumAuditLibraryOnly = True;\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_FivePointMRKPlanarMomentumAudit.wl\"}]];\nmomentumAudit = hrf5MRKPlanarMomentumAudit[];"]
  },
  WindowTitle -> "FivePoint_MRK_Planar_Composite_Limit",
  StyleDefinitions -> "Default.nb",
  TaggingRules -> <|
    "Purpose" -> "Simultaneous five-point MRK and planarity HR audit",
    "GeneratedBy" -> "rebuild_five_point_mrk_planar_notebook.wl",
    "Date" -> "2026-08-04"
  |>
];

out = FileNameJoin[{base, "FivePoint_MRK_Planar_Composite_Limit.nb"}];
Export[out, nb];
Print[out];
