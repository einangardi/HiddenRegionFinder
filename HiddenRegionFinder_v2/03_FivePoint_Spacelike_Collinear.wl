(* ::Package:: *)

(* 03_FivePoint_Spacelike_Collinear.wl

   Five-point massless scattering in the spacelike collinear limit.

   This example starts from the six-propagator seed topology and performs the
   complete organised analysis of the seven- and eight-propagator descendants
   obtained by splitting the four-point vertices of the seed graph.

   The workflow mirrors the research notebook:
     1. construct the seed Symanzik polynomials;
     2. generate all one-split 7-propagator graphs and selected two-split
        8-propagator graphs;
     3. build U and F for every descendant;
     4. take the spacelike collinear leading polynomial Flead;
     5. run obstruction scans in the interior and on boundary strata;
     6. collect the interesting boundary cases and LP scaling data;
     7. build paper-style topology/region summaries with generators and comments.

   Cancellation factors:
     $HRFEx03UsePolynomialFactorsQ = False  -> binomial (legacy default in .wl)
     $HRFEx03UsePolynomialFactorsQ = True   -> footnote-4 polynomial patch (recommended for HR verification)
*)

$HRFExample03Directory = If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName],
  Quiet[Check[NotebookDirectory[], Directory[]]]
];

If[! ValueQ[$HRFEx03UsePolynomialFactorsQ], $HRFEx03UsePolynomialFactorsQ = False];
If[! ValueQ[$HRFEx03ObstructionProgressQ], $HRFEx03ObstructionProgressQ = TrueQ[$HRFExampleVerbose]];
If[! ValueQ[$HRFCandidateGeneratorSetLimit], $HRFCandidateGeneratorSetLimit = 64];
(* 7-prop boundary: only codim-1 strata {x}=0 for listed Symanzik vars (default x6 = 7th propagator). *)
If[! ValueQ[$HRFEx03SevenPropBoundaryZeroVars], $HRFEx03SevenPropBoundaryZeroVars = {x6}];
If[! ValueQ[$HRFEx03RunEightPropBoundaryScanQ], $HRFEx03RunEightPropBoundaryScanQ = False];
If[! ValueQ[$HRFEx03RunFullTopologyScanQ], $HRFEx03RunFullTopologyScanQ = True];
$HRFEx03DeferredFullScanMessage =
  "Full 7/8-propagator scan disabled ($HRFEx03RunFullTopologyScanQ=False). \
Confirm seed via hrfEx03RunSeedObstruction[] first, then reload with \
$HRFEx03RunFullTopologyScanQ=True.";

ClearAll[hrfEx03EnsurePolynomialPatch, hrfEx03CancellationFactorMode];
hrfEx03CancellationFactorMode[] := If[TrueQ[$HRFEx03UsePolynomialFactorsQ], "Polynomial", "Binomial"];
hrfEx03EnsurePolynomialPatch[] := Module[{},
  If[! TrueQ[$HRFEx03UsePolynomialFactorsQ], Return[False]];
  If[! ValueQ[hrfInstallPolynomialCancellationPatch],
    Get[FileNameJoin[{$HRFExample03Directory, "HRF_PolynomialCancellationFactors.wl"}]]
  ];
  If[! ValueQ[$HRFPolynomialRequireKinematicDomainQ], $HRFPolynomialRequireKinematicDomainQ = False];
  If[! ValueQ[$HRFUsePolynomialCancellationFactors], $HRFUsePolynomialCancellationFactors = True];
  hrfInstallPolynomialCancellationPatch[];
  True
];

If[! TrueQ[$HRFFinderCoreLoadedQ], Get[$HRFExample03Directory <> "HiddenRegionFinder.wl"]];
hrfEx03EnsurePolynomialPatch[];
Get[$HRFExample03Directory <> "HRF_FivePointReporting.wl"];

If[! TrueQ[$HRFQuietReports],
  Print["[Example 03] mode: ",
    If[TrueQ[$HRFEx03RunFullTopologyScanQ], "full topology scan", "seed-only (full scan deferred)"],
    "; cancellation factors: ", hrfEx03CancellationFactorMode[]];
  If[TrueQ[$HRFEx03RunFullTopologyScanQ],
    Print["[Example 03] 7-prop graphs expected: 6; 8-prop: 9; StopOnFirstAdmissible=",
      TrueQ[$HRFFindObstructionsStopOnFirstAdmissibleQ]];
    Print["[Example 03] boundary scan: 7-prop zero vars ", $HRFEx03SevenPropBoundaryZeroVars,
      "; 8-prop boundary=", TrueQ[$HRFEx03RunEightPropBoundaryScanQ]]
  ,
    Print["[Example 03] ", $HRFEx03DeferredFullScanMessage]
  ];
  If[! TrueQ[$HRFEx03UsePolynomialFactorsQ],
    Print["[Example 03] NOTE: binomial mode. Set $HRFEx03UsePolynomialFactorsQ = True BEFORE Get[03_FivePoint_Spacelike_Collinear.wl] for polynomial f_k (HR verification)."]
  ]
];

(* Keep general example output quiet.  Only the scaling routine reports concise
   diagnostics, since that is the part currently being tested. *)
$HRFExampleVerbose = False;
$HRFVerboseScaling = False;
$HRFScalingReport = True;

ClearAll[hrfReport, hrfTimed, hrfTimedTable];
hrfReport[msg___] := If[TrueQ[$HRFExampleVerbose], Print[DateString[{"Hour", ":", "Minute", ":", "Second"}], "  ", msg]];
hrfTimed[label_, expr_] := Module[{t, r},
  hrfReport["START: ", label];
  {t, r} = AbsoluteTiming[expr];
  hrfReport["END:   ", label, "  time = ", NumberForm[t, {9, 3}], " s"];
  r
];
hrfTimedTable[label_, n_Integer, body_] := Table[
  hrfReport[label, " ", i, "/", n];
  hrfTimed[ToString[label] <> " " <> ToString[i], body],
  {i, n}
];

(* ---------------------------------------------------------------------- *)
(* Seed topology and collinear kinematics                                  *)
(* ---------------------------------------------------------------------- *)

seedInternalLines = {
  {"0", {1, 3}}, {"0", {1, 5}}, {"0", {2, 3}},
  {"0", {2, 5}}, {"0", {3, 4}}, {"0", {4, 5}}
};

ThreeLoopVertexInternalLines = {{"0", {1, 3}}, {"0", {1, 5}}, {"0", {3, 7}}, {"0", {6, 5}}, {"0", {3, 4}}, {"0", {4, 5}},{"0", {2, 7}},{"0", {6, 7}}, {"0", {2, 6}}};


seedExternalLines = {
  {p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}, {p5, 5}
};

UFSeed5pt = SymanzikUF[seedInternalLines, seedExternalLines];
FSeed5pt = toCyclicMandelstams[UFSeed5pt["F"]];
USeed5pt = UFSeed5pt["U"];
VarsSeed5pt = UFSeed5pt["Variables"];

(* Spacelike collinear substitution used in the notes. *)
collPar1 = {
  s12 -> s z,
  s23 -> -4 \[Delta]^2,
  s34 -> -s x (-1 + z),
  s45 -> s,
  s15 -> s x + c \[Delta]
};

KinVars = {s, x, z};
KinAssump = x < 0 && x > -1 && z > 1 && s > 0;
(* s is the overall Mandelstam scale after collPar1; x and z are dimensionless
   collinear ratios.  Used by extended channel-direction search if enabled. *)
CollinearDimensionfulKinVars = {s};
hrfCollinearFindObstructionOptions = Join[
  hrfKinematicLimitObstructionOptions["Collinear5pt"],
  {
    (* Match working binomial Ex03 (share1): extended channel harvest off; polynomial
       mode is via $HRFUsePolynomialCancellationFactors only. *)
    "UseExtendedFactors" -> False,
    "DimensionfulKinVars" -> CollinearDimensionfulKinVars
  }
];

