(* ::Title:: *)
(*K_{4,3}: exact wide-angle Landshoff hidden-region audit*)

(*
  This audit constructs the massless K_{4,3} graph directly from its
  spanning trees and spanning two-forests.  The four external momenta are
  attached to the four-vertex partition; the three-vertex partition is
  internal.  Edge variables are ordered row by row,

      x0=x_{11}, x1=x_{12}, x2=x_{13}, ... , x11=x_{43}.

  The on-shell expansion is p_i^2 = delta mu_i with generic positive mu_i.
  The script certifies:

    1. F0 and Grad[F0] vanish on the positive rank-one locus x_{ia}=u_i w_a;
    2. the six independent cycle-ratio normals have a non-degenerate
       quadratic form throughout s12 > -s23 > 0;
    3. x_{ia}~delta^(-1), R_{ia}-1~delta^(1/2) makes U, delta F1 and the
       cancelled F0 layer all have weight -6;
    4. the leading local Lee--Pomeransky polynomial has no multiplicative
       scaling symmetry beyond the one redundant (u,w) chart coordinate.

  Thus the candidate is scaleful and defines a hidden region.  For unit
  propagator powers in D=4-2 epsilon its parameter-space power is
  delta^(3-6 epsilon).
*)

ClearAll["Global`*"];

$HRFQuietReports = True;
auditDirectory = If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName], Directory[]];
Get[FileNameJoin[{auditDirectory, "HiddenRegionFinder.wl"}]];

ClearAll[assertAudit];
assertAudit[condition_, message_] := If[TrueQ[condition], Null,
  Print["ERROR: " <> message]; Exit[1]];

(* Graph and Symanzik polynomials. *)
internalLines = Flatten[
  Table[{"0", {i, 4 + a}}, {i, 4}, {a, 3}], 1];
externalLines = {{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}};

uf = SymanzikUF[internalLines, externalLines];
vars = uf["Variables"];
uPolynomial = Expand[uf["U"]];
fMassive = toCyclicMandelstams4ptMassive[uf["F"]];

massCoefficients = Array[mu, 4];
onShellRules = Thread[{p1sq, p2sq, p3sq, p4sq} -> delta massCoefficients];
fExpanded = Expand[fMassive /. onShellRules];
f0 = Expand[Coefficient[fExpanded, delta, 0]];
f1 = Expand[Coefficient[fExpanded, delta, 1]];

(* Channel two-forest polynomials.  For four massless external legs,

     F0 = s12 Phi_{12|34} + s23 Phi_{14|23}
          + s13 Phi_{13|24},   s13=-s12-s23.

   This gives a compact, directly combinatorial expression for F_SL=F0. *)
