(* rebuild_standard_notebooks.wl
   Regenerate collaboration notebooks with BoxData Input cells for standard
   syntax colouring. Run once from the share directory:
     Get["rebuild_standard_notebooks.wl"];
*)

ClearAll[hrfNbStdInput, hrfNbStdInitCell, hrfNbStdText, hrfNbStdSection, hrfNbStdTitle, hrfNbStdSave, hrfNbStdExport];

hrfNbStdInput[code_String, label_String:"In[1]:="] := Module[{boxes, flat},
  (* Join lines with ; not space — bare newline becomes implicit Times in InputForm. *)
  flat = StringTrim @ StringReplace[
    StringReplace[StringTrim[code], RegularExpression["\r\n|\r|\n"] -> "; "],
    RegularExpression[";\\s*;+"] -> "; "
  ];
  boxes = ToExpression[flat, InputForm, MakeBoxes];
  (* Bare symbols: Export collapses to plain strings (no syntax colour). *)
  If[StringQ[boxes] && boxes === flat,
    boxes = ToExpression[
      "InterpretationBox[StyleBox[\"" <> flat <> "\", ShowStringCharacters->True], " <> flat <> ", Editable->False]",
      InputForm,
      MakeBoxes
    ]
  ];
  Cell[BoxData[boxes], "Input", CellLabel -> label]
];

(* Do NOT call RestartKernel here: with InitializationCellEvaluation->True that loops forever on open. *)
hrfNbStdInitCell[] := Cell[
  BoxData @ ToExpression[
    "Print[\"HRF notebook loaded. Before In[1], use Evaluation > Restart Kernel once (manual).\"]; Null",
    InputForm,
    MakeBoxes
  ],
  "Input",
  InitializationCell -> True,
  ShowCellTags -> False,
  CellLabel -> "init:="
];

hrfNbStdText[text_String] := Cell[text, "Text"];
hrfNbStdSection[text_String] := Cell[text, "Section"];
hrfNbStdTitle[text_String] := Cell[text, "Title"];

hrfNbStdSave[path_String, nb_Notebook] := Module[{obj},
  If[$FrontEnd =!= Null,
    obj = NotebookPut[nb, Visible -> False];
    NotebookSave[obj, path];
    NotebookClose[obj, SaveRemaining -> False];
    ,
    Export[path, nb, "Notebook"]
  ]
];

hrfNbStdExport[
  path_String,
  title_String,
  cells_List,
  intro_String:"Evaluate cells in order from the top. Use a fresh kernel.",
  evaluator_:Automatic
] := Module[{nb, headCells, nbOpts, windowTitle},
  windowTitle = FileBaseName[path];
  headCells = Join[
    {hrfNbStdTitle[title], hrfNbStdText[intro]},
    If[StringQ[evaluator],
      {
        hrfNbStdText[
          "Kernel \"" <> evaluator <>
            "\" (Evaluation > Notebook's Kernel). On open, init prints a reminder only. Restart Kernel once manually, then run In[1] onward. Do not put RestartKernel in auto-run init cells."
        ],
        hrfNbStdInitCell[]
      },
      {}
    ],
    cells
  ];
  nbOpts = {
    WindowSize -> {1200, 900},
    ShowCellTags -> False,
    CellLabelAutoDelete -> False,
    StyleDefinitions -> "Default.nb",
    WindowTitle -> windowTitle,
    Sequence @@ If[StringQ[evaluator],
      {Evaluator -> evaluator, InitializationCellEvaluation -> False, InitializationCellWarning -> False},
      {}
    ]
  };
  nb = Notebook[{Cell[CellGroupData[headCells, Open]]}, Sequence @@ nbOpts];
  hrfNbStdSave[path, nb];
  Print["exported ", path, If[StringQ[evaluator], " (kernel " <> evaluator <> ")", ""]];
];

$dir = If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName],
  Directory[]
];

