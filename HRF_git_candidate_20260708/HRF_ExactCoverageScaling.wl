(* Exact Lee--Pomeransky coverage-scaling feasibility.

   This helper is loaded by HiddenRegionFinder.wl and can also be loaded
   explicitly for comparison with the bounded findCoverageLPScaling routine.
   It implements the paper conditions
   (5.22)--(5.25) as a finite enumeration of rational linear feasibility
   problems:

     - all F_SL monomials have common weight W_SL,
     - all non-SL monomials have weight at least W_HR,
    - W_HR > W_SL, with explicit delta powers included through the
      augmented rows (r_i; a_i),
     - every active variable is covered either by F_SL or by a non-SL monomial
       at W_HR.

   When all post-cancellation terms have a_i=0 this reduces to the old
   homogeneous problem.  When restored F_delta layers are supplied, the
   delta component of the region vector is fixed to one and the physical
   gap is solved directly.

   The only disjunction is the coverage condition: every active variable
   missing from F_SL must be supplied by at least one non-SL monomial on the
   W_HR face.  We enumerate these finite face choices explicitly and solve
   ordinary linear feasibility for each choice. *)

ClearAll[
  hrfExactPrimitiveIntegerVector,
  hrfExactRowsSupportPositions,
  hrfExactRowsCoverVariables,
  hrfExactScalingSignConstraints,
  hrfExactScalingSignConstraintList,
  hrfExactCoverageFailure,
  hrfExactCoverageChoiceSets,
  hrfExactLinearFeasibleSolution,
  hrfExactLinearPositiveGapSolution,
  hrfExactCoverageSearch,
  findExactCoverageLPScaling
];

Options[findExactCoverageLPScaling] = {
  "ScalingSign" -> "NonPositive",
  "TimeLimit" -> Infinity,
  "MaxInstances" -> 1
};

hrfExactPrimitiveIntegerVector[v_List] := Module[
  {rat, den, ints, g},
  rat = Rationalize[v, 0];
  den = LCM @@ Denominator[rat];
  ints = den rat;
  g = GCD @@ DeleteCases[Abs[ints], 0];
  If[g === 0 || g === GCD[], ints, ints/g]
];

