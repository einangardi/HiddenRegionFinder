(* ::Package:: *)
(*
  Complete generator-independent Regge audit on a fixed contraction stratum.

  The strict Regge expansion is restricted after setting the contracted
  Schwinger variables to zero.  If its nominal delta^0 coefficient vanishes,
  the first nonzero coefficient is retained with its absolute delta power q.
  The hierarchy LP then assigns U the relative power -q.  This is essential:
  rebasing F alone while leaving U at relative power zero would change the
  augmented Newton polytope.

  Every exposed face of the first nonzero Regge coefficient is tested for a
  positive projective pinch and then against the same-layer complement, U,
  and every higher Regge layer.  No cancellation-factor cap or generator
  presentation is used.
*)

ClearAll[
  hrfWA16ReggeRestrictedLayerData,
  hrfWA16ReggeHierarchyGapAudit,
  hrfWA16ReggeBoundaryFaceHierarchyRow,
  hrfWA16ReggeBoundaryAudit,
  hrfWA16ReggeBoundaryCompactSummary
];

If[Length[DownValues[hrfWA16ReggeInteriorAudit]] == 0,
  Get[FileNameJoin[{DirectoryName[$InputFileName],
    "HRF_WideAngle16ReggeInteriorAudit.wl"}]]
];

hrfWA16ReggeRestrictedLayerData[
    rec_Association, channel_String, zero_List] := Module[
  {vars, coefficients, restricted, nonzeroPowers, q, leading, higher, u},
  vars = Complement[rec["Vars"], zero];
  coefficients = Join[
    <|0 -> Expand[hrfWA16ReggeLeadingPolynomial[rec["F0"], channel]]|>,
    hrfWA16ReggeLayers[rec["F0"], channel]
  ];
  restricted = AssociationMap[
    Expand[# /. Thread[zero -> 0]] &,
    coefficients
  ];
  nonzeroPowers = Select[Keys[restricted], ! TrueQ[restricted[#] === 0] &];
  u = Expand[rec["U"] /. Thread[zero -> 0]];
  If[nonzeroPowers === {},
    Return[<|
      "Variables" -> vars,
      "U" -> u,
      "Status" -> "TrivialRestrictedReggePolynomial"
    |>]
  ];
  q = Min[nonzeroPowers];
  leading = restricted[q];
  higher = Association @ Cases[
    Sort[nonzeroPowers],
    p_ /; p > q :> (p - q) -> restricted[p]
  ];
  <|
    "Variables" -> vars,
    "U" -> u,
    "LeadingEta" -> q,
    "LeadingPolynomial" -> leading,
    "HigherRelativeLayers" -> higher,
    "AbsoluteRestrictedLayers" -> KeyTake[restricted, nonzeroPowers],
    "Status" -> "Nontrivial"
  |>
];

(* Generalization of hrfWA16HierarchyGapAudit in which U can carry a
   nonzero relative eta power.  For a leading F coefficient at absolute
   delta power q, subtracting q from all weights gives U eta=-q. *)
hrfWA16ReggeHierarchyGapAudit[
    fSL_, fObs_, u_, layers_Association, vars_List,
    leadingEta_Integer?NonNegative] := Module[
  {fslRows, ref, postRows, n, objective, matrix, rhs, sol, vec,
   gapVal, rhoVal, postGaps, active, activeCounts},
  fslRows = hrfWA16ExponentRows[fSL, vars];
  postRows = Join[
    hrfWA16WeightedExponentRows[fObs, vars, 0, "FObs"],
    hrfWA16WeightedExponentRows[u, vars, -leadingEta, "U"],
    Flatten[
      KeyValueMap[
        hrfWA16WeightedExponentRows[
          #2, vars, #1, "FDeltaRelative[" <> ToString[#1] <> "]"
        ] &,
        layers
      ],
      1
    ]
  ];
  If[fslRows === {} || postRows === {},
    Return[<|
      "HierarchyFeasibleQ" -> False,
      "HierarchyStatus" -> "EmptyRows",
      "LeadingEta" -> leadingEta,
      "FSLExponentRows" -> fslRows,
      "PostExponentRows" -> postRows
    |>]
  ];
  n = Length[vars];
  ref = First[fslRows];
  objective = Join[ConstantArray[0, n], {-1}];
  matrix = Join[
    (Join[-(# - ref), {0}] & /@ Rest[fslRows]),
    (Join[-(#[[1]] - ref), {-1}] & /@ postRows)
  ];
  rhs = Join[
    ConstantArray[{0, 0}, Max[0, Length[fslRows] - 1]],
    ({-#[[2]], 1} & /@ postRows)
  ];
  sol = Quiet @ Check[LinearProgramming[objective, matrix, rhs], $Failed];
  Which[
    sol === $Failed,
      <|
        "HierarchyFeasibleQ" -> Missing["LPFailed"],
        "HierarchyStatus" -> "LPFailed",
        "LeadingEta" -> leadingEta
      |>,
    MatchQ[sol, {Indeterminate ..}],
      <|
        "HierarchyFeasibleQ" -> True,
        "HierarchyStatus" -> "UnboundedPositiveGap",
        "MaxGap" -> Infinity,
        "Scaling" -> Missing["UnboundedWitnessNotReturned"],
        "LeadingEta" -> leadingEta
      |>,
    VectorQ[sol, NumericQ],
      vec = Rationalize[sol, 0];
      rhoVal = -Take[vec, n];
      gapVal = Rationalize[Last[vec], 0];
      postGaps = Rationalize[
        ((#[[1]] - ref).rhoVal + #[[2]]) & /@ postRows,
        0
      ];
      active = Pick[postRows, Thread[postGaps == gapVal]];
      activeCounts = Counts[active[[All, 3]]];
      <|
        "HierarchyFeasibleQ" -> TrueQ[gapVal > 0],
        "HierarchyStatus" -> If[
          TrueQ[gapVal > 0], "PositiveGap", "ZeroMaxGap"
        ],
        "MaxGap" -> gapVal,
        "Scaling" -> Thread[vars -> rhoVal],
        "LeadingEta" -> leadingEta,
        "UEtaRelativeToLeadingF" -> -leadingEta,
        "FSLWeight" -> ref.rhoVal + leadingEta,
        "FSLExponentRowCount" -> Length[fslRows],
        "PostExponentRowCount" -> Length[postRows],
        "ActivePostRowCount" -> Length[active],
        "ActivePostSourceCounts" -> activeCounts,
        "ActivePostRows" -> active
      |>,
    True,
      <|
        "HierarchyFeasibleQ" -> Missing["UnexpectedLPResult"],
        "HierarchyStatus" -> "UnexpectedLPResult",
        "LeadingEta" -> leadingEta,
        "Raw" -> sol
      |>
  ]
];

hrfWA16ReggeBoundaryFaceHierarchyRow[
    row_Association, f0_, u_, layers_Association, vars_List,
    leadingEta_Integer?NonNegative] := Module[{hierarchy, feasible, status},
  If[! TrueQ[Lookup[row, "PositivePinchQ", False]], Return[row]];
  hierarchy = hrfWA16ReggeHierarchyGapAudit[
    row["FSL"], Expand[f0 - row["FSL"]], u, layers, vars, leadingEta
  ];
  feasible = Lookup[hierarchy, "HierarchyFeasibleQ", Missing["Unresolved"]];
  status = Which[
    TrueQ[feasible], "PositivePinchAndHierarchy",
    FalseQ[feasible], "RejectedByHierarchy",
    True, "HierarchySolveUnresolved"
  ];
  Join[
    row,
    <|
      "Status" -> status,
      "PositivePinchQ" -> Which[
        TrueQ[feasible], True,
        FalseQ[feasible], False,
        True, Missing["Unresolved"]
      ],
      "HierarchyAudit" -> hierarchy
    |>
  ]
];

hrfWA16ReggeBoundaryAudit[
    rec_Association, channel_String, zero_List,
    parentInteriorNegativeCertificateQ_ : False] := Module[
  {data, vars, leadingEta, f0, u, layers, factorList, nontrivialFactors,
   points, cdd, process, parsed, faces, selectedPoints, rawRows, rows},
  data = hrfWA16ReggeRestrictedLayerData[rec, channel, zero];
  vars = data["Variables"];
  If[data["Status"] =!= "Nontrivial" || vars === {},
    Return[<|
      "ID" -> rec["ID"], "Channel" -> channel, "ZeroVars" -> zero,
      "Codimension" -> Length[zero], "ActiveVarCount" -> Length[vars],
      "Status" -> "TrivialRestrictedReggePolynomial",
      "Certificate" -> "TrivialRestrictedReggePolynomial",
      "HiddenRegionQ" -> False,
      "PositivePinchFaceCount" -> 0,
      "UnresolvedFaceCount" -> 0,
      "PositiveOrUnresolvedFaces" -> {}
    |>]
  ];
  leadingEta = data["LeadingEta"];
  f0 = data["LeadingPolynomial"];
  u = data["U"];
  layers = data["HigherRelativeLayers"];
  (* If the parent's complete first-layer face lattice contains no positive or
     unresolved pinch, every boundary with a nonzero delta^0 restriction is
     already closed.  The restriction selects the coordinate face on which
     the contracted-variable exponents vanish, and every face of a face is a
     face of the parent polytope.  Its pinch equations are identical in the
     active variables; derivatives in the absent variables vanish. *)
  If[leadingEta === 0 && TrueQ[parentInteriorNegativeCertificateQ],
    Return[<|
      "ID" -> rec["ID"], "Channel" -> channel, "ZeroVars" -> zero,
      "Codimension" -> Length[zero], "ActiveVarCount" -> Length[vars],
      "LeadingReggeEta" -> 0,
      "Status" -> "Complete",
      "Certificate" -> "InheritedParentInteriorFaceClosure",
      "HiddenRegionQ" -> False,
      "LeadingTermCount" -> Length[hrfWA16PolyTerms[f0]],
      "PositivePinchFaceCount" -> 0,
      "UnresolvedFaceCount" -> 0,
      "PositiveOrUnresolvedFaces" -> {}
    |>]
  ];
  factorList = Quiet @ Check[FactorList[f0], $Failed];
  nontrivialFactors = If[ListQ[factorList],
    Select[Rest[factorList], Length[hrfWA16PolyTerms[First[#]]] > 1 &],
    Missing["FactorizationFailed"]
  ];
  If[hrfWA16SignDefinitePositivePolynomialQ[f0, vars],
    Return[<|
      "ID" -> rec["ID"], "Channel" -> channel, "ZeroVars" -> zero,
      "Codimension" -> Length[zero], "ActiveVarCount" -> Length[vars],
      "LeadingReggeEta" -> leadingEta,
      "Status" -> "Complete",
      "Certificate" -> "GlobalSubtractionFreeFirstNonzeroReggeLayer",
      "HiddenRegionQ" -> False,
      "LeadingTermCount" -> Length[hrfWA16PolyTerms[f0]],
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
      "ID" -> rec["ID"], "Channel" -> channel, "ZeroVars" -> zero,
      "Status" -> "CDDExecutableMissing",
      "HiddenRegionQ" -> Missing["Unresolved"]
    |>]
  ];
  cdd = hrfWA16CDDInput[points];
  process = RunProcess[{$HRFWA16CDDExecutable, "--repall"}, All, cdd];
  If[Lookup[process, "ExitCode", 1] =!= 0,
    Return[<|
      "ID" -> rec["ID"], "Channel" -> channel, "ZeroVars" -> zero,
      "Status" -> "CDDFailed",
      "CDDStandardError" -> Lookup[process, "StandardError", ""],
      "HiddenRegionQ" -> Missing["Unresolved"]
    |>]
  ];
  parsed = hrfWA16ParseFacetIncidences[Lookup[process, "StandardOutput", ""]];
  If[! AssociationQ[parsed],
    Return[<|
      "ID" -> rec["ID"], "Channel" -> channel, "ZeroVars" -> zero,
      "Status" -> parsed,
      "HiddenRegionQ" -> Missing["Unresolved"]
    |>]
  ];
  faces = hrfWA16EnumerateFaceVertexSets[
    parsed["VertexCount"], parsed["FacetVertexSets"]
  ];
  rawRows = Table[
    selectedPoints = points[[faces[[i]]]];
    hrfWA16ReggeFacePinchRow[
      hrfWA16FaceFSL[f0, vars, selectedPoints],
      vars, faces[[i]], selectedPoints
    ],
    {i, Length[faces]}
  ];
  rows = hrfWA16ReggeBoundaryFaceHierarchyRow[
      #, f0, u, layers, vars, leadingEta
    ] & /@ rawRows;
  <|
    "ID" -> rec["ID"], "Channel" -> channel, "ZeroVars" -> zero,
    "Codimension" -> Length[zero], "ActiveVarCount" -> Length[vars],
    "LeadingReggeEta" -> leadingEta,
    "UEtaRelativeToLeadingF" -> -leadingEta,
    "Status" -> If[
      Count[rows, r_ /; MissingQ[Lookup[r, "PositivePinchQ", Missing[]]]] > 0,
      "UnresolvedFaces", "Complete"
    ],
    "Method" -> "restricted first-nonzero Regge layer, exact face lattice, positive pinch equations, and absolute-eta hierarchy LP",
    "GeneratorPresentationIndependentQ" -> True,
    "CancellationFactorMonomialCap" -> Infinity,
    "LeadingTermCount" -> Length[hrfWA16PolyTerms[f0]],
    "LeadingPointCount" -> Length[points],
    "LeadingFacetCount" -> Length[parsed["FacetVertexSets"]],
    "FaceCount" -> Length[faces],
    "HigherRelativeLayerTermCounts" -> Map[
      Length[hrfWA16PolyTerms[#]] &, layers
    ],
    "NontrivialFactorCount" -> If[
      ListQ[nontrivialFactors], Length[nontrivialFactors],
      Missing["NotAvailable"]
    ],
    "RawPositivePinchFaceCount" -> Count[
      rawRows, r_ /; TrueQ[Lookup[r, "PositivePinchQ", False]]
    ],
    "FaceStatusCounts" -> Counts[Lookup[rows, "Status", "Absent"]],
    "PositivePinchFaceCount" -> Count[
      rows, r_ /; TrueQ[Lookup[r, "PositivePinchQ", False]]
    ],
    "UnresolvedFaceCount" -> Count[
      rows, r_ /; MissingQ[Lookup[r, "PositivePinchQ", Missing[]]]
    ],
    "HiddenRegionQ" -> AnyTrue[
      rows, TrueQ[Lookup[#, "PositivePinchQ", False]] &
    ],
    "RepresentativeDerivativeCombinationFaces" -> Take[
      Select[
        rows,
        Lookup[#, "Status", ""] ===
          "RejectedByPositiveDerivativeCombination" &
      ],
      UpTo[3]
    ],
    "PositiveOrUnresolvedFaces" -> Select[
      rows,
      TrueQ[Lookup[#, "PositivePinchQ", False]] ||
        MissingQ[Lookup[#, "PositivePinchQ", Missing[]]] &
    ]
  |>
];

hrfWA16ReggeBoundaryCompactSummary[rows_List] := <|
  "ScanCount" -> Length[rows],
  "StatusCounts" -> Counts[Lookup[rows, "Status", Missing["Absent"]]],
  "CertificateCounts" -> Counts[
    Lookup[rows, "Certificate", "FaceLatticePinch"]
  ],
  "LeadingReggeEtaCounts" -> Counts[
    Lookup[rows, "LeadingReggeEta", Missing["Trivial"]]
  ],
  "FaceStatusCounts" -> Merge[
    Cases[Lookup[rows, "FaceStatusCounts", <||>], _Association], Total
  ],
  "FaceCount" -> Total[Lookup[rows, "FaceCount", 0]],
  "RawPositivePinchFaceCount" -> Total[
    Lookup[rows, "RawPositivePinchFaceCount", 0]
  ],
  "PositivePinchFaceCount" -> Total[
    Lookup[rows, "PositivePinchFaceCount", 0]
  ],
  "UnresolvedFaceCount" -> Total[Lookup[rows, "UnresolvedFaceCount", 0]],
  "HiddenRegionStratumCount" -> Count[
    rows, r_ /; TrueQ[Lookup[r, "HiddenRegionQ", False]]
  ]
|>;
