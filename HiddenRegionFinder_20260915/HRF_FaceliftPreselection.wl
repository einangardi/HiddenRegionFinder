(* ::Package:: *)
(* Deprecated compatibility loader.

   The canonical implementation is HRF_AsymptoticOrderAlignment.wl and the
   canonical symbol prefix is hrfAsymptoticOrderAlignment.  This file keeps
   notebooks and scripts written with the former hrfFacelift prefix working.
*)

Module[{packageDirectory, canonicalFile, canonicalNames},
  packageDirectory = Module[{inp = Quiet @ Check[$InputFileName, ""]},
    If[StringQ[inp] && inp =!= "" && FileExistsQ[inp],
      DirectoryName[inp],
      Directory[]
    ]
  ];
  canonicalFile = FileNameJoin[
    {packageDirectory, "HRF_AsymptoticOrderAlignment.wl"}
  ];
  If[Length[DownValues[hrfAsymptoticOrderAlignmentSearch]] == 0,
    Quiet @ Check[Get[canonicalFile], Null]
  ];

  canonicalNames = Names["Global`hrfAsymptoticOrderAlignment*"];
  Scan[
    Function[canonicalName,
      With[
        {
          canonical = Symbol[canonicalName],
          legacy = Symbol @ StringReplace[
            canonicalName,
            "hrfAsymptoticOrderAlignment" -> "hrfFacelift"
          ]
        },
        ClearAll[legacy];
        Options[legacy] = Options[canonical];
        legacy[args___] := canonical[args]
      ]
    ],
    canonicalNames
  ];
];
