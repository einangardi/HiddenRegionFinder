(* ::Package:: *)
(* 02_Forward_Regge_2to2_Massless.wl

   Massless 4 -> 2 examples in the Regge / forward limit.
   Mirrors Example 01 (Crown, SuperCrown, HyperCrown, Diving Beetle) with:
     - wide-angle massless baseline (s12 and s23 both active)
     - three Regge channels T23, T12, T13 (small t = -\[Delta]*s)

   Usage:
     Get["HiddenRegionFinder.wl"];
     Get["02_Forward_Regge_2to2_Massless.wl"];

   Optional flags:
     $HRFRunEx02BoundariesOnLoad = False   (* default: core only; run hrfEx02RunSuperCrownBoundary[] etc. *)
     $HRFRunEx02HyperCrownBoundaries = True
     $HRFEx02HyperCrownBoundaryMode = "X11Only" | "All" | "None"
     $HRFRunEx02InteriorStudiesOnLoad = False   (* True runs 16 interior scans; hour-scale + high RAM *)
     $HRFRunEx02LegacyCrownForwardOnLoad = False
     $HRFRunEx02SuperCrownBoundary = True
     $HRFEx02SuperCrownBoundaryMode = "X89Only" | "Codim1" | "All"
     $HRFRunEx02CrownSanityOnLoad = True
     $HRFFindObstructionsStopOnFirstAdmissibleQ = False   (* enumerate admissible sets; HR by coverage scaling *)
     $HRFCandidateGeneratorSetLimit = 64
     $HRFEx02CrownSanityChannels = {"T23"}   (* {"T23","T12","T13"} for all channels *)
     $HRFEx02DeepTrimScanStorageQ = True   (* drop ValidTrialScalingEvaluations / HiddenRegionScans *)
     $HRFExample02Report = True
     Reporting: hrfEx02ReggeChannelDisplay[diagram, region, channel] after boundary runs
*)

If[! ValueQ[$HRFExample02Report], $HRFExample02Report = True];
If[! ValueQ[$HRFRunEx02SuperCrownBoundary], $HRFRunEx02SuperCrownBoundary = True];
(* SuperCrown boundary strata: X89Only = {x8,x9} (Crown-inherited); Codim1 = four single-var strata. *)
If[! ValueQ[$HRFEx02SuperCrownBoundaryMode], $HRFEx02SuperCrownBoundaryMode = "X89Only"];
If[! ValueQ[$HRFRunEx02HyperCrownBoundaries], $HRFRunEx02HyperCrownBoundaries = True];
(* "All" = 15 strata of {x8,x9,x10,x11}; "X11Only" = single {x11}=0 (fast, matches Ex01 target). *)
If[! ValueQ[$HRFEx02HyperCrownBoundaryMode], $HRFEx02HyperCrownBoundaryMode = "X11Only"];
If[! ValueQ[$HRFRunEx02InteriorStudiesOnLoad], $HRFRunEx02InteriorStudiesOnLoad = False];
If[! ValueQ[$HRFRunEx02LegacyCrownForwardOnLoad], $HRFRunEx02LegacyCrownForwardOnLoad = False];
If[! ValueQ[$HRFRunEx02DBBoundary], $HRFRunEx02DBBoundary = False];
(* False = load diagram defs only; run hrfEx02RunSuperCrownBoundary[] / hrfEx02RunHyperCrownBoundary[] per session. *)
If[! ValueQ[$HRFRunEx02BoundariesOnLoad], $HRFRunEx02BoundariesOnLoad = False];
If[! ValueQ[$HRFRunEx02CrownSanityOnLoad], $HRFRunEx02CrownSanityOnLoad = True];
If[! ValueQ[$HRFEx02CrownSanityChannels], $HRFEx02CrownSanityChannels = {"T23"}];
If[! ValueQ[$HRFEx02TrimScanStorageQ], $HRFEx02TrimScanStorageQ = True];
(* Deep trim drops ValidTrialScalingEvaluations / HiddenRegionScans (keeps GeneratorSetScalingSummary). *)
If[! ValueQ[$HRFEx02DeepTrimScanStorageQ], $HRFEx02DeepTrimScanStorageQ = True];
(* Match Ex01/Ex04: enumerate admissible generator sets; coverage LP picks HR by scaling. *)
If[! ValueQ[$HRFFindObstructionsStopOnFirstAdmissibleQ], $HRFFindObstructionsStopOnFirstAdmissibleQ = False];
If[! ValueQ[$HRFCandidateGeneratorSetLimit], $HRFCandidateGeneratorSetLimit = 64];
If[! ValueQ[$HRFEx02ObstructionProgressQ], $HRFEx02ObstructionProgressQ = TrueQ[$HRFExample02Report]];
If[! ValueQ[$HRFScalingReport], $HRFScalingReport = False];

$HRFExample02Directory = If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName],
  Quiet[Check[NotebookDirectory[], Directory[]]]
];

