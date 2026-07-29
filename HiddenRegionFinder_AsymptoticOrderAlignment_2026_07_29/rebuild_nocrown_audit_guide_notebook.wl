(* Build a collaborator-facing guide to the four-loop No-Crown audits.
   The two original notebooks remain the detailed data records; this notebook
   explains the common logic and the computational coverage. *)

SetDirectory[DirectoryName[$InputFileName]];
$HRFRunWideAngle16NoCrownAuditOnLoad = False;
Get["HRF_WideAngle16NoCrownAudit.wl"];
Get["HRF_WideAngle16FacePinchAudit.wl"];
Get["HRF_WideAngle16ReggeBoundaryAudit.wl"];

ClearAll[textCell, inputCell, outputCell, programCell, sectionGroup,
  subsectionGroup, resultGrid, drawAuditGraph];
textCell[s_String] := Cell[s, "Text"];
SetAttributes[inputCell, HoldAll];
(* Store ordinary evaluatable boxes.  HoldAll prevents the builder from
   executing e, while MakeBoxes emits the expression itself rather than a
   HoldForm/Defer wrapper that would merely echo when the notebook cell runs. *)
inputCell[e_] := Cell[BoxData @ MakeBoxes[e, StandardForm], "Input"];
outputCell[e_] := Cell[BoxData @ ToBoxes[e], "Output"];
programCell[s_String] := Cell[s, "Program"];
sectionGroup[t_String, cells_List, state_: Open] :=
  CellGroupData[Prepend[cells, Cell[t, "Section"]], state];
subsectionGroup[t_String, cells_List, state_: Open] :=
  CellGroupData[Prepend[cells, Cell[t, "Subsection"]], state];
resultGrid[d_] := Grid[d, Frame -> All, Alignment -> Left,
  Background -> {None, {LightGray, None}}, BaseStyle -> {FontSize -> 11},
  ItemSize -> {{Automatic, Automatic}, Automatic}];

rawRecords = hrfWA16ParseDiagramRecords[hrfWA16InputFile[]];

wideCurrent = Get["results/wide_angle_16_current_audit_summary.wl"];
wideBoundary = Get[
  "results/wide_angle_16_stored_boundaries_current_gap_summary.wl"];
wideCodim3 = Get["results/wide_angle_16_codim3_hierarchy_gap_summary.wl"];
wideHigh = Get[
  "results/wide_angle_16_face_pinch_higher_codim_summary.wl"];
wideRegression = Get["results/wide_angle_16_face_pinch_regression.wl"];
reggeInterior = Get["results/wa16_regge_interior_v1_summary.wl"];
reggeClasses = Get[
  "results/wa16_regge_interior_v1_permutation_classes.wl"];
reggeBoundary = Get["results/wa16_regge_boundary_v1_summary.wl"];
reggeBoundaryClasses = Get[
  "results/wa16_regge_boundary_v1_class_summary.wl"];
reggeBoundaryChannels = Get[
  "results/wa16_regge_boundary_v1_channel_summary.wl"];
wideCodim2Record = Get[
  "results/wide_angle_16_codim2_complete_summary.wl"];
wideCodim2Coverage = wideCodim2Record["Coverage"];
Print["[guide] loaded compact result records"];

