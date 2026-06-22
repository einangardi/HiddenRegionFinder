(* ::Package:: *)

(* 01_WideAngle_2to2_OffShell.wl

   Wide-angle 2 -> 2 kinematics with external off-shellnesses taken to zero.
   This file contains the ordinary Crown, SuperCrown, HyperCrown and Diving Beetle examples.

   Expected highlights:
     Crown:      interior hidden region; F_SL = s12 gen1 + s23 gen2 (two pair-sector generators).
     SuperCrown: boundary hidden region on {x8,x9}=0, inherited from the Crown.
     HyperCrown: boundary scan over all nonempty subsets of {x8,x9,x10,x11} up to codimension 4.
    DB:         boundary scan diagnostic; in current tests no hidden region was found
                 up to the tested codimension/obstruction size.

   Usage in the current flat directory:
     Get[NotebookDirectory[] <> "HiddenRegionFinder.wl"];
     Get[NotebookDirectory[] <> "01_WideAngle_2to2_OffShell.wl"];

   Optional load-time flags:
     $HRFRunHyperCrownBoundaryScansOnLoad = True   (* 15 HyperCrown boundary strata *)
     $HRFRunDBFullBoundaryScan = True                (* retain all 794 DB boundary scans *)
     $HRFRunDeepBoundaryScan = True                  (* examine 794 DB strata, retain interesting only *)
     $HRFScalingReport = False                       (* quieter automatic coverage during boundary scans *)

   After loading, inspect:
     hrfHyperCrownRegionStudyTable[]
     hrfHyperCrownChannelAttemptTable[]
     hrfDivingBeetleRegionStudyTable[]
     hrfDivingBeetleFailureNarrative[]
*)


If[! ValueQ[$HRFScalingReport], $HRFScalingReport = False];
If[! ValueQ[$HRFRunScalingDiagnostics], $HRFRunScalingDiagnostics = False];
If[! ValueQ[$HRFRunDeepBoundaryScan], $HRFRunDeepBoundaryScan = False];
If[! ValueQ[$HRFRunCrownInteriorScanOnLoad], $HRFRunCrownInteriorScanOnLoad = True];
If[! ValueQ[$HRFRunExample01ReportingOnLoad], $HRFRunExample01ReportingOnLoad = True];
If[! ValueQ[$HRFExample01Report], $HRFExample01Report = True];
(* Runtime safety flags.  Expensive exploratory scans are not run during Get by default. *)
If[! ValueQ[$HRFRunSuperCrownInteriorScan], $HRFRunSuperCrownInteriorScan = False];
(* Two-loop interiors need polynomial + Adaptive (Ex04); binomial PairSectors on load is legacy. *)
If[! ValueQ[$HRFRunHyperCrownInteriorScan], $HRFRunHyperCrownInteriorScan = False];
If[! ValueQ[$HRFRunHyperCrownBoundaryScansOnLoad], $HRFRunHyperCrownBoundaryScansOnLoad = False];
If[! ValueQ[$HRFRunSuperCrownBoundaryScanOnLoad], $HRFRunSuperCrownBoundaryScanOnLoad = False];
If[! ValueQ[$HRFRunDivingBeetleDiagnosticsOnLoad], $HRFRunDivingBeetleDiagnosticsOnLoad = False];
If[! ValueQ[$HRFRunDivingBeetleInteriorScanOnLoad], $HRFRunDivingBeetleInteriorScanOnLoad = False];
If[! ValueQ[$HRFRunDBFullBoundaryScan], $HRFRunDBFullBoundaryScan = False];

$HRFExample01Directory = If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName],
  Quiet[Check[NotebookDirectory[], Directory[]]]
];

If[! TrueQ[$HRFFinderCoreLoadedQ], Get[$HRFExample01Directory <> "HiddenRegionFinder.wl"]];
Get[$HRFExample01Directory <> "HRF_Example01Common.wl"];
Get[$HRFExample01Directory <> "HRF_FinalLogicPatch.wl"];
Get[$HRFExample01Directory <> "HRF_Example01Reporting.wl"];

ClearAll[hrfExample01Say];
hrfExample01Say[msg_] := If[TrueQ[$HRFExample01Report], Print["[Example 01] " <> msg]];

ClearAll[makeFourPointOnShellF0];

