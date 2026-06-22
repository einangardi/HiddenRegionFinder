(* HRF_WideAngleBoundaryDiagnostic.wl
   Per-trial wide-angle boundary audit: generators, decomposition, sector form, scaling.
   Use to see which acceptance tests pass/fail and whether findObstructions picks the
   physically expected trial.

   Load (after HiddenRegionFinder.wl):
     Get["HRF_WideAngleBoundaryDiagnostic.wl"];

   Quick run (HyperCrown {x11}=0, no coverage LP):
     hrfWideAngleBoundaryDiagnostic["HyperCrownX11"]

   Diving Beetle (after 01a setup):
     hrfWideAngleBoundaryDiagnostic["DivingBeetleInterior"]
     hrfWideAngleBoundaryDiagnostic["DivingBeetleX89"]

   Analyze an existing Ex04 scan (no re-search):
     hrfWideAngleBoundaryDiagnosticFromScan[Ex04HyperCrownX11Target["PolynomialScan"],
       Ex04HyperCrownX11Target["FRestricted"], Ex04HyperCrownX11Target["RemainingVars"],
       KinVars4pt, Expand[HyperCrownData["UF"]["U"] /. x11 -> 0], {x11}]

   Full trial log (slower; all candidates up to cap):
     hrfWideAngleBoundaryDiagnostic["HyperCrownX11", "RescanQ" -> True,
       "StopOnFirstAdmissible" -> False]
*)

If[! TrueQ[$HRFFinderCoreLoadedQ],
  Get[FileNameJoin[{hrfPackageDirectory[], "HiddenRegionFinder.wl"}]]
];
If[Length[DownValues[hrfInstallPolynomialCancellationPatch]] === 0,
  Get[FileNameJoin[{hrfPackageDirectory[], "HRF_PolynomialCancellationFactors.wl"}]]
];
If[Length[DownValues[hrfHiddenSummaryRow]] === 0,
  Get[FileNameJoin[{hrfPackageDirectory[], "HRF_FinalLogicPatch.wl"}]]
];
If[Length[DownValues[hrfCoverageFoundQ]] === 0,
  Get[FileNameJoin[{hrfPackageDirectory[], "HRF_Example01Common.wl"}]]
];
If[Length[DownValues[hrfPolyGeneratorDiscardReason]] === 0,
  Get[FileNameJoin[{hrfPackageDirectory[], "HRF_PolynomialFactorReporting.wl"}]]
];

If[! ValueQ[$HRFBoundaryDiagnosticRunScalingQ], $HRFBoundaryDiagnosticRunScalingQ = False];
If[! ValueQ[$HRFBoundaryDiagnosticRescanQ], $HRFBoundaryDiagnosticRescanQ = False];

ClearAll[
  hrfWideAngleBoundaryImplementedTests, hrfWideAngleBoundaryEnsureDiagrams,
  hrfWideAngleBoundarySpec, hrfWideAngleKinFreeGeneratorsQ,
  hrfWideAngleSLPresentationData, hrfWideAngleTrialChecklist,
  hrfWideAngleTrialDiagnosticRow, hrfWideAngleBoundaryDiagnosticScan,
  hrfWideAngleBoundaryDiagnosticFromScan, hrfWideAngleBoundaryDiagnosticReport,
  hrfWideAngleBoundaryDiagnostic, hrfWideAngleBoundaryCompareModes
];

