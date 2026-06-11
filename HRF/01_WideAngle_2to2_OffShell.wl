(* ::Package:: *)

(* 01_WideAngle_2to2_OffShell.wl

   Wide-angle 2 -> 2 kinematics with external off-shellnesses taken to zero.
   This file contains the ordinary Crown, SuperCrown and Diving Beetle examples.

   Expected highlights:
     Crown:      interior hidden region, obstruction 0, two pair-sector generators.
     SuperCrown: boundary hidden region on {x8,x9}=0, inherited from the Crown.
     DB:         boundary scan diagnostic; in current tests no hidden region was found
                 up to the tested codimension/obstruction size.

   Usage:
     SetDirectory[DirectoryName[$InputFileName]];  (* if running as script *)
     Get["../HiddenRegionFinder.wl"];
     << this file, or evaluate section by section.
*)


If[! ValueQ[findObstructions], Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "HiddenRegionFinder.wl"}]]];

ClearAll[makeFourPointOnShellF0];

(* makeFourPointOnShellF0[internal, external]
   Input:  graph in pySecDec-style internal/external-line notation.
   Output: Association with "UF", "FOnShell", "F0", "Vars".
   The off-shellnesses p_i^2 are replaced by delta and F0 is the strict delta^0 part. *)
makeFourPointOnShellF0[internalLines_, externalLines_] := Module[
  {uf, f, fOnShell, f0, vars},
  uf = SymanzikUF[internalLines, externalLines];
  f = toCyclicMandelstams4ptMassive[uf["F"]];
  fOnShell = Expand[f /. {p1sq -> \[Delta], p2sq -> \[Delta], p3sq -> \[Delta], p4sq -> \[Delta]}];
  f0 = Expand[fOnShell /. \[Delta] -> 0];
  vars = uf["Variables"];
  <|"UF" -> uf, "FOnShell" -> fOnShell, "F0" -> f0, "Vars" -> vars|>
];

KinAssump4ptOnShell = s12 > 0 && s23 < 0;
KinVars4pt = {s12, s23};

(* ---------------------------------------------------------------------- *)
(* Ordinary Crown: interior hidden region                                  *)
(* ---------------------------------------------------------------------- *)

CrownInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 6}}, {"0", {2, 5}}, {"0", {2, 6}},
  {"0", {3, 5}}, {"0", {3, 6}}, {"0", {4, 5}}, {"0", {4, 6}}
};

CrownExternalEdges = {{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}};

CrownData = makeFourPointOnShellF0[CrownInternalEdges, CrownExternalEdges];
F0Crown = CrownData["F0"];
VarsCrown = CrownData["Vars"];

CrownScan = findObstructions[
  F0Crown, VarsCrown, KinAssump4ptOnShell, KinVars4pt, 20,
  "GeneratorMode" -> "PairSectors",
  "UseExtendedFactors" -> True,
  "MaxGenerators" -> 2
];

CrownGeneratorCheck = PolynomialReduce[
  CrownScan["ObstructionData", "Superleading"],
  CrownScan["Generators"],
  Join[VarsCrown, KinVars4pt]
];

(* Expected CrownGeneratorCheck: {{s12,-s23},0}. *)

(* Coverage-based LP scaling diagnostic for the ordinary Crown.  There is no
   separate F_obs in this 2 -> 2 off-shell/on-shell test, so the replacement
   criterion uses F_SL and U only. *)
CrownCoverageScalingData = findCoverageLPScaling[
  CrownScan["ObstructionData", "Complement"], CrownData["UF"]["U"], VarsCrown, 5
];
CrownOldScalingDiagnostic = Module[
  {old = findMinimalLPScaling[
      CrownScan["ObstructionData", "Obstruction"],
      CrownScan["ObstructionData", "Complement"],
      CrownData["UF"]["U"], VarsCrown, 5]},
  If[ListQ[old], scalingDiagnostic[CrownScan["ObstructionData", "Complement"], CrownData["UF"]["U"], VarsCrown, old], old]
];


(* ---------------------------------------------------------------------- *)
(* SuperCrown: boundary hidden region inherited from Crown                  *)
(* ---------------------------------------------------------------------- *)

SuperCrownInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 6}}, {"0", {2, 7}}, {"0", {2, 6}},
  {"0", {3, 5}}, {"0", {3, 8}}, {"0", {4, 7}}, {"0", {4, 8}},
  {"0", {5, 7}}, {"0", {6, 8}}, {"0", {7, 8}}, {"0", {5, 6}}
};

SuperCrownExternalEdges = CrownExternalEdges;

