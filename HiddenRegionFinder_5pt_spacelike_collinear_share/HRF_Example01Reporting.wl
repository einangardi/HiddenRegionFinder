(* HRF_Example01Reporting.wl
   Region-study reporting for Example 01 (HyperCrown, Diving Beetle, etc.).
   Expects HRF_FinalLogicPatch.wl to be loaded first for hrfCoverageData and
   hrfEffectiveSuperleadingSector. *)

ClearAll[
  hrfEx01Compact, hrfEx01ScalingVector, hrfEx01VariableScalingAssoc,
  hrfEx01GeneratorUseRemainder, hrfEx01ChannelBasis, hrfEx01BestTrialFromDiagnostic,
  hrfEx01ScanFromDiagnostic, hrfEx01CoverageForScan, hrfEx01RegionStudyRow,
  hrfEx01RegionStudyTable, hrfEx01RegionStudyTableNotice, hrfEx01ChannelAttemptRowsFromScan,
  hrfEx01BoundaryOutcomeRow, hrfEx01BoundaryOutcomeTable,
  hrfHyperCrownInteriorRow, hrfHyperCrownRegionStudyRows, hrfHyperCrownRegionStudyTable,
  hrfHyperCrownChannelAttemptTable, hrfHyperCrownStudySummary, hrfHyperCrownInteriorNarrative,
  hrfDivingBeetleInteriorRows, hrfDivingBeetleBoundaryRows,
  hrfDivingBeetleRegionStudyTable, hrfDivingBeetleStudySummary, hrfDivingBeetleFailureNarrative
];

hrfEx01Compact[x_] := Which[
  x === "--", "--",
  MatchQ[x, _Missing] || x === {} || x === Null, "--",
  ListQ[x], ToString[InputForm[x]],
  AssociationQ[x], ToString[InputForm[Normal[x]]],
  True, ToString[InputForm[x]]
];

hrfEx01ScalingVector[scaling_] := Module[{raw},
  raw = If[AssociationQ[scaling], Lookup[scaling, "Scaling", Missing["NoScaling"]], scaling];
  Which[
    ListQ[raw], ToString[InputForm[raw]],
    MatchQ[raw, _Missing], "--",
    True, hrfEx01Compact[raw]
  ]
];

hrfEx01VariableScalingAssoc[diag_, activeVars_] := Module[{vs},
  vs = If[AssociationQ[diag], Lookup[diag, "VariableScaling", Missing[]], Missing[]];
  Which[
    AssociationQ[vs], vs,
    ListQ[vs] && ListQ[activeVars] && Length[vs] === Length[activeVars],
      AssociationThread[activeVars -> vs],
    True, <||>
  ]
];

hrfEx01GeneratorUseRemainder[scan_] := Module[{use},
  use = If[AssociationQ[scan], Lookup[scan, "GeneratorUseData", <||>], <||>];
  If[AssociationQ[use], Lookup[use, "Remainder", Missing["NotAvailable"]], Missing["NotAvailable"]]
];

hrfEx01ChannelBasis[scan_] := Module[{attempt},
  attempt = If[AssociationQ[scan], Lookup[scan, "AcceptedObstructionAttemptData", <||>], <||>];
  Lookup[attempt, "ChannelBasis", Missing["NotRecorded"]]
];

