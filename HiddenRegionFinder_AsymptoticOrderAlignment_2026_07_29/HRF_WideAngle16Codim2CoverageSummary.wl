(* ::Package:: *)

(* Coverage accounting for the wide-angle codimension-two audit.

   The 1200 strata split into two disjoint sets:

     188 strata containing x8, covered by the earlier saved audit;
    1012 complementary strata, covered by the present per-stratum audit.

   This file does not promote legacy coverage to a current per-stratum result.
   It reports the two provenances separately and declares combined coverage
   complete only when every complementary stratum has a readable, completed
   result.  Thus a stale or absent output cannot silently count as NoHR.
*)

ClearAll[
  hrfWA16Codim2ResultDirectory, hrfWA16Codim2ResultPath,
  hrfWA16Codim2ReadResult, hrfWA16Codim2CurrentRows,
  hrfWA16Codim2CoverageSummary, hrfWA16Codim2DiagramSummary,
  hrfWA16Codim2CompactRecord, hrfWA16Codim2WriteCompactSummary
];

$HRFWA16Codim2CoverageDirectory = DirectoryName[ExpandFileName[$InputFileName]];

If[Length[DownValues[hrfWA16Codim2Manifest]] == 0,
  Get[FileNameJoin[{$HRFWA16Codim2CoverageDirectory,
    "HRF_WideAngle16Codim2Audit.wl"}]]
];

hrfWA16Codim2ResultDirectory[] := FileNameJoin[{
  $HRFWA16Codim2CoverageDirectory, "results", "generated", "wa16_codim2"
}];

hrfWA16Codim2ResultPath[index_Integer] := FileNameJoin[{
  hrfWA16Codim2ResultDirectory[],
  "stratum_" <> IntegerString[index, 10, 4] <> ".wl"
}];

hrfWA16Codim2ReadResult[index_Integer] := Module[{path, value},
  path = hrfWA16Codim2ResultPath[index];
  If[! FileExistsQ[path], Return[Missing["Absent"]]];
  value = Quiet @ Check[Get[path], $Failed];
  If[AssociationQ[value], value, Missing["Unreadable"]]
];

hrfWA16Codim2CurrentRows[] := Map[
  Function[row,
    With[{result = hrfWA16Codim2ReadResult[row["ManifestIndex"]]},
      Join[row, <|
        "CurrentResultStatus" -> Which[
          MissingQ[result], First[result],
          ! And[
              Lookup[result, "ManifestIndex", Missing[]] ===
                row["ManifestIndex"],
              Lookup[result, "DiagramID", Missing[]] === row["DiagramID"],
              Lookup[result, "ZeroVars", Missing[]] === row["ZeroVars"]
            ], "MetadataMismatch",
          True, Lookup[result, "Outcome", "Unreadable"]
        ],
        "CurrentResult" -> result
      |>]
    ]
  ],
  hrfWA16Codim2Manifest[]
];

hrfWA16Codim2CoverageSummary[] := Module[
  {rows, legacy, complementary, statusCounts, completeComplementaryQ,
   currentResults, digestTuples},
  rows = hrfWA16Codim2CurrentRows[];
  legacy = Select[rows, TrueQ[# ["PreviouslyStoredX8SectorQ"]] &];
  complementary = Select[rows, TrueQ[# ["MissingFromSavedAuditQ"]] &];
  statusCounts = Counts[complementary[[All, "CurrentResultStatus"]]];
  completeComplementaryQ =
    Lookup[statusCounts, "CompleteNoHR", 0] +
      Lookup[statusCounts, "CompleteHiddenRegion", 0] ===
        Length[complementary];
  currentResults = Cases[complementary[[All, "CurrentResult"]],
    _Association];
  digestTuples = ({Lookup[#, "ManifestIndex", Missing[]],
        Lookup[#, "DiagramID", Missing[]],
        Lookup[#, "ZeroVars", Missing[]],
        Lookup[#, "DecisionTupleHash", Missing[]],
        Lookup[#, "Outcome", Missing[]]} &) /@ currentResults;
  <|
    "TotalCodimensionTwoStrata" -> Length[rows],
    "LegacyX8SectorCount" -> Length[legacy],
    "ComplementaryStratumCount" -> Length[complementary],
    "ComplementaryCurrentStatusCounts" -> statusCounts,
    "ComplementaryCoverageCompleteQ" -> completeComplementaryQ,
    "CombinedCoverageCompleteQ" ->
      Length[legacy] == 188 && completeComplementaryQ,
    "ComplementaryHiddenRegionCount" ->
      Lookup[statusCounts, "CompleteHiddenRegion", 0],
    "ComplementaryNoHRCount" -> Lookup[statusCounts, "CompleteNoHR", 0],
    "ComplementaryMaxCandidateGeneratorCount" ->
      Max[0, Sequence @@ Lookup[currentResults,
        "CandidateGeneratorCount", 0]],
    "ComplementaryValidObstructionTrialCount" ->
      Total[Lookup[currentResults, "ValidObstructionTrialCount", 0]],
    "ComplementaryUnresolvedPositivityCount" ->
      Total[Lookup[currentResults, "UnresolvedPositivityCount", 0]],
    "ComplementaryTruncatedSearchCount" ->
      Count[Lookup[currentResults, "SearchTruncatedQ", False], True],
    "ComplementaryResultDigestSHA256" ->
      Hash[digestTuples, "SHA256"],
    "ComplementaryUnresolvedCount" ->
      Lookup[statusCounts, "Unresolved", 0] +
      Lookup[statusCounts, "Unreadable", 0] +
      Lookup[statusCounts, "Absent", 0]
  |>
];

hrfWA16Codim2DiagramSummary[] := Module[{rows, complementary},
  rows = hrfWA16Codim2CurrentRows[];
  complementary = Select[rows, TrueQ[# ["MissingFromSavedAuditQ"]] &];
  Dataset @ Map[
    Function[group,
      With[{statuses = group[[All, "CurrentResultStatus"]]}, <|
        "DiagramID" -> First[group]["DiagramID"],
        "ComplementaryStrata" -> Length[group],
        "CompleteNoHR" -> Count[statuses, "CompleteNoHR"],
        "CompleteHiddenRegion" -> Count[statuses, "CompleteHiddenRegion"],
        "UnresolvedOrMissing" -> Count[statuses,
          Except["CompleteNoHR" | "CompleteHiddenRegion"]]
      |>]
    ],
    GatherBy[complementary, # ["DiagramID"] &]
  ]
];

hrfWA16Codim2CompactRecord[] := <|
  "Audit" -> "Wide-angle four-loop No-Crown codimension two",
  "Method" -> "Complete generator-first HRF on the 1012 strata complementary to the legacy x8 sector",
  "Coverage" -> hrfWA16Codim2CoverageSummary[],
  "PerDiagram" -> Normal[hrfWA16Codim2DiagramSummary[]],
  "LegacyEvidence" -> <|
    "StratumCount" -> 188,
    "Sector" -> "codimension-two contractions containing x8",
    "Source" -> "results/wide_angle_16_stored_boundaries_current_gap_summary.wl"
  |>,
  "GeneratedAt" -> DateString[Now, "ISODateTime"]
|>;

hrfWA16Codim2WriteCompactSummary[path_String] := Module[{record},
  record = hrfWA16Codim2CompactRecord[];
  Put[record, path];
  record
];