hrfWideAngleBoundaryImplementedTests[] := Dataset[{
  <|"Test" -> "Per-generator degree / massless multilinearity", "EnforcedInFinderQ" -> True,
    "Stage" -> "candidate", "Function" -> "generatorFactorData / hrfGeneratorDegreeAdmissibleQ"|>,
  <|"Test" -> "Per-generator PDF (5.12) simultaneous f_k", "EnforcedInFinderQ" -> True,
    "Stage" -> "candidate", "Function" -> "simultaneouslyAdmissibleSubsetQ per generator"|>,
  <|"Test" -> "Obstruction subset + F_SL in generator ideal", "EnforcedInFinderQ" -> True,
    "Stage" -> "obstruction", "Function" -> "obstructionByOriginalTermsGeneralDiagnostic"|>,
  <|"Test" -> "SL-sector PDF (5.12) on generators entering F_SL", "EnforcedInFinderQ" -> True,
    "Stage" -> "post-obstruction", "Function" -> "slSectorAdmissibilityData"|>,
  <|"Test" -> "F_0 = Obstruction + F_SL reconstruction", "EnforcedInFinderQ" -> True,
    "Stage" -> "reporting", "Function" -> "hrfObstructionDecompositionConsistentQ"|>,
  <|"Test" -> "Kin-free sector generators (wide-angle)", "EnforcedInFinderQ" -> True,
    "Stage" -> "valid-trial", "Function" -> "hrfWideAngleKinSectorPresentationQ (subset)"|>,
  <|"Test" -> "F_SL = s_a g_a with quotients +/- s12,s23", "EnforcedInFinderQ" -> True,
    "Stage" -> "valid-trial", "Function" -> "hrfWideAngleKinSectorPresentationQ"|>,
  <|"Test" -> "Coverage scaling W_SL < W_HR + variable coverage", "EnforcedInFinderQ" -> False,
    "Stage" -> "post-scan", "Function" -> "findCoverageLPScaling (reporting only)"|>,
  <|"Test" -> "Unique / canonical obstruction monomial set", "EnforcedInFinderQ" -> False,
    "Stage" -> "none", "Function" -> "not implemented"|>,
  <|"Test" -> "Reject trial when scaling = NoValidScaling", "EnforcedInFinderQ" -> False,
    "Stage" -> "none", "Function" -> "not implemented"|>
}];

hrfWideAngleBoundaryEnsureDiagrams[] := Module[{d = hrfPackageDirectory[]},
  If[ValueQ[F0HyperCrown] && ValueQ[F0SuperCrown] && ValueQ[F0Crown], Return[True]];
  Block[{
    $HRFExample01Report = False, $HRFRunCrownInteriorScanOnLoad = False,
    $HRFRunExample01ReportingOnLoad = False, $HRFRunScalingDiagnostics = False,
    $HRFRunHyperCrownInteriorScan = False, $HRFRunHyperCrownBoundaryScansOnLoad = False,
    $HRFRunSuperCrownInteriorScan = False, $HRFRunSuperCrownBoundaryScanOnLoad = False,
    $HRFRunDivingBeetleDiagnosticsOnLoad = False, $HRFRunDivingBeetleInteriorScanOnLoad = False
  },
    Get[FileNameJoin[{d, "01_WideAngle_2to2_OffShell.wl"}]]
  ];
  $HRFUsePolynomialCancellationFactors = True;
  hrfInstallPolynomialCancellationPatch[];
  True
];

