(* ::Package:: *)
(*
  Cap- and generator-presentation-independent interior Regge audit for the
  sixteen four-loop no-Crown graphs.

  For a channel t = -delta s, the massless four-point polynomial is written

      F/s = FRegge0 + delta FRegge1.

  Every exposed face of FRegge0 is tested for a positive projective pinch.
  A surviving pinch is then tested with the oriented hierarchy LP against
  FRegge0-FSL, U, and all positive Regge-delta layers.  This is the Regge
  analogue of HRF_WideAngle16FacePinchAudit.wl and makes no cancellation-
  factor or generator ansatz.
*)

ClearAll[
  hrfWA16ReggeLargeInvariant, hrfWA16ReggeNormalizedPolynomial,
  hrfWA16ReggeLeadingPolynomial, hrfWA16ReggeLayers,
  hrfWA16ReggeFacePinchRow, hrfWA16ReggeInteriorAudit,
  hrfWA16ReggeCompactSummary
];

If[Length[DownValues[hrfWA16LoadRecords]] == 0,
  Get[FileNameJoin[{DirectoryName[$InputFileName],
    "HRF_WideAngle16NoCrownAudit.wl"}]]
];
If[Length[DownValues[hrfWA16FaceFSL]] == 0,
  Get[FileNameJoin[{DirectoryName[$InputFileName],
    "HRF_WideAngle16FacePinchAudit.wl"}]]
];
If[Length[DownValues[hrfReggeDeltaPolynomial]] == 0,
  Get[FileNameJoin[{DirectoryName[$InputFileName],
    "HRF_Example02ReggeKinematics.wl"}]]
];

If[! ValueQ[$HRFWA16ReggePinchFindInstanceTimeLimit],
  $HRFWA16ReggePinchFindInstanceTimeLimit = 10
];

hrfWA16ReggeLargeInvariant[channel_String] := Switch[channel,
  "T23", s12,
  "T12", s23,
  "T13", s12,
  _, Missing["UnknownReggeChannel", channel]
];

hrfWA16ReggeNormalizedPolynomial[poly_, channel_String] := Module[{large},
  large = hrfWA16ReggeLargeInvariant[channel];
  If[MissingQ[large], Return[large]];
  Cancel[Expand[poly/large]]
];

hrfWA16ReggeLeadingPolynomial[f_, channel_String] :=
  hrfWA16ReggeNormalizedPolynomial[hrfReggeLeadingF[f, channel], channel];

hrfWA16ReggeLayers[f_, channel_String] :=
  hrfDeltaLayerAssociation[
    hrfWA16ReggeNormalizedPolynomial[
      hrfReggeDeltaPolynomial[f, channel], channel
    ],
    \[Delta]
  ];

