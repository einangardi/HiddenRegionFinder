(* ::Package:: *)

(* Run one bounded worker tranche of the wide-angle codimension-two audit.

   Usage with the initialization-free command-line kernel:

     WolframKernel -noinit -script HRF_RunWideAngle16Codim2Batch.wl \
       RESIDUE MODULUS COUNT [SOFT_SECONDS] [KIN_SECONDS] [OBS_SECONDS] \
       [MISSING_OR_UNRESOLVED]

   The worker selects not-yet-recorded missing-manifest rows satisfying
   Mod[ManifestIndex, MODULUS] == RESIDUE and processes at most COUNT of them.
   Two workers therefore use (RESIDUE,MODULUS)=(0,2) and (1,2).

   Every result is written atomically before the next stratum starts.  An
   unresolved result is retained and the worker continues; a .running.wl
   marker identifies a process killed outside Mathematica.
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
If[Length[args] < 3,
  Print["Usage: ... RESIDUE MODULUS COUNT [SOFT] [KIN] [OBS]"];
  Exit[2]
];

residue = Quiet @ Check[ToExpression[args[[1]]], $Failed];
modulus = Quiet @ Check[ToExpression[args[[2]]], $Failed];
count = Quiet @ Check[ToExpression[args[[3]]], $Failed];
softSeconds = If[Length[args] >= 4,
  Quiet @ Check[ToExpression[args[[4]]], 100], 100];
kinDomainSeconds = If[Length[args] >= 5,
  Quiet @ Check[ToExpression[args[[5]]], 5], 5];
obstructionSeconds = If[Length[args] >= 6,
  Quiet @ Check[ToExpression[args[[6]]], 20], 20];
includeUnresolvedQ = If[Length[args] >= 7,
  ToLowerCase[args[[7]]] === "missingorunresolved", False];

If[! And[IntegerQ[residue], IntegerQ[modulus], modulus > 0,
    0 <= residue < modulus, IntegerQ[count], count > 0],
  Print["Invalid worker partition or count."];
  Exit[2]
];

$HRFKinDomainFindInstanceTimeLimit = kinDomainSeconds;
$HRFObstructionFindInstanceTimeLimit = obstructionSeconds;
Get["HRF_WideAngle16Codim2Audit.wl"];

outDir = FileNameJoin[{repo, "results", "generated", "wa16_codim2"}];
If[! DirectoryQ[outDir],
  CreateDirectory[outDir, CreateIntermediateDirectories -> True]
];

outputPath[index_Integer] := FileNameJoin[{outDir,
  "stratum_" <> IntegerString[index, 10, 4] <> ".wl"}];
markerPath[index_Integer] := FileNameJoin[{outDir,
  "stratum_" <> IntegerString[index, 10, 4] <> ".running.wl"}];
temporaryPath[index_Integer] := FileNameJoin[{outDir,
  "stratum_" <> IntegerString[index, 10, 4] <> ".tmp.wl"}];

recordedOutcome[index_Integer] := Module[{path = outputPath[index], value},
  If[! FileExistsQ[path], Return["Missing"]];
  value = Quiet @ Check[Get[path], $Failed];
  If[AssociationQ[value], Lookup[value, "Outcome", "Unreadable"], "Unreadable"]
];

eligible = Select[
  hrfWA16Codim2MissingManifest[],
  Mod[# ["ManifestIndex"], modulus] == residue &&
    With[{outcome = recordedOutcome[# ["ManifestIndex"]]},
      outcome === "Missing" || outcome === "Unreadable" ||
        (includeUnresolvedQ && outcome === "Unresolved")
    ] &
];
selected = Take[eligible, UpTo[count]];

rows = Reap[
  Do[
    index = row["ManifestIndex"];
    marker = markerPath[index];
    temporary = temporaryPath[index];
    output = outputPath[index];
    Export[marker, <|"ManifestIndex" -> index, "ProcessID" -> $ProcessID,
      "WorkerResidue" -> residue, "WorkerModulus" -> modulus,
      "StartedAt" -> DateString[Now, "ISODateTime"]|>, "Package"];
    result = hrfWA16Codim2RunManifestRow[row,
      "SoftTimeLimit" -> softSeconds, "StoreFullScanQ" -> False];
    Export[temporary, result, "Package"];
    If[FileExistsQ[output], DeleteFile[output]];
    RenameFile[temporary, output];
    If[FileExistsQ[marker], DeleteFile[marker]];
    summary = KeyTake[result, {"ManifestIndex", "DiagramID", "ZeroVars",
      "Outcome", "ElapsedSeconds", "CandidateGeneratorCount",
      "ValidObstructionTrialCount", "UnresolvedPositivityCount"}];
    Print[InputForm[summary]];
    Sow[summary],
    {row, selected}
  ]
][[2]];
rows = If[rows === {}, {}, First[rows]];
workerSummary = <|
  "WorkerResidue" -> residue,
  "WorkerModulus" -> modulus,
  "RequestedCount" -> count,
  "ProcessedCount" -> Length[rows],
  "CompleteNoHRCount" -> Count[Lookup[rows, "Outcome", ""], "CompleteNoHR"],
  "CompleteHiddenRegionCount" -> Count[
    Lookup[rows, "Outcome", ""], "CompleteHiddenRegion"],
  "UnresolvedCount" -> Count[Lookup[rows, "Outcome", ""], "Unresolved"],
  "ElapsedSecondsTotal" -> Total[Lookup[rows, "ElapsedSeconds", 0]]
|>;
Print["WORKER_SUMMARY ", InputForm[workerSummary]];
Exit[0];
