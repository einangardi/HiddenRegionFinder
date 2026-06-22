(* hrfGeneratorCandidateDetailAudit.wl
   ~1-hour generator audit: what the capped Adaptive candidates ARE and which
   admissibility checks they satisfy.  No obstruction search / FindInstance.

   Usage:
     Get["hrfGeneratorCandidateDetailAudit.wl"];
     hrfGeneratorDetailAuditOneHour[];          (* both targets, polynomial *)
     hrfGeneratorDetailAuditOneHour["HyperCrown"];  (* one target *)

   Checks reported (candidate stage only):
     DegreeAdmissibleQ, FactorDegreeAdmissibleQ,
     IndividuallyPositiveCompatibleQ (PDF per factor, no FindInstance if kin-domain off),
     SimultaneouslyAdmissibleSubsetQ (PDF 5.12 on factor subset per generator),
     AdmissibleGeneratorQ (>=2 f_k, degree, PDF per generator),
     PerGeneratorAdmissibleQ / SimultaneouslyAdmissibleGeneratorSetQ (set level). *)

$HRFDetailAuditDirectory = Which[
  StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName],
    DirectoryName[$InputFileName],
  ValueQ[hrfPackageDirectory], hrfPackageDirectory[],
  True, Quiet @ Check[NotebookDirectory[], Directory[]]
];

If[! TrueQ[$HRFFinderCoreLoadedQ],
  Get[FileNameJoin[{$HRFDetailAuditDirectory, "HiddenRegionFinder.wl"}]]
];
Get[FileNameJoin[{$HRFDetailAuditDirectory, "HRF_PolynomialCancellationFactors.wl"}]];
Get[FileNameJoin[{$HRFDetailAuditDirectory, "HRF_PolynomialFactorReporting.wl"}]];

ClearAll[
  hrfDetailAuditResolveOpts, hrfBuildCandidateTrialsNoObstruction,
  hrfGeneratorCandidateSetRow, hrfGeneratorCandidateSetTable,
  hrfGeneratorPerGenRow, hrfGeneratorPerGenTable,
  hrfDetailAuditPoolSummary, hrfDetailAuditOneCase,
  hrfGeneratorDetailAuditOneHour, hrfDetailAuditLoadTargets
];

hrfDetailAuditResolveOpts[F_, vars_, ff_, cap_] := Module[{maxSubset},
  maxSubset = If[Length[ff] > 40, 2, If[ValueQ[$HRFMaxProductSubsetSize], $HRFMaxProductSubsetSize, 3]];
  <|
    "MaxGeneratorTotalDegree" -> Automatic,
    "MaxGeneratorVarExponent" -> Automatic,
    "CandidateGeneratorSetLimit" -> cap,
    "MaxGenerators" -> 2,
    "MaxProductSubsetSize" -> maxSubset,
    "MaxProductSubsetSizeNote" -> If[maxSubset < 3,
      "Large factor pool: MaxProductSubsetSize capped at 2 for audit runtime",
      "Default MaxProductSubsetSize"
    ]
  |>
];