hrfWideAngleBoundarySpec[target_String] := Module[{},
  hrfWideAngleBoundaryEnsureDiagrams[];
  Switch[target,
    "CrownInterior" | "Crown",
      <|
        "Target" -> "CrownInterior",
        "Label" -> "Crown interior (reference)",
        "F" -> F0Crown, "Vars" -> VarsCrown, "ZeroVars" -> {},
        "KinAssump" -> KinAssump4ptOnShell, "KinVars" -> KinVars4pt,
        "U" -> CrownData["UF"]["U"],
        "KinematicLimit" -> "WideAngle4pt"
      |>,
    "HyperCrownX11" | "HyperCrown" | "HyperCrownX11=0",
      <|
        "Target" -> "HyperCrownX11",
        "Label" -> "HyperCrown boundary {x11}=0",
        "F" -> F0HyperCrown, "Vars" -> VarsHyperCrown, "ZeroVars" -> {x11},
        "KinAssump" -> KinAssump4ptOnShell, "KinVars" -> KinVars4pt,
        "U" -> Expand[HyperCrownData["UF"]["U"] /. x11 -> 0],
        "KinematicLimit" -> "WideAngle4ptBoundary"
      |>,
    "SuperCrownX89" | "SuperCrown",
      <|
        "Target" -> "SuperCrownX89",
        "Label" -> "SuperCrown boundary {x8,x9}=0",
        "F" -> F0SuperCrown, "Vars" -> VarsSuperCrown, "ZeroVars" -> {x8, x9},
        "KinAssump" -> KinAssump4ptOnShell, "KinVars" -> KinVars4pt,
        "U" -> Expand[SuperCrownData["UF"]["U"] /. {x8 -> 0, x9 -> 0}],
        "KinematicLimit" -> "WideAngle4ptBoundary"
      |>,
    "DivingBeetleInterior" | "DBInterior" | "DivingBeetle",
      <|
        "Target" -> "DivingBeetleInterior",
        "Label" -> "Diving Beetle interior",
        "F" -> F0DB, "Vars" -> VarsDB, "ZeroVars" -> {},
        "KinAssump" -> KinAssump4ptOnShell, "KinVars" -> KinVars4pt,
        "U" -> DBData["UF"]["U"],
        "KinematicLimit" -> "WideAngle4ptExhaustive"
      |>,
    "DivingBeetleX89" | "DBX89" | "DivingBeetleX8X9",
      <|
        "Target" -> "DivingBeetleX89",
        "Label" -> "Diving Beetle boundary {x8,x9}=0",
        "F" -> F0DB, "Vars" -> VarsDB, "ZeroVars" -> {x8, x9},
        "KinAssump" -> KinAssump4ptOnShell, "KinVars" -> KinVars4pt,
        "U" -> Expand[DBData["UF"]["U"] /. {x8 -> 0, x9 -> 0}],
        "KinematicLimit" -> "WideAngle4ptBoundary"
      |>,
    _, Missing["UnknownTarget", target]
  ]
];

