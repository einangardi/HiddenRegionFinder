(* rebuild_current_notebooks.wl
   Generate curated HRF notebooks that follow only the current working path.

   Run from the HRF source directory:
     Get["rebuild_current_notebooks.wl"];
*)

ClearAll[
  hrfCurInput, hrfCurText, hrfCurSection, hrfCurSubsection, hrfCurTitle,
  hrfCurSave, hrfCurExport
];

hrfCurInput[code_String, label_String : "In[1]:="] := Module[{boxes, flat},
  flat = StringTrim @ StringReplace[
    StringReplace[StringTrim[code], RegularExpression["\r\n|\r|\n"] -> " "],
    RegularExpression[";\\s*;+"] -> "; "
  ];
  boxes = ToExpression[flat, InputForm, MakeBoxes];
  If[StringQ[boxes] && boxes === flat,
    boxes = ToExpression[
      "InterpretationBox[StyleBox[\"" <> StringReplace[flat, "\"" -> "\\\""] <>
        "\", ShowStringCharacters->True], " <> flat <> ", Editable->False]",
      InputForm,
      MakeBoxes
    ]
  ];
  Cell[BoxData[boxes], "Input", CellLabel -> label]
];

hrfCurText[text_String] := Cell[text, "Text"];
hrfCurSection[text_String] := Cell[text, "Section"];
hrfCurSubsection[text_String] := Cell[text, "Subsection"];
hrfCurTitle[text_String] := Cell[text, "Title"];

hrfCurSave[path_String, nb_Notebook] := Module[{obj},
  If[$FrontEnd =!= Null,
    obj = NotebookPut[nb, Visible -> False];
    NotebookSave[obj, path];
    NotebookClose[obj, SaveRemaining -> False],
    Export[path, nb, "Notebook"]
  ]
];

hrfCurExport[path_String, title_String, cells_List, intro_String] := Module[{nb},
  nb = Notebook[
    {Cell[CellGroupData[Join[
      {hrfCurTitle[title], hrfCurText[intro]},
      cells
    ], Open]]},
    WindowSize -> {1250, 900},
    ShowCellTags -> False,
    CellLabelAutoDelete -> False,
    StyleDefinitions -> "Default.nb",
    WindowTitle -> FileBaseName[path],
    Evaluator -> "Local"
  ];
  hrfCurSave[path, nb];
  Print["exported ", path];
];

$dir = If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName],
  Directory[]
];

(* ---------------------------------------------------------------------- *)
(* 00 Quickstart                                                           *)
(* ---------------------------------------------------------------------- *)

hrfCurExport[
  FileNameJoin[{$dir, "00_Current_HRF_Quickstart.nb"}],
  "HRF current workflow quickstart",
  {
    hrfCurSection["Fresh-kernel load gate"],
    hrfCurText["This cell checks that the current source files load from a clean kernel and that the polynomial-factor and exact-coverage-scaling entry points are present."],
    hrfCurInput[
      "ClearAll[downValueQ];\ndownValueQ[name_String] := Length[ToExpression[name, InputForm, DownValues]] > 0;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialCancellationFactors.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_FinalLogicPatch.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_Example01Common.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_ExactCoverageScaling.wl\"}]];\nhrfInstallPolynomialCancellationPatch[];\nAssociation[\n  \"CoreLoaded\" -> TrueQ[$HRFFinderCoreLoadedQ],\n  \"findObstructions\" -> downValueQ[\"findObstructions\"],\n  \"findExactCoverageLPScaling\" -> downValueQ[\"findExactCoverageLPScaling\"],\n  \"hrfCoverageFoundQ\" -> downValueQ[\"hrfCoverageFoundQ\"]\n]",
      "In[1]:="
    ],
    hrfCurSection["Compact tests"],
    hrfCurText["These are the compact checks used before preparing the Git source candidate. They are the preferred quick regression path; the exhaustive Example 02 interior scan is intentionally not run here."],
    hrfCurInput[
      "$HRFQuietReports = True;\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialFactorRegressionTests.wl\"}]];\nreg = hrfRunPolynomialFactorRegressionTests[];\nreg[\"Summary\"]",
      "In[2]:="
    ],
    hrfCurInput[
      "Block[{\n  $HRFQuietReports = True, $HRFExample02Report = False,\n  $HRFRunEx02InteriorStudiesOnLoad = False,\n  $HRFRunEx02BoundariesOnLoad = False,\n  $HRFRunEx02CrownSanityOnLoad = False,\n  $HRFRunEx02SuperCrownBoundary = False,\n  $HRFRunEx02HyperCrownBoundaries = False,\n  $HRFFindObstructionsStopOnFirstAdmissibleQ = False,\n  $HRFCandidateGeneratorSetLimit = 64\n  },\n  Get[FileNameJoin[{NotebookDirectory[], \"02_Forward_Regge_2to2_Massless.wl\"}]];\n  crownStudy = hrfEx02InteriorStudy[\"Crown\", Ex02Diagrams[\"Crown\"], 20];\n  Dataset[{KeyTake[crownStudy[\"Wide\"], {\"Hidden region identified?\", \"Scaling status\", \"Scaling vector\"}],\n    KeyTake[crownStudy[\"T23\"], {\"Hidden region identified?\", \"Scaling status\", \"Scaling vector\"}]}]\n]",
      "In[3]:="
    ],
    hrfCurSection["Where to go next"],
    hrfCurText["Use notebook 01 for wide-angle four-point examples, notebook 02 for Regge four-point examples, notebook 03 for spacelike collinear five-point examples, notebook 04 for topology preselection, and notebook 05 for regression/audit details."]
  },
  "Evaluate from a fresh kernel in this source directory. The notebook is a compact health check and index for the curated current notebooks."
];

