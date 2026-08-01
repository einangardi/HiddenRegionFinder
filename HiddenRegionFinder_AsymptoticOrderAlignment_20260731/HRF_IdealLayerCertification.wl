(* Original-coordinate ideal-layer certification for asymptotically order-aligned HRs.

   The exposed F face is invariant under a uniform shift of its alignment vector
   vector.  A face-only HRF run therefore determines a relative direction,
   but not in general its depth or uniform lift into the full LP polynomial.

   This module fixes both ambiguities without sector dissection.  For each
   occupied F-weight layer it computes the leading class in the I-adic
   filtration I^m/I^(m+1), I=<f_1,...,f_r>.  Positive transverse weights of
   the factors are then solved together with the full U balance.  A unique
   solution is a scaleful common-pinch certificate. *)

ClearAll[
  hrfIdealLayerEtaLatticeStep,
  hrfIdealLayerPolynomialData,
  hrfIdealLayerPowerGenerators,
  hrfIdealLayerJetData,
  hrfIdealLayerLinearBounds,
  hrfIdealLayerUniqueSolution,
  hrfIdealLayerCertificate
];

Options[hrfIdealLayerCertificate] = {
  "MaxDepthMultiplier" -> 6,
  "MaxUniformShiftAbs" -> 8,
  "MaxIdealOrder" -> Automatic,
  "RequireNonPositivePullbackQ" -> True
};

hrfIdealLayerEtaLatticeStep[termData_List] := Module[{powers, differences, g},
  powers = Sort @ DeleteDuplicates @ Lookup[termData, "EtaPower", {}];
  If[Length[powers] <= 1, Return[1]];
  differences = DeleteCases[Abs[Subtract @@@ Subsets[powers, {2}]], 0];
  If[differences === {}, Return[1]];
  g = Apply[GCD, differences];
  If[IntegerQ[g] && g > 0, g, 1]
];

