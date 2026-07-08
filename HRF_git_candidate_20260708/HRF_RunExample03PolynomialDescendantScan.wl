(* ::Package:: *)
(* Run the Example 03 seven/eight-propagator descendants with polynomial
   cancellation factors and export compact HR summaries. *)

SetDirectory[DirectoryName[$InputFileName]];

$HRFQuietReports = False;
$HRFExampleVerbose = False;
$HRFDebugTiming = False;
$HRFScalingReport = True;
$HRFEx03UsePolynomialFactorsQ = True;
$HRFEx03RunFullTopologyScanQ = True;
If[! ValueQ[$HRFRunExample03EightPropBoundaryScanQ],
  $HRFRunExample03EightPropBoundaryScanQ = False
];
$HRFEx03RunEightPropBoundaryScanQ = TrueQ[$HRFRunExample03EightPropBoundaryScanQ];
$HRFFindObstructionsStopOnFirstAdmissibleQ = False;
$HRFFindObstructionsStoreAllTrialsQ = True;
$HRFPolynomialRequireKinematicDomainQ = False;

Get["03_FivePoint_Spacelike_Collinear.wl"];

ClearAll[
  hrfEx03PolyFactorClass, hrfEx03PolyFactorSummary,
  hrfEx03PolyScalingAssoc, hrfEx03PolyScanAssoc,
  hrfEx03PolyRegionRow, hrfEx03PolyRowsForFamily,
  hrfEx03PolyWriteCSV
];

hrfEx03PolyFactorClass[f_, vars_] := Module[{n},
  n = hrfPolynomialMonomialCount[f, vars];
  If[binomialQ[f, vars], "binomial", "polynomial-" <> ToString[n] <> "-term"]
];

