(* HRF_FivePointReporting.wl
   Reporting helpers for 03_FivePoint_Spacelike_Collinear.wl, aligned with the
   Example 01 reporting conventions where they apply to five-point data.

   Five-point collinear kinematics uses three independent variables {s, x, z},
   so the two-channel crossed-basis obstruction search from Example 01 is not
   invoked automatically.  These helpers still use the same obstruction-record
   and hidden-region conventions:
     - use Complement when Superleading is zero after reduction;
     - interior exact reduction by admissible generators counts as a hidden region;
     - boundary hidden regions require accepted coverage scaling.
*)

ClearAll[
  hrfFPCompact, hrfFPFactorOrDash, hrfFPAssocOrEmpty, hrfFPMissingDash,
  hrfFPScalingVectorDisplay, hrfFPVariableScalingDisplay, hrfFPWeightDisplay,
  hrfFPScalingCoverageFields, hrfFPObstructionData, hrfFPEffectiveSuperleadingSector,
  hrfFPEffectiveSuperleadingSource, hrfFPObstructionFoundQ, hrfFPExactReductionQ,
  hrfFPCoverageFoundQ, hrfFPSelectedDiagnostic, hrfFPWeight, hrfFPHasGeneratorsQ,
  hrfFPAdmissibleGeneratorSetQ, hrfFPChannelBasis, hrfFPGeneratorUseRemainder,
  hrfFPHiddenRegionQ, hrfFPRegionScalingSummaryRow, hrfFPRegionScalingSummaryTable,
  hrfFPScalingCoverageSummaryRow, hrfFPScalingCoverageSummaryTable,
  hrfFPScalingCoverageRowFromScalingData, hrfFPScalingCoverageTableFromScalingData,
  hrfFPScanSummaryRow, hrfFPScanSummaryTable, hrfFPObstructionRegionPresentQ,
  hrfFPGraphDrawingLookup, hrfFPFindScalingDataRow, hrfFPVariableScalingAssociation,
  hrfFPScalingLegendGrid,   hrfFPScalingStudyPanel, hrfFPScalingStudyPanels,
  hrfFPRegionScalingStudyPanels, hrfFPScalingStudyPanelMatch,
  hrfFPToRows, hrfFPSelectColumns, hrfFPHiddenRegionDisplayColumns,
  hrfFPRegionScalingDisplayColumns, hrfFPScalingCoverageDisplayColumns,
  hrfFPDisplayTable, hrfFPHiddenRegionDisplay, hrfFPRegionScalingDisplay,
  hrfFPScalingCoverageDisplay
];

hrfFPAssocOrEmpty[x_] := If[AssociationQ[x], x, <||>];

hrfFPCompact[x_] := Which[
  x === "--", "--",
  MatchQ[x, _Missing] || x === {} || x === Null, "--",
  ListQ[x], ToString[InputForm[x]],
  AssociationQ[x], ToString[InputForm[Normal[x]]],
  True, ToString[InputForm[x]]
];

hrfFPFactorOrDash[x_] := hrfFPCompact[If[MatchQ[x, _Missing] || x === 0, "--", x]];

hrfFPMissingDash[x_] := If[MatchQ[x, _Missing] || x === Null, "--", x];

hrfFPScalingVectorDisplay[scaling_] := Which[
  ListQ[scaling], ToString[InputForm[scaling]],
  AssociationQ[scaling], ToString[InputForm[Values[scaling]]],
  True, "--"
];

hrfFPVariableScalingDisplay[diag_] := Module[{vs},
  vs = Lookup[diag, "VariableScaling", Missing["NotAvailable"]];
  Which[
    AssociationQ[vs], ToString[InputForm[Normal[vs]]],
    ListQ[vs], ToString[InputForm[vs]],
    MatchQ[vs, _Missing], "--",
    True, hrfFPCompact[vs]
  ]
];

hrfFPWeightDisplay[diag_, preferred_, fallback_] :=
  hrfFPMissingDash[hrfFPWeight[diag, preferred, fallback]];

