(* rebuild_recursive_derivative_preselection_notebook.wl
   Regenerate the inspection notebook for the recursive boundary-aware
   derivative preselection scan over planarDiagram.txt and nonplanarDiagram.txt.

   Run from this directory:
     Get["rebuild_recursive_derivative_preselection_notebook.wl"];
*)

ClearAll[hrfNbRDInput, hrfNbRDText, hrfNbRDSection, hrfNbRDTitle, hrfNbRDExport];

hrfNbRDInput[code_String, label_String : "In[1]:="] := Module[{boxes, flat},
  flat = StringReplace[StringTrim[code], RegularExpression["\n"] -> " "];
  boxes = ToExpression[flat, InputForm, MakeBoxes];
  If[StringQ[boxes] && boxes === flat,
    boxes = ToExpression[flat <> ";", InputForm, MakeBoxes]
  ];
  Cell[BoxData[boxes], "Input", CellLabel -> label]
];

hrfNbRDText[text_String] := Cell[text, "Text"];
hrfNbRDSection[text_String] := Cell[text, "Section"];
hrfNbRDTitle[text_String] := Cell[text, "Title"];

hrfNbRDExport[path_String, title_String, cells_List] := Module[{nb},
  nb = Notebook[
    {
      Cell[CellGroupData[{
        hrfNbRDTitle[title],
        hrfNbRDText["Evaluate cells in order from the top. This notebook applies the recursive derivative preselection: one-sign derivative variables are set to zero and the sign test is repeated on the restricted F0."],
        Sequence @@ cells
      }, Open]]
    },
    WindowSize -> {1300, 900},
    ShowCellTags -> False,
    CellLabelAutoDelete -> True,
    StyleDefinitions -> "Default.nb",
    WindowTitle -> title
  ];
  Export[path, nb, "Notebook"];
  Print["exported ", path];
];

$dir = Directory[];

hrfNbRDExport[
  FileNameJoin[{$dir, "07_RecursiveDerivativePreselection.nb"}],
  "Recursive derivative preselection",
  {
    hrfNbRDSection["Setup"],
    hrfNbRDText["This scan is boundary-aware as a preselection only. Candidate rows include PreselectionZeroVars as a diagnostic record of why the recursive sign test kept the graph; the HRF handoff reports the original listed graph, not the contracted boundary graph."],
    hrfNbRDInput[
      "$HRFQuietReports = True;\nGet[FileNameJoin[{NotebookDirectory[], \"HRF_RecursiveDerivativePreselection.wl\"}]];",
      "In[1]:="
    ],

    hrfNbRDSection["Run Scan"],
    hrfNbRDInput[
      "RDScan = hrfRunRecursiveDerivativePreselection[];\nRDScan[\"Summary\"]",
      "In[2]:="
    ],
    hrfNbRDText["The summary includes ExternalConventionCounts. The desired convention is p_i attached at vertex i for i = 1,...,5; all input rows should be True. CandidateRows are post-selected representatives: duplicate candidates which differ only by internal propagator naming or by the generic external-label exchange p4 <-> p5 are removed, while RawCandidateRows keeps the pre-deduplication list."],

    hrfNbRDSection["Example 03 Block"],
    hrfNbRDText["These are the primary representatives of the seed, six one-split seven-propagator diagrams, and nine two-split eight-propagator diagrams from notebook 03. They are also placed first in the candidate dataset and CSV handoff."],
    hrfNbRDInput[
      "RDScan[\"ReferenceDataset\"]",
      "In[3]:="
    ],
    hrfNbRDText["This is the full post-selected candidate table, including planar and nonplanar rows. The Example 03 block appears first, followed by the remaining planar candidates and then the remaining nonplanar candidates."],
    hrfNbRDInput[
      "RDScan[\"CandidateDataset\"]",
      "In[4]:="
    ],

    hrfNbRDSection["Seven-Propagator Candidates"],
    hrfNbRDInput[
      "RDSeven = Select[RDScan[\"CandidateRows\"], #PropagatorCount == 7 &];\nDataset[hrfRecursiveWideDisplayRow /@ RDSeven]",
      "In[5]:="
    ],

    hrfNbRDSection["Draw Candidates"],
    hrfNbRDText["The drawing shows the original listed integral graph. The ZeroVars shown in the title are only the recursive-preselection diagnostic, not instructions for the HRF stage. Change rowsToDraw to inspect another slice."],
    hrfNbRDInput[
      "rowsToDraw = Take[RDSeven, UpTo[20]];\nhrfRecursiveCandidateDrawingGrid[rowsToDraw, 2]",
      "In[6]:="
    ],

    hrfNbRDSection["Inspect One Candidate"],
    hrfNbRDInput[
      "family = \"nonplanar\";\ndiagramIndex = 50;\nrow = FirstCase[RDScan[\"Rows\"], r_ /; r[\"Family\"] == family && r[\"DiagramIndex\"] == diagramIndex, First[RDScan[\"CandidateRows\"]]];\n{hrfRecursiveCandidateDrawingPanel[row], Dataset[{hrfRecursiveWideDisplayRow[row]}], Dataset[hrfRecursiveDerivativeStatusRows[row]]}",
      "In[7]:="
    ],

    hrfNbRDSection["Exports"],
    hrfNbRDInput[
      "Export[FileNameJoin[{NotebookDirectory[], \"RecursiveDerivativePreselectionScan.csv\"}], hrfRecursiveCSVTable[hrfRecursiveWideDisplayRow /@ RDScan[\"Rows\"]]];\nExport[FileNameJoin[{NotebookDirectory[], \"RecursiveDerivativePreselectionCandidates.csv\"}], hrfRecursiveCSVTable[hrfRecursiveWideDisplayRow /@ RDScan[\"CandidateRows\"]]];\nExport[FileNameJoin[{NotebookDirectory[], \"RecursiveDerivativePreselectionReference03.csv\"}], hrfRecursiveCSVTable[hrfRecursiveWideDisplayRow /@ RDScan[\"ReferenceRows\"]]];\nExport[FileNameJoin[{NotebookDirectory[], \"RecursiveDerivativePreselectionReference03Matches.csv\"}], hrfRecursiveCSVTable[hrfRecursiveWideDisplayRow /@ RDScan[\"ReferenceMatchRows\"]]];\nExport[FileNameJoin[{NotebookDirectory[], \"RecursiveDerivativePreselectionHandoff.csv\"}], hrfRecursiveCSVTable[RDScan[\"CandidateHandoffRows\"]]];\nPut[RDScan[\"CandidateHandoffRows\"], FileNameJoin[{NotebookDirectory[], \"RecursiveDerivativePreselectionHandoff.wl\"}]];",
      "In[8]:="
    ]
  }
];

Print["Recursive derivative preselection notebook rebuilt in ", $dir];
