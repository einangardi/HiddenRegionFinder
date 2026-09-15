(* ::Package:: *)
(*
  Current-HRF audit for the 16 four-loop wide-angle 2 -> 2 graphs that pass
  mixed-sign derivative preselection but have no three-loop Crown contraction
  minor.

  Public entry points:
    hrfWA16LoadRecords[]
    hrfWA16CrownControl[]
    hrfWA16InteriorAudit[]
    hrfWA16Codim3NearMissAudit[]
    hrfWA16RunAll[]

  The codimension-three audit is deliberately restricted to {x3,x5,x8}:
  this is the previously pending near-miss stratum.  It is not advertised as
  an exhaustive scan of all codimension-three and deeper contractions.
*)

ClearAll[
  hrfWA16PackageDirectory, hrfWA16InputFile, hrfWA16ToWLList,
  hrfWA16ParseDiagramRecords, hrfWA16BuildData, hrfWA16LoadRecords,
  hrfWA16ModeOptions, hrfWA16ScanOne, hrfWA16PairAudit,
  hrfWA16CompactScanRow, hrfWA16CrownControl, hrfWA16InteriorAudit,
  hrfWA16Codim3NearMissAudit, hrfWA16Summary, hrfWA16RunAll
];

hrfWA16PackageDirectory[] := Module[{inp = Quiet @ Check[$InputFileName, ""]},
  Which[
    StringQ[inp] && inp =!= "" && FileExistsQ[inp], DirectoryName[ExpandFileName[inp]],
    FileExistsQ[FileNameJoin[{Directory[], "HiddenRegionFinder.wl"}]], Directory[],
    True, Directory[]
  ]
];

$HRFWA16PackageDirectory = hrfWA16PackageDirectory[];
$HRFWA16InputFile = FileNameJoin[{
  $HRFWA16PackageDirectory, "data", "wide_angle", "16_examples_diagrams.txt"
}];
$HRFWA16ResultFile = FileNameJoin[{
  $HRFWA16PackageDirectory, "results", "wide_angle_16_current_audit.wl"
}];

If[! TrueQ[$HRFFinderCoreLoadedQ], Get[FileNameJoin[{$HRFWA16PackageDirectory, "HiddenRegionFinder.wl"}]]];
$HRFExample01Report = False;
$HRFRunCrownInteriorScanOnLoad = False;
Get[FileNameJoin[{$HRFWA16PackageDirectory, "01_WideAngle_2to2_OffShell.wl"}]];
Get[FileNameJoin[{$HRFWA16PackageDirectory, "HRF_PolynomialCancellationFactors.wl"}]];
Get[FileNameJoin[{$HRFWA16PackageDirectory, "HRF_KinematicGeneratorPresets.wl"}]];
hrfInstallPolynomialCancellationPatch[];

hrfWA16InputFile[] := $HRFWA16InputFile;

hrfWA16ToWLList[s_String] := ToExpression @ StringReplace[
  StringTrim[s],
  {
    "[" -> "{", "]" -> "}",
    "'0'" -> "\"0\"",
    "'p1'" -> "p1", "'p2'" -> "p2", "'p3'" -> "p3", "'p4'" -> "p4"
  }
];