hrfNbStdExport[
  FileNameJoin[{$dir, "01_WideAngle_4pt.nb"}],
  "Wide-angle 4-point examples",
  {
    hrfNbStdSection["Setup"],
    hrfNbStdText["Example 01 (light load). In[1] loads diagrams + polynomial patch + Crown interior only (~1–2 min, WideAngle4pt preset). HyperCrown {x11}=0 is optional at In[17]. HyperCrown full interior is optional at In[19]. Run one notebook at a time on Local kernel."],
    hrfNbStdInput[
      "$HRFQuietReports = True;\n$HRFExample01Report = True;\n$HRFExample04Report = True;\n$HRFScalingReport = False;\n$HRFRunCrownInteriorScanOnLoad = False;\n$HRFRunHyperCrownBoundaryScansOnLoad = False;\n$HRFRunSuperCrownBoundaryScanOnLoad = False;\n$HRFRunDivingBeetleDiagnosticsOnLoad = False;\n$HRFRunHyperCrownInteriorScan = False;\n$HRFRunDivingBeetleInteriorScanOnLoad = False;\n$HRFEx04CompareBinomialQ = False;\n$HRFEx04TrimScanStorageQ = True;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"01_WideAngle_2to2_OffShell.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialCancellationFactors.wl\"}]];\n$HRFPolynomialMaxMonomials = 12;\n$HRFPolynomialRequireKinematicDomainQ = False;\nhrfInstallPolynomialCancellationPatch[];\n$HRFEx04RunObstructionSearchQ = True;\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFCandidateGeneratorSetLimit = 64;\nGet[FileNameJoin[{NotebookDirectory[], \"04_PolynomialFactor_Regression.wl\"}]];\nEx04CrownRegression = hrfEx04CrownRegression[];\nPrint[\"=== Example 01 CORE LOAD COMPLETE ===\"];\nPrint[\"Polynomial-only (no binomial). Next: In[2] Crown table; optional HyperCrown cells below.\"];",
      "In[1]:="
    ],
    hrfNbStdSection["Crown sanity check"],
    hrfNbStdText["Wide-angle Crown interior (polynomial). Requires setup In[1] complete. Shows generators and scaling vector."],
    hrfNbStdInput["hrfEx04CrownSanityDisplay[]", "In[2]:="],
    hrfNbStdSection["Diagrams"],
    hrfNbStdInput["drawGraphFromPySecDecInput[CrownInternalEdges, CrownExternalEdges]", "In[3]:="],
    hrfNbStdInput["drawGraphFromPySecDecInput[SuperCrownInternalEdges, CrownExternalEdges]", "In[4]:="],
    hrfNbStdInput["drawGraphFromPySecDecInput[HyperCrownInternalEdges, CrownExternalEdges]", "In[5]:="],
    hrfNbStdInput["drawGraphFromPySecDecInput[DBInternalEdges, CrownExternalEdges]", "In[6]:="],
    hrfNbStdSection["Crown interior (reference hidden region)"],
    hrfNbStdText["Optional binomial Crown reference (slow if polynomial patch already active). Set $HRFRunCrownInteriorScanOnLoad=True and reload 01 before the patch, or evaluate manually."],
    hrfNbStdInput[
      "If[AssociationQ[CrownScan], Dataset[{KeyTake[hrfHiddenSummaryRow[\"Crown\", \"Interior\", {}, VarsCrown, CrownScan, hrfCoverageData[CrownScan, CrownData[\"UF\"][\"U\"], VarsCrown, 5]], {\"Region vector\", \"Hidden region identified?\", \"Scaling vector\", \"Variable scaling by region variable\", \"Comment\"}]}], \"CrownScan not run (binomial interior disabled)\"]",
      "In[7]:="
    ],
    hrfNbStdSection["Interior region-study tables"],
    hrfNbStdText["After In[1] these tables are empty for HyperCrown until optional Ex04 runs: In[17] ({x11}=0 boundary) and/or In[19] (full interior), then re-evaluate In[8] and In[13]. Diving Beetle polynomial runs live in 01a_DivingBeetle_WideAngle.nb (interior + {x8,x9} boundary); In[9] here is legacy PairSectors only if you set load flags before In[1]."],
    hrfNbStdInput["hrfHyperCrownRegionStudyTable[]", "In[8]:="],
    hrfNbStdInput["hrfDivingBeetleRegionStudyTable[]", "In[9]:="],
    hrfNbStdSection["Boundary outcome tables"],
    hrfNbStdText["HyperCrown boundary table requires $HRFRunHyperCrownBoundaryScansOnLoad=True before setup (15 strata, slow)."],
    hrfNbStdInput["hrfEx01BoundaryOutcomeTable[HyperCrownBoundaryCandidateScans]", "In[10]:="],
    hrfNbStdInput["If[ValueQ[DBBoundaryOutcomeTable], DBBoundaryOutcomeTable, \"Diving Beetle boundary scan not run\"]", "In[11]:="],
    hrfNbStdInput["hrfDivingBeetleFailureNarrative[]", "In[12]:="],
    hrfNbStdSection["Channel obstruction attempts (HyperCrown)"],
    hrfNbStdText["Populates after In[17]/In[19] (same Ex04 bridge as In[8]); re-run this cell after those optional runs."],
    hrfNbStdInput["hrfHyperCrownChannelAttemptTable[]", "In[13]:="],
    hrfNbStdSection["Polynomial hidden regions (Crown + HyperCrown)"],
    hrfNbStdText["In[1] computed Ex04CrownRegression only. Optional HyperCrown {x11}=0 (~30 s) at In[17]. Full HyperCrown interior (~10–20 min, polynomial-only) at In[19] only if needed."],
    hrfNbStdInput[
      "$HRFEx04RunObstructionSearchQ = True;\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFCandidateGeneratorSetLimit = 64;\n$HRFObstructionFindInstanceTimeLimit = 20;\n$HRFPolynomialRequireKinematicDomainQ = False;\nIf[! ValueQ[Ex04CrownRegression], Get[FileNameJoin[{NotebookDirectory[], \"04_PolynomialFactor_Regression.wl\"}]]];",
      "In[14]:="
    ],
    hrfNbStdText["Crown interior (polynomial, PairSectors) — from In[1] unless missing."],
    hrfNbStdInput[
      "If[! ValueQ[Ex04CrownRegression], Ex04CrownRegression = hrfEx04CrownRegression[]]; Ex04CrownRegression",
      "In[15]:="
    ],
    hrfNbStdInput[
      "hrfEx04InspectPolynomialScan[Ex04CrownRegression, Automatic, Automatic, KinAssump4ptOnShell, KinVars4pt, CrownData[\"UF\"][\"U\"]]",
      "In[16]:="
    ],
    hrfNbStdText["HyperCrown boundary {x11}=0 (WideAngle4ptBoundary: PairSectors, kin-free sector check). Obstruction ~1–3 min; coverage LP on 11 vars adds ~1–2 min. Assign the report, then pull copy-paste-friendly ingredients from the Association (not from Dataset cells)."],
    hrfNbStdInput["hrfX11Report = hrfEx04HyperCrownX11Display[];", "In[17]:="],
    hrfNbStdText["Summary Dataset (display only). For generators, scaling vector, variable scaling use Ingredients below."],
    hrfNbStdInput["hrfX11Report[\"Summary\"]", "In[17a]:="],
    hrfNbStdText["Copy-paste friendly primary ingredients (same fields as summary row, as plain lists/associations):"],
    hrfNbStdInput[
      "KeyTake[hrfX11Report[\"Ingredients\"], {\"Generators\", \"ScalingVector\", \"VariableScaling\"}]",
      "In[17b]:="
    ],
    hrfNbStdText["Per-trial tables include Scaling vector and Variable scaling columns. Full structured log: hrfX11Report[\"Extract\"]."],
    hrfNbStdInput["hrfX11Report[\"AllValidTrialsScaling\"]", "In[17c]:="],
    hrfNbStdText["Per-trial audit (generators, sector form, decomposition, scaling). Re-scan without LP: Get[\"HRF_WideAngleBoundaryDiagnostic.wl\"]; hrfWideAngleBoundaryDiagnostic[\"HyperCrownX11\"]. With LP on valid trials only: add \"RunScalingQ\" -> True. Analyze existing scan: hrfWideAngleBoundaryDiagnosticFromScan[Ex04HyperCrownX11Target[\"PolynomialScan\"], ...]."],
    hrfNbStdInput["Get[FileNameJoin[{NotebookDirectory[], \"HRF_WideAngleBoundaryDiagnostic.wl\"}]]; hrfWideAngleBoundaryDiagnostic[\"HyperCrownX11\", \"RunScalingQ\" -> False][[1]]", "In[18]:="],
    hrfNbStdInput[
      "hrfEx04InspectPolynomialScan[Ex04HyperCrownX11Target, Automatic, Automatic, KinAssump4ptOnShell, KinVars4pt, Expand[HyperCrownData[\"UF\"][\"U\"] /. x11 -> 0]]",
      "In[18]:="
    ],
    hrfNbStdText["OPTIONAL — HyperCrown interior (polynomial; ~5-15 min with trim). After In[19], check hrfHyperCrownInteriorNarrative[] for an exhaustive no-HR certificate. Full trial log: $HRFEx04TrimScanStorageQ=False and $HRFFindObstructionsStoreAllTrialsQ=True."],
    hrfNbStdInput[
      "Ex04HyperCrownInterior = hrfEx04HyperCrownInterior[]",
      "In[19]:="
    ],
    hrfNbStdInput[
      "hrfEx04InspectPolynomialScan[Ex04HyperCrownInterior, Automatic, Automatic, KinAssump4ptOnShell, KinVars4pt, HyperCrownData[\"UF\"][\"U\"]]",
      "In[20]:="
    ],
    hrfNbStdInput["hrfHyperCrownInteriorNarrative[]", "In[21]:="],
    hrfNbStdInput[
      "If[hrfEx04CasePopulatedQ[Ex04HyperCrownX11Target], Ex04HyperCrownX11Target[\"GeneratorTrialTable\"][\"Polynomial\"], \"Run hrfEx04HyperCrownX11Display[] first.\"]",
      "In[22]:="
    ]
  },
  "Example 01: In[1] Crown only (~1–2 min). Optional HyperCrown at In[17]/In[19]. One kernel (Local).",
  "Local"
];

