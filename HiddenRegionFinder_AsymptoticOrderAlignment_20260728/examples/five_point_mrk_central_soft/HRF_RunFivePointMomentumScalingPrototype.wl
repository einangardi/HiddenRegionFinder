$HistoryLength = 0;
base = DirectoryName[$InputFileName];
$HRF5MRKRepoDirectory = DirectoryName[DirectoryName[base]];
$HRF5MRKLibraryOnly = True;
Get[FileNameJoin[{base, "HRF_FivePointMRKExploratory.wl"}]];
Get[FileNameJoin[{base, "HRF_MomentumScalingReconstruction.wl"}]];

data = hrf5MRKSeedData[{1, 2, 3, 5, 4}];
summary = Get[FileNameJoin[{base, "certified_summary.wl"}]];
relativeLPScaling = summary["RepresentativeCertificate"]["RelativeTotalScaling"];

externalPowers = <|
  p1 -> {Infinity, -2, Infinity},
  p2 -> {-2, Infinity, Infinity},
  p3 -> {-2, 2, 0},
  p4 -> {1, 1, 1},
  p5 -> {2, -2, 0}
|>;

(* The relative LP vector does not determine the common virtuality power.
   Here the zero-weight edge x2 is hard, q2^2~s12~delta^-4. *)
anchoredResult = hrfMomentumScalingReconstruct[
  data["InternalLines"], data["ExternalLines"], data["Variables"],
  relativeLPScaling, externalPowers,
  "NormalizeLPScalingQ" -> True,
  "HardVirtualityPower" -> -4,
  "AllowCancellationEnhancedVirtualityQ" -> False,
  "ExponentBounds" -> {-2, 2},
  "ExponentStep" -> 1/2,
  "MaximumBranches" -> 20000,
  "SolverMethod" -> "ComponentFactorizedCSP",
  "SelectPreferredPhysicalBranchQ" -> True
];

representativeBranch = Lookup[anchoredResult,
  "PreferredHomogeneousBranch", Missing["NoRepresentativeBranch"]];
edgeBasisAudit = If[AssociationQ[representativeBranch],
  hrfMomentumEdgeBasisAudit[
    data["InternalLines"], data["Variables"], representativeBranch],
  Missing["NoRepresentativeBranch"]
];

representativeCombinationAudit = If[AssociationQ[representativeBranch],
  hrfMomentumLoopCombinationAudit[
    data["InternalLines"], data["ExternalLines"], data["Variables"],
    representativeBranch, externalPowers, {p1, p2}],
  Missing["NoRepresentativeBranch"]
];

(* Virtualities and vertex conservation do not by themselves select a unique
   momentum-space realization.  Search the complete bounded solution set for
   the branch with the largest number of balanced propagators that also has a
   transverse-dominated loop combination forced by momentum conservation. *)
branchBalancedCount[branch_Association] := Count[
  Values[branch["ComponentBalanceTypes"]], "Balanced"];
rankedBranches = Reverse @ SortBy[
  anchoredResult["Branches"], branchBalancedCount];
balanceLevels = Reverse @ Sort @ DeleteDuplicates[
  branchBalancedCount /@ rankedBranches];
