repoDirectory = DirectoryName[$InputFileName];

ClearAll[hrfAsymptoticOrderAlignmentNotebookSmokeTests];
hrfAsymptoticOrderAlignmentNotebookSmokeTests[] := Module[
  {nmrkFile, dscFile, nmrkText, dscText, nmrkCert, nmrkTwoLoop,
   dscCert, rows, summary},
  nmrkFile = FileNameJoin[{repoDirectory,
    "06_NMRK_wz_AsymptoticOrderAlignment_Checks.nb"}];
  dscFile = FileNameJoin[{repoDirectory,
    "07_DSC_AsymptoticOrderAlignment_Checks.nb"}];
  nmrkText = Import[nmrkFile, "Text"];
  dscText = Import[dscFile, "Text"];
  nmrkCert = Import[FileNameJoin[{repoDirectory, "results", "nmrk_wz",
    "one_loop_hexagon_certificate.wl"}], "WL"];
  nmrkTwoLoop = Import[FileNameJoin[{repoDirectory, "results", "nmrk_wz",
    "two_loop_wz_certificates.wl"}], "WL"];
  dscCert = Import[FileNameJoin[{repoDirectory, "results", "dsc",
    "one_loop_hexagon_certificate.wl"}], "WL"];
  rows = {
    {"NMRK.NotebookSyntaxQ", SyntaxQ[nmrkText], True},
    {"DSC.NotebookSyntaxQ", SyntaxQ[dscText], True},
    {"NMRK.NoDSCResultImportsQ",
      ! StringContainsQ[nmrkText,
        {"generic_DSC", "facet_recertified_DSC", "results/dsc"}], True},
    {"NMRK.KinematicsSelfContainedQ",
      And @@ (StringContainsQ[nmrkText, #] & /@
        {"p3^+=P X34", "p4_perp=-q1_perp/(z-1)",
          "X34=X34h/eta", "arXiv:2204.12459"}), True},
    {"NMRK.GeneratorMultiplicityQualifiedQ",
      And[StringContainsQ[nmrkText, "three generator classes"],
        StringContainsQ[nmrkText,
          "No x_i alone is treated as a cancellation factor"]], True},
    {"DSC.NoNMRKResultImportsQ",
      ! StringContainsQ[dscText,
        {"wz_NMRK", "one_loop_NMRK_DSC", "results/nmrk_wz"}], True},
    {"DSC.KinematicsSelfContainedQ",
      And @@ (StringContainsQ[dscText, #] & /@
        {"s23 vanish as eps^2", "s12=stilde12",
          "a<0, -1<tau1<0", "arXiv:2507.05355"}), True},
    {"NMRK.CertifiedVector",
      nmrkCert["CertifiedTotalScaling"], {-2, -2, -3, -2, -3, -2}},
    {"NMRK.Gap", nmrkCert["HierarchyGap"], 1},
    {"NMRK.PlanarCertified",
      nmrkTwoLoop["planar-hexbox", "CertifiedUniqueCount"], 7},
    {"NMRK.PlanarFullSupport",
      nmrkTwoLoop["planar-hexbox", "FullSupportCertifiedCount"], 4},
    {"NMRK.NonplanarCertified",
      nmrkTwoLoop["nonplanar-hexbox", "CertifiedUniqueCount"], 3},
    {"NMRK.NonplanarFullSupport",
      nmrkTwoLoop["nonplanar-hexbox", "FullSupportCertifiedCount"], 1},
    {"NMRK.HexagonPentagonCertified",
      nmrkTwoLoop["hexagon-pentagon", "CertifiedUniqueCount"], 0},
    {"DSC.CertifiedVector",
      dscCert["CertifiedTotalScaling"], {-2, -2, -2, 0, -2, -2}},
    {"DSC.Gap", dscCert["HierarchyGap"], 2},
    {"DSC.NaiveVectorKeptSeparateQ",
      dscCert["NaiveComposedScaling"] =!= dscCert["CertifiedTotalScaling"],
      True}
  };
  rows = (<|"Test" -> #[[1]], "Value" -> #[[2]], "Expected" -> #[[3]],
      "PassQ" -> TrueQ[#[[2]] === #[[3]]]|> &) /@ rows;
  summary = <|
    "Passed" -> Count[rows, r_ /; TrueQ[r["PassQ"]]],
    "Failed" -> Count[rows, r_ /; ! TrueQ[r["PassQ"]]],
    "Total" -> Length[rows]
  |>;
  <|"Summary" -> summary, "Rows" -> rows|>
];

If[$FrontEnd === Null,
  result = hrfAsymptoticOrderAlignmentNotebookSmokeTests[];
  Print[InputForm[result["Summary"]]];
  If[result["Summary", "Failed"] > 0,
    Print[InputForm[Select[result["Rows"], ! TrueQ[#1["PassQ"]] &]]];
    Exit[1]
  ]
];