hrfNbStdExport[
  FileNameJoin[{$dir, "01a_DivingBeetle_WideAngle.nb"}],
  "Example 01a — Diving Beetle wide-angle diagnostic",
  {
    hrfNbStdSection["Setup"],
    hrfNbStdText["Minimal session: load Diving Beetle diagram + polynomial patch only (no Crown regression, no legacy boundary scan). Interior uses WideAngle4ptExhaustive; boundary {x8,x9}=0 uses WideAngle4ptBoundary. Full 794-stratum scan is deferred to a later notebook update."],
    hrfNbStdInput[
      "$HRFExample01Report = False;\n$HRFExample04Report = True;\n$HRFScalingReport = False;\n$HRFRunCrownInteriorScanOnLoad = False;\n$HRFRunHyperCrownBoundaryScansOnLoad = False;\n$HRFRunSuperCrownBoundaryScanOnLoad = False;\n$HRFRunDivingBeetleDiagnosticsOnLoad = False;\n$HRFRunDivingBeetleInteriorScanOnLoad = False;\n$HRFRunDBFullBoundaryScan = False;\n$HRFRunDeepBoundaryScan = False;\n$HRFEx04CompareBinomialQ = False;\n$HRFEx04TrimScanStorageQ = True;\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFCandidateGeneratorSetLimit = 64;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"01_WideAngle_2to2_OffShell.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialCancellationFactors.wl\"}]];\n$HRFPolynomialMaxMonomials = 12;\n$HRFPolynomialRequireKinematicDomainQ = False;\nhrfInstallPolynomialCancellationPatch[];\nGet[FileNameJoin[{NotebookDirectory[], \"04_PolynomialFactor_Regression.wl\"}]];\nPrint[\"=== Diving Beetle setup complete ===\"];\nPrint[\"Diagram vars: \", VarsDB];",
      "In[1]:="
    ],
    hrfNbStdSection["Diagram"],
    hrfNbStdInput["drawGraphFromPySecDecInput[DBInternalEdges, CrownExternalEdges]", "In[2]:="],
    hrfNbStdSection["Interior (polynomial obstruction)"],
    hrfNbStdText["PairSectors exhaustive interior search + coverage scaling on DB U. May take several minutes."],
    hrfNbStdInput["Ex04DivingBeetleInterior = hrfEx04DivingBeetleInterior[]", "In[3]:="],
    hrfNbStdInput["hrfDBInteriorReport = hrfEx04DivingBeetleInteriorDisplay[]", "In[4]:="],
    hrfNbStdInput["KeyTake[hrfDBInteriorReport[\"Ingredients\"], {\"Generators\", \"ScalingVector\", \"VariableScaling\", \"HiddenRegionQ\"}]", "In[4a]:="],
    hrfNbStdInput["hrfEx04InspectPolynomialScan[Ex04DivingBeetleInterior, Automatic, Automatic, KinAssump4ptOnShell, KinVars4pt, DBData[\"UF\"][\"U\"]]", "In[5]:="],
    hrfNbStdSection["Boundary {x8,x9}=0 (SuperCrown stratum on DB)"],
    hrfNbStdText["Same boundary as SuperCrown inheritance stratum. Lightweight case (no factor audit). Per-trial diagnostic optional at In[8]."],
    hrfNbStdInput["Ex04DivingBeetleX89Target = hrfEx04DivingBeetleX89Boundary[]", "In[6]:="],
    hrfNbStdInput["hrfDBX89Report = hrfEx04DivingBeetleX89Display[]", "In[7]:="],
    hrfNbStdInput["KeyTake[hrfDBX89Report[\"Ingredients\"], {\"Generators\", \"ScalingVector\", \"VariableScaling\", \"HiddenRegionQ\"}]", "In[7a]:="],
    hrfNbStdInput["Get[FileNameJoin[{NotebookDirectory[], \"HRF_WideAngleBoundaryDiagnostic.wl\"}]]; hrfWideAngleBoundaryDiagnosticFromScan[Ex04DivingBeetleX89Target[\"PolynomialScan\"], Ex04DivingBeetleX89Target[\"FRestricted\"], Ex04DivingBeetleX89Target[\"RemainingVars\"], KinVars4pt, Expand[DBData[\"UF\"][\"U\"] /. {x8 -> 0, x9 -> 0}], {x8, x9}][[1]]", "In[8]:="],
    hrfNbStdSection["Future work"],
    hrfNbStdText["Full Diving Beetle boundary scan (794 strata) is not in this notebook yet. When added, it will mirror HyperCrown In[10] in 01_WideAngle_4pt.nb with Ex04 polynomial cases per stratum or a filtered deep scan."]
  },
  "Diving Beetle: interior + {x8,x9} boundary only. Fresh Local kernel.",
  "Local"
];

