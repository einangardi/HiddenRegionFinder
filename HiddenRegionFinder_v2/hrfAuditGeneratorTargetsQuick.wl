(* Quick generator audit for ThreeLoopVertex + HyperCrown x11=0 — no k=3 subset enum, no obstruction. *)
SetDirectory @ Which[
  StringQ[$InputFileName] && $InputFileName =!= "" && FileExistsQ[$InputFileName],
    DirectoryName[$InputFileName],
  ValueQ[hrfPackageDirectory], hrfPackageDirectory[],
  True, Directory[]
];

Get["HiddenRegionFinder.wl"];
Get["HRF_PolynomialCancellationFactors.wl"];
Get["HRF_Example03CollinearCore.wl"];

Block[{$HRFUsePolynomialCancellationFactors = True, $HRFPolynomialRequireKinematicDomainQ = False},
  hrfInstallPolynomialCancellationPatch[];

  hrfQuickAudit[F_, vars_, kinAssump_, kinVars_, label_] := Module[
    {ff, bounds, phys, physFF, kinFree, kinMixed, admissPairs, single2,
     opts, pairDiag, adaptive, limit = 64, oneGen, twoGen, maxSubset},
    bounds = hrfResolveGeneratorDegreeBounds[F, vars, <|
      "MaxGeneratorTotalDegree" -> Automatic,
      "MaxGeneratorVarExponent" -> Automatic
    |>];
    ff = hrfSafeCancellationFactorsPolynomial[F, vars, kinAssump, kinVars, {s}][[1]];
    phys = hrfFilterFactorsForGeneratorPhysics[ff, vars, kinVars, bounds];
    physFF = phys["Factors"];
    maxSubset = If[Length[physFF] > 40, 2, 3];
    opts = <|
      "MaxGeneratorTotalDegree" -> Automatic,
      "MaxGeneratorVarExponent" -> Automatic,
      "CandidateGeneratorSetLimit" -> limit,
      "MaxGenerators" -> 2,
      "MaxProductSubsetSize" -> maxSubset
    |>;
    bounds = hrfResolveGeneratorDegreeBounds[F, vars, opts];
    kinFree = Select[ff, ! hrfFactorContainsKinVarsQ[#, kinVars] &];
    kinMixed = Select[ff, hrfFactorContainsKinVarsQ[#, kinVars] &];

    Print["\n=== ", label, " ==="];
    Print["  f_k total=", Length[ff], "  kin-free=", Length[kinFree], "  kin-mixed=", Length[kinMixed]];
    Print["  physics-eligible=", Length[physFF],
      "  span-dropped=", Length[phys["SpanRedundantKinMixed"]]];

    admissPairs = Select[Subsets[physFF, {2}],
      hrfGeneratorPairPhysicsAdmissibleQ[#[[1]], #[[2]], bounds, vars, kinVars] &&
        simultaneouslyAdmissibleSubsetQ[#, vars, kinAssump, kinVars] &
    ];
    single2 = Select[Subsets[physFF, {2}],
      simultaneouslyAdmissibleSubsetQ[#, vars, kinAssump, kinVars] &&
        hrfGeneratorDegreeAdmissibleQ[Expand[Times @@ #], bounds, vars] &
    ];
    Print["  physics+simult pairs=", Length[admissPairs],
      "  (of C(", Length[physFF], ",2))"];
    Print["  single-product k=2 adm=", Length[single2],
      "  (MaxProductSubsetSize=", maxSubset, ")"];

    pairDiag = candidateGeneratorSetsDiagnostic[ff, 2, vars, kinAssump, kinVars, F, opts];
    adaptive = candidateGeneratorSetsAdaptive[ff, vars, kinAssump, kinVars, F, opts];
    oneGen = Select[adaptive, Length[#] === 1 &];
    twoGen = Select[adaptive, Length[#] > 1 &];
    Print["  PairSectors: ", Length[pairDiag],
      " (1-gen=", Length[Select[pairDiag, Length[#] === 1 &]],
      ", 2-gen=", Length[Select[pairDiag, Length[#] > 1 &]], ")"];
    Print["  Adaptive: ", Length[adaptive],
      " (1-gen=", Length[oneGen], ", 2-gen=", Length[twoGen],
      ", cap=", limit, ")"];

    Print["  Sample adaptive 1-gen factor counts in product:"];
    Do[
      Print["    gen ", i, ": ",
        generatorFactorData[oneGen[[i, 1]], ff, vars, kinVars, kinAssump, bounds][[1, "GeneratorFactorCount"]],
        " factors"],
      {i, Min[8, Length[oneGen]]}
    ];

    If[Length[oneGen] > 0,
      Module[{facCounts = Table[
        generatorFactorData[oneGen[[i, 1]], ff, vars, kinVars, kinAssump, bounds][[1, "GeneratorFactorCount"]],
        {i, Length[oneGen]}
      ]},
        Print["  1-gen factor-count histogram: ", Counts[facCounts]]
      ]
    ];

    <|
      "Label" -> label,
      "Factors" -> Length[ff],
      "KinFree" -> Length[kinFree],
      "KinMixed" -> Length[kinMixed],
      "PhysicsEligible" -> Length[physFF],
      "AdmissPairs" -> Length[admissPairs],
      "SingleProduct2" -> Length[single2],
      "PairSectorSets" -> Length[pairDiag],
      "AdaptiveSets" -> Length[adaptive],
      "Adaptive1Gen" -> Length[oneGen],
      "Adaptive2Gen" -> Length[twoGen]
    |>
  ];

  Print["\n=== Quick generator audit (no obstruction, no k=3 enum) ===\n"];
  r1 = hrfQuickAudit[F0ThreeLoopVertex5pt, VarsThreeLoopVertex5pt, KinAssump, KinVars,
    "ThreeLoopVertex (target)"];

  Block[{$HRFRunCrownInteriorScanOnLoad = False, $HRFRunExample01ReportingOnLoad = False,
    $HRFRunHyperCrownInteriorScan = False, $HRFRunDivingBeetleInteriorScanOnLoad = False,
    $HRFRunHyperCrownBoundaryScansOnLoad = False},
    Get["01_WideAngle_2to2_OffShell.wl"]
  ];
  hrfInstallPolynomialCancellationPatch[];
  r2 = hrfQuickAudit[Expand[F0HyperCrown /. x11 -> 0], Complement[VarsHyperCrown, {x11}],
    KinAssump4ptOnShell, KinVars4pt, "HyperCrown {x11}=0 (target)"];

  Print["\n=== Summary ==="];
  Print[Dataset[{r1, r2}]];
];