hrfFPScalingCoverageFields[d_, diag_] := Module[{scalingRaw},
  scalingRaw = If[AssociationQ[d], Lookup[d, "Scaling", Missing["NoScaling"]], Missing["NoScalingData"]];
  <|
    "Scaling" -> hrfFPScalingVectorDisplay[scalingRaw],
    "VariableScaling" -> hrfFPVariableScalingDisplay[diag],
    "W_SL" -> hrfFPWeightDisplay[diag, "FSLWeight", "WSL"],
    "W_HR" -> hrfFPWeightDisplay[diag, "PostCancellationLeadingWeight", "WHR"],
    "Gap" -> hrfFPWeightDisplay[diag, "HierarchyGapPostLPminusFSL", "GapWHRminusWSL"],
    "VarsAtWSL" -> hrfFPCompact[Lookup[diag, "VariablesCoveredByFSLAtWSL", "--"]],
    "VarsAtWHR" -> hrfFPCompact[Lookup[diag, "VariablesInPostCancellationLeadingSupport", "--"]],
    "VarsMissingFromCoverage" -> hrfFPCompact[Lookup[diag, "VariablesMissingFromLeadingRegionCoverage", "--"]]
  |>
];

hrfFPObstructionData[scan_] := hrfFPAssocOrEmpty[
  If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing["NoScan"]], Missing["NoScan"]]
];

hrfFPEffectiveSuperleadingSector[scan_] := Module[{od, sl, comp},
  od = hrfFPObstructionData[scan];
  If[! AssociationQ[od], Return[Missing["NoObstructionData"]]];
  sl = Lookup[od, "Superleading", Missing["NoSuperleading"]];
  comp = Lookup[od, "Complement", Missing["NoComplement"]];
  Which[
    ! MatchQ[comp, _Missing] && ! TrueQ[Expand[comp] === 0], comp,
    ! MatchQ[sl, _Missing], sl,
    True, Missing["NoSuperleadingSector"]
  ]
];

hrfFPEffectiveSuperleadingSource[scan_] := Module[{od, sl, comp},
  od = hrfFPObstructionData[scan];
  If[! AssociationQ[od], Return[Missing["NoObstructionData"]]];
  sl = Lookup[od, "Superleading", Missing["NoSuperleading"]];
  comp = Lookup[od, "Complement", Missing["NoComplement"]];
  Which[
    ! MatchQ[comp, _Missing] && ! TrueQ[Expand[comp] === 0], "Complement/unreduced superleading sector",
    ! MatchQ[sl, _Missing], "Superleading/remainder sector",
    True, Missing["NoSuperleadingSector"]
  ]
];

hrfFPObstructionFoundQ[scan_] := Module[{od},
  od = hrfFPObstructionData[scan];
  AssociationQ[od] && (KeyExistsQ[od, "Superleading"] || KeyExistsQ[od, "Complement"])
];

hrfFPExactReductionQ[scan_] := Module[{od, sl},
  od = hrfFPObstructionData[scan];
  If[!(AssociationQ[od] && KeyExistsQ[od, "Superleading"]), Return[False]];
  TrueQ[Expand[od["Superleading"]] === 0]
];

hrfFPCoverageFoundQ[scaling_] :=
  AssociationQ[scaling] && ListQ[Lookup[scaling, "Scaling", Missing[]]];

hrfFPSelectedDiagnostic[scaling_] := Module[{d},
  d = If[AssociationQ[scaling], scaling, <||>];
  Which[
    AssociationQ[Lookup[d, "SelectedCandidateDiagnostic", Missing[]]], d["SelectedCandidateDiagnostic"],
    AssociationQ[Lookup[d, "Diagnostics", Missing[]]], d["Diagnostics"],
    True, <||>
  ]
];

hrfFPWeight[diag_, preferred_, fallback_] :=
  Lookup[diag, preferred, Lookup[diag, fallback, Missing["NotAvailable"]]];

hrfFPHasGeneratorsQ[scan_] := Module[{gens},
  gens = If[AssociationQ[scan], Lookup[scan, "Generators", {}], {}];
  ListQ[gens] && Length[gens] > 0
];

hrfFPAdmissibleGeneratorSetQ[scan_] :=
  TrueQ[Lookup[If[AssociationQ[scan], scan, <||>], "AdmissibleGeneratorSetQ", False]];

hrfFPChannelBasis[scan_] := Module[{attempt},
  attempt = hrfFPAssocOrEmpty[
    If[AssociationQ[scan], Lookup[scan, "ObstructionAttemptData", <||>], <||>]
  ];
  Lookup[attempt, "ChannelBasis", Missing["NotRecorded"]]
];