(* makeFourPointOnShellF0[internal, external]
   Input:  graph in pySecDec-style internal/external-line notation.
   Output: Association with "UF", "FOnShell", "F0", "Vars".
   The off-shellnesses p_i^2 are replaced by delta and F0 is the strict delta^0 part. *)
makeFourPointOnShellF0[internalLines_, externalLines_] := Module[
  {uf, f, fOnShell, f0, vars},
  uf = SymanzikUF[internalLines, externalLines];
  f = toCyclicMandelstams4ptMassive[uf["F"]];
  fOnShell = Expand[f /. {p1sq -> \[Delta], p2sq -> \[Delta], p3sq -> \[Delta], p4sq -> \[Delta]}];
  f0 = Expand[fOnShell /. \[Delta] -> 0];
  vars = uf["Variables"];
  <|"UF" -> uf, "FOnShell" -> fOnShell, "F0" -> f0, "Vars" -> vars|>
];

(* Massless wide-angle 2->2 channel: s>0, t<0, u<0  <=>  s12 > -s23 > 0. *)
KinAssump4ptOnShell = s12 > -s23 > 0;
KinVars4pt = {s12, s23};

(* ---------------------------------------------------------------------- *)
(* Ordinary Crown: interior hidden region                                  *)
(* ---------------------------------------------------------------------- *)

CrownInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 6}}, {"0", {2, 5}}, {"0", {2, 6}},
  {"0", {3, 5}}, {"0", {3, 6}}, {"0", {4, 5}}, {"0", {4, 6}}
};

CrownExternalEdges = {{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}};

CrownData = makeFourPointOnShellF0[CrownInternalEdges, CrownExternalEdges];
F0Crown = CrownData["F0"];
VarsCrown = CrownData["Vars"];

If[TrueQ[$HRFRunCrownInteriorScanOnLoad],
  If[TrueQ[$HRFUsePolynomialCancellationFactors],
    hrfExample01Say["Warning: Crown interior on load uses polynomial cancellation factors (slow). Set $HRFRunCrownInteriorScanOnLoad=False or load 01 before hrfInstallPolynomialCancellationPatch[]."]
  ];
  hrfExample01Say["Crown: running interior obstruction finder."];
  CrownScan = hrfAttachBoundaryScanContext[
    findObstructions[
      F0Crown, VarsCrown, KinAssump4ptOnShell, KinVars4pt, 20,
      "GeneratorMode" -> "PairSectors",
      "UseExtendedFactors" -> True,
      "MaxGenerators" -> 2
    ],
    F0Crown, VarsCrown, {}
  ];

  CrownGeneratorCheck = PolynomialReduce[
    CrownScan["ObstructionData", "Superleading"],
    CrownScan["Generators"],
    Join[VarsCrown, KinVars4pt]
  ];,
  CrownScan = Missing["NotRun", "Set $HRFRunCrownInteriorScanOnLoad=True before loading, or evaluate the Crown interior scan cell manually."];
  CrownGeneratorCheck = Missing["NotRun"]
];

(* Expected CrownGeneratorCheck: {{s12,-s23},0} with two x-sector generators. *)

(* Coverage-based LP scaling diagnostic for the ordinary Crown.  There is no
   separate F_obs in this 2 -> 2 off-shell/on-shell test, so the replacement
   criterion uses F_SL and U only. *)
If[TrueQ[$HRFRunScalingDiagnostics],
  hrfExample01Say["Crown: running optional coverage-scaling diagnostic."];
  CrownCoverageScalingData = findCoverageLPScaling[
    CrownScan["ObstructionData", "Superleading"], CrownData["UF"]["U"], VarsCrown, 5
  ];
  CrownOldScalingDiagnostic = Module[
  {old = findMinimalLPScaling[
      CrownScan["ObstructionData", "Obstruction"],
      CrownScan["ObstructionData", "Complement"],
      CrownData["UF"]["U"], VarsCrown, 5]},
  If[ListQ[old], scalingDiagnostic[CrownScan["ObstructionData", "Superleading"], CrownData["UF"]["U"], VarsCrown, old], old]
  ];,
  CrownCoverageScalingData = Missing["NotRun", "Set $HRFRunScalingDiagnostics=True before loading the example"];
  CrownOldScalingDiagnostic = Missing["NotRun", "Set $HRFRunScalingDiagnostics=True before loading the example"]
];


