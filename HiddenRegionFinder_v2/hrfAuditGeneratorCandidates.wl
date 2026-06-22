(* hrfAuditGeneratorCandidates.wl
   Generator combinatorics audit WITHOUT findObstructions / FindInstance.
   Use to see why candidate generator counts are large.

   hrfAuditGeneratorCandidates[F, vars, kinAssump, kinVars, label, opts]
   hrfAuditGeneratorTargets[]  -- Seed5pt, ThreeLoopVertex, HyperCrown x11=0 *)

$HRFAuditDirectory = Which[
  StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName],
    DirectoryName[$InputFileName],
  ValueQ[hrfPackageDirectory], hrfPackageDirectory[],
  True, Quiet @ Check[NotebookDirectory[], Directory[]]
];

If[! TrueQ[$HRFFinderCoreLoadedQ],
  Get[FileNameJoin[{$HRFAuditDirectory, "HiddenRegionFinder.wl"}]]
];
Get[FileNameJoin[{$HRFAuditDirectory, "HRF_PolynomialCancellationFactors.wl"}]];

ClearAll[hrfAuditGeneratorCandidates, hrfAuditGeneratorTargets, hrfAuditPrintSummary];

hrfAuditGeneratorCandidates[F_, vars_, kinAssump_, kinVars_, label_,
   mode_String : "Polynomial", dimSpec_: Automatic, kinDomainQ_: Automatic] := Module[
  {usePoly = (mode === "Polynomial"), ff, bounds, degreeOpts, phys,
   kinFree, kinMixed, opts, single2, single3, pairDiag, adaptive,
   admPairs, pairGens, physPairs, nPairsTotal, nPairsPhys,
   scanFactors, df, oldKinDomain},

  oldKinDomain = $HRFPolynomialRequireKinematicDomainQ;
  If[kinDomainQ =!= Automatic, $HRFPolynomialRequireKinematicDomainQ = TrueQ[kinDomainQ]];

  degreeOpts = <|
    "MaxGeneratorTotalDegree" -> Automatic,
    "MaxGeneratorVarExponent" -> Automatic,
    "CandidateGeneratorSetLimit" -> $HRFCandidateGeneratorSetLimit,
    "MaxGenerators" -> 2,
    "MaxProductSubsetSize" -> $HRFMaxProductSubsetSize
  |>;
  bounds = hrfResolveGeneratorDegreeBounds[F, vars, degreeOpts];

  Block[{$HRFUsePolynomialCancellationFactors = usePoly},
    hrfInstallPolynomialCancellationPatch[];
    ff = If[usePoly,
      hrfSafeCancellationFactorsPolynomial[F, vars, kinAssump, kinVars, dimSpec][[1]],
      hrfBinomialOnlySafeFactorsExtended[F, vars, kinAssump, kinVars, dimSpec][[1]]
    ];
  ];

  phys = If[TrueQ[$HRFUseGeneratorPhysicsFilterQ],
    hrfFilterFactorsForGeneratorPhysics[ff, vars, kinVars, bounds],
    <|"Factors" -> ff, "SpanRedundantKinMixed" -> {}, "KinFreeFactors" -> {}, "KinMixedFactors" -> ff|>
  ];
  kinFree = Select[ff, ! hrfFactorContainsKinVarsQ[#, kinVars] &];
  kinMixed = Select[ff, hrfFactorContainsKinVarsQ[#, kinVars] &];
  opts = degreeOpts;

  (* Single-product generators: admissible subsets of size 2 and 3 *)
  single2 = Select[Subsets[phys["Factors"], {2}],
    simultaneouslyAdmissibleSubsetQ[#, vars, kinAssump, kinVars] &&
      hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ #], bounds, vars] &
  ];
  single3 = Select[Subsets[phys["Factors"], {3}],
    simultaneouslyAdmissibleSubsetQ[#, vars, kinAssump, kinVars] &&
      hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ #], bounds, vars] &
  ];

  (* Pair-sector breakdown (diagnostic mode) *)
  pairDiag = candidateGeneratorSetsDiagnostic[ff, 2, vars, kinAssump, kinVars, F, opts];
  adaptive = candidateGeneratorSetsAdaptive[ff, vars, kinAssump, kinVars, F, opts];

  (* Physics-admissible pairs among eligible factors *)
  physFF = phys["Factors"];
  nPairsTotal = If[Length[physFF] >= 2, Length[Subsets[physFF, {2}]], 0];
  physPairs = Select[Subsets[physFF, {2}],
    hrfGeneratorPairPhysicsAdmissibleQ[#[[1]], #[[2]], bounds, vars, kinVars] &&
      simultaneouslyAdmissibleSubsetQ[#, vars, kinAssump, kinVars] &
  ];
  nPairsPhys = Length[physPairs];

  df = If[ValueQ[hrfPolynomialFactorAudit],
    hrfPolynomialFactorAudit[F, vars, kinAssump, kinVars, dimSpec],
    <|"BinomialCount" -> "--", "PolynomialCount" -> Length[ff], "AddedFactorCount" -> "--"|>
  ];

  $HRFPolynomialRequireKinematicDomainQ = oldKinDomain;

  <|
    "Label" -> label,
    "Mode" -> mode,
    "Vars" -> Length[vars],
    "BinomialFactors" -> Lookup[df, "BinomialCount", "--"],
    "PolynomialFactors" -> Lookup[df, "PolynomialCount", Length[ff]],
    "AcceptedFactors" -> Length[ff],
    "KinFreeFactors" -> Length[kinFree],
    "KinMixedFactors" -> Length[kinMixed],
    "PhysicsEligible" -> Length[physFF],
    "SpanRedundantDropped" -> Length[phys["SpanRedundantKinMixed"]],
    "SimultaneousPairs2" -> nPairsPhys,
    "TotalPairs2" -> nPairsTotal,
    "SingleProductSubsets2" -> Length[single2],
    "SingleProductSubsets3" -> Length[single3],
    "PairSectorSets" -> Length[pairDiag],
    "PairSector1Gen" -> Count[pairDiag, _?(Length[#] === 1 &)],
    "PairSector2Gen" -> Count[pairDiag, _?(Length[#] > 1 &)],
    "AdaptiveTotal" -> Length[adaptive],
    "Adaptive1Gen" -> Count[adaptive, _?(Length[#] === 1 &)],
    "Adaptive2Gen" -> Count[adaptive, _?(Length[#] > 1 &)],
    "CandidateCap" -> $HRFCandidateGeneratorSetLimit,
    "Factors" -> ff,
    "PhysicsFactors" -> physFF
  |>
];

hrfAuditPrintSummary[a_Association] := Module[{},
  Print["--- ", a["Label"], " [", a["Mode"], "] ---"];
  Print["  vars=", a["Vars"],
    "  accepted f_k=", a["AcceptedFactors"],
    " (kin-free=", a["KinFreeFactors"], ", kin-mixed=", a["KinMixedFactors"], ")"];
  Print["  physics-eligible=", a["PhysicsEligible"],
    "  span-dropped=", a["SpanRedundantDropped"]];
  Print["  pair table size C(n,2)=", a["TotalPairs2"],
    "  physics+simult adm pairs=", a["SimultaneousPairs2"]];
  Print["  single-product adm subsets: k=2 -> ", a["SingleProductSubsets2"],
    ", k=3 -> ", a["SingleProductSubsets3"]];
  Print["  PairSectors candidate sets: ", a["PairSectorSets"],
    " (1-gen=", a["PairSector1Gen"], ", 2-gen=", a["PairSector2Gen"], ")"];
  Print["  Adaptive candidate sets: ", a["AdaptiveTotal"],
    " (1-gen=", a["Adaptive1Gen"], ", 2-gen=", a["Adaptive2Gen"],
    ", cap=", a["CandidateCap"], ")"]
];

hrfAuditGeneratorTargets[] := Module[{rows = {}},
  Get[FileNameJoin[{$HRFAuditDirectory, "HRF_PolynomialCancellationFactors.wl"}]];
  Get[FileNameJoin[{$HRFAuditDirectory, "HRF_PolynomialFactorReporting.wl"}]];

  Get[FileNameJoin[{$HRFAuditDirectory, "HRF_Example03CollinearCore.wl"}]];
  hrfInstallPolynomialCancellationPatch[];

  Print["\n=== Generator candidate audit (no obstruction search) ==="];
  Print["(kin-domain FindInstance OFF for speed; set kinDomainQ->True per case if needed)\n"];

  AppendTo[rows, hrfAuditGeneratorCandidates[
    F0Seed5pt, VarsSeed5pt, KinAssump, KinVars,
    "Seed5pt (reference)", "Polynomial", CollinearDimensionfulKinVars, False]];
  hrfAuditPrintSummary[rows[[-1]]];

  AppendTo[rows, hrfAuditGeneratorCandidates[
    F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars,
    "ThreeLoopVertex (target)", "Polynomial", CollinearDimensionfulKinVars, False]];
  hrfAuditPrintSummary[rows[[-1]]];

  Block[{$HRFRunCrownInteriorScanOnLoad = False, $HRFRunExample01ReportingOnLoad = False,
    $HRFRunHyperCrownInteriorScan = False, $HRFRunDivingBeetleInteriorScanOnLoad = False,
    $HRFRunHyperCrownBoundaryScansOnLoad = False},
    Get[FileNameJoin[{$HRFAuditDirectory, "01_WideAngle_2to2_OffShell.wl"}]]
  ];
  hrfInstallPolynomialCancellationPatch[];

  AppendTo[rows, hrfAuditGeneratorCandidates[
    Expand[F0HyperCrown /. x11 -> 0], Complement[VarsHyperCrown, {x11}],
    KinAssump4ptOnShell, KinVars4pt,
    "HyperCrown x11=0 (target)", "Polynomial", Automatic, False]];
  hrfAuditPrintSummary[rows[[-1]]];

  Print["\n=== Comparison table ==="];
  Print[Dataset @ KeyDrop[#, {"Factors", "PhysicsFactors"}] & /@ rows];

  <|
    "Audits" -> rows,
    "Comparison" -> Dataset @ (KeyDrop[#, {"Factors", "PhysicsFactors"}] & /@ rows)
  |>
];

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] hrfAuditGeneratorTargets[] — fast generator combinatorics, no FindInstance."]
];
