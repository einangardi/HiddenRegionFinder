(* HRF_Example03CollinearCore.wl
   Lightweight five-point collinear kinematics: seed and vertex-corrected
   ThreeLoopVertex topologies only.  Does NOT run 7/8-propagator graph scans.

   Load for targeted interior comparison:
     Get["HRF_Example03CollinearCore.wl"];
*)

$HRFExample03CoreDirectory = If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName],
  Quiet[Check[NotebookDirectory[], Directory[]]]
];

If[! TrueQ[$HRFFinderCoreLoadedQ],
  Get[FileNameJoin[{$HRFExample03CoreDirectory, "HiddenRegionFinder.wl"}]]
];

ClearAll[hrfEx03LeadingDeltaPolynomial];

seedInternalLines = {
  {"0", {1, 3}}, {"0", {1, 5}}, {"0", {2, 3}},
  {"0", {2, 5}}, {"0", {3, 4}}, {"0", {4, 5}}
};

ThreeLoopVertexInternalLines = {
  {"0", {1, 3}}, {"0", {1, 5}}, {"0", {3, 7}}, {"0", {6, 5}},
  {"0", {3, 4}}, {"0", {4, 5}}, {"0", {2, 7}}, {"0", {6, 7}}, {"0", {2, 6}}
};

seedExternalLines = {{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}, {p5, 5}};

collPar1 = {
  s12 -> s z,
  s23 -> -4 \[Delta]^2,
  s34 -> -s x (-1 + z),
  s45 -> s,
  s15 -> s x + c \[Delta]
};

KinVars = {s, x, z};
KinAssump = x < 0 && x > -1 && z > 1 && s > 0;
CollinearDimensionfulKinVars = {s};

hrfEx03LeadingDeltaPolynomial[poly_] := Module[{expanded, powers, minPower},
  expanded = Expand[poly];
  powers = Exponent[#, \[Delta]] & /@ If[Head[expanded] === Plus, List @@ expanded, {expanded}];
  minPower = Min[powers];
  Coefficient[expanded, \[Delta], minPower] // Expand
];

(* Seed six-propagator topology *)
UFSeed5pt = SymanzikUF[seedInternalLines, seedExternalLines];
FSeed5pt = toCyclicMandelstams[UFSeed5pt["F"]];
USeed5pt = UFSeed5pt["U"];
VarsSeed5pt = UFSeed5pt["Variables"];
F0Seed5pt = hrfEx03LeadingDeltaPolynomial[Expand[FSeed5pt /. collPar1]];

(* Vertex-corrected nine-propagator (3-loop) topology *)
UFThreeLoopVertex5pt = SymanzikUF[ThreeLoopVertexInternalLines, seedExternalLines];
FThreeLoopVertex5pt = toCyclicMandelstams[UFThreeLoopVertex5pt["F"]];
UThreeLoopVertex5pt = UFThreeLoopVertex5pt["U"];
VarsThreeLoopVertex5pt = UFThreeLoopVertex5pt["Variables"];
F0ThreeLoopVertex5pt = hrfEx03LeadingDeltaPolynomial[Expand[FThreeLoopVertex5pt /. collPar1]];

If[! TrueQ[$HRFQuietReports],
  Print["[Example 03 core] seed vars=", Length[VarsSeed5pt],
    "  ThreeLoopVertex vars=", Length[VarsThreeLoopVertex5pt],
    "  (no graph/boundary scans)."]
];
