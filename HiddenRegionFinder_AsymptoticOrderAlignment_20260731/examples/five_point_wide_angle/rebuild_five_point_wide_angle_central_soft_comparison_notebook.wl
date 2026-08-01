$HistoryLength = 0;
base = DirectoryName[$InputFileName];
$HRF5ComparisonLibraryOnly = True;
Get[FileNameJoin[{base, "HRF_FivePointWideAngleCentralSoftComparison.wl"}]];
comparison = hrf5WideAngleCentralSoftComparison[];
wide = comparison["WideAngleCoplanarOnShell"];
mrk = comparison["CentralSoftMRK"];

ClearAll[txt, sec, subsec, displayCell, outCell, inCell, saveNotebook,
  readableTable, inlineValue];
txt[s_String] := Cell[s, "Text"];
sec[s_String] := Cell[s, "Section"];
subsec[s_String] := Cell[s, "Subsection"];
displayCell[expr_] := Cell[BoxData @ ToBoxes[TraditionalForm[expr]], "Output"];
outCell[expr_] := Cell[BoxData @ ToBoxes[expr], "Output"];
inCell[code_String] := Cell[
  BoxData @ ToExpression[code, InputForm, MakeBoxes], "Input"
];
inlineValue[value_] := If[ListQ[value] || AssociationQ[value],
  Style[ToString[value, InputForm, PageWidth -> Infinity],
    FontFamily -> "Source Code Pro"], value];
