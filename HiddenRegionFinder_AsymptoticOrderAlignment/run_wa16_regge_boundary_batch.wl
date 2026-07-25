(* Checkpointed complete boundary audit for one of the six Regge parent
   permutation classes.

   Usage:
     wolframscript -file run_wa16_regge_boundary_batch.wl class=1
     wolframscript -file run_wa16_regge_boundary_batch.wl class=1 min=1 max=3
*)

SetDirectory[DirectoryName[$InputFileName]];
$HRFRunWideAngle16NoCrownAuditOnLoad = False;
Get["HRF_WideAngle16NoCrownAudit.wl"];
Get["HRF_WideAngle16ReggeBoundaryAudit.wl"];

args = Rest[$ScriptCommandLine];
valueFor[prefix_, default_] := Module[{hit},
  hit = Select[args, StringStartsQ[ToString[#], prefix <> "="] &];
  If[hit === {}, default,
    ToExpression[StringDrop[ToString[Last[hit]], StringLength[prefix] + 1]]
  ]
];
classIndex = valueFor["class", Missing["Required"]];
minCodim = valueFor["min", 1];
maxCodimOption = valueFor["max", Automatic];
If[MissingQ[classIndex], Print["ERROR: class=N is required"]; Exit[2]];

classes = Get["results/wa16_regge_interior_v1_permutation_classes.wl"];
If[! IntegerQ[classIndex] || classIndex < 1 || classIndex > Length[classes],
  Print["ERROR: class index must be between 1 and ", Length[classes]];
  Exit[2]
];
rawRecords = hrfWA16ParseDiagramRecords[hrfWA16InputFile[]];
records = Association[Map[#ID -> hrfWA16BuildData[#] &, rawRecords]];
class = classes[[classIndex]];
rep = class["Representative"];
rec = records[rep["ID"]];
channel = rep["Channel"];
maxCodim = Replace[maxCodimOption, Automatic :> Length[rec["Vars"]] - 2];
If[! DirectoryQ["results"], CreateDirectory["results"]];

Do[
  base = "results/wa16_regge_boundary_v1_class" <> ToString[classIndex] <>
    "_codim" <> ToString[codim];
  zeroSets = Subsets[rec["Vars"], {codim}];
  rows = If[FileExistsQ[base <> "_partial_rows.wl"],
    Get[base <> "_partial_rows.wl"], {}
  ];
  startIndex = Length[rows] + 1;
  Print[
    "BEGIN CLASS ", classIndex, " ", rep, " CODIM ", codim,
    " ROW ", startIndex, "/", Length[zeroSets]
  ];
  Do[
    AppendTo[rows,
      hrfWA16ReggeBoundaryAudit[rec, channel, zeroSets[[i]], True]
    ];
    If[Mod[i, 100] == 0 || i == Length[zeroSets],
      Export[base <> "_partial_rows.wl", rows, "Package"];
      Print[
        "CLASS ", classIndex, " CODIM ", codim, " PROGRESS ", i,
        "/", Length[zeroSets],
        " accepted=", Total[Lookup[rows, "PositivePinchFaceCount", 0]],
        " unresolved=", Total[Lookup[rows, "UnresolvedFaceCount", 0]]
      ]
    ],
    {i, startIndex, Length[zeroSets]}
  ];
  summary = Join[
    <|
      "PermutationClass" -> classIndex,
      "Representative" -> rep,
      "ParentExactClassMultiplicity" -> class["Multiplicity"],
      "PropagatorCount" -> Length[rec["Vars"]],
      "Codimension" -> codim,
      "ExpectedScanCount" -> Length[zeroSets]
    |>,
    hrfWA16ReggeBoundaryCompactSummary[rows]
  ];
  Export[base <> "_rows.wl", rows, "Package"];
  Export[base <> "_summary.wl", summary, "Package"];
  Print["END CLASS ", classIndex, " CODIM ", codim, " ", InputForm[summary]],
  {codim, minCodim, maxCodim}
];