hrfNbStdExport[
  FileNameJoin[{$dir, "02_ReggeLimit_4pt.nb"}],
  "Regge-limit 4-point examples",
  {
    hrfNbStdSection["Setup (core + Crown sanity)"],
    hrfNbStdText["In[1] loads core + Crown Regge sanity on T23 (~10–30 s). Memory: default deep trim keeps summary tables only; run In[3] and In[7] on fresh Second kernels (or use 02a/02b). After Ingredients cells (In[6b], In[10e]), run hrfEx02ReleaseScanMemory[] in In[25]. $HRFFindObstructionsStopOnFirstAdmissibleQ=False enumerates all admissible sets (more RAM); set True if memory is tight."],
    hrfNbStdInput[
      "$HRFExample02Report = True;\n$HRFScalingReport = False;\n$HRFRunEx02InteriorStudiesOnLoad = False;\n$HRFRunEx02LegacyCrownForwardOnLoad = False;\n$HRFRunEx02BoundariesOnLoad = False;\n$HRFRunEx02SuperCrownBoundary = False;\n$HRFRunEx02HyperCrownBoundaries = False;\n$HRFRunEx02CrownSanityOnLoad = True;\n$HRFEx02TrimScanStorageQ = True;\n$HRFEx02DeepTrimScanStorageQ = True;\n$HRFEx02CrownSanityChannels = {\"T23\"};\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFCandidateGeneratorSetLimit = 64;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialCancellationFactors.wl\"}]];\n$HRFPolynomialMaxMonomials = 12;\n$HRFPolynomialRequireKinematicDomainQ = False;\nhrfInstallPolynomialCancellationPatch[];\nGet[FileNameJoin[{NotebookDirectory[], \"02_Forward_Regge_2to2_Massless.wl\"}]];\nhrfEx02PostLoadCheck[]",
      "In[1]:="
    ],
    hrfNbStdSection["Crown Regge sanity check"],
    hrfNbStdText["Regge Crown interior on T23 (PairSectors MaxGenerators=1 + polynomial). Validates Ex02 setup before SuperCrown/HyperCrown. Generators and scaling vector per channel row."],
    hrfNbStdInput["hrfEx02CrownSanityDisplay[]", "In[2]:="],
    hrfNbStdText["Copy-paste friendly Crown T23 ingredients (after In[1]):"],
    hrfNbStdInput[
      "hrfCrownT23Report = hrfEx02CrownSanityChannelDisplay[\"T23\"];\nKeyTake[hrfCrownT23Report[\"Ingredients\"], {\"Generators\", \"ScalingVector\", \"VariableScaling\"}]",
      "In[2a]:="
    ],
    hrfNbStdInput["hrfCrownT23Report[\"AllValidTrialsScaling\"]", "In[2b]:="],
    hrfNbStdSection["Boundary: SuperCrown {x8,x9}"],
    hrfNbStdText["Run In[1] first. In[3] runs SuperCrown {x8,x9}: wide + 3 Regge channels (~10 s–2 min each on Crown-like topologies; prints channel done lines). In[4]–In[6] are instant tables after In[3]."],
    hrfNbStdInput["hrfEx02RunSuperCrownBoundary[]", "In[3]:="],
    hrfNbStdInput["Ex02SuperCrownReggeChannelSummary", "In[4]:="],
    hrfNbStdInput["Ex02SuperCrownBoundaryDetailTable", "In[5]:="],
    hrfNbStdInput["Ex02SuperCrownBoundaryHRTable", "In[6]:="],
    hrfNbStdText["Per-channel Extract/Ingredients for SuperCrown {x8,x9} (after In[3]). Wide uses MaxGenerators=2; T23/T12/T13 use MaxGenerators=1."],
    hrfNbStdInput[
      "hrfSCWideReport = hrfEx02ReggeChannelDisplay[\"SuperCrown\", \"Boundary {x8,x9}\", \"Wide\"];\nhrfSCWideReport[\"Ingredients\"][\"ScalingVector\"]",
      "In[6a]:="
    ],
    hrfNbStdInput["hrfEx02ReggeChannelDisplay[\"SuperCrown\", \"Boundary {x8,x9}\", \"T23\"][\"AllValidTrialsScaling\"]", "In[6b]:="],
    hrfNbStdSection["Boundary: HyperCrown {x11}=0"],
    hrfNbStdText["Fresh kernel recommended if memory is tight. In[7] runs HyperCrown {x11}=0: wide PairSectors scan (WideAngle4ptBoundary; often 10–30+ min; trial progress every 5 trials). Then 3 Regge channels (~2–5 min each). In[8]–In[10] are tables after In[7] completes."],
    hrfNbStdInput["hrfEx02RunHyperCrownBoundary[]", "In[7]:="],
    hrfNbStdInput["hrfEx02BoundaryComparisonDisplay[\"HyperCrown\"]", "In[8]:="],
    hrfNbStdInput["Ex02HyperCrownBoundaryDetailTable", "In[9]:="],
    hrfNbStdInput["Ex02HyperCrownBoundaryHRTable", "In[10]:="],
    hrfNbStdText["Named report associations for HyperCrown {x11}=0 (after In[7]). Assign report, then pull Ingredients — same pattern as Ex01 hrfX11Report."],
    hrfNbStdInput["hrfHCWideReport = hrfEx02HyperCrownBoundaryDisplay[\"Wide\"];", "In[10a]:="],
    hrfNbStdInput["hrfHCWideReport[\"Summary\"]", "In[10b]:="],
    hrfNbStdInput[
      "KeyTake[hrfHCWideReport[\"Ingredients\"], {\"Generators\", \"ScalingVector\", \"VariableScaling\"}]",
      "In[10c]:="
    ],
    hrfNbStdInput["hrfHCWideReport[\"AllValidTrialsScaling\"]", "In[10d]:="],
    hrfNbStdInput["hrfEx02ReggeChannelDisplay[\"HyperCrown\", \"Boundary {x11}\", \"T23\"][\"Ingredients\"][\"ScalingVector\"]", "In[10e]:="],
    hrfNbStdSection["Regge channel conventions"],
    hrfNbStdInput["hrfEx02ChannelLegend[]", "In[11]:="],
    hrfNbStdSection["Diagrams"],
    hrfNbStdText["Each cell returns a Graph (large). If you see nothing, setup did not finish — re-run In[1]."],
    hrfNbStdInput["hrfEx02ShowDiagram[CrownInternalEdges, CrownExternalEdges]", "In[12]:="],
    hrfNbStdInput["hrfEx02ShowDiagram[SuperCrownInternalEdges, CrownExternalEdges]", "In[13]:="],
    hrfNbStdInput["hrfEx02ShowDiagram[HyperCrownInternalEdges, CrownExternalEdges]", "In[14]:="],
    hrfNbStdInput["hrfEx02ShowDiagram[DBInternalEdges, DBExternalEdges]", "In[15]:="],
    hrfNbStdSection["Optional: full interior batch (slow)"],
    hrfNbStdText["Skip unless you need all four interior diagrams x (wide + T23/T12/T13). Can take 1-2+ hours and needs substantial RAM."],
    hrfNbStdInput["hrfEx02BuildInteriorStudies[]", "In[16]:="],
    hrfNbStdSection["Interior comparison tables"],
    hrfNbStdText["Empty until optional In[16] is evaluated."],
    hrfNbStdInput["hrfEx02InteriorComparisonDisplay[\"Crown\"]", "In[17]:="],
    hrfNbStdInput["hrfEx02InteriorComparisonDisplay[\"SuperCrown\"]", "In[18]:="],
    hrfNbStdInput["hrfEx02InteriorComparisonDisplay[\"HyperCrown\"]", "In[19]:="],
    hrfNbStdInput["hrfEx02InteriorComparisonDisplay[\"Diving Beetle\"]", "In[20]:="],
    hrfNbStdSection["Optional: full boundary inspect"],
    hrfNbStdText["Narrative + all tables in one call (after In[3] and/or In[7])."],
    hrfNbStdInput["hrfEx02SuperCrownBoundaryInspect[]", "In[21]:="],
    hrfNbStdInput["hrfEx02DiagramBoundaryInspect[\"HyperCrown\"]", "In[22]:="],
    hrfNbStdSection["Difference flags and narrative"],
    hrfNbStdInput["hrfEx02DisplayComparisonTable[Ex02ReggeOnlyFlags]", "In[23]:="],
    hrfNbStdInput["Ex02ComparisonNarrative", "In[24]:="],
    hrfNbStdSection["Memory (optional)"],
    hrfNbStdText["After SuperCrown/HyperCrown Ingredients cells, release bulky ChannelScans from RAM. Summary tables stay valid; re-run In[3]/In[7] before calling channel display again."],
    hrfNbStdInput["hrfEx02MemoryFootprint[]", "In[24a]:="],
    hrfNbStdInput["hrfEx02ReleaseScanMemory[]", "In[24b]:="],
    hrfNbStdSection["Sanity check (smoke tests)"],
    hrfNbStdText["Smoke tests reload Example 02 with Crown interior only (boundaries off). Expect 7/7 passed on a healthy install (Lookup-safe scaling checks)."],
    hrfNbStdInput[
      "Get[FileNameJoin[{NotebookDirectory[], \"HRF_NotebookSmokeTests.wl\"}]];\nhrfRunNotebookSmokeTests[][\"Summary\"]",
      "In[25]:="
    ]
  },
  "Ex02: In[1] Regge Crown T23 sanity; boundaries In[3]/In[7] separately on Second kernel.",
  "Second"
];