(* ---------------------------------------------------------------------- *)
(* SuperCrown: boundary hidden region inherited from Crown                  *)
(* ---------------------------------------------------------------------- *)

SuperCrownInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 6}}, {"0", {2, 7}}, {"0", {2, 6}},
  {"0", {3, 5}}, {"0", {3, 8}}, {"0", {4, 7}}, {"0", {4, 8}},
  {"0", {5, 7}}, {"0", {6, 8}}, {"0", {7, 8}}, {"0", {5, 6}}
};



SuperCrownExternalEdges = CrownExternalEdges;

SuperCrownData = makeFourPointOnShellF0[SuperCrownInternalEdges, SuperCrownExternalEdges];
F0SuperCrown = SuperCrownData["F0"];
VarsSuperCrown = SuperCrownData["Vars"];

(* Interior scan is exploratory and can be expensive; it is not run during Get by default. *)
If[TrueQ[$HRFRunSuperCrownInteriorScan],
  hrfExample01Say["SuperCrown: running interior obstruction finder."];
  SuperCrownInteriorScan = findObstructions[
    F0SuperCrown, VarsSuperCrown, KinAssump4ptOnShell, KinVars4pt, 30,
    "GeneratorMode" -> "PairSectors",
    "UseExtendedFactors" -> True,
    "MaxGenerators" -> 2
  ];,
  SuperCrownInteriorScan = Missing["NotRun", "Set $HRFRunSuperCrownInteriorScan=True before loading, or evaluate the SuperCrown interior scan cell manually."]
];

(* Boundary stratum exposing the inherited Crown structure. *)
zeroSC = {x8, x9};
F0SuperCrownBoundary = Factor[Expand[F0SuperCrown /. Thread[zeroSC -> 0]]];
VarsSuperCrownBoundary = Complement[VarsSuperCrown, zeroSC];

If[TrueQ[$HRFRunSuperCrownBoundaryScanOnLoad],
  hrfExample01Say["SuperCrown: running boundary obstruction finder on {x8,x9}=0."];
  SuperCrownBoundaryScan = findObstructions[
    F0SuperCrownBoundary, VarsSuperCrownBoundary,
    KinAssump4ptOnShell, KinVars4pt, 100,
    "GeneratorMode" -> "PairSectors",
    "UseExtendedFactors" -> True,
    "MaxGenerators" -> 2
  ];

  SuperCrownGeneratorCheck = PolynomialReduce[
    SuperCrownBoundaryScan["ObstructionData", "Superleading"],
    SuperCrownBoundaryScan["Generators"],
    Join[VarsSuperCrownBoundary, KinVars4pt]
  ];,
  SuperCrownBoundaryScan = Missing["NotRun", "Set $HRFRunSuperCrownBoundaryScanOnLoad=True before loading, or evaluate the SuperCrown boundary scan cell manually."];
  SuperCrownGeneratorCheck = Missing["NotRun"]
];

(* Expected SuperCrownGeneratorCheck: {{s12 x10 x11, -s23 x10 x11},0}. *)

(* Coverage-based LP scaling diagnostic for the inherited Crown boundary. *)
If[TrueQ[$HRFRunScalingDiagnostics],
  hrfExample01Say["SuperCrown: running optional coverage-scaling diagnostic on boundary."];
  SuperCrownCoverageScalingData = findCoverageLPScaling[
    SuperCrownBoundaryScan["ObstructionData", "Superleading"],
    SuperCrownData["UF"]["U"] /. Thread[zeroSC -> 0] // Expand,
    VarsSuperCrownBoundary, 5
  ];
  SuperCrownOldScalingDiagnostic = Module[
  {old = findMinimalLPScaling[
      SuperCrownBoundaryScan["ObstructionData", "Obstruction"],
      SuperCrownBoundaryScan["ObstructionData", "Complement"],
      SuperCrownData["UF"]["U"] /. Thread[zeroSC -> 0] // Expand,
      VarsSuperCrownBoundary, 5]},
  If[ListQ[old], scalingDiagnostic[SuperCrownBoundaryScan["ObstructionData", "Superleading"], SuperCrownData["UF"]["U"] /. Thread[zeroSC -> 0] // Expand, VarsSuperCrownBoundary, old], old]
  ];,
  SuperCrownCoverageScalingData = Missing["NotRun", "Set $HRFRunScalingDiagnostics=True before loading the example"];
  SuperCrownOldScalingDiagnostic = Missing["NotRun", "Set $HRFRunScalingDiagnostics=True before loading the example"]
];


(* ---------------------------------------------------------------------- *)
(* HyperCrown: data-driven boundary scan                                    *)
(* ---------------------------------------------------------------------- *)

HyperCrownInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 6}}, {"0", {4, 9}}, {"0", {4, 6}}, {"0", {2, 7}}, {"0", {2, 6}},
  {"0", {3, 8}}, {"0", {3, 6}}, {"0", {9, 5}}, {"0", {7, 8}},
  {"0", {8, 9}}, {"0", {5, 7}}
};

