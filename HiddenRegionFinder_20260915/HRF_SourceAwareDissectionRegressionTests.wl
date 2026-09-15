(* Focused regressions for source-aware cancellation dissection. *)

$HRFSourceAwareTestDirectory = DirectoryName[$InputFileName];
SetDirectory[$HRFSourceAwareTestDirectory];
$HRFQuietReports = True;
Get[FileNameJoin[{$HRFSourceAwareTestDirectory, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{$HRFSourceAwareTestDirectory,
  "HRF_AsymptoticOrderAlignment.wl"}]];

ClearAll[hrfSADTestRow, hrfRunSourceAwareDissectionRegressionTests];

hrfSADTestRow[name_, value_, expected_] := <|
  "Test" -> name,
  "Value" -> value,
  "Expected" -> expected,
  "PassQ" -> TrueQ[value === expected]
|>;

hrfRunSourceAwareDissectionRegressionTests[] := Module[
  {rows = {}, y, deepChart, deepCertificates, genericDeepAudit,
   standardCertificate,
   deepCertificate, dsc, dscScan, dscVars, dscU, dscRow, dscAudit,
   dscCertificate, nmrk, nmrkData, nmrkRow, nmrkAudit,
   nmrkCertificate, nmrkTransform, summary},

  (* A deliberately small polynomial with two lower facets at the same
     cancellation endpoint.  One balances the first F_SL jet; in the other
     F_SL is genuinely subleading.  This verifies that the implementation
     measures, rather than assumes, the resolved F_SL weight. *)
  Clear[x1, x2, eta];
  y = Unique["hrfSADY"];
  deepChart = hrfSADDissectChart[
    <|
      "FSL" -> (x1 - x2)^2,
      "FObs" -> 0,
      "FOutside" -> (x1 - x2) + eta*x2 + eta*x2^2,
      "U" -> 0
    |>,
    {x1 - x2}, {x1, x2}, {x1}, {x1 -> x2 + y}, {1}, eta,
    {0, 0}, 0, "/usr/local/bin/cddexec",
    "MaxPointCount" -> 100
  ];
  deepCertificates = Lookup[deepChart, "Certificates", {}];
  standardCertificate = SelectFirst[
    deepCertificates, TrueQ[Lookup[#, "FSLOnLeadingFacetQ", False]] &,
    <||>
  ];
  deepCertificate = SelectFirst[
    deepCertificates,
    TrueQ[Lookup[#, "FSLSubleadingAfterCancellationQ", False]] &,
    <||>
  ];
  AppendTo[rows, hrfSADTestRow[
    "Synthetic.CertificateCount", Length[deepCertificates], 2
  ]];
  AppendTo[rows, hrfSADTestRow[
    "Synthetic.StandardFSLWeight",
    Lookup[standardCertificate, "ResolvedFSLWeight", Missing[]], 0
  ]];
  AppendTo[rows, hrfSADTestRow[
    "Synthetic.StandardLeadingWeight",
    Lookup[standardCertificate, "ResolvedLeadingWeight", Missing[]], 0
  ]];
  AppendTo[rows, hrfSADTestRow[
    "Synthetic.DeepFSLWeight",
    Lookup[deepCertificate, "ResolvedFSLWeight", Missing[]], 2
  ]];
  AppendTo[rows, hrfSADTestRow[
    "Synthetic.DeepLeadingWeight",
    Lookup[deepCertificate, "ResolvedLeadingWeight", Missing[]], 1
  ]];
  AppendTo[rows, hrfSADTestRow[
    "Synthetic.DeepCancellationDetectedQ",
    Lookup[deepCertificate, "FSLSubleadingAfterCancellationQ", False], True
  ]];
  genericDeepAudit = hrfSourceAwareDissectionCertificate[
    <|
      "FSL" -> (x1 - x2)^2,
      "FOutside" -> (x1 - x2) + eta*x2 + eta*x2^2
    |>,
    {x1 - x2}, {x1, x2}, eta,
    "MaxPivotChoices" -> 1,
    "MaxSignSectors" -> 1,
    "MaxPointCount" -> 100
  ];
  AppendTo[rows, hrfSADTestRow[
    "Synthetic.GenericEntryPointCertificateCount",
    Lookup[genericDeepAudit, "DistinctCertifiedRegionCount", 0], 2
  ]];
  AppendTo[rows, hrfSADTestRow[
    "Synthetic.ExplicitPivotCapReportedQ",
    Lookup[genericDeepAudit, "SearchTruncatedQ", False], True
  ]];

  (* Positive control already certified by the independent ideal-jet
     calculation.  The source-aware dissection must reproduce it. *)
  dsc = Import[
    FileNameJoin[{$HRFSourceAwareTestDirectory, "testdata", "alignment",
      "dsc_one_loop_hexagon_scan.wl"}], "WL"
  ];
  dscScan = dsc["Scan"];
  dscVars = dscScan["Variables"];
  dscU = SymanzikUF[
    dsc["Graph"]["InternalLines"], dsc["Graph"]["ExternalLines"]
  ]["U"];
  dscRow = First[dscScan["StagedDeduplicatedHiddenRegionRows"]];
  dscAudit = hrfSourceAwareAlignedDissectionCertificate[
    dscRow, dscScan["TermData"], dscVars, dscU,
    dscScan["EtaSymbol"], Factor,
    "MaxPivotChoices" -> 1,
    "MaxSignSectors" -> 1,
    "MaxPointCount" -> 1000
  ];
  dscCertificate = First[Lookup[dscAudit, "Certificates", {<||>}]];
  AppendTo[rows, hrfSADTestRow[
    "DSC.CertifiedQ", Lookup[dscAudit, "CertifiedQ", False], True
  ]];
  AppendTo[rows, hrfSADTestRow[
    "DSC.PullbackVector", Values[Lookup[dscCertificate, "PullbackScaling", <||>]],
    {-2, -2, -2, 0, -2, -2}
  ]];
  AppendTo[rows, hrfSADTestRow[
    "DSC.FSLOnLeadingFacetQ",
    Lookup[dscCertificate, "FSLOnLeadingFacetQ", False], True
  ]];
  AppendTo[rows, hrfSADTestRow[
    "DSC.NoDeepCancellationQ",
    Lookup[dscCertificate, "FSLSubleadingAfterCancellationQ", True], False
  ]];
  AppendTo[rows, hrfSADTestRow[
    "DSC.AllPullbackChecksQ",
    And @@ Values[Lookup[dscCertificate, "PullbackChecks", <||>]], True
  ]];

  (* Previously this example was accepted by synthetic promotion.  Exact
     dissection finds a different, source-resolved lower facet. *)
  nmrkTransform[p_] := Module[{q},
    q = Factor[p /. {q1*q1b -> Q, q1b*q1 -> Q}];
    q = q /. {
      (1 - z)*(1 - zb) -> Kz, (1 - zb)*(1 - z) -> Kz,
      (-1 + z)*(-1 + zb) -> Kz, (-1 + zb)*(-1 + z) -> Kz
    };
    q = Expand[q] /. {
      z*zb -> Kz + z + zb - 1,
      zb*z -> Kz + z + zb - 1
    };
    Factor[q]
  ];
  nmrk = Import[
    FileNameJoin[{$HRFSourceAwareTestDirectory, "testdata", "alignment",
      "nmrk_wz_one_loop_hexagon_scan.wl"}], "WL"
  ];
  nmrkData = Import[
    FileNameJoin[{$HRFSourceAwareTestDirectory, "data", "nmrk",
      "one_loop_hexagon_kinematics.wl"}], "WL"
  ];
  nmrkRow = First[nmrk["StagedDeduplicatedHiddenRegionRows"]];
  nmrkAudit = hrfSourceAwareAlignedDissectionCertificate[
    nmrkRow, nmrk["TermData"], nmrk["Variables"], nmrkData["U"],
    nmrk["EtaSymbol"], nmrkTransform,
    "MaxPivotChoices" -> 1,
    "MaxSignSectors" -> 1,
    "MaxPointCount" -> 1000
  ];
  nmrkCertificate = First[Lookup[nmrkAudit, "Certificates", {<||>}]];
  AppendTo[rows, hrfSADTestRow[
    "NMRK.CertifiedQ", Lookup[nmrkAudit, "CertifiedQ", False], True
  ]];
  AppendTo[rows, hrfSADTestRow[
    "NMRK.PullbackVector",
    Values[Lookup[nmrkCertificate, "PullbackScaling", <||>]],
    {-2, -5, -6, -2, -6, -5}
  ]];
  AppendTo[rows, hrfSADTestRow[
    "NMRK.CancellationDepth",
    Lookup[nmrkCertificate, "CancellationDepth", Missing[]], 4
  ]];
  AppendTo[rows, hrfSADTestRow[
    "NMRK.FSLOnLeadingFacetQ",
    Lookup[nmrkCertificate, "FSLOnLeadingFacetQ", False], True
  ]];
  AppendTo[rows, hrfSADTestRow[
    "NMRK.NoDeepCancellationQ",
    Lookup[nmrkCertificate, "FSLSubleadingAfterCancellationQ", True], False
  ]];
  AppendTo[rows, hrfSADTestRow[
    "NMRK.AllPullbackChecksQ",
    And @@ Values[Lookup[nmrkCertificate, "PullbackChecks", <||>]], True
  ]];

  summary = <|
    "Passed" -> Count[rows, row_ /; TrueQ[row["PassQ"]]],
    "Failed" -> Count[rows, row_ /; ! TrueQ[row["PassQ"]]],
    "Total" -> Length[rows]
  |>;
  <|"Summary" -> summary, "Rows" -> rows|>
];

If[MemberQ[FileNameTake /@ $ScriptCommandLine,
    "HRF_SourceAwareDissectionRegressionTests.wl"],
  Module[{result = hrfRunSourceAwareDissectionRegressionTests[]},
    Print[InputForm[result["Summary"]]];
    If[result["Summary"]["Failed"] > 0,
      Print[InputForm[Select[result["Rows"], ! TrueQ[#1["PassQ"]] &]]];
      Exit[1]
    ]
  ]
];
