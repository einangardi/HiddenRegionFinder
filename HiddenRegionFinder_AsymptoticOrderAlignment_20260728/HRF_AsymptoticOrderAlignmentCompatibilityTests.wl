(* Canonical-name and legacy-alias smoke tests for asymptotic-order alignment. *)

testDirectory = DirectoryName[$InputFileName];
$HRFQuietReports = True;
Get[FileNameJoin[{testDirectory, "HiddenRegionFinder.wl"}]];
Get[FileNameJoin[{testDirectory, "HRF_AsymptoticOrderAlignment.wl"}]];
Get[FileNameJoin[{testDirectory, "HRF_FaceliftPreselection.wl"}]];

ClearAll[hrfAlignmentCompatibilityTestRow, hrfRunAlignmentCompatibilityTests];

hrfAlignmentCompatibilityTestRow[name_String, value_] := <|
  "Test" -> name,
  "PassedQ" -> TrueQ[value]
|>;

hrfRunAlignmentCompatibilityTests[] := Module[
  {rows, canonicalTable, legacyTable, canonicalChoice, legacyChoice,
   compatibilityResult, summary},

  canonicalTable = hrfAsymptoticOrderAlignmentTermTable[
    x1 + eta x2, {x1, x2}, eta
  ];
  legacyTable = hrfFaceliftTermTable[x1 + eta x2, {x1, x2}, eta];
  canonicalChoice = hrfResolveAlignmentOption[
    {
      "AsymptoticOrderAlignmentMode" -> "Always",
      "FaceliftMode" -> "Only"
    },
    "AsymptoticOrderAlignmentMode", "FaceliftMode", "Off"
  ];
  legacyChoice = hrfResolveAlignmentOption[
    {"FaceliftMode" -> "Only"},
    "AsymptoticOrderAlignmentMode", "FaceliftMode", "Off"
  ];
  compatibilityResult = hrfAddLegacyFaceliftResultKeys @ <|
    "AsymptoticOrderAlignmentHiddenRegionQ" -> True,
    "AsymptoticOrderAlignmentStatus" -> "Done"
  |>;

  rows = {
    hrfAlignmentCompatibilityTestRow[
      "Canonical search loaded",
      Length[DownValues[hrfAsymptoticOrderAlignmentSearch]] > 0
    ],
    hrfAlignmentCompatibilityTestRow[
      "Legacy search alias loaded",
      Length[DownValues[hrfFaceliftSearch]] > 0
    ],
    hrfAlignmentCompatibilityTestRow[
      "Canonical and legacy term tables agree",
      SameQ[canonicalTable, legacyTable]
    ],
    hrfAlignmentCompatibilityTestRow[
      "Canonical option takes precedence",
      canonicalChoice === "Always"
    ],
    hrfAlignmentCompatibilityTestRow[
      "Legacy option remains accepted",
      legacyChoice === "Only"
    ],
    hrfAlignmentCompatibilityTestRow[
      "Legacy result keys remain available",
      compatibilityResult["FaceliftHiddenRegionQ"] === True &&
        compatibilityResult["FaceliftStatus"] === "Done"
    ]
  };
  summary = <|
    "Passed" -> Count[rows, row_ /; TrueQ[row["PassedQ"]]],
    "Failed" -> Count[rows, row_ /; ! TrueQ[row["PassedQ"]]],
    "Total" -> Length[rows]
  |>;
  <|"Summary" -> summary, "Rows" -> rows|>
];

If[MemberQ[FileNameTake /@ $ScriptCommandLine,
    "HRF_AsymptoticOrderAlignmentCompatibilityTests.wl"],
  result = hrfRunAlignmentCompatibilityTests[];
  Print[InputForm[result["Summary"]]];
  If[result["Summary", "Failed"] > 0, Exit[1], Exit[0]]
];
