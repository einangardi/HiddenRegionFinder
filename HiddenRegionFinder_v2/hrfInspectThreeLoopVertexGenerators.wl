(* hrfInspectThreeLoopVertexGenerators.wl
   ThreeLoopVertex 5pt collinear: f_k pool, valid pair audit, SingleProduct resolver.
   Uses the same Collinear5pt rules as Ex03 seed study (not wide-angle Adaptive).

   Load (from HiddenRegionFinder_polynomial_factors/):
     Get["HRF_Example03CollinearCore.wl"];
     Get["HRF_PolynomialCancellationFactors.wl"];
     hrfInstallPolynomialCancellationPatch[];
     Get["HRF_Example03SeedStudy.wl"];
     hrfEx03SeedStudyLoad[];
     Get["hrfInspectThreeLoopVertexGenerators.wl"];

   Recommended:
     hrfThreeLoopVertexFactorTable[]
     hrfThreeLoopVertexGeneratorPairAuditTable[]
     hrfThreeLoopVertexGeneratorSelectionTable[]

   Full obstruction (slow):
     scan = hrfThreeLoopVertexObstructionScan[];
     hrfThreeLoopVertexInspectScan[scan]; *)

$HRFVertexInspectDirectory = Which[
  StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName],
    DirectoryName[$InputFileName],
  ValueQ[hrfPackageDirectory], hrfPackageDirectory[],
  True, Quiet @ Check[NotebookDirectory[], Directory[]]
];

If[! TrueQ[$HRFFinderCoreLoadedQ],
  Get[FileNameJoin[{$HRFVertexInspectDirectory, "HiddenRegionFinder.wl"}]]
];
Get[FileNameJoin[{$HRFVertexInspectDirectory, "HRF_PolynomialCancellationFactors.wl"}]];
Get[FileNameJoin[{$HRFVertexInspectDirectory, "HRF_FinalLogicPatch.wl"}]];
Get[FileNameJoin[{$HRFVertexInspectDirectory, "HRF_PolynomialFactorReporting.wl"}]];

If[! ValueQ[F0ThreeLoopVertex5pt],
  Get[FileNameJoin[{$HRFVertexInspectDirectory, "HRF_Example03CollinearCore.wl"}]]
];
If[! ValueQ[hrfFivePointGeneratorPairAuditTable],
  Get[FileNameJoin[{$HRFVertexInspectDirectory, "HRF_Example03SeedStudy.wl"}]]
];

ClearAll[
  hrfThreeLoopVertexStudyLoad, hrfThreeLoopVertexObstructionOptions,
  hrfThreeLoopVertexSafeFactors, hrfThreeLoopVertexFactorTable,
  hrfThreeLoopVertexGeneratorPairAuditTable, hrfThreeLoopVertexGeneratorPairAuditSummary,
  hrfThreeLoopVertexHarvestAudit, hrfThreeLoopVertexGeneratorSelectionTable,
  hrfThreeLoopVertexObstructionScan, hrfThreeLoopVertexInspectScan,
  hrfThreeLoopVertexGeneratorRows, hrfThreeLoopVertexCandidateTable,
  hrfThreeLoopVertexScalingDiagnostic
];

hrfThreeLoopVertexStudyLoad[] := Module[{},
  If[! ValueQ[hrfEx03SeedStudyLoad], Get[FileNameJoin[{$HRFVertexInspectDirectory, "HRF_Example03SeedStudy.wl"}]]];
  hrfEx03SeedStudyLoad[];
  $HRFPolynomialRequireKinematicDomainQ = False;
  $HRFUsePolynomialCancellationFactors = True;
  hrfInstallPolynomialCancellationPatch[];
  If[! TrueQ[$HRFGeneratorPhysicsFilterLoadedQ],
    Get[FileNameJoin[{$HRFVertexInspectDirectory, "HRF_GeneratorPhysicsFilter.wl"}]]
  ];
  True
];

