(* ::Package:: *)
(* 02_Forward_Regge_2to2_Massless.wl

   Massless 4 -> 2 examples in the Regge / forward limit.
   Mirrors Example 01 (Crown, SuperCrown, HyperCrown, Diving Beetle) with:
     - wide-angle massless baseline (s12 and s23 both active)
     - three Regge channels T23, T12, T13 (small t = -\[Delta]*s)

   Usage:
     Get["HiddenRegionFinder.wl"];
     Get["02_Forward_Regge_2to2_Massless.wl"];

   Optional flags:
     $HRFRunEx02HyperCrownBoundaries = True
     $HRFRunEx02SuperCrownBoundary = True
     $HRFExample02Report = True
*)

If[! ValueQ[$HRFExample02Report], $HRFExample02Report = True];
If[! ValueQ[$HRFRunEx02SuperCrownBoundary], $HRFRunEx02SuperCrownBoundary = True];
If[! ValueQ[$HRFRunEx02HyperCrownBoundaries], $HRFRunEx02HyperCrownBoundaries = False];
If[! ValueQ[$HRFRunEx02DBBoundary], $HRFRunEx02DBBoundary = False];
If[! ValueQ[$HRFScalingReport], $HRFScalingReport = False];

$HRFExample02Directory = If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName],
  Quiet[Check[NotebookDirectory[], Directory[]]]
];

If[! ValueQ[findObstructions], Get[$HRFExample02Directory <> "HiddenRegionFinder.wl"]];
Get[$HRFExample02Directory <> "HRF_Example01Common.wl"];
Get[$HRFExample02Directory <> "HRF_FinalLogicPatch.wl"];
Get[$HRFExample02Directory <> "HRF_Example01Reporting.wl"];
Get[$HRFExample02Directory <> "HRF_Example02ReggeKinematics.wl"];
Get[$HRFExample02Directory <> "HRF_Example02Reporting.wl"];

ClearAll[hrfExample02Say, makeFourPointMasslessF, hrfEx02RunObstructionScan,
  hrfEx02InteriorStudy, hrfEx02BoundaryStudy, hrfEx02DrawDiagram];

hrfExample02Say[msg_] := If[TrueQ[$HRFExample02Report], Print["[Example 02] " <> msg]];

makeFourPointMasslessF[internalLines_, externalLines_] := Module[{uf, f, vars},
  uf = SymanzikUF[internalLines, externalLines];
  f = toCyclicMandelstams4ptMassless[uf["F"]];
  vars = uf["Variables"];
  <|"UF" -> uf, "F" -> Expand[f], "Vars" -> vars|>
];

hrfEx02DrawDiagram[internalEdges_, externalEdges_] :=
  drawGraphFromPySecDecInput[internalEdges, externalEdges];

KinAssump4ptWideMassless = s12 > 0 && s23 < 0;
KinVars4ptWideMassless = {s12, s23};

hrfEx02RunObstructionScan[F_, vars_, kinAssump_, kinVars_, maxSize_:20] :=
  findObstructions[
    F, vars, kinAssump, kinVars, maxSize,
    "GeneratorMode" -> "PairSectors",
    "UseExtendedFactors" -> True,
    "MaxGenerators" -> 2
  ];

hrfEx02InteriorStudy[diagram_, data_Association, maxSize_:20] := Module[
  {F = data["F"], vars = data["Vars"], U = data["UF"]["U"], wideScan, rows = {}, study},
  hrfExample02Say[diagram <> ": interior wide-angle scan."];
  wideScan = hrfEx02RunObstructionScan[F, vars, KinAssump4ptWideMassless, KinVars4ptWideMassless, maxSize];
  study = <|
    "Diagram" -> diagram,
    "Data" -> data,
    "Wide" -> hrfEx02StudyRow[diagram, "Interior wide-angle", "Wide", {}, vars, wideScan, U,
      hrfCoverageData[wideScan, U, vars, 5], 5]
  |>;
  Do[
    Module[{fRegge, kv, ka, scan, cov},
      hrfExample02Say[diagram <> ": interior Regge channel " <> regCh <> "."];
      fRegge = hrfReggeLeadingF[F, regCh];
      kv = hrfReggeKinVars[regCh];
      ka = hrfReggeKinAssumptions[regCh];
      scan = hrfEx02RunObstructionScan[fRegge, vars, ka, kv, maxSize];
      cov = hrfCoverageData[scan, U, vars, 5];
      study = Join[study, <|regCh -> hrfEx02StudyRow[diagram, "Interior Regge " <> regCh, regCh, {}, vars, scan, U, cov, 5]|>];
    ],
    {regCh, hrfReggeChannels[]}
  ];
  study
];

