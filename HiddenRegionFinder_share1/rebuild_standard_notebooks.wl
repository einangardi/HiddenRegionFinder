(* rebuild_standard_notebooks.wl
   Regenerate collaboration notebooks with BoxData Input cells for standard
   syntax colouring. Run once from the share directory:
     Get["rebuild_standard_notebooks.wl"];
*)

ClearAll[hrfNbStdInput, hrfNbStdText, hrfNbStdSection, hrfNbStdTitle, hrfNbStdExport];

hrfNbStdInput[code_String, label_String:"In[1]:="] := Module[{boxes, flat},
  flat = StringReplace[StringTrim[code], RegularExpression["\n"] -> " "];
  boxes = ToExpression[flat, InputForm, MakeBoxes];
  If[StringQ[boxes] && boxes === flat,
    boxes = ToExpression[flat <> ";", InputForm, MakeBoxes]
  ];
  Cell[BoxData[boxes], "Input", CellLabel -> label]
];

hrfNbStdText[text_String] := Cell[text, "Text"];
hrfNbStdSection[text_String] := Cell[text, "Section"];
hrfNbStdTitle[text_String] := Cell[text, "Title"];

hrfNbStdExport[path_String, title_String, cells_List] := Module[{nb},
  nb = Notebook[
    {
      Cell[CellGroupData[{
        hrfNbStdTitle[title],
        hrfNbStdText["Evaluate cells in order from the top. Use a fresh kernel for the setup cell."],
        Sequence @@ cells
      }, Open]]
    },
    WindowSize -> {1200, 900},
    ShowCellTags -> False,
    CellLabelAutoDelete -> True,
    StyleDefinitions -> "Default.nb",
    WindowTitle -> title
  ];
  Export[path, nb, "Notebook"];
  Print["exported ", path];
];

$dir = Directory[];

hrfNbStdExport[
  FileNameJoin[{$dir, "01_WideAngle_4pt.nb"}],
  "Wide-angle 4-point examples",
  {
    hrfNbStdSection["Setup"],
    hrfNbStdInput[
      "$HRFExample01Report = False;\n$HRFScalingReport = False;\n$HRFRunHyperCrownBoundaryScansOnLoad = True;\n$HRFRunSuperCrownBoundaryScanOnLoad = True;\n$HRFRunDivingBeetleDiagnosticsOnLoad = True;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"01_WideAngle_2to2_OffShell.wl\"}]];",
      "In[1]:="
    ],
    hrfNbStdSection["Diagrams"],
    hrfNbStdInput["drawGraphFromPySecDecInput[CrownInternalEdges, CrownExternalEdges]", "In[2]:="],
    hrfNbStdInput["drawGraphFromPySecDecInput[SuperCrownInternalEdges, CrownExternalEdges]", "In[3]:="],
    hrfNbStdInput["drawGraphFromPySecDecInput[HyperCrownInternalEdges, CrownExternalEdges]", "In[4]:="],
    hrfNbStdInput["drawGraphFromPySecDecInput[DBInternalEdges, CrownExternalEdges]", "In[5]:="],
    hrfNbStdSection["Interior region-study tables"],
    hrfNbStdInput["hrfHyperCrownRegionStudyTable[]", "In[6]:="],
    hrfNbStdInput["hrfDivingBeetleRegionStudyTable[]", "In[7]:="],
    hrfNbStdSection["Boundary outcome tables"],
    hrfNbStdInput["hrfEx01BoundaryOutcomeTable[HyperCrownBoundaryCandidateScans]", "In[8]:="],
    hrfNbStdInput["If[ValueQ[DBBoundaryOutcomeTable], DBBoundaryOutcomeTable, \"Diving Beetle boundary scan not run\"]", "In[9]:="],
    hrfNbStdInput["hrfDivingBeetleFailureNarrative[]", "In[10]:="],
    hrfNbStdSection["Channel obstruction attempts (HyperCrown)"],
    hrfNbStdInput["hrfHyperCrownChannelAttemptTable[]", "In[11]:="]
  }
];

