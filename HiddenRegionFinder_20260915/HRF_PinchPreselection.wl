(* ::Package:: *)
(* HRF_PinchPreselection.wl
   Necessary-condition preselection for pinch singularities in parameter space.

   This implements the three-step algorithm of arXiv:2407.13738, section 3.2,
   "Algorithm to identify potential pinch singularities in F^(sij)".

   Load after HiddenRegionFinder.wl:
     Get["HRF_PinchPreselection.wl"];

   Main public routines:
     hrfPinchPreselectSingleInvariant[F, vars]
     hrfPinchPreselectByKinematics[F, vars, kinVars]
*)

If[! ValueQ[$HRFPinchPreselectionMaxIterations], $HRFPinchPreselectionMaxIterations = Infinity];
If[! ValueQ[$HRFPinchPreselectionAssumptions], $HRFPinchPreselectionAssumptions = True];

ClearAll[
  hrfPinchCompact, hrfPinchCoefficientSign, hrfPinchSplitSigns,
  hrfPinchSignLabel, hrfPinchMonomialCoefficientRows,
  hrfPinchActiveVars, hrfPinchPreselectSingleInvariant,
  hrfPinchKinematicCoefficients, hrfPinchPreselectByKinematics,
  hrfPinchSummaryRow
];

hrfPinchCompact[x_] := ToString[InputForm[x]];

Options[hrfPinchCoefficientSign] = {"Assumptions" -> Automatic};
hrfPinchCoefficientSign[c_, OptionsPattern[]] := Module[{cc, ass, s},
  ass = Replace[OptionValue["Assumptions"], Automatic :> $HRFPinchPreselectionAssumptions];
  cc = FullSimplify[Factor[c], ass];
  s = Quiet @ Check[Sign[cc], Indeterminate];
  Which[
    TrueQ[s > 0], 1,
    TrueQ[s < 0], -1,
    TrueQ[s === 0], 0,
    TrueQ[Simplify[cc > 0, ass]], 1,
    TrueQ[Simplify[cc < 0, ass]], -1,
    TrueQ[Simplify[cc == 0, ass]], 0,
    True, Indeterminate
  ]
];

hrfPinchSignLabel[1] := "positive";
hrfPinchSignLabel[-1] := "negative";
hrfPinchSignLabel[0] := "zero";
hrfPinchSignLabel[_] := "ambiguous";

Options[hrfPinchMonomialCoefficientRows] = {"Assumptions" -> Automatic};
hrfPinchMonomialCoefficientRows[F_, vars_List, OptionsPattern[]] := Module[
  {rules, ass, monomialFor, coeff, factored, sign},
  ass = OptionValue["Assumptions"];
  rules = CoefficientRules[Expand[F], vars];
  monomialFor[powers_List] := Times @@ MapThread[Power, {vars, powers}];
  Table[
    coeff = rules[[i, 2]];
    factored = FullSimplify[Factor[coeff], ass];
    sign = hrfPinchCoefficientSign[factored, "Assumptions" -> ass];
    <|
      "Exponents" -> rules[[i, 1]],
      "Monomial" -> monomialFor[rules[[i, 1]]],
      "Coefficient" -> coeff,
      "FactoredCoefficient" -> factored,
      "Sign" -> sign,
      "SignLabel" -> hrfPinchSignLabel[sign],
      "Term" -> Expand[coeff monomialFor[rules[[i, 1]]]]
    |>,
    {i, Length[rules]}
  ]
];

Options[hrfPinchSplitSigns] = {"Assumptions" -> Automatic};
hrfPinchSplitSigns[F_, vars_List, OptionsPattern[]] := Module[
  {rows, plus = 0, minus = 0, zero = 0, ambiguous = {}, term, s, ass},
  ass = OptionValue["Assumptions"];
  rows = hrfPinchMonomialCoefficientRows[F, vars, "Assumptions" -> ass];
  Do[
    term = rows[[i]]["Term"];
    s = rows[[i]]["Sign"];
    Which[
      s === 1, plus = plus + term,
      s === -1, minus = minus + term,
      s === 0, zero = zero + term,
      True, AppendTo[ambiguous, term]
    ],
    {i, Length[rows]}
  ];
  <|
    "PositivePart" -> Expand[plus],
    "NegativePart" -> Expand[minus],
    "ZeroPart" -> Expand[zero],
    "AmbiguousTerms" -> ambiguous,
    "MonomialCoefficientRows" -> rows
  |>
];

