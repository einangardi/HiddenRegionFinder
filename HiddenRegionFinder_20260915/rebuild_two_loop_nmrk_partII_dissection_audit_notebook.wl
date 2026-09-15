(* Rebuild an evaluated notebook auditing one two-loop six-point NMRK w=z
   topology with the current source-aware dissection.  Set
   $HRFPartIIAuditGraphName before loading this file to select a topology. *)

$HistoryLength = 0;
$HRFQuietReports = True;
$hrfPartIIAuditDirectory = DirectoryName[$InputFileName];
SetDirectory[$hrfPartIIAuditDirectory];

Get["HiddenRegionFinder.wl"];
Get["HRF_AsymptoticOrderAlignment.wl"];

ClearAll[
  hrfPartIIWZTransform, hrfPartIIScalingVector, hrfPartIIScalefulQ,
  hrfPartIIBoundaryKey, hrfPartIIIdealKey, hrfPartIIVectorKey,
  hrfPartIIHRKey, hrfPartIIRegionKey, hrfPartIIFactorKey,
  hrfPartIIGeneratorKey,
  hrfPartIIGeneratorKeyForCandidate, hrfPartIIInputCell, hrfPartIIOutputCell,
  hrfPartIITextCell, hrfPartIISection, hrfPartIIGrid,
  hrfPartIIPositivePinchObstruction
];

(* The same exact w=z coefficient chart used by the saved NMRK audit. *)
hrfPartIIWZTransform[p_] := Module[{q},
  q = Factor[p /. {q1*q1b -> Q, q1b*q1 -> Q}];
  q = q /. {
    (1 - z)*(1 - zb) -> Kz, (1 - zb)*(1 - z) -> Kz,
    (-1 + z)*(-1 + zb) -> Kz, (-1 + zb)*(-1 + z) -> Kz
  };
  q = Expand[q] /. {
    z*zb -> Kz + z + zb - 1,
    zb*z -> Kz + z + zb - 1,
    1 - z - zb + z*zb -> Kz,
    1 - zb - z + z*zb -> Kz,
    z*zb - z - zb + 1 -> Kz
  };
  Factor[q]
];

auditGraphName = If[
  ValueQ[$HRFPartIIAuditGraphName], $HRFPartIIAuditGraphName,
  "planar-hexbox"
];
graphSpecs = <|
  "planar-hexbox" -> {
    {"0", {5, 6}}, {"0", {1, 8}}, {"0", {8, 6}},
    {"0", {1, 2}}, {"0", {2, 3}}, {"0", {3, 4}},
    {"0", {4, 7}}, {"0", {7, 5}}, {"0", {7, 8}}
  },
  "nonplanar-hexbox" -> {
    {"0", {5, 8}}, {"0", {1, 8}}, {"0", {1, 2}},
    {"0", {2, 3}}, {"0", {7, 3}}, {"0", {7, 5}},
    {"0", {4, 7}}, {"0", {6, 8}}, {"0", {4, 6}}
  },
  "hexagon-pentagon" -> {
    {"0", {5, 6}}, {"0", {1, 8}}, {"0", {8, 6}},
    {"0", {1, 3}}, {"0", {3, 4}}, {"0", {4, 7}},
    {"0", {7, 5}}, {"0", {7, 2}}, {"0", {8, 2}}
  }
|>;
graphDisplayNames = <|
  "planar-hexbox" -> "planar hexagon--box",
  "nonplanar-hexbox" ->
    "same-path hexagon--pentagon (legacy key nonplanar-hexbox)",
  "hexagon-pentagon" ->
    "separate-path hexagon--pentagon (legacy key hexagon-pentagon)"
|>;
expectedCandidateCounts = <|
  "planar-hexbox" -> 13,
  "nonplanar-hexbox" -> 8,
  "hexagon-pentagon" -> 0
|>;
previousTableCounts = <|
  "planar-hexbox" -> {7, 4, 3},
  "nonplanar-hexbox" -> {3, 1, 2},
  "hexagon-pentagon" -> {0, 0, 0}
|>;
outputStems = <|
  "planar-hexbox" -> {
    "09_TwoLoop_NMRK_wz_PartII_Dissection_Audit.nb",
    "partII_dissection_13_candidate_audit.wl"
  },
  "nonplanar-hexbox" -> {
    "10_TwoLoop_NMRK_wz_SamePath_HexagonPentagon_PartII_Audit.nb",
    "partII_dissection_same_path_hexagon_pentagon_audit.wl"
  },
  "hexagon-pentagon" -> {
    "11_TwoLoop_NMRK_wz_SeparatePath_HexagonPentagon_PartII_Audit.nb",
    "partII_dissection_separate_path_hexagon_pentagon_audit.wl"
  }
|>;

If[! KeyExistsQ[graphSpecs, auditGraphName],
  Print["Unknown graph key: ", auditGraphName];
  Exit[2]
];

graphDisplayName = graphDisplayNames[auditGraphName];
expectedCandidateCount = expectedCandidateCounts[auditGraphName];
{previousTableCount, previousTableInteriorCount,
  previousTableBoundaryCount} = previousTableCounts[auditGraphName];
{outputNotebookFile, outputResultFile} = outputStems[auditGraphName];
internalLines = graphSpecs[auditGraphName];
externalLines = {
  {p1, 1}, {p2, 4}, {p3, 5}, {p4, 3}, {p5, 2}, {p6, 6}
};
graphU = SymanzikUF[internalLines, externalLines]["U"];

