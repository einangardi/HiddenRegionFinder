(* ::Title:: *)
(*K_{3,3}: exact audit of a three-factor cancellation layer*)

(*
  This file constructs the massless second Symanzik polynomial of K_{3,3}
  with one external leg at every vertex.  It then proves an exact cubic
  cancellation on a planar cyclic 3 -> 3 kinematic family.

  The cancellation is algebraically new: F, Grad[F] and Hessian[F] vanish
  on the stationary ray, while the third derivative tensor does not.
  The ray is not a first-sheet hidden region because its Schwinger matrix
  has zero row and column sums and hence cannot have all entries positive.
*)

ClearAll["Global`*"];

xMat = Array[xx, {3, 3}];
sCross = Array[ss, {3, 3}];
xVars = Flatten[xMat];
sVars = Flatten[sCross];

rowSums = Total /@ sCross;
colSums = Total /@ Transpose[sCross];

sAA[i_, j_] /; i < j :=
  (-rowSums[[i]] - rowSums[[j]] + rowSums[[First@Complement[Range[3], {i, j}]]])/2;

sBB[a_, b_] /; a < b :=
  (-colSums[[a]] - colSums[[b]] + colSums[[First@Complement[Range[3], {a, b}]]])/2;

pTerm[i_, a_] :=
  (Times @@ Delete[xMat[[i]], a]) *
  (Times @@ Delete[xMat[[All, a]], i]) *
  Total@Flatten@xMat[[Complement[Range[3], {i}], Complement[Range[3], {a}]]];

qTerm[i_, j_, a_] /; i < j := Module[{k, otherColumns},
  k = First@Complement[Range[3], {i, j}];
  otherColumns = Complement[Range[3], {a}];
  xMat[[k, a]] * (Times @@ Flatten@Table[xMat[[rr, bb]], {rr, {i, j}}, {bb, otherColumns}])
];

tripleInvariant[i_, j_, a_] /; i < j :=
  sAA[i, j] + sCross[[i, a]] + sCross[[j, a]];

