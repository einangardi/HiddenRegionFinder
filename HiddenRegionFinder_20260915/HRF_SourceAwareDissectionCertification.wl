(* Source-aware dissection and lower-facet certification.

   Candidate discovery is performed in the original LP variables, possibly
   after an asymptotic-order alignment.  This module performs the logically
   separate certification step.  It works in the aligned coordinates, maps
   independent cancellation factors to signed endpoint variables, preserves
   the decomposition into F_SL, F_obs, other F layers and U, enumerates exact
   lower facets with cddlib, and pulls every admissible facet normal back to
   the original LP variables.

   In particular, F_SL is never promoted to the resolved layer by hand.  Its
   first nonzero local weight is measured from the transformed polynomial.
   The output therefore distinguishes

     ResolvedFSLWeight == ResolvedLeadingWeight

   from a genuinely deeper cancellation in which F_SL is subleading. *)

ClearAll[
  hrfSADPolynomialTerms,
  hrfSADMonomialQ,
  hrfSADRowKey,
  hrfSADAlignPolynomial,
  hrfSADOutsidePolynomial,
  hrfSADPivotChoices,
  hrfSADValuation,
  hrfSADCoefficientMap,
  hrfSADCombineCoefficientMaps,
  hrfSADCDDInput,
  hrfSADParseFacetIncidences,
  hrfSADFacetFromIncidence,
  hrfSADFixedNormalAudit,
  hrfSADPullbackWeights,
  hrfSADSourceFacetData,
  hrfSADDissectChart,
  hrfSourceAwareDissectionCertificate,
  hrfSourceAwareAlignedDissectionCertificate
];

Options[hrfSourceAwareAlignedDissectionCertificate] = {
  "CDDExecutable" -> Automatic,
  "MaxPivotChoices" -> 8,
  "MaxSolveBranches" -> 4,
  "MaxSignSectors" -> 64,
  "MaxPointCount" -> 5000,
  "SolveTimeLimit" -> 20,
  "CDDTimeLimit" -> 30,
  "RequirePositiveTransverseSuppressionQ" -> True
};

Options[hrfSourceAwareDissectionCertificate] = Join[
  Options[hrfSourceAwareAlignedDissectionCertificate],
  {
    "BaseScaling" -> Automatic,
    "BaseWeight" -> 0
  }
];

hrfSADPolynomialTerms[p_] := Module[{q = Expand[p]},
  Which[
    TrueQ[q === 0], {},
    Head[q] === Plus, List @@ q,
    True, {q}
  ]
];

hrfSADMonomialQ[p_, vars_List] := Module[{rules},
  If[TrueQ[Expand[p] === 0], Return[False]];
  rules = Quiet @ Check[CoefficientRules[Expand[p], vars], $Failed];
  ListQ[rules] && Length[rules] == 1
];

hrfSADRowKey[row_List] := StringRiffle[ToString /@ row, ","];

(* Pull a polynomial through x_i -> eta^phi_i x_i and remove the common
   alignment weight.  The coefficient algebra is kept exact. *)
hrfSADAlignPolynomial[p_, vars_List, phi_List, faceWeight_, eta_] := Module[
  {rules},
  rules = CoefficientRules[Expand[p], vars];
  Total @ Map[
    Function[rule,
      Last[rule] Times @@ MapThread[Power, {vars, First[rule]}]
        eta^(First[rule].phi - faceWeight)
    ],
    rules
  ]
];