savedScan = Import[
  "results/nmrk_wz/full_wz_" <> auditGraphName <> ".wl", "WL"
];
masterVariables = savedScan["Variables"];
termData = savedScan["TermData"];
etaSymbol = savedScan["EtaSymbol"];
candidateRows = savedScan["StagedDeduplicatedHiddenRegionRows"];

If[Length[candidateRows] =!= expectedCandidateCount,
  Print["Expected ", expectedCandidateCount,
    " staged structural candidates, found ",
    Length[candidateRows]];
  Exit[1]
];

(* These caps exhaust the present staged-candidate samples.  Completeness
   is nevertheless recorded candidate by candidate rather than assumed. *)
dissectionOptions = {
  "MaxPivotChoices" -> 64,
  "MaxSolveBranches" -> 16,
  "MaxSignSectors" -> 64,
  "MaxPointCount" -> 20000,
  "SolveTimeLimit" -> 60,
  "CDDTimeLimit" -> 120
};

(* An exact early rejection: if the common cancellation ideal contains a
   nonzero monomial in active positive LP variables, the factors cannot
   vanish simultaneously in the interior of the selected stratum. *)
hrfPartIIPositivePinchObstruction[row_Association] := Module[
  {zeroVars, activeVars, factors, basis, assumptions},
  zeroVars = Lookup[row, "PreselectionZeroVars", {}];
  activeVars = Complement[masterVariables, zeroVars];
  factors = Lookup[Lookup[row, "HRFSummary", <||>],
    "CancellationFactors", {}];
  factors = hrfPartIIWZTransform[
      Expand[# /. Thread[zeroVars -> 0]]
    ] & /@ factors;
  basis = GroebnerBasis[factors, activeVars,
    MonomialOrder -> Lexicographic];
  assumptions = Q > 0 && X34h > 0 && X45 > 0 && X56h > 0 && Kz > 0;
  SelectFirst[
    basis,
    Function[p,
      Module[{terms, coefficient},
        terms = MonomialList[p, activeVars];
        If[Length[terms] =!= 1, Return[False]];
        coefficient = terms[[1]] / Times @@ MapThread[
          Power, {activeVars, Exponent[terms[[1]], #] & /@ activeVars}
        ];
        TrueQ[FullSimplify[coefficient != 0, assumptions]]
      ]
    ],
    Missing["NoPositiveMonomialObstruction"]
  ]
];

candidateAudits = MapIndexed[
  Function[{row, index},
    Module[{old, audit, factors, zeroVars, checks, obstruction},
      Print["[Part-II dissection audit] ", auditGraphName, " candidate ",
        First[index], "/", expectedCandidateCount];
      old = Lookup[row, "TotalScalingAudit", <||>];
      factors = Lookup[Lookup[row, "HRFSummary", <||>],
        "CancellationFactors", {}];
      zeroVars = Lookup[row, "PreselectionZeroVars", {}];
      obstruction = hrfPartIIPositivePinchObstruction[row];
      audit = If[MissingQ[obstruction],
        hrfSourceAwareAlignedDissectionCertificate[
          row, termData, masterVariables, graphU, etaSymbol,
          hrfPartIIWZTransform, Sequence @@ dissectionOptions
        ],
        <|
          "CertificationStatus" -> "RejectedNoPositiveCommonPinch",
          "CertifiedQ" -> False,
          "DistinctCertifiedRegionCount" -> 0,
          "SearchCompleteQ" -> True,
          "SearchTruncatedQ" -> False,
          "PositivePinchObstruction" -> obstruction,
          "Certificates" -> {}
        |>
      ];
      checks = Lookup[Lookup[audit, "Certificates", {}],
        "PullbackChecks", {}];
      <|
        "Candidate" -> First[index],
        "BoundaryZeroVariables" -> zeroVars,
        "FaceScaling" -> Lookup[row, "Scaling", Missing[]],
        "CancellationFactors" -> factors,
        "ProvisionalStatus" -> Lookup[old, "AuditStatus", Missing[]],
        "ProvisionalTotalScaling" -> Lookup[old, "TotalScaling", <||>],
        "ProvisionalWSL" -> Lookup[old, "WSL", Missing[]],
        "ProvisionalWHR" -> Lookup[old, "WHR", Missing[]],
        "ProvisionalGap" -> Lookup[old, "HierarchyGap", Missing[]],
        "ProvisionalResolvedRank" ->
          Lookup[old, "ResolvedWHRAffineRank", Missing[]],
        "RequiredFacetRank" -> Lookup[old, "RequiredFacetRank", Missing[]],
        "CertificationStatus" ->
          Lookup[audit, "CertificationStatus", Missing[]],
        "PositivePinchObstruction" ->
          Lookup[audit, "PositivePinchObstruction", Missing[]],
        "CertifiedQ" -> Lookup[audit, "CertifiedQ", False],
        "CertifiedRegionCount" ->
          Lookup[audit, "DistinctCertifiedRegionCount", 0],
        "SearchCompleteQ" -> Lookup[audit, "SearchCompleteQ", False],
        "SearchTruncatedQ" -> Lookup[audit, "SearchTruncatedQ", False],
        "PivotCoverage" -> {
          Lookup[audit, "PivotChoiceCount", 0],
          Lookup[audit, "TotalPivotChoiceCount", 0]
        },
        "SignSectorCoverage" -> {
          Lookup[audit, "SignSectorCount", 0],
          Lookup[audit, "TotalSignSectorCount", 0]
        },
        "SolveBranchTruncatedQ" ->
          Lookup[audit, "SolveBranchTruncatedQ", False],
        "ChartStatusCounts" ->
          Counts @ Cases[
            Lookup[audit, "ChartAudits", {}],
            a_Association :> Lookup[a, "ChartStatus", "Missing"]
          ],
        "AllReturnedCertificatesScalefulQ" ->
          (checks =!= {} && And @@ Map[
            TrueQ[Lookup[#, "ExactLowerFacetQ", False]] &&
            TrueQ[Lookup[#, "CompleteFacetRankQ", False]] &&
            TrueQ[Lookup[#, "HiddenHierarchyQ", False]] &&
            TrueQ[Lookup[#, "PositiveTransverseSuppressionsQ", False]] &,
            checks
          ]),
        "Certificates" -> Lookup[audit, "Certificates", {}]
      |>
    ]
  ],
  candidateRows
];

hrfPartIIScalingVector[assoc_Association] :=
  Lookup[assoc, masterVariables, "boundary"];

hrfPartIIScalefulQ[certificate_Association] := Module[{checks},
  checks = Lookup[certificate, "PullbackChecks", <||>];
  TrueQ[Lookup[checks, "ExactLowerFacetQ", False]] &&
  TrueQ[Lookup[checks, "CompleteFacetRankQ", False]] &&
  TrueQ[Lookup[checks, "HiddenHierarchyQ", False]] &&
  TrueQ[Lookup[checks, "PositiveTransverseSuppressionsQ", False]]
];

certificateRecords = Flatten @ Map[
  Function[candidate,
    MapIndexed[
      Function[{certificate, index},
        <|
          "Candidate" -> candidate["Candidate"],
          "LocalFacet" -> First[index],
          "BoundaryZeroVariables" ->
            candidate["BoundaryZeroVariables"],
          "CancellationFactors" -> candidate["CancellationFactors"],
          "PullbackScaling" -> certificate["PullbackScaling"],
          "PullbackVector" ->
            hrfPartIIScalingVector[certificate["PullbackScaling"]],
          "WSL" -> Lookup[certificate, "WSL", Missing[]],
          "WHR" -> Lookup[certificate, "ResolvedLeadingWeight", Missing[]],
          "CancellationDepth" ->
            Lookup[certificate, "CancellationDepth", Missing[]],
          "TransverseSuppressions" ->
            Lookup[certificate, "TransverseSuppressions", <||>],
          "LeadingFacetSourceCounts" ->
            Lookup[certificate, "LeadingFacetSourceCounts", <||>],
          "ScalefulQ" -> hrfPartIIScalefulQ[certificate],
          "PullbackChecks" -> Lookup[certificate, "PullbackChecks", <||>]
        |>
      ],
      candidate["Certificates"]
    ]
  ],
  candidateAudits
];

hrfPartIIBoundaryKey[zeroVars_List] :=
  Sort[ToString[InputForm[#]] & /@ zeroVars];

(* The Groebner-basis key compares the local cancellation ideals exactly in
   the active LP variables.  Kinematic symbols remain coefficient parameters. *)
hrfPartIIIdealKey[factors_List, zeroVars_List] := Module[
  {active, restricted, basis},
  active = Complement[masterVariables, zeroVars];
  restricted = DeleteCases[
    Together[Expand[# /. Thread[zeroVars -> 0]]] & /@ factors,
    0
  ];
  basis = GroebnerBasis[restricted, active, MonomialOrder -> Lexicographic];
  Sort[hrfAsymptoticOrderAlignmentCanonicalPolynomialKey[#, active] & /@ basis]
];

hrfPartIIVectorKey[record_Association] := {
  hrfPartIIBoundaryKey[record["BoundaryZeroVariables"]],
  ToString[InputForm[KeySort[record["PullbackScaling"]]]]
};

(* Physical HR equivalence used for the Table-8 audit: same stratum, exact
   pinch ideal, normalised pullback vector and W_HR.  W_SL is retained below
   only to diagnose distinct Part-I/alignment presentations of the same HR. *)
hrfPartIIHRKey[record_Association] := {
  hrfPartIIVectorKey[record],
  hrfPartIIIdealKey[
    record["CancellationFactors"], record["BoundaryZeroVariables"]
  ],
  record["WHR"]
};

(* Strict certificate-presentation equivalence additionally resolves W_SL. *)
hrfPartIIRegionKey[record_Association] := {
  hrfPartIIHRKey[record],
  record["WSL"]
};

hrfPartIIFactorKey[factor_] :=
  hrfAsymptoticOrderAlignmentCanonicalPolynomialKey[
    factor, masterVariables
  ];

hrfPartIIGeneratorKey[generator_] :=
  hrfAsymptoticOrderAlignmentCanonicalPolynomialKey[
    Expand[generator], masterVariables
  ];

hrfPartIIGeneratorKeyForCandidate[index_Integer] :=
  hrfPartIIGeneratorKey @ First @ Lookup[
    Lookup[candidateRows[[index]], "HRFSummary", <||>],
    "Generators", {}
  ];

vectorGroups = GatherBy[certificateRecords, hrfPartIIVectorKey];
physicalHRGroups = GatherBy[certificateRecords, hrfPartIIHRKey];
regionGroups = GatherBy[certificateRecords, hrfPartIIRegionKey];

factorRecords = Flatten @ MapIndexed[
  Function[{row, index},
    Map[
      <|"Candidate" -> First[index], "Factor" -> #,
        "FactorKey" -> hrfPartIIFactorKey[#]|> &,
      Lookup[Lookup[row, "HRFSummary", <||>],
        "CancellationFactors", {}]
    ]
  ],
  candidateRows
];
factorGroups = GatherBy[factorRecords, #["FactorKey"] &];
factorClassRows = MapIndexed[
  Function[{group, index},
    <|
      "FactorFamily" -> First[index],
      "CancellationFactor" -> First[group]["Factor"],
      "Candidates" -> DeleteDuplicates[group[[All, "Candidate"]]]
    |>
  ],
  factorGroups
];

generatorRecords = MapIndexed[
  Function[{row, index},
    Module[{summary, generator},
      summary = Lookup[row, "HRFSummary", <||>];
      generator = First @ Lookup[summary, "Generators", {}];
      <|
        "Candidate" -> First[index],
        "Factors" -> Lookup[summary, "CancellationFactors", {}],
        "Generator" -> generator,
        "GeneratorKey" -> hrfPartIIGeneratorKey[generator]
      |>
    ]
  ],
  candidateRows
];
generatorGroups = GatherBy[generatorRecords, #["GeneratorKey"] &];

generatorClassRows = MapIndexed[
  Function[{group, index},
    Module[{candidates, records, groups},
      candidates = group[[All, "Candidate"]];
      records = Select[certificateRecords,
        MemberQ[candidates, #["Candidate"]] &];
      groups = GatherBy[records, hrfPartIIVectorKey];
      <|
        "GeneratorFamily" -> First[index],
        "CancellationFactorPair" -> First[group]["Factors"],
        "Generator" -> First[group]["Generator"],
        "Candidates" -> candidates,
        "DistinctPullbackVectors" -> Length[groups],
        "InteriorVectors" -> Count[groups,
          g_ /; First[g]["BoundaryZeroVariables"] === {}],
        "CodimensionOneVectors" -> Count[groups,
          g_ /; Length[First[g]["BoundaryZeroVariables"]] == 1]
      |>
    ]
  ],
  generatorGroups
];

vectorGeneratorMultiplicity = Map[
  Length @ DeleteDuplicates[
    hrfPartIIGeneratorKeyForCandidate /@ #[[All, "Candidate"]]
  ] &,
  vectorGroups
];

(* A boundary HR is an exact restriction of an interior HR when the
   pullback scaling, cancellation ideal and W_HR agree after setting the
   contracted parameter to zero.  W_SL is presentation bookkeeping. *)
boundaryInteriorPresentationPairs = Flatten[
  Table[
    Module[{zero, active, boundaryActiveScaling},
      zero = First[boundary["BoundaryZeroVariables"]];
      active = Complement[masterVariables, {zero}];
      boundaryActiveScaling = KeyTake[boundary["PullbackScaling"], active];
      Map[
        <|
          "BoundaryCandidateFacet" ->
            {boundary["Candidate"], boundary["LocalFacet"]},
          "ContractedVariable" -> zero,
          "InteriorCandidateFacet" -> {#["Candidate"], #["LocalFacet"]},
          "BoundaryVector" -> boundary["PullbackVector"],
          "BoundaryHRKey" -> hrfPartIIHRKey[boundary],
          "WHR" -> boundary["WHR"]
        |> &,
        Select[certificateRecords,
          #["BoundaryZeroVariables"] === {} &&
          KeyTake[#["PullbackScaling"], active] === boundaryActiveScaling &&
          hrfPartIIIdealKey[#["CancellationFactors"], {zero}] ===
            hrfPartIIIdealKey[boundary["CancellationFactors"], {zero}] &&
          #["WHR"] === boundary["WHR"] &
        ]
      ]
    ],
    {boundary, Select[certificateRecords,
      Length[#["BoundaryZeroVariables"]] == 1 &]}
  ],
  1
];

boundaryInteriorVectorRows = Map[
  Function[group,
    <|
      "ContractedVariable" -> First[group]["ContractedVariable"],
      "BoundaryVector" -> First[group]["BoundaryVector"],
      "WHR" -> First[group]["WHR"],
      "BoundaryPresentations" ->
        DeleteDuplicates[group[[All, "BoundaryCandidateFacet"]]],
      "InteriorExtensions" ->
        DeleteDuplicates[group[[All, "InteriorCandidateFacet"]]]
    |>
  ],
  GatherBy[boundaryInteriorPresentationPairs,
    #["BoundaryHRKey"] &]
];

physicalHRRows = MapIndexed[
  Function[{group, index},
    <|
      "HR" -> First[index],
      "BoundaryZeroVariables" -> First[group]["BoundaryZeroVariables"],
      "PullbackVector" -> First[group]["PullbackVector"],
      "WHR" -> First[group]["WHR"],
      "WSLPresentations" -> DeleteDuplicates[group[[All, "WSL"]]],
      "CancellationDepthPresentations" ->
        DeleteDuplicates[group[[All, "CancellationDepth"]]],
      "SourcePresentations" ->
        ({#["Candidate"], #["LocalFacet"]} & /@ group),
      "PresentationMultiplicity" -> Length[group],
      "ScalefulQ" -> And @@ Lookup[group, "ScalefulQ", False]
    |>
  ],
  physicalHRGroups
];
presentationSplitRows = Select[
  physicalHRRows,
  Length[#["WSLPresentations"]] > 1 ||
    Length[#["CancellationDepthPresentations"]] > 1 &
];

regionGroupRows = MapIndexed[
  Function[{group, index},
    <|
      "Region" -> First[index],
      "BoundaryZeroVariables" -> First[group]["BoundaryZeroVariables"],
      "PullbackVector" -> First[group]["PullbackVector"],
      "WSL" -> First[group]["WSL"],
      "WHR" -> First[group]["WHR"],
      "CancellationDepth" -> First[group]["CancellationDepth"],
      "SourcePresentations" ->
        ({#["Candidate"], #["LocalFacet"]} & /@ group),
      "PresentationMultiplicity" -> Length[group],
      "ScalefulQ" -> And @@ Lookup[group, "ScalefulQ", False]
    |>
  ],
  regionGroups
];

vectorCollisionRows = MapIndexed[
  Function[{group, index},
    <|
      "VectorClass" -> First[index],
      "BoundaryZeroVariables" -> First[group]["BoundaryZeroVariables"],
      "PullbackVector" -> First[group]["PullbackVector"],
      "CertificatePresentations" ->
        ({#["Candidate"], #["LocalFacet"]} & /@ group),
      "CertificateMultiplicity" -> Length[group],
      "DistinctPinchAndWeightClasses" ->
        Length[DeleteDuplicates[hrfPartIIHRKey /@ group]],
      "DistinctStrictPresentationClasses" ->
        Length[DeleteDuplicates[hrfPartIIRegionKey /@ group]]
    |>
  ],
  Select[vectorGroups, Length[#] > 1 &]
];

auditSummary = <|
  "StagedCandidateCount" -> Length[candidateRows],
  "CandidatesWithAtLeastOneCertificate" ->
    Count[candidateAudits, a_ /; TrueQ[a["CertifiedQ"]]],
  "CandidatesWithCompleteSearch" ->
    Count[candidateAudits, a_ /; TrueQ[a["SearchCompleteQ"]]],
  "AllCandidateSearchesCompleteQ" ->
    AllTrue[candidateAudits, TrueQ[#["SearchCompleteQ"]] &],
  "AllCertificatesScalefulQ" ->
    AllTrue[certificateRecords, TrueQ[#["ScalefulQ"]] &],
  "RawCertificateCount" -> Length[certificateRecords],
  "DistinctPullbackVectorCount" -> Length[vectorGroups],
  "InteriorDistinctPullbackVectorCount" ->
    Count[vectorGroups,
      group_ /; First[group]["BoundaryZeroVariables"] === {}],
  "CodimensionOneDistinctPullbackVectorCount" ->
    Count[vectorGroups,
      group_ /; Length[First[group]["BoundaryZeroVariables"]] == 1],
  "VectorClassesWithMultiplePresentations" ->
    Count[vectorGroups, group_ /; Length[group] > 1],
  "DistinctPhysicalHRCount" -> Length[physicalHRGroups],
  "InteriorPhysicalHRCount" ->
    Count[physicalHRGroups,
      group_ /; First[group]["BoundaryZeroVariables"] === {}],
  "CodimensionOnePhysicalHRCount" ->
    Count[physicalHRGroups,
      group_ /; Length[First[group]["BoundaryZeroVariables"]] == 1],
  "DistinctCancellationFactorCount" -> Length[factorGroups],
  "DistinctGeneratorCount" -> Length[generatorGroups],
  "PullbackVectorsSharedAcrossGeneratorFamilies" ->
    Count[vectorGeneratorMultiplicity, n_ /; n > 1],
  "BoundaryVectorsWithInteriorExtension" ->
    Length[boundaryInteriorVectorRows],
  "BoundaryVectorsWithoutInteriorExtension" ->
    Count[physicalHRGroups,
      group_ /; Length[First[group]["BoundaryZeroVariables"]] == 1] -
      Length[boundaryInteriorVectorRows],
  "StrictCertificatePresentationCount" -> Length[regionGroups],
  "DistinctPinchIdealAndWeightRegionCount" -> Length[regionGroups],
  "InteriorCertifiedRegionCount" ->
    Count[regionGroupRows, r_ /; r["BoundaryZeroVariables"] === {}],
  "CodimensionOneCertifiedRegionCount" ->
    Count[regionGroupRows, r_ /; Length[r["BoundaryZeroVariables"]] == 1],
  "RegionClassesWithMultiplePresentations" ->
    Count[regionGroupRows, r_ /; r["PresentationMultiplicity"] > 1],
  "PreviousTableCount" -> previousTableCount,
  "PreviousTableInteriorCount" -> previousTableInteriorCount,
  "PreviousTableBoundaryCount" -> previousTableBoundaryCount,
  "CountAgreesWithPreviousTableQ" ->
    (Length[physicalHRGroups] == previousTableCount &&
      Count[physicalHRGroups,
        group_ /; First[group]["BoundaryZeroVariables"] === {}] ==
          previousTableInteriorCount &&
      Count[physicalHRGroups,
        group_ /; Length[First[group]["BoundaryZeroVariables"]] == 1] ==
          previousTableBoundaryCount)
|>;

compactCandidateRows = Map[
  <|
    "candidate" -> #["Candidate"],
    "boundary" -> #["BoundaryZeroVariables"],
    "face scaling" -> #["FaceScaling"],
    "cancellation factors" -> #["CancellationFactors"],
    "old status" -> #["ProvisionalStatus"],
    "old rank/required" -> {
      #["ProvisionalResolvedRank"], #["RequiredFacetRank"]
    },
    "old gap" -> #["ProvisionalGap"],
    "positive-pinch obstruction" -> #["PositivePinchObstruction"],
    "certified facets" -> #["CertifiedRegionCount"],
    "complete search" -> #["SearchCompleteQ"],
    "all returned facets scaleful" ->
      #["AllReturnedCertificatesScalefulQ"]
  |> &,
  candidateAudits
];

compactCertificateRows = Map[
  KeyTake[#, {
    "Candidate", "LocalFacet", "BoundaryZeroVariables", "PullbackVector",
    "WSL", "WHR", "CancellationDepth", "TransverseSuppressions",
    "LeadingFacetSourceCounts", "ScalefulQ"
  }] &,
  certificateRecords
];

auditResult = <|
  "GeneratedOn" -> DateString[Now, "ISODateTime"],
  "GraphKey" -> auditGraphName,
  "GraphDisplayName" -> graphDisplayName,
  "Implementation" -> <|
    "Core" -> "HiddenRegionFinder.wl",
    "Alignment" -> "HRF_AsymptoticOrderAlignment.wl",
    "Dissection" -> "HRF_SourceAwareDissectionCertification.wl",
    "DissectionEntryPoint" ->
      "hrfSourceAwareAlignedDissectionCertificate",
    "Options" -> dissectionOptions
  |>,
  "Summary" -> auditSummary,
  "Candidates" -> compactCandidateRows,
  "Certificates" -> compactCertificateRows,
  "CancellationFactorClasses" -> factorClassRows,
  "GeneratorClasses" -> generatorClassRows,
  "BoundaryInteriorRelations" -> boundaryInteriorVectorRows,
  "CertifiedHRClasses" -> physicalHRRows,
  "StrictCertificatePresentationClasses" -> regionGroupRows,
  "PresentationSplitsWithinHRs" -> presentationSplitRows,
  "CertifiedRegionClasses" -> regionGroupRows,
  "RepeatedVectorClasses" -> vectorCollisionRows
|>;

Export[
  FileNameJoin[{"results", "nmrk_wz", outputResultFile}],
  auditResult,
  "Package"
];

hrfPartIITextCell[s_String] := Cell[s, "Text"];
hrfPartIIOutputCell[e_] := Cell[BoxData @ ToBoxes[e], "Output"];
hrfPartIISection[s_String] := Cell[s, "Section"];
hrfPartIIGrid[rows_List] := Grid[rows, Frame -> All, Alignment -> Left,
  BaseStyle -> {FontSize -> 10}, ItemSize -> All];

hrfPartIIInputCell[code_String, label_String] := Module[{boxes, flat},
  flat = StringTrim @ StringReplace[
    StringReplace[StringTrim[code], RegularExpression["\r\n|\r|\n"] -> " "],
    RegularExpression[";\\s*;+"] -> "; "
  ];
  boxes = ToExpression[flat, InputForm, MakeBoxes];
  Cell[BoxData[boxes], "Input", CellLabel -> label]
];

candidateDisplay = hrfPartIIGrid @ Prepend[
  ({#["candidate"], #["boundary"], #["face scaling"],
      #["cancellation factors"], #["old status"], #["old rank/required"],
      #["old gap"], #["positive-pinch obstruction"],
      #["certified facets"], #["complete search"],
      #["all returned facets scaleful"]} & /@ compactCandidateRows),
  {"candidate", "boundary", "alignment face", "cancellation factors",
    "old provisional status", "old rank/required", "old gap",
    "positive-pinch obstruction", "exact local facets",
    "search complete", "scaleful"}
];

certificateDisplay = Dataset[compactCertificateRows];
physicalHRDisplay = Dataset[physicalHRRows];
strictPresentationDisplay = Dataset[regionGroupRows];
presentationSplitDisplay = If[presentationSplitRows === {},
  "No HR has multiple W_SL or cancellation-depth presentations.",
  Dataset[presentationSplitRows]
];
collisionDisplay = If[vectorCollisionRows === {},
  "No repeated pullback vectors were found.", Dataset[vectorCollisionRows]
];
factorClassDisplay = Dataset[factorClassRows];
generatorClassDisplay = Dataset[generatorClassRows];
boundaryInteriorDisplay = Dataset[boundaryInteriorVectorRows];

setupCode = StringRiffle[{
  "$HRFQuietReports=True;",
  "Get[FileNameJoin[{NotebookDirectory[],\"HiddenRegionFinder.wl\"}]];",
  "Get[FileNameJoin[{NotebookDirectory[],\"HRF_AsymptoticOrderAlignment.wl\"}]];",
  "savedScan=Import[FileNameJoin[{NotebookDirectory[],\"results\",\"nmrk_wz\",\"full_wz_" <> auditGraphName <> ".wl\"}],\"WL\"];",
  "candidateRows=savedScan[\"StagedDeduplicatedHiddenRegionRows\"];",
  "Length[candidateRows]"
}, "\n"];

auditCode = StringRiffle[{
  "candidateAudits=MapIndexed[Function[{row,index},",
  "  audit=hrfSourceAwareAlignedDissectionCertificate[row,termData,masterVariables,graphU,etaSymbol,hrfPartIIWZTransform,Sequence@@dissectionOptions];",
  "  <|\"Candidate\"->First[index],\"Audit\"->audit|>],candidateRows];",
  "KeyTake[auditSummary,{\"StagedCandidateCount\",\"CandidatesWithAtLeastOneCertificate\",\"AllCandidateSearchesCompleteQ\",\"AllCertificatesScalefulQ\"}]"
}, "\n"];

dedupCode = StringRiffle[{
  "vectorGroups=GatherBy[certificateRecords,hrfPartIIVectorKey];",
  "physicalHRGroups=GatherBy[certificateRecords,hrfPartIIHRKey];",
  "regionGroups=GatherBy[certificateRecords,hrfPartIIRegionKey];",
  "KeyTake[auditSummary,{\"RawCertificateCount\",\"DistinctPullbackVectorCount\",\"DistinctPhysicalHRCount\",\"InteriorPhysicalHRCount\",\"CodimensionOnePhysicalHRCount\",\"StrictCertificatePresentationCount\",\"CountAgreesWithPreviousTableQ\"}]"
}, "\n"];

classificationCode = StringRiffle[{
  "factorGroups=GatherBy[factorRecords,#1[\"FactorKey\"]&];",
  "generatorGroups=GatherBy[generatorRecords,#1[\"GeneratorKey\"]&];",
  "KeyTake[auditSummary,{\"DistinctCancellationFactorCount\",\"DistinctGeneratorCount\",\"PullbackVectorsSharedAcrossGeneratorFamilies\",\"BoundaryVectorsWithInteriorExtension\",\"BoundaryVectorsWithoutInteriorExtension\"}]"
}, "\n"];

factorMultiplicityProfile = Counts[
  Length[Lookup[Lookup[#, "HRFSummary", <||>],
    "CancellationFactors", {}]] & /@ candidateRows
];
boundaryRelationStrata = Counts[
  Lookup[boundaryInteriorVectorRows, "ContractedVariable", {}]
];
classificationText =
  "Across the " <> ToString[expectedCandidateCount] <>
  " staged candidates, the number of cancellation factors per candidate has profile " <>
  ToString[InputForm[factorMultiplicityProfile]] <> ". Part I returns one generator per candidate; in these samples each generator factors into two of the reported cancellation factors. After canonicalising overall signs and normalisations, there are " <>
  ToString[Length[factorGroups]] <> " distinct cancellation-factor polynomials and " <>
  ToString[Length[generatorGroups]] <> " distinct product generators. The identity of the factor set or generator is therefore a useful family label; the factor count alone need not be.";
boundaryRelationText =
  "A codimension-one HR is called an exact boundary restriction of an interior HR only when, after setting the contracted LP parameter to zero, the active pullback scaling, exact cancellation ideal and W_HR agree. W_SL is not used because it labels the Part-I/alignment presentation. There are " <>
  ToString[Length[boundaryInteriorVectorRows]] <> " such boundary HRs, distributed as " <>
  ToString[InputForm[boundaryRelationStrata]] <> "; " <>
  ToString[auditSummary["BoundaryVectorsWithoutInteriorExtension"]] <>
  " boundary HRs have no interior extension within this topology sample.";

conclusionText = If[TrueQ[auditSummary["AllCandidateSearchesCompleteQ"]],
  If[TrueQ[auditSummary["CountAgreesWithPreviousTableQ"]],
    "All " <> ToString[expectedCandidateCount] <>
      " searches are complete. Under the physical equivalence key (stratum, exact cancellation ideal, normalised pullback vector and W_HR), the result agrees with the existing Table 8 count.",
    "All " <> ToString[expectedCandidateCount] <>
      " searches are complete, but the physical HR count differs from Table 8. The table should be changed only after the corresponding audits of all three topologies have been reviewed together."
  ],
  "At least one search remains truncated. Every displayed certificate is an exact existence witness, but the number of certified regions is only a lower bound; Table 8 must not yet be changed from this run alone."
];

notebook = Notebook[{
  Cell["Two-loop NMRK Part-II and source-aware dissection audit", "Title"],
  Cell[graphDisplayName <> " at w=z", "Subtitle"],
  hrfPartIITextCell[
    "Purpose. This evaluated notebook applies the current source-aware dissection to all " <>
    ToString[expectedCandidateCount] <> " staged candidates for the " <>
    graphDisplayName <> " and tests whether they are rejected, rescued or identified with one another. It does not assume that the old staged status is final."
  ],

  hrfPartIISection["1. What the current dissection does"],
  hrfPartIITextCell[
    "The current implementation is HRF_SourceAwareDissectionCertification.wl. It preserves four sources separately: F_SL, F_Obs, every remaining native F layer and U. It maps each independent cancellation factor to signed endpoint coordinates, enumerates all pivot choices and sign sectors, recombines equal local exponent rows exactly, and sends the resulting rational Newton support to cddlib. An accepted certificate must have a positive eta-oriented exact lower facet of full affine rank, positive suppression transverse to every cancellation factor, a nonzero inverse-chart Jacobian, an exact pullback to the original LP variables and W_HR>W_SL. No copy of F_SL is promoted to W_HR by hand."
  ],
  hrfPartIITextCell[
    "This is a certification step for a full-rank Part-II solution, but it is also a completion step when the original-variable weight system is rank deficient: the local facet can select a different pullback scaling. A zero gap rejects only the provisional scaling being tested unless the Part-II active-set search is exhaustive."
  ],

  hrfPartIISection["2. Exact code and saved candidate input"],
  hrfPartIIInputCell[setupCode, "In[1]:="],
  hrfPartIIOutputCell[expectedCandidateCount],
  hrfPartIITextCell[
    "The graph incidence data, U polynomial, w=z coefficient transform, enlarged exhaustive caps and the complete evaluation loop are defined in rebuild_two_loop_nmrk_partII_dissection_audit_notebook.wl. The operative call is shown next."
  ],
  hrfPartIIInputCell[auditCode, "In[2]:="],
  hrfPartIIOutputCell[KeyTake[auditSummary, {
    "StagedCandidateCount", "CandidatesWithAtLeastOneCertificate",
    "AllCandidateSearchesCompleteQ", "AllCertificatesScalefulQ"
  }]],

  hrfPartIISection[
    "3. The " <> ToString[expectedCandidateCount] <> " staged candidates"
  ],
  hrfPartIITextCell[
    "The old status and rank columns are diagnostics inherited from the previous audit. They are displayed for comparison and are not used to decide the modern result. The last three columns come from the exact source-aware dissection."
  ],
  hrfPartIIOutputCell[candidateDisplay],

  hrfPartIISection["4. Every exact local-facet certificate"],
  hrfPartIITextCell[
    "ScalefulQ is the conjunction of ExactLowerFacetQ, CompleteFacetRankQ, HiddenHierarchyQ and PositiveTransverseSuppressionsQ. The full PullbackChecks associations are retained in the accompanying WL result file."
  ],
  hrfPartIIOutputCell[certificateDisplay],

  hrfPartIISection["5. Exact duplicate audit"],
  hrfPartIITextCell[
    "A raw local-facet certificate is not automatically a distinct HR. The physical grouping merges outputs with the same boundary stratum, normalised pullback scaling, W_HR and cancellation ideal, the latter tested by exact Groebner bases in the active LP variables. W_SL and the associated cancellation depth are retained as presentation diagnostics but do not split an HR."
  ],
  hrfPartIIInputCell[dedupCode, "In[3]:="],
  hrfPartIIOutputCell[KeyTake[auditSummary, {
    "RawCertificateCount", "DistinctPullbackVectorCount",
    "DistinctPhysicalHRCount", "InteriorPhysicalHRCount",
    "CodimensionOnePhysicalHRCount",
    "VectorClassesWithMultiplePresentations",
    "StrictCertificatePresentationCount",
    "CountAgreesWithPreviousTableQ"
  }]],
  hrfPartIITextCell["Repeated pullback-vector classes:"],
  hrfPartIIOutputCell[collisionDisplay],
  hrfPartIITextCell[
    "Deduplicated physical HR classes and the candidate/local-facet presentations that generate them:"
  ],
  hrfPartIIOutputCell[physicalHRDisplay],
  hrfPartIITextCell[
    "HRs admitting more than one W_SL or cancellation-depth presentation:"
  ],
  hrfPartIIOutputCell[presentationSplitDisplay],

  hrfPartIISection["6. Cancellation-factor families and boundary closures"],
  hrfPartIITextCell[classificationText],
  hrfPartIIInputCell[classificationCode, "In[4]:="],
  hrfPartIIOutputCell[KeyTake[auditSummary, {
    "DistinctCancellationFactorCount", "DistinctGeneratorCount",
    "PullbackVectorsSharedAcrossGeneratorFamilies",
    "BoundaryVectorsWithInteriorExtension",
    "BoundaryVectorsWithoutInteriorExtension"
  }]],
  hrfPartIITextCell[
    "The " <> ToString[Length[factorGroups]] <>
    " cancellation-factor classes:"
  ],
  hrfPartIIOutputCell[factorClassDisplay],
  hrfPartIITextCell[
    "The " <> ToString[Length[generatorGroups]] <>
    " generator families, with the number of distinct interior and codimension-one pullback vectors supplied by each family:"
  ],
  hrfPartIIOutputCell[generatorClassDisplay],
  hrfPartIITextCell[boundaryRelationText],
  hrfPartIIOutputCell[boundaryInteriorDisplay],

  hrfPartIISection["7. Consequence for Table 8"],
  hrfPartIITextCell[conclusionText],
  hrfPartIITextCell[
    "The compact machine-readable record is results/nmrk_wz/" <>
    outputResultFile <>
    ". The notebook and result are reproducible from the rebuild script in a fresh Mathematica kernel."
  ]
},
  WindowSize -> {1500, 950},
  WindowTitle -> "Two-loop NMRK Part-II dissection audit",
  StyleDefinitions -> "Default.nb",
  CellLabelAutoDelete -> False,
  Evaluator -> "Local"
];

Export[
  outputNotebookFile,
  notebook,
  "Notebook"
];

Print["Wrote ", outputNotebookFile];
Print["Wrote results/nmrk_wz/", outputResultFile];
Print[InputForm[auditSummary]];
