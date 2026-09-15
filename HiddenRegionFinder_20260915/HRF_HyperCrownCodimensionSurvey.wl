(* Current HyperCrown wide-angle survey through codimension two.
   Load after HiddenRegionFinder.wl, 01_WideAngle_2to2_OffShell.wl,
   HRF_PolynomialCancellationFactors.wl and 04_PolynomialFactor_Regression.wl.

   Positive rows are conclusive existence results.  A negative row is called
   an exclusion only when the full harvest was used, no candidate cap was
   reached, every trial completed, and exact coverage rejected them all. *)

ClearAll[
  hrfHyperCrownCodimensionSurveyTable,
  hrfHyperCrownLegacyComparisonTable,
  hrfHyperCrownPositiveRegionVectorTable,
  hrfHyperCrownEstablishedTypeTable,
  hrfHyperCrownSymmetryOrbitTable,
  hrfHyperCrownSymmetryAudit,
  hrfHyperCrownBoundaryOrbit,
  hrfHyperCrownVariableIndex,
  hrfHyperCrownSortVariables,
  hrfHyperCrownActiveVariables,
  hrfHyperCrownVectorString,
  hrfHyperCrownComponentRuleString,
  hrfHyperCrownRunCurrentStratum,
  hrfHyperCrownStratumAudit,
  hrfHyperCrownOppositePairChannelAudit
];

(* The graph has the D4 symmetry of the square
     5 -- 9
     |    |
     7 -- 8
   with external vertices {1,4,3,2} attached in that cyclic order and
   vertex 6 fixed.  A and C generate the order-four subgroup that fixes
   {s12,s23}.  B exchanges s12 and s23.  The survey quotients by the full
   D4 action: external labels, edge labels and invariants are relabelled
   simultaneously, so crossing-related representatives are not rerun as
   separate topologies. *)

HyperCrownVariableOrder20260728 =
  Table[Symbol["x" <> ToString[i]], {i, 0, 11}];

HyperCrownD4Generators20260728 = {
  <|"Name" -> "A", "ExternalPermutation" -> {1 -> 2, 2 -> 1, 3 -> 4, 4 -> 3},
    "EdgePermutation" -> Thread[HyperCrownVariableOrder20260728 ->
      {x4, x5, x6, x7, x0, x1, x2, x3, x9, x8, x10, x11}],
    "KinematicPermutation" -> {s12 -> s12, s23 -> s23}|>,
  <|"Name" -> "B", "ExternalPermutation" -> {1 -> 1, 2 -> 4, 3 -> 3, 4 -> 2},
    "EdgePermutation" -> Thread[HyperCrownVariableOrder20260728 ->
      {x0, x1, x4, x5, x2, x3, x6, x7, x11, x10, x9, x8}],
    "KinematicPermutation" -> {s12 -> s23, s23 -> s12}|>,
  <|"Name" -> "C", "ExternalPermutation" -> {1 -> 4, 2 -> 3, 3 -> 2, 4 -> 1},
    "EdgePermutation" -> Thread[HyperCrownVariableOrder20260728 ->
      {x2, x3, x0, x1, x6, x7, x4, x5, x8, x9, x11, x10}],
    "KinematicPermutation" -> {s12 -> s12, s23 -> s23}|>
};

HyperCrownFixedLabelSymmetryGenerators20260728 =
  HyperCrownD4Generators20260728[[{1, 3}]];

HyperCrownSymmetryOrbits20260728 = {
  <|"Codimension" -> 0, "Orbit" -> "interior",
    "Representative" -> {}, "Members" -> {{}},
    "Status" -> "Unresolved direct scan"|>,
  <|"Codimension" -> 1, "Orbit" -> "type I: one square edge contracted",
    "Representative" -> {x9},
    "Members" -> {{x8}, {x9}, {x10}, {x11}},
    "Status" -> "HR established on the whole orbit"|>,
  <|"Codimension" -> 2, "Orbit" -> "adjacent square edges contracted",
    "Representative" -> {x8, x10},
    "Members" -> {{x8, x10}, {x9, x10}, {x9, x11}, {x8, x11}},
    "Status" -> "HR established on the whole orbit"|>,
  <|"Codimension" -> 2, "Orbit" -> "opposite square edges contracted",
    "Representative" -> {x8, x9},
    "Members" -> {{x8, x9}, {x10, x11}},
    "Status" -> "No HR: uncapped complete-polynomial-factor scan and exact coverage"|>
};