hrfWA16ReggeFacePinchRow[
    fsl_, vars_List, face_List, selectedPoints_List] := Module[
  {derivatives, signRejectedQ, combinationCertificate, normalizationRule,
   normalizationVariable, solveVars, solveDerivatives, instance, status},
  derivatives = DeleteCases[Expand[D[fsl, #]] & /@ vars, 0];
  signRejectedQ = AnyTrue[
    derivatives,
    hrfWA16SignDefinitePositivePolynomialQ[#, vars] &
  ];
  If[signRejectedQ,
    Return[<|
      "FaceVertexIndices" -> face,
      "FacePointCount" -> Length[face],
      "FSL" -> fsl,
      "DerivativeCount" -> Length[derivatives],
      "Status" -> "RejectedBySignDefiniteDerivative",
      "PositivePinchQ" -> False
    |>]
  ];
  combinationCertificate = hrfWA16PositiveLogDerivativeCombination[
    fsl, vars, vars
  ];
  If[AssociationQ[combinationCertificate],
    Return[<|
      "FaceVertexIndices" -> face,
      "FacePointCount" -> Length[face],
      "FSL" -> fsl,
      "DerivativeCount" -> Length[derivatives],
      "Status" -> "RejectedByPositiveDerivativeCombination",
      "PositivePinchQ" -> False,
      "DerivativeCombinationCertificate" -> combinationCertificate
    |>]
  ];
  If[derivatives === {},
    Return[<|
      "FaceVertexIndices" -> face,
      "FacePointCount" -> Length[face],
      "FSL" -> fsl,
      "DerivativeCount" -> 0,
      "Status" -> "AllDerivativesZero",
      "PositivePinchQ" -> True,
      "PinchWitness" -> "Every positive point"
    |>]
  ];
  normalizationVariable = First @ Select[vars, ! FreeQ[fsl, #] &];
  normalizationRule = normalizationVariable -> 1;
  solveVars = DeleteCases[vars, normalizationVariable];
  solveDerivatives = DeleteCases[
    Expand[# /. normalizationRule] & /@ derivatives,
    0
  ];
  instance = TimeConstrained[
    Quiet @ Check[
      FindInstance[
        And[
          And @@ Thread[solveDerivatives == 0],
          And @@ Thread[solveVars > 0]
        ],
        solveVars,
        Reals
      ],
      $Failed
    ],
    $HRFWA16ReggePinchFindInstanceTimeLimit,
    $TimedOut
  ];
  status = Which[
    instance === {}, "NoPositivePinch",
    instance === $TimedOut, "PinchSolveTimedOut",
    instance === $Failed, "PinchSolveFailed",
    ListQ[instance], "PositivePinch",
    True, "UnexpectedPinchSolveResult"
  ];
  <|
    "FaceVertexIndices" -> face,
    "FacePointCount" -> Length[face],
    "FSL" -> fsl,
    "DerivativeCount" -> Length[derivatives],
    "Status" -> status,
    "PositivePinchQ" -> Which[
      status === "PositivePinch", True,
      status === "NoPositivePinch", False,
      True, Missing["Unresolved"]
    ],
    "PinchWitness" -> If[
      status === "PositivePinch",
      Prepend[First[instance], normalizationRule],
      Missing["None"]
    ]
  |>
];

hrfWA16ReggeInteriorAudit[rec_Association, channel_String] := Module[
  {vars, fWide, f0, u, layers, points, cdd, process, parsed, faces,
   selectedPoints, rows, factorList, nontrivialFactors},
  vars = rec["Vars"];
  fWide = rec["F0"];
  f0 = Expand[hrfWA16ReggeLeadingPolynomial[fWide, channel]];
  u = Expand[rec["U"]];
  layers = hrfWA16ReggeLayers[fWide, channel];
  If[MissingQ[f0] || TrueQ[f0 === 0],
    Return[<|
      "ID" -> rec["ID"], "Channel" -> channel,
      "Status" -> "TrivialReggeLeadingPolynomial",
      "HiddenRegionQ" -> False,
      "PositivePinchFaceCount" -> 0,
      "UnresolvedFaceCount" -> 0
    |>]
  ];
  factorList = Quiet @ Check[FactorList[f0], $Failed];
  nontrivialFactors = If[ListQ[factorList],
    Select[
      Rest[factorList],
      Length[MonomialList[First[#], vars]] > 1 &
    ],
    Missing["FactorizationFailed"]
  ];
  If[hrfWA16SignDefinitePositivePolynomialQ[f0, vars],
    Return[<|
      "ID" -> rec["ID"], "Channel" -> channel,
      "Status" -> "Complete",
      "Certificate" -> "GlobalSubtractionFreeReggeF0",
      "HiddenRegionQ" -> False,
      "ReggeF0TermCount" -> Length[hrfWA16PolyTerms[f0]],
      "ReggeDeltaLayerTermCounts" -> Map[Length[hrfWA16PolyTerms[#]] &, layers],
      "NontrivialFactorCount" -> If[ListQ[nontrivialFactors],
        Length[nontrivialFactors], Missing["NotAvailable"]],
      "PositivePinchFaceCount" -> 0,
      "UnresolvedFaceCount" -> 0,
      "PositiveOrUnresolvedFaces" -> {}
    |>]
  ];
  points = DeleteDuplicates[
    hrfWA16TermXRow[#, vars] & /@ hrfWA16PolyTerms[f0]
  ];
  If[! FileExistsQ[$HRFWA16CDDExecutable],
    Return[<|
      "ID" -> rec["ID"], "Channel" -> channel,
      "Status" -> "CDDExecutableMissing",
      "HiddenRegionQ" -> Missing["Unresolved"]
    |>]
  ];
  cdd = hrfWA16CDDInput[points];
  process = RunProcess[{$HRFWA16CDDExecutable, "--repall"}, All, cdd];
  If[Lookup[process, "ExitCode", 1] =!= 0,
    Return[<|
      "ID" -> rec["ID"], "Channel" -> channel,
      "Status" -> "CDDFailed",
      "CDDStandardError" -> Lookup[process, "StandardError", ""],
      "HiddenRegionQ" -> Missing["Unresolved"]
    |>]
  ];
  parsed = hrfWA16ParseFacetIncidences[Lookup[process, "StandardOutput", ""]];
  If[! AssociationQ[parsed],
    Return[<|
      "ID" -> rec["ID"], "Channel" -> channel,
      "Status" -> parsed,
      "HiddenRegionQ" -> Missing["Unresolved"]
    |>]
  ];
  faces = hrfWA16EnumerateFaceVertexSets[
    parsed["VertexCount"], parsed["FacetVertexSets"]
  ];
  rows = Table[
    selectedPoints = points[[faces[[i]]]];
    hrfWA16ReggeFacePinchRow[
      hrfWA16FaceFSL[f0, vars, selectedPoints],
      vars, faces[[i]], selectedPoints
    ],
    {i, Length[faces]}
  ];
  rows = hrfWA16FaceHierarchyRow[#, f0, u, layers, vars] & /@ rows;
  <|
    "ID" -> rec["ID"],
    "Channel" -> channel,
    "Status" -> If[
      Count[rows, r_ /; MissingQ[Lookup[r, "PositivePinchQ", Missing[]]]] > 0,
      "UnresolvedFaces",
      "Complete"
    ],
    "Method" -> "Regge-leading exact face lattice, positive pinch equations, and oriented hierarchy LP",
    "GeneratorPresentationIndependentQ" -> True,
    "CancellationFactorMonomialCap" -> Infinity,
    "ReggeF0TermCount" -> Length[hrfWA16PolyTerms[f0]],
    "ReggeF0PointCount" -> Length[points],
    "ReggeF0FacetCount" -> Length[parsed["FacetVertexSets"]],
    "FaceCount" -> Length[faces],
    "ReggeDeltaLayerTermCounts" -> Map[Length[hrfWA16PolyTerms[#]] &, layers],
    "NontrivialFactorCount" -> If[ListQ[nontrivialFactors],
      Length[nontrivialFactors], Missing["NotAvailable"]],
    "FaceStatusCounts" -> Counts[Lookup[rows, "Status", "Absent"]],
    "PositivePinchFaceCount" -> Count[
      rows, r_ /; TrueQ[Lookup[r, "PositivePinchQ", False]]
    ],
    "UnresolvedFaceCount" -> Count[
      rows, r_ /; MissingQ[Lookup[r, "PositivePinchQ", Missing[]]]
    ],
    "HiddenRegionQ" -> Count[
      rows, r_ /; TrueQ[Lookup[r, "PositivePinchQ", False]]
    ] > 0,
    "PositiveOrUnresolvedFaces" -> Select[
      rows,
      TrueQ[Lookup[#, "PositivePinchQ", False]] ||
        MissingQ[Lookup[#, "PositivePinchQ", Missing[]]] &
    ]
  |>
];

hrfWA16ReggeCompactSummary[rows_List] := <|
  "ScanCount" -> Length[rows],
  "StatusCounts" -> Counts[Lookup[rows, "Status", Missing["Absent"]]],
  "CertificateCounts" -> Counts[Lookup[rows, "Certificate", "FaceLatticePinch"]],
  "FaceStatusCounts" -> Merge[
    Cases[Lookup[rows, "FaceStatusCounts", <||>], _Association],
    Total
  ],
  "PositivePinchFaceCount" -> Total[Lookup[rows, "PositivePinchFaceCount", 0]],
  "UnresolvedFaceCount" -> Total[Lookup[rows, "UnresolvedFaceCount", 0]],
  "HiddenRegionGraphChannelCount" -> Count[
    rows, r_ /; TrueQ[Lookup[r, "HiddenRegionQ", False]]
  ],
  "IrreducibleReggeLeadingCount" -> Count[
    rows, r_ /; Lookup[r, "NontrivialFactorCount", Missing[]] === 1
  ]
|>;
