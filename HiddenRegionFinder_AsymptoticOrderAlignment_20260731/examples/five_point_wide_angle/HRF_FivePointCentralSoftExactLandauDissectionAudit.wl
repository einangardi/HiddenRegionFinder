(* Exact lower-facet audit of the five-point central-soft LP polynomial in
   local coordinates about its moving positive stationary point.  This is a
   discovery diagnostic: it does not assume an alignment face or a maximum
   number of HRF generators. *)

$HistoryLength = 0;
base = DirectoryName[$InputFileName];
repo = DirectoryName[DirectoryName[base]];
$HRFPackageDirectory = repo;
$HRFQuietReports = True;
Get[FileNameJoin[{repo, "HiddenRegionFinder.wl"}]];

$HRF5WALandshoffAuditLibraryOnly = True;
Get[FileNameJoin[{base, "HRF_FivePointWideAngleLandshoffAllLayerAudit.wl"}]];
wideAngle = hrf5WALandshoffAllLayerAudit[];
symmetric = wideAngle["InvariantSymmetricForm"];

$HRF5MRKRepoDirectory = repo;
$HRF5MRKLibraryOnly = True;
Get[FileNameJoin[{DirectoryName[base], "five_point_mrk_central_soft",
  "HRF_FivePointMRKExploratory.wl"}]];
data = hrf5MRKSeedData[{1, 2, 3, 5, 4}];
rules = hrf5MRKExactCentralSoftRules[1, 2, 1];

vars = {x0, x1, x2, x3, x4, x5};
localVars = {x1, x3, x5, yA, yB, yC};
allVars = Append[localVars, delta];

qValues = Together[Values[symmetric["QuadraticCoefficients"]] /. rules];
rhoValues = Together[symmetric["StationaryRatioVector"] /. rules];
stationaryValue = Together[symmetric["StationaryValue"] /. rules];

localRules = {
  x0 -> rhoValues[[1]] x1 + yA,
  x2 -> rhoValues[[2]] x3 + yB,
  x4 -> rhoValues[[3]] x5 + yC
};

(* Use the exact stationary decomposition rather than expanding F first. *)
localF = Together[
  qValues[[1]] x5 yA yB + qValues[[2]] x1 yB yC +
  qValues[[3]] x3 yC yA + x1 x3 x5 stationaryValue
];
localU = Together[data["U"] /. localRules];
localLP = Together[localF + localU];
localPolynomial = Expand[Numerator[localLP]];
localDenominator = Factor[Denominator[localLP]];

