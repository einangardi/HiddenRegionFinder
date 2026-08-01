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
zero.  The first-stage alignment vector is

```text
(-3,-3,0,-3,-3,-3).
```

The second-stage HRF vector in the aligned face is uniform,
`(-1,-1,-1,-1,-1,-1)`.  Their composition—not either vector separately—is
the original-coordinate region vector

```text
(-4,-4,-1,-4,-4,-4;1).
```

The complete native-layer audit gives `(W_SL,W_HR)=(-9,-8)`.  In particular,
the term `-T x0 x3 x4` carries native delta order four and lies at `W_HR=-8`;
stripping that native order incorrectly makes it appear below the physical
layer.

The resolved augmented Newton points have affine rank 6, equal to the
required rank, so this is a certified lower facet rather than a scaleless
staged candidate.

This is the hard-scale-normalized Schwinger vector.  Adding a common `+4`
while simultaneously allowing `s12~delta^-4` merely converts to dimensionful
Schwinger parameters; the resulting non-negative list is not an alternative
IR region vector.

The certified vector fixes propagator virtuality powers `(4,4,1,4,4,4)`.
With `r=q0` and `ell=q0-q4`, the complete hard-scale-normalized component
powers `(q+,q-,|q_perp|)` are

```text
q0: (4,0,2)   q1: (4,0,2)   q2: (0,1,2)
q3: (3,1,2)   q4: (4,0,2)   q5: (4,0,2)
```

The `q0/q1` poles restrict `r+` to width `delta^4`; `q4/q5` restrict
`ell+` to `delta^4`; and `q2/q3` restrict `ell-` to `delta`.  The loop
measure therefore has power `4 D+1`, while the six denominator powers sum
to 21.  This gives `delta^(4 D-20)`.  The local-coordinate parameter-space
calculation independently gives measure power `-20` and LP contribution
`delta^(4 D)`, hence the same scalar power.  At `D=4-2 epsilon` this is
`delta^(-4-8 epsilon)`.

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
- `HRF_RunFivePointMRKPinchMomentumCheck.wl`: superseded exploratory edge-flow
  valuation audit; it is not a current momentum-space certificate.
- `five_point_mrk_pinch_momentum_result.wl`: machine-readable output of that
  edge-flow check.
- `HRF_LightConePolePinch.wl`: reusable light-cone propagator and pole helpers.
- `HRF_RunFivePointMRKPolePinchCheck.wl`: superseded pole-width exploration;
  its output must be rederived from the corrected native layers.
- `five_point_mrk_pole_pinch_result.wl`: machine-readable pole locations,
  leading-sensitivity table, local loop widths, and momentum power count.
- `HRF_RunSpacelikeAndMRKPowerCountingChecks.wl`: legacy comparison script;
  its spacelike calibration is retained, but its central-soft MRK count is
  superseded.
- `spacelike_mrk_power_counting_result.wl`: legacy output, not a current
  central-soft MRK certificate.
- `HRF_RunFivePointMRKCorrectedPowerCounting.wl`: current two-representation
  scalar power-counting certificate.
- `five_point_mrk_corrected_power_counting_result.wl`: machine-readable output
  of the current certificate.
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