hrfWideAngleKinFreeGeneratorsQ[gens_List, kinVars_List] :=
  gens =!= {} && And @@ (FreeQ[Expand[#], Alternatives @@ kinVars] & /@ gens);

hrfWideAngleSLPresentationData[fsl_, gens_, vars_, kinVars_] := Module[
  {allVars, quot, rem, active, qActive, activeMask},
  allVars = DeleteDuplicates @ Join[vars, kinVars];
  {quot, rem} = PolynomialReduce[Expand[fsl], gens, allVars];
  quot = If[ListQ[quot], quot, {quot}];
  activeMask = If[Length[quot] =!= Length[gens], {}, 
    Unitize @ Table[If[TrueQ[Expand[quot[[i]]] === 0], 0, 1], {i, Length[gens]}]
  ];
  active = If[activeMask === {}, {}, Pick[gens, activeMask, 1]];
  qActive = If[activeMask === {}, {}, Pick[quot, activeMask, 1]];
  <|
    "Remainder" -> Expand[rem],
    "InIdealQ" -> TrueQ[Expand[rem] === 0],
    "UsedGenerators" -> active,
    "Quotients" -> qActive,
    "QuotientIsKinMonomialQ" -> If[qActive === {}, False,
      And @@ (hrfWideAngleSLQuotientQ[#, kinVars] & /@ qActive)],
    "BothChannelsUsedQ" -> Sort @ DeleteDuplicates @ Flatten @ Table[
      Select[kinVars, ! FreeQ[Expand[qActive[[i]]], #] &], {i, Length[qActive]}
    ] === Sort[kinVars]
  |>
];

hrfWideAngleTrialChecklist[trial_Association, F_, vars_, kinVars_, U_:Missing, runScalingQ_:False] := Module[
  {od, gens, fsl, obs, fIn, sc, pres, attempt},
  od = Lookup[trial, "ObstructionData", Missing[]];
  gens = Lookup[trial, "Generators", {}];
  attempt = Lookup[trial, "ObstructionAttemptData", <||>];
  fIn = If[AssociationQ[trial] && KeyExistsQ[trial, "InputPolynomial"], trial["InputPolynomial"], F];
  obs = If[AssociationQ[od], Lookup[od, "Obstruction", Missing[]], Missing[]];
  fsl = If[AssociationQ[od], Lookup[od, "Superleading", Lookup[od, "Complement", Missing[]]], Missing[]];
  pres = If[MatchQ[fsl, _Missing], <||>, hrfWideAngleSLPresentationData[fsl, gens, vars, kinVars]];
  sc = If[TrueQ[runScalingQ] && ! MatchQ[U, Missing] && AssociationQ[od] &&
      hrfValidObstructionTrialQ[trial, vars, kinVars],
    Module[{scan = <|
      "Generators" -> gens, "ObstructionData" -> od, "ActiveVars" -> vars,
      "KinVars" -> kinVars, "InputPolynomial" -> fIn|>},
      hrfCoverageData[scan, U, vars, 5]
    ],
    Missing["ScalingNotRun"]
  ];
  <|
    "PerGeneratorAdmissibleQ" -> TrueQ[Lookup[trial, "PerGeneratorAdmissibleQ", False]],
    "CandidateUnionPDFQ" -> TrueQ[Lookup[trial, "SimultaneouslyAdmissibleGeneratorSetQ", False]],
    "ObstructionFoundQ" -> AssociationQ[od] && ! MatchQ[od, HoldPattern[Missing["NoObstructionFound", ___]]],
    "ValidObstructionResultQ" -> AssociationQ[od] && hrfValidObstructionResultQ[od, gens, vars, kinVars],
    "SLSectorAdmissibleQ" -> TrueQ[Lookup[trial, "AdmissibleSLSectorQ", False]],
    "KinFreeGeneratorsQ" -> hrfWideAngleKinFreeGeneratorsQ[gens, kinVars],
    "KinSectorPresentationQ" -> hrfWideAngleKinSectorPresentationQ[trial, vars, kinVars],
    "ValidTrialQ" -> hrfValidObstructionTrialQ[trial, vars, kinVars],
    "WideAngleKinSectorTrialQ" -> hrfWideAngleKinSectorPresentationTrialQ[trial, vars, kinVars],
    "DecompositionConsistentQ" -> If[! MatchQ[fIn, _Missing], hrfObstructionDecompositionConsistentQ[
      <|"ObstructionData" -> od, "Generators" -> gens|>, fIn], Missing["NoInputF"]],
    "SuccessfulDecompositionQ" -> Module[{scan = <|
      "Generators" -> gens, "ObstructionData" -> od, "ActiveVars" -> vars,
      "KinVars" -> kinVars, "InputPolynomial" -> fIn|>},
      hrfSuccessfulObstructionDecompositionQ[scan]
    ],
    "SLInIdealQ" -> Lookup[pres, "InIdealQ", False],
    "SLQuotientKinMonomialQ" -> Lookup[pres, "QuotientIsKinMonomialQ", False],
    "BothKinChannelsInSLQ" -> Lookup[pres, "BothChannelsUsedQ", False],
    "ScalingFoundQ" -> If[AssociationQ[sc], hrfCoverageFoundQ[sc], Missing["ScalingNotRun"]],
    "ScalingStatus" -> If[AssociationQ[sc], Lookup[sc, "ScalingStatus", Missing[]], Missing["ScalingNotRun"]],
    "RejectedReason" -> Lookup[attempt, "RejectedReason", "--"],
    "DiscardReason" -> hrfPolyGeneratorDiscardReason[trial]
  |>
];

hrfWideAngleTrialDiagnosticRow[trial_Association, idx_Integer, F_, vars_, kinAssump_, kinVars_, U_,
   runScalingQ_:False, preferFewerQ_:False] := Module[
  {od, gens, fsl, pres, checks, rank},
  od = Lookup[trial, "ObstructionData", Missing[]];
  gens = Lookup[trial, "Generators", {}];
  fsl = If[AssociationQ[od], Lookup[od, "Superleading", Lookup[od, "Complement", "--"]], "--"];
  pres = If[AssociationQ[od] && ! MatchQ[fsl, "--"], hrfWideAngleSLPresentationData[fsl, gens, vars, kinVars], <||>];
  checks = hrfWideAngleTrialChecklist[trial, F, vars, kinVars, U, runScalingQ];
  rank = If[! preferFewerQ && Length[kinVars] === 2,
    hrfWideAngleTrialSelectionRank[trial, kinVars, preferFewerQ],
    hrfObstructionTrialRank[trial, preferFewerQ]
  ];
  Join[<|
    "Trial" -> idx,
    "GeneratorCount" -> Length[gens],
    "Generators" -> If[ValueQ[hrfCompact], hrfCompact[gens], ToString[InputForm[gens]]],
    "F_SL" -> If[ValueQ[hrfCompact], hrfCompact[fsl], ToString[InputForm[fsl]]],
    "Obstruction" -> If[AssociationQ[od], If[ValueQ[hrfCompact], hrfCompact[Lookup[od, "Obstruction", "--"]],
      ToString[InputForm[Lookup[od, "Obstruction", "--"]]]], "--"],
    "SLQuotients" -> If[pres === <||>, "--",
      If[ValueQ[hrfCompact], hrfCompact[pres["Quotients"]], ToString[InputForm[pres["Quotients"]]]]],
    "UsedGenerators" -> If[pres === <||>, "--",
      If[ValueQ[hrfCompact], hrfCompact[pres["UsedGenerators"]], ToString[InputForm[pres["UsedGenerators"]]]]],
    "SelectionRank" -> rank
  |>, Association @ Normal @ checks]
];

hrfWideAngleBoundaryDiagnosticScan[spec_Association, opts:OptionsPattern[]] := Module[
  {fWork, varsWork, limit, maxSize, mode, cap, stopQ, storeQ, runScalingQ, preferFewerQ,
   scan, trials, rows, acceptedIdx, bestIdx, t0},
  fWork = Expand[spec["F"] /. Thread[spec["ZeroVars"] -> 0]];
  varsWork = Complement[spec["Vars"], spec["ZeroVars"]];
  limit = Lookup[spec, "KinematicLimit", "WideAngle4pt"];
  maxSize = Lookup[spec, "MaxSize", Automatic];
  mode = OptionValue["GeneratorMode"];
  cap = OptionValue["CandidateGeneratorSetLimit"];
  stopQ = OptionValue["StopOnFirstAdmissible"];
  storeQ = OptionValue["StoreAllObstructionTrialsQ"];
  runScalingQ = OptionValue["RunScalingQ"];
  preferFewerQ = False;
  t0 = AbsoluteTime[];
  Block[{$HRFUsePolynomialCancellationFactors = True},
    hrfInstallPolynomialCancellationPatch[];
    scan = findObstructions[fWork, varsWork, spec["KinAssump"], spec["KinVars"], maxSize,
      "UseExtendedFactors" -> True,
      Sequence @@ hrfKinematicLimitObstructionOptions[limit],
      Sequence @@ If[mode =!= Automatic, {"GeneratorMode" -> mode}, {}],
      "StopOnFirstAdmissible" -> stopQ,
      "CandidateGeneratorSetLimit" -> cap,
      "StoreAllObstructionTrialsQ" -> storeQ,
      "U" -> Lookup[spec, "U", Automatic]
    ];
  ];
  If[! AssociationQ[scan],
    Return[<|
      "Spec" -> spec,
      "Scan" -> scan,
      "Error" -> "findObstructions did not return an association",
      "TrialRows" -> {},
      "ValidTrialIndices" -> {},
      "FinderAcceptedGenerators" -> {},
      "BestRankIndex" -> Missing["ScanFailed"],
      "ImplementedTests" -> hrfWideAngleBoundaryImplementedTests[],
      "Options" -> <|"GeneratorMode" -> mode, "StopOnFirstAdmissible" -> stopQ,
        "CandidateGeneratorSetLimit" -> cap, "StoreAllObstructionTrialsQ" -> storeQ,
        "RunScalingQ" -> runScalingQ|>
    |>]
  ];
  scan = Join[scan, <|
    "InputPolynomial" -> fWork, "ZeroVars" -> spec["ZeroVars"],
    "ActiveVars" -> varsWork, "KinVars" -> spec["KinVars"]
  |>];
  trials = Lookup[scan, "ObstructionAttemptData", {}];
  If[! ListQ[trials], trials = {}];
  If[trials === {} && ListQ[Lookup[scan, "Generators", {}]] && scan["Generators"] =!= {},
    trials = {KeyDrop[scan, {"ObstructionAttemptData"}]}
  ];
  rows = Table[
    hrfWideAngleTrialDiagnosticRow[trials[[i]], i, fWork, varsWork, spec["KinAssump"],
      spec["KinVars"], spec["U"], runScalingQ, preferFewerQ],
    {i, Length[trials]}
  ];
  acceptedIdx = Flatten @ Position[rows, _?(TrueQ[Lookup[#, "ValidTrialQ", False]] &), {1}, Heads -> False];
  bestIdx = If[acceptedIdx === {}, {},
    {First @ First @ Sort @ Transpose[{acceptedIdx, rows[[acceptedIdx, "SelectionRank"]]}]}
  ];
  <|
    "Spec" -> spec,
    "Scan" -> scan,
    "ElapsedSeconds" -> AbsoluteTime[] - t0,
    "TrialRows" -> rows,
    "ValidTrialIndices" -> acceptedIdx,
    "FinderAcceptedGenerators" -> Lookup[scan, "Generators", {}],
    "BestRankIndex" -> If[bestIdx === {}, Missing["NoValidTrial"], First[bestIdx]],
    "ImplementedTests" -> hrfWideAngleBoundaryImplementedTests[],
    "Options" -> <|"GeneratorMode" -> mode, "StopOnFirstAdmissible" -> stopQ,
      "CandidateGeneratorSetLimit" -> cap, "StoreAllObstructionTrialsQ" -> storeQ,
      "RunScalingQ" -> runScalingQ|>
  |>
];

Options[hrfWideAngleBoundaryDiagnosticScan] = {
  "GeneratorMode" -> Automatic,
  "StopOnFirstAdmissible" -> False,
  "CandidateGeneratorSetLimit" -> 64,
  "StoreAllObstructionTrialsQ" -> True,
  "RunScalingQ" -> False
};

hrfWideAngleBoundaryDiagnosticFromScan[scan_Association, F_, vars_, kinVars_, U_, zeroVars_:{}] := Module[
  {trials, rows, acceptedIdx, bestIdx, preferFewerQ = False},
  If[! AssociationQ[scan], Return[Missing["NotScan"]]];
  trials = Lookup[scan, "ObstructionAttemptData", {}];
  If[! ListQ[trials], trials = {}];
  If[trials === {} && ListQ[Lookup[scan, "Generators", {}]] && scan["Generators"] =!= {},
    trials = {KeyDrop[scan, {"ObstructionAttemptData"}]}
  ];
  rows = Table[
    hrfWideAngleTrialDiagnosticRow[trials[[i]], i, F, vars, True, kinVars, U, False, preferFewerQ],
    {i, Length[trials]}
  ];
  acceptedIdx = Flatten @ Position[rows, _?(TrueQ[Lookup[#, "ValidTrialQ", False]] &), {1}, Heads -> False];
  bestIdx = If[acceptedIdx === {}, {},
    {First @ First @ Sort @ Transpose[{acceptedIdx, rows[[acceptedIdx, "SelectionRank"]]}]}
  ];
  <|
    "Spec" -> <|"Label" -> "from existing scan", "ZeroVars" -> zeroVars|>,
    "Scan" -> scan,
    "ElapsedSeconds" -> 0,
    "TrialRows" -> rows,
    "ValidTrialIndices" -> acceptedIdx,
    "FinderAcceptedGenerators" -> Lookup[scan, "Generators", {}],
    "BestRankIndex" -> If[bestIdx === {}, Missing["NoValidTrial"], First[bestIdx]],
    "ImplementedTests" -> hrfWideAngleBoundaryImplementedTests[],
    "Options" -> <|"Source" -> "ExistingScan"|>,
    "Note" -> If[trials === {} || Length[trials] === 1,
      "Trial log missing or trimmed — set $HRFFindObstructionsStoreAllTrialsQ=True and re-scan for full audit.",
      "Analyzed stored ObstructionAttemptData."
    ]
  |>
];

hrfWideAngleBoundaryDiagnosticReport[diag_Association] := Module[
  {rows, valid, best, accGens, lines},
  If[! AssociationQ[diag], Return["Not a diagnostic association."]];
  rows = Lookup[diag, "TrialRows", {}];
  valid = Lookup[diag, "ValidTrialIndices", {}];
  best = Lookup[diag, "BestRankIndex", Missing[]];
  accGens = Lookup[diag, "FinderAcceptedGenerators", {}];
  lines = Flatten @ {
    "=== Wide-angle boundary diagnostic ===",
    Lookup[Lookup[diag, "Spec", <||>], "Label", Lookup[diag, "Spec", "Target", "--"]],
    "Elapsed (s): " <> ToString[NumberForm[Lookup[diag, "ElapsedSeconds", 0], {6, 1}]],
    Lookup[diag, "Note", Nothing],
    "Candidates tried: " <> ToString[Length[rows]],
    "Valid trials (hrfValidObstructionTrialQ): " <> ToString[Length[valid]],
    "Finder accepted generators: " <> ToString[InputForm[accGens]],
    If[valid =!= {} && ! MissingQ[best],
      "Best-ranked valid trial index: " <> ToString[best] <>
        " | ValidTrialQ=" <> ToString[Lookup[rows[[best]], "ValidTrialQ", False]] <>
        " | KinSectorPresentationQ=" <> ToString[Lookup[rows[[best]], "KinSectorPresentationQ", False]] <>
        " | ScalingFoundQ=" <> ToString[Lookup[rows[[best]], "ScalingFoundQ", "n/a"]],
      "Best-ranked valid trial: (none)"
    ],
    If[valid =!= {} && ! MissingQ[best] && Lookup[rows[[best]], "ValidTrialQ", False],
      "*** Rank-best valid trial differs from finder output — check SelectionRank vs StopOnFirstAdmissible ***",
      If[valid === {} && accGens =!= {},
        "*** Finder accepted generators but no trial passes ValidTrialQ (missing sector filter on stored scan?) ***",
        Nothing
      ]
    ],
    "",
    "Tests enforced in finder vs reporting-only:",
    "  (see ImplementedTests dataset in result)",
    "",
    "Valid trials summary:",
    If[valid === {}, "  (none)", StringRiffle[
      ("  #" <> ToString[#] <> " gens=" <> ToString[Lookup[rows[[#]], "GeneratorCount", "--"]] <>
        " kinFree=" <> ToString[Lookup[rows[[#]], "KinFreeGeneratorsQ", False]] <>
        " sector=" <> ToString[Lookup[rows[[#]], "KinSectorPresentationQ", False]] <>
        " scaling=" <> ToString[Lookup[rows[[#]], "ScalingFoundQ", "n/a"]]) & /@ valid, "\n"]
    ]
  };
  Print[StringRiffle[lines, "\n"]];
  diag
];

hrfWideAngleBoundaryDiagnostic[target_: "HyperCrownX11", opts:OptionsPattern[]] := Module[
  {spec, rescanQ, runScalingQ, diag, tbl},
  If[! AssociationQ[spec = hrfWideAngleBoundarySpec[target]], Return[spec]];
  rescanQ = TrueQ @ Replace[OptionValue["RescanQ"], Automatic -> True];
  runScalingQ = Which[
    OptionValue["RunScalingQ"] =!= Automatic, TrueQ[OptionValue["RunScalingQ"]],
    True, TrueQ[$HRFBoundaryDiagnosticRunScalingQ]
  ];
  diag = If[TrueQ[rescanQ],
    hrfWideAngleBoundaryDiagnosticScan[spec,
      "GeneratorMode" -> OptionValue["GeneratorMode"],
      "StopOnFirstAdmissible" -> OptionValue["StopOnFirstAdmissible"],
      "CandidateGeneratorSetLimit" -> OptionValue["CandidateGeneratorSetLimit"],
      "StoreAllObstructionTrialsQ" -> OptionValue["StoreAllObstructionTrialsQ"],
      "RunScalingQ" -> runScalingQ
    ],
    Missing["RescanDisabled", "Set RescanQ -> True or analyze existing scan with hrfWideAngleBoundaryDiagnosticFromScan"]
  ];
  If[! AssociationQ[diag], Return[diag]];
  hrfWideAngleBoundaryDiagnosticReport[diag];
  tbl = Dataset[Lookup[diag, "TrialRows", {}]];
  {tbl, diag}
];

Options[hrfWideAngleBoundaryDiagnostic] = Join[
  Options[hrfWideAngleBoundaryDiagnosticScan],
  {"RescanQ" -> True}
];

hrfWideAngleBoundaryCompareModes[target_String:"HyperCrownX11"] := Module[
  {spec, modes = {"PairSectors", "Adaptive"}, diags, summary},
  If[! AssociationQ[spec = hrfWideAngleBoundarySpec[target]], Return[spec]];
  diags = Association @ Map[
    Function[m,
      m -> Module[{d},
        d = hrfWideAngleBoundaryDiagnosticScan[spec,
          "GeneratorMode" -> m,
          "StopOnFirstAdmissible" -> True,
          "StoreAllObstructionTrialsQ" -> False,
          "RunScalingQ" -> False
        ];
        <|
          "Mode" -> m,
          "ElapsedSeconds" -> d["ElapsedSeconds"],
          "CandidateCount" -> Lookup[d["Scan"], "CandidateGeneratorCount", 0],
          "ValidTrialCount" -> Length[d["ValidTrialIndices"]],
          "AcceptedGenerators" -> d["FinderAcceptedGenerators"],
          "BestValidTrial" -> If[Length[d["ValidTrialIndices"]] > 0,
            d["TrialRows"][[First[d["ValidTrialIndices"]]]], Missing["None"]]
        |>
      ]
    ],
    modes
  ];
  summary = Dataset[Values[diags]];
  Print["=== Mode comparison: ", target, " ==="];
  Print[summary];
  <|"Target" -> target, "Modes" -> diags, "Summary" -> summary|>
];

If[! TrueQ[$HRFWideAngleBoundaryDiagnosticLoadedQ] && ! TrueQ[$HRFQuietReports],
  Print["[loaded] HRF_WideAngleBoundaryDiagnostic.wl — try hrfWideAngleBoundaryDiagnostic[\"HyperCrownX11\"]"]
];
$HRFWideAngleBoundaryDiagnosticLoadedQ = True;
