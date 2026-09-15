(* Focused regressions for final dissection certification in the ordinary,
   non-aligned HiddenRegionFinder path. *)

$HRFOrdinaryDissectionTestDirectory = DirectoryName[$InputFileName];
SetDirectory[$HRFOrdinaryDissectionTestDirectory];
$HRFQuietReports = True;
Get[FileNameJoin[{$HRFOrdinaryDissectionTestDirectory,
  "HiddenRegionFinder.wl"}]];

ClearAll[hrfODITestRow, hrfRunOrdinaryDissectionIntegrationTests];

hrfODITestRow[name_, value_, expected_] := <|
  "Test" -> name,
  "Value" -> value,
  "Expected" -> expected,
  "PassQ" -> TrueQ[value === expected]
|>;

hrfRunOrdinaryDissectionIntegrationTests[] := Module[
  {rows = {}, trial, coverage, evaluation, layers, eta, components,
   certified, unavailable, legacy, fullScan, f1, f2, generator, summary},

  Clear[x1, x2, x3, x4];
  trial = <|
    "ObstructionData" -> <|
      "Superleading" -> (x1 - x2)^2,
      "Obstruction" -> 0
    |>,
    "SLSectorFactorUnion" -> {x1 - x2}
  |>;
  coverage = <|
    "Scaling" -> {0, 0},
    "AcceptedCount" -> 1,
    "ScalingSearchCompleteQ" -> True
  |>;
  evaluation = <|
    "Trial" -> trial,
    "ScalingData" -> coverage,
    "CoverageScalingData" -> coverage,
    "ValidScalingQ" -> True,
    "HiddenRegionQ" -> True
  |>;
  layers = <|
    "DeltaLayers" -> <|
      0 -> (x1 - x2),
      1 -> (x2 + x2^2)
    |>
  |>;

  eta = Unique["hrfODITestEta$"];
  components = hrfOrdinaryDissectionComponents[trial, 0, layers, eta];
  AppendTo[rows, hrfODITestRow[
    "Components.AbsentObstructionIsZero",
    components["FObs"], 0
  ]];
  AppendTo[rows, hrfODITestRow[
    "Components.RestoredLayersRemainOutside",
    components["FOutside"],
    x1 - x2 + eta*x2 + eta*x2^2
  ]];

  certified = hrfApplyOrdinaryDissectionCertification[
    evaluation, 0, {x1, x2}, layers, "Required",
    {
      "MaxPivotChoices" -> 1,
      "MaxSignSectors" -> 1,
      "MaxPointCount" -> 100
    }
  ];
  AppendTo[rows, hrfODITestRow[
    "Required.ExactCertificateAcceptedQ",
    certified["HiddenRegionQ"], True
  ]];
  AppendTo[rows, hrfODITestRow[
    "Required.Status",
    certified["DissectionCertificationStatus"], "Certified"
  ]];
  AppendTo[rows, hrfODITestRow[
    "Required.CertifiedScalingIsAuthoritativeQ",
    certified["ScalingData", "Scaling"] =!=
      certified["CoverageScalingData", "Scaling"], True
  ]];
  AppendTo[rows, hrfODITestRow[
    "Required.CappedPositiveSearchReportedIncompleteQ",
    certified["DissectionSearchIncompleteQ"], True
  ]];
  AppendTo[rows, hrfODITestRow[
    "Required.PositiveCertificateIsNotUndecidedQ",
    certified["CertificationUnresolvedQ"], False
  ]];

  unavailable = hrfApplyOrdinaryDissectionCertification[
    evaluation, 0, {x1, x2}, layers, "Required",
    {"CDDExecutable" -> "/definitely/not/a/cdd/executable"}
  ];
  AppendTo[rows, hrfODITestRow[
    "Required.UnavailableCertificateRejectsAcceptanceQ",
    unavailable["HiddenRegionQ"], False
  ]];
  AppendTo[rows, hrfODITestRow[
    "Required.UnavailableCertificateIsUnresolvedQ",
    unavailable["CertificationUnresolvedQ"], True
  ]];

  legacy = hrfApplyOrdinaryDissectionCertification[
    evaluation, 0, {x1, x2}, layers, "Off", {}
  ];
  AppendTo[rows, hrfODITestRow[
    "Off.PreservesCoverageAcceptanceQ",
    legacy["HiddenRegionQ"], True
  ]];
  AppendTo[rows, hrfODITestRow[
    "Outcome.CompleteNegativeIsRejected",
    hrfOrdinaryDissectionOutcome[<|
      "CertifiedQ" -> False, "SearchCompleteQ" -> True|>],
    "Rejected"
  ]];
  AppendTo[rows, hrfODITestRow[
    "Outcome.IncompleteNegativeIsUnresolved",
    hrfOrdinaryDissectionOutcome[<|
      "CertifiedQ" -> False, "SearchCompleteQ" -> False|>],
    "Unresolved"
  ]];

  (* Exercise the public ordinary path, including the conversion of distinct
     certified facets into HiddenRegionScans.  The provisional coverage
     equations see the uncancelled U layer at W=-1; exact dissection resolves
     its additional cancellation and correctly moves the leading LP weight
     to W=0 without changing the pulled-back scaling vector. *)
  f1 = x1 - x2;
  f2 = x3 - x4;
  generator = Expand[f1 f2];
  fullScan = findObstructions[
    generator, {x1, x2, x3, x4}, True, {}, Automatic,
    "CancellationFactorOverride" -> {f1, f2},
    "GeneratorSetOverride" -> {{generator}},
    "MaxGenerators" -> 1,
    "StopOnFirstAdmissible" -> False,
    "StoreAllObstructionTrialsQ" -> True,
    "U" -> f1 + f2,
    "FObsForScaling" -> <|
      "DeltaLayers" -> <|1 -> x2 + x4|>
    |>,
    "CoverageScalingMethod" -> "ExactCoverage",
    "OrdinaryDissectionOptions" -> {"MaxPointCount" -> 200}
  ];
  AppendTo[rows, hrfODITestRow[
    "PublicPath.CertifiedQ", fullScan["HiddenRegionQ"], True
  ]];
  AppendTo[rows, hrfODITestRow[
    "PublicPath.RegionCountMatchesScansQ",
    fullScan["HiddenRegionCount"] === Length[fullScan["HiddenRegionScans"]],
    True
  ]];
  AppendTo[rows, hrfODITestRow[
    "PublicPath.SelectedFacetAttachedQ",
    KeyExistsQ[First[fullScan["HiddenRegionScans"]],
      "SelectedDissectionCertificate"],
    True
  ]];
  AppendTo[rows, hrfODITestRow[
    "PublicPath.SourceResolvedWeightRefinesCoverage",
    {
      fullScan["CoverageScalingData", "SelectedCandidateDiagnostic", "WHR"],
      fullScan["CertifiedScalingData", "SelectedCandidateDiagnostic", "WHR"]
    },
    {-1, 0}
  ]];
  AppendTo[rows, hrfODITestRow[
    "PublicPath.SearchCompleteQ",
    fullScan["HiddenRegionSearchCompleteQ"], True
  ]];

  summary = <|
    "Passed" -> Count[rows, row_ /; TrueQ[row["PassQ"]]],
    "Failed" -> Count[rows, row_ /; ! TrueQ[row["PassQ"]]],
    "Total" -> Length[rows]
  |>;
  <|"Summary" -> summary, "Rows" -> rows|>
];

If[MemberQ[FileNameTake /@ $ScriptCommandLine,
    "HRF_OrdinaryDissectionIntegrationTests.wl"],
  Module[{result = hrfRunOrdinaryDissectionIntegrationTests[]},
    Print[InputForm[result["Summary"]]];
    If[result["Summary", "Failed"] > 0,
      Print[InputForm[Select[result["Rows"], ! TrueQ[#1["PassQ"]] &]]];
      Exit[1]
    ]
  ]
];
