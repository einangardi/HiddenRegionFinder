(* HRF_MomentumScalingReconstruction.wl

   Reconstruct component-wise momentum valuations from a certified LP region.

   Input data:
     - internal graph edges, in the same order as the LP parameters;
     - external attachments and external (+,-,perp) valuations;
     - the LP parameter valuation v_e.

   Only differences of LP valuations determine ratios of virtualities.  If
   v_e is first shifted so that Max[v_e]=0 and the corresponding hardest
   virtuality has physical power kappa_hard, then

      kappa_e = kappa_hard-v_e.

   At valuation level, momentum conservation at a
   vertex requires the smallest exponent in each nontrivial component to be
   attained at least twice.  Each internal edge also obeys

      kappa_e = Min[a_e+b_e, 2 c_e]

   A cancellation-enhanced realization a+b=2c<kappa can optionally be
   admitted, but such a branch requires a separate leading-coefficient
   feasibility check.  The present routine enumerates rational-valued
   branches in a user-controlled finite range, classifies their virtuality
   type, and audits which non-balanced components can be removed by choosing
   another propagator-edge loop basis.
*)

ClearAll[
  hrfMomentumFiniteExponentQ, hrfMomentumMinimumAttainedTwiceConstraint,
  hrfMomentumVirtualityConstraint, hrfMomentumEdgeSymbols,
  hrfMomentumVertexComponentTerms, hrfMomentumScalingReconstruct,
  hrfMomentumVirtualityType, hrfMomentumScalingBranchSummary,
  hrfMomentumVirtualityStateDomain, hrfMomentumVertexPossibleQ,
  hrfMomentumEnumerateCSPBranches, hrfMomentumVirtualityRealizationType
  , hrfMomentumComponentVertexPossibleQ,
  hrfMomentumEnumerateComponentAssignments,
  hrfMomentumEnumerateFactorizedBranches,
  hrfMomentumSpanningTreeEdgeSets, hrfMomentumEdgeBasisAudit,
  hrfMomentumPreferredHomogeneousBranch,
  hrfMomentumDirectVirtualityStateQ,
  hrfMomentumBalancedAtVirtualityScaleQ,
  hrfMomentumVertexRelationMatrix,
  hrfMomentumOptimizedLinearCombinationPower,
  hrfMomentumLoopCombinationAudit
];

hrfMomentumFiniteExponentQ[x_] := x =!= Infinity && x =!= DirectedInfinity[1] &&
  x =!= Missing["ZeroComponent"] && ! MissingQ[x];

hrfMomentumMinimumAttainedTwiceConstraint[terms_List] := Module[{pairs},
  Which[
    Length[terms] == 0, True,
    Length[terms] == 1, False,
    True,
      pairs = Subsets[Range[Length[terms]], {2}];
      Or @@ Map[
        Function[pair,
          terms[[pair[[1]]]] == terms[[pair[[2]]]] &&
            And @@ Thread[terms >= terms[[pair[[1]]]]]
        ],
        pairs
      ]
  ]
];

hrfMomentumVirtualityConstraint[{a_, b_, c_}, kappa_,
    allowCancellationEnhancedQ_:False] :=
  (a + b == kappa && 2 c >= kappa) ||
  (2 c == kappa && a + b >= kappa) ||
  (TrueQ[allowCancellationEnhancedQ] &&
    a + b == 2 c && a + b < kappa);

hrfMomentumEdgeSymbols[n_Integer?Positive] := Table[
  {
    Symbol["q" <> ToString[e] <> "PlusPower"],
    Symbol["q" <> ToString[e] <> "MinusPower"],
    Symbol["q" <> ToString[e] <> "PerpPower"]
  },
  {e, 0, n - 1}
];

