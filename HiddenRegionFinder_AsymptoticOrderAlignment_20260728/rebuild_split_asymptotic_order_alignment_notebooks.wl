$HistoryLength = 0;
repoDirectory = DirectoryName[$InputFileName];
SetDirectory[repoDirectory];

ClearAll[outputCell, inputCell, ensureDirectory, plainVector,
  canonicalTerminology,
  exportPackageClean];
outputCell[expr_] := Cell[BoxData[ToBoxes[expr]], "Output"];
inputCell[text_String] := Cell[text, "Input"];
ensureDirectory[path_] := If[! DirectoryQ[path], CreateDirectory[path]];
plainVector[a_Association] := Values[a];
plainVector[x_] := x;
canonicalTerminology[expr_] := expr /.
  "StagedFaceliftPlusHRF" -> "StagedAsymptoticOrderAlignmentPlusHRF";
exportPackageClean[path_, expression_] := Module[{text},
  Export[path, expression, "Package"];
  text = Import[path, "Text"];
  Export[path,
    StringReplace[text,
      RegularExpression["[ \\t]+(?=\\r?\\n)"] -> ""],
    "Text"
  ];
];

resultsDirectory = FileNameJoin[{repoDirectory, "results"}];
nmrkResultsDirectory = FileNameJoin[{resultsDirectory, "nmrk_wz"}];
dscResultsDirectory = FileNameJoin[{resultsDirectory, "dsc"}];
ensureDirectory[nmrkResultsDirectory];
ensureDirectory[dscResultsDirectory];

(* Current NMRK certificate. *)
nmrkScan = canonicalTerminology @ Import[
  FileNameJoin[{repoDirectory, "testdata", "alignment",
    "nmrk_wz_one_loop_hexagon_scan.wl"}], "WL"
];
nmrkComparison = canonicalTerminology @ Import[
  FileNameJoin[{resultsDirectory, "one_loop_NMRK_DSC_weight_comparison.wl"}],
  "WL"
]["NMRK"];
nmrkRow = First[nmrkScan["DeduplicatedHiddenRegionRows"]];
nmrkAudit = nmrkRow["TotalScalingAudit"];
nmrkSummary = nmrkScan["Summary"];
nmrkCertificate = <|
  "Expansion" -> "central NMRK with w=z and wb=zb",
  "Summary" -> KeyTake[nmrkSummary, {
    "StagedHiddenRegionCount", "StrictHiddenRegionPresentationCount",
    "UniqueHiddenRegionCount", "ScalelessRejectedCount"
  }],
  "FaceScaling" -> nmrkRow["Scaling"],
  "HRFScaling" -> Values[
    nmrkRow["HRFSummary", "CoverageScalingData", "VariableScaling"]
  ],
  "CertifiedTotalScaling" -> Values[nmrkAudit["TotalScaling"]],
  "RelativeTotalScaling" -> Values[nmrkAudit["RelativeTotalScaling"]],
  "WSL" -> nmrkAudit["WSL"],
  "WHR" -> nmrkAudit["WHR"],
  "HierarchyGap" -> nmrkAudit["HierarchyGap"],
  "CertificationVectorSource" -> nmrkAudit["CertificationVectorSource"],
  "CancellationFactors" -> nmrkRow["HRFSummary", "CancellationFactors"],
  "FSL" -> nmrkComparison["FSL"],
  "BlueFPolynomial" -> nmrkComparison["BlueFPolynomial"],
  "BlueUPolynomial" -> nmrkComparison["BlueUPolynomial"]
|>;
exportPackageClean[
  FileNameJoin[{nmrkResultsDirectory, "one_loop_hexagon_certificate.wl"}],
  nmrkCertificate
];
nmrkTwoLoopCertificates = canonicalTerminology @ Import[
  FileNameJoin[{nmrkResultsDirectory, "two_loop_wz_certificates.wl"}], "WL"
];
nmrkGenericControls = canonicalTerminology @ Import[
  FileNameJoin[{nmrkResultsDirectory, "two_loop_generic_controls.wl"}], "WL"
];