hrfNbStdExport[
  FileNameJoin[{$dir, "02a_SuperCrown_Regge.nb"}],
  "Example 02 — SuperCrown boundary only",
  {
    hrfNbStdSection["Setup"],
    hrfNbStdText["Minimal memory session: core load + T23 Regge sanity + SuperCrown boundary {x8,x9} only."],
    hrfNbStdInput[
      "$HRFExample02Report = True;\n$HRFScalingReport = False;\n$HRFRunEx02BoundariesOnLoad = False;\n$HRFRunEx02CrownSanityOnLoad = True;\n$HRFEx02TrimScanStorageQ = True;\n$HRFEx02CrownSanityChannels = {\"T23\"};\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFCandidateGeneratorSetLimit = 64;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialCancellationFactors.wl\"}]];\n$HRFPolynomialMaxMonomials = 12;\n$HRFPolynomialRequireKinematicDomainQ = False;\nhrfInstallPolynomialCancellationPatch[];\nGet[FileNameJoin[{NotebookDirectory[], \"02_Forward_Regge_2to2_Massless.wl\"}]];\nhrfEx02PostLoadCheck[]",
      "In[1]:="
    ],
    hrfNbStdSection["SuperCrown boundary {x8,x9}"],
    hrfNbStdInput["hrfEx02RunSuperCrownBoundary[]", "In[2]:="],
    hrfNbStdInput["Ex02SuperCrownReggeChannelSummary", "In[3]:="],
    hrfNbStdInput["Ex02SuperCrownBoundaryDetailTable", "In[4]:="],
    hrfNbStdInput["Ex02SuperCrownBoundaryHRTable", "In[5]:="]
  },
  "Single-diagram Regge boundary study. Fresh kernel.",
  "Second"
];