hrfNbStdExport[
  FileNameJoin[{$dir, "02_ReggeLimit_4pt.nb"}],
  "Regge-limit 4-point examples",
  {
    hrfNbStdSection["Setup"],
    hrfNbStdInput[
      "$HRFExample02Report = False;\n$HRFScalingReport = False;\n$HRFRunEx02SuperCrownBoundary = True;\n$HRFRunEx02HyperCrownBoundaries = True;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"02_Forward_Regge_2to2_Massless.wl\"}]];",
      "In[1]:="
    ],
    hrfNbStdSection["Regge channel conventions"],
    hrfNbStdInput["hrfEx02ChannelLegend[]", "In[2]:="],
    hrfNbStdSection["Diagrams"],
    hrfNbStdInput["hrfEx02DrawDiagram[CrownInternalEdges, CrownExternalEdges]", "In[3]:="],
    hrfNbStdInput["hrfEx02DrawDiagram[SuperCrownInternalEdges, CrownExternalEdges]", "In[4]:="],
    hrfNbStdInput["hrfEx02DrawDiagram[HyperCrownInternalEdges, CrownExternalEdges]", "In[5]:="],
    hrfNbStdInput["hrfEx02DrawDiagram[DBInternalEdges, DBExternalEdges]", "In[6]:="],
    hrfNbStdSection["Interior comparison tables"],
    hrfNbStdInput["hrfEx02InteriorComparisonDisplay[\"Crown\"]", "In[7]:="],
    hrfNbStdInput["hrfEx02InteriorComparisonDisplay[\"SuperCrown\"]", "In[8]:="],
    hrfNbStdInput["hrfEx02InteriorComparisonDisplay[\"HyperCrown\"]", "In[9]:="],
    hrfNbStdInput["hrfEx02InteriorComparisonDisplay[\"Diving Beetle\"]", "In[10]:="],
    hrfNbStdSection["Boundary comparison tables"],
    hrfNbStdInput["hrfEx02BoundaryComparisonDisplay[\"SuperCrown\"]", "In[11]:="],
    hrfNbStdInput["hrfEx02BoundaryComparisonDisplay[\"HyperCrown\"]", "In[12]:="],
    hrfNbStdSection["Difference flags and narrative"],
    hrfNbStdInput["hrfEx02DisplayComparisonTable[Ex02ReggeOnlyFlags]", "In[13]:="],
    hrfNbStdInput["Ex02ComparisonNarrative", "In[14]:="]
  }
];

hrfNbStdExport[
  FileNameJoin[{$dir, "03_SpacelikeCollinear_5pt.nb"}],
  "Spacelike collinear 5-point examples",
  {
    hrfNbStdSection["Setup"],
    hrfNbStdInput[
      "$HRFExampleVerbose = False;\n$HRFVerboseScaling = False;\n$HRFScalingReport = False;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"03_FivePoint_Spacelike_Collinear.wl\"}]];",
      "In[1]:="
    ],
    hrfNbStdSection["Seed and ThreeLoopVertex topology"],
    hrfNbStdInput["drawGraphFromPySecDecInput[seedInternalLines, seedExternalLines]", "In[2]:="],
    hrfNbStdInput["drawGraphFromPySecDecInput[ThreeLoopVertexInternalLines, seedExternalLines]", "In[3]:="],
    hrfNbStdSection["Seven-propagator summary tables"],
    hrfNbStdInput["TopologyHiddenRegionTable2Loop7Prop", "In[4]:="],
    hrfNbStdInput["TopologyRegionScalingTable2Loop7Prop", "In[5]:="],
    hrfNbStdInput["TopologyScalingCoverageTable2Loop7Prop", "In[6]:="],
    hrfNbStdSection["Eight-propagator summary tables"],
    hrfNbStdInput["TopologyHiddenRegionTable2Loop8Prop", "In[7]:="],
    hrfNbStdInput["TopologyRegionScalingTable2Loop8Prop", "In[8]:="],
    hrfNbStdInput["TopologyScalingCoverageTable2Loop8Prop", "In[9]:="],
    hrfNbStdSection["Export tables (optional)"],
    hrfNbStdInput[
      "Export[FileNameJoin[{NotebookDirectory[], \"TopologyHiddenRegionRows2Loop7Prop.csv\"}], Normal[TopologyHiddenRegionTable2Loop7Prop]];\nExport[FileNameJoin[{NotebookDirectory[], \"TopologyHiddenRegionRows2Loop8Prop.csv\"}], Normal[TopologyHiddenRegionTable2Loop8Prop]];",
      "In[10]:="
    ]
  }
];

Print["Standard BoxData notebooks rebuilt in ", $dir];
