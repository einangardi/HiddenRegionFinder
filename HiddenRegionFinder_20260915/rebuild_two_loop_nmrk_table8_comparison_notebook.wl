(* Build a compact cross-topology comparison from the three exhaustive
   source-aware Part-II audit records.  This notebook is diagnostic only;
   it does not edit Table 8. *)

$HistoryLength = 0;
$hrfTable8AuditDirectory = DirectoryName[$InputFileName];
SetDirectory[$hrfTable8AuditDirectory];

ClearAll[hrfT8Text, hrfT8Section];
hrfT8Text[s_String] := Cell[s, "Text"];
hrfT8Section[s_String] := Cell[s, "Section"];

resultFiles = <|
  "planar-hexbox" ->
    "partII_dissection_13_candidate_audit.wl",
  "same-path-hexagon-pentagon" ->
    "partII_dissection_same_path_hexagon_pentagon_audit.wl",
  "separate-path-hexagon-pentagon" ->
    "partII_dissection_separate_path_hexagon_pentagon_audit.wl"
|>;

results = Map[
  Import[FileNameJoin[{
    $hrfTable8AuditDirectory, "results", "nmrk_wz", #}], "WL"] &,
  resultFiles
];

comparisonRows = KeyValueMap[
  Function[{key, result},
    Module[{summary = result["Summary"], certifiedCandidates},
      certifiedCandidates = Lookup[
        Select[result["Candidates"], #["certified facets"] > 0 &],
        "candidate", {}
      ];
      <|
        "Topology" -> result["GraphDisplayName"],
        "StagedCandidates" -> summary["StagedCandidateCount"],
        "CertifiedCandidates" ->
          summary["CandidatesWithAtLeastOneCertificate"],
        "RawCertificates" -> summary["RawCertificateCount"],
        "PhysicalHRs" -> summary["DistinctPhysicalHRCount"],
        "InteriorHRs" -> summary["InteriorPhysicalHRCount"],
        "CodimensionOneHRs" ->
          summary["CodimensionOnePhysicalHRCount"],
        "StrictCertificatePresentations" ->
          summary["StrictCertificatePresentationCount"],
        "StagedDistinctCancellationFactors" ->
          summary["DistinctCancellationFactorCount"],
        "HRSupplyingCancellationFactors" -> Count[
          result["CancellationFactorClasses"],
          row_ /; AnyTrue[row["Candidates"],
            MemberQ[certifiedCandidates, #] &]
        ],
        "StagedDistinctGenerators" -> summary["DistinctGeneratorCount"],
        "HRSupplyingGenerators" -> Count[
          result["GeneratorClasses"],
          row_ /; row["DistinctPullbackVectors"] > 0
        ],
        "BoundaryRestrictionsOfInterior" ->
          summary["BoundaryVectorsWithInteriorExtension"],
        "PreviousTableCount" -> summary["PreviousTableCount"],
        "AgreesWithPreviousTable" ->
          summary["CountAgreesWithPreviousTableQ"]
      |>
    ]
  ],
  results
];

candidateOutcomeRows = KeyValueMap[
  Function[{key, result},
    Module[{candidates = result["Candidates"]},
      <|
        "Topology" -> result["GraphDisplayName"],
        "ExactNoPositivePinchRejections" -> Count[
          candidates,
          row_ /; ! MissingQ[row["positive-pinch obstruction"]]
        ],
        "CompleteDissectionNoCertificate" -> Count[
          candidates,
          row_ /; MissingQ[row["positive-pinch obstruction"]] &&
            row["complete search"] === True &&
            row["certified facets"] === 0
        ],
        "CandidatesProducingCertificates" -> Count[
          candidates, row_ /; row["certified facets"] > 0
        ]
      |>
    ]
  ],
  results
];

comparisonResult = <|
  "GeneratedOn" -> DateString[Now, "ISODateTime"],
  "EquivalenceKey" -> {
    "BoundaryStratum", "ExactCancellationIdeal",
    "NormalisedPullbackVector", "WHR"
  },
  "PresentationOnlyData" -> {"WSL", "CancellationDepth"},
  "TopologyComparison" -> comparisonRows,
  "CandidateOutcomes" -> candidateOutcomeRows
|>;

Export[
  FileNameJoin[{
    "results", "nmrk_wz",
    "partII_dissection_table8_topology_comparison.wl"
  }],
  comparisonResult,
  "Package"
];

notebook = Notebook[{
  Cell["Two-loop NMRK Table 8 comparison audit", "Title"],
  Cell["Planar hexagon--box and the two hexagon--pentagon attachments",
    "Subtitle"],
  hrfT8Text[
    "This evaluated notebook compares the three two-loop topology audits before any change is made to Table 8. A physical HR is identified by its boundary stratum, exact cancellation ideal, normalised pullback vector and W_HR. W_SL and the corresponding cancellation depth are retained as certificate-presentation data but do not split an HR."
  ],

  hrfT8Section["1. Direct comparison"],
  Cell[BoxData @ ToBoxes @ Dataset[comparisonRows], "Output"],

  hrfT8Section["2. Candidate outcomes"],
  hrfT8Text[
    "The exact no-positive-pinch rejection applies when the common cancellation ideal contains a nonzero monomial in active LP variables. Since the LP variables and chart coefficients are positive, the cancellation factors then have no common zero in the selected stratum. The remaining zero-certificate candidates were exhaustively dissected."
  ],
  Cell[BoxData @ ToBoxes @ Dataset[candidateOutcomeRows], "Output"],

  hrfT8Section["3. Reading the result"],
  hrfT8Text[
    "The planar graph has 25 physical HRs (13 interior and 12 codimension one), with two HRs admitting different W_SL/depth presentations. The same-path hexagon--pentagon has 9 physical HRs (3 interior and 6 codimension one), all with a single presentation. The separate-path graph has no staged candidate and remains at zero. These records are ready for review, but this notebook deliberately leaves Table 8 unchanged."
  ]
},
  WindowSize -> {1450, 900},
  WindowTitle -> "Two-loop NMRK Table 8 comparison audit",
  StyleDefinitions -> "Default.nb",
  CellLabelAutoDelete -> False,
  Evaluator -> "Local"
];

Export[
  "12_TwoLoop_NMRK_wz_Table8_Comparison_Audit.nb",
  notebook,
  "Notebook"
];

Print["Wrote 12_TwoLoop_NMRK_wz_Table8_Comparison_Audit.nb"];
Print[
  "Wrote results/nmrk_wz/",
  "partII_dissection_table8_topology_comparison.wl"
];
Print[InputForm[comparisonRows]];