hrfNbStdExport[
  FileNameJoin[{$dir, "02b_HyperCrown_Regge.nb"}],
  "Example 02 — HyperCrown {x11}=0 only",
  {
    hrfNbStdSection["Setup"],
    hrfNbStdText["Minimal memory session: core load + T23 Regge sanity + HyperCrown boundary {x11}=0 (wide PairSectors matches Ex01 Ex04, plus three Regge channels)."],
    hrfNbStdInput[
      "$HRFExample02Report = True;\n$HRFScalingReport = False;\n$HRFRunEx02BoundariesOnLoad = False;\n$HRFRunEx02CrownSanityOnLoad = True;\n$HRFEx02TrimScanStorageQ = True;\n$HRFEx02CrownSanityChannels = {\"T23\"};\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFCandidateGeneratorSetLimit = 64;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialCancellationFactors.wl\"}]];\n$HRFPolynomialMaxMonomials = 12;\n$HRFPolynomialRequireKinematicDomainQ = False;\nhrfInstallPolynomialCancellationPatch[];\nGet[FileNameJoin[{NotebookDirectory[], \"02_Forward_Regge_2to2_Massless.wl\"}]];\nhrfEx02PostLoadCheck[]",
      "In[1]:="
    ],
    hrfNbStdSection["HyperCrown boundary {x11}=0"],
    hrfNbStdInput["hrfEx02RunHyperCrownBoundary[]", "In[2]:="],
    hrfNbStdInput["Ex02HyperCrownBoundaryDetailTable", "In[3]:="],
    hrfNbStdInput["Ex02HyperCrownBoundaryHRTable", "In[4]:="],
    hrfNbStdInput["hrfHCWideReport = hrfEx02HyperCrownBoundaryDisplay[\"Wide\"]; hrfHCWideReport[\"Ingredients\"][\"ScalingVector\"]", "In[5]:="]
  },
  "Single-diagram Regge boundary study. Fresh kernel.",
  "Second"
];

