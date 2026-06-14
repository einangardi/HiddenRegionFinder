(* HRF_PolynomialCancellationFactors.wl
   Footnote-4 extension: polynomial cancellation factors with mixed signs.

   Design notes:
     - Patched safeCancellationFactors* routes through $HRFUsePolynomialCancellationFactors
       so binomial and polynomial modes can be compared in one session.
     - Optional open-kinematic-stratum filter rejects f_k that only vanish at
       isolated kinematic points (hidden regions should persist across the domain).
     - $HRFPolynomialLastFactorAudit records the most recent factor pass.

   Load after HiddenRegionFinder.wl:
     Get["HRF_PolynomialCancellationFactors.wl"];
*)

If[! ValueQ[$HRFUsePolynomialCancellationFactors], $HRFUsePolynomialCancellationFactors = True];
If[! ValueQ[$HRFPolynomialMaxMonomials], $HRFPolynomialMaxMonomials = 4];
If[! ValueQ[$HRFPolynomialMaxDerivativeMonomials], $HRFPolynomialMaxDerivativeMonomials = 8];
If[! ValueQ[$HRFPolynomialRequireOpenKinematicStratum], $HRFPolynomialRequireOpenKinematicStratum = True];
If[! ValueQ[$HRFPolynomialMinKinematicWitnesses], $HRFPolynomialMinKinematicWitnesses = 2];
If[! ValueQ[$HRFPolynomialEnableSignedMonomialPairs], $HRFPolynomialEnableSignedMonomialPairs = True];
If[! ValueQ[$HRFPolynomialRegressionMode], $HRFPolynomialRegressionMode = True];
If[! ValueQ[$HRFPolynomialLastFactorAudit], $HRFPolynomialLastFactorAudit = <||>];

ClearAll[
  hrfPolynomialSay, hrfPolynomialCompact, hrfPolynomialMonomialCount,
  hrfPolynomialFactorQ, hrfBinomialFactorQ, hrfMixedSignQ,
  hrfPolynomialPositiveDomainQ, hrfKinematicTestPoints, hrfKinWitnessAtPoint,
  hrfOpenKinematicStratumQ, hrfClassifyCancellationFactor,
  hrfSignedMonomialPairFactors, hrfDerivativeWholePolynomialFactors,
  hrfRawPolynomialCandidates, hrfFilterPolynomialCandidates,
  hrfBinomialOnlySafeFactorsExtended, hrfSafeCancellationFactorsPolynomial,
  hrfInstallPolynomialCancellationPatch, hrfPolynomialRegressionTargets,
  hrfPolynomialFactorAudit
];

hrfPolynomialSay[msg_] := If[! TrueQ[$HRFQuietReports], Print["[polynomial factors] ", msg]];

hrfPolynomialCompact[x_] := Which[
  MatchQ[x, _Missing] || x === Null || x === {}, "--",
  True, ToString[InputForm[x]]
];

hrfPolynomialMonomialCount[p_, vars_] := Length[MonomialList[Expand[p], vars]];

hrfBinomialFactorQ[p_, vars_] := binomialQ[p, vars];

hrfPolynomialFactorQ[p_, vars_] := Module[{n = hrfPolynomialMonomialCount[p, vars]},
  IntegerQ[n] && n >= 2 && n <= $HRFPolynomialMaxMonomials
];

hrfMixedSignQ[p_, vars_] := Module[{coeffs},
  coeffs = CoefficientRules[Expand[p], vars][[All, 2]];
  Length[DeleteDuplicates[Sign /@ coeffs]] > 1
];

hrfPolynomialPositiveDomainQ[p_, vars_, kinAssumptions_, kinVars_] :=
  positiveCompatibleQ[Expand[p], vars, kinAssumptions, kinVars];