hrfFPGeneratorUseRemainder[scan_] := Module[{use},
  use = hrfFPAssocOrEmpty[
    If[AssociationQ[scan], Lookup[scan, "GeneratorUseData", <||>], <||>]
  ];
  Lookup[use, "Remainder", Missing["NotAvailable"]]
];

hrfFPHiddenRegionQ[scan_, scaling_, regionType_] := Module[
  {isInteriorQ, exactQ, rem, sc = hrfFPAssocOrEmpty[scaling]},
  isInteriorQ = regionType === "Interior";
  exactQ = hrfFPExactReductionQ[scan];
  rem = hrfFPGeneratorUseRemainder[scan];
  hrfFPObstructionFoundQ[scan] && hrfFPAdmissibleGeneratorSetQ[scan] && hrfFPHasGeneratorsQ[scan] &&
    If[isInteriorQ,
      hrfFPCoverageFoundQ[sc] || exactQ || TrueQ[Expand[rem] === 0],
      hrfFPCoverageFoundQ[sc]
    ]
];

hrfFPObstructionRegionPresentQ[scan_] := Module[{fsl},
  If[! hrfFPObstructionFoundQ[scan], Return[False]];
  fsl = hrfFPEffectiveSuperleadingSector[scan];
  ! MatchQ[fsl, _Missing] && ! TrueQ[Expand[fsl] === 0]
];

hrfFPRegionScalingSummaryRow[row_Association, regionType_, scan_:Automatic] := Module[
  {d, diag, sc, effectiveScan, hiddenQ, exactQ, fsl, fslSource, comment, coverage},
  effectiveScan = Which[
    AssociationQ[scan], scan,
    True, hrfFPAssocOrEmpty[Lookup[row, "ObstructionScan", <||>]]
  ];
  d = hrfFPAssocOrEmpty[Lookup[row, "CoverageLPScalingData", <||>]];
  diag = hrfFPSelectedDiagnostic[d];
  sc = d;
  coverage = hrfFPScalingCoverageFields[d, diag];
  fsl = Lookup[row, "FSL", hrfFPEffectiveSuperleadingSector[effectiveScan]];
  fslSource = Lookup[row, "SuperleadingSectorSource", hrfFPEffectiveSuperleadingSource[effectiveScan]];
  exactQ = hrfFPExactReductionQ[effectiveScan];
  hiddenQ = hrfFPHiddenRegionQ[effectiveScan, sc, regionType];
  comment = Which[
    hiddenQ && hrfFPCoverageFoundQ[sc] && TrueQ[Lookup[sc, "UniqueAcceptedScalingQ", False]], "unique accepted scaling found",
    hiddenQ && hrfFPCoverageFoundQ[sc], "accepted scaling found; inspect diagnostics for possible non-uniqueness",
    hiddenQ && regionType === "Interior" && exactQ, "interior exact reduction by admissible generators",
    ! hrfFPObstructionFoundQ[effectiveScan], "no obstruction record produced by the obstruction scan",
    ! hrfFPHasGeneratorsQ[effectiveScan], "no generators reported by the obstruction scan",
    ! hrfFPAdmissibleGeneratorSetQ[effectiveScan], "no admissible generator set survived the scan",
    regionType === "Boundary" && ! hrfFPCoverageFoundQ[sc], "boundary scan found no accepted coverage scaling",
    ! hrfFPCoverageFoundQ[sc], "no accepted coverage scaling in this test",
    True, "not available"
  ];
  Join[<|
    "Topology" -> Lookup[row, "TopologyName", Missing["NoTopology"]],
    "TopologyTeX" -> Lookup[row, "TopologyTeX", Missing["NoTopologyTeX"]],
    "GraphIndex" -> Lookup[row, "GraphIndex", Missing["NoGraphIndex"]],
    "RegionType" -> regionType,
    "ZeroVars" -> Lookup[row, "ZeroVars", If[regionType === "Interior", {}, Missing["NoZeroVars"]]],
    "HiddenRegionQ" -> hiddenQ,
    "AcceptedScalingQ" -> hrfFPCoverageFoundQ[sc],
    "Scaling" -> coverage["Scaling"],
    "VariableScaling" -> coverage["VariableScaling"],
    "W_SL" -> coverage["W_SL"],
    "W_HR" -> coverage["W_HR"],
    "Gap" -> coverage["Gap"],
    "VarsAtWSL" -> coverage["VarsAtWSL"],
    "VarsAtWHR" -> coverage["VarsAtWHR"],
    "VarsMissingFromCoverage" -> coverage["VarsMissingFromCoverage"],
    "AcceptedScalingCount" -> If[AssociationQ[d], Lookup[d, "AcceptedCount", 0], 0],
    "CandidateCount" -> If[AssociationQ[d], Lookup[d, "CandidateCount", 0], 0],
    "ActiveVars" -> Lookup[row, "RemainingVars", Missing["NoActiveVars"]],
    "Generators" -> hrfFPCompact[
      If[AssociationQ[effectiveScan],
        Lookup[effectiveScan, "Generators", Lookup[row, "Generators", {}]],
        Lookup[row, "Generators", {}]
      ]
    ],
    "GeneratorSetAdmissibleQ" -> hrfFPAdmissibleGeneratorSetQ[effectiveScan],
    "SuperleadingSector" -> hrfFPFactorOrDash[fsl],
    "Comment" -> comment,
    (* Backward-compatible keys used by older notebooks/exports. *)
    "ScalingVector" -> coverage["Scaling"],
    "WSL" -> coverage["W_SL"],
    "WHR" -> coverage["W_HR"],
    "GapWHRminusWSL" -> coverage["Gap"],
    "CoveredByFSLAtWSL" -> coverage["VarsAtWSL"],
    "CoveredAtWHR" -> coverage["VarsAtWHR"],
    "MissingVars" -> coverage["VarsMissingFromCoverage"],
    "UniqueAcceptedScalingQ" -> If[AssociationQ[d], Lookup[d, "UniqueAcceptedScalingQ", False], False],
    "ChannelBasis" -> hrfFPCompact[hrfFPChannelBasis[effectiveScan]],
    "SuperleadingSectorSource" -> hrfFPCompact[fslSource]
  |>]
];