HyperCrownCodimensionSurvey20260728 = {
  <|"Stratum" -> "Interior", "ZeroVars" -> {}, "Codimension" -> 0,
    "Harvest" -> "Full", "FactorCount" -> 2149,
    "CompletedTrials" -> 63, "CandidateCap" -> 64,
    "CurrentOutcome" -> "No HR in completed trials",
    "Evidence" -> "Direct capped scan only",
    "Confidence" -> "Unresolved: trial 64 timed out; pool capped",
    "LegacyClaim" -> "No HR"|>,
  <|"Stratum" -> "x8=0", "ZeroVars" -> {x8}, "Codimension" -> 1,
    "Harvest" -> "Full", "FactorCount" -> 796,
    "CompletedTrials" -> 63, "CandidateCap" -> 64,
    "CurrentOutcome" -> "HR found by exact D4 symmetry",
    "HiddenRegionCount" -> 1,
    "Evidence" -> "Image of x9=0 under A: x8<->x9; s12,s23 fixed",
    "Confidence" -> "Established existence",
    "LegacyClaim" -> "No HR"|>,
  <|"Stratum" -> "x9=0", "ZeroVars" -> {x9}, "Codimension" -> 1,
    "Harvest" -> "Lightweight positive witness", "FactorCount" -> 25,
    "CompletedTrials" -> 4, "CandidateCap" -> 64,
    "CurrentOutcome" -> "HR found", "HiddenRegionCount" -> 1,
    "Evidence" -> "Direct HRF witness",
    "Confidence" -> "Established existence", "LegacyClaim" -> "No HR"|>,
  <|"Stratum" -> "x10=0", "ZeroVars" -> {x10}, "Codimension" -> 1,
    "Harvest" -> "Lightweight positive witness", "FactorCount" -> 25,
    "CompletedTrials" -> 4, "CandidateCap" -> 64,
    "CurrentOutcome" -> "HR found", "HiddenRegionCount" -> 1,
    "Evidence" -> "Direct HRF witness",
    "Confidence" -> "Established existence", "LegacyClaim" -> "No HR"|>,
  <|"Stratum" -> "x11=0", "ZeroVars" -> {x11}, "Codimension" -> 1,
    "Harvest" -> "Lightweight positive witness", "FactorCount" -> 25,
    "CompletedTrials" -> 4, "CandidateCap" -> 64,
    "CurrentOutcome" -> "HR found", "HiddenRegionCount" -> 1,
    "Evidence" -> "Direct HRF witness",
    "Confidence" -> "Established existence", "LegacyClaim" -> "No HR"|>,
  <|"Stratum" -> "x8=x9=0", "ZeroVars" -> {x8, x9}, "Codimension" -> 2,
    "Harvest" -> "Complete derivative/channel-polynomial factors", "FactorCount" -> 35,
    "CompletedTrials" -> 1, "CandidateCap" -> Infinity,
    "CurrentOutcome" -> "No HR",
    "Evidence" -> "Uncapped scan: sole generator is s12-supported; exact coverage finds no scaling",
    "Confidence" -> "Certified within the complete polynomial-factor construction; no search cap reached",
    "LegacyClaim" -> "HR"|>,
  <|"Stratum" -> "x8=x10=0", "ZeroVars" -> {x8, x10}, "Codimension" -> 2,
    "Harvest" -> "Full", "FactorCount" -> 149,
    "CompletedTrials" -> 64, "CandidateCap" -> 64,
    "CurrentOutcome" -> "HR found", "HiddenRegionCount" -> 1,
    "AcceptedGeneratorPresentationCount" -> 2,
    "Evidence" -> "Direct HRF witness",
    "Confidence" -> "Established existence", "LegacyClaim" -> "No HR"|>,
  <|"Stratum" -> "x8=x11=0", "ZeroVars" -> {x8, x11}, "Codimension" -> 2,
    "Harvest" -> "Full", "FactorCount" -> 149,
    "CompletedTrials" -> 64, "CandidateCap" -> 64,
    "CurrentOutcome" -> "HR found", "HiddenRegionCount" -> 1,
    "AcceptedGeneratorPresentationCount" -> 2,
    "Evidence" -> "Direct HRF witness",
    "Confidence" -> "Established existence", "LegacyClaim" -> "No HR"|>,
  <|"Stratum" -> "x9=x10=0", "ZeroVars" -> {x9, x10}, "Codimension" -> 2,
    "Harvest" -> "Full", "FactorCount" -> 150,
    "CompletedTrials" -> 64, "CandidateCap" -> 64,
    "CurrentOutcome" -> "HR found by exact D4 symmetry",
    "HiddenRegionCount" -> 1,
    "Evidence" -> "Image of an established adjacent-pair stratum",
    "Confidence" -> "Established existence",
    "LegacyClaim" -> "No HR"|>,
  <|"Stratum" -> "x9=x11=0", "ZeroVars" -> {x9, x11}, "Codimension" -> 2,
    "Harvest" -> "Full", "FactorCount" -> 153,
    "CompletedTrials" -> 64, "CandidateCap" -> 64,
    "CurrentOutcome" -> "HR found by exact D4 symmetry",
    "HiddenRegionCount" -> 1,
    "Evidence" -> "Image of an established adjacent-pair stratum",
    "Confidence" -> "Established existence",
    "LegacyClaim" -> "No HR"|>,
  <|"Stratum" -> "x10=x11=0", "ZeroVars" -> {x10, x11}, "Codimension" -> 2,
    "Harvest" -> "By exact D4 image", "FactorCount" -> 35,
    "CompletedTrials" -> 1, "CandidateCap" -> Infinity,
    "CurrentOutcome" -> "No HR",
    "Evidence" -> "D4 image of the uncapped x8=x9=0 certificate",
    "Confidence" -> "Certified within the complete polynomial-factor construction",
    "LegacyClaim" -> "HR"|>
};

