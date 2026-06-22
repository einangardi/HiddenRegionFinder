(* HRF_Example01Common.wl
   Small shared helpers used by Example 01 reporting notebooks and patches. *)

ClearAll[
  hrfCompact, hrfFactorOrDash, hrfScalingAssoc, hrfScalingDataAssoc, hrfEvalScalingData,
  hrfExactReductionCoverageScalingData, hrfCoverageFoundQ,
  hrfSelectedDiagnostic, hrfWeight, hrfHiddenSummaryTable, hrfNotebookTimed,
  hrfNotebookPackageDir
];

If[! ValueQ[$HRFQuietReports], $HRFQuietReports = False];

(* Resolve directory containing HiddenRegionFinder.wl for notebook setup cells. *)
hrfNotebookPackageDir[] := Module[{candidates},
  candidates = DeleteDuplicates @ Flatten @ {
    If[StringQ[$NotebookFileName] && $NotebookFileName =!= "", DirectoryName[$NotebookFileName], Nothing],
    If[StringQ[NotebookDirectory[]] && NotebookDirectory[] =!= "", NotebookDirectory[], Nothing],
    If[StringQ[$InputFileName] && $InputFileName =!= "", DirectoryName[$InputFileName], Nothing]
  };
  SelectFirst[candidates, FileExistsQ[FileNameJoin[{#, "HiddenRegionFinder.wl"}]] &, $Failed]
];

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

(* Coverage LP output may be Missing[...] when F_SL=0 or no obstruction; never pass that to Lookup. *)
hrfScalingDataAssoc[scaling_] := If[AssociationQ[scaling], scaling, <||>];

hrfEvalScalingData[eval_] := Module[{raw},
  If[! AssociationQ[eval], Return[<||>]];
  raw = Which[
    KeyExistsQ[eval, "ScalingData"], eval["ScalingData"],
    KeyExistsQ[eval, "CoverageScalingData"], eval["CoverageScalingData"],
    True, <||>
  ];
  hrfScalingDataAssoc[raw]
];

hrfExactReductionCoverageScalingData[] := <|
  "ScalingStatus" -> "ExactReduction",
  "ScalingStatusMessage" -> "Exact reduction (F_SL=0; no LP scaling vector required)"
|>;

hrfCoverageFoundQ[scaling_] := Module[{sc, diag},
  sc = hrfScalingAssoc[scaling];
  If[! AssociationQ[sc], Return[False]];
  If[MatchQ[Lookup[sc, "Scaling", Missing[]], _Missing], Return[False]];
  If[! ListQ[sc["Scaling"]], Return[False]];
  If[KeyExistsQ[sc, "AcceptedCount"], Return[TrueQ[Lookup[sc, "AcceptedCount", 0] >= 1]]];
  diag = hrfSelectedDiagnostic[sc];
  TrueQ[Lookup[diag, "HiddenDominatesPostCancellationLPQ", False]] &&
    TrueQ[Lookup[diag, "LeadingRegionCoverageQ", False]]
];

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