hrfMomentumVertexComponentTerms[
    vertex_, componentIndex_Integer, internalLines_List, edgeSymbols_List,
    externalLines_List, externalScalings_Association] := Module[
  {internalTerms, attachedExternal, externalTerms},
  internalTerms = MapIndexed[
    If[MemberQ[#1[[2]], vertex], edgeSymbols[[First[#2], componentIndex]], Nothing] &,
    internalLines
  ];
  attachedExternal = Cases[externalLines, {p_, vertex} :> p];
  externalTerms = Select[
    Lookup[externalScalings, attachedExternal, Missing["ExternalScaling"]][[All, componentIndex]],
    hrfMomentumFiniteExponentQ
  ];
  Join[internalTerms, externalTerms]
];

hrfMomentumVirtualityType[{a_, b_, c_}] := Which[
  a + b == 2 c, "Balanced",
  a + b < 2 c, "LongitudinalDominated",
  a + b > 2 c, "TransverseDominated",
  True, "Undetermined"
];

hrfMomentumVirtualityRealizationType[{a_, b_, c_}, kappa_] := Which[
  a + b == 2 c && a + b < kappa, "NearOnShellCancellationEnhanced",
  a + b == 2 c && a + b == kappa, "BalancedAtVirtualityScale",
  a + b == kappa && a + b < 2 c, "LongitudinalDominated",
  2 c == kappa && 2 c < a + b, "TransverseDominated",
  True, "Undetermined"
];

hrfMomentumVirtualityStateDomain[kappa_, {lower_, upper_}, step_,
    allowCancellationEnhancedQ_:False] := Module[
  {values, longitudinal, transverse, enhanced},
  values = Range[lower, upper, step];
  longitudinal = Flatten[Table[
    With[{b = kappa - a},
      If[MemberQ[values, b],
        ({a, b, #} &) /@ Select[values, 2 # >= kappa &],
        {}
      ]
    ],
    {a, values}
  ], 1];
  transverse = If[MemberQ[values, kappa/2],
    Flatten[Table[
      If[a + b >= kappa, {{a, b, kappa/2}}, {}],
      {a, values}, {b, values}
    ], 2],
    {}
  ];
  enhanced = Flatten[Table[
    If[a + b == 2 c && a + b < kappa, {{a, b, c}}, {}],
    {a, values}, {b, values}, {c, values}
  ], 3];
  DeleteDuplicates[Join[
    longitudinal, transverse,
    If[TrueQ[allowCancellationEnhancedQ], enhanced, {}]
  ]]
];

(* Feasibility of one tropical vertex/component constraint under a partial
   edge assignment.  Each unassigned edge contributes the set of component
   powers available in its current domain.  A completion exists iff some
   candidate minimum can be selected by at least two terms and every other
   term can be chosen at or above that minimum. *)
hrfMomentumVertexPossibleQ[
    vertex_, component_, assignment_Association, domains_List,
    internalLines_List, externalLines_List, externalScalings_Association] := Module[
  {sets, attached, externalValues, candidates},
  sets = MapIndexed[
    If[MemberQ[#1[[2]], vertex],
      If[KeyExistsQ[assignment, First[#2]],
        {assignment[First[#2]][[component]]},
        DeleteDuplicates[domains[[First[#2], All, component]]]
      ],
      Nothing
    ] &,
    internalLines
  ];
  attached = Cases[externalLines, {p_, vertex} :> p];
  externalValues = Select[
    Lookup[externalScalings, attached, Missing["ExternalScaling"]][[All, component]],
    hrfMomentumFiniteExponentQ
  ];
  sets = Join[sets, List /@ externalValues];
  If[Length[sets] < 2, Return[False]];
  candidates = DeleteDuplicates[Flatten[sets]];
  AnyTrue[candidates,
    Function[m,
      Count[sets, s_ /; MemberQ[s, m]] >= 2 &&
        And @@ (Max[#] >= m & /@ sets)
    ]
  ]
];

hrfMomentumEnumerateCSPBranches[
    domains_List, internalLines_List, externalLines_List,
    externalScalings_Association, maxBranches_Integer] := Module[
  {n = Length[domains], vertices, allConstraintsPossibleQ, solutions = {}, search},
  vertices = Sort @ DeleteDuplicates[Flatten[internalLines[[All, 2]]]];
  allConstraintsPossibleQ[assignment_] := And @@ Flatten @ Table[
    hrfMomentumVertexPossibleQ[
      vertex, component, assignment, domains, internalLines,
      externalLines, externalScalings
    ],
    {vertex, vertices}, {component, 3}
  ];
  search[assignment_Association] := Module[
    {unassigned, filtered, selectedEdge, candidates},
    If[Length[solutions] >= maxBranches, Return[]];
    If[Length[assignment] == n,
      If[allConstraintsPossibleQ[assignment], AppendTo[solutions, assignment]];
      Return[]
    ];
    unassigned = Complement[Range[n], Keys[assignment]];
    filtered = Association @ Map[
      Function[e,
        e -> Select[domains[[e]],
          allConstraintsPossibleQ[Append[assignment, e -> #]] &]
      ],
      unassigned
    ];
    If[AnyTrue[Values[filtered], # === {} &], Return[]];
    selectedEdge = First @ First @ SortBy[Normal[filtered], Length[Last[#]] &];
    candidates = filtered[selectedEdge];
    Scan[
      Function[state,
        If[Length[solutions] < maxBranches,
          search[Append[assignment, selectedEdge -> state]]
        ]
      ],
      candidates
    ];
  ];
  search[<||>];
  solutions
];

hrfMomentumComponentVertexPossibleQ[
    vertex_, component_, assignment_Association, values_List,
    internalLines_List, externalLines_List, externalScalings_Association] := Module[
  {sets, attached, externalValues, candidates},
  sets = MapIndexed[
    If[MemberQ[#1[[2]], vertex],
      If[KeyExistsQ[assignment, First[#2]],
        {assignment[First[#2]]}, values
      ],
      Nothing
    ] &,
    internalLines
  ];
  attached = Cases[externalLines, {p_, vertex} :> p];
  externalValues = Select[
    Lookup[externalScalings, attached, Missing["ExternalScaling"]][[All, component]],
    hrfMomentumFiniteExponentQ
  ];
  sets = Join[sets, List /@ externalValues];
  If[Length[sets] < 2, Return[False]];
  candidates = DeleteDuplicates[Flatten[sets]];
  AnyTrue[candidates,
    Function[m,
      Count[sets, s_ /; MemberQ[s, m]] >= 2 &&
        And @@ (Max[#] >= m & /@ sets)
    ]
  ]
];

hrfMomentumEnumerateComponentAssignments[
    values_List, component_Integer, internalLines_List, externalLines_List,
    externalScalings_Association] := Module[
  {n = Length[internalLines], vertices, possibleQ, solutions = {}, search},
  vertices = Sort @ DeleteDuplicates[Flatten[internalLines[[All, 2]]]];
  possibleQ[assignment_] := And @@ Table[
    hrfMomentumComponentVertexPossibleQ[
      vertex, component, assignment, values, internalLines,
      externalLines, externalScalings
    ],
    {vertex, vertices}
  ];
  search[assignment_Association] := Module[{unassigned, edge},
    If[Length[assignment] == n,
      If[possibleQ[assignment],
        AppendTo[solutions, Table[assignment[e], {e, n}]]
      ];
      Return[]
    ];
    unassigned = Complement[Range[n], Keys[assignment]];
    edge = First[unassigned];
    Scan[
      Function[value,
        With[{next = Append[assignment, edge -> value]},
          If[possibleQ[next], search[next]]
        ]
      ],
      values
    ];
  ];
  search[<||>];
  Reverse @ SortBy[DeleteDuplicates[solutions], {Min, Total}]
];

hrfMomentumEnumerateFactorizedBranches[
    values_List, virtualities_List, internalLines_List, externalLines_List,
    externalScalings_Association, maxBranches_Integer,
    allowCancellationEnhancedQ_:False] := Module[
  {plus, minus, perp, solutions = {}, allowed, states},
  plus = hrfMomentumEnumerateComponentAssignments[
    values, 1, internalLines, externalLines, externalScalings];
  minus = hrfMomentumEnumerateComponentAssignments[
    values, 2, internalLines, externalLines, externalScalings];
  perp = hrfMomentumEnumerateComponentAssignments[
    values, 3, internalLines, externalLines, externalScalings];
  Catch[
    Do[
      allowed = Table[
        Select[values,
          hrfMomentumVirtualityConstraint[
            {plusRow[[e]], minusRow[[e]], #}, virtualities[[e]],
            allowCancellationEnhancedQ
          ] &
        ],
        {e, Length[virtualities]}
      ];
      If[AllTrue[allowed, # =!= {} &],
        Scan[
          Function[perpRow,
            If[And @@ Table[MemberQ[allowed[[e]], perpRow[[e]]],
                {e, Length[virtualities]}],
              states = Table[
                {plusRow[[e]], minusRow[[e]], perpRow[[e]]},
                {e, Length[virtualities]}
              ];
              AppendTo[solutions, states];
              If[Length[solutions] >= maxBranches, Throw[Null]]
            ]
          ],
          perp
        ]
      ],
      {plusRow, plus}, {minusRow, minus}
    ]
  ];
  <|
    "Solutions" -> solutions,
    "ComponentAssignmentCounts" -> <|
      "Plus" -> Length[plus], "Minus" -> Length[minus],
      "Perp" -> Length[perp]
    |>
  |>
];

hrfMomentumDirectVirtualityStateQ[{a_, b_, c_}, kappa_] :=
  (a + b == kappa && 2 c >= kappa) ||
  (2 c == kappa && a + b >= kappa);

hrfMomentumBalancedAtVirtualityScaleQ[{a_, b_, c_}, kappa_] :=
  a + b == kappa && 2 c == kappa;

(* The propagator assignment is selected before loop modes are inferred.
   Prefer virtualities realized without a cancellation inside q^2; subject
   to that, maximize homogeneous propagators at their actual virtuality
   scale.  Near-on-shell cancellation-enhanced propagators remain available
   when forced by an external on-shell momentum.  Loop-mode faithfulness is
   audited separately, since a Glauber loop can be a difference of two soft
   propagator momenta. *)
hrfMomentumPreferredHomogeneousBranch[
    domains_List, virtualities_List, internalLines_List, externalLines_List,
    externalScalings_Association, edgeVariables_List] := Module[
  {n, found, directSets, balancedSets, filteredDomains, solution, states,
   actualDirect, actualBalanced},
  n = Length[internalLines];
  found = Catch[
    Do[
      directSets = Subsets[Range[n], {directTarget}];
      Scan[
        Function[direct,
          Do[
            balancedSets = Subsets[direct, {balancedTarget}];
            Scan[
              Function[balanced,
                filteredDomains = MapIndexed[
                  Function[{domain, index},
                    Which[
                      MemberQ[balanced, First[index]],
                        Select[domain, Function[state,
                          hrfMomentumBalancedAtVirtualityScaleQ[
                            state, virtualities[[First[index]]]]]],
                      MemberQ[direct, First[index]],
                        Select[domain, Function[state,
                          hrfMomentumDirectVirtualityStateQ[
                            state, virtualities[[First[index]]]]]],
                      True, domain
                    ]
                  ],
                  domains
                ];
                If[AllTrue[filteredDomains, # =!= {} &],
                  solution = hrfMomentumEnumerateCSPBranches[
                    filteredDomains, internalLines, externalLines,
                    externalScalings, 1
                  ];
                  If[solution =!= {},
                    Throw[<|
                      "RequiredDirectEdgeIndices" -> direct,
                      "RequiredBalancedEdgeIndices" -> balanced,
                      "Assignment" -> First[solution]
                    |>]
                  ]
                ]
              ],
              balancedSets
            ],
            {balancedTarget, directTarget, 0, -1}
          ]
        ],
        directSets
      ],
      {directTarget, n, 0, -1}
    ];
    Missing["NoMomentumScalingBranch"]
  ];
  If[MissingQ[found], Return[found]];
  states = Table[found["Assignment"][e], {e, n}];
  actualDirect = Select[Range[n],
    hrfMomentumDirectVirtualityStateQ[
      states[[#]], virtualities[[#]]] &];
  actualBalanced = Select[Range[n],
    hrfMomentumBalancedAtVirtualityScaleQ[
      states[[#]], virtualities[[#]]] &];
  <|
    "EdgeComponentPowers" -> AssociationThread[edgeVariables, states],
    "ComponentBalanceTypes" -> AssociationThread[
      edgeVariables, hrfMomentumVirtualityType /@ states],
    "RequiredDirectEdges" -> edgeVariables[[
      found["RequiredDirectEdgeIndices"]]],
    "RequiredBalancedEdges" -> edgeVariables[[
      found["RequiredBalancedEdgeIndices"]]],
    "DirectVirtualityEdges" -> edgeVariables[[actualDirect]],
    "DirectVirtualityPropagatorCount" -> Length[actualDirect],
    "BalancedAtVirtualityScaleEdges" -> edgeVariables[[actualBalanced]],
    "BalancedAtVirtualityScalePropagatorCount" -> Length[actualBalanced]
  |>
];

Options[hrfMomentumScalingReconstruct] = {
  "NormalizeLPScalingQ" -> True,
  "HardVirtualityPower" -> 0,
  "AllowCancellationEnhancedVirtualityQ" -> False,
  "ExponentBounds" -> Automatic,
  "MaximumBranches" -> 64,
  "ExponentDomain" -> Integers,
  "ExponentStep" -> 1/2,
  "SolverMethod" -> "BacktrackingCSP",
  "StatePreference" -> "NoSuperhard",
  "SelectPreferredPhysicalBranchQ" -> False,
  "SelectPreferredHomogeneousBranchQ" -> False
};

hrfMomentumScalingReconstruct[
    internalLines_List, externalLines_List, edgeVariables_List,
    lpScalingInput_, externalScalings_Association, OptionsPattern[]] := Module[
  {n, lpVector, normalizedLP, virtualities, edgeSymbols, unknowns, vertices,
   vertexTerms, vertexConstraints, virtualityConstraints, bounds, lower, upper,
   boundConstraints, constraints, domain, maxBranches, instances, branches,
   step, stateDomains, cspSolutions, method, hardVirtualityPower,
   allowCancellationEnhancedQ, preferredHomogeneousBranch},

  n = Length[internalLines];
  If[Length[edgeVariables] =!= n,
    Return[<|"Status" -> "EdgeVariableLengthMismatch"|>]
  ];
  lpVector = Which[
    AssociationQ[lpScalingInput], Lookup[lpScalingInput, edgeVariables, Missing["LPScaling"]],
    ListQ[lpScalingInput], lpScalingInput,
    True, Return[<|"Status" -> "MalformedLPScaling"|>]
  ];
  If[Length[lpVector] =!= n || ! FreeQ[lpVector, _Missing],
    Return[<|"Status" -> "MalformedLPScaling"|>]
  ];
  normalizedLP = If[TrueQ[OptionValue["NormalizeLPScalingQ"]],
    lpVector - Max[lpVector], lpVector
  ];
  hardVirtualityPower = OptionValue["HardVirtualityPower"];
  virtualities = hardVirtualityPower - normalizedLP;
  allowCancellationEnhancedQ = TrueQ[
    OptionValue["AllowCancellationEnhancedVirtualityQ"]];
  edgeSymbols = hrfMomentumEdgeSymbols[n];
  unknowns = Flatten[edgeSymbols];
  vertices = Sort @ DeleteDuplicates[Flatten[internalLines[[All, 2]]]];

  vertexTerms = Association @ Flatten @ Table[
    With[{terms = hrfMomentumVertexComponentTerms[
        vertex, component, internalLines, edgeSymbols, externalLines,
        externalScalings]},
      {ToString[vertex] <> ":" <> {"plus", "minus", "perp"}[[component]] -> terms}
    ],
    {vertex, vertices}, {component, 3}
  ];
  vertexConstraints = hrfMomentumMinimumAttainedTwiceConstraint /@ Values[vertexTerms];
  virtualityConstraints = MapThread[
    hrfMomentumVirtualityConstraint[#1, #2,
      allowCancellationEnhancedQ] &,
    {edgeSymbols, virtualities}
  ];

  bounds = Replace[OptionValue["ExponentBounds"], Automatic :> {
      Min[-4, Min[Cases[Flatten[Values[externalScalings]], _Integer | _Rational]] - 2],
      Max[6, Max[virtualities] + 2]
    }];
  {lower, upper} = bounds;
  boundConstraints = And @@ Thread[lower <= unknowns <= upper];
  constraints = And[
    And @@ vertexConstraints,
    And @@ virtualityConstraints,
    boundConstraints
  ];
  domain = OptionValue["ExponentDomain"];
  maxBranches = OptionValue["MaximumBranches"];
  step = OptionValue["ExponentStep"];
  method = OptionValue["SolverMethod"];
  stateDomains = hrfMomentumVirtualityStateDomain[
      #, bounds, step, allowCancellationEnhancedQ] & /@ virtualities;
  If[OptionValue["StatePreference"] === "NoSuperhard",
    stateDomains = Map[
      SortBy[#, {(-Min[#]) &, (-Total[#]) &}] &,
      stateDomains
    ]
  ];
  If[AnyTrue[stateDomains, # === {} &],
    Return[<|"Status" -> "EmptyVirtualityStateDomain",
      "VirtualityPowers" -> AssociationThread[edgeVariables, virtualities]|>]
  ];
  preferredHomogeneousBranch = If[
    TrueQ[OptionValue["SelectPreferredPhysicalBranchQ"]] ||
      TrueQ[OptionValue["SelectPreferredHomogeneousBranchQ"]],
    With[{preferred = hrfMomentumPreferredHomogeneousBranch[
        stateDomains, virtualities, internalLines, externalLines,
        externalScalings,
        edgeVariables]},
      If[AssociationQ[preferred],
        Join[preferred, <|
          "VirtualityPowers" -> AssociationThread[
            edgeVariables, virtualities],
          "VirtualityTypes" -> AssociationThread[
            edgeVariables,
            MapThread[hrfMomentumVirtualityRealizationType,
              {Values[preferred["EdgeComponentPowers"]], virtualities}]
          ]
        |>],
        preferred
      ]
    ],
    Missing["NotRequested"]
  ];
  If[method === "ComponentFactorizedCSP",
    With[{factorized = hrfMomentumEnumerateFactorizedBranches[
        Reverse @ Range[lower, upper, step], virtualities,
        internalLines, externalLines, externalScalings, maxBranches,
        allowCancellationEnhancedQ]},
      cspSolutions = Lookup[factorized, "Solutions", {}];
      branches = MapIndexed[
        Function[{states, index},
          <|
            "BranchIndex" -> First[index],
            "Rules" -> Flatten @ MapThread[Thread[#1 -> #2] &,
              {edgeSymbols, states}],
            "EdgeComponentPowers" -> AssociationThread[edgeVariables, states],
            "VirtualityPowers" -> AssociationThread[edgeVariables, virtualities],
            "VirtualityTypes" -> AssociationThread[
              edgeVariables,
              MapThread[hrfMomentumVirtualityRealizationType,
                {states, virtualities}]
            ],
            "ComponentBalanceTypes" -> AssociationThread[
              edgeVariables, hrfMomentumVirtualityType /@ states
            ],
            "ComponentAssignmentCounts" ->
              Lookup[factorized, "ComponentAssignmentCounts", <||>]
          |>
        ],
        cspSolutions
      ]
    ],
  If[method === "BacktrackingCSP",
    cspSolutions = hrfMomentumEnumerateCSPBranches[
      stateDomains, internalLines, externalLines, externalScalings, maxBranches
    ];
    branches = MapIndexed[
      Function[{assignment, index},
        With[{states = Table[assignment[e], {e, n}]},
          <|
            "BranchIndex" -> First[index],
            "Rules" -> Flatten @ MapThread[Thread[#1 -> #2] &,
              {edgeSymbols, states}],
            "EdgeComponentPowers" -> AssociationThread[edgeVariables, states],
            "VirtualityPowers" -> AssociationThread[edgeVariables, virtualities],
            "VirtualityTypes" -> AssociationThread[
              edgeVariables,
              MapThread[hrfMomentumVirtualityRealizationType,
                {states, virtualities}]
            ]
            ,"ComponentBalanceTypes" -> AssociationThread[
              edgeVariables, hrfMomentumVirtualityType /@ states
            ]
          |>
        ]
      ],
      cspSolutions
    ],
    instances = Quiet @ Check[
      FindInstance[constraints, unknowns, domain, maxBranches],
      $Failed
    ];
    If[instances === $Failed,
      Return[<|"Status" -> "SolverFailed", "Constraints" -> constraints|>]
    ];
    branches = MapIndexed[
      Function[{rules, index},
        <|
          "BranchIndex" -> First[index],
          "Rules" -> rules,
          "EdgeComponentPowers" -> AssociationThread[
            edgeVariables, (edgeSymbols /. rules)
          ],
          "VirtualityPowers" -> AssociationThread[edgeVariables, virtualities],
          "VirtualityTypes" -> AssociationThread[
            edgeVariables,
            MapThread[hrfMomentumVirtualityRealizationType,
              {(edgeSymbols /. rules), virtualities}]
          ]
          ,"ComponentBalanceTypes" -> AssociationThread[
            edgeVariables,
            hrfMomentumVirtualityType /@ (edgeSymbols /. rules)
          ]
        |>
      ],
      instances
    ]
  ]];
  <|
    "Status" -> If[branches === {}, "NoSolution", "Solved"],
    "LPScalingInput" -> AssociationThread[edgeVariables, lpVector],
    "NormalizedLPScaling" -> AssociationThread[edgeVariables, normalizedLP],
    "HardVirtualityPower" -> hardVirtualityPower,
    "AllowCancellationEnhancedVirtualityQ" ->
      allowCancellationEnhancedQ,
    "VirtualityPowers" -> AssociationThread[edgeVariables, virtualities],
    "ExternalComponentPowers" -> externalScalings,
    "EdgeComponentSymbols" -> AssociationThread[edgeVariables, edgeSymbols],
    "VertexComponentTerms" -> vertexTerms,
    "Constraints" -> constraints,
    "ExponentBounds" -> bounds,
    "ExponentStep" -> step,
    "VirtualityStateDomainSizes" -> AssociationThread[
      edgeVariables, Length /@ stateDomains],
    "BranchCount" -> Length[branches],
    "MaximumBranchesRequested" -> maxBranches,
    "PreferredHomogeneousBranch" -> preferredHomogeneousBranch,
    "Branches" -> branches
  |>
];

(* Every complement of a spanning tree is a propagator-edge choice of
   independent loop variables.  The incidence-rank test remains valid when
   the graph contains parallel edges. *)
hrfMomentumSpanningTreeEdgeSets[internalLines_List] := Module[
  {endpoints, vertices, incidence, candidates, required},
  endpoints = internalLines[[All, 2]];
  vertices = Sort @ DeleteDuplicates @ Flatten[endpoints];
  required = Length[vertices] - 1;
  incidence = Table[
    Which[
      endpoints[[e, 1]] === vertices[[v]], 1,
      endpoints[[e, 2]] === vertices[[v]], -1,
      True, 0
    ],
    {v, Length[vertices]}, {e, Length[endpoints]}
  ];
  candidates = Subsets[Range[Length[endpoints]], {required}];
  Select[candidates, MatrixRank[incidence[[All, #]]] == required &]
];

hrfMomentumVertexRelationMatrix[
    internalLines_List, externalLines_List,
    incomingExternalMomenta_List] := Module[
  {endpoints, externalMomenta, vertices, internalBlock, externalBlock},
  endpoints = internalLines[[All, 2]];
  externalMomenta = externalLines[[All, 1]];
  vertices = Sort @ DeleteDuplicates @ Join[
    Flatten[endpoints], externalLines[[All, 2]]];
  internalBlock = Table[
    Boole[vertices[[v]] === endpoints[[e, 2]]] -
      Boole[vertices[[v]] === endpoints[[e, 1]]],
    {v, Length[vertices]}, {e, Length[endpoints]}
  ];
  externalBlock = Table[
    If[vertices[[v]] === externalLines[[p, 2]],
      If[MemberQ[incomingExternalMomenta, externalMomenta[[p]]], 1, -1],
      0
    ],
    {v, Length[vertices]}, {p, Length[externalLines]}
  ];
  <|
    "Vertices" -> vertices,
    "ExternalMomenta" -> externalMomenta,
    "ColumnLabels" -> Join[Range[Length[internalLines]], externalMomenta],
    "Matrix" -> MapThread[Join, {internalBlock, externalBlock}]
  |>
];

Options[hrfMomentumOptimizedLinearCombinationPower] = {
  "RelationCoefficientRange" -> 1
};

(* An internal-momentum combination has many equivalent expressions after
   adding vertex-conservation equations.  For each light-cone component, the
   largest minimum valuation among these expressions is the generic power
   after all cancellations forced by momentum conservation. *)
hrfMomentumOptimizedLinearCombinationPower[
    targetInternalCoefficients_List, branch_Association,
    edgeVariables_List, internalLines_List, externalLines_List,
    externalScalings_Association, incomingExternalMomenta_List,
    OptionsPattern[]] := Module[
  {relations, matrix, externalMomenta, allPowers, base, coefficientRange,
   shifts, componentRows},
  relations = hrfMomentumVertexRelationMatrix[
    internalLines, externalLines, incomingExternalMomenta];
  matrix = relations["Matrix"];
  externalMomenta = relations["ExternalMomenta"];
  allPowers = Join[
    Lookup[branch["EdgeComponentPowers"], edgeVariables],
    Lookup[externalScalings, externalMomenta]
  ];
  base = Join[targetInternalCoefficients,
    ConstantArray[0, Length[externalMomenta]]];
  coefficientRange = OptionValue["RelationCoefficientRange"];
  shifts = Tuples[
    Range[-coefficientRange, coefficientRange], Length[matrix]];
  componentRows = Table[
    Module[{candidates, bestPower, best},
      candidates = Map[
        Function[y,
          With[{coefficients = base + y . matrix},
            <|
              "Power" -> With[{active = Flatten @ Position[
                    coefficients, _?(# =!= 0 &), {1}, Heads -> False]},
                If[active === {}, Infinity,
                  Min[allPowers[[active, component]]]]
              ],
              "VertexRelationCoefficients" -> y,
              "RepresentationCoefficients" -> coefficients
            |>
          ]
        ],
        shifts
      ];
      bestPower = Max[Lookup[candidates, "Power"]];
      best = First @ Select[candidates, # ["Power"] === bestPower &];
      Join[<|"Component" -> {"plus", "minus", "perp"}[[component]]|>,
        best]
    ],
    {component, 3}
  ];
  <|
    "OptimizedComponentPowers" -> Lookup[componentRows, "Power"],
    "ComponentRows" -> componentRows,
    "ColumnLabels" -> Join[edgeVariables, externalMomenta]
  |>
];

Options[hrfMomentumLoopCombinationAudit] = {
  "RelationCoefficientRange" -> 1
};

hrfMomentumLoopCombinationAudit[
    internalLines_List, externalLines_List, edgeVariables_List,
    branch_Association, externalScalings_Association,
    incomingExternalMomenta_List, OptionsPattern[]] := Module[
  {n, trees, chordSets, loopNumber, coefficientVectors, canonicalTarget,
   rawRows, rows},
  n = Length[internalLines];
  trees = hrfMomentumSpanningTreeEdgeSets[internalLines];
  chordSets = Complement[Range[n], #] & /@ trees;
  loopNumber = If[chordSets === {}, 0, Length[First[chordSets]]];
  coefficientVectors = DeleteCases[
    Tuples[{-1, 0, 1}, loopNumber], {0 ..}];
  canonicalTarget[target_] := Module[{first = SelectFirst[target, # =!= 0 &]},
    If[first < 0, -target, target]
  ];
  rawRows = Flatten @ Map[
    Function[chords,
      Map[
        Function[coefficients,
          Module[{target, active, naive, optimized, powers},
            target = ConstantArray[0, n];
            target[[chords]] = coefficients;
            target = canonicalTarget[target];
            active = Flatten @ Position[target, _?(# =!= 0 &), {1},
              Heads -> False];
            naive = Min /@ Transpose[
              Lookup[branch["EdgeComponentPowers"],
                edgeVariables[[active]]]];
            optimized = hrfMomentumOptimizedLinearCombinationPower[
              target, branch, edgeVariables, internalLines, externalLines,
              externalScalings, incomingExternalMomenta,
              "RelationCoefficientRange" ->
                OptionValue["RelationCoefficientRange"]];
            powers = optimized["OptimizedComponentPowers"];
            <|
              "TargetInternalCoefficients" ->
                AssociationThread[edgeVariables, target],
              "SourceEdgeBasis" -> edgeVariables[[chords]],
              "NaiveComponentPowers" -> naive,
              "OptimizedComponentPowers" -> powers,
              "ForcedCancellationComponents" -> Pick[
                {"plus", "minus", "perp"},
                MapThread[Greater, {powers, naive}]],
              "ForcedCancellationQ" -> Or @@
                MapThread[Greater, {powers, naive}],
              "ModeType" -> hrfMomentumVirtualityType[powers],
              "GlauberLikeQ" ->
                hrfMomentumVirtualityType[powers] ===
                  "TransverseDominated",
              "OptimizationCertificate" -> optimized
            |>
          ]
        ],
        coefficientVectors
      ]
    ],
    chordSets
  ];
  rows = DeleteDuplicatesBy[rawRows,
    Values[# ["TargetInternalCoefficients"]] &];
  <|
    "LoopNumber" -> loopNumber,
    "CombinationRows" -> rows,
    "ForcedCancellationRows" -> Select[rows,
      TrueQ[# ["ForcedCancellationQ"]] &],
    "GlauberCombinationRows" -> Select[rows,
      TrueQ[# ["ForcedCancellationQ"]] &&
        TrueQ[# ["GlauberLikeQ"]] &],
    "GlauberCombinationFoundQ" -> AnyTrue[rows,
      TrueQ[# ["ForcedCancellationQ"]] &&
        TrueQ[# ["GlauberLikeQ"]] &]
  |>
];

hrfMomentumEdgeBasisAudit[
    internalLines_List, edgeVariables_List, branch_Association] := Module[
  {trees, allEdges, balanceTypes, rows, minimum},
  trees = hrfMomentumSpanningTreeEdgeSets[internalLines];
  allEdges = Range[Length[internalLines]];
  balanceTypes = Lookup[branch, "ComponentBalanceTypes",
    AssociationMap[
      hrfMomentumVirtualityType,
      branch["EdgeComponentPowers"]
    ]
  ];
  rows = Map[
    Function[tree,
      With[{chords = Complement[allEdges, tree]},
        <|
          "SpanningTreeEdges" -> edgeVariables[[tree]],
          "IndependentLoopEdges" -> edgeVariables[[chords]],
          "IndependentLoopBalanceTypes" ->
            Lookup[balanceTypes, edgeVariables[[chords]]],
          "NonBalancedIndependentLoopCount" -> Count[
            Lookup[balanceTypes, edgeVariables[[chords]]],
            Except["Balanced"]
          ]
        |>
      ]
    ],
    trees
  ];
  minimum = If[rows === {}, Missing["NoEdgeLoopBasis"],
    Min[Lookup[rows, "NonBalancedIndependentLoopCount"]]
  ];
  <|
    "EdgeLoopBasisCount" -> Length[rows],
    "MinimumNonBalancedIndependentLoops" -> minimum,
    "AllBalancedEdgeLoopBasisExistsQ" -> TrueQ[minimum == 0],
    "RoutingRobustNonBalancedModeQ" -> IntegerQ[minimum] && minimum > 0,
    "BasisRows" -> rows
  |>
];

hrfMomentumScalingBranchSummary[result_Association] := Dataset @ Map[
  Function[branch,
    Association @ Map[
      Function[edge,
        edge -> <|
          "(+,-,perp)" -> branch["EdgeComponentPowers"][edge],
          "q^2 power" -> branch["VirtualityPowers"][edge],
          "type" -> branch["VirtualityTypes"][edge]
        |>
      ],
      Keys[branch["EdgeComponentPowers"]]
    ]
  ],
  Lookup[result, "Branches", {}]
];