If[! TrueQ[$HRFFinderCoreLoadedQ], Get[$HRFExample02Directory <> "HiddenRegionFinder.wl"]];
Get[$HRFExample02Directory <> "HRF_Example01Common.wl"];
Get[$HRFExample02Directory <> "HRF_FinalLogicPatch.wl"];
Get[$HRFExample02Directory <> "HRF_Example01Reporting.wl"];
Get[$HRFExample02Directory <> "HRF_Example02ReggeKinematics.wl"];
Get[$HRFExample02Directory <> "HRF_Example02Reporting.wl"];
Get[$HRFExample02Directory <> "HRF_PolynomialFactorReporting.wl"];

(* Two-loop topologies need polynomial cancellation factors (not just binomials). *)
If[! ValueQ[$HRFEx02PolynomialMaxMonomials], $HRFEx02PolynomialMaxMonomials = 12];
If[! ValueQ[$HRFUsePolynomialCancellationFactors], $HRFUsePolynomialCancellationFactors = True];
$HRFPolynomialMaxMonomials = $HRFEx02PolynomialMaxMonomials;
If[! ValueQ[hrfInstallPolynomialCancellationPatch],
  Get[$HRFExample02Directory <> "HRF_PolynomialCancellationFactors.wl"]
];
hrfInstallPolynomialCancellationPatch[];
(* Match Ex04 notebook: domain FindInstance filter slows 2-loop scans without changing physics. *)
If[! ValueQ[$HRFPolynomialRequireKinematicDomainQ], $HRFPolynomialRequireKinematicDomainQ = False];

ClearAll[hrfExample02Say, makeFourPointMasslessF, hrfEx02ReggeCancellationFactors,
  hrfEx02RunObstructionScan, hrfEx02InteriorStudy, hrfEx02BoundaryStudy, hrfEx02DrawDiagram,
  hrfEx02ChannelMeta, hrfEx02TrimScanForNotebook, hrfEx02ReleaseScanMemory, hrfEx02MemoryFootprint,
  hrfEx02RunSuperCrownBoundary, hrfEx02RunHyperCrownBoundary, hrfEx02RunDBBoundary,
  hrfEx02FinaliseBoundaryReporting, hrfEx02BoundariesOnLoadQ, hrfEx02RunCrownSanityCheck];

hrfExample02Say[msg_] := If[TrueQ[$HRFExample02Report], Print["[Example 02] " <> msg]];

hrfEx02BoundariesOnLoadQ[] := Which[
  $HRFRunEx02BoundariesOnLoad === False, False,
  $HRFRunEx02BoundariesOnLoad === True, True,
  True,
    TrueQ[$HRFRunEx02SuperCrownBoundary] || TrueQ[$HRFRunEx02HyperCrownBoundaries] ||
      TrueQ[$HRFRunEx02DBBoundary]
];

hrfEx02TrimScanForNotebook[scan_] := Module[{trimmed},
  If[! TrueQ[$HRFEx02TrimScanStorageQ] || ! AssociationQ[scan], Return[scan]];
  trimmed = KeyDrop[scan, {
    "ObstructionAttemptData", "AdmissibleObstructionAttemptData",
    "CandidateGeneratorSets", "CandidateGeneratorSetDiagnostics",
    "CandidateGeneratorFactorData", "AdmissibleCandidateGeneratorFactorData",
    "AdmissibleCandidateGeneratorSetFactorUnions"
  }];
  If[TrueQ[$HRFEx02DeepTrimScanStorageQ],
    trimmed = KeyDrop[trimmed, {"ValidTrialScalingEvaluations", "HiddenRegionScans"}]
  ];
  trimmed
];

(* Drop bulky scan associations after Ingredients/tables are extracted. Safe after In[6b]/In[10e]. *)
hrfEx02ReleaseScanMemory[] := Module[{n = 0},
  If[ValueQ[Ex02CrownSanityScans], Ex02CrownSanityScans = <||>; n++ ];
  If[ListQ[Ex02BoundaryRows],
    Ex02BoundaryRows = Map[
      Function[row,
        If[AssociationQ[row],
          KeyDrop[row, {"ChannelScans", "FRestricted"}],
          row
        ]
      ],
      Ex02BoundaryRows
    ];
    n++
  ];
  Print["[Example 02] released scan memory (ChannelScans, FRestricted, CrownSanityScans). ",
    "Re-run boundary cells to restore channel Ingredients display."];
  n
];