HyperCrownExternalEdges = CrownExternalEdges;

HyperCrownData = makeFourPointOnShellF0[HyperCrownInternalEdges, HyperCrownExternalEdges];
F0HyperCrown = HyperCrownData["F0"];
VarsHyperCrown = HyperCrownData["Vars"];

(* Interior scan is exploratory and can be expensive; it is not run during Get by default. *)
If[TrueQ[$HRFRunHyperCrownInteriorScan],
  hrfExample01Say["HyperCrown: running interior obstruction finder."];
  HyperCrownInteriorScan = hrfAttachBoundaryScanContext[
    findObstructions[
      F0HyperCrown, VarsHyperCrown, KinAssump4ptOnShell, KinVars4pt, 20,
      Sequence @@ Join[
        {"UseExtendedFactors" -> True, "StoreAllObstructionTrialsQ" -> False},
        hrfKinematicLimitInteriorOptions["WideAngle4pt"]
      ]
    ],
    F0HyperCrown, VarsHyperCrown, {}
  ];,
  HyperCrownInteriorScan = Missing["NotRun", "Set $HRFRunHyperCrownInteriorScan=True before loading, or evaluate the HyperCrown interior scan cell manually."]
];

(* Boundary scan: do not assume a distinguished {x8,x9} stratum.  Scan all
   nonempty subsets of the four added HyperCrown variables up to codimension 4. *)
HyperCrownBoundaryCandidateVariables = {x8, x9, x10, x11};
HyperCrownBoundaryZeroSets = Subsets[
  HyperCrownBoundaryCandidateVariables,
  {1, Length[HyperCrownBoundaryCandidateVariables]}
];

ClearAll[hrfExample01ObstructionFoundQ, hrfExample01BoundaryGeneratorCheck];
hrfExample01ObstructionFoundQ[scan_] := Module[{od},
  od = If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing["NoScan"]], Missing["NoScan"]];
  If[ValueQ[hrfObstructionFoundQ], Return[hrfObstructionFoundQ[scan]]];
  AssociationQ[od] && KeyExistsQ[od, "Superleading"] && od["Superleading"] =!= 0
];

hrfExample01BoundaryGeneratorCheck[scan_, vars_] := If[hrfExample01ObstructionFoundQ[scan],
  PolynomialReduce[
    scan["ObstructionData", "Superleading"],
    scan["Generators"],
    Join[vars, KinVars4pt]
  ],
  Missing["NoObstructionFound"]
];

ClearAll[hrfExample01VariableIndex, hrfExample01GraphBoundaryData];
hrfExample01VariableIndex[v_Symbol] := ToExpression[StringDrop[SymbolName[Unevaluated[v]], 1]];

(* Deprecated diagnostic helper.  The notebook boundary scans use polynomial
   restriction x_i -> 0, not graph-edge deletion/recomputation.  This helper is
   kept only for manual experiments. *)
hrfExample01GraphBoundaryData[internalEdges_, externalEdges_, zeroVars_] := Module[
  {idx, reducedEdges, data},
  idx = Sort[hrfExample01VariableIndex /@ zeroVars, Greater];
  reducedEdges = Delete[internalEdges, List /@ idx];
  data = makeFourPointOnShellF0[reducedEdges, externalEdges];
  <|
    "ZeroVars" -> zeroVars,
    "DeletedEdgeIndices" -> Reverse[idx],
    "ReducedInternalEdges" -> reducedEdges,
    "Data" -> data,
    "FRestricted" -> data["F0"],
    "URestricted" -> data["UF"]["U"],
    "RemainingVars" -> data["Vars"]
  |>
];

