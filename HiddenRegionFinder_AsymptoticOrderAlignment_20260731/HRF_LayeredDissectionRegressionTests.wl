(* Focused regressions for layered asymptotic-order-alignment certification. *)

$HRFTestDirectory = DirectoryName[$InputFileName];
SetDirectory[$HRFTestDirectory];
$HRFQuietReports = True;
Get[FileNameJoin[{$HRFTestDirectory, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{$HRFTestDirectory, "HRF_AsymptoticOrderAlignment.wl"}]];

ClearAll[hrfLayeredTestRow, hrfRunLayeredDissectionRegressionTests];

hrfLayeredTestRow[name_, value_, expected_] := <|
  "Test" -> name,
  "Value" -> value,
  "Expected" -> expected,
  "PassQ" -> TrueQ[value === expected]
|>;

hrfRunLayeredDissectionRegressionTests[] := Module[
  {rows = {}, dsc, scan, vars, uPoly, baseRow, shiftedRows, audits,
   totals, accepted, certificate, nmrk, nmrkData, nmrkRow, nmrkAudit,
   nmrkTransform, summary},

  dsc = Import[
    FileNameJoin[{$HRFTestDirectory, "testdata", "alignment",
      "dsc_one_loop_hexagon_scan.wl"}], "WL"
  ];
  scan = dsc["Scan"];
  vars = scan["Variables"];
  uPoly = SymanzikUF[
    dsc["Graph"]["InternalLines"], dsc["Graph"]["ExternalLines"]
  ]["U"];
  baseRow = First[scan["StagedDeduplicatedHiddenRegionRows"]];

  shiftedRows = Table[
    Join[baseRow, <|
      "Scaling" -> baseRow["Scaling"] + c,
      "Weight" -> baseRow["Weight"] + 2 c
    |>],
    {c, {-1, 0, 1, 2}}
  ];
  audits = hrfAsymptoticOrderAlignmentTotalLowerFacetAudit[
      #, scan["TermData"], vars, uPoly, Factor, scan["EtaSymbol"]
    ] & /@ shiftedRows;
  totals = Lookup[audits, "TotalScaling"];
  accepted = Lookup[audits, "AuditStatus"];
  certificate = First[
    audits[[1, "IdealLayerCertification", "Certificates"]]
  ];

  AppendTo[rows, hrfLayeredTestRow[
    "DSC.UniformShift.TotalInvariantQ", SameQ @@ totals, True
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "DSC.UniformShift.AllIdealLayerAcceptedQ",
    DeleteDuplicates[accepted], {"AcceptedIdealLayerJetCertificate"}
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "DSC.PullbackVector", Values[First[totals]],
    {-2, -2, -2, 0, -2, -2}
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "DSC.CancellationDepth", certificate["CancellationDepth"], 2
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "DSC.IntermediateLayerWeights",
    Lookup[certificate["IntermediateVanishingLayers"], "Weight"], {-3}
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "DSC.LowestLayerIdealOrder",
    certificate["LayerAudit"][[1, "IdealOrder"]], 2
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "DSC.IntermediateLayerIdealOrder",
    certificate["LayerAudit"][[2, "IdealOrder"]], 1
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "DSC.TransverseWeights",
    Values[certificate["TransverseWeights"]], {1, 1}
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "DSC.NoResidualScalingQ",
    certificate["ResidualMonomialRescalingQ"], False
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "DSC.DissectionSkippedAfterIdealCertificateQ",
    audits[[1, "LayeredDissectionCertification", "CertificationStatus"]],
    "SkippedIdealLayerCertified"
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "DSC.EtaLatticeStep",
    audits[[1, "IdealLayerCertification",
      "DeclaredEtaExponentLatticeStep"]], 1
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "SyntheticEvenEtaLattice.Step",
    hrfIdealLayerEtaLatticeStep[
      {<|"EtaPower" -> 0|>, <|"EtaPower" -> 2|>,
       <|"EtaPower" -> 4|>}
    ], 2
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "DSC.AbsentLayersNotCancellationLayersQ",
    audits[[1, "IdealLayerCertification",
      "AbsentLayersAreCancellationLayersQ"]], False
  ]];

  nmrkTransform[p_] := Module[{q},
    q = Factor[p /. {q1*q1b -> Q, q1b*q1 -> Q}];
    q = q /. {
      (1 - z)*(1 - zb) -> Kz, (1 - zb)*(1 - z) -> Kz,
      (-1 + z)*(-1 + zb) -> Kz, (-1 + zb)*(-1 + z) -> Kz
    };
    q = Expand[q] /. {
      z*zb -> Kz + z + zb - 1, zb*z -> Kz + z + zb - 1
    };
    Factor[q]
  ];
  nmrk = Import[
    FileNameJoin[{$HRFTestDirectory, "testdata", "alignment",
      "nmrk_wz_one_loop_hexagon_scan.wl"}], "WL"
  ];
  nmrkData = Import[
    FileNameJoin[{$HRFTestDirectory, "data", "nmrk",
      "one_loop_hexagon_kinematics.wl"}],
    "WL"
  ];
  nmrkRow = First[nmrk["StagedDeduplicatedHiddenRegionRows"]];
  nmrkAudit = hrfAsymptoticOrderAlignmentTotalLowerFacetAudit[
    nmrkRow, nmrk["TermData"], nmrk["Variables"], nmrkData["U"],
    nmrkTransform, nmrk["EtaSymbol"]
  ];
  AppendTo[rows, hrfLayeredTestRow[
    "NMRKwz.AcceptedQ", nmrkAudit["TotalLowerFacetQ"], True
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "NMRKwz.TotalVector", Values[nmrkAudit["TotalScaling"]],
    {-2, -2, -3, -2, -3, -2}
  ]];
  AppendTo[rows, hrfLayeredTestRow[
    "NMRKwz.HierarchyGap", nmrkAudit["HierarchyGap"], 1
  ]];

  summary = <|
    "Passed" -> Count[rows, row_ /; TrueQ[row["PassQ"]]],
    "Failed" -> Count[rows, row_ /; ! TrueQ[row["PassQ"]]],
    "Total" -> Length[rows]
  |>;
  <|"Summary" -> summary, "Rows" -> rows|>
];

If[$FrontEnd === Null,
  result = hrfRunLayeredDissectionRegressionTests[];
  Print[InputForm[result["Summary"]]];
  If[result["Summary"]["Failed"] > 0,
    Print[InputForm[Select[result["Rows"], ! TrueQ[#1["PassQ"]] &]]];
    Exit[1]
  ];
];