(* Mirror findObstructions candidate loop through admissibility only. *)
hrfBuildCandidateTrialsNoObstruction[F_, vars_, kinAssump_, kinVars_, ff_, degreeOpts_, bounds_] := Module[
  {generatorSets, trials = {}, i, setData, perGenQ},
  generatorSets = candidateGeneratorSetsAdaptive[ff, vars, kinAssump, kinVars, F, degreeOpts];
  Do[
    setData = generatorSetAdmissibilityData[generatorSets[[i]], ff, vars, kinVars, kinAssump, bounds];
    perGenQ = TrueQ[Lookup[setData, "PerGeneratorAdmissibleQ", False]];
    AppendTo[trials, <|
      "Index" -> i,
      "Generators" -> generatorSets[[i]],
      "GeneratorCount" -> Length[generatorSets[[i]]],
      "GeneratorFactorData" -> setData["GeneratorFactorData"],
      "GeneratorSetFactorUnion" -> setData["GeneratorSetFactorUnion"],
      "GeneratorSetFactorCount" -> setData["GeneratorSetFactorCount"],
      "PerGeneratorAdmissibleQ" -> perGenQ,
      "SimultaneouslyAdmissibleGeneratorSetQ" -> setData["SimultaneouslyAdmissibleGeneratorSetQ"],
      "AdmissibleGeneratorSetQ" -> perGenQ,
      "CandidateStageDiscardReason" -> Which[
        ! perGenQ, "per-generator admissibility failed (need >=2 f_k, degree bounds, PDF 5.12 each)",
        TrueQ[setData["SimultaneouslyAdmissibleGeneratorSetQ"]], "candidate-stage admissible (union PDF ok)",
        True, "per-generator ok but union of all f_k in set fails simultaneous PDF (5.12)"
      ]
    |>],
    {i, Length[generatorSets]}
  ];
  <|"GeneratorSets" -> generatorSets, "Trials" -> trials|>
];

hrfGeneratorCandidateSetRow[trial_Association] := <|
  "Index" -> Lookup[trial, "Index", "--"],
  "GeneratorCount" -> Lookup[trial, "GeneratorCount", 0],
  "Generators" -> hrfPolynomialCompact[Lookup[trial, "Generators", {}]],
  "SetFactorCount" -> Lookup[trial, "GeneratorSetFactorCount", 0],
  "PerGeneratorAdmissibleQ" -> Lookup[trial, "PerGeneratorAdmissibleQ", False],
  "SimultaneousUnionPDFQ" -> Lookup[trial, "SimultaneouslyAdmissibleGeneratorSetQ", False],
  "CandidateStageReason" -> Lookup[trial, "CandidateStageDiscardReason", "--"]
|>;

hrfGeneratorCandidateSetTable[trials_List] := Dataset[hrfGeneratorCandidateSetRow /@ trials];

hrfGeneratorPerGenRow[trial_Association] := Module[{gd, idx, gens},
  idx = Lookup[trial, "Index", "--"];
  gens = Lookup[trial, "Generators", {}];
  gd = Lookup[trial, "GeneratorFactorData", {}];
  Flatten @ Table[
    <|
      "SetIndex" -> idx,
      "GenInSet" -> j,
      "GeneratorCountInSet" -> Length[gens],
      "Generator" -> hrfPolynomialCompact[gens[[j]]],
      "FactorCount" -> Lookup[gd[[j]], "GeneratorFactorCount", 0],
      "TotalDegree" -> Lookup[gd[[j]], "TotalDegree", "--"],
      "DegreeAdmissibleQ" -> Lookup[gd[[j]], "DegreeAdmissibleQ", False],
      "FactorDegreeAdmissibleQ" -> Lookup[gd[[j]], "FactorDegreeAdmissibleQ", False],
      "PDFPerFactorQ" -> Lookup[gd[[j]], "IndividuallyPositiveCompatibleQ", False],
      "PDFSubsetQ" -> Lookup[gd[[j]], "SimultaneouslyAdmissibleSubsetQ", False],
      "AdmissibleGeneratorQ" -> Lookup[gd[[j]], "AdmissibleGeneratorQ", False],
      "Factors" -> StringRiffle[hrfPolynomialCompact /@ Lookup[gd[[j]], "GeneratorFactors", {}], " * "]
    |>,
    {j, Length[gens]}
  ]
];

hrfGeneratorPerGenTable[trials_List] := Dataset[Flatten[hrfGeneratorPerGenRow /@ trials, 1]];