If[TrueQ[$HRFRunHyperCrownBoundaryScansOnLoad],
  hrfExample01Say[
    "HyperCrown: running boundary obstruction finder on all nonempty subsets of {x8,x9,x10,x11} up to codimension 4 (" <>
      ToString[Length[HyperCrownBoundaryZeroSets]] <> " strata)."
  ];
  HyperCrownBoundaryCandidateScans = Table[
    Module[{zeroHC, row, scan, vars, f, genCheck, uRestricted},
      zeroHC = HyperCrownBoundaryZeroSets[[i]];
      uRestricted = Expand[HyperCrownData["UF"]["U"] /. Thread[zeroHC -> 0]];
      row = findObstructionsOnBoundary[
        F0HyperCrown, VarsHyperCrown, zeroHC, KinAssump4ptOnShell, KinVars4pt, 30,
        "GeneratorMode" -> "PairSectors",
        "UseExtendedFactors" -> True,
        "MaxGenerators" -> 2
      ];
      scan = row["ObstructionScan"];
      vars = row["RemainingVars"];
      f = row["FRestricted"];
      If[! AssociationQ[scan],
        scan = <|
          "ObstructionData" -> Missing["TrivialBoundary"],
          "Generators" -> {}, "CancellationFactors" -> {},
          "AdmissibleGeneratorSetQ" -> False
        |>
      ];
      genCheck = hrfExample01BoundaryGeneratorCheck[scan, vars];
      cov = If[hrfObstructionFoundQ[scan],
        findCoverageLPScaling[
          hrfEffectiveSuperleadingSector[scan],
          uRestricted,
          vars,
          5
        ],
        Missing["NoObstructionForScaling"]
      ];
      <|
        "Case" -> "HyperCrown",
        "Index" -> i,
        "ZeroVars" -> zeroHC,
        "RemainingVars" -> vars,
        "FRestricted" -> f,
        "URestricted" -> uRestricted,
        "ObstructionScan" -> scan,
        "GeneratorCheck" -> genCheck,
        "CoverageScalingData" -> cov
      |>
    ],
    {i, Length[HyperCrownBoundaryZeroSets]}
  ],
  HyperCrownBoundaryCandidateScans = Missing["NotRun", "Set $HRFRunHyperCrownBoundaryScansOnLoad=True before loading, or evaluate the HyperCrown boundary scan cell manually."]
];

