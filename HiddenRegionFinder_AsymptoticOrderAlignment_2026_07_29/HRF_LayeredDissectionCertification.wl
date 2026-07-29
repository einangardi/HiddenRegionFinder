(* Layered common-pinch certification for asymptotically order-aligned hidden regions.

   Asymptotic-order alignment identifies a leading F-face only up to a uniform shift of its
   scaling vector.  The HRF run on that face is useful for discovering the
   cancellation factors, but its raw sum with the face vector is not an
   invariant final region vector.  This module resolves linear cancellation
   factors explicitly, keeps the complete eta-filtered LP polynomial F+U,
   and certifies candidate pullbacks by exact lower-facet tests.

   The search uses only the shift-invariant relative direction returned by
   the staged calculation.  A candidate is accepted only when every
   independent cancellation coordinate is suppressed by the HR hierarchy
   gap and the resulting local leading support is a full lower facet. *)

ClearAll[
  hrfLayeredLinearFactorQ,
  hrfLayeredFactorSupport,
  hrfLayeredPivotChoices,
  hrfLayeredAugmentedPoints,
  hrfLayeredNormalizeNormal,
  hrfLayeredFacetAudit,
  hrfLayeredPinchLayerAudit,
  hrfLayeredDissectionCertificate
];

Options[hrfLayeredDissectionCertificate] = {
  "MaxDepthMultiplier" -> 6,
  "MaxUniformShiftAbs" -> 8,
  "MaxPivotChoices" -> 1,
  "RequireNonPositivePullbackQ" -> True
};

