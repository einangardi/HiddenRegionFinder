(* ::Package:: *)
(*
  Complete generator-first codimension-two audit for the sixteen four-loop
  wide-angle No-Crown graphs.

  This file deliberately does not enumerate Newton faces.  For each native
  restricted F0 it performs the ordinary HRF order:

    complete factors -> generators -> FSL+FObs -> scaling -> pinch/facet.

  Public entry points:
    hrfWA16Codim2Manifest[]
    hrfWA16Codim2MissingManifest[]
    hrfWA16Codim2PilotManifest[n]
    hrfWA16Codim2RunManifestRow[row, opts]
    hrfWA16Codim2RunIndex[index, opts]
*)

ClearAll[
  hrfWA16Codim2PackageDirectory, hrfWA16Codim2Manifest,
  hrfWA16Codim2EnsureCore, hrfWA16Codim2ToWLList,
  hrfWA16Codim2ParseDiagramRecords, hrfWA16Codim2RawRecords,
  hrfWA16Codim2MissingManifest, hrfWA16Codim2EvenSample,
  hrfWA16Codim2PilotManifest, hrfWA16Codim2DecisionTuple,
  hrfWA16Codim2ScanExpression, hrfWA16Codim2CompactScan,
  hrfWA16Codim2RunManifestRow, hrfWA16Codim2RunIndex
];

hrfWA16Codim2PackageDirectory[] := Module[{inp = Quiet @ Check[$InputFileName, ""]},
  Which[
    StringQ[inp] && inp =!= "" && FileExistsQ[inp], DirectoryName[ExpandFileName[inp]],
    FileExistsQ[FileNameJoin[{Directory[], "HRF_WideAngle16NoCrownAudit.wl"}]], Directory[],
    True, Directory[]
  ]
];

$HRFWA16Codim2PackageDirectory = hrfWA16Codim2PackageDirectory[];
$HRFWA16Codim2InputFile = FileNameJoin[{
  $HRFWA16Codim2PackageDirectory, "data", "wide_angle",
  "16_examples_diagrams.txt"
}];

hrfWA16Codim2EnsureCore[] := Module[{},
  If[Length[DownValues[hrfWA16BuildData]] == 0,
    $HRFRunWideAngle16NoCrownAuditOnLoad = False;
    Get[FileNameJoin[{$HRFWA16Codim2PackageDirectory,
      "HRF_WideAngle16NoCrownAudit.wl"}]]
  ];
  True
];

hrfWA16Codim2ToWLList[s_String] := ToExpression @ StringReplace[
  StringTrim[s],
  {
    "[" -> "{", "]" -> "}",
    "'0'" -> "\"0\"",
    "'p1'" -> "p1", "'p2'" -> "p2", "'p3'" -> "p3", "'p4'" -> "p4"
  }
];