hrfNbStdExport[
  FileNameJoin[{$dir, "03_SpacelikeCollinear_5pt.nb"}],
  "Spacelike collinear 5-point examples",
  {
    hrfNbStdText["Run the seed diagram diagnostic (In[1]-In[5]) first. The full 7/8-propagator topology scan is disabled until the seed case finds a hidden region with a single generator."],
    hrfNbStdSection["Seed diagram diagnostic (run first)"],
    hrfNbStdText["Fast seed-only workflow (matches working binomial Ex03): polynomial f_k kin-normalized and Mandelstam-linear, SingleProduct generator g = product of all simultaneously admissible f_k. In[4] should show SafeSingleProductSetCount >= 1 before In[5]."],
    hrfNbStdInput[
      "$HRFEx03RunFullTopologyScanQ = False;\n$HRFEx03UsePolynomialFactorsQ = True;\n$HRFEx03ObstructionProgressQ = True;\n$HRFExampleVerbose = False;\n$HRFVerboseScaling = False;\n$HRFScalingReport = False;\n$HRFQuietReports = False;\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFCandidateGeneratorSetLimit = 64;\n$HRFPolynomialMaxMonomials = 12;\n$HRFPolynomialRequireKinematicDomainQ = False;\n$HRFUseGeneratorPhysicsFilterQ = True;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_Example03CollinearCore.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialCancellationFactors.wl\"}]];\nhrfInstallPolynomialCancellationPatch[];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_Example03SeedStudy.wl\"}]];\nhrfEx03SeedStudyLoad[];",
      "In[1]:="
    ],
    hrfNbStdInput["drawGraphFromPySecDecInput[seedInternalLines, seedExternalLines]", "In[2]:="],
    hrfNbStdInput["hrfEx03SeedFactorTable[]", "In[3]:="],
    hrfNbStdInput["hrfEx03SeedGeneratorAudit[]", "In[4]:="],
    hrfNbStdText["Route comparison: canonical f_k (one row per class), all eligible pair products with rejection reasons, obstruction trial stages. Seed5pt only — ThreeLoopVertex is at In[5c] and In[14]."],
    hrfNbStdInput[
      "Ex03RouteComparison = hrfEx03SeedRouteComparison[];\nEx03RouteComparison[\"Summary\"]",
      "In[4a]:="
    ],
    hrfNbStdInput["Ex03RouteComparison[\"CanonicalFactorTable\"]", "In[4b]:="],
    hrfNbStdInput["Ex03RouteComparison[\"GeneratorPairAuditTable\"]", "In[4c]:="],
    hrfNbStdInput["Ex03RouteComparison[\"GeneratorSelectionTable\"]", "In[4d]:="],
    hrfNbStdText["Optional: every raw harvest variant."],
    hrfNbStdInput["Ex03RouteComparison[\"FactorTableVerbose\"]", "In[4e]:="],
    hrfNbStdInput[
      "Ex03SeedObstruction = hrfEx03RunSeedObstruction[];\nKeyTake[Ex03SeedObstruction, {\"HiddenRegionQ\", \"Generators\", \"AttemptSummary\"}]",
      "In[5]:="
    ],
    hrfNbStdInput["Ex03SeedObstruction[\"GeneratorPairAuditTable\"]", "In[5a]:="],
    hrfNbStdInput["Ex03SeedObstruction[\"ObstructionTrialTable\"]", "In[5b]:="],
    hrfNbStdSection["Seed5pt vs ThreeLoopVertex (generator audit)"],
    hrfNbStdText["Both topologies: canonical f_k table (Topology column), pair audit, binomial vs polynomial resolver. Vertex obstruction skipped by default."],
    hrfNbStdInput[
      "Ex03FivePointRoutes = hrfEx03SeedFivePointRouteStudy[];\nEx03FivePointRoutes[\"GeneratorSelectionTable\"];\nEx03FivePointRoutes[\"CanonicalFactorTable\"];\nEx03FivePointRoutes[\"GeneratorPairAuditTable\"]",
      "In[5c]:="
    ],
    hrfNbStdInput[
      "Ex03FivePointRoutes[\"ThreeLoopVertex\"][\"NonBinomialGeneratorSelectedQ\"];\nEx03FivePointRoutes[\"HiddenRegionQ\"]",
      "In[5d]:="
    ],
    hrfNbStdSection["Full 7/8-propagator scan (disabled until seed OK)"],
    hrfNbStdText["Optional and slow (~1-3 h). Only run after In[5] reports HiddenRegionQ=True with a single generator. This reloads the full Example 03 driver with $HRFEx03RunFullTopologyScanQ=True."],
    hrfNbStdInput[
      "$HRFEx03RunFullTopologyScanQ = True;\n$HRFEx03UsePolynomialFactorsQ = True;\n$HRFEx03ObstructionProgressQ = True;\n$HRFEx03SevenPropBoundaryZeroVars = {x6};\n$HRFEx03RunEightPropBoundaryScanQ = False;\n$HRFExampleVerbose = False;\n$HRFVerboseScaling = False;\n$HRFScalingReport = False;\n$HRFQuietReports = False;\n$HRFFindObstructionsStopOnFirstAdmissibleQ = True;\n$HRFCandidateGeneratorSetLimit = 64;\n$HRFPolynomialMaxMonomials = 12;\n$HRFPolynomialRequireKinematicDomainQ = False;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"03_FivePoint_Spacelike_Collinear.wl\"}]];",
      "In[6]:="
    ],
    hrfNbStdText["Requires In[6] (full load). These tables are independent of the polynomial obstruction cells below."],
    hrfNbStdInput["TopologyHiddenRegionTable2Loop7Prop", "In[7]:="],
    hrfNbStdInput["TopologyRegionScalingTable2Loop7Prop", "In[8]:="],
    hrfNbStdInput["TopologyScalingCoverageTable2Loop7Prop", "In[9]:="],
    hrfNbStdSection["Eight-propagator summary tables (optional)"],
    hrfNbStdInput["TopologyHiddenRegionTable2Loop8Prop", "In[10]:="],
    hrfNbStdInput["TopologyRegionScalingTable2Loop8Prop", "In[11]:="],
    hrfNbStdInput["TopologyScalingCoverageTable2Loop8Prop", "In[12]:="],
    hrfNbStdSection["Export tables (optional)"],
    hrfNbStdInput[
      "Export[FileNameJoin[{NotebookDirectory[], \"TopologyHiddenRegionRows2Loop7Prop.csv\"}], Normal[TopologyHiddenRegionTable2Loop7Prop]];\nExport[FileNameJoin[{NotebookDirectory[], \"TopologyHiddenRegionRows2Loop8Prop.csv\"}], Normal[TopologyHiddenRegionTable2Loop8Prop]];",
      "In[13]:="
    ],
    hrfNbStdSection["Five-point polynomial study (Seed5pt vs ThreeLoopVertex, duplicate of In[5c])"],
    hrfNbStdText["Same as In[5c] if already evaluated. Vertex obstruction scan skipped by default; set SkipVertexObstructionScans -> False for full vertex HiddenRegionQ (slow)."],
    hrfNbStdInput[
      "Ex03FivePointRoutes = hrfEx03SeedFivePointRouteStudy[];\nEx03FivePointRoutes[\"CanonicalFactorTable\"]",
      "In[14a]:="
    ],
    hrfNbStdInput[
      "Ex03FivePointRoutes[\"GeneratorPairAuditTable\"];\nEx03FivePointRoutes[\"GeneratorSelectionTable\"];\nEx03FivePointRoutes[\"HiddenRegionQ\"]",
      "In[14b]:="
    ],
    hrfNbStdText["Requires In[14] load of 04_PolynomialFactor_Regression.wl for full obstruction runs below."],
    hrfNbStdInput[
      "$HRFQuietReports = True;\n$HRFExample04Report = True;\n$HRFEx04RunObstructionSearchQ = True;\n$HRFRunEx04RegressionOnLoad = False;\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFCandidateGeneratorSetLimit = 64;\n$HRFMaxProductSubsetSize = 2;\n$HRFEx04TrimScanStorageQ = True;\n$HRFObstructionFindInstanceTimeLimit = 20;\n$HRFPolynomialRequireKinematicDomainQ = False;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_Example03CollinearCore.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_PolynomialCancellationFactors.wl\"}]];\n$HRFPolynomialMaxMonomials = 12;\nhrfInstallPolynomialCancellationPatch[];\nGet[FileNameJoin[{NotebookDirectory[], \"04_PolynomialFactor_Regression.wl\"}]];",
      "In[14]:="
    ],
    hrfNbStdText["Factor audit: compare available f_k pools before running obstruction (fast). ThreeLoopVertex typically has many more cancellation factors than Seed5pt."],
    hrfNbStdInput["hrfEx04FivePointFactorDiffTable[]", "In[15]:="],
    hrfNbStdText["Seed5pt interior (~few min). Inspect output includes Successful obstruction decomposition?, Mandelstam sectors in F_SL, and HiddenRegionQ with leading U scaling."],
    hrfNbStdInput[
      "Ex04Seed5ptInterior = hrfEx04Seed5ptInterior[];\nhrfEx04InspectFivePointCase[Ex04Seed5ptInterior, \"Seed5pt\"]",
      "In[16]:="
    ],
    hrfNbStdText["Named report with Extract/Ingredients (copy-paste friendly scaling vector):"],
    hrfNbStdInput[
      "hrfSeed5ptReport = hrfEx04FivePointCaseDisplay[Ex04Seed5ptInterior, \"Seed5pt\"];\nKeyTake[hrfSeed5ptReport[\"Ingredients\"], {\"Generators\", \"ScalingVector\", \"VariableScaling\"}]",
      "In[16a]:="
    ],
    hrfNbStdInput["hrfSeed5ptReport[\"AllValidTrialsScaling\"]", "In[16b]:="],
    hrfNbStdInput["Ex04Seed5ptInterior[\"GeneratorTrialTable\"][\"Polynomial\"]", "In[17]:="],
    hrfNbStdText["ThreeLoopVertex: preview coupled f_k products without full obstruction (fast). Full scan below is slow (~15-30 min candidate build, then obstruction trials)."],
    hrfNbStdInput[
      "Get[FileNameJoin[{NotebookDirectory[], \"hrfInspectThreeLoopVertexGenerators.wl\"}]];\nhrfThreeLoopVertexCandidateTable[]",
      "In[18]:="
    ],
    hrfNbStdText["ThreeLoopVertex FULL collinear obstruction (Collinear5pt / SingleProduct, ~1-5 min). Same rules as pair audit; stores trial log + HiddenRegionQ."],
    hrfNbStdInput[
      "Ex03VertexObstruction = hrfEx03RunVertexObstruction[];\nKeyTake[Ex03VertexObstruction, {\"HiddenRegionQ\", \"GeneratorPairAuditSummary\", \"AttemptSummary\"}];\nEx03VertexObstruction[\"ObstructionTrialTable\"]",
      "In[18b]:="
    ],
    hrfNbStdInput[
      "Ex03VertexObstruction = hrfThreeLoopVertexObstructionScan[];\nKeyTake[Ex03VertexObstruction, {\"HiddenRegionQ\", \"AdmissibleGeneratorSetQ\", \"CandidateGeneratorCount\", \"Generators\"}]",
      "In[18c]:="
    ],
    hrfNbStdText["ThreeLoopVertex interior obstruction via Ex04 harness (slow). Requires In[14]. After fix: UseExtendedFactors=False for Collinear5pt."],
    hrfNbStdInput[
      "Ex04ThreeLoopVertexInterior = hrfEx04ThreeLoopVertexInterior[];\nhrfEx04InspectFivePointCase[Ex04ThreeLoopVertexInterior, \"ThreeLoopVertex\"]",
      "In[19]:="
    ],
    hrfNbStdText["ThreeLoopVertex report (physics filter on kinematic-dependent f_k):"],
    hrfNbStdInput[
      "hrfVertexReport = hrfEx04FivePointCaseDisplay[Ex04ThreeLoopVertexInterior, \"ThreeLoopVertex\"];\nhrfVertexReport[\"Ingredients\"][\"ScalingVector\"]",
      "In[19a]:="
    ],
    hrfNbStdInput["hrfVertexReport[\"AllValidTrialsScaling\"]", "In[19b]:="],
    hrfNbStdInput[
      "Ex04ThreeLoopVertexInterior[\"GeneratorTrialTable\"][\"Polynomial\"];\nhrfThreeLoopVertexGeneratorRows[Ex04ThreeLoopVertexInterior[\"PolynomialScan\"]]",
      "In[20]:="
    ],
    hrfNbStdText["Side-by-side summary: generator counts, valid multi-generator trials, decomposition status, hidden-region verdict, and scaling status/vector."],
    hrfNbStdInput[
      "Ex04FivePointComparison = hrfEx04FivePointComparisonDisplay[{Ex04Seed5ptInterior, Ex04ThreeLoopVertexInterior}];\nEx04FivePointComparison",
      "In[21]:="
    ],
    hrfNbStdSection["Sanity check (smoke tests)"],
    hrfNbStdText["Fast regression on Seed5pt (+ optional slow HyperCrown x11=0). Set $HRFSmokeRunSlowQ=True before evaluating for the boundary check. ThreeLoopVertex full scan: $HRFSmokeRunVerySlowQ=True (~30+ min)."],
    hrfNbStdInput[
      "Get[FileNameJoin[{NotebookDirectory[], \"HRF_NotebookSmokeTests.wl\"}]];\nhrfRunNotebookSmokeTests[][\"Summary\"]",
      "In[22]:="
    ]
  },
  "Seed diagnostic at In[1]-In[5]. Full 7/8-propagator scan at In[6] (optional). Polynomial study at In[14].",
  "Local"
];

