# Release provenance

Release consolidation date: 2026-07-24

This repository consolidates the HRF development line used for the five-point
spacelike-collinear, double-spacelike-collinear, `w=z` NMRK, four-loop
wide-angle, and four-loop Regge studies.  The canonical name of the
composite-limit preprocessing step is **asymptotic-order alignment**.

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
derivative-factor length cap, and complete four-loop No-Crown audits.

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
Fresh expensive scans write to `results/generated/`, which is ignored by Git.

## Four-point Crown/no-Crown program

The principal positive four-point records are
`01_Current_WideAngle_4pt.nb` and `02_Current_Regge_4pt.nb`.  They establish
the Crown as an interior HR seed and show, through the SuperCrown and
HyperCrown examples, why boundary strata must be searched when the Crown is a
contraction minor of a larger topology.  The Regge notebook follows the
positive examples through all three channels where applicable.

`WideAngle16_NoCrown_HRF_Audit.nb` and
`WideAngle16_NoCrown_Regge_HRF_Audit.nb` are the complementary negative
records.  They test the “only if” direction on the 16 four-loop mixed-sign
graphs without a Crown contraction minor.  The release therefore preserves
both sides of the observed Crown-minor criterion, as well as the positive and
negative evidence for the wide-angle-to-Regge correspondence.

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

## Compatibility boundary

The historical term survives only in deprecated loader, symbol, option, and
stored-fixture keys needed to reproduce earlier runs.  It is not used for new
algorithm names, notebooks, output filenames, or explanatory text.

## Validation represented by this release

- polynomial cancellation factors and base HRF: 29/29;
- layered DSC/NMRK certification: 16/16;
- alignment compatibility: 6/6;
- six-point notebooks: 17/17;
- Crown/Regge/five-point notebook controls: 7/7;
- wide-angle face/pinch controls: 8/8;
- Regge interior controls: 7/7;
- Regge boundary controls: 9/9.

The seven collaborator-facing physics records are identified in the top-level
`README.md`.
