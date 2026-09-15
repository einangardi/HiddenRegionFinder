$HistoryLength = 0;

repoDirectory = DirectoryName[$InputFileName];
SetDirectory[repoDirectory];

$HRFQuietReports = True;
$HRFScalingReport = False;
$HRFUsePolynomialCancellationFactors = True;
$HRFPolynomialRequireKinematicDomainQ = True;

Get[FileNameJoin[{repoDirectory, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{repoDirectory, "HRF_AsymptoticOrderAlignment.wl"}]];

ClearAll[
  allPairMandelstamF, alignmentSummary, representativeRows,
  runGenericDSCAsymptoticOrderAlignment, graphSpecs, dscData, dscRawInvariantAssociation,
  dscPhysicalInvariantRules, dscPhysicalAssumptions, dscKinematicVariables
];

dscData = Import[
  FileNameJoin[{repoDirectory, "DSC_TwistorInvariantData_20260719.wl"}],
  "WL"
];

(* The stored twistor formulae use the fixed raw projective normalization.
   For the physical 2->4 sheet used here all 15 invariants receive one common
   minus sign.  Rename the paper variables zc,zbc to zD,zbD in this runner. *)
dscRawInvariantAssociation = dscData["PhysicalPairInvariants"];
dscPhysicalInvariantRules = KeyValueMap[
  #1 -> -(#2 /. {zc -> zD, zbc -> zbD}) &,
  dscRawInvariantAssociation
];

dscKinematicVariables = {a, tau1, tau2, zD, zbD};
dscPhysicalAssumptions =
  a < 0 && -1 < tau1 < 0 && tau2 < -1 && zD < 0 && zbD < 0;

allPairMandelstamF[uf_Association] := Expand[
  spExpand[uf["F"]] //. {sp[x_, y_] /; ! OrderedQ[{x, y}] :> sp[y, x]} /.
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

alignmentSummary[scan_] := If[
  AssociationQ[scan],
  Lookup[scan, "Summary", <||>],
  <|"ScanFailed" -> scan|>
];

representativeRows[scan_, rowKey_:"DeduplicatedHiddenRegionRows"] := Module[{rows},
  If[! AssociationQ[scan], Return[{}]];
  rows = Lookup[scan, rowKey, {}];
  Function[row,
    <|
      "Scaling" -> Lookup[row, "Scaling", Missing["NoFaceScaling"]],
      "Weight" -> Lookup[row, "Weight", Missing["NoFaceWeight"]],
      "EtaPowers" -> Lookup[row, "EtaPowers", {}],
      "Support" -> Lookup[row, "Support", {}],
      "PreselectionZeroVars" -> Lookup[row, "PreselectionZeroVars", {}],
      "Generators" -> Lookup[Lookup[row, "HRFSummary", <||>], "Generators", {}],
      "CancellationFactors" -> Lookup[
        Lookup[row, "HRFSummary", <||>], "CancellationFactors", {}
      ],
      "CoverageScalingData" -> Lookup[
        Lookup[row, "HRFSummary", <||>],
        "CoverageScalingData",
        Missing["NotEvaluated"]
      ],
      "FacePolynomial" -> Lookup[row, "Polynomial", Missing["NotStored"]]
    |>
  ] /@ rows
];

commonExternalLines = {
  {p1, 1}, {p2, 4}, {p3, 5}, {p4, 3}, {p5, 2}, {p6, 6}
};

graphSpecs = <|
  "hexagon" -> <|
    "Description" -> "one-loop hexagon",
    "InternalLines" -> {
      {"0", {5, 6}}, {"0", {1, 6}}, {"0", {1, 2}},
      {"0", {2, 3}}, {"0", {3, 4}}, {"0", {4, 5}}
    },
    "ExternalLines" -> commonExternalLines
  |>,
  "hexbox" -> <|
    "Description" -> "two-loop planar hexbox",
    "InternalLines" -> {
      {"0", {5, 6}}, {"0", {1, 8}}, {"0", {8, 6}},
      {"0", {1, 2}}, {"0", {2, 3}}, {"0", {3, 4}},
      {"0", {4, 7}}, {"0", {7, 5}}, {"0", {7, 8}}
    },
    "ExternalLines" -> commonExternalLines
  |>,
  "hexagon-pentagon" -> <|
    "Description" -> "two-loop hexagon-pentagon variant",
    "InternalLines" -> {
      {"0", {5, 6}}, {"0", {1, 8}}, {"0", {8, 6}},
      {"0", {1, 3}}, {"0", {3, 4}}, {"0", {4, 7}},
      {"0", {7, 5}}, {"0", {7, 2}}, {"0", {8, 2}}
    },
    "ExternalLines" -> commonExternalLines
  |>,
  "nonplanar-hexbox" -> <|
    "Description" -> "two-loop non-planar hexbox variant",
    "InternalLines" -> {
      {"0", {5, 8}}, {"0", {1, 8}}, {"0", {1, 2}},
      {"0", {2, 3}}, {"0", {7, 3}}, {"0", {7, 5}},
      {"0", {4, 7}}, {"0", {6, 8}}, {"0", {4, 6}}
    },
    "ExternalLines" -> commonExternalLines
  |>
|>;

runGenericDSCAsymptoticOrderAlignment[graphName_String] := Module[
  {spec, uf, vars, uPoly, fMandelstam, vertices, loopCount, signSample,
   positivePairs, negativePairs, signCheck, buildSeconds, scanSeconds,
   scan, result, compactResult, outputDirectory, outputFile, compactOutputFile},

  If[! KeyExistsQ[graphSpecs, graphName],
    Print["Unknown graph: ", graphName, ". Choices: ", Keys[graphSpecs]];
    Return[$Failed]
  ];

  spec = graphSpecs[graphName];
  uf = SymanzikUF[spec["InternalLines"], spec["ExternalLines"]];
  vars = uf["Variables"];
  uPoly = uf["U"];
  vertices = Union[Flatten[spec["InternalLines"][[All, 2]]]];
  loopCount = Length[spec["InternalLines"]] - Length[vertices] + 1;

  {buildSeconds, fMandelstam} = AbsoluteTiming[allPairMandelstamF[uf]];

  signSample = {
    eps -> 1/10000, a -> -1/2, tau1 -> -1/2, tau2 -> -2,
    zD -> -7/10, zbD -> -9/10
  };
  positivePairs = {s12, s34, s35, s36, s45, s46, s56};
  negativePairs = {s13, s14, s15, s16, s23, s24, s25, s26};
  signCheck = And[
    And @@ Thread[(positivePairs /. dscPhysicalInvariantRules /. signSample) > 0],
    And @@ Thread[(negativePairs /. dscPhysicalInvariantRules /. signSample) < 0]
  ];

  Print["[DSC] graph=", graphName, ", loops=", loopCount,
    ", edges=", Length[vars], ", sign-check=", signCheck];
  Print["[DSC] starting generic physical-domain asymptotic-order alignment scan"];

  {scanSeconds, scan} = AbsoluteTiming[
    hrfAsymptoticOrderAlignmentSearch[
      fMandelstam,
      vars,
      "EtaSymbol" -> eps,
      "KinematicRules" -> dscPhysicalInvariantRules,
      "KinematicAssumptions" -> dscPhysicalAssumptions,
      "KinematicVariables" -> dscKinematicVariables,
      "MandelstamVariables" -> {},
      "DisableMandelstamLinearityForChartVariablesQ" -> True,
      "U" -> uPoly,
      "ScalingRange" -> Range[-2, 0],
      "RequirePromotedQ" -> False,
      "MinFaceTerms" -> 2,
      "FacePolynomialTransform" -> Factor,
      "RunHRFQ" -> True,
      "HRFOptions" -> {
        "MaxScalingAbs" -> 8,
        "CandidateGeneratorSetLimit" -> 128
      }
    ]
  ];

  result = <|
    "RunType" -> "generic DSC, no additional kinematic restriction",
    "GraphName" -> graphName,
    "Graph" -> <|
      "Description" -> spec["Description"],
      "InternalLines" -> spec["InternalLines"],
      "ExternalLines" -> spec["ExternalLines"],
      "Variables" -> vars,
      "LoopCount" -> loopCount
    |>,
    "Kinematics" -> <|
      "EtaSymbol" -> eps,
      "Variables" -> dscKinematicVariables,
      "Assumptions" -> dscPhysicalAssumptions,
      "CommonPhysicalSign" -> -1,
      "AdditionalRestrictions" -> {},
      "InvariantRuleHash" -> Hash[dscPhysicalInvariantRules, "SHA256"],
      "PhysicalSignSampleCheck" -> signCheck
    |>,
    "TimingsSeconds" -> <|"BuildF" -> buildSeconds, "AsymptoticOrderAlignmentScan" -> scanSeconds|>,
    "AsymptoticOrderAlignmentSummary" -> alignmentSummary[scan],
    "RepresentativeRows" -> representativeRows[scan],
    "StagedRepresentativeRows" -> representativeRows[
      scan, "StagedDeduplicatedHiddenRegionRows"
    ],
    "Scan" -> scan
  |>;

  outputDirectory = FileNameJoin[{repoDirectory, "results", "generated"}];
  If[! DirectoryQ[outputDirectory],
    CreateDirectory[outputDirectory, CreateIntermediateDirectories -> True]
  ];
  outputFile = FileNameJoin[{
    outputDirectory, "dsc_" <> graphName <> "_alignment_scan.wl"
  }];
  Export[outputFile, result, "Package"];

  compactResult = KeyDrop[result, {"Scan"}];
  compactOutputFile = FileNameJoin[{
    outputDirectory, "dsc_" <> graphName <> "_alignment_summary.wl"
  }];
  Export[compactOutputFile, compactResult, "Package"];

  Print["[DSC] summary=", InputForm[result["AsymptoticOrderAlignmentSummary"]]];
  Print["[DSC] representative-count=", Length[result["RepresentativeRows"]]];
  Print["[DSC] elapsed-seconds=", scanSeconds];
  Print["[DSC] output=", outputFile];
  Print["[DSC] compact-output=", compactOutputFile];
  result
];

requestedGraph = If[Length[$ScriptCommandLine] >= 2, $ScriptCommandLine[[2]], "hexagon"];
runResult = runGenericDSCAsymptoticOrderAlignment[requestedGraph];
If[runResult === $Failed, Exit[1], Exit[0]];
