# Release provenance

Release consolidation date: 2026-07-31

This repository consolidates the HRF development line used for the five-point
spacelike-collinear, double-spacelike-collinear, `w=z` NMRK, four-loop
wide-angle, and four-loop Regge studies.  The canonical name of the
composite-limit preprocessing step is **asymptotic-order alignment**.

## Changes consolidated on 31 July

The derivative-harvest interface now enforces the conceptual order of the HRF
construction.  Candidate factors are first harvested without imposing the
full stationary system.  Saturation is permitted only for an already selected
leading cancellation sector, or for explicitly supplied derivative-sector
relations.  The new preferred mode is `"SaturatedLeadingIdeal"`; an
unjustified full-gradient request is recorded as incomplete rather than being
silently used as a discovery fallback.

The five-point near-planar wide-angle example supplies the positive control.
On the coplanar leading surface its full leading polynomial equals the
cancellation sector, and candidate-specific saturation recovers the three
normal factors and their three pair-product generators.  Its notebook and the
paper draft now give the dissection coordinates explicitly.  The scalar power
is counted first in the original Schwinger variables, including the three
restricted normal widths, and independently in momentum space; both give
`lambda^(2 D-9)=lambda^(-1-4 epsilon)`.

The current JHEP paper draft and its build inputs are vendored under `docs/`.

## Baseline

The alignment development started from the 8 July 2026 HRF candidate.  The
baseline source hashes recorded before the later certification work were:

- `HiddenRegionFinder.wl`:
  `fdca838b49c6e3a79ebaa194e70d3cf66f56b8bd629d08fd0ffbc1d7c7b073c9`
- alignment preselection implementation, then stored under its historical
  filename:
  `5988609091570c2d70996744bef74359ea1efd698cc81954fafadf31b10fe73e`

The baseline validation contained 15/15 staging checks and 3/3 initial
alignment smoke checks.  Subsequent work added occupied-layer certification,
uniform-shift resolution, local-dissection fallback, removal of the
derivative-factor length cap, complete-polynomial-factor construction,
explicit exploratory/certified search profiles, a complete four-loop Regge
No-Crown audit, and the now-complete wide-angle No-Crown audit.

## Vendored inputs

To make the release portable, the following formerly external inputs are now
stored in the repository:

- `data/wide_angle/16_examples_diagrams.txt`: the sixteen four-loop graph
  definitions used by both the wide-angle and Regge audits;
- `data/nmrk/one_loop_hexagon_kinematics.wl`: the exact six-point NMRK
  invariant rules and one-loop graph data;
- `data/nmrk/asymptotic_order_alignment_seeds.wl`: the 16 planar and 9
  nonplanar structurally distinct `w=z` alignment seeds retained from the
  exhaustive 19 July 2026 discovery scans;
- `testdata/alignment/`: frozen full one-loop DSC and NMRK scans used only by
  the layered regression suite.

The compact scientific outputs used by the notebooks live under `results/`.
Fresh expensive scans write to `results/generated/`.  Generated scan output is
not part of this dated release and should be ignored by the containing Git
repository.

## Four-point Crown/no-Crown program

The principal positive four-point records are
`01_Current_WideAngle_4pt.nb` and `02_Current_Regge_4pt.nb`.  They establish
the Crown as an interior HR seed and show, through the SuperCrown and
HyperCrown examples, why boundary strata must be searched when the Crown is a
contraction minor of a larger topology.  The Regge notebook follows the
positive examples through all three channels where applicable.

The current wide-angle record includes a focused SuperCrown codimension-two
witness at `x8=x9=0`.  For the HyperCrown it separates the two established
positive boundary types (codimension one and adjacent-pair codimension two),
the exactly excluded opposite-pair orbit, and the still-unresolved interior.
Permutation and crossing representatives are generated from the exact graph
automorphisms rather than counted as independent searches.

`WideAngle16_NoCrown_HRF_Audit.nb` and
`WideAngle16_NoCrown_Regge_HRF_Audit.nb` are the complementary negative
records.  They test the “only if” direction on the 16 four-loop mixed-sign
graphs without a Crown contraction minor.  The release therefore preserves
both sides of the observed Crown-minor criterion, as well as the positive and
negative evidence for the wide-angle-to-Regge correspondence.

`NoCrown_4Loop_WideAngle_and_Regge_Audit_Guide.nb` is the concise
collaborator-facing implementation guide to these two records.  It keeps the
provenance explicit while closing the former coverage gap: the historical
wide-angle record contains the 188 codimension-two strata involving `x8`, and
the current exact per-stratum run certifies the complementary 1012.  Thus the
wide-angle and Regge audits are both complete for the stated sample.

## Five-point principal application

The five-point spacelike-collinear study is a principal physics application,
not merely a regression control.  Its main record is
`03_Current_SpacelikeCollinear_5pt.nb`, with
`04_Current_5pt_Preselection.nb` as the topology-preselection companion.
The associated core, seed study, descendant runner, full 70-topology runner,
and compact scan summaries are retained in the release.

This application requires ordinary HRF rather than asymptotic-order
alignment.  It is the canonical example in which the decomposition
`F_0 = F_SL + F_Obs` exposes how the obstruction fixes a non-uniform hidden-
region scaling.  It is also the example connected to the public HRF statement
in arXiv:2607.15126.

The companion `08_Current_5pt_MRK_CentralSoft.nb` studies a composite
central-soft multi-Regge limit on the same topology.  It records the complete
edge-flow reconstruction, the light-cone pinch that fixes the restricted
support, the resulting Glauber loop, and matching parameter- and
momentum-space power counts.

## Search completeness and user-visible budgets

The correctness-sensitive search budgets are public `findObstructions`
options and are echoed in every result through
`"EffectiveSearchConfiguration"`.  A result also reports
`"SearchTruncatedQ"`, `"HiddenRegionSearchCompleteQ"`, and the associated
generator/factor audits.  The notebooks expose an exploratory finite profile
for finding witnesses and a certified profile with unbounded candidate and
two-generator-union budgets.  A truncated or timed-out scan is classified as
`unresolved`, never as an absence certificate.

The default complete cancellation-factor construction factorises the full
primitive derivatives and channel polynomials.  The historical signed-
monomial-pair enlargement is retained only as an opt-in legacy diagnostic.

## Compatibility boundary

The historical term survives only in deprecated loader, symbol, option, and
stored-fixture keys needed to reproduce earlier runs.  It is not used for new
algorithm names, notebooks, output filenames, or explanatory text.

## Validation represented by this release

- polynomial cancellation factors and base HRF: 31/31;
- exact complete-polynomial-factor coverage: 2/2;
- Crown/HyperCrown momentum reconstruction: 16/16;
- layered DSC/NMRK certification: 16/16;
- alignment compatibility: 6/6;
- six-point notebooks: 17/17;
- explicit three-generator near-planar interface: 6/6;
- candidate-specific derivative-ideal saturation: 13/13;
- Crown/Regge/five-point notebook controls: 7/7;
- wide-angle face/pinch controls: 8/8;
- wide-angle codimension-two audit engine: 6/6;
- Regge interior controls: 7/7;
- Regge boundary controls: 9/9.

The collaborator-facing physics records are identified in the top-level
`README.md`.  The exact release checks are recorded in
`RELEASE_CHECKS_20260731.md`.
