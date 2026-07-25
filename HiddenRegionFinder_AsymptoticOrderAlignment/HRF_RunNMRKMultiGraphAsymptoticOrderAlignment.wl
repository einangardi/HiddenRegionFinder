$HistoryLength = 0;

repo = DirectoryName[$InputFileName];
dataFile = FileNameJoin[{repo, "data", "nmrk",
  "one_loop_hexagon_kinematics.wl"}];
alignmentSeedFile = FileNameJoin[{repo, "data", "nmrk",
  "asymptotic_order_alignment_seeds.wl"}];
outDir = FileNameJoin[{repo, "results", "nmrk_wz"}];

SetDirectory[repo];
$HRFQuietReports = True;
$HRFScalingReport = False;
$HRFUsePolynomialCancellationFactors = True;
$HRFPolynomialRequireKinematicDomainQ = True;
Get["HiddenRegionFinder.wl"];

ClearAll[allPairMandelstamF, genericChartTransform, wzChartTransform, compactRow];

allPairMandelstamF[uf_Association] := Expand[
  spExpand[uf["F"]] //. {sp[a_, b_] /; ! OrderedQ[{a, b}] :> sp[b, a]} /.
    {
      sp[p1, p1] -> 0, sp[p2, p2] -> 0, sp[p3, p3] -> 0,
      sp[p4, p4] -> 0, sp[p5, p5] -> 0, sp[p6, p6] -> 0,
      sp[p1, p2] -> s12/2, sp[p1, p3] -> s13/2, sp[p1, p4] -> s14/2,
      sp[p1, p5] -> s15/2, sp[p1, p6] -> s16/2,
      sp[p2, p3] -> s23/2, sp[p2, p4] -> s24/2, sp[p2, p5] -> s25/2,
      sp[p2, p6] -> s26/2, sp[p3, p4] -> s34/2, sp[p3, p5] -> s35/2,
      sp[p3, p6] -> s36/2, sp[p4, p5] -> s45/2, sp[p4, p6] -> s46/2,
      sp[p5, p6] -> s56/2
    }
];

genericChartTransform[p_] := Factor[p /. {q1*q1b -> Q, q1b*q1 -> Q}];

wzChartTransform[p_] := Module[{q},
  q = Factor[p /. {q1*q1b -> Q, q1b*q1 -> Q}];
  q = q /. {
      (1 - z)*(1 - zb) -> Kz, (1 - zb)*(1 - z) -> Kz,
      (-1 + z)*(-1 + zb) -> Kz, (-1 + zb)*(-1 + z) -> Kz
    };
  q = Expand[q] /. {z*zb -> Kz + z + zb - 1, zb*z -> Kz + z + zb - 1};
  q = Expand[q] /. {
      1 - z - zb + z*zb -> Kz, 1 - zb - z + z*zb -> Kz,
      z*zb - z - zb + 1 -> Kz
    };
  Factor[q]
];

graphSpecs = <|
  "planar-hexbox" -> {
    {"0", {5, 6}}, {"0", {1, 8}}, {"0", {8, 6}},
    {"0", {1, 2}}, {"0", {2, 3}}, {"0", {3, 4}},
    {"0", {4, 7}}, {"0", {7, 5}}, {"0", {7, 8}}
  },
  "nonplanar-hexbox" -> {
    {"0", {5, 8}}, {"0", {1, 8}}, {"0", {1, 2}},
    {"0", {2, 3}}, {"0", {7, 3}}, {"0", {7, 5}},
    {"0", {4, 7}}, {"0", {6, 8}}, {"0", {4, 6}}
  },
  "hexagon-pentagon" -> {
    {"0", {5, 6}}, {"0", {1, 8}}, {"0", {8, 6}},
    {"0", {1, 3}}, {"0", {3, 4}}, {"0", {4, 7}},
    {"0", {7, 5}}, {"0", {7, 2}}, {"0", {8, 2}}
  }
|>;

args = Take[$ScriptCommandLine, -2];
If[Length[args] < 2 || ! KeyExistsQ[graphSpecs, args[[1]]] || ! MemberQ[{"generic", "wz"}, args[[2]]],
  Print["Usage: wolframscript -file HRF_RunNMRKMultiGraphAsymptoticOrderAlignment.wl <planar-hexbox|nonplanar-hexbox|hexagon-pentagon> <generic|wz>"];
  Exit[2]
];

graphName = args[[1]];
chartName = args[[2]];
internalLines = graphSpecs[graphName];
externalLines = {{p1, 1}, {p2, 4}, {p3, 5}, {p4, 3}, {p5, 2}, {p6, 6}};

hexData = Import[dataFile, "WL"];
uf = SymanzikUF[internalLines, externalLines];
vars = uf["Variables"];
uPoly = uf["U"];

dependentRules = hexData["DependentMandelstamRules"];
invariantRules = Normal[KeyTake[
  hexData["InvariantRules"], {s12, s23, s34, s45, s56, s16, s46, s35, s14}
]];
standardRules = hexData["StandardNMRKRules"];

(* The final certification algorithm changed, but face discovery did not.
   For w=z, rerun exactly the structurally distinct faces retained by the
   exhaustive 19 July discovery scans.  This avoids enumerating the same
   roughly two thousand raw faces again. *)