(* ---------------------------------------------------------------------- *)
(* 01 Wide-angle four-point                                                *)
(* ---------------------------------------------------------------------- *)

hrfCurExport[
  FileNameJoin[{$dir, "01_Current_WideAngle_4pt.nb"}],
  "Current wide-angle 4-point examples",
  {
    hrfCurSection["Setup"],
    hrfCurText["This notebook uses the current polynomial-factor path and exact coverage scaling. No comparison route is run on load."],
    hrfCurInput[
      "$HRFQuietReports = True;\n$HRFExample01Report = False;\n$HRFExample04Report = True;\n$HRFScalingReport = False;\n$HRFRunCrownInteriorScanOnLoad = False;\n$HRFRunSuperCrownInteriorScan = False;\n$HRFRunSuperCrownBoundaryScanOnLoad = False;\n$HRFRunHyperCrownInteriorScan = False;\n$HRFRunHyperCrownBoundaryScansOnLoad = False;\n$HRFRunDivingBeetleDiagnosticsOnLoad = False;\n$HRFRunDivingBeetleInteriorScanOnLoad = False;\n$HRFRunDBFullBoundaryScan = False;\n$HRFRunDeepBoundaryScan = False;\n$HRFEx04CompareBinomialQ = False;\n$HRFEx04TrimScanStorageQ = True;\n$HRFEx04RunObstructionSearchQ = True;\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n\n(* Explicit exploratory profile used by ordinary interactive cells. *)\nHRFNotebookDefaultSearchProfile = <|\n  \"CandidateGeneratorSetLimit\" -> 64,\n  \"MaxTwoGeneratorUnionTrials\" -> 48,\n  \"PolynomialMaxMonomials\" -> Automatic,\n  \"LegacySignedMonomialPairsQ\" -> False,\n  \"KinDomainFindInstanceTimeLimit\" -> 5,\n  \"ObstructionFindInstanceTimeLimit\" -> 20\n|>;\n$HRFCandidateGeneratorSetLimit = HRFNotebookDefaultSearchProfile[\"CandidateGeneratorSetLimit\"];\n$HRFMaxTwoGeneratorUnionTrials = HRFNotebookDefaultSearchProfile[\"MaxTwoGeneratorUnionTrials\"];\n$HRFPolynomialMaxMonomials = HRFNotebookDefaultSearchProfile[\"PolynomialMaxMonomials\"];\n$HRFPolynomialEnableSignedMonomialPairs = HRFNotebookDefaultSearchProfile[\"LegacySignedMonomialPairsQ\"];\n$HRFKinDomainFindInstanceTimeLimit = HRFNotebookDefaultSearchProfile[\"KinDomainFindInstanceTimeLimit\"];\n$HRFObstructionFindInstanceTimeLimit = HRFNotebookDefaultSearchProfile[\"ObstructionFindInstanceTimeLimit\"];\n$HRFPolynomialRequireKinematicDomainQ = False;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"01_WideAngle_2to2_OffShell.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialCancellationFactors.wl\"}]];\nhrfInstallPolynomialCancellationPatch[];\nGet[FileNameJoin[{NotebookDirectory[], \"04_PolynomialFactor_Regression.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_WideAngleMomentumReconstruction.wl\"}]];",
      "In[1]:="
    ],
    hrfCurSection["Graphs"],
    hrfCurInput["drawGraphFromPySecDecInput[CrownInternalEdges, CrownExternalEdges]", "In[2]:="],
    hrfCurInput["drawGraphFromPySecDecInput[SuperCrownInternalEdges, SuperCrownExternalEdges]", "In[3]:="],
    hrfCurInput["drawGraphFromPySecDecInput[HyperCrownInternalEdges, HyperCrownExternalEdges]", "In[4]:="],
    hrfCurInput["drawGraphFromPySecDecInput[DBInternalEdges, DBExternalEdges]", "In[5]:="],
    hrfCurSection["Crown interior"],
    hrfCurInput[
      "Ex04CrownRegression = hrfEx04CrownRegression[];\nhrfCrownReport = hrfEx04CrownSanityDisplay[];\nhrfCrownReport",
      "In[6]:="
    ],
    hrfCurInput[
      "KeyTake[hrfEx04CaseIngredients[Ex04CrownRegression], {\"Generators\", \"ScalingVector\", \"HiddenRegionQ\"}]",
      "In[7]:="
    ],
    hrfCurSection["SuperCrown codimension-two boundary HR"],
    hrfCurText["This focused constructive check restores the SuperCrown example without attempting a full boundary survey. On B={x8=0,x9=0}, the restricted polynomial contains the Crown superleading polynomial multiplied by x10 x11. The present polynomial-factor path finds the two Crown generators, zero obstruction and one exact region vector. Boundary equations x_e=0 and scaling components v_e are reported separately."],
    hrfCurInput[
      "Ex04SuperCrownX89Target = hrfEx04SuperCrownX89Boundary[];\nhrfSCIngredients = hrfEx04CaseIngredients[Ex04SuperCrownX89Target];\n<|\n  \"Boundary B\" -> hrfSCIngredients[\"BoundaryZeroVariables\"],\n  \"Active edge order\" -> hrfSCIngredients[\"RegionVariables\"],\n  \"v_B=(v_e;1)\" -> Append[hrfSCIngredients[\"ScalingVector\"], 1],\n  \"Named components\" -> Normal[hrfSCIngredients[\"VariableScaling\"]],\n  \"Hidden region\" -> hrfSCIngredients[\"HiddenRegionQ\"]\n|>",
      "In[7a]:="
    ],
    hrfCurInput[
      "KeyTake[hrfSCIngredients, {\"Generators\", \"FSL\", \"Obstruction\", \"ScalingStatus\"}]",
      "In[7b]:="
    ],
    hrfCurInput[
      "KeyTake[Ex04SuperCrownX89Target[\"PolynomialScan\"], {\"EffectiveSearchConfiguration\", \"SearchTruncatedQ\", \"HiddenRegionSearchCompleteQ\", \"HiddenRegionCount\"}]",
      "In[7c]:="
    ],
    hrfCurSection["HyperCrown boundary x11 = 0"],
    hrfCurText["This is the current positive HyperCrown boundary example. It uses the WideAngle4ptBoundary preset and exact coverage scaling."],
    hrfCurInput[
      "hrfX11Report = hrfEx04HyperCrownX11Display[];\nhrfX11Report[\"Summary\"]",
      "In[8]:="
    ],
    hrfCurInput[
      "KeyTake[hrfX11Report[\"Ingredients\"], {\"Generators\", \"ScalingVector\", \"HiddenRegionQ\", \"Obstruction\", \"FSL\"}]",
      "In[9]:="
    ],
    hrfCurInput["hrfX11Report[\"AllValidTrialsScaling\"]", "In[10]:="],
    hrfCurSection["HyperCrown survey: interior and codimensions one and two"],
    hrfCurText["This survey separates constructive existence witnesses from certified exclusions. A direct positive witness establishes one representative; exact graph permutations and crossings establish every member of its D4 orbit. A negative statement is made only when the complete derivative/channel-polynomial factor construction, obstruction trials and exact scaling tests all finish without truncation."],
    hrfCurInput[
      "Get[FileNameJoin[{NotebookDirectory[], \"HRF_HyperCrownCodimensionSurvey.wl\"}]];\nhrfHyperCrownCodimensionSurveyTable[]",
      "In[10a]:="
    ],
    hrfCurSubsection["Exact graph symmetry and orbit completion"],
    hrfCurText["The HyperCrown graph has the D4 automorphism group of its four-edge square. Some elements leave s12 and s23 fixed; others exchange them. In this topology survey an external permutation, its induced edge permutation and the corresponding relabelling of the two invariants are performed together. A crossing-related image is therefore the same physical case with a different choice of which symmetric external pair is called incoming. The positive Schwinger orthant, cancellation locus and region vector are carried bijectively to the image, so one HRF representative certifies its full D4 orbit."],
    hrfCurInput["hrfHyperCrownSymmetryAudit[]", "In[10b]:="],
    hrfCurInput["hrfHyperCrownSymmetryOrbitTable[]", "In[10c]:="],
    hrfCurSubsection["Enumeration and level of certainty"],
    hrfCurText["There are two inequivalent HyperCrown boundary-HR types through codimension two. Type I has one square edge contracted and four labelled representatives. Type II has two adjacent square edges contracted and four labelled representatives. The opposite-edge orbit has no HR: on x8=x9=0 the complete uncapped polynomial-factor construction produces only the s12-supported Crown-like generator, while the s23 coefficient supplies no companion generator; exact coverage proves that the remaining one-generator presentation has no scaling vector. The x10=x11 result follows by D4 symmetry. The interior remains a separate unresolved search."],
    hrfCurInput["hrfHyperCrownEstablishedTypeTable[]", "In[10d]:="],
    hrfCurText["Notation is kept separate: B denotes equations x_e=0, whereas v_e is a component of the scaling vector defined by x_e~delta^(v_e). The master edge order is X=(x0,x1,...,x11); delete the variables in B while retaining that order. Every augmented normal is displayed horizontally as v_B=(v_e;1), followed by named component rules {v_i->...}. The two accepted generator presentations on each directly positive codimension-two stratum give the same vector, so they constitute one region rather than two distinct HRs."],
    hrfCurInput["hrfHyperCrownPositiveRegionVectorTable[]", "In[10e]:="],
    hrfCurText["Search budgets are explicit. The exploratory profile is useful for finding positive witnesses; it cannot certify absence. The certified profile removes the candidate, two-generator-union and polynomial-size caps. FullHarvestQ->True means complete factorisation of the relevant derivatives and primitive channel polynomials. The former signed-monomial-pair enlargement is retained only as a legacy diagnostic because arbitrary two-term sub-sums are not polynomial cancellation factors."],
    hrfCurInput["Dataset @ KeyValueMap[Function[{name, cfg}, Join[<|\"Profile\" -> name|>, cfg]], HRFSearchProfiles20260728]", "In[10f]:="],
    hrfCurText["The opposite-edge audit displays both channel coefficients. The s12 coefficient factorises into the familiar Crown-like product. The complete derivative/channel-polynomial factor construction finds no admissible generator supported in s23; the long s23 coefficient is therefore an obstruction, not a second cancellation generator."],
    hrfCurInput["hrfHyperCrownOppositePairChannelAudit[]", "In[10g]:="],
    hrfCurInput[
      "hcCase = hrfHyperCrownRunCurrentStratum[{x8, x9},\n  \"FullHarvestQ\" -> True,\n  \"CandidateGeneratorSetLimit\" -> Infinity,\n  \"MaxTwoGeneratorUnionTrials\" -> Infinity,\n  \"PolynomialMaxMonomials\" -> Automatic,\n  \"LegacySignedMonomialPairsQ\" -> False,\n  \"KinDomainFindInstanceTimeLimit\" -> Infinity,\n  \"ObstructionFindInstanceTimeLimit\" -> Infinity,\n  \"StopOnFirstAdmissible\" -> False];\nhrfHyperCrownStratumAudit[hcCase]",
      "In[10f]:="
    ],
    hrfCurInput[
      "(* Interior audit: slow and presently not a certified exclusion. *)\n(* hcInterior = hrfHyperCrownRunCurrentStratum[{}, \"FullHarvestQ\" -> True]; *)",
      "In[10g]:="
    ],
    hrfCurSection["Momentum-space reconstruction of the positive regions"],
    hrfCurText["These are constructive momentum-flow certificates for the Crown and for every HyperCrown stratum in the two established symmetry orbits. The LP rule x_e~delta^(v_e) implies q_e^2~delta^(-v_e). Component powers are displayed as (q+,q-,qPerp), with p1 chosen as the large-minus direction and p2 as the large-plus direction. A p3- or p4-collinear momentum has all three fixed-frame components of order one; its virtuality is nevertheless O(delta) because the leading longitudinal and transverse pieces obey the on-shell relation. The Jet direction column records this coefficient-level information, which cannot be inferred from component valuations alone."],
    hrfCurSubsection["Crown interior: Landshoff momentum flow"],
    hrfCurText["All eight propagators have virtuality O(delta). The lines occur in four jet pairs parallel to p1,p2,p3,p4 and join two disconnected hard vertices. Three jet momenta may be chosen as loop variables; the fourth is fixed by k1+k2=k3+k4. This is the wide-angle Landshoff region, not a Glauber region at generic scattering angle."],
    hrfCurInput[
      "CrownMomentumCertificate = hrfWideAngleCrownMomentumCertificate[];\nhrfWideAngleMomentumCertificateSummary[CrownMomentumCertificate]",
      "In[11]:="
    ],
    hrfCurInput["CrownMomentumCertificate[\"MomentumTable\"]", "In[12]:="],
    hrfCurInput[
      "<|\"MomentumRelations\" -> CrownMomentumCertificate[\"MomentumRelations\"],\n  \"VertexConservationCompatibleQ\" -> CrownMomentumCertificate[\"VertexAudit\", \"AllVertexComponentsCompatibleQ\"],\n  \"IndependentLoopBasisValidQ\" -> CrownMomentumCertificate[\"IndependentLoopBasisValidQ\"]|>",
      "In[13]:="
    ],
    hrfCurSubsection["HyperCrown boundary x11=0: Landshoff plus a soft loop"],
    hrfCurText["The parametric boundary x11=0 contracts the x11 edge and merges its endpoints before momentum conservation is imposed. The ten jet propagators have q_e^2~delta, whereas x10 has q10~(delta,delta,delta) and q10^2~delta^2. A valid four-loop basis is {x0,x4,x6,x10}: three external-direction jet momenta plus the soft exchange. Thus the boundary region is a Landshoff descendant with an extra soft loop, not a new generic-angle Glauber mode."],
    hrfCurInput[
      "HyperCrownX11MomentumCertificate = hrfWideAngleHyperCrownX11MomentumCertificate[];\nhrfWideAngleMomentumCertificateSummary[HyperCrownX11MomentumCertificate]",
      "In[14]:="
    ],
    hrfCurInput["HyperCrownX11MomentumCertificate[\"MomentumTable\"]", "In[15]:="],
    hrfCurInput[
      "<|\"BoundaryContraction\" -> HyperCrownX11MomentumCertificate[\"BoundaryContraction\"],\n  \"MomentumRelations\" -> HyperCrownX11MomentumCertificate[\"MomentumRelations\"],\n  \"VertexConservationCompatibleQ\" -> HyperCrownX11MomentumCertificate[\"VertexAudit\", \"AllVertexComponentsCompatibleQ\"],\n  \"IndependentLoopBasisValidQ\" -> HyperCrownX11MomentumCertificate[\"IndependentLoopBasisValidQ\"]|>",
      "In[16]:="
    ],
    hrfCurSubsection["All positive HyperCrown strata"],
    hrfCurText["The four codimension-one regions are symmetry-related Landshoff descendants with one soft loop: contracting x8, x9, x10 or x11 makes the opposite square edge x9, x8, x11 or x10 soft, respectively. The four positive adjacent-pair codimension-two regions have uniform v_e=-1 on every active parameter. Their extra parallel pair is collinear to p1, p2, p3 or p4 according to the stratum; no propagator or loop requires Glauber scaling."],
    hrfCurInput[
      "HyperCrownPositiveMomentumCertificates = hrfWideAngleHyperCrownPositiveMomentumCertificates[];\nDataset @ KeyValueMap[Function[{stratum, cert}, <|\n  \"Boundary B\" -> stratum,\n  \"v_B (active order;1)\" -> ToString[InputForm[cert[\"ScalingVectorWithDelta\"]]],\n  \"Virtualities\" -> ToString[InputForm[Normal[cert[\"VirtualityPowers\"]]]],\n  \"Vertex conservation\" -> cert[\"VertexAudit\", \"AllVertexComponentsCompatibleQ\"],\n  \"Loop basis valid\" -> cert[\"IndependentLoopBasisValidQ\"],\n  \"Interpretation\" -> cert[\"Interpretation\"]|>], HyperCrownPositiveMomentumCertificates]",
      "In[16a]:="
    ],
    hrfCurText["Select any established stratum to inspect the complete edge-by-edge (+,-,perp) table. The example below is the uniform x8=x10=0 region; available keys are {x8}, {x9}, {x10}, {x11}, {x8,x10}, {x8,x11}, {x9,x10} and {x9,x11}."],
    hrfCurInput[
      "HyperCrownPositiveMomentumCertificates[\"{x8, x10}\"][\"MomentumTable\"]",
      "In[16b]:="
    ],
    hrfCurSection["Diving Beetle checks"],
    hrfCurText["These cells are the current direct HRF checks for Diving Beetle. They are expected to produce no accepted hidden region in the tested interior and x8,x9 boundary cases."],
    hrfCurInput[
      "Ex04DivingBeetleInterior = hrfEx04DivingBeetleInterior[];\nhrfDBInteriorReport = hrfEx04DivingBeetleInteriorDisplay[];\nhrfDBInteriorReport[\"Summary\"]",
      "In[17]:="
    ],
    hrfCurInput[
      "Ex04DivingBeetleX89Target = hrfEx04DivingBeetleX89Boundary[];\nhrfDBX89Report = hrfEx04DivingBeetleX89Display[];\nhrfDBX89Report[\"Summary\"]",
      "In[18]:="
    ],
    hrfCurText["The more extensive Diving Beetle exclusion and the per-trial development diagnostics are maintained in the dedicated audit notebooks; they are not repeated here."]
  },
  "Current wide-angle path only: polynomial factors, generator physics filter, and exact coverage scaling."
];

