(* ::Package:: *)
(*
  Complete generator-independent audit of the necessary HRF hierarchy and
  pinch conditions for a fixed contraction stratum.  Failure on every face
  is therefore a complete negative certificate; a surviving face would still
  require the remaining HRF construction before being called an HR.

  Equation (14) implies that the x-exponent support of F_SL is an exposed face
  of the F0 Newton polytope.  We enumerate that complete (and much smaller)
  face lattice from exact cddlib facet incidences and test equation (13)
  directly on every corresponding F_SL polynomial.  Every positive pinch is
  finally required by equation (17) to pass the oriented (rho;1) hierarchy LP
  against F0-F_SL, U, and all restored-delta layers.  This final test is
  equivalent to asking that the F0 face extend to the required pure lower face
  of the augmented LP polytope, without enumerating all augmented faces.

  This audit does not assume a cancellation-factor term cap, a generator
  presentation, or a Crown minor.
*)

ClearAll[
  hrfWA16PolyTerms, hrfWA16TermXRow, hrfWA16TaggedAugmentedPoints,
  hrfWA16CDDInput, hrfWA16ParseFacetIncidences,
  hrfWA16EnumerateFaceVertexSets, hrfWA16PureF0FaceSets,
  hrfWA16PhysicalChannelPolynomial, hrfWA16SignDefinitePositivePolynomialQ,
  hrfWA16PositiveLogDerivativeCombination,
  hrfWA16FaceFSL, hrfWA16FacePinchRow, hrfWA16FaceHierarchyRow,
  hrfWA16FacePinchAudit
];

If[Length[DownValues[hrfWA16HierarchyGapAudit]] == 0,
  Get[FileNameJoin[{DirectoryName[$InputFileName],
    "HRF_WideAngle16HierarchyGapAudit.wl"}]]
];

If[! ValueQ[$HRFWA16CDDExecutable],
  $HRFWA16CDDExecutable = With[
    {exe = Quiet @ Check[FindExecutable["cddexec"], $Failed]},
    If[StringQ[exe], exe, "/usr/local/bin/cddexec"]
  ]
];
If[! ValueQ[$HRFWA16FacePinchFindInstanceTimeLimit],
  $HRFWA16FacePinchFindInstanceTimeLimit = 10
];

hrfWA16PolyTerms[p_] := Which[
  TrueQ[Expand[p] === 0], {},
  Head[Expand[p]] === Plus, List @@ Expand[p],
  True, {Expand[p]}
];

hrfWA16TermXRow[t_, vars_List] := hrfExponentListInVars[t, vars];

