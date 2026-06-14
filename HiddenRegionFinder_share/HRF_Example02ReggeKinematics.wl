(* HRF_Example02ReggeKinematics.wl
   Three Regge / forward kinematic conventions for massless 4pt scattering.
   Momentum conservation is s13 = -s12 - s23.
   The small (t-channel) invariant is written t = -\[Delta]*s with \[Delta] > 0. *)

ClearAll[
  hrfReggeChannelLabels, hrfReggeChannelAssociation, hrfReggeChannels,
  hrfReggeChannelDescription, hrfReggeLeadingF, hrfReggeKinVars,
  hrfReggeKinAssumptions, hrfReggeSubstituteBack, hrfReggeChannelData
];

hrfReggeChannelLabels[] := {"T23", "T12", "T13"};

hrfReggeChannelAssociation[] := <|
  "T23" -> <|"t" -> s23, "s" -> s12, "delta" -> "-s23/s12", "large" -> s12, "small" -> s23|>,
  "T12" -> <|"t" -> s12, "s" -> s23, "delta" -> "-s12/s23", "large" -> s23, "small" -> s12|>,
  "T13" -> <|"t" -> s13, "s" -> s12, "delta" -> "-s13/s12", "large" -> s12, "small" -> s13|>
|>;

hrfReggeChannels[] := Keys[hrfReggeChannelAssociation[]];

hrfReggeChannelDescription[channel_String] := Module[{info = hrfReggeChannelAssociation[][[channel]]},
  StringRiffle[{
    "Regge channel " <> channel,
    "t = " <> ToString[InputForm[info["t"]]] <> ", s = " <> ToString[InputForm[info["s"]]],
    "\[Delta] = " <> info["delta"] <> " > 0",
    "leading limit: " <> ToString[InputForm[info["small"]]] <> " -> 0 with " <> ToString[InputForm[info["large"]]] <> " kept"
  }, " | "]
];

(* Leading Regge polynomial: strict \[Delta]^0 part (small invariant set to zero). *)
hrfReggeLeadingF[F_, channel_String] := Module[{f = Expand[F]},
  Switch[channel,
    "T23", Expand[f /. s23 -> 0],
    "T12", Expand[f /. s12 -> 0],
    "T13", Expand[f /. s23 -> -s12],
    _, Missing["UnknownReggeChannel", channel]
  ]
];

hrfReggeKinVars[channel_String] := Switch[channel,
  "T23", {s12},
  "T12", {s23},
  "T13", {s12},
  _, {}
];

hrfReggeKinAssumptions[channel_String] := Switch[channel,
  "T23", s12 > 0,
  "T12", s23 < 0,
  "T13", s12 > 0,
  _, False
];

hrfReggeSubstituteBack[expr_, channel_String] := Switch[channel,
  "T23", expr,
  "T12", expr,
  "T13", Expand[expr /. s12 -> -s23],
  _, expr
];

hrfReggeChannelData[channel_String] := <|
  "Channel" -> channel,
  "Description" -> hrfReggeChannelDescription[channel],
  "KinVars" -> hrfReggeKinVars[channel],
  "KinAssumptions" -> hrfReggeKinAssumptions[channel],
  "Association" -> hrfReggeChannelAssociation[][[channel]]
|>;

Print["[loaded] Example 02 Regge kinematics (channels T23, T12, T13)."];