readableTable[rows_List] := Module[{headers, body},
  headers = DeleteDuplicates @ Flatten[Keys /@ rows];
  body = (inlineValue /@ Lookup[#, headers, ""]) & /@ rows;
  Grid[Prepend[body, Style[#, Bold] & /@ headers], Frame -> All,
    Alignment -> Left, Spacings -> {1.0, 0.65},
    Background -> {None, {RGBColor[0.94, 0.96, 0.99], None}}]
];
saveNotebook[path_, nb_] := If[$FrontEnd =!= Null,
  obj = NotebookPut[nb, Visible -> False]; NotebookSave[obj, path];
  NotebookClose[obj, SaveRemaining -> False],
  Export[path, nb, "Notebook"]
];

coeff = wide["PairProductCoefficients"];
aWA = Factor[coeff["y0 y2"]/x5];
bWA = Factor[-coeff["y0 y4"]/x3];
cWA = Factor[-coeff["y2 y4"]/x1];
fWASimple = aWA x5 y0 y2 - bWA x3 y0 y4 - cWA x1 y2 y4;

wideScalingRows = {
  <|"object" -> "original LP parameters (x0,...,x5)",
    "weight" -> "(-1,-1,-1,-1,-1,-1;1)"|>,
  <|"object" -> "internal coordinates (x1,x3,x5)",
    "weight" -> "(-1,-1,-1)"|>,
  <|"object" -> "symmetric normal coordinates (y0,y2,y4)",
    "weight" -> "(-1/2,-1/2,-1/2)"|>,
  <|"object" -> "raw F_SL", "weight" -> "W_SL=-3"|>,
  <|"object" -> "F_SL after cancellation; U; lambda F1",
    "weight" -> "W_HR=-2"|>
};

mrkLayerRows = KeyValueMap[
  <|"delta weight" -> #1, "coefficient polynomial" -> Factor[#2]|> &,
  KeyTake[mrk["TotalFLayers"], Range[-13, -8]]
];
mrkScalingRows = {
  <|"stage" -> "asymptotic-order alignment",
    "vector (x0,...,x5;1)" -> "(-3,-3,0,-3,-3,-3;1)"|>,
  <|"stage" -> "would-be HRF scaling in the aligned variables",
    "vector (x0,...,x5;1)" -> "(-1,-1,-1,-1,-1,-1;1)"|>,
  <|"stage" -> "rejected composed scaling in the original variables",
    "vector (x0,...,x5;1)" -> "(-4,-4,-1,-4,-4,-4;1)"|>,
  <|"stage" -> "raw superleading F layer", "vector (x0,...,x5;1)" -> "W=-13"|>,
  <|"stage" -> "first obstruction", "vector (x0,...,x5;1)" -> "W=-12"|>
};

comparisonRows = {
  <|"feature" -> "kinematic route to Gram zero",
    "wide-angle on-shell" -> "finite transverse momenta, w=wbar",
    "central-soft MRK" -> "p4_perp -> 0; w,wbar -> infinity"|>,
  <|"feature" -> "leading cancellation structure",
    "wide-angle on-shell" -> "quadratic form in three linear normal coordinates",
    "central-soft MRK" -> "leading product, immediately obstructed at the next layer"|>,
  <|"feature" -> "LP-parameter vector",
    "wide-angle on-shell" -> "uniform (-1,-1,-1,-1,-1,-1;1)",
    "central-soft MRK" -> "previous nonuniform candidate is rejected"|>,
  <|"feature" -> "cancellation hierarchy",
    "wide-angle on-shell" -> "one gap: -3 -> -2",
    "central-soft MRK" -> "-13 leading product; nonzero obstruction at -12"|>
};

lightConeVariableRows = {
  <|"symbol" -> "P", "definition" -> "p3+ = P delta^(-b)",
    "meaning" -> "upper-jet longitudinal normalization"|>,
  <|"symbol" -> "K", "definition" -> "p4+ = K delta^a",
    "meaning" -> "central-emission longitudinal normalization"|>,
  <|"symbol" -> "M", "definition" -> "p5- = M delta^(-b)",
    "meaning" -> "lower-jet longitudinal normalization"|>,
  <|"symbol" -> "T", "definition" -> "|p3_perp|^2 = T",
    "meaning" -> "fixed upper transverse scale"|>,
  <|"symbol" -> "R", "definition" -> "|p4_perp|^2 = R delta^(2a)",
    "meaning" -> "rescaled central transverse scale"|>,
  <|"symbol" -> "C", "definition" -> "2 Re(p3_perp conjugate(k_perp)) = C",
    "meaning" -> "transverse interference; C^2 <= 4 T R"|>
};

mrkPaperVariableRows = {
  <|"paper variable" -> "x", "invariants" -> "s12=s/x^2",
    "central-soft scaling" -> "x=delta^b"|>,
  <|"paper variable" -> "s", "invariants" -> "hard energy coefficient",
    "central-soft scaling" -> "s=P M"|>,
  <|"paper variable" -> "s1", "invariants" -> "s45=s1/x",
    "central-soft scaling" -> "s1=K M delta^a"|>,
  <|"paper variable" -> "s2", "invariants" -> "s34=s2/x",
    "central-soft scaling" -> "s2=(P R/K) delta^a"|>,
  <|"paper variable" -> "t1", "invariants" -> "t1=s15",
    "central-soft scaling" -> "t1=-T-C delta^a-R delta^(2a)+..."|>,
  <|"paper variable" -> "t2", "invariants" -> "t2=s23",
    "central-soft scaling" -> "t2=-T+..."|>,
  <|"paper variable" -> "z,zbar", "invariants" ->
      "t1=-(1-z)(1-zbar)s1 s2/s; t2=-z zbar s1 s2/s",
    "central-soft scaling" -> "z=Z delta^(-a), zbar=Zbar delta^(-a)"|>
};

nb = Notebook[{
  Cell["Five-point seed: wide-angle Landshoff versus central-soft MRK",
    "Title"],
  txt["This notebook compares the F polynomial for the same two-loop six-propagator graph and the same external attachment order {1,2,3,5,4}. It separates the exact coplanar wide-angle on-shell expansion from the central-soft MRK composite expansion. Every region vector is displayed in the convention (v_x0,...,v_x5;1)."],

  sec["1. Reproducible setup"],
  inCell["$HRF5ComparisonLibraryOnly=True; Get[FileNameJoin[{NotebookDirectory[],\"HRF_FivePointWideAngleCentralSoftComparison.wl\"}]]; comparison=hrf5WideAngleCentralSoftComparison[];"],
  txt["The graph has internal edges x0:(1,3), x1:(1,5), x2:(2,3), x3:(2,5), x4:(3,4), x5:(4,5). External momenta are attached to vertices in the order {1,2,3,5,4}; this is the representative attachment that has the central-soft MRK hidden region."],

  sec["2. Common exact transverse chart"],
  txt["Use p3_perp=q, p4_perp=k and p5_perp=-q-k, with w=-p3_perp/p4_perp and wbar=-conjugate(p3_perp)/conjugate(p4_perp). The exact wide-angle coplanar branch has finite nonzero q and k with w=wbar=-q/k. The central-soft MRK limit instead sends k to zero, so w and wbar become large."],
  subsec["2.1 Exact light-cone coefficients used below"],
  outCell[readableTable[lightConeVariableRows]],
  txt["All P,K,M,R,T are positive. The sign of C records the relative transverse orientation; in a general physical configuration it obeys the transverse Cauchy-Schwarz bound."],
  subsec["2.2 Relation to the variables of the NNLL 2-to-3 MRK paper"],
  txt["The paper fixes {s,s1,s2,t1,t2}, or equivalently {s,s1,s2,z,zbar}, and varies the auxiliary parameter x. The central-soft limit is a composite path rather than ordinary MRK at fixed s1,s2,z,zbar:"],
  outCell[readableTable[mrkPaperVariableRows]],
  txt["The finite rescaled variables satisfy Z Zbar=T/R and Z+Zbar=-C/R. The exact transverse variables used later in that paper are w=-p3_perp/p4_perp, wbar=-conjugate(p3_perp)/conjugate(p4_perp), X34=p3+/p4+, and X45=p4+/p5+, together with one dimensionful transverse scale. Along the central-soft path, w~delta^(-a), X34~delta^(-(a+b)), and X45~delta^(a-b)."],

  sec["3. Coplanar wide-angle on-shell expansion"],
  txt["Here p_i^2=lambda tends to zero while all adjacent invariants remain wide-angle and the massless endpoint satisfies Gram=0. The polynomial is F=F0+lambda F1. With all x_e scaling as lambda^(-1), F0 has raw weight -3, whereas U and lambda F1 have weight -2."],
  subsec["3.1 Positive Landau locus and local coordinates"],
  txt["The following replacement rules define three normal coordinates y0,y2,y4 around the positive Landau locus. The remaining x1,x3,x5 are internal coordinates along it."],
  displayCell[wide["LocalCoordinateRules"]],
  subsec["3.2 Exact factorised superleading sector"],
  txt["In these coordinates the constant and linear terms vanish identically. There is also no cubic normal-coordinate term. The complete F_SL=F0 is the quadratic form"],
  displayCell[fWASimple],
  txt["where all three coefficient functions below are positive for positive light-cone data:"],
  outCell[readableTable[{
    <|"coefficient" -> AWA, "value" -> aWA|>,
    <|"coefficient" -> BWA, "value" -> bWA|>,
    <|"coefficient" -> CWA, "value" -> cWA|>
  }]],
  subsec["3.3 Scaling"],
  outCell[readableTable[wideScalingRows]],
  txt["The symmetric local presentation has y0,y2,y4 proportional to lambda^(-1/2). Each term x_i y_j y_k in F_SL therefore has weight -2, exactly matching U and lambda F1. The original-variable HR vector remains the uniform vector; the half-integer weights refer only to the dissected local normal coordinates."],

  sec["4. Central-soft MRK expansion"],
  txt["For the representative path p4_perp~delta and x_MRK~delta^2, asymptotic-order alignment produces the first vector below. The later vectors were previously reported as an HRF composition, but the next-layer audit below shows that they must be rejected."],
  outCell[readableTable[mrkScalingRows]],
  subsec["4.1 The aligned leading factorisation"],
  displayCell[mrk["LeadingAlignedFactorization"]],
  txt["At the leading aligned level the candidate locus is simultaneous: P x2-K x3=0 and x1 x4-x0 x5=0. It is not a union of coordinate boundaries. This leading statement alone is insufficient because the next aligned layer must also be examined."],
  subsec["4.2 The full sequence of F layers"],
  txt["After applying the would-be composed vector, the layers beginning at the raw superleading weight -13 are:"],
  outCell[readableTable[mrkLayerRows]],
  txt["The delta^(-12) coefficient is -T x0 x3 x4. It does not vanish on the two-factor locus and is strictly nonzero for T,x0,x3,x4>0. It is therefore a genuine obstruction, not a harmless deformation that may be skipped."],
  subsec["4.3 Positive-stationarity test after alignment"],
  displayCell[mrk["CombinedFirstTwoAlignedLayers"]],
  txt["The derivatives with respect to x1 and x2 force P x2-K x3=0 and x1 x4-x0 x5=0. After imposing these, the x0 derivative reduces to -T x3 x4, which cannot vanish in the positive interior. Hence the combined first two aligned layers have no positive stationary pinch. The previously reported vector (-4,-4,-1,-4,-4,-4;1) is rejected."],

  sec["5. Structural comparison"],
  outCell[readableTable[comparisonRows]],
  txt["The coplanar wide-angle on-shell region remains an exact positive Landau region. By contrast, the previously reported central-soft MRK candidate fails at the first obstruction after asymptotic-order alignment. Before drawing a wide-angle-to-MRK correspondence at five points, the remaining attachment orders and possible alternative scalings must be re-audited with this obstruction test enforced."]
}, WindowTitle -> "Five-point wide-angle and central-soft F comparison",
  StyleDefinitions -> "Default.nb"];

out = FileNameJoin[{base, "FivePoint_WideAngle_CentralSoft_F_Comparison.nb"}];
saveNotebook[out, nb];
Print["Wrote ", out];