(* Default kinematic probe points for common examples. *)
hrfKinematicTestPoints[kinAssumptions_, kinVars_List] := Module[{pts = {}, kv},
  kv = kinVars;
  Which[
    kv === {s12, s23},
      pts = {{s12 -> 1, s23 -> -1}, {s12 -> 2, s23 -> -1/2}, {s12 -> 1/2, s23 -> -3}},
    kv === {s12},
      pts = {{s12 -> 1}, {s12 -> 2}, {s12 -> 1/2}},
    kv === {s23},
      pts = {{s23 -> -1}, {s23 -> -2}, {s23 -> -1/2}},
    kv === {s, x, z},
      pts = {{s -> 1, x -> -1/2, z -> 2}, {s -> 2, x -> -3/4, z -> 3/2}, {s -> 1/2, x -> -1/5, z -> 5/4}},
    True,
      pts = Table[
        Thread[kv -> Table[(-1)^j (1 + j/3), {j, i, i + Length[kv] - 1}]],
        {i, 1, Max[3, $HRFPolynomialMinKinematicWitnesses]}
      ]
  ];
  Select[pts, Quiet @ Check[Reduce[kinAssumptions /. #, kv, Reals] =!= False, False] &]
];

hrfKinWitnessAtPoint[C_, vars_, kinAssumptions_, kinVars_, kinPoint_Association] := Module[
  {subC, subA, inst},
  subC = Expand[C /. kinPoint];
  subA = kinAssumptions /. kinPoint;
  inst = Quiet @ FindInstance[
    subA && subC == 0 && And @@ Thread[vars > 0],
    vars,
    Reals
  ];
  inst =!= {} && inst =!= $Failed
];

(* Mild robustness: factor should be compatible with several interior kinematic points,
   not just an accidental isolated configuration. *)
hrfOpenKinematicStratumQ[C_, vars_, kinAssumptions_, kinVars_] := Module[
  {points, hits, need},
  If[kinVars === {} || ! TrueQ[$HRFPolynomialRequireOpenKinematicStratum],
    Return[hrfPolynomialPositiveDomainQ[C, vars, kinAssumptions, kinVars]]
  ];
  points = hrfKinematicTestPoints[kinAssumptions, kinVars];
  If[points === {},
    Return[hrfPolynomialPositiveDomainQ[C, vars, kinAssumptions, kinVars]]
  ];
  hits = Length @ Select[
    points,
    hrfKinWitnessAtPoint[C, vars, kinAssumptions, kinVars, Association[#]] &
  ];
  need = Min[$HRFPolynomialMinKinematicWitnesses, Length[points]];
  hits >= need
];

hrfClassifyCancellationFactor[f_, vars_] := Which[
  hrfBinomialFactorQ[f, vars], "binomial",
  hrfPolynomialFactorQ[f, vars] && hrfMixedSignQ[f, vars], "polynomial mixed-sign",
  hrfPolynomialFactorQ[f, vars], "polynomial",
  True, "other"
];

hrfSignedMonomialPairFactors[deriv_, vars_] := Module[{terms, out = {}, i, j, sum, diff},
  terms = MonomialList[Expand[deriv], vars];
  If[Length[terms] > $HRFPolynomialMaxDerivativeMonomials, Return[{}]];
  For[i = 1, i <= Length[terms] - 1, i++,
    For[j = i + 1, j <= Length[terms], j++,
      sum = Expand[terms[[i]] + terms[[j]]];
      diff = Expand[terms[[i]] - terms[[j]]];
      If[hrfPolynomialFactorQ[sum, vars] && hrfMixedSignQ[sum, vars], AppendTo[out, Factor[sum]]];
      If[hrfPolynomialFactorQ[diff, vars] && hrfMixedSignQ[diff, vars], AppendTo[out, Factor[diff]]];
    ]
  ];
  DeleteDuplicates[out]
];

hrfDerivativeWholePolynomialFactors[F_, vars_, kinAssumptions_, kinVars_, dimensionfulSpec_: Automatic] := Module[
  {out = {}, d, v},
  Do[
    d = Expand[D[F, v]];
    If[! monomialQ[d, vars] &&
        hrfPolynomialFactorQ[d, vars] &&
        hrfPolynomialPositiveDomainQ[d, vars, kinAssumptions, kinVars] &&
        hrfOpenKinematicStratumQ[d, vars, kinAssumptions, kinVars],
      AppendTo[out, Factor[d]]
    ],
    {v, vars}
  ];
  DeleteDuplicates[out]
];

hrfRawPolynomialCandidates[F_, vars_, kinAssumptions_, kinVars_, dimensionfulSpec_: Automatic] := Module[
  {byDeriv, fromFactors, fromWhole, fromPairs = {}, deriv, v},
  byDeriv = derivativeFactorsExtended[F, vars, kinVars, dimensionfulSpec];
  fromFactors = DeleteDuplicates[Flatten[Values[byDeriv]]];
  fromWhole = hrfDerivativeWholePolynomialFactors[F, vars, kinAssumptions, kinVars, dimensionfulSpec];
  If[TrueQ[$HRFPolynomialEnableSignedMonomialPairs],
    Do[
      deriv = Expand[D[F, v]];
      fromPairs = Join[fromPairs, hrfSignedMonomialPairFactors[deriv, vars]],
      {v, vars}
    ];
  ];
  <|
    "ByDerivative" -> byDeriv,
    "FromFactorization" -> fromFactors,
    "FromWholeDerivatives" -> fromWhole,
    "FromSignedMonomialPairs" -> DeleteDuplicates[fromPairs],
    "Raw" -> DeleteDuplicates @ Join[fromFactors, fromWhole, fromPairs]
  |>
];

hrfFilterPolynomialCandidates[raw_List, vars_, kinAssumptions_, kinVars_, mode_String] := Module[
  {passed = {}, rejected = {}, auditRows = {}, row, ok, reason},
  Do[
    ok = Which[
      mode === "Binomial", hrfBinomialFactorQ[raw[[i]], vars],
      True, hrfBinomialFactorQ[raw[[i]], vars] || hrfPolynomialFactorQ[raw[[i]], vars]
    ];
    reason = Which[
      ! ok, "not binomial/polynomial candidate",
      ! hrfPolynomialPositiveDomainQ[raw[[i]], vars, kinAssumptions, kinVars],
        "fails positive-domain compatibility",
      ! hrfOpenKinematicStratumQ[raw[[i]], vars, kinAssumptions, kinVars],
        "fails open-kinematic-stratum probe (isolated-point guard)",
      True, "accepted"
    ];
    row = <|
      "Factor" -> raw[[i]],
      "Class" -> hrfClassifyCancellationFactor[raw[[i]], vars],
      "MonomialCount" -> hrfPolynomialMonomialCount[raw[[i]], vars],
      "MixedSignQ" -> hrfMixedSignQ[raw[[i]], vars],
      "AcceptedQ" -> (reason === "accepted"),
      "RejectReason" -> If[reason === "accepted", "--", reason]
    |>;
    AppendTo[auditRows, row];
    If[reason === "accepted", AppendTo[passed, raw[[i]]], AppendTo[rejected, raw[[i]]]],
    {i, Length[raw]}
  ];
  <|"Accepted" -> DeleteDuplicates[passed], "Rejected" -> rejected, "AuditRows" -> auditRows|>
];

hrfBinomialOnlySafeFactorsExtended[F_, vars_, kinAssumptions_, kinVars_, dimensionfulSpec_: Automatic] := Module[
  {pack, filtered},
  pack = hrfRawPolynomialCandidates[F, vars, kinAssumptions, kinVars, dimensionfulSpec];
  filtered = hrfFilterPolynomialCandidates[pack["Raw"], vars, kinAssumptions, kinVars, "Binomial"];
  $HRFPolynomialLastFactorAudit = <|
    "Mode" -> "Binomial",
    "RawCount" -> Length[pack["Raw"]],
    "AcceptedCount" -> Length[filtered["Accepted"]],
    "RejectedCount" -> Length[filtered["Rejected"]],
    "AuditRows" -> filtered["AuditRows"],
    "SourceCounts" -> <|
      "Factorization" -> Length[pack["FromFactorization"]],
      "WholeDerivatives" -> Length[pack["FromWholeDerivatives"]],
      "SignedMonomialPairs" -> Length[pack["FromSignedMonomialPairs"]]
    |>
  |>;
  {filtered["Accepted"], pack["ByDerivative"]}
];

hrfSafeCancellationFactorsPolynomial[F_, vars_, kinAssumptions_, kinVars_,
   dimensionfulSpec_: Automatic] := Module[
  {pack, filtered},
  pack = hrfRawPolynomialCandidates[F, vars, kinAssumptions, kinVars, dimensionfulSpec];
  filtered = hrfFilterPolynomialCandidates[pack["Raw"], vars, kinAssumptions, kinVars, "Polynomial"];
  $HRFPolynomialLastFactorAudit = <|
    "Mode" -> "Polynomial",
    "RawCount" -> Length[pack["Raw"]],
    "AcceptedCount" -> Length[filtered["Accepted"]],
    "RejectedCount" -> Length[filtered["Rejected"]],
    "AuditRows" -> filtered["AuditRows"],
    "SourceCounts" -> <|
      "Factorization" -> Length[pack["FromFactorization"]],
      "WholeDerivatives" -> Length[pack["FromWholeDerivatives"]],
      "SignedMonomialPairs" -> Length[pack["FromSignedMonomialPairs"]]
    |>
  |>;
  {filtered["Accepted"], pack["ByDerivative"]}
];

hrfPolynomialFactorAudit[F_, vars_, kinAssumptions_, kinVars_, dimensionfulSpec_: Automatic] := Module[
  {binF, polyF, added, onlyPoly},
  binF = hrfBinomialOnlySafeFactorsExtended[F, vars, kinAssumptions, kinVars, dimensionfulSpec][[1]];
  polyF = hrfSafeCancellationFactorsPolynomial[F, vars, kinAssumptions, kinVars, dimensionfulSpec][[1]];
  added = Complement[hrfPolynomialCompact /@ polyF, hrfPolynomialCompact /@ binF];
  onlyPoly = Select[polyF, ! MemberQ[binF, #] &];
  <|
    "BinomialFactors" -> binF,
    "PolynomialFactors" -> polyF,
    "BinomialCount" -> Length[binF],
    "PolynomialCount" -> Length[polyF],
    "AddedFactorCount" -> Length[onlyPoly],
    "AddedFactors" -> onlyPoly,
    "AddedFactorDisplay" -> added,
    "RemovedFactorCount" -> Length[Complement[binF, polyF]],
    "OpenKinematicFilterActiveQ" -> TrueQ[$HRFPolynomialRequireOpenKinematicStratum]
  |>
];

hrfInstallPolynomialCancellationPatch[] := Module[{},
  Quiet @ Check[Unprotect[safeCancellationFactors, safeCancellationFactorsExtended], Null];
  safeCancellationFactors[F_, vars_, kinAssumptions_, kinVars_] :=
    If[TrueQ[$HRFUsePolynomialCancellationFactors],
      hrfSafeCancellationFactorsPolynomial[F, vars, kinAssumptions, kinVars, Automatic],
      hrfBinomialOnlySafeFactorsExtended[F, vars, kinAssumptions, kinVars, Automatic]
    ];
  safeCancellationFactorsExtended[F_, vars_, kinAssumptions_, kinVars_, dimensionfulSpec_: Automatic] :=
    If[TrueQ[$HRFUsePolynomialCancellationFactors],
      hrfSafeCancellationFactorsPolynomial[F, vars, kinAssumptions, kinVars, dimensionfulSpec],
      hrfBinomialOnlySafeFactorsExtended[F, vars, kinAssumptions, kinVars, dimensionfulSpec]
    ];
  hrfPolynomialSay["installed dynamic binomial/polynomial cancellation-factor patch."];
  True
];

hrfPolynomialRegressionTargets = <|
  "CrownInterior" -> <|
    "Source" -> "01_WideAngle",
    "Note" -> "regression: hidden region should survive polynomial extension"
  |>,
  "HyperCrownBoundaryX11" -> <|
    "Diagram" -> "HyperCrown",
    "ZeroVars" -> {x11},
    "Note" -> "target: expected new physics under polynomial f_k"
  |>,
  "ThreeLoopVertex" -> <|
    "Note" -> "target: five-point collinear descendant (load 03_FivePoint_Spacelike_Collinear.wl)"
  |>
|>;

hrfInstallPolynomialCancellationPatch[];

hrfPolynomialSay["loaded. Max monomials per factor: " <> ToString[$HRFPolynomialMaxMonomials] <>
  "; open-kinematic filter: " <> ToString[$HRFPolynomialRequireOpenKinematicStratum]];
