$HistoryLength = 0;
repo = DirectoryName[$InputFileName];
SetDirectory[repo];
outDir = FileNameJoin[{repo, "results", "nmrk_wz"}];

ClearAll[compactRow];
compactRow[row_Association] := Module[{audit, hrf, cov},
  audit = Lookup[row, "TotalScalingAudit", <||>];
  hrf = Lookup[row, "HRFSummary", <||>];
  cov = Lookup[hrf, "CoverageScalingData", <||>];
  <|
    "FaceScaling" -> Lookup[row, "Scaling", Missing["NotAvailable"]],
    "ActiveVariables" -> Lookup[audit, "ActiveVariables", {}],
    "BoundaryZeroVariables" -> Lookup[audit, "BoundaryZeroVariables", {}],
    "HRFScaling" -> Lookup[cov, "Scaling", Missing["NotAvailable"]],
    "CancellationFactors" -> Lookup[hrf, "CancellationFactors", {}],
    "AuditStatus" -> Lookup[audit, "AuditStatus", Missing["NotAvailable"]],
    "CertifiedTotalScaling" -> Values[Lookup[audit, "TotalScaling", <||>]],
    "CertifiedTotalScalingAssociation" -> Lookup[audit, "TotalScaling", <||>],
    "RelativeTotalScaling" -> Values[Lookup[audit, "RelativeTotalScaling", <||>]],
    "WSL" -> Lookup[audit, "WSL", Missing["NotAvailable"]],
    "WHR" -> Lookup[audit, "WHR", Missing["NotAvailable"]],
    "HierarchyGap" -> Lookup[audit, "HierarchyGap", Missing["NotAvailable"]],
    "CertificationVectorSource" -> Lookup[audit, "CertificationVectorSource", Missing["NotAvailable"]]
  |>
];

graphs = {"planar-hexbox", "nonplanar-hexbox", "hexagon-pentagon"};
wzCertificates = Association @ Table[
  fullFile = FileNameJoin[{outDir, "full_wz_" <> graph <> ".wl"}];
  full = Import[fullFile, "WL"];
  rows = Lookup[full, "DeduplicatedHiddenRegionRows", {}];
  staged = Lookup[full, "StagedDeduplicatedHiddenRegionRows", {}];
  statuses = If[staged === {}, {},
    Lookup[Lookup[staged, "TotalScalingAudit", <||>], "AuditStatus", "Missing"]
  ];
  cert = <|
    "GraphName" -> graph,
    "Expansion" -> "central NMRK with w=z and wb=zb",
    "CurrentFinalAuditQ" -> True,
    "StagedUniqueCount" -> Length[staged],
    "CertifiedUniqueCount" -> Length[rows],
    "FullSupportCertifiedCount" -> Count[rows,
      r_ /; Lookup[r["TotalScalingAudit"], "BoundaryZeroVariables", {}] === {}],
    "BoundaryStratumCertifiedCount" -> Count[rows,
      r_ /; Lookup[r["TotalScalingAudit"], "BoundaryZeroVariables", {}] =!= {}],
    "RejectedUniqueCount" -> Length[staged] - Length[rows],
    "AuditStatusCounts" -> Counts[statuses],
    "Representatives" -> (compactRow /@ rows)
  |>;
  Export[FileNameJoin[{outDir, "certified_wz_" <> graph <> ".wl"}], cert, "Package"];
  graph -> cert,
  {graph, graphs}
];
Export[FileNameJoin[{outDir, "two_loop_wz_certificates.wl"}], wzCertificates, "Package"];

genericControlsFile = FileNameJoin[{outDir, "two_loop_generic_controls.wl"}];
If[! FileExistsQ[genericControlsFile],
  Print["Missing compact generic-NMRK control file: ", genericControlsFile];
  Exit[1]
];
genericControls = Import[genericControlsFile, "WL"];

Print[InputForm[<|"WEqualsZ" -> KeyMap[Identity,
  Map[KeyTake[#, {"StagedUniqueCount", "CertifiedUniqueCount",
    "FullSupportCertifiedCount", "BoundaryStratumCertifiedCount"}] &,
    wzCertificates]], "Generic" -> genericControls|>]];
