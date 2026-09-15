$HistoryLength = 0;
path = FileNameJoin[{DirectoryName[$InputFileName],
  "SixPoint_WideAngle_SelfCrossing_HR_Audit.nb"}];
nb = Import[path, "Notebook"];
summary = If[Head[nb] === Notebook,
  <|
    "Head" -> Head[nb],
    "CellCount" -> Length[Cases[nb, _Cell, Infinity]],
    "InputCount" -> Length[Cases[nb, Cell[_, "Input", ___], Infinity]],
    "TitleCount" -> Length[Cases[nb, Cell[_, "Title", ___], Infinity]],
    "FailureCount" -> Length[Cases[nb, _Failure, Infinity]]
  |>,
  <|"Head" -> Head[nb], "ImportResult" -> nb|>
];
Print[InputForm[summary]];
If[Head[nb] === Notebook && summary["TitleCount"] == 1 &&
    summary["InputCount"] >= 1 && summary["FailureCount"] == 0,
  Exit[0], Exit[1]];
