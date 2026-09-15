$HistoryLength = 0;

candidateDir = DirectoryName[$InputFileName];
dataFile = FileNameJoin[{candidateDir, "data", "nmrk",
  "one_loop_hexagon_kinematics.wl"}];
outFile = FileNameJoin[{candidateDir, "results", "generated",
  "nmrk_wz_one_loop_hexagon_alignment_scan.wl"}];

SetDirectory[candidateDir];

$HRFQuietReports = True;
$HRFScalingReport = False;
$HRFUsePolynomialCancellationFactors = True;
$HRFPolynomialRequireKinematicDomainQ = True;

Get["HiddenRegionFinder.wl"];

ClearAll[hexChartTransform];

data = Import[dataFile, "WL"];
vars = data["HexagonVariables"];
U = data["U"];
F = data["FMinimalSet"];

chartRules = Join[data["StandardNMRKRules"], {w -> z, wb -> zb}];
chartVars = {Q, X34h, X45, X56h, Kz};
chartAssumptions = And @@ Thread[chartVars > 0];

hexChartTransform[p_] := Module[{q},
  q = Factor[p /. {q1*q1b -> Q, q1b*q1 -> Q}];
  q = q /. {
      (1 - z)*(1 - zb) -> Kz,
      (1 - zb)*(1 - z) -> Kz,
      (-1 + z)*(-1 + zb) -> Kz,
      (-1 + zb)*(-1 + z) -> Kz
    };
  q = Expand[q] /. {z*zb -> Kz + z + zb - 1, zb*z -> Kz + z + zb - 1};
  q = Expand[q] /. {
      1 - z - zb + z*zb -> Kz,
      1 - zb - z + z*zb -> Kz,
      z*zb - z - zb + 1 -> Kz
    };
  Factor[q]
];

scan = findObstructions[
  F,
  vars,
  chartAssumptions,
  chartVars,
  Automatic,
  "U" -> U,
  "AsymptoticOrderAlignmentMode" -> "Only",
  "AsymptoticOrderAlignmentOptions" -> {
    "KinematicRules" -> chartRules,
    "MandelstamVariables" -> {},
    "DisableMandelstamLinearityForChartVariablesQ" -> True,
    "ScalingRange" -> Range[-2, 0],
    "RequirePromotedQ" -> False,
    "MinFaceTerms" -> 2,
    "FacePolynomialTransform" -> hexChartTransform,
    "RunHRFQ" -> True,
    "HRFOptions" -> {
      "MaxScalingAbs" -> 8,
      "CandidateGeneratorSetLimit" -> 128
    }
  }
];

summary = <|
  "HiddenRegionQ" -> Lookup[scan, "HiddenRegionQ", False],
  "AsymptoticOrderAlignmentHiddenRegionQ" -> Lookup[scan, "AsymptoticOrderAlignmentHiddenRegionQ", False],
  "AsymptoticOrderAlignmentAcceptedPresentationCount" -> Lookup[scan, "AsymptoticOrderAlignmentAcceptedPresentationCount", 0],
  "AsymptoticOrderAlignmentUniqueHiddenRegionCount" -> Lookup[scan, "AsymptoticOrderAlignmentUniqueHiddenRegionCount", 0],
  "StandardScanSkippedQ" -> Lookup[scan, "StandardScanSkippedQ", False],
  "AsymptoticOrderAlignmentStatus" -> Lookup[scan, "AsymptoticOrderAlignmentStatus", Missing["NoStatus"]]
|>;

Print[InputForm[summary]];

If[! DirectoryQ[DirectoryName[outFile]], CreateDirectory[DirectoryName[outFile]]];
Export[outFile, scan["AsymptoticOrderAlignmentScan"], "Package"];
Print["Exported ", outFile];

If[
  TrueQ[summary["HiddenRegionQ"]] &&
    TrueQ[summary["AsymptoticOrderAlignmentHiddenRegionQ"]] &&
    summary["AsymptoticOrderAlignmentUniqueHiddenRegionCount"] === 1 &&
    summary["AsymptoticOrderAlignmentAcceptedPresentationCount"] >= 1,
  Exit[0],
  Exit[1]
];
