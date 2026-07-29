(* Exploratory five-point MRK and central-soft composite-limit scan.

   Physical labels follow the all-outgoing convention of the cited 2->3 paper:
     -p1,-p2 -> p3,p4,p5,
   with p4 the central emitted gluon.

   The composite chart is derived from
     p4_perp = delta^a k,   MRK gap parameter x = delta^b,  0 < a < b,
   at fixed exchanged transverse momentum p3_perp.  Consequently
     s12 ~ delta^(-2 b),
     s34,s45 ~ delta^(a-b),
     s23 = -T,
     s15 = -T - sigma C delta^a - (A B/S) delta^(2 a).
   The last term implements |p4_perp|^2=s1 s2/s.  C is the transverse
   interference 2 Re(p3_perp conjugate(k)); sigma selects its sign chart.
*)

$HistoryLength = 0;

ClearAll[repoDirectory, hrf5MRKSupportDirectory];
hrf5MRKSupportDirectory = DirectoryName[$InputFileName];
repoDirectory = If[ValueQ[$HRF5MRKRepoDirectory], $HRF5MRKRepoDirectory,
  DirectoryName[DirectoryName[hrf5MRKSupportDirectory]]];
$HRFPackageDirectory = repoDirectory;

$HRFQuietReports = True;
$HRFScalingReport = False;
$HRFUsePolynomialCancellationFactors = True;
$HRFPolynomialRequireKinematicDomainQ = True;

Get[FileNameJoin[{repoDirectory, "HiddenRegionFinder.wl"}]];

ClearAll[
  hrf5MRKCyclicOrders, hrf5MRKCanonicalOrder, hrf5MRKPentagonData,
  hrf5MRKSeedData, hrf5MRKGenericRules, hrf5MRKCentralSoftRules,
  hrf5MRKExactCentralSoftRules,
  hrf5MRKRunAlignment, hrf5MRKCompactSummary
];

