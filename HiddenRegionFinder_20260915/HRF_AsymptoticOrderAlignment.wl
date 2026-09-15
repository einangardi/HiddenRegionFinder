(* ::Package:: *)
(* HRF_AsymptoticOrderAlignment.wl

   Pre-HRF asymptotic-order alignment layer.

   The input is the full eta-dependent LP/Symanzik polynomial after a
   kinematic scaling chart has been chosen.  The layer enumerates exposed
   faces, applies the recursive mixed-derivative preselection to each face,
   and runs HRF only on terminal strata that survive the preselection.
*)

ClearAll[
  hrfAsymptoticOrderAlignmentPackageDirectory, hrfAsymptoticOrderAlignmentLoadDependency,
  hrfAsymptoticOrderAlignmentPolynomialTerms, hrfAsymptoticOrderAlignmentTermEtaPower,
  hrfAsymptoticOrderAlignmentTermXRow, hrfAsymptoticOrderAlignmentActiveSupport,
  hrfAsymptoticOrderAlignmentTermTable, hrfAsymptoticOrderAlignmentFaceFromVector,
  hrfAsymptoticOrderAlignmentEnumerateFaces, hrfAsymptoticOrderAlignmentRunHRF,
  hrfAsymptoticOrderAlignmentFaceScanRow, hrfAsymptoticOrderAlignmentSearch,
  hrfAsymptoticOrderAlignmentScanSummary, hrfAsymptoticOrderAlignmentCompact,
  hrfAsymptoticOrderAlignmentMandelstamLinearQ,
  hrfAsymptoticOrderAlignmentXFreeQ, hrfAsymptoticOrderAlignmentStripXFreeFactors,
  hrfAsymptoticOrderAlignmentCanonicalPolynomialKey, hrfAsymptoticOrderAlignmentCanonicalGeneratorKey,
  hrfAsymptoticOrderAlignmentNormalizeVector, hrfAsymptoticOrderAlignmentDedupKey,
  hrfAsymptoticOrderAlignmentStructuralDedupKey, hrfAsymptoticOrderAlignmentRepresentativeRow,
  hrfAsymptoticOrderAlignmentDeduplicateRows, hrfAsymptoticOrderAlignmentStrictDeduplicateRows,
  hrfAsymptoticOrderAlignmentStructuralDeduplicateRows,
  hrfAsymptoticOrderAlignmentTotalLowerFacetAudit, hrfAsymptoticOrderAlignmentApplyTotalLowerFacetAudit
];

hrfAsymptoticOrderAlignmentPackageDirectory[] := Module[{inp},
  If[Length[DownValues[hrfPackageDirectory]] > 0,
    Return[Quiet @ Check[hrfPackageDirectory[], Directory[]]]
  ];
  inp = Quiet @ Check[$InputFileName, ""];
  If[StringQ[inp] && inp =!= "" && FileExistsQ[inp], Return[DirectoryName[inp]]];
  Directory[]
];

hrfAsymptoticOrderAlignmentLoadDependency[file_String, symbolName_String] := Module[{sym},
  sym = ToExpression[symbolName];
  If[Length[DownValues[sym]] == 0,
    Quiet @ Check[Get[FileNameJoin[{hrfAsymptoticOrderAlignmentPackageDirectory[], file}]], Null]
  ]
];

hrfAsymptoticOrderAlignmentLoadDependency["HRF_PinchPreselection.wl", "hrfPinchPreselectSingleInvariant"];
hrfAsymptoticOrderAlignmentLoadDependency["HRF_PolynomialCancellationFactors.wl", "hrfInstallPolynomialCancellationPatch"];
hrfAsymptoticOrderAlignmentLoadDependency["HRF_ExactCoverageScaling.wl", "findExactCoverageLPScaling"];
hrfAsymptoticOrderAlignmentLoadDependency[
  "HRF_LayeredDissectionCertification.wl",
  "hrfLayeredDissectionCertificate"
];
hrfAsymptoticOrderAlignmentLoadDependency[
  "HRF_SourceAwareDissectionCertification.wl",
  "hrfSourceAwareAlignedDissectionCertificate"
];
hrfAsymptoticOrderAlignmentLoadDependency[
  "HRF_IdealLayerCertification.wl",
  "hrfIdealLayerCertificate"
];

hrfAsymptoticOrderAlignmentCompact[x_] := ToString[InputForm[x]];

hrfAsymptoticOrderAlignmentPolynomialTerms[p_] := Module[{q = Expand[p]},
  If[TrueQ[q === 0], {}, If[Head[q] === Plus, List @@ q, {q}]]
];

