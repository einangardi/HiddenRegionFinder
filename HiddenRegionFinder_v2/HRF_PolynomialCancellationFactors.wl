(* HRF_PolynomialCancellationFactors.wl
   Footnote-4 extension: polynomial cancellation factors with mixed signs.

   Design notes:
     - Patched safeCancellationFactors* routes through $HRFUsePolynomialCancellationFactors
       so binomial and polynomial modes can be compared in one session.
     - Kinematic acceptance uses FindInstance via positiveCompatibleQ / hrfKinDomainCompatibleQ
       (monotone under domain restriction: stronger domain cannot admit more factors).
     - $HRFPolynomialRequireKinematicDomainQ = False skips the domain check (debug only).
     - $HRFPolynomialLastFactorAudit records the most recent factor pass.

   Load after HiddenRegionFinder.wl:
     Get["HRF_PolynomialCancellationFactors.wl"];
*)

If[! ValueQ[$HRFUsePolynomialCancellationFactors], $HRFUsePolynomialCancellationFactors = True];
If[! ValueQ[$HRFPolynomialMaxMonomials], $HRFPolynomialMaxMonomials = Automatic];
$HRFPolynomialEffectiveMaxMonomials = Automatic;
If[! ValueQ[$HRFPolynomialMaxDerivativeMonomials], $HRFPolynomialMaxDerivativeMonomials = 8];
If[! ValueQ[$HRFPolynomialRequireKinematicDomainQ],
  (* Back-compat alias for notebooks that still set the old flag name. *)
  If[ValueQ[$HRFPolynomialRequireOpenKinematicStratum],
    $HRFPolynomialRequireKinematicDomainQ = $HRFPolynomialRequireOpenKinematicStratum,
    $HRFPolynomialRequireKinematicDomainQ = True
  ]
];
$HRFPolynomialRequireOpenKinematicStratum = $HRFPolynomialRequireKinematicDomainQ;
If[! ValueQ[$HRFPolynomialEnableSignedMonomialPairs], $HRFPolynomialEnableSignedMonomialPairs = True];
(* Collinear single-channel: harvest only derivative factorization (not signed-pair / whole-D). *)
If[! ValueQ[$HRFPolynomialDerivativeFactorizationOnlyQ], $HRFPolynomialDerivativeFactorizationOnlyQ = Automatic];
If[! ValueQ[$HRFPolynomialRegressionMode], $HRFPolynomialRegressionMode = True];
If[! ValueQ[$HRFPolynomialLastFactorAudit], $HRFPolynomialLastFactorAudit = <||>];
(* Footnote-4: f_k must have mixed signs to cancel. Wide-angle (s12,s23): kin-free f_k only. *)
If[! ValueQ[$HRFRequireMixedSignCancellationFactorsQ], $HRFRequireMixedSignCancellationFactorsQ = True];
If[! ValueQ[$HRFRequireKinFreeCancellationFactorsQ], $HRFRequireKinFreeCancellationFactorsQ = Automatic];

$HRFPolySupportDirectory = Which[
  ValueQ[hrfPackageDirectory], hrfPackageDirectory[],
  StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName],
    DirectoryName[$InputFileName],
  True,
    Quiet @ Check[NotebookDirectory[], Directory[]]
];
If[! TrueQ[$HRFGeneratorPhysicsFilterLoadedQ],
  Quiet @ Get[FileNameJoin[{$HRFPolySupportDirectory, "HRF_GeneratorPhysicsFilter.wl"}]]
];

ClearAll[
  hrfPolynomialSay, hrfPolynomialCompact, hrfPolynomialCompactDisplay,
  hrfPolynomialMonomialCount, hrfResolvePolynomialMaxMonomials,
  hrfEnsurePolynomialMaxMonomialsFromRaw, hrfPolynomialMaxMonomialsCap,
  hrfPolynomialFactorQ, hrfBinomialFactorQ, hrfMixedSignQ,
  hrfCancellationFactorAdmissibleShapeQ, hrfFormatCancellationFactorDisplay, hrfTermXMonomialPart,
  hrfExponentListInVars, hrfVarsWithPositiveExponent, hrfMonomialContentInVars, hrfPrimitiveCancellationFactor,
  hrfStripZCollinearFactor, hrfStripIfOverallShellDivides, hrfStripPolynomialShell, hrfOverallKinShellDivisors,
  hrfStripAllOverallKinShells, hrfStripOverallNonSymanzikFactors, hrfStripOverallSign,
  hrfStripOverallKinMonomialContent, hrfCanonicalCancellationFactor,
  hrfCanonicalCancellationFactorKey, hrfCanonicalCancellationFactorShellRemoved,
  hrfCancellationFactorsEquivalentQ, hrfMemberCanonicalCancellationFactorQ,
  hrfLightNormalizeCancellationCandidates,
  hrfNormalizeCancellationCandidates, hrfPolynomialKinDomainQ,
  hrfClassifyCancellationFactor,
  hrfSignedMonomialPairFactors, hrfDerivativeWholePolynomialFactors,
  hrfRawPolynomialCandidates, hrfFilterPolynomialCandidates,
  hrfResolveKinFreeCancellationFactorsQ, hrfResolveDerivativeFactorizationOnlyQ,
  hrfCancellationFactorAcceptanceQ,
  hrfBinomialOnlySafeFactorsExtended, hrfSafeCancellationFactorsPolynomial,
  hrfInstallPolynomialCancellationPatch, hrfPolynomialRegressionTargets,
  hrfPolynomialFactorAudit,
  hrfFactorContainsKinQ, hrfTermInF0UpToXMonomialQ,
  hrfFactorF0SupportAuditRow, hrfFactorF0SupportAudit,
  hrfResolveRequireGeneratorMonomialsInF0Q,
  hrfXExponentDominatedByQ, hrfKinSectorGeneratorMonomialInF0Q,
  hrfGeneratorMonomialsInF0Q, hrfTwoGeneratorSetMonomialsInF0Q,
  hrfGeneratorSetMonomialsInF0Q, hrfGeneratorF0SupportAdmissibleQ
];