hrfEx01BestTrialFromDiagnostic[diag_] := Module[{trials, ranked},
  If[! AssociationQ[diag], Return[Missing["NotDiagnostic"]]];
  trials = Lookup[diag, "Trials", {}];
  ranked = Select[trials, TrueQ[Lookup[#, "AdmissibleSLSectorQ", False]] &];
  If[ranked === {},
    ranked = Select[trials,
      Module[{od = Lookup[#, "ObstructionData", Missing[]]},
        AssociationQ[od] && KeyExistsQ[od, "Superleading"] &&
          ! MatchQ[Lookup[od, "Superleading", Missing[]], _Missing]
      ] &
    ]
  ];
  If[ranked === {}, Missing["NoTrialWithObstruction"], First[ranked]]
];

hrfEx01ScanFromDiagnostic[diag_] := Module[{trial, obs},
  trial = hrfEx01BestTrialFromDiagnostic[diag];
  If[! AssociationQ[trial], Return[trial]];
  obs = Lookup[trial, "ObstructionData", Missing["NoObstructionData"]];
  <|
    "CancellationFactors" -> Lookup[diag, "SafeFactors", {}],
    "Generators" -> Lookup[trial, "Generators", {}],
    "GeneratorFactorData" -> Lookup[trial, "GeneratorFactorData", {}],
    "AdmissibleGeneratorSetQ" -> Lookup[trial, "AdmissibleSLSectorQ", False],
    "ObstructionData" -> obs,
    "GeneratorUseData" -> Lookup[trial, "GeneratorUseData", <||>],
    "AcceptedObstructionAttemptData" -> <|
      "ChannelBasis" -> Missing["DiagnosticTrialOnly"],
      "Superleading" -> If[AssociationQ[obs], Lookup[obs, "Superleading", Missing[]], Missing[]]
    |>,
    "DiagnosticSource" -> True,
    "DiagnosticTrialIndex" -> Lookup[trial, "GeneratorSetIndex", Missing["NoIndex"]]
  |>
];

hrfEx01CoverageForScan[scan_, U_, activeVars_, maxAbs_: 5] := Module[{useScan},
  useScan = Which[
    AssociationQ[scan] && TrueQ[Lookup[scan, "DiagnosticSource", False]], scan,
    AssociationQ[scan], scan,
    True, Missing["NoScan"]
  ];
  If[! hrfObstructionFoundQ[useScan], Return[Missing["NoObstructionFound"]]];
  hrfCoverageData[useScan, U, activeVars, maxAbs]
];

hrfEx01RegionStudyRow[label_, configuration_, zeroVars_, activeVars_, scan_, U_, scaling_: Automatic, maxAbs_: 5] := Module[
  {sc, diag, hiddenRow, vsAssoc, channel, fsl, fslSource},
  sc = Which[
    scaling === Automatic, hrfEx01CoverageForScan[scan, U, activeVars, maxAbs],
    True, hrfScalingDataAssoc[scaling]
  ];
  diag = If[AssociationQ[sc], hrfSelectedDiagnostic[sc], <||>];
  vsAssoc = hrfEx01VariableScalingAssoc[diag, activeVars];
  channel = hrfEx01ChannelBasis[scan];
  fsl = hrfEffectiveSuperleadingSector[scan];
  fslSource = hrfEffectiveSuperleadingSource[scan];
  hiddenRow = hrfHiddenSummaryRow[label, configuration, zeroVars, activeVars, scan, sc];
  Join[hiddenRow, <|
    "Region vector" -> hrfEx01Compact[activeVars],
    "Channel basis" -> hrfEx01Compact[channel],
    "Superleading sector" -> If[ValueQ[hrfFactorOrDash], hrfFactorOrDash[fsl], hrfEx01Compact[fsl]],
    "F_SL sector" -> If[ValueQ[hrfFactorOrDash], hrfFactorOrDash[fsl], hrfEx01Compact[fsl]],
    "F_SL sector source" -> hrfEx01Compact[fslSource],
    "Superleading sector source" -> hrfEx01Compact[fslSource],
    "Variable scaling by region variable" -> hrfEx01Compact[vsAssoc],
    "Gap W_HR - W_SL" -> If[ValueQ[hrfWeight],
      hrfWeight[diag, "HierarchyGapPostLPminusFSL", "GapWHRminusWSL"],
      Lookup[diag, "HierarchyGapPostLPminusFSL", Missing["NotAvailable"]]
    ],
    "Vars missing from coverage" -> hrfEx01Compact[Lookup[diag, "VariablesMissingFromLeadingRegionCoverage", "--"]]
  |>]
];

hrfEx01RegionStudyTable[rows_] := Dataset[rows];

hrfEx01RegionStudyTableNotice[title_, message_String] := Dataset[{
  <|"Case" -> title, "Configuration" -> "--", "Note" -> message|>
}];

hrfEx01ChannelAttemptRowsFromScan[scan_Association, boundaryLabel_] := Module[
  {accepted, allAttempts, attempts, a, od},
  accepted = Lookup[scan, "AcceptedObstructionAttemptData", <||>];
  allAttempts = Lookup[accepted, "ChannelObstructionAttempts", Missing[]];
  attempts = Which[
    ListQ[allAttempts], allAttempts,
    AssociationQ[accepted], {accepted},
    True, {}
  ];
  Map[
    Function[a,
      od = Lookup[a, "Obstruction", Missing["NoObstruction"]];
      <|
        "Boundary" -> boundaryLabel,
        "Channel basis" -> Lookup[a, "ChannelBasis", Missing["NoChannelBasis"]],
        "Obstruction decomposition succeeded?" -> Lookup[a, "AcceptedQ", Missing["NoAcceptedQ"]],
        "Rejected reason" -> Lookup[a, "RejectedReason", Missing["NoRejectedReason"]],
        "Selected term count" -> Lookup[a, "SelectedTermCount", Missing["NoSelectedTermCount"]],
        "Superleading sector" -> hrfEx01Compact[Lookup[a, "Superleading", Missing["NoSuperleading"]]],
        "Obstruction preview" -> hrfEx01Compact[od]
      |>
    ],
    attempts
  ]
];

hrfEx01BoundaryOutcomeRow[row_Association] := Module[{scan, obs, od, z, vars},
  scan = Lookup[row, "ObstructionScan", Missing["NoScan"]];
  z = Lookup[row, "ZeroVars", {}];
  vars = Lookup[row, "RemainingVars", {}];
  od = If[AssociationQ[scan], Lookup[scan, "ObstructionData", Missing[]], Missing[]];
  <|
    "Zero variables" -> hrfEx01Compact[z],
    "Codimension" -> Length[z],
    "Region vector" -> hrfEx01Compact[vars],
    "Status" -> Which[
      ! AssociationQ[scan], "no scan",
      MatchQ[scan, _Missing], "missing scan",
      MatchQ[od, _Missing], "no obstruction data",
      AssociationQ[od] && KeyExistsQ[od, "Superleading"] && od["Superleading"] =!= 0, "nonzero superleading sector",
      AssociationQ[od] && KeyExistsQ[od, "Superleading"] && TrueQ[Expand[od["Superleading"]] === 0], "exact reduction",
      True, "scan completed"
    ],
    "Cancellation factor count" -> If[AssociationQ[scan], Length[Lookup[scan, "CancellationFactors", {}]], 0],
    "Generators" -> hrfEx01Compact[If[AssociationQ[scan], Factor /@ Lookup[scan, "Generators", {}], {}]],
    "Admissible SL sector?" -> If[AssociationQ[scan], Lookup[scan, "AdmissibleSLSectorQ", Lookup[scan, "AdmissibleGeneratorSetQ", False]], False],
    "Channel basis" -> hrfEx01Compact[hrfEx01ChannelBasis[scan]],
    "Comment" -> Which[
      vars === {}, "trivial: no remaining variables",
      Lookup[row, "FRestricted", 1] === 0, "trivial: restricted F is zero",
      ! AssociationQ[scan], "obstruction finder not run",
      AssociationQ[scan] && Length[Lookup[scan, "CancellationFactors", {}]] < 2, "fewer than two cancellation factors",
      AssociationQ[scan] && ! TrueQ[Lookup[scan, "AdmissibleSLSectorQ", Lookup[scan, "AdmissibleGeneratorSetQ", False]]], "no admissible SL-sector generator set",
      AssociationQ[od] && KeyExistsQ[od, "Superleading"] && od["Superleading"] =!= 0, "obstruction candidate; inspect scaling row",
      True, "no hidden-region candidate at tested size"
    ],
    "Trivial stratum?" -> If[TrueQ[Lookup[row, "FRestricted", 1] === 0], "Yes (F=0)", "No"]
  |>
];

hrfEx01BoundaryOutcomeTable[rows_List] := Dataset[hrfEx01BoundaryOutcomeRow /@ rows];

hrfHyperCrownInteriorRow[] := Module[{scan},
  scan = Which[
    ValueQ[HyperCrownInteriorScan] && AssociationQ[HyperCrownInteriorScan], HyperCrownInteriorScan,
    ValueQ[Ex04HyperCrownInterior] && AssociationQ[Ex04HyperCrownInterior] &&
      KeyExistsQ[Ex04HyperCrownInterior, "PolynomialScan"], Ex04HyperCrownInterior["PolynomialScan"],
    True, Missing["HyperCrownInteriorScanNotRun"]
  ];
  If[! AssociationQ[scan], Return[scan]];
  <|
    "Case" -> "HyperCrown",
    "Index" -> 0,
    "ZeroVars" -> {},
    "RemainingVars" -> VarsHyperCrown,
    "FRestricted" -> F0HyperCrown,
    "URestricted" -> HyperCrownData["UF"]["U"],
    "ObstructionScan" -> scan,
    "GeneratorCheck" -> hrfExample01BoundaryGeneratorCheck[scan, VarsHyperCrown]
  |>
];

hrfHyperCrownRegionStudyRows[maxAbs_: 5] := Module[{rows, interior, boundary},
  interior = hrfHyperCrownInteriorRow[];
  rows = {};
  If[AssociationQ[interior],
    AppendTo[rows,
      hrfEx01RegionStudyRow[
        "HyperCrown", "Interior", {}, VarsHyperCrown,
        interior["ObstructionScan"], HyperCrownData["UF"]["U"], Automatic, maxAbs
      ]
    ]
  ];
  If[ListQ[HyperCrownBoundaryCandidateScans],
    Do[
      boundary = HyperCrownBoundaryCandidateScans[[i]];
      AppendTo[rows,
        hrfEx01RegionStudyRow[
          "HyperCrown",
          "Boundary " <> ToString[InputForm[boundary["ZeroVars"]]],
          boundary["ZeroVars"],
          boundary["RemainingVars"],
          boundary["ObstructionScan"],
          boundary["URestricted"],
          Lookup[boundary, "CoverageScalingData", Automatic],
          maxAbs
        ]
      ],
      {i, Length[HyperCrownBoundaryCandidateScans]}
    ],
    If[ValueQ[Ex04HyperCrownX11Target] && AssociationQ[Ex04HyperCrownX11Target] &&
        KeyExistsQ[Ex04HyperCrownX11Target, "PolynomialScan"],
      AppendTo[rows,
        hrfEx01RegionStudyRow[
          "HyperCrown", "Boundary {x11}=0",
          Ex04HyperCrownX11Target["ZeroVars"],
          Ex04HyperCrownX11Target["RemainingVars"],
          Ex04HyperCrownX11Target["PolynomialScan"],
          Expand[HyperCrownData["UF"]["U"] /. x11 -> 0],
          Automatic, maxAbs
        ]
      ]
    ]
  ];
  rows
];

hrfHyperCrownRegionStudyTable[maxAbs_: 5] := Module[{rows = hrfHyperCrownRegionStudyRows[maxAbs]},
  If[rows === {},
    hrfEx01RegionStudyTableNotice["HyperCrown",
      "No region-study rows yet. Optional Ex04: run In[19] (Ex04HyperCrownInterior, interior) and/or In[17] (Ex04HyperCrownX11Target, {x11}=0 boundary), then re-evaluate this cell. Legacy binomial: set $HRFRunHyperCrownInteriorScan=True and/or $HRFRunHyperCrownBoundaryScansOnLoad=True before In[1]."
    ],
    hrfEx01RegionStudyTable[rows]
  ]
];

hrfHyperCrownChannelAttemptTable[] := Module[{rows = {}, interior, row, scan},
  interior = hrfHyperCrownInteriorRow[];
  If[AssociationQ[interior],
    scan = interior["ObstructionScan"];
    If[AssociationQ[scan],
      rows = Join[rows, hrfEx01ChannelAttemptRowsFromScan[scan, "Interior"]]
    ]
  ];
  If[ListQ[HyperCrownBoundaryCandidateScans],
    Do[
      row = HyperCrownBoundaryCandidateScans[[i]];
      scan = row["ObstructionScan"];
      If[AssociationQ[scan],
        rows = Join[rows, hrfEx01ChannelAttemptRowsFromScan[scan, hrfEx01Compact[row["ZeroVars"]]]]
      ],
      {i, Length[HyperCrownBoundaryCandidateScans]}
    ],
    If[ValueQ[Ex04HyperCrownX11Target] && AssociationQ[Ex04HyperCrownX11Target] &&
        KeyExistsQ[Ex04HyperCrownX11Target, "PolynomialScan"],
      scan = Ex04HyperCrownX11Target["PolynomialScan"];
      If[AssociationQ[scan],
        rows = Join[rows, hrfEx01ChannelAttemptRowsFromScan[scan, "{x11}"]]
      ]
    ]
  ];
  If[rows === {},
    Dataset[{<|"Boundary" -> "--", "Note" -> "No channel attempts yet. Run optional In[19] (interior) and/or In[17] ({x11}=0 boundary), then re-evaluate; or enable legacy HyperCrown scans before In[1]."|>}],
    Dataset[rows]
  ]
];

hrfHyperCrownStudySummary[] := Module[{interiorScan, sum, certQ},
  interiorScan = Which[
    ValueQ[Ex04HyperCrownInterior] && AssociationQ[Ex04HyperCrownInterior] &&
      KeyExistsQ[Ex04HyperCrownInterior, "PolynomialScan"], Ex04HyperCrownInterior["PolynomialScan"],
    ValueQ[HyperCrownInteriorScan] && AssociationQ[HyperCrownInteriorScan], HyperCrownInteriorScan,
    True, Missing["NotRun"]
  ];
  sum = If[AssociationQ[interiorScan], Lookup[interiorScan, "ObstructionAttemptSummary", <||>], <||>];
  certQ = AssociationQ[interiorScan] && hrfNoInteriorHiddenRegionCertificateQ[interiorScan];
  <|
    "InteriorScanRunQ" -> AssociationQ[interiorScan],
    "InteriorObstructionFoundQ" -> If[AssociationQ[interiorScan], hrfObstructionFoundQ[interiorScan], False],
    "InteriorAdmissibleSLSectorQ" -> If[AssociationQ[interiorScan],
      TrueQ[Lookup[interiorScan, "AdmissibleSLSectorQ", Lookup[interiorScan, "AdmissibleGeneratorSetQ", False]]],
      False
    ],
    "InteriorHiddenRegionQ" -> If[AssociationQ[interiorScan],
      If[ValueQ[hrfPolyHiddenRegionQ],
        hrfPolyHiddenRegionQ[interiorScan, "Interior"],
        hrfObstructionFoundQ[interiorScan]
      ],
      False
    ],
    "InteriorNoHiddenRegionCertificateQ" -> certQ,
    "CandidateGeneratorCount" -> Lookup[interiorScan, "CandidateGeneratorCount", Lookup[sum, "CandidateGeneratorCount", 0]],
    "ObstructionTrialsRun" -> Lookup[sum, "TrialCount", Lookup[interiorScan, "ObstructionAttemptCount", 0]],
    "PerGeneratorAdmissibleTrials" -> Lookup[sum, "PerGeneratorAdmissibleCount", Missing["NotAvailable"]],
    "AdmissibleSLSectorTrials" -> Lookup[sum, "AdmissibleSLSectorCount", Missing["NotAvailable"]],
    "ValidObstructionTrials" -> Lookup[sum, "ValidObstructionCount", Lookup[interiorScan, "ValidObstructionTrialCount", 0]],
    "CandidateCapReachedQ" -> TrueQ[Lookup[interiorScan, "CandidateGeneratorSetLimitReachedQ", False]],
    "AllCandidatesTriedQ" -> TrueQ[Lookup[interiorScan, "AllCandidateGeneratorSetsTriedQ", False]],
    "Ex04PolynomialScanQ" -> (ValueQ[Ex04HyperCrownInterior] && AssociationQ[Ex04HyperCrownInterior] &&
      KeyExistsQ[Ex04HyperCrownInterior, "PolynomialScan"])
  |>
];

hrfHyperCrownInteriorNarrative[] := Module[{s = hrfHyperCrownStudySummary[]},
  StringRiffle[{
    "HyperCrown interior study summary.",
    "Interior scan run: " <> ToString[s["InteriorScanRunQ"]],
    "Interior obstruction record: " <> ToString[s["InteriorObstructionFoundQ"]],
    "Interior admissible SL sector (best trial): " <> ToString[s["InteriorAdmissibleSLSectorQ"]],
    "Interior hidden region (poly + scaling): " <> ToString[s["InteriorHiddenRegionQ"]],
    "Exhaustive no-interior-HR certificate: " <> ToString[s["InteriorNoHiddenRegionCertificateQ"]],
    "Candidate generator sets: " <> ToString[s["CandidateGeneratorCount"]] <>
      "  (trials run " <> ToString[s["ObstructionTrialsRun"]] <> ")",
    "Per-gen admissible / SL admissible / valid obstruction trials: " <>
      ToString[s["PerGeneratorAdmissibleTrials"]] <> " / " <>
      ToString[s["AdmissibleSLSectorTrials"]] <> " / " <> ToString[s["ValidObstructionTrials"]],
    If[TrueQ[s["CandidateCapReachedQ"]] && ! TrueQ[s["InteriorNoHiddenRegionCertificateQ"]],
      "Candidate cap was reached before all sets were tried; raise $HRFCandidateGeneratorSetLimit to certify absence of interior HR.",
      Nothing
    ],
    If[TrueQ[s["InteriorNoHiddenRegionCertificateQ"]],
      "Within search bounds (Adaptive candidates, physics filter, obstruction size, candidate cap): no interior hidden region.",
      If[TrueQ[s["InteriorScanRunQ"]] && ! TrueQ[s["InteriorObstructionFoundQ"]],
        "Scan completed but certificate is false (incomplete candidate enumeration or cap hit).",
        "Run Ex04HyperCrownInterior = hrfEx04HyperCrownInterior[] (In[19]) for a polynomial interior scan."
      ]
    ],
    If[TrueQ[s["Ex04PolynomialScanQ"]],
      "Source: Ex04 polynomial scan (recommended).",
      "Source: legacy HyperCrownInteriorScan (PairSectors/binomial unless polynomial patch installed)."
    ]
  }, "\n"]
];

hrfDivingBeetleInteriorRows[maxAbs_: 5] := Module[{rows = {}},
  If[ValueQ[DBInteriorScan] && AssociationQ[DBInteriorScan],
    AppendTo[rows,
      hrfEx01RegionStudyRow[
        "Diving Beetle", "Interior scan", {}, VarsDB,
        DBInteriorScan, DBData["UF"]["U"], Automatic, maxAbs
      ]
    ]
  ];
  If[ValueQ[DBInteriorDiagnostic] && AssociationQ[DBInteriorDiagnostic],
    Module[{diagScan = hrfEx01ScanFromDiagnostic[DBInteriorDiagnostic]},
      If[AssociationQ[diagScan],
        AppendTo[rows,
          hrfEx01RegionStudyRow[
            "Diving Beetle", "Interior generator diagnostic (best trial)", {}, VarsDB,
            diagScan, DBData["UF"]["U"], Automatic, maxAbs
          ]
        ]
      ]
    ]
  ];
  rows
];

hrfDivingBeetleBoundaryRows[maxAbs_: 5] := Module[{rows = {}},
  If[ListQ[DBFullBoundaryScans],
    Do[
      Module[{row = DBFullBoundaryScans[[i]], scan, z, vars, u},
        z = Lookup[row, "ZeroVars", {}];
        vars = Lookup[row, "RemainingVars", {}];
        scan = Lookup[row, "ObstructionScan", Missing["NoScan"]];
        u = Expand[DBData["UF"]["U"] /. Thread[z -> 0]];
        AppendTo[rows,
          hrfEx01RegionStudyRow[
            "Diving Beetle",
            "Boundary " <> ToString[InputForm[z]],
            z, vars, scan, u, Automatic, maxAbs
          ]
        ]
      ],
      {i, Length[DBFullBoundaryScans]}
    ]
  ];
  If[rows === {} && ListQ[InterestingBoundaryDBCodim4Size20],
    rows = Map[
      hrfEx01BoundaryOutcomeRow,
      InterestingBoundaryDBCodim4Size20
    ]
  ];
  rows
];

hrfDivingBeetleRegionStudyTable[maxAbs_: 5] := Module[{rows},
  rows = Join[hrfDivingBeetleInteriorRows[maxAbs], hrfDivingBeetleBoundaryRows[maxAbs]];
  If[rows === {},
    hrfEx01RegionStudyTableNotice["Diving Beetle",
      "No region-study rows. Set $HRFRunDivingBeetleInteriorScanOnLoad=True and/or $HRFRunDBFullBoundaryScan=True (or $HRFRunDeepBoundaryScan=True) before In[1], or run the legacy Diving Beetle scan cells manually."
    ],
    hrfEx01RegionStudyTable[rows]
  ]
];

hrfDivingBeetleStudySummary[] := Module[{interiorScan, boundary, interesting, examined},
  interiorScan = If[ValueQ[DBInteriorScan], DBInteriorScan, Missing["NotRun"]];
  boundary = Which[
    ListQ[DBFullBoundaryScans], DBFullBoundaryScans,
    ListQ[InterestingBoundaryDBCodim4Size20], InterestingBoundaryDBCodim4Size20,
    True, {}
  ];
  examined = Which[
    ValueQ[DBBoundaryStrataExamined] && IntegerQ[DBBoundaryStrataExamined], DBBoundaryStrataExamined,
    ListQ[DBFullBoundaryScans], Length[DBFullBoundaryScans],
    True, 0
  ];
  interesting = Select[boundary, hrfObstructionFoundQ[Lookup[#, "ObstructionScan", <||>]] &];
  <|
    "InteriorScanRunQ" -> (ValueQ[DBInteriorScan] && AssociationQ[DBInteriorScan]),
    "InteriorObstructionFoundQ" -> If[AssociationQ[interiorScan], hrfObstructionFoundQ[interiorScan], False],
    "InteriorAdmissibleSLSectorQ" -> If[AssociationQ[interiorScan], TrueQ[Lookup[interiorScan, "AdmissibleSLSectorQ", Lookup[interiorScan, "AdmissibleGeneratorSetQ", False]]], False],
    "InteriorHiddenRegionQ" -> If[ValueQ[DBInteriorScan] && AssociationQ[DBInteriorScan],
      Module[{rows = hrfDivingBeetleInteriorRows[]},
        rows =!= {} && TrueQ[Lookup[First[rows], "Hidden region identified?", "No"] === "Yes"]
      ],
      False
    ],
    "BoundaryStrataExamined" -> examined,
    "BoundaryStrataScanned" -> Length[boundary],
    "BoundaryInterestingCandidates" -> Length[If[ListQ[InterestingBoundaryDBCodim4Size20], InterestingBoundaryDBCodim4Size20, {}]],
    "BoundaryStrataWithObstructionRecord" -> Length[interesting],
    "BoundaryStrataWithNonzeroSuperleading" -> Length[Select[interesting,
      Module[{osc = Lookup[#, "ObstructionScan", <||>], od},
        od = Lookup[osc, "ObstructionData", Missing[]];
        AssociationQ[od] && KeyExistsQ[od, "Superleading"] && od["Superleading"] =!= 0
      ] &
    ]],
    "BoundaryStrataWithAdmissibleSLSector" -> Length[Select[interesting,
      Module[{osc = Lookup[#, "ObstructionScan", <||>]},
        TrueQ[Lookup[osc, "AdmissibleSLSectorQ", Lookup[osc, "AdmissibleGeneratorSetQ", False]]]
      ] &
    ]],
    "DiagnosticTrialCount" -> If[AssociationQ[DBInteriorDiagnostic], Length[Lookup[DBInteriorDiagnostic, "Trials", {}]], 0]
  |>
];

hrfDivingBeetleFailureNarrative[] := Module[{s = hrfDivingBeetleStudySummary[], boundaryRunQ},
  boundaryRunQ = IntegerQ[s["BoundaryStrataExamined"]] && s["BoundaryStrataExamined"] > 0;
  StringRiffle[{
    "Diving Beetle study summary.",
    "Interior scan run: " <> ToString[s["InteriorScanRunQ"]],
    "Interior obstruction record: " <> ToString[s["InteriorObstructionFoundQ"]],
    "Interior admissible SL sector: " <> ToString[s["InteriorAdmissibleSLSectorQ"]],
    If[boundaryRunQ,
      "Boundary strata examined (codim <= 4): " <> ToString[s["BoundaryStrataExamined"]],
      "Boundary strata examined: 0 (set $HRFRunDBFullBoundaryScan=True for a retained full scan, or $HRFRunDeepBoundaryScan=True for the filtered interesting-boundary pass)."
    ],
    If[boundaryRunQ,
      "Boundary interesting obstruction candidates retained: " <> ToString[s["BoundaryInterestingCandidates"]],
      Nothing
    ],
    If[boundaryRunQ,
      "Boundary strata with obstruction data: " <> ToString[s["BoundaryStrataWithObstructionRecord"]],
      Nothing
    ],
    If[boundaryRunQ,
      "Boundary strata with nonzero superleading: " <> ToString[s["BoundaryStrataWithNonzeroSuperleading"]],
      Nothing
    ],
    If[boundaryRunQ,
      "Boundary strata with admissible SL sector: " <> ToString[s["BoundaryStrataWithAdmissibleSLSector"]],
      Nothing
    ],
    If[boundaryRunQ && s["BoundaryInterestingCandidates"] === 0,
      "All examined boundary strata failed the interesting-boundary filter (need >=2 cancellation factors, >=1 generator, and nonzero superleading at obstruction size 20).",
      If[boundaryRunQ && s["BoundaryStrataWithNonzeroSuperleading"] === 0,
        "No retained boundary stratum produced a nonzero superleading sector at the tested obstruction size.",
        If[boundaryRunQ,
          "Some boundary strata produced superleading candidates; inspect hrfDivingBeetleRegionStudyTable[] for scaling and coverage.",
          "Full boundary study not run in this session; interior-only failure mode cannot rule out a boundary hidden region."
        ]
      ]
    ],
    If[! TrueQ[s["InteriorAdmissibleSLSectorQ"]],
      "Interior scan found no admissible SL-sector generator set at the tested size (fewer than two extended cancellation factors and/or no confirmed F_SL).",
      "Interior scan found an admissible SL-sector generator set."
    ],
    "Generator diagnostic trial count (optional): " <> ToString[s["DiagnosticTrialCount"]]
  }, "\n"]
];

Print["[loaded] Example 01 region-study reporting. Try hrfHyperCrownRegionStudyTable[], hrfHyperCrownChannelAttemptTable[], hrfHyperCrownInteriorNarrative[], hrfDivingBeetleRegionStudyTable[]."];
