(* ::Package:: *)
(* Scan the 70 recursively preselected five-point topologies with the current
   polynomial HRF algorithm.

   Default run: interior only, all handoff rows.

   Useful controls before Get["HRF_RunPreselected5ptScan.wl"]:
     $HRFPreselectedScanMaxRows = 5;
     $HRFPreselectedScanRowRange = {1, 16};
     $HRFPreselectedRunBoundaryQ = True;
     $HRFPreselectedBoundaryMaxCodim = 1;
*)

SetDirectory[DirectoryName[$InputFileName]];

If[! ValueQ[$HRFPreselectedScanMaxRows], $HRFPreselectedScanMaxRows = All];
If[! ValueQ[$HRFPreselectedScanRowRange], $HRFPreselectedScanRowRange = All];
If[! ValueQ[$HRFPreselectedRunInteriorQ], $HRFPreselectedRunInteriorQ = True];
If[! ValueQ[$HRFPreselectedRunBoundaryQ], $HRFPreselectedRunBoundaryQ = False];
If[! ValueQ[$HRFPreselectedBoundaryMaxCodim], $HRFPreselectedBoundaryMaxCodim = 1];
If[! ValueQ[$HRFPreselectedMaxScalingAbs], $HRFPreselectedMaxScalingAbs = 5];
If[! ValueQ[$HRFPreselectedOutputPrefix], $HRFPreselectedOutputPrefix = "Preselected5ptHRFScan"];
If[! ValueQ[$HRFPreselectedStoreDetailedRowsQ], $HRFPreselectedStoreDetailedRowsQ = True];

$HRFQuietReports = If[ValueQ[$HRFQuietReports], $HRFQuietReports, False];
$HRFExampleVerbose = False;
$HRFDebugTiming = False;
$HRFScalingReport = If[ValueQ[$HRFScalingReport], $HRFScalingReport, True];
$HRFVerboseScaling = False;
$HRFFindObstructionsStopOnFirstAdmissibleQ = False;
$HRFFindObstructionsStoreAllTrialsQ = True;
$HRFPolynomialRequireKinematicDomainQ = False;

Get["HiddenRegionFinder.wl"];
Get["HRF_KinematicGeneratorPresets.wl"];
Get["HRF_PolynomialCancellationFactors.wl"];
hrfInstallPolynomialCancellationPatch[];
Get["HRF_Example03CollinearCore.wl"];

ClearAll[
  hrfPreselectedRows, hrfPreselectedSelectRows, hrfPreselectedFindOptions,
  hrfPreselectedTopologyName, hrfPreselectedBuildData, hrfPreselectedScanObstruction,
  hrfPreselectedScalingForScan, hrfPreselectedBoundarySubsets,
  hrfPreselectedScanInteriorRow, hrfPreselectedScanBoundaryRows,
  hrfPreselectedFactorClass, hrfPreselectedFactorSummary, hrfPreselectedScalingSummary,
  hrfPreselectedSummaryRow, hrfPreselectedCountsBy, hrfPreselectedCSVString, hrfPreselectedCSVTable,
  hrfPreselectedWriteCSV
];

hrfPreselectedRows[] := Get["RecursiveDerivativePreselectionHandoff.wl"];

hrfPreselectedSelectRows[rows_List] := Module[{selected = rows, range, max},
  range = $HRFPreselectedScanRowRange;
  If[ListQ[range] && Length[range] == 2,
    selected = Take[rows, {Max[1, range[[1]]], Min[Length[rows], range[[2]]]}]
  ];
  max = $HRFPreselectedScanMaxRows;
  If[IntegerQ[max] && max > 0, selected = Take[selected, UpTo[max]]];
  selected
];

hrfPreselectedFindOptions[] := Join[
  hrfKinematicLimitObstructionOptions["Collinear5pt"],
  {
    "UseExtendedFactors" -> False,
    "DimensionfulKinVars" -> CollinearDimensionfulKinVars
  }
];

hrfPreselectedTopologyName[row_Association, scanIndex_Integer] := Module[{ex03},
  ex03 = Lookup[row, "Example03Topology", ""];
  If[StringQ[ex03] && ex03 =!= "",
    ex03,
    ToString[Lookup[row, "Family", "row"]] <> ":" <> ToString[Lookup[row, "DiagramIndex", scanIndex]]
  ]
];