hrfEx02MemoryFootprint[] := Module[{byteCount, label},
  byteCount[s_] := If[ValueQ[s], ByteCount[s], 0];
  label[s_, name_] := <|"Symbol" -> name, "Bytes" -> byteCount[s]|>;
  Dataset @ SortBy[
    Join[
      {label[Ex02Diagrams, "Ex02Diagrams"], label[Ex02CrownSanityScans, "Ex02CrownSanityScans"],
       label[Ex02CrownSanityRow, "Ex02CrownSanityRow"], label[Ex02BoundaryRows, "Ex02BoundaryRows"]},
      If[ListQ[Ex02BoundaryRows],
        Table[
          With[{row = Ex02BoundaryRows[[i]]},
            <|"Symbol" -> "Ex02BoundaryRows[[" <> ToString[i] <> "]]",
              "Bytes" -> byteCount[row],
              "ChannelScansBytes" -> If[AssociationQ[row] && KeyExistsQ[row, "ChannelScans"],
                byteCount[row["ChannelScans"]], 0]|>
          ],
          {i, Length[Ex02BoundaryRows]}
        ],
        {}
      ]
    ],
    -Lookup[#, "Bytes", 0] &
  ]
];

makeFourPointMasslessF[internalLines_, externalLines_] := Module[{uf, f, vars},
  uf = SymanzikUF[internalLines, externalLines];
  f = toCyclicMandelstams4ptMassless[uf["F"]];
  vars = uf["Variables"];
  <|"UF" -> uf, "F" -> Expand[f], "Vars" -> vars|>
];

hrfEx02DrawDiagram[internalEdges_, externalEdges_] := If[ValueQ[hrfEx02ShowDiagram],
  hrfEx02ShowDiagram[internalEdges, externalEdges],
  drawGraphFromPySecDecInput[internalEdges, externalEdges]
];

(* Massless wide-angle 2->2 channel: s12 > -s23 > 0. *)
KinAssump4ptWideMassless = s12 > -s23 > 0;
KinVars4ptWideMassless = {s12, s23};

(* Regge-leading F often has no channel-direction factors with a single kin var.
   Supplement with the wide-angle factor pool from the full F, filtered to the
   active Regge kinematic domain. *)
hrfEx02ReggeCancellationFactors[Ffull_, fRegge_, vars_, kinAssump_, kinVars_] := Module[
  {facR, facW, merged},
  facR = safeCancellationFactorsExtended[fRegge, vars, kinAssump, kinVars, {}][[1]];
  facW = safeCancellationFactorsExtended[Ffull, vars, KinAssump4ptWideMassless, KinVars4ptWideMassless, {}][[1]];
  merged = DeleteDuplicates @ Join[
    facR,
    Select[facW, positiveCompatibleQ[#, vars, kinAssump, kinVars] &]
  ];
  merged
];

hrfEx02ChannelMeta[channel_, Finput_, vars_, kinAssump_, kinVars_, scan_, Ffull_:Automatic] := Module[
  {facPool},
  facPool = Which[
    channel === "Wide" || Ffull === Automatic,
      Length[Lookup[scan, "CancellationFactors", {}]],
    True,
      Length[hrfEx02ReggeCancellationFactors[Ffull, Finput, vars, kinAssump, kinVars]]
  ];
  <|
    "FMonomialCount" -> Length[MonomialList[Finput, vars]],
    "FactorPoolSize" -> facPool,
    "GeneratorMode" -> "PairSectors",
    "MaxGenerators" -> If[channel === "Wide", 2, 1],
    "ExactReductionQ" -> If[ValueQ[hrfExactReductionQ], hrfExactReductionQ[scan], False],
    "DecompositionOK" -> hrfEx02DecompositionOKQ[scan],
    "AdmissibleQ" -> TrueQ[Lookup[scan, "AdmissibleGeneratorSetQ", False]],
    "GeneratorCount" -> Length[Lookup[scan, "Generators", {}]]
  |>
];

hrfEx02RunObstructionScan[F_, vars_, kinAssump_, kinVars_, maxSize_:Automatic, Ffull_:Automatic, U_:Automatic, kinLimit_:Automatic] := Module[
  {reggeQ = Ffull =!= Automatic || (Length[kinVars] === 1 && MemberQ[{s12, s23}, First[kinVars]]),
   limit, scan},
  limit = Which[
    kinLimit =!= Automatic, kinLimit,
    reggeQ, "Regge4pt",
    True, "WideAngle4ptBoundary"
  ];
  scan = findObstructions[
    F, vars, kinAssump, kinVars, maxSize,
    "UseExtendedFactors" -> True,
    Sequence @@ hrfKinematicLimitObstructionOptions[limit],
    "StopOnFirstAdmissible" -> TrueQ[$HRFFindObstructionsStopOnFirstAdmissibleQ],
    "CandidateGeneratorSetLimit" -> $HRFCandidateGeneratorSetLimit,
    "CancellationFactorOverride" -> If[reggeQ,
      hrfEx02ReggeCancellationFactors[Ffull, F, vars, kinAssump, kinVars],
      Automatic],
    Sequence @@ If[! MatchQ[U, Automatic | Missing], {"U" -> U}, {}],
    "StoreAllObstructionTrialsQ" -> ! TrueQ[$HRFEx02TrimScanStorageQ]
  ];
  If[! MatchQ[U, Automatic | Missing] && AssociationQ[scan] && ! hrfScanCoverageScalingReadyQ[scan],
    hrfAttachCoverageScalingData[scan, U, vars, 5],
    scan
  ]
];

hrfEx02InteriorStudy[diagram_, data_Association, maxSize_:Automatic] := Module[
  {F = data["F"], vars = data["Vars"], U = data["UF"]["U"], wideScan, rows = {}, study, channelScans = <||>},
  hrfExample02Say[diagram <> ": interior wide-angle scan."];
  wideScan = hrfEx02TrimScanForNotebook @ hrfEx02RunObstructionScan[
    F, vars, KinAssump4ptWideMassless, KinVars4ptWideMassless, maxSize, Automatic, U, "WideAngle4ptExhaustive"];
  channelScans = <|"Wide" -> wideScan|>;
  study = <|
    "Diagram" -> diagram,
    "Data" -> data,
    "ChannelScans" -> channelScans,
    "Wide" -> hrfEx02StudyRow[diagram, "Interior wide-angle", "Wide", {}, vars, wideScan, U,
      hrfCoverageData[wideScan, U, vars, 5], 5]
  |>;
  Do[
    Module[{fRegge, kv, ka, scan, cov},
      hrfExample02Say[diagram <> ": interior Regge channel " <> regCh <> "."];
      fRegge = hrfReggeLeadingF[F, regCh];
      kv = hrfReggeKinVars[regCh];
      ka = hrfReggeKinAssumptions[regCh];
      scan = hrfEx02TrimScanForNotebook @ hrfEx02RunObstructionScan[fRegge, vars, ka, kv, maxSize, F, U];
      channelScans = Join[channelScans, <|regCh -> scan|>];
      cov = hrfCoverageData[scan, U, vars, 5];
      study = Join[study, <|regCh -> hrfEx02StudyRow[diagram, "Interior Regge " <> regCh, regCh, {}, vars, scan, U, cov, 5]|>];
    ],
    {regCh, hrfReggeChannels[]}
  ];
  Join[study, <|"ChannelScans" -> channelScans|>]
];

hrfEx02BoundaryStudy[diagram_, data_Association, zeroVars_List, regionLabel_, maxSize_:Automatic] := Module[
  {F = data["F"], U = data["UF"]["U"], fB, varsB, uB, wideScan, row, channelMeta = <||>, channelScans = <||>, t0},
  fB = Expand[F /. Thread[zeroVars -> 0]];
  varsB = Complement[data["Vars"], zeroVars];
  uB = Expand[U /. Thread[zeroVars -> 0]];
  If[fB === 0,
    Return[<|
      "Diagram" -> diagram,
      "Region" -> regionLabel,
      "ZeroVars" -> zeroVars,
      "Status" -> "TrivialBoundary",
      "FRestricted" -> 0,
      "ChannelScans" -> <||>,
      "Wide" -> <|"Hidden region identified?" -> "No", "Comment" -> "trivial: restricted F is zero",
        "Kinematic regime" -> "Wide", "Diagram" -> diagram|>,
      "T23" -> <|"Hidden region identified?" -> "No", "Comment" -> "trivial: restricted F is zero",
        "Kinematic regime" -> "T23", "Diagram" -> diagram|>,
      "T12" -> <|"Hidden region identified?" -> "No", "Comment" -> "trivial: restricted F is zero",
        "Kinematic regime" -> "T12", "Diagram" -> diagram|>,
      "T13" -> <|"Hidden region identified?" -> "No", "Comment" -> "trivial: restricted F is zero",
        "Kinematic regime" -> "T13", "Diagram" -> diagram|>
    |>]
  ];
  hrfExample02Say[diagram <> " " <> regionLabel <> ": wide-angle obstruction + scaling (PairSectors, polynomial) ..."];
  t0 = AbsoluteTime[];
  wideScan = hrfEx02TrimScanForNotebook @ hrfEx02RunObstructionScan[
    fB, varsB, KinAssump4ptWideMassless, KinVars4ptWideMassless, maxSize, Automatic, uB, "WideAngle4ptBoundary"];
  channelScans = <|"Wide" -> wideScan|>;
  channelMeta = <|"Wide" -> hrfEx02ChannelMeta["Wide", fB, varsB, KinAssump4ptWideMassless, KinVars4ptWideMassless, wideScan]|>;
  row = <|
    "Diagram" -> diagram,
    "Region" -> regionLabel,
    "ZeroVars" -> zeroVars,
    "FRestricted" -> fB,
    "URestricted" -> uB,
    "RemainingVars" -> varsB,
    "ChannelScans" -> channelScans,
    "Wide" -> hrfEx02StudyRow[diagram, regionLabel <> " wide-angle", "Wide", zeroVars, varsB, wideScan, uB,
      hrfCoverageData[wideScan, uB, varsB, 5], 5]
  |>;
  hrfExample02Say[diagram <> " " <> regionLabel <> ": wide done (" <>
    ToString[NumberForm[AbsoluteTime[] - t0, {6, 1}]] <> " s); HR=" <>
    Lookup[row["Wide"], "Hidden region identified?", "No"]];
  Do[
    Module[{fRegge, kv, ka, scan, cov, t1},
      hrfExample02Say[diagram <> " " <> regionLabel <> ": Regge channel " <> regCh <> " obstruction + scaling ..."];
      t1 = AbsoluteTime[];
      fRegge = hrfReggeLeadingF[fB, regCh];
      kv = hrfReggeKinVars[regCh];
      ka = hrfReggeKinAssumptions[regCh];
      scan = hrfEx02TrimScanForNotebook @ hrfEx02RunObstructionScan[fRegge, varsB, ka, kv, maxSize, fB, uB];
      channelScans = Join[channelScans, <|regCh -> scan|>];
      cov = hrfCoverageData[scan, uB, varsB, 5];
      channelMeta = Join[channelMeta, <|
        regCh -> hrfEx02ChannelMeta[regCh, fRegge, varsB, ka, kv, scan, fB]
      |>];
      row = Join[row, <|regCh -> hrfEx02StudyRow[diagram, regionLabel <> " Regge " <> regCh, regCh, zeroVars, varsB, scan, uB, cov, 5]|>];
      hrfExample02Say[diagram <> " " <> regionLabel <> ": Regge " <> regCh <> " done (" <>
        ToString[NumberForm[AbsoluteTime[] - t1, {6, 1}]] <> " s); HR=" <>
        Lookup[row[regCh], "Hidden region identified?", "No"]];
    ],
    {regCh, hrfReggeChannels[]}
  ];
  Join[row, <|"ChannelMeta" -> channelMeta, "ChannelScans" -> channelScans|>]
];

hrfEx02RunCrownSanityCheck[] := Module[{data, F, vars, U, rows = {}, row, t0, regCh, fRegge, kv, ka, scan, channels, sanityScans = <||>},
  data = Ex02Diagrams["Crown"];
  F = data["F"];
  vars = data["Vars"];
  U = data["UF"]["U"];
  channels = Intersection[$HRFEx02CrownSanityChannels, hrfReggeChannels[]];
  If[channels === {}, channels = {"T23"}];
  hrfExample02Say["Crown: interior Regge sanity (" <> StringRiffle[channels, "/"] <>
    ", PairSectors MaxGenerators=1, polynomial) ..."];
  t0 = AbsoluteTime[];
  Do[
    fRegge = hrfReggeLeadingF[F, regCh];
    kv = hrfReggeKinVars[regCh];
    ka = hrfReggeKinAssumptions[regCh];
    scan = hrfEx02TrimScanForNotebook @ hrfEx02RunObstructionScan[fRegge, vars, ka, kv, Automatic, F, U];
    sanityScans = Join[sanityScans, <|regCh -> scan|>];
    row = hrfEx02StudyRow["Crown", "Interior Regge " <> regCh, regCh, {}, vars, scan, U,
      hrfCoverageData[scan, U, vars, 5], 5];
    AppendTo[rows, row],
    {regCh, channels}
  ];
  Ex02CrownSanityRow = Dataset[rows];
  Ex02CrownSanityScans = sanityScans;
  hrfExample02Say["Crown Regge sanity: done (" <> ToString[NumberForm[AbsoluteTime[] - t0, {6, 1}]] <> " s); " <>
    StringRiffle[
      (Lookup[#, "Kinematic regime", "--"] <> " HR=" <> Lookup[#, "Hidden region identified?", "No"]) & /@ rows,
      "; "
    ]];
  Dataset[rows]
];

(* ---------------------------------------------------------------------- *)
(* Diagram definitions (same topologies as Example 01, massless external legs) *)
(* ---------------------------------------------------------------------- *)

CrownInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 6}}, {"0", {2, 5}}, {"0", {2, 6}},
  {"0", {3, 5}}, {"0", {3, 6}}, {"0", {4, 5}}, {"0", {4, 6}}
};
CrownExternalEdges = {{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}};

SuperCrownInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 6}}, {"0", {2, 7}}, {"0", {2, 6}},
  {"0", {3, 5}}, {"0", {3, 8}}, {"0", {4, 7}}, {"0", {4, 8}},
  {"0", {5, 7}}, {"0", {6, 8}}, {"0", {7, 8}}, {"0", {5, 6}}
};
SuperCrownExternalEdges = CrownExternalEdges;

HyperCrownInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 6}}, {"0", {4, 9}}, {"0", {4, 6}}, {"0", {2, 7}}, {"0", {2, 6}},
  {"0", {3, 8}}, {"0", {3, 6}}, {"0", {9, 5}}, {"0", {7, 8}},
  {"0", {8, 9}}, {"0", {5, 7}}
};
HyperCrownExternalEdges = CrownExternalEdges;

DBInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 7}}, {"0", {7, 4}}, {"0", {4, 9}},
  {"0", {9, 3}}, {"0", {3, 5}}, {"0", {2, 5}}, {"0", {2, 6}},
  {"0", {6, 8}}, {"0", {6, 4}}, {"0", {9, 8}}, {"0", {8, 7}}
};
DBExternalEdges = CrownExternalEdges;

Ex02Diagrams = Module[{t0, diags},
  If[TrueQ[$HRFExample02Report],
    Print["[Example 02] building massless diagram UF data (4 topologies)..."]
  ];
  t0 = AbsoluteTime[];
  diags = <|
    "Crown" -> makeFourPointMasslessF[CrownInternalEdges, CrownExternalEdges],
    "SuperCrown" -> makeFourPointMasslessF[SuperCrownInternalEdges, SuperCrownExternalEdges],
    "HyperCrown" -> makeFourPointMasslessF[HyperCrownInternalEdges, HyperCrownExternalEdges],
    "Diving Beetle" -> makeFourPointMasslessF[DBInternalEdges, DBExternalEdges]
  |>;
  If[TrueQ[$HRFExample02Report],
    Print["[Example 02] diagram UF data ready (", NumberForm[AbsoluteTime[] - t0, {4, 1}], " s)"]
  ];
  diags
];