FSeed5ptCollinear = Expand[FSeed5pt /. collPar1];
F0Seed5pt = Coefficient[FSeed5ptCollinear, \[Delta], 0] // Expand;

Seed5ptGraphDrawing = drawGraphFromPySecDecInput[seedInternalLines, seedExternalLines];

Seed5ptScan = If[TrueQ[$HRFEx03RunFullTopologyScanQ],
  findObstructions[
    F0Seed5pt, VarsSeed5pt, KinAssump, KinVars, Automatic,
    Sequence @@ hrfCollinearFindObstructionOptions
  ],
  Missing["Deferred", "Seed obstruction deferred. Run hrfEx03RunSeedObstruction[] from HRF_Example03SeedStudy.wl."]
];

If[TrueQ[$HRFEx03RunFullTopologyScanQ],

ClearAll[
  incidentHalfEdges, pairings4, splitFourPointVertex,
  splitOneFourPointVertexGraphs, vertexValences, fourValentVertices,
  graphKeyWithExternalLabels, deleteDuplicateGraphs,
  splitTwoFourPointVertexGraphsDynamic
];

incidentHalfEdges[internalLines_, externalLines_, v_] := Module[{inc = {}, i},
  For[i = 1, i <= Length[internalLines], i++,
    If[MemberQ[internalLines[[i, 2]], v], AppendTo[inc, {"Internal", i}]]
  ];
  For[i = 1, i <= Length[externalLines], i++,
    If[externalLines[[i, 2]] === v, AppendTo[inc, {"External", i}]]
  ];
  inc
];

pairings4[list_] := {
  {list[[{1, 2}]], list[[{3, 4}]]},
  {list[[{1, 3}]], list[[{2, 4}]]},
  {list[[{1, 4}]], list[[{2, 3}]]}
};

splitFourPointVertex[internalLines_, externalLines_, v_, sideB_] := Module[
  {vertices, newV, newInternal, newExternal, h, i, edge, ends},
  vertices = DeleteDuplicates[Join[Flatten[internalLines[[All, 2]]], externalLines[[All, 2]]]];
  newV = Max[vertices] + 1;
  newInternal = internalLines;
  newExternal = externalLines;

  For[i = 1, i <= Length[sideB], i++,
    h = sideB[[i]];
    If[h[[1]] === "Internal",
      edge = newInternal[[h[[2]]]];
      ends = edge[[2]];
      newInternal[[h[[2]]]] = {edge[[1]], ends /. v -> newV};
    ];
    If[h[[1]] === "External",
      newExternal[[h[[2]]]] = {newExternal[[h[[2]], 1]], newV};
    ];
  ];

  newInternal = Append[newInternal, {"0", {v, newV}}];
  <|
    "InternalLines" -> newInternal,
    "ExternalLines" -> newExternal,
    "SplitVertex" -> v,
    "NewVertex" -> newV,
    "MovedHalfEdges" -> sideB
  |>
];

splitOneFourPointVertexGraphs[internalLines_, externalLines_, verticesToSplit_] := Module[
  {graphs = {}, ii, v, inc, pairings, p, sideB},
  For[ii = 1, ii <= Length[verticesToSplit], ii++,
    v = verticesToSplit[[ii]];
    inc = incidentHalfEdges[internalLines, externalLines, v];
    If[Length[inc] == 4,
      pairings = pairings4[inc];
      For[p = 1, p <= Length[pairings], p++,
        sideB = pairings[[p, 2]];
        AppendTo[graphs, splitFourPointVertex[internalLines, externalLines, v, sideB]];
      ];
    ];
  ];
  graphs
];

vertexValences[internalLines_, externalLines_] := Module[{verts, assoc, e, v},
  verts = DeleteDuplicates[Join[Flatten[internalLines[[All, 2]]], externalLines[[All, 2]]]];
  assoc = AssociationThread[verts -> ConstantArray[0, Length[verts]]];
  Do[Do[assoc[v] = assoc[v] + 1, {v, e[[2]]}], {e, internalLines}];
  Do[assoc[e[[2]]] = assoc[e[[2]]] + 1, {e, externalLines}];
  assoc
];

fourValentVertices[internalLines_, externalLines_] :=
  Keys @ Select[vertexValences[internalLines, externalLines], # == 4 &];

graphKeyWithExternalLabels[internalLines_, externalLines_] := Module[
  {internalEdges, externalEdges},
  internalEdges = Sort[Sort /@ internalLines[[All, 2]]];
  externalEdges = Sort[Table[{ToString[externalLines[[i, 1]]], externalLines[[i, 2]]}, {i, Length[externalLines]}]];
  {internalEdges, externalEdges}
];

deleteDuplicateGraphs[graphs_] := DeleteDuplicatesBy[graphs, graphKeyWithExternalLabels[#InternalLines, #ExternalLines] &];

splitTwoFourPointVertexGraphsDynamic[internalLines_, externalLines_] := Module[
  {graphs = {}, firstSplits, i, g, remainingFourVerts, j, secondSplits},
  firstSplits = splitOneFourPointVertexGraphs[
    internalLines, externalLines, fourValentVertices[internalLines, externalLines]
  ];
  Do[
    g = firstSplits[[i]];
    remainingFourVerts = fourValentVertices[g["InternalLines"], g["ExternalLines"]];
    Do[
      secondSplits = splitOneFourPointVertexGraphs[
        g["InternalLines"], g["ExternalLines"], {remainingFourVerts[[j]]}
      ];
      graphs = Join[graphs, secondSplits],
      {j, Length[remainingFourVerts]}
    ],
    {i, Length[firstSplits]}
  ];
  (* The notebook kept every other member after the ordered double split,
     which removes the reverse ordering of the same two vertex splits. *)
  graphs[[1 ;; ;; 2]]
];

(* ---------------------------------------------------------------------- *)
(* Generate 7- and 8-propagator descendants                                *)
(* ---------------------------------------------------------------------- *)

fourPointVertices = {3, 5};

Graphs2Loop7Prop = splitOneFourPointVertexGraphs[
  seedInternalLines, seedExternalLines, fourPointVertices
];

Graphs2Loop8Prop = splitTwoFourPointVertexGraphsDynamic[
  seedInternalLines, seedExternalLines
];

GraphCountSummary = <|
  "SeedPropagators" -> Length[seedInternalLines],
  "SevenPropagatorGraphs" -> Length[Graphs2Loop7Prop],
  "EightPropagatorGraphs" -> Length[Graphs2Loop8Prop]
|>;

(* Expected notebook counts: 6 one-split graphs and 9 two-split graphs. *)


(* ---------------------------------------------------------------------- *)
(* Compact topology labels for opened seed vertices                         *)
(* ---------------------------------------------------------------------- *)

ClearAll[
  internalNeighbours, externalAttachmentVertex, splitChannelFromPair,
  openingChannelForExternalLeg, topologySubscriptForGraph,
  topologyNameForGraph, topologyTeXNameForGraph
];

internalNeighbours[internalLines_, v_] := DeleteDuplicates @ Cases[
  internalLines,
  {_, ends_} /; MemberQ[ends, v] :> First[DeleteCases[ends, v]]
];

externalAttachmentVertex[externalLines_, p_] := Module[{hits},
  hits = Cases[externalLines, {p, v_} :> v];
  If[hits === {}, Missing["ExternalLegNotFound", p], First[hits]]
];

splitChannelFromPair[pair_] := Switch[Sort[pair],
  {1, 2}, "s",
  {1, 4}, "t",
  {2, 4}, "u",
  _, Missing["UnknownOpeningPair", pair]
];

(*
   The two four-point seed vertices are the ones carrying p3 and p5.  If such
   a vertex has not been opened, the corresponding label is \[Bullet].  If it
   has been opened, we identify the split-vertex half not carrying the external
   leg and classify the two seed neighbours attached to that half:
      {1,2} -> s,  {1,4} -> t,  {2,4} -> u.
*)
openingChannelForExternalLeg[internalLines_, externalLines_, p_] := Module[
  {extV, splitPartnerCandidates, splitPartner, pair},
  extV = externalAttachmentVertex[externalLines, p];
  If[Head[extV] === Missing, Return[extV]];
  splitPartnerCandidates = Select[internalNeighbours[internalLines, extV], ! MemberQ[{1, 2, 4}, #] &];
  If[splitPartnerCandidates === {}, Return["\[Bullet]"]];
  splitPartner = First[splitPartnerCandidates];
  pair = Sort @ Intersection[internalNeighbours[internalLines, splitPartner], {1, 2, 4}];
  If[Length[pair] == 2, splitChannelFromPair[pair], Missing["CannotClassifyOpening", <|"ExternalLeg" -> p, "Pair" -> pair|>]]
];

topologySubscriptForGraph[internalLines_, externalLines_] := {
  openingChannelForExternalLeg[internalLines, externalLines, p3],
  openingChannelForExternalLeg[internalLines, externalLines, p5]
};

topologyNameForGraph[internalLines_, externalLines_] := Module[{sub = topologySubscriptForGraph[internalLines, externalLines]},
  "G_" <> StringJoin[ToString /@ sub]
];

topologyTeXNameForGraph[internalLines_, externalLines_] := Module[{sub = topologySubscriptForGraph[internalLines, externalLines], tex},
  tex = sub /. "\[Bullet]" -> "\\bullet";
  "\\mathcal{G}_{" <> StringJoin[ToString /@ tex] <> "}"
];

ClearAll[buildUFData];
buildUFData[graphs_] := Table[
  Module[{res},
    res = SymanzikUF[graphs[[i, "InternalLines"]], graphs[[i, "ExternalLines"]]];
    <|
      "GraphIndex" -> i,
      "InternalLines" -> graphs[[i, "InternalLines"]],
      "ExternalLines" -> graphs[[i, "ExternalLines"]],
      "TopologySubscript" -> topologySubscriptForGraph[graphs[[i, "InternalLines"]], graphs[[i, "ExternalLines"]]],
      "TopologyName" -> topologyNameForGraph[graphs[[i, "InternalLines"]], graphs[[i, "ExternalLines"]]],
      "TopologyTeX" -> topologyTeXNameForGraph[graphs[[i, "InternalLines"]], graphs[[i, "ExternalLines"]]],
      "U" -> res["U"],
      "F" -> toCyclicMandelstams[res["F"]],
      "Variables" -> res["Variables"]
    |>
  ],
  {i, Length[graphs]}
];

UFData2Loop7Prop = hrfTimed["build U,F for 7-propagator graphs", buildUFData[Graphs2Loop7Prop]];
UFData2Loop8Prop = hrfTimed["build U,F for 8-propagator graphs", buildUFData[Graphs2Loop8Prop]];


TopologySummary2Loop7Prop = UFData2Loop7Prop[[All, {"GraphIndex", "TopologyName", "TopologyTeX", "TopologySubscript"}]];
TopologySummary2Loop8Prop = UFData2Loop8Prop[[All, {"GraphIndex", "TopologyName", "TopologyTeX", "TopologySubscript"}]];


(* Graph drawings: these display the topology and the x_i labels used in the
   scaling vectors.  The drawings are intentionally stored as objects so that
   notebooks can display or export selected interesting diagrams. *)
GraphDrawings2Loop7Prop = Table[
  <|
    "GraphIndex" -> UFData2Loop7Prop[[i, "GraphIndex"]],
    "TopologyName" -> UFData2Loop7Prop[[i, "TopologyName"]],
    "TopologyTeX" -> UFData2Loop7Prop[[i, "TopologyTeX"]],
    "Graph" -> drawGraphFromPySecDecInput[UFData2Loop7Prop[[i, "InternalLines"]], UFData2Loop7Prop[[i, "ExternalLines"]]]
  |>,
  {i, Length[UFData2Loop7Prop]}
];
GraphDrawings2Loop8Prop = Table[
  <|
    "GraphIndex" -> UFData2Loop8Prop[[i, "GraphIndex"]],
    "TopologyName" -> UFData2Loop8Prop[[i, "TopologyName"]],
    "TopologyTeX" -> UFData2Loop8Prop[[i, "TopologyTeX"]],
    "Graph" -> drawGraphFromPySecDecInput[UFData2Loop8Prop[[i, "InternalLines"]], UFData2Loop8Prop[[i, "ExternalLines"]]]
  |>,
  {i, Length[UFData2Loop8Prop]}
];

(* ---------------------------------------------------------------------- *)
(* Collinear leading data and interior obstruction scans                    *)
(* ---------------------------------------------------------------------- *)

ClearAll[leadingDeltaPolynomial, addCollinearLeadingData];

leadingDeltaPolynomial[poly_] := Module[{expanded, powers, minPower},
  expanded = Expand[poly];
  powers = Exponent[#, \[Delta]] & /@ If[Head[expanded] === Plus, List @@ expanded, {expanded}];
  minPower = Min[powers];
  Coefficient[expanded, \[Delta], minPower] // Expand
];

addCollinearLeadingData[UFData_, kinAssumptions_, kinVars_] := Table[
  Module[{Fcol, Flead, obs},
    hrfReport["  interior obstruction scan graph ", i, "/", Length[UFData]];
    Fcol = Expand[UFData[[i, "F"]] /. collPar1];
    Flead = leadingDeltaPolynomial[Fcol];
    obs = hrfTimed["findObstructions interior graph " <> ToString[i], findObstructions[
      Flead, UFData[[i, "Variables"]], kinAssumptions, kinVars, Automatic,
      Sequence @@ hrfCollinearFindObstructionOptions
    ]];
    Join[UFData[[i]], <|
      "FCollinear" -> Fcol,
      "Flead" -> Flead,
      "InteriorObstructionScan" -> obs
    |>]
  ],
  {i, Length[UFData]}
];

UFCollinear2Loop7Prop = hrfTimed["collinear leading/interior obstruction scans for 7-propagator graphs",
  addCollinearLeadingData[UFData2Loop7Prop, KinAssump, KinVars]
];
UFCollinear2Loop8Prop = hrfTimed["collinear leading/interior obstruction scans for 8-propagator graphs",
  addCollinearLeadingData[UFData2Loop8Prop, KinAssump, KinVars]
];

InteriorScanSummary2Loop7Prop = UFCollinear2Loop7Prop[[All, {
  "GraphIndex", "InteriorObstructionScan"
}]];

InteriorScanSummary2Loop8Prop = UFCollinear2Loop8Prop[[All, {
  "GraphIndex", "InteriorObstructionScan"
}]];

(* ---------------------------------------------------------------------- *)
(* Boundary obstruction scans                                               *)
(* ---------------------------------------------------------------------- *)

ClearAll[boundarySubsetsGeneric, restrictPolynomialToBoundaryGeneric,
  findObstructionsOnBoundaries, findObstructionsOnBoundaryStrata,
  extractInterestingBoundaryCases,
  boundaryCaseSummary, scalingForBoundaryCase];

boundarySubsetsGeneric[vars_, maxCodim_] := Flatten[Table[Subsets[vars, {k}], {k, 1, maxCodim}], 1];

restrictPolynomialToBoundaryGeneric[F_, vars_, zeroVars_] := Module[{remainingVars, Fr},
  Fr = Expand[F /. Thread[zeroVars -> 0]];
  remainingVars = Complement[vars, zeroVars];
  <|"ZeroVars" -> zeroVars, "RemainingVars" -> remainingVars, "FRestricted" -> Fr|>
];

findObstructionsOnBoundaryStrata[F_, vars_, kinAssumptions_, kinVars_, strata_List] := Module[
  {results = {}, i, res, obs, stratum},
  Do[
    stratum = strata[[i]];
    hrfReport["    boundary stratum ", i, "/", Length[strata], " zeroVars=", stratum];
    res = restrictPolynomialToBoundaryGeneric[F, vars, stratum];
    obs = If[res["FRestricted"] === 0 || res["RemainingVars"] === {},
      <||>,
      hrfTimed["findObstructions boundary stratum " <> ToString[i], findObstructions[
        res["FRestricted"], res["RemainingVars"], kinAssumptions, kinVars, Automatic,
        Sequence @@ hrfCollinearFindObstructionOptions
      ]]
    ];
    AppendTo[results, Join[res, <|"ObstructionScan" -> obs|>]],
    {i, Length[strata]}
  ];
  results
];

findObstructionsOnBoundaries[F_, vars_, kinAssumptions_, kinVars_, maxCodim_ : 2] :=
  findObstructionsOnBoundaryStrata[F, vars, kinAssumptions, kinVars, boundarySubsetsGeneric[vars, maxCodim]];

BoundaryScan2Loop7Prop = hrfTimed["boundary obstruction scans for 7-propagator graphs (x6=0 only)", Table[
  hrfReport["  boundary scan 7-prop graph ", i, "/", Length[UFCollinear2Loop7Prop]];
  <|
    "GraphIndex" -> i,
    "InternalLines" -> UFCollinear2Loop7Prop[[i, "InternalLines"]],
    "ExternalLines" -> UFCollinear2Loop7Prop[[i, "ExternalLines"]],
    "TopologyName" -> UFCollinear2Loop7Prop[[i, "TopologyName"]],
    "TopologyTeX" -> UFCollinear2Loop7Prop[[i, "TopologyTeX"]],
    "TopologySubscript" -> UFCollinear2Loop7Prop[[i, "TopologySubscript"]],
    "BoundaryScans" -> findObstructionsOnBoundaryStrata[
      UFCollinear2Loop7Prop[[i, "Flead"]],
      UFCollinear2Loop7Prop[[i, "Variables"]], KinAssump, KinVars,
      Table[{v}, {v, Intersection[$HRFEx03SevenPropBoundaryZeroVars,
        UFCollinear2Loop7Prop[[i, "Variables"]]]}]
    ]
  |>,
  {i, Length[UFCollinear2Loop7Prop]}
]];

BoundaryScan2Loop8Prop = If[TrueQ[$HRFEx03RunEightPropBoundaryScanQ],
  hrfTimed["boundary obstruction scans for 8-propagator graphs", Table[
    hrfReport["  boundary scan 8-prop graph ", i, "/", Length[UFCollinear2Loop8Prop]];
    <|
      "GraphIndex" -> i,
      "InternalLines" -> UFCollinear2Loop8Prop[[i, "InternalLines"]],
      "ExternalLines" -> UFCollinear2Loop8Prop[[i, "ExternalLines"]],
      "TopologyName" -> UFCollinear2Loop8Prop[[i, "TopologyName"]],
      "TopologyTeX" -> UFCollinear2Loop8Prop[[i, "TopologyTeX"]],
      "TopologySubscript" -> UFCollinear2Loop8Prop[[i, "TopologySubscript"]],
      "BoundaryScans" -> findObstructionsOnBoundaries[
        UFCollinear2Loop8Prop[[i, "Flead"]],
        UFCollinear2Loop8Prop[[i, "Variables"]], KinAssump, KinVars, 2
      ]
    |>,
    {i, Length[UFCollinear2Loop8Prop]}
  ]],
  If[! TrueQ[$HRFQuietReports],
    Print["[Example 03] skipping 8-propagator boundary scans ($HRFEx03RunEightPropBoundaryScanQ=False)."]
  ];
  Table[
    <|
      "GraphIndex" -> i,
      "InternalLines" -> UFCollinear2Loop8Prop[[i, "InternalLines"]],
      "ExternalLines" -> UFCollinear2Loop8Prop[[i, "ExternalLines"]],
      "TopologyName" -> UFCollinear2Loop8Prop[[i, "TopologyName"]],
      "TopologyTeX" -> UFCollinear2Loop8Prop[[i, "TopologyTeX"]],
      "TopologySubscript" -> UFCollinear2Loop8Prop[[i, "TopologySubscript"]],
      "BoundaryScans" -> {}
    |>,
    {i, Length[UFCollinear2Loop8Prop]}
  ]
];

extractInterestingBoundaryCases[boundaryScan_] := Flatten[Table[
  Module[{graphIndex, scans, selected},
    graphIndex = boundaryScan[[i, "GraphIndex"]];
    scans = boundaryScan[[i, "BoundaryScans"]];
    selected = Select[scans,
      Module[{osc = Lookup[#, "ObstructionScan", <||>]},
        AssociationQ[osc] &&
        KeyExistsQ[osc, "CancellationFactors"] &&
        Length[Lookup[osc, "CancellationFactors", {}]] >= 2 &&
        hrfFPObstructionRegionPresentQ[osc]
      ] &
    ];
    Table[Join[<|
      "GraphIndex" -> graphIndex,
      "TopologyName" -> boundaryScan[[i, "TopologyName"]],
      "TopologyTeX" -> boundaryScan[[i, "TopologyTeX"]],
      "TopologySubscript" -> boundaryScan[[i, "TopologySubscript"]]
    |>, selected[[j]]], {j, Length[selected]}]
  ],
  {i, Length[boundaryScan]}
], 1];

InterestingBoundary2Loop7Prop = extractInterestingBoundaryCases[BoundaryScan2Loop7Prop];
InterestingBoundary2Loop8Prop = extractInterestingBoundaryCases[BoundaryScan2Loop8Prop];

boundaryCaseSummary[cases_] := cases[[All, {
  "GraphIndex", "ZeroVars", "RemainingVars", "ObstructionScan"
}]];

InterestingBoundarySummary2Loop7Prop = If[
  Length[InterestingBoundary2Loop7Prop] == 0, {},
  boundaryCaseSummary[InterestingBoundary2Loop7Prop]
];

InterestingBoundarySummary2Loop8Prop = If[
  Length[InterestingBoundary2Loop8Prop] == 0, {},
  boundaryCaseSummary[InterestingBoundary2Loop8Prop]
];

(* ---------------------------------------------------------------------- *)
(* Coverage-based Lee--Pomeransky scaling data                              *)
(* ---------------------------------------------------------------------- *)

ClearAll[scalingForBoundaryCase, scalingForInteriorCase];

(*
   The historical MinimalLPScaling entry is retained only for comparison.  The
   replacement CoverageLPScalingData rejects vectors for which an active
   Lee--Pomeransky parameter is absent from the leading support.  In the
   collinear five-point examples there is no separate F_obs constraint, so the
   coverage test is applied to F_SL and U.  The diagnostics report the leading
   weights and leading monomials of U and F_SL.
*)

scalingForBoundaryCase[case_, UFCollinearData_] := Module[
  {graphIndex, scan, obsData, obstruction, fsl, fslSource, U, vars, newScaling},
  graphIndex = case["GraphIndex"];
  scan = case["ObstructionScan"];
  obsData = scan["ObstructionData"];
  obstruction = obsData["Obstruction"];
  fsl = hrfFPEffectiveSuperleadingSector[scan];
  fslSource = hrfFPEffectiveSuperleadingSource[scan];
  U = UFCollinearData[[graphIndex, "U"]] /. Thread[case["ZeroVars"] -> 0] // Expand;
  vars = case["RemainingVars"];
  newScaling = If[MatchQ[fsl, _Missing] || TrueQ[Expand[fsl] === 0],
    Missing["NoNonzeroSuperleadingSector"],
    (* F_Obs is the obstruction polynomial: W_SL must be strictly more singular
       than the first surviving weight of U + F_Obs.  Uniform {-1,...,-1} is
       only a nullspace seed for the fast search; the admissible five-point
       vectors are heterogeneous, e.g. {-2,-1,-2,-2,-2,-1,-2}. *)
    findCoverageLPScaling[fsl, U, vars, 5, obstruction]
  ];
  <|
    "GraphIndex" -> graphIndex,
    "TopologyName" -> Lookup[case, "TopologyName", UFCollinearData[[graphIndex, "TopologyName"]]],
    "TopologyTeX" -> Lookup[case, "TopologyTeX", UFCollinearData[[graphIndex, "TopologyTeX"]]],
    "TopologySubscript" -> Lookup[case, "TopologySubscript", UFCollinearData[[graphIndex, "TopologySubscript"]]],
    "ZeroVars" -> case["ZeroVars"],
    "RemainingVars" -> vars,
    "URestricted" -> U,
    "ObstructionScan" -> scan,
    "Generators" -> Lookup[scan, "Generators", {}],
    "FSL" -> fsl,
    "SuperleadingSectorSource" -> fslSource,
    "Obstruction" -> obstruction,
    "CoverageLPScalingData" -> newScaling
  |>
];

scalingForInteriorCase[data_] := Module[
  {scan, obsData, obstruction, fsl, fslSource, U, vars, newScaling},
  scan = data["InteriorObstructionScan"];
  If[! AssociationQ[scan] || ! AssociationQ[Lookup[scan, "ObstructionData", <||>]],
    Return[<|
      "GraphIndex" -> data["GraphIndex"],
      "TopologyName" -> data["TopologyName"],
      "TopologyTeX" -> data["TopologyTeX"],
      "TopologySubscript" -> data["TopologySubscript"],
      "ObstructionScan" -> scan,
      "CoverageLPScalingData" -> Missing["NoInteriorObstruction"]|>]
  ];
  obsData = scan["ObstructionData"];
  obstruction = obsData["Obstruction"];
  fsl = hrfFPEffectiveSuperleadingSector[scan];
  fslSource = hrfFPEffectiveSuperleadingSource[scan];
  U = data["U"];
  vars = data["Variables"];
  newScaling = If[MatchQ[fsl, _Missing] || TrueQ[Expand[fsl] === 0],
    Missing["NoNonzeroSuperleadingSector"],
    (* F_Obs is the obstruction polynomial: W_SL must be strictly more singular
       than the first surviving weight of U + F_Obs.  Uniform {-1,...,-1} is
       only a nullspace seed for the fast search; the admissible five-point
       vectors are heterogeneous, e.g. {-2,-1,-2,-2,-2,-1,-2}. *)
    findCoverageLPScaling[fsl, U, vars, 5, obstruction]
  ];
  <|
    "GraphIndex" -> data["GraphIndex"],
    "TopologyName" -> data["TopologyName"],
    "TopologyTeX" -> data["TopologyTeX"],
    "TopologySubscript" -> data["TopologySubscript"],
    "ZeroVars" -> {},
    "RemainingVars" -> vars,
    "U" -> U,
    "ObstructionScan" -> scan,
    "Generators" -> Lookup[scan, "Generators", {}],
    "FSL" -> fsl,
    "SuperleadingSectorSource" -> fslSource,
    "Obstruction" -> obstruction,
    "CoverageLPScalingData" -> newScaling
  |>
];

InteriorScalingData2Loop7Prop = Table[
  Print["scaling interior 7-prop graph ", i, "/", Length[UFCollinear2Loop7Prop]];
  scalingForInteriorCase[UFCollinear2Loop7Prop[[i]]], {i, Length[UFCollinear2Loop7Prop]}
];
InteriorScalingData2Loop8Prop = Table[
  Print["scaling interior 8-prop graph ", i, "/", Length[UFCollinear2Loop8Prop]];
  scalingForInteriorCase[UFCollinear2Loop8Prop[[i]]], {i, Length[UFCollinear2Loop8Prop]}
];
BoundaryScalingData2Loop7Prop = Table[
  Print["scaling boundary 7-prop case ", i, "/", Length[InterestingBoundary2Loop7Prop]];
  scalingForBoundaryCase[InterestingBoundary2Loop7Prop[[i]], UFCollinear2Loop7Prop], {i, Length[InterestingBoundary2Loop7Prop]}
];
BoundaryScalingData2Loop8Prop = Table[
  Print["scaling boundary 8-prop case ", i, "/", Length[InterestingBoundary2Loop8Prop]];
  scalingForBoundaryCase[InterestingBoundary2Loop8Prop[[i]], UFCollinear2Loop8Prop], {i, Length[InterestingBoundary2Loop8Prop]}
];

(* Backwards-compatible names used by earlier versions of this example. *)
ScalingData2Loop7Prop = BoundaryScalingData2Loop7Prop;
ScalingData2Loop8Prop = BoundaryScalingData2Loop8Prop;

ClearAll[coverageScalingMissingQ, coverageScalingDebugRow, coverageScalingDebugTable];
coverageScalingMissingQ[row_] := Module[{data = Lookup[row, "CoverageLPScalingData", Missing["NoData"]]},
  ! AssociationQ[data] || MatchQ[Lookup[data, "Scaling", Missing["NoScaling"]], _Missing]
];

coverageScalingDebugRow[row_] := Module[{data, acc, first, nm, nm1},
  data = hrfFPAssocOrEmpty[Lookup[row, "CoverageLPScalingData", <||>]];
  acc = If[AssociationQ[data], Lookup[data, "AcceptedCandidateDiagnostics", {}], {}];
  first = If[acc === {}, <||>, First[acc]];
  nm = If[AssociationQ[data], Lookup[data, "NearMissDiagnostics", {}], {}];
  nm1 = If[nm === {}, <||>, First[nm]];
  <|
    "GraphIndex" -> Lookup[row, "GraphIndex", Missing["NoGraphIndex"]],
    "ZeroVars" -> Lookup[row, "ZeroVars", Missing["NoZeroVars"]],
    "RemainingVars" -> Lookup[row, "RemainingVars", Missing["NoRemainingVars"]],
    "CandidateCount" -> If[AssociationQ[data], Lookup[data, "CandidateCount", Missing["NoCandidateCount"]], Missing["NoData"]],
    "AcceptedCount" -> If[AssociationQ[data], Lookup[data, "AcceptedCount", Missing["NoAcceptedCount"]], Missing["NoData"]],
    "SelectedScaling" -> If[AssociationQ[data], Lookup[data, "Scaling", Missing["NoScaling"]], Missing["NoData"]],
    "FirstAcceptedGap" -> Lookup[first, "HierarchyGapPostLPminusFSL", Missing["NoAcceptedCandidate"]],
    "FirstAcceptedUnitGapQ" -> Lookup[first, "UnitGapQ", Missing["NoAcceptedCandidate"]],
    "FirstNearMissScaling" -> Lookup[nm1, "ScalingVector", Missing["NoNearMiss"]],
    "FirstNearMissWSL" -> Lookup[nm1, "FSLWeight", Missing["NoNearMiss"]],
    "FirstNearMissWHR" -> Lookup[nm1, "PostCancellationLeadingWeight", Missing["NoNearMiss"]],
    "FirstNearMissGap" -> Lookup[nm1, "HierarchyGapPostLPminusFSL", Missing["NoNearMiss"]],
    "FirstNearMissFailedConditions" -> Lookup[nm1, "FailedConditions", {}],
    "FirstAcceptedFSLMissingVariables" -> Lookup[first, "FSLMissingVariables", Missing["NoAcceptedCandidate"]],
    "FirstAcceptedMissingLeadingVariables" -> Lookup[first, "VariablesMissingFromLeadingSupport", Missing["NoAcceptedCandidate"]],
    "NearMisses" -> nm
  |>
];
coverageScalingDebugTable[rows_] := coverageScalingDebugRow /@ rows;

CoverageScalingFailures2Loop7Prop = Select[
  Join[InteriorScalingData2Loop7Prop, BoundaryScalingData2Loop7Prop], coverageScalingMissingQ
];
CoverageScalingFailures2Loop8Prop = Select[
  Join[InteriorScalingData2Loop8Prop, BoundaryScalingData2Loop8Prop], coverageScalingMissingQ
];

CoverageScalingDebugSummary2Loop7Prop = coverageScalingDebugTable[
  Join[InteriorScalingData2Loop7Prop, BoundaryScalingData2Loop7Prop]
];
CoverageScalingDebugSummary2Loop8Prop = coverageScalingDebugTable[
  Join[InteriorScalingData2Loop8Prop, BoundaryScalingData2Loop8Prop]
];


(* ---------------------------------------------------------------------- *)
(* Paper-style topology/region/scaling summary tables                       *)
(* ---------------------------------------------------------------------- *)

ClearAll[
  selectedCoverageData, acceptedCoverageQ, selectedAcceptedDiagnostic,
  regionScalingSummaryRow, regionScalingSummaryTable,
  topologyRegionScalingOverview
];

selectedCoverageData[row_Association] := Lookup[row, "CoverageLPScalingData", <||>];

(* Backward-compatible alias: accepted coverage scaling found. *)
acceptedCoverageQ[row_Association] := hrfFPCoverageFoundQ[selectedCoverageData[row]];

selectedAcceptedDiagnostic[row_Association] := hrfFPSelectedDiagnostic[selectedCoverageData[row]];

regionScalingSummaryRow[row_Association, regionType_] :=
  hrfFPRegionScalingSummaryRow[row, regionType, Lookup[row, "ObstructionScan", Automatic]];

regionScalingSummaryTable[interiorRows_, boundaryRows_] :=
  hrfFPRegionScalingSummaryTable[interiorRows, boundaryRows];

TopologyRegionScalingSummary2Loop7Prop = regionScalingSummaryTable[
  InteriorScalingData2Loop7Prop, BoundaryScalingData2Loop7Prop
];
TopologyRegionScalingSummary2Loop8Prop = regionScalingSummaryTable[
  InteriorScalingData2Loop8Prop, BoundaryScalingData2Loop8Prop
];

TopologyHiddenRegionCandidateRows2Loop7Prop = Select[TopologyRegionScalingSummary2Loop7Prop, TrueQ[#HiddenRegionQ] &];
TopologyHiddenRegionCandidateRows2Loop8Prop = Select[TopologyRegionScalingSummary2Loop8Prop, TrueQ[#HiddenRegionQ] &];
TopologyHiddenRegionRows2Loop7Prop = TopologyHiddenRegionCandidateRows2Loop7Prop;
TopologyHiddenRegionRows2Loop8Prop = TopologyHiddenRegionCandidateRows2Loop8Prop;
TopologyHiddenRegionWithScalingRows2Loop7Prop = Select[
  TopologyRegionScalingSummary2Loop7Prop,
  TrueQ[Lookup[#, "HiddenRegionQ", False]] && TrueQ[Lookup[#, "AcceptedScalingQ", False]] &
];
TopologyHiddenRegionWithScalingRows2Loop8Prop = Select[
  TopologyRegionScalingSummary2Loop8Prop,
  TrueQ[Lookup[#, "HiddenRegionQ", False]] && TrueQ[Lookup[#, "AcceptedScalingQ", False]] &
];

(* Compact tables focused on scaling vectors and coverage supports.
   These are built directly from the scaling-data rows, not from the wider
   region summaries, so Scaling / VarsAtWSL / VarsAtWHR are always present. *)
TopologyScalingCoverageSummary2Loop7Prop = hrfFPScalingCoverageTableFromScalingData[
  InteriorScalingData2Loop7Prop, BoundaryScalingData2Loop7Prop
];
TopologyScalingCoverageSummary2Loop8Prop = hrfFPScalingCoverageTableFromScalingData[
  InteriorScalingData2Loop8Prop, BoundaryScalingData2Loop8Prop
];
TopologyAcceptedScalingRows2Loop7Prop = Select[
  TopologyScalingCoverageSummary2Loop7Prop, TrueQ[Lookup[#, "AcceptedScalingQ", False]] &
];
TopologyAcceptedScalingRows2Loop8Prop = Select[
  TopologyScalingCoverageSummary2Loop8Prop, TrueQ[Lookup[#, "AcceptedScalingQ", False]] &
];
TopologyHiddenRegionScalingSummary2Loop7Prop = With[{rows = Select[
  TopologyScalingCoverageSummary2Loop7Prop,
  TrueQ[Lookup[#, "HiddenRegionQ", False]] && TrueQ[Lookup[#, "AcceptedScalingQ", False]] &
]},
  If[rows === {}, TopologyAcceptedScalingRows2Loop7Prop, rows]
];
TopologyHiddenRegionScalingSummary2Loop8Prop = With[{rows = Select[
  TopologyScalingCoverageSummary2Loop8Prop,
  TrueQ[Lookup[#, "HiddenRegionQ", False]] && TrueQ[Lookup[#, "AcceptedScalingQ", False]] &
]},
  If[rows === {}, TopologyAcceptedScalingRows2Loop8Prop, rows]
];

If[$HRFScalingReport,
  Print["[Example 03] accepted scaling rows: 7-prop=", Length[TopologyAcceptedScalingRows2Loop7Prop],
    "  8-prop=", Length[TopologyAcceptedScalingRows2Loop8Prop]]
];

TopologyObstructionScanSummary2Loop7Prop = hrfFPScanSummaryTable[UFCollinear2Loop7Prop];
TopologyObstructionScanSummary2Loop8Prop = hrfFPScanSummaryTable[UFCollinear2Loop8Prop];

(* Diagram + scaling study panels for notebook 06 (x_i labels on graphs). *)
TopologyRegionScalingStudyPanels2Loop7Prop = hrfFPRegionScalingStudyPanels[
  TopologyRegionScalingSummary2Loop7Prop,
  GraphDrawings2Loop7Prop,
  InteriorScalingData2Loop7Prop,
  BoundaryScalingData2Loop7Prop
];
TopologyRegionScalingStudyPanels2Loop8Prop = hrfFPRegionScalingStudyPanels[
  TopologyRegionScalingSummary2Loop8Prop,
  GraphDrawings2Loop8Prop,
  InteriorScalingData2Loop8Prop,
  BoundaryScalingData2Loop8Prop
];
TopologyHiddenRegionScalingStudyPanels2Loop7Prop = hrfFPRegionScalingStudyPanels[
  TopologyHiddenRegionRows2Loop7Prop,
  GraphDrawings2Loop7Prop,
  InteriorScalingData2Loop7Prop,
  BoundaryScalingData2Loop7Prop
];
TopologyHiddenRegionScalingStudyPanels2Loop8Prop = hrfFPRegionScalingStudyPanels[
  TopologyHiddenRegionRows2Loop8Prop,
  GraphDrawings2Loop8Prop,
  InteriorScalingData2Loop8Prop,
  BoundaryScalingData2Loop8Prop
];
TopologyAcceptedScalingStudyPanels2Loop7Prop = hrfFPRegionScalingStudyPanels[
  TopologyAcceptedScalingRows2Loop7Prop,
  GraphDrawings2Loop7Prop,
  InteriorScalingData2Loop7Prop,
  BoundaryScalingData2Loop7Prop
];
TopologyAcceptedScalingStudyPanels2Loop8Prop = hrfFPRegionScalingStudyPanels[
  TopologyAcceptedScalingRows2Loop8Prop,
  GraphDrawings2Loop8Prop,
  InteriorScalingData2Loop8Prop,
  BoundaryScalingData2Loop8Prop
];

(* ---------------------------------------------------------------------- *)
(* Interior-versus-boundary generator comparison                           *)
(* ---------------------------------------------------------------------- *)

ClearAll[
  obstructionRegionPresentQ, obstructionGeneratorSignature,
  obstructionScanRecord, compareInteriorAndBoundaryGenerators,
  occurrenceClass
];

(*
   The interior stratum is represented by ZeroVars -> {}.  Boundary strata
   have one or more Lee--Pomeransky parameters set to zero.  The comparison
   below is deliberately by generator signature rather than by the full
   obstruction data, because the same cancellation generator can occur both
   in the interior and on a boundary while the complementary polynomial and
   LP scaling data change.
*)

obstructionRegionPresentQ[scan_] := hrfFPObstructionRegionPresentQ[scan];

obstructionGeneratorSignature[generators_] :=
  Sort[ToString[InputForm[Factor[#]]] & /@ Flatten[{generators}]];

obstructionScanRecord[graphIndex_, zeroVars_, remainingVars_, scan_, stratumType_] := <|
  "GraphIndex" -> graphIndex,
  "StratumType" -> stratumType,
  "ZeroVars" -> zeroVars,
  "RemainingVars" -> remainingVars,
  "Generators" -> Lookup[scan, "Generators", {}],
  "GeneratorSignature" -> obstructionGeneratorSignature[Lookup[scan, "Generators", {}]],
  "ObstructionScan" -> scan
|>;

occurrenceClass[hasInterior_, hasBoundary_] := Which[
  TrueQ[hasInterior] && TrueQ[hasBoundary], "InteriorAndBoundary",
  TrueQ[hasInterior], "InteriorOnly",
  TrueQ[hasBoundary], "BoundaryOnly",
  True, "Absent"
];

compareInteriorAndBoundaryGenerators[UFCollinearData_, boundaryScan_] := Module[
  {interiorRows, boundaryRows, rows, grouped},

  interiorRows = DeleteCases[Table[
    With[{scan = UFCollinearData[[i, "InteriorObstructionScan"]]},
      If[obstructionRegionPresentQ[scan],
        obstructionScanRecord[
          UFCollinearData[[i, "GraphIndex"]], {}, UFCollinearData[[i, "Variables"]],
          scan, "Interior"
        ],
        Nothing
      ]
    ],
    {i, Length[UFCollinearData]}
  ], Null];

  boundaryRows = Flatten[Table[
    With[{graphIndex = boundaryScan[[i, "GraphIndex"]], scans = boundaryScan[[i, "BoundaryScans"]]},
      Table[
        With[{scan = scans[[j, "ObstructionScan"]]},
          If[obstructionRegionPresentQ[scan],
            obstructionScanRecord[
              graphIndex, scans[[j, "ZeroVars"]], scans[[j, "RemainingVars"]],
              scan, "Boundary"
            ],
            Nothing
          ]
        ],
        {j, Length[scans]}
      ]
    ],
    {i, Length[boundaryScan]}
  ], 1];

  rows = Join[interiorRows, boundaryRows];
  grouped = GatherBy[rows, {#["GraphIndex"], #["GeneratorSignature"]} &];

  Table[
    Module[{grp = grouped[[i]], interior, boundary},
      interior = Select[grp, #["StratumType"] === "Interior" &];
      boundary = Select[grp, #["StratumType"] === "Boundary" &];
      <|
        "GraphIndex" -> grp[[1, "GraphIndex"]],
        "Generators" -> grp[[1, "Generators"]],
        "GeneratorSignature" -> grp[[1, "GeneratorSignature"]],
        "Occurrence" -> occurrenceClass[Length[interior] > 0, Length[boundary] > 0],
        "InteriorRegions" -> (KeyTake[#, {"ZeroVars", "RemainingVars", "ObstructionScan"}] & /@ interior),
        "BoundaryRegions" -> (KeyTake[#, {"ZeroVars", "RemainingVars", "ObstructionScan"}] & /@ boundary)
      |>
    ],
    {i, Length[grouped]}
  ]
];

InteriorBoundaryComparison2Loop7Prop = compareInteriorAndBoundaryGenerators[
  UFCollinear2Loop7Prop, BoundaryScan2Loop7Prop
];

InteriorBoundaryComparison2Loop8Prop = compareInteriorAndBoundaryGenerators[
  UFCollinear2Loop8Prop, BoundaryScan2Loop8Prop
];

SameGeneratorInteriorBoundary2Loop7Prop = Select[
  InteriorBoundaryComparison2Loop7Prop, #["Occurrence"] === "InteriorAndBoundary" &
];
SameGeneratorInteriorBoundary2Loop8Prop = Select[
  InteriorBoundaryComparison2Loop8Prop, #["Occurrence"] === "InteriorAndBoundary" &
];

InteriorOnlyGenerator2Loop7Prop = Select[
  InteriorBoundaryComparison2Loop7Prop, #["Occurrence"] === "InteriorOnly" &
];
InteriorOnlyGenerator2Loop8Prop = Select[
  InteriorBoundaryComparison2Loop8Prop, #["Occurrence"] === "InteriorOnly" &
];

BoundaryOnlyGenerator2Loop7Prop = Select[
  InteriorBoundaryComparison2Loop7Prop, #["Occurrence"] === "BoundaryOnly" &
];
BoundaryOnlyGenerator2Loop8Prop = Select[
  InteriorBoundaryComparison2Loop8Prop, #["Occurrence"] === "BoundaryOnly" &
];

(* Compact final object for downstream examples/tests. *)

hrfReport["assembling final FivePointSpacelikeCollinearAnalysis object"];

FivePointSpacelikeCollinearAnalysis = <|
  "Kinematics" -> <|"Substitution" -> collPar1, "Assumptions" -> KinAssump, "Variables" -> KinVars|>,
  "Seed" -> <|"InternalLines" -> seedInternalLines, "ExternalLines" -> seedExternalLines,
    "U" -> USeed5pt, "F" -> FSeed5pt, "Flead" -> F0Seed5pt, "Scan" -> Seed5ptScan,
    "GraphDrawing" -> Seed5ptGraphDrawing|>,
  "GraphCountSummary" -> GraphCountSummary,
  "SevenPropagator" -> <|
    "Graphs" -> Graphs2Loop7Prop,
    "GraphDrawings" -> GraphDrawings2Loop7Prop,
    "UFCollinearData" -> UFCollinear2Loop7Prop,
    "InteriorScanSummary" -> InteriorScanSummary2Loop7Prop,
    "BoundaryScan" -> BoundaryScan2Loop7Prop,
    "InterestingBoundaryCases" -> InterestingBoundary2Loop7Prop,
    "InterestingBoundarySummary" -> InterestingBoundarySummary2Loop7Prop,
    "InteriorScalingData" -> InteriorScalingData2Loop7Prop,
    "BoundaryScalingData" -> BoundaryScalingData2Loop7Prop,
    "ScalingData" -> ScalingData2Loop7Prop,
    "TopologyRegionScalingSummary" -> TopologyRegionScalingSummary2Loop7Prop,
    "TopologyHiddenRegionRows" -> TopologyHiddenRegionRows2Loop7Prop,
    "TopologyScalingCoverageSummary" -> TopologyScalingCoverageSummary2Loop7Prop,
    "TopologyAcceptedScalingRows" -> TopologyAcceptedScalingRows2Loop7Prop,
    "TopologyHiddenRegionScalingSummary" -> TopologyHiddenRegionScalingSummary2Loop7Prop,
    "TopologyRegionScalingStudyPanels" -> TopologyRegionScalingStudyPanels2Loop7Prop,
    "TopologyHiddenRegionScalingStudyPanels" -> TopologyHiddenRegionScalingStudyPanels2Loop7Prop,
    "TopologyAcceptedScalingStudyPanels" -> TopologyAcceptedScalingStudyPanels2Loop7Prop,
    "TopologyObstructionScanSummary" -> TopologyObstructionScanSummary2Loop7Prop,
    "CoverageScalingFailures" -> CoverageScalingFailures2Loop7Prop,
    "InteriorBoundaryComparison" -> InteriorBoundaryComparison2Loop7Prop,
    "SameGeneratorInteriorBoundary" -> SameGeneratorInteriorBoundary2Loop7Prop,
    "InteriorOnlyGenerators" -> InteriorOnlyGenerator2Loop7Prop,
    "BoundaryOnlyGenerators" -> BoundaryOnlyGenerator2Loop7Prop
  |>,
  "EightPropagator" -> <|
    "Graphs" -> Graphs2Loop8Prop,
    "GraphDrawings" -> GraphDrawings2Loop8Prop,
    "UFCollinearData" -> UFCollinear2Loop8Prop,
    "InteriorScanSummary" -> InteriorScanSummary2Loop8Prop,
    "BoundaryScan" -> BoundaryScan2Loop8Prop,
    "InterestingBoundaryCases" -> InterestingBoundary2Loop8Prop,
    "InterestingBoundarySummary" -> InterestingBoundarySummary2Loop8Prop,
    "InteriorScalingData" -> InteriorScalingData2Loop8Prop,
    "BoundaryScalingData" -> BoundaryScalingData2Loop8Prop,
    "ScalingData" -> ScalingData2Loop8Prop,
    "TopologyRegionScalingSummary" -> TopologyRegionScalingSummary2Loop8Prop,
    "TopologyHiddenRegionRows" -> TopologyHiddenRegionRows2Loop8Prop,
    "TopologyScalingCoverageSummary" -> TopologyScalingCoverageSummary2Loop8Prop,
    "TopologyAcceptedScalingRows" -> TopologyAcceptedScalingRows2Loop8Prop,
    "TopologyHiddenRegionScalingSummary" -> TopologyHiddenRegionScalingSummary2Loop8Prop,
    "TopologyRegionScalingStudyPanels" -> TopologyRegionScalingStudyPanels2Loop8Prop,
    "TopologyHiddenRegionScalingStudyPanels" -> TopologyHiddenRegionScalingStudyPanels2Loop8Prop,
    "TopologyAcceptedScalingStudyPanels" -> TopologyAcceptedScalingStudyPanels2Loop8Prop,
    "TopologyObstructionScanSummary" -> TopologyObstructionScanSummary2Loop8Prop,
    "CoverageScalingFailures" -> CoverageScalingFailures2Loop8Prop,
    "InteriorBoundaryComparison" -> InteriorBoundaryComparison2Loop8Prop,
    "SameGeneratorInteriorBoundary" -> SameGeneratorInteriorBoundary2Loop8Prop,
    "InteriorOnlyGenerators" -> InteriorOnlyGenerator2Loop8Prop,
    "BoundaryOnlyGenerators" -> BoundaryOnlyGenerator2Loop8Prop
  |>
|>;

(* Notebook-friendly Dataset displays (raw *Rows* objects are plain lists). *)
TopologyHiddenRegionTable2Loop7Prop = hrfFPHiddenRegionDisplay[TopologyHiddenRegionRows2Loop7Prop];
TopologyHiddenRegionTable2Loop8Prop = hrfFPHiddenRegionDisplay[TopologyHiddenRegionRows2Loop8Prop];
TopologyRegionScalingTable2Loop7Prop = hrfFPRegionScalingDisplay[TopologyRegionScalingSummary2Loop7Prop];
TopologyRegionScalingTable2Loop8Prop = hrfFPRegionScalingDisplay[TopologyRegionScalingSummary2Loop8Prop];
TopologyScalingCoverageTable2Loop7Prop = hrfFPScalingCoverageDisplay[TopologyScalingCoverageSummary2Loop7Prop];
TopologyScalingCoverageTable2Loop8Prop = hrfFPScalingCoverageDisplay[TopologyScalingCoverageSummary2Loop8Prop];

,
  (* seed-only mode: defer 7/8-propagator scans and notebook summary tables *)
  GraphCountSummary = <|
    "SeedPropagators" -> Length[seedInternalLines],
    "SevenPropagatorGraphs" -> Missing["Deferred", $HRFEx03DeferredFullScanMessage],
    "EightPropagatorGraphs" -> Missing["Deferred", $HRFEx03DeferredFullScanMessage]
  |>;
  TopologyHiddenRegionTable2Loop7Prop = Missing["Deferred", $HRFEx03DeferredFullScanMessage];
  TopologyHiddenRegionTable2Loop8Prop = Missing["Deferred", $HRFEx03DeferredFullScanMessage];
  TopologyRegionScalingTable2Loop7Prop = Missing["Deferred", $HRFEx03DeferredFullScanMessage];
  TopologyRegionScalingTable2Loop8Prop = Missing["Deferred", $HRFEx03DeferredFullScanMessage];
  TopologyScalingCoverageTable2Loop7Prop = Missing["Deferred", $HRFEx03DeferredFullScanMessage];
  TopologyScalingCoverageTable2Loop8Prop = Missing["Deferred", $HRFEx03DeferredFullScanMessage];
  FivePointSpacelikeCollinearAnalysis = <|
    "Kinematics" -> <|"Substitution" -> collPar1, "Assumptions" -> KinAssump, "Variables" -> KinVars|>,
    "Seed" -> <|"InternalLines" -> seedInternalLines, "ExternalLines" -> seedExternalLines,
      "U" -> USeed5pt, "F" -> FSeed5pt, "Flead" -> F0Seed5pt, "Scan" -> Seed5ptScan,
      "GraphDrawing" -> Seed5ptGraphDrawing|>,
    "GraphCountSummary" -> GraphCountSummary,
    "SevenPropagator" -> Missing["Deferred", $HRFEx03DeferredFullScanMessage],
    "EightPropagator" -> Missing["Deferred", $HRFEx03DeferredFullScanMessage]
  |>
];

(* Suggested interactive inspection commands:

   GraphCountSummary
   InterestingBoundarySummary2Loop7Prop
   InterestingBoundarySummary2Loop8Prop
   TopologyRegionScalingSummary2Loop7Prop
   TopologyHiddenRegionRows2Loop7Prop
   TopologyScalingCoverageSummary2Loop7Prop
   TopologyAcceptedScalingRows2Loop7Prop
   TopologyHiddenRegionScalingSummary2Loop7Prop
   TopologyRegionScalingStudyPanels2Loop7Prop
   TopologyHiddenRegionScalingStudyPanels2Loop7Prop
   TopologyAcceptedScalingStudyPanels2Loop7Prop
   GraphDrawings2Loop7Prop
   (* single case, e.g. G_t\[Bullet] interior: *)
   hrfFPScalingStudyPanelMatch[
     TopologyRegionScalingSummary2Loop7Prop, GraphDrawings2Loop7Prop,
     InteriorScalingData2Loop7Prop, BoundaryScalingData2Loop7Prop, 2]
   TopologyObstructionScanSummary2Loop7Prop
   InteriorScalingData2Loop7Prop
   BoundaryScalingData2Loop7Prop
   CoverageScalingFailures2Loop7Prop
   TopologyRegionScalingSummary2Loop8Prop
   TopologyHiddenRegionRows2Loop8Prop
   TopologyScalingCoverageSummary2Loop8Prop
   TopologyAcceptedScalingRows2Loop8Prop
   TopologyHiddenRegionScalingSummary2Loop8Prop
   TopologyRegionScalingStudyPanels2Loop8Prop
   TopologyHiddenRegionScalingStudyPanels2Loop8Prop
   TopologyAcceptedScalingStudyPanels2Loop8Prop
   GraphDrawings2Loop8Prop
   TopologyObstructionScanSummary2Loop8Prop
   InteriorScalingData2Loop8Prop
   BoundaryScalingData2Loop8Prop
   CoverageScalingFailures2Loop8Prop
   InteriorBoundaryComparison2Loop7Prop
   InteriorBoundaryComparison2Loop8Prop
   SameGeneratorInteriorBoundary2Loop7Prop
   SameGeneratorInteriorBoundary2Loop8Prop
   BoundaryOnlyGenerator2Loop7Prop
   BoundaryOnlyGenerator2Loop8Prop
   FivePointSpacelikeCollinearAnalysis["SevenPropagator", "SameGeneratorInteriorBoundary"]
   FivePointSpacelikeCollinearAnalysis["EightPropagator", "InteriorBoundaryComparison"]
*)

If[! TrueQ[$HRFQuietReports],
  Print["=== Example 03 LOAD COMPLETE (", hrfEx03CancellationFactorMode[], " factors) ==="];
  If[ValueQ[GraphCountSummary], Print["GraphCountSummary: ", GraphCountSummary]]
];
