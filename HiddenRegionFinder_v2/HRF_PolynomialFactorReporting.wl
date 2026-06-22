(* HRF_PolynomialFactorReporting.wl
   Audit tables for polynomial-factor development: track new f_k, suppressed
   candidates, and generator-set acceptance/discards. *)

If[! ValueQ[hrfPolynomialCompact],
  Quiet @ Check[Unprotect[safeCancellationFactors, safeCancellationFactorsExtended], Null];
  Get[FileNameJoin[{
    If[StringQ[$InputFileName] && $InputFileName =!= "", DirectoryName[$InputFileName],
      If[StringQ[$HRFExample04Directory], $HRFExample04Directory, Directory[]]],
    "HRF_PolynomialCancellationFactors.wl"
  }]];
];
If[Length[DownValues[hrfCompact]] === 0,
  Quiet @ Get[FileNameJoin[{
    If[StringQ[$InputFileName] && $InputFileName =!= "", DirectoryName[$InputFileName],
      If[StringQ[$HRFExample04Directory], $HRFExample04Directory, Directory[]]],
    "HRF_Example01Common.wl"
  }]]
];

ClearAll[
  hrfPolyHiddenRegionQ, hrfPolyRegionTypeFromScan, hrfPolyGeneratorDiscardReason,
  hrfPolyGeneratorAuditRow, hrfPolyGeneratorAuditTable,
  hrfPolyGeneratorTrialRow, hrfPolyGeneratorTrialTable,
  hrfPolyEnrichGeneratorSetScalingRow, hrfPolyGeneratorSetScalingRows,
  hrfPolyGeneratorSetScalingDisplayRow, hrfPolyGeneratorSetScalingTable,
  hrfPolyAdmissibleGeneratorSetTable, hrfEx04ScanPrimaryIngredients,
  hrfPolyGeneratorPairRow, hrfPolyGeneratorPairTable,
  hrfPolyAcceptedFactorTable,
  hrfPolyIndexedFactorTable, hrfPolyThreeMonomialPairAudit,
  hrfPolyFactorAuditDisplayRow, hrfPolyFactorAuditTable,
  hrfPolyFactorDiffDisplayRow, hrfPolyFactorDiffTable,
  hrfPolyModeComparisonRow, hrfPolyModeComparisonTable,
  hrfPolyRegressionSummaryNarrative, hrfEx04FivePointComparisonDisplay,
  hrfPolyFivePointGeneratorStats
];

If[! ValueQ[$HRFPreferExample01HiddenSummaryForPolyQ], $HRFPreferExample01HiddenSummaryForPolyQ = False];

hrfPolyRegionTypeFromScan[scan_Association] := Module[{zeroVars},
  zeroVars = Lookup[scan, "ZeroVars", {}];
  If[zeroVars === {}, "Interior", "Boundary"]
];

hrfPolyHiddenRegionQ[scan_, regionType_:Automatic, scaling_:Automatic] := Module[
  {sc, admQ, exactQ, rem, rt},
  If[! AssociationQ[scan], Return[False]];
  If[KeyExistsQ[scan, "HiddenRegionQ"], Return[TrueQ[scan["HiddenRegionQ"]]]];
  If[TrueQ[$HRFPreferExample01HiddenSummaryForPolyQ] && ValueQ[hrfHiddenSummaryRow],
    Return[TrueQ[hrfHiddenSummaryRow["probe", If[regionType === Automatic, "Interior", regionType],
      {}, {}, scan, scaling]["Hidden region identified?"] === "Yes"]]
  ];
  rt = Which[
    regionType === Automatic, hrfPolyRegionTypeFromScan[scan],
    True, regionType
  ];
  admQ = TrueQ[Lookup[scan, "AdmissibleGeneratorSetQ", False]];
  If[! hrfSuccessfulObstructionDecompositionQ[scan] || ! admQ, Return[False]];
  sc = hrfScalingAssoc @ hrfScanCoverageScalingData[scan, scaling];
  exactQ = hrfExactReductionQ[scan];
  rem = hrfGeneratorUseRemainder[scan];
  If[rt === "Interior",
    hrfCoverageFoundQ[sc] || (exactQ && TrueQ[Expand[rem] === 0]),
    hrfCoverageFoundQ[sc] || (exactQ && TrueQ[Expand[rem] === 0])
  ]
];