hrfThreeLoopVertexHarvestAudit[] := Module[{pack, filtered},
  hrfThreeLoopVertexStudyLoad[];
  pack = hrfRawPolynomialCandidates[F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars, Automatic];
  filtered = hrfFilterPolynomialCandidates[pack["Raw"], VarsThreeLoopVertex5pt, KinAssump, KinVars, "Polynomial"];
  hrfSafeCancellationFactorsPolynomial[F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars];
  Dataset @ Table[
    <|
      "Index" -> i,
      "Raw" -> hrfFormatCancellationFactorDisplay[pack["Raw"][[i]], VarsThreeLoopVertex5pt, KinVars],
      "MonomialCount" -> hrfPolynomialMonomialCount[pack["Raw"][[i]], VarsThreeLoopVertex5pt],
      "AcceptedQ" -> MemberQ[filtered["Accepted"], pack["Raw"][[i]]],
      "RejectReason" -> Module[{acc = hrfCancellationFactorAcceptanceQ[pack["Raw"][[i]], VarsThreeLoopVertex5pt, KinAssump, KinVars, "Polynomial"]},
        If[TrueQ[acc["AcceptQ"]], "accepted", acc["RejectReason"]]
      ],
      "KinVars" -> StringRiffle[hrfFactorKinVarsPresent[pack["Raw"][[i]], KinVars], ","],
      "MandelstamLinearQ" -> hrfFactorMandelstamLinearQ[pack["Raw"][[i]], KinVars]
    |>,
    {i, Length[pack["Raw"]]}
  ]
];

(* Collinear5pt preset — same as hrfKinematicGeneratorPreset["Collinear5pt"]. *)
hrfThreeLoopVertexObstructionOptions[] := Join[
  hrfKinematicLimitObstructionOptions["Collinear5pt"],
  {
    "UseExtendedFactors" -> False,
    "DimensionfulKinVars" -> CollinearDimensionfulKinVars,
    "U" -> hrfEx03LeadingDeltaPolynomial[Expand[UThreeLoopVertex5pt /. collPar1]],
    "StopOnFirstAdmissible" -> False,
    "StoreAllObstructionTrialsQ" -> True
  }
];

hrfThreeLoopVertexSafeFactors[] := Module[{},
  hrfThreeLoopVertexStudyLoad[];
  hrfSafeCancellationFactorsPolynomial[
    F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars
  ][[1]]
];

hrfThreeLoopVertexFactorTable[] := Module[{},
  hrfThreeLoopVertexStudyLoad[];
  hrfFivePointCanonicalFactorTable[
    F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars, "ThreeLoopVertex"
  ]
];

hrfThreeLoopVertexGeneratorPairAuditTable[] := Module[{audit},
  hrfThreeLoopVertexStudyLoad[];
  audit = hrfFivePointGeneratorPairAuditTable[
    F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars,
    hrfThreeLoopVertexSafeFactors[], "ThreeLoopVertex"
  ];
  audit["Table"]
];

hrfThreeLoopVertexGeneratorPairAuditSummary[] := Module[{audit},
  hrfThreeLoopVertexStudyLoad[];
  audit = hrfFivePointGeneratorPairAuditTable[
    F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars,
    hrfThreeLoopVertexSafeFactors[], "ThreeLoopVertex"
  ];
  audit["Summary"]
];

hrfThreeLoopVertexGeneratorSelectionTable[] := Module[{study},
  hrfThreeLoopVertexStudyLoad[];
  study = hrfFivePointGeneratorStudy[
    F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars,
    "ThreeLoopVertex", <|"SkipObstructionScans" -> True|>
  ];
  study["GeneratorSelectionTable"]
];