HyperCrownBoundaryHiddenCandidates = If[ListQ[HyperCrownBoundaryCandidateScans],
  Select[
    HyperCrownBoundaryCandidateScans,
    hrfObstructionFoundQ[Lookup[#, "ObstructionScan", Missing["NoScan"]]] &
  ],
  {}
];

(* Backward-compatible aliases.  These refer to the first boundary with an
   obstruction, if any; the full data-driven result is HyperCrownBoundaryCandidateScans. *)
If[HyperCrownBoundaryHiddenCandidates =!= {},
  zeroHyperCrownBoundary = First[HyperCrownBoundaryHiddenCandidates]["ZeroVars"];
  F0HyperCrownBoundary = First[HyperCrownBoundaryHiddenCandidates]["FRestricted"];
  VarsHyperCrownBoundary = First[HyperCrownBoundaryHiddenCandidates]["RemainingVars"];
  HyperCrownBoundaryScan = First[HyperCrownBoundaryHiddenCandidates]["ObstructionScan"];
  HyperCrownGeneratorCheck = First[HyperCrownBoundaryHiddenCandidates]["GeneratorCheck"];,
  zeroHyperCrownBoundary = Missing["NoObstructionBoundaryFound"];
  F0HyperCrownBoundary = Missing["NoObstructionBoundaryFound"];
  VarsHyperCrownBoundary = Missing["NoObstructionBoundaryFound"];
  HyperCrownBoundaryScan = Missing["NoObstructionFoundInCandidateBoundaries"];
  HyperCrownGeneratorCheck = Missing["NoObstructionFound"]
];

(* Coverage-based LP scaling diagnostics for all HyperCrown boundaries with an obstruction. *)
If[TrueQ[$HRFRunScalingDiagnostics],
  hrfExample01Say["HyperCrown: running optional coverage-scaling diagnostics on boundary candidates with obstructions."];
  HyperCrownBoundaryCoverageSummaries = Table[
    Module[{row = HyperCrownBoundaryHiddenCandidates[[i]], z, vars, scan},
      z = row["ZeroVars"];
      vars = row["RemainingVars"];
      scan = row["ObstructionScan"];
      <|
        "ZeroVars" -> z,
        "RemainingVars" -> vars,
        "CoverageScalingData" -> findCoverageLPScaling[
          scan["ObstructionData", "Superleading"],
          row["URestricted"],
          vars, 5,
          scan["ObstructionData", "Obstruction"]
        ]
      |>
    ],
    {i, Length[HyperCrownBoundaryHiddenCandidates]}
  ];
  HyperCrownCoverageScalingData = If[HyperCrownBoundaryCoverageSummaries === {},
    Missing["NoObstructionBoundaryFound"],
    First[HyperCrownBoundaryCoverageSummaries]["CoverageScalingData"]
  ];
  HyperCrownOldScalingDiagnostic = Missing["Superseded", "Use HyperCrownBoundaryCoverageSummaries for the data-driven boundary scan."];,
  HyperCrownBoundaryCoverageSummaries = Missing["NotRun", "Set $HRFRunScalingDiagnostics=True before loading the example"];
  HyperCrownCoverageScalingData = Missing["NotRun", "Set $HRFRunScalingDiagnostics=True before loading the example"];
  HyperCrownOldScalingDiagnostic = Missing["NotRun", "Set $HRFRunScalingDiagnostics=True before loading the example"]
];

If[TrueQ[$HRFRunExample01ReportingOnLoad],
  HyperCrownRegionStudyTable = hrfHyperCrownRegionStudyTable[];
  HyperCrownChannelAttemptTable = hrfHyperCrownChannelAttemptTable[];,
  HyperCrownRegionStudyTable = Missing["NotRun", "Set $HRFRunExample01ReportingOnLoad=True before loading."];
  HyperCrownChannelAttemptTable = Missing["NotRun", "Set $HRFRunExample01ReportingOnLoad=True before loading."]
];


(* ---------------------------------------------------------------------- *)
(* Diving Beetle: boundary scan diagnostic                                  *)
(* ---------------------------------------------------------------------- *)

DBInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 7}}, {"0", {7, 4}}, {"0", {4, 9}},
  {"0", {9, 3}}, {"0", {3, 5}}, {"0", {2, 5}}, {"0", {2, 6}},
  {"0", {6, 8}}, {"0", {6, 4}}, {"0", {9, 8}}, {"0", {8, 7}}
};

DBExternalEdges = CrownExternalEdges;

DBData = makeFourPointOnShellF0[DBInternalEdges, DBExternalEdges];
F0DB = DBData["F0"];
VarsDB = DBData["Vars"];

If[TrueQ[$HRFRunDivingBeetleInteriorScanOnLoad],
  hrfExample01Say["Diving Beetle: running interior obstruction finder."];
  DBInteriorScan = hrfAttachBoundaryScanContext[
    findObstructions[
      F0DB, VarsDB, KinAssump4ptOnShell, KinVars4pt, 20,
      "GeneratorMode" -> "PairSectors",
      "UseExtendedFactors" -> True,
      "MaxGenerators" -> 2
    ],
    F0DB, VarsDB, {}
  ];,
  DBInteriorScan = Missing["NotRun", "Set $HRFRunDivingBeetleInteriorScanOnLoad=True before loading, or evaluate the Diving Beetle interior scan cell manually."]
];

If[TrueQ[$HRFRunDivingBeetleDiagnosticsOnLoad],
  hrfExample01Say["Diving Beetle: running optional interior generator diagnostic."];
  DBInteriorDiagnostic = obstructionGeneratorDiagnostic[
    F0DB, VarsDB, KinAssump4ptOnShell, KinVars4pt, 20, 2
  ];,
  DBInteriorDiagnostic = Missing["NotRun", "Set $HRFRunDivingBeetleDiagnosticsOnLoad=True before loading, or evaluate the Diving Beetle diagnostic cell manually."]
];

