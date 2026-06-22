(* HRF_RegressionFixtures.wl
   Minimal Crown / Seed5pt fixtures without Example 01 load-time scans. *)

If[! TrueQ[$HRFFinderCoreLoadedQ],
  Get[FileNameJoin[{
    Which[
      ValueQ[hrfPackageDirectory], hrfPackageDirectory[],
      StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName],
        DirectoryName[$InputFileName],
      True, Quiet @ Check[NotebookDirectory[], Directory[]]
    ],
    "HiddenRegionFinder.wl"
  }]]
];

ClearAll[hrfRegressionLoadCrown, hrfRegressionLoadSeed5pt];

hrfRegressionLoadCrown[] := Module[{},
  If[! ValueQ[makeFourPointOnShellF0],
    ClearAll[makeFourPointOnShellF0];
    makeFourPointOnShellF0[internalLines_, externalLines_] := Module[
      {uf, f, fOnShell, f0, vars},
      uf = SymanzikUF[internalLines, externalLines];
      f = toCyclicMandelstams4ptMassive[uf["F"]];
      fOnShell = Expand[f /. {p1sq -> \[Delta], p2sq -> \[Delta], p3sq -> \[Delta], p4sq -> \[Delta]}];
      f0 = Expand[fOnShell /. \[Delta] -> 0];
      vars = uf["Variables"];
      <|"UF" -> uf, "FOnShell" -> fOnShell, "F0" -> f0, "Vars" -> vars|>
    ];
  ];
  KinAssump4ptOnShell = s12 > -s23 > 0;
  KinVars4pt = {s12, s23};
  CrownInternalEdges = {
    {"0", {1, 5}}, {"0", {1, 6}}, {"0", {2, 5}}, {"0", {2, 6}},
    {"0", {3, 5}}, {"0", {3, 6}}, {"0", {4, 5}}, {"0", {4, 6}}
  };
  CrownExternalEdges = {{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}};
  CrownData = makeFourPointOnShellF0[CrownInternalEdges, CrownExternalEdges];
  F0Crown = CrownData["F0"];
  VarsCrown = CrownData["Vars"];
  True
];

hrfRegressionLoadSeed5pt[] := Module[{dir},
  dir = Which[
    ValueQ[hrfPackageDirectory], hrfPackageDirectory[],
    StringQ[$HRFTestDirectory], $HRFTestDirectory,
    StringQ[$InputFileName] && $InputFileName =!= "", DirectoryName[$InputFileName],
    True, Quiet @ Check[NotebookDirectory[], Directory[]]
  ];
  Get[FileNameJoin[{dir, "HRF_Example03CollinearCore.wl"}]];
  True
];
