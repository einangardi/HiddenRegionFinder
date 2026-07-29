(* Exact, cap-independent face/pinch audit of the higher-codimension strata
   of the 16 four-loop wide-angle no-Crown graphs.

   Usage:
     wolframscript -file run_wa16_face_pinch_depth_batch.wl ID ...
     wolframscript -file run_wa16_face_pinch_depth_batch.wl min=4 ID ...

   The default begins at codimension four, where the uncapped permissive
   factor harvest has many survivors.  This runner supplies the decisive
   certificate at codimension four and closes the deeper-codimension loophole
   without any factor-length cap or generator ansatz.
*)

SetDirectory[DirectoryName[$InputFileName]];
Get["HRF_WideAngle16NoCrownAudit.wl"];
Get["HRF_WideAngle16HigherCodimPrefilter.wl"];
Get["HRF_WideAngle16FacePinchAudit.wl"];

args = Rest[$ScriptCommandLine];
minTokens = Select[args, StringStartsQ[ToString[#], "min="] &];
maxTokens = Select[args, StringStartsQ[ToString[#], "max="] &];
minCodim = If[minTokens === {}, 4,
  ToExpression[StringDrop[ToString[Last[minTokens]], 4]]
];
maxCodimOption = If[maxTokens === {}, Automatic,
  ToExpression[StringDrop[ToString[Last[maxTokens]], 4]]
];
idTokens = Select[
  args,
  ! StringStartsQ[ToString[#], "min="] &&
    ! StringStartsQ[ToString[#], "max="] &
];
ids = ToExpression /@ idTokens;
If[ids === {},
  Print["ERROR: provide at least one graph ID."]; Exit[2]
];

rawRecords = hrfWA16ParseDiagramRecords[hrfWA16InputFile[]];
If[! DirectoryQ["results"], CreateDirectory["results"]];

Do[
  raw = First @ Select[rawRecords, Lookup[#, "ID"] == id &];
  rec = hrfWA16BuildData[raw];
  maxCodim = Replace[maxCodimOption, Automatic :> Length[rec["Vars"]] - 2];
  Do[
    base = "results/wa16_face_pinch_v1_id" <> ToString[id] <>
      "_codim" <> ToString[codim];
    zeroSets = hrfWA16BoundaryZeroSets[rec, codim];
    rows = If[FileExistsQ[base <> "_partial_rows.wl"],
      Get[base <> "_partial_rows.wl"], {}
    ];
    startIndex = Length[rows] + 1;
    Print[
      "BEGIN ID ", id, " CODIM ", codim, " ROW ", startIndex,
      "/", Length[zeroSets]
    ];
    Do[
      AppendTo[rows, hrfWA16FacePinchAudit[rec, zeroSets[[i]]]];
      If[Mod[i, 25] == 0 || i == Length[zeroSets],
        Export[base <> "_partial_rows.wl", rows, "Package"];
        Print[
          "ID ", id, " CODIM ", codim, " PROGRESS ", i, "/",
          Length[zeroSets],
          " positive=", Total[Lookup[rows, "PositivePinchFaceCount", 0]],
          " unresolved=", Total[Lookup[rows, "UnresolvedFaceCount", 0]]
        ]
      ],
      {i, startIndex, Length[zeroSets]}
    ];
    summary = <|
      "ID" -> id,
      "PropagatorCount" -> Length[rec["Vars"]],
      "Codimension" -> codim,
      "ScanCount" -> Length[rows],
      "Method" -> "exact F0 face lattice, positive pinch equations, and oriented hierarchy LP",
      "GeneratorPresentationIndependentQ" -> True,
      "CancellationFactorMonomialCap" -> Infinity,
      "StatusCounts" -> Counts[Lookup[rows, "Status", Missing["Absent"]]],
      "CertificateCounts" -> Counts[Lookup[rows, "Certificate", "FaceLatticePinch"]],
      "FaceStatusCounts" -> Merge[
        Cases[Lookup[rows, "FaceStatusCounts", <||>], _Association],
        Total
      ],
      "PositivePinchFaceCount" -> Total[Lookup[rows, "PositivePinchFaceCount", 0]],
      "UnresolvedFaceCount" -> Total[Lookup[rows, "UnresolvedFaceCount", 0]],
      "HiddenRegionStratumCount" -> Count[
        rows, r_ /; TrueQ[Lookup[r, "HiddenRegionQ", False]]
      ]
    |>;
    Export[base <> "_rows.wl", rows, "Package"];
    Export[base <> "_summary.wl", summary, "Package"];
    Print["END ID ", id, " CODIM ", codim, " ", InputForm[summary]],
    {codim, minCodim, maxCodim}
  ],
  {id, ids}
];