hrfWA16TaggedAugmentedPoints[
    f0_, u_, layers_Association, vars_List] := Module[
  {tagged, addTerms},
  addTerms[p_, eta_, source_] :=
    ({Append[hrfWA16TermXRow[#, vars], eta], source} & /@
      hrfWA16PolyTerms[p]);
  tagged = Join[
    addTerms[f0, 0, "F0"],
    addTerms[u, 0, "U"],
    Flatten[
      KeyValueMap[addTerms[#2, #1, "FDelta[" <> ToString[#1] <> "]"] &, layers],
      1
    ]
  ];
  tagged
];

hrfWA16CDDInput[points_List] := Module[{rows},
  rows = StringRiffle[
    StringRiffle[ToString /@ Prepend[#, 1], " "] & /@ points,
    "\n"
  ];
  "V-representation\nbegin\n" <>
    ToString[Length[points]] <> " " <>
    ToString[Length[First[points]] + 1] <> " rational\n" <>
    rows <> "\nend\n"
];

hrfWA16ParseFacetIncidences[text_String] := Module[
  {lines, marker, begin, header, vertexCount, out = {}, i, parts, left,
   signedCount, listed},
  lines = StringSplit[text, {"\r\n", "\n", "\r"}];
  marker = FirstPosition[lines, "Facet incidence", Missing["Absent"]];
  If[MissingQ[marker], Return[Missing["NoFacetIncidence"]]];
  begin = SelectFirst[
    Range[First[marker] + 1, Length[lines]],
    StringTrim[lines[[#]]] === "begin" &,
    Missing["NoIncidenceBegin"]
  ];
  If[MissingQ[begin] || begin + 1 > Length[lines],
    Return[Missing["MalformedFacetIncidence"]]
  ];
  header = ToExpression /@ StringSplit[StringTrim[lines[[begin + 1]]]];
  If[Length[header] < 2, Return[Missing["MalformedIncidenceHeader"]]];
  vertexCount = header[[2]];
  i = begin + 2;
  While[i <= Length[lines] && StringTrim[lines[[i]]] =!= "end",
    parts = StringSplit[lines[[i]], ":"];
    If[Length[parts] === 2,
      left = ToExpression /@ StringSplit[StringTrim[parts[[1]]]];
      signedCount = left[[2]];
      listed = If[StringTrim[parts[[2]]] === "", {},
        ToExpression /@ StringSplit[StringTrim[parts[[2]]]]
      ];
      AppendTo[out,
        If[signedCount >= 0, listed, Complement[Range[vertexCount], listed]]
      ];
    ];
    i++
  ];
  <|"VertexCount" -> vertexCount, "FacetVertexSets" -> out|>
];

hrfWA16EnumerateFaceVertexSets[
    vertexCount_Integer, facetSets_List] := Module[
  {faces = <||>, current, intersections, key},
  key[x_List] := StringRiffle[ToString /@ x, ","];
  faces[key[Range[vertexCount]]] = Range[vertexCount];
  Do[
    current = Values[faces];
    intersections = DeleteCases[
      DeleteDuplicates[Intersection[#, facet] & /@ current],
      {}
    ];
    Do[faces[key[face]] = face, {face, intersections}],
    {facet, facetSets}
  ];
  Values[faces]
];

hrfWA16PureF0FaceSets[
    faces_List, pointSources_List] := Select[
  faces,
  Function[face,
    face =!= {} && AllTrue[
      face,
      Function[i,
        TrueQ[Lookup[pointSources[[i]], "F0", False]] &&
          Sort[Keys[pointSources[[i]]]] === {"F0"}
      ]
    ]
  ]
];

hrfWA16PhysicalChannelPolynomial[p_] :=
  Expand[p /. {s12 -> hrfWA16A + hrfWA16B, s23 -> -hrfWA16A}];

hrfWA16SignDefinitePositivePolynomialQ[p_, positiveVars_List] := Module[{c},
  If[TrueQ[Expand[p] === 0], Return[False]];
  c = Last /@ CoefficientRules[Expand[p], positiveVars];
  c =!= {} &&
    (And @@ (TrueQ[# >= 0] & /@ c) || And @@ (TrueQ[# <= 0] & /@ c))
];

(* Exact Farkas-type no-pinch certificate.  At a simultaneous pinch every
   logarithmic derivative x_i d_i F vanishes.  If a constant real linear
   combination of those derivatives is a nonzero polynomial with coefficients
   of one sign in the positive variables, it is strictly nonzero throughout
   the physical orthant and gives an immediate contradiction. *)
hrfWA16PositiveLogDerivativeCombination[
    physical_, vars_List, positiveVars_List] := Module[
  {logDerivatives, ruleLists, exponentKeys, matrix, c, solve, witness,
   coefficientVector, trySign},
  logDerivatives = DeleteCases[
    MapThread[Expand[#1 D[physical, #1]] &, {vars}],
    0
  ];
  If[logDerivatives === {}, Return[Missing["NoCertificate"]]];
  ruleLists = CoefficientRules[#, positiveVars] & /@ logDerivatives;
  exponentKeys = DeleteDuplicates @ Flatten[First /@ # & /@ ruleLists, 1];
  If[exponentKeys === {}, Return[Missing["NoCertificate"]]];
  matrix = Transpose @ (
    Lookup[Association[#], exponentKeys, 0] & /@ ruleLists
  );
  c = Array[hrfWA16DerivativeCombinationCoefficient, Length[logDerivatives]];
  trySign[sign_] := Quiet @ Check[
    FindInstance[
      And[
        And @@ Thread[sign matrix.c >= 0],
        sign Total[matrix.c] >= 1
      ],
      c,
      Reals
    ],
    $Failed
  ];
  solve = trySign[1];
  If[solve === {} || solve === $Failed, solve = trySign[-1]];
  If[! ListQ[solve] || solve === {}, Return[Missing["NoCertificate"]]];
  witness = First[solve];
  coefficientVector = Expand[matrix.(c /. witness)];
  <|
    "CombinationCoefficients" -> (c /. witness),
    "CoefficientVector" -> coefficientVector,
    "CombinationPolynomial" -> Expand[Total[(c /. witness) logDerivatives]]
  |>
];

hrfWA16FaceFSL[
    f0_, vars_List, selectedPoints_List] := Module[{terms},
  terms = hrfWA16PolyTerms[f0];
  Expand @ Total @ Select[
    terms,
    MemberQ[selectedPoints, hrfWA16TermXRow[#, vars]] &
  ]
];

hrfWA16FacePinchRow[
    fsl_, vars_List, face_List, selectedPoints_List] := Module[
  {physical, derivatives, positiveVars, signRejectedQ, combinationCertificate,
   normalizationRules, solveVars, solveDerivatives, instance, status},
  physical = hrfWA16PhysicalChannelPolynomial[fsl];
  derivatives = DeleteCases[Expand[D[physical, #]] & /@ vars, 0];
  positiveVars = Join[vars, {hrfWA16A, hrfWA16B}];
  signRejectedQ = AnyTrue[
    derivatives,
    hrfWA16SignDefinitePositivePolynomialQ[#, positiveVars] &
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
    physical, vars, positiveVars
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
  (* The pinch equations are homogeneous under one common rescaling of all
     Schwinger variables and under one common rescaling of the two Mandelstam
     coordinates.  Fix one positive representative of each orbit.  This does
     not remove a positive solution and avoids asking FindInstance to resolve
     two exact flat directions. *)
  normalizationRules = {First[vars] -> 1, hrfWA16A -> 1};
  solveVars = Complement[positiveVars, First /@ normalizationRules];
  solveDerivatives = DeleteCases[
    Expand[# /. normalizationRules] & /@ derivatives,
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
    $HRFWA16FacePinchFindInstanceTimeLimit,
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
      Join[normalizationRules, First[instance]],
      Missing["None"]
    ]
  |>
];

hrfWA16FaceHierarchyRow[
    row_Association, f0_, u_, layers_Association, vars_List] := Module[
  {hierarchy, status, feasible},
  If[! TrueQ[Lookup[row, "PositivePinchQ", False]], Return[row]];
  hierarchy = hrfWA16HierarchyGapAudit[
    row["FSL"], Expand[f0 - row["FSL"]], u, layers, vars
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

hrfWA16FacePinchAudit[rec_Association, zero_List : {}] := Module[
  {vars, f0, u, full, layers, points, physicalF0, positiveVars, cdd,
   process, parsed, faces, rows,
   selectedPoints},
  vars = Complement[rec["Vars"], zero];
  f0 = Expand[rec["F0"] /. Thread[zero -> 0]];
  u = Expand[rec["U"] /. Thread[zero -> 0]];
  full = Expand[rec["Data"]["FOnShell"] /. Thread[zero -> 0]];
  layers = hrfDeltaLayerAssociation[full, \[Delta]];
  If[f0 === 0 || vars === {},
    Return[<|
      "ID" -> rec["ID"], "ZeroVars" -> zero,
      "Status" -> "TrivialRestrictedPolynomial",
      "Certificate" -> "TrivialRestrictedPolynomial",
      "HiddenRegionQ" -> False,
      "PositivePinchFaceCount" -> 0,
      "UnresolvedFaceCount" -> 0,
      "PositiveOrUnresolvedFaces" -> {}
    |>]
  ];
  (* If the complete restricted F0 is subtraction-free (up to one overall
     sign) in positive physical-channel coordinates, then every nonempty
     subset of its x-monomials is likewise subtraction-free.  Since F0 is
     homogeneous of positive x-degree, every such subset has a nonzero,
     sign-definite x derivative.  Thus no pure-F0 face can satisfy the pinch
     equations, and the full face lattice need not be constructed. *)
  physicalF0 = hrfWA16PhysicalChannelPolynomial[f0];
  positiveVars = Join[vars, {hrfWA16A, hrfWA16B}];
  If[hrfWA16SignDefinitePositivePolynomialQ[physicalF0, positiveVars],
    Return[<|
      "ID" -> rec["ID"], "ZeroVars" -> zero,
      "ActiveVarCount" -> Length[vars],
      "Status" -> "Complete",
      "Certificate" -> "GlobalSubtractionFreeF0",
      "HiddenRegionQ" -> False,
      "PositivePinchFaceCount" -> 0,
      "UnresolvedFaceCount" -> 0,
      "PositiveOrUnresolvedFaces" -> {}
    |>]
  ];
  points = DeleteDuplicates[
    hrfWA16TermXRow[#, vars] & /@ hrfWA16PolyTerms[f0]
  ];
  cdd = hrfWA16CDDInput[points];
  If[! FileExistsQ[$HRFWA16CDDExecutable],
    Return[<|
      "ID" -> rec["ID"], "ZeroVars" -> zero,
      "Status" -> "CDDExecutableMissing", "HiddenRegionQ" -> Missing["Unresolved"]
    |>]
  ];
  process = RunProcess[
    {$HRFWA16CDDExecutable, "--repall"},
    All,
    cdd
  ];
  If[Lookup[process, "ExitCode", 1] =!= 0,
    Return[<|
      "ID" -> rec["ID"], "ZeroVars" -> zero,
      "Status" -> "CDDFailed", "CDDStandardError" -> Lookup[process, "StandardError", ""],
      "HiddenRegionQ" -> Missing["Unresolved"]
    |>]
  ];
  parsed = hrfWA16ParseFacetIncidences[Lookup[process, "StandardOutput", ""]];
  If[! AssociationQ[parsed],
    Return[<|
      "ID" -> rec["ID"], "ZeroVars" -> zero,
      "Status" -> parsed, "HiddenRegionQ" -> Missing["Unresolved"]
    |>]
  ];
  faces = hrfWA16EnumerateFaceVertexSets[
    parsed["VertexCount"], parsed["FacetVertexSets"]
  ];
  rows = Table[
    selectedPoints = points[[faces[[i]]]];
    hrfWA16FacePinchRow[
      hrfWA16FaceFSL[f0, vars, selectedPoints],
      vars, faces[[i]], selectedPoints
    ],
    {i, Length[faces]}
  ];
  rows = hrfWA16FaceHierarchyRow[#, f0, u, layers, vars] & /@ rows;
  <|
    "ID" -> rec["ID"],
    "ZeroVars" -> zero,
    "ActiveVarCount" -> Length[vars],
    "F0PointCount" -> Length[points],
    "F0FacetCount" -> Length[parsed["FacetVertexSets"]],
    "FaceCount" -> Length[faces],
    "PureF0FaceCount" -> Length[faces],
    "FaceStatusCounts" -> Counts[Lookup[rows, "Status", "Absent"]],
    "PositivePinchFaceCount" -> Count[
      rows, r_ /; TrueQ[Lookup[r, "PositivePinchQ", False]]
    ],
    "UnresolvedFaceCount" -> Count[
      rows, r_ /; MissingQ[Lookup[r, "PositivePinchQ", Missing[]]]
    ],
    "Status" -> If[
      Count[rows, r_ /; MissingQ[Lookup[r, "PositivePinchQ", Missing[]]]] > 0,
      "UnresolvedFaces",
      "Complete"
    ],
    "HiddenRegionQ" -> Count[
      rows, r_ /; TrueQ[Lookup[r, "PositivePinchQ", False]]
    ] > 0,
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