hrfAsymptoticOrderAlignmentTermEtaPower[t_, eta_] := Exponent[t, eta];
hrfAsymptoticOrderAlignmentTermXRow[t_, vars_List] := Exponent[t, #] & /@ vars;

hrfAsymptoticOrderAlignmentActiveSupport[rows_List, vars_List] := Module[{sum},
  If[rows === {}, Return[{}]];
  sum = Total[Unitize[rows]];
  vars[[Flatten@Position[sum, _?(# > 0 &)]]]
];

hrfAsymptoticOrderAlignmentMandelstamLinearQ[f_, mandelstamVars_List] := Module[
  {terms, exps},
  If[mandelstamVars === {}, Return[True]];
  terms = hrfAsymptoticOrderAlignmentPolynomialTerms[f];
  And @@ Table[
    exps = Exponent[terms[[i]], #] & /@ mandelstamVars;
    And @@ ((0 <= # <= 1) & /@ exps) && Total[exps] <= 1,
    {i, Length[terms]}
  ]
];

hrfAsymptoticOrderAlignmentXFreeQ[p_, vars_List] := Module[{sym},
  If[vars === {}, Return[True]];
  sym = Alternatives @@ vars;
  FreeQ[Expand[p], sym]
];

hrfAsymptoticOrderAlignmentStripXFreeFactors[p_, vars_List] := Module[{q, fac, kept},
  q = Factor[p];
  If[TrueQ[q === 0], Return[0]];
  fac = FactorList[q];
  kept = Cases[
    fac,
    {f_, n_} /; ! hrfAsymptoticOrderAlignmentXFreeQ[f, vars] :> f^n
  ];
  If[kept === {}, 1, Factor[Times @@ kept]]
];

hrfAsymptoticOrderAlignmentCanonicalPolynomialKey[p_, vars_List] := Module[
  {core, k1, k2},
  core = Factor[hrfAsymptoticOrderAlignmentStripXFreeFactors[p, vars]];
  If[TrueQ[core === 0], Return["0"]];
  k1 = hrfAsymptoticOrderAlignmentCompact[core];
  k2 = hrfAsymptoticOrderAlignmentCompact[Factor[-core]];
  First[Sort[{k1, k2}]]
];

hrfAsymptoticOrderAlignmentCanonicalGeneratorKey[gens_List, vars_List] := Module[
  {keys},
  keys = hrfAsymptoticOrderAlignmentCanonicalPolynomialKey[#, vars] & /@ Flatten[{gens}];
  StringRiffle[Sort[keys], " || "]
];

hrfAsymptoticOrderAlignmentNormalizeVector[v_List] := Module[{m},
  If[v === {}, Return[{}]];
  m = Max[v];
  v - m
];

hrfAsymptoticOrderAlignmentDedupKey[row_Association, vars_List] := Module[
  {summary, gens, restricted, faceVec, scalingData, hrfScaling},
  summary = Lookup[row, "HRFSummary", <||>];
  gens = Lookup[summary, "Generators", {}];
  restricted = Lookup[row, "RestrictedFacePolynomial", Lookup[row, "Polynomial", 0]];
  faceVec = hrfAsymptoticOrderAlignmentNormalizeVector[Lookup[row, "Scaling", {}]];
  scalingData = Lookup[summary, "CoverageScalingData", <||>];
  hrfScaling = If[AssociationQ[scalingData],
    hrfAsymptoticOrderAlignmentNormalizeVector[Lookup[scalingData, "PrimitiveScaling", {}]],
    {}
  ];
  <|
    "RestrictedPolynomialKey" -> hrfAsymptoticOrderAlignmentCanonicalPolynomialKey[restricted, vars],
    "GeneratorKey" -> hrfAsymptoticOrderAlignmentCanonicalGeneratorKey[gens, vars],
    "FaceVectorKey" -> hrfAsymptoticOrderAlignmentCompact[faceVec],
    "HRFScalingKey" -> hrfAsymptoticOrderAlignmentCompact[hrfScaling]
  |>
];

hrfAsymptoticOrderAlignmentStructuralDedupKey[row_Association, vars_List] := Module[
  {summary, gens, restricted},
  summary = Lookup[row, "HRFSummary", <||>];
  gens = Lookup[summary, "Generators", {}];
  restricted = Lookup[row, "RestrictedFacePolynomial", Lookup[row, "Polynomial", 0]];
  <|
    "RestrictedPolynomialKey" -> hrfAsymptoticOrderAlignmentCanonicalPolynomialKey[restricted, vars],
    "GeneratorKey" -> hrfAsymptoticOrderAlignmentCanonicalGeneratorKey[gens, vars]
  |>
];

hrfAsymptoticOrderAlignmentRepresentativeRow[group_List] := First @ SortBy[
  group,
  {
    Length[Lookup[#, "PreselectionZeroVars", {}]] &,
    Length[Lookup[#, "Indices", {}]] &,
    hrfAsymptoticOrderAlignmentCompact[hrfAsymptoticOrderAlignmentNormalizeVector[Lookup[#, "Scaling", {}]]] &
  }
];

hrfAsymptoticOrderAlignmentDeduplicateRows[rows_List, vars_List, keyFunction_] := Module[
  {groups},
  groups = GatherBy[rows, keyFunction[#, vars] &];
  MapIndexed[
    With[{rep = hrfAsymptoticOrderAlignmentRepresentativeRow[#1]},
      <|
        "DedupIndex" -> First[#2],
        "Count" -> Length[#1],
        "Key" -> keyFunction[rep, vars],
        "Representative" -> rep,
        "Members" -> #1
      |>
    ] &,
    groups
  ]
];

hrfAsymptoticOrderAlignmentStrictDeduplicateRows[rows_List, vars_List] :=
  hrfAsymptoticOrderAlignmentDeduplicateRows[rows, vars, hrfAsymptoticOrderAlignmentDedupKey];

hrfAsymptoticOrderAlignmentStructuralDeduplicateRows[rows_List, vars_List] :=
  hrfAsymptoticOrderAlignmentDeduplicateRows[rows, vars, hrfAsymptoticOrderAlignmentStructuralDedupKey];

hrfAsymptoticOrderAlignmentTermTable[F_, vars_List, eta_] := Module[{num, terms},
  (* Clearing a common x-independent Laurent denominator chooses the
     dimensionless hard-scale normalization used by the region search.  The
     resulting Schwinger vector is relative to that hard scale; any overall
     dimensionful prefactor must be restored separately in a power count. *)
  num = Expand[Numerator[Together[F]]];
  terms = hrfAsymptoticOrderAlignmentPolynomialTerms[num];
  MapIndexed[
    With[{term = #1,
        pow = hrfAsymptoticOrderAlignmentTermEtaPower[#1, eta],
        row = hrfAsymptoticOrderAlignmentTermXRow[#1, vars]},
      <|
        "Index" -> First[#2],
        "EtaPower" -> pow,
        "XRow" -> row,
        "CoeffNoEta" -> Factor[#1/eta^pow],
        "Term" -> term
      |>
    ] &,
    terms
  ]
];

hrfAsymptoticOrderAlignmentFaceFromVector[termData_List, vars_List, v_List,
    faceTransform_: Identity] := Module[
  {weights, wmin, selected, poly},
  weights = (#["EtaPower"] + #["XRow"].v) & /@ termData;
  wmin = Min[weights];
  selected = Pick[termData, weights, wmin];
  poly = Factor[Total[#["CoeffNoEta"] & /@ selected]];
  poly = Factor[faceTransform[poly]];
  <|
    "Scaling" -> v,
    "Weight" -> wmin,
    "Indices" -> (#["Index"] & /@ selected),
    "EtaPowers" -> Sort@DeleteDuplicates[#["EtaPower"] & /@ selected],
    "XRows" -> (#["XRow"] & /@ selected),
    "Support" -> hrfAsymptoticOrderAlignmentActiveSupport[#["XRow"] & /@ selected, vars],
    "Polynomial" -> poly,
    "TermCount" -> Length[selected],
    "PromotedQ" -> Length[DeleteDuplicates[#["EtaPower"] & /@ selected]] > 1
  |>
];

Options[hrfAsymptoticOrderAlignmentEnumerateFaces] = {
  "ScalingRange" -> Range[-3, 0],
  "FaceVectors" -> Automatic,
  "MinFaceTerms" -> 2,
  "RequirePromotedQ" -> False,
  "FacePolynomialTransform" -> Identity
};

hrfAsymptoticOrderAlignmentEnumerateFaces[termData_List, vars_List, OptionsPattern[]] := Module[
  {vectors, faces, minTerms, requirePromotedQ},
  vectors = Replace[
    OptionValue["FaceVectors"],
    Automatic :> Tuples[OptionValue["ScalingRange"], Length[vars]]
  ];
  minTerms = OptionValue["MinFaceTerms"];
  requirePromotedQ = TrueQ[OptionValue["RequirePromotedQ"]];
  faces = Values @ GroupBy[
    hrfAsymptoticOrderAlignmentFaceFromVector[
      termData, vars, #, OptionValue["FacePolynomialTransform"]
    ] & /@ vectors,
    #["Indices"] &,
    First
  ];
  Select[
    faces,
    Length[#["Indices"]] >= minTerms &&
      (! requirePromotedQ || TrueQ[#["PromotedQ"]]) &
  ]
];

Options[hrfAsymptoticOrderAlignmentRunHRF] = {
  "KinematicAssumptions" -> True,
  "KinematicVariables" -> {},
  "MandelstamVariables" -> {},
  "DisableMandelstamLinearityForChartVariablesQ" -> True,
  "U" -> Automatic,
  "HRFOptions" -> {}
};

hrfAsymptoticOrderAlignmentRunHRF[F_, vars_List, zeroVars_List, OptionsPattern[]] := Module[
  {activeVars, fRestricted, uOpt, hrfOptions, kinAssumptions, kinVars,
   mandelstamVars, disableChartLinearityQ, run},
  activeVars = Complement[vars, zeroVars];
  fRestricted = Expand[F /. Thread[zeroVars -> 0]];
  uOpt = OptionValue["U"];
  If[uOpt =!= Automatic, uOpt = Expand[uOpt /. Thread[zeroVars -> 0]]];
  hrfOptions = DeleteCases[
    Flatten[{OptionValue["HRFOptions"]}],
    ("AsymptoticOrderAlignmentMode" | "AsymptoticOrderAlignmentPolynomial" |
      "AsymptoticOrderAlignmentOptions" | "FaceliftMode" |
      "FaceliftPolynomial" | "FaceliftOptions") -> _
  ];
  kinAssumptions = OptionValue["KinematicAssumptions"];
  kinVars = OptionValue["KinematicVariables"];
  mandelstamVars = OptionValue["MandelstamVariables"];
  disableChartLinearityQ = TrueQ[OptionValue["DisableMandelstamLinearityForChartVariablesQ"]];
  run[] := Quiet @ Check[
    findObstructions[
      fRestricted,
      activeVars,
      kinAssumptions,
      kinVars,
      Automatic,
      Sequence @@ Join[
        (* OptionValue uses the first repeated rule.  Put caller-supplied
           HRFOptions first so that controls such as MaxGenerators genuinely
           override the alignment wrapper defaults. *)
        hrfOptions,
        {
          "GeneratorMode" -> "PairSectors",
          "MaxGenerators" -> 2,
          "UseExtendedFactors" -> False,
          "DimensionfulKinVars" -> {},
          "StopOnFirstAdmissible" -> False,
          "StoreAllObstructionTrialsQ" -> True,
          "U" -> uOpt,
          "RequireValidScalingForHiddenRegionQ" -> True,
          "CoverageScalingMethod" -> "ExactCoverage",
          "MaxScalingAbs" -> 8,
          "AsymptoticOrderAlignmentMode" -> "Off"
        }
      ]
    ],
    $Failed
  ];
  If[disableChartLinearityQ,
    Block[{hrfFactorMandelstamLinearQ},
      hrfFactorMandelstamLinearQ[f_, _] := hrfAsymptoticOrderAlignmentMandelstamLinearQ[f, mandelstamVars];
      If[ValueQ[hrfInstallPolynomialCancellationPatch],
        hrfInstallPolynomialCancellationPatch[]
      ];
      run[]
    ],
    run[]
  ]
];

Options[hrfAsymptoticOrderAlignmentFaceScanRow] = Join[
  Options[hrfAsymptoticOrderAlignmentRunHRF],
  {
    "RunHRFQ" -> True,
    "KeepAmbiguousPreselectionQ" -> False,
    "PinchPreselectionOptions" -> {}
  }
];

hrfAsymptoticOrderAlignmentFaceScanRow[face_Association, vars_List, OptionsPattern[]] := Module[
  {scan, potentialQ, keepQ, zeroVars, restrictedPoly, hrf = Missing["Skipped"],
   runHRFQ, hrfSummary},
  scan = hrfPinchPreselectSingleInvariant[
    face["Polynomial"],
    vars,
    Sequence @@ Join[
      {"Assumptions" -> OptionValue["KinematicAssumptions"]},
      OptionValue["PinchPreselectionOptions"]
    ]
  ];
  potentialQ = Lookup[scan, "PotentialPinchQ", False];
  keepQ = TrueQ[potentialQ === True] ||
    (TrueQ[OptionValue["KeepAmbiguousPreselectionQ"]] && MatchQ[potentialQ, _Missing]);
  zeroVars = Lookup[scan, "ZeroVars", {}];
  restrictedPoly = Expand[face["Polynomial"] /. Thread[zeroVars -> 0]];
  runHRFQ = TrueQ[OptionValue["RunHRFQ"]] && TrueQ[potentialQ === True];
  If[runHRFQ,
    hrf = hrfAsymptoticOrderAlignmentRunHRF[
      face["Polynomial"],
      vars,
      zeroVars,
      "KinematicAssumptions" -> OptionValue["KinematicAssumptions"],
      "KinematicVariables" -> OptionValue["KinematicVariables"],
      "MandelstamVariables" -> OptionValue["MandelstamVariables"],
      "DisableMandelstamLinearityForChartVariablesQ" ->
        OptionValue["DisableMandelstamLinearityForChartVariablesQ"],
      "U" -> OptionValue["U"],
      "HRFOptions" -> OptionValue["HRFOptions"]
    ]
  ];
  hrfSummary = If[AssociationQ[hrf],
    <|
      "HiddenRegionQ" -> Lookup[hrf, "HiddenRegionQ", False],
      "CancellationFactorCount" -> Length[Lookup[hrf, "CancellationFactors", {}]],
      "GeneratorCount" -> Length[Lookup[hrf, "Generators", {}]],
      "ValidObstructionCount" -> Lookup[
        Lookup[hrf, "ObstructionAttemptSummary", <||>],
        "ValidObstructionCount",
        0
      ],
      "ValidScalingCount" -> Lookup[
        Lookup[hrf, "ObstructionAttemptSummary", <||>],
        "HiddenRegionWithValidScalingCount",
        0
      ],
      "Generators" -> Factor /@ Lookup[hrf, "Generators", {}],
      "CancellationFactors" -> Factor /@ Lookup[hrf, "CancellationFactors", {}],
      "CoverageScalingData" -> Lookup[hrf, "CoverageScalingData", Missing["NotEvaluated"]]
    |>,
    <|
      "HiddenRegionQ" -> False,
      "CancellationFactorCount" -> 0,
      "GeneratorCount" -> 0,
      "ValidObstructionCount" -> 0,
      "ValidScalingCount" -> 0
    |>
  ];
  Join[
    KeyTake[face, {"Scaling", "Weight", "Indices", "EtaPowers", "Support",
      "TermCount", "PromotedQ", "Polynomial"}],
    <|
      "PreselectionPotentialPinchQ" -> potentialQ,
      "PreselectionKeepQ" -> keepQ,
      "PreselectionZeroVars" -> zeroVars,
      "PreselectionRemainingVars" -> Lookup[scan, "RemainingVars", {}],
      "PreselectionActiveRemainingVars" -> Lookup[scan, "ActiveRemainingVars", {}],
      "PreselectionExitReason" -> Lookup[scan, "ExitReason", ""],
      "RestrictedFacePolynomial" -> restrictedPoly,
      "PinchPreselectionScan" -> scan,
      "HRFScan" -> hrf,
      "HRFSummary" -> hrfSummary
    |>
  ]
];

Options[hrfAsymptoticOrderAlignmentSearch] = Join[
  Options[hrfAsymptoticOrderAlignmentEnumerateFaces],
  Options[hrfAsymptoticOrderAlignmentFaceScanRow],
  {
    "EtaSymbol" -> eta,
    "KinematicRules" -> {},
    "ExtraRules" -> {},
    "MaxFaces" -> All,
    "RequireTotalLowerFacetQ" -> True,
    "SourceAwareDissectionOptions" -> {}
  }
];

(* Final certification for a staged alignment+HRF candidate.

   The primary certificate resolves all occupied layers through the
   cancellation ideal.  If that system is unavailable or non-unique, the
   source-aware fallback dissects the cancellation locus, enumerates exact
   lower facets in local coordinates, and pulls their normals back to the
   original edge variables.  For n active local variables a facet has affine
   rank n in the augmented exponent space.  F_SL is retained as a separate
   source, so its resolved weight is measured rather than promoted by hand.

   The historical raw and synthetically promoted rank tests are still
   reported as diagnostics but cannot accept a region. *)
hrfAsymptoticOrderAlignmentTotalLowerFacetAudit[
    row_Association, termData_List, vars_List, uPoly_, faceTransform_:Identity,
    etaSym_:eta, sourceAwareOptions_List:{}] := Module[
  {summary, stagedQ, cov, zeroVars, zeroPositions, activePositions, activeVars,
   faceVector, faceActive, hrfAssoc, totalVector, totalAssoc, relativeAssoc,
   faceWeight, faceIndices, outsideData, survivesBoundaryQ, obsData, fSL,
   fObs, fSLRows, fObsRows, redPoints, outsideWeights, outsideWeightValues,
   outsidePoints, obstructionPoints, uRows, uPoints, postPoints, pointWeight,
   wSLValues, wSL, postWeights, wHR, leadingPoints, rawAugmentedRows,
   rawDifferences, rawAffineRank, rawNormalSpace, rawFacetNormal,
   rawOrientedNormal, rawPositiveEtaNormalQ, rawNormalizedNormal,
   rawNormalAgreementQ, rawLowerFacetQ, promotedFSLPoints,
   resolvedLeadingPoints, augmentedRows, differences, affineRank, normalSpace,
   rawNormal, orientedNormal, normalizedNormal,
   candidateNormal, normalAgreementQ, positiveEtaNormalQ, lowerInequalitiesQ,
   lowerFacetQ, xRows, xDifferences, monomialNullSpace, makePoint,
   transformedLayer, layerRows, weight, nums, reason, idealCertification,
   idealCertificates, idealQ, sourceAwareCertification,
   sourceAwareCertificates, sourceAwareQ, layeredCertification,
   selectedCertificate, selectedFacet, provisionalPromotionFacetQ,
   selectedTotalAssoc, selectedRelativeAssoc, selectedWSL, selectedWHR,
   certificationMethod, sourceAwareSearchTruncatedQ,
   sourceAwareSearchCompleteQ,
   certificationUnresolvedQ, idealScalingCandidates,
   idealLayerDissectionAgreementQ, baseAudit},

  summary = Lookup[row, "HRFSummary", <||>];
  stagedQ = TrueQ[Lookup[
    summary, "StagedHiddenRegionQ", Lookup[summary, "HiddenRegionQ", False]
  ]];
  If[! stagedQ,
    Return[<|"AuditStatus" -> "SkippedNoStagedHiddenRegion",
      "StagedHiddenRegionQ" -> False, "TotalLowerFacetQ" -> False|>]
  ];
  If[MatchQ[uPoly, Automatic | None | Missing[__]],
    Return[<|"AuditStatus" -> "FailedNoUPolynomial",
      "StagedHiddenRegionQ" -> True, "TotalLowerFacetQ" -> False|>]
  ];

  cov = Lookup[summary, "CoverageScalingData", <||>];
  zeroVars = Lookup[row, "PreselectionZeroVars", {}];
  zeroPositions = Flatten[Position[vars, Alternatives @@ zeroVars]];
  activePositions = Complement[Range[Length[vars]], zeroPositions];
  activeVars = vars[[activePositions]];
  faceVector = Lookup[row, "Scaling", {}];
  If[Length[faceVector] =!= Length[vars],
    Return[<|"AuditStatus" -> "FailedMalformedFaceScaling",
      "StagedHiddenRegionQ" -> True, "TotalLowerFacetQ" -> False|>]
  ];
  faceActive = faceVector[[activePositions]];
  hrfAssoc = Lookup[cov, "VariableScaling", <||>];
  If[! AssociationQ[hrfAssoc] || ! AllTrue[activeVars, KeyExistsQ[hrfAssoc, #] &],
    Return[<|"AuditStatus" -> "FailedMissingHRFScaling",
      "StagedHiddenRegionQ" -> True, "TotalLowerFacetQ" -> False|>]
  ];
  totalVector = faceActive + Lookup[hrfAssoc, activeVars];
  totalAssoc = AssociationThread[activeVars, totalVector];
  nums = Cases[totalVector, _Integer | _Rational];
  relativeAssoc = If[Length[nums] == Length[totalVector],
    AssociationThread[activeVars, totalVector - Max[nums]], totalAssoc
  ];
  faceWeight = Lookup[row, "Weight", Missing["NoFaceWeight"]];
  faceIndices = Lookup[row, "Indices", {}];

  obsData = Lookup[Lookup[row, "HRFScan", <||>], "ObstructionData", <||>];
  fSL = Lookup[obsData, "Superleading", Missing["NoSuperleading"]];
  fObs = Lookup[obsData, "Obstruction", Missing["NoObstruction"]];
  If[MissingQ[fSL] || MissingQ[fObs] || MissingQ[faceWeight],
    Return[<|"AuditStatus" -> "FailedMissingDecomposition",
      "StagedHiddenRegionQ" -> True, "TotalLowerFacetQ" -> False,
      "TotalScaling" -> totalAssoc|>]
  ];

  fSLRows = polynomialExponentRows[Expand[fSL], activeVars];
  fObsRows = polynomialExponentRows[Expand[fObs], activeVars];
  If[fSLRows === {},
    Return[<|"AuditStatus" -> "FailedEmptyFSL",
      "StagedHiddenRegionQ" -> True, "TotalLowerFacetQ" -> False,
      "TotalScaling" -> totalAssoc|>]
  ];

  makePoint[rowX_, power_, source_] := <|
    "Row" -> rowX, "Power" -> power, "Source" -> source,
    "AugmentedRow" -> Append[rowX, power]
  |>;
  redPoints = DeleteDuplicatesBy[
    (makePoint[#, faceWeight - #.faceActive, "FSL"] &) /@ fSLRows,
    Lookup[#, "AugmentedRow"] &
  ];

  survivesBoundaryQ[data_Association] :=
    zeroPositions === {} || Total[data["XRow"][[zeroPositions]]] == 0;
  outsideData = Select[
    termData,
    survivesBoundaryQ[#] && ! MemberQ[faceIndices, Lookup[#, "Index", -1]] &
  ];
  outsideWeights = Association @ Map[
    Lookup[#, "Index"] ->
      (Lookup[#, "EtaPower"] + Lookup[#, "XRow"][[activePositions]].totalVector) &,
    outsideData
  ];
  outsideWeightValues = Sort @ DeleteDuplicates[Values[outsideWeights]];
  outsidePoints = Flatten @ Table[
    transformedLayer = faceTransform @ Total[
      Lookup[
        Select[outsideData,
          Lookup[outsideWeights, Lookup[#, "Index"]] == weight &],
        "CoeffNoEta", {}
      ] /. Thread[zeroVars -> 0]
    ];
    layerRows = polynomialExponentRows[Expand[transformedLayer], activeVars];
    (makePoint[#, weight - #.totalVector, "FOutside"] &) /@ layerRows,
    {weight, outsideWeightValues}
  ];

  obstructionPoints = DeleteDuplicatesBy[
    (makePoint[#, faceWeight - #.faceActive, "FObs"] &) /@ fObsRows,
    Lookup[#, "AugmentedRow"] &
  ];
  uRows = polynomialExponentRows[Expand[uPoly /. Thread[zeroVars -> 0]], activeVars];
  uPoints = (makePoint[#, 0, "U"] &) /@ uRows;
  postPoints = DeleteDuplicatesBy[
    Join[outsidePoints, obstructionPoints, uPoints],
    {Lookup[#, "AugmentedRow"], Lookup[#, "Source"]} &
  ];
  If[postPoints === {},
    Return[<|"AuditStatus" -> "FailedEmptyPostCancellationPolytope",
      "StagedHiddenRegionQ" -> True, "TotalLowerFacetQ" -> False,
      "TotalScaling" -> totalAssoc|>]
  ];

  pointWeight[p_Association] := p["Row"].totalVector + p["Power"];
  wSLValues = Sort @ DeleteDuplicates[pointWeight /@ redPoints];
  wSL = If[Length[wSLValues] == 1, First[wSLValues], Missing["NonUniformFSL"]];
  postWeights = pointWeight /@ postPoints;
  wHR = Min[postWeights];
  leadingPoints = DeleteDuplicatesBy[
    Pick[postPoints, postWeights, wHR], Lookup[#, "AugmentedRow"] &
  ];
  rawAugmentedRows = Lookup[leadingPoints, "AugmentedRow", {}];
  rawDifferences = If[Length[rawAugmentedRows] <= 1, {},
    (# - First[rawAugmentedRows]) & /@ Rest[rawAugmentedRows]
  ];
  rawAffineRank = If[rawDifferences === {}, 0, MatrixRank[rawDifferences]];
  rawNormalSpace = If[rawDifferences === {}, {}, NullSpace[rawDifferences]];
  candidateNormal = Append[totalVector, 1];
  rawFacetNormal = If[Length[rawNormalSpace] == 1,
    First[rawNormalSpace], Missing["NonUniqueNormal"]
  ];
  rawOrientedNormal = If[
    ListQ[rawFacetNormal] && Last[rawFacetNormal] < 0,
    -rawFacetNormal, rawFacetNormal
  ];
  rawPositiveEtaNormalQ =
    ListQ[rawOrientedNormal] && TrueQ[Last[rawOrientedNormal] > 0];
  rawNormalizedNormal = If[rawPositiveEtaNormalQ,
    Together[rawOrientedNormal/Last[rawOrientedNormal]],
    Missing["NoPositiveEtaNormal"]
  ];
  rawNormalAgreementQ = ListQ[rawNormalizedNormal] &&
    TrueQ[And @@ Thread[Together[rawNormalizedNormal - candidateNormal] == 0]];
  rawLowerFacetQ = TrueQ[
    rawAffineRank == Length[activeVars] && Length[rawNormalSpace] == 1 &&
    rawPositiveEtaNormalQ && rawNormalAgreementQ
  ];

  (* Historical diagnostic only: the former implementation placed copies of
     the F_SL exponent rows at W_HR to ask whether they would complete the
     facet rank.  This does not establish that the resolved F_SL jet is
     actually present there.  The construction is retained for comparison,
     but it is never used for acceptance below. *)
  promotedFSLPoints = DeleteDuplicatesBy[
    (makePoint[#["Row"], wHR - #["Row"].totalVector, "FSLPromoted"] &) /@
      redPoints,
    Lookup[#, "AugmentedRow"] &
  ];
  resolvedLeadingPoints = DeleteDuplicatesBy[
    Join[leadingPoints, promotedFSLPoints], Lookup[#, "AugmentedRow"] &
  ];
  augmentedRows = Lookup[resolvedLeadingPoints, "AugmentedRow", {}];
  differences = If[Length[augmentedRows] <= 1, {},
    (# - First[augmentedRows]) & /@ Rest[augmentedRows]
  ];
  affineRank = If[differences === {}, 0, MatrixRank[differences]];
  normalSpace = If[differences === {}, {}, NullSpace[differences]];
  rawNormal = If[Length[normalSpace] == 1, First[normalSpace], Missing["NonUniqueNormal"]];
  orientedNormal = If[ListQ[rawNormal] && Last[rawNormal] < 0, -rawNormal, rawNormal];
  positiveEtaNormalQ = ListQ[orientedNormal] && TrueQ[Last[orientedNormal] > 0];
  normalizedNormal = If[positiveEtaNormalQ, Together[orientedNormal/Last[orientedNormal]],
    Missing["NoPositiveEtaNormal"]
  ];
  normalAgreementQ = ListQ[normalizedNormal] &&
    TrueQ[And @@ Thread[Together[normalizedNormal - candidateNormal] == 0]];
  lowerInequalitiesQ = TrueQ[And @@ Thread[postWeights >= wHR]];
  lowerFacetQ = TrueQ[
    ! MissingQ[wSL] && wHR > wSL &&
    affineRank == Length[activeVars] && Length[normalSpace] == 1 &&
    positiveEtaNormalQ && normalAgreementQ && lowerInequalitiesQ
  ];

  (* Original-coordinate determination: audit every occupied full-LP weight
     layer in the I-adic filtration of the common pinch.  This can fix both
     the depth multiplier and the uniform alignment representative before the
     ultimate source-aware dissection test.  An absent eta layer is never
     counted as a cancellation layer. *)
  idealCertification = If[
    zeroVars === {} &&
      Length[DownValues[hrfIdealLayerCertificate]] > 0,
    Quiet @ Check[
      hrfIdealLayerCertificate[
        row, termData, vars, uPoly, etaSym,
        "MaxDepthMultiplier" -> 6,
        "MaxUniformShiftAbs" -> 8
      ],
      <|"CertificationStatus" -> "IdealLayerCertificationFailed",
        "CertifiedQ" -> False|>
    ],
    <|"CertificationStatus" -> If[zeroVars === {},
        "IdealLayerCertificationUnavailable", "SkippedBoundaryStratum"],
      "CertifiedQ" -> False|>
  ];
  idealCertificates = Lookup[idealCertification, "Certificates", {}];
  idealQ = TrueQ[Lookup[idealCertification, "CertifiedQ", False]] &&
    idealCertificates =!= {};

  (* Ultimate certificate: resolve the cancellation and test the exact local
     lower facets even when the original-coordinate ideal-layer equations
     already give a unique vector.  The ideal solution is then an independent
     determination and cross-check, while the source-aware dissection measures
     the first nonzero local F_SL weight instead of promoting it by hand. *)
  sourceAwareCertification = If[
    Length[DownValues[hrfSourceAwareAlignedDissectionCertificate]] > 0,
    Quiet @ Check[
      hrfSourceAwareAlignedDissectionCertificate[
        row, termData, vars, uPoly, etaSym, faceTransform,
        Sequence @@ sourceAwareOptions
      ],
      <|"CertificationStatus" -> "SourceAwareDissectionFailed",
        "CertifiedQ" -> False|>
    ],
    <|"CertificationStatus" -> "SourceAwareDissectionUnavailable",
      "CertifiedQ" -> False|>
  ];
  sourceAwareCertificates = Lookup[sourceAwareCertification, "Certificates", {}];
  sourceAwareQ = TrueQ[Lookup[sourceAwareCertification, "CertifiedQ", False]] &&
    sourceAwareCertificates =!= {};
  sourceAwareSearchTruncatedQ = TrueQ[
    Lookup[sourceAwareCertification, "SearchTruncatedQ", False]
  ];
  sourceAwareSearchCompleteQ = TrueQ[
    Lookup[sourceAwareCertification, "SearchCompleteQ", False]
  ];
  certificationUnresolvedQ =
    ! sourceAwareQ && ! sourceAwareSearchCompleteQ;

  (* Retain the older restricted dissection result only as a comparison
     diagnostic.  It is no longer allowed to certify a region because its
     transverse-weight ansatz does not retain source-resolved F_SL jets. *)
  layeredCertification = If[
    ! sourceAwareQ && zeroVars === {} &&
      Length[DownValues[hrfLayeredDissectionCertificate]] > 0,
    Quiet @ Check[
      hrfLayeredDissectionCertificate[
        row, termData, vars, uPoly, etaSym,
        "MaxDepthMultiplier" -> 6,
        "MaxUniformShiftAbs" -> 8
      ],
      <|"CertificationStatus" -> "LegacyLayeredCertificationFailed",
        "CertifiedQ" -> False|>
    ],
    <|"CertificationStatus" -> Which[
        sourceAwareQ, "SkippedSourceAwareDissectionCertified",
        zeroVars =!= {}, "SkippedBoundaryStratum",
        True, "LegacyLayeredDissectionUnavailable"],
      "CertifiedQ" -> False|>
  ];

  selectedCertificate = If[sourceAwareQ, First[sourceAwareCertificates], <||>];
  certificationMethod = If[sourceAwareQ,
    "SourceAwareAlignedDissection", "UncertifiedStagedCandidate"
  ];
  idealScalingCandidates = Lookup[idealCertificates, "PullbackScaling", {}];
  idealLayerDissectionAgreementQ = If[idealQ && sourceAwareQ,
    MemberQ[idealScalingCandidates,
      Lookup[selectedCertificate, "PullbackScaling", Missing[]]],
    Missing["NotBothCertified"]
  ];
  selectedFacet = Lookup[selectedCertificate, "FacetAudit", <||>];
  selectedTotalAssoc = If[sourceAwareQ,
    selectedCertificate["PullbackScaling"], totalAssoc
  ];
  selectedRelativeAssoc = If[sourceAwareQ,
    selectedCertificate["RelativePullbackScaling"], relativeAssoc
  ];
  selectedWSL = If[sourceAwareQ,
    Lookup[selectedCertificate, "WSL", wSL], wSL];
  selectedWHR = If[sourceAwareQ,
    Lookup[selectedCertificate, "ResolvedLeadingWeight", wHR], wHR
  ];
  provisionalPromotionFacetQ = lowerFacetQ;
  lowerFacetQ = TrueQ[sourceAwareQ];

  xRows = Lookup[resolvedLeadingPoints, "Row", {}];
  xDifferences = If[Length[xRows] <= 1, {}, (# - First[xRows]) & /@ Rest[xRows]];
  monomialNullSpace = If[xDifferences === {}, IdentityMatrix[Length[activeVars]],
    NullSpace[xDifferences]
  ];
  reason = Which[
    sourceAwareQ, "AcceptedSourceAwareDissectedLowerFacet",
    certificationUnresolvedQ && sourceAwareSearchTruncatedQ,
      "SourceAwareDissectionSearchTruncated",
    certificationUnresolvedQ, "SourceAwareDissectionIncomplete",
    MissingQ[wSL], "NonUniformFSLWeight",
    ! TrueQ[wHR > wSL], "NoHiddenHierarchy",
    True, Lookup[sourceAwareCertification, "CertificationStatus",
      "SourceAwareDissectionUnresolved"]
  ];

  baseAudit = <|
    "AuditStatus" -> reason,
    "StagedHiddenRegionQ" -> True,
    "TotalLowerFacetQ" -> lowerFacetQ,
    "ScalelessRejectedQ" -> (! lowerFacetQ && ! certificationUnresolvedQ),
    "CertificationUnresolvedQ" -> certificationUnresolvedQ,
    "ActiveVariables" -> activeVars,
    "BoundaryZeroVariables" -> zeroVars,
    "FaceScaling" -> AssociationThread[activeVars, faceActive],
    "HRFScaling" -> KeyTake[hrfAssoc, activeVars],
    "TotalScaling" -> selectedTotalAssoc,
    "RelativeTotalScaling" -> selectedRelativeAssoc,
    "WSL" -> selectedWSL,
    "WHR" -> selectedWHR,
    "HierarchyGap" -> If[MissingQ[selectedWSL], Missing["NoGap"],
      selectedWHR - selectedWSL],
    "WHRPointCount" -> Length[leadingPoints],
    "WHRSourceCounts" -> Counts[Lookup[leadingPoints, "Source"]],
    "WHRAugmentedRows" -> rawAugmentedRows,
    "WHRAffineRank" -> rawAffineRank,
    "WHRFacetNormalNullSpace" -> rawNormalSpace,
    "WHRNormalizedInwardNormal" -> rawNormalizedNormal,
    "WHRPositiveEtaNormalQ" -> rawPositiveEtaNormalQ,
    "WHRNormalAgreementQ" -> rawNormalAgreementQ,
    "WHROnlyLowerFacetQ" -> rawLowerFacetQ,
    "ResolvedWHRPointCount" -> If[sourceAwareQ,
      Lookup[selectedFacet, "LeadingPointCount", Length[resolvedLeadingPoints]],
      Length[resolvedLeadingPoints]
    ],
    "ResolvedWHRSourceCounts" -> If[sourceAwareQ,
      Lookup[selectedCertificate, "LeadingFacetSourceCounts", <||>],
      Counts[Lookup[resolvedLeadingPoints, "Source"]]
    ],
    "ResolvedWHRAugmentedRows" -> If[sourceAwareQ,
      Lookup[selectedFacet, "LeadingAugmentedRows", {}], augmentedRows
    ],
    "ResolvedWHRAffineRank" -> If[sourceAwareQ,
      Lookup[selectedFacet, "LeadingAffineRank", affineRank], affineRank
    ],
    "RequiredFacetRank" -> Length[activeVars],
    "ResolvedFacetNormalNullSpace" -> normalSpace,
    "NormalizedInwardNormal" -> If[sourceAwareQ,
      Append[Lookup[selectedTotalAssoc, activeVars], 1], normalizedNormal
    ],
    "CandidateNormal" -> If[sourceAwareQ,
      Append[Lookup[selectedTotalAssoc, activeVars], 1], candidateNormal
    ],
    "DissectedLocalNormalizedInwardNormal" -> If[sourceAwareQ,
      Lookup[selectedFacet, "NormalizedInwardNormal", Missing["NotDissected"]],
      Missing["NotDissected"]
    ],
    "PositiveEtaNormalQ" -> If[sourceAwareQ, True, positiveEtaNormalQ],
    "NormalAgreementQ" -> If[sourceAwareQ, True, normalAgreementQ],
    "LowerFacetInequalitiesQ" -> If[sourceAwareQ, True, lowerInequalitiesQ],
    "MonomialRescalingNullSpace" -> If[sourceAwareQ,
      Lookup[selectedFacet, "MonomialRescalingNullSpace", {}],
      monomialNullSpace
    ],
    "ResidualMonomialRescalingQ" -> If[sourceAwareQ,
      Lookup[selectedCertificate, "ResidualMonomialRescalingQ",
        Lookup[selectedFacet, "ResidualMonomialRescalingQ", False]],
      monomialNullSpace =!= {}
    ],
    "CertificationVectorSource" -> certificationMethod,
    "StagedComposedScaling" -> totalAssoc,
    "StagedCompositionSupersededQ" -> sourceAwareQ,
    "UniqueIdealJetSolutionQ" -> idealQ,
    "IdealLayerDissectionAgreementQ" -> idealLayerDissectionAgreementQ,
    "FSLOnLeadingFacetQ" -> If[sourceAwareQ,
      Lookup[selectedCertificate, "FSLOnLeadingFacetQ", Missing[]],
      Missing["NotSourceResolved"]
    ],
    "ResolvedFSLWeight" -> If[sourceAwareQ,
      Lookup[selectedCertificate, "ResolvedFSLWeight", Missing[]],
      Missing["NotSourceResolved"]
    ],
    "FSLSubleadingAfterCancellationQ" -> If[sourceAwareQ,
      Lookup[selectedCertificate, "FSLSubleadingAfterCancellationQ",
        Missing[]],
      Missing["NotSourceResolved"]
    ],
    "LeadingFacetRequiresFSLQ" -> If[sourceAwareQ,
      Lookup[selectedCertificate, "LeadingFacetRequiresFSLQ", Missing[]],
      Missing["NotTestedByIdealCertificate"]
    ],
    "FSLContributesToLeadingPolynomialQ" -> If[sourceAwareQ,
      Lookup[selectedCertificate, "FSLContributesToLeadingPolynomialQ",
        Missing[]],
      Missing["NotTestedByIdealCertificate"]
    ],
    "SourceAwarePullbackChecks" -> If[sourceAwareQ,
      Lookup[selectedCertificate, "PullbackChecks", <||>], <||>
    ],
    "SourceAwareCertifiedRegionCount" ->
      Lookup[sourceAwareCertification, "DistinctCertifiedRegionCount", 0],
    "MultipleSourceAwareCertifiedRegionsQ" ->
      Lookup[sourceAwareCertification, "MultipleCertifiedRegionsQ", False],
    "SourceAwareSearchTruncatedQ" -> sourceAwareSearchTruncatedQ,
    "SourceAwareSearchCompleteQ" ->
      sourceAwareSearchCompleteQ,
    "SyntheticFSLPromotionFacetQ" -> provisionalPromotionFacetQ,
    "SyntheticFSLPromotionUsedForAcceptanceQ" -> False,
    "IdealLayerCertification" -> idealCertification,
    "SourceAwareDissectionCertification" -> sourceAwareCertification,
    "LayeredDissectionCertification" -> layeredCertification
  |>;
  baseAudit
];

hrfAsymptoticOrderAlignmentApplyTotalLowerFacetAudit[row_Association, termData_List, vars_List,
    uPoly_, faceTransform_:Identity, requireQ_:True, etaSym_:eta,
    sourceAwareOptions_List:{}] := Module[
  {summary, stagedQ, audit, finalQ, unresolvedQ, updatedSummary},
  summary = Lookup[row, "HRFSummary", <||>];
  stagedQ = TrueQ[Lookup[
    summary, "StagedHiddenRegionQ", Lookup[summary, "HiddenRegionQ", False]
  ]];
  audit = If[stagedQ,
    hrfAsymptoticOrderAlignmentTotalLowerFacetAudit[
      row, termData, vars, uPoly, faceTransform, etaSym,
      sourceAwareOptions
    ],
    <|"AuditStatus" -> "SkippedNoStagedHiddenRegion",
      "StagedHiddenRegionQ" -> False, "TotalLowerFacetQ" -> False|>
  ];
  finalQ = stagedQ && (! TrueQ[requireQ] || TrueQ[Lookup[audit, "TotalLowerFacetQ", False]]);
  unresolvedQ = TrueQ[Lookup[audit, "CertificationUnresolvedQ", False]];
  updatedSummary = Join[
    summary,
    <|
      "StagedHiddenRegionQ" -> stagedQ,
      "TotalLowerFacetRequiredQ" -> TrueQ[requireQ],
      "TotalLowerFacetQ" -> TrueQ[Lookup[audit, "TotalLowerFacetQ", False]],
      "TotalLowerFacetCertificationUnresolvedQ" -> unresolvedQ,
      "ScalelessRejectedQ" ->
        (stagedQ && TrueQ[requireQ] && ! finalQ && ! unresolvedQ),
      "SearchTruncatedQ" ->
        (TrueQ[Lookup[summary, "SearchTruncatedQ", False]] || unresolvedQ),
      "HiddenRegionSearchCompleteQ" ->
        (TrueQ[Lookup[summary, "HiddenRegionSearchCompleteQ", True]] &&
          ! unresolvedQ),
      "HiddenRegionQ" -> finalQ
    |>
  ];
  Join[row, <|"TotalScalingAudit" -> audit, "HRFSummary" -> updatedSummary|>]
];

hrfAsymptoticOrderAlignmentSearch[F_, vars_List, OptionsPattern[]] := Module[
  {etaSym, rules, expr, termData, faces, maxFaces, rows, keptRows,
   stagedHRRows, stagedStructuralGroups, stagedStrictGroups, hrRows,
   structuralGroups, strictGroups},
  etaSym = OptionValue["EtaSymbol"];
  rules = Join[OptionValue["ExtraRules"], OptionValue["KinematicRules"]];
  expr = Factor[Together[F /. rules]];
  termData = hrfAsymptoticOrderAlignmentTermTable[expr, vars, etaSym];
  faces = hrfAsymptoticOrderAlignmentEnumerateFaces[
    termData,
    vars,
    "ScalingRange" -> OptionValue["ScalingRange"],
    "FaceVectors" -> OptionValue["FaceVectors"],
    "MinFaceTerms" -> OptionValue["MinFaceTerms"],
    "RequirePromotedQ" -> OptionValue["RequirePromotedQ"],
    "FacePolynomialTransform" -> OptionValue["FacePolynomialTransform"]
  ];
  maxFaces = OptionValue["MaxFaces"];
  If[IntegerQ[maxFaces], faces = Take[faces, UpTo[maxFaces]]];
  rows = hrfAsymptoticOrderAlignmentFaceScanRow[
      #,
      vars,
      "RunHRFQ" -> OptionValue["RunHRFQ"],
      "KeepAmbiguousPreselectionQ" -> OptionValue["KeepAmbiguousPreselectionQ"],
      "PinchPreselectionOptions" -> OptionValue["PinchPreselectionOptions"],
      "KinematicAssumptions" -> OptionValue["KinematicAssumptions"],
      "KinematicVariables" -> OptionValue["KinematicVariables"],
      "MandelstamVariables" -> OptionValue["MandelstamVariables"],
      "DisableMandelstamLinearityForChartVariablesQ" ->
        OptionValue["DisableMandelstamLinearityForChartVariablesQ"],
      "U" -> OptionValue["U"],
      "HRFOptions" -> OptionValue["HRFOptions"]
    ] & /@ faces;
  rows = hrfAsymptoticOrderAlignmentApplyTotalLowerFacetAudit[
      #, termData, vars, OptionValue["U"], OptionValue["FacePolynomialTransform"],
      OptionValue["RequireTotalLowerFacetQ"], etaSym,
      OptionValue["SourceAwareDissectionOptions"]
    ] & /@ rows;
  keptRows = Select[rows, TrueQ[#["PreselectionKeepQ"]] &];
  stagedHRRows = Select[
    rows, TrueQ[Lookup[#["HRFSummary"], "StagedHiddenRegionQ", False]] &
  ];
  stagedStructuralGroups = hrfAsymptoticOrderAlignmentStructuralDeduplicateRows[stagedHRRows, vars];
  stagedStrictGroups = hrfAsymptoticOrderAlignmentStrictDeduplicateRows[stagedHRRows, vars];
  hrRows = Select[rows, TrueQ[Lookup[#["HRFSummary"], "HiddenRegionQ", False]] &];
  structuralGroups = hrfAsymptoticOrderAlignmentStructuralDeduplicateRows[hrRows, vars];
  strictGroups = hrfAsymptoticOrderAlignmentStrictDeduplicateRows[hrRows, vars];
  <|
    "InputPolynomial" -> F,
    "Rules" -> rules,
    "Variables" -> vars,
    "EtaSymbol" -> etaSym,
    "TermData" -> termData,
    "Faces" -> faces,
    "Rows" -> rows,
    "PreselectedRows" -> keptRows,
    "StagedHiddenRegionRows" -> stagedHRRows,
    "StagedDeduplicatedHiddenRegionGroups" -> stagedStructuralGroups,
    "StagedDeduplicatedHiddenRegionRows" -> Lookup[stagedStructuralGroups, "Representative", {}],
    "StagedStrictHiddenRegionPresentationGroups" -> stagedStrictGroups,
    "StagedStrictHiddenRegionPresentationRows" -> Lookup[stagedStrictGroups, "Representative", {}],
    "HiddenRegionRows" -> hrRows,
    "DeduplicatedHiddenRegionGroups" -> structuralGroups,
    "DeduplicatedHiddenRegionRows" -> Lookup[structuralGroups, "Representative", {}],
    "StrictHiddenRegionPresentationGroups" -> strictGroups,
    "StrictHiddenRegionPresentationRows" -> Lookup[strictGroups, "Representative", {}],
    "Summary" -> Join[
      hrfAsymptoticOrderAlignmentScanSummary[rows],
      <|
        "StagedUniqueHiddenRegionCount" -> Length[stagedStructuralGroups],
        "StagedStrictHiddenRegionPresentationCount" -> Length[stagedStrictGroups],
        "UniqueHiddenRegionCount" -> Length[structuralGroups],
        "StrictHiddenRegionPresentationCount" -> Length[strictGroups]
      |>
    ]
  |>
];

hrfAsymptoticOrderAlignmentScanSummary[rows_List] := <|
  "FaceCount" -> Length[rows],
  "PromotedFaceCount" -> Count[rows, r_ /; TrueQ[r["PromotedQ"]]],
  "PreselectionKeptCount" -> Count[rows, r_ /; TrueQ[r["PreselectionKeepQ"]]],
  "PreselectionPositiveCount" -> Count[
    rows,
    r_ /; TrueQ[r["PreselectionPotentialPinchQ"] === True]
  ],
  "PreselectionAmbiguousCount" -> Count[
    rows,
    r_ /; MatchQ[r["PreselectionPotentialPinchQ"], _Missing]
  ],
  "StagedHiddenRegionCount" -> Count[
    rows,
    r_ /; TrueQ[Lookup[r["HRFSummary"], "StagedHiddenRegionQ", False]]
  ],
  "TotalLowerFacetAcceptedCount" -> Count[
    rows,
    r_ /; TrueQ[Lookup[r["HRFSummary"], "TotalLowerFacetQ", False]]
  ],
  "ScalelessRejectedCount" -> Count[
    rows,
    r_ /; TrueQ[Lookup[r["HRFSummary"], "ScalelessRejectedQ", False]]
  ],
  "HiddenRegionCount" -> Count[
    rows,
    r_ /; TrueQ[Lookup[r["HRFSummary"], "HiddenRegionQ", False]]
  ],
  "RowsByExitReason" -> Counts[Lookup[rows, "PreselectionExitReason", {}]]
|>;

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] asymptotic-order alignment preselection layer. Use hrfAsymptoticOrderAlignmentSearch."]
];