(* ---------------------------------------------------------------------- *)
(* 02 Regge four-point                                                     *)
(* ---------------------------------------------------------------------- *)

hrfCurExport[
  FileNameJoin[{$dir, "02_Current_Regge_4pt.nb"}],
  "Current Regge-limit 4-point examples",
  {
    hrfCurSection["Setup"],
    hrfCurText["This notebook runs the current Regge path. Boundaries are explicit calls so each block can be run in a fresh kernel if memory is tight."],
    hrfCurInput[
      "$HRFExample02Report = True;\n$HRFScalingReport = False;\n$HRFRunEx02InteriorStudiesOnLoad = False;\n$HRFRunEx02LegacyCrownForwardOnLoad = False;\n$HRFRunEx02BoundariesOnLoad = False;\n$HRFRunEx02SuperCrownBoundary = False;\n$HRFRunEx02HyperCrownBoundaries = False;\n$HRFRunEx02DBBoundary = False;\n$HRFRunEx02CrownSanityOnLoad = False;\n$HRFEx02TrimScanStorageQ = True;\n$HRFEx02DeepTrimScanStorageQ = True;\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFCandidateGeneratorSetLimit = 64;\n$HRFPolynomialMaxMonomials = 12;\n$HRFPolynomialRequireKinematicDomainQ = False;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialCancellationFactors.wl\"}]];\nhrfInstallPolynomialCancellationPatch[];\nGet[FileNameJoin[{NotebookDirectory[], \"02_Forward_Regge_2to2_Massless.wl\"}]];\nhrfEx02PostLoadCheck[]",
      "In[1]:="
    ],
    hrfCurSection["Channel convention and graphs"],
    hrfCurInput["hrfEx02ChannelLegend[]", "In[2]:="],
    hrfCurInput["hrfEx02ShowDiagram[CrownInternalEdges, CrownExternalEdges]", "In[3]:="],
    hrfCurInput["hrfEx02ShowDiagram[SuperCrownInternalEdges, CrownExternalEdges]", "In[4]:="],
    hrfCurInput["hrfEx02ShowDiagram[HyperCrownInternalEdges, CrownExternalEdges]", "In[5]:="],
    hrfCurInput["hrfEx02ShowDiagram[DBInternalEdges, DBExternalEdges]", "In[6]:="],
    hrfCurSection["Crown interior positive control"],
    hrfCurText["Runs wide angle plus the three Regge channels for the Crown interior. This is the positive control for the Regge path."],
    hrfCurInput[
      "Ex02CrownInterior = hrfEx02InteriorStudy[\"Crown\", Ex02Diagrams[\"Crown\"], 20];\nDataset[KeyTake[Ex02CrownInterior[#], {\"Kinematic regime\", \"Hidden region identified?\", \"Scaling status\", \"Scaling vector\"}] & /@ {\"Wide\", \"T23\", \"T12\", \"T13\"}]",
      "In[7]:="
    ],
    hrfCurSection["SuperCrown boundary x8 = x9 = 0"],
    hrfCurText["Expected current result: accepted hidden region in wide angle and in all three Regge channels."],
    hrfCurInput["hrfEx02RunSuperCrownBoundary[]", "In[8]:="],
    hrfCurInput["Ex02SuperCrownReggeChannelSummary", "In[9]:="],
    hrfCurInput["Ex02SuperCrownBoundaryDetailTable", "In[10]:="],
    hrfCurInput[
      "hrfSCWideReport = hrfEx02ReggeChannelDisplay[\"SuperCrown\", \"Boundary {x8,x9}\", \"Wide\"];\nKeyTake[hrfSCWideReport[\"Ingredients\"], {\"Generators\", \"ScalingVector\", \"VariableScaling\", \"HiddenRegionQ\"}]",
      "In[11]:="
    ],
    hrfCurSection["HyperCrown boundary x11 = 0"],
    hrfCurText["This is slower than SuperCrown. In the monitored split run, the accepted Regge boundary HR appeared in channel T12; wide angle is handled in notebook 01."],
    hrfCurInput["hrfEx02RunHyperCrownBoundary[]", "In[12]:="],
    hrfCurInput["Ex02HyperCrownBoundaryDetailTable", "In[13]:="],
    hrfCurInput["Ex02HyperCrownBoundaryHRTable", "In[14]:="],
    hrfCurInput[
      "hrfHCT12Report = hrfEx02ReggeChannelDisplay[\"HyperCrown\", \"Boundary {x11}\", \"T12\"];\nKeyTake[hrfHCT12Report[\"Ingredients\"], {\"Generators\", \"ScalingVector\", \"VariableScaling\", \"HiddenRegionQ\"}]",
      "In[15]:="
    ],
    hrfCurSection["Diving Beetle boundary x8 = x9 = 0"],
    hrfCurText["This is the current negative control in the tested Regge boundary stratum."],
    hrfCurInput["hrfEx02RunDBBoundary[]", "In[16]:="],
    hrfCurInput["hrfEx02BoundaryComparisonDisplay[\"Diving Beetle\"]", "In[17]:="],
    hrfCurSection["Optional interiors"],
    hrfCurText["Run only when needed; HyperCrown interior is slow. These calls use the same current Regge path one diagram at a time."],
    hrfCurInput[
      "Ex02SuperCrownInterior = hrfEx02InteriorStudy[\"SuperCrown\", Ex02Diagrams[\"SuperCrown\"], 20];\nEx02HyperCrownInterior = hrfEx02InteriorStudy[\"HyperCrown\", Ex02Diagrams[\"HyperCrown\"], 30];\nEx02DBInterior = hrfEx02InteriorStudy[\"Diving Beetle\", Ex02Diagrams[\"Diving Beetle\"], 20];",
      "In[18]:="
    ]
  },
  "Current Regge path only: explicit boundary/interior runners and Regge delta layers in scaling acceptance."
];