drawAuditGraph[rec_Association, zero_List : {}] := Module[
  {internal, external, intEdges, extEdges, edges, zeroIndices, labels,
   styles, externalVertices},
  internal = rec["InternalLines"][[All, 2]];
  external = rec["ExternalLines"];
  intEdges = UndirectedEdge @@@ internal;
  extEdges = (UndirectedEdge[#[[2]], #[[1]]] &) /@ external;
  edges = Join[intEdges, extEdges];
  zeroIndices = ToExpression[StringDrop[ToString[#], 1]] & /@ zero;
  labels = AssociationThread[intEdges,
    MapIndexed[Placed[Style[Subscript[x, First[#2] - 1],
      If[MemberQ[zeroIndices, First[#2] - 1], Red, Black], 10], Center] &,
      intEdges]];
  styles = AssociationThread[intEdges,
    MapIndexed[If[MemberQ[zeroIndices, First[#2] - 1],
      Directive[Red, AbsoluteThickness[3]],
      Directive[GrayLevel[.3], AbsoluteThickness[1.5]]] &, intEdges]];
  styles = Join[styles, AssociationThread[extEdges,
    ConstantArray[Directive[Gray, Dashed], Length[extEdges]]]];
  externalVertices = external[[All, 1]];
  Graph[edges, EdgeLabels -> Normal[labels], EdgeStyle -> Normal[styles],
    VertexLabels -> Placed["Name", Center],
    VertexStyle -> Table[
      v -> If[MemberQ[externalVertices, v], LightBlue, White],
      {v, VertexList[Graph[edges]]}],
    VertexSize -> .28, GraphLayout -> "SpringEmbedding", ImageSize -> 470,
    PlotLabel -> Style[
      "diagram " <> ToString[rec["ID"]] <>
        If[zero === {}, "", " with " <> ToString[zero, InputForm] <> "=0"],
      12, Bold]]
];

graphGrid = resultGrid @ Prepend[
  ({#["ID"], Length[#["InternalLines"]], #["InternalLines"],
      #["ExternalLines"]} & /@ rawRecords),
  {"diagram", "E", "ordered internal edges (x0,x1,...)",
    "external attachments"}
];

boundaryCountGrid = resultGrid @ {
  {"stratum", "number", "wide-angle stored coverage", "Regge coverage"},
  {"interior", 16, "all 16", "48 graph/channel interiors"},
  {"codimension 1", 204, "all 204", "all"},
  {"codimension 2", 1200,
    "188 legacy x8 strata plus 1012 current complementary strata", "all"},
  {"codimension 3", 4312, "all 4312", "all"},
  {"codimension 4 through E-2", 108736, "all 108736", "all"},
  {"all nonempty boundaries", 114452,
    "all 114452", "114452 per channel"}
};

scopeGrid = resultGrid @ {
  {"audit", "cases", "HR found", "unresolved", "logical status"},
  {"wide angle: interiors plus all nonempty boundaries", 114468, 0, 0,
    "complete"},
  {"Regge: interiors", reggeInterior["GraphChannelCount"],
    reggeInterior["HiddenRegionGraphChannelCount"],
    reggeInterior["UnresolvedFaceCount"], "complete"},
  {"Regge: nonempty boundaries", reggeBoundary["ExpandedBoundaryCount"],
    reggeBoundary["HiddenRegionStratumCount"],
    reggeBoundary["UnresolvedFaceCount"], "complete"}
};

singleRunOptionGrid = resultGrid @ {
  {"setting", "certification value", "reason"},
  {"GeneratorMode", "PairSectors", "allow the two kinematic sectors of wide-angle 2->2 scattering"},
  {"MaxGenerators", 2, "one cancellation generator per sector is sufficient for this run mode"},
  {"UseExtendedFactors", True, "include polynomial, not only binomial, cancellation factors"},
  {"EnableSignedMonomialPairs", False, "use factors of complete derivatives and channel polynomials"},
  {"StopOnFirstAdmissible", False, "retain every admissible obstruction presentation"},
  {"CandidateGeneratorSetLimit", Infinity, "a finite value can find a witness but cannot prove absence"},
  {"MaxTwoGeneratorUnionTrials", Infinity, "do not truncate two-sector unions"},
  {"PolynomialMaxMonomials", Automatic, "derive the complete factor size from the polynomial being audited"},
  {"CoverageScalingMethod", "ExactCoverage", "solve the homogeneous face and strict hierarchy together"},
  {"RequireValidScalingForHiddenRegionQ", True, "a cancellation candidate without a positive hierarchy gap is not an HR"}
};

wideStageGrid = resultGrid @ {
  {"stage", "objects", "survivors requiring hierarchy test", "positive gap", "conclusion"},
  {"16 interiors", 16,
    wideCurrent["FourLoop16Interior", "ValidObstructionTrialCount"], 0,
    "no accepted HR"},
  {"all codimension-one strata", First[wideBoundary]["OriginalScanRowCount"],
    First[wideBoundary]["AuditedTrialCount"],
    First[wideBoundary]["PositiveGapTrialCount"], "no accepted HR"},
  {"codimension two containing x8", Last[wideBoundary]["OriginalScanRowCount"],
    Last[wideBoundary]["AuditedTrialCount"],
    Last[wideBoundary]["PositiveGapTrialCount"],
    "no accepted HR in this selected sector"},
  {"complementary codimension-two strata",
    wideCodim2Coverage["ComplementaryStratumCount"], 0,
    wideCodim2Coverage["ComplementaryHiddenRegionCount"],
    If[TrueQ[wideCodim2Coverage["ComplementaryCoverageCompleteQ"]],
      "complete NoHR: no admissible generator on any stratum",
      "coverage incomplete"]},
  {"all codimension-three strata",
    wideCurrent["AllCodim3Prefilter", "ScanCount"],
    wideCodim3["TrialCount"], wideCodim3["PositiveGapTrialCount"],
    "only the {x3,x5,x8} orbit survives; every trial has gap zero"},
  {"codimension four through E-2", wideHigh["ScannedStratumCount"],
    wideHigh["PositivePinchFaceCount"], 0,
    "every exposed face rejected; no unresolved solve"}
};

reggeClassGrid = resultGrid @ Prepend[
  Table[
    {i, reggeBoundaryClasses[[i, "Representative"]],
      reggeBoundaryClasses[[i, "GraphChannelMultiplicity"]],
      reggeBoundaryClasses[[i, "PropagatorCount"]],
      reggeBoundaryClasses[[i, "RepresentativeBoundaryCount"]],
      reggeBoundaryClasses[[i, "HiddenRegionStratumCount"]],
      reggeBoundaryClasses[[i, "UnresolvedFaceCount"]]},
    {i, Length[reggeBoundaryClasses]}],
  {"class", "direct representative", "represented graph/channels", "E",
    "boundaries directly audited", "HR", "unresolved"}
];

reggeChannelGrid = resultGrid @ Prepend[
  ({#["Channel"], #["BoundaryCount"],
      Lookup[#["CertificateCounts"], "InheritedParentInteriorFaceClosure", 0],
      Lookup[#["CertificateCounts"],
        "GlobalSubtractionFreeFirstNonzeroReggeLayer", 0],
      Lookup[#["CertificateCounts"], "TrivialRestrictedReggePolynomial", 0],
      #["HiddenRegionStratumCount"], #["UnresolvedFaceCount"]} & /@
    reggeBoundaryChannels),
  {"channel", "boundaries", "inherited q=0", "sign-definite q=1",
    "trivial", "HR", "unresolved"}
];

safeOptimizationGrid = resultGrid @ {
  {"operation", "why it preserves a negative certificate"},
  {"factor complete derivatives and channel polynomials", "retains the full polynomial cancellation factors rather than imposing a monomial-length cutoff"},
  {"support and degree incompatibility tests", "rejects factor combinations only when their product cannot occur in the multilinear F polynomial"},
  {"exact generator deduplication", "merges literally identical generator polynomials without quotienting distinct cancellation hypersurfaces"},
  {"exact graph/channel permutation", "the complete tuple (leading polynomial, higher layers, U) is transported by an explicit variable permutation"},
  {"checkpoint by graph and codimension", "changes execution order and storage only, not the set of strata or equations"}
};

unsafeShortcutGrid = resultGrid @ {
  {"shortcut", "why it is not an absence proof"},
  {"finite generator or union cap", "an unvisited cancellation presentation may remain"},
  {"timeout interpreted as False", "failure to decide is unresolved, not negative"},
  {"testing only a preferred generator ansatz", "a different admissible set of cancellation factors may produce another decomposition"},
  {"discarding a valid decomposition before solving its scaling", "the positive pinch generally appears only after F_SL has been isolated by the scaling law"},
  {"transferring a wide-angle verdict directly to Regge", "kinematic specialization changes the polynomial and its possible cancellation factors"}
};

crownAudit = wideRegression["CrownAudit"];
crownFace = First[crownAudit["PositiveOrUnresolvedFaces"]];
nearMiss = Get["results/wide_angle_16_codim3_nearmiss_105233.wl"];
nearMissTrial = nearMiss["RepresentativeTrial"];
Print["[guide] constructed summary tables"];

notebook = Notebook[{
  Cell["How the four-loop No-Crown hidden-region audits were performed",
    "Title"],
  Cell["A reproducible guide to the wide-angle and three-channel Regge searches",
    "Subtitle"],
  textCell["Purpose. The two detailed audit notebooks contain a large amount of run history and diagnostic output. This notebook instead presents the mathematical question, one ordinary HRF run, the enumeration of graphs and contraction strata, and the exact shortcuts that made the exhaustive parts feasible. It is intended to be sufficiently precise that the strategy can be reimplemented independently."],

  sectionGroup["1. Question, sample and exact scope", {
    textCell["The sample consists of sixteen massless four-loop 2->2 graphs. Each graph has mixed-sign Schwinger-parameter derivatives, so the elementary necessary test for a cancellation pinch does not exclude it. None contains the three-loop Crown as a contraction minor. The question is whether any graph, in its interior or on a contraction boundary, has a hidden region at wide angle or in one of the three Regge channels."],
    outputCell[scopeGrid],
    textCell["Both conclusions are now exhaustive for this sample. At wide angle the earlier record covered the 188 codimension-two strata containing x8; the current generator-first run separately certifies all 1012 complementary strata. Keeping those provenances distinct makes clear which conclusions come from the historical scan and which come from the present exact rerun."],
    outputCell[boundaryCountGrid]
  }],

  sectionGroup["2. The HRF decision problem on one stratum", {
    textCell["Fix a graph, a kinematic limit and a contraction set S. Set x_i=0 for i in S and keep all remaining Schwinger parameters positive. In ordinary wide-angle scattering the native leading polynomial F0 is already the correct starting point; no preliminary face selection is required."],
    textCell["HRF first factorises the mixed-sign derivatives of F0 and identifies compatible polynomial cancellation factors. Admissible products of these factors define candidate generators of the cancellation ideal. Only then does HRF construct decompositions F0=F_SL+F_obs in which F_SL belongs to that ideal. Finally it solves for a scaling vector rho which makes F_SL homogeneous and places F_obs, U and every restored delta layer at strictly higher weight."],
    outputCell[resultGrid @ {
      {"condition", "equation tested", "meaning"},
      {"positive pinch", "d_i F_SL=0, x_i>0", "first-sheet Landau stationary point on the active stratum"},
      {"face homogeneity", "rho.(r_a-r_b)=0 for a,b in F_SL", "the proposed superleading monomials scale together"},
      {"strict hierarchy", "rho.(r_c-r_a)+eta_c-eta_a>0", "all complementary and restored-layer monomials are genuinely later"}
    }],
    textCell["The positive pinch is tested on the isolated F_SL, not on the unscaled F0. If a scaling solution exists, the monomials of F_SL necessarily form the corresponding lower face after that scaling has been found. This geometric statement certifies the result; it is not the candidate-generation step for an ordinary wide-angle run."]
  }],

  sectionGroup["3. One ordinary HRF run", {
    textCell["The executable cell below runs only the interior of the first diagram (85774). Its purpose is to display one complete HRF decision with all certification settings exposed; it does not rerun the full sixteen-graph boundary audit. The exhaustive audit is represented later by its compact persisted certificates. The historical discovery runner used a candidate limit of 128; for a new absence claim, the explicit unbounded settings below are preferable."],
    outputCell[singleRunOptionGrid],
    inputCell[
      SetDirectory[NotebookDirectory[]];
      $HRFRunWideAngle16NoCrownAuditOnLoad = False;
      Get["HRF_WideAngle16NoCrownAudit.wl"];
      rec = First[hrfWA16LoadRecords[]];
      zero = {};
      f = Expand[rec["F0"] /. Thread[zero -> 0]];
      u = Expand[rec["U"] /. Thread[zero -> 0]];
      fFull = Expand[rec["Data"]["FOnShell"] /. Thread[zero -> 0]];
      vars = Complement[rec["Vars"], zero];
      scan = findObstructions[f, vars, KinAssump4ptOnShell, KinVars4pt, 20,
        "UseExtendedFactors" -> True,
        "GeneratorMode" -> "PairSectors", "MaxGenerators" -> 2,
        "EnableSignedMonomialPairs" -> False,
        "StopOnFirstAdmissible" -> False,
        "CandidateGeneratorSetLimit" -> Infinity,
        "MaxTwoGeneratorUnionTrials" -> Infinity,
        "PolynomialMaxMonomials" -> Automatic,
        "StoreAllObstructionTrialsQ" -> False,
        "U" -> u,
        "FObsForScaling" -> <|
          "DeltaLayers" -> hrfDeltaLayerAssociation[fFull, \[Delta]]|>,
        "CoverageScalingMethod" -> "ExactCoverage",
        "RequireValidScalingForHiddenRegionQ" -> True];
      <|
        "DiagramID" -> rec["ID"],
        "ContractedVariables" -> zero,
        "Stratum" -> If[zero === {}, "interior", "boundary"],
        "Conclusion" -> Which[
          TrueQ[scan["HiddenRegionQ"]], "hidden region found",
          TrueQ[scan["HiddenRegionSearchCompleteQ"]] &&
            ! TrueQ[scan["SearchTruncatedQ"]],
            "complete search: no hidden region",
          True, "unresolved"
        ],
        "HiddenRegionCount" -> scan["HiddenRegionCount"],
        "CandidateGeneratorCount" -> scan["CandidateGeneratorCount"],
        "ValidObstructionTrialCount" ->
          scan["ValidObstructionTrialCount"],
        "SearchTruncatedQ" -> scan["SearchTruncatedQ"],
        "HiddenRegionSearchCompleteQ" ->
          scan["HiddenRegionSearchCompleteQ"]
      |>
    ],
    textCell["The final association is deliberately short. Conclusion equal to \"complete search: no hidden region\" means that the candidate construction and all required decisions completed without truncation. \"Unresolved\" must not be read as NoHR."],
    textCell["A negative row is reportable only when SearchTruncatedQ is False and all positivity and scaling solves are resolved. A positive witness can be found with finite budgets, but a finite budget cannot certify that no unvisited generator set works."],
    textCell["For the sixteen interiors, the stored scan tried PairSectors, Adaptive and SingleProduct modes. The current complete polynomial-factor construction produces no admissible generator in any interior. The later exposed-face calculation was introduced historically as an independent safeguard when the completeness of the factor harvest was still in question; it is not the preferred HRF workflow after removal of the hard caps."]
  }],

  sectionGroup["4. Enumerating graphs and contraction boundaries", {
    textCell["The ordered internal-edge list fixes the correspondence x0,x1,... . A boundary stratum is a subset S of these variables, imposed by x_i=0 for i in S. For a graph with E internal edges, codimension k contains Binomial[E,k] strata. The scan stops at k=E-2 because fewer than two active Schwinger parameters cannot support a nontrivial cancellation hypersurface."],
    inputCell[zeroSets[rec_, k_] := Subsets[rec["Vars"], {k}]],
    textCell["Four graphs have E=12 and twelve have E=13. This gives the counts in Section 1. Graph identity or crossing was used to reduce work only after an explicit variable permutation was shown to transport every polynomial entering the decision problem."],
    outputCell[graphGrid],
    textCell["Drawings of all sixteen labelled graphs are retained in the two detailed audit notebooks. Here the ordered edge lists are the primary reproducible definitions; the only drawing shown below is the codimension-three near miss used to illustrate the logic."]
  }],

  sectionGroup["5. Wide-angle search: discovery followed by a presentation-independent audit", {
    textCell["The lower-codimension investigation used HRF to harvest cancellation factors, build admissible generator sets, construct F_SL and solve the hierarchy. Cheap support and degree tests rejected impossible factor pairs before polynomial reduction. Every surviving obstruction presentation was checked by exact rational hierarchy inequalities."],
    outputCell[wideStageGrid],
    textCell["The formerly missing 1012 codimension-two strata have now been completed by the current uncapped generator-first HRF scan. Every stratum has a readable per-stratum certificate, every search is untruncated, and every result is CompleteNoHR. In fact the complete factor harvest produces no admissible generator on any of these complementary strata, so no F_SL+F_obs decomposition reaches the scaling stage."],
    outputCell[resultGrid @ {
      {"codimension-two provenance", "strata", "NoHR", "HR", "unresolved"},
      {"legacy sector containing x8", 188, 188, 0, 0},
      {"current complementary audit",
        wideCodim2Coverage["ComplementaryStratumCount"],
        wideCodim2Coverage["ComplementaryNoHRCount"],
        wideCodim2Coverage["ComplementaryHiddenRegionCount"],
        wideCodim2Coverage["ComplementaryUnresolvedCount"]}
    }],
    textCell["This optimization belongs only to factor admissibility, before generator construction and before the F_SL+F_obs decomposition. For a kinematics-free, homogeneous, square-free mixed-sign factor, a Newton-polytope vertex-dominance argument proves the existence of a zero in the positive orthant. For two such factors with disjoint Schwinger-variable supports, their positive zeros can be chosen independently, proving simultaneous admissibility. These exact certificates replace the corresponding semialgebraic FindInstance calls. They do not construct or constrain the decomposition: F_obs is still the exact polynomial remainder modulo the candidate generator ideal and F_SL=F-F_obs. Factors outside this narrowly certified class use the general semialgebraic test."],
    textCell["The closest wide-angle near miss is the orbit with x3=x5=x8=0 in the twelve thirteen-propagator graphs. It has genuine cancellation generators and a valid obstruction decomposition, but all twenty presentations have maximal hierarchy gap zero. Thus the cancellation surface is present without a distinct hidden-region scaling."],
    textCell["The corresponding labelled graph is drawn in the detailed wide-angle notebook; its ordered edge definition is included in Section 4 of this guide."],
    outputCell[resultGrid @ {
      {"quantity", "representative result"},
      {"diagram", nearMiss["ID"]},
      {"contracted variables", nearMiss["ZeroVars"]},
      {"F_SL", nearMissTrial["FSLFactorized"]},
      {"valid obstruction", True},
      {"maximal hierarchy gap", nearMissTrial["MaxGap"]},
      {"strict hidden-region scaling", nearMissTrial["HierarchyFeasibleQ"]}
    }],
    textCell["At codimension four and deeper, the historical study additionally applied the exposed-face decision procedure of the next section. That independent calculation covers 108736 strata and is insensitive to the then-existing cancellation-factor caps. With the present uncapped polynomial-factor construction, a new scan should retain the generator-first HRF order used above."]
  }],

  sectionGroup["6. The exposed-face calculation as an independent cross-check", {
    textCell["The following calculation was developed to close a historical loophole: the generator harvest then contained hard caps, so a negative generator search did not by itself establish completeness. Enumerating every exposed face searches a much larger superset of candidate F_SL polynomials. It is mathematically valid as a necessary-condition audit, but it reverses the efficient HRF logic and should not be used as the primary wide-angle algorithm when the complete generator construction is available."],
    textCell["For every restricted polynomial P_q, the cross-check performed the following operations."],
    programCell["AUDIT-STRATUM(graph, contraction S, kinematic limit)\n  1. Construct U and all delta coefficients after x_i=0 for i in S.\n  2. Let q be the first nonzero delta power and P=P_q.\n  3. If P is zero or has one overall sign, return a negative certificate.\n  4. Enumerate every exposed face of Newton(P) with exact rational polyhedral arithmetic.\n  5. For each face polynomial F_SL:\n       a. reject if one derivative is sign-definite;\n       b. otherwise search for a Farkas separating combination of x_i d_i F_SL;\n       c. otherwise solve the positive Landau equations exactly;\n       d. for every positive solution, solve the oriented hierarchy linear program.\n  6. HR is possible only if a face has both a positive pinch and a strictly positive hierarchy gap.\n  7. Any timeout or failed exact solve is UNRESOLVED, never NO HR."],
    textCell["The face lattice is obtained from exact cddlib facet incidences. This removes dependence on a chosen generator presentation, but it is substantially more expensive because most faces do not arise from an admissible cancellation ideal. The final hierarchy linear program tests the complement, U and all restored layers."],
    textCell["The Farkas step is especially important. Write L_i=x_i d_i F_SL. If real numbers c_i exist such that the nonzero polynomial sum_i c_i L_i has coefficients of one sign in positive physical coordinates, that polynomial is strictly one-signed for x_i>0. The L_i therefore cannot all vanish. The c_i themselves need not be positive; positivity belongs to the Schwinger parameters and the induced monomial values."],
    textCell["The known Crown is the positive control. The identical algorithm finds one surviving face, a positive pinch and hierarchy gap one."],
    outputCell[resultGrid @ {
      {"control", "faces", "positive pinch plus hierarchy", "gap"},
      {"three-loop Crown", crownAudit["FaceCount"],
        crownAudit["PositivePinchFaceCount"],
        crownFace["HierarchyAudit", "MaxGap"]}
    }],
    inputCell[
      Get["HRF_WideAngle16FacePinchAudit.wl"];
      raw = First @ Select[
        hrfWA16ParseDiagramRecords[hrfWA16InputFile[]],
        #["ID"] === 85774 &];
      auditRecord = hrfWA16BuildData[raw];
      hrfWA16FacePinchAudit[auditRecord,
        {x0, x3, x5, x6}]
    ]
  }],

  sectionGroup["7. Regge audit recorded in the historical calculation", {
    textCell["With all momenta algebraically incoming and s13=-s12-s23, the three channels are T23: s23->0 at fixed s12; T12: s12->0 at fixed s23; and T13: s13->0, equivalently s23->-s12. After division by the large invariant, F/s=P_0+delta P_1."],
    textCell["The 48 graph/channel interiors were first grouped by exact graph relabellings and Schwinger-variable permutations. Equality of P_0 up to an overall sign was not sufficient by itself: the exponent supports of U and every suppressed layer also had to map. Twelve exact polynomial triples reduced to six audit classes."],
    outputCell[reggeClassGrid],
    textCell["Within this presentation-independent cross-check, a boundary optimization was possible. If P_0 remains nonzero after a contraction S, its exponent support is a coordinate face of the parent support. Every face of that restriction had already been included in the exhaustive parent face enumeration. This is a shortcut inside the face-based cross-check, not the candidate-generation principle of HRF."],
    textCell["A genuinely new problem occurs only when the contraction annihilates P_0. Then the first nonzero layer is P_q with q>0. Its absolute order must be retained: relative to P_q, U carries delta weight -q. In this sample q=1, and every such first layer is either identically zero after further contraction or subtraction-free up to an overall sign."],
    outputCell[reggeChannelGrid],
    textCell["These three mutually exclusive certificates account for every one of the 343356 nonempty Regge boundaries in the recorded face-based audit. A future generator-first implementation may reproduce the same conclusion more economically."]
  }],

  sectionGroup["8. Safe optimizations for a generator-first implementation", {
    outputCell[safeOptimizationGrid],
    textCell["The following common shortcuts may be useful during discovery, but cannot support a final absence statement."],
    outputCell[unsafeShortcutGrid]
  }],

  sectionGroup["9. Reproduction map", {
    textCell["The detailed numerical records remain in WideAngle16_NoCrown_HRF_Audit.nb and WideAngle16_NoCrown_Regge_HRF_Audit.nb. The files below are the smallest implementation map for reproducing the methodology."],
    outputCell[resultGrid @ {
      {"role", "file"},
      {"graph import and one ordinary HRF run", "HRF_WideAngle16NoCrownAudit.wl"},
      {"complete codimension-two manifest and one-stratum runner", "HRF_WideAngle16Codim2Audit.wl"},
      {"checkpointed codimension-two batch runner", "HRF_RunWideAngle16Codim2Batch.wl"},
      {"codimension-two coverage accounting", "HRF_WideAngle16Codim2CoverageSummary.wl"},
      {"codimension-two certification regressions", "HRF_WideAngle16Codim2RegressionTests.wl"},
      {"wide-angle face, pinch and hierarchy test", "HRF_WideAngle16FacePinchAudit.wl"},
      {"wide-angle checkpointed boundary enumeration", "run_wa16_face_pinch_depth_batch.wl"},
      {"Regge interior polynomial and face audit", "HRF_WideAngle16ReggeInteriorAudit.wl"},
      {"Regge restricted-layer and boundary audit", "HRF_WideAngle16ReggeBoundaryAudit.wl"},
      {"Regge interior checkpoint runner", "run_wa16_regge_interior_batch.wl"},
      {"Regge class/boundary checkpoint runner", "run_wa16_regge_boundary_batch.wl"},
      {"compact persisted results", "results/wide_angle_16_* and results/wa16_regge_*"}
    }],
    textCell["Requirements. Mathematica reconstructs the graph polynomials and solves the algebraic and linear problems. cddexec from cddlib supplies exact rational facet incidences. Batch runners checkpoint after small blocks, so interrupted calculations resume without changing the mathematical sample."],
    inputCell[RunProcess[{"wolframscript", "-file",
      "run_wa16_regge_interior_regression.wl"}]],
    inputCell[RunProcess[{"wolframscript", "-file",
      "run_wa16_regge_boundary_regression.wl"}]]
  }, Closed],

  sectionGroup["10. References", {
    textCell["E. Gardi et al., arXiv:2407.13738: the original No-Crown observation, first-sheet parameter-space pinches and dissection."],
    textCell["E. Gardi et al., arXiv:2607.15126, especially Eqs. (13)-(17): cancellation locus, homogeneous superleading sector and strict hierarchy conditions."]
  }, Closed]
}, WindowTitle -> "Four-loop No-Crown audit guide", Saveable -> True,
  StyleDefinitions -> "Default.nb"];
Print["[guide] constructed notebook expression"];

Put[notebook, "NoCrown_4Loop_WideAngle_and_Regge_Audit_Guide.nb"];
Print["WROTE ",
  ExpandFileName["NoCrown_4Loop_WideAngle_and_Regge_Audit_Guide.nb"]];
