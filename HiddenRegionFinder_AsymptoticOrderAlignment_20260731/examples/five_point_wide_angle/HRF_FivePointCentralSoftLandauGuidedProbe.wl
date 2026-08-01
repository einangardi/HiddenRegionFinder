(* Probe the asymptotic-order alignment vector obtained by degenerating the
   exact positive wide-angle Landau family into the central-soft chart. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
repo = DirectoryName[DirectoryName[base]];
$HRFPackageDirectory = repo;
$HRFQuietReports = True;
Get[FileNameJoin[{repo, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{repo, "HRF_AsymptoticOrderAlignment.wl"}]];
$HRF5MRKRepoDirectory = repo;
$HRF5MRKLibraryOnly = True;
Get[FileNameJoin[{DirectoryName[base], "five_point_mrk_central_soft",
  "HRF_FivePointMRKExploratory.wl"}]];

data = hrf5MRKSeedData[{1, 2, 3, 5, 4}];
rules = hrf5MRKExactCentralSoftRules[1, 2, 1];
expr = Together[data["F"] /. rules];
vars = data["Variables"];
termData = hrfAsymptoticOrderAlignmentTermTable[expr, vars, delta];

(* The overall shift is irrelevant to the ratios.  Choosing h=-3 sets the
   largest entry to zero. *)
landauAlignmentVector = {-2, -3, 0, -3, -2, -3};
face = hrfAsymptoticOrderAlignmentFaceFromVector[
  termData, vars, landauAlignmentVector, Identity
];

assumptions = P > 0 && M > 0 && K > 0 && R > 0 && T > 0 && C > 0 &&
  C^2 < 4 R T;
row = hrfAsymptoticOrderAlignmentFaceScanRow[
  face, vars,
  "RunHRFQ" -> True,
  "KinematicAssumptions" -> assumptions,
  "KinematicVariables" -> {P, M, K, R, T, C},
  "MandelstamVariables" -> {},
  "DisableMandelstamLinearityForChartVariablesQ" -> True,
  "U" -> data["U"],
  "HRFOptions" -> {
    "MaxGenerators" -> 4,
    "CandidateGeneratorSetLimit" -> Infinity,
    "MaxTwoGeneratorUnionTrials" -> Infinity,
    "MaxScalingAbs" -> 12
  }
];
totalAudit = hrfAsymptoticOrderAlignmentTotalLowerFacetAudit[
  row, termData, vars, data["U"], Identity, delta
];
(* The face polynomial is cubic whereas U is quadratic.  Restoring the
   native face intercept fixes the uniform HRF component to -2, not the -1
   obtained when the aligned face is passed to HRF without its explicit
   delta weight. *)
covNative = row["HRFSummary", "CoverageScalingData"];
covRestored = Join[covNative, <|
  "Scaling" -> ConstantArray[-2, Length[vars]],
  "RationalScaling" -> ConstantArray[-2, Length[vars]],
  "RationalScalingWithUnitGap" -> ConstantArray[-2, Length[vars]],
  "VariableScaling" -> AssociationThread[vars, ConstantArray[-2, Length[vars]]]
|>];
rowRestored = Join[row, <|"HRFSummary" -> Join[row["HRFSummary"], <|
  "CoverageScalingData" -> covRestored
|>]|>];
totalAuditRestored = hrfAsymptoticOrderAlignmentTotalLowerFacetAudit[
  rowRestored, termData, vars, data["U"], Identity, delta
];

(* Manual local dissection of the two cancellation factors.  In the aligned
   variables use yA=P x2-K x3 and yB=x1 x4-x0 x5.  The symmetric half-depth
   promotion raises their product by one order. *)
faceRules = Thread[vars -> MapThread[delta^#1 #2 &, {landauAlignmentVector, vars}]];
alignedLP = Together[(data["U"] + expr) /. faceRules];
localRules = {
  x2 -> (K x3 + yA)/P,
  x0 -> (x1 x4 - yB)/x5
};
localNumerator = Expand[Numerator[Together[alignedLP /. localRules]]];
localVars = {x1, x3, x4, x5, yA, yB};
localScaling = {-2, -2, -2, -2, -3/2, -7/2};
localTerms = List @@ localNumerator;
localRows = (Table[Exponent[#, v], {v, localVars}] &) /@ localTerms;
localEtaPowers = Exponent[#, delta] & /@ localTerms;
localWeights = MapThread[#1.#2 + #3 &,
  {localRows, ConstantArray[localScaling, Length[localRows]], localEtaPowers}];
localMinWeight = Min[localWeights];
localLeadingAugmentedRows = DeleteDuplicates @ MapThread[Append[#1, #2] &,
  {Pick[localRows, localWeights, localMinWeight],
   Pick[localEtaPowers, localWeights, localMinWeight]}];
localAffineRank = If[Length[localLeadingAugmentedRows] <= 1, 0,
  MatrixRank[(# - First[localLeadingAugmentedRows]) & /@
    Rest[localLeadingAugmentedRows]]
];
localFacetQ = TrueQ[localAffineRank == Length[localVars]];

(* On the transverse-coplanar boundary C^2=4 R T, introduce all three
   Landau-normal coordinates. *)
coplanarAlignedLP = alignedLP /. {T -> t^2, R -> r^2, C -> 2 r t};
threeNormalRules = {
  x0 -> (r x1 + y0)/t,
  x2 -> (K x3 + y2)/P,
  x4 -> (r x5 + y4)/t
};
threeNormalPolynomial = Expand[
  Numerator[Together[coplanarAlignedLP /. threeNormalRules]]
];
threeNormalVars = {x1, x3, x5, y0, y2, y4};
threeNormalScaling = {-2, -2, -2, -3/2, -3/2, -3/2};
threeNormalTerms = List @@ threeNormalPolynomial;
threeNormalRows = (Table[Exponent[#, v], {v, threeNormalVars}] &) /@
  threeNormalTerms;
threeNormalEtaPowers = Exponent[#, delta] & /@ threeNormalTerms;
threeNormalWeights = MapThread[#1.#2 + #3 &,
  {threeNormalRows,
   ConstantArray[threeNormalScaling, Length[threeNormalRows]],
   threeNormalEtaPowers}];
threeNormalMinWeight = Min[threeNormalWeights];
threeNormalLeadingRows = DeleteDuplicates @ MapThread[Append[#1, #2] &,
  {Pick[threeNormalRows, threeNormalWeights, threeNormalMinWeight],
   Pick[threeNormalEtaPowers, threeNormalWeights, threeNormalMinWeight]}];
threeNormalAffineRank = If[Length[threeNormalLeadingRows] <= 1, 0,
  MatrixRank[(# - First[threeNormalLeadingRows]) & /@
    Rest[threeNormalLeadingRows]]
];
threeNormalFacetQ = TrueQ[threeNormalAffineRank == Length[threeNormalVars]];

Print[InputForm[KeyTake[face,
  {"Scaling", "Weight", "Indices", "EtaPowers", "TermCount", "Polynomial"}
]]];
Print[InputForm[<|
  "HRFSummary" -> row["HRFSummary"],
  "TotalAudit" -> KeyTake[totalAudit,
    {"AuditStatus", "TotalLowerFacetQ", "TotalScaling",
      "RelativeTotalScaling", "WSL", "WHR", "CertificationMethod"}]
  , "NativeWeightRestoredAudit" -> KeyTake[totalAuditRestored,
    {"AuditStatus", "TotalLowerFacetQ", "TotalScaling",
      "RelativeTotalScaling", "WSL", "WHR", "CertificationMethod"}]
  , "LocalDissectionAudit" -> <|
    "Variables" -> localVars,
    "Scaling" -> localScaling,
    "LeadingWeight" -> localMinWeight,
    "LeadingPointCount" -> Length[localLeadingAugmentedRows],
    "AffineRank" -> localAffineRank,
    "RequiredRank" -> Length[localVars],
    "LowerFacetQ" -> localFacetQ
  |>
  , "CoplanarThreeNormalAudit" -> <|
    "Variables" -> threeNormalVars,
    "Scaling" -> threeNormalScaling,
    "LeadingWeight" -> threeNormalMinWeight,
    "LeadingPointCount" -> Length[threeNormalLeadingRows],
    "AffineRank" -> threeNormalAffineRank,
    "RequiredRank" -> Length[threeNormalVars],
    "LowerFacetQ" -> threeNormalFacetQ
  |>
|>]];
Export[FileNameJoin[{base,
  "five_point_central_soft_landau_guided_face.wl"}],
  <|"AlignmentVector" -> landauAlignmentVector, "Face" -> face,
    "TermData" -> termData, "U" -> data["U"], "Row" -> row,
    "TotalAudit" -> totalAudit,
    "NativeWeightRestoredAudit" -> totalAuditRestored,
    "LocalDissection" -> <|"Variables" -> localVars,
      "Scaling" -> localScaling, "Polynomial" -> localNumerator,
      "LeadingWeight" -> localMinWeight,
      "LeadingAugmentedRows" -> localLeadingAugmentedRows,
      "AffineRank" -> localAffineRank, "LowerFacetQ" -> localFacetQ|>
    , "CoplanarThreeNormalDissection" -> <|
      "Variables" -> threeNormalVars,
      "Scaling" -> threeNormalScaling,
      "Polynomial" -> threeNormalPolynomial,
      "LeadingWeight" -> threeNormalMinWeight,
      "LeadingAugmentedRows" -> threeNormalLeadingRows,
      "AffineRank" -> threeNormalAffineRank,
      "LowerFacetQ" -> threeNormalFacetQ|>
  |>, "Package"];