F33 = Expand[
  Total[(sCross[[#[[1]], #[[2]]]] pTerm[#[[1]], #[[2]]]) & /@
    Tuples[Range[3], 2]]
  + Total[(tripleInvariant[#[[1]], #[[2]], #[[3]]]
      qTerm[#[[1]], #[[2]], #[[3]]]) & /@
    Flatten[Table[{i, j, a}, {i, 1, 2}, {j, i + 1, 3}, {a, 3}], 2]]
];

If[Length@MonomialList[F33, xVars] =!= 45,
  Print["ERROR: expected 45 monomials in F33."]; Exit[1]
];

(* A symmetric slice.  Momentum conservation expresses all same-side
   invariants in terms of the 3 x 3 cross-invariant matrix. *)
symRules = Flatten@Table[
  sCross[[i, a]] -> If[i == a, pKin, qKin], {i, 3}, {a, 3}
];

(* The five-vector Gram determinant on this slice. *)
pairInvariant[i_, j_] /; i < j := Which[
  i <= 3 && j <= 3, sAA[i, j],
  i <= 3 && j >= 4, sCross[[i, j - 3]],
  i >= 4 && j >= 4, sBB[i - 3, j - 3]
];

gram5 = Factor@Det@Table[
  If[i == j, 0, pairInvariant[Min[i, j], Max[i, j]]],
  {i, 5}, {j, 5}
];
gram5Symmetric = Factor[gram5 /. symRules];
expectedGram = -3 pKin^2 (pKin - 4 qKin)^2 (pKin + 2 qKin)/16;

If[Factor[gram5Symmetric - expectedGram] =!= 0,
  Print["ERROR: unexpected Gram determinant."]; Exit[1]
];

(* The non-degenerate Gram branch p = 4 q. *)
xStar = Table[If[i == a, -2, 1], {i, 3}, {a, 3}];
stationaryXRules = Thread[xVars -> Flatten[xStar]];

fAtStar = Factor[F33 /. symRules /. pKin -> 4 qKin /. stationaryXRules];
gradientAtStar = Factor /@
  (D[F33, #] & /@ xVars /. symRules /. pKin -> 4 qKin /. stationaryXRules);
hessianAtStar = Map[Factor,
  D[F33, {xVars, 2}] /. symRules /. pKin -> 4 qKin /. stationaryXRules, {2}];
thirdTensorAtStar =
  D[F33, {xVars, 3}] /. symRules /. pKin -> 4 qKin /. stationaryXRules;

If[fAtStar =!= 0 || gradientAtStar =!= ConstantArray[0, 9]
   || hessianAtStar =!= ConstantArray[0, {9, 9}],
  Print["ERROR: the claimed cubic stationary ray was not reproduced."];
  Print[InputForm[<|"F" -> fAtStar, "Gradient" -> gradientAtStar,
    "Hessian" -> hessianAtStar|>]]; Exit[1]
];

If[AllTrue[Flatten[thirdTensorAtStar], PossibleZeroQ],
  Print["ERROR: the third derivative tensor should be nonzero."]; Exit[1]
];

(* Direct normal-coordinate certificate.  For arbitrary perturbations y,
   F[t xStar + eps y] starts at eps^3. *)
yMat = Array[yy, {3, 3}];
normalExpansion = Expand[
  F33 /. symRules /. pKin -> 4 qKin
      /. Thread[xVars -> Flatten[tauCoord xStar + epsCoord yMat]]
];
normalLayers = Association@Table[
  k -> Factor@Coefficient[normalExpansion, epsCoord, k], {k, 0, 5}
];

If[!And @@ Table[normalLayers[k] === 0, {k, 0, 2}]
   || normalLayers[3] === 0,
  Print["ERROR: normal expansion does not begin at cubic order."]; Exit[1]
];

(* An explicit set of eight linear cancellation factors.  We use xx[1,2]
   as the projective coordinate along the stationary ray. *)
xStarFlat = Flatten[xStar];
referenceIndex = 2;
factorPolynomials = Delete[
  xVars - xStarFlat xVars[[referenceIndex]], referenceIndex
];
fVars = Array[ff, 8];
adaptedX = ConstantArray[0, 9];
adaptedX[[referenceIndex]] = tauCoord;
adaptedX[[Delete[Range[9], referenceIndex]]] =
  Delete[xStarFlat, referenceIndex] tauCoord + fVars;

adaptedF = Expand[
  F33 /. symRules /. pKin -> 4 qKin /. Thread[xVars -> adaptedX]
];
adaptedCoefficientRules = CoefficientRules[adaptedF, Join[{tauCoord}, fVars]];
normalDegreesPresent = Sort@DeleteDuplicates[
  Total@Rest@First[#] & /@ adaptedCoefficientRules
];

If[normalDegreesPresent =!= {3, 4, 5},
  Print["ERROR: expected normal degrees 3, 4 and 5."]; Exit[1]
];

(* Exact planar cyclic 3 -> 3 family.  r = tan(theta/2). *)
den = 1 + rKin^2;
sDiagonal = -4/den;
sForward = (-1 - 3 rKin^2 + 2 Sqrt[3] rKin)/den;
sBackward = (-1 - 3 rKin^2 - 2 Sqrt[3] rKin)/den;

sCyclic = {
  {sDiagonal, sForward, sBackward},
  {sBackward, sDiagonal, sForward},
  {sForward, sBackward, sDiagonal}
};

b = -1/2 + Sqrt[3] rKin/2;
c = -1/2 - Sqrt[3] rKin/2;
xCyclic = {{1, b, c}, {c, 1, b}, {b, c, 1}};
cyclicRules = Join[
  Thread[sVars -> Flatten[sCyclic]],
  Thread[xVars -> Flatten[xCyclic]]
];

cyclicF = Factor[F33 /. cyclicRules];
cyclicGradient = Factor /@ (D[F33, #] & /@ xVars /. cyclicRules);
cyclicHessian = Map[Factor, D[F33, {xVars, 2}] /. cyclicRules, {2}];
cyclicRowSums = Factor /@ Total[xCyclic, {2}];
cyclicColumnSums = Factor /@ Total[Transpose[xCyclic], {2}];

If[cyclicF =!= 0 || cyclicGradient =!= ConstantArray[0, 9]
   || cyclicHessian =!= ConstantArray[0, {9, 9}],
  Print["ERROR: exact cyclic family check failed."]; Exit[1]
];

If[cyclicRowSums =!= ConstantArray[0, 3]
   || cyclicColumnSums =!= ConstantArray[0, 3],
  Print["ERROR: expected zero row and column sums."]; Exit[1]
];

report = <|
  "FMonomialCount" -> Length@MonomialList[F33, xVars],
  "GramDeterminantOnSymmetricSlice" -> gram5Symmetric,
  "NondegenerateGramBranch" -> (pKin == 4 qKin),
  "StationarySchwingerMatrix" -> xStar,
  "FAtStationaryRay" -> fAtStar,
  "GradientZeroQ" -> (gradientAtStar == ConstantArray[0, 9]),
  "HessianZeroQ" -> (hessianAtStar == ConstantArray[0, {9, 9}]),
  "ThirdDerivativeNonzeroQ" -> Not@AllTrue[Flatten[thirdTensorAtStar], PossibleZeroQ],
  "FirstNonzeroNormalOrder" -> First@Select[Range[0, 5], normalLayers[#] =!= 0 &],
  "CancellationFactors" -> factorPolynomials,
  "NormalDegreesPresent" -> normalDegreesPresent,
  "CyclicStationaryMatrix" -> xCyclic,
  "CyclicRowSums" -> cyclicRowSums,
  "CyclicColumnSums" -> cyclicColumnSums,
  "PositiveOrthantQ" -> False,
  "Conclusion" ->
    "Exact three-factor cancellation exists algebraically, but this cyclic family is not a first-sheet HR because its nonzero stationary Schwinger matrix cannot be entrywise positive."
|>;

Print[InputForm[report]];