If[TrueQ[$HRFRunDBFullBoundaryScan],
  hrfExample01Say["Diving Beetle: running full boundary scan up to codimension 4 (all strata)."];
  DBBoundaryStrataExamined = Length[boundarySubsets[VarsDB, 4]];
  DBFullBoundaryScans = findObstructionsOnBoundaries4pt[
    F0DB, VarsDB, KinAssump4ptOnShell, KinVars4pt,
    4, 20, 2
  ];
  DBBoundaryOutcomeTable = hrfEx01BoundaryOutcomeTable[DBFullBoundaryScans];,
  DBFullBoundaryScans = Missing["NotRun", "Set $HRFRunDBFullBoundaryScan=True before loading."];
  DBBoundaryOutcomeTable = Missing["NotRun"]
];

If[TrueQ[$HRFRunDeepBoundaryScan],
  hrfExample01Say["Diving Beetle: running interesting-boundary scan up to codimension 4, obstruction size 20."];
  DBBoundaryStrataExamined = Length[boundarySubsets[VarsDB, 4]];
  InterestingBoundaryDBCodim4Size20 = scanInterestingBoundariesOnly4pt[
    F0DB, VarsDB, KinAssump4ptOnShell, KinVars4pt,
    4, 20, 2
  ];
  DBBoundarySummary = summarizeBoundaryScan4pt[InterestingBoundaryDBCodim4Size20];,
  If[! ValueQ[DBBoundaryStrataExamined],
    DBBoundaryStrataExamined = Missing["NotRun"]
  ];
  InterestingBoundaryDBCodim4Size20 = Missing["NotRun", "Set $HRFRunDeepBoundaryScan=True before loading the example, or run the deep-scan cells in the notebook."];
  DBBoundarySummary = {}
];

If[TrueQ[$HRFRunExample01ReportingOnLoad],
  DBRegionStudyTable = hrfDivingBeetleRegionStudyTable[];
  DBStudySummary = hrfDivingBeetleStudySummary[];
  DBFailureNarrative = hrfDivingBeetleFailureNarrative[];,
  DBRegionStudyTable = Missing["NotRun", "Set $HRFRunExample01ReportingOnLoad=True before loading."];
  DBStudySummary = Missing["NotRun"];
  DBFailureNarrative = Missing["NotRun"]
];

ClearAll[DBBoundaryGeneratorDiagnostic];
DBBoundaryGeneratorDiagnostic[zeroVars_List, maxSize_:20, maxGenerators_:2] := Module[
  {res, diag, trials, goodTrials},
  res = restrictPolynomialToBoundary[F0DB, VarsDB, zeroVars];
  If[res["FRestricted"] === 0 || Length[res["RemainingVars"]] == 0,
    Return[<|"ZeroVars" -> zeroVars, "Status" -> "Trivial boundary",
      "RemainingVars" -> res["RemainingVars"], "FRestricted" -> res["FRestricted"]|>]
  ];
  diag = obstructionGeneratorDiagnostic[res["FRestricted"], res["RemainingVars"],
    KinAssump4ptOnShell, KinVars4pt, maxSize, maxGenerators];
  trials = Lookup[diag, "Trials", {}];
  goodTrials = Select[trials,
    Module[{obs = Lookup[#, "ObstructionData", Missing[]]},
      AssociationQ[obs] && ! MatchQ[obs, _Missing]
    ] &
  ];
  <|
    "ZeroVars" -> zeroVars,
    "Status" -> If[goodTrials === {}, "No obstruction found for this boundary", "Obstruction candidate found"],
    "RemainingVars" -> res["RemainingVars"],
    "CancellationFactors" -> Lookup[diag, "SafeFactors", {}],
    "NumberOfGeneratorSetsTried" -> Length[trials],
    "GeneratorSetsTried" -> (Lookup[#, "Generators", {}] & /@ trials),
    "SuccessfulTrials" -> goodTrials
  |>
];

(* Compact inspection commands:
DBBoundarySummary[[All, {"Index", "ZeroVars", "Codimension", "CancellationFactors", "Generators", "Obstruction"}]]
hrfHyperCrownRegionStudyTable[]
hrfDivingBeetleRegionStudyTable[]
hrfDivingBeetleFailureNarrative[]
*)





(* Compact coverage-scaling test object for this 2 -> 2 file. *)
CoverageScalingTests2to2OffShell = <|
  "CrownInterior" -> CrownCoverageScalingData,
  "CrownInteriorOldDiagnostic" -> CrownOldScalingDiagnostic,
  "HyperCrownBoundary" -> HyperCrownCoverageScalingData,
  "HyperCrownBoundaryOldDiagnostic" -> HyperCrownOldScalingDiagnostic
|>;
