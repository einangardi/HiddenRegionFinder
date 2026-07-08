(* HRF_HyperCrownX11Light.wl
   Memory-safe HyperCrown {x11}=0 probe: Ex01 massive vs Ex02 massless wide + Regge.
   Does NOT load 01/02/04 example files (no interior or 15-stratum boundary batch).
(* Run: Get["HRF_HyperCrownX11Light.wl"];
   hrfHyperCrownX11LightProbe[]              (* default: Ex02 wide + Regge T23 *)
   hrfHyperCrownX11LightProbe["All"]         (* all cases; ~15+ min, needs RAM *)
   hrfHyperCrownX11LightProbe["Ex02Wide"]    (* single case *)
*)

$HRFQuietReports = True;
$HRFPolynomialMaxMonomials = 12;
$HRFCandidateGeneratorSetLimit = 64;
$HRFFindObstructionsStopOnFirstAdmissibleQ = True;

hrfHCX11Dir[] := If[StringQ[$InputFileName] && $InputFileName =!= "",
  DirectoryName[$InputFileName], Directory[]];

hrfHCX11EnsureCore[] := Module[{d = hrfHCX11Dir[]},
  If[! TrueQ[$HRFFinderCoreLoadedQ], Get[FileNameJoin[{d, "HiddenRegionFinder.wl"}]]];
  If[! ValueQ[hrfInstallPolynomialCancellationPatch],
    Get[FileNameJoin[{d, "HRF_PolynomialCancellationFactors.wl"}]]
  ];
  $HRFUsePolynomialCancellationFactors = True;
  hrfInstallPolynomialCancellationPatch[];
  If[! ValueQ[hrfHiddenSummaryRow], Get[FileNameJoin[{d, "HRF_FinalLogicPatch.wl"}]]];
  If[! ValueQ[hrfCoverageFoundQ], Get[FileNameJoin[{d, "HRF_Example01Common.wl"}]]];
  If[! ValueQ[hrfReggeLeadingF], Get[FileNameJoin[{d, "HRF_Example02ReggeKinematics.wl"}]]];
];

hrfHCX11HyperCrownMassive[] := Module[{edges, ext, uf, f, f0, vars},
  edges = {
    {"0", {1, 5}}, {"0", {1, 6}}, {"0", {4, 9}}, {"0", {4, 6}}, {"0", {2, 7}}, {"0", {2, 6}},
    {"0", {3, 8}}, {"0", {3, 6}}, {"0", {9, 5}}, {"0", {7, 8}}, {"0", {8, 9}}, {"0", {5, 7}}
  };
  ext = {{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}};
  uf = SymanzikUF[edges, ext];
  f = toCyclicMandelstams4ptMassive[uf["F"]];
  f0 = Expand[f /. {p1sq -> \[Delta], p2sq -> \[Delta], p3sq -> \[Delta], p4sq -> \[Delta]} /. \[Delta] -> 0];
  vars = uf["Variables"];
  <|"UF" -> uf, "F0" -> f0, "Vars" -> vars|>
];

hrfHCX11HyperCrownMassless[] := Module[{edges, ext, uf, f, vars},
  edges = {
    {"0", {1, 5}}, {"0", {1, 6}}, {"0", {4, 9}}, {"0", {4, 6}}, {"0", {2, 7}}, {"0", {2, 6}},
    {"0", {3, 8}}, {"0", {3, 6}}, {"0", {9, 5}}, {"0", {7, 8}}, {"0", {8, 9}}, {"0", {5, 7}}
  };
  ext = {{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}};
  uf = SymanzikUF[edges, ext];
  f = toCyclicMandelstams4ptMassless[uf["F"]];
  vars = uf["Variables"];
  <|"UF" -> uf, "F" -> Expand[f], "Vars" -> vars|>
];

hrfHCX11ReggeFactors[Ffull_, fRegge_, vars_, kinAssump_, kinVars_] := Module[{facR, facW},
  facR = safeCancellationFactorsExtended[fRegge, vars, kinAssump, kinVars, {}][[1]];
  facW = safeCancellationFactorsExtended[Ffull, vars, s12 > -s23 > 0, {s12, s23}, {}][[1]];
  DeleteDuplicates @ Join[facR, Select[facW, positiveCompatibleQ[#, vars, kinAssump, kinVars] &]]
];

hrfHCX11ScanRow[label_, scan_, fIn_, zeroVars_, activeVars_, kinVars_, U_, configuration_, scaling_:Automatic] := Module[
  {row, sc},
  scan = Join[scan, <|"InputPolynomial" -> fIn, "ZeroVars" -> zeroVars, "ActiveVars" -> activeVars,
    "KinVars" -> kinVars|>];
  sc = If[scaling === Automatic, hrfCoverageData[scan, U, activeVars, 5], scaling];
  row = hrfHiddenSummaryRow[label, configuration, zeroVars, activeVars, scan, sc];
  <|
    "Label" -> label,
    "Hidden" -> row["Hidden region identified?"],
    "Comment" -> Lookup[row, "Comment", "--"],
    "Gens" -> Length[Lookup[scan, "Generators", {}]],
    "Factors" -> Length[Lookup[scan, "CancellationFactors", {}]],
    "Decomp" -> hrfSuccessfulObstructionDecompositionQ[scan],
    "Exact" -> hrfExactReductionQ[scan],
    "Adm" -> Lookup[scan, "AdmissibleGeneratorSetQ", False],
    "Scaling" -> Lookup[row, "Scaling status", "--"],
    "Scan" -> scan
  |>
];

ClearAll[hrfHyperCrownX11LightProbe];
hrfHyperCrownX11LightProbe[cases_: Automatic] := Module[
  {mass, ml, zero = {x11}, vars, f01, f02, u02, u02T23, rows = {},
   scan01, scan02W, scan02R, f02R, facR, want},
  want = Which[
    cases === Automatic, {"Ex02Wide", "Ex02Regge"},
    cases === "All", {"Ex01Wide", "Ex02Wide", "Ex02Regge"},
    StringQ[cases], {cases},
    ListQ[cases], cases,
    True, {"Ex02Wide", "Ex02Regge"}
  ];
  hrfHCX11EnsureCore[];
  mass = hrfHCX11HyperCrownMassive[];
  ml = hrfHCX11HyperCrownMassless[];
  f01 = Expand[mass["F0"] /. Thread[zero -> 0]];
  f02 = Expand[ml["F"] /. Thread[zero -> 0]];
  vars = Complement[mass["Vars"], zero];
  u02 = Expand[ml["UF"]["U"] /. Thread[zero -> 0]];
  u02T23 = hrfReggeLeadingF[u02, "T23"];

  Print["=== HyperCrown {x11}=0 light probe (", want, ") ==="];
  Print["F polynomials equal (massive F0 vs massless F)? ", TrueQ[Expand[f01 - f02] === 0]];
  Print["Monomials Ex01/Ex02: ", Length[MonomialList[f01, vars]], " / ", Length[MonomialList[f02, vars]]];

  If[MemberQ[want, "Ex01Wide"],
    scan01 = findObstructions[f01, vars, s12 > -s23 > 0, {s12, s23}, 30,
      "GeneratorMode" -> "Adaptive", "UseExtendedFactors" -> True, "MaxGenerators" -> 2];
    AppendTo[rows, hrfHCX11ScanRow["Ex01 massive wide {x11}=0", scan01, f01, zero, vars, {s12, s23},
      Expand[mass["UF"]["U"] /. Thread[zero -> 0]], "Boundary {x11}"]];
  ];

  If[MemberQ[want, "Ex02Wide"],
    scan02W = findObstructions[f02, vars, s12 > -s23 > 0, {s12, s23}, 30,
      "GeneratorMode" -> "Adaptive", "UseExtendedFactors" -> True, "MaxGenerators" -> 2];
    AppendTo[rows, hrfHCX11ScanRow["Ex02 massless wide {x11}=0", scan02W, f02, zero, vars, {s12, s23}, u02, "Boundary {x11}"]];
  ];

  If[MemberQ[want, "Ex02Regge"],
    f02R = hrfReggeLeadingF[f02, "T23"];
    facR = hrfHCX11ReggeFactors[f02, f02R, vars, s12 > 0, {s12}];
    Print["Regge T23 factor pool: ", Length[facR]];
    scan02R = findObstructions[f02R, vars, s12 > 0, {s12}, 30,
      "GeneratorMode" -> "PairSectors", "UseExtendedFactors" -> True,
      "MaxGenerators" -> 1, "PreferFewerGenerators" -> True,
      "CancellationFactorOverride" -> facR];
    AppendTo[rows, hrfHCX11ScanRow["Ex02 massless Regge T23 {x11}=0", scan02R, f02R, zero, vars, {s12}, u02, "Boundary {x11} Regge T23"]];
  ];

  Print[""];
  Do[
    Print[r["Label"], ": Hidden=", r["Hidden"], " | Gens=", r["Gens"], " | Factors=", r["Factors"],
      " | Decomp=", r["Decomp"], " | Exact=", r["Exact"], " | Scaling=", r["Scaling"]],
    {r, rows}
  ];
  Dataset[KeyDrop[#, {"Scan"}] & /@ rows]
];

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] HRF_HyperCrownX11Light.wl — evaluate hrfHyperCrownX11LightProbe[]"]
];