hrfPolynomialSay[msg_] := If[! TrueQ[$HRFQuietReports], Print["[polynomial factors] ", msg]];

(* Exponent[constant, vars] and Exponent[{}, vars] can return {} or stay unevaluated;
   always return a length-|vars| list. *)
hrfExponentListInVars[p_, vars_List] := Module[{ep, ex},
  Which[
    vars === {}, {},
    True,
      ep = Quiet @ Check[Expand[p], p];
      ex = Quiet @ Check[Exponent[ep, vars], $Failed];
      Which[
        ListQ[ex] && Length[ex] === Length[vars], ex,
        True, ConstantArray[0, Length[vars]]
      ]
  ]
];

hrfVarsWithPositiveExponent[term_, vars_List] :=
  Pick[vars, hrfExponentListInVars[term, vars], _?(# > 0 &)];

hrfPolynomialCompact[x_] := Which[
  MatchQ[x, _Missing] || x === Null || x === {}, "--",
  StringQ[x], x,
  True, ToString[InputForm[x]]
];

hrfCancellationFactorAdmissibleShapeQ[f_, vars_] := Module[{c},
  c = If[ValueQ[hrfPrimitiveCancellationFactor],
    hrfPrimitiveCancellationFactor[Expand[f], vars],
    Expand[f]
  ];
  ! TrueQ[c === 0] && ! monomialQ[c, vars] &&
    hrfPolynomialFactorQ[c, vars] && hrfMixedSignQ[c, vars]
];

(* Display: group terms by common x-monomial, factor it out of the kin combination. *)
hrfTermXMonomialPart[t_, vars_List] := Module[{xExp},
  xExp = hrfExponentListInVars[t, vars];
  Times @@ MapThread[If[#2 > 0, Power[#1, #2], 1] &, {vars, xExp}]
];

hrfFormatCancellationFactorDisplay[f_, vars_, kinVars_: {}] := Module[
  {c, terms, groups, keys, parts},
  If[! ListQ[vars] || vars === {}, Return[hrfPolynomialCompact[f]]];
  c = If[ValueQ[hrfCanonicalCancellationFactor],
    hrfCanonicalCancellationFactor[f, vars, kinVars],
    hrfPrimitiveCancellationFactor[Expand[f], vars]
  ];
  If[TrueQ[c === 0] || monomialQ[c, vars], Return["--"]];
  terms = MonomialList[Expand[c], vars];
  If[kinVars =!= {},
    terms = MonomialList[Expand @ Collect[Plus @@ terms, kinVars, Factor], vars]
  ];
  If[Length[terms] === 1, ToString[InputForm[First[terms]]],
    StringRiffle[ToString[InputForm[#]] & /@ terms, " + "]
  ]
];

hrfPolynomialCompactDisplay[f_, vars_, kinVars_: {}] :=
  hrfFormatCancellationFactorDisplay[f, vars, kinVars];

hrfPolynomialMonomialCount[p_, vars_] := Length[MonomialList[Expand[p], vars]];

(* Automatic: no cap during harvest; before filtering, effective limit = max monomial
   count in the raw pool for this F0 (so derivative factorization is never silently dropped).
   Set an explicit Integer >= 2 to impose a hard cap. *)
hrfResolvePolynomialMaxMonomials[raw_List : {}, vars_List : {}] := Which[
  IntegerQ[$HRFPolynomialMaxMonomials] && $HRFPolynomialMaxMonomials >= 2,
    $HRFPolynomialMaxMonomials,
  $HRFPolynomialMaxMonomials === Infinity,
    Infinity,
  raw =!= {} && ListQ[vars] && vars =!= {},
    Max[2, Max[hrfPolynomialMonomialCount[#, vars] & /@ raw]],
  True,
    Infinity
];

hrfEnsurePolynomialMaxMonomialsFromRaw[raw_List, vars_List] :=
  ($HRFPolynomialEffectiveMaxMonomials = hrfResolvePolynomialMaxMonomials[raw, vars]);

hrfPolynomialMaxMonomialsCap[] := Which[
  ValueQ[$HRFPolynomialEffectiveMaxMonomials] &&
    $HRFPolynomialEffectiveMaxMonomials =!= Automatic,
    $HRFPolynomialEffectiveMaxMonomials,
  True,
    hrfResolvePolynomialMaxMonomials[{}, {}]
];

hrfBinomialFactorQ[p_, vars_] := binomialQ[p, vars];

hrfPolynomialFactorQ[p_, vars_] := Module[
  {n = hrfPolynomialMonomialCount[p, vars], cap = hrfPolynomialMaxMonomialsCap[]},
  IntegerQ[n] && n >= 2 && (cap === Infinity || n <= cap)
];

hrfMixedSignQ[p_, vars_] := Module[{coeffs},
  coeffs = CoefficientRules[Expand[p], vars][[All, 2]];
  Length[DeleteDuplicates[Sign /@ coeffs]] > 1
];

(* Remove overall monomial x-content shared by all terms (e.g. x5*B -> B). *)
hrfMonomialContentInVars[f_, vars_] := Module[{ml, exp0, j, g},
  ml = MonomialList[Expand[f], vars];
  If[ml === {} || vars === {}, Return[1]];
  exp0 = hrfExponentListInVars[ml[[1]], vars];
  Do[
    g = hrfExponentListInVars[ml[[j]], vars];
    exp0 = Table[Min[exp0[[k]], g[[k]]], {k, Length[vars]}],
    {j, 2, Length[ml]}
  ];
  If[Total[exp0] === 0, Return[1]];
  Times @@ MapThread[Power, {vars, exp0}]
];

hrfPrimitiveCancellationFactor[f_, vars_] := Module[{e, mon, core},
  e = Expand[f];
  mon = hrfMonomialContentInVars[e, vars];
  core = If[mon === 1, e, Expand[e/mon]];
  If[TrueQ[core === 0], Return[0]];
  Factor[core]
];

(* Strip shell only when it divides the entire factor. *)
hrfStripIfOverallShellDivides[e_, shell_] := Module[{ee = Expand[e], sh = Expand[shell]},
  If[TrueQ[ee === 0], Return[0]];
  Which[
    sh === 1 - z || sh === z - 1,
      If[! TrueQ[Expand[ee /. z -> 1] === 0], Return[ee]];
      Factor @ Expand @ Cancel[ee/sh],
    MemberQ[{s, x, z, s12, s23}, sh],
      If[FreeQ[ee, sh], Return[ee]];
      If[! TrueQ[Expand[ee /. sh -> 0] === 0], Return[ee]];
      Factor @ Expand @ Cancel[ee/sh],
    True,
      Module[{divVars = Variables[sh], r},
        If[divVars === {}, Return[ee]];
        r = Quiet @ PolynomialRemainder[ee, sh, divVars];
        If[! TrueQ[Expand[r] === 0], Return[ee]];
        Factor @ Expand @ Cancel[ee/sh]
      ]
  ]
];

hrfStripPolynomialShell[f_, shell_, allVars_] :=
  hrfStripIfOverallShellDivides[f, shell];

hrfStripZCollinearFactor[e_] := Module[{f = Expand[e], allVars = Variables[Expand[e]]},
  If[TrueQ[f === 0], Return[0]];
  If[FreeQ[f, z], Return[f]];
  hrfStripPolynomialShell[f, 1 - z, allVars] // Function[{g},
    If[TrueQ[Expand[g - f] === 0], hrfStripPolynomialShell[f, z - 1, allVars], g]
  ]
];

hrfOverallKinShellDivisors[kinVars_] := Module[{shells = kinVars},
  If[MemberQ[kinVars, z], shells = Join[shells, {1 - z, z - 1}]];
  DeleteDuplicates[shells]
];

(* Remove overall factors that do not depend on any Symanzik x_i.
   Factor first, then drop Times factors free of symanzikVars (kin shells, signs, etc.). *)
hrfStripOverallNonSymanzikFactors[f_, symanzikVars_List] := Module[{g, parts, symPart, sym},
  sym = If[symanzikVars === {}, Null, Alternatives @@ symanzikVars];
  g = Factor[Expand[f]];
  If[TrueQ[g === 0], Return[0]];
  parts = Switch[Head[g], Times, List @@ g, _, {g}];
  symPart = If[sym === Null, parts,
    Select[parts, ! FreeQ[#, sym] &]
  ];
  Which[
    symPart === {}, 0,
    Length[symPart] === 1, First[symPart],
    True, Times @@ symPart
  ]
];

(* Legacy name: collinear-specific shell list replaced by Factor-based stripping. *)
hrfStripAllOverallKinShells[f_, kinVars_, vars_] :=
  hrfStripOverallNonSymanzikFactors[f, vars];

hrfStripOverallSign[f_, vars_] := Module[{e = Expand[f], ml, leadCoeff},
  If[TrueQ[e === 0], Return[0]];
  If[vars === {} || FreeQ[e, Alternatives @@ vars], Return[Factor[e]]];
  ml = MonomialList[e, vars];
  If[ml === {}, Return[Factor[e]]];
  leadCoeff = Coefficient[e, First[ml], vars];
  If[NumericQ[leadCoeff] && leadCoeff < 0, Factor[-e], Factor[e]]
];

hrfStripOverallKinMonomialContent[f_, kinVars_] := Module[{vars = {}},
  If[TrueQ[Expand[f] === 0], Return[0]];
  hrfStripAllOverallKinShells[f, kinVars, vars]
];

hrfCanonicalCancellationFactor[f_, vars_, kinVars_: {}] := Module[{core},
  core = hrfPrimitiveCancellationFactor[f, vars];
  If[TrueQ[core === 0], Return[0]];
  core = hrfStripOverallNonSymanzikFactors[core, vars];
  If[TrueQ[core === 0], Return[0]];
  core = hrfStripOverallSign[core, vars];
  If[TrueQ[core === 0], Return[0]];
  Factor[Expand[core]]
];

hrfCanonicalCancellationFactorKey[f_, vars_, kinVars_: {}] :=
  hrfFormatCancellationFactorDisplay[f, vars, kinVars];

hrfCanonicalCancellationFactorShellRemoved[f_, vars_, kinVars_: {}] := Module[
  {prim, stripped, ratio},
  prim = hrfPrimitiveCancellationFactor[f, vars];
  If[TrueQ[prim === 0], Return["--"]];
  stripped = hrfStripOverallNonSymanzikFactors[prim, vars];
  If[TrueQ[stripped === 0], Return["kin-only"]];
  If[TrueQ[Expand[prim - stripped] === 0], Return["--"]];
  ratio = Factor @ Cancel[Expand[prim/stripped]];
  hrfPolynomialCompact[ratio]
];

hrfCancellationFactorsEquivalentQ[f1_, f2_, vars_, kinVars_: {}] := Module[{c1, c2},
  c1 = hrfCanonicalCancellationFactor[f1, vars, kinVars];
  c2 = hrfCanonicalCancellationFactor[f2, vars, kinVars];
  TrueQ[Expand[c1 - c2] === 0]
];

hrfMemberCanonicalCancellationFactorQ[list_, f_, vars_, kinVars_: {}] :=
  Length[Select[list, hrfCancellationFactorsEquivalentQ[#, f, vars, kinVars] &]] > 0;

hrfLightNormalizeCancellationCandidates[cands_List, vars_, kinVars_: {}] := Module[{out},
  out = hrfPrimitiveCancellationFactor[#, vars] & /@ cands;
  DeleteDuplicates @ Select[out, ! TrueQ[# === 0] &]
];

hrfNormalizeCancellationCandidates[cands_List, vars_, kinVars_: {}] := Module[{out, acc = {}},
  out = hrfCanonicalCancellationFactor[#, vars, kinVars] & /@ cands;
  Do[
    If[! TrueQ[out[[i]] === 0] &&
        ! hrfMemberCanonicalCancellationFactorQ[acc, out[[i]], vars, kinVars],
      AppendTo[acc, out[[i]]]
    ],
    {i, Length[out]}
  ];
  acc
];

(* Existence of (kin in domain) and (positive x_i) with factor = 0. *)
hrfPolynomialKinDomainQ[p_, vars_, kinAssumptions_, kinVars_] := Module[{},
  If[kinVars === {} || ! TrueQ[$HRFPolynomialRequireKinematicDomainQ],
    Return[True]
  ];
  If[ValueQ[hrfKinDomainCompatibleQ],
    hrfKinDomainCompatibleQ[Expand[p], vars, kinAssumptions, kinVars],
    positiveCompatibleQ[Expand[p], vars, kinAssumptions, kinVars]
  ]
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
      sum = hrfPrimitiveCancellationFactor[Expand[terms[[i]] + terms[[j]]], vars];
      diff = hrfPrimitiveCancellationFactor[Expand[terms[[i]] - terms[[j]]], vars];
      If[hrfPolynomialFactorQ[sum, vars] && hrfMixedSignQ[sum, vars], AppendTo[out, sum]];
      If[hrfPolynomialFactorQ[diff, vars] && hrfMixedSignQ[diff, vars], AppendTo[out, diff]];
    ]
  ];
  DeleteDuplicates[out]
];

hrfDerivativeWholePolynomialFactors[F_, vars_, kinAssumptions_, kinVars_, dimensionfulSpec_: Automatic] := Module[
  {out = {}, d, v, core},
  Do[
    d = Expand[D[F, v]];
    core = hrfPrimitiveCancellationFactor[d, vars];
    If[! monomialQ[d, vars] &&
        hrfPolynomialFactorQ[core, vars] &&
        hrfPolynomialKinDomainQ[core, vars, kinAssumptions, kinVars] &&
        (! TrueQ[$HRFRequireMixedSignCancellationFactorsQ] || hrfMixedSignQ[core, vars]),
      AppendTo[out, core]
    ],
    {v, vars}
  ];
  DeleteDuplicates[out]
];

(* Wide-angle two-channel: kin-mixed f_k cannot enter two kin-free sector generators. *)
hrfResolveKinFreeCancellationFactorsQ[kinVars_List] := Which[
  $HRFRequireKinFreeCancellationFactorsQ === Automatic,
    Length[kinVars] === 2 && Complement[kinVars, {s12, s23}] === {},
  True, TrueQ[$HRFRequireKinFreeCancellationFactorsQ],
  True, False
];

(* Single-channel collinear (e.g. {s,x,z}): only keep f_k from derivative factorization. *)
hrfResolveDerivativeFactorizationOnlyQ[kinVars_List] := Which[
  $HRFPolynomialDerivativeFactorizationOnlyQ === Automatic,
    ! hrfResolveKinFreeCancellationFactorsQ[kinVars],
  True, TrueQ[$HRFPolynomialDerivativeFactorizationOnlyQ],
  True, False
];

hrfCancellationFactorAcceptanceQ[f_, vars_, kinAssumptions_, kinVars_, mode_String] := Module[
  {shapeQ, kinDomainQ, mixedQ, kinFreeQ, core},
  core = hrfPrimitiveCancellationFactor[Expand[f], vars];
  If[monomialQ[core, vars],
    Return[<|"AcceptQ" -> False, "RejectReason" -> "pure monomial (not a cancellation factor)"|>]
  ];
  shapeQ = Which[
    mode === "Binomial", hrfBinomialFactorQ[f, vars],
    True, hrfBinomialFactorQ[f, vars] || hrfPolynomialFactorQ[f, vars]
  ];
  If[! shapeQ, Return[<|"AcceptQ" -> False, "RejectReason" -> "not binomial/polynomial candidate"|>]];
  If[! hrfPolynomialKinDomainQ[f, vars, kinAssumptions, kinVars],
    Return[<|"AcceptQ" -> False,
      "RejectReason" -> "fails kinematic-domain compatibility (no positive x_i solution in domain)"|>]
  ];
  If[TrueQ[$HRFRequireMixedSignCancellationFactorsQ] && ! hrfMixedSignQ[f, vars],
    Return[<|"AcceptQ" -> False,
      "RejectReason" -> "same-sign coefficients (not a cancellation factor)"|>]
  ];
  If[hrfResolveKinFreeCancellationFactorsQ[kinVars] && hrfFactorContainsKinQ[f, kinVars],
    Return[<|"AcceptQ" -> False,
      "RejectReason" -> "kin-dependent f_k (wide-angle two-generator: kin-free only)"|>]
  ];
  If[kinVars =!= {} && Length[DownValues[hrfFactorMandelstamLinearQ]] > 0 &&
      ! hrfFactorMandelstamLinearQ[f, kinVars],
    Return[<|"AcceptQ" -> False,
      "RejectReason" -> "nonlinear Mandelstam monomial in f_k (each kin var at most linear per term)"|>]
  ];
  <|"AcceptQ" -> True, "RejectReason" -> "accepted"|>
];

hrfRawPolynomialCandidates[F_, vars_, kinAssumptions_, kinVars_, dimensionfulSpec_: Automatic] := Module[
  {byDeriv, fromFactors, fromWhole = {}, fromPairs = {}, deriv, v, derivOnlyQ},
  (* Match binomial findObstructions: Automatic -> ordinary derivatives only;
     explicit DimensionfulKinVars list -> extended channel harvest. *)
  derivOnlyQ = hrfResolveDerivativeFactorizationOnlyQ[kinVars];
  byDeriv = If[dimensionfulSpec === Automatic,
    derivativeFactors[F, vars],
    derivativeFactorsExtended[F, vars, kinVars, dimensionfulSpec]
  ];
  fromFactors = hrfLightNormalizeCancellationCandidates[
    DeleteDuplicates[Flatten[Values[byDeriv]]],
    vars,
    kinVars
  ];
  If[! derivOnlyQ,
    fromWhole = hrfDerivativeWholePolynomialFactors[F, vars, kinAssumptions, kinVars, dimensionfulSpec];
    If[TrueQ[$HRFPolynomialEnableSignedMonomialPairs],
      Do[
        deriv = Expand[D[F, v]];
        fromPairs = Join[fromPairs, hrfSignedMonomialPairFactors[deriv, vars]],
        {v, vars}
      ];
    ];
    fromPairs = hrfLightNormalizeCancellationCandidates[fromPairs, vars, kinVars];
  ];
  <|
    "ByDerivative" -> byDeriv,
    "FromFactorization" -> fromFactors,
    "FromWholeDerivatives" -> fromWhole,
    "FromSignedMonomialPairs" -> fromPairs,
    "DerivativeFactorizationOnlyQ" -> derivOnlyQ,
    "Raw" -> hrfLightNormalizeCancellationCandidates[
      Join[fromFactors, fromWhole, fromPairs],
      vars,
      kinVars
    ]
  |>
];

hrfFilterPolynomialCandidates[raw_List, vars_, kinAssumptions_, kinVars_, mode_String] := Module[
  {passed = {}, rejected = {}, auditRows = {}, row, acc, kinFreeQ},
  hrfEnsurePolynomialMaxMonomialsFromRaw[raw, vars];
  kinFreeQ = hrfResolveKinFreeCancellationFactorsQ[kinVars];
  Do[
    acc = hrfCancellationFactorAcceptanceQ[raw[[i]], vars, kinAssumptions, kinVars, mode];
    row = <|
      "Factor" -> raw[[i]],
      "Class" -> hrfClassifyCancellationFactor[raw[[i]], vars],
      "MonomialCount" -> hrfPolynomialMonomialCount[raw[[i]], vars],
      "MixedSignQ" -> hrfMixedSignQ[raw[[i]], vars],
      "ContainsKinVarsQ" -> If[kinVars === {}, False, hrfFactorContainsKinQ[raw[[i]], kinVars]],
      "KinFreePoolRequiredQ" -> kinFreeQ,
      "AcceptedQ" -> TrueQ[acc["AcceptQ"]],
      "RejectReason" -> If[TrueQ[acc["AcceptQ"]], "--", acc["RejectReason"]]
    |>;
    AppendTo[auditRows, row];
    If[TrueQ[acc["AcceptQ"]], AppendTo[passed, raw[[i]]], AppendTo[rejected, raw[[i]]]],
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
  {pack, filtered, accepted},
  pack = hrfRawPolynomialCandidates[F, vars, kinAssumptions, kinVars, dimensionfulSpec];
  filtered = hrfFilterPolynomialCandidates[pack["Raw"], vars, kinAssumptions, kinVars, "Polynomial"];
  accepted = hrfNormalizeCancellationCandidates[filtered["Accepted"], vars, kinVars];
  If[TrueQ[pack["DerivativeFactorizationOnlyQ"]],
    accepted = Select[accepted,
      hrfMemberCanonicalCancellationFactorQ[pack["FromFactorization"], #, vars, kinVars] &
    ];
  ];
  accepted = Select[accepted,
    kinVars === {} || Length[DownValues[hrfFactorMandelstamLinearQ]] === 0 ||
      hrfFactorMandelstamLinearQ[#, kinVars] &
  ];
  accepted = Select[accepted, hrfCancellationFactorAdmissibleShapeQ[#, vars] &];
  $HRFPolynomialLastFactorAudit = <|
    "Mode" -> "Polynomial",
    "RawCount" -> Length[pack["Raw"]],
    "EffectiveMaxMonomials" -> $HRFPolynomialEffectiveMaxMonomials,
    "AcceptedCount" -> Length[accepted],
    "PreNormalizeAcceptedCount" -> Length[filtered["Accepted"]],
    "RejectedCount" -> Length[filtered["Rejected"]],
    "AuditRows" -> filtered["AuditRows"],
    "SourceCounts" -> <|
      "Factorization" -> Length[pack["FromFactorization"]],
      "WholeDerivatives" -> Length[pack["FromWholeDerivatives"]],
      "SignedMonomialPairs" -> Length[pack["FromSignedMonomialPairs"]]
    |>
  |>;
  {accepted, pack["ByDerivative"]}
];

(* Does a term of f_k have x-exponents dominated by some monomial of F0?
   Matches the idea: f_k may carry an overall x-monomial prefactor, but its
   Symanzik support should not introduce new x directions beyond F0. *)
hrfFactorContainsKinQ[f_, kinVars_] := Module[{ff = Expand[f]},
  If[kinVars === {}, False, ! FreeQ[ff, Alternatives @@ kinVars]]
];

hrfXExponentDominatedByQ[ex_, f0Ex_] := Module[{a, b, len},
  len = Max[
    If[ListQ[ex], Length[ex], 0],
    If[ListQ[f0Ex], Length[f0Ex], 0]
  ];
  If[len === 0, Return[True]];
  a = PadRight[If[ListQ[ex], ex, {}], len, 0];
  b = PadRight[If[ListQ[f0Ex], f0Ex, {}], len, 0];
  And @@ Thread[a <= b]
];

hrfTermInF0UpToXMonomialQ[term_, F_, vars_] := Module[
  {ex, f0Terms, f0ex},
  ex = hrfExponentListInVars[term, vars];
  f0Terms = If[Head[Expand[F]] === Plus, List @@ Expand[F], {Expand[F]}];
  f0ex = hrfExponentListInVars[#, vars] & /@ f0Terms;
  If[f0ex === {}, Return[False]];
  AnyTrue[f0ex, hrfXExponentDominatedByQ[ex, #] &]
];

(* Each x-monomial m of a sector generator g must match an F0 term
   kinVar * (x-monomial with exponent vector >= m), allowing extra x_i in F0. *)
hrfKinSectorGeneratorMonomialInF0Q[xMono_, kinSector_, F0_, vars_, kinVars_] := Catch[
  Module[{ex = hrfExponentListInVars[xMono, vars], terms, i, te, xe},
    terms = If[Head[Expand[F0]] === Plus, List @@ Expand[F0], {Expand[F0]}];
    If[terms === {}, Throw[False, $F0MonomialMatch]];
    Do[
      te = Expand[terms[[i]]];
      xe = hrfExponentListInVars[te, vars];
      Which[
        kinSector === Automatic,
          If[hrfXExponentDominatedByQ[ex, xe], Throw[True, $F0MonomialMatch]],
        kinSector === None,
          If[(kinVars === {} || FreeQ[te, Alternatives @@ kinVars]) &&
              hrfXExponentDominatedByQ[ex, xe], Throw[True, $F0MonomialMatch]],
        kinVars === {},
          If[hrfXExponentDominatedByQ[ex, xe], Throw[True, $F0MonomialMatch]],
        True,
          If[MemberQ[kinVars, kinSector] && ! FreeQ[te, kinSector] &&
              And @@ (If[# === kinSector, True, FreeQ[te, #]] & /@ kinVars) &&
              hrfXExponentDominatedByQ[ex, xe],
            Throw[True, $F0MonomialMatch]
          ]
      ],
      {i, Length[terms]}
    ];
    False
  ],
  $F0MonomialMatch
];

If[! ValueQ[$HRFRequireGeneratorMonomialsInF0Q], $HRFRequireGeneratorMonomialsInF0Q = Automatic];

hrfResolveRequireGeneratorMonomialsInF0Q[kinVars_] := Which[
  $HRFRequireGeneratorMonomialsInF0Q === Automatic,
    Length[kinVars] === 2 && Complement[kinVars, {s12, s23}] === {},
  True, TrueQ[$HRFRequireGeneratorMonomialsInF0Q]
];

hrfGeneratorMonomialsInF0Q[gen_, F0_, vars_, kinVars_, kinSector_: Automatic] := Module[
  {ml, sectors},
  If[! hrfResolveRequireGeneratorMonomialsInF0Q[kinVars], Return[True]];
  ml = MonomialList[Expand[gen], vars];
  If[ml === {}, Return[True]];
  sectors = Which[
    kinSector =!= Automatic, {kinSector},
    kinVars === {}, {None},
    True, Prepend[kinVars, None]
  ];
  And @@ Table[
    Or @@ Table[
      hrfKinSectorGeneratorMonomialInF0Q[ml[[i]], sectors[[j]], F0, vars, kinVars],
      {j, Length[sectors]}
    ],
    {i, Length[ml]}
  ]
];

hrfTwoGeneratorSetMonomialsInF0Q[gens_List, F0_, vars_, kinVars_] := Module[{ga, gb},
  If[! hrfResolveRequireGeneratorMonomialsInF0Q[kinVars], Return[True]];
  If[Length[gens] =!= 2, Return[True]];
  {ga, gb} = gens;
  If[Length[kinVars] === 2,
    Or[
      hrfGeneratorMonomialsInF0Q[ga, F0, vars, kinVars, kinVars[[1]]] &&
        hrfGeneratorMonomialsInF0Q[gb, F0, vars, kinVars, kinVars[[2]]],
      hrfGeneratorMonomialsInF0Q[ga, F0, vars, kinVars, kinVars[[2]]] &&
        hrfGeneratorMonomialsInF0Q[gb, F0, vars, kinVars, kinVars[[1]]]
    ],
    And @@ (hrfGeneratorMonomialsInF0Q[#, F0, vars, kinVars, Automatic] & /@ gens)
  ]
];

hrfGeneratorSetMonomialsInF0Q[gens_List, F0_, vars_, kinVars_] := Module[{},
  If[! hrfResolveRequireGeneratorMonomialsInF0Q[kinVars], Return[True]];
  Which[
    Length[gens] === 2, hrfTwoGeneratorSetMonomialsInF0Q[gens, F0, vars, kinVars],
    True, And @@ (hrfGeneratorMonomialsInF0Q[#, F0, vars, kinVars, Automatic] & /@ gens)
  ]
];

hrfGeneratorF0SupportAdmissibleQ[gen_, F0_, vars_, kinVars_, kinSector_: Automatic] := Module[{},
  If[! hrfResolveRequireGeneratorMonomialsInF0Q[kinVars], Return[True]];
  If[F0 === None || F0 === Automatic || TrueQ[Expand[F0] === 0], Return[True]];
  Which[
    kinSector =!= Automatic,
      hrfGeneratorMonomialsInF0Q[gen, F0, vars, kinVars, kinSector],
    Length[kinVars] === 2,
      (* Wide-angle: each generator must be homogeneous in one Mandelstam sector. *)
      Or[
        hrfGeneratorMonomialsInF0Q[gen, F0, vars, kinVars, kinVars[[1]]],
        hrfGeneratorMonomialsInF0Q[gen, F0, vars, kinVars, kinVars[[2]]],
        hrfGeneratorMonomialsInF0Q[gen, F0, vars, kinVars, None]
      ],
    True,
      hrfGeneratorMonomialsInF0Q[gen, F0, vars, kinVars, Automatic]
  ]
];

hrfFactorF0SupportAuditRow[f_, F_, vars_, kinVars_, kinAssumptions_, kinFree_List, bounds_] := Module[
  {terms, termRows, allOK, kinQ, xDeg, dF},
  terms = List @@ Expand[f];
  kinQ = hrfFactorContainsKinQ[f, kinVars];
  xDeg = hrfPolynomialTotalDegreeInVars[f, vars];
  dF = Lookup[bounds, "MaxGeneratorTotalDegree", hrfPolynomialTotalDegreeInVars[F, vars]];
  termRows = Table[
    <|
      "Term" -> hrfPolynomialCompact[terms[[i]]],
      "InF0UpToXMonomialQ" -> hrfTermInF0UpToXMonomialQ[terms[[i]], F, vars]
    |>,
    {i, Length[terms]}
  ];
  allOK = termRows =!= {} && And @@ Lookup[termRows, "InF0UpToXMonomialQ", False];
  <|
    "Factor" -> hrfPolynomialCompact[f],
    "Class" -> hrfClassifyCancellationFactor[f, vars],
    "ContainsKinVarsQ" -> kinQ,
    "XDegree" -> xDeg,
    "MaxKinFreePartnerXDegree" -> If[kinQ, dF - xDeg, "--"],
    "XSupport" -> hrfPolynomialCompact[hrfFactorXSupport[f, vars]],
    "KinMixedSpanRedundantQ" -> If[kinQ && ValueQ[hrfKinMixedFactorSpanRedundantQ],
      hrfKinMixedFactorSpanRedundantQ[f, kinFree, vars, kinVars],
      False
    ],
    "MandelstamLinearQ" -> If[Length[DownValues[hrfFactorMandelstamLinearQ]] > 0,
      hrfFactorMandelstamLinearQ[f, kinVars],
      True
    ],
    "MonomialCount" -> Length[terms],
    "AllTermsInF0UpToXMonomialQ" -> allOK,
    "KinematicHomogeneousQ" -> kinematicallyHomogeneousQ[f, vars, kinVars, Automatic],
    "KinDomainQ" -> hrfPolynomialKinDomainQ[f, vars, kinAssumptions, kinVars],
    "TermAudit" -> termRows
  |>
];

hrfFactorF0SupportAudit[F_, vars_, kinAssumptions_, kinVars_, mode_String : "Polynomial"] := Module[
  {pack, filtered, ff, kinFree, bounds},
  pack = hrfRawPolynomialCandidates[F, vars, kinAssumptions, kinVars, Automatic];
  filtered = hrfFilterPolynomialCandidates[pack["Raw"], vars, kinAssumptions, kinVars, mode];
  ff = filtered["Accepted"];
  bounds = hrfResolveGeneratorDegreeBounds[F, vars, <||>];
  kinFree = Select[ff, ! hrfFactorContainsKinQ[#, kinVars] &];
  Dataset[hrfFactorF0SupportAuditRow[#, F, vars, kinVars, kinAssumptions, kinFree, bounds] & /@ ff]
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
    "OpenKinematicFilterActiveQ" -> TrueQ[$HRFPolynomialRequireKinematicDomainQ]
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
  If[! TrueQ[$HRFPolynomialPatchQuietReinstallQ],
    hrfPolynomialSay["installed dynamic binomial/polynomial cancellation-factor patch."]
  ];
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

hrfPolynomialSay["loaded. Max monomials per factor: " <>
  ToString[$HRFPolynomialMaxMonomials] <>
  " (Automatic = from raw harvest per F0); kinematic-domain check (FindInstance): " <>
  ToString[$HRFPolynomialRequireKinematicDomainQ]];