originalLP = Together[Expand[data["F"] /. rules] + data["U"]];
originalPolynomial = Expand[Numerator[originalLP]];
originalAllVars = Append[vars, delta];
originalPoints = DeleteDuplicates[
  First /@ Select[CoefficientRules[originalPolynomial, originalAllVars],
    ! TrueQ[Factor[Together[Last[#]]] === 0] &]
];

coefficientRules = CoefficientRules[localPolynomial, allVars];
coefficientRules = Select[coefficientRules,
  ! TrueQ[Factor[Together[Last[#]]] === 0] &];
points = DeleteDuplicates[First /@ coefficientRules];
affineDimension = MatrixRank[(# - First[points]) & /@ Rest[points]];

(* qconvex returns outward facet normals followed by their offsets. *)
qhullInput = StringRiffle[
  Join[{ToString[Length[allVars]], ToString[Length[points]]},
    (StringRiffle[ToString /@ #, " "] & /@ points)], "\n"] <> "\n";
qhull = RunProcess[{"qconvex", "n"}, All, qhullInput];
If[qhull["ExitCode"] =!= 0,
  Print[qhull["StandardError"]]; Exit[1]
];
qhullLines = Select[StringTrim /@ StringSplit[qhull["StandardOutput"], "\n"],
  # =!= "" &];
qhullNormals = ToExpression /@ (StringSplit /@ Drop[qhullLines, 2]);
lowerOutwardNormals = Select[qhullNormals, #[[Length[allVars]]] < -10^-9 &];

candidateNormals = DeleteDuplicates[
  Rationalize[Take[#, Length[allVars]]/#[[Length[allVars]]], 10^-7] & /@
    lowerOutwardNormals
];

ClearAll[facetRow];
facetRow[normal_List] := Module[
  {weights, minimum, leading, rank, pathWeights, rhoOrders,
   normalWeights, originalWeights, restrictedMask, restrictedQ,
   originalNormal, originalPointWeights, originalMinimum,
   originalLeading, originalRank, originalFacetQ},
  weights = points.normal;
  minimum = Min[weights];
  leading = Pick[points, weights, minimum];
  rank = If[Length[leading] <= 1, 0,
    MatrixRank[(# - First[leading]) & /@ Rest[leading]]];
  pathWeights = Take[normal, 3];
  rhoOrders = {1, 3, 1};
  normalWeights = normal[[4 ;; 6]];
  originalWeights = {
    Min[pathWeights[[1]] + rhoOrders[[1]], normalWeights[[1]]],
    pathWeights[[1]],
    Min[pathWeights[[2]] + rhoOrders[[2]], normalWeights[[2]]],
    pathWeights[[2]],
    Min[pathWeights[[3]] + rhoOrders[[3]], normalWeights[[3]]],
    pathWeights[[3]]
  };
  restrictedMask = Thread[normalWeights > pathWeights + rhoOrders];
  restrictedQ = And @@ restrictedMask;
  originalNormal = Append[originalWeights, 1];
  originalPointWeights = originalPoints.originalNormal;
  originalMinimum = Min[originalPointWeights];
  originalLeading = Pick[originalPoints, originalPointWeights, originalMinimum];
  originalRank = If[Length[originalLeading] <= 1, 0,
    MatrixRank[(# - First[originalLeading]) & /@ Rest[originalLeading]]];
  originalFacetQ = TrueQ[originalRank == Length[vars]];
  <|
    "LocalNormal" -> normal,
    "LeadingWeight" -> minimum,
    "LeadingPointCount" -> Length[leading],
    "AffineRank" -> rank,
    "LowerFacetQ" -> TrueQ[rank == Length[localVars]],
    "PathWeights" -> pathWeights,
    "MovingLandauRatioOrders" -> rhoOrders,
    "NormalWeights" -> normalWeights,
    "RestrictedNormalMask" -> restrictedMask,
    "AtLeastOneNormalRestrictedQ" -> Or @@ restrictedMask,
    "AllThreeNormalsRestrictedQ" -> restrictedQ,
    "PulledBackOriginalWeights" -> originalWeights,
    "OriginalCoordinateLeadingPointCount" -> Length[originalLeading],
    "OriginalCoordinateAffineRank" -> originalRank,
    "OriginalCoordinateLowerFacetQ" -> originalFacetQ,
    "HiddenAfterPullbackQ" ->
      TrueQ[rank == Length[localVars]] && Or @@ restrictedMask &&
        ! originalFacetQ,
    "LeadingPoints" -> leading
  |>
];

facetRows = facetRow /@ candidateNormals;
fullLowerFacets = Select[facetRows, TrueQ[# ["LowerFacetQ"]] &];
landauRestrictedFacets = Select[fullLowerFacets,
  TrueQ[# ["AllThreeNormalsRestrictedQ"]] &];
hiddenPullbackFacets = Select[fullLowerFacets,
  TrueQ[# ["HiddenAfterPullbackQ"]] &];

result = <|
  "KinematicPath" -> <|"a" -> 1, "b" -> 2, "sigma" -> 1|>,
  "PhysicalAssumptions" ->
    P > 0 && M > 0 && K > 0 && R > 0 && T > 0 && C > 0 && C^2 < 4 R T,
  "MovingStationaryRatios" -> rhoValues,
  "MovingStationaryRatioLeadingOrders" -> {1, 3, 1},
  "LocalVariables" -> localVars,
  "LocalRules" -> localRules,
  "LocalF" -> localF,
  "LocalU" -> localU,
  "LocalLPDenominator" -> localDenominator,
  "LocalLPPolynomial" -> localPolynomial,
  "ExponentPointCount" -> Length[points],
  "AffineDimension" -> affineDimension,
  "QHullFacetCount" -> Length[qhullNormals],
  "LowerFacetCandidateCount" -> Length[candidateNormals],
  "FullLowerFacetCount" -> Length[fullLowerFacets],
  "LandauRestrictedLowerFacetCount" -> Length[landauRestrictedFacets],
  "HiddenPullbackFacetCount" -> Length[hiddenPullbackFacets],
  "FullLowerFacets" -> fullLowerFacets,
  "LandauRestrictedLowerFacets" -> landauRestrictedFacets,
  "HiddenPullbackFacets" -> hiddenPullbackFacets
|>;

Print[InputForm[KeyDrop[result,
  {"LocalF", "LocalU", "LocalLPPolynomial", "MovingStationaryRatios",
   "FullLowerFacets"}]]];
If[landauRestrictedFacets =!= {},
  Print["Landau-restricted lower facets:"];
  Print[InputForm[landauRestrictedFacets]]
];
If[hiddenPullbackFacets =!= {},
  Print["Hidden facets after pullback:"];
  Print[InputForm[hiddenPullbackFacets]]
];

Export[FileNameJoin[{base,
  "five_point_central_soft_exact_landau_dissection_audit.wl"}],
  result, "Package"];
