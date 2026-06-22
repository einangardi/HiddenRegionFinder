(* HRF_HyperCrownX11Diagnostic.wl
   DEPRECATED (memory-heavy): loads 04 + 02 on Get.
   Use HRF_WideAngleBoundaryDiagnostic.wl or HRF_HyperCrownX11Light.wl instead. *)
$HRFQuietReports = True;
$HRFExample01Report = False;
$HRFExample02Report = False;
$HRFExample04Report = False;
$HRFEx04RunObstructionSearchQ = True;
$HRFFindObstructionsStopOnFirstAdmissibleQ = True;
$HRFPolynomialMaxMonomials = 12;
$HRFPolynomialRequireKinematicDomainQ = False;

Get[FileNameJoin[{Directory[], "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{Directory[], "HRF_PolynomialCancellationFactors.wl"}]];
hrfInstallPolynomialCancellationPatch[];
Get[FileNameJoin[{Directory[], "HRF_FinalLogicPatch.wl"}]];
Get[FileNameJoin[{Directory[], "HRF_Example01Reporting.wl"}]];
Get[FileNameJoin[{Directory[], "04_PolynomialFactor_Regression.wl"}]];

Print["=== Ex04 HyperCrown {x11}=0 (massive F0, polynomial, KinAssump4ptOnShell) ==="];
ex04 = hrfEx04HyperCrownX11Target[];
row04 = hrfEx04RegionStudyRow[
  ex04["PolynomialScan"], ex04["Label"], ex04["RemainingVars"],
  KinAssump4ptOnShell, KinVars4pt,
  Expand[HyperCrownData["UF"]["U"] /. x11 -> 0], {x11}
];
Print["Hidden: ", row04["Hidden region identified?"]];
Print["Decomp: ", hrfSuccessfulObstructionDecompositionQ[ex04["PolynomialScan"]]];
Print["Adm: ", ex04["PolynomialScan"]["AdmissibleGeneratorSetQ"]];
Print["Gens: ", Length[ex04["PolynomialScan"]["Generators"]]];
Print["Factors: ", Length[ex04["PolynomialScan"]["CancellationFactors"]]];
Print["Scaling: ", Lookup[row04, "Scaling status", Lookup[row04, "ScalingStatus", "--"]]];

$HRFRunEx02SuperCrownBoundary = False;
$HRFRunEx02HyperCrownBoundaries = False;
$HRFRunEx02DBBoundary = False;
Get[FileNameJoin[{Directory[], "02_Forward_Regge_2to2_Massless.wl"}]];

data = Ex02Diagrams["HyperCrown"];
f01 = Expand[F0HyperCrown /. x11 -> 0];
f02 = Expand[data["F"] /. x11 -> 0];
vars = Complement[data["Vars"], {x11}];
uB = Expand[data["UF"]["U"] /. x11 -> 0];

Print["\n=== F at {x11}=0 ==="];
Print["Ex01 massive == Ex02 massless? ", TrueQ[Expand[f01 - f02] === 0]];
Print["Ex01 monomials: ", Length[MonomialList[f01, vars]]];
Print["Ex02 monomials: ", Length[MonomialList[f02, vars]]];

bnd = hrfEx02BoundaryStudy["HyperCrown", data, {x11}, "Boundary {x11}"];

wideScan = hrfEx02RunObstructionScan[f02, vars, KinAssump4ptWideMassless, KinVars4ptWideMassless];
wideScan = Join[wideScan, <|"InputPolynomial" -> f02, "ZeroVars" -> {x11}, "ActiveVars" -> vars|>];

Print["\n=== Ex02 HyperCrown {x11}=0 wide (massless F, polynomial) ==="];
Print["Hidden: ", bnd["Wide"]["Hidden region identified?"]];
Print["Decomp: ", hrfSuccessfulObstructionDecompositionQ[wideScan]];
Print["Adm: ", wideScan["AdmissibleGeneratorSetQ"]];
Print["Factors: ", Length[wideScan["CancellationFactors"]]];
Print["Comment: ", bnd["Wide"]["Comment"]];
Print["Gens: ", bnd["Wide"]["Generators"]];
Print["Scaling: ", Lookup[bnd["Wide"], "Scaling status", "--"]];

Do[
  ch = hrfReggeChannels[][[i]];
  row = bnd[ch];
  fRegge = hrfReggeLeadingF[f02, ch];
  kv = hrfReggeKinVars[ch];
  ka = hrfReggeKinAssumptions[ch];
  regScan = hrfEx02RunObstructionScan[fRegge, vars, ka, kv, Automatic, f02];
  Print["\n=== Ex02 HyperCrown {x11}=0 Regge ", ch, " ==="];
  Print["Hidden: ", row["Hidden region identified?"]];
  Print["Decomp: ", hrfSuccessfulObstructionDecompositionQ[regScan]];
  Print["Adm: ", regScan["AdmissibleGeneratorSetQ"]];
  Print["Exact: ", hrfExactReductionQ[regScan]];
  Print["Factors: ", Length[regScan["CancellationFactors"]]];
  Print["Comment: ", row["Comment"]];
  Print["Gens: ", row["Generators"]];
  Print["Scaling: ", Lookup[row, "Scaling status", "--"]];
  If[AssociationQ[regScan["ObstructionData"]],
    Print["SL zero: ", TrueQ[Expand[regScan["ObstructionData"]["Superleading"]] === 0]];
  ,
  {i, Length[hrfReggeChannels[]]}
];

Print["\n=== Done ==="];