hrfPreselectedBuildData[row_Association, scanIndex_Integer] := Module[
  {uf, f, fcol, f0, name},
  uf = SymanzikUF[row["InternalLines"], row["ExternalLines"]];
  f = toCyclicMandelstams[uf["F"]];
  fcol = Expand[f /. collPar1];
  f0 = hrfEx03LeadingDeltaPolynomial[fcol];
  name = hrfPreselectedTopologyName[row, scanIndex];
  Join[row, <|
    "ScanIndex" -> scanIndex,
    "TopologyName" -> name,
    "U" -> uf["U"],
    "F" -> f,
    "FCollinear" -> fcol,
    "Flead" -> f0,
    "Variables" -> uf["Variables"]
  |>]
];

hrfPreselectedScanObstruction[F_, vars_, U_] :=
  findObstructions[
    F, vars, KinAssump, KinVars, Automatic,
    Sequence @@ hrfPreselectedFindOptions[],
    "U" -> U,
    "MaxScalingAbs" -> $HRFPreselectedMaxScalingAbs,
    "RequireValidScalingForHiddenRegionQ" -> True,
    "EnumerateHiddenRegionsQ" -> True
  ];

hrfPreselectedScalingForScan[scan_, U_, vars_] := Module[
  {builtInScaling, obsData, obstruction, fsl},
  If[! AssociationQ[scan] || ! AssociationQ[Lookup[scan, "ObstructionData", <||>]],
    builtInScaling = If[AssociationQ[scan], Lookup[scan, "CoverageScalingData", Missing["NoCoverageData"]], Missing["NoScan"]];
    Return[builtInScaling]
  ];
  builtInScaling = Lookup[scan, "CoverageScalingData", Missing["NotEvaluated"]];
  If[AssociationQ[builtInScaling] || ! MatchQ[builtInScaling, Missing["NotEvaluated"]],
    Return[builtInScaling]
  ];
  obsData = scan["ObstructionData"];
  obstruction = obsData["Obstruction"];
  fsl = hrfFPEffectiveSuperleadingSector[scan];
  If[MatchQ[fsl, _Missing] || TrueQ[Expand[fsl] === 0],
    Missing["NoNonzeroSuperleadingSector"],
    findCoverageLPScaling[fsl, U, vars, $HRFPreselectedMaxScalingAbs, obstruction]
  ]
];

hrfPreselectedBoundarySubsets[vars_List] := Flatten[
  Table[Subsets[vars, {k}], {k, 1, $HRFPreselectedBoundaryMaxCodim}],
  1
];

hrfPreselectedScanInteriorRow[data_Association] := Module[{scan, scaling},
  scan = hrfPreselectedScanObstruction[data["Flead"], data["Variables"], data["U"]];
  scaling = hrfPreselectedScalingForScan[scan, data["U"], data["Variables"]];
  Join[data, <|
    "RegionType" -> "Interior",
    "ZeroVars" -> {},
    "RemainingVars" -> data["Variables"],
    "ObstructionScan" -> scan,
    "CoverageLPScalingData" -> scaling
  |>]
];

hrfPreselectedScanBoundaryRows[data_Association] := Module[
  {strata, rows = {}, zeroVars, remainingVars, fRestricted, uRestricted, scan, scaling},
  strata = hrfPreselectedBoundarySubsets[data["Variables"]];
  Do[
    zeroVars = strata[[i]];
    remainingVars = Complement[data["Variables"], zeroVars];
    fRestricted = Expand[data["Flead"] /. Thread[zeroVars -> 0]];
    uRestricted = Expand[data["U"] /. Thread[zeroVars -> 0]];
    scan = If[fRestricted === 0 || remainingVars === {},
      <||>,
      hrfPreselectedScanObstruction[fRestricted, remainingVars, uRestricted]
    ];
    scaling = hrfPreselectedScalingForScan[scan, uRestricted, remainingVars];
    AppendTo[rows, Join[data, <|
      "RegionType" -> "Boundary",
      "ZeroVars" -> zeroVars,
      "RemainingVars" -> remainingVars,
      "FRestricted" -> fRestricted,
      "URestricted" -> uRestricted,
      "ObstructionScan" -> scan,
      "CoverageLPScalingData" -> scaling
    |>]],
    {i, Length[strata]}
  ];
  rows
];

hrfPreselectedFactorClass[f_, vars_] := Module[{n},
  n = hrfPolynomialMonomialCount[f, vars];
  If[binomialQ[f, vars], "binomial", "polynomial-" <> ToString[n] <> "-term"]
];