(* ---------------------------------------------------------------------- *)
(* 03 Five-point spacelike collinear                                       *)
(* ---------------------------------------------------------------------- *)

hrfCurExport[
  FileNameJoin[{$dir, "03_Current_SpacelikeCollinear_5pt.nb"}],
  "Current spacelike-collinear 5-point examples",
  {
    hrfCurSection["Setup for seed and vertex"],
    hrfCurInput[
      "$HRFQuietReports = True;\n$HRFExample04Report = True;\n$HRFEx04RunObstructionSearchQ = True;\n$HRFRunEx04RegressionOnLoad = False;\n$HRFRunEx04SlowCasesOnLoad = False;\n$HRFRunEx04FivePointOnLoad = False;\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFCandidateGeneratorSetLimit = 128;\n$HRFMaxProductSubsetSize = 2;\n$HRFEx04TrimScanStorageQ = True;\n$HRFPolynomialRequireKinematicDomainQ = False;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_Example03CollinearCore.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialCancellationFactors.wl\"}]];\nhrfInstallPolynomialCancellationPatch[];\nGet[FileNameJoin[{NotebookDirectory[], \"04_PolynomialFactor_Regression.wl\"}]];",
      "In[1]:="
    ],
    hrfCurSection["Seed graph"],
    hrfCurInput["drawGraphFromPySecDecInput[seedInternalLines, seedExternalLines]", "In[2]:="],
    hrfCurInput[
      "Ex04Seed5ptInterior = hrfEx04Seed5ptInterior[];\nhrfSeedReport = hrfEx04FivePointCaseDisplay[Ex04Seed5ptInterior, \"Seed5pt\"];\nhrfSeedReport[\"Summary\"]",
      "In[3]:="
    ],
    hrfCurInput[
      "KeyTake[hrfSeedReport[\"Ingredients\"], {\"Generators\", \"ScalingVector\", \"VariableScaling\", \"HiddenRegionQ\", \"Obstruction\", \"FSL\"}]",
      "In[4]:="
    ],
    hrfCurSection["Three-loop vertex graph"],
    hrfCurInput["drawGraphFromPySecDecInput[ThreeLoopVertexInternalLines, seedExternalLines]", "In[5]:="],
    hrfCurInput[
      "Ex04ThreeLoopVertexInterior = hrfEx04ThreeLoopVertexInterior[];\nhrfVertexReport = hrfEx04FivePointCaseDisplay[Ex04ThreeLoopVertexInterior, \"ThreeLoopVertex\"];\nhrfVertexReport[\"Summary\"]",
      "In[6]:="
    ],
    hrfCurInput[
      "KeyTake[hrfVertexReport[\"Ingredients\"], {\"Generators\", \"ScalingVector\", \"VariableScaling\", \"HiddenRegionQ\", \"Obstruction\", \"FSL\"}]",
      "In[7]:="
    ],
    hrfCurInput["hrfEx04FivePointComparisonDisplay[{Ex04Seed5ptInterior, Ex04ThreeLoopVertexInterior}]", "In[8]:="],
    hrfCurSection["Seven/eight-propagator descendant scan"],
    hrfCurText["This is the current compact descendant scan. It regenerates Example03PolynomialDescendantScanSummary.wl/csv files in the notebook directory."],
    hrfCurInput[
      "SetDirectory[NotebookDirectory[]];\n$HRFRunExample03EightPropBoundaryScanQ = True;\nGet[\"HRF_RunExample03PolynomialDescendantScan.wl\"];",
      "In[9]:="
    ],
    hrfCurInput["Example03PolynomialDescendantSummary", "In[10]:="],
    hrfCurInput["Dataset[Example03PolynomialDescendantHRRows]", "In[11]:="],
    hrfCurSection["Full 70-topology preselected scan"],
    hrfCurText["Optional and slower. Run interior and boundary scans, then load the result browser. These are the current commands for regenerating the five-point preselected outputs."],
    hrfCurInput[
      "SetDirectory[NotebookDirectory[]];\n$HRFPreselectedRunInteriorQ = True;\n$HRFPreselectedRunBoundaryQ = False;\n$HRFPreselectedOutputPrefix = \"Preselected5ptHRFScan_interior\";\nGet[\"HRF_RunPreselected5ptScan.wl\"];",
      "In[12]:="
    ],
    hrfCurInput[
      "SetDirectory[NotebookDirectory[]];\n$HRFPreselectedRunInteriorQ = False;\n$HRFPreselectedRunBoundaryQ = True;\n$HRFPreselectedBoundaryMaxCodim = 2;\n$HRFPreselectedOutputPrefix = \"Preselected5ptHRFScan_boundary_codim2\";\nGet[\"HRF_RunPreselected5ptScan.wl\"];",
      "In[13]:="
    ],
    hrfCurInput[
      "$HRFQuietReports = True;\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_Example03PreselectedResults.wl\"}]];\nhrfEx03PreselectedScanSummary[]",
      "In[14]:="
    ],
    hrfCurInput["hrfEx03PreselectedInteriorHRTable[]", "In[15]:="],
    hrfCurInput["hrfEx03PreselectedBoundaryHRTable[]", "In[16]:="],
    hrfCurInput["hrfEx03PreselectedHRTopologyPanels[]", "In[17]:="]
  },
  "Current five-point path: seed, three-loop vertex, 7/8 descendants, and optional 70-topology preselected scan."
];