hrfExactRowsSupportPositions[rows_List] := Module[{mat},
  If[rows === {}, Return[{}]];
  mat = Unitize[rows];
  Flatten @ Position[Total[mat], _?(# > 0 &)]
];

hrfExactRowsCoverVariables[rows_List, vars_List] := vars[[hrfExactRowsSupportPositions[rows]]];

hrfExactScalingSignConstraints[r_List, "NonPositive"] := And @@ Thread[r <= 0];
hrfExactScalingSignConstraints[r_List, "Mixed"] := True;
hrfExactScalingSignConstraints[r_List, _] := And @@ Thread[r <= 0];

hrfExactScalingSignConstraintList[r_List, "NonPositive"] := Thread[r <= 0];
hrfExactScalingSignConstraintList[r_List, "Mixed"] := {};
hrfExactScalingSignConstraintList[r_List, _] := Thread[r <= 0];

hrfExactCoverageFailure[missingPositions_List, postRows_List, r_List, wHR_] := Module[
  {rowWeights, leadingRows},
  rowWeights = hrfWeightedRowWeightExpr[#, r] & /@ postRows;
  leadingRows = Pick[postRows, rowWeights, wHR];
  Complement[missingPositions, hrfWeightedRowsSupportPositions[leadingRows]]
];

hrfExactCoverageChoiceSets[missingPositions_List, postRows_List] := Module[
  {perPositionChoices},
  If[postRows === {},
    Return[<|"PossibleQ" -> False, "MissingPositions" -> missingPositions,
      "PerPositionChoices" -> <||>, "Reason" -> "NoPostRows"|>]
  ];
  If[missingPositions === {},
    Return[<|"PossibleQ" -> True, "MissingPositions" -> {},
      "PerPositionChoices" -> <||>, "Reason" -> "OnlyNonEmptyPostFaceRequired"|>]
  ];
  perPositionChoices = Association @ Table[
    pos -> Flatten @ Position[
      postRows,
      row_ /; With[{raw = Lookup[row, "Row", row]}, ListQ[raw] && Length[raw] >= pos && raw[[pos]] > 0],
      {1},
      Heads -> False
    ],
    {pos, missingPositions}
  ];
  <|
    "PossibleQ" -> ! MemberQ[Values[perPositionChoices], {}],
    "MissingPositions" -> missingPositions,
    "PerPositionChoices" -> perPositionChoices,
    "Reason" -> If[MemberQ[Values[perPositionChoices], {}], "UncoveredMissingVariable", "CoverageChoicesAvailable"]
  |>
];

hrfExactLinearFeasibleSolution[constraints_List, vars_List] := Module[{sol},
  sol = Quiet @ Check[
    LinearOptimization[0, And @@ constraints, vars, {"PrimalMinimizer", "PrimalMinimumValue"}],
    $Failed
  ];
  If[ListQ[sol] && Length[sol] >= 1 && VectorQ[First[sol], NumericQ],
    Rationalize[First[sol], 0],
    $Failed
  ]
];

hrfExactLinearPositiveGapSolution[constraints_List, vars_List, gapVar_] := Module[
  {sol, vec, gap},
  sol = Quiet @ Check[
    LinearOptimization[-gapVar, And @@ constraints, vars, {"PrimalMinimizer", "PrimalMinimumValue"}],
    $Failed
  ];
  If[ListQ[sol] && Length[sol] >= 1 && VectorQ[First[sol], NumericQ],
    vec = Rationalize[First[sol], 0];
    gap = Rationalize[gapVar /. Thread[vars -> vec], 0];
    If[TrueQ[gap > 0], Return[vec]]
  ];
  (* If the positive-gap objective is unbounded, ask only for a unit witness.
     This is not a normalization; it is just a convenient feasible point. *)
  hrfExactLinearFeasibleSolution[Join[constraints, {gapVar >= 1}], vars]
];

hrfExactCoverageSearch[baseConstraints_List, postRows_List, r_List, wHR_, choiceData_Association,
   lpVars_List, gapVar_:None] :=
  Catch[
    Module[{checked = 0, missing, perPositionChoices, tryChoice, search, result},

      If[! TrueQ[Lookup[choiceData, "PossibleQ", False]],
        Return[<|"FoundQ" -> False, "LPCheckCount" -> 0, "CoverageChoiceCount" -> 0|>]
      ];

      missing = Lookup[choiceData, "MissingPositions", {}];
      perPositionChoices = Lookup[choiceData, "PerPositionChoices", <||>];

      tryChoice[choice_List] := Module[{sol},
        checked++;
        sol = With[
          {constraints = Join[baseConstraints, ((hrfWeightedRowWeightExpr[#, r] == wHR) & /@ postRows[[choice]])]},
          If[gapVar === None,
            hrfExactLinearFeasibleSolution[constraints, lpVars],
            hrfExactLinearPositiveGapSolution[constraints, lpVars, gapVar]
          ]
        ];
        If[sol =!= $Failed,
          <|"FoundQ" -> True, "Scaling" -> Take[sol, Length[r]], "WHR" -> sol[[Length[r] + 1]],
            "PostFaceChoiceIndices" -> choice, "LPCheckCount" -> checked,
            "CoverageChoiceCount" -> checked|>,
          $Failed
        ]
      ];

      If[missing === {},
        Do[
          result = tryChoice[{idx}];
          If[AssociationQ[result], Throw[result, hrfExactCoverageFound]],
          {idx, Range[Length[postRows]]}
        ];
        Return[<|"FoundQ" -> False, "LPCheckCount" -> checked, "CoverageChoiceCount" -> checked|>]
      ];

      search[covered_List, chosen_List] := Module[
        {remaining, pos, candidates, idx, newCovered, result},
        remaining = Complement[missing, covered];
        If[remaining === {},
          result = tryChoice[chosen];
          If[AssociationQ[result], Throw[result, hrfExactCoverageFound]];
          Return[$Failed]
        ];
        pos = First @ MinimalBy[remaining, Length[Lookup[perPositionChoices, #, {}]] &];
        candidates = Lookup[perPositionChoices, pos, {}];
        Do[
          idx = candidate;
          newCovered = Union[
            covered,
            Intersection[missing, hrfWeightedRowsSupportPositions[{postRows[[idx]]}]]
          ];
          search[newCovered, Sort[Append[chosen, idx]]],
          {candidate, candidates}
        ];
        $Failed
      ];

      search[{}, {}];
      <|"FoundQ" -> False, "LPCheckCount" -> checked, "CoverageChoiceCount" -> checked|>
    ],
    hrfExactCoverageFound
  ];

findExactCoverageLPScaling[fSL_, U_, vars_, fObs_:None, OptionsPattern[]] := Module[
  {fSLList, fSLRows, fSLRowsFlat, URows, fObsRows, postRows,
   nvars, r, wHR, wSL, gapVar, signMode, signConstraints, baseConstraints,
   coveragePositions, missingPositions, choiceData, search, runSearch, timeLimit,
   rRat, wHRRat, wSLRat, primitive, scalingOut, gapOut, postWeights,
   leadingPostRows, fSLVars, postVars, coveredVars, status, message,
   maxInstances, lpVars, weightedPostQ, fSLWeightOut, postLeadingWeightOut},

  fSLList = DeleteCases[Flatten[{fSL}], 0];
  If[fSLList === {} || U === 0,
    Return[<|"Scaling" -> Missing["NoFSLOrU"],
      "CandidateGenerationMethod" -> "ExactCoverageFaceEnumerationLP",
      "ScalingStatus" -> "NoFSLOrU",
      "ScalingStatusMessage" -> "No nonzero F_SL or U polynomial supplied"|>]
  ];

  fSLRows = polynomialExponentRows[#, vars] & /@ fSLList;
  URows = hrfWeightedRowsFromPolynomial[U, vars, 0, "U"];
  fObsRows = hrfWeightedRowsFromLayers[hrfWeightedPostLayerData[fObs, "FObs"], vars];
  If[MemberQ[fSLRows, {}] || URows === {},
    Return[<|"Scaling" -> Missing["EmptyExponentSupport"],
      "CandidateGenerationMethod" -> "ExactCoverageFaceEnumerationLP",
      "ScalingStatus" -> "EmptyExponentSupport",
      "ScalingStatusMessage" -> "F_SL or post-cancellation polynomial has empty exponent support"|>]
  ];

  fSLRowsFlat = DeleteDuplicates[Join @@ fSLRows];
  postRows = DeleteDuplicatesBy[
    Join[URows, fObsRows],
    {Lookup[#, "Power", 0], Lookup[#, "Row", {}], Lookup[#, "Source", "Post"]} &
  ];
  weightedPostQ = AnyTrue[postRows, ! TrueQ[Lookup[#, "Power", 0] === 0] &];
  nvars = Length[vars];
  r = Array[Unique["rho"] &, nvars];
  wHR = Unique["wHR"];
  gapVar = If[weightedPostQ, Unique["gap"], None];
  wSL = fSLRowsFlat[[1]].r;
  signMode = OptionValue["ScalingSign"];
  signConstraints = hrfExactScalingSignConstraintList[r, signMode];
  lpVars = If[weightedPostQ, Join[r, {wHR, gapVar}], Join[r, {wHR}]];

  coveragePositions = hrfExactRowsSupportPositions[fSLRowsFlat];
  missingPositions = Complement[Range[nvars], coveragePositions];
  choiceData = hrfExactCoverageChoiceSets[missingPositions, postRows];
  baseConstraints = Join[
    ((#.r == wSL) & /@ fSLRowsFlat),
    ((hrfWeightedRowWeightExpr[#, r] >= wHR) & /@ postRows),
    If[weightedPostQ, {gapVar >= 0, wHR - wSL >= gapVar}, {wHR == wSL + 1}],
    signConstraints
  ];

  timeLimit = OptionValue["TimeLimit"];
  maxInstances = OptionValue["MaxInstances"];
  runSearch[] := hrfExactCoverageSearch[baseConstraints, postRows, r, wHR, choiceData, lpVars, gapVar];
  search = If[timeLimit === Infinity || timeLimit === None,
    runSearch[],
    TimeConstrained[runSearch[], timeLimit, $TimedOut]
  ];

  If[search === $TimedOut,
    Return[<|"Scaling" -> Missing["ExactCoverageTimedOut", timeLimit],
      "CandidateGenerationMethod" -> "ExactCoverageFaceEnumerationLP",
      "ScalingStatus" -> "TimedOut",
      "ScalingStatusMessage" -> "Exact face-enumerated linear coverage feasibility timed out",
      "ScalingSearchCompleteQ" -> False,
      "ExplicitDeltaWeightsRestoredQ" -> weightedPostQ,
      "CoverageChoiceCount" -> Missing["TimedOutBeforeComplete"],
      "MissingVariablesBeforePostFace" -> vars[[missingPositions]]|>]
  ];

  If[! TrueQ[Lookup[search, "FoundQ", False]],
    status = "NoValidScaling";
    message = "No exact rational scaling satisfies F_SL homogeneity, W_HR>W_SL, post-face inequalities, sign constraints, and coverage";
    Return[<|"Scaling" -> Missing["NoExactCoverageScaling"],
      "CandidateGenerationMethod" -> "ExactCoverageFaceEnumerationLP",
      "AcceptedCount" -> 0,
      "ScalingStatus" -> status,
      "ScalingStatusMessage" -> message,
      "ScalingSearchCompleteQ" -> True,
      "ExplicitDeltaWeightsRestoredQ" -> weightedPostQ,
      "CoverageChoiceCount" -> Lookup[search, "CoverageChoiceCount", 0],
      "LPCheckCount" -> Lookup[search, "LPCheckCount", 0],
      "MissingVariablesBeforePostFace" -> vars[[missingPositions]],
      "Criteria" -> <|
        "FSLCancellation" -> "all monomials in F_SL have common weight W_SL",
        "HiddenHierarchy" -> If[weightedPostQ,
          "post-cancellation leading weight W_HR is strictly above W_SL using augmented rows (r_i; a_i); the gap is derived",
          "post-cancellation leading weight W_HR is fixed to W_SL+1 by homogeneous normalization"],
        "PostFace" -> "all post-cancellation monomials have augmented weight >= W_HR",
        "Coverage" -> "active variables appear in F_SL or in post-cancellation monomials at W_HR",
        "Sign" -> signMode|>|>]
  ];

  rRat = Rationalize[search["Scaling"], 0];
  wHRRat = Rationalize[search["WHR"], 0];
  wSLRat = Rationalize[wSL /. Thread[r -> rRat], 0];
  primitive = hrfExactPrimitiveIntegerVector[rRat];
  scalingOut = If[weightedPostQ, rRat, primitive];
  postWeights = hrfWeightedRowWeight[#, scalingOut] & /@ postRows;
  fSLWeightOut = If[weightedPostQ, wSLRat, fSLRowsFlat[[1]].primitive];
  postLeadingWeightOut = Min[postWeights];
  gapOut = postLeadingWeightOut - fSLWeightOut;
  leadingPostRows = Pick[postRows, postWeights, postLeadingWeightOut];
  fSLVars = hrfExactRowsCoverVariables[fSLRowsFlat, vars];
  postVars = hrfWeightedRowsCoverVariables[leadingPostRows, vars];
  coveredVars = Union[fSLVars, postVars];

  <|
    "Scaling" -> scalingOut,
    "RationalScaling" -> rRat,
    "PrimitiveScaling" -> primitive,
    "RationalScalingWithUnitGap" -> rRat,
    "PrimitiveHierarchyGap" -> If[weightedPostQ, Missing["NotHomogeneous"], gapOut],
    "UnitGapNormalizationQ" -> ! weightedPostQ,
    "ExplicitDeltaWeightsRestoredQ" -> weightedPostQ,
    "CandidateGenerationMethod" -> "ExactCoverageFaceEnumerationLP",
    "AcceptedCount" -> 1,
    "ScalingStatus" -> "Found",
    "ScalingStatusMessage" -> "Exact face-enumerated rational coverage scaling found",
    "ScalingSearchCompleteQ" -> True,
    "CoverageChoiceCount" -> Lookup[search, "CoverageChoiceCount", Missing["NotAvailable"]],
    "LPCheckCount" -> Lookup[search, "LPCheckCount", Missing["NotAvailable"]],
    "PostFaceChoiceIndicesUnitGap" -> Lookup[search, "PostFaceChoiceIndices", Missing["NotAvailable"]],
    "VariableScaling" -> AssociationThread[vars, scalingOut],
    "RationalVariableScaling" -> AssociationThread[vars, rRat],
    "RationalVariableScalingWithUnitGap" -> AssociationThread[vars, rRat],
    "FSLWeightPrimitive" -> fSLWeightOut,
    "PostCancellationLeadingWeightPrimitive" -> postLeadingWeightOut,
    "HierarchyGapPostLPminusFSL" -> gapOut,
    "FSLWeightUnitGap" -> wSLRat,
    "PostCancellationLeadingWeightUnitGap" -> wHRRat,
    "FSLExponentRows" -> fSLRowsFlat,
    "PostCancellationExponentRowCount" -> Length[postRows],
    "PostCancellationLeadingRows" -> leadingPostRows,
    "PostCancellationLeadingPowers" -> Sort @ DeleteDuplicates[Lookup[#, "Power", 0] & /@ leadingPostRows],
    "PostCancellationLeadingSources" -> Tally[Lookup[#, "Source", "Post"] & /@ leadingPostRows],
    "VariablesCoveredByFSLAtWSL" -> fSLVars,
    "VariablesInPostCancellationLeadingSupport" -> postVars,
    "VariablesCoveredByLeadingRegionMonomials" -> coveredVars,
    "VariablesMissingFromLeadingRegionCoverage" -> Complement[vars, coveredVars],
    "LeadingRegionCoverageQ" -> (Complement[vars, coveredVars] === {}),
    "MissingVariablesBeforePostFace" -> vars[[missingPositions]],
    "Criteria" -> <|
      "FSLCancellation" -> "all monomials in F_SL have common weight W_SL",
      "HiddenHierarchy" -> If[weightedPostQ,
        "post-cancellation leading weight W_HR is strictly above W_SL using augmented rows (r_i; a_i); the gap is derived",
        "post-cancellation leading weight W_HR is fixed to W_SL+1 by homogeneous normalization"],
      "PostFace" -> "all post-cancellation monomials have augmented weight >= W_HR",
      "Coverage" -> "active variables appear in F_SL or in post-cancellation monomials at W_HR",
      "Sign" -> signMode|>
  |>
];
