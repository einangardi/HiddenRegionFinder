$HistoryLength = 0;

repoDirectory = DirectoryName[$InputFileName];
SetDirectory[repoDirectory];
$HRFQuietReports = True;
Get[FileNameJoin[{repoDirectory, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{repoDirectory, "HRF_AsymptoticOrderAlignment.wl"}]];

ClearAll[
  termWeights, originalLPAudit, localWeightData, localFacetAudit,
  originalWHRRankAudit, pinchLayerAudit
];

stored = Import[
  FileNameJoin[{repoDirectory, "testdata", "alignment",
    "dsc_one_loop_hexagon_scan.wl"}],
  "WL"
];
scan = stored["Scan"];
vars = scan["Variables"];
termData = scan["TermData"];
fPhysical = Total[Lookup[termData, "Term"]];
uf = SymanzikUF[
  stored["Graph"]["InternalLines"], stored["Graph"]["ExternalLines"]
];
uPolynomial = uf["U"];

stagedRow = First[scan["StagedDeduplicatedHiddenRegionRows"]];
baseFace = stagedRow["Scaling"];
baseHRF = Lookup[
  stagedRow["HRFSummary"]["CoverageScalingData"],
  "PrimitiveScaling"
];

(* Include c=2 because it preserves the same F face while moving the
   degree-one U monomials onto the reported W_HR layer in the current,
   non-covariant composition. *)
shiftValues = {-1, 0, 1, 2};
shiftFaces = Association @ Table[
  c -> hrfAsymptoticOrderAlignmentFaceFromVector[termData, vars, baseFace + c, Factor],
  {c, shiftValues}
];

shiftRuns = Association @ KeyValueMap[
  Function[{c, face},
    c -> hrfAsymptoticOrderAlignmentFaceScanRow[
      face,
      vars,
      "RunHRFQ" -> True,
      "KinematicAssumptions" -> stored["Kinematics"]["Assumptions"],
      "KinematicVariables" -> stored["Kinematics"]["Variables"],
      "MandelstamVariables" -> {},
      "DisableMandelstamLinearityForChartVariablesQ" -> True,
      "U" -> uPolynomial,
      "HRFOptions" -> {
        "MaxScalingAbs" -> 8,
        "CandidateGeneratorSetLimit" -> 128
      }
    ]
  ],
  shiftFaces
];

termWeights[vector_List] :=
  (#["EtaPower"] + #["XRow"].vector &) /@ termData;

originalLPAudit[vector_List] := Module[
  {fWeights, wSL, outside, uRules, uWeights, wHR, slIndices,
   hrFIndices, hrUIndices},
  fWeights = termWeights[vector];
  wSL = Min[fWeights];
  outside = Select[Range[Length[termData]], fWeights[[#]] > wSL &];
  uRules = CoefficientRules[Expand[uPolynomial], vars];
  uWeights = (First[#].vector &) /@ uRules;
  wHR = Min[Join[fWeights[[outside]], uWeights]];
  slIndices = Select[Range[Length[termData]], fWeights[[#]] == wSL &];
  hrFIndices = Select[outside, fWeights[[#]] == wHR &];
  hrUIndices = Flatten @ Position[uWeights, wHR];
  <|
    "Vector" -> AssociationThread[vars, vector],
    "WSL" -> wSL,
    "WHR" -> wHR,
    "Gap" -> wHR - wSL,
    "SLExponentPoints" -> DeleteDuplicates[termData[[slIndices, "XRow"]]],
    "HRFExponentPoints" -> DeleteDuplicates[termData[[hrFIndices, "XRow"]]],
    "HRUExponentPoints" -> If[hrUIndices === {}, {}, First /@ uRules[[hrUIndices]]]
  |>
];

originalWHRRankAudit[audit_Association] := Module[{rows, differences},
  rows = Join[audit["HRFExponentPoints"], audit["HRUExponentPoints"]];
  differences = If[Length[rows] <= 1, {}, (# - First[rows]) & /@ Rest[rows]];
  <|
    "LeadingExponentAffineRank" -> MatrixRank[differences],
    "ScalingNullSpace" -> If[differences === {}, IdentityMatrix[Length[vars]],
      NullSpace[differences]]
  |>
];

pinchRules = {
  x2 -> -tau1*x1/(1 + tau1),
  x5 -> -(1 + tau2)*x4
};

pinchLayerAudit[vector_List, layerWeights_List] := Module[
  {weights, layerPolynomial},
  weights = termWeights[vector];
  Table[
    layerPolynomial = Factor @ Total @ Lookup[
      Pick[termData, weights, layerWeight], "CoeffNoEta"
    ];
    <|
      "Weight" -> layerWeight,
      "TermCount" -> Count[weights, layerWeight],
      "VanishesOnCommonPinchQ" -> TrueQ[
        Factor[Together[layerPolynomial /. pinchRules]] === 0
      ]
    |>,
    {layerWeight, layerWeights}
  ]
];

shiftRows = Table[
  run = shiftRuns[c];
  cov = Lookup[run["HRFSummary"], "CoverageScalingData", <||>];
  hCurrent = Lookup[cov, "PrimitiveScaling", Missing["NoScaling"]];
  hCovariant = baseHRF - c;
  <|
    "UniformShift" -> c,
    "FaceVector" -> baseFace + c,
    "FaceWeight" -> shiftFaces[c]["Weight"],
    "FacePolynomialIdenticalQ" -> TrueQ[
      Factor[shiftFaces[c]["Polynomial"] - shiftFaces[0]["Polynomial"]] === 0
    ],
    "CurrentHRFVector" -> hCurrent,
    "CovarianceRequiredHRFVector" -> hCovariant,
    "CurrentTotalVector" -> If[ListQ[hCurrent], baseFace + c + hCurrent, Missing[]],
    "CovariantTotalVector" -> baseFace + c + hCovariant,
    "CurrentGap" -> Lookup[cov, "PrimitiveHierarchyGap", Missing[]],
    "CurrentTotalAudit" -> If[
      ListQ[hCurrent] && Length[hCurrent] == Length[vars],
      originalLPAudit[baseFace + c + hCurrent],
      Missing[]
    ]
  |>,
  {c, shiftValues}
];

storedTotal = baseFace + baseHRF;
dissectedPullback = {-2, -2, -2, 0, -2, -2};
primitiveRelativeCandidate = {-1, -1, -1, 0, -1, -1};

localVars = {x0, x1, y1, x3, x4, y2};
localNormal = {-2, -2, -1, 0, -2, -1};
dissectionRules = {
  x2 -> (sigma1*y1 - tau1*x1)/(1 + tau1),
  x5 -> sigma2*y2 - (1 + tau2)*x4
};

localWeightData[polynomial_] := Module[{q, rules, weights},
  q = Expand[Numerator[Together[polynomial /. dissectionRules]]];
  rules = CoefficientRules[q, Append[localVars, eps]];
  weights = (Most[First[#]].localNormal + Last[First[#]]) & /@ rules;
  <|"Weights" -> Sort[DeleteDuplicates[weights]], "Counts" -> Counts[weights]|>
];

localFacetAudit[normal_List, s1_, s2_] := Module[
  {q, rules, points, weights, minimum, leading, differences},
  q = Expand @ Numerator @ Together[
    (fPhysical + uPolynomial) /. dissectionRules /.
      {sigma1 -> s1, sigma2 -> s2}
  ];
  rules = CoefficientRules[q, Append[localVars, eps]];
  points = First /@ rules;
  weights = (Most[#].normal + Last[#]) & /@ points;
  minimum = Min[weights];
  leading = DeleteDuplicates @ Pick[points, weights, minimum];
  differences = If[Length[leading] <= 1, {},
    (# - First[leading]) & /@ Rest[leading]
  ];
  <|
    "Normal" -> normal,
    "LeadingWeight" -> minimum,
    "LeadingPointCount" -> Length[leading],
    "LeadingAffineRank" -> MatrixRank[differences],
    "LowerFacetQ" -> MatrixRank[differences] == Length[localVars]
  |>
];

sectorRows = Flatten @ Table[
  <|
    "Sector" -> {s1, s2},
    "F" -> localWeightData[fPhysical /. {sigma1 -> s1, sigma2 -> s2}],
    "U" -> localWeightData[uPolynomial /. {sigma1 -> s1, sigma2 -> s2}]
  |>,
  {s1, {-1, 1}}, {s2, {-1, 1}}
];

primitiveLiftRows = Table[
  <|
    "TransverseWeightSplit" -> t,
    "Interpretation" -> Which[
      t == 0, "only the second cancellation factor is parametrically small",
      t == 1, "only the first cancellation factor is parametrically small",
      True, "both cancellation factors are parametrically small"
    ],
    "Sectors" -> Table[
      localFacetAudit[{-1, -1, -1 + t, 0, -1, -t}, s1, s2],
      {s1, {-1, 1}}, {s2, {-1, 1}}
    ]
  |>,
  {t, {0, 1/2, 1}}
];

storedTotalAudit = originalLPAudit[storedTotal];
primitiveRelativeAudit = originalLPAudit[primitiveRelativeCandidate];
dissectedPullbackAudit = originalLPAudit[dissectedPullback];

result = <|
  "BaseFaceVector" -> AssociationThread[vars, baseFace],
  "BaseHRFVector" -> AssociationThread[vars, baseHRF],
  "StoredTotalVector" -> AssociationThread[vars, storedTotal],
  "UniformShiftRuns" -> shiftRows,
  "CovariantTotalsIdenticalQ" -> SameQ @@ Lookup[shiftRows, "CovariantTotalVector"],
  "CurrentTotalsIdenticalQ" -> SameQ @@ Lookup[shiftRows, "CurrentTotalVector"],
  "StoredTotalAudit" -> storedTotalAudit,
  "PrimitiveRelativeCandidateAudit" -> primitiveRelativeAudit,
  "PrimitiveRelativeWHRRankAudit" -> originalWHRRankAudit[primitiveRelativeAudit],
  "PrimitiveRelativePinchLayerAudit" ->
    pinchLayerAudit[primitiveRelativeCandidate, {-2, -1, 0}],
  "DissectedPullbackAudit" -> dissectedPullbackAudit,
  "DissectedPullbackPinchLayerAudit" ->
    pinchLayerAudit[dissectedPullback, {-4, -3, -2}],
  "DissectionLocalNormal" -> AssociationThread[localVars, localNormal],
  "DissectionSectorWeightData" -> sectorRows,
  "PrimitiveRelativeLocalLiftAudits" -> primitiveLiftRows,
  "DissectedCommonPinchFacetAudits" -> Table[
    localFacetAudit[localNormal, s1, s2],
    {s1, {-1, 1}}, {s2, {-1, 1}}
  ],
  "Findings" -> {
    "The selected F face is invariant under a uniform shift of its alignment vector.",
    "The current staged runner receives the identical face polynomial and unweighted U in every shifted run, so it returns the same HRF vector instead of the compensating shifted vector.",
    "The mathematically covariant combination f+c+h-c is invariant.",
    "With the arbitrary choice c=2, the current non-covariant total is the primitive relative vector and its original-coordinate W_HR support has full rank, so even the scalefulness decision depends on the alignment representative.",
    "Both the primitive relative candidate and the dissected pullback have original-LP hierarchy gap one; the factor two is not a doubling of W_HR-W_SL.",
    "For the primitive relative vector, the local lift in which both cancellation factors are small has rank four and is not a facet; the two endpoint lifts are facets but suppress only one cancellation factor at a time.",
    "For the factor-two pullback, both the nominal W_SL=-4 layer and the next W=-3 layer vanish on the common pinch; W=-2 is the first nonvanishing layer.",
    "The factor-two dissected lift suppresses both cancellation factors and is a full facet with F and U simultaneously leading at weight -2 in all four sign sectors."
  }
|>;

outputFile = FileNameJoin[{
  repoDirectory, "results", "generated",
  "dsc_one_loop_uniform_shift_audit.wl"
}];
If[! DirectoryQ[DirectoryName[outputFile]],
  CreateDirectory[DirectoryName[outputFile],
    CreateIntermediateDirectories -> True]
];
Export[outputFile, result, "Package"];

Print[InputForm @ KeyTake[result, {
  "BaseFaceVector", "BaseHRFVector", "StoredTotalVector",
  "CovariantTotalsIdenticalQ", "CurrentTotalsIdenticalQ"
}]];
Print[InputForm @ (KeyTake[#, {
  "UniformShift", "FacePolynomialIdenticalQ", "CurrentHRFVector",
  "CovarianceRequiredHRFVector", "CurrentTotalVector", "CovariantTotalVector",
  "CurrentGap"
}] & /@ shiftRows)];
Print[InputForm @ KeyTake[result, {
  "StoredTotalAudit", "PrimitiveRelativeCandidateAudit",
  "PrimitiveRelativeWHRRankAudit", "PrimitiveRelativePinchLayerAudit",
  "DissectedPullbackAudit", "DissectedPullbackPinchLayerAudit",
  "DissectionSectorWeightData", "PrimitiveRelativeLocalLiftAudits",
  "DissectedCommonPinchFacetAudits"
}]];
Print["Output: ", outputFile];
