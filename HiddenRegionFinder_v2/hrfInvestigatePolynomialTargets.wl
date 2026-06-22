(* hrfInvestigatePolynomialTargets.wl
   Deep obstruction investigation for expected polynomial hidden-region targets. *)

$HRFQuietReports = True;
$HRFExample04Report = False;

$HRFInvestigateDirectory = Which[
  StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName],
    DirectoryName[$InputFileName],
  True,
    Quiet @ Check[NotebookDirectory[], Directory[]]
];

If[! TrueQ[$HRFFinderCoreLoadedQ],
  Get[FileNameJoin[{$HRFInvestigateDirectory, "HiddenRegionFinder.wl"}]]
];
Get[FileNameJoin[{$HRFInvestigateDirectory, "HRF_PolynomialCancellationFactors.wl"}]];
Get[FileNameJoin[{$HRFInvestigateDirectory, "HRF_FinalLogicPatch.wl"}]];
Get[FileNameJoin[{$HRFInvestigateDirectory, "HRF_PolynomialFactorReporting.wl"}]];

ClearAll[hrfInvestigateScan, hrfInvestigateCase, hrfInvestigatePolynomialTargets];

hrfInvestigateScan[label_, F_, vars_, kinAssump_, kinVars_, mode_String, opts___] := Module[
  {usePoly = (mode === "Polynomial"), obs, trials, admissible, ff, diff},
  Block[{$HRFUsePolynomialCancellationFactors = usePoly},
    hrfInstallPolynomialCancellationPatch[];
    diff = hrfPolynomialFactorAudit[F, vars, kinAssump, kinVars, Automatic];
    ff = If[usePoly,
      hrfSafeCancellationFactorsPolynomial[F, vars, kinAssump, kinVars, Automatic][[1]],
      hrfBinomialOnlySafeFactorsExtended[F, vars, kinAssump, kinVars,
        If[MemberQ[kinVars, s], CollinearDimensionfulKinVars, Automatic]][[1]]
    ];
    obs = findObstructions[F, vars, kinAssump, kinVars, 20,
      "GeneratorMode" -> "Adaptive",
      "UseExtendedFactors" -> usePoly,
      "MaxGenerators" -> 2,
      "StopOnFirstAdmissible" -> False,
      "CandidateGeneratorSetLimit" -> 256,
      If[MemberQ[kinVars, s], "DimensionfulKinVars" -> {s}, Nothing],
      opts
    ];
  ];
  trials = Lookup[obs, "ObstructionAttemptData", {}];
  admissible = Select[trials, TrueQ[Lookup[#, "AdmissibleSLSectorQ", False]] &];
  <|
    "Label" -> label,
    "Mode" -> mode,
    "FactorDiff" -> <|"Binomial" -> diff["BinomialCount"], "Polynomial" -> diff["PolynomialCount"],
      "Added" -> diff["AddedFactorCount"]|>,
    "FactorCount" -> Length[ff],
    "CandidateGeneratorSets" -> Length[Lookup[obs, "CandidateGeneratorSets", {}]],
    "TrialCount" -> Length[trials],
    "AdmissibleTrialCount" -> Length[admissible],
    "Generators" -> Lookup[obs, "Generators", {}],
    "GeneratorCount" -> Length[Lookup[obs, "Generators", {}]],
    "ObstructionData" -> Lookup[obs, "ObstructionData", Missing[]],
    "AdmissibleGeneratorSetQ" -> TrueQ[Lookup[obs, "AdmissibleGeneratorSetQ", False]],
    "HiddenRegionQ" -> hrfPolyHiddenRegionQ[obs, "Interior"],
    "Superleading" -> If[AssociationQ[obs["ObstructionData"]],
      obs["ObstructionData"]["Superleading"], Missing[]],
    "Obstruction" -> If[AssociationQ[obs["ObstructionData"]],
      obs["ObstructionData"]["Obstruction"], Missing[]],
    "SLRemainder" -> If[ValueQ[hrfGeneratorUseRemainder], hrfGeneratorUseRemainder[obs], Missing[]],
    "RejectSummary" -> Counts[
      hrfPolyGeneratorDiscardReason /@ trials
    ],
    "FirstAdmissibleTrial" -> If[admissible =!= {}, admissible[[1]], Missing[]],
    "RawScan" -> obs
  |>
];

hrfInvestigateCase[title_, scans_List] := Module[{rows, anyHidden, od},
  rows = scans;
  anyHidden = Select[rows, TrueQ[Lookup[#, "HiddenRegionQ", False]] &];
  Print["\n=== ", title, " ==="];
  Do[
    Print["  [", rows[[i, "Mode"]], "] factors=", rows[[i, "FactorCount"]],
      " poly added=", rows[[i, "FactorDiff", "Added"]],
      " candSets=", rows[[i, "CandidateGeneratorSets"]],
      " trials=", rows[[i, "TrialCount"]],
      " admissible=", rows[[i, "AdmissibleTrialCount"]],
      " gens=", rows[[i, "GeneratorCount"]],
      " hiddenQ=", rows[[i, "HiddenRegionQ"]]];
    If[rows[[i, "GeneratorCount"]] > 0,
      Print["    generators=", rows[[i, "Generators"]]];
      Print["    SL=", rows[[i, "Superleading"]]];
    ];
    If[! TrueQ[rows[[i, "HiddenRegionQ"]]],
      Print["    reject counts=", rows[[i, "RejectSummary"]]];
      od = rows[[i, "ObstructionData"]];
      If[MatchQ[od, _Missing], Print["    obstruction=", od]]
    ];
    ,
    {i, Length[rows]}
  ];
  If[anyHidden === {}, Print["  >> No hidden region found in any mode."], 
    Print["  >> Hidden region found in: ", Lookup[anyHidden, "Mode"]]];
  rows
];

hrfInvestigatePolynomialTargets[] := Module[
  {results = {}, seedRef, vertex, hyperX11},

  (* --- 5pt: load core --- *)
  Get[FileNameJoin[{$HRFInvestigateDirectory, "HRF_Example03CollinearCore.wl"}]];
  hrfInstallPolynomialCancellationPatch[];

  Print["Five-point collinear (reference Seed5pt vs target ThreeLoopVertex)"];
  seedRef = hrfInvestigateCase["Seed5pt interior (reference)", {
    hrfInvestigateScan["Seed5pt", F0Seed5pt, VarsSeed5pt, KinAssump, KinVars, "Binomial"],
    hrfInvestigateScan["Seed5pt", F0Seed5pt, VarsSeed5pt, KinAssump, KinVars, "Polynomial"]
  }];
  vertex = hrfInvestigateCase["ThreeLoopVertex interior (target)", {
    hrfInvestigateScan["ThreeLoopVertex", F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt,
      KinAssump, KinVars, "Binomial"],
    hrfInvestigateScan["ThreeLoopVertex", F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt,
      KinAssump, KinVars, "Polynomial"]
  }];
  AppendTo[results, <|"Seed5pt" -> seedRef, "ThreeLoopVertex" -> vertex|>];

  (* --- HyperCrown x11=0 --- *)
  Block[{$HRFRunCrownInteriorScanOnLoad = False, $HRFRunExample01ReportingOnLoad = False,
    $HRFRunHyperCrownInteriorScan = False, $HRFRunDivingBeetleInteriorScanOnLoad = False,
    $HRFRunHyperCrownBoundaryScansOnLoad = False},
    Get[FileNameJoin[{$HRFInvestigateDirectory, "01_WideAngle_2to2_OffShell.wl"}]]
  ];
  hrfInstallPolynomialCancellationPatch[];
  hyperX11 = hrfInvestigateCase["HyperCrown boundary {x11}=0 (target)", {
    hrfInvestigateScan["HyperCrown x11=0",
      Expand[F0HyperCrown /. x11 -> 0], Complement[VarsHyperCrown, {x11}],
      KinAssump4ptOnShell, KinVars4pt, "Binomial", "UseExtendedFactors" -> True],
    hrfInvestigateScan["HyperCrown x11=0",
      Expand[F0HyperCrown /. x11 -> 0], Complement[VarsHyperCrown, {x11}],
      KinAssump4ptOnShell, KinVars4pt, "Polynomial", "UseExtendedFactors" -> True]
  }];
  AppendTo[results, <|"HyperCrownX11" -> hyperX11|>];

  <|
    "Results" -> results,
    "Summary" -> Dataset @ Flatten @ {
      <|"Case" -> "Seed5pt", "Mode" -> #["Mode"], "HiddenRegionQ" -> #["HiddenRegionQ"],
        "Factors" -> #["FactorCount"], "Generators" -> #["GeneratorCount"]|> & /@ seedRef,
      <|"Case" -> "ThreeLoopVertex", "Mode" -> #["Mode"], "HiddenRegionQ" -> #["HiddenRegionQ"],
        "Factors" -> #["FactorCount"], "Generators" -> #["GeneratorCount"]|> & /@ vertex,
      <|"Case" -> "HyperCrown x11=0", "Mode" -> #["Mode"], "HiddenRegionQ" -> #["HiddenRegionQ"],
        "Factors" -> #["FactorCount"], "Generators" -> #["GeneratorCount"]|> & /@ hyperX11
    }
  |>
];

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] hrfInvestigatePolynomialTargets[]. Evaluate to run deep target investigation."]
];
