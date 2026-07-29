(* ::Package:: *)

(* Regression checks for the checkpointed wide-angle No-Crown codimension-two
   audit.  Manifest index 8 is an already-stored control stratum (x0=x8=0)
   whose complete polynomial-factor harvest produces no admissible generator.
   Such an empty generator set is a rigorous algebraic No-HR certificate when
   no search limit was reached. *)

$HRFWA16Codim2RegressionDirectory = Which[
  StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName],
    DirectoryName[$InputFileName],
  True, Directory[]
];

If[Length[DownValues[hrfWA16Codim2RunIndex]] == 0,
  Get[FileNameJoin[{$HRFWA16Codim2RegressionDirectory,
    "HRF_WideAngle16Codim2Audit.wl"}]]
];

ClearAll[hrfRunWideAngle16Codim2RegressionTests];

hrfRunWideAngle16Codim2RegressionTests[] := Module[
  {result, messageResult, certificateResult, timeoutProbe, rows},
  result = hrfWA16Codim2RunIndex[8, "SoftTimeLimit" -> 120];
  messageResult = hrfWA16Codim2RunIndex[2, "SoftTimeLimit" -> 120];
  certificateResult = Block[{$HRFKinDomainFindInstanceTimeLimit = 0.001},
    hrfWA16Codim2RunIndex[825, "SoftTimeLimit" -> 120]
  ];
  timeoutProbe = Block[{$HRFKinDomainFindInstanceTimeLimit = 0,
      $HRFKinDomainUnresolvedCount = 0},
    <|"Value" -> hrfKinDomainCompatibleQ[
        x0^2 - x0*x1 + x1^2, {x0, x1}, s12 > 0, {s12}],
      "UnresolvedCount" -> $HRFKinDomainUnresolvedCount|>
  ];
  rows = {
    <|"Test" -> "Control.ManifestIdentity",
      "PassQ" -> (result["DiagramID"] === 85774 &&
        Sort[result["ZeroVars"]] === Sort[{x0, x8}]),
      "Value" -> KeyTake[result, {"ManifestIndex", "DiagramID", "ZeroVars"}]|>,
    <|"Test" -> "Control.CompleteFactorAndGeneratorSearch",
      "PassQ" -> (! TrueQ[result["SearchTruncatedQ"]] &&
        result["CandidateGeneratorCount"] === 0 &&
        TrueQ[result["HiddenRegionSearchCompleteQ"]]),
      "Value" -> KeyTake[result, {"SearchTruncatedQ",
        "CandidateGeneratorCount", "HiddenRegionSearchCompleteQ"}]|>,
    <|"Test" -> "Control.EmptyGeneratorSetCertifiesNoHR",
      "PassQ" -> (result["Outcome"] === "CompleteNoHR" &&
        ! TrueQ[result["HiddenRegionQ"]] &&
        result["ValidObstructionTrialCount"] === 0),
      "Value" -> KeyTake[result, {"Outcome", "HiddenRegionQ",
        "ValidObstructionTrialCount"}]|>,
    <|"Test" -> "Messages.DoNotDiscardValidAssociation",
      "PassQ" -> (messageResult["Outcome"] === "CompleteNoHR" &&
        messageResult["CandidateGeneratorCount"] === 0 &&
        TrueQ[messageResult["HiddenRegionSearchCompleteQ"]]),
      "Value" -> KeyTake[messageResult, {"Outcome", "CandidateGeneratorCount",
        "HiddenRegionSearchCompleteQ"}]|>,
    <|"Test" -> "ExactCertificate.EliminatesPositivityTimeout",
      "PassQ" -> (certificateResult["Outcome"] === "CompleteNoHR" &&
        certificateResult["CancellationFactorCount"] > 0 &&
        certificateResult["UnresolvedPositivityCount"] === 0 &&
        TrueQ[certificateResult["HiddenRegionSearchCompleteQ"]]),
      "Value" -> KeyTake[certificateResult, {"Outcome",
        "CancellationFactorCount", "UnresolvedPositivityCount",
        "HiddenRegionSearchCompleteQ"}]|>,
    <|"Test" -> "Timeout.LowLevelDecisionIsAudited",
      "PassQ" -> (! TrueQ[timeoutProbe["Value"]] &&
        timeoutProbe["UnresolvedCount"] > 0),
      "Value" -> timeoutProbe|>
  };
  <|
    "Summary" -> <|
      "Total" -> Length[rows],
      "Passed" -> Count[Lookup[rows, "PassQ", False], True],
      "Failed" -> Count[Lookup[rows, "PassQ", False], False],
      "AllPassedQ" -> And @@ Lookup[rows, "PassQ", False]
    |>,
    "Rows" -> rows,
    "Dataset" -> Dataset[rows],
    "ControlResult" -> result,
    "MessageControlResult" -> messageResult,
    "CertificateControlResult" -> certificateResult,
    "TimeoutProbe" -> timeoutProbe
  |>
];