hrfWA16ParseDiagramRecords[file_String] := Module[{txt, chunks, parse},
  txt = Import[file, "Text"];
  chunks = Select[StringTrim /@ Rest[StringSplit[txt, "diagrams["]], StringLength[#] > 0 &];
  parse[ch_String] := Module[{id, internal, external},
    id = ToExpression @ First @ StringCases[
      ch, StartOfString ~~ Shortest[n : DigitCharacter ..] ~~ "]" :> n
    ];
    internal = First @ StringCases[
      ch,
      "'internal_lines'" ~~ WhitespaceCharacter ... ~~ ":" ~~ WhitespaceCharacter ... ~~
        Shortest[x__] ~~ "," ~~ WhitespaceCharacter ... ~~ "'external_lines'" :> StringTrim[x]
    ];
    external = First @ StringCases[
      ch,
      "'external_lines'" ~~ WhitespaceCharacter ... ~~ ":" ~~ WhitespaceCharacter ... ~~
        Shortest[x__] ~~ "," ~~ WhitespaceCharacter ... ~~ "'propagators'" :> StringTrim[x]
    ];
    <|
      "ID" -> id,
      "Name" -> "diaf" <> ToString[id],
      "InternalLines" -> hrfWA16ToWLList[internal],
      "ExternalLines" -> hrfWA16ToWLList[external]
    |>
  ];
  parse /@ chunks
];

hrfWA16BuildData[rec_Association] := Module[{data},
  data = makeFourPointOnShellF0[rec["InternalLines"], rec["ExternalLines"]];
  Join[rec, <|
    "Data" -> data,
    "F0" -> data["F0"],
    "U" -> data["UF"]["U"],
    "Vars" -> data["Vars"]
  |>]
];

hrfWA16LoadRecords[] := hrfWA16BuildData /@ hrfWA16ParseDiagramRecords[hrfWA16InputFile[]];

hrfWA16ModeOptions["PairSectors"] := Join[
  hrfKinematicLimitObstructionOptions["WideAngle4ptExhaustive"],
  {"GeneratorMode" -> "PairSectors", "MaxGenerators" -> 2}
];
hrfWA16ModeOptions["Adaptive"] := {
  "GeneratorMode" -> "Adaptive", "MaxGenerators" -> 2,
  "PreferFewerGenerators" -> False, "MaxProductSubsetSize" -> 2
};
hrfWA16ModeOptions["SingleProduct"] := {
  "GeneratorMode" -> "SingleProduct", "MaxGenerators" -> 1,
  "PreferFewerGenerators" -> True, "MaxProductSubsetSize" -> 2
};

hrfWA16ScanOne[rec_Association, zero_List : {}, mode_String : "PairSectors",
    timeLimit_Integer : 300] := Module[
  {f, u, fFull, vars, scan, status = "OK"},
  f = Expand[rec["F0"] /. Thread[zero -> 0]];
  u = Expand[rec["U"] /. Thread[zero -> 0]];
  fFull = Expand[rec["Data"]["FOnShell"] /. Thread[zero -> 0]];
  vars = Complement[rec["Vars"], zero];
  scan = TimeConstrained[
    Quiet @ Check[
      findObstructions[
        f, vars, KinAssump4ptOnShell, KinVars4pt, 20,
        "UseExtendedFactors" -> True,
        Sequence @@ hrfWA16ModeOptions[mode],
        "StopOnFirstAdmissible" -> False,
        "CandidateGeneratorSetLimit" -> 128,
        "StoreAllObstructionTrialsQ" -> True,
        "U" -> u,
        "FObsForScaling" -> <|"DeltaLayers" -> hrfDeltaLayerAssociation[fFull, \[Delta]]|>,
        "CoverageScalingMethod" -> "ExactCoverage",
        "RequireValidScalingForHiddenRegionQ" -> True
      ],
      status = "Error"; $Failed
    ],
    timeLimit,
    status = "TimedOut"; $TimedOut
  ];
  <|
    "ID" -> rec["ID"], "Name" -> rec["Name"], "ZeroVars" -> zero,
    "Mode" -> mode, "Status" -> status, "Scan" -> scan
  |>
];

hrfWA16PairAudit[rec_Association, scan_Association] := Module[
  {ff, bounds, rows},
  ff = Lookup[scan, "DegreeAdmissibleGeneratorFactors", {}];
  bounds = Lookup[scan, "GeneratorDegreeBounds", <||>];
  rows = If[Length[ff] >= 2,
    Normal @ hrfGeneratorPhysicsPairTable[
      ff, rec["Vars"], KinAssump4ptOnShell, KinVars4pt, bounds
    ],
    {}
  ];
  <|
    "FactorCount" -> Length[ff],
    "PairCount" -> Length[rows],
    "DisjointSupportPairCount" -> Count[
      rows, r_ /; TrueQ[Lookup[r, "DisjointXSupportQ", False]]
    ],
    "SimultaneouslyAdmissiblePairCount" -> Count[
      rows, r_ /; TrueQ[Lookup[r, "SimultaneouslyAdmissibleQ", False]]
    ],
    "PhysicsAdmissiblePairCount" -> Count[
      rows, r_ /; TrueQ[Lookup[r, "PhysicsAdmissibleQ", False]]
    ],
    "PairRows" -> rows
  |>
];

hrfWA16CompactScanRow[row_Association] := Module[
  {scan = Lookup[row, "Scan", $Failed], cov},
  cov = If[AssociationQ[scan], Lookup[scan, "CoverageScalingData", <||>], <||>];
  Join[
    KeyDrop[row, {"Scan"}],
    If[AssociationQ[scan], <|
      "CancellationFactorCount" -> Length[Lookup[scan, "CancellationFactors", {}]],
      "CandidateGeneratorCount" -> Lookup[scan, "CandidateGeneratorCount", 0],
      "ValidObstructionTrialCount" -> Lookup[scan, "ValidObstructionTrialCount", 0],
      "HiddenRegionQ" -> TrueQ[Lookup[scan, "HiddenRegionQ", False]],
      "HiddenRegionCount" -> Lookup[scan, "HiddenRegionCount", 0],
      "CandidateGeneratorSetLimitReachedQ" -> TrueQ[
        Lookup[scan, "CandidateGeneratorSetLimitReachedQ", False]
      ],
      "ScalingStatus" -> If[AssociationQ[cov], Lookup[cov, "Status", Missing["Absent"]], cov],
      "Scaling" -> If[AssociationQ[cov], Lookup[cov, "Scaling", Missing["Absent"]], cov],
      "HierarchyGap" -> If[
        AssociationQ[cov], Lookup[cov, "HierarchyGapPostLPminusFSL", Missing["Absent"]], cov
      ]
    |>, <||>]
  ]
];

hrfWA16CrownControl[] := Module[{rec, row, scan},
  rec = <|
    "ID" -> "Crown", "Name" -> "three-loop Crown",
    "InternalLines" -> CrownInternalEdges, "ExternalLines" -> CrownExternalEdges,
    "Data" -> CrownData, "F0" -> F0Crown, "U" -> CrownData["UF"]["U"],
    "Vars" -> VarsCrown
  |>;
  row = hrfWA16ScanOne[rec, {}, "PairSectors", 300];
  scan = row["Scan"];
  Join[hrfWA16CompactScanRow[row], <|"PairAudit" -> hrfWA16PairAudit[rec, scan]|>]
];

hrfWA16InteriorAudit[] := Module[{records, rows},
  records = hrfWA16LoadRecords[];
  rows = Flatten @ Table[
    With[{row = hrfWA16ScanOne[rec, {}, mode, 300]},
      Join[
        hrfWA16CompactScanRow[row],
        If[mode === "PairSectors" && AssociationQ[row["Scan"]],
          <|"PairAudit" -> hrfWA16PairAudit[rec, row["Scan"]]|>,
          <||>
        ]
      ]
    ],
    {rec, records}, {mode, {"PairSectors", "Adaptive", "SingleProduct"}}
  ];
  rows
];

hrfWA16Codim3NearMissAudit[] := Module[{records},
  records = hrfWA16LoadRecords[];
  hrfWA16CompactScanRow[
    hrfWA16ScanOne[#, {x3, x5, x8}, "PairSectors", 300]
  ] & /@ records
];

hrfWA16Summary[result_Association] := Module[
  {interior, codim3, pairRows},
  interior = Lookup[result, "Interior", {}];
  codim3 = Lookup[result, "Codim3NearMiss", {}];
  pairRows = Select[interior, Lookup[#, "Mode", ""] === "PairSectors" &];
  <|
    "CrownHiddenRegionQ" -> TrueQ[Lookup[result["CrownControl"], "HiddenRegionQ", False]],
    "InteriorScanCount" -> Length[interior],
    "InteriorHiddenRegionCount" -> Count[interior, r_ /; TrueQ[Lookup[r, "HiddenRegionQ", False]]],
    "InteriorPairCount" -> Total[Lookup[Lookup[pairRows, "PairAudit", <||>], "PairCount", 0]],
    "InteriorDisjointSupportPairCount" -> Total[
      Lookup[Lookup[pairRows, "PairAudit", <||>], "DisjointSupportPairCount", 0]
    ],
    "Codim3ScanCount" -> Length[codim3],
    "Codim3ValidObstructionTrialCount" -> Total[Lookup[codim3, "ValidObstructionTrialCount", 0]],
    "Codim3HiddenRegionCount" -> Count[codim3, r_ /; TrueQ[Lookup[r, "HiddenRegionQ", False]]],
    "Codim3TimedOutCount" -> Count[codim3, r_ /; Lookup[r, "Status", ""] === "TimedOut"],
    "Codim3CandidateLimitReachedCount" -> Count[
      codim3, r_ /; TrueQ[Lookup[r, "CandidateGeneratorSetLimitReachedQ", False]]
    ],
    "ScopeNote" -> "The codimension-three result covers only the previously pending {x3,x5,x8} near-miss stratum."
  |>
];

hrfWA16RunAll[] := Module[{result},
  result = <|
    "InputFile" -> hrfWA16InputFile[],
    "CrownControl" -> hrfWA16CrownControl[],
    "Interior" -> hrfWA16InteriorAudit[],
    "Codim3NearMiss" -> hrfWA16Codim3NearMissAudit[]
  |>;
  result = Join[result, <|"Summary" -> hrfWA16Summary[result]|>];
  Export[$HRFWA16ResultFile, result, "Package"];
  result
];

If[TrueQ[$HRFRunWideAngle16NoCrownAuditOnLoad],
  HRFWA16CurrentAudit = hrfWA16RunAll[]
];
