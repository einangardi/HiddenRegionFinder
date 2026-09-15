$HistoryLength = 0;
base = DirectoryName[$InputFileName];
$HRF6SelfCrossingAuditLibraryOnly = True;
Get[FileNameJoin[{base, "HRF_SixPointWideAngleSelfCrossingAudit.wl"}]];
audit = hrf6SelfCrossingAudit[];

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

momentaRows = Map[
  <|"momentum" -> Subscript[p, #],
    "all-outgoing four-vector" -> audit["PhysicalKinematics",
      "AllOutgoingMomenta", #]|> &,
  {1, 2, 3, 4, 5, 6}
];

facetRows = {
  <|"chart" -> "t1 resolved", "local variables" ->
      audit["PhysicalExpansion", "ChartA", "LocalVariableOrder"],
    "normal" -> audit["PhysicalExpansion", "ChartA", "LocalNormal"],
    "leading points" -> audit["PhysicalExpansion", "ChartA",
      "FacetCertificate", "LeadingPointCount"],
    "affine rank" -> audit["PhysicalExpansion", "ChartA",
      "FacetCertificate", "AffineRank"],
    "lower facet" -> audit["PhysicalExpansion", "ChartA",
      "FacetCertificate", "LowerFacetCertifiedQ"]|>,
  <|"chart" -> "t2 resolved", "local variables" ->
      audit["PhysicalExpansion", "ChartB", "LocalVariableOrder"],
    "normal" -> audit["PhysicalExpansion", "ChartB", "LocalNormal"],
    "leading points" -> audit["PhysicalExpansion", "ChartB",
      "FacetCertificate", "LeadingPointCount"],
    "affine rank" -> audit["PhysicalExpansion", "ChartB",
      "FacetCertificate", "AffineRank"],
    "lower facet" -> audit["PhysicalExpansion", "ChartB",
      "FacetCertificate", "LowerFacetCertifiedQ"]|>
};

inheritanceRows = {
  <|"limit" -> "NMRK with w=z",
    "factor 1 identity" -> audit["Inheritance", "NMRKFactorIdentitiesQ"][[1]],
    "factor 2 identity" -> audit["Inheritance", "NMRKFactorIdentitiesQ"][[2]],
    "result" -> "aligned leading limits are L2^N and L1^N"|>,
  <|"limit" -> "double spacelike collinear",
    "factor 1 identity" -> audit["Inheritance", "DSCFactorIdentitiesQ"][[1]],
    "factor 2 identity" -> audit["Inheritance", "DSCFactorIdentitiesQ"][[2]],
    "result" -> "aligned leading limits are L2^D and L1^D"|>
};

summaryRows = {
  <|"test" -> "massless external momenta",
    "passed" -> audit["PhysicalKinematics", "AllMasslessQ"]|>,
  <|"test" -> "momentum conservation",
    "passed" -> audit["PhysicalKinematics", "MomentumConservationQ"]|>,
  <|"test" -> "physical self-crossing path",
    "passed" -> audit["PhysicalKinematics", "SelfCrossingPathQ"]|>,
  <|"test" -> "positive boundary stationary pinch",
    "passed" -> audit["BoundaryLandauLocus", "PositiveStationaryPinchQ"]|>,
  <|"test" -> "HRF discovers factors, generator and scaling",
    "passed" -> audit["CoreHRF", "HiddenRegionQ"]|>,
  <|"test" -> "both dissection charts are lower facets",
    "passed" -> audit["PhysicalExpansion", "BothDissectionChartsCertifiedQ"]|>,
  <|"test" -> "NMRK and DSC inherit the wide-angle factors",
    "passed" -> audit["Inheritance", "BothLimitsInheritWideAngleFactorsQ"]|>
};

nb = Notebook[{
  Cell["Six-point twisted hexagon: wide-angle self-crossing hidden region",
    "Title"],
  txt["This notebook tests whether the one-loop twisted-hexagon hidden regions found in NMRK with zero transverse recoil and in the double spacelike-collinear limit descend from a special wide-angle configuration. The answer is affirmative: the physical 2-to-4 self-crossing surface contains a boundary hidden region, and its two cancellation factors reduce exactly to the factors used in both composite limits."],

  sec["1. Reproducible setup"],
  inCell["$HRF6SelfCrossingAuditLibraryOnly=True; Get[FileNameJoin[{NotebookDirectory[],\"HRF_SixPointWideAngleSelfCrossingAudit.wl\"}]]; audit=hrf6SelfCrossingAudit[];"],
  outCell[readableTable[summaryRows]],

  sec["2. Exact physical self-crossing path"],
  txt["All momenta are outgoing. The cyclic ordering used by Dixon and Esterlis is (k1,...,k6)=(p3,p6,p1,p5,p4,p2), so p1 and p2 are incoming. The parameter beta is a transverse recoil and eta=beta^2 is the invariant expansion parameter. The fixed rational scattering angle is chosen only to provide a compact exact physical witness; it does not define the cancellation mechanism."],
  outCell[readableTable[momentaRows]],
  inCell["{audit[\"PhysicalKinematics\",\"MassShellValues\"],audit[\"PhysicalKinematics\",\"MomentumSum\"],audit[\"PhysicalKinematics\",\"CrossRatios\"]}"],
  outCell[{
    audit["PhysicalKinematics", "MassShellValues"],
    audit["PhysicalKinematics", "MomentumSum"],
    audit["PhysicalKinematics", "CrossRatios"]
  }],
  txt["The cross ratios obey v_A=w_A throughout the path, while u_A tends to one from the physical 2-to-4 region. At eta=0 all adjacent invariants remain finite and nonzero, so this is a genuinely wide-angle endpoint rather than a soft or collinear limit."],

  sec["3. Boundary Landau locus"],
  txt["The self-crossing pinches the box boundary obtained by contracting x0 and x3. Restricting the complete hexagon polynomial to this boundary gives"],
  displayCell[audit["BoundaryLandauLocus", "BoundaryPolynomial"]],
  txt["On u_A=s36 s45/(s145 s245)=1 it factorises exactly as"],
  displayCell[audit["BoundaryLandauLocus",
    "FactorizedBoundaryPolynomial"]],
  txt["In the physical 2-to-4 chamber s36 and s45 are positive while s145 and s245 are negative. Both linear factors therefore have positive zeros. At the exact rational witness x1=x2=x4=x5=1 the four active stationary equations vanish:"],
  outCell[audit["BoundaryLandauLocus",
    "BoundaryGradientAtPhysicalWitness"]],

  sec["4. Core HRF construction"],
  txt["At the exact physical endpoint HRF is given only the restricted polynomial, its active variables, the physical first lifting layer and U. No cancellation factor or generator is supplied. The derivative harvest and pairing stages return"],
  inCell["audit[\"CoreHRF\"]"],
  outCell[audit["CoreHRF"]],
  txt["Thus the active edge scaling is (-1,-1,-1,-1), the four monomials in the generator have W_SL=-2, and cancellation promotes their combined contribution to the physical layer W_HR=-1."],

  sec["5. Restricted-polynomial dissection and facet certificate"],
  txt["The boundary restriction x0=x3=0 is imposed before dissection, while restoring the contracted entries only for reporting gives the original-coordinate vector (x0,...,x5;1)=(0,-1,-1,0,-1,-1;1). Put t1=x1-x2 and t2=x5-x4. The two ordinary dissection charts resolve one normal at a time. The complete restricted LP polynomial through the first physical eta layer gives:"],
  outCell[readableTable[facetRows]],
  txt["Each chart has affine rank four, the rank required for a codimension-one lower facet in the five-dimensional augmented exponent space of the four active local variables and eta. Higher eta layers cannot undercut the facet because the LP polynomial is at most quadratic in the edge parameters. For unit propagator powers the scalar contribution scales as eta^(D/2-3)=eta^(-1-epsilon) in D=4-2 epsilon."],

  sec["6. Descent to the two six-point limits"],
  txt["The invariant wide-angle factors are"],
  displayCell[audit["Inheritance", "WideAngleFactors"]],
  txt["Substituting the exact NMRK chart, imposing w=z and applying its alignment vector gives the following leading expressions; their nonzero prefactors multiply precisely L2^N and L1^N:"],
  displayCell[audit["Inheritance", "NMRKLeadingFactors"]],
  txt["The same calculation in the double spacelike-collinear chart gives nonzero prefactors multiplying L2^D and L1^D:"],
  displayCell[audit["Inheritance", "DSCLeadingFactors"]],
  outCell[readableTable[inheritanceRows]],

  sec["7. Conclusion"],
  txt["The twisted hexagon has no hidden region at generic wide-angle kinematics, but it does have a boundary hidden region on the physical self-crossing surface u_A=1 with v_A=w_A. The zero-recoil NMRK and double spacelike-collinear factors are aligned degenerations of its two wide-angle cancellation factors. The appropriate organizing statement is therefore the same one already found at four and five points: a special wide-angle seed locus supplies cancellation geometry that persists under further kinematic specialization, while the total region vector remains expansion dependent."],
  txt["Reference: L. J. Dixon and I. Esterlis, All orders results for self-crossing Wilson loops mimicking double parton scattering, arXiv:1602.02107."]
}, WindowTitle -> "Six-point wide-angle self-crossing HR audit",
  StyleDefinitions -> "Default.nb"];

out = FileNameJoin[{base,
  "SixPoint_WideAngle_SelfCrossing_HR_Audit.nb"}];
saveNotebook[out, nb];
Print["Wrote ", out];
