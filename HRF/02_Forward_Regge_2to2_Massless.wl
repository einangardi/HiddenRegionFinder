(* ::Package:: *)
(* 02_Forward_Regge_2to2_Massless.wl

   Forward / Regge-type 2 -> 2 setup.
   External legs are massless and the expansion parameter is the ratio s23/s12.
   For the Crown, the s23 term is suppressed and the leading structure is a
   single product generator.
*)

If[! ValueQ[findObstructions], Get[FileNameJoin[{DirectoryName[$InputFileName], "..", "HiddenRegionFinder.wl"}]]];

ClearAll[makeFourPointMasslessF];

makeFourPointMasslessF[internalLines_, externalLines_] := Module[{uf, f, vars},
  uf = SymanzikUF[internalLines, externalLines];
  f = toCyclicMandelstams4ptMassless[uf["F"]];
  vars = uf["Variables"];
  <|"UF" -> uf, "F" -> Expand[f], "Vars" -> vars|>
];

CrownInternalEdges = {
  {"0", {1, 5}}, {"0", {1, 6}}, {"0", {2, 5}}, {"0", {2, 6}},
  {"0", {3, 5}}, {"0", {3, 6}}, {"0", {4, 5}}, {"0", {4, 6}}
};
CrownExternalEdges = {{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}};

CrownMasslessData = makeFourPointMasslessF[CrownInternalEdges, CrownExternalEdges];
FCrownMassless = CrownMasslessData["F"];
VarsCrown = CrownMasslessData["Vars"];

(* Regge / forward counting: s23 is subleading relative to s12. *)
KinVars4ptSmall23 = {s12};
KinAssump4ptSmall23 = s12 > 0;
F0CrownSmall23 = Factor[Expand[FCrownMassless /. s23 -> 0]];

CrownForwardScan = findObstructions[
  F0CrownSmall23, VarsCrown, KinAssump4ptSmall23, KinVars4ptSmall23, 20,
  "GeneratorMode" -> "PairSectors",
  "UseExtendedFactors" -> True,
  "MaxGenerators" -> 2
];

CrownForwardGeneratorCheck = PolynomialReduce[
  CrownForwardScan["ObstructionData", "Superleading"],
  CrownForwardScan["Generators"],
  Join[VarsCrown, KinVars4ptSmall23]
];

(* Expected CrownForwardGeneratorCheck: {{s12},0}. *)

(* Coverage-based LP scaling diagnostic for the 2 -> 2 massless forward test.
   There is no separate F_obs: the replacement criterion uses F_SL and U. *)
CrownForwardCoverageScalingData = findCoverageLPScaling[
  CrownForwardScan["ObstructionData", "Complement"],
  CrownMasslessData["UF"]["U"], VarsCrown, 5
];
CrownForwardOldScalingDiagnostic = Module[
  {old = findMinimalLPScaling[
      CrownForwardScan["ObstructionData", "Obstruction"],
      CrownForwardScan["ObstructionData", "Complement"],
      CrownMasslessData["UF"]["U"], VarsCrown, 5]},
  If[ListQ[old], scalingDiagnostic[CrownForwardScan["ObstructionData", "Complement"], CrownMasslessData["UF"]["U"], VarsCrown, old], old]
];

CoverageScalingTests2to2Forward = <|
  "CrownForward" -> CrownForwardCoverageScalingData,
  "CrownForwardOldDiagnostic" -> CrownForwardOldScalingDiagnostic
|>;