hrfDetailAuditPoolSummary[ff_, vars_, kinVars_, bounds_, label_] := Module[
  {phys, physFF, admPairs, kinFree, kinMixed},
  phys = hrfFilterFactorsForGeneratorPhysics[ff, vars, kinVars, bounds];
  physFF = phys["Factors"];
  kinFree = Select[ff, ! hrfFactorContainsKinVarsQ[#, kinVars] &];
  kinMixed = Select[ff, hrfFactorContainsKinVarsQ[#, kinVars] &];
  admPairs = Select[Subsets[physFF, {2}],
    hrfGeneratorPairPhysicsAdmissibleQ[#[[1]], #[[2]], bounds, vars, kinVars] &&
      simultaneouslyAdmissibleSubsetQ[#, vars, True, kinVars] &
  ];
  <|
    "Label" -> label,
    "AcceptedFactors" -> Length[ff],
    "KinFree" -> Length[kinFree],
    "KinMixed" -> Length[kinMixed],
    "PhysicsEligible" -> Length[physFF],
    "SpanDropped" -> Length[phys["SpanRedundantKinMixed"]],
    "PhysicsAdmissiblePairs" -> Length[admPairs],
    "MaxTotalDegree" -> Lookup[bounds, "MaxGeneratorTotalDegree", "--"],
    "MaxVarExponent" -> Lookup[bounds, "MaxGeneratorVarExponent", "--"]
  |>
];

hrfDetailAuditOneCase[F_, vars_, kinAssump_, kinVars_, label_, cap_: 64, mode_: "Polynomial"] := Module[
  {t0, t1, usePoly = (mode === "Polynomial"), ff, opts, bounds, pool, built, trials,
   perGenOK, unionOK, hist, oldKin},
  oldKin = $HRFPolynomialRequireKinematicDomainQ;
  $HRFPolynomialRequireKinematicDomainQ = False;
  t0 = AbsoluteTime[];
  Block[{$HRFUsePolynomialCancellationFactors = usePoly},
    hrfInstallPolynomialCancellationPatch[];
    ff = If[usePoly,
      hrfSafeCancellationFactorsPolynomial[F, vars, kinAssump, kinVars, Automatic][[1]],
      hrfBinomialOnlySafeFactorsExtended[F, vars, kinAssump, kinVars, Automatic][[1]]
    ];
  ];
  opts = hrfDetailAuditResolveOpts[F, vars, ff, cap];
  bounds = hrfResolveGeneratorDegreeBounds[F, vars, opts];
  pool = hrfDetailAuditPoolSummary[ff, vars, kinVars, bounds, label];
  Print["\n========== ", label, " [", mode, "] =========="];
  Print["  ", pool];
  Print["  audit opts: cap=", cap, "  ", opts["MaxProductSubsetSizeNote"]];
  Print["  building Adaptive candidates..."];
  built = hrfBuildCandidateTrialsNoObstruction[F, vars, kinAssump, kinVars, ff, opts, bounds];
  trials = built["Trials"];
  t1 = AbsoluteTime[];
  perGenOK = Count[trials, _?(TrueQ[Lookup[#, "PerGeneratorAdmissibleQ", False]] &)];
  unionOK = Count[trials, _?(TrueQ[Lookup[#, "SimultaneouslyAdmissibleGeneratorSetQ", False]] &)];
  hist = Counts[Lookup[trials, "GeneratorCount", 0]];
  Print["  elapsed ", ToString @ NumberForm[t1 - t0, {6, 1}], " s"];
  Print["  capped candidates=", Length[trials],
    "  per-gen admissible=", perGenOK,
    "  union-PDF ok=", unionOK,
    "  gen-count histogram ", Normal[hist]];
  Print["\n--- Candidate sets (compact) ---"];
  Print[hrfGeneratorCandidateSetTable[trials]];
  Print["\n--- Per-generator checks ---"];
  Print[hrfGeneratorPerGenTable[trials]];
  If[Length[ff] <= 16,
    Print["\n--- Pair table (physics-eligible f_k pairs) ---"];
    Print[hrfPolyGeneratorPairTable[<|"CancellationFactors" -> ff, "GeneratorDegreeBounds" -> bounds|>,
      vars, kinAssump, kinVars]]
  ,
    Print["\n--- Pair table skipped (", Length[ff], " factors; run hrfPolyGeneratorPairTable on a scan manually if needed) ---"];
  ];
  $HRFPolynomialRequireKinematicDomainQ = oldKin;
  <|
    "Label" -> label,
    "Mode" -> mode,
    "ElapsedSeconds" -> (t1 - t0),
    "PoolSummary" -> pool,
    "AuditOpts" -> opts,
    "CandidateCount" -> Length[trials],
    "PerGeneratorAdmissibleCount" -> perGenOK,
    "UnionPDFAdmissibleCount" -> unionOK,
    "GeneratorCountHistogram" -> hist,
    "CandidateSetTable" -> hrfGeneratorCandidateSetTable[trials],
    "PerGeneratorTable" -> hrfGeneratorPerGenTable[trials],
    "Trials" -> trials,
    "Factors" -> ff
  |>
];

hrfDetailAuditLoadTargets[] := Module[{},
  Get[FileNameJoin[{$HRFDetailAuditDirectory, "HRF_Example03CollinearCore.wl"}]];
  hrfInstallPolynomialCancellationPatch[];
  Block[{$HRFRunCrownInteriorScanOnLoad = False, $HRFRunExample01ReportingOnLoad = False,
    $HRFRunHyperCrownInteriorScan = False, $HRFRunDivingBeetleInteriorScanOnLoad = False,
    $HRFRunHyperCrownBoundaryScansOnLoad = False},
    Get[FileNameJoin[{$HRFDetailAuditDirectory, "01_WideAngle_2to2_OffShell.wl"}]]
  ];
  hrfInstallPolynomialCancellationPatch[];
];

hrfGeneratorDetailAuditOneHour[which_: All, cap_: 64] := Module[
  {t0 = AbsoluteTime[], rows = {}, t1},
  hrfDetailAuditLoadTargets[];
  Print["=== Generator detail audit (~1 h budget, no obstruction search) ==="];
  Print["cap=", cap, "  kin-domain FindInstance OFF\n"];
  If[which === All || which === "Seed5pt",
    AppendTo[rows, hrfDetailAuditOneCase[
      F0Seed5pt, VarsSeed5pt, KinAssump, KinVars,
      "Seed5pt (reference)", cap, "Polynomial"]]
  ];
  If[which === All || which === "HyperCrown" || which === "HyperCrownInterior",
    AppendTo[rows, hrfDetailAuditOneCase[
      F0HyperCrown, VarsHyperCrown, KinAssump4ptOnShell, KinVars4pt,
      "HyperCrown interior", cap, "Polynomial"]]
  ];
  If[which === All || which === "HyperCrown" || which === "HyperCrownX11",
    AppendTo[rows, hrfDetailAuditOneCase[
      Expand[F0HyperCrown /. x11 -> 0], Complement[VarsHyperCrown, {x11}],
      KinAssump4ptOnShell, KinVars4pt,
      "HyperCrown {x11}=0 (target)", cap, "Polynomial"]]
  ];
  If[which === All || which === "ThreeLoopVertex",
    AppendTo[rows, hrfDetailAuditOneCase[
      F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars,
      "ThreeLoopVertex (target)", cap, "Polynomial"]]
  ];
  t1 = AbsoluteTime[];
  Print["\n=== Timing summary ==="];
  Print[Dataset @ KeyTake[#, {"Label", "ElapsedSeconds", "CandidateCount",
    "PerGeneratorAdmissibleCount", "UnionPDFAdmissibleCount"}] & /@ rows];
  Print["Total wall time: ", ToString @ NumberForm[t1 - t0, {6, 1}], " s"];
  <|"Cases" -> rows, "TotalSeconds" -> (t1 - t0)|>
];

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] hrfGeneratorDetailAuditOneHour[] — candidate generators + admissibility checks, no FindInstance."]
];
