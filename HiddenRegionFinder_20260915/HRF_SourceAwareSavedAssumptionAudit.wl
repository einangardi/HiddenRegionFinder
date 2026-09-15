(* Re-audit saved examples whose earlier acceptance used the synthetic
   F_SL-promotion facet.  The source-aware dissection either supplies an
   exact resolved lower facet or leaves the old candidate unresolved. *)

$HistoryLength = 0;
$HRFSourceAwareAuditDirectory = DirectoryName[$InputFileName];
SetDirectory[$HRFSourceAwareAuditDirectory];
$HRFQuietReports = True;
Get[FileNameJoin[{$HRFSourceAwareAuditDirectory, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{$HRFSourceAwareAuditDirectory,
  "HRF_AsymptoticOrderAlignment.wl"}]];

ClearAll[
  hrfSAWZTransform,
  hrfSACompactCertificate,
  hrfSACompactAudit,
  hrfSARunSavedAssumptionAudit
];

hrfSAWZTransform[p_] := Module[{q},
  q = Factor[p /. {q1*q1b -> Q, q1b*q1 -> Q}];
  q = q /. {
    (1 - z)*(1 - zb) -> Kz, (1 - zb)*(1 - z) -> Kz,
    (-1 + z)*(-1 + zb) -> Kz, (-1 + zb)*(-1 + z) -> Kz
  };
  q = Expand[q] /. {
    z*zb -> Kz + z + zb - 1,
    zb*z -> Kz + z + zb - 1,
    1 - z - zb + z*zb -> Kz,
    1 - zb - z + z*zb -> Kz,
    z*zb - z - zb + 1 -> Kz
  };
  Factor[q]
];

hrfSACompactCertificate[certificate_Association] := KeyTake[
  certificate,
  {
    "PullbackScaling", "RelativePullbackScaling", "WSL",
    "ResolvedLeadingWeight", "ResolvedFSLWeight", "CancellationDepth",
    "FSLOnLeadingFacetQ", "FSLSubleadingAfterCancellationQ",
    "FSLContributesToLeadingPolynomialQ", "LeadingFacetRequiresFSLQ",
    "TransverseSuppressions", "PositiveTransverseSuppressionsQ",
    "LeadingFacetSourceCounts", "PullbackChecks"
  }
];

hrfSACompactAudit[audit_Association] := <|
  "CertificationStatus" -> Lookup[audit, "CertificationStatus", Missing[]],
  "CertifiedQ" -> Lookup[audit, "CertifiedQ", False],
  "DistinctCertifiedRegionCount" ->
    Lookup[audit, "DistinctCertifiedRegionCount", 0],
  "MultipleCertifiedRegionsQ" ->
    Lookup[audit, "MultipleCertifiedRegionsQ", False],
  "SearchTruncatedQ" -> Lookup[audit, "SearchTruncatedQ", False],
  "SearchIncompleteQ" -> Lookup[audit, "SearchIncompleteQ", False],
  "SearchCompleteQ" -> Lookup[audit, "SearchCompleteQ", False],
  "TotalPivotChoiceCount" -> Lookup[audit, "TotalPivotChoiceCount", 0],
  "PivotChoiceCount" -> Lookup[audit, "PivotChoiceCount", 0],
  "TotalSignSectorCount" -> Lookup[audit, "TotalSignSectorCount", 0],
  "SignSectorCount" -> Lookup[audit, "SignSectorCount", 0],
  "ChartStatusCounts" -> Counts[
    Lookup[Lookup[audit, "ChartAudits", {}], "ChartStatus", "Missing"]
  ],
  "Certificates" ->
    (hrfSACompactCertificate /@ Lookup[audit, "Certificates", {}])
|>;

hrfSARunSavedAssumptionAudit[] := Module[
  {graphSpecs, externalLines, graphRows = {}, graphName, fullFile, full,
   internalLines, uPoly, vars, termData, stagedRows, assumedRows, audit,
   oneLoop, oneLoopData, oneLoopRow, oneLoopAudit, wideAngle, wideAngleAudit,
   allCases, allCertificates, summary},

  graphSpecs = <|
    "planar-hexbox" -> {
      {"0", {5, 6}}, {"0", {1, 8}}, {"0", {8, 6}},
      {"0", {1, 2}}, {"0", {2, 3}}, {"0", {3, 4}},
      {"0", {4, 7}}, {"0", {7, 5}}, {"0", {7, 8}}
    },
    "nonplanar-hexbox" -> {
      {"0", {5, 8}}, {"0", {1, 8}}, {"0", {1, 2}},
      {"0", {2, 3}}, {"0", {7, 3}}, {"0", {7, 5}},
      {"0", {4, 7}}, {"0", {6, 8}}, {"0", {4, 6}}
    }
  |>;
  externalLines = {
    {p1, 1}, {p2, 4}, {p3, 5},
    {p4, 3}, {p5, 2}, {p6, 6}
  };

  Do[
    fullFile = FileNameJoin[{
      $HRFSourceAwareAuditDirectory, "results", "nmrk_wz",
      "full_wz_" <> graphName <> ".wl"
    }];
    full = Import[fullFile, "WL"];
    internalLines = graphSpecs[graphName];
    uPoly = SymanzikUF[internalLines, externalLines]["U"];
    vars = full["Variables"];
    termData = full["TermData"];
    stagedRows = full["StagedDeduplicatedHiddenRegionRows"];
    assumedRows = Select[
      stagedRows,
      Lookup[Lookup[#, "TotalScalingAudit", <||>], "AuditStatus", ""] ===
          "AcceptedLowerFacet" &&
        ! TrueQ[Lookup[Lookup[#, "TotalScalingAudit", <||>],
          "WHROnlyLowerFacetQ", False]] &
    ];
    MapIndexed[
      Function[{row, index},
        Print["[source-aware audit] ", graphName, " ", First[index], "/",
          Length[assumedRows]];
        audit = hrfSourceAwareAlignedDissectionCertificate[
          row, termData, vars, uPoly, full["EtaSymbol"], hrfSAWZTransform
        ];
        AppendTo[graphRows, <|
          "Case" -> "TwoLoopNMRKwz",
          "Graph" -> graphName,
          "SavedRepresentativeIndex" -> First[index],
          "FaceScaling" -> Lookup[row, "Scaling", Missing[]],
          "BoundaryZeroVariables" ->
            Lookup[row, "PreselectionZeroVars", {}],
          "OldAudit" -> KeyTake[
            Lookup[row, "TotalScalingAudit", <||>],
            {"AuditStatus", "TotalScaling", "WSL", "WHR", "HierarchyGap",
              "WHROnlyLowerFacetQ", "ResolvedWHRAffineRank",
              "RequiredFacetRank"}
          ],
          "SourceAwareAudit" -> hrfSACompactAudit[audit]
        |>]
      ],
      assumedRows
    ],
    {graphName, Keys[graphSpecs]}
  ];

  oneLoop = Import[FileNameJoin[{
    $HRFSourceAwareAuditDirectory, "testdata", "alignment",
    "nmrk_wz_one_loop_hexagon_scan.wl"
  }], "WL"];
  oneLoopData = Import[FileNameJoin[{
    $HRFSourceAwareAuditDirectory, "data", "nmrk",
    "one_loop_hexagon_kinematics.wl"
  }], "WL"];
  oneLoopRow = First[oneLoop["StagedDeduplicatedHiddenRegionRows"]];
  oneLoopAudit = hrfSourceAwareAlignedDissectionCertificate[
    oneLoopRow, oneLoop["TermData"], oneLoop["Variables"], oneLoopData["U"],
    oneLoop["EtaSymbol"], hrfSAWZTransform
  ];

  wideAngle = Import[FileNameJoin[{
    $HRFSourceAwareAuditDirectory, "examples", "five_point_wide_angle",
    "five_point_central_soft_landau_guided_face.wl"
  }], "WL"];
  wideAngleAudit = hrfSourceAwareAlignedDissectionCertificate[
    wideAngle["Row"], wideAngle["TermData"],
    {x0, x1, x2, x3, x4, x5}, wideAngle["U"], delta, Factor
  ];

  allCases = Join[
    {
      <|
        "Case" -> "OneLoopNMRKwz",
        "Graph" -> "hexagon",
        "OldAudit" -> KeyTake[
          Lookup[oneLoopRow, "TotalScalingAudit", <||>],
          {"AuditStatus", "TotalScaling", "WSL", "WHR", "HierarchyGap",
            "WHROnlyLowerFacetQ"}
        ],
        "SourceAwareAudit" -> hrfSACompactAudit[oneLoopAudit]
      |>,
      <|
        "Case" -> "FivePointWideAngleCentralSoft",
        "Graph" -> "landau-guided face",
        "OldAudit" -> KeyTake[
          wideAngle["TotalAudit"],
          {"AuditStatus", "TotalScaling", "WSL", "WHR", "HierarchyGap",
            "WHROnlyLowerFacetQ", "ResolvedWHRAffineRank",
            "RequiredFacetRank"}
        ],
        "SourceAwareAudit" -> hrfSACompactAudit[wideAngleAudit]
      |>
    },
    graphRows
  ];
  allCertificates = Flatten[
    Lookup[Lookup[allCases, "SourceAwareAudit", <||>], "Certificates", {}],
    1
  ];
  summary = <|
    "CaseCount" -> Length[allCases],
    "FormerlyPromotedAcceptedCaseCount" -> Count[
      allCases,
      case_ /; Lookup[case["OldAudit"], "AuditStatus", ""] ===
          "AcceptedLowerFacet" &&
        ! TrueQ[Lookup[case["OldAudit"], "WHROnlyLowerFacetQ", False]]
    ],
    "SourceAwareRecertifiedFormerlyPromotedCaseCount" -> Count[
      allCases,
      case_ /; Lookup[case["OldAudit"], "AuditStatus", ""] ===
          "AcceptedLowerFacet" &&
        ! TrueQ[Lookup[case["OldAudit"], "WHROnlyLowerFacetQ", False]] &&
        TrueQ[case["SourceAwareAudit", "CertifiedQ"]]
    ],
    "SourceAwareCertifiedCaseCount" -> Count[
      allCases,
      case_ /; TrueQ[case["SourceAwareAudit", "CertifiedQ"]]
    ],
    "NotCertifiedCaseCount" -> Count[
      allCases,
      case_ /; ! TrueQ[case["SourceAwareAudit", "CertifiedQ"]]
    ],
    "CompleteNoFacetCaseCount" -> Count[
      allCases,
      case_ /; ! TrueQ[case["SourceAwareAudit", "CertifiedQ"]] &&
        TrueQ[case["SourceAwareAudit", "SearchCompleteQ"]]
    ],
    "TruncatedUnresolvedCaseCount" -> Count[
      allCases,
      case_ /; ! TrueQ[case["SourceAwareAudit", "CertifiedQ"]] &&
        TrueQ[case["SourceAwareAudit", "SearchTruncatedQ"]]
    ],
    "CertifiedRegionCount" -> Length[allCertificates],
    "FSLLeadingRegionCount" -> Count[
      allCertificates,
      certificate_ /; TrueQ[certificate["FSLOnLeadingFacetQ"]]
    ],
    "FSLSubleadingRegionCount" -> Count[
      allCertificates,
      certificate_ /;
        TrueQ[certificate["FSLSubleadingAfterCancellationQ"]]
    ]
  |>;
  <|"Summary" -> summary, "Cases" -> allCases|>
];

If[MemberQ[FileNameTake /@ $ScriptCommandLine,
    "HRF_SourceAwareSavedAssumptionAudit.wl"],
  result = hrfSARunSavedAssumptionAudit[];
  outputFile = FileNameJoin[{
    $HRFSourceAwareAuditDirectory, "results",
    "source_aware_saved_assumption_audit.wl"
  }];
  Export[outputFile, result, "Package"];
  Print[InputForm[result["Summary"]]];
  Print["[source-aware audit] output=", outputFile];
];