HyperCrownPositiveRegionVectors20260728 = {
  <|"Stratum" -> "x8=0", "ZeroVars" -> {x8},
    "Evidence" -> "D4 image of x9=0",
    "VariableScaling" -> AssociationThread[
      DeleteCases[HyperCrownVariableOrder20260728, x8],
      (If[# === x9, -2, -1] &) /@
        DeleteCases[HyperCrownVariableOrder20260728, x8]],
    "W_SL" -> -6, "W_HR" -> -5,
    "DistinctRegionVectorCount" -> 1|>,
  <|"Stratum" -> "x9=0", "ZeroVars" -> {x9},
    "Evidence" -> "Direct HRF witness",
    "VariableScaling" -> <|x0 -> -1, x1 -> -1, x10 -> -1, x11 -> -1,
      x2 -> -1, x3 -> -1, x4 -> -1, x5 -> -1, x6 -> -1, x7 -> -1,
      x8 -> -2|>, "W_SL" -> -6, "W_HR" -> -5,
    "DistinctRegionVectorCount" -> 1|>,
  <|"Stratum" -> "x10=0", "ZeroVars" -> {x10},
    "Evidence" -> "Direct HRF witness",
    "VariableScaling" -> <|x0 -> -1, x1 -> -1, x11 -> -2, x2 -> -1,
      x3 -> -1, x4 -> -1, x5 -> -1, x6 -> -1, x7 -> -1, x8 -> -1,
      x9 -> -1|>, "W_SL" -> -6, "W_HR" -> -5,
    "DistinctRegionVectorCount" -> 1|>,
  <|"Stratum" -> "x11=0", "ZeroVars" -> {x11},
    "Evidence" -> "Direct HRF witness",
    "VariableScaling" -> <|x0 -> -1, x1 -> -1, x10 -> -2, x2 -> -1,
      x3 -> -1, x4 -> -1, x5 -> -1, x6 -> -1, x7 -> -1, x8 -> -1,
      x9 -> -1|>, "W_SL" -> -6, "W_HR" -> -5,
    "DistinctRegionVectorCount" -> 1|>,
  <|"Stratum" -> "x8=x10=0", "ZeroVars" -> {x8, x10},
    "Evidence" -> "Direct HRF witness",
    "VariableScaling" -> AssociationThread[
      DeleteCases[HyperCrownVariableOrder20260728, Alternatives[x8, x10]],
      ConstantArray[-1, 10]],
    "W_SL" -> -5, "W_HR" -> -4,
    "AcceptedGeneratorPresentationCount" -> 2,
    "DistinctRegionVectorCount" -> 1|>,
  <|"Stratum" -> "x8=x11=0", "ZeroVars" -> {x8, x11},
    "Evidence" -> "Direct HRF witness",
    "VariableScaling" -> AssociationThread[
      DeleteCases[HyperCrownVariableOrder20260728, Alternatives[x8, x11]],
      ConstantArray[-1, 10]],
    "W_SL" -> -5, "W_HR" -> -4,
    "AcceptedGeneratorPresentationCount" -> 2,
    "DistinctRegionVectorCount" -> 1|>,
  <|"Stratum" -> "x9=x10=0", "ZeroVars" -> {x9, x10},
    "Evidence" -> "D4 image of an established adjacent-pair stratum",
    "VariableScaling" -> AssociationThread[
      DeleteCases[HyperCrownVariableOrder20260728, Alternatives[x9, x10]],
      ConstantArray[-1, 10]],
    "W_SL" -> -5, "W_HR" -> -4,
    "AcceptedGeneratorPresentationCount" -> 2,
    "DistinctRegionVectorCount" -> 1|>,
  <|"Stratum" -> "x9=x11=0", "ZeroVars" -> {x9, x11},
    "Evidence" -> "D4 image of an established adjacent-pair stratum",
    "VariableScaling" -> AssociationThread[
      DeleteCases[HyperCrownVariableOrder20260728, Alternatives[x9, x11]],
      ConstantArray[-1, 10]],
    "W_SL" -> -5, "W_HR" -> -4,
    "AcceptedGeneratorPresentationCount" -> 2,
    "DistinctRegionVectorCount" -> 1|>
};

hrfHyperCrownVariableIndex[x_Symbol] :=
  ToExpression[StringDrop[SymbolName[Unevaluated[x]], 1]];

hrfHyperCrownSortVariables[xs_List] := SortBy[xs, hrfHyperCrownVariableIndex];

hrfHyperCrownActiveVariables[zeroVars_List] :=
  Select[HyperCrownVariableOrder20260728, ! MemberQ[zeroVars, #] &];

hrfHyperCrownBoundaryOrbit[
    zeroVars_List,
    generators_List : HyperCrownD4Generators20260728] := SortBy[
  FixedPoint[
    Function[sets, DeleteDuplicates @ Join[sets,
      Flatten[Table[
        hrfHyperCrownSortVariables[
          set /. generator["EdgePermutation"]],
        {set, sets}, {generator, generators}], 1]]],
    {hrfHyperCrownSortVariables[zeroVars]}],
  ToString[InputForm[#]] &
];

hrfHyperCrownVectorString[row_Association] := Module[{active, values},
  active = hrfHyperCrownActiveVariables[row["ZeroVars"]];
  values = Lookup[row["VariableScaling"], active];
  "(" <> StringRiffle[ToString[InputForm[#]] & /@ values, ", "] <> "; 1)"
];

hrfHyperCrownComponentRuleString[row_Association] := Module[{active, rules},
  active = hrfHyperCrownActiveVariables[row["ZeroVars"]];
  rules = MapThread[
    "v" <> ToString[hrfHyperCrownVariableIndex[#1]] <> " -> " <>
      ToString[InputForm[#2]] &,
    {active, Lookup[row["VariableScaling"], active]}];
  "{" <> StringRiffle[rules, ", "] <> "}"
];

hrfHyperCrownPositiveRegionVectorTable[] := Column[{
  Style[
    "Notation: B is the set of boundary equations x_e=0.  For every active edge, x_e ~ delta^(v_e).  " <>
    "Delete B from X=(x0,x1,...,x11), retaining this order; the displayed augmented normal is v_B=(v_e;1).",
    "Text"],
  Grid[
    Prepend[
      Map[Function[row, {
        row["Stratum"], hrfHyperCrownVectorString[row],
        hrfHyperCrownComponentRuleString[row],
        row["W_SL"], row["W_HR"],
        Lookup[row, "AcceptedGeneratorPresentationCount", 1],
        row["DistinctRegionVectorCount"], row["Evidence"]
      }], HyperCrownPositiveRegionVectors20260728],
      {"Boundary B", "v_B in active-edge order", "Named components",
       "W_SL", "W_HR", "Accepted presentations", "Distinct HR vectors",
       "Evidence"}],
    Frame -> All, Alignment -> Left, ItemSize -> All,
    Background -> {None, {LightGray, None}}
  ]
}, Spacings -> 1];

hrfHyperCrownEstablishedTypeTable[] := Dataset[{
  <|
    "Type" -> "I",
    "Codimension" -> 1,
    "Representative B" -> "{x9=0}",
    "All labelled boundaries" ->
      "{x8=0}, {x9=0}, {x10=0}, {x11=0}",
    "Scaling pattern" ->
      "the opposite surviving square edge has v_e=-2; every other active v_e=-1",
    "Momentum interpretation" -> "Landshoff descendant plus one soft loop",
    "Certainty" -> "Established"
  |>,
  <|
    "Type" -> "II",
    "Codimension" -> 2,
    "Representative B" -> "{x8=0,x10=0}",
    "All labelled boundaries" ->
      "{x8,x10}=0, {x9,x10}=0, {x9,x11}=0, {x8,x11}=0",
    "Scaling pattern" -> "v_e=-1 for every active edge",
    "Momentum interpretation" ->
      "Landshoff descendant plus one external-direction collinear loop",
    "Certainty" -> "Established"
  |>
}];

hrfHyperCrownSymmetryOrbitTable[] := Dataset @ Map[
  Function[row, <|
    "Codimension" -> row["Codimension"], "Orbit" -> row["Orbit"],
    "Representative" -> ToString[InputForm[row["Representative"]]],
    "Orbit members" -> ToString[InputForm[row["Members"]]],
    "Conclusion" -> row["Status"]
  |>], HyperCrownSymmetryOrbits20260728];

hrfHyperCrownSymmetryAudit[] := Module[
  {vars = HyperCrownVariableOrder20260728, a, b, c, z},
  a = HyperCrownD4Generators20260728[[1, "EdgePermutation"]];
  b = HyperCrownD4Generators20260728[[2, "EdgePermutation"]];
  c = HyperCrownD4Generators20260728[[3, "EdgePermutation"]];
  <|
    "Graph automorphism group" -> "D4", "Graph group order" -> 8,
    "Fixed-label subgroup" -> "<A,C>",
    "Fixed-label subgroup order" -> 4,
    "Equivalence used in this survey" ->
      "full D4: simultaneous external, edge and invariant relabelling, including crossings",
    "A maps x9=0 to x8=0" -> Sort[{x9 /. a}] === {x8},
    "A preserves F0 with s12,s23 fixed" ->
      TrueQ[Expand[(F0HyperCrown /. a) - F0HyperCrown] === 0],
    "C maps x10=0 to x11=0" -> Sort[{x10 /. c}] === {x11},
    "C preserves F0 with s12,s23 fixed" ->
      TrueQ[Expand[(F0HyperCrown /. c) - F0HyperCrown] === 0],
    "B exchanges s12 and s23" ->
      TrueQ[Expand[
        (F0HyperCrown /. b /. {s12 -> z, s23 -> s12} /. z -> s23) -
          F0HyperCrown] === 0],
    "Computed codimension-one orbit has four members" ->
      Length[hrfHyperCrownBoundaryOrbit[{x9}]] === 4,
    "Computed adjacent-pair orbit has four members" ->
      Length[hrfHyperCrownBoundaryOrbit[{x8, x10}]] === 4,
    "Computed opposite-pair orbit has two members" ->
      Length[hrfHyperCrownBoundaryOrbit[{x8, x9}]] === 2,
    "Established inequivalent HR types" -> 2,
    "Established labelled boundary strata" -> 8,
    "Codimension-one orbit" -> "{x8}, {x9}, {x10}, {x11}",
    "Adjacent-pair orbit" ->
      "{x8,x10}, {x9,x10}, {x9,x11}, {x8,x11}",
    "Excluded opposite-pair orbit" -> "{x8,x9}, {x10,x11}"
  |>
];

hrfHyperCrownCodimensionSurveyTable[] := Dataset[
  KeyTake[#, {"Codimension", "Stratum", "Harvest", "FactorCount",
      "CompletedTrials", "CurrentOutcome", "Evidence", "Confidence"}] & /@
    HyperCrownCodimensionSurvey20260728
];

hrfHyperCrownLegacyComparisonTable[] := Dataset[
  KeyTake[#, {"Codimension", "Stratum", "LegacyClaim", "CurrentOutcome",
      "Confidence"}] & /@ HyperCrownCodimensionSurvey20260728
];

(* Search budgets are explicit user-facing data.  Exploratory limits may find
   positive witnesses quickly but can never certify absence.  The certified
   profile removes correctness-sensitive caps; resource timeouts, if any,
   must be reported as incomplete rather than as "no HR". *)
HRFSearchProfiles20260728 = <|
  "Exploratory" -> <|
    "CandidateGeneratorSetLimit" -> 64,
    "MaxTwoGeneratorUnionTrials" -> 48,
    "PolynomialMaxMonomials" -> Automatic,
    "LegacySignedMonomialPairsQ" -> False,
    "KinDomainFindInstanceTimeLimit" -> 5,
    "ObstructionFindInstanceTimeLimit" -> 20
  |>,
  "Certified" -> <|
    "CandidateGeneratorSetLimit" -> Infinity,
    "MaxTwoGeneratorUnionTrials" -> Infinity,
    "PolynomialMaxMonomials" -> Automatic,
    "LegacySignedMonomialPairsQ" -> False,
    "KinDomainFindInstanceTimeLimit" -> Infinity,
    "ObstructionFindInstanceTimeLimit" -> Infinity
  |>
|>;

hrfHyperCrownOppositePairChannelAudit[] := Module[
  {zeroVars = {x8, x9}, f, vars, factors, byDerivative, opts, sets,
   singles, tags, a12, a23},
  f = Expand[F0HyperCrown /. {x8 -> 0, x9 -> 0}];
  vars = Complement[VarsHyperCrown, zeroVars];
  a12 = Expand[Coefficient[f, s12]];
  a23 = Expand[Coefficient[f, s23]];
  Block[{
      $HRFPolynomialEnableSignedMonomialPairs = False,
      $HRFPolynomialMaxMonomials = Automatic,
      $HRFKinDomainFindInstanceTimeLimit = Infinity,
      $HRFMaxTwoGeneratorUnionTrials = 0
    },
    {factors, byDerivative} = safeCancellationFactorsExtended[
      f, vars, KinAssump4ptOnShell, KinVars4pt, {}
    ];
    opts = <|
      "CandidateGeneratorSetLimit" -> Infinity,
      "MaxTwoGeneratorUnionTrials" -> 0,
      "MaxGenerators" -> 2,
      "MaxProductSubsetSize" -> 2,
      "RelaxSingleProductDegreeQ" -> False,
      "SkipPDFFindInstanceQ" -> False,
      "UseGeneratorCompletionQ" -> False,
      "UseGeneratorSectorQuotientQ" -> False
    |>;
    sets = candidateGeneratorSetsDiagnostic[
      factors, 2, vars, KinAssump4ptOnShell, KinVars4pt, f, opts
    ]
  ];
  singles = First /@ Select[sets, Length[#] === 1 &];
  tags = hrfGeneratorSectorSupportTags[singles, f, vars, KinVars4pt];
  <|
    "Boundary" -> zeroVars,
    "CoefficientOfS12" -> Factor[a12],
    "CoefficientOfS23" -> Factor[a23],
    "CompleteCancellationFactorCount" -> Length[factors],
    "AdmissibleGenerators" ->
      hrfFormatGeneratorsForOutput[singles, factors, vars, KinVars4pt],
    "GeneratorSectorTags" -> tags,
    "S12GeneratorCount" -> Count[tags, _?(MemberQ[#, s12] &)],
    "S23GeneratorCount" -> Count[tags, _?(MemberQ[#, s23] &)],
    "S23CrownLikeGeneratorExistsQ" -> AnyTrue[tags, MemberQ[#, s23] &]
  |>
];

Options[hrfHyperCrownRunCurrentStratum] = {
  "FullHarvestQ" -> True,
  "CandidateGeneratorSetLimit" -> 64,
  "MaxTwoGeneratorUnionTrials" -> 48,
  "PolynomialMaxMonomials" -> Automatic,
  "LegacySignedMonomialPairsQ" -> False,
  "KinDomainFindInstanceTimeLimit" -> Inherited,
  "ObstructionFindInstanceTimeLimit" -> Inherited,
  "StopOnFirstAdmissible" -> False
};

hrfHyperCrownRunCurrentStratum[zeroVars_List, OptionsPattern[]] := Module[
  {fullQ = TrueQ[OptionValue["FullHarvestQ"]], uRestricted, label},
  uRestricted = Expand[HyperCrownData["UF"]["U"] /. Thread[zeroVars -> 0]];
  label = If[zeroVars === {}, "HyperCrown interior",
    "HyperCrown boundary " <> ToString[InputForm[zeroVars]]];
  Block[
    {$HRFEx04LightweightCaseQ = ! fullQ,
     $HRFPolynomialEnableSignedMonomialPairs =
       TrueQ[OptionValue["LegacySignedMonomialPairsQ"]],
     $HRFCandidateGeneratorSetLimit = OptionValue["CandidateGeneratorSetLimit"],
     $HRFMaxTwoGeneratorUnionTrials = OptionValue["MaxTwoGeneratorUnionTrials"],
     $HRFPolynomialMaxMonomials = OptionValue["PolynomialMaxMonomials"],
     $HRFKinDomainFindInstanceTimeLimit = Replace[
       OptionValue["KinDomainFindInstanceTimeLimit"],
       Inherited :> If[ValueQ[$HRFKinDomainFindInstanceTimeLimit],
         $HRFKinDomainFindInstanceTimeLimit, 5]],
     $HRFObstructionFindInstanceTimeLimit = Replace[
       OptionValue["ObstructionFindInstanceTimeLimit"],
       Inherited :> If[ValueQ[$HRFObstructionFindInstanceTimeLimit],
         $HRFObstructionFindInstanceTimeLimit, 20]],
     $HRFFindObstructionsStopOnFirstAdmissibleQ =
       TrueQ[OptionValue["StopOnFirstAdmissible"]]},
    hrfEx04RunObstructionCase[
      F0HyperCrown, VarsHyperCrown, KinAssump4ptOnShell, KinVars4pt,
      label, If[zeroVars === {}, 20, Automatic], zeroVars, uRestricted,
      If[zeroVars === {}, "WideAngle4ptExhaustive", "WideAngle4ptBoundary"]
    ]
  ]
];

hrfHyperCrownStratumAudit[case_Association] := Module[{scan = case["PolynomialScan"]},
  <|
    "ZeroVars" -> case["ZeroVars"],
    "CandidateGeneratorCount" -> Lookup[scan, "CandidateGeneratorCount", Missing[]],
    "CandidateGeneratorSetLimitReachedQ" ->
      Lookup[scan, "CandidateGeneratorSetLimitReachedQ", Missing[]],
    "SearchTruncatedQ" -> Lookup[scan, "SearchTruncatedQ", Missing[]],
    "EffectiveSearchConfiguration" ->
      Lookup[scan, "EffectiveSearchConfiguration", Missing[]],
    "GeneratorConstructionAudit" ->
      Lookup[scan, "GeneratorConstructionAudit", Missing[]],
    "AllCandidateGeneratorSetsTriedQ" ->
      Lookup[scan, "AllCandidateGeneratorSetsTriedQ", Missing[]],
    "HiddenRegionSearchCompleteQ" ->
      Lookup[scan, "HiddenRegionSearchCompleteQ", Missing[]],
    "NoHiddenRegionWithinSearchBoundsQ" ->
      Lookup[scan, "NoHiddenRegionWithinSearchBoundsQ", Missing[]],
    "HiddenRegionCount" -> Lookup[scan, "HiddenRegionCount", 0],
    "Generators" -> Lookup[scan, "Generators", {}],
    "ObstructionAttemptSummary" ->
      Lookup[scan, "ObstructionAttemptSummary", Missing[]]
  |>
];

Print["[loaded] HyperCrown codimension 0--2 current survey. Try hrfHyperCrownCodimensionSurveyTable[]."];