hrfSADOutsidePolynomial[
    data_List, activePositions_List, zeroPositions_List, phi_List,
    faceWeight_, zeroVars_List, eta_] := Module[{surviving},
  surviving = Select[
    data,
    zeroPositions === {} || Total[Lookup[#, "XRow"][[zeroPositions]]] == 0 &
  ];
  Total @ Map[
    Function[term,
      (Lookup[term, "CoeffNoEta", 0] /. Thread[zeroVars -> 0])
        eta^(Lookup[term, "EtaPower", 0] +
          Lookup[term, "XRow"][[activePositions]].phi - faceWeight)
    ],
    surviving
  ]
];

(* A factor need not be globally linear.  It is sufficient that the selected
   pivot can be solved rationally.  The pivot enumeration is deliberately
   separated from Solve so failed or algebraic branches remain unresolved. *)
hrfSADPivotChoices[factors_List, vars_List] := Module[{supports},
  supports = Map[
    Function[factor,
      Select[vars, Function[var, ! FreeQ[factor, var]]]
    ],
    factors
  ];
  If[MemberQ[supports, {}], {}, Select[Tuples[supports], DuplicateFreeQ]]
];

(* Exact valuation of a rational function.  Denominators depending on the
   local variables are allowed here; the chart construction separately
   requires their common product to be a monomial so that clearing it only
   translates the Newton support. *)
hrfSADValuation[p_, vars_List, weights_List] := Module[
  {q, numerator, denominator, nRules, dRules},
  q = Cancel[Together[p]];
  numerator = Expand[Numerator[q]];
  denominator = Expand[Denominator[q]];
  nRules = CoefficientRules[numerator, vars];
  dRules = CoefficientRules[denominator, vars];
  If[nRules === {} || dRules === {}, Return[Missing["EmptyValuationSupport"]]];
  Min[(First[#].weights) & /@ nRules] -
    Min[(First[#].weights) & /@ dRules]
];

hrfSADCoefficientMap[p_, vars_List] := Module[{rules},
  rules = Quiet @ Check[CoefficientRules[Expand[p], vars], $Failed];
  If[! ListQ[rules], Return[Missing["NonPolynomialAfterClearing"]]];
  Association @ Map[
    hrfSADRowKey[First[#]] -> Together[Last[#]] &,
    rules
  ]
];

hrfSADCombineCoefficientMaps[maps_Association] := Module[
  {keys, rows, sourceCoefficients, total},
  If[AnyTrue[Values[maps], MissingQ], Return[Missing["CoefficientMapFailure"]]];
  keys = Union @@ (Keys /@ Values[maps]);
  DeleteCases[
    Map[
      Function[key,
        rows = ToExpression /@ StringSplit[key, ","];
        sourceCoefficients = Association @ KeyValueMap[
          #1 -> Lookup[#2, key, 0] &,
          maps
        ];
        total = Together[Total[Values[sourceCoefficients]]];
        If[TrueQ[total === 0], Nothing,
          <|
            "Row" -> rows,
            "Coefficient" -> total,
            "SourceCoefficients" -> Select[sourceCoefficients, ! TrueQ[# === 0] &],
            "Sources" -> Keys @ Select[sourceCoefficients, ! TrueQ[# === 0] &]
          |>
        ]
      ],
      keys
    ],
    Nothing
  ]
];

hrfSADCDDInput[points_List] := Module[{rows},
  rows = StringRiffle[
    StringRiffle[ToString /@ Prepend[#, 1], " "] & /@ points,
    "\n"
  ];
  "V-representation\nbegin\n" <>
    ToString[Length[points]] <> " " <>
    ToString[Length[First[points]] + 1] <> " rational\n" <>
    rows <> "\nend\n"
];

hrfSADParseFacetIncidences[text_String] := Module[
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

hrfSADFacetFromIncidence[points_List, incidence_List] := Module[
  {rows, differences, rank, normalSpace, normal, oriented, normalized,
   weights, facetWeight, actualIncidence, lowerQ, requiredRank,
   monomialRows, monomialDifferences, monomialNullSpace},
  rows = points[[incidence]];
  requiredRank = Length[First[points]] - 1;
  differences = If[Length[rows] <= 1, {}, (# - First[rows]) & /@ Rest[rows]];
  rank = If[differences === {}, 0, MatrixRank[differences]];
  normalSpace = If[differences === {}, {}, NullSpace[differences]];
  If[rank =!= requiredRank || Length[normalSpace] =!= 1,
    Return[Missing["NonFacetIncidence"]]
  ];
  normal = First[normalSpace];
  oriented = If[Last[normal] < 0, -normal, normal];
  If[! TrueQ[Last[oriented] > 0], Return[Missing["NotLowerOriented"]]];
  normalized = Together[oriented/Last[oriented]];
  weights = Together /@ (points.normalized);
  facetWeight = Min[weights];
  actualIncidence = Flatten @ Position[weights, facetWeight];
  lowerQ = Sort[actualIncidence] === Sort[incidence];
  If[! lowerQ, Return[Missing["NotLowerFacet"]]];
  monomialRows = Most /@ rows;
  monomialDifferences = If[Length[monomialRows] <= 1, {},
    (# - First[monomialRows]) & /@ Rest[monomialRows]
  ];
  monomialNullSpace = If[monomialDifferences === {},
    IdentityMatrix[Length[First[monomialRows]]],
    NullSpace[monomialDifferences]
  ];
  <|
    "LowerFacetQ" -> True,
    "FacetIndices" -> actualIncidence,
    "LeadingWeight" -> facetWeight,
    "LeadingPointCount" -> Length[actualIncidence],
    "LeadingAugmentedRows" -> rows,
    "LeadingAffineRank" -> rank,
    "RequiredFacetRank" -> requiredRank,
    "NormalizedInwardNormal" -> normalized,
    "FacetNormalNullSpace" -> normalSpace,
    "MonomialRescalingNullSpace" -> monomialNullSpace,
    "ResidualMonomialRescalingQ" -> (monomialNullSpace =!= {})
  |>
];

hrfSADFixedNormalAudit[points_List, normal_List] := Module[
  {weights, leadingWeight, leading, differences, rank, normalSpace,
   normalized, requiredRank},
  If[points === {}, Return[<|"LowerFacetQ" -> False, "Reason" -> "EmptySupport"|>]];
  requiredRank = Length[First[points]] - 1;
  weights = Together /@ (points.normal);
  leadingWeight = Min[weights];
  leading = DeleteDuplicates @ Pick[points, weights, leadingWeight];
  differences = If[Length[leading] <= 1, {}, (# - First[leading]) & /@ Rest[leading]];
  rank = If[differences === {}, 0, MatrixRank[differences]];
  normalSpace = If[differences === {}, {}, NullSpace[differences]];
  normalized = If[Length[normalSpace] == 1,
    With[{n = First[normalSpace]},
      If[Last[n] == 0, Missing["ZeroEtaNormal"],
        Together[If[Last[n] < 0, -n, n]/Abs[Last[n]]]
      ]
    ],
    Missing["NonUniqueNormal"]
  ];
  <|
    "LowerFacetQ" -> TrueQ[
      rank == requiredRank && ListQ[normalized] &&
      And @@ Thread[Together[normalized - normal] == 0]
    ],
    "LeadingWeight" -> leadingWeight,
    "LeadingAffineRank" -> rank,
    "RequiredFacetRank" -> requiredRank,
    "NormalizedInwardNormal" -> normalized
  |>
];

hrfSADPullbackWeights[
    activeVars_List, pivots_List, solveRules_List, localVars_List,
    localWeights_List] := Module[{assoc, pivotWeights},
  assoc = AssociationThread[localVars, localWeights];
  pivotWeights = Association @ Map[
    Function[pivot,
      pivot -> hrfSADValuation[pivot /. solveRules, localVars, localWeights]
    ],
    pivots
  ];
  Association @ Map[
    Function[var,
      var -> If[MemberQ[pivots, var], Lookup[pivotWeights, var], Lookup[assoc, var]]
    ],
    activeVars
  ]
];

hrfSADSourceFacetData[
    facet_Association, pointRecords_List, sourceMaps_Association,
    fullPoints_List, denominatorWeight_] := Module[
  {normal, leadingWeight, leadingRecords, sourceWeights, fslWeight,
   fslRows, survivingFSLLeadingRows, otherMaps, otherRecords, otherPoints,
   withoutAudit, requiredQ},
  normal = facet["NormalizedInwardNormal"];
  leadingWeight = facet["LeadingWeight"];
  leadingRecords = pointRecords[[facet["FacetIndices"]]];
  sourceWeights = Association @ KeyValueMap[
    Function[{source, map},
      source -> If[map === <||>, Infinity,
        Min[(ToExpression /@ StringSplit[#, ","]).normal & /@ Keys[map]] -
          denominatorWeight
      ]
    ],
    sourceMaps
  ];
  fslWeight = Lookup[sourceWeights, "FSL", Infinity];
  fslRows = If[Lookup[sourceMaps, "FSL", <||>] === <||>, {},
    ToExpression /@ StringSplit[#, ","] & /@ Keys[sourceMaps["FSL"]]
  ];
  survivingFSLLeadingRows = Select[
    fslRows,
    TrueQ[Together[#.normal - denominatorWeight] ===
      Together[leadingWeight - denominatorWeight]] &&
      MemberQ[Lookup[pointRecords, "Row", {}], #] &
  ];
  otherMaps = KeyDrop[sourceMaps, "FSL"];
  otherRecords = hrfSADCombineCoefficientMaps[otherMaps];
  otherPoints = If[ListQ[otherRecords], Lookup[otherRecords, "Row", {}], {}];
  withoutAudit = hrfSADFixedNormalAudit[otherPoints, normal];
  requiredQ = TrueQ[facet["LowerFacetQ"]] &&
    ! TrueQ[Lookup[withoutAudit, "LowerFacetQ", False]];
  <|
    "SourceWeights" -> sourceWeights,
    "ResolvedFSLWeight" -> fslWeight,
    "FSLOnLeadingFacetQ" -> TrueQ[fslWeight === leadingWeight - denominatorWeight],
    "FSLSubleadingAfterCancellationQ" -> TrueQ[fslWeight > leadingWeight - denominatorWeight],
    "FSLLeadingRowsSurvivingInCompletePolynomial" -> survivingFSLLeadingRows,
    "FSLContributesToLeadingPolynomialQ" -> (survivingFSLLeadingRows =!= {}),
    "LeadingFacetRequiresFSLQ" -> requiredQ,
    "FacetWithoutFSLAudit" -> withoutAudit,
    "LeadingFacetSourceCounts" -> Counts @ Flatten[Lookup[leadingRecords, "Sources", {}]]
  |>
];

Options[hrfSADDissectChart] = Options[hrfSourceAwareAlignedDissectionCertificate];

hrfSADDissectChart[
    components_Association, factors_List, activeVars_List, pivots_List,
    solveRules_List, sectorSigns_List, eta_, faceActive_List, faceWeight_,
    cddExecutable_String, OptionsPattern[]] := Module[
  {yVars, tVars, sectorRules, localVars, transformed, rationalComponents,
   denominators, commonDenominator, polynomialComponents, allVars, sourceMaps,
   pointRecords, points, process, incidenceData, facets, denominatorWeight,
   certificates, normal, localWeights, pullbackRelative, pullbackVector,
   factorWeights, suppressions, positiveQ, fslRawWeights, wSL,
   sourceData, relativeValues, relativeAssoc, jacobian, chartInverseResiduals,
   chartInverseQ, pullbackChecks, chartStatus},

  yVars = DeleteDuplicates @ Cases[solveRules, s_Symbol /; StringStartsQ[SymbolName[s], "hrfSADY"], Infinity];
  If[Length[yVars] =!= Length[factors],
    Return[<|"ChartStatus" -> "MalformedTransverseCoordinates", "Certificates" -> {}|>]
  ];
  tVars = Array[Unique["hrfSADT"] &, Length[yVars]];
  sectorRules = Thread[yVars -> MapThread[Times, {sectorSigns, tVars}]];
  localVars = Join[Complement[activeVars, pivots], tVars];
  transformed = Association @ KeyValueMap[
    #1 -> Cancel[Together[Expand[#2 /. solveRules /. sectorRules]]] &,
    components
  ];
  rationalComponents = Values[transformed];
  denominators = Denominator[Together[#]] & /@ rationalComponents;
  commonDenominator = Times @@ DeleteCases[denominators, 1];
  If[commonDenominator === Times[], commonDenominator = 1];
  If[! hrfSADMonomialQ[commonDenominator, Join[localVars, {eta}]],
    Return[<|
      "ChartStatus" -> "UnsupportedNonMonomialDissectionDenominator",
      "CommonDenominator" -> commonDenominator,
      "Certificates" -> {}
    |>]
  ];
  polynomialComponents = Association @ KeyValueMap[
    Function[{source, polynomial},
      source -> Expand[Cancel[Together[polynomial commonDenominator]]]
    ],
    transformed
  ];
  If[AnyTrue[Values[polynomialComponents],
      ! PolynomialQ[#, Join[localVars, {eta}]] &],
    Return[<|"ChartStatus" -> "PolynomialClearingFailed", "Certificates" -> {}|>]
  ];
  allVars = Join[localVars, {eta}];
  sourceMaps = Association @ KeyValueMap[
    #1 -> hrfSADCoefficientMap[#2, allVars] &,
    polynomialComponents
  ];
  pointRecords = hrfSADCombineCoefficientMaps[sourceMaps];
  If[! ListQ[pointRecords] || pointRecords === {},
    Return[<|"ChartStatus" -> "EmptyResolvedPolynomial", "Certificates" -> {}|>]
  ];
  points = Lookup[pointRecords, "Row"];
  If[Length[points] > OptionValue["MaxPointCount"],
    Return[<|
      "ChartStatus" -> "PointLimitExceeded",
      "PointCount" -> Length[points],
      "Certificates" -> {}
    |>]
  ];
  process = TimeConstrained[
    RunProcess[{cddExecutable, "--repall"}, All, hrfSADCDDInput[points]],
    OptionValue["CDDTimeLimit"],
    $TimedOut
  ];
  If[process === $TimedOut,
    Return[<|
      "ChartStatus" -> "CDDTimedOut",
      "CDDTimeLimit" -> OptionValue["CDDTimeLimit"],
      "Certificates" -> {}
    |>]
  ];
  If[Lookup[process, "ExitCode", 1] =!= 0,
    Return[<|
      "ChartStatus" -> "CDDExecutionFailed",
      "CDDStandardError" -> Lookup[process, "StandardError", ""],
      "Certificates" -> {}
    |>]
  ];
  incidenceData = hrfSADParseFacetIncidences[Lookup[process, "StandardOutput", ""]];
  If[MissingQ[incidenceData] || incidenceData["VertexCount"] =!= Length[points],
    Return[<|
      "ChartStatus" -> "CDDIncidenceMismatch",
      "InputPointCount" -> Length[points],
      "CDDIncidenceData" -> incidenceData,
      "Certificates" -> {}
    |>]
  ];
  facets = DeleteMissing[
    hrfSADFacetFromIncidence[points, #] & /@ incidenceData["FacetVertexSets"]
  ];
  facets = Select[facets, TrueQ[Lookup[#, "LowerFacetQ", False]] &];
  certificates = Reap[
    Do[
      normal = facet["NormalizedInwardNormal"];
      localWeights = Most[normal];
      denominatorWeight = hrfSADValuation[commonDenominator, localVars, localWeights];
      pullbackRelative = hrfSADPullbackWeights[
        activeVars, pivots, solveRules /. sectorRules, localVars, localWeights
      ];
      If[AssociationQ[pullbackRelative] &&
          FreeQ[Values[pullbackRelative], _Missing],
        pullbackVector = faceActive + Lookup[pullbackRelative, activeVars];
        factorWeights = Map[
          hrfSADValuation[#, activeVars, Lookup[pullbackRelative, activeVars]] &,
          factors
        ];
        suppressions = localWeights[[-Length[factors] ;; -1]] - factorWeights;
        positiveQ = And @@ Thread[suppressions > 0];
        fslRawWeights = If[Lookup[components, "FSL", 0] === 0, {},
          (First[#].Lookup[pullbackRelative, activeVars]) & /@
            CoefficientRules[Expand[components["FSL"] /. eta -> 1], activeVars]
        ];
        wSL = If[fslRawWeights =!= {} && Length[DeleteDuplicates[fslRawWeights]] == 1,
          faceWeight + First[fslRawWeights], Missing["NonUniformFSL"]
        ];
        sourceData = hrfSADSourceFacetData[
          facet, pointRecords, sourceMaps, points, denominatorWeight
        ];
        relativeValues = pullbackVector - Max[pullbackVector];
        relativeAssoc = AssociationThread[activeVars, relativeValues];
        jacobian = Factor @ Det @ Table[
          D[pivots[[i]] /. solveRules, yVars[[j]]],
          {i, Length[pivots]}, {j, Length[yVars]}
        ];
        chartInverseResiduals = Together /@ (factors - yVars /. solveRules);
        chartInverseQ = And @@ (TrueQ[# === 0] & /@ chartInverseResiduals);
        pullbackChecks = <|
          "ExactChartInverseQ" -> chartInverseQ,
          "NonzeroDissectionJacobianQ" -> ! TrueQ[jacobian === 0],
          "PullbackValuationsResolvedQ" ->
            FreeQ[Values[pullbackRelative], _Missing],
          "UniformSuperleadingWeightQ" -> ! MissingQ[wSL],
          "PositiveTransverseSuppressionsQ" -> positiveQ,
          "ExactLowerFacetQ" -> TrueQ[facet["LowerFacetQ"]],
          "CompleteFacetRankQ" -> TrueQ[
            facet["LeadingAffineRank"] === facet["RequiredFacetRank"]
          ],
          "HiddenHierarchyQ" -> TrueQ[
            faceWeight + facet["LeadingWeight"] - denominatorWeight > wSL
          ],
          "SourceResolvedFSLWeightMeasuredQ" ->
            ! TrueQ[sourceData["ResolvedFSLWeight"] === Infinity]
        |>;
        If[TrueQ[And @@ Values[pullbackChecks]] &&
            (! TrueQ[OptionValue["RequirePositiveTransverseSuppressionQ"]] || positiveQ) &&
            ! MissingQ[wSL] &&
            TrueQ[faceWeight + facet["LeadingWeight"] - denominatorWeight > wSL],
          Sow @ Join[
            <|
              "CertifiedQ" -> True,
              "CertificateMethod" -> "SourceAwareAlignedDissection",
              "PivotVariables" -> pivots,
              "DissectionRules" -> solveRules,
              "SectorSigns" -> sectorSigns,
              "LocalVariables" -> localVars,
              "LocalScaling" -> AssociationThread[localVars, localWeights],
              "DissectionJacobian" -> jacobian,
              "ChartInverseResiduals" -> chartInverseResiduals,
              "PullbackChecks" -> pullbackChecks,
              "CommonMonomialDenominator" -> commonDenominator,
              "PullbackScaling" -> AssociationThread[activeVars, pullbackVector],
              "RelativePullbackScaling" -> relativeAssoc,
              "AlignedRelativeScaling" -> pullbackRelative,
              "TransverseSuppressions" -> AssociationThread[factors, suppressions],
              "PositiveTransverseSuppressionsQ" -> positiveQ,
              "WSL" -> wSL,
              "ResolvedLeadingWeight" ->
                faceWeight + facet["LeadingWeight"] - denominatorWeight,
              "CancellationDepth" ->
                faceWeight + facet["LeadingWeight"] - denominatorWeight - wSL,
              "ResolvedFSLWeight" ->
                faceWeight + sourceData["ResolvedFSLWeight"],
              "FSLOnLeadingFacetQ" -> sourceData["FSLOnLeadingFacetQ"],
              "FSLSubleadingAfterCancellationQ" ->
                sourceData["FSLSubleadingAfterCancellationQ"],
              "FSLContributesToLeadingPolynomialQ" ->
                sourceData["FSLContributesToLeadingPolynomialQ"],
              "LeadingFacetRequiresFSLQ" -> sourceData["LeadingFacetRequiresFSLQ"],
              "LeadingFacetSourceCounts" -> sourceData["LeadingFacetSourceCounts"],
              "SourceWeights" -> Map[faceWeight + # &, sourceData["SourceWeights"]],
              "FacetWithoutFSLAudit" -> sourceData["FacetWithoutFSLAudit"],
              "FacetAudit" -> facet,
              "SourcePolynomialsAfterDissection" -> polynomialComponents
            |>,
            KeyTake[sourceData, {"FSLLeadingRowsSurvivingInCompletePolynomial"}]
          ]
        ]
      ],
      {facet, facets}
    ]
  ][[2]];
  certificates = If[certificates === {}, {}, First[certificates]];
  chartStatus = If[certificates === {}, "NoAdmissibleLowerFacet", "CertifiedLowerFacet"];
  <|
    "ChartStatus" -> chartStatus,
    "PivotVariables" -> pivots,
    "DissectionRules" -> solveRules,
    "SectorSigns" -> sectorSigns,
    "LocalVariables" -> localVars,
    "InputPointCount" -> Length[points],
    "LowerFacetCount" -> Length[facets],
    "Certificates" -> certificates
  |>
];

(* Public entry point for a polynomial which has already been assembled in
   the coordinates in which the cancellation is to be dissected.  Explicit
   powers of eta in the source components are retained.  This is useful for
   auditing saved examples and for non-composite limits, where no preceding
   alignment row is required. *)
hrfSourceAwareDissectionCertificate[
    components_Association, factors_List, vars_List, eta_,
    OptionsPattern[]] := Module[
  {requiredSources, normalizedComponents, baseScaling, baseWeight,
   pivotChoices, totalPivotChoiceCount, maxPivots, yVars, solveBranches,
   maxBranches, solveBranchTruncatedQ = False, sectors,
   totalSignSectorCount, maxSectors, cddExecutable, chartAudits,
   certificates, truncatedChartStatuses, incompleteChartStatuses,
   searchTruncatedQ, searchIncompleteQ, status},

  requiredSources = {"FSL", "FObs", "FOutside", "U"};
  normalizedComponents = Association @ Map[
    # -> Expand[Lookup[components, #, 0]] &,
    requiredSources
  ];
  baseScaling = Replace[OptionValue["BaseScaling"],
    Automatic -> ConstantArray[0, Length[vars]]
  ];
  baseWeight = OptionValue["BaseWeight"];
  If[Length[baseScaling] =!= Length[vars],
    Return[<|
      "CertificationStatus" -> "UnavailableMalformedBaseScaling",
      "CertifiedQ" -> False,
      "Certificates" -> {}
    |>]
  ];
  pivotChoices = hrfSADPivotChoices[factors, vars];
  If[pivotChoices === {},
    Return[<|
      "CertificationStatus" -> "UnavailableNoPivotChoices",
      "CertifiedQ" -> False,
      "Certificates" -> {}
    |>]
  ];
  totalPivotChoiceCount = Length[pivotChoices];
  maxPivots = OptionValue["MaxPivotChoices"];
  pivotChoices = Take[pivotChoices, UpTo[maxPivots]];
  maxBranches = OptionValue["MaxSolveBranches"];
  maxSectors = OptionValue["MaxSignSectors"];
  sectors = Tuples[{-1, 1}, Length[factors]];
  totalSignSectorCount = Length[sectors];
  sectors = Take[sectors, UpTo[maxSectors]];
  cddExecutable = Replace[OptionValue["CDDExecutable"],
    Automatic :> With[{exe = Quiet @ Check[FindExecutable["cddexec"], $Failed]},
      If[StringQ[exe], exe, "/usr/local/bin/cddexec"]]
  ];
  If[! StringQ[cddExecutable] || ! FileExistsQ[cddExecutable],
    Return[<|
      "CertificationStatus" -> "CDDExecutableMissing",
      "CertifiedQ" -> False,
      "Certificates" -> {}
    |>]
  ];
  chartAudits = Reap[
    Do[
      yVars = Array[Unique["hrfSADY"] &, Length[factors]];
      solveBranches = TimeConstrained[
        Quiet @ Check[Solve[Thread[factors == yVars], pivots], {}],
        OptionValue["SolveTimeLimit"],
        $TimedOut
      ];
      If[solveBranches === $TimedOut,
        Sow @ <|
          "ChartStatus" -> "SolveTimedOut",
          "PivotVariables" -> pivots,
          "SolveTimeLimit" -> OptionValue["SolveTimeLimit"],
          "Certificates" -> {}
        |>;
        Continue[]
      ];
      If[Length[solveBranches] > maxBranches,
        solveBranchTruncatedQ = True
      ];
      solveBranches = Take[solveBranches, UpTo[maxBranches]];
      Do[
        Sow @ hrfSADDissectChart[
          normalizedComponents, factors, vars, pivots, solveRules, signs,
          eta, baseScaling, baseWeight, cddExecutable,
          "MaxPointCount" -> OptionValue["MaxPointCount"],
          "CDDTimeLimit" -> OptionValue["CDDTimeLimit"],
          "RequirePositiveTransverseSuppressionQ" ->
            OptionValue["RequirePositiveTransverseSuppressionQ"]
        ],
        {solveRules, solveBranches}, {signs, sectors}
      ],
      {pivots, pivotChoices}
    ]
  ][[2]];
  chartAudits = If[chartAudits === {}, {}, First[chartAudits]];
  certificates = Flatten[Lookup[chartAudits, "Certificates", {}], 1];
  certificates = Values @ GroupBy[
    certificates,
    {
      Lookup[#, "PullbackScaling", <||>],
      Lookup[#, "ResolvedLeadingWeight", Missing[]],
      Lookup[#, "FSLOnLeadingFacetQ", Missing[]]
    } &,
    First
  ];
  certificates = SortBy[
    certificates,
    {
      Values @ Lookup[#, "PullbackScaling", <||>],
      Lookup[#, "ResolvedLeadingWeight", Infinity],
      Lookup[#, "ResolvedFSLWeight", Infinity]
    } &
  ];
  truncatedChartStatuses = {
    "SolveTimedOut", "CDDTimedOut", "PointLimitExceeded"
  };
  searchTruncatedQ =
    totalPivotChoiceCount > Length[pivotChoices] ||
    totalSignSectorCount > Length[sectors] ||
    solveBranchTruncatedQ ||
    AnyTrue[
      Lookup[chartAudits, "ChartStatus", ""],
      MemberQ[truncatedChartStatuses, #] &
    ];
  incompleteChartStatuses = Join[
    truncatedChartStatuses,
    {
      "MalformedTransverseCoordinates",
      "UnsupportedNonMonomialDissectionDenominator",
      "PolynomialClearingFailed", "EmptyResolvedPolynomial",
      "CDDExecutionFailed", "CDDIncidenceMismatch"
    }
  ];
  searchIncompleteQ = searchTruncatedQ || AnyTrue[
    Lookup[chartAudits, "ChartStatus", ""],
    MemberQ[incompleteChartStatuses, #] &
  ];
  status = If[certificates === {},
    "NoSourceAwareDissectedLowerFacet",
    "CertifiedSourceAwareDissectedLowerFacet"
  ];
  <|
    "CertificationStatus" -> status,
    "CertifiedQ" -> (certificates =!= {}),
    "CertificateMethod" -> "SourceAwareDissection",
    "Variables" -> vars,
    "BaseScaling" -> AssociationThread[vars, baseScaling],
    "BaseWeight" -> baseWeight,
    "CancellationFactors" -> factors,
    "SourcePolynomials" -> normalizedComponents,
    "TotalPivotChoiceCount" -> totalPivotChoiceCount,
    "PivotChoiceCount" -> Length[pivotChoices],
    "TotalSignSectorCount" -> totalSignSectorCount,
    "SignSectorCount" -> Length[sectors],
    "SolveBranchTruncatedQ" -> solveBranchTruncatedQ,
    "SearchTruncatedQ" -> searchTruncatedQ,
    "SearchIncompleteQ" -> searchIncompleteQ,
    "SearchCompleteQ" -> ! searchIncompleteQ,
    "DistinctCertifiedRegionCount" -> Length[certificates],
    "MultipleCertifiedRegionsQ" -> (Length[certificates] > 1),
    "ChartAudits" -> chartAudits,
    "Certificates" -> certificates
  |>
];

hrfSourceAwareAlignedDissectionCertificate[
    row_Association, termData_List, vars_List, uPoly_, eta_,
    faceTransform_:Identity, OptionsPattern[]] := Module[
  {summary, cov, zeroVars, zeroPositions, activePositions, activeVars,
   faceVector, faceActive, faceWeight, faceIndices, obsData, fSL, fObs,
   factors, outsideData, components, pivotChoices, totalPivotChoiceCount,
   maxPivots, yVars, solveBranches, maxBranches,
   solveBranchTruncatedQ = False, sectors, totalSignSectorCount, maxSectors,
   cddExecutable, chartAudits, certificates, truncatedChartStatuses,
   incompleteChartStatuses, searchTruncatedQ, searchIncompleteQ, status},

  summary = Lookup[row, "HRFSummary", <||>];
  cov = Lookup[summary, "CoverageScalingData", <||>];
  zeroVars = Lookup[row, "PreselectionZeroVars", {}];
  zeroPositions = Flatten[Position[vars, Alternatives @@ zeroVars]];
  activePositions = Complement[Range[Length[vars]], zeroPositions];
  activeVars = vars[[activePositions]];
  faceVector = Lookup[row, "Scaling", {}];
  faceWeight = Lookup[row, "Weight", Missing["NoFaceWeight"]];
  faceIndices = Lookup[row, "Indices", {}];
  If[Length[faceVector] =!= Length[vars] || MissingQ[faceWeight],
    Return[<|"CertificationStatus" -> "UnavailableMalformedAlignmentFace",
      "CertifiedQ" -> False, "Certificates" -> {}|>]
  ];
  faceActive = faceVector[[activePositions]];
  obsData = Lookup[Lookup[row, "HRFScan", <||>], "ObstructionData", <||>];
  fSL = Lookup[obsData, "Superleading", Missing["NoSuperleading"]];
  fObs = Lookup[obsData, "Obstruction", Missing["NoObstruction"]];
  If[MissingQ[fSL] || MissingQ[fObs],
    Return[<|"CertificationStatus" -> "UnavailableMissingDecomposition",
      "CertifiedQ" -> False, "Certificates" -> {}|>]
  ];
  factors = DeleteDuplicates[Factor /@ Lookup[summary, "CancellationFactors", {}]];
  factors = faceTransform[Expand[# /. Thread[zeroVars -> 0]]] & /@ factors;
  factors = DeleteCases[factors, 0 | 1 | -1];
  If[factors === {},
    Return[<|"CertificationStatus" -> "UnavailableNoCancellationFactors",
      "CertifiedQ" -> False, "Certificates" -> {}|>]
  ];
  outsideData = Select[
    termData,
    (zeroPositions === {} || Total[Lookup[#, "XRow"][[zeroPositions]]] == 0) &&
      ! MemberQ[faceIndices, Lookup[#, "Index", -1]] &
  ];
  components = <|
    "FSL" -> faceTransform[Expand[fSL /. Thread[zeroVars -> 0]]],
    "FObs" -> faceTransform[Expand[fObs /. Thread[zeroVars -> 0]]],
    "FOutside" -> faceTransform @ Expand @ hrfSADOutsidePolynomial[
      outsideData, activePositions, zeroPositions, faceActive, faceWeight,
      zeroVars, eta
    ],
    "U" -> faceTransform @ Expand @ hrfSADAlignPolynomial[
      uPoly /. Thread[zeroVars -> 0], activeVars, faceActive, faceWeight, eta
    ]
  |>;
  pivotChoices = hrfSADPivotChoices[factors, activeVars];
  If[pivotChoices === {},
    Return[<|"CertificationStatus" -> "UnavailableNoPivotChoices",
      "CertifiedQ" -> False, "Certificates" -> {}|>]
  ];
  totalPivotChoiceCount = Length[pivotChoices];
  maxPivots = OptionValue["MaxPivotChoices"];
  pivotChoices = Take[pivotChoices, UpTo[maxPivots]];
  maxBranches = OptionValue["MaxSolveBranches"];
  maxSectors = OptionValue["MaxSignSectors"];
  sectors = Tuples[{-1, 1}, Length[factors]];
  totalSignSectorCount = Length[sectors];
  sectors = Take[sectors, UpTo[maxSectors]];
  cddExecutable = Replace[OptionValue["CDDExecutable"],
    Automatic :> With[{exe = Quiet @ Check[FindExecutable["cddexec"], $Failed]},
      If[StringQ[exe], exe, "/usr/local/bin/cddexec"]]
  ];
  If[! StringQ[cddExecutable] || ! FileExistsQ[cddExecutable],
    Return[<|"CertificationStatus" -> "CDDExecutableMissing",
      "CertifiedQ" -> False, "Certificates" -> {}|>]
  ];
  chartAudits = Reap[
    Do[
      yVars = Array[Unique["hrfSADY"] &, Length[factors]];
      solveBranches = TimeConstrained[
        Quiet @ Check[Solve[Thread[factors == yVars], pivots], {}],
        OptionValue["SolveTimeLimit"],
        $TimedOut
      ];
      If[solveBranches === $TimedOut,
        Sow @ <|
          "ChartStatus" -> "SolveTimedOut",
          "PivotVariables" -> pivots,
          "SolveTimeLimit" -> OptionValue["SolveTimeLimit"],
          "Certificates" -> {}
        |>;
        Continue[]
      ];
      If[Length[solveBranches] > maxBranches,
        solveBranchTruncatedQ = True
      ];
      solveBranches = Take[solveBranches, UpTo[maxBranches]];
      Do[
        Sow @ hrfSADDissectChart[
          components, factors, activeVars, pivots, solveRules, signs, eta,
          faceActive, faceWeight, cddExecutable,
          "MaxPivotChoices" -> OptionValue["MaxPivotChoices"],
          "MaxSolveBranches" -> OptionValue["MaxSolveBranches"],
          "MaxSignSectors" -> OptionValue["MaxSignSectors"],
          "MaxPointCount" -> OptionValue["MaxPointCount"],
          "SolveTimeLimit" -> OptionValue["SolveTimeLimit"],
          "CDDTimeLimit" -> OptionValue["CDDTimeLimit"],
          "RequirePositiveTransverseSuppressionQ" ->
            OptionValue["RequirePositiveTransverseSuppressionQ"]
        ],
        {solveRules, solveBranches}, {signs, sectors}
      ],
      {pivots, pivotChoices}
    ]
  ][[2]];
  chartAudits = If[chartAudits === {}, {}, First[chartAudits]];
  certificates = Flatten[Lookup[chartAudits, "Certificates", {}], 1];
  certificates = Values @ GroupBy[
    certificates,
    {
      Lookup[#, "PullbackScaling", <||>],
      Lookup[#, "ResolvedLeadingWeight", Missing[]],
      Lookup[#, "FSLOnLeadingFacetQ", Missing[]]
    } &,
    First
  ];
  certificates = SortBy[
    certificates,
    {
      Values @ Lookup[#, "PullbackScaling", <||>],
      Lookup[#, "ResolvedLeadingWeight", Infinity],
      Lookup[#, "ResolvedFSLWeight", Infinity]
    } &
  ];
  truncatedChartStatuses = {
    "SolveTimedOut", "CDDTimedOut", "PointLimitExceeded"
  };
  searchTruncatedQ =
    totalPivotChoiceCount > Length[pivotChoices] ||
    totalSignSectorCount > Length[sectors] ||
    solveBranchTruncatedQ ||
    AnyTrue[
      Lookup[chartAudits, "ChartStatus", ""],
      MemberQ[truncatedChartStatuses, #] &
    ];
  incompleteChartStatuses = Join[
    truncatedChartStatuses,
    {
      "MalformedTransverseCoordinates",
      "UnsupportedNonMonomialDissectionDenominator",
      "PolynomialClearingFailed", "EmptyResolvedPolynomial",
      "CDDExecutionFailed", "CDDIncidenceMismatch"
    }
  ];
  searchIncompleteQ = searchTruncatedQ || AnyTrue[
    Lookup[chartAudits, "ChartStatus", ""],
    MemberQ[incompleteChartStatuses, #] &
  ];
  status = If[certificates === {},
    "NoSourceAwareDissectedLowerFacet", "CertifiedSourceAwareDissectedLowerFacet"];
  <|
    "CertificationStatus" -> status,
    "CertifiedQ" -> (certificates =!= {}),
    "CertificateMethod" -> "SourceAwareAlignedDissection",
    "ActiveVariables" -> activeVars,
    "BoundaryZeroVariables" -> zeroVars,
    "AlignmentScaling" -> AssociationThread[activeVars, faceActive],
    "AlignmentWeight" -> faceWeight,
    "CancellationFactors" -> factors,
    "SourcePolynomialsInAlignedCoordinates" -> components,
    "TotalPivotChoiceCount" -> totalPivotChoiceCount,
    "PivotChoiceCount" -> Length[pivotChoices],
    "TotalSignSectorCount" -> totalSignSectorCount,
    "SignSectorCount" -> Length[sectors],
    "SolveBranchTruncatedQ" -> solveBranchTruncatedQ,
    "SearchTruncatedQ" -> searchTruncatedQ,
    "SearchIncompleteQ" -> searchIncompleteQ,
    "SearchCompleteQ" -> ! searchIncompleteQ,
    "DistinctCertifiedRegionCount" -> Length[certificates],
    "MultipleCertifiedRegionsQ" -> (Length[certificates] > 1),
    "ChartAudits" -> chartAudits,
    "Certificates" -> certificates
  |>
];

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] source-aware dissection and lower-facet certification."]
];