hrfWA16Codim2ParseDiagramRecords[file_String] := Module[{txt, chunks, parse},
  txt = Import[file, "Text"];
  chunks = Select[StringTrim /@ Rest[StringSplit[txt, "diagrams["]],
    StringLength[#] > 0 &];
  parse[ch_String] := Module[{id, internal, external},
    id = ToExpression @ First @ StringCases[
      ch, StartOfString ~~ Shortest[n : DigitCharacter ..] ~~ "]" :> n];
    internal = First @ StringCases[
      ch, "'internal_lines'" ~~ WhitespaceCharacter ... ~~ ":" ~~
        WhitespaceCharacter ... ~~ Shortest[x__] ~~ "," ~~
        WhitespaceCharacter ... ~~ "'external_lines'" :> StringTrim[x]];
    external = First @ StringCases[
      ch, "'external_lines'" ~~ WhitespaceCharacter ... ~~ ":" ~~
        WhitespaceCharacter ... ~~ Shortest[x__] ~~ "," ~~
        WhitespaceCharacter ... ~~ "'propagators'" :> StringTrim[x]];
    <|"ID" -> id, "Name" -> "diaf" <> ToString[id],
      "InternalLines" -> hrfWA16Codim2ToWLList[internal],
      "ExternalLines" -> hrfWA16Codim2ToWLList[external]|>
  ];
  parse /@ chunks
];

hrfWA16Codim2RawRecords[] := hrfWA16Codim2RawRecords[] =
  hrfWA16Codim2ParseDiagramRecords[$HRFWA16Codim2InputFile];

hrfWA16Codim2Manifest[] := hrfWA16Codim2Manifest[] = Module[
  {records, index = 0},
  records = hrfWA16Codim2RawRecords[];
  Flatten @ MapIndexed[
    Function[{rec, graphPosition},
      With[{vars = Table[Symbol["x" <> ToString[i]],
            {i, 0, Length[rec["InternalLines"]] - 1}]}, Map[
        Function[zero,
          index++;
          <|
            "ManifestIndex" -> index,
            "GraphPosition" -> First[graphPosition],
            "DiagramID" -> rec["ID"],
            "DiagramName" -> rec["Name"],
            "EdgeCount" -> Length[vars],
            "ZeroVars" -> zero,
            "PreviouslyStoredX8SectorQ" -> MemberQ[zero, x8],
            "MissingFromSavedAuditQ" -> Not @ MemberQ[zero, x8]
          |>
        ],
        Subsets[vars, {2}]
      ]]
    ],
    records
  ]
];

hrfWA16Codim2MissingManifest[] :=
  Select[hrfWA16Codim2Manifest[], TrueQ[# ["MissingFromSavedAuditQ"]] &];

hrfWA16Codim2EvenSample[rows_List, n_Integer] := Module[{positions},
  If[n <= 0 || rows === {}, Return[{}]];
  If[n >= Length[rows], Return[rows]];
  positions = DeleteDuplicates @ Round @ Subdivide[1, Length[rows], n - 1];
  rows[[positions]]
];

(* A balanced pilot reflects the graph population: one quarter twelve-edge
   graphs and three quarters thirteen-edge graphs. *)
hrfWA16Codim2PilotManifest[n_Integer : 16] := Module[
  {missing, e12, e13, n12, n13},
  missing = hrfWA16Codim2MissingManifest[];
  e12 = Select[missing, # ["EdgeCount"] == 12 &];
  e13 = Select[missing, # ["EdgeCount"] == 13 &];
  n12 = Min[Length[e12], Max[1, Round[n/4]]];
  n13 = Min[Length[e13], Max[0, n - n12]];
  SortBy[
    Join[hrfWA16Codim2EvenSample[e12, n12],
      hrfWA16Codim2EvenSample[e13, n13]],
    # ["ManifestIndex"] &
  ]
];

hrfWA16Codim2DecisionTuple[row_Association] := Module[
  {records, rec, zero, f, u, fFull, layers, vars},
  hrfWA16Codim2EnsureCore[];
  records = hrfWA16Codim2RawRecords[];
  rec = hrfWA16BuildData[records[[row["GraphPosition"]]]];
  zero = row["ZeroVars"];
  f = Expand[rec["F0"] /. Thread[zero -> 0]];
  u = Expand[rec["U"] /. Thread[zero -> 0]];
  fFull = Expand[rec["Data"]["FOnShell"] /. Thread[zero -> 0]];
  layers = hrfDeltaLayerAssociation[fFull, \[Delta]];
  vars = Complement[rec["Vars"], zero];
  <|
    "Record" -> rec, "F0Restricted" -> f, "URestricted" -> u,
    "DeltaLayers" -> layers, "ActiveVars" -> vars,
    "DecisionTupleHash" -> Hash[{f, u, layers, vars}, "SHA256"]
  |>
];

hrfWA16Codim2ScanExpression[data_Association] := findObstructions[
  data["F0Restricted"], data["ActiveVars"],
  KinAssump4ptOnShell, KinVars4pt, 20,
  "UseExtendedFactors" -> True,
  "GeneratorMode" -> "PairSectors", "MaxGenerators" -> 2,
  "EnableSignedMonomialPairs" -> False,
  "StopOnFirstAdmissible" -> False,
  "CandidateGeneratorSetLimit" -> Infinity,
  "MaxTwoGeneratorUnionTrials" -> Infinity,
  "PolynomialMaxMonomials" -> Automatic,
  "StoreAllObstructionTrialsQ" -> False,
  "U" -> data["URestricted"],
  "FObsForScaling" -> <|"DeltaLayers" -> data["DeltaLayers"]|>,
  "CoverageScalingMethod" -> "ExactCoverage",
  "RequireValidScalingForHiddenRegionQ" -> True
];

hrfWA16Codim2CompactScan[scan_Association] := Module[
  {truncated, complete, hidden, factorAudit, generatorAudit},
  truncated = TrueQ[Lookup[scan, "SearchTruncatedQ", False]];
  complete = TrueQ[Lookup[scan, "HiddenRegionSearchCompleteQ", False]];
  hidden = TrueQ[Lookup[scan, "HiddenRegionQ", False]];
  factorAudit = Lookup[scan, "PolynomialFactorHarvestAudit", <||>];
  generatorAudit = Lookup[scan, "GeneratorConstructionAudit", <||>];
  <|
    "Outcome" -> Which[
      hidden && ! truncated, "CompleteHiddenRegion",
      complete && ! truncated, "CompleteNoHR",
      True, "Unresolved"
    ],
    "HiddenRegionQ" -> hidden,
    "HiddenRegionCount" -> Lookup[scan, "HiddenRegionCount", 0],
    "SearchTruncatedQ" -> truncated,
    "HiddenRegionSearchCompleteQ" -> complete,
    "CancellationFactorCount" -> Length[Lookup[scan, "CancellationFactors", {}]],
    "DegreeAdmissibleFactorCount" -> Length[
      Lookup[scan, "DegreeAdmissibleGeneratorFactors", {}]],
    "CandidateGeneratorCount" -> Lookup[scan, "CandidateGeneratorCount", 0],
    "ValidObstructionTrialCount" -> Lookup[scan, "ValidObstructionTrialCount", 0],
    "CandidateGeneratorSetLimitReachedQ" -> TrueQ[
      Lookup[scan, "CandidateGeneratorSetLimitReachedQ", False]],
    "PolynomialFactorLimitReachedQ" -> TrueQ[
      Lookup[scan, "PolynomialMaxMonomialsLimitReachedQ", False]],
    "UnresolvedPositivityCount" -> Lookup[scan, "UnresolvedPositivityCount", 0],
    "EffectiveSearchConfiguration" -> Lookup[
      scan, "EffectiveSearchConfiguration", <||>],
    "PolynomialFactorHarvestAudit" -> factorAudit,
    "GeneratorConstructionAudit" -> generatorAudit,
    "CoverageScalingData" -> Lookup[scan, "CoverageScalingData", <||>],
    "ValidTrialScalingEvaluations" -> Lookup[
      scan, "ValidTrialScalingEvaluations", {}]
  |>
];

Options[hrfWA16Codim2RunManifestRow] = {
  "SoftTimeLimit" -> 300,
  "StoreFullScanQ" -> False
};

hrfWA16Codim2RunManifestRow[row_Association, OptionsPattern[]] := Module[
  {data, limit, started, elapsed, scan, compact},
  data = hrfWA16Codim2DecisionTuple[row];
  limit = OptionValue["SoftTimeLimit"];
  started = AbsoluteTime[];
  scan = If[limit === Infinity,
    Quiet[hrfWA16Codim2ScanExpression[data]],
    TimeConstrained[
      Quiet[hrfWA16Codim2ScanExpression[data]],
      limit, $TimedOut]
  ];
  elapsed = N[AbsoluteTime[] - started];
  compact = Which[
    scan === $TimedOut, <|"Outcome" -> "Unresolved", "Failure" -> "SoftTimeLimit"|>,
    scan === $Failed, <|"Outcome" -> "Unresolved", "Failure" -> "EvaluationFailed"|>,
    AssociationQ[scan], hrfWA16Codim2CompactScan[scan],
    True, <|"Outcome" -> "Unresolved", "Failure" -> "NonAssociationResult"|>
  ];
  Join[
    row,
    <|
      "ActiveVars" -> data["ActiveVars"],
      "DecisionTupleHash" -> data["DecisionTupleHash"],
      "ElapsedSeconds" -> elapsed,
      "CompletedAt" -> DateString[Now, "ISODateTime"]
    |>,
    compact,
    If[TrueQ[OptionValue["StoreFullScanQ"]] && AssociationQ[scan],
      <|"FullScan" -> scan|>, <||>]
  ]
];

Options[hrfWA16Codim2RunIndex] = Options[hrfWA16Codim2RunManifestRow];
hrfWA16Codim2RunIndex[index_Integer, OptionsPattern[]] := Module[{manifest, row},
  manifest = hrfWA16Codim2Manifest[];
  If[index < 1 || index > Length[manifest],
    Return[<|"Outcome" -> "InvalidManifestIndex", "ManifestIndex" -> index|>]
  ];
  row = manifest[[index]];
  hrfWA16Codim2RunManifestRow[row,
    "SoftTimeLimit" -> OptionValue["SoftTimeLimit"],
    "StoreFullScanQ" -> OptionValue["StoreFullScanQ"]]
];
