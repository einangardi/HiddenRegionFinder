(* rebuild_polynomial_notebooks.wl *)

Get[FileNameJoin[{Directory[], "rebuild_standard_notebooks.wl"}]];

$dir = Directory[];

hrfNbStdExport[
  FileNameJoin[{$dir, "04_PolynomialFactor_Regression.nb"}],
  "Polynomial factor regression",
  {
    hrfNbStdSection["Setup"],
    hrfNbStdText["Obstruction search ON. StopOnFirstAdmissible keeps total runtime ~hour-scale. HyperCrown {x11}=0 ~20 s; full 64 trials ~15 min. ThreeLoopVertex candidate build ~15-30 min then trials. Use a fresh kernel."],
    hrfNbStdInput[
      "$HRFRunEx04RegressionOnLoad = True;\n$HRFRunEx04SlowCasesOnLoad = True;\n$HRFRunEx04FivePointOnLoad = True;\n$HRFExample04Report = True;\n$HRFScalingReport = False;\n$HRFCandidateGeneratorSetLimit = 64;\n$HRFEx04RunObstructionSearchQ = True;\n$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\n$HRFMaxProductSubsetSize = 2;\n$HRFObstructionFindInstanceTimeLimit = 20;\n$HRFPolynomialRequireKinematicDomainQ = False;\n$HRFEx04GeneratorPairTableMaxFactors = 16;\nGet[FileNameJoin[{NotebookDirectory[], \"HiddenRegionFinder.wl\"}]];\nGet[FileNameJoin[{NotebookDirectory[], \"04_PolynomialFactor_Regression.wl\"}]];",
      "In[1]:="
    ],
    hrfNbStdSection["Regression comparison"],
    hrfNbStdInput["Ex04PolynomialRegressionTable", "In[2]:="],
    hrfNbStdInput["Ex04PolynomialRegressionNarrative", "In[3]:="],
    hrfNbStdSection["HyperCrown {x11}=0 — inspect generators and region"],
    hrfNbStdInput[
      "hrfEx04InspectPolynomialScan[Ex04HyperCrownX11Target, Automatic, Automatic, KinAssump4ptOnShell, KinVars4pt, Expand[HyperCrownData[\"UF\"][\"U\"] /. x11 -> 0]]",
      "In[4]:="
    ],
    hrfNbStdInput["Ex04HyperCrownX11Target[\"GeneratorTrialTable\"][\"Polynomial\"]", "In[5]:="],
    hrfNbStdInput[
      "hrfEx04GeneratorPairTable[Ex04HyperCrownX11Target, \"Polynomial\", Complement[VarsHyperCrown, {x11}], KinAssump4ptOnShell, KinVars4pt]",
      "In[6]:="
    ],
    hrfNbStdSection["HyperCrown interior"],
    hrfNbStdInput[
      "hrfEx04InspectPolynomialScan[Ex04HyperCrownInterior, Automatic, Automatic, KinAssump4ptOnShell, KinVars4pt, HyperCrownData[\"UF\"][\"U\"]]",
      "In[7]:="
    ],
    hrfNbStdSection["Seed5pt collinear interior"],
    hrfNbStdInput[
      "hrfEx04InspectFivePointCase[Ex04Seed5ptInterior, \"Seed5pt\"]",
      "In[8]:="
    ],
    hrfNbStdInput[
      "hrfSeed5ptReport = hrfEx04FivePointCaseDisplay[Ex04Seed5ptInterior, \"Seed5pt\"];\nhrfSeed5ptReport[\"Ingredients\"][\"ScalingVector\"]",
      "In[8a]:="
    ],
    hrfNbStdSection["ThreeLoopVertex collinear interior"],
    hrfNbStdText["Expect long candidate-build phase before first trial. Inspect accepted generators below."],
    hrfNbStdInput[
      "hrfEx04InspectFivePointCase[Ex04ThreeLoopVertexInterior, \"ThreeLoopVertex\"]",
      "In[9]:="
    ],
    hrfNbStdInput[
      "hrfVertexReport = hrfEx04FivePointCaseDisplay[Ex04ThreeLoopVertexInterior, \"ThreeLoopVertex\"];\nhrfVertexReport[\"AllValidTrialsScaling\"]",
      "In[9a]:="
    ],
    hrfNbStdInput[
      "Get[FileNameJoin[{NotebookDirectory[], \"hrfInspectThreeLoopVertexGenerators.wl\"}]];\nhrfThreeLoopVertexGeneratorRows[Ex04ThreeLoopVertexInterior[\"PolynomialScan\"]]",
      "In[10]:="
    ],
    hrfNbStdInput["Ex04FivePointComparison", "In[11]:="],
    hrfNbStdSection["Optional: full 64-trial scan (HyperCrown {x11}=0, ~15 min)"],
    hrfNbStdInput[
      "$HRFFindObstructionsStopOnFirstAdmissibleQ = False;\nBlock[{$HRFUsePolynomialCancellationFactors = True},\n  hrfInstallPolynomialCancellationPatch[];\n  fullHC = findObstructions[Expand[F0HyperCrown /. x11 -> 0], Complement[VarsHyperCrown, {x11}], KinAssump4ptOnShell, KinVars4pt, 30, \"GeneratorMode\" -> \"PairSectors\", \"UseExtendedFactors\" -> True, \"MaxGenerators\" -> 2, \"StopOnFirstAdmissible\" -> False, \"CandidateGeneratorSetLimit\" -> 64];\n];\nhrfPolyGeneratorTrialTable[fullHC, \"HyperCrown x11=0 full\"]",
      "In[12]:="
    ],
    hrfNbStdSection["Regression tests (Crown + Seed5pt)"],
    hrfNbStdInput[
      "res = hrfRunPolynomialFactorRegressionTests[];\nres[\"Summary\"]\nres[\"Rows\"]",
      "In[reg]:="
    ],
    hrfNbStdSection["Notebook smoke tests (Ex02 Crown + Seed5pt)"],
    hrfNbStdText["Validates binomial Regge and 5pt polynomial paths. Set $HRFSmokeRunSlowQ=True for HyperCrown {x11}=0; $HRFSmokeRunVerySlowQ=True for ThreeLoopVertex."],
    hrfNbStdInput[
      "Get[FileNameJoin[{NotebookDirectory[], \"HRF_NotebookSmokeTests.wl\"}]];\nhrfRunNotebookSmokeTests[]",
      "In[smoke]:="
    ]
  },
  "Polynomial factor regression. Obstruction search ON by default in In[1].",
  "Local"
];

Print["Polynomial notebook rebuilt."];