hrfLayeredFactorSupport[f_, vars_List] := Select[vars, ! FreeQ[f, #] &];

hrfLayeredLinearFactorQ[f_, vars_List] := Module[{rules, degrees},
  If[! PolynomialQ[f, vars], Return[False]];
  rules = CoefficientRules[Expand[f], vars];
  If[rules === {}, Return[False]];
  degrees = Total /@ (First /@ rules);
  Max[degrees] == 1 && Min[degrees] == 1 &&
    Length[hrfLayeredFactorSupport[f, vars]] >= 2
];

hrfLayeredPivotChoices[factors_List, vars_List] := Module[{choices},
  choices = hrfLayeredFactorSupport[#, vars] & /@ factors;
  Select[Tuples[choices], DuplicateFreeQ]
];

hrfLayeredAugmentedPoints[polynomial_, localVars_List, eta_] := Module[
  {expanded, rules},
  (* Dissection denominators are independent of the local variables and eta;
     forming one global Together[] denominator causes an avoidable explosion
     for two-loop charts. *)
  expanded = Expand[polynomial];
  rules = CoefficientRules[expanded, Append[localVars, eta]];
  rules = Select[
    rules,
    ! TrueQ[Cancel[Together[Last[#]]] === 0] &
  ];
  DeleteDuplicates[First /@ rules]
];

hrfLayeredNormalizeNormal[normal_List] := Module[{oriented},
  oriented = If[Last[normal] < 0, -normal, normal];
  If[Last[oriented] <= 0, Missing["NoPositiveEtaNormal"],
    Together[oriented/Last[oriented]]
  ]
];

hrfLayeredFacetAudit[points_List, localNormal_List] := Module[
  {candidate, weights, minimum, leading, differences, rank, normalSpace,
   normalized, agreementQ, xRows, xDifferences, xNullSpace},
  candidate = Append[localNormal, 1];
  weights = points.candidate;
  minimum = Min[weights];
  leading = DeleteDuplicates @ Pick[points, weights, minimum];
  differences = If[Length[leading] <= 1, {},
    (# - First[leading]) & /@ Rest[leading]
  ];
  rank = If[differences === {}, 0, MatrixRank[differences]];
  normalSpace = If[differences === {}, {}, NullSpace[differences]];
  normalized = If[Length[normalSpace] == 1,
    hrfLayeredNormalizeNormal[First[normalSpace]],
    Missing["NonUniqueNormal"]
  ];
  agreementQ = ListQ[normalized] &&
    TrueQ[And @@ Thread[Together[normalized - candidate] == 0]];
  xRows = Most /@ leading;
  xDifferences = If[Length[xRows] <= 1, {},
    (# - First[xRows]) & /@ Rest[xRows]
  ];
  xNullSpace = If[xDifferences === {}, IdentityMatrix[Length[localNormal]],
    NullSpace[xDifferences]
  ];
  <|
    "LowerFacetQ" -> TrueQ[
      rank == Length[localNormal] && Length[normalSpace] == 1 && agreementQ
    ],
    "LeadingWeight" -> minimum,
    "LeadingPointCount" -> Length[leading],
    "LeadingAffineRank" -> rank,
    "RequiredFacetRank" -> Length[localNormal],
    "FacetNormalNullSpace" -> normalSpace,
    "NormalizedInwardNormal" -> normalized,
    "CandidateNormal" -> candidate,
    "NormalAgreementQ" -> agreementQ,
    "LeadingAugmentedRows" -> leading,
    "MonomialRescalingNullSpace" -> xNullSpace,
    "ResidualMonomialRescalingQ" -> (xNullSpace =!= {})
  |>
];

hrfLayeredPinchLayerAudit[
    termData_List, activePositions_List, zeroPositions_List,
    pullback_List, pinchRules_List, zeroVars_List] := Module[
  {surviving, weights, layerWeights, layerPolynomial},
  surviving = Select[
    termData,
    zeroPositions === {} || Total[Lookup[#, "XRow"][[zeroPositions]]] == 0 &
  ];
  weights = (
    Lookup[#, "EtaPower"] + Lookup[#, "XRow"][[activePositions]].pullback
  ) & /@ surviving;
  layerWeights = Sort @ DeleteDuplicates[weights];
  Table[
    layerPolynomial = Factor @ Total @ Lookup[
      Pick[surviving, weights, layerWeight], "CoeffNoEta", {}
    ];
    <|
      "Weight" -> layerWeight,
      "TermCount" -> Count[weights, layerWeight],
      "VanishesOnCommonPinchQ" -> TrueQ[
        Factor[Together[
          layerPolynomial /. Thread[zeroVars -> 0] /. pinchRules
        ]] === 0
      ]
    |>,
    {layerWeight, layerWeights}
  ]
];

hrfLayeredDissectionCertificate[
    row_Association, termData_List, vars_List, uPoly_, eta_,
    OptionsPattern[]] := Module[
  {summary, cov, zeroVars, zeroPositions, activePositions, activeVars,
   faceVector, hrfAssoc, stagedTotal, relativeDirection, gap,
   factors, unsupportedFactors, pivotChoices, fullF, fullP, maxDepth,
   maxShift, requireNonPositiveQ, certificates, pivots, yVars, solve,
   solveRules, pinchSolve, pinchRules, localVars, transformedP, points,
   depth, shift, pullback, pullbackAssoc, factorWeights, commonWeights,
   localNormal, facetAudit, layerAudit, relativeAssoc, nums, groupedTerms},

  summary = Lookup[row, "HRFSummary", <||>];
  cov = Lookup[summary, "CoverageScalingData", <||>];
  zeroVars = Lookup[row, "PreselectionZeroVars", {}];
  zeroPositions = Flatten[Position[vars, Alternatives @@ zeroVars]];
  activePositions = Complement[Range[Length[vars]], zeroPositions];
  activeVars = vars[[activePositions]];
  faceVector = Lookup[row, "Scaling", {}];
  hrfAssoc = Lookup[cov, "VariableScaling", <||>];

  If[Length[faceVector] =!= Length[vars] ||
      ! AssociationQ[hrfAssoc] ||
      ! AllTrue[activeVars, KeyExistsQ[hrfAssoc, #] &],
    Return[<|"CertificationStatus" -> "UnavailableMalformedStagedScaling",
      "CertifiedQ" -> False|>]
  ];

  stagedTotal = faceVector[[activePositions]] + Lookup[hrfAssoc, activeVars];
  relativeDirection = Together[stagedTotal - Max[stagedTotal]];
  If[relativeDirection === ConstantArray[0, Length[activeVars]],
    Return[<|"CertificationStatus" -> "UnavailableZeroRelativeDirection",
      "CertifiedQ" -> False|>]
  ];

  gap = Lookup[cov, "HierarchyGapPostLPminusFSL",
    Lookup[cov, "PrimitiveHierarchyGap", 1]
  ];
  If[! NumericQ[gap] || ! TrueQ[gap > 0], gap = 1];

  factors = DeleteDuplicates[
    Factor /@ Lookup[summary, "CancellationFactors", {}]
  ];
  factors = Expand[# /. Thread[zeroVars -> 0]] & /@ factors;
  factors = DeleteCases[factors, 0 | 1 | -1];
  unsupportedFactors = Select[factors, ! hrfLayeredLinearFactorQ[#, activeVars] &];
  If[factors === {} || unsupportedFactors =!= {},
    Return[<|
      "CertificationStatus" -> If[factors === {},
        "UnavailableNoCancellationFactors", "UnavailableNonlinearFactors"],
      "CertifiedQ" -> False,
      "CancellationFactors" -> factors,
      "UnsupportedFactors" -> unsupportedFactors
    |>]
  ];

  pivotChoices = hrfLayeredPivotChoices[factors, activeVars];
  If[pivotChoices === {},
    Return[<|"CertificationStatus" -> "UnavailableNoIndependentPivots",
      "CertifiedQ" -> False, "CancellationFactors" -> factors|>]
  ];
  pivotChoices = Take[pivotChoices, UpTo[OptionValue["MaxPivotChoices"]]];

  (* The chart-expanded coefficient algebra can produce thousands of terms
     with identical (eta power, Feynman exponent row).  Compress those rows
     before the coordinate change; this preserves exact cancellations while
     keeping two-loop dissections tractable. *)
  groupedTerms = GroupBy[
    termData,
    {Lookup[#, "EtaPower"], Lookup[#, "XRow"]} &
  ];
  fullF = Total @ KeyValueMap[
    Function[{key, data},
      Together[Total[Lookup[data, "Term", {}]]]
    ],
    groupedTerms
  ];
  fullP = Expand[(fullF + uPoly) /. Thread[zeroVars -> 0]];
  maxDepth = OptionValue["MaxDepthMultiplier"];
  maxShift = OptionValue["MaxUniformShiftAbs"];
  requireNonPositiveQ = TrueQ[OptionValue["RequireNonPositivePullbackQ"]];
  certificates = Reap[
    Do[
      pivots = pivotChoice;
      yVars = Array[Unique["hrfDissectionY"] &, Length[factors]];
      solve = Quiet @ Check[
        Solve[Thread[factors == yVars], pivots],
        {}
      ];
      pinchSolve = Quiet @ Check[
        Solve[Thread[factors == 0], pivots],
        {}
      ];
      If[solve =!= {} && pinchSolve =!= {},
        solveRules = First[solve];
        pinchRules = First[pinchSolve];
        localVars = Join[Complement[activeVars, pivots], yVars];
        transformedP = Expand[fullP /. solveRules];
        points = hrfLayeredAugmentedPoints[transformedP, localVars, eta];
        If[points =!= {},
          Do[
            pullback = depth relativeDirection + shift;
            If[! requireNonPositiveQ || And @@ Thread[pullback <= 0],
              pullbackAssoc = AssociationThread[activeVars, pullback];
              factorWeights = (
                DeleteDuplicates[Lookup[pullbackAssoc,
                  hrfLayeredFactorSupport[#, activeVars]]]
              ) & /@ factors;
              If[AllTrue[factorWeights, Length[#] == 1 &],
                commonWeights = First /@ factorWeights;
                localNormal = Join[
                  Lookup[pullbackAssoc, Complement[activeVars, pivots]],
                  commonWeights + gap
                ];
                facetAudit = hrfLayeredFacetAudit[points, localNormal];
                If[TrueQ[facetAudit["LowerFacetQ"]],
                  layerAudit = hrfLayeredPinchLayerAudit[
                    termData, activePositions, zeroPositions, pullback,
                    pinchRules, zeroVars
                  ];
                  nums = Cases[pullback, _Integer | _Rational];
                  relativeAssoc = If[Length[nums] == Length[pullback],
                    AssociationThread[activeVars, pullback - Max[nums]],
                    AssociationThread[activeVars, pullback]
                  ];
                  Sow[<|
                    "CertifiedQ" -> True,
                    "DepthMultiplier" -> depth,
                    "UniformShift" -> shift,
                    "PullbackScaling" -> AssociationThread[activeVars, pullback],
                    "RelativePullbackScaling" -> relativeAssoc,
                    "LocalVariables" -> localVars,
                    "LocalScaling" -> AssociationThread[localVars, localNormal],
                    "PivotVariables" -> pivots,
                    "DissectionRules" -> solveRules,
                    "PinchRules" -> pinchRules,
                    "CancellationFactors" -> factors,
                    "TransverseSuppression" -> ConstantArray[gap, Length[factors]],
                    "LayerAudit" -> layerAudit,
                    "WSL" -> If[layerAudit === {}, Missing["NoFLayers"],
                      First[layerAudit]["Weight"]],
                    "ResolvedLeadingWeight" -> facetAudit["LeadingWeight"],
                    "CancellationDepth" -> If[layerAudit === {},
                      Missing["NoFLayers"],
                      facetAudit["LeadingWeight"] - First[layerAudit]["Weight"]
                    ],
                    "IntermediateVanishingLayers" -> If[layerAudit === {}, {},
                      Select[
                        layerAudit,
                        First[layerAudit]["Weight"] < #1["Weight"] <
                            facetAudit["LeadingWeight"] &&
                          TrueQ[#1["VanishesOnCommonPinchQ"]] &
                      ]
                    ],
                    "FacetAudit" -> facetAudit
                  |>]
                ]
              ]
            ],
            {depth, 1, maxDepth}, {shift, 0, -maxShift, -1}
          ]
        ]
      ],
      {pivotChoice, pivotChoices}
    ]
  ][[2]];
  certificates = If[certificates === {}, {}, First[certificates]];
  certificates = Values @ GroupBy[
    certificates,
    Lookup[#, "PullbackScaling"] &,
    First
  ];

  <|
    "CertificationStatus" -> If[certificates === {},
      "NoCommonPinchLowerFacet", "CertifiedCommonPinchLowerFacet"],
    "CertifiedQ" -> (certificates =!= {}),
    "StagedTotalScaling" -> AssociationThread[activeVars, stagedTotal],
    "ShiftInvariantRelativeDirection" ->
      AssociationThread[activeVars, relativeDirection],
    "HierarchyGapUsedForEachTransverseDirection" -> gap,
    "CancellationFactors" -> factors,
    "PivotChoiceCount" -> Length[pivotChoices],
    "Certificates" -> certificates
  |>
];

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] layered common-pinch dissection certification."]
];