(* Current DSC certificates. *)
dscHexagon = canonicalTerminology @ Import[
  FileNameJoin[{resultsDirectory, "facet_recertified_DSC_hexagon.wl"}], "WL"
];
dscHexbox = canonicalTerminology @ Import[
  FileNameJoin[{resultsDirectory, "facet_recertified_DSC_hexbox.wl"}], "WL"
];
dscNonplanar = canonicalTerminology @ Import[
  FileNameJoin[{resultsDirectory,
    "facet_recertified_DSC_nonplanar-hexbox.wl"}], "WL"
];
dscHexagonPentagon = canonicalTerminology @ Import[
  FileNameJoin[{resultsDirectory,
    "facet_recertified_DSC_hexagon-pentagon.wl"}], "WL"
];
dscRow = First[dscHexagon["FinalRepresentatives"]];
dscAudit = dscRow["TotalScalingAudit"];
dscIdealCertificate = First[
  dscAudit["IdealLayerCertification", "Certificates"]
];
dscFace = dscRow["Scaling"];
dscNaive = Values[dscAudit["StagedComposedScaling"]];
dscHRF = dscNaive - dscFace;
dscOneLoopCertificate = <|
  "Expansion" -> "generic double-spacelike-collinear limit",
  "PhysicalDomain" ->
    "a<0, -1<tau1<0, tau2<-1, zD<0, zbD<0",
  "FaceScaling" -> dscFace,
  "HRFScaling" -> dscHRF,
  "NaiveComposedScaling" -> dscNaive,
  "CertifiedTotalScaling" -> Values[dscAudit["TotalScaling"]],
  "RelativeTotalScaling" -> Values[dscAudit["RelativeTotalScaling"]],
  "WSL" -> dscAudit["WSL"],
  "WHR" -> dscAudit["WHR"],
  "HierarchyGap" -> dscAudit["WHR"] - dscAudit["WSL"],
  "CertificationVectorSource" -> dscAudit["CertificationVectorSource"],
  "CancellationFactors" ->
    dscAudit["IdealLayerCertification", "CancellationFactors"],
  "TransverseWeights" -> Values[dscIdealCertificate["TransverseWeights"]],
  "LayerAudit" -> Take[dscIdealCertificate["LayerAudit"], UpTo[3]]
|>;
exportPackageClean[
  FileNameJoin[{dscResultsDirectory, "one_loop_hexagon_certificate.wl"}],
  dscOneLoopCertificate
];

dscTwoLoopCertificate = <|
  "hexbox" -> dscHexbox["Summary"],
  "nonplanar-hexbox" -> dscNonplanar["Summary"],
  "hexagon-pentagon" -> dscHexagonPentagon["Summary"]
|>;
exportPackageClean[
  FileNameJoin[{dscResultsDirectory, "two_loop_structural_certificates.wl"}],
  dscTwoLoopCertificate
];

nmrkStageGrid = Grid[
  Prepend[{
    {"Alignment representative f", nmrkCertificate["FaceScaling"]},
    {"Face-only HRF vector h", nmrkCertificate["HRFScaling"]},
    {"Certified total vector v",
      nmrkCertificate["CertifiedTotalScaling"]},
    {"Relative total vector",
      nmrkCertificate["RelativeTotalScaling"]}
  }, {"Quantity", "Vector (x0,...,x5)"}],
  Frame -> All, Alignment -> Left
];
nmrkResultGrid = Grid[{
  {"Accepted face presentations",
    nmrkSummary["StrictHiddenRegionPresentationCount"]},
  {"Structurally unique regions", nmrkSummary["UniqueHiddenRegionCount"]},
  {"(W_SL,W_HR)", {nmrkAudit["WSL"], nmrkAudit["WHR"]}},
  {"Hierarchy gap", nmrkAudit["HierarchyGap"]},
  {"Certificate", nmrkAudit["CertificationVectorSource"]}
}, Frame -> All, Alignment -> Left];
nmrkPolynomialPanel = OpenerView[{
  "Certified NMRK LP layers",
  Column[{
    Style["F_SL", Bold, Darker[Red]],
    TraditionalForm[nmrkCertificate["FSL"]],
    Style["F at W_HR", Bold, Darker[Blue]],
    TraditionalForm[nmrkCertificate["BlueFPolynomial"]],
    Style["U at W_HR", Bold, Darker[Blue]],
    TraditionalForm[nmrkCertificate["BlueUPolynomial"]]
  }, Spacings -> 1.1]
}, False];

