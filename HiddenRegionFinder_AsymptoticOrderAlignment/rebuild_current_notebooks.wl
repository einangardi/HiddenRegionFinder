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
      "$HRFQuietReports = True;\n$HRFExample01Report = False;\n$HRFExample04Report = True;\n$HRFScalingReport = False;\n$HRFRunCrownInteriorScanOnLoad = False;\n$HRFRunSuperCrownInteriorScan = False;\n$HRFRunSuperCrownBoundaryScanOnLoad = False;\n$HRFRunHyperCrownInteriorScan = False;\n$HRFRunHyperCrownBoundaryScansOnLoad = False;\n$HRFRunDivingBeetleDiagnosticsOnLoad = False;\n$HRFRunDivingBeetleInteriorScanOnLoad = False;\n$HRFRunDBFullBoundaryScan = False;\n$HRFRunDeepBoundaryScan = False;\n$HRFEx04CompareBinomialQ = False;\n$HRFEx04TrimScanStorageQ = True;\n$HRFEx04RunObstructionSearchQ = True;\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFCandidateGeneratorSetLimit = 64;\n$HRFPolynomialMaxMonomials = 12;\n$HRFPolynomialRequireKinematicDomainQ = False;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"01_WideAngle_2to2_OffShell.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialCancellationFactors.wl\"}]];\nhrfInstallPolynomialCancellationPatch[];\nGet[FileNameJoin[{NotebookDirectory[], \"04_PolynomialFactor_Regression.wl\"}]];",
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
      "KeyTake[hrfEx04CaseIngredients[Ex04CrownRegression], {\"Generators\", \"ScalingVector\", \"VariableScaling\", \"HiddenRegionQ\"}]",
      "In[7]:="
    ],
    hrfCurSection["HyperCrown boundary x11 = 0"],
    hrfCurText["This is the current positive HyperCrown boundary example. It uses the WideAngle4ptBoundary preset and exact coverage scaling."],
    hrfCurInput[
      "hrfX11Report = hrfEx04HyperCrownX11Display[];\nhrfX11Report[\"Summary\"]",
      "In[8]:="
    ],
    hrfCurInput[
      "KeyTake[hrfX11Report[\"Ingredients\"], {\"Generators\", \"ScalingVector\", \"VariableScaling\", \"HiddenRegionQ\", \"Obstruction\", \"FSL\"}]",
      "In[9]:="
    ],
    hrfCurInput["hrfX11Report[\"AllValidTrialsScaling\"]", "In[10]:="],
    hrfCurSection["Diving Beetle checks"],
    hrfCurText["These cells are the current direct HRF checks for Diving Beetle. They are expected to produce no accepted hidden region in the tested interior and x8,x9 boundary cases."],
    hrfCurInput[
      "Ex04DivingBeetleInterior = hrfEx04DivingBeetleInterior[];\nhrfDBInteriorReport = hrfEx04DivingBeetleInteriorDisplay[];\nhrfDBInteriorReport[\"Summary\"]",
      "In[11]:="
    ],
    hrfCurInput[
      "Ex04DivingBeetleX89Target = hrfEx04DivingBeetleX89Boundary[];\nhrfDBX89Report = hrfEx04DivingBeetleX89Display[];\nhrfDBX89Report[\"Summary\"]",
      "In[12]:="
    ],
    hrfCurSection["Optional diagnostics"],
    hrfCurInput[
      "Get[FileNameJoin[{NotebookDirectory[], \"HRF_WideAngleBoundaryDiagnostic.wl\"}]];\nhrfWideAngleBoundaryDiagnostic[\"HyperCrownX11\", \"RunScalingQ\" -> False][[1]]",
      "In[13]:="
    ]
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