hrfPolyGeneratorDiscardReason[trial_Association] := Module[{perGen, adm, obs, degQ, gd, attempt},
  perGen = TrueQ[Lookup[trial, "PerGeneratorAdmissibleQ", False]];
  adm = TrueQ[Lookup[trial, "AdmissibleSLSectorQ", False]];
  obs = Lookup[trial, "ObstructionData", Missing[]];
  attempt = Lookup[trial, "ObstructionAttemptData", <||>];
  gd = Lookup[trial, "GeneratorFactorData", {}];
  degQ = gd === {} || AllTrue[gd, TrueQ[Lookup[#, "DegreeAdmissibleQ", True]] &];
  Which[
    ! degQ, "discarded: generator degree bounds violated",
    ! perGen, "discarded: per-generator admissibility failed",
    MatchQ[obs, HoldPattern[Missing["NoObstructionFound", _]]],
      "discarded: obstruction search found no sector (see RejectedReason)",
    KeyExistsQ[attempt, "RejectedReason"],
      Lookup[attempt, "RejectedReason"],
    MatchQ[obs, _Missing], "discarded: no obstruction data",
    AssociationQ[obs] && TrueQ[Expand[Lookup[obs, "Superleading", 1]] === 0],
      "discarded: exact reduction (Superleading SL sector zero; Complement may be used in reporting)",
    ! adm, "discarded: SL-sector admissibility or exact ideal membership failed after obstruction",
    True, "accepted candidate"
  ]
];

hrfPolyGeneratorAuditRow[scan_Association, label_: "scan"] := Module[
  {cand, adm, trials, accepted, discarded, bounds},
  If[! AssociationQ[scan], Return[<||>]];
  cand = Lookup[scan, "CandidateGeneratorSets", {}];
  adm = Lookup[scan, "AdmissibleCandidateGeneratorSets", {}];
  trials = If[KeyExistsQ[scan, "ObstructionAttemptData"], scan["ObstructionAttemptData"], {}];
  accepted = Lookup[scan, "Generators", {}];
  discarded = Select[cand, ! MemberQ[adm, #] &];
  bounds = Lookup[scan, "GeneratorDegreeBounds", <||>];
  <|
    "Label" -> label,
    "CancellationFactorCount" -> Length[Lookup[scan, "CancellationFactors", {}]],
    "DegreeFilteredFactorCount" -> Lookup[scan, "DegreeFilteredGeneratorFactorCount", 0],
    "MaxGeneratorTotalDegree" -> Lookup[bounds, "MaxGeneratorTotalDegree", "--"],
    "MaxGeneratorVarExponent" -> Lookup[bounds, "MaxGeneratorVarExponent", "--"],
    "KinematicType" -> Lookup[bounds, "InferredKinematicType", "--"],
    "CandidateGeneratorCount" -> Length[cand],
    "AdmissibleGeneratorCount" -> Length[adm],
    "DiscardedGeneratorCount" -> Length[discarded],
    "AcceptedGenerators" -> hrfPolynomialCompact[accepted],
    "DiscardedGenerators" -> hrfPolynomialCompact[discarded],
    "HiddenRegionQ" -> hrfPolyHiddenRegionQ[scan, Automatic]
  |>
];

hrfPolyGeneratorAuditTable[scans_Association] := Dataset[KeyValueMap[hrfPolyGeneratorAuditRow[#2, #1] &, scans]];

hrfPolyGeneratorTrialRow[trial_Association, label_: "trial"] := Module[{attempt},
  attempt = Lookup[trial, "ObstructionAttemptData", <||>];
  <|
    "Label" -> label,
    "Generators" -> hrfPolynomialCompact[Lookup[trial, "Generators", {}]],
    "TotalDegrees" -> If[KeyExistsQ[trial, "GeneratorFactorData"],
      Lookup[trial["GeneratorFactorData"], "TotalDegree", {}],
      "--"
    ],
    "DegreeAdmissibleQ" -> If[KeyExistsQ[trial, "GeneratorFactorData"],
      Lookup[trial["GeneratorFactorData"], "DegreeAdmissibleQ", {}],
      "--"
    ],
    "PerGeneratorAdmissibleQ" -> Lookup[trial, "PerGeneratorAdmissibleQ", False],
    "AdmissibleSLSectorQ" -> Lookup[trial, "AdmissibleSLSectorQ", False],
    "ObstructionRejectedReason" -> Lookup[attempt, "RejectedReason", "--"],
    "DiscardReason" -> hrfPolyGeneratorDiscardReason[trial]
  |>
];

hrfPolyGeneratorTrialTable[scan_Association, label_: "scan"] := Module[{trials},
  If[! AssociationQ[scan], Return[Dataset[{}]]];
  trials = If[KeyExistsQ[scan, "ObstructionAttemptData"],
    scan["ObstructionAttemptData"],
    {}
  ];
  If[trials === {},
    Return[Dataset[{<|
      "Label" -> label,
      "Generators" -> hrfPolynomialCompact[Lookup[scan, "Generators", {}]],
      "PerGeneratorAdmissibleQ" -> True,
      "AdmissibleSLSectorQ" -> True,
      "DiscardReason" -> "accepted (no trial log; single accepted set)"
    |>}]]
  ];
  Dataset[hrfPolyGeneratorTrialRow[#, label] & /@ trials]
];

hrfPolyEnrichGeneratorSetScalingRow[row_Association, activeVars_: {}, evalByIdx_Association:<||>] := Module[
  {idx, ev, cov, diag, sv, vs, gensSymbolic},
  idx = Lookup[row, "TrialIndex", Missing["NotAvailable"]];
  ev = Lookup[evalByIdx, idx, Missing["NoEval"]];
  cov = If[AssociationQ[ev], hrfEvalScalingData[ev], <||>];
  sv = Which[
    ListQ[Lookup[row, "ScalingVector", {}]], row["ScalingVector"],
    AssociationQ[cov] && ListQ[Lookup[cov, "Scaling", {}]], cov["Scaling"],
    True, Lookup[row, "ScalingVector", Missing["NotAvailable"]]
  ];
  diag = If[AssociationQ[cov] && cov =!= <||> && Length[DownValues[hrfSelectedDiagnostic]] > 0,
    hrfSelectedDiagnostic[cov], <||>];
  vs = Which[
    KeyExistsQ[row, "VariableScaling"] && ! MatchQ[row["VariableScaling"], _Missing],
      row["VariableScaling"],
    AssociationQ[diag], Lookup[diag, "VariableScaling", Missing["NotAvailable"]],
    True, Missing["NotAvailable"]
  ];
  gensSymbolic = Which[
    ListQ[Lookup[row, "GeneratorsSymbolic", {}]], row["GeneratorsSymbolic"],
    AssociationQ[ev], Lookup[ev, "Generators", {}],
    True, {}
  ];
  Join[row, <|
    "RegionVariables" -> If[activeVars === {}, Lookup[row, "RegionVariables", {}], activeVars],
    "GeneratorsSymbolic" -> gensSymbolic,
    "ScalingVector" -> sv,
    "ScalingVectorInputForm" -> Which[
      KeyExistsQ[row, "ScalingVectorInputForm"] && StringQ[row["ScalingVectorInputForm"]],
        row["ScalingVectorInputForm"],
      ListQ[sv], ToString[InputForm[sv]],
      MatchQ[sv, _Missing], "--",
      True, ToString[InputForm[sv]]
    ],
    "VariableScaling" -> vs,
    "VariableScalingInputForm" -> Which[
      KeyExistsQ[row, "VariableScalingInputForm"] && StringQ[row["VariableScalingInputForm"]],
        row["VariableScalingInputForm"],
      AssociationQ[vs], ToString[InputForm[Normal[vs]]],
      MatchQ[vs, _Missing], "--",
      True, ToString[InputForm[vs]]
    ],
    "W_SL" -> Lookup[row, "W_SL", Lookup[diag, "WSL", Lookup[diag, "FSLWeight", Missing["NotAvailable"]]]],
    "W_HR" -> Lookup[row, "W_HR", Lookup[diag, "WHR", Lookup[diag, "PostCancellationLeadingWeight", Missing["NotAvailable"]]]],
    "VariablesAtWSL" -> Lookup[row, "VariablesAtWSL",
      Lookup[diag, "VariablesCoveredByFSLAtWSL", Missing["NotAvailable"]]],
    "VariablesAtWHR" -> Lookup[row, "VariablesAtWHR",
      Lookup[diag, "VariablesInPostCancellationLeadingSupport", Missing["NotAvailable"]]]
  |>]
];

hrfPolyGeneratorSetScalingRows[scan_Association, activeVars_: Automatic] := Module[
  {rows, av, evalByIdx},
  If[! AssociationQ[scan], Return[{}]];
  av = If[activeVars === Automatic, Lookup[scan, "ActiveVars", {}], activeVars];
  evalByIdx = Association @ Map[
    Lookup[#, "TrialIndex", Missing["NotAvailable"]] -> # &,
    Lookup[scan, "ValidTrialScalingEvaluations", {}]
  ];
  rows = Lookup[scan, "GeneratorSetScalingSummary", {}];
  If[rows === {} && evalByIdx =!= <||>,
    rows = Table[
      With[{ev = evalByIdx[[Keys[evalByIdx][[i]]]], cov = hrfEvalScalingData[evalByIdx[[Keys[evalByIdx][[i]]]]]},
        <|
          "TrialIndex" -> Lookup[ev, "TrialIndex", i],
          "Generators" -> hrfPolynomialCompact[Lookup[ev, "Generators", {}]],
          "GeneratorsSymbolic" -> Lookup[ev, "Generators", {}],
          "ValidObstructionQ" -> True,
          "AdmissibleSLSectorQ" -> True,
          "ValidScalingQ" -> TrueQ[Lookup[ev, "ValidScalingQ", False]],
          "HiddenRegionQ" -> TrueQ[Lookup[ev, "HiddenRegionQ", False]],
          "ScalingStatus" -> Lookup[cov, "ScalingStatusMessage", Lookup[cov, "ScalingStatus", "--"]],
          "ScalingVector" -> If[ListQ[Lookup[cov, "Scaling", {}]], cov["Scaling"], Missing["NotAvailable"]]
        |>
      ],
      {i, Length[Keys[evalByIdx]]}
    ]
  ];
  hrfPolyEnrichGeneratorSetScalingRow[#, av, evalByIdx] & /@ rows
];

hrfPolyGeneratorSetScalingDisplayRow[row_Association, label_: "scan"] := <|
  "Label" -> label,
  "TrialIndex" -> Lookup[row, "TrialIndex", Missing["NotAvailable"]],
  "Generators" -> Lookup[row, "Generators",
    If[ListQ[Lookup[row, "GeneratorsSymbolic", {}]],
      hrfPolynomialCompact[row["GeneratorsSymbolic"]], "--"]],
  "PerGeneratorAdmissibleQ" -> Lookup[row, "PerGeneratorAdmissibleQ", False],
  "AdmissibleSLSectorQ" -> Lookup[row, "AdmissibleSLSectorQ", False],
  "ValidObstructionQ" -> Lookup[row, "ValidObstructionQ", False],
  "KinSectorPresentationQ" -> Lookup[row, "KinSectorPresentationQ", Missing["NotAvailable"]],
  "ValidScalingQ" -> Lookup[row, "ValidScalingQ", False],
  "HiddenRegionQ" -> Lookup[row, "HiddenRegionQ", False],
  "Scaling status" -> Lookup[row, "ScalingStatus", "--"],
  "Scaling vector" -> Lookup[row, "ScalingVectorInputForm", "--"],
  "Variable scaling by region variable" -> Lookup[row, "VariableScalingInputForm", "--"],
  "Region vector" -> hrfCompact[Lookup[row, "RegionVariables", {}]],
  "Variables at W_SL" -> hrfCompact[Lookup[row, "VariablesAtWSL", Missing["NotAvailable"]]],
  "Variables at W_HR" -> hrfCompact[Lookup[row, "VariablesAtWHR", Missing["NotAvailable"]]],
  "W_SL" -> Lookup[row, "W_SL", Missing["NotAvailable"]],
  "W_HR" -> Lookup[row, "W_HR", Missing["NotAvailable"]]
|>;

hrfPolyGeneratorSetScalingTable[scan_Association, label_: "scan"] := Module[{rows},
  If[! AssociationQ[scan], Return[Dataset[{}]]];
  rows = hrfPolyGeneratorSetScalingRows[scan];
  If[rows === {}, Return[Dataset[{}]]];
  Dataset[hrfPolyGeneratorSetScalingDisplayRow[#, label] & /@ rows]
];

hrfPolyAdmissibleGeneratorSetTable[scan_Association, label_: "scan"] := Module[{rows},
  If[! AssociationQ[scan], Return[Dataset[{}]]];
  rows = Select[
    hrfPolyGeneratorSetScalingRows[scan],
    TrueQ[Lookup[#, "AdmissibleSLSectorQ", False]] &&
      TrueQ[Lookup[#, "PerGeneratorAdmissibleQ", False]] &
  ];
  If[rows === {}, Return[Dataset[{}]]];
  Dataset[hrfPolyGeneratorSetScalingDisplayRow[#, label] & /@ rows]
];

hrfEx04ScanPrimaryIngredients[scan_Association, activeVars_: {}, zeroVars_: {}, label_: "scan"] := Module[
  {sc, diag, parts, gens, fsl, fIn},
  If[! AssociationQ[scan], Return[Missing["InvalidScan"]]];
  sc = If[Length[DownValues[hrfScanCoverageScalingData]] > 0,
    hrfScalingAssoc @ hrfScanCoverageScalingData[scan, Automatic], <||>];
  diag = If[Length[DownValues[hrfSelectedDiagnostic]] > 0, hrfSelectedDiagnostic[sc], <||>];
  parts = If[Length[DownValues[hrfObstructionPolynomialParts]] > 0,
    hrfObstructionPolynomialParts[scan], <||>];
  gens = Lookup[scan, "Generators", {}];
  fsl = If[Length[DownValues[hrfEffectiveSuperleadingSector]] > 0,
    hrfEffectiveSuperleadingSector[scan], Missing["NotAvailable"]];
  fIn = If[Length[DownValues[hrfEffectiveInputPolynomial]] > 0,
    hrfEffectiveInputPolynomial[scan], Missing["NotAvailable"]];
  <|
    "Case" -> label,
    "RegionVariables" -> activeVars,
    "BoundaryZeroVariables" -> zeroVars,
    "InputPolynomial" -> fIn,
    "Generators" -> gens,
    "GeneratorsInputForm" -> If[ListQ[gens], ToString[InputForm[#]] & /@ gens, {}],
    "HiddenRegionQ" -> hrfPolyHiddenRegionQ[scan],
    "Obstruction" -> Lookup[parts, "Obstruction", Missing["NotAvailable"]],
    "FSL" -> fsl,
    "ScalingVector" -> If[Length[DownValues[hrfResolvedScalingVector]] > 0,
      hrfResolvedScalingVector[sc], Lookup[sc, "Scaling", Missing["NotAvailable"]]],
    "VariableScaling" -> If[Length[DownValues[hrfResolvedVariableScaling]] > 0,
      hrfResolvedVariableScaling[sc, activeVars],
      Lookup[diag, "VariableScaling", Missing["NotAvailable"]]],
    "VariablesAtWSL" -> Lookup[diag, "VariablesCoveredByFSLAtWSL", Missing["NotAvailable"]],
    "VariablesAtWHR" -> Lookup[diag, "VariablesInPostCancellationLeadingSupport", Missing["NotAvailable"]],
    "W_SL" -> Lookup[diag, "WSL", Lookup[diag, "FSLWeight", Missing["NotAvailable"]]],
    "W_HR" -> Lookup[diag, "WHR", Lookup[diag, "PostCancellationLeadingWeight", Missing["NotAvailable"]]],
    "ScalingStatus" -> Lookup[sc, "ScalingStatusMessage", Lookup[sc, "ScalingStatus", "--"]]
  |>
];

hrfPolyGeneratorPairRow[f1_, f2_, gen_, vars_, kinAssump_, kinVars_, bounds_] := Module[
  {simQ, tot, prodQ, f1Q, f2Q},
  simQ = simultaneouslyAdmissibleSubsetQ[{f1, f2}, vars, kinAssump, kinVars];
  tot = hrfPolynomialTotalDegreeInVars[gen, vars];
  prodQ = hrfGeneratorProductDegreeAdmissibleQ[gen, bounds, vars];
  f1Q = hrfCancellationFactorDegreeAdmissibleQ[f1, bounds, vars];
  f2Q = hrfCancellationFactorDegreeAdmissibleQ[f2, bounds, vars];
  <|
    "Factor1" -> hrfPolynomialCompact[f1],
    "Factor2" -> hrfPolynomialCompact[f2],
    "ProductTotalDegree" -> tot,
    "Factor1DegreeAdmissibleQ" -> f1Q,
    "Factor2DegreeAdmissibleQ" -> f2Q,
    "ProductDegreeAdmissibleQ" -> prodQ,
    "SimultaneouslyAdmissibleQ" -> simQ,
    "EntersPairGeneratorQ" -> (f1Q && f2Q && prodQ && simQ),
    "PairGenerator" -> hrfPolynomialCompact[gen]
  |>
];

hrfPolyGeneratorPairTable[scan_Association, vars_, kinAssump_, kinVars_] := Module[
  {ff, bounds, physFF, pairs, rows},
  If[! AssociationQ[scan], Return[Dataset[{}]]];
  ff = Lookup[scan, "CancellationFactors", {}];
  bounds = Lookup[scan, "GeneratorDegreeBounds", <||>];
  If[Length[ff] < 2, Return[Dataset[{}]]];
  physFF = If[TrueQ[$HRFUseGeneratorPhysicsFilterQ] && ValueQ[hrfFilterFactorsForGeneratorPhysics],
    hrfFilterFactorsForGeneratorPhysics[ff, vars, kinVars, bounds]["Factors"],
    ff
  ];
  If[Length[physFF] < 2, Return[Dataset[{<|"Note" -> "Fewer than 2 physics-eligible factors after span dedup."|>}]]];
  pairs = Subsets[physFF, {2}];
  rows = If[ValueQ[hrfGeneratorPhysicsPairRow],
    hrfGeneratorPhysicsPairRow[#[[1]], #[[2]], bounds, vars, kinAssump, kinVars] & /@ pairs,
    hrfPolyGeneratorPairRow[#[[1]], #[[2]], Times @@ #, vars, kinAssump, kinVars, bounds] & /@ pairs
  ];
  Dataset[rows]
];

hrfPolyAcceptedFactorTable[scan_Association] := Dataset[
  <|"Factor" -> hrfPolynomialCompact[#]|> & /@ Lookup[scan, "CancellationFactors", {}]
];

hrfPolyFactorContainsKinQ[f_, kinVars_] := Which[
  kinVars === {}, False,
  Length[DownValues[hrfFactorContainsKinVarsQ]] > 0, hrfFactorContainsKinVarsQ[f, kinVars],
  Length[DownValues[hrfFactorContainsKinQ]] > 0, hrfFactorContainsKinQ[f, kinVars],
  True, ! FreeQ[Expand[f], Alternatives @@ kinVars]
];

hrfPolyIndexedFactorTable[scan_Association] := Module[{ff, vars, rows},
  If[! AssociationQ[scan], Return[Dataset[{}]]];
  ff = Lookup[scan, "CancellationFactors", {}];
  vars = Lookup[scan, "ActiveVars", Lookup[scan, "Vars", {}]];
  rows = Table[
    <|
      "Index" -> i,
      "Factor" -> hrfPolynomialCompact[ff[[i]]],
      "MonomialCount" -> hrfPolynomialMonomialCount[ff[[i]], vars],
      "MixedSignQ" -> hrfMixedSignQ[ff[[i]], vars],
      "ContainsKinQ" -> hrfPolyFactorContainsKinQ[ff[[i]], Lookup[scan, "KinVars", {}]]
    |>,
    {i, Length[ff]}
  ];
  Dataset[rows]
];

hrfPolyPairProductInGeneratorSetsQ[prod_, genSets_List] := Module[{p = Expand[prod]},
  genSets =!= {} && Or @@ (
    Module[{gs = Expand /@ #},
      MemberQ[gs, p] || (Length[gs] === 1 && TrueQ[gs[[1]] === p])
    ] & /@ genSets
  )
];

hrfPolyThreeMonomialPairAudit[scan_Association, vars_, kinAssump_, kinVars_] := Module[
  {ff, bounds, physFF, threeMon, pairs, candSets, acceptedGens, rows},
  If[! AssociationQ[scan], Return[<|"Factors" -> Dataset[{}], "Pairs" -> Dataset[{}]|>]];
  ff = Lookup[scan, "CancellationFactors", {}];
  bounds = Lookup[scan, "GeneratorDegreeBounds", hrfResolveGeneratorDegreeBounds[
    Lookup[scan, "InputPolynomial", 0], vars, <||>
  ]];
  physFF = If[TrueQ[$HRFUseGeneratorPhysicsFilterQ] && ValueQ[hrfFilterFactorsForGeneratorPhysics],
    hrfFilterFactorsForGeneratorPhysics[ff, vars, kinVars, bounds]["Factors"],
    ff
  ];
  threeMon = Select[physFF, hrfPolynomialMonomialCount[#, vars] === 3 &];
  pairs = Subsets[threeMon, {2}];
  candSets = Lookup[scan, "CandidateGeneratorSets", Missing["Trimmed"]];
  acceptedGens = Expand /@ Lookup[scan, "Generators", {}];
  rows = Table[
    Module[{f1 = pairs[[i, 1]], f2 = pairs[[i, 2]], prod = Expand[f1 f2],
      xs1, xs2, row},
      xs1 = If[Length[DownValues[hrfFactorXSupport]] > 0, hrfFactorXSupport[f1, vars], {}];
      xs2 = If[Length[DownValues[hrfFactorXSupport]] > 0, hrfFactorXSupport[f2, vars], {}];
      row = <|
        "Factor1" -> hrfPolynomialCompact[f1],
        "Factor2" -> hrfPolynomialCompact[f2],
        "DisjointXSupportQ" -> Length[Intersection[xs1, xs2]] === 0,
        "SimultaneouslyAdmissibleQ" -> simultaneouslyAdmissibleSubsetQ[{f1, f2}, vars, kinAssump, kinVars],
        "PhysicsAdmissibleQ" -> If[Length[DownValues[hrfGeneratorPairPhysicsAdmissibleQ]] > 0,
          hrfGeneratorPairPhysicsAdmissibleQ[f1, f2, bounds, vars, kinVars],
          hrfGeneratorProductDegreeAdmissibleQ[prod, bounds, vars]
        ],
        "PairGenerator" -> hrfPolynomialCompact[prod],
        "InCandidateGeneratorSetsQ" -> If[candSets === Missing["Trimmed"], Missing["Trimmed"],
          hrfPolyPairProductInGeneratorSetsQ[prod, candSets]
        ],
        "InAcceptedGeneratorsQ" -> MemberQ[acceptedGens, prod]
      |>;
      row
    ],
    {i, Length[pairs]}
  ];
  <|
    "ThreeMonomialFactorCount" -> Length[threeMon],
    "ThreeMonomialFactors" -> Dataset @ Table[
      <|
        "Index" -> First @ FirstPosition[ff, threeMon[[i]], Missing["NotInScan"], {1}],
        "Factor" -> hrfPolynomialCompact[threeMon[[i]]],
        "MonomialCount" -> 3
      |>,
      {i, Length[threeMon]}
    ],
    "PairCount" -> Length[pairs],
    "Pairs" -> Dataset[rows],
    "CandidateGeneratorSetsStoredQ" -> (candSets =!= Missing["Trimmed"])
  |>
];

hrfPolyFactorAuditForMode[F_, vars_, kinAssump_, kinVars_, mode_String] := Module[
  {pack, filtered, rows},
  pack = hrfRawPolynomialCandidates[F, vars, kinAssump, kinVars, Automatic];
  filtered = hrfFilterPolynomialCandidates[pack["Raw"], vars, kinAssump, kinVars, mode];
  rows = filtered["AuditRows"];
  <|
    "Accepted" -> hrfPolyFactorAuditTable[Select[rows, TrueQ[Lookup[#, "AcceptedQ", False]] &]],
    "Rejected" -> hrfPolyFactorAuditTable[Select[rows, ! TrueQ[Lookup[#, "AcceptedQ", False]] &]]
  |>
];

hrfPolyFivePointGeneratorStats[scan_Association] := Module[{vars, kin, valid, gens, sc},
  If[! AssociationQ[scan], Return[<||>]];
  vars = Lookup[scan, "ActiveVars", {}];
  kin = Lookup[scan, "KinVars", {}];
  valid = Select[Lookup[scan, "ObstructionAttemptData", {}],
    hrfValidObstructionTrialQ[#, vars, kin] &];
  gens = Lookup[scan, "Generators", {}];
  sc = hrfScanCoverageScalingData[scan, Automatic];
  <|
    "AcceptedGeneratorCount" -> Length[gens],
    "ValidTrialCount" -> Length[valid],
    "MaxGeneratorCountAmongValidTrials" -> If[valid === {}, 0,
      Max[Length[Lookup[#, "Generators", {}]] & /@ valid]],
    "ValidMultiGeneratorTrialCount" -> Count[valid, Length[Lookup[#, "Generators", {}]] >= 2 &],
    "SuccessfulDecompositionQ" -> hrfSuccessfulObstructionDecompositionQ[scan],
    "HiddenRegionQ" -> hrfPolyHiddenRegionQ[scan, Automatic],
    "ScalingStatus" -> Lookup[sc, "ScalingStatusMessage", Lookup[sc, "ScalingStatus", "--"]],
    "ScalingVector" -> hrfCompact[Lookup[sc, "Scaling", "--"]]
  |>
];

hrfEx04FivePointComparisonDisplay[cases_List] := Module[
  {seed, vertex, seedStats, vertexStats},
  seed = FirstCase[cases, c_ /; StringContainsQ[Lookup[c, "Label", ""], "Seed5pt"], <||>];
  vertex = FirstCase[cases, c_ /; StringContainsQ[Lookup[c, "Label", ""], "ThreeLoopVertex"], <||>];
  If[! AssociationQ[seed] || ! AssociationQ[vertex] ||
      ! KeyExistsQ[seed, "ComparisonRow"] || ! KeyExistsQ[vertex, "ComparisonRow"],
    Return[Missing["NotAvailable", "Five-point seed vs ThreeLoopVertex comparison not available."]]
  ];
  seedStats = hrfPolyFivePointGeneratorStats[Lookup[seed, "PolynomialScan", <||>]];
  vertexStats = hrfPolyFivePointGeneratorStats[Lookup[vertex, "PolynomialScan", <||>]];
  Dataset @ {
    <|
      "Case" -> "Seed5pt",
      "Vars" -> Length[Lookup[seed, "RemainingVars", {}]],
      "BinomialHiddenQ" -> Lookup[seed["ComparisonRow"], "BinomialHiddenRegionQ", False],
      "PolynomialHiddenQ" -> Lookup[seed["ComparisonRow"], "PolynomialHiddenRegionQ", False],
      "BinomialFactors" -> Lookup[seed["ComparisonRow"], "BinomialFactorCount", 0],
      "PolynomialFactors" -> Lookup[seed["ComparisonRow"], "PolynomialFactorCount", 0],
      "PolynomialGenerators" -> Lookup[seed["ComparisonRow"], "PolynomialGenerators", "--"],
      "AcceptedGeneratorCount" -> Lookup[seedStats, "AcceptedGeneratorCount", 0],
      "ValidMultiGeneratorTrials" -> Lookup[seedStats, "ValidMultiGeneratorTrialCount", 0],
      "MaxValidGeneratorCount" -> Lookup[seedStats, "MaxGeneratorCountAmongValidTrials", 0],
      "SuccessfulDecompositionQ" -> Lookup[seedStats, "SuccessfulDecompositionQ", False],
      "ScalingStatus" -> Lookup[seedStats, "ScalingStatus", "--"],
      "ScalingVector" -> Lookup[seedStats, "ScalingVector", "--"],
      "Note" -> "Reference 5pt hidden region; expect one coupled generator from admissible f_k products"
    |>,
    <|
      "Case" -> "ThreeLoopVertex",
      "Vars" -> Length[Lookup[vertex, "RemainingVars", {}]],
      "BinomialHiddenQ" -> Lookup[vertex["ComparisonRow"], "BinomialHiddenRegionQ", False],
      "PolynomialHiddenQ" -> Lookup[vertex["ComparisonRow"], "PolynomialHiddenRegionQ", False],
      "BinomialFactors" -> Lookup[vertex["ComparisonRow"], "BinomialFactorCount", 0],
      "PolynomialFactors" -> Lookup[vertex["ComparisonRow"], "PolynomialFactorCount", 0],
      "PolynomialGenerators" -> Lookup[vertex["ComparisonRow"], "PolynomialGenerators", "--"],
      "AcceptedGeneratorCount" -> Lookup[vertexStats, "AcceptedGeneratorCount", 0],
      "ValidMultiGeneratorTrials" -> Lookup[vertexStats, "ValidMultiGeneratorTrialCount", 0],
      "MaxValidGeneratorCount" -> Lookup[vertexStats, "MaxGeneratorCountAmongValidTrials", 0],
      "SuccessfulDecompositionQ" -> Lookup[vertexStats, "SuccessfulDecompositionQ", False],
      "ScalingStatus" -> Lookup[vertexStats, "ScalingStatus", "--"],
      "ScalingVector" -> Lookup[vertexStats, "ScalingVector", "--"],
      "Note" -> "Vertex-corrected topology; compare f_k pool and whether multi-generator trials are valid"
    |>
  }
];

hrfPolyFactorAuditDisplayRow[row_Association] := <|
  "Factor" -> hrfPolynomialCompact[Lookup[row, "Factor", "--"]],
  "Class" -> Lookup[row, "Class", "--"],
  "MonomialCount" -> Lookup[row, "MonomialCount", "--"],
  "MixedSign" -> Lookup[row, "MixedSignQ", "--"],
  "ContainsKin" -> Lookup[row, "ContainsKinVarsQ", "--"],
  "Accepted" -> Lookup[row, "AcceptedQ", False],
  "RejectReason" -> Lookup[row, "RejectReason", "--"]
|>;

hrfPolyFactorAuditTable[auditRows_List] := Dataset[hrfPolyFactorAuditDisplayRow /@ auditRows];

hrfPolyFactorDiffDisplayRow[diff_Association] := <|
  "BinomialCount" -> Lookup[diff, "BinomialCount", 0],
  "PolynomialCount" -> Lookup[diff, "PolynomialCount", 0],
  "AddedFactorCount" -> Lookup[diff, "AddedFactorCount", 0],
  "AddedFactors" -> hrfPolynomialCompact[Lookup[diff, "AddedFactors", {}]],
  "OpenKinematicFilter" -> Lookup[diff, "OpenKinematicFilterActiveQ", False]
|>;

hrfPolyFactorDiffTable[diff_Association] := Dataset[{hrfPolyFactorDiffDisplayRow[diff]}];

hrfPolyModeComparisonRow[label_, binScan_, polyScan_, factorDiff_, zeroVars_: {}] := Module[{regionType, binAssoc, polyAssoc},
  regionType = If[zeroVars === {}, "Interior", "Boundary"];
  binAssoc = AssociationQ[binScan];
  polyAssoc = AssociationQ[polyScan];
  <|
  "Case" -> label,
  "BinomialFactorCount" -> If[AssociationQ[factorDiff], Lookup[factorDiff, "BinomialCount", 0], Missing["NotRun"]],
  "PolynomialFactorCount" -> If[AssociationQ[factorDiff], Lookup[factorDiff, "PolynomialCount", 0], Missing["NotRun"]],
  "AddedFactors" -> If[AssociationQ[factorDiff], hrfPolynomialCompact[Lookup[factorDiff, "AddedFactors", {}]], "--"],
  "BinomialHiddenRegionQ" -> If[binAssoc, hrfPolyHiddenRegionQ[binScan, regionType], Missing["NotRun"]],
  "PolynomialHiddenRegionQ" -> If[polyAssoc, hrfPolyHiddenRegionQ[polyScan, regionType], Missing["NotRun"]],
  "BinomialGenerators" -> If[binAssoc, hrfPolynomialCompact[Lookup[binScan, "Generators", {}]], "--"],
  "PolynomialGenerators" -> If[polyAssoc, hrfPolynomialCompact[Lookup[polyScan, "Generators", {}]], "--"],
  "BinomialCandidateGenerators" -> If[binAssoc, Lookup[binScan, "CandidateGeneratorCount", 0], Missing["NotRun"]],
  "PolynomialCandidateGenerators" -> If[polyAssoc, Lookup[polyScan, "CandidateGeneratorCount", 0], Missing["NotRun"]],
  "BinomialDiscardedGenerators" -> If[binAssoc, Lookup[hrfPolyGeneratorAuditRow[binScan, label], "DiscardedGeneratorCount", 0], Missing["NotRun"]],
  "PolynomialDiscardedGenerators" -> If[polyAssoc, Lookup[hrfPolyGeneratorAuditRow[polyScan, label], "DiscardedGeneratorCount", 0], Missing["NotRun"]],
  "RegressionStableQ" -> If[binAssoc && polyAssoc,
    hrfPolyHiddenRegionQ[binScan, regionType] === hrfPolyHiddenRegionQ[polyScan, regionType],
    Missing["NotRun"]
  ]
|>
];

hrfPolyModeComparisonTable[rows_List] := Dataset[rows];

hrfPolyRegressionSummaryNarrative[comparisonTable_] := Module[{rows, unstable, added},
  rows = If[Head[comparisonTable] === Dataset, Normal[comparisonTable], comparisonTable];
  unstable = Select[rows, ! TrueQ[Lookup[#, "RegressionStableQ", True]] &];
  added = Select[rows,
    TrueQ[Lookup[#, "PolynomialFactorCount", 0] > Lookup[#, "BinomialFactorCount", 0]] &
  ];
  StringRiffle[{
    "Polynomial-factor regression summary.",
    "Cases with changed hidden-region verdict (binomial vs polynomial): " <> ToString[Length[unstable]],
    If[unstable =!= {},
      "  " <> StringRiffle[Lookup[#, "Case"] & /@ unstable, ", "],
      Nothing
    ],
    "Cases with added f_k under polynomial mode: " <> ToString[Length[added]],
    If[added =!= {},
      "  " <> StringRiffle[
        Lookup[#, "Case"] <> " (+" <>
          ToString[Lookup[#, "PolynomialFactorCount", 0] - Lookup[#, "BinomialFactorCount", 0]] <> ")" & /@ added,
        ", "
      ],
      Nothing
    ],
    "Open-kinematic-stratum filter active: " <> ToString[$HRFPolynomialRequireKinematicDomainQ]
  }, "\n"]
];

If[! TrueQ[$HRFQuietReports], Print["[loaded] polynomial-factor reporting helpers."]];
