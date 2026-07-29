# Five-point MRK central-soft checks

This directory is the lean collaborator-facing record of the first exact-
kinematics HRF scan of five-point MRK with a central-soft composite limit.
References to the 12 "labelings" mean assignments of external momenta to
internal graph vertices, not alternative rapidity orderings.  Every case has
the same physical hierarchy `y3 >> y4 >> y5`.

The all-outgoing process is `-p1,-p2 -> p3,p4,p5`, with `p4` the central
emission.  The exact chart takes

- `p4_perp ~ delta^a`,
- the MRK gap parameter `x ~ delta^b`, with `0 < a < b`,
- exact on-shell outgoing momenta and exact momentum conservation.

This is essential: a leading-only MRK substitution omits layers that can be
promoted by asymptotic-order alignment and gives a false negative.

For the representative path `p4_perp~delta` and `x~delta^2`, the exact
light-cone scaling is

```text
p3: (p+,p-,|p_perp|) ~ (delta^-2, delta^2, 1)
p4: (p+,p-,|p_perp|) ~ (delta,    delta,   delta)
p5: (p+,p-,|p_perp|) ~ (delta^2,  delta^-2,1)
```

Hence `y3~-2 log(delta)`, `y4=O(1)`, and `y5~2 log(delta)`.  This is not
generic MRK because the central transverse momentum is soft, but the
multi-Regge rapidity hierarchy remains intact.  Since `s1,s2~delta`, the
Section-2 relations give `s12~delta^-4`, `s34,s45~delta^-1`, while the
transfers `s23,s15` remain finite.

## Current result

- All 12 inequivalent one-loop pentagon labelings: no HR.
- Two-loop six-propagator seed in generic MRK: no certified HR.
- The same two-loop seed in the exact central-soft composite limit: one HR
  for 6 of the 12 labelings.
- Within this scan, the criterion is exact: the HR occurs iff the central
  gluon `p4` is attached to internal vertex 3 or 5, the two four-valent
  vertices of the seed graph.
- The result is unchanged for the two transverse sign charts and for
  `(a,b)=(1,2),(1,3),(2,3)`.

For the representative ordering `{1,2,3,5,4}` at `(a,b)=(1,2)`, the aligned
superleading polynomial is proportional to

```text
(P x2 - K x3) (x1 x4 - x0 x5),
```

and the simultaneous cancellation locus is defined by both factors being
zero.  The relative total vector is

```text
(-3,-3,0,-3,-3,-3;1).
```

The resolved augmented Newton points have affine rank 6, equal to the
required rank, so this is a certified lower facet rather than a scaleless
staged candidate.

The momentum-component reconstruction has also been calibrated against the
published five-point spacelike-collinear facet and hidden regions.  It
correctly recovers the hidden Glauber loop as a linear combination of two
soft edge momenta.  For the present MRK HR, the relative vector quoted above
is insufficient for absolute momentum and power counting.  The full
aligned-plus-HRF vector in the original exact chart is

```text
(-4,-4,-1,-4,-4,-4;1),
```

so the propagator virtuality powers are `(4,4,1,4,4,4)`.  With `q0` and `q3`
as an independent edge-momentum basis, momentum conservation admits the
valuation-level assignment
`q0~(delta^6,delta^-2,delta^2)` and `q3~(delta,delta^3,delta^2)`.  The loop
rerouting `ell=q0-q4` has central value `(delta^2,delta^2,1)`.  Writing every
propagator in the adapted basis `(r=q0,ell)` shows that precisely `q4` and
`q5` depend on the local `ell+` fluctuation at leading power.  Their Feynman
poles approach from opposite half-planes.  Both slopes have power `-2` and
both virtualities have power `4`, so the pinched width is
`Delta ell+~delta^6`.  The residual `q2=p3-ell` fixes
`(Delta ell-,Delta ell_perp)~(delta^3,delta^2)`.  The local widths are thus
`(6,3,2)`: there is one genuine Glauber loop, not two.

The unit-numerator scalar power count provides an additional certificate.
The raw superleading F layer has weight `-13`, whereas the scaleful LP layer
has weight `-8`.  The total cancellation depth is therefore five: four from
asymptotic-order alignment and one from the final HRF gap.  In parameter
space the measure gives `-21+5=-16`, while `P^(-D/2)` gives `4D`; hence

```text
I_HR ~ delta^(4D-16) = delta^(-8 epsilon),  D=4-2 epsilon.
```

Momentum space now supplies an independent certificate.  The `r` widths
`(6,-2,2)` give measure power `2D`, while the pinched Glauber widths
`(6,3,2)` give `2D+5`.  Subtracting the total propagator power `21` yields
`4D+5-21=4D-16`, in exact agreement with parameter space.  No extra
cancellation-depth factor is inserted in the momentum count: its effect is
already present in the restricted loop widths.

## Files

- `FivePoint_MRK_CentralSoft_AsymptoticAlignment.nb`: self-contained physics
  narrative, exact chart, graph drawings, 12-ordering table and representative
  certificate.
- `certified_summary.wl`: compact machine-readable result used by the notebook.
- `HRF_FivePointMRKExploratory.wl`: graph definitions and exact kinematic chart.
- `HRF_FivePointMRKTargetedRun.wl`: targeted full HRF runner.
- `HRF_MomentumScalingReconstruction.wl`: virtuality, vertex-conservation and
  primitive loop-combination audit.
- `HRF_RunFivePointMomentumScalingPrototype.wl`: complete bounded component
  scan based on the relative vector.  It is retained only as a preliminary
  ambiguity diagnostic and must not be used for absolute power counting.
- `momentum_scaling_prototype_result.wl`: machine-readable component and
  Glauber-ambiguity audit from that preliminary scan.
- `HRF_RunFivePointMRKPinchMomentumCheck.wl`: full-depth edge-flow valuation
  audit and central-value rerouting.
- `five_point_mrk_pinch_momentum_result.wl`: machine-readable output of that
  edge-flow check.
- `HRF_LightConePolePinch.wl`: reusable light-cone propagator and pole helpers.
- `HRF_RunFivePointMRKPolePinchCheck.wl`: coefficient-level `ell+` pole-pinch
  certificate and local-width reconstruction.
- `five_point_mrk_pole_pinch_result.wl`: machine-readable pole locations,
  leading-sensitivity table, local loop widths, and momentum power count.
- `HRF_RunSpacelikeAndMRKPowerCountingChecks.wl`: parameter/momentum scalar
  power-counting certificates for both five-point HRs.
- `spacelike_mrk_power_counting_result.wl`: machine-readable power counts.
- `rebuild_five_point_mrk_notebook.wl`: notebook builder.
- `HRF_FivePointMRKBuildSummary.wl`: compact-summary builder.  It expects the
  detailed targeted outputs, which are intentionally not included here.

## Representative rerun

From this directory, with the consolidated asymptotic-order-alignment HRF
release available at the path selected in `HRF_FivePointMRKExploratory.wl`:

```sh
wolframscript -file HRF_FivePointMRKTargetedRun.wl 2 exact-soft-plus 1 2 seed
```

The checks recorded here were run with Wolfram Engine 15.0.1 for macOS ARM.
