(* Deprecated compatibility loader.  New code should load
   HRF_AsymptoticOrderAlignmentNotebookSmokeTests.wl and call
   hrfAsymptoticOrderAlignmentNotebookSmokeTests[]. *)

repoDirectory = DirectoryName[$InputFileName];
Get[FileNameJoin[{repoDirectory,
  "HRF_AsymptoticOrderAlignmentNotebookSmokeTests.wl"}]];

ClearAll[hrfSplitNotebookSmokeTests];
hrfSplitNotebookSmokeTests[] :=
  hrfAsymptoticOrderAlignmentNotebookSmokeTests[];