(* ---------------------------------------------------------------------- *)
(* 04 Preselection                                                         *)
(* ---------------------------------------------------------------------- *)

hrfCurExport[
  FileNameJoin[{$dir, "04_Current_5pt_Preselection.nb"}],
  "Current 5-point topology preselection",
  {
    hrfCurSection["Setup"],
    hrfCurInput[
      "$HRFQuietReports = True;\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_RecursiveDerivativePreselection.wl\"}]];",
      "In[1]:="
    ],
    hrfCurSection["Run recursive derivative preselection"],
    hrfCurText["This produces the 70 representative topology handoff. PreselectionZeroVars are diagnostic provenance for the recursive sign test; HRF still receives the original listed graph."],
    hrfCurInput[
      "RDScan = hrfRunRecursiveDerivativePreselection[];\nRDScan[\"Summary\"]",
      "In[2]:="
    ],
    hrfCurInput["RDScan[\"CandidateDataset\"]", "In[3]:="],
    hrfCurInput["hrfRecursiveCandidateDrawingGrid[Take[RDScan[\"CandidateRows\"], UpTo[20]], 2]", "In[4]:="],
    hrfCurSection["Export handoff fixture"],
    hrfCurInput[
      "Export[FileNameJoin[{NotebookDirectory[], \"RecursiveDerivativePreselectionHandoff.csv\"}], hrfRecursiveCSVTable[RDScan[\"CandidateHandoffRows\"]]];\nPut[RDScan[\"CandidateHandoffRows\"], FileNameJoin[{NotebookDirectory[], \"RecursiveDerivativePreselectionHandoff.wl\"}]];",
      "In[5]:="
    ]
  },
  "Current preselection notebook: recursive derivative preselection only, with the handoff fixture used by the five-point HRF scan."
];