allGlauberRows = {};
Do[
  levelSearch = Reap[
    Do[
      audit = hrfMomentumLoopCombinationAudit[
        data["InternalLines"], data["ExternalLines"], data["Variables"],
        branch, externalPowers, {p1, p2}];
      If[TrueQ[audit["GlauberCombinationFoundQ"]],
        Scan[
          Sow[<|"Branch" -> branch, "Audit" -> audit,
            "Witness" -> #|>] &,
          audit["GlauberCombinationRows"]
        ]
      ],
      {branch, Select[rankedBranches,
        branchBalancedCount[#] === balancedLevel &]}
    ]
  ][[2]];
  If[levelSearch =!= {}, allGlauberRows = First[levelSearch]; Break[]],
  {balancedLevel, balanceLevels}
];
bestGlauberRow = If[allGlauberRows === {},
  Missing["NoGlauberCompatibleBranch"],
  First @ SortBy[allGlauberRows,
    Function[row, With[{powers = row["Witness"]["OptimizedComponentPowers"]},
      {-branchBalancedCount[row["Branch"]],
       Abs[powers[[1]] - powers[[2]]],
       -Min[powers[[1]], powers[[2]]]}
    ]]]
];
glauberCompatibleBranch = If[AssociationQ[bestGlauberRow],
  bestGlauberRow["Branch"], bestGlauberRow];
glauberCombinationAudit = If[AssociationQ[bestGlauberRow],
  bestGlauberRow["Audit"], bestGlauberRow];
glauberWitness = If[AssociationQ[glauberCombinationAudit],
  bestGlauberRow["Witness"],
  Missing["NoGlauberWitness"]];

momentumAmbiguityAudit = <|
  "CompleteBoundedBranchCount" -> anchoredResult["BranchCount"],
  "MaxBalancedPropagatorCount" -> If[AssociationQ[representativeBranch],
    branchBalancedCount[representativeBranch], Missing["NoBranch"]],
  "MaximallyBalancedBranchHasGlauberCombinationQ" ->
    If[AssociationQ[representativeCombinationAudit],
      representativeCombinationAudit["GlauberCombinationFoundQ"],
      Missing["NoAudit"]],
  "BestGlauberCompatibleBalancedPropagatorCount" ->
    If[AssociationQ[glauberCompatibleBranch],
      branchBalancedCount[glauberCompatibleBranch], Missing["NoBranch"]],
  "BestGlauberCompatibleBranchHasGlauberPropagatorQ" ->
    If[AssociationQ[glauberCompatibleBranch],
      MemberQ[Values[glauberCompatibleBranch["ComponentBalanceTypes"]],
        "TransverseDominated"], Missing["NoBranch"]],
  "Conclusion" ->
    "The LP virtualities and vertex equations admit both a maximally balanced no-Glauber realization and a Glauber-compatible realization.  They therefore do not determine the loop mode uniquely; the leading pinch equations are needed as an additional selector."
|>;

(* A constructive leading-power realization.  With q0 and q3 independent,
     q1=p1-q0, q2=p2-q3,
     q4=q0+q2-p3, q5=p5-q4.
   Choose q0_perp~delta^-1/2, q0+~delta and split the leading p1-
   component between q0 and q1.  Choose q3+~delta, q3_perp~delta^-1/2
   and q3-~delta^-2.  Generic coefficients then give the dependent
   propagators and exactly the representative powers. *)
constructiveCertificate = <|
  "IndependentLoopEdges" -> {x0, x3},
  "DependentMomentumRelations" -> {
    "q1=p1-q0", "q2=p2-q3", "q4=q0+q2-p3", "q5=p5-q4"
  },
  "q0Power" -> {1, -2, -1/2},
  "q3Power" -> {1, -2, -1/2},
  "q0BalanceType" -> "Balanced",
  "q3BalanceType" -> "Balanced",
  "Interpretation" ->
    "Both independent loop modes are homogeneous.  Only the dependent hard propagator x2 is longitudinal-dominated; the other five propagators are homogeneous."
|>;

Print["=== physically anchored virtualities ==="];
Print[InputForm[KeyTake[anchoredResult,
  {"Status", "NormalizedLPScaling", "HardVirtualityPower",
   "VirtualityPowers", "BranchCount"}]]];
Print["=== representative branch ==="];
Print[InputForm[If[AssociationQ[representativeBranch],
  KeyTake[representativeBranch,
    {"EdgeComponentPowers", "VirtualityPowers", "VirtualityTypes",
     "ComponentBalanceTypes"}], representativeBranch]]];
Print["=== propagator-edge loop-basis audit ==="];
Print[InputForm[If[AssociationQ[edgeBasisAudit],
  KeyDrop[edgeBasisAudit, {"BasisRows"}], edgeBasisAudit]]];
Print["=== loop-combination ambiguity audit ==="];
Print[InputForm[momentumAmbiguityAudit]];
Print["=== best Glauber-compatible witness ==="];
Print[InputForm[<|
  "Branch" -> glauberCompatibleBranch,
  "Witness" -> glauberWitness
|>]];

Export[FileNameJoin[{base, "momentum_scaling_prototype_result.wl"}],
  <|
    "AnchoredResult" -> anchoredResult,
    "RepresentativeBranch" -> representativeBranch,
    "EdgeBasisAudit" -> edgeBasisAudit,
    "RepresentativeCombinationAudit" -> representativeCombinationAudit,
    "GlauberCompatibleBranch" -> glauberCompatibleBranch,
    "GlauberCombinationAudit" -> glauberCombinationAudit,
    "GlauberWitness" -> glauberWitness,
    "MomentumAmbiguityAudit" -> momentumAmbiguityAudit,
    "ConstructiveCertificate" -> constructiveCertificate
  |>, "Package"];
