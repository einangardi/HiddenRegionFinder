(* Build the final self-contained notebook for the exact no-Crown audit. *)

SetDirectory[DirectoryName[$InputFileName]];
$HRFRunWideAngle16NoCrownAuditOnLoad = False;
Get["HRF_WideAngle16NoCrownAudit.wl"];
Get["HRF_WideAngle16FacePinchAudit.wl"];

ClearAll[textCell, inputCell, outputCell, sectionGroup, resultGrid,
  drawWA16Graph];
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
faceSummary = Get["results/wide_angle_16_face_pinch_higher_codim_summary.wl"];
faceRows = faceSummary["Rows"];
regression = Get["results/wide_angle_16_face_pinch_regression.wl"];
crownAudit = regression["CrownAudit"];
farkasAudit = regression["FarkasNoCrownAudit"];
mixedAudit = regression["MixedNoCrownAudit"];
priorSummary = Get["results/wide_angle_16_current_audit_summary.wl"];
boundarySummary = Get["results/wide_angle_16_stored_boundaries_current_gap_summary.wl"];
codim3Summary = Get["results/wide_angle_16_codim3_hierarchy_gap_summary.wl"];
codim3NearMiss = Get["results/wide_angle_16_codim3_nearmiss_105233.wl"];
codim3NearMissTrial = codim3NearMiss["RepresentativeTrial"];
crownFace = First[crownAudit["PositiveOrUnresolvedFaces"]];
farkasFace = First[farkasAudit["RepresentativeDerivativeCombinationFaces"]];