SuperCrownData = makeFourPointOnShellF0[SuperCrownInternalEdges, SuperCrownExternalEdges];
F0SuperCrown = SuperCrownData["F0"];
VarsSuperCrown = SuperCrownData["Vars"];

(* Interior scan is not expected to find the clean Crown sector. *)
SuperCrownInteriorScan = findObstructions[
  F0SuperCrown, VarsSuperCrown, KinAssump4ptOnShell, KinVars4pt, 30,
  "GeneratorMode" -> "PairSectors",
  "UseExtendedFactors" -> True,
  "MaxGenerators" -> 2
];

(* Boundary stratum exposing the inherited Crown structure. *)
zeroSC = {x8, x9};
F0SuperCrownBoundary = Factor[Expand[F0SuperCrown /. Thread[zeroSC -> 0]]];
VarsSuperCrownBoundary = Complement[VarsSuperCrown, zeroSC];

SuperCrownBoundaryScan = findObstructions[
  F0SuperCrownBoundary, VarsSuperCrownBoundary,
  KinAssump4ptOnShell, KinVars4pt, 30,
  "GeneratorMode" -> "PairSectors",
  "UseExtendedFactors" -> True,
  "MaxGenerators" -> 2
];

SuperCrownGeneratorCheck = PolynomialReduce[
  SuperCrownBoundaryScan["ObstructionData", "Superleading"],
  SuperCrownBoundaryScan["Generators"],
  Join[VarsSuperCrownBoundary, KinVars4pt]
];

(* Expected SuperCrownGeneratorCheck: {{s12 x10 x11, -s23 x10 x11},0}. *)

(* Coverage-based LP scaling diagnostic for the inherited Crown boundary. *)
SuperCrownCoverageScalingData = findCoverageLPScaling[
  SuperCrownBoundaryScan["ObstructionData", "Complement"],
  SuperCrownData["UF"]["U"] /. Thread[zeroSC -> 0] // Expand,
  VarsSuperCrownBoundary, 5
];
SuperCrownOldScalingDiagnostic = Module[
  {old = findMinimalLPScaling[
      SuperCrownBoundaryScan["ObstructionData", "Obstruction"],
      SuperCrownBoundaryScan["ObstructionData", "Complement"],
      SuperCrownData["UF"]["U"] /. Thread[zeroSC -> 0] // Expand,
      VarsSuperCrownBoundary, 5]},
  If[ListQ[old], scalingDiagnostic[SuperCrownBoundaryScan["ObstructionData", "Complement"], SuperCrownData["UF"]["U"] /. Thread[zeroSC -> 0] // Expand, VarsSuperCrownBoundary, old], old]
];


(* ---------------------------------------------------------------------- *)
(* Diving Beetle: boundary scan diagnostic                                  *)
(* ---------------------------------------------------------------------- *)

DBInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 7}}, {"0", {7, 4}}, {"0", {4, 9}},
  {"0", {9, 3}}, {"0", {3, 5}}, {"0", {2, 5}}, {"0", {2, 6}},
  {"0", {6, 8}}, {"0", {6, 4}}, {"0", {9, 8}}, {"0", {8, 7}}
};

DBExternalEdges = CrownExternalEdges;

DBData = makeFourPointOnShellF0[DBInternalEdges, DBExternalEdges];
F0DB = DBData["F0"];
VarsDB = DBData["Vars"];

DBInteriorDiagnostic = obstructionGeneratorDiagnostic[
  F0DB, VarsDB, KinAssump4ptOnShell, KinVars4pt, 20, 2
];

InterestingBoundaryDBCodim4Size20 = scanInterestingBoundariesOnly4pt[
  F0DB, VarsDB, KinAssump4ptOnShell, KinVars4pt,
  4, 20, 2
];

DBBoundarySummary = summarizeBoundaryScan4pt[InterestingBoundaryDBCodim4Size20];

(* Compact inspection command:
DBBoundarySummary[[All, {"Index", "ZeroVars", "Codimension", "CancellationFactors", "Generators", "Obstruction"}]]
*)





(* Compact coverage-scaling test object for this 2 -> 2 file. *)
CoverageScalingTests2to2OffShell = <|
  "CrownInterior" -> CrownCoverageScalingData,
  "CrownInteriorOldDiagnostic" -> CrownOldScalingDiagnostic,
  "SuperCrownBoundary" -> SuperCrownCoverageScalingData,
  "SuperCrownBoundaryOldDiagnostic" -> SuperCrownOldScalingDiagnostic
|>;