allEdgeIndices = Range[Length[uf["Edges"]]];
canonicalPartition[partition_] := Sort[Sort /@ partition];
externalPartition[forest_] := canonicalPartition[
  (Intersection[#, Range[4]] &) /@
    ConnectedComponents[
      graphFromEdgeIndices[uf["Edges"], uf["Vertices"], forest]]];
channelForestPolynomial[target_] := Expand@Total[
  (Times @@ vars[[Complement[allEdgeIndices, #]]]) & /@
    Select[uf["TwoForests"],
      externalPartition[#] === canonicalPartition[target] &]];

phiS = channelForestPolynomial[{{1, 2}, {3, 4}}];
phiT = channelForestPolynomial[{{1, 4}, {2, 3}}];
phiU = channelForestPolynomial[{{1, 3}, {2, 4}}];

totalDegree[poly_, polynomialVars_] :=
  Exponent[Expand[poly /. Thread[polynomialVars -> zDegree polynomialVars]], zDegree];
squareFreeQ[poly_, polynomialVars_] := Max[Exponent[poly, #] & /@ polynomialVars] <= 1;

assertAudit[Length[vars] == 12, "K_{4,3} must have twelve edge variables."];
assertAudit[Length[MonomialList[uPolynomial, vars]] == 432,
  "Unexpected spanning-tree/complement count for U."];
assertAudit[Length[MonomialList[f0, vars]] == 72,
  "Unexpected on-shell two-forest monomial count for F0."];
assertAudit[totalDegree[uPolynomial, vars] == 6 && totalDegree[f0, vars] == 7,
  "The Symanzik degrees must be L=6 and L+1=7."];
assertAudit[squareFreeQ[uPolynomial, vars] && squareFreeQ[f0, vars],
  "The massless graph polynomials must be multiaffine in the edge variables."];
assertAudit[Exponent[fExpanded, delta] == 1,
  "The chosen on-shell expansion should have only F0+delta F1."];
assertAudit[
  (Length[MonomialList[#, vars]] & /@ {phiS, phiT, phiU}) == {24, 24, 24},
  "Each channel two-forest polynomial should contain 24 monomials."];
assertAudit[
  Expand[f0 - (s12 (phiS - phiU) + s23 (phiT - phiU))] === 0,
  "The channel-forest representation of F_SL=F0 was not reproduced."];

(* Positive rank-one Landau locus. *)
rowScales = Array[u, 4];
columnScales = Array[w, 3];
rankOneRules = Thread[vars -> Flatten@Table[
  rowScales[[i]] columnScales[[a]], {i, 4}, {a, 3}]];

f0OnLocus = Expand[f0 /. rankOneRules];
gradientOnLocus = Expand[# /. rankOneRules] & /@ (D[f0, #] & /@ vars);

assertAudit[f0OnLocus === 0, "F0 does not vanish on the rank-one locus."];
assertAudit[gradientOnLocus === ConstantArray[0, 12],
  "Grad[F0] does not vanish on the rank-one locus."];

channelForestsOnLocus = Factor /@ ({phiS, phiT, phiU} /. rankOneRules);
expectedCommonChannelForest =
  2 Product[u[i], {i, 4}] *
  (u[1] u[2] u[3] + u[1] u[2] u[4] +
    u[1] u[3] u[4] + u[2] u[3] u[4]) *
  Product[w[a]^2, {a, 3}] * (w[1] + w[2] + w[3]);
assertAudit[
  And @@ (Expand[# - expectedCommonChannelForest] === 0 & /@
    channelForestsOnLocus),
  "The three channel forests do not coincide on the rank-one locus."];

(* Six independent cycle ratios.  The fourth row and third column fix the
   row/column rescalings, leaving R_{ia}, i=1,2,3 and a=1,2, as normals. *)
ratioVars = Flatten[Array[r, {3, 2}]];
normalVars = Flatten[Array[y, {3, 2}]];
ratioChartRules = Thread[vars -> Flatten@Table[
  rowScales[[i]] columnScales[[a]]
    If[i <= 3 && a <= 2, r[i, a], 1],
  {i, 4}, {a, 3}]];

f0RatioChart = Expand[f0 /. ratioChartRules];
rankOneRatioRules = Thread[ratioVars -> 1];
ratioGradient = Factor /@
  ((D[f0RatioChart, #] & /@ ratioVars) /. rankOneRatioRules);
ratioHessian = Map[Factor,
  D[f0RatioChart, {ratioVars, 2}] /. rankOneRatioRules, {2}];
ratioHessianDeterminant = Factor[Det[ratioHessian]];

expectedHessianDeterminant =
  4 s12^2 s23^2 (s12 + s23)^2 *
  w[1]^12 w[2]^12 w[3]^12 *
  (w[1] w[2] + w[1] w[3] + w[2] w[3])^3 *
  Product[u[i]^6, {i, 4}] *
  (u[1] u[2] u[3] + u[1] u[2] u[4] +
    u[1] u[3] u[4] + u[2] u[3] u[4])^6;

assertAudit[ratioGradient === ConstantArray[0, 6],
  "The cycle-ratio chart has a nonzero linear layer."];
assertAudit[Factor[ratioHessianDeterminant - expectedHessianDeterminant] === 0,
  "Unexpected determinant of the six-dimensional normal Hessian."];

(* The determinant is strictly nonzero for u_i,w_a>0 and s12>-s23>0.
   A sample point records the real signature without replacing the exact
   determinant certificate. *)
sampleHessian = ratioHessian /. Join[
  {s12 -> 2, s23 -> -1},
  Thread[rowScales -> 1], Thread[columnScales -> 1]];
sampleEigenvalues = N[Eigenvalues[sampleHessian], 12];
sampleSignature = {
  Count[sampleEigenvalues, _?Positive],
  Count[sampleEigenvalues, _?Negative]
};
assertAudit[sampleSignature == {2, 4},
  "Unexpected normal-Hessian signature at the physical sample point."];

(* Local asymptotic chart.  epsilonLocal=sqrt(delta).  The factor
   delta^(-1)=epsilonLocal^(-2) multiplying every x_{ia} is stripped here;
   homogeneity supplies weights -6 for U and -7 for F0/F1. *)
localChartRules = Thread[vars -> Flatten@Table[
  rowScales[[i]] columnScales[[a]]
    If[i <= 3 && a <= 2, 1 + epsilonLocal y[i, a], 1],
  {i, 4}, {a, 3}]];

uOnLocus = Expand[uPolynomial /. localChartRules /. epsilonLocal -> 0];
f1OnLocus = Expand[f1 /. localChartRules /. epsilonLocal -> 0];
f0Local = Expand[f0 /. localChartRules];
f0LocalLayers = Association@Table[
  k -> Expand[Coefficient[f0Local, epsilonLocal, k]], {k, 0, 7}];
normalQuadratic = f0LocalLayers[2];

expectedUOnLocus =
  (w[1] w[2] + w[1] w[3] + w[2] w[3])^3 *
  (u[1] u[2] u[3] + u[1] u[2] u[4] +
    u[1] u[3] u[4] + u[2] u[3] u[4])^2;

assertAudit[Expand[uOnLocus - expectedUOnLocus] === 0,
  "Unexpected U polynomial on the rank-one locus."];
assertAudit[f0LocalLayers[0] === 0 && f0LocalLayers[1] === 0 &&
  normalQuadratic =!= 0,
  "F0 must begin at quadratic order in the six normal coordinates."];

(* For positive virtualities mu_i, F1 is coefficientwise positive on the
   positive rank-one locus. *)
f1PositiveCoefficientRules = CoefficientRules[
  f1OnLocus, Join[rowScales, columnScales, massCoefficients]];
f1CoefficientwisePositiveQ =
  f1PositiveCoefficientRules =!= {} &&
  And @@ (TrueQ[# > 0] & /@ Values[f1PositiveCoefficientRules]);
assertAudit[f1CoefficientwisePositiveQ,
  "F1 is not coefficientwise positive on the positive rank-one locus."];

(* Local lower-facet/scalefulness certificate.  At weight -6 the local LP
   polynomial is U|C + F1|C + (quadratic normal layer of F0).  There are
   thirteen chart coordinates: seven u,w variables plus six normals.  The
   parametrisation has exactly one redundancy, u_i -> alpha u_i and
   w_a -> w_a/alpha.  Affine rank twelve therefore means that there is no
   further multiplicative rescaling which could make the region scaleless. *)
leadingLocalPolynomial = Expand[uOnLocus + f1OnLocus + normalQuadratic];
localCoordinates = Join[rowScales, columnScales, normalVars];
leadingExponentVectors = Keys[
  CoefficientRules[leadingLocalPolynomial, localCoordinates]];
leadingExponentDifferences =
  (# - First[leadingExponentVectors]) & /@ Rest[leadingExponentVectors];
leadingAffineRank = MatrixRank[leadingExponentDifferences];
extraScalingNullity = Length[localCoordinates] - 1 - leadingAffineRank;

assertAudit[leadingAffineRank == 12 && extraScalingNullity == 0,
  "The leading local LP polynomial has an additional scaling null direction."];

(* Region and scalar power count. *)
regionVector = Join[ConstantArray[-1, 12], {1}];
wSL = -7;
wHR = -6;
cancellationDepth = wHR - wSL;
normalWidthPower = 1/2;
normalCodimension = 6;
measurePower = Total[Most[regionVector]] +
  normalCodimension normalWidthPower;
lpIntegrandPower = 3 (4 - 2 dimEpsilon);
scalarIntegralPower = Expand[measurePower + lpIntegrandPower];

assertAudit[cancellationDepth == 1, "The cancellation depth must be one."];
assertAudit[scalarIntegralPower === 3 - 6 dimEpsilon,
  "Unexpected scalar-integral power count."];

K43LandshoffAuditResult = <|
  "Graph" -> "K_{4,3}",
  "Loops" -> 6,
  "Edges" -> 12,
  "EdgeOrder" -> vars,
  "UMonomialCount" -> Length[MonomialList[uPolynomial, vars]],
  "F0MonomialCount" -> Length[MonomialList[f0, vars]],
  "ChannelForestMonomialCounts" ->
    (Length[MonomialList[#, vars]] & /@ {phiS, phiT, phiU}),
  "FSLChannelIdentityQ" -> True,
  "PositiveRankOneLandauLocusQ" -> True,
  "IndependentNormalCount" -> 6,
  "NormalHessianDeterminant" -> ratioHessianDeterminant,
  "PhysicalSampleSignature" -> sampleSignature,
  "RegionVector" -> regionVector,
  "WSL" -> wSL,
  "WHR" -> wHR,
  "CancellationDepth" -> cancellationDepth,
  "NormalWidth" -> delta^(1/2),
  "LeadingLocalMonomialCount" -> Length[leadingExponentVectors],
  "LeadingLocalAffineRank" -> leadingAffineRank,
  "ExtraScalingNullity" -> extraScalingNullity,
  "ScalefulQ" -> True,
  "ScalarIntegralPowerD4m2eps" -> delta^(scalarIntegralPower),
  "CertifiedHiddenRegionQ" -> True
|>;

Print[InputForm[K43LandshoffAuditResult]];
