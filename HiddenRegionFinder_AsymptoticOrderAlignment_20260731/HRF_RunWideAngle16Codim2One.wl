(* Run one codimension-two stratum in a fresh process.

   Usage:
     wolframscript -file HRF_RunWideAngle16Codim2One.wl \
       INDEX [SOFT_SECONDS] [KIN_DOMAIN_SECONDS] [OBSTRUCTION_SECONDS]

   The default 5 s and 20 s symbolic sublimits define the fast discovery
   tier.  A timed-out subdecision is recorded as Unresolved and must be sent
   to the exact-resolution tier; it is never certified as NoHR.

   The result is written atomically to results/generated/wa16_codim2/.
   A .running.wl marker remains if the process is killed externally.
*)

$HistoryLength = 0;
repo = DirectoryName[$InputFileName];
SetDirectory[repo];
$HRFQuietReports = True;
$HRFScalingReport = False;
$HRFPolynomialRequireKinematicDomainQ = True;

args = If[$ScriptCommandLine =!= {},
  Rest[$ScriptCommandLine],
  Module[{pos = FirstPosition[$CommandLine, "-script", Missing["NotFound"]]},
    If[MissingQ[pos], {}, Drop[$CommandLine, First[pos] + 1]]
  ]
];
If[Length[args] < 1,
  Print["Usage: wolframscript -file HRF_RunWideAngle16Codim2One.wl INDEX [SOFT_SECONDS]"];
  Exit[2]
];
index = Quiet @ Check[ToExpression[args[[1]]], $Failed];
softSeconds = If[Length[args] >= 2,
  Quiet @ Check[ToExpression[args[[2]]], 300], 300];
kinDomainSeconds = If[Length[args] >= 3,
  Quiet @ Check[ToExpression[args[[3]]], 5], 5];
obstructionSeconds = If[Length[args] >= 4,
  Quiet @ Check[ToExpression[args[[4]]], 20], 20];
If[! IntegerQ[index] || index < 1, Print["Invalid manifest index."]; Exit[2]];
$HRFKinDomainFindInstanceTimeLimit = kinDomainSeconds;
$HRFObstructionFindInstanceTimeLimit = obstructionSeconds;

Get["HRF_WideAngle16Codim2Audit.wl"];
outDir = FileNameJoin[{repo, "results", "generated", "wa16_codim2"}];
If[! DirectoryQ[outDir], CreateDirectory[outDir, CreateIntermediateDirectories -> True]];
stem = "stratum_" <> IntegerString[index, 10, 4];
marker = FileNameJoin[{outDir, stem <> ".running.wl"}];
temporary = FileNameJoin[{outDir, stem <> ".tmp.wl"}];
output = FileNameJoin[{outDir, stem <> ".wl"}];

Export[marker, <|"ManifestIndex" -> index, "ProcessID" -> $ProcessID,
  "StartedAt" -> DateString[Now, "ISODateTime"]|>, "Package"];
result = hrfWA16Codim2RunIndex[index, "SoftTimeLimit" -> softSeconds];
Export[temporary, result, "Package"];
If[FileExistsQ[output], DeleteFile[output]];
RenameFile[temporary, output];
If[FileExistsQ[marker], DeleteFile[marker]];
Print[InputForm[KeyTake[result, {"ManifestIndex", "DiagramID", "ZeroVars",
  "Outcome", "ElapsedSeconds", "CandidateGeneratorCount",
  "ValidObstructionTrialCount", "SearchTruncatedQ",
  "HiddenRegionSearchCompleteQ"}]]];
If[result["Outcome"] === "Unresolved", Exit[3], Exit[0]];
