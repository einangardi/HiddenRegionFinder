(* HRF_Example01Common.wl
   Small shared helpers used by Example 01 reporting notebooks and patches. *)

ClearAll[
  hrfCompact, hrfFactorOrDash, hrfScalingAssoc, hrfCoverageFoundQ,
  hrfSelectedDiagnostic, hrfWeight, hrfHiddenSummaryTable, hrfNotebookTimed
];

If[! ValueQ[$HRFQuietReports], $HRFQuietReports = False];

hrfNotebookTimed[label_, expr_] := Module[{t, r},
  If[! TrueQ[$HRFQuietReports], Print["[timed] START ", label]];
  {t, r} = AbsoluteTiming[expr];
  If[! TrueQ[$HRFQuietReports], Print["[timed] END   ", label, "  ", NumberForm[t, {6, 2}], " s"]];
  r
];

hrfCompact[x_] := Which[
  x === "--", "--",
  MatchQ[x, _Missing] || x === {} || x === Null, "--",
  ListQ[x], ToString[InputForm[x]],
  AssociationQ[x], ToString[InputForm[Normal[x]]],
  True, ToString[InputForm[x]]
];

hrfFactorOrDash[x_] := hrfCompact[If[MatchQ[x, _Missing] || x === 0, "--", x]];

hrfScalingAssoc[scaling_] := If[AssociationQ[scaling], scaling, <||>];

hrfCoverageFoundQ[scaling_] :=
  AssociationQ[scaling] && ListQ[Lookup[scaling, "Scaling", Missing[]]];

hrfSelectedDiagnostic[scaling_] := Module[{sc = hrfScalingAssoc[scaling]},
  Which[
    AssociationQ[Lookup[sc, "SelectedCandidateDiagnostic", Missing[]]],
      sc["SelectedCandidateDiagnostic"],
    AssociationQ[Lookup[sc, "Diagnostics", Missing[]]], sc["Diagnostics"],
    True, <||>
  ]
];

hrfWeight[diag_, preferred_, fallback_] :=
  Lookup[diag, preferred, Lookup[diag, fallback, Missing["NotAvailable"]]];

hrfHiddenSummaryTable[rows_] := Dataset[rows];

Print["[loaded] Example 01 common reporting helpers."];