(* ---------------------------------------------------------------------- *)
(* 05 Regression and audits                                                *)
(* ---------------------------------------------------------------------- *)

hrfCurExport[
  FileNameJoin[{$dir, "05_Current_Regression_and_Audits.nb"}],
  "Current regression and audit checks",
  {
    hrfCurSection["Polynomial regression suite"],
    hrfCurInput[
      "$HRFQuietReports = True;\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialFactorRegressionTests.wl\"}]];\nres = hrfRunPolynomialFactorRegressionTests[];\nres[\"Summary\"]",
      "In[1]:="
    ],
    hrfCurInput["res[\"Rows\"]", "In[2]:="],
    hrfCurSection["Notebook smoke tests"],
    hrfCurText["Default smoke tests are compact. Full Example 02 interior sweeps should be run through monitored split jobs rather than as a single notebook smoke."],
    hrfCurInput[
      "$HRFSmokeRunSlowQ = False;\n$HRFSmokeRunVerySlowQ = False;\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_NotebookSmokeTests.wl\"}]];\nsmoke = hrfRunNotebookSmokeTests[];\nsmoke[\"Summary\"]",
      "In[3]:="
    ],
    hrfCurSection["Three-loop vertex focused audit"],
    hrfCurInput[
      "$HRFQuietReports = True;\n$HRFExample04Report = False;\n$HRFEx04RunObstructionSearchQ = True;\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFCandidateGeneratorSetLimit = 128;\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_Example03CollinearCore.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"04_PolynomialFactor_Regression.wl\"}]];\nvertexCase = hrfEx04ThreeLoopVertexInterior[];\nvertexScan = vertexCase[\"PolynomialScan\"];\nvertexScaling = hrfScanCoverageScalingData[vertexScan, Automatic];\nAssociation[\n  \"HiddenRegionQ\" -> Lookup[vertexCase[\"ComparisonRow\"], \"PolynomialHiddenRegionQ\", False],\n  \"GeneratorCount\" -> Length[Lookup[vertexScan, \"Generators\", {}]],\n  \"ScalingStatus\" -> Lookup[vertexScaling, \"ScalingStatusMessage\", Lookup[vertexScaling, \"ScalingStatus\", \"--\"]],\n  \"Scaling\" -> Lookup[vertexScaling, \"Scaling\", Missing[\"NoScaling\"]]\n]",
      "In[4]:="
    ],
    hrfCurSection["Generator inspection tables"],
    hrfCurInput[
      "Get[FileNameJoin[{NotebookDirectory[], \"hrfInspectThreeLoopVertexGenerators.wl\"}]];\nhrfThreeLoopVertexCandidateTable[]",
      "In[5]:="
    ]
  },
  "Regression notebook for the current HRF implementation. Use before packaging or after changing obstruction/scaling code."
];

Print["Current HRF notebooks rebuilt in ", $dir];