hrfIdealLayerPolynomialData[
    termData_List, activePositions_List, zeroPositions_List,
    vector_List, zeroVars_List] := Module[
  {surviving, weights, grouped},
  surviving = Select[
    termData,
    zeroPositions === {} || Total[Lookup[#, "XRow"][[zeroPositions]]] == 0 &
  ];
  weights = (
    Lookup[#, "EtaPower"] + Lookup[#, "XRow"][[activePositions]].vector
  ) & /@ surviving;
  grouped = GroupBy[MapThread[#1 -> #2 &, {weights, surviving}], First -> Last];
  KeyValueMap[
    Function[{weight, data},
      <|
        "Weight" -> weight,
        "TermCount" -> Length[data],
        "Polynomial" -> Factor @ Together @ Total[
          Lookup[data, "CoeffNoEta", {}] /. Thread[zeroVars -> 0]
        ]
      |>
    ],
    KeySort[grouped]
  ]
];

hrfIdealLayerPowerGenerators[factors_List, order_Integer] := Module[
  {multiDegrees},
  multiDegrees = Select[
    Tuples[Range[0, order], Length[factors]], Total[#] == order &
  ];
  <|
    "MultiDegrees" -> multiDegrees,
    "Generators" -> Map[
      Function[degrees,
        Times @@ MapThread[Power, {factors, degrees}]
      ],
      multiDegrees
    ]
  |>
];

hrfIdealLayerJetData[
    polynomial_, localRules_List, localVars_List,
    maxOrder_Integer] := Module[
  {p, localPolynomial, numerator, denominator, rules, degrees, order,
   support},
  p = Expand[polynomial];
  If[TrueQ[p === 0],
    Return[<|"AbsentLayerQ" -> True, "NonzeroLayerQ" -> False,
      "IdealOrder" -> Infinity, "JetSupport" -> {}|>]
  ];
  localPolynomial = Factor[Together[p /. localRules]];
  numerator = Expand[Numerator[localPolynomial]];
  denominator = Factor[Denominator[localPolynomial]];
  If[! FreeQ[denominator, Alternatives @@ localVars],
    Return[<|
      "AbsentLayerQ" -> False,
      "NonzeroLayerQ" -> True,
      "IdealOrder" -> Missing["TransverseDependentDenominator"],
      "JetSupport" -> {},
      "JetStatus" -> "UnsupportedLocalDenominator"
    |>]
  ];
  rules = CoefficientRules[numerator, localVars];
  degrees = Total[First[#]] & /@ rules;
  order = If[degrees === {}, Infinity, Min[degrees]];
  If[order === 0,
    Return[<|
      "AbsentLayerQ" -> False,
      "NonzeroLayerQ" -> True,
      "VanishesOnCommonPinchQ" -> False,
      "IdealOrder" -> 0,
      "JetSupport" -> {ConstantArray[0, Length[localVars]]}
    |>]
  ];
  support = Pick[First /@ rules, degrees, order];
  If[IntegerQ[order] && order <= maxOrder,
    <|
      "AbsentLayerQ" -> False,
      "NonzeroLayerQ" -> True,
      "VanishesOnCommonPinchQ" -> True,
      "IdealOrder" -> order,
      "JetSupport" -> support,
      "JetStatus" -> "ExactIdealOrderFound"
    |>,
    <|
    "AbsentLayerQ" -> False,
    "NonzeroLayerQ" -> True,
    "VanishesOnCommonPinchQ" -> True,
    "IdealOrder" -> order,
    "JetSupport" -> {},
    "JetStatus" -> "OrderExceedsAuditBound"
    |>
  ]
];

hrfIdealLayerLinearBounds[constraints_List, variables_List] := Module[
  {bounds, minimum, maximum, minResult, maxResult},
  bounds = Table[
    minResult = Quiet @ Check[
      LinearOptimization[
        variable, And @@ constraints, variables,
        {"PrimalMinimizer", "PrimalMinimumValue"}
      ],
      $Failed
    ];
    maxResult = Quiet @ Check[
      LinearOptimization[
        -variable, And @@ constraints, variables,
        {"PrimalMinimizer", "PrimalMinimumValue"}
      ],
      $Failed
    ];
    If[! ListQ[minResult] || ! ListQ[maxResult],
      Return[$Failed]
    ];
    minimum = Rationalize[minResult[[2]], 0];
    maximum = Rationalize[-maxResult[[2]], 0];
    {minimum, maximum},
    {variable, variables}
  ];
  bounds
];

hrfIdealLayerUniqueSolution[constraints_List, variables_List] := Module[
  {bounds, values},
  bounds = hrfIdealLayerLinearBounds[constraints, variables];
  If[bounds === $Failed || ! AllTrue[bounds, SameQ @@ # &],
    Return[<|"UniqueQ" -> False, "Bounds" -> bounds|>]
  ];
  values = First /@ bounds;
  <|
    "UniqueQ" -> True,
    "Solution" -> values,
    "Bounds" -> bounds,
    "PositiveQ" -> And @@ Thread[values > 0]
  |>
];

hrfIdealLayerCertificate[
    row_Association, termData_List, vars_List, uPoly_, eta_,
    OptionsPattern[]] := Module[
  {summary, cov, zeroVars, zeroPositions, activePositions, activeVars,
   faceVector, hrfAssoc, stagedTotal, relativeDirection, factors,
   unsupported, pivotChoices, pivots, pinchSolve, pinchRules,
   localVars, localSolve, localRules,
   maxDepth, maxShift, maxOrder, requireNonPositiveQ, etaStep,
   uRules, certificates, depth, shift, pullback, layerData, jetLayers,
   wSL, wResolved, q, constraints, fslSupports, allSupports,
   uniqueCandidates, uniqueSolutions, activeLowestSupports, solution,
   intermediate, relativeAssoc, nums},

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
  factors = DeleteDuplicates[
    Factor /@ Lookup[summary, "CancellationFactors", {}]
  ];
  factors = Expand[# /. Thread[zeroVars -> 0]] & /@ factors;
  factors = DeleteCases[factors, 0 | 1 | -1];
  unsupported = Select[
    factors,
    ! hrfLayeredLinearFactorQ[#, activeVars] &
  ];
  If[factors === {} || unsupported =!= {},
    Return[<|
      "CertificationStatus" -> If[factors === {},
        "UnavailableNoCancellationFactors", "UnavailableNonlinearFactors"],
      "CertifiedQ" -> False,
      "UnsupportedFactors" -> unsupported
    |>]
  ];

  pivotChoices = hrfLayeredPivotChoices[factors, activeVars];
  If[pivotChoices === {},
    Return[<|"CertificationStatus" -> "UnavailableNoIndependentPivots",
      "CertifiedQ" -> False|>]
  ];
  pivots = First[pivotChoices];
  pinchSolve = Quiet @ Check[
    Solve[Thread[factors == 0], pivots],
    {}
  ];
  If[pinchSolve === {},
    Return[<|"CertificationStatus" -> "UnavailablePinchSolveFailed",
      "CertifiedQ" -> False|>]
  ];
  pinchRules = First[pinchSolve];
  localVars = Array[Unique["idealTransverseCoordinate"] &, Length[factors]];
  localSolve = Quiet @ Check[
    Solve[Thread[factors == localVars], pivots],
    {}
  ];
  If[localSolve === {},
    Return[<|"CertificationStatus" -> "UnavailableLocalCoordinateSolveFailed",
      "CertifiedQ" -> False|>]
  ];
  localRules = First[localSolve];

  maxDepth = OptionValue["MaxDepthMultiplier"];
  maxShift = OptionValue["MaxUniformShiftAbs"];
  maxOrder = Replace[OptionValue["MaxIdealOrder"],
    Automatic -> Max[2, Length[factors] + 1]
  ];
  requireNonPositiveQ = TrueQ[OptionValue["RequireNonPositivePullbackQ"]];
  etaStep = hrfIdealLayerEtaLatticeStep[termData];
  uRules = CoefficientRules[
    Expand[uPoly /. Thread[zeroVars -> 0]], activeVars
  ];
  certificates = Reap[
    Do[
      pullback = depth relativeDirection + shift;
      If[! requireNonPositiveQ || And @@ Thread[pullback <= 0],
        layerData = hrfIdealLayerPolynomialData[
          termData, activePositions, zeroPositions, pullback, zeroVars
        ];
        layerData = Select[layerData, ! TrueQ[#1["Polynomial"] === 0] &];
        If[layerData =!= {},
          jetLayers = Map[
            Join[KeyDrop[#, "Polynomial"],
              hrfIdealLayerJetData[
                #1["Polynomial"], localRules, localVars, maxOrder
              ]] &,
            layerData
          ];
          If[AllTrue[jetLayers, ListQ[Lookup[#, "JetSupport", {}]] &],
            wSL = First[jetLayers]["Weight"];
            wResolved = Min[(First[#].pullback &) /@ uRules];
            q = Array[Unique["idealTransverseWeight"] &, Length[factors]];
            allSupports = Flatten[
              Table[
                (layer["Weight"] + #.q >= wResolved) & /@
                  layer["JetSupport"],
                {layer, jetLayers}
              ]
            ];
            fslSupports = First[jetLayers]["JetSupport"];
            constraints = Join[
              allSupports,
              Thread[q >= 0]
            ];
            uniqueCandidates = Table[
              <|
                "Support" -> support,
                "SolutionData" -> hrfIdealLayerUniqueSolution[
                  Append[constraints, wSL + support.q == wResolved], q
                ]
              |>,
              {support, fslSupports}
            ];
            uniqueCandidates = Select[
              uniqueCandidates,
              TrueQ[#["SolutionData", "UniqueQ"]] &&
                TrueQ[#["SolutionData", "PositiveQ"]] &
            ];
            uniqueSolutions = DeleteDuplicates[
              Lookup[Lookup[uniqueCandidates, "SolutionData", {}],
                "Solution", {}]
            ];
            If[Length[uniqueSolutions] == 1,
              solution = First[uniqueSolutions];
              activeLowestSupports = Lookup[
                Select[uniqueCandidates,
                  Lookup[#1["SolutionData"], "Solution", Missing[]] ===
                    solution &],
                "Support", {}
              ];
              intermediate = Select[
                jetLayers,
                wSL < #1["Weight"] < wResolved &&
                  TrueQ[#1["NonzeroLayerQ"]] &&
                  TrueQ[#1["VanishesOnCommonPinchQ"]] &
              ];
              nums = Cases[pullback, _Integer | _Rational];
              relativeAssoc = If[Length[nums] == Length[pullback],
                AssociationThread[activeVars, pullback - Max[nums]],
                AssociationThread[activeVars, pullback]
              ];
              Sow[<|
                "CertifiedQ" -> True,
                "CertificateMethod" -> "OriginalCoordinateIdealJet",
                "DepthMultiplier" -> depth,
                "UniformShift" -> shift,
                "PullbackScaling" -> AssociationThread[activeVars, pullback],
                "RelativePullbackScaling" -> relativeAssoc,
                "WSL" -> wSL,
                "ResolvedLeadingWeight" -> wResolved,
                "CancellationDepth" -> wResolved - wSL,
                "TransverseWeights" -> AssociationThread[factors, solution],
                "ActiveLowestJetSupports" -> activeLowestSupports,
                "IntermediateVanishingLayers" -> intermediate,
                "LayerAudit" -> jetLayers,
                "UniqueIdealJetSolutionQ" -> True,
                "ResidualMonomialRescalingQ" -> False,
                "PinchRules" -> pinchRules
              |>]
            ]
          ]
        ]
      ],
      {depth, 1, maxDepth}, {shift, 0, -maxShift, -1}
    ]
  ][[2]];
  certificates = If[certificates === {}, {}, First[certificates]];
  certificates = Values @ GroupBy[
    certificates, Lookup[#, "PullbackScaling"] &, First
  ];

  <|
    "CertificationStatus" -> If[certificates === {},
      "NoUniqueIdealJetCertificate", "CertifiedOriginalCoordinateIdealJet"],
    "CertifiedQ" -> (certificates =!= {}),
    "CertificateMethod" -> "OriginalCoordinateIdealJet",
    "DeclaredExpansionParameter" -> eta,
    "DeclaredEtaExponentLatticeStep" -> etaStep,
    "AbsentLayersAreCancellationLayersQ" -> False,
    "StagedTotalScaling" -> AssociationThread[activeVars, stagedTotal],
    "ShiftInvariantRelativeDirection" ->
      AssociationThread[activeVars, relativeDirection],
    "CancellationFactors" -> factors,
    "Certificates" -> certificates
  |>
];

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] original-coordinate ideal-layer certification."]
];
