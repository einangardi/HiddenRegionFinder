$HistoryLength = 0;

repoDirectory = DirectoryName[$InputFileName];
SetDirectory[repoDirectory];

$HRFQuietReports = True;
Get[FileNameJoin[{repoDirectory, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{repoDirectory, "HRF_AsymptoticOrderAlignment.wl"}]];

ClearAll[certifiedDSCEntry, certifiedDSCGraph];

certifiedDSCEntry[label_String, row_Association, scan_Association, uPoly_] :=
 Module[
  {audit, activeVars, zeroVars, total, vector, termData, activeData,
   fWeights, fGroups, fLayers, uReduced, uRules, uWeights, uGroups,
   uLayers, wSL, wHR, redPolynomial, blueFPolynomial, blueUPolynomial,
   redRows, blueFRows, blueURows, numerical, relative},

  audit = row["TotalScalingAudit"];
  activeVars = audit["ActiveVariables"];
  zeroVars = audit["BoundaryZeroVariables"];
  total = audit["TotalScaling"];
  vector = Lookup[total, activeVars];
  numerical = Cases[vector, _Integer | _Rational];
  relative = AssociationThread[
    activeVars,
    If[Length[numerical] == Length[vector], vector - Max[numerical], vector]
  ];

  termData = scan["TermData"];
  activeData = Select[
    termData,
    With[{positions = Flatten[Position[scan["Variables"], Alternatives @@ zeroVars]]},
      positions === {} || Total[#["XRow"][[positions]]] == 0
    ] &
  ];
  fWeights = Association @ Map[
    #["Index"] ->
      (#["EtaPower"] +
        #["XRow"][[Flatten[Position[scan["Variables"], Alternatives @@ activeVars]]]].
          vector) &,
    activeData
  ];
  fGroups = GroupBy[
    activeData,
    Lookup[fWeights, #["Index"]] &
  ];
  fLayers = Association @ KeyValueMap[
    #1 -> Factor[Total[Lookup[#2, "CoeffNoEta", {}]] /. Thread[zeroVars -> 0]] &,
    KeySort[fGroups]
  ];

  uReduced = Expand[uPoly /. Thread[zeroVars -> 0]];
  uRules = CoefficientRules[uReduced, activeVars];
  uWeights = Association @ MapIndexed[
    First[#2] -> (First[#1].vector) &,
    uRules
  ];
  uGroups = GroupBy[
    MapIndexed[{First[#2], #1} &, uRules],
    Lookup[uWeights, First[#]] &
  ];
  uLayers = Association @ KeyValueMap[
    #1 -> Factor[Total[
      (Last[Last[#]] Times @@ MapThread[Power, {activeVars, First[Last[#]]}]) & /@
        #2
    ]] &,
    KeySort[uGroups]
  ];

  wSL = audit["WSL"];
  wHR = audit["WHR"];
  redPolynomial = Lookup[fLayers, wSL, 0];
  blueFPolynomial = Lookup[fLayers, wHR, 0];
  blueUPolynomial = Lookup[uLayers, wHR, 0];
  redRows = polynomialExponentRows[Expand[redPolynomial], activeVars];
  blueFRows = polynomialExponentRows[Expand[blueFPolynomial], activeVars];
  blueURows = polynomialExponentRows[Expand[blueUPolynomial], activeVars];

  <|
    "Label" -> label,
    "Variables" -> activeVars,
    "BoundaryZeroVariables" -> zeroVars,
    "FaceScaling" -> audit["FaceScaling"],
    "HRFScaling" -> audit["HRFScaling"],
    "TotalScaling" -> total,
    "RelativeTotalScaling" -> relative,
    "WSL" -> wSL,
    "WHR" -> wHR,
    "HierarchyGap" -> audit["HierarchyGap"],
    "SingularHypersurfaceFactors" ->
      row["HRFSummary"]["CancellationFactors"],
    "Generator" -> row["HRFSummary"]["Generators"],
    "RedPolynomial" -> redPolynomial,
    "RedFMonomialRows" -> redRows,
    "BlueFPolynomial" -> blueFPolynomial,
    "BlueFMonomialRows" -> blueFRows,
    "BlueUPolynomial" -> blueUPolynomial,
    "BlueUMonomialRows" -> blueURows,
    "BlackFLayers" -> KeySelect[fLayers, # > wHR &],
    "BlackULayers" -> KeySelect[uLayers, # > wHR &],
    "FacetAudit" -> KeyTake[audit, {
      "AuditStatus", "WHROnlyLowerFacetQ", "ResolvedWHRAffineRank",
      "RequiredFacetRank", "NormalizedInwardNormal", "CandidateNormal",
      "ResidualMonomialRescalingQ"
    }]
  |>
 ];

certifiedDSCGraph[graphName_String] := Module[
  {result, scan, uPoly, stagedRows, auditedRows, finalRows, groups, entries},
  result = Import[
    FileNameJoin[{repoDirectory, "results", "generated",
      "dsc_" <> graphName <> "_alignment_scan.wl"}],
    "WL"
  ];
  scan = result["Scan"];
  uPoly = SymanzikUF[
    result["Graph"]["InternalLines"], result["Graph"]["ExternalLines"]
  ]["U"];
  stagedRows = Lookup[
    scan, "StagedHiddenRegionRows", Lookup[scan, "HiddenRegionRows", {}]
  ];
  auditedRows = hrfAsymptoticOrderAlignmentApplyTotalLowerFacetAudit[
      #, scan["TermData"], scan["Variables"], uPoly, Factor, True,
      scan["EtaSymbol"]
    ] & /@ stagedRows;
  finalRows = Select[
    auditedRows, TrueQ[Lookup[#["HRFSummary"], "HiddenRegionQ", False]] &
  ];
  groups = hrfAsymptoticOrderAlignmentStructuralDeduplicateRows[finalRows, scan["Variables"]];
  entries = MapIndexed[
    certifiedDSCEntry[
      graphName <> " certified region " <> ToString[First[#2]],
      #1["Representative"], scan, uPoly
    ] &,
    groups
  ];
  <|
    "GraphName" -> graphName,
    "StagedPresentationCount" -> Length[stagedRows],
    "FinalPresentationCount" -> Length[finalRows],
    "FinalUniqueCount" -> Length[groups],
    "Entries" -> entries
  |>
];

cache = AssociationMap[
  certifiedDSCGraph,
  {"hexbox", "nonplanar-hexbox"}
];

outputFile = FileNameJoin[{
  repoDirectory, "results", "certified_DSC_two_loop_polynomials.wl"
}];
Export[outputFile, cache, "Package"];
Print["Exported ", outputFile];
Print[InputForm[Map[KeyDrop[#, "Entries"] &, cache]]];