hrfPreselectedFactorSummary[scan_, vars_] := Module[{factors, selected},
  factors = If[AssociationQ[scan], Lookup[scan, "CancellationFactors", {}], {}];
  selected = If[AssociationQ[scan], Lookup[scan, "SLSectorFactorUnion", {}], {}];
  <|
    "CancellationFactorCount" -> Length[factors],
    "CancellationFactorClassCounts" -> Counts[hrfPreselectedFactorClass[#, vars] & /@ factors],
    "PolynomialCancellationFactorQ" -> AnyTrue[factors, ! binomialQ[#, vars] &],
    "SLSectorFactorCount" -> Length[selected],
    "SLSectorFactorClassCounts" -> Counts[hrfPreselectedFactorClass[#, vars] & /@ selected],
    "SLSectorAllBinomialQ" -> (selected =!= {} && AllTrue[selected, binomialQ[#, vars] &]),
    "SLSectorPolynomialFactorQ" -> AnyTrue[selected, ! binomialQ[#, vars] &]
  |>
];

hrfPreselectedScalingSummary[scaling_] := If[AssociationQ[scaling],
  <|
    "AcceptedScalingQ" -> TrueQ[Lookup[scaling, "AcceptedCount", 0] > 0],
    "ScalingVector" -> Lookup[scaling, "Scaling", Missing["NoScaling"]],
    "AcceptedScalingCount" -> Lookup[scaling, "AcceptedCount", 0],
    "ScalingStatus" -> Lookup[scaling, "ScalingStatusMessage",
      Lookup[scaling, "ScalingStatus", "Scaling vector determined"]]
  |>,
  <|
    "AcceptedScalingQ" -> False,
    "ScalingVector" -> scaling,
    "AcceptedScalingCount" -> 0,
    "ScalingStatus" -> scaling
  |>
];

hrfPreselectedSummaryRow[row_Association] := Module[
  {scan, obsData, scaling, scaleSummary, vars},
  scan = Lookup[row, "ObstructionScan", <||>];
  obsData = If[AssociationQ[scan],
    Lookup[scan, "ObstructionData", Missing["NoObstructionData"]],
    Missing["NoObstructionScan"]
  ];
  scaling = Lookup[row, "CoverageLPScalingData", Missing["NoCoverageData"]];
  scaleSummary = hrfPreselectedScalingSummary[scaling];
  vars = Lookup[row, "RemainingVars", Lookup[row, "Variables", {}]];
  Join[
    KeyTake[row, {
      "ScanIndex", "Family", "DiagramIndex", "Example03Group", "Example03Topology",
      "Example03GraphIndex", "Example03PrimaryQ", "PropagatorCount", "TopologyName",
      "RegionType", "ZeroVars", "RemainingVars", "PreselectionZeroVars",
      "PreselectionEffectivePropagatorCount"
    }],
    <|
      "F0TermCount" -> hrfPolynomialMonomialCount[Lookup[row, "FRestricted", Lookup[row, "Flead", 0]], Lookup[row, "Variables", vars]],
      "ObstructionRecordQ" -> AssociationQ[obsData],
      "ValidObstructionTrialCount" -> If[AssociationQ[scan], Lookup[scan, "ValidObstructionTrialCount", 0], 0],
      "CandidateGeneratorCount" -> If[AssociationQ[scan], Lookup[scan, "CandidateGeneratorCount", 0], 0],
      "GeneratorCount" -> If[AssociationQ[scan], Length[Lookup[scan, "Generators", {}]], 0],
      "GeneratorSetFactorCount" -> If[AssociationQ[scan], Lookup[scan, "GeneratorSetFactorCount", 0], 0],
      "SearchMethod" -> If[AssociationQ[obsData],
        Lookup[obsData, "SearchMethod", Missing["NoSearchMethod"]],
        Missing["NoObstructionData"]]
    |>,
    hrfPreselectedFactorSummary[scan, vars],
    scaleSummary,
    <|"HRFoundWithScalingQ" -> TrueQ[scaleSummary["AcceptedScalingQ"]]|>
  ]
];

hrfPreselectedCountsBy[rows_List, key_] := If[rows === {}, <||>, Counts[Lookup[rows, key]]];

hrfPreselectedCSVString[x_String] := x;
hrfPreselectedCSVString[x_] := ToString[InputForm[x]];
hrfPreselectedCSVTable[rows_List] := Module[{keys},
  If[rows === {}, Return[{}]];
  keys = Keys[First[rows]];
  Prepend[(hrfPreselectedCSVString /@ Lookup[#, keys] &) /@ rows, keys]
];
hrfPreselectedWriteCSV[path_, rows_] := Export[path, hrfPreselectedCSVTable[rows], "CSV"];

allHandoffRows = hrfPreselectedRows[];
selectedHandoffRows = hrfPreselectedSelectRows[allHandoffRows];

If[! TrueQ[$HRFQuietReports],
  Print["[Preselected 5pt] handoff rows=", Length[allHandoffRows],
    " selected=", Length[selectedHandoffRows],
    " interior=", TrueQ[$HRFPreselectedRunInteriorQ],
    " boundary=", TrueQ[$HRFPreselectedRunBoundaryQ],
    " boundary max codim=", $HRFPreselectedBoundaryMaxCodim]
];

Preselected5ptDetailedRows = {};
Do[
  If[! TrueQ[$HRFQuietReports],
    Print["[Preselected 5pt] row ", i, "/", Length[selectedHandoffRows],
      "  ", hrfPreselectedTopologyName[selectedHandoffRows[[i]], i]]
  ];
  data = hrfPreselectedBuildData[selectedHandoffRows[[i]], i];
  If[TrueQ[$HRFPreselectedRunInteriorQ],
    AppendTo[Preselected5ptDetailedRows, hrfPreselectedScanInteriorRow[data]]
  ];
  If[TrueQ[$HRFPreselectedRunBoundaryQ],
    Preselected5ptDetailedRows = Join[
      Preselected5ptDetailedRows,
      hrfPreselectedScanBoundaryRows[data]
    ]
  ],
  {i, Length[selectedHandoffRows]}
];

Preselected5ptScanRows = hrfPreselectedSummaryRow /@ Preselected5ptDetailedRows;
Preselected5ptHRRows = Select[Preselected5ptScanRows, TrueQ[#["HRFoundWithScalingQ"]] &];
Preselected5ptScanSummary = <|
  "RunDate" -> DateString[{"Year", "-", "Month", "-", "Day", " ", "Hour", ":", "Minute", ":", "Second"}],
  "SelectedRows" -> Length[selectedHandoffRows],
  "TotalHandoffRows" -> Length[allHandoffRows],
  "InteriorRunQ" -> TrueQ[$HRFPreselectedRunInteriorQ],
  "BoundaryRunQ" -> TrueQ[$HRFPreselectedRunBoundaryQ],
  "BoundaryMaxCodim" -> If[TrueQ[$HRFPreselectedRunBoundaryQ], $HRFPreselectedBoundaryMaxCodim, 0],
  "ScanRows" -> Length[Preselected5ptScanRows],
  "HRRows" -> Length[Preselected5ptHRRows],
  "RowsByRegionType" -> hrfPreselectedCountsBy[Preselected5ptScanRows, "RegionType"],
  "HRRowsByRegionType" -> hrfPreselectedCountsBy[Preselected5ptHRRows, "RegionType"],
  "RowsByPropagatorCount" -> hrfPreselectedCountsBy[Preselected5ptScanRows, "PropagatorCount"],
  "HRRowsByPropagatorCount" -> hrfPreselectedCountsBy[Preselected5ptHRRows, "PropagatorCount"],
  "HRRowsWithPolynomialSLSectorFactors" -> Count[
    Preselected5ptHRRows,
    r_ /; TrueQ[Lookup[r, "SLSectorPolynomialFactorQ", False]]
  ],
  "HRRowsWithAllBinomialSLSectorFactors" -> Count[
    Preselected5ptHRRows,
    r_ /; TrueQ[Lookup[r, "SLSectorAllBinomialQ", False]]
  ]
|>;

Put[
  <|
    "Summary" -> Preselected5ptScanSummary,
    "Rows" -> Preselected5ptScanRows,
    "HRRows" -> Preselected5ptHRRows,
    "DetailedRows" -> If[TrueQ[$HRFPreselectedStoreDetailedRowsQ], Preselected5ptDetailedRows, Missing["NotStored"]]
  |>,
  $HRFPreselectedOutputPrefix <> "Summary.wl"
];
hrfPreselectedWriteCSV[$HRFPreselectedOutputPrefix <> "Rows.csv", Preselected5ptScanRows];
hrfPreselectedWriteCSV[$HRFPreselectedOutputPrefix <> "HRRows.csv", Preselected5ptHRRows];

Print["PRESELECTED_5PT_SCAN_SUMMARY"];
Print[InputForm[Preselected5ptScanSummary]];
Print["PRESELECTED_5PT_HR_ROWS"];
Print[InputForm[Preselected5ptHRRows]];