nmrkGraphNames = {"planar-hexbox", "nonplanar-hexbox",
  "hexagon-pentagon"};
nmrkTwoLoopGrid = Grid[
  Prepend[
    Function[g, With[{wz = nmrkTwoLoopCertificates[g],
        generic = nmrkGenericControls[g]},
      {g, generic["StagedUniqueCount"], wz["StagedUniqueCount"],
        wz["CertifiedUniqueCount"], wz["FullSupportCertifiedCount"],
        wz["BoundaryStratumCertifiedCount"]}
    ]] /@ nmrkGraphNames,
    {"Graph", "generic staged", "w=z staged", "w=z certified",
      "full support", "boundary strata"}
  ], Frame -> All, Alignment -> Left
];
nmrkRepresentativePanels = Column[
  Function[g, With[{rows = nmrkTwoLoopCertificates[g, "Representatives"]},
    OpenerView[{
      g <> " certified representatives (" <> ToString[Length[rows]] <> ")",
      If[rows === {}, "No certified region.",
        Grid[
          Prepend[
            Function[r, {
              r["BoundaryZeroVariables"],
              r["CertifiedTotalScalingAssociation"],
              {r["WSL"], r["WHR"]},
              r["HierarchyGap"],
              r["CertificationVectorSource"]
            }] /@ rows,
            {"boundary x=0", "certified scaling on active variables",
              "(W_SL,W_HR)", "gap", "certificate"}
          ], Frame -> All, Alignment -> Left
        ]
      ]
    }, False]
  ]] /@ nmrkGraphNames,
  Spacings -> 1
];

nmrkGraphDefinitionGrid = Grid[
  Prepend[{
    {"one-loop hexagon",
      "(5,6),(1,6),(1,2),(2,3),(3,4),(4,5)"},
    {"planar hexbox",
      "(5,6),(1,8),(8,6),(1,2),(2,3),(3,4),(4,7),(7,5),(7,8)"},
    {"nonplanar hexbox",
      "(5,8),(1,8),(1,2),(2,3),(7,3),(7,5),(4,7),(6,8),(4,6)"},
    {"hexagon-pentagon",
      "(5,6),(1,8),(8,6),(1,3),(3,4),(4,7),(7,5),(7,2),(8,2)"}
  }, {"Graph", "Internal edges (vertex pairs, in x0,x1,... order)"}],
  Frame -> All, Alignment -> Left
];

