# Release provenance

Release consolidation date: 2026-09-15

This directory is the shareable HRF snapshot assembled from the 31 July 2026
asymptotic-order-alignment release and the validated code, notebooks and
compact certificates added through 15 September 2026.  The implementation
files remain beside the top-level notebooks, as in the earlier public
bundles.  Specialised example notebooks retain their supporting files in the
same example directory and use only relative paths to the release root.

## Consolidated development line

The baseline is `HiddenRegionFinder_AsymptoticOrderAlignment_20260731` after
its 21--22 August source-aware certification updates.  The principal core
files are:

- `HiddenRegionFinder.wl` for ordinary HRF, boundary handling, obstruction
  construction and scaling;
- `HRF_AsymptoticOrderAlignment.wl` for composite kinematic limits;
- `HRF_IdealLayerCertification.wl` for the original-coordinate occupied-layer
  analysis;
- `HRF_SourceAwareDissectionCertification.wl` for source-resolved local
  dissection and exact pullback;
- `HRF_MomentumScalingReconstruction.wl` and
  `HRF_WideAngleMomentumReconstruction.wl` for momentum-space reconstruction.

No experimental candidate copy from the parent working directory replaces
these files.  Generated scan directories, editor metadata and TeX auxiliary
files are excluded.

## New records since the July release

Notebooks 09--12 provide the exhaustive Part-II/dissection analysis of three
two-loop zero-recoil NMRK topologies.  Their compact records are under
`results/nmrk_wz/`:

- the planar hexagon--box has 13 staged candidates, all completely
  dissected, giving 25 physical HRs after deduplication;
- the same-path hexagon--pentagon has eight staged candidates, all completely
  decided, four of which produce nine physical HRs;
- the separate-path hexagon--pentagon has no staged candidate;
- the comparison record distinguishes candidate presentations, local facet
  certificates and physical HR classes.

The six-point wide-angle self-crossing notebook and its exact audit live in
`examples/six_point_wide_angle_self_crossing/`.  The release root also
contains the exact `K_{3,3}` and `K_{4,3}` topology audits and the resolved
single-/double-collinear cross-ratio map check used in the paper.

## Source-aware certification status

The aligned NMRK/DSC pipeline uses source-aware dissection as its final
certificate.  The saved-assumption audit recertifies the six formerly
promoted accepted representatives and returns 17 exact local facets, with no
observed deeper cancellation.

The ordinary HRF integration also records source-aware certification status.
Its generic endpoint-chart implementation is deliberately conservative: an
unsupported, capped or incomplete chart cover is `unresolved`, never a
negative certificate.  Some older Crown and five-point notebook controls use
dedicated exact coverage and dissection constructions that are not equivalent
to an exhaustive run of this generic endpoint-chart routine.  The historical
`HRF_NotebookSmokeTests.wl` is therefore retained for provenance but is not a
release gate; the focused mathematical suites and evaluated physics notebooks
are authoritative for this snapshot.

The candidate-specific derivative-harvest suite also contains a Crown negative
control.  It substitutes `s12=1, s23=-1` before harvesting, thereby mixing the
two independent kinematic sectors; the resulting two relations correctly do
not yield a complete Crown presentation.  This does not test the dedicated
Crown construction, which separates the derivative components multiplying
`s12` and `s23` before factorisation and thereby obtains the four cancellation
factors and two product generators.  With this distinction made explicit, all
13 checks in the derivative-harvest suite pass.

## Portable inputs and outputs

Portable graph and kinematic inputs are stored under `data/`; frozen full
regression fixtures are under `testdata/`; compact exact certificates are
under `results/`.  Fresh expensive scans write to `results/generated/`, which
is intentionally absent from the bundle.

The current manuscript source, bibliography, JHEP style files, compiled
bibliography and PDF are stored under `docs/`.  The standalone NMRK/DSC
comparison note is retained at the release root and under `output/pdf/` in the
same form as the preceding release.

## External requirements

The release was checked with Wolfram Language 15.0.1.  Exact facet
enumeration requires `cddexec` from `cddlib`; the code searches the executable
path and falls back to `/usr/local/bin/cddexec`.  Missing external software or
an exhausted explicit budget is reported as unresolved.

The implementation and examples presently assume massless internal
propagators.  Massive internal lines require the separate extension discussed
in the manuscript outlook.