hrfEx02BoundaryStudy[diagram_, data_Association, zeroVars_List, regionLabel_, maxSize_:30] := Module[
  {F = data["F"], U = data["UF"]["U"], fB, varsB, uB, wideScan, row},
  fB = Expand[F /. Thread[zeroVars -> 0]];
  varsB = Complement[data["Vars"], zeroVars];
  uB = Expand[U /. Thread[zeroVars -> 0]];
  If[fB === 0,
    Return[<|
      "Diagram" -> diagram,
      "Region" -> regionLabel,
      "ZeroVars" -> zeroVars,
      "Status" -> "TrivialBoundary",
      "FRestricted" -> 0,
      "Wide" -> <|"Hidden region identified?" -> "No", "Comment" -> "trivial: restricted F is zero",
        "Kinematic regime" -> "Wide", "Diagram" -> diagram|>,
      "T23" -> <|"Hidden region identified?" -> "No", "Comment" -> "trivial: restricted F is zero",
        "Kinematic regime" -> "T23", "Diagram" -> diagram|>,
      "T12" -> <|"Hidden region identified?" -> "No", "Comment" -> "trivial: restricted F is zero",
        "Kinematic regime" -> "T12", "Diagram" -> diagram|>,
      "T13" -> <|"Hidden region identified?" -> "No", "Comment" -> "trivial: restricted F is zero",
        "Kinematic regime" -> "T13", "Diagram" -> diagram|>
    |>]
  ];
  wideScan = hrfEx02RunObstructionScan[fB, varsB, KinAssump4ptWideMassless, KinVars4ptWideMassless, maxSize];
  row = <|
    "Diagram" -> diagram,
    "Region" -> regionLabel,
    "ZeroVars" -> zeroVars,
    "FRestricted" -> fB,
    "URestricted" -> uB,
    "RemainingVars" -> varsB,
    "Wide" -> hrfEx02StudyRow[diagram, regionLabel <> " wide-angle", "Wide", zeroVars, varsB, wideScan, uB,
      hrfCoverageData[wideScan, uB, varsB, 5], 5]
  |>;
  Do[
    Module[{fRegge, kv, ka, scan, cov},
      fRegge = hrfReggeLeadingF[fB, regCh];
      kv = hrfReggeKinVars[regCh];
      ka = hrfReggeKinAssumptions[regCh];
      scan = hrfEx02RunObstructionScan[fRegge, varsB, ka, kv, maxSize];
      cov = hrfCoverageData[scan, uB, varsB, 5];
      row = Join[row, <|regCh -> hrfEx02StudyRow[diagram, regionLabel <> " Regge " <> regCh, regCh, zeroVars, varsB, scan, uB, cov, 5]|>];
    ],
    {regCh, hrfReggeChannels[]}
  ];
  row
];

(* ---------------------------------------------------------------------- *)
(* Diagram definitions (same topologies as Example 01, massless external legs) *)
(* ---------------------------------------------------------------------- *)

CrownInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 6}}, {"0", {2, 5}}, {"0", {2, 6}},
  {"0", {3, 5}}, {"0", {3, 6}}, {"0", {4, 5}}, {"0", {4, 6}}
};
CrownExternalEdges = {{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}};

SuperCrownInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 6}}, {"0", {2, 7}}, {"0", {2, 6}},
  {"0", {3, 5}}, {"0", {3, 8}}, {"0", {4, 7}}, {"0", {4, 8}},
  {"0", {5, 7}}, {"0", {6, 8}}, {"0", {7, 8}}, {"0", {5, 6}}
};
SuperCrownExternalEdges = CrownExternalEdges;

HyperCrownInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 6}}, {"0", {4, 9}}, {"0", {4, 6}}, {"0", {2, 7}}, {"0", {2, 6}},
  {"0", {3, 8}}, {"0", {3, 6}}, {"0", {9, 5}}, {"0", {7, 8}},
  {"0", {8, 9}}, {"0", {5, 7}}
};
HyperCrownExternalEdges = CrownExternalEdges;

DBInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 7}}, {"0", {7, 4}}, {"0", {4, 9}},
  {"0", {9, 3}}, {"0", {3, 5}}, {"0", {2, 5}}, {"0", {2, 6}},
  {"0", {6, 8}}, {"0", {6, 4}}, {"0", {9, 8}}, {"0", {8, 7}}
};
DBExternalEdges = CrownExternalEdges;

Ex02Diagrams = <|
  "Crown" -> makeFourPointMasslessF[CrownInternalEdges, CrownExternalEdges],
  "SuperCrown" -> makeFourPointMasslessF[SuperCrownInternalEdges, SuperCrownExternalEdges],
  "HyperCrown" -> makeFourPointMasslessF[HyperCrownInternalEdges, HyperCrownExternalEdges],
  "Diving Beetle" -> makeFourPointMasslessF[DBInternalEdges, DBExternalEdges]
|>;

(* ---------------------------------------------------------------------- *)
(* Interior studies *)
(* ---------------------------------------------------------------------- *)

