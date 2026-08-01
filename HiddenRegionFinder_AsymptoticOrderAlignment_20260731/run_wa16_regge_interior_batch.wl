(* Checkpointed interior Regge audit for the sixteen no-Crown graphs.

   Usage:
     wolframscript -file run_wa16_regge_interior_batch.wl T23
     wolframscript -file run_wa16_regge_interior_batch.wl T12 85774 105230
*)

SetDirectory[DirectoryName[$InputFileName]];
$HRFRunWideAngle16NoCrownAuditOnLoad = False;
Get["HRF_WideAngle16ReggeInteriorAudit.wl"];

args = Rest[$ScriptCommandLine];
If[args === {},
  Print["ERROR: provide one of T23, T12, T13."]; Exit[2]
];
channel = First[args];
If[! MemberQ[{"T23", "T12", "T13"}, channel],
  Print["ERROR: unknown channel ", channel]; Exit[2]
];
requestedIDs = ToExpression /@ Rest[args];
rawRecords = hrfWA16ParseDiagramRecords[hrfWA16InputFile[]];
If[requestedIDs =!= {},
  rawRecords = Select[rawRecords, MemberQ[requestedIDs, Lookup[#, "ID"]] &]
];
If[! DirectoryQ["results"], CreateDirectory["results"]];
base = "results/wa16_regge_interior_v1_" <> ToLowerCase[channel];
rows = If[FileExistsQ[base <> "_partial_rows.wl"],
  Get[base <> "_partial_rows.wl"], {}
];
completedIDs = Lookup[rows, "ID", {}];

Print["BEGIN REGGE INTERIOR ", channel, " completed=", Length[rows],
  " remaining=", Length[Complement[Lookup[rawRecords, "ID"], completedIDs]]];
Do[
  id = raw["ID"];
  If[! MemberQ[completedIDs, id],
    rec = hrfWA16BuildData[raw];
    seconds = AbsoluteTiming[row = hrfWA16ReggeInteriorAudit[rec, channel]][[1]];
    row = Join[row, <|"Seconds" -> seconds|>];
    AppendTo[rows, row];
    Export[base <> "_partial_rows.wl", rows, "Package"];
    Print["REGGE ", channel, " ID ", id,
      " status=", Lookup[row, "Status", "Absent"],
      " faces=", Lookup[row, "FaceCount", 0],
      " positive=", Lookup[row, "PositivePinchFaceCount", 0],
      " unresolved=", Lookup[row, "UnresolvedFaceCount", 0],
      " seconds=", NumberForm[seconds, {7, 2}]]
  ],
  {raw, rawRecords}
];
summary = Join[
  <|
    "Channel" -> channel,
    "Method" -> "Regge-leading exact face lattice, positive pinch equations, and oriented hierarchy LP",
    "GeneratorPresentationIndependentQ" -> True,
    "CancellationFactorMonomialCap" -> Infinity,
    "GraphIDs" -> Lookup[rows, "ID", {}],
    "TotalSeconds" -> Total[Lookup[rows, "Seconds", 0]]
  |>,
  hrfWA16ReggeCompactSummary[rows]
];
Export[base <> "_rows.wl", rows, "Package"];
Export[base <> "_summary.wl", summary, "Package"];
Print["END REGGE INTERIOR ", channel, " ", InputForm[summary]];