alignmentSeeds = Import[alignmentSeedFile, "WL"];
candidateVectors = If[chartName === "wz",
  Lookup[alignmentSeeds, graphName, {}],
  Automatic
];

If[chartName === "generic",
  chartRules = standardRules;
  chartVars = {Q, X34h, X45, X56h, z, zb, w, wb};
  chartTransform = genericChartTransform,
  chartRules = Join[standardRules, {w -> z, wb -> zb}];
  chartVars = {Q, X34h, X45, X56h, Kz};
  chartTransform = wzChartTransform
];
chartAssumptions = And @@ Thread[chartVars > 0];

fAll = allPairMandelstamF[uf];
fGeneric = Expand[fAll /. dependentRules];
fMinimal = Factor[Together[fGeneric /. invariantRules]];

started = AbsoluteTime[];
scan = findObstructions[
  fMinimal, vars, chartAssumptions, chartVars, Automatic,
  "U" -> uPoly,
  "AsymptoticOrderAlignmentMode" -> "Only",
  "AsymptoticOrderAlignmentOptions" -> {
    "KinematicRules" -> chartRules,
    "KinematicAssumptions" -> chartAssumptions,
    "KinematicVariables" -> chartVars,
    "MandelstamVariables" -> {},
    "DisableMandelstamLinearityForChartVariablesQ" -> True,
    "ScalingRange" -> Range[-2, 0],
    "FaceVectors" -> candidateVectors,
    "RequirePromotedQ" -> False,
    "MinFaceTerms" -> 2,
    "FacePolynomialTransform" -> chartTransform,
    "RunHRFQ" -> True,
    "HRFOptions" -> {"MaxScalingAbs" -> 8, "CandidateGeneratorSetLimit" -> 128}
  }
];
elapsed = N[AbsoluteTime[] - started];
alignmentScan = Lookup[scan, "AsymptoticOrderAlignmentScan", <||>];

compactRow[row_] := Module[{audit, hrf},
  audit = Lookup[row, "TotalScalingAudit", <||>];
  hrf = Lookup[row, "HRFSummary", <||>];
  <|
    "FaceScaling" -> Lookup[row, "Scaling", Missing["NotAvailable"]],
    "ActiveVariables" -> Lookup[audit, "ActiveVariables", {}],
    "BoundaryZeroVariables" -> Lookup[audit, "BoundaryZeroVariables", {}],
    "HRFScaling" -> Lookup[Lookup[hrf, "CoverageScalingData", <||>], "Scaling", Missing["NotAvailable"]],
    "CancellationFactors" -> Lookup[hrf, "CancellationFactors", {}],
    "AuditStatus" -> Lookup[audit, "AuditStatus", Missing["NotAvailable"]],
    "CertifiedTotalScaling" -> Values[Lookup[audit, "TotalScaling", <||>]],
    "CertifiedTotalScalingAssociation" -> Lookup[audit, "TotalScaling", <||>],
    "RelativeTotalScaling" -> Values[Lookup[audit, "RelativeTotalScaling", <||>]],
    "WSL" -> Lookup[audit, "WSL", Missing["NotAvailable"]],
    "WHR" -> Lookup[audit, "WHR", Missing["NotAvailable"]],
    "HierarchyGap" -> Lookup[audit, "HierarchyGap", Missing["NotAvailable"]],
    "CertificationVectorSource" -> Lookup[audit, "CertificationVectorSource", Missing["NotAvailable"]]
  |>
];

rows = Lookup[alignmentScan, "DeduplicatedHiddenRegionRows", {}];
stagedRows = Lookup[alignmentScan, "StagedDeduplicatedHiddenRegionRows", {}];
auditStatuses = If[stagedRows === {}, {},
  Lookup[Lookup[stagedRows, "TotalScalingAudit", <||>],
    "AuditStatus", Missing["NotAvailable"]]
];

certificate = <|
  "GraphName" -> graphName,
  "Expansion" -> If[chartName === "wz", "central NMRK with w=z and wb=zb", "generic central NMRK"],
  "CurrentFinalAuditQ" -> True,
  "StagedUniqueCount" -> Length[stagedRows],
  "CertifiedUniqueCount" -> Length[rows],
  "RejectedUniqueCount" -> Length[stagedRows] - Length[rows],
  "AuditStatusCounts" -> Counts[auditStatuses],
  "ElapsedSeconds" -> elapsed,
  "Representatives" -> (compactRow /@ rows)
|>;

If[! DirectoryQ[outDir], CreateDirectory[outDir, CreateIntermediateDirectories -> True]];
fullFile = FileNameJoin[{outDir, "full_" <> chartName <> "_" <> graphName <> ".wl"}];
certificateFile = FileNameJoin[{outDir, "certified_" <> chartName <> "_" <> graphName <> ".wl"}];
Export[fullFile, alignmentScan, "Package"];
Export[certificateFile, certificate, "Package"];

Print[InputForm[certificate]];
Print["Full scan: ", fullFile];
Print["Certificate: ", certificateFile];
Exit[0];
