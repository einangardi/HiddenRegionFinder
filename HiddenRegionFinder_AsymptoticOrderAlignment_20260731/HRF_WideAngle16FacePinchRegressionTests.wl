(* Regression tests for the cap- and presentation-independent wide-angle
   face/pinch certificate. *)

If[Length[DownValues[hrfWA16LoadRecords]] == 0,
  Get[FileNameJoin[{DirectoryName[$InputFileName], "HRF_WideAngle16NoCrownAudit.wl"}]]
];
If[Length[DownValues[hrfWA16FacePinchAudit]] == 0,
  Get[FileNameJoin[{DirectoryName[$InputFileName], "HRF_WideAngle16FacePinchAudit.wl"}]]
];

ClearAll[hrfWA16FacePinchTestRow, hrfRunWA16FacePinchRegressionTests];

hrfWA16FacePinchTestRow[name_, pass_, detail_: ""] := <|
  "Test" -> name, "PassQ" -> TrueQ[pass], "Detail" -> detail
|>;

hrfRunWA16FacePinchRegressionTests[] := Module[
  {rows = {}, crownRec, crown, raw, rec, hard, farkas, mixed, expectedFSL},
  crownRec = <|
    "ID" -> "Crown", "Name" -> "three-loop Crown",
    "InternalLines" -> CrownInternalEdges,
    "ExternalLines" -> CrownExternalEdges,
    "Data" -> CrownData, "F0" -> F0Crown,
    "U" -> CrownData["UF"]["U"], "Vars" -> VarsCrown
  |>;
  crown = hrfWA16FacePinchAudit[crownRec, {}];
  AppendTo[rows, hrfWA16FacePinchTestRow[
    "Crown.PositivePinchFaceCount",
    Lookup[crown, "PositivePinchFaceCount", -1] === 1,
    "Known positive control has exactly one pure-F0 pinch face"
  ]];
  AppendTo[rows, hrfWA16FacePinchTestRow[
    "Crown.NoUnresolvedFaces",
    Lookup[crown, "UnresolvedFaceCount", -1] === 0,
    "Exact face/pinch audit is complete"
  ]];
  expectedFSL = If[Lookup[crown, "PositiveOrUnresolvedFaces", {}] === {},
    Missing["Absent"],
    First[crown["PositiveOrUnresolvedFaces"]]["FSL"]
  ];
  AppendTo[rows, hrfWA16FacePinchTestRow[
    "Crown.PositiveWitness",
    TrueQ[Lookup[crown, "HiddenRegionQ", False]] &&
      ! MatchQ[expectedFSL, _Missing],
    "Positive witness survives without a generator presentation"
  ]];

  raw = First @ Select[
    hrfWA16ParseDiagramRecords[hrfWA16InputFile[]],
    Lookup[#, "ID"] == 85774 &
  ];
  rec = hrfWA16BuildData[raw];
  hard = hrfWA16FacePinchAudit[rec, {x0, x3, x4, x9}];
  AppendTo[rows, hrfWA16FacePinchTestRow[
    "NoCrown85774.GlobalSubtractionFreeCertificate",
    Lookup[hard, "Certificate", ""] === "GlobalSubtractionFreeF0" &&
      ! TrueQ[Lookup[hard, "HiddenRegionQ", True]],
    "A subtraction-free restricted F0 rejects every possible face at once"
  ]];
  farkas = hrfWA16FacePinchAudit[rec, {x0, x3, x5, x6}];
  AppendTo[rows, hrfWA16FacePinchTestRow[
    "NoCrown85774.LogDerivativeFarkasCertificate",
    Lookup[Lookup[farkas, "FaceStatusCounts", <||>],
      "RejectedByPositiveDerivativeCombination", 0] > 0 &&
      Lookup[farkas, "UnresolvedFaceCount", -1] === 0,
    "Mixed derivative faces are rejected by an exact subtraction-free linear combination of x_i d_i F_SL"
  ]];

  raw = First @ Select[
    hrfWA16ParseDiagramRecords[hrfWA16InputFile[]],
    Lookup[#, "ID"] == 105232 &
  ];
  rec = hrfWA16BuildData[raw];
  mixed = hrfWA16FacePinchAudit[rec, {x0, x1, x3, x5}];
  AppendTo[rows, hrfWA16FacePinchTestRow[
    "NoCrown105232.MixedF0FaceLatticeCount",
    Lookup[mixed, "FaceCount", -1] === 1207,
    "Complete exact F0 face lattice for a mixed-sign near-miss"
  ]];
  AppendTo[rows, hrfWA16FacePinchTestRow[
    "NoCrown105232.AllFacesRejected",
    Lookup[mixed, "FaceStatusCounts", <||>] ===
      <|"RejectedBySignDefiniteDerivative" -> 1207|> &&
      ! TrueQ[Lookup[mixed, "HiddenRegionQ", True]],
    "Every F0 face violates the positive pinch equations"
  ]];
  AppendTo[rows, hrfWA16FacePinchTestRow[
    "NoCrown105232.NoUnresolvedFaces",
    Lookup[mixed, "UnresolvedFaceCount", -1] === 0,
    "Negative certificate contains no timed-out or failed solve"
  ]];
  <|
    "Rows" -> rows,
    "Summary" -> <|
      "Total" -> Length[rows],
      "Passed" -> Count[rows, r_ /; TrueQ[r["PassQ"]]],
      "Failed" -> Count[rows, r_ /; ! TrueQ[r["PassQ"]]]
    |>,
    "CrownAudit" -> crown,
    "SubtractionFreeNoCrownAudit" -> hard,
    "FarkasNoCrownAudit" -> farkas,
    "MixedNoCrownAudit" -> mixed
  |>
];
