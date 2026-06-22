(* HRF_KinematicGeneratorPresets.wl
   Generator search presets by kinematic limit (not by diagram).
   Wide-angle 4pt: two sector generators via PairSectors (Ex01/Ex02/Ex04 standard).
   Regge / collinear: one generator via PairSectors. *)

ClearAll[
  hrfKinematicLimitNames, hrfKinematicGeneratorPreset, hrfKinematicLimitObstructionOptions,
  hrfFindObstructionsForKinematicLimit, hrfKinematicLimitFromKinVars, hrfKinematicLimitDescription,
  hrfKinematicLimitInteriorOptions, hrfKinematicLimitUseExtendedFactorsQ
];

If[! ValueQ[$HRFUseKinematicGeneratorPresetsQ], $HRFUseKinematicGeneratorPresetsQ = True];

hrfKinematicLimitNames[] = {"WideAngle4pt", "WideAngle4ptBoundary", "WideAngle4ptExhaustive", "Regge4pt", "Collinear5pt"};

(* Crown / default wide-angle: PairSectors (two kin-free sector generators). *)
hrfKinematicGeneratorPreset["WideAngle4pt"] = <|
  "KinematicLimit" -> "WideAngle4pt",
  "GeneratorMode" -> "PairSectors",
  "MaxGenerators" -> 2,
  "PreferFewerGenerators" -> False,
  "MaxProductSubsetSize" -> 2,
  "Description" -> "Wide-angle 4pt (s12,s23): PairSectors, two sector generators"
|>;

(* Boundary / interior aliases: same PairSectors settings, distinct preset names for Ex04 routing. *)
hrfKinematicGeneratorPreset["WideAngle4ptBoundary"] = <|
  "KinematicLimit" -> "WideAngle4ptBoundary",
  "GeneratorMode" -> "PairSectors",
  "MaxGenerators" -> 2,
  "PreferFewerGenerators" -> False,
  "MaxProductSubsetSize" -> 2,
  "Description" -> "Wide-angle 4pt boundary: PairSectors (fast; two kin-free sector generators)"
|>;

(* Interior no-HR certificate: PairSectors only, no extra single-product trials. *)
hrfKinematicGeneratorPreset["WideAngle4ptExhaustive"] = <|
  "KinematicLimit" -> "WideAngle4ptExhaustive",
  "GeneratorMode" -> "PairSectors",
  "MaxGenerators" -> 2,
  "PreferFewerGenerators" -> False,
  "MaxProductSubsetSize" -> 2,
  "Description" -> "Wide-angle 4pt exhaustive (PairSectors): interior no-HR certificate"
|>;

hrfKinematicGeneratorPreset["Regge4pt"] = <|
  "KinematicLimit" -> "Regge4pt",
  "GeneratorMode" -> "PairSectors",
  "MaxGenerators" -> 1,
  "PreferFewerGenerators" -> True,
  "MaxProductSubsetSize" -> 2,
  "Description" -> "Regge 4pt single channel: one generator g(x)"
|>;

hrfKinematicGeneratorPreset["Collinear5pt"] = <|
  "KinematicLimit" -> "Collinear5pt",
  "GeneratorMode" -> "SingleProduct",
  "MaxGenerators" -> 1,
  "PreferFewerGenerators" -> True,
  "RelaxSingleProductDegreeQ" -> False,
  "SkipPDFFindInstanceQ" -> False,
  "Description" -> "Spacelike collinear 5pt: polynomial f_k (canonical Factor strip of non-x_i shells), SingleProduct pair"
|>;

hrfKinematicGeneratorPreset[other_] := Missing["UnknownKinematicLimit", other];

hrfKinematicLimitDescription[limit_String] := Module[{p = hrfKinematicGeneratorPreset[limit],
  base = If[StringQ[limit] && StringEndsQ[limit, "Exhaustive"], "WideAngle4pt", limit]},
  Which[
    AssociationQ[p], Lookup[p, "Description", limit],
    base =!= limit && AssociationQ[hrfKinematicGeneratorPreset[base]],
      Lookup[hrfKinematicGeneratorPreset[base], "Description", limit] <> " (exhaustive)",
    True, ToString[limit]
  ]
];

(* Collinear5pt / SingleProduct: derivative-only safe pool (UseExtendedFactors=False). *)
hrfKinematicLimitUseExtendedFactorsQ[limit_String] := ! MemberQ[{"Collinear5pt", "Regge4pt"}, limit];

hrfKinematicLimitObstructionOptions[limit_String] := Module[{p},
  p = hrfKinematicGeneratorPreset[limit];
  If[! AssociationQ[p], Return[{}]];
  DeleteCases[
    {
      "GeneratorMode" -> p["GeneratorMode"],
      "MaxGenerators" -> p["MaxGenerators"],
      "PreferFewerGenerators" -> p["PreferFewerGenerators"],
      "MaxProductSubsetSize" -> Lookup[p, "MaxProductSubsetSize", Automatic],
      "RelaxSingleProductDegreeQ" -> Lookup[p, "RelaxSingleProductDegreeQ", Automatic],
      "SkipPDFFindInstanceQ" -> Lookup[p, "SkipPDFFindInstanceQ", Automatic]
    },
    _[_, Automatic]
  ]
];

hrfKinematicLimitInteriorOptions[limit_String:"WideAngle4pt"] := Module[{exhaustive},
  exhaustive = limit <> "Exhaustive";
  If[AssociationQ[hrfKinematicGeneratorPreset[exhaustive]],
    hrfKinematicLimitObstructionOptions[exhaustive],
    hrfKinematicLimitObstructionOptions[limit]
  ]
];

hrfKinematicLimitFromKinVars[kinVars_List] := Which[
  Length[kinVars] === 1 && MemberQ[{s12, s23}, First[kinVars]], "Regge4pt",
  Length[kinVars] === 2 && Sort[Unevaluated[kinVars]] === Sort[{s12, s23}], "WideAngle4pt",
  Length[kinVars] >= 3 || MemberQ[kinVars, s] || MemberQ[kinVars, x] || MemberQ[kinVars, z],
    "Collinear5pt",
  True, "WideAngle4pt"
];

hrfFindObstructionsForKinematicLimit[limit_String, F_, vars_, kinAssump_, kinVars_, maxSize_, opts___] :=
  findObstructions[
    F, vars, kinAssump, kinVars, maxSize,
    "UseExtendedFactors" -> hrfKinematicLimitUseExtendedFactorsQ[limit],
    Sequence @@ If[TrueQ[$HRFUseKinematicGeneratorPresetsQ],
      hrfKinematicLimitObstructionOptions[limit],
      {"GeneratorMode" -> "PairSectors", "MaxGenerators" -> 2}
    ],
    opts
  ];