hrfEx03PolyFactorSummary[scan_] := Module[{factors, counts, selected},
  factors = If[AssociationQ[scan], Lookup[scan, "CancellationFactors", {}], {}];
  counts = Counts[hrfEx03PolyFactorClass[#, Lookup[scan, "ActiveVars", {}]] & /@ factors];
  selected = If[AssociationQ[scan], Lookup[scan, "SLSectorFactorUnion", {}], {}];
  <|
    "CancellationFactorCount" -> Length[factors],
    "CancellationFactorClassCounts" -> counts,
    "AllCancellationFactorsBinomialQ" -> (factors =!= {} && AllTrue[factors, binomialQ[#, Lookup[scan, "ActiveVars", {}]] &]),
    "PolynomialCancellationFactorQ" -> AnyTrue[factors, ! binomialQ[#, Lookup[scan, "ActiveVars", {}]] &],
    "SLSectorFactorCount" -> Length[selected],
    "SLSectorFactorClassCounts" -> Counts[hrfEx03PolyFactorClass[#, Lookup[scan, "ActiveVars", {}]] & /@ selected],
    "SLSectorAllBinomialQ" -> (selected =!= {} && AllTrue[selected, binomialQ[#, Lookup[scan, "ActiveVars", {}]] &]),
    "SLSectorPolynomialFactorQ" -> AnyTrue[selected, ! binomialQ[#, Lookup[scan, "ActiveVars", {}]] &]
  |>
];

hrfEx03PolyScalingAssoc[row_] := Module[{d},
  d = Lookup[row, "CoverageLPScalingData", Missing["NoCoverageData"]];
  If[! AssociationQ[d], Return[<|
    "AcceptedScalingQ" -> False,
    "ScalingVector" -> d,
    "AcceptedScalingCount" -> 0,
    "UniqueAcceptedScalingQ" -> False,
    "ScalingStatus" -> Missing["NoCoverageData"]
  |>]];
  <|
    "AcceptedScalingQ" -> TrueQ[Lookup[d, "AcceptedCount", 0] > 0],
    "ScalingVector" -> Lookup[d, "Scaling", Missing["NoScaling"]],
    "AcceptedScalingCount" -> Lookup[d, "AcceptedCount", 0],
    "UniqueAcceptedScalingQ" -> Lookup[d, "UniqueAcceptedScalingQ", False],
    "ScalingStatus" -> Lookup[d, "ScalingStatusMessage", Lookup[d, "ScalingStatus", ""]]
  |>
];

hrfEx03PolyScanAssoc[scan_] := If[AssociationQ[scan],
  Module[{od = Lookup[scan, "ObstructionData", <||>]},
    Join[
      <|
        "ObstructionRecordQ" -> AssociationQ[od],
        "HiddenRegionQ" -> TrueQ[Lookup[scan, "HiddenRegionQ", hrfFPObstructionRegionPresentQ[scan]]],
        "HiddenRegionCount" -> Lookup[scan, "HiddenRegionCount", Missing["NoHiddenRegionCount"]],
        "ValidObstructionTrialCount" -> Lookup[scan, "ValidObstructionTrialCount", Missing["NoValidTrialCount"]],
        "CandidateGeneratorCount" -> Lookup[scan, "CandidateGeneratorCount", Missing["NoCandidateGeneratorCount"]],
        "GeneratorCount" -> Length[Lookup[scan, "Generators", {}]],
        "GeneratorSetFactorCount" -> Lookup[scan, "GeneratorSetFactorCount", 0],
        "SearchMethod" -> If[AssociationQ[od], Lookup[od, "SearchMethod", Missing["NoSearchMethod"]], od]
      |>,
      hrfEx03PolyFactorSummary[scan]
    ]
  ],
  <|
    "ObstructionRecordQ" -> False,
    "HiddenRegionQ" -> False,
    "HiddenRegionCount" -> 0,
    "ValidObstructionTrialCount" -> 0,
    "CandidateGeneratorCount" -> 0,
    "GeneratorCount" -> 0,
    "GeneratorSetFactorCount" -> 0,
    "SearchMethod" -> Missing["NoScan"],
    "CancellationFactorCount" -> 0,
    "CancellationFactorClassCounts" -> <||>,
    "AllCancellationFactorsBinomialQ" -> False,
    "PolynomialCancellationFactorQ" -> False,
    "SLSectorFactorCount" -> 0,
    "SLSectorFactorClassCounts" -> <||>,
    "SLSectorAllBinomialQ" -> False,
    "SLSectorPolynomialFactorQ" -> False
  |>
];

hrfEx03PolyRegionRow[row_, propCount_Integer, region_String] := Module[
  {scan = Lookup[row, "ObstructionScan", <||>], scaling},
  scaling = hrfEx03PolyScalingAssoc[row];
  Join[
    <|
      "PropagatorCount" -> propCount,
      "GraphIndex" -> Lookup[row, "GraphIndex", Missing["NoGraphIndex"]],
      "TopologyName" -> Lookup[row, "TopologyName", Missing["NoTopologyName"]],
      "RegionType" -> region,
      "ZeroVars" -> Lookup[row, "ZeroVars", {}],
      "RemainingVars" -> Lookup[row, "RemainingVars", Missing["NoRemainingVars"]]
    |>,
    hrfEx03PolyScanAssoc[scan],
    scaling,
    <|
      "HRFoundWithScalingQ" -> TrueQ[Lookup[scaling, "AcceptedScalingQ", False]]
    |>
  ]
];

hrfEx03PolyRowsForFamily[propCount_Integer, interiorRows_, boundaryRows_] := Join[
  hrfEx03PolyRegionRow[#, propCount, "Interior"] & /@ interiorRows,
  hrfEx03PolyRegionRow[#, propCount, "Boundary"] & /@ boundaryRows
];

Example03PolynomialDescendantScanRows = Join[
  hrfEx03PolyRowsForFamily[7, InteriorScalingData2Loop7Prop, BoundaryScalingData2Loop7Prop],
  hrfEx03PolyRowsForFamily[8, InteriorScalingData2Loop8Prop, BoundaryScalingData2Loop8Prop]
];

Example03PolynomialDescendantHRRows = Select[
  Example03PolynomialDescendantScanRows,
  TrueQ[Lookup[#, "HRFoundWithScalingQ", False]] &
];

Example03PolynomialDescendantSummary = <|
  "RunDate" -> DateString[{"Year", "-", "Month", "-", "Day", " ", "Hour", ":", "Minute", ":", "Second"}],
  "PolynomialFactorsQ" -> True,
  "EightPropBoundaryScanQ" -> TrueQ[$HRFEx03RunEightPropBoundaryScanQ],
  "Rows" -> Length[Example03PolynomialDescendantScanRows],
  "HRRows" -> Length[Example03PolynomialDescendantHRRows],
  "RowsByPropagatorCount" -> Counts[Lookup[Example03PolynomialDescendantScanRows, "PropagatorCount"]],
  "HRRowsByPropagatorCount" -> Counts[Lookup[Example03PolynomialDescendantHRRows, "PropagatorCount"]],
  "HRRowsByRegionType" -> Counts[Lookup[Example03PolynomialDescendantHRRows, "RegionType"]],
  "HRRowsWithPolynomialSLSectorFactors" -> Count[
    Example03PolynomialDescendantHRRows,
    r_ /; TrueQ[Lookup[r, "SLSectorPolynomialFactorQ", False]]
  ],
  "HRRowsWithAllBinomialSLSectorFactors" -> Count[
    Example03PolynomialDescendantHRRows,
    r_ /; TrueQ[Lookup[r, "SLSectorAllBinomialQ", False]]
  ]
|>;

ClearAll[hrfEx03PolyCSVString, hrfEx03PolyCSVTable];
hrfEx03PolyCSVString[x_String] := x;
hrfEx03PolyCSVString[x_] := ToString[InputForm[x]];
hrfEx03PolyCSVTable[rows_List] := Module[{keys},
  If[rows === {}, Return[{}]];
  keys = Keys[First[rows]];
  Prepend[
    (hrfEx03PolyCSVString /@ Lookup[#, keys] &) /@ rows,
    keys
  ]
];
hrfEx03PolyWriteCSV[path_, rows_] := Export[path, hrfEx03PolyCSVTable[rows], "CSV"];

Put[
  <|
    "Summary" -> Example03PolynomialDescendantSummary,
    "Rows" -> Example03PolynomialDescendantScanRows,
    "HRRows" -> Example03PolynomialDescendantHRRows
  |>,
  "Example03PolynomialDescendantScanSummary.wl"
];
hrfEx03PolyWriteCSV[
  "Example03PolynomialDescendantScanRows.csv",
  Example03PolynomialDescendantScanRows
];
hrfEx03PolyWriteCSV[
  "Example03PolynomialDescendantHRRows.csv",
  Example03PolynomialDescendantHRRows
];

Print["SUMMARY"];
Print[InputForm[Example03PolynomialDescendantSummary]];
Print["HR_ROWS"];
Print[InputForm[Example03PolynomialDescendantHRRows]];