nmrkPlanarInteriorRows = Select[
  nmrkTwoLoopCertificates["planar-hexbox", "Representatives"],
  #1["BoundaryZeroVariables"] === {} &
];
nmrkGeneratorKeys =
  ToString[InputForm[Expand[Times @@ #1["CancellationFactors"]]]] & /@
    nmrkPlanarInteriorRows;
nmrkDistinctGeneratorKeys = DeleteDuplicates[nmrkGeneratorKeys];
nmrkGeneratorAuditGrid = Grid[
  Prepend[
    MapIndexed[
      Function[{r, i},
        With[{factors = r["CancellationFactors"],
          class = First @ FirstPosition[nmrkDistinctGeneratorKeys,
            nmrkGeneratorKeys[[First[i]]]]},
          {First[i], class, r["RelativeTotalScaling"],
            TraditionalForm[factors[[1]]], TraditionalForm[factors[[2]]]}
        ]
      ],
      nmrkPlanarInteriorRows
    ],
    {"row", "generator class", "relative vector", "polynomial factor 1",
      "polynomial factor 2"}
  ], Frame -> All, Alignment -> Left
];

nmrkNotebook = Notebook[{
  Cell["NMRK asymptotic-order alignment and HRF checks", "Title"],
  Cell["This notebook contains only the central NMRK expansion and its w=z, wb=zb restriction.  It contains no DSC substitutions or DSC result files.  The relation to DSC is documented separately in NMRK_DSC_Kinematic_and_HRF_Comparison.tex.", "Text"],
  Cell["Graph and momentum conventions", "Section"],
  Cell["All momenta are algebraically outgoing.  The physical process is 2->4 with p1 and p2 incoming.  Every graph uses the external attachments p1->1, p2->4, p3->5, p4->3, p5->2 and p6->6.  For the one-loop hexagon this gives the cyclic external ordering (1,5,4,2,3,6).  The Feynman parameters x0,x1,... follow the internal-edge order displayed below.", "Text"],
  outputCell[nmrkGraphDefinitionGrid],
  Cell["NMRK kinematic variables", "Section"],
  Cell["Let P=p4^+ and Q=q1 q1bar=|q1_perp|^2.  The longitudinal variables are defined by p3^+=P X34, p4^+=P, p5^+=P/X45 and p6^+=P/(X45 X56).  Thus X34, X45 and X56 are ordered ratios of adjacent plus components; X34h and X56h below denote finite rescaled variables, not new invariants.", "Text"],
  Cell["The transverse variables z,w and their barred partners are defined by p4_perp=-q1_perp/(z-1), p5_perp=z q1_perp/[w(z-1)], p6_perp=z(w-1)q1_perp/[w(z-1)], and p3_perp=-(p4_perp+p5_perp+p6_perp).  The barred equations define zb and wb.  In a real physical slice barred variables are complex conjugates; HRF uses the algebraic chart described next.", "Text"],
  Cell["Central NMRK limit and positive chart", "Subsection"],
  Cell["The expansion parameter is eta->0.  Central NMRK means X34=X34h/eta, X56=X56h/eta and X45=O(1), with Q, z, zb, w and wb fixed.  The special surface tested here is w=z and wb=zb.  We replace (1-z)(1-zb) by the chart variable Kz and impose Q>0, X34h>0, X45>0, X56h>0 and Kz>0.", "Text"],
  Cell["For the planar ordering used here, 1-uA = X45 |w-z|^2 / [(1+X45)(|w|^2+X45 |z|^2)].  Consequently w=z is the cross-ratio boundary uA=1; it is an additional restriction, not part of generic central NMRK.", "Text"],
  Cell["Load and reproduce", "Section"],
  inputCell["SetDirectory[NotebookDirectory[]];\n$HRFQuietReports=True;\nGet[\"HiddenRegionFinder.wl\"];\nGet[\"HRF_AsymptoticOrderAlignment.wl\"];"],
  inputCell["RunProcess[{\"wolframscript\",\"-file\",FileNameJoin[{NotebookDirectory[],\"HRF_RunWZNMRKHexagonAsymptoticOrderAlignment.wl\"}]}]"],
  Cell["Current one-loop certificate", "Section"],
  Cell["Three accepted face presentations are equivalent descriptions of one structurally unique NMRK hidden region.", "Text"],
  outputCell[nmrkResultGrid],
  Cell["Scaling vectors", "Section"],
  Cell["Here the direct composition is valid: the certified total vector is f+h.  The relative vector is shown only as a pattern diagnostic; calculations use the certified total vector with final eta component 1.", "Text"],
  outputCell[nmrkStageGrid],
  Cell["Cancellation hypersurface and LP layers", "Section"],
  outputCell[Column[TraditionalForm /@ nmrkCertificate["CancellationFactors"]]],
  outputCell[nmrkPolynomialPanel],
  Cell["Two-loop NMRK results", "Section"],
  Cell["The exhaustive generic-NMRK scans have no staged candidate.  The w=z candidates have now been rerun through the current final LP/ideal-layer audit.  Full-support and one-edge-boundary regions are counted separately.", "Text"],
  outputCell[nmrkTwoLoopGrid],
  Cell["Certified two-loop representatives", "Subsection"],
  Cell["The panels are initially collapsed.  Vectors are associations on the active variables, so a boundary-stratum result cannot be mistaken for a nine-component full-support vector.", "Text"],
  outputCell[nmrkRepresentativePanels],
  Cell["Interior-generator multiplicity: open audit", "Subsection"],
  Cell["A cancellation hypersurface is defined by non-monomial polynomial factors.  No x_i alone is treated as a cancellation factor.  The seven full-support planar-hexbox vectors fall into five generator classes.  Rows 1, 4 and 5 have the same product of the same two non-monomial linear factors (up to factor order and overall signs), but have different certified vectors.  Whether these are three genuinely distinct local facets of one singular hypersurface or an overcount remains to be established by a common local-coordinate/dissection analysis.", "Text"],
  outputCell[nmrkGeneratorAuditGrid],
  Cell["References and notation sources", "Section"],
  Cell["NMRK light-cone and central-emission variables: E. P. Byrne et al., arXiv:2204.12459, and E. P. Byrne et al., arXiv:2506.10644.  Local dissection and pullback of hidden-region vectors: E. Gardi et al., arXiv:2407.13738.  The comparison with DSC is documented in NMRK_DSC_Kinematic_and_HRF_Comparison.pdf in this directory.", "Text"],
  Cell["Regression", "Section"],
  inputCell["Get[\"HRF_LayeredDissectionRegressionTests.wl\"];\nhrfRunLayeredDissectionRegressionTests[]" ]
},
  WindowTitle -> "NMRK_wz_AsymptoticOrderAlignment_Checks",
  StyleDefinitions -> "Default.nb",
  CellLabelAutoDelete -> False
];
Put[nmrkNotebook,
  FileNameJoin[{repoDirectory, "06_NMRK_wz_AsymptoticOrderAlignment_Checks.nb"}]
];

dscStageGrid = Grid[
  Prepend[{
    {"Chosen alignment representative f", dscFace,
      "face selection only"},
    {"Face-only HRF vector h", dscHRF,
      "discovery-stage vector"},
    {"Naive f+h", dscNaive, "not the final region vector"},
    {"Certified total vector v", Values[dscAudit["TotalScaling"]],
      "final original-coordinate vector"},
    {"Relative certified vector", Values[dscAudit["RelativeTotalScaling"]],
      "display diagnostic"}
  }, {"Quantity", "Vector (x0,...,x5)", "Meaning"}],
  Frame -> All, Alignment -> Left
];
dscLayerGrid = Grid[
  Prepend[
    ({#1["Weight"], #1["TermCount"], #1["IdealOrder"],
       #1["JetSupport"]} &) /@ dscOneLoopCertificate["LayerAudit"],
    {"Weight", "F terms", "I-adic order", "jet support"}
  ], Frame -> All, Alignment -> Left
];
dscOneLoopGrid = Grid[{
  {"Certified total vector", dscOneLoopCertificate["CertifiedTotalScaling"]},
  {"(W_SL,W_HR)", {dscAudit["WSL"], dscAudit["WHR"]}},
  {"Hierarchy gap", dscAudit["WHR"] - dscAudit["WSL"]},
  {"Transverse weights", dscOneLoopCertificate["TransverseWeights"]},
  {"Certificate", dscAudit["CertificationVectorSource"]}
}, Frame -> All, Alignment -> Left];

twoLoopRows = {
  With[{s = dscHexbox["Summary"],
        r = First[dscHexbox["FinalRepresentatives"]]},
    {"hexbox", s["StagedPresentationCount"],
      s["AuditedStructuralRepresentativeCount"],
      s["AcceptedStructuralRepresentativeCount"],
      Values[r["TotalScalingAudit", "TotalScaling"]],
      r["TotalScalingAudit", "HierarchyGap"]}],
  With[{s = dscNonplanar["Summary"]},
    {"nonplanar hexbox", s["StagedPresentationCount"],
      s["AuditedStructuralRepresentativeCount"],
      s["AcceptedStructuralRepresentativeCount"], "--", "--"}],
  With[{s = dscHexagonPentagon["Summary"]},
    {"hexagon-pentagon", Lookup[s, "StagedPresentationCount", 0],
      Lookup[s, "AuditedStructuralRepresentativeCount", 0],
      Lookup[s, "AcceptedStructuralRepresentativeCount", 0], "--", "--"}]
};
dscTwoLoopGrid = Grid[
  Prepend[twoLoopRows, {"Graph", "staged", "structural audits",
    "certified", "certified vector", "gap"}],
  Frame -> All, Alignment -> Left
];

dscAdjacentLeadingGrid = Grid[
  Prepend[{
    {"s12", "tau2/[a (1+tau1) (1+tau2)]", "O(1)", "positive"},
    {"s23", "-eps^2 tau1/(a zbD)", "O(eps^2)", "negative"},
    {"s34", "-1/[(a-1) (1+tau2)]", "O(1)", "positive"},
    {"s45", "1/a", "O(1)", "positive"},
    {"s56", "-tau1/[(a-1) (1+tau1)]", "O(1)", "positive"},
    {"s16", "-eps^2 tau2 zD/a", "O(eps^2)", "negative"}
  }, {"Invariant", "raw-twistor leading coefficient/form", "power",
    "physical sign after common minus"}],
  Frame -> All, Alignment -> Left
];

dscNotebook = Notebook[{
  Cell["Double-spacelike-collinear asymptotic-order alignment and HRF checks", "Title"],
  Cell["This notebook contains only the double-spacelike-collinear (DSC) expansion in the physical 2->4 sheet with p1 and p2 incoming.  It contains no NMRK substitutions or NMRK result files.  The relation to NMRK is documented separately in NMRK_DSC_Kinematic_and_HRF_Comparison.tex.", "Text"],
  Cell["Graph and momentum conventions", "Section"],
  Cell["All momenta are algebraically outgoing.  The physical process is 2->4 with p1 and p2 incoming.  Every graph uses the external attachments p1->1, p2->4, p3->5, p4->3, p5->2 and p6->6.  The Feynman parameters x0,x1,... follow the internal-edge order displayed below.", "Text"],
  outputCell[nmrkGraphDefinitionGrid],
  Cell["Definition of the DSC variables", "Section"],
  Cell["The exact momentum-twistor chart is parametrized by the small deformation eps and five finite dimensionless variables a, tau1, tau2, zD and zbD (called zc and zbc in DSC_TwistorInvariantData_20260719.wl).  Operationally these variables are defined by the exact invariant formulae in that file.  Their leading adjacent invariants in the present physical labels are displayed below.  The formula column retains the common raw twistor sign; the final column gives the physical invariant sign after applying the common minus.  This identifies the limit and physical sheet without assuming prior knowledge of the chart.", "Text"],
  outputCell[dscAdjacentLeadingGrid],
  Cell["The two spacelike-collinear pairs are (p1,p6) and (p2,p3): s16 and s23 vanish as eps^2 while the remaining adjacent invariants stay hard.  The parameter called epsilon in the invariant form of Duhr--Venkata--Zhang may therefore differ by a square from the raw twistor deformation eps used by this runner.", "Text"],
  Cell["Native-to-physical label map", "Subsection"],
  Cell["Duhr--Venkata--Zhang write the small native invariants as stilde14 and stilde23.  The graph convention is obtained by exchanging native labels 4 and 6: s12=stilde12, s13=stilde13, s26=stilde24, s36=stilde34, s23=stilde23 and s16=stilde14.  This relabelling must be applied before comparing signs or collinear pairs.", "Text"],
  Cell["Physical domain", "Subsection"],
  Cell["The physical chart used by the runner is a<0, -1<tau1<0, tau2<-1, zD<0 and zbD<0.  On the 2->4 sheet, s16<0 and s23<0; s12>0 and the adjacent outgoing invariants s34, s45 and s56 are positive.  Raw momentum-twistor brackets carry a common projective sign, so they must not be identified directly with physical pair invariants.", "Text"],
  inputCell["dscTwistorData=Import[FileNameJoin[{NotebookDirectory[],\"DSC_TwistorInvariantData_20260719.wl\"}],\"WL\"];"],
  Cell["Load and reproduce", "Section"],
  inputCell["SetDirectory[NotebookDirectory[]];\n$HRFQuietReports=True;\nGet[\"HiddenRegionFinder.wl\"];\nGet[\"HRF_AsymptoticOrderAlignment.wl\"];"],
  inputCell["RunProcess[{\"wolframscript\",\"-file\",FileNameJoin[{NotebookDirectory[],\"HRF_RunGenericDSCAsymptoticOrderAlignment.wl\"}],\"hexagon\"}]"],
  Cell["One-loop hexagon: certified DSC region", "Section"],
  Cell["The face-only sum is not the final vector.  The occupied-layer ideal-jet certificate fixes both the depth and the uniform alignment representative in the original Feynman coordinates.", "Text"],
  outputCell[dscStageGrid],
  outputCell[dscOneLoopGrid],
  Cell["Occupied-layer audit", "Subsection"],
  Cell["The lowest three occupied F layers have ideal orders 2, 1 and 0.  In particular, the nonzero weight -3 layer cancels to first order; it is not an absent eta layer.", "Text"],
  outputCell[dscLayerGrid],
  Cell["Cancellation hypersurface", "Subsection"],
  outputCell[Column[TraditionalForm /@ dscOneLoopCertificate["CancellationFactors"]]],
  Cell["Two-loop structural audit", "Section"],
  outputCell[dscTwoLoopGrid],
  Cell["Reproduction and regression", "Section"],
  inputCell["RunProcess[{\"wolframscript\",\"-file\",FileNameJoin[{NotebookDirectory[],\"HRF_RunGenericDSCAsymptoticOrderAlignment.wl\"}],\"hexbox\"}]"],
  inputCell["Get[\"HRF_LayeredDissectionRegressionTests.wl\"];\nhrfRunLayeredDissectionRegressionTests[]" ],
  Cell["References and notation sources", "Section"],
  Cell["DSC momentum-twistor and invariant parametrization: C. Duhr, A. Venkata and C. Zhang, arXiv:2507.05355.  Local dissection and pullback of hidden-region vectors: E. Gardi et al., arXiv:2407.13738.  The complete translation to NMRK variables is given in NMRK_DSC_Kinematic_and_HRF_Comparison.pdf in this directory.", "Text"]
},
  WindowTitle -> "DSC_AsymptoticOrderAlignment_Checks",
  StyleDefinitions -> "Default.nb",
  CellLabelAutoDelete -> False
];
Put[dscNotebook,
  FileNameJoin[{repoDirectory, "07_DSC_AsymptoticOrderAlignment_Checks.nb"}]
];

Print["Wrote 06_NMRK_wz_AsymptoticOrderAlignment_Checks.nb"];
Print["Wrote 07_DSC_AsymptoticOrderAlignment_Checks.nb"];
Print["Wrote compact expansion-specific certificate files."];
