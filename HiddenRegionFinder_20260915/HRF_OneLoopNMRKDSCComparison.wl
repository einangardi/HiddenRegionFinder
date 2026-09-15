$HistoryLength = 0;

repoDirectory = DirectoryName[$InputFileName];
SetDirectory[repoDirectory];

$HRFQuietReports = True;
Get[FileNameJoin[{repoDirectory, "HiddenRegionFinder.wl"}]];

ClearAll[
  comparisonTerms, comparisonTotalScaling, comparisonULayers,
  comparisonFLayers, comparisonLeadingData, comparisonScalingSymmetryAudit,
  nmrkChartTransform
];

comparisonTerms[p_] := With[{q = Expand[p]},
  If[TrueQ[q === 0], {}, If[Head[q] === Plus, List @@ q, {q}]]
];

comparisonTotalScaling[row_Association, vars_List] := Module[
  {face, hrf, zero, audit, certified},
  audit = Lookup[row, "TotalScalingAudit", <||>];
  certified = Lookup[audit, "TotalScaling", <||>];
  If[AssociationQ[certified] && AllTrue[vars, KeyExistsQ[certified, #] &],
    Return[KeyTake[certified, vars]]
  ];
  face = AssociationThread[vars, row["Scaling"]];
  hrf = Lookup[
    row["HRFSummary"]["CoverageScalingData"], "VariableScaling", <||>
  ];
  zero = Lookup[row, "PreselectionZeroVars", {}];
  Association @ Table[
    v -> If[MemberQ[zero, v], Missing["BoundaryZero"],
      Lookup[face, v, 0] + Lookup[hrf, v, 0]],
    {v, vars}
  ]
];

comparisonFLayers[scan_Association, total_Association, transform_] := Module[
  {vars, vector, data, weights, grouped},
  vars = scan["Variables"];
  vector = Lookup[total, vars];
  data = scan["TermData"];
  weights = (#["EtaPower"] + #["XRow"].vector &) /@ data;
  grouped = GroupBy[MapThread[#1 -> #2 &, {weights, data}], First -> Last];
  Association @ KeyValueMap[
    #1 -> Factor[transform[Total[Lookup[#2, "CoeffNoEta", {}]]]] &,
    KeySort[grouped]
  ]
];

comparisonULayers[uPoly_, vars_List, total_Association] := Module[
  {vector, rules, grouped},
  vector = Lookup[total, vars];
  rules = CoefficientRules[Expand[uPoly], vars];
  grouped = GroupBy[
    rules,
    (First[#].vector) & ->
      (Last[#] Times @@ MapThread[Power, {vars, First[#]}] &)
  ];
  Association @ KeyValueMap[#1 -> Factor[Total[#2]] &, KeySort[grouped]]
];

comparisonLeadingData[label_, scan_Association, row_Association, uPoly_,
    transform_] := Module[
  {vars, total, vector, numerical, relative, fLayers, uLayers, wSL,
   postWeights, wHR, fsl, ratio, ratioXFreeQ, blueF, blueU, blackF,
   blackU, termData, fWeights, uRules, uWeights, redRows, blueFRows,
   blueURows},
  vars = scan["Variables"];
  total = comparisonTotalScaling[row, vars];
  vector = Lookup[total, vars];
  numerical = Cases[Values[total], _Integer | _Rational];
  relative = Association @ KeyValueMap[
    #1 -> If[MissingQ[#2], #2, #2 - Max[numerical]] &,
    total
  ];
  fLayers = comparisonFLayers[scan, total, transform];
  uLayers = comparisonULayers[uPoly, vars, total];
  wSL = Lookup[Lookup[row, "TotalScalingAudit", <||>],
    "WSL", Min[Keys[fLayers]]
  ];
  postWeights = Join[Select[Keys[fLayers], # > wSL &], Keys[uLayers]];
  wHR = Lookup[Lookup[row, "TotalScalingAudit", <||>],
    "WHR", Min[postWeights]
  ];
  fsl = Factor[row["HRFScan"]["ObstructionData"]["Superleading"]];
  ratio = Factor[Together[fLayers[wSL]/fsl]];
  ratioXFreeQ = FreeQ[ratio, Alternatives @@ vars];
  blueF = Lookup[fLayers, wHR, 0];
  blueU = Lookup[uLayers, wHR, 0];
  blackF = KeySelect[fLayers, # > wHR &];
  blackU = KeySelect[uLayers, # > wHR &];
  termData = scan["TermData"];
  fWeights = (#["EtaPower"] + #["XRow"].vector &) /@ termData;
  redRows = DeleteDuplicates @ Pick[Lookup[termData, "XRow"], fWeights, wSL];
  blueFRows = DeleteDuplicates @ Pick[Lookup[termData, "XRow"], fWeights, wHR];
  uRules = CoefficientRules[Expand[uPoly], vars];
  uWeights = (First[#].vector &) /@ uRules;
  blueURows = DeleteDuplicates @ Pick[First /@ uRules, uWeights, wHR];
  <|
    "Label" -> label,
    "Variables" -> vars,
    "FaceScaling" -> AssociationThread[vars, row["Scaling"]],
    "HRFScaling" -> row["HRFSummary"]["CoverageScalingData"]["VariableScaling"],
    "TotalScaling" -> total,
    "RelativeTotalScaling" -> relative,
    "WSL" -> wSL,
    "WHR" -> wHR,
    "HierarchyGap" -> wHR - wSL,
    "IntermediateVanishingLayers" -> Lookup[
      FirstCase[
        Join[
          Lookup[
            Lookup[Lookup[row, "TotalScalingAudit", <||>],
              "IdealLayerCertification", <||>],
            "Certificates", {}
          ],
          Lookup[
            Lookup[Lookup[row, "TotalScalingAudit", <||>],
              "LayeredDissectionCertification", <||>],
            "Certificates", {}
          ]
        ],
        a_Association :> a,
        <||>
      ],
      "IntermediateVanishingLayers", {}
    ],
    "SingularHypersurfaceFactors" -> row["HRFSummary"]["CancellationFactors"],
    "Generator" -> row["HRFSummary"]["Generators"],
    "FSL" -> fsl,
    "RedPolynomial" -> fLayers[wSL],
    "RedMatchesFSLUpToXFreeFactorQ" -> ratioXFreeQ,
    "RedToFSLRatio" -> ratio,
    "RedFMonomialRows" -> redRows,
    "BlueFPolynomial" -> blueF,
    "BlueFMonomialRows" -> blueFRows,
    "BlueUPolynomial" -> blueU,
    "BlueUMonomialRows" -> blueURows,
    "BlackFLayers" -> blackF,
    "BlackULayers" -> blackU,
    "FLayers" -> fLayers,
    "ULayers" -> uLayers
  |>
];

comparisonScalingSymmetryAudit[scan_Association, uPoly_, vector_List,
    transform_] := Module[
  {vars, termData, fWeights, wSL, postIndices, uRules, uWeights, wHR,
   blueFIndices, blueFRows, blueURules, blueURows, leadingRows, differences,
   nullSpace, blueF, blueU},
  vars = scan["Variables"];
  termData = scan["TermData"];
  fWeights = (#["EtaPower"] + #["XRow"].vector &) /@ termData;
  wSL = Min[fWeights];
  postIndices = Select[Range[Length[termData]], fWeights[[#]] > wSL &];
  uRules = CoefficientRules[Expand[uPoly], vars];
  uWeights = (First[#].vector &) /@ uRules;
  wHR = Min[Join[fWeights[[postIndices]], uWeights]];
  blueFIndices = Select[postIndices, fWeights[[#]] == wHR &];
  blueFRows = DeleteDuplicates[termData[[blueFIndices, "XRow"]]];
  blueURules = Pick[uRules, uWeights, wHR];
  blueURows = DeleteDuplicates[First /@ blueURules];
  leadingRows = Join[blueFRows, blueURows];
  differences = If[Length[leadingRows] <= 1, {},
    (# - First[leadingRows]) & /@ Rest[leadingRows]
  ];
  nullSpace = If[differences === {}, IdentityMatrix[Length[vars]],
    NullSpace[differences]
  ];
  blueF = Factor @ transform @ Total[
    Lookup[termData[[blueFIndices]], "CoeffNoEta", {}]
  ];
  blueU = Factor @ Total[
    (Last[#] Times @@ MapThread[Power, {vars, First[#]}] &) /@ blueURules
  ];
  <|
    "Vector" -> AssociationThread[vars, vector],
    "RelativeVector" -> AssociationThread[vars, vector - Max[vector]],
    "WSL" -> wSL,
    "WHR" -> wHR,
    "BlueFMonomialRows" -> blueFRows,
    "BlueUMonomialRows" -> blueURows,
    "BlueFPolynomial" -> blueF,
    "BlueUPolynomial" -> blueU,
    "LeadingExponentRows" -> leadingRows,
    "LeadingExponentAffineRank" -> MatrixRank[differences],
    "QuasiHomogeneousScalingNullSpace" -> nullSpace,
    "MonomialRescalingSymmetryQ" -> (nullSpace =!= {})
  |>
];

nmrkChartTransform[p_] := Module[{q},
  q = Factor[p /. {q1*q1b -> Q, q1b*q1 -> Q}];
  q = q /. {
    (1 - z)*(1 - zb) -> Kz, (1 - zb)*(1 - z) -> Kz,
    (-1 + z)*(-1 + zb) -> Kz, (-1 + zb)*(-1 + z) -> Kz
  };
  q = Expand[q] /. {
    z*zb -> Kz + z + zb - 1, zb*z -> Kz + z + zb - 1
  };
  q = Expand[q] /. {
    1 - z - zb + z*zb -> Kz,
    1 - zb - z + z*zb -> Kz,
    z*zb - z - zb + 1 -> Kz
  };
  Factor[q]
];

nmrkScan = Import[
  FileNameJoin[{repoDirectory, "testdata", "alignment",
    "nmrk_wz_one_loop_hexagon_scan.wl"}],
  "WL"
];
nmrkData = Import[
  FileNameJoin[{repoDirectory, "data", "nmrk",
    "one_loop_hexagon_kinematics.wl"}],
  "WL"
];
nmrkRow = First[nmrkScan["DeduplicatedHiddenRegionRows"]];
nmrkComparison = comparisonLeadingData[
  "w=z NMRK", nmrkScan, nmrkRow, nmrkData["U"], nmrkChartTransform
];

dscResult = Import[
  FileNameJoin[{repoDirectory, "testdata", "alignment",
    "dsc_one_loop_hexagon_scan.wl"}],
  "WL"
];
dscScan = dscResult["Scan"];
dscRows = Lookup[dscScan, "DeduplicatedHiddenRegionRows", {}];
If[dscRows === {},
  dscRows = Lookup[dscScan, "StagedDeduplicatedHiddenRegionRows", {}]
];
dscRow = First[dscRows];
dscRecertified = Import[
  FileNameJoin[{repoDirectory, "results", "facet_recertified_DSC_hexagon.wl"}],
  "WL"
];
If[Lookup[dscRecertified, "FinalRepresentatives", {}] =!= {},
  dscRow = Join[dscRow, <|
    "TotalScalingAudit" ->
      First[dscRecertified["FinalRepresentatives"]]["TotalScalingAudit"]
  |>]
];
dscU = SymanzikUF[
  dscResult["Graph"]["InternalLines"], dscResult["Graph"]["ExternalLines"]
]["U"];
dscComparison = comparisonLeadingData[
  "generic DSC", dscScan, dscRow, dscU, Factor
];

pinchDictionary = {
  Kz*X45*X56h/(1 + X45) -> -tau1/(1 + tau1),
  X34h*X45/(1 + X45) -> -1/(1 + tau2)
};

result = <|
  "NMRK" -> nmrkComparison,
  "DSC" -> dscComparison,
  "PinchDictionary" -> pinchDictionary,
  "DSCStoredComposedVectorAudit" -> comparisonScalingSymmetryAudit[
    dscScan, dscU, Lookup[dscComparison["TotalScaling"], dscScan["Variables"]],
    Factor
  ],
  "DSCScalefulAlternativeAudit" -> comparisonScalingSymmetryAudit[
    dscScan, dscU, {-2, -1, -1, 0, -2, -2}, Factor
  ]
|>;

outputFile = FileNameJoin[{
  repoDirectory, "results", "one_loop_NMRK_DSC_weight_comparison.wl"
}];
Export[outputFile, result, "Package"];

Print["NMRK summary: ", InputForm @ KeyTake[nmrkComparison, {
  "TotalScaling", "RelativeTotalScaling", "WSL", "WHR", "HierarchyGap",
  "SingularHypersurfaceFactors", "RedMatchesFSLUpToXFreeFactorQ"
}]];
Print["DSC summary: ", InputForm @ KeyTake[dscComparison, {
  "TotalScaling", "RelativeTotalScaling", "WSL", "WHR", "HierarchyGap",
  "SingularHypersurfaceFactors", "RedMatchesFSLUpToXFreeFactorQ"
}]];
Print["Output: ", outputFile];