drawWA16Graph[rec_Association, zero_List : {}] := Module[
  {internal, external, intEdges, extEdges, all, zeroIndex, labels, styles,
   externalVertices},
  internal = rec["InternalLines"][[All, 2]];
  external = rec["ExternalLines"];
  intEdges = UndirectedEdge @@@ internal;
  extEdges = (UndirectedEdge[#[[2]], #[[1]]] &) /@ external;
  all = Join[intEdges, extEdges];
  zeroIndex = ToExpression[StringDrop[ToString[#], 1]] & /@ zero;
  labels = AssociationThread[intEdges,
    MapIndexed[Placed[Style[Subscript[x, First[#2] - 1],
      If[MemberQ[zeroIndex, First[#2] - 1], Red, Black], 11], Center] &,
      intEdges]];
  styles = AssociationThread[intEdges,
    MapIndexed[If[MemberQ[zeroIndex, First[#2] - 1],
      Directive[Red, AbsoluteThickness[3]],
      Directive[GrayLevel[.35], AbsoluteThickness[1.5]]] &, intEdges]];
  styles = Join[styles, AssociationThread[extEdges,
    ConstantArray[Directive[Gray, Dashed], Length[extEdges]]]];
  externalVertices = external[[All, 1]];
  Graph[all, EdgeLabels -> Normal[labels], EdgeStyle -> Normal[styles],
    VertexLabels -> Placed["Name", Center],
    VertexStyle -> Table[v -> If[MemberQ[externalVertices, v], LightBlue, White],
      {v, VertexList[Graph[all]]}], VertexSize -> .3,
    GraphLayout -> "SpringEmbedding", ImageSize -> 420,
    PlotLabel -> Style[rec["Name"] <>
      If[zero === {}, "", "   contracted " <> ToString[zero, InputForm]], 12, Bold]]
];

incompleteK43Panel = Module[
  {present, missing, labels, styles, vertexLabels, coordinates},
  present = {
    "a" <-> "e", "a" <-> "g",
    "b" <-> "e", "b" <-> "f", "b" <-> "g",
    "c" <-> "e", "c" <-> "f", "c" <-> "g",
    "d" <-> "f", "d" <-> "g"
  };
  missing = {"a" <-> "f", "d" <-> "e"};
  labels = Association[
    "a" <-> "e" -> Subscript[x, 0], "a" <-> "g" -> Subscript[x, 1],
    "b" <-> "e" -> Subscript[x, 2], "b" <-> "f" -> Subscript[x, 9],
    "b" <-> "g" -> Subscript[x, 10], "c" <-> "e" -> Subscript[x, 4],
    "c" <-> "f" -> Subscript[x, 11], "c" <-> "g" -> Subscript[x, 12],
    "d" <-> "f" -> Subscript[x, 7], "d" <-> "g" -> Subscript[x, 6],
    "a" <-> "f" -> Style["absent", Red, Italic],
    "d" <-> "e" -> Style["absent", Red, Italic]
  ];
  styles = Join[
    AssociationThread[present, ConstantArray[Directive[Black, AbsoluteThickness[1.7]], Length[present]]],
    AssociationThread[missing, ConstantArray[Directive[Red, Dashed, AbsoluteThickness[2]], Length[missing]]]
  ];
  vertexLabels = {
    "a" -> Placed[Style["a = 1", Bold], Center],
    "b" -> Placed[Style["b = {2,7}", Bold], Center],
    "c" -> Placed[Style["c = {3,8}", Bold], Center],
    "d" -> Placed[Style["d = 4", Bold], Center],
    "e" -> Placed[Style["e = 5", Bold], Center],
    "f" -> Placed[Style["f = 9", Bold], Center],
    "g" -> Placed[Style["g = {6,10}", Bold], Center]
  };
  coordinates = {
    "a" -> {0, 3}, "b" -> {0, 2}, "c" -> {0, 1}, "d" -> {0, 0},
    "e" -> {3, 2.7}, "g" -> {3, 1.5}, "f" -> {3, .3}
  };
  Graph[Join[present, missing],
    VertexCoordinates -> coordinates,
    VertexLabels -> vertexLabels,
    VertexStyle -> Join[
      Thread[{"a", "b", "c", "d"} -> LightBlue],
      Thread[{"e", "f", "g"} -> LightYellow]
    ],
    VertexSize -> .38, EdgeLabels -> Normal[labels], EdgeStyle -> Normal[styles],
    ImageSize -> 520,
    PlotLabel -> Style["Contracted topology:  K4,3 minus {a-f, d-e}", 13, Bold]
  ]
];

perGraphRows = Table[
  rr = Select[faceRows, Lookup[#, "ID"] == rec["ID"] &];
  <|"ID" -> rec["ID"], "E" -> Length[rec["InternalLines"]],
    "Codimensions" -> Sort[Lookup[rr, "Codimension"]],
    "Strata" -> Total[Lookup[rr, "ScanCount", 0]],
    "SubtractionFree" -> Total[
      Lookup[Lookup[rr, "CertificateCounts", <||>], "GlobalSubtractionFreeF0", 0]],
    "FaceLattice" -> Total[
      Lookup[Lookup[rr, "CertificateCounts", <||>], "FaceLatticePinch", 0]],
    "DerivativeFaces" -> Total[
      Lookup[Lookup[rr, "FaceStatusCounts", <||>], "RejectedBySignDefiniteDerivative", 0]],
    "FarkasFaces" -> Total[
      Lookup[Lookup[rr, "FaceStatusCounts", <||>],
        "RejectedByPositiveDerivativeCombination", 0]],
    "HR" -> Total[Lookup[rr, "HiddenRegionStratumCount", 0]],
    "Unresolved" -> Total[Lookup[rr, "UnresolvedFaceCount", 0]]|>,
  {rec, rawRecords}
];

summaryGrid = resultGrid @ {
  {"quantity", "value"},
  {"graphs", 16},
  {"codimensions", faceSummary["CodimensionRange"]},
  {"contraction strata", faceSummary["ScannedStratumCount"]},
  {"hidden-region strata", faceSummary["HiddenRegionStratumCount"]},
  {"unresolved faces", faceSummary["UnresolvedFaceCount"]},
  {"complete", faceSummary["CompleteQ"]}
};

lowCodimensionGrid = resultGrid @ {
  {"scope", "objects", "exact near-miss trials", "positive hierarchy gap", "HR", "unresolved"},
  {"16 interiors", 16,
    priorSummary["FourLoop16Interior"]["ValidObstructionTrialCount"], 0,
    priorSummary["FourLoop16Interior"]["HiddenRegionCount"], 0},
  {"codimension 1", First[boundarySummary]["OriginalScanRowCount"],
    First[boundarySummary]["AuditedTrialCount"],
    First[boundarySummary]["PositiveGapTrialCount"], 0, 0},
  {"selected codimension-2 x8 sector", Last[boundarySummary]["OriginalScanRowCount"],
    Last[boundarySummary]["AuditedTrialCount"],
    Last[boundarySummary]["PositiveGapTrialCount"], 0, 0},
  {"all codimension 3", priorSummary["AllCodim3Prefilter"]["ScanCount"],
    codim3Summary["TrialCount"], codim3Summary["PositiveGapTrialCount"], 0,
    priorSummary["AllCodim3Prefilter"]["UnresolvedCount"]}
};

codim3TrialGrid = resultGrid @ {
  {"quantity", "representative value"},
  {"diagram", codim3NearMiss["ID"]},
  {"contracted parameters", codim3NearMiss["ZeroVars"]},
  {"generator g", codim3NearMissTrial["Generator"]},
  {"factorized F_SL", codim3NearMissTrial["FSLFactorized"]},
  {"valid obstruction", True},
  {"strict hierarchy feasible", codim3NearMissTrial["HierarchyFeasibleQ"]},
  {"maximal gap W_HR-W_SL", codim3NearMissTrial["MaxGap"]},
  {"rho variable order", First /@ codim3NearMissTrial["LimitingScaling"]},
  {"limiting oriented vector (rho;1)",
    Append[Last /@ codim3NearMissTrial["LimitingScaling"], 1]},
  {"active post-face sources", codim3NearMissTrial["ActivePostSourceCounts"]}
};

codim3CandidateGrid = resultGrid @ Prepend[
  (Function[row, {
      row["TrialIndex"], row["GeneratorCount"], row["GeneratorsSymbolic"],
      row["ValidObstructionQ"], row["ValidScalingQ"]
    }] /@ codim3NearMiss["TrialSummaries"]),
  {"trial", "generators", "generator polynomials", "obstruction", "strict scaling"}
];

crossingClassGrid = resultGrid @ {
  {"fixed-external-label isomorphism class", "exact trials per graph"},
  {{105230, 105241}, 1},
  {{105231, 105238}, 3},
  {{105232, 105235}, 1},
  {{105233, 105240}, 3},
  {{105234, 105237}, 1},
  {{105236, 105239}, 1}
};

graphResultGrid = resultGrid @ Prepend[
  ({#ID, #E, #Codimensions, #Strata, #SubtractionFree, #FaceLattice,
      #DerivativeFaces, #FarkasFaces, #HR, #Unresolved} & /@ perGraphRows),
  {"ID", "E", "codimensions", "strata", "subtraction-free strata",
    "face-lattice strata", "sign-derivative faces", "Farkas faces", "HR", "unresolved"}
];

definitionGrid = resultGrid @ Prepend[
  ({#ID, Length[#InternalLines], #InternalLines, #ExternalLines} & /@ rawRecords),
  {"ID", "E", "ordered internal edges (x0,x1,...)", "external attachments"}
];

polynomialInventoryGrid = resultGrid @ Prepend[
  ({#ID, Length[#Vars], Length[MonomialList[#U, #Vars]],
      Length[MonomialList[#F0, #Vars]], Max[Keys[hrfDeltaLayerAssociation[#Data["FOnShell"], \[Delta]]]]} &
      /@ records),
  {"ID", "variables", "U terms", "F0 terms", "highest restored delta layer"}
];

allGraphPanels = Column[
  Row[#, Spacer[20]] & /@ Partition[drawWA16Graph /@ rawRecords, UpTo[2]],
  Spacings -> 1.1
];

notebook = Notebook[{
  Cell["Wide-angle four-loop graphs without a Crown minor", "Title"],
  Cell["Complete HRF search record and cap-independent audit — 23 July 2026", "Subtitle"],
  textCell["Question. These 16 massless four-loop 2->2 graphs have mixed-sign derivatives but no three-loop Crown contraction minor. The original conjecture was that they have no hidden regions. This single notebook records the initial interior and low-codimension HRF searches, their closest near miss, and the later cap-independent proof for every contraction stratum from codimension four to the last nontrivial codimension."],

  sectionGroup["1. Result", {
    textCell["No hidden region is found in any audited stratum, and no solve is left unresolved. The conclusion does not depend on a maximum length for derivative factors, on finding a particular cancellation generator, or on assuming the special Crown presentation of F_SL."],
    outputCell[summaryGrid],
    textCell["The decisive criterion is the absence of any exposed F0 face that simultaneously (i) has a positive Landau pinch and (ii) admits the required oriented hierarchy against the rest of F0, U and the restored on-shell layers."],
    outputCell[graphResultGrid]
  }],

  sectionGroup["2. Initial HRF search: interior through codimension three", {
    textCell["The investigation began with the ordinary HRF obstruction search. The table records its scope exactly. The interiors, codimension one and codimension three were scanned completely. At codimension two, the stored result is the selected x8 descendant near-miss sector; it is not an all-face codimension-two enumeration."],
    outputCell[lowCodimensionGrid],
    textCell["The only permissive codimension-three orbit is {x3,x5,x8}=0 in the twelve thirteen-propagator graphs. It produces 20 exact obstruction presentations, but every one has maximal hierarchy gap zero rather than the required strictly positive W_HR-W_SL. Diagram 105233 is a representative. Red edges in the drawing are contracted; each xi labels its Schwinger parameter."],
    outputCell[drawWA16Graph[
      First @ Select[rawRecords, #ID == codim3NearMiss["ID"] &],
      codim3NearMiss["ZeroVars"]]],
    textCell["All twelve thirteen-propagator graphs have the same ordered internal topology and differ only by external-leg assignments. Contracting x3, x5 and x8 merges {2,7}, {3,8} and {6,10}. With attachment vertices a,b,c,d and core vertices e,f,g as labelled below, every one of the twelve contractions is the same unlabeled graph K4,3 with precisely the two edges a-f and d-e absent."],
    outputCell[incompleteK43Panel],
    textCell["The contracted graph has E=10, V=7 and hence four loops. Vertices b and c are four-valent after their external legs are included, while g is internally four-valent. Its automorphisms exchange a<->d and b<->c independently. With p1,p2,p3,p4 fixed this gives the six pairs below; allowing crossing, all twelve graphs form one topology class."],
    outputCell[crossingClassGrid],
    textCell["This makes the Crown resemblance precise. The three-loop Crown is K4,2. The present graph is a maximal Crown-defective bipartite completion: neither pair among e,f,g connects to all four attachment vertices, but adding either missing edge immediately creates a literal K4,2 Crown subgraph. Adding one edge gives E=11, V=7, hence five loops; completing K4,3 gives E=12, V=7, hence six loops and contains all three possible K4,2 subgraphs. Therefore complete K4,3 is not a new five-loop seed. The natural five-loop completion already contains the known Crown seed, although it could still support additional regions beyond the inherited one."],
    outputCell[codim3TrialGrid],
    textCell["The factorized expression makes the near miss transparent: a genuine cancellation generator and a valid F_SL obstruction decomposition exist. The hierarchy inequalities nevertheless close only at gap zero. The displayed oriented vector includes the final expansion-parameter entry explicitly: (rho;1)=(0,...,0;1). Since no strictly positive W_HR-W_SL is possible, this is not a hidden region."],
    CellGroupData[{
      Cell["All three exact generator presentations", "Subsection"],
      outputCell[codim3CandidateGrid],
      textCell["All three presentations have a valid obstruction and fail the strict scaling test. Across the twelve graphs there are 20 such trials and no unresolved solve."]
    }, Closed]
  }],

  sectionGroup["3. Kinematics and polynomial definitions", {
    textCell["All four external momenta are algebraically incoming. In the physical wide-angle 2->2 region, s12>0, s23<0 and s13=-s12-s23<0. We use the manifestly positive coordinates a=-s23>0 and b=s12+s23=-s13>0, hence s23=-a and s12=a+b. Every Schwinger parameter xi is positive in the interior."],
    textCell["For each ordered graph, U is the first Symanzik polynomial and F(delta) is the second Symanzik polynomial with all external virtualities restored by the on-shell expansion parameter delta. F0 is the delta-leading coefficient. Setting xi=0 contracts the corresponding ordered internal edge. The graph definitions below therefore fix both the topology and every polynomial variable."],
    outputCell[definitionGrid],
    inputCell[SetDirectory[NotebookDirectory[]];
      Get["HRF_WideAngle16NoCrownAudit.wl"];
      rawRecords = hrfWA16ParseDiagramRecords[hrfWA16InputFile[]];
      records = hrfWA16BuildData /@ rawRecords;]
  }],

  sectionGroup["4. Cap-independent higher-codimension face/pinch test", {
    textCell["Write F0=F_SL+F_obs. Equations (13), (14) and (17) of arXiv:2607.15126 imply three exact requirements. First, all x-derivatives of F_SL vanish at one point with xi,a,b>0. Second, its monomials have one weight under rho. Third, every monomial of F_obs, U and every restored delta layer has strictly larger total weight. The second and third statements mean that the x-exponent support of F_SL is an exposed face of the F0 Newton polytope whose oriented normal extends to the augmented hierarchy."],
    textCell["The algorithm enumerates the complete F0 face lattice using exact rational cddlib incidences. A face is rejected if one derivative has one sign. If that fails, an exact linear (Farkas) search asks whether a constant combination of the logarithmic derivatives xi d_i F_SL is a nonzero subtraction-free polynomial. Such a polynomial is strictly positive in the physical orthant but would vanish at a common pinch. Only the remaining faces require an exact normalized FindInstance solve. Any positive pinch is finally passed to the oriented (rho;1) hierarchy LP."],
    inputCell[Get["HRF_WideAngle16FacePinchAudit.wl"];
      hrfWA16FacePinchAudit[records[[1]], {x0, x3, x5, x6}]]
  }],

  sectionGroup["5. Positive control: the three-loop Crown", {
    textCell["The same presentation-independent algorithm must retain the known Crown hidden region. It finds exactly one positive pinch face. The witness has all xi=1 and a=b=1; the hierarchy LP gives rho_i=-1, W_SL=-4 and gap 1."],
    outputCell[resultGrid @ {
      {"F0 faces", crownAudit["FaceCount"]},
      {"positive pinch-and-hierarchy faces", crownAudit["PositivePinchFaceCount"]},
      {"F_SL", crownFace["FSL"]},
      {"pinch witness", crownFace["PinchWitness"]},
      {"scaling", crownFace["HierarchyAudit"]["Scaling"]},
      {"W_SL", crownFace["HierarchyAudit"]["FSLWeight"]},
      {"gap", crownFace["HierarchyAudit"]["MaxGap"]}
    }]
  }],

  sectionGroup["6. Representative higher-codimension Farkas near miss", {
    textCell["Diagram 85774 on the contraction {x0,x3,x5,x6}=0 contains faces for which no single derivative is sign-definite. The stronger log-derivative certificate closes them. The displayed rational coefficients c_i produce P=sum_i c_i xi d_i F_SL with nonnegative coefficients and P not identically zero. Thus P>0 for xi,a,b>0, contradicting a simultaneous pinch."],
    outputCell[drawWA16Graph[First @ Select[rawRecords, #ID == 85774 &],
      {x0, x3, x5, x6}]],
    CellGroupData[{
      Cell["Exact face and Farkas certificate", "Subsection"],
      Cell["F_SL", "Subsubsection"], outputCell[farkasFace["FSL"]],
      Cell["Combination coefficients", "Subsubsection"],
        outputCell[farkasFace["DerivativeCombinationCertificate"]["CombinationCoefficients"]],
      Cell["Strictly positive combination polynomial", "Subsubsection"],
        outputCell[farkasFace["DerivativeCombinationCertificate"]["CombinationPolynomial"]]
    }, Open],
    textCell["A larger thirteen-propagator mixed-sign example, diagram 105232 with {x0,x1,x3,x5}=0, has 1,207 F0 faces. Every face is rejected algebraically and no nonlinear ambiguity remains."],
    outputCell[KeyTake[mixedAudit, {"ID", "ZeroVars", "F0PointCount",
      "F0FacetCount", "FaceCount", "FaceStatusCounts", "UnresolvedFaceCount"}]]
  }],

  sectionGroup["7. Why long derivative factors cannot reopen the result", {
    textCell["The historical eight-monomial cutoff has been removed from HRF: $HRFPolynomialMaxDerivativeMonomials is now fixed to Infinity, and the current raw harvest resets its per-polynomial state on every stratum. The uncapped factor prefilter consequently retains many more candidate presentations. None of those presentations can evade the face/pinch proof, because any HR—whatever generators or polynomial multipliers describe it—must select one of the enumerated F0 faces and satisfy the same pinch and hierarchy equations."],
    textCell["The graph-theoretic observation 'no Crown contraction minor' therefore remains a useful classifier, but it is not used as the proof. The proof is the stronger polynomial statement: every possible F_SL face is subtraction-free, has a sign-definite derivative, or has a subtraction-free linear combination of logarithmic derivatives; any exceptional positive pinch would still have to pass the exact hierarchy LP."],
    textCell["This sharpens the earlier evidence at the bottom of p. 19 of arXiv:2407.13738, where the individual channel coefficients admitted separate solutions but no common solution was found when both wide-angle invariants were active."]
  }],

  sectionGroup["8. Graph drawings", {
    textCell["The labels x0,x1,... follow the ordered internal-edge lists in Section 3. External legs are dashed."],
    outputCell[allGraphPanels]
  }, Closed],

  sectionGroup["9. Polynomial inventory and reproducibility", {
    outputCell[polynomialInventoryGrid],
    textCell["The full expressions are generated, not imported as unexplained symbols: makeFourPointOnShellF0 constructs U, F0 and F(delta) from the displayed edge lists and external attachments. The following association exposes every expression for direct inspection."],
    inputCell[allPolynomials = Association @ Map[
      #ID -> <|"Variables" -> #Vars, "U" -> #U, "F0" -> #F0,
        "F(delta)" -> #Data["FOnShell"]|> &, records]],
    inputCell[Get["HRF_WideAngle16FacePinchRegressionTests.wl"];
      hrfRunWA16FacePinchRegressionTests[]],
    inputCell[RunProcess[{"wolframscript", "-file",
      "run_wa16_face_pinch_depth_batch.wl", "min=4", "85774"}]],
    textCell["Low-codimension inputs are results/wide_angle_16_current_audit_summary.wl, results/wide_angle_16_stored_boundaries_current_gap_summary.wl, results/wide_angle_16_codim3_hierarchy_gap_summary.wl and results/wide_angle_16_codim3_nearmiss_105233.wl. Higher-codimension primary files are HRF_WideAngle16FacePinchAudit.wl (certificate), run_wa16_face_pinch_depth_batch.wl (checkpointed exhaustive runner), aggregate_wa16_face_pinch_audit.wl (summary), and HRF_WideAngle16FacePinchRegressionTests.wl (Crown plus negative controls). cddexec is used only for exact Newton-face incidences."]
  }, Closed],

  sectionGroup["10. References", {
    textCell["E. Gardi et al., arXiv:2407.13738, especially the discussion at the bottom of p. 19 (original no-Crown evidence and dissection framework)."],
    textCell["E. Gardi et al., arXiv:2607.15126, Eqs. (13)–(17) (pinch, homogeneous F_SL, ideal presentation and strict hierarchy conditions)."]
  }, Closed]
}, WindowTitle -> "No-Crown four-loop wide-angle HRF audit",
  Saveable -> True, StyleDefinitions -> "Default.nb"];

Put[notebook, "WideAngle16_NoCrown_HRF_Audit.nb"];
Print["WROTE ", ExpandFileName[
  "WideAngle16_NoCrown_HRF_Audit.nb"]];
