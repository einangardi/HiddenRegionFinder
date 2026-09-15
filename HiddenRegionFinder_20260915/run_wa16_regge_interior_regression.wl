SetDirectory[DirectoryName[$InputFileName]];
$HRFRunWideAngle16NoCrownAuditOnLoad = False;
Get["HRF_WideAngle16ReggeInteriorRegressionTests.wl"];
result = hrfRunWA16ReggeInteriorRegressionTests[];
If[! DirectoryQ["results"], CreateDirectory["results"]];
Export["results/wa16_regge_interior_v1_regression.wl", result, "Package"];
Print[InputForm[result["Summary"]]];
If[result["Summary", "Failed"] > 0, Exit[1], Exit[0]];