hrfFPRegionScalingSummaryTable[interiorRows_, boundaryRows_, interiorScans_:{}] := Join[
  Table[
    hrfFPRegionScalingSummaryRow[
      interiorRows[[i]], "Interior",
      If[ListQ[interiorScans] && i <= Length[interiorScans], interiorScans[[i]], Automatic]
    ],
    {i, Length[interiorRows]}
  ],
  hrfFPRegionScalingSummaryRow[#, "Boundary", Lookup[#, "ObstructionScan", Automatic]] & /@ boundaryRows
];

hrfFPScalingCoverageSummaryRow[row_Association] := Module[{d, diag, fields},
  d = hrfFPAssocOrEmpty[Lookup[row, "CoverageLPScalingData", <||>]];
  fields = If[AssociationQ[row] && KeyExistsQ[row, "Scaling"],
    <|
      "Scaling" -> Lookup[row, "Scaling", "--"],
      "VariableScaling" -> Lookup[row, "VariableScaling", "--"],
      "W_SL" -> Lookup[row, "W_SL", "--"],
      "W_HR" -> Lookup[row, "W_HR", "--"],
      "Gap" -> Lookup[row, "Gap", "--"],
      "VarsAtWSL" -> Lookup[row, "VarsAtWSL", Lookup[row, "CoveredByFSLAtWSL", "--"]],
      "VarsAtWHR" -> Lookup[row, "VarsAtWHR", Lookup[row, "CoveredAtWHR", "--"]],
      "VarsMissingFromCoverage" -> Lookup[row, "VarsMissingFromCoverage", Lookup[row, "MissingVars", "--"]]
    |>,
    hrfFPScalingCoverageFields[d, hrfFPSelectedDiagnostic[d]]
  ];
  Join[<|
    "TopologyTeX" -> Lookup[row, "TopologyTeX", "--"],
    "GraphIndex" -> Lookup[row, "GraphIndex", "--"],
    "RegionType" -> Lookup[row, "RegionType", "--"],
    "ZeroVars" -> hrfFPCompact[Lookup[row, "ZeroVars", {}]],
    "ActiveVars" -> hrfFPCompact[Lookup[row, "ActiveVars", Lookup[row, "RemainingVars", "--"]]],
    "HiddenRegionQ" -> Lookup[row, "HiddenRegionQ", False],
    "AcceptedScalingQ" -> Lookup[row, "AcceptedScalingQ", hrfFPCoverageFoundQ[d]],
    "Comment" -> Lookup[row, "Comment", "--"]
  |>, fields]
];

hrfFPScalingCoverageSummaryTable[rows_] := hrfFPScalingCoverageSummaryRow /@ rows;

hrfFPScalingCoverageRowFromScalingData[row_Association] := Module[{d, diag, zv, fields, regionType, scan},
  d = hrfFPAssocOrEmpty[Lookup[row, "CoverageLPScalingData", <||>]];
  diag = hrfFPSelectedDiagnostic[d];
  fields = hrfFPScalingCoverageFields[d, diag];
  zv = Lookup[row, "ZeroVars", {}];
  regionType = If[zv === {}, "Interior", "Boundary"];
  scan = hrfFPAssocOrEmpty[Lookup[row, "ObstructionScan", <||>]];
  Join[<|
    "TopologyTeX" -> Lookup[row, "TopologyTeX", "--"],
    "GraphIndex" -> Lookup[row, "GraphIndex", "--"],
    "RegionType" -> regionType,
    "ZeroVars" -> hrfFPCompact[zv],
    "ActiveVars" -> hrfFPCompact[Lookup[row, "RemainingVars", {}]],
    "HiddenRegionQ" -> hrfFPHiddenRegionQ[scan, d, regionType],
    "AcceptedScalingQ" -> hrfFPCoverageFoundQ[d],
    "ScalingStatus" -> Which[
      hrfFPCoverageFoundQ[d], "accepted scaling found",
      ! AssociationQ[Lookup[row, "CoverageLPScalingData", Missing[]]] || MatchQ[Lookup[row, "CoverageLPScalingData", Missing[]], _Missing],
        ToString[Lookup[row, "CoverageLPScalingData", "not computed"]],
      True, "no accepted scaling in scan up to maxAbs=5"
    ]
  |>, fields]
];

hrfFPScalingCoverageTableFromScalingData[interiorRows_, boundaryRows_] := Join[
  hrfFPScalingCoverageRowFromScalingData /@ interiorRows,
  hrfFPScalingCoverageRowFromScalingData /@ boundaryRows
];

hrfFPScanSummaryRow[graphIndex_, topologyName_, topologyTeX_, zeroVars_, remainingVars_, scan_] := Module[
  {od, fsl, fslSource},
  od = hrfFPObstructionData[scan];
  fsl = hrfFPEffectiveSuperleadingSector[scan];
  fslSource = hrfFPEffectiveSuperleadingSource[scan];
  <|
    "GraphIndex" -> graphIndex,
    "Topology" -> topologyName,
    "TopologyTeX" -> topologyTeX,
    "RegionType" -> If[zeroVars === {}, "Interior", "Boundary"],
    "ZeroVars" -> hrfFPCompact[zeroVars],
    "ActiveVars" -> hrfFPCompact[remainingVars],
    "Generators" -> hrfFPCompact[Lookup[scan, "Generators", {}]],
    "GeneratorSetAdmissibleQ" -> hrfFPAdmissibleGeneratorSetQ[scan],
    "ChannelBasis" -> hrfFPCompact[hrfFPChannelBasis[scan]],
    "SuperleadingSector" -> hrfFPFactorOrDash[fsl],
    "SuperleadingSectorSource" -> hrfFPCompact[fslSource],
    "Obstruction" -> hrfFPFactorOrDash[Lookup[od, "Obstruction", Missing["Absent"]]],
    "ReductionRemainder" -> hrfFPFactorOrDash[Lookup[od, "Superleading", Missing["Absent"]]],
    "ObstructionFoundQ" -> hrfFPObstructionRegionPresentQ[scan]
  |>
];

hrfFPScanSummaryTable[collinearData_] := Table[
  hrfFPScanSummaryRow[
    collinearData[[i, "GraphIndex"]],
    collinearData[[i, "TopologyName"]],
    collinearData[[i, "TopologyTeX"]],
    {},
    collinearData[[i, "Variables"]],
    collinearData[[i, "InteriorObstructionScan"]]
  ],
  {i, Length[collinearData]}
];

(* Diagram + scaling study panels.  Internal edge i in drawGraphFromPySecDecInput
   is labelled x(i-1), matching SymanzikUF Variables and scaling-vector components. *)

hrfFPGraphDrawingLookup[graphDrawings_, graphIndex_] := Module[{row},
  row = FirstCase[graphDrawings, r_ /; Lookup[r, "GraphIndex", -1] === graphIndex, <||>];
  Lookup[row, "Graph", Missing["NoGraphDrawing", graphIndex]]
];

hrfFPFindScalingDataRow[interiorRows_, boundaryRows_, summaryRow_Association] := Module[
  {gi, zv, rt},
  gi = Lookup[summaryRow, "GraphIndex", Missing["NoGraphIndex"]];
  zv = Lookup[summaryRow, "ZeroVars", {}];
  rt = Lookup[summaryRow, "RegionType", "Interior"];
  Which[
    ! IntegerQ[gi], <||>,
    rt === "Interior",
      FirstCase[interiorRows, r_ /; Lookup[r, "GraphIndex", -1] === gi, <||>],
    True,
      FirstCase[boundaryRows,
        r_ /; Lookup[r, "GraphIndex", -1] === gi && Lookup[r, "ZeroVars", {}] === zv,
        <||>
      ]
  ]
];

hrfFPVariableScalingAssociation[row_Association] := Module[{d, diag, vs},
  d = hrfFPAssocOrEmpty[Lookup[row, "CoverageLPScalingData", <||>]];
  diag = hrfFPSelectedDiagnostic[d];
  vs = Lookup[diag, "VariableScaling", Missing["NotAvailable"]];
  Which[
    AssociationQ[vs], vs,
    ListQ[vs] && Length[vs] > 0,
      AssociationThread[Lookup[row, "RemainingVars", {}], vs],
    True, <||>
  ]
];

hrfFPScalingLegendGrid[activeVars_, scalingAssoc_Association] := If[
  ! ListQ[activeVars] || activeVars === {},
  Style["No active Lee--Pomeransky parameters.", Gray],
  Grid[
    Prepend[
      Table[
        {ToString[InputForm[v]], Lookup[scalingAssoc, v, "--"]},
        {v, activeVars}
      ],
      {Style["LP parameter", Bold], Style["scaling exponent", Bold]}
    ],
    Alignment -> Left,
    Dividers -> {False, {False, True, False}},
    Spacings -> {1, 0.4}
  ]
];

hrfFPScalingStudyPanel[summaryRow_Association, graphDrawings_, scalingDataRow_Association] := Module[
  {gi, graph, zv, activeVars, scalingAssoc, title},
  gi = Lookup[summaryRow, "GraphIndex", Missing["NoGraphIndex"]];
  graph = hrfFPGraphDrawingLookup[graphDrawings, gi];
  zv = Lookup[summaryRow, "ZeroVars", {}];
  activeVars = Lookup[summaryRow, "ActiveVars",
    Lookup[scalingDataRow, "RemainingVars", Missing["NoActiveVars"]]
  ];
  If[! ListQ[activeVars], activeVars = {}];
  scalingAssoc = hrfFPVariableScalingAssociation[scalingDataRow];
  title = Lookup[summaryRow, "TopologyTeX", Lookup[summaryRow, "Topology", ""]];
  Column[
    {
      Style[title, 16, Bold],
      If[MatchQ[graph, _Missing], Style["No diagram available.", Gray], graph],
      Grid[
        {
          {"GraphIndex", gi},
          {"RegionType", Lookup[summaryRow, "RegionType", "--"]},
          {"ZeroVars (boundary)", hrfFPCompact[zv]},
          {"ActiveVars", hrfFPCompact[activeVars]},
          {"HiddenRegionQ", Lookup[summaryRow, "HiddenRegionQ", False]},
          {"AcceptedScalingQ", Lookup[summaryRow, "AcceptedScalingQ", False]},
          {"Scaling", Lookup[summaryRow, "Scaling", "--"]},
          {"W_SL", Lookup[summaryRow, "W_SL", "--"]},
          {"W_HR", Lookup[summaryRow, "W_HR", "--"]},
          {"Gap", Lookup[summaryRow, "Gap", Lookup[summaryRow, "GapWHRminusWSL", "--"]]},
          {"VarsAtWSL", Lookup[summaryRow, "VarsAtWSL", "--"]},
          {"VarsAtWHR", Lookup[summaryRow, "VarsAtWHR", "--"]},
          {"Comment", Lookup[summaryRow, "Comment", "--"]}
        },
        Alignment -> Left
      ],
      Style["Scaling exponents by propagator label (x_i on diagram):", Bold],
      hrfFPScalingLegendGrid[activeVars, scalingAssoc],
      Style[
        "Internal edge labels x0,x1,... match drawGraphFromPySecDecInput and the scaling vector order.",
        Small, Gray
      ]
    },
    Spacings -> 1.2,
    Dividers -> {None, {None, True}}
  ]
];

hrfFPScalingStudyPanel[summaryRow_Association, graphDrawings_] :=
  hrfFPScalingStudyPanel[summaryRow, graphDrawings, <||>];

hrfFPScalingStudyPanels[summaryRows_, graphDrawings_, interiorRows_, boundaryRows_] :=
  Table[
    hrfFPScalingStudyPanel[
      summaryRows[[i]], graphDrawings,
      hrfFPFindScalingDataRow[interiorRows, boundaryRows, summaryRows[[i]]]
    ],
    {i, Length[summaryRows]}
  ];

hrfFPRegionScalingStudyPanels[
  summaryRows_, graphDrawings_, interiorScalingRows_, boundaryScalingRows_
] := hrfFPScalingStudyPanels[summaryRows, graphDrawings, interiorScalingRows, boundaryScalingRows];

hrfFPScalingStudyPanelMatch[
  summaryRows_, graphDrawings_, interiorScalingRows_, boundaryScalingRows_,
  graphIndex_Integer, zeroVars_:{}
] := Module[{row},
  row = FirstCase[
    summaryRows,
    r_ /; Lookup[r, "GraphIndex", -1] === graphIndex && Lookup[r, "ZeroVars", {}] === zeroVars,
    Missing["NoMatchingSummaryRow", graphIndex, zeroVars]
  ];
  If[MatchQ[row, _Missing],
    row,
    hrfFPScalingStudyPanel[
      row, graphDrawings,
      hrfFPFindScalingDataRow[interiorScalingRows, boundaryScalingRows, row]
    ]
  ]
];

hrfFPToRows[data_] := Which[
  Head[data] === Dataset, Normal[data],
  ListQ[data], data,
  True, {}
];

hrfFPSelectColumns[row_Association, cols_List] :=
  KeyTake[row, Intersection[cols, Keys[row]]];

hrfFPHiddenRegionDisplayColumns[] := {
  "TopologyTeX", "RegionType", "ZeroVars", "HiddenRegionQ",
  "GeneratorSetAdmissibleQ", "Generators", "W_SL", "W_HR", "Comment"
};

hrfFPRegionScalingDisplayColumns[] := {
  "TopologyTeX", "RegionType", "ZeroVars", "HiddenRegionQ", "AcceptedScalingQ",
  "W_SL", "W_HR", "Gap", "Generators", "Comment"
};

hrfFPScalingCoverageDisplayColumns[] := {
  "TopologyTeX", "RegionType", "HiddenRegionQ", "AcceptedScalingQ",
  "Scaling", "W_SL", "W_HR", "Gap", "VarsAtWSL", "VarsAtWHR"
};

hrfFPDisplayTable[data_, cols_List] := Module[{rows},
  rows = hrfFPToRows[data];
  If[rows === {}, Dataset[{}], Dataset @ (hrfFPSelectColumns[#, cols] & /@ rows)]
];

hrfFPHiddenRegionDisplay[data_] := hrfFPDisplayTable[data, hrfFPHiddenRegionDisplayColumns[]];
hrfFPRegionScalingDisplay[data_] := hrfFPDisplayTable[data, hrfFPRegionScalingDisplayColumns[]];
hrfFPScalingCoverageDisplay[data_] := hrfFPDisplayTable[data, hrfFPScalingCoverageDisplayColumns[]];

If[! TrueQ[$HRFQuietReports], Print["[loaded] five-point reporting helpers."]];
