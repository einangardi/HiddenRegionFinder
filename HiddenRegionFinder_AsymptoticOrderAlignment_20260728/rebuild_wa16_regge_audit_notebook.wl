(* Build the separate self-contained Regge notebook for the 16 No-Crown
   four-loop graphs. *)

SetDirectory[DirectoryName[$InputFileName]];
$HRFRunWideAngle16NoCrownAuditOnLoad = False;
Get["HRF_WideAngle16NoCrownAudit.wl"];
Get["HRF_WideAngle16ReggeBoundaryAudit.wl"];

ClearAll[textCell, inputCell, outputCell, sectionGroup, resultGrid,
  drawReggeAuditGraph];
textCell[s_String] := Cell[s, "Text"];
SetAttributes[inputCell, HoldAll];
inputCell[e_] := Cell[BoxData @ ToBoxes[HoldForm[e]], "Input"];
outputCell[e_] := Cell[BoxData @ ToBoxes[e], "Output"];
sectionGroup[t_String, cells_List, state_: Open] :=
  CellGroupData[Prepend[cells, Cell[t, "Section"]], state];
resultGrid[d_] := Grid[d, Frame -> All, Alignment -> Left,
  Background -> {None, {LightGray, None}}, BaseStyle -> {FontSize -> 11}];