(* ---------------------------------------------------------------------- *)
(* Interior studies *)
(* ---------------------------------------------------------------------- *)

Ex02InteriorStudies = If[TrueQ[$HRFRunEx02InteriorStudiesOnLoad],
  <|
    "Crown" -> hrfEx02InteriorStudy["Crown", Ex02Diagrams["Crown"], 20],
    "SuperCrown" -> hrfEx02InteriorStudy["SuperCrown", Ex02Diagrams["SuperCrown"], 20],
    "HyperCrown" -> hrfEx02InteriorStudy["HyperCrown", Ex02Diagrams["HyperCrown"], 30],
    "Diving Beetle" -> hrfEx02InteriorStudy["Diving Beetle", Ex02Diagrams["Diving Beetle"], 20]
  |>,
  <|
    "Crown" -> Missing["NotRun", "Set $HRFRunEx02InteriorStudiesOnLoad=True or call hrfEx02BuildInteriorStudies[]"],
    "SuperCrown" -> Missing["NotRun", "Set $HRFRunEx02InteriorStudiesOnLoad=True or call hrfEx02BuildInteriorStudies[]"],
    "HyperCrown" -> Missing["NotRun", "Set $HRFRunEx02InteriorStudiesOnLoad=True or call hrfEx02BuildInteriorStudies[]"],
    "Diving Beetle" -> Missing["NotRun", "Set $HRFRunEx02InteriorStudiesOnLoad=True or call hrfEx02BuildInteriorStudies[]"]
  |>
];