Print["Standard BoxData notebooks rebuilt in ", $dir];
Print["WARNING: exported .nb files are empty templates (no cell outputs). ",
  "Close Mathematica copies before rebuilding, or Save As a dated copy first. ",
  "Parent HRF/ sync is OFF by default; set $HRFRebuildSyncParentNotebooksQ = True to copy upward."];

(* Optional: keep parent HRF/ copies in sync (off by default — overwrites open notebooks there). *)
If[! ValueQ[$HRFRebuildSyncParentNotebooksQ], $HRFRebuildSyncParentNotebooksQ = False];
If[TrueQ[$HRFRebuildSyncParentNotebooksQ] && MatchQ[Last @ FileNameSplit[$dir], "HiddenRegionFinder_polynomial_factors"],
  Scan[
    Function[{name},
      Module[{src, dst},
        src = FileNameJoin[{$dir, name}];
        dst = FileNameJoin[{DirectoryName[$dir], name}];
        If[FileExistsQ[src],
          If[FileExistsQ[dst], DeleteFile[dst]];
          CopyFile[src, dst];
          Print["synced ", dst];
        ]
      ]
    ],
    {"01_WideAngle_4pt.nb", "01a_DivingBeetle_WideAngle.nb", "02_ReggeLimit_4pt.nb", "02a_SuperCrown_Regge.nb", "02b_HyperCrown_Regge.nb", "03_SpacelikeCollinear_5pt.nb", "04_PolynomialFactor_Regression.nb"}
  ];
];