hrfThreeLoopVertexGeneratorRows[scan_Association] := Module[{gd, gens},
  If[! AssociationQ[scan], Return[Dataset[{}]]];
  gens = Lookup[scan, "Generators", {}];
  gd = Lookup[scan, "GeneratorFactorData", {}];
  If[gd === {} && gens =!= {},
    gd = generatorFactorData[gens, scan["CancellationFactors"],
      VarsThreeLoopVertex5pt, KinVars, KinAssump,
      Lookup[scan, "GeneratorDegreeBounds", Automatic], F0ThreeLoopVertex5pt];
  ];
  Dataset @ Table[
    <|
      "Index" -> i,
      "Generator" -> If[Length[DownValues[hrfFormatCancellationFactorDisplay]] > 0,
        hrfFormatCancellationFactorDisplay[gens[[i]], VarsThreeLoopVertex5pt, KinVars],
        hrfPolynomialCompact[gens[[i]]]
      ],
      "FactorCount" -> Lookup[gd[[i]], "GeneratorFactorCount", "--"],
      "TotalDegree" -> Lookup[gd[[i]], "TotalDegree", "--"],
      "DegreeAdmissibleQ" -> Lookup[gd[[i]], "DegreeAdmissibleQ", "--"],
      "MandelstamLinearQ" -> If[Length[DownValues[hrfFactorMandelstamLinearQ]] > 0,
        hrfFactorMandelstamLinearQ[gens[[i]], KinVars], True],
      "PDFSubsetQ" -> Lookup[gd[[i]], "SimultaneouslyAdmissibleSubsetQ", "--"],
      "AdmissibleGeneratorQ" -> Lookup[gd[[i]], "AdmissibleGeneratorQ", "--"],
      "Factors" -> StringRiffle[
        If[Length[DownValues[hrfFormatCancellationFactorDisplay]] > 0,
          hrfFormatCancellationFactorDisplay[#, VarsThreeLoopVertex5pt, KinVars] & /@
            Lookup[gd[[i]], "GeneratorFactors", {}],
          hrfPolynomialCompact /@ Lookup[gd[[i]], "GeneratorFactors", {}]
        ], " * "]
    |>,
    {i, Min[Length[gens], Length[gd]]}
  ]
];

hrfThreeLoopVertexInspectScan[scan_Association] := Module[{},
  If[! AssociationQ[scan],
    Print["Not an obstruction scan association."];
    Return[Missing["InvalidScan"]]
  ];
  If[MatchQ[Lookup[scan, "ObstructionData", ""], HoldPattern[Missing["Deferred", _]]],
    Print["Obstruction search was not run."];
    Return[scan]
  ];
  Print["=== ThreeLoopVertex obstruction scan (Collinear5pt / SingleProduct) ==="];
  Print["  Cancellation factors: ", Length[Lookup[scan, "CancellationFactors", {}]]];
  Print["  Candidate generator sets: ", Lookup[scan, "CandidateGeneratorCount", 0]];
  Print["  Accepted generators: ", Length[Lookup[scan, "Generators", {}]]];
  Print["  AdmissibleGeneratorSetQ: ", Lookup[scan, "AdmissibleGeneratorSetQ", False]];
  Print["  HiddenRegionQ: ", hrfPolyHiddenRegionQ[scan, "Interior"]];
  Print["\n--- Accepted generators ---"];
  Print[hrfThreeLoopVertexGeneratorRows[scan]];
  If[KeyExistsQ[scan, "ObstructionAttemptData"] && scan["ObstructionAttemptData"] =!= {},
    Print["\n--- Trial log ---"];
    Print[hrfPolyGeneratorTrialTable[scan, "ThreeLoopVertex"]];
  ];
  scan
];

(* Legacy name: redirects to pair audit + selection (no Adaptive z^2 candidates). *)
hrfThreeLoopVertexCandidateTable[] := Module[{summary, pairs, sel},
  hrfThreeLoopVertexStudyLoad[];
  summary = hrfThreeLoopVertexGeneratorPairAuditSummary[];
  pairs = hrfThreeLoopVertexGeneratorPairAuditTable[];
  sel = hrfThreeLoopVertexGeneratorSelectionTable[];
  Print["=== ThreeLoopVertex f_k and valid pairs (Collinear5pt) ==="];
  Print["  Safe f_k count: ", Length[hrfThreeLoopVertexSafeFactors[]]];
  Print["  Pair audit summary: ", summary];
  Print["\n--- Raw harvest audit (why f_k dropped) ---"];
  Print[hrfThreeLoopVertexHarvestAudit[]];
  Print["\n--- Canonical f_k ---"];
  Print[hrfThreeLoopVertexFactorTable[]];
  Print["\n--- Generator pair audit (kin prefilter + PDF + degree + F0 + Mandelstam) ---"];
  Print[pairs];
  Print["\n--- Binomial vs polynomial resolver ---"];
  Print[sel];
  If[Lookup[summary, "ListedPairCount", 0] === 0,
    Print["\n*** No physics-admissible pairs. Inspect Canonical f_k table and harvest audit ($HRFPolynomialLastFactorAudit). ***"]
  ];
  <|"FactorTable" -> hrfThreeLoopVertexFactorTable[],
    "PairAuditTable" -> pairs,
    "PairAuditSummary" -> summary,
    "SelectionTable" -> sel|>
];

hrfThreeLoopVertexObstructionScan[] := Module[{scan},
  hrfThreeLoopVertexStudyLoad[];
  Print["Running findObstructions (Collinear5pt SingleProduct)..."];
  scan = findObstructions[
    F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars, Automatic,
    Sequence @@ Normal[hrfThreeLoopVertexObstructionOptions[]]
  ];
  hrfThreeLoopVertexInspectScan[scan]
];

(* Walk obstruction -> scaling gates for the selected generator.
   Optional manualFSL / manualObstruction: test findCoverageLPScaling alone if you
   already know F_SL and Obstruction from manual checks. *)
hrfThreeLoopVertexScalingDiagnostic[manualObstruction_: None, manualFSL_: None] := Module[
  {opts, ff, gen, U, diag, trial, row, cov, fObs},
  hrfThreeLoopVertexStudyLoad[];
  If[Length[DownValues[hrfEvaluateValidTrialScaling]] === 0,
    Get[FileNameJoin[{$HRFVertexInspectDirectory, "HRF_FinalLogicPatch.wl"}]]
  ];
  opts = <|"RelaxSingleProductDegreeQ" -> False, "SkipPDFFindInstanceQ" -> False|>;
  ff = hrfThreeLoopVertexSafeFactors[];
  gen = Expand @ First @ First @ candidateGeneratorSets[
    ff, VarsThreeLoopVertex5pt, KinAssump, KinVars, F0ThreeLoopVertex5pt, opts
  ];
  U = hrfEx03LeadingDeltaPolynomial[Expand[UThreeLoopVertex5pt /. collPar1]];
  diag = obstructionByOriginalTermsGeneralDiagnostic[
    F0ThreeLoopVertex5pt, {gen}, VarsThreeLoopVertex5pt, KinVars, Automatic, KinAssump
  ];
  Print["=== ThreeLoopVertex scaling gate diagnostic ==="];
  Print["  F0 monomial count: ", hrfObstructionTermCount[F0ThreeLoopVertex5pt]];
  Print["  Max obstruction terms (|F|-1): ",
    hrfResolveMaxObstructionSize[F0ThreeLoopVertex5pt, {gen}, VarsThreeLoopVertex5pt, Automatic]];
  Print["  Generator monomial count (info only): ", hrfGeneratorMonomialCountInVars[gen, VarsThreeLoopVertex5pt]];
  Print["  Leading U supplied: ", ! MatchQ[U, None | Automatic | Missing]];
  Print["\n--- Gate 1: obstruction decomposition ---"];
  Print["  Obstruction accepted: ", TrueQ[Lookup[diag["AttemptData"], "AcceptedQ", False]]];
  Print["  Rejection: ", Lookup[diag["AttemptData"], "RejectedReason", "--"]];
  If[KeyExistsQ[diag["AttemptData"], "CoefficientEquationCount"],
    Print["  Remainder coefficient equations: ", diag["AttemptData"]["CoefficientEquationCount"]];
    Print["  Generic remainder monomials: ", Lookup[diag["AttemptData"], "GenericRemainderTermCount", "--"]];
  ];
  Print["\n--- Gate 2: scaling LP (only if Gate 1 passes) ---"];
  If[TrueQ[Lookup[diag["AttemptData"], "AcceptedQ", False]],
    cov = findCoverageLPScaling[diag["Result"]["Superleading"], U, VarsThreeLoopVertex5pt, 5,
      diag["Result"]["Obstruction"]];
    Print["  findCoverageLPScaling accepted: ", Lookup[cov, "AcceptedCount", 0]];
    Print["  Scaling vector: ", Lookup[cov, "Scaling", Missing["None"]]];
    Print["  Status: ", Lookup[cov, "ScalingStatusMessage", Lookup[cov, "Status", "--"]]],
    Print["  Scaling NOT RUN — pipeline stops when obstruction decomposition fails."];
    Print["  GeneratorSetScalingSummary shows ValidScalingQ -> Missing[NotEvaluated]."];
  ];
  If[! MatchQ[manualFSL, None | Automatic | Missing],
    Print["\n--- Manual F_SL scaling test (bypasses Gate 1) ---"];
    fObs = If[MatchQ[manualObstruction, None | Automatic | Missing], None, manualObstruction];
    cov = findCoverageLPScaling[Expand[manualFSL], U, VarsThreeLoopVertex5pt, 5, fObs];
    Print["  Accepted: ", Lookup[cov, "AcceptedCount", 0]];
    Print["  Scaling vector: ", Lookup[cov, "Scaling", Missing["None"]]];
    Print["  Status: ", Lookup[cov, "ScalingStatusMessage", Lookup[cov, "Status", "--"]]];
  ];
  Print["\n--- Full scan summary (findObstructions) ---"];
  trial = Module[{scan},
    scan = findObstructions[F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars, Automatic,
      Sequence @@ Normal[hrfThreeLoopVertexObstructionOptions[]]];
    If[Lookup[scan, "GeneratorSetScalingSummary", {}] =!= {},
      scan["GeneratorSetScalingSummary"][[1]],
      <|"Note" -> "No scaling summary row"|>
    ]
  ];
  Print["  ", trial];
  <|"Generator" -> gen, "ObstructionDiagnostic" -> diag, "ScalingSummaryRow" -> trial, "LeadingU" -> U|>
];

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] hrfThreeLoopVertexHarvestAudit[] | hrfThreeLoopVertexGeneratorPairAuditTable[] | hrfThreeLoopVertexScalingDiagnostic[]"]
];
