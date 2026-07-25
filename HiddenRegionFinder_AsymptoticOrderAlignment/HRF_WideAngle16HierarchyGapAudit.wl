(* ::Package:: *)
(*
  Exact hierarchy-gap audit for stored or freshly generated wide-angle
  obstruction trials.  This deliberately omits the coverage condition.

  A result MaxGap == 0 is therefore a strong negative certificate: even the
  relaxed exponent-polytope problem cannot place every post-cancellation
  monomial strictly above the homogeneous F_SL face.
*)

ClearAll[
  hrfWA16ExponentRows, hrfWA16WeightedExponentRows,
  hrfWA16HierarchyGapAudit, hrfWA16TrialGenerators,
  hrfWA16RebuildTrialPolynomials, hrfWA16AuditStoredTrial,
  hrfWA16AuditStoredRow
];

hrfWA16ExponentRows[poly_, vars_List] :=
  polynomialExponentRows[Expand[poly], vars];

hrfWA16WeightedExponentRows[poly_, vars_List, etaPower_, source_] :=
  ({#, etaPower, source} & /@ hrfWA16ExponentRows[poly, vars]);

hrfWA16HierarchyGapAudit[fSL_, fObs_, u_, layers_Association, vars_List] := Module[
  {fslRows, ref, postRows, n, objective, matrix, rhs, sol, vec,
   gapVal, rhoVal, postGaps, active, activeCounts},
  fslRows = hrfWA16ExponentRows[fSL, vars];
  postRows = Join[
    hrfWA16WeightedExponentRows[fObs, vars, 0, "FObs"],
    hrfWA16WeightedExponentRows[u, vars, 0, "U"],
    Flatten[
      KeyValueMap[
        hrfWA16WeightedExponentRows[#2, vars, #1, "FDelta[" <> ToString[#1] <> "]"] &,
        layers
      ],
      1
    ]
  ];
  If[fslRows === {} || postRows === {},
    Return[<|
      "HierarchyFeasibleQ" -> False,
      "HierarchyStatus" -> "EmptyRows",
      "FSLExponentRows" -> fslRows,
      "PostExponentRows" -> postRows
    |>]
  ];
  n = Length[vars];
  ref = First[fslRows];
  (* Exact matrix LP.  Put y=-rho>=0 and retain gap>=0 as the final
     variable.  Then

       (a-ref).rho + eta >= gap

     becomes -(a-ref).y-gap >= -eta.  This is algebraically identical to the
     former symbolic LinearOptimization problem, but avoids rebuilding a
     symbolic constraint system for every generator presentation. *)
  objective = Join[ConstantArray[0, n], {-1}];
  matrix = Join[
    (Join[-(# - ref), {0}] & /@ Rest[fslRows]),
    (Join[-(#[[1]] - ref), {-1}] & /@ postRows)
  ];
  rhs = Join[
    ConstantArray[{0, 0}, Max[0, Length[fslRows] - 1]],
    ({-#[[2]], 1} & /@ postRows)
  ];
  sol = Quiet @ Check[
    LinearProgramming[objective, matrix, rhs],
    $Failed
  ];
  Which[
    sol === $Failed,
      <|"HierarchyFeasibleQ" -> Missing["LPFailed"], "HierarchyStatus" -> "LPFailed"|>,
    MatchQ[sol, {Indeterminate ..}],
      <|
        "HierarchyFeasibleQ" -> True,
        "HierarchyStatus" -> "UnboundedPositiveGap",
        "MaxGap" -> Infinity,
        "Scaling" -> Missing["UnboundedWitnessNotReturned"]
      |>,
    VectorQ[sol, NumericQ],
      vec = Rationalize[sol, 0];
      rhoVal = -Take[vec, n];
      gapVal = Rationalize[Last[vec], 0];
      postGaps = Rationalize[((#[[1]] - ref).rhoVal + #[[2]]) & /@ postRows, 0];
      active = Pick[postRows, Thread[postGaps == gapVal]];
      activeCounts = Counts[active[[All, 3]]];
      <|
        "HierarchyFeasibleQ" -> TrueQ[gapVal > 0],
        "HierarchyStatus" -> If[TrueQ[gapVal > 0], "PositiveGap", "ZeroMaxGap"],
        "MaxGap" -> gapVal,
        "Scaling" -> Thread[vars -> rhoVal],
        "FSLWeight" -> ref.rhoVal,
        "FSLExponentRowCount" -> Length[fslRows],
        "PostExponentRowCount" -> Length[postRows],
        "ActivePostRowCount" -> Length[active],
        "ActivePostSourceCounts" -> activeCounts,
        "ActivePostRows" -> active
      |>,
    True,
      <|
        "HierarchyFeasibleQ" -> Missing["UnexpectedLPResult"],
        "HierarchyStatus" -> "UnexpectedLPResult",
        "Raw" -> sol
      |>
  ]
];

hrfWA16TrialGenerators[trial_Association] := Module[
  {symbolic = Lookup[trial, "GeneratorsSymbolic", Missing["Absent"]], text},
  Which[
    ListQ[symbolic], symbolic,
    ListQ[Lookup[trial, "Generators", {}]], Lookup[trial, "Generators", {}],
    StringQ[text = Lookup[trial, "Generators", ""]] && StringTrim[text] =!= "",
      ToExpression["{" <> text <> "}"],
    True, {}
  ]
];

hrfWA16RebuildTrialPolynomials[rec_Association, zero_List, generators_List] := Module[
  {f, u, fOn, vars, diag, result, layers},
  f = Expand[rec["F0"] /. Thread[zero -> 0]];
  u = Expand[rec["U"] /. Thread[zero -> 0]];
  fOn = Expand[rec["Data"]["FOnShell"] /. Thread[zero -> 0]];
  vars = Complement[rec["Vars"], zero];
  diag = If[
    AllTrue[generators, ! hrfFactorContainsKinVarsQ[#, KinVars4pt] &],
    (* For an x-only ideal, reduction acts coefficientwise on
       F=s12 A(x)+s23 B(x).  An invertible change of Mandelstam basis
       therefore commutes with the reduction and gives the same pulled-back
       FSL/obstruction split.  The two crossed-basis attempts are redundant. *)
    obstructionByOriginalTermsGeneralDiagnosticCore[
      f, generators, vars, KinVars4pt, 20,
      "OriginalChannelBasis", {}, KinAssump4ptOnShell
    ],
    obstructionByOriginalTermsGeneralDiagnostic[
      f, generators, vars, KinVars4pt, 20, KinAssump4ptOnShell
    ]
  ];
  result = If[
    AssociationQ[diag] && AssociationQ[Lookup[diag, "Result", Missing["Absent"]]],
    diag["Result"],
    Missing["NoRebuiltObstruction"]
  ];
  If[! AssociationQ[result], Return[result]];
  layers = hrfDeltaLayerAssociation[fOn, \[Delta]];
  <|
    "Variables" -> vars,
    "Generators" -> generators,
    "FSL" -> Expand[result["Superleading"]],
    "FObstruction" -> Expand[result["Obstruction"]],
    "U" -> u,
    "DeltaLayers" -> layers
  |>
];

hrfWA16AuditStoredTrial[rec_Association, zero_List, trial_Association] := Module[
  {generators, polynomials, audit},
  generators = hrfWA16TrialGenerators[trial];
  polynomials = hrfWA16RebuildTrialPolynomials[rec, zero, generators];
  If[! AssociationQ[polynomials],
    Return[<|
      "TrialIndex" -> Lookup[trial, "TrialIndex", Missing["Absent"]],
      "Generators" -> generators,
      "RebuiltObstructionQ" -> False,
      "HierarchyStatus" -> "NoRebuiltObstruction"
    |>]
  ];
  audit = hrfWA16HierarchyGapAudit[
    polynomials["FSL"], polynomials["FObstruction"], polynomials["U"],
    polynomials["DeltaLayers"], polynomials["Variables"]
  ];
  Join[
    <|
      "TrialIndex" -> Lookup[trial, "TrialIndex", Missing["Absent"]],
      "GeneratorCount" -> Length[generators],
      "Generators" -> generators,
      "RebuiltObstructionQ" -> True,
      "Polynomials" -> polynomials
    |>,
    audit
  ]
];

hrfWA16AuditStoredRow[rec_Association, row_Association] := Module[
  {zero, trials, audits},
  zero = Lookup[row, "ZeroVars", {}];
  trials = Lookup[row, "GeneratorSetScalingSummary", {}];
  audits = hrfWA16AuditStoredTrial[rec, zero, #] & /@ trials;
  <|
    "ID" -> rec["ID"],
    "ZeroVars" -> zero,
    "TrialCount" -> Length[audits],
    "PositiveGapTrialCount" -> Count[
      audits, a_ /; TrueQ[Lookup[a, "HierarchyFeasibleQ", False]]
    ],
    "ZeroMaxGapTrialCount" -> Count[
      audits, a_ /; Lookup[a, "HierarchyStatus", ""] === "ZeroMaxGap"
    ],
    "Trials" -> audits
  |>
];