hrfEx02BuildInteriorStudies[] := (
  Ex02InteriorStudies = <|
    "Crown" -> hrfEx02InteriorStudy["Crown", Ex02Diagrams["Crown"], 20],
    "SuperCrown" -> hrfEx02InteriorStudy["SuperCrown", Ex02Diagrams["SuperCrown"], 20],
    "HyperCrown" -> hrfEx02InteriorStudy["HyperCrown", Ex02Diagrams["HyperCrown"], 30],
    "Diving Beetle" -> hrfEx02InteriorStudy["Diving Beetle", Ex02Diagrams["Diving Beetle"], 20]
  |>;
  Ex02InteriorStudies
);

Ex02InteriorStudyTable = If[TrueQ[$HRFRunEx02InteriorStudiesOnLoad],
  hrfEx02DiagramStudyTable[
    Flatten @ KeyValueMap[
      Function[{diagram, study},
        Lookup[study, #] & /@ Prepend[hrfReggeChannels[], "Wide"]
      ],
      Ex02InteriorStudies
    ]
  ],
  Dataset[{}]
];

Ex02InteriorComparisonTables = If[TrueQ[$HRFRunEx02InteriorStudiesOnLoad],
  Association @@ (
    (#[[1]] -> hrfEx02InteriorComparisonTable[#[[2]]]) & /@
      Select[Normal[Ex02InteriorStudies], AssociationQ[#[[2]]] &]
  ),
  <||>
];

(* ---------------------------------------------------------------------- *)
(* Boundary studies (one diagram per kernel session recommended)          *)
(* ---------------------------------------------------------------------- *)

If[! ValueQ[Ex02BoundaryRows] || ! ListQ[Ex02BoundaryRows], Ex02BoundaryRows = {}];

hrfEx02RunSuperCrownBoundary[] := Module[{row},
  hrfExample02Say["SuperCrown: boundary study on {x8,x9}=0 (Crown-inherited stratum)."];
  row = hrfEx02BoundaryStudy["SuperCrown", Ex02Diagrams["SuperCrown"], {x8, x9}, "Boundary {x8,x9}"];
  Ex02BoundaryRows = Join[Ex02BoundaryRows, {row}];
  hrfEx02FinaliseBoundaryReporting[];
  hrfEx02BoundaryComparisonDisplay["SuperCrown"]
];

hrfEx02RunHyperCrownBoundary[] := Module[{row},
  hrfExample02Say["HyperCrown: boundary study on {x11}=0 only."];
  row = hrfEx02BoundaryStudy["HyperCrown", Ex02Diagrams["HyperCrown"], {x11}, "Boundary {x11}"];
  Ex02BoundaryRows = Join[Ex02BoundaryRows, {row}];
  hrfEx02FinaliseBoundaryReporting[];
  hrfEx02BoundaryComparisonDisplay["HyperCrown"]
];

hrfEx02RunDBBoundary[] := Module[{row},
  hrfExample02Say["Diving Beetle: boundary study on {x8,x9}=0."];
  row = hrfEx02BoundaryStudy["Diving Beetle", Ex02Diagrams["Diving Beetle"], {x8, x9}, "Boundary {x8,x9}"];
  Ex02BoundaryRows = Join[Ex02BoundaryRows, {row}];
  hrfEx02FinaliseBoundaryReporting[];
  row
];

hrfEx02FinaliseBoundaryReporting[] := Module[{},
  Ex02LoadCompleteQ = True;
  Ex02BoundaryComparisonTables = If[Ex02BoundaryRows === {},
    <||>,
    <|
      "SuperCrown" -> hrfEx02BoundaryComparisonTable[
        Select[Ex02BoundaryRows, Lookup[#, "Diagram", ""] === "SuperCrown" &]
      ],
      "HyperCrown" -> hrfEx02BoundaryComparisonTable[
        Select[Ex02BoundaryRows, Lookup[#, "Diagram", ""] === "HyperCrown" &]
      ],
      "Diving Beetle" -> hrfEx02BoundaryComparisonTable[
        Select[Ex02BoundaryRows, Lookup[#, "Diagram", ""] === "Diving Beetle" &]
      ]
    |>
  ];
  Ex02SuperCrownBoundaryDetailTable = hrfEx02BoundaryChannelDetailTable["SuperCrown"];
  Ex02SuperCrownReggeChannelSummary = hrfEx02SuperCrownReggeChannelSummary[];
  Ex02HyperCrownBoundaryHRTable = hrfEx02BoundaryHRConfidenceTable["HyperCrown"];
  Ex02HyperCrownBoundaryDetailTable = hrfEx02BoundaryChannelDetailTable["HyperCrown"];
  Ex02SuperCrownBoundaryHRTable = hrfEx02BoundaryHRConfidenceTable["SuperCrown"];
  Ex02ReggeOnlyFlags = hrfEx02ReggeOnlyFlagsTable[Values[Ex02InteriorStudies], Ex02BoundaryRows];
  Ex02ComparisonNarrative = hrfEx02Narrative[Ex02ReggeOnlyFlags];
  Print["=== Example 02 boundary reporting updated ==="];
  Print["Boundary strata: ", Length[Ex02BoundaryRows]];
  True
];

If[TrueQ[hrfEx02BoundariesOnLoadQ[]],
  If[TrueQ[$HRFRunEx02SuperCrownBoundary],
    Which[
      $HRFEx02SuperCrownBoundaryMode === "Codim1",
      hrfExample02Say["SuperCrown: boundary study on codimension-1 strata {x8},{x9},{x10},{x11}."];
      Ex02SuperCrownBoundaryZeroSets = {{x8}, {x9}, {x10}, {x11}};
      Ex02BoundaryRows = Join[Ex02BoundaryRows,
        Table[
          hrfEx02BoundaryStudy[
            "SuperCrown", Ex02Diagrams["SuperCrown"],
            Ex02SuperCrownBoundaryZeroSets[[k]],
            "Boundary " <> ToString[InputForm[Ex02SuperCrownBoundaryZeroSets[[k]]]]
          ],
          {k, Length[Ex02SuperCrownBoundaryZeroSets]}
        ]
      ],
      $HRFEx02SuperCrownBoundaryMode === "All",
      hrfExample02Say["SuperCrown: boundary study on all 15 subsets of {x8,x9,x10,x11}."];
      Ex02SuperCrownBoundaryZeroSets = Subsets[{x8, x9, x10, x11}, {1, 4}];
      Ex02BoundaryRows = Join[Ex02BoundaryRows,
        Table[
          hrfEx02BoundaryStudy[
            "SuperCrown", Ex02Diagrams["SuperCrown"],
            Ex02SuperCrownBoundaryZeroSets[[k]],
            "Boundary " <> ToString[InputForm[Ex02SuperCrownBoundaryZeroSets[[k]]]]
          ],
          {k, Length[Ex02SuperCrownBoundaryZeroSets]}
        ]
      ],
      True,
      hrfEx02RunSuperCrownBoundary[]
    ];
  ];
  If[TrueQ[$HRFRunEx02HyperCrownBoundaries],
    Which[
      $HRFEx02HyperCrownBoundaryMode === "X11Only",
      hrfEx02RunHyperCrownBoundary[],
      True,
      hrfExample02Say["HyperCrown: boundary study on all 15 subsets of {x8,x9,x10,x11}."];
      Ex02HyperCrownBoundaryZeroSets = Subsets[{x8, x9, x10, x11}, {1, 4}];
      Ex02BoundaryRows = Join[Ex02BoundaryRows,
        Table[
          hrfEx02BoundaryStudy[
            "HyperCrown", Ex02Diagrams["HyperCrown"],
            Ex02HyperCrownBoundaryZeroSets[[k]],
            "Boundary " <> ToString[InputForm[Ex02HyperCrownBoundaryZeroSets[[k]]]]
          ],
          {k, Length[Ex02HyperCrownBoundaryZeroSets]}
        ]
      ]
    ];
  ];
  If[TrueQ[$HRFRunEx02DBBoundary],
    hrfEx02RunDBBoundary[]
  ];
  hrfEx02FinaliseBoundaryReporting[];
  ,
  Ex02LoadCompleteQ = True;
  Ex02BoundaryComparisonTables = <||>;
  Ex02SuperCrownBoundaryDetailTable = Dataset[{}];
  Ex02SuperCrownReggeChannelSummary = Dataset[{}];
  Ex02HyperCrownBoundaryHRTable = Dataset[{}];
  Ex02HyperCrownBoundaryDetailTable = Dataset[{}];
  Ex02SuperCrownBoundaryHRTable = Dataset[{}];
  Ex02ReggeOnlyFlags = Dataset[{}];
  Ex02ComparisonNarrative = "Run hrfEx02RunSuperCrownBoundary[] and/or hrfEx02RunHyperCrownBoundary[] (one diagram per fresh kernel).";
  If[TrueQ[$HRFRunEx02CrownSanityOnLoad],
    hrfEx02RunCrownSanityCheck[]
  ];
  Print["=== Example 02 CORE LOAD COMPLETE (no boundary scans) ==="];
  Print["Next: hrfEx02RunSuperCrownBoundary[]  OR  hrfEx02RunHyperCrownBoundary[]  in a fresh kernel each."];
];

If[TrueQ[Ex02LoadCompleteQ] && TrueQ[hrfEx02BoundariesOnLoadQ[]],
  Print["=== Example 02 LOAD COMPLETE ==="];
  Print["Boundary strata: ", Length[Ex02BoundaryRows]];
];

(* Backward-compatible Crown aliases from the original 02 file. *)
CrownMasslessData = Ex02Diagrams["Crown"];
FCrownMassless = CrownMasslessData["F"];
VarsCrown = CrownMasslessData["Vars"];
KinVars4ptSmall23 = hrfReggeKinVars["T23"];
KinAssump4ptSmall23 = hrfReggeKinAssumptions["T23"];
F0CrownSmall23 = hrfReggeLeadingF[FCrownMassless, "T23"];
(* Legacy Crown T23 alias — duplicates interior/boundary work; off by default. *)
If[TrueQ[$HRFRunEx02LegacyCrownForwardOnLoad],
  CrownForwardScan = hrfEx02RunObstructionScan[F0CrownSmall23, VarsCrown, KinAssump4ptSmall23, KinVars4ptSmall23];
  CoverageScalingTests2to2Forward = <|
    "CrownForward" -> hrfCoverageData[CrownForwardScan, CrownMasslessData["UF"]["U"], VarsCrown, 5],
    "Ex02InteriorStudies" -> Ex02InteriorStudies,
    "Ex02ReggeOnlyFlags" -> Ex02ReggeOnlyFlags
  |>,
  CrownForwardScan = Missing["NotRun", "Set $HRFRunEx02LegacyCrownForwardOnLoad=True if needed"];
  CoverageScalingTests2to2Forward = Missing["NotRun", "Set $HRFRunEx02LegacyCrownForwardOnLoad=True if needed"]
];

hrfExample02Say["ready. Boundaries on load=" <> ToString[hrfEx02BoundariesOnLoadQ[]] <>
  ", boundary rows=" <> ToString[If[ListQ[Ex02BoundaryRows], Length[Ex02BoundaryRows], 0]] <>
  ", interiorOnLoad=" <> ToString[$HRFRunEx02InteriorStudiesOnLoad] <>
  ". Use hrfEx02RunSuperCrownBoundary[] / hrfEx02RunHyperCrownBoundary[] per fresh kernel."];

If[! TrueQ[hrfEx02BoundariesOnLoadQ[]],
  Print["Next: hrfEx02RunSuperCrownBoundary[] or hrfEx02RunHyperCrownBoundary[] (one diagram per kernel)."]
];

(* Compact inspection:
hrfEx02DrawDiagram[CrownInternalEdges, CrownExternalEdges]
hrfEx02ChannelLegend[]
hrfEx02BoundaryComparisonDisplay["HyperCrown"]
hrfEx02DiagramBoundaryInspect["HyperCrown"]
Ex02HyperCrownBoundaryHRTable
hrfEx02SuperCrownBoundaryInspect[]
Ex02SuperCrownBoundaryHRTable
Ex02ReggeOnlyFlags
Ex02ComparisonNarrative

Notebook: Example_02_Regge_2to2_Debug_Demo.nb
*)