Ex02InteriorStudies = <|
  "Crown" -> hrfEx02InteriorStudy["Crown", Ex02Diagrams["Crown"], 20],
  "SuperCrown" -> hrfEx02InteriorStudy["SuperCrown", Ex02Diagrams["SuperCrown"], 20],
  "HyperCrown" -> hrfEx02InteriorStudy["HyperCrown", Ex02Diagrams["HyperCrown"], 30],
  "Diving Beetle" -> hrfEx02InteriorStudy["Diving Beetle", Ex02Diagrams["Diving Beetle"], 20]
|>;

Ex02InteriorStudyTable = hrfEx02DiagramStudyTable[
  Flatten @ KeyValueMap[
    Function[{diagram, study},
      Lookup[study, #] & /@ Prepend[hrfReggeChannels[], "Wide"]
    ],
    Ex02InteriorStudies
  ]
];

Ex02InteriorComparisonTables = Association @@ (
  (#[[1]] -> hrfEx02InteriorComparisonTable[#[[2]]]) & /@ Normal[Ex02InteriorStudies]
);

(* ---------------------------------------------------------------------- *)
(* Boundary studies *)
(* ---------------------------------------------------------------------- *)

Ex02BoundaryRows = {};

If[TrueQ[$HRFRunEx02SuperCrownBoundary],
  hrfExample02Say["SuperCrown: boundary study on {x8,x9}=0."];
  Ex02BoundaryRows = Append[Ex02BoundaryRows,
    hrfEx02BoundaryStudy["SuperCrown", Ex02Diagrams["SuperCrown"], {x8, x9}, "Boundary {x8,x9}", 30]
  ];
];

If[TrueQ[$HRFRunEx02HyperCrownBoundaries],
  hrfExample02Say["HyperCrown: boundary study on all 15 subsets of {x8,x9,x10,x11}."];
  Ex02HyperCrownBoundaryZeroSets = Subsets[{x8, x9, x10, x11}, {1, 4}];
  Ex02BoundaryRows = Join[Ex02BoundaryRows,
    Table[
      hrfEx02BoundaryStudy[
        "HyperCrown", Ex02Diagrams["HyperCrown"],
        Ex02HyperCrownBoundaryZeroSets[[k]],
        "Boundary " <> ToString[InputForm[Ex02HyperCrownBoundaryZeroSets[[k]]]],
        30
      ],
      {k, Length[Ex02HyperCrownBoundaryZeroSets]}
    ]
  ];
];

If[TrueQ[$HRFRunEx02DBBoundary],
  hrfExample02Say["Diving Beetle: boundary study on {x8,x9}=0."];
  Ex02BoundaryRows = Append[Ex02BoundaryRows,
    hrfEx02BoundaryStudy["Diving Beetle", Ex02Diagrams["Diving Beetle"], {x8, x9}, "Boundary {x8,x9}", 20]
  ];
];

Ex02BoundaryComparisonTables = If[Ex02BoundaryRows === {},
  <||>,
  <|
    "SuperCrown" -> If[Length[Ex02BoundaryRows] >= 1,
      hrfEx02BoundaryComparisonTable[{First[Ex02BoundaryRows]}],
      Dataset[{}]
    ],
    "HyperCrown" -> hrfEx02BoundaryComparisonTable[
      Select[Ex02BoundaryRows, Lookup[#, "Diagram", ""] === "HyperCrown" &]
    ],
    "Diving Beetle" -> hrfEx02BoundaryComparisonTable[
      Select[Ex02BoundaryRows, Lookup[#, "Diagram", ""] === "Diving Beetle" &]
    ]
  |>
];

Ex02ReggeOnlyFlags = hrfEx02ReggeOnlyFlagsTable[Values[Ex02InteriorStudies], Ex02BoundaryRows];
Ex02ComparisonNarrative = hrfEx02Narrative[Ex02ReggeOnlyFlags];

(* Backward-compatible Crown aliases from the original 02 file. *)
CrownMasslessData = Ex02Diagrams["Crown"];
FCrownMassless = CrownMasslessData["F"];
VarsCrown = CrownMasslessData["Vars"];
KinVars4ptSmall23 = hrfReggeKinVars["T23"];
KinAssump4ptSmall23 = hrfReggeKinAssumptions["T23"];
F0CrownSmall23 = hrfReggeLeadingF[FCrownMassless, "T23"];
CrownForwardScan = hrfEx02RunObstructionScan[F0CrownSmall23, VarsCrown, KinAssump4ptSmall23, KinVars4ptSmall23, 20];

CoverageScalingTests2to2Forward = <|
  "CrownForward" -> hrfCoverageData[CrownForwardScan, CrownMasslessData["UF"]["U"], VarsCrown, 5],
  "Ex02InteriorStudies" -> Ex02InteriorStudies,
  "Ex02ReggeOnlyFlags" -> Ex02ReggeOnlyFlags
|>;

(* Compact inspection:
hrfEx02DrawDiagram[CrownInternalEdges, CrownExternalEdges]
hrfEx02ChannelLegend[]
hrfEx02InteriorComparisonDisplay["Crown"]
Ex02ReggeOnlyFlags
Ex02ComparisonNarrative

Notebook: Example_02_Regge_2to2_Debug_Demo.nb
*)