hrfPinchActiveVars[F_, vars_List] := Select[vars, ! TrueQ[FreeQ[Expand[F], #]] &];

Options[hrfPinchPreselectSingleInvariant] = {
  "Assumptions" -> Automatic,
  "MaxIterations" -> Automatic
};
hrfPinchPreselectSingleInvariant[F_, vars_List, OptionsPattern[]] := Module[
  {ass, maxIt, zeroVars = {}, iterations = {}, f, active, split, fp, fm,
   dRows, derivativeAmbiguous, oneSided, iter = 0, result, zeroRules},
  ass = OptionValue["Assumptions"];
  maxIt = Replace[OptionValue["MaxIterations"], Automatic :> $HRFPinchPreselectionMaxIterations];
  f = Expand[F];
  While[True,
    iter++;
    zeroRules = If[zeroVars === {}, {}, Thread[zeroVars -> 0]];
    f = Expand[F /. zeroRules];
    active = hrfPinchActiveVars[f, Complement[vars, zeroVars]];
    split = hrfPinchSplitSigns[f, active, "Assumptions" -> ass];
    fp = split["PositivePart"];
    fm = split["NegativePart"];
    dRows = Table[
      Module[{dTotal, dSplit},
        dTotal = Expand[D[f, active[[i]]]];
        dSplit = hrfPinchSplitSigns[dTotal, active, "Assumptions" -> ass];
        <|
          "Variable" -> active[[i]],
          "DTotal" -> dTotal,
          "DPositive" -> dSplit["PositivePart"],
          "DNegative" -> dSplit["NegativePart"],
          "DZero" -> dSplit["ZeroPart"],
          "AmbiguousTerms" -> dSplit["AmbiguousTerms"],
          "SignRows" -> dSplit["MonomialCoefficientRows"]
        |>
      ],
      {i, Length[active]}
    ];
    derivativeAmbiguous = Select[dRows, Lookup[#, "AmbiguousTerms", {}] =!= {} &];
    oneSided = Lookup[
      Select[
        dRows,
        Lookup[#, "AmbiguousTerms", {}] === {} &&
          Xor[TrueQ[#["DPositive"] === 0], TrueQ[#["DNegative"] === 0]] &
      ],
      "Variable",
      {}
    ];
    AppendTo[iterations, <|
      "Iteration" -> iter,
      "ZeroVarsBefore" -> zeroVars,
      "RestrictedPolynomial" -> f,
      "ActiveVars" -> active,
      "PositivePart" -> fp,
      "NegativePart" -> fm,
      "AmbiguousTerms" -> split["AmbiguousTerms"],
      "MonomialCoefficientRows" -> split["MonomialCoefficientRows"],
      "DerivativeRows" -> dRows,
      "OneSidedDerivativeVars" -> oneSided
    |>];
    result = Which[
      split["AmbiguousTerms"] =!= {},
        <|"PotentialPinchQ" -> Missing["AmbiguousSigns"],
          "ExitReason" -> "ambiguous coefficient signs"|>,
      derivativeAmbiguous =!= {},
        <|"PotentialPinchQ" -> Missing["AmbiguousDerivativeSigns"],
          "ExitReason" -> "ambiguous derivative coefficient signs"|>,
      TrueQ[fp === 0] || TrueQ[fm === 0],
        <|"PotentialPinchQ" -> False,
          "ExitReason" -> "one sign is absent after restrictions"|>,
      oneSided === {},
        <|"PotentialPinchQ" -> True,
          "ExitReason" -> "all remaining positive/negative derivative pairs are nonzero"|>,
      ! TrueQ[iter < maxIt],
        <|"PotentialPinchQ" -> Missing["IterationLimit"],
          "ExitReason" -> "iteration limit reached"|>,
      True,
        Missing["Continue"]
    ];
    If[AssociationQ[result], Break[]];
    zeroVars = Sort @ DeleteDuplicates@Join[zeroVars, oneSided];
  ];
  Join[result, <|
    "ZeroVars" -> zeroVars,
    "RemainingVars" -> Complement[vars, zeroVars],
    "ActiveRemainingVars" -> active,
    "RestrictedPolynomial" -> f,
    "PositivePart" -> fp,
    "NegativePart" -> fm,
    "Iterations" -> iterations
  |>]
];

hrfPinchKinematicCoefficients[F_, vars_List, kinVars_List] := Module[
  {poly, coeffs},
  poly = Collect[Expand[F], kinVars, Expand];
  coeffs = Association @ Table[
    kinVars[[i]] -> Expand[Coefficient[poly, kinVars[[i]]]],
    {i, Length[kinVars]}
  ];
  KeySelect[coeffs, ! TrueQ[coeffs[#] === 0] &]
];

Options[hrfPinchPreselectByKinematics] = Options[hrfPinchPreselectSingleInvariant];
hrfPinchPreselectByKinematics[F_, vars_List, kinVars_List, OptionsPattern[]] := Module[
  {coeffs, scans, rows, nonzeroKeys, candidateQ, captured, residual},
  coeffs = hrfPinchKinematicCoefficients[F, vars, kinVars];
  captured = Total[KeyValueMap[#1 #2 &, coeffs]];
  residual = Expand[F - captured];
  scans = Association @ KeyValueMap[
    #1 -> hrfPinchPreselectSingleInvariant[#2, vars,
      "Assumptions" -> OptionValue["Assumptions"],
      "MaxIterations" -> OptionValue["MaxIterations"]
    ] &,
    coeffs
  ];
  rows = hrfPinchSummaryRow /@ Normal[scans];
  nonzeroKeys = Keys[coeffs];
  candidateQ = Which[
    nonzeroKeys === {}, False,
    AnyTrue[Values[scans], TrueQ[#["PotentialPinchQ"] === False] &], False,
    AnyTrue[Values[scans], MatchQ[#["PotentialPinchQ"], _Missing] &], Missing["Ambiguous"],
    True, True
  ];
  <|
    "PotentialPinchQ" -> candidateQ,
    "KinematicCoefficients" -> coeffs,
    "ResidualAfterLinearKinematicCoefficients" -> residual,
    "CoefficientScans" -> scans,
    "SummaryRows" -> rows,
    "SummaryDataset" -> Dataset[rows]
  |>
];

hrfPinchSummaryRow[channel_ -> scan_Association] := <|
  "Channel" -> channel,
  "PotentialPinchQ" -> Lookup[scan, "PotentialPinchQ", Missing["NoResult"]],
  "ZeroVars" -> Lookup[scan, "ZeroVars", {}],
  "RemainingActiveVars" -> Lookup[scan, "ActiveRemainingVars", {}],
  "ExitReason" -> Lookup[scan, "ExitReason", ""],
  "RestrictedPolynomial" -> hrfPinchCompact[Lookup[scan, "RestrictedPolynomial", 0]]
|>;

If[! TrueQ[$HRFQuietReports],
  Print["[loaded] pinch preselection. Use hrfPinchPreselectSingleInvariant or hrfPinchPreselectByKinematics."]
];