rawRecords = hrfWA16ParseDiagramRecords[hrfWA16InputFile[]];
records = hrfWA16BuildData /@ rawRecords;
recordAssociation = Association[Map[#ID -> # &, records]];
interiorSummary = Get["results/wa16_regge_interior_v1_summary.wl"];
interiorExactClasses = Get["results/wa16_regge_interior_v1_exact_classes.wl"];
permutationClasses = Get[
  "results/wa16_regge_interior_v1_permutation_classes.wl"
];
boundarySummary = Get["results/wa16_regge_boundary_v1_summary.wl"];
boundaryClassRows = Get[
  "results/wa16_regge_boundary_v1_class_summary.wl"
];
boundaryChannelRows = Get[
  "results/wa16_regge_boundary_v1_channel_summary.wl"
];
boundaryRegression = Get[
  "results/wa16_regge_boundary_v1_regression.wl"
];

drawReggeAuditGraph[rec_Association] := Module[
  {internal, external, intEdges, extEdges, labels, styles, externalVertices},
  internal = rec["InternalLines"][[All, 2]];
  external = rec["ExternalLines"];
  intEdges = UndirectedEdge @@@ internal;
  extEdges = (UndirectedEdge[#[[2]], #[[1]]] &) /@ external;
  labels = AssociationThread[intEdges,
    MapIndexed[Placed[Style[Subscript[x, First[#2] - 1], 10], Center] &,
      intEdges]];
  styles = Join[
    AssociationThread[intEdges,
      ConstantArray[Directive[GrayLevel[.3], AbsoluteThickness[1.5]],
        Length[intEdges]]],
    AssociationThread[extEdges,
      ConstantArray[Directive[Gray, Dashed], Length[extEdges]]]
  ];
  externalVertices = external[[All, 1]];
  Graph[Join[intEdges, extEdges],
    EdgeLabels -> Normal[labels], EdgeStyle -> Normal[styles],
    VertexLabels -> Placed["Name", Center],
    VertexStyle -> Table[
      v -> If[MemberQ[externalVertices, v], LightBlue, White],
      {v, VertexList[Graph[Join[intEdges, extEdges]]]}
    ],
    VertexSize -> .28, GraphLayout -> "SpringEmbedding", ImageSize -> 390,
    PlotLabel -> Style["diagram " <> ToString[rec["ID"]], 12, Bold]
  ]
];

allCases = Flatten @ Map[
  Function[exact,
    Append[KeyTake[#, {"ID", "Channel", "PropagatorCount"}],
      "PermutationClass" -> exact["PermutationAuditClass"]] & /@
      exact["Members"]
  ],
  interiorExactClasses
];

interiorClassRows = Table[
  rep = permutationClasses[[i, "Representative"]];
  exact = SelectFirst[
    interiorExactClasses,
    #["Representative"]["ID"] === rep["ID"] &&
      #["Representative"]["Channel"] === rep["Channel"] &
  ];
  audit = exact["Audit"];
  <|
    "Class" -> i,
    "Representative" -> rep,
    "FullMultiplicity" -> boundaryClassRows[[i, "GraphChannelMultiplicity"]],
    "F0Terms" -> audit["ReggeF0TermCount"],
    "Faces" -> audit["FaceCount"],
    "SameSignDerivative" -> Lookup[
      audit["FaceStatusCounts"], "RejectedBySignDefiniteDerivative", 0
    ],
    "FarkasCertificate" -> Lookup[
      audit["FaceStatusCounts"],
      "RejectedByPositiveDerivativeCombination", 0
    ],
    "Accepted" -> audit["PositivePinchFaceCount"],
    "Unresolved" -> audit["UnresolvedFaceCount"]
  |>,
  {i, Length[permutationClasses]}
];

mappingClassRows = Table[
  members = SortBy[
    Select[allCases, #["PermutationClass"] === i &],
    {#ID &, #Channel &}
  ];
  memberLabels =
    (ToString[#ID] <> "/" <> #Channel & /@ members);
  <|
    "Class" -> i,
    "Representative" -> permutationClasses[[i, "Representative"]],
    "PropagatorCount" -> boundaryClassRows[[i, "PropagatorCount"]],
    "Members" -> Column[
      StringRiffle[#, ", "] & /@ Partition[memberLabels, UpTo[4]],
      Spacings -> .25
    ],
    "Multiplicity" -> Length[members]
  |>,
  {i, Length[permutationClasses]}
];

summaryGrid = resultGrid @ {
  {"quantity", "result"},
  {"graphs", boundarySummary["GraphCount"]},
  {"Regge channels", boundarySummary["ChannelCount"]},
  {"graph/channel interiors", interiorSummary["GraphChannelCount"]},
  {"interior hidden-region cases",
    interiorSummary["HiddenRegionGraphChannelCount"]},
  {"expanded nonempty contraction strata",
    boundarySummary["ExpandedBoundaryCount"]},
  {"boundary hidden-region strata",
    boundarySummary["HiddenRegionStratumCount"]},
  {"unresolved interior or boundary faces",
    interiorSummary["UnresolvedFaceCount"] +
      boundarySummary["UnresolvedFaceCount"]},
  {"conclusion", "No No-Crown HR in the full three-channel Regge audit"}
};

channelDefinitionGrid = resultGrid @ {
  {"label", "small invariant t", "large invariant s", "delta=-t/s",
    "strict substitution"},
  {"T23", s23, s12, -s23/s12, s23 -> 0},
  {"T12", s12, s23, -s12/s23, s12 -> 0},
  {"T13", s13, s12, -s13/s12, s23 -> -s12}
};

mappingClassGrid = resultGrid @ Prepend[
  ({#Class, #Representative, #PropagatorCount, #Members, #Multiplicity} & /@
    mappingClassRows),
  {"audit class", "directly audited representative", "propagators E",
    "represented diagram/channel cases", "number of represented cases"}
];

interiorAuditGrid = resultGrid @ Prepend[
  ({#Class, #Representative, #F0Terms, #Faces,
      #SameSignDerivative, #FarkasCertificate, #Accepted, #Unresolved} & /@
    interiorClassRows),
  {"audit class", "directly audited representative",
    "F_Regge,0 monomials", "Newton faces tested",
    "rejected: same-sign derivative",
    "rejected: Farkas separating combination",
    "accepted HR faces", "unresolved faces"}
];

farkasMappingGrid = resultGrid @ {
  {"course notation", "object in the HRF face test"},
  {"N_a", "coefficient row of monomial m_a across all logarithmic derivatives L_i"},
  {"alpha_a (renamed lambda_a here)", "the induced positive monomial value m_a(x,kappa), not an independent Schwinger parameter"},
  {"eta", "the unrestricted derivative-combination coefficients c_i"}
};

boundaryClassGrid = resultGrid @ Prepend[
  ({#PermutationClass, #Representative, #GraphChannelMultiplicity,
      #PropagatorCount, #CodimensionRange, #RepresentativeBoundaryCount,
      Lookup[#RepresentativeCertificateCounts,
        "InheritedParentInteriorFaceClosure", 0],
      Lookup[#RepresentativeCertificateCounts,
        "GlobalSubtractionFreeFirstNonzeroReggeLayer", 0],
      Lookup[#RepresentativeCertificateCounts,
        "TrivialRestrictedReggePolynomial", 0],
      #HiddenRegionStratumCount, #UnresolvedFaceCount} & /@
    boundaryClassRows),
  {"class", "representative", "full multiplicity", "E", "codimensions",
    "direct boundaries", "inherited q=0", "sign-definite q=1", "trivial",
    "HR", "unresolved"}
];

channelGrid = resultGrid @ Prepend[
  ({#Channel, #GraphCount, #BoundaryCount,
      Lookup[#CertificateCounts, "InheritedParentInteriorFaceClosure", 0],
      Lookup[#CertificateCounts,
        "GlobalSubtractionFreeFirstNonzeroReggeLayer", 0],
      Lookup[#CertificateCounts, "TrivialRestrictedReggePolynomial", 0],
      #HiddenRegionStratumCount, #UnresolvedFaceCount} & /@
    boundaryChannelRows),
  {"channel", "graphs", "boundaries", "inherited q=0",
    "sign-definite q=1", "trivial", "HR", "unresolved"}
];

mapGrid = resultGrid @ Prepend[
  ({#ID, #Channel, #PropagatorCount, #PermutationClass} & /@
    SortBy[allCases, {#PermutationClass &, #ID &, #Channel &}]),
  {"diagram", "channel", "E", "audit class"}
];

definitionGrid = resultGrid @ Prepend[
  ({#ID, Length[#InternalLines], #InternalLines, #ExternalLines} & /@
    rawRecords),
  {"ID", "E", "ordered internal edges (x0,x1,...)",
    "external attachments"}
];

polynomialInventory = Flatten @ Table[
  rec = records[[i]];
  Table[
    <|
      "ID" -> rec["ID"], "Channel" -> channel,
      "U terms" -> Length[MonomialList[rec["U"], rec["Vars"]]],
      "FRegge0 terms" -> Length[hrfWA16PolyTerms[
        hrfWA16ReggeLeadingPolynomial[rec["F0"], channel]]],
      "delta-layer term counts" -> Map[
        Length[hrfWA16PolyTerms[#]] &,
        hrfWA16ReggeLayers[rec["F0"], channel]
      ]
    |>,
    {channel, {"T23", "T12", "T13"}}
  ],
  {i, Length[records]}
];
polynomialGrid = resultGrid @ Prepend[
  ({#ID, #Channel, #["U terms"], #["FRegge0 terms"],
      #["delta-layer term counts"]} & /@ polynomialInventory),
  {"ID", "channel", "U terms", "strict Regge F terms",
    "suppressed-layer terms"}
];

allGraphPanels = Column[
  Row[#, Spacer[20]] & /@
    Partition[drawReggeAuditGraph /@ rawRecords, UpTo[2]],
  Spacings -> 1.1
];

notebook = Notebook[{
  Cell["Regge hidden-region audit of the 16 four-loop No-Crown graphs",
    "Title"],
  Cell["Interior and every contraction boundary in T23, T12 and T13 - 23 July 2026",
    "Subtitle"],
  textCell["Purpose. This notebook is a self-contained Regge record for the sixteen four-loop massless 2->2 graphs that have mixed-sign derivative factors but no three-loop Crown contraction minor. It defines the three limits, reconstructs the graph polynomials, states the exact graph/channel maps, and records both the interior and complete boundary certificates."],

  sectionGroup["1. Final result", {
    outputCell[summaryGrid],
    textCell["The statement is complete for this graph sample: all 48 interiors and all 343356 nonempty contraction strata through E-2 are resolved. No face is left undecided. Together with the independent wide-angle audit of the same graphs, this supports the wide-angle-to-Regge conjecture through four loops for this complete No-Crown sample."],
    textCell["This is evidence for the conjecture, not a general theorem. Regge specialization can delete a kinematic sector and may expose a face that was absent at wide angle. The boundary proof below identifies exactly why that possibility does not occur here."]
  }],

  sectionGroup["2. Regge kinematics", {
    textCell["All external momenta are algebraically incoming and s13=-s12-s23. A Regge channel holds one invariant s fixed and writes its spacelike transfer as t=-delta s with delta>0. The three conventions used by HRF are:"],
    outputCell[channelDefinitionGrid],
    textCell["After division by the indicated large invariant, the polynomial has the form F/s=F_Regge,0+delta F_Regge,1. The audit keeps the absolute delta power when a contraction annihilates F_Regge,0; it never silently resets the relative weight of U."],
    inputCell[Get["HRF_Example02ReggeKinematics.wl"];
      hrfReggeChannelAssociation[]]
  }],

  sectionGroup["3. Graphs and polynomial definitions", {
    textCell["The ordered internal edge list defines x0,x1,... . Setting xi=0 contracts that edge. SymanzikUF constructs U and the second Symanzik polynomial; makeFourPointOnShellF0 then imposes massless four-point kinematics. The displayed lists therefore determine every expression used below."],
    outputCell[definitionGrid],
    inputCell[SetDirectory[NotebookDirectory[]];
      $HRFRunWideAngle16NoCrownAuditOnLoad = False;
      Get["HRF_WideAngle16NoCrownAudit.wl"];
      Get["HRF_WideAngle16ReggeBoundaryAudit.wl"];
      rawRecords = hrfWA16ParseDiagramRecords[hrfWA16InputFile[]];
      records = hrfWA16BuildData /@ rawRecords;]
  }],

  sectionGroup["4. Mapping the three channels", {
    textCell["There is no universal T23<->T12<->T13 map within a fixed labelled graph. For example, 85774/T23 maps to 85774/T13, but 85774/T12 belongs to another class; the three channels of 105230 are all distinct parent classes. Exact graph relabellings and explicit Schwinger-variable permutations nevertheless reduce the 48 cases first to twelve exact triples and then to six audit-invariant classes."],
    textCell["The certified object is {F_Regge,0, delta layers, U}. F_Regge,0 agrees exactly up to one overall sign under the recorded permutation, while the delta layers and U have identical exponent supports. This is precisely the information used by the pinch and hierarchy audit."],
    textCell["Each row below is one equivalence class. The directly audited representative is written as diagram/channel. The member column lists every one of the 48 diagram/channel cases transported to that representative; the final column is only the number of those cases, not a diagram symmetry factor or an amplitude multiplicity."],
    outputCell[mappingClassGrid],
    CellGroupData[{
      Cell["All 48 graph/channel assignments", "Subsection"],
      outputCell[mapGrid],
      inputCell[Get["results/wa16_regge_interior_v1_permutation_classes.wl"]]
    }, Closed]
  }],

  sectionGroup["5. Interior face/pinch audit and Landau certificates", {
    textCell["This is now a separate audit table. Its face counts refer to the directly audited representative only; they are not multiplied by the number of represented diagram/channel cases. For each representative, every exposed face of the strict Regge-leading Newton polytope was enumerated. A face was rejected by a same-sign derivative, by a Farkas separating combination, or, if necessary, by the exact positive pinch equations and oriented hierarchy LP."],
    outputCell[interiorAuditGrid],
    textCell["After multiplication by the class sizes, 11093616 faces are covered: 11084880 are rejected by a same-sign derivative and 8736 by the Farkas separating certificate. No nonlinear solve remains unresolved."],
    CellGroupData[{
      Cell["Farkas theorem in the course formulation and its use here", "Subsection"],
      textCell["Course formulation. Given real vectors N_a, exactly one of the following holds: (1) there is a vector eta such that eta.N_a>0 for every a; or (2) there are numbers alpha_a>=0, not all zero, such that sum_a alpha_a N_a=0. Thus a strict separating direction and a nontrivial positive dependence are mutually exclusive."],
      textCell["Connection with the first sheet. The x_e used here are precisely the projective Schwinger (Feynman) parameters. A first-sheet Landau solution has x_e>=0; on an interior stratum all x_e>0, while a boundary stratum has some x_e=0 and is treated after contracting those edges. The physical Regge channel is also written in coordinates kappa_r>0, with all physical signs placed in the polynomial coefficients."],
      textCell["For a proposed cancellation face F_SL, define L_e=x_e dF_SL/dx_e. On an interior stratum x_e>0, so the equations L_e=0 are equivalent to the ordinary Landau stationarity equations dF_SL/dx_e=0."],
      textCell["Write L_e=sum_a M_(a e) m_a(x,kappa) in the common monomial basis and define N_a=(M_(a 1),...,M_(a E)). Every monomial has the form m_a=product_e x_e^(n_(a e)) product_r kappa_r^(p_(a r)); hence first-sheet positivity x_e>0 together with kappa_r>0 implies m_a(x,kappa)>0."],
      textCell["To avoid confusing the course coefficients alpha_a with the conventional Schwinger parameters, call them lambda_a in this application. Set lambda_a=m_a(x,kappa)>0. The Landau equations then become sum_a lambda_a N_a=0. Thus the nonnegative dependence in alternative (2) is induced by Schwinger-parameter positivity: the lambda_a are positive monomials in the Schwinger and physical kinematic coordinates, not an additional set of independent Landau parameters."],
      outputCell[farkasMappingGrid],
      textCell["The audit searches for unrestricted real coefficients c_e such that c.N_a>=0 for every a and c.N_a>0 for at least one a; it also permits the overall opposite sign. This is a weak separating direction. It is already sufficient because, if a first-sheet pinch existed, 0=c.(sum_a lambda_a N_a)=sum_a lambda_a(c.N_a)>0, a contradiction. The strict alternative (1) in the course statement is the special case in which every scalar product is positive."],
      textCell["Equivalently, P=sum_e c_e L_e is a nonzero polynomial whose monomial coefficients all have one sign, so P cannot vanish anywhere in the positive Schwinger domain. Notice that the c_e need not be positive. First-sheet positivity belongs to the x_e and consequently to the induced lambda_a=m_a(x,kappa). The label 'positive-combination certificate' was therefore misleading and has been replaced by 'Farkas separating combination'. A same-sign individual derivative is the simplest instance of the same contradiction."],
      textCell["This is where the physical premise that a hidden region originates at a Landau singularity enters the negative proof. For an interior face all x_i are positive. Cases with some x_i=0 are not discarded by this premise: every such set is treated as a separate contraction stratum in the complete boundary audit of Sections 6 and 7, and positivity is imposed only on the remaining active parameters."],
      textCell["The certificate is sufficient, not an alternative definition of a Landau singularity. Faces for which no such separating combination exists are passed to the explicit positive solution of the Landau equations and then to the hierarchy test."]
    }, Open],
    textCell["The three-loop Crown is the positive control: its leading Regge polynomial factorizes into the complementary minor factors and exactly one face survives in each channel, with hierarchy gap one. Thus the method distinguishes the known seed from all sixteen No-Crown interiors."],
    inputCell[Get["HRF_WideAngle16ReggeInteriorAudit.wl"];
      hrfWA16ReggeInteriorAudit[recordAssociation[85774], "T23"]]
  }],

  sectionGroup["6. Why almost every boundary was already proved", {
    textCell["Let P be the exponent support of the parent strict Regge polynomial. Contracting a set S of Schwinger parameters and retaining a nonzero delta^0 polynomial selects P_S={a in P: a_i=0 for every i in S}. Because all exponents are nonnegative, P_S is the coordinate face minimizing sum_{i in S} a_i. Every exposed face of P_S is therefore already an exposed face of P."],
    textCell["The pinch equations also agree. The restricted F_SL depends only on active variables, so its derivatives with respect to contracted variables vanish identically; a positive solution in the active variables would extend to a positive solution of the parent face equations. Since the parent audit found no positive or unresolved face, every nonzero delta^0 restriction is closed without constructing a second face lattice."],
    textCell["This is the exact mechanism by which the interior calculation can be reused for boundaries. It is stronger and safer than transferring a wide-angle negative verdict directly to Regge kinematics."]
  }],

  sectionGroup["7. Exceptional boundaries with vanishing delta^0 layer", {
    textCell["The only genuinely new possibility is a contraction for which the entire delta^0 coefficient vanishes. The first surviving coefficient is then at delta^1. Its absolute power must be retained: relative to this F layer, U has eta=-1 in the augmented hierarchy. The code implements that general LP even though no such LP is needed for the final negative result."],
    textCell["For every exceptional No-Crown contraction, the delta^1 coefficient is subtraction-free up to one overall sign. Consequently it has no positive cancellation hypersurface and no hidden region. The three exact boundary certificates partition all 343356 strata:"],
    outputCell[boundaryClassGrid],
    outputCell[channelGrid],
    textCell["After expansion to the full graph list, each channel contains exactly 114452 boundaries with the same totals: 46520 inherited coordinate-face certificates, 12640 sign-definite delta^1 certificates and 55292 trivial restricted polynomials."],
    inputCell[Get["results/wa16_regge_boundary_v1_summary.wl"]]
  }],

  sectionGroup["8. Positive controls and regression", {
    textCell["The known HyperCrown boundary x11=0 remains positive in the Regge audit, so the inherited and sign-definite shortcuts do not erase genuine boundary seeds. The regression also directly enumerates one inherited coordinate face and checks one exceptional delta^1 contraction."],
    outputCell[resultGrid @ Prepend[
      ({#Test, #PassQ, #Detail} & /@ boundaryRegression["Rows"]),
      {"test", "pass", "detail"}
    ]],
    outputCell[KeyTake[boundaryRegression["HyperCrownControl"],
      {"Channel", "ZeroVars", "LeadingReggeEta", "FaceCount",
       "PositivePinchFaceCount", "UnresolvedFaceCount", "HiddenRegionQ"}]],
    inputCell[Get["HRF_WideAngle16ReggeBoundaryRegressionTests.wl"];
      hrfRunWA16ReggeBoundaryRegressionTests[]]
  }],

  sectionGroup["9. Wide-angle-to-Regge conclusion", {
    textCell["For the Crown, both the wide-angle and Regge limits have a hidden region. For every one of the sixteen No-Crown four-loop graphs, neither the wide-angle audit nor any of the three complete Regge audits has an interior or boundary hidden region. Thus no False->True counterexample occurs anywhere in this sample."],
    textCell["The emerging polynomial criterion is a signed-circuit statement. The Crown retains a balanced factorized circuit after one kinematic sector is suppressed. The No-Crown parent faces have exact derivative certificates; their coordinate subfaces inherit those certificates, while the only new first layers created by contraction are subtraction-free. A general proof of the conjecture would need to show that every positive Regge circuit lifts to an admissible wide-angle circuit, which is not true for arbitrary polynomials and remains a graph-theoretic question."]
  }],

  sectionGroup["10. Graph drawings", {
    textCell["The Schwinger labels follow the ordered internal-edge definitions in Section 3; external legs are dashed."],
    outputCell[allGraphPanels]
  }, Closed],

  sectionGroup["11. Polynomial inventory and reproducibility", {
    outputCell[polynomialGrid],
    inputCell[allReggePolynomials = Association @ Flatten @ Table[
      rec = records[[i]];
      Table[
        {rec["ID"], channel} -> <|
          "Variables" -> rec["Vars"], "U" -> rec["U"],
          "FRegge0" -> hrfWA16ReggeLeadingPolynomial[rec["F0"], channel],
          "DeltaLayers" -> hrfWA16ReggeLayers[rec["F0"], channel]
        |>,
        {channel, {"T23", "T12", "T13"}}
      ],
      {i, Length[records]}
    ]],
    inputCell[RunProcess[{"wolframscript", "-file",
      "run_wa16_regge_interior_regression.wl"}]],
    inputCell[RunProcess[{"wolframscript", "-file",
      "run_wa16_regge_boundary_regression.wl"}]],
    textCell["Primary files: HRF_WideAngle16ReggeInteriorAudit.wl and HRF_WideAngle16ReggeBoundaryAudit.wl contain the exact certificates; run_wa16_regge_boundary_batch.wl is the checkpointed boundary runner; aggregate_wa16_regge_boundary_audit.wl expands the six representatives to all 48 cases. The compact persisted results are in results/wa16_regge_interior_v1_summary.wl and results/wa16_regge_boundary_v1_summary.wl."]
  }, Closed],

  sectionGroup["12. References", {
    textCell["E. Gardi et al., arXiv:2407.13738: original No-Crown evidence and the dissection framework."],
    textCell["E. Gardi et al., arXiv:2607.15126, especially Eqs. (13)-(17): pinch, homogeneous F_SL, ideal presentation and strict hierarchy conditions."]
  }, Closed]
}, WindowTitle -> "No-Crown four-loop Regge HRF audit",
  Saveable -> True, StyleDefinitions -> "Default.nb"];

Put[notebook, "WideAngle16_NoCrown_Regge_HRF_Audit.nb"];
Print["WROTE ", ExpandFileName["WideAngle16_NoCrown_Regge_HRF_Audit.nb"]];