(* Inequivalent cyclic orders modulo rotations and reversal, with p1 fixed. *)
hrf5MRKCyclicOrders[] := Module[{perms, canon},
  perms = ({1} ~Join~ #) & /@ Permutations[{2, 3, 4, 5}];
  canon[ord_] := First @ Sort[{ord, Prepend[Reverse[Rest[ord]], 1]}];
  DeleteDuplicates[canon /@ perms]
];

hrf5MRKCanonicalOrder = {1, 2, 3, 4, 5};

hrf5MRKPentagonData[order_List] := Module[{cycle, internal, external, uf},
  cycle = Range[5];
  internal = Map[{"0", #} &, Partition[Append[cycle, First[cycle]], 2, 1]];
  external = MapIndexed[{Symbol["p" <> ToString[#1]], First[#2]} &, order];
  uf = SymanzikUF[internal, external];
  <|
    "Topology" -> "OneLoopPentagon",
    "ExternalOrder" -> order,
    "InternalLines" -> internal,
    "ExternalLines" -> external,
    "Variables" -> uf["Variables"],
    "U" -> uf["U"],
    "F" -> Expand[toCyclicMandelstams[uf["F"]]]
  |>
];

(* The established two-loop six-propagator seed used in the five-point
   spacelike-collinear study, now tested in five-point MRK. *)
hrf5MRKSeedData[order_List] := Module[{internal, external, uf},
  internal = {
    {"0", {1, 3}}, {"0", {1, 5}}, {"0", {2, 3}},
    {"0", {2, 5}}, {"0", {3, 4}}, {"0", {4, 5}}
  };
  external = MapIndexed[{Symbol["p" <> ToString[#1]], First[#2]} &, order];
  uf = SymanzikUF[internal, external];
  <|
    "Topology" -> "TwoLoopSixPropagatorSeed",
    "ExternalOrder" -> order,
    "InternalLines" -> internal,
    "ExternalLines" -> external,
    "Variables" -> uf["Variables"],
    "U" -> uf["U"],
    "F" -> Expand[toCyclicMandelstams[uf["F"]]]
  |>
];

(* Generic MRK: x=delta. *)
hrf5MRKGenericRules[] := {
  s12 -> S/delta^2,
  s23 -> -T2,
  s34 -> A/delta,
  s45 -> B/delta,
  s15 -> -T1
};

(* Central-soft composite chart with 0<a<b. *)
hrf5MRKCentralSoftRules[a_Integer?Positive, b_Integer?Positive,
    sigma : (-1 | 1)] /; a < b := {
  s12 -> S/delta^(2 b),
  s23 -> -T,
  s34 -> A delta^(a-b),
  s45 -> B delta^(a-b),
  s15 -> -T - sigma C delta^a - (A B/S) delta^(2 a)
};

(* Exact massless light-cone realization of the same composite limit.

   Outgoing transverse momenta are q, lambda k, -q-lambda k, with
     |q|^2=T, |k|^2=R, 2 Re(q conjugate(k))=sigma C.
   Positive outgoing light-cone components are chosen as
     p3+ = P delta^-b,  p4+ = K delta^a,  p5- = M delta^-b,
   while the conjugate components follow exactly from p_i^2=0.  The two
   incoming components are the exact sums of the outgoing ones.  Hence all
   five invariant rules below obey on-shellness and momentum conservation at
   every nonzero delta, not only at leading MRK order. *)
hrf5MRKExactCentralSoftRules[a_Integer?Positive, b_Integer?Positive,
    sigma : (-1 | 1)] /; a < b := Module[
  {p3p, p3m, p4p, p4m, p5p, p5m, incomingPlus, incomingMinus, lam},
  lam = delta^a;
  p3p = P delta^-b;
  p3m = (T/P) delta^b;
  p4p = K lam;
  p4m = (R/K) lam;
  p5m = M delta^-b;
  p5p = ((T + sigma C lam + R lam^2)/M) delta^b;
  incomingPlus = p3p + p4p + p5p;
  incomingMinus = p3m + p4m + p5m;
  {
    s12 -> Expand[incomingPlus incomingMinus],
    s23 -> Expand[-incomingPlus p3m],
    s34 -> Expand[p3p p4m + p3m p4p - sigma C lam],
    s45 -> Expand[p4p p5m + p4m p5p + sigma C lam + 2 R lam^2],
    s15 -> Expand[-incomingMinus p5p]
  }
];

hrf5MRKCompactSummary[scan_Association] := Module[{a},
  a = Lookup[scan, "AsymptoticOrderAlignmentScan", <||>];
  <|
    "HiddenRegionQ" -> Lookup[scan, "HiddenRegionQ", False],
    "AlignmentHiddenRegionQ" -> Lookup[scan,
      "AsymptoticOrderAlignmentHiddenRegionQ", False],
    "AcceptedPresentationCount" -> Lookup[scan,
      "AsymptoticOrderAlignmentAcceptedPresentationCount", 0],
    "UniqueHiddenRegionCount" -> Lookup[scan,
      "AsymptoticOrderAlignmentUniqueHiddenRegionCount", 0],
    "AlignmentSummary" -> If[AssociationQ[a],
      Lookup[a, "Summary", Missing["NoSummary"]], Missing["NoScan"]]
  |>
];

hrf5MRKRunAlignment[data_Association, rules_List, kinVars_List,
    assumptions_, scalingRange_:Range[-4, 0]] := Module[{scan},
  scan = findObstructions[
    data["F"], data["Variables"], assumptions, kinVars, Automatic,
    "U" -> data["U"],
    "AsymptoticOrderAlignmentMode" -> "Only",
    "AsymptoticOrderAlignmentOptions" -> {
      "EtaSymbol" -> delta,
      "KinematicRules" -> rules,
      "MandelstamVariables" -> {},
      "DisableMandelstamLinearityForChartVariablesQ" -> True,
      "ScalingRange" -> scalingRange,
      "RequirePromotedQ" -> False,
      "MinFaceTerms" -> 2,
      "RunHRFQ" -> True,
      "HRFOptions" -> {
        "MaxScalingAbs" -> 12,
        "CandidateGeneratorSetLimit" -> 256
      }
    }
  ];
  <|"Scan" -> scan, "Summary" -> hrf5MRKCompactSummary[scan]|>
];

If[! TrueQ[$HRF5MRKLibraryOnly],
  genericAssumptions = S > 0 && A > 0 && B > 0 && T1 > 0 && T2 > 0;
  softAssumptions = S > 0 && A > 0 && B > 0 && T > 0 && C > 0;

  canonicalPentagon = hrf5MRKPentagonData[hrf5MRKCanonicalOrder];
  genericPentagonResult = hrf5MRKRunAlignment[
    canonicalPentagon, hrf5MRKGenericRules[],
    {S, A, B, T1, T2}, genericAssumptions, Range[-4, 0]
  ];
  Print["Canonical pentagon / generic MRK: ",
    InputForm[genericPentagonResult["Summary"]]];

  centralSoftPentagonResult = hrf5MRKRunAlignment[
    canonicalPentagon, hrf5MRKCentralSoftRules[1, 2, 1],
    {S, A, B, T, C}, softAssumptions, Range[-6, 0]
  ];
  Print["Canonical pentagon / central-soft a:b=1:2, sigma=+1: ",
    InputForm[centralSoftPentagonResult["Summary"]]];
];
