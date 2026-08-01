# Maintainer notes

The top-level `README.md` is the collaborator-facing entry point.  This file
records the smaller set of conventions needed when extending or rebuilding
the release.

## Naming

Use **asymptotic-order alignment** in new code and documentation.  Canonical
symbols begin with `hrfAsymptoticOrderAlignment`, and canonical options begin
with `AsymptoticOrderAlignment`.  The former names are maintained only by
explicit compatibility shims and tests.

## Portable paths

All executable files resolve inputs from `DirectoryName[$InputFileName]` or
`NotebookDirectory[]`.  Do not introduce absolute paths.  Permanent compact
inputs belong under `data/`; frozen full regression fixtures belong under
`testdata/`; fresh expensive outputs belong under `results/generated/`.

## Six-point rebuild

```sh
wolframscript -file rebuild_split_asymptotic_order_alignment_notebooks.wl
```

This rebuilds only the canonical NMRK and DSC notebooks and refreshes their
compact certificates in `results/nmrk_wz/` and `results/dsc/`.  Cross-limit
physics belongs in `NMRK_DSC_Kinematic_and_HRF_Comparison.tex`.

## Four-point Crown family

`01_Current_WideAngle_4pt.nb` and `02_Current_Regge_4pt.nb` are principal
positive physics records.  Their source scripts are
`01_WideAngle_2to2_OffShell.wl` and
`02_Forward_Regge_2to2_Massless.wl`.  They must remain paired with the two
No-Crown audit notebooks in the collaborator-facing presentation:

- notebooks 01 and 02 record the positive Crown interior and the inherited
  SuperCrown/HyperCrown boundary regions;
- the wide-angle and Regge No-Crown audits test the complementary “only if”
  direction on the 16 four-loop graphs without a Crown contraction minor.

Do not treat the boundary examples as auxiliary tests.  They demonstrate the
physical reason contraction strata are part of the HR search: the parent
topology may inherit the Crown region only on the boundary that exposes the
minor.  Changes to boundary enumeration, polynomial cancellation factors, or
Regge channel mappings must be checked against notebooks 01 and 02 as well as
the negative audits.

The completed No-Crown codimension-two audit is deliberately generator first.
`HRF_WideAngle16Codim2Audit.wl` constructs the 1200-stratum manifest and the
ordinary HRF decision problem; it does not enumerate Newton faces before
generator construction.  The 188 strata containing `x8` retain their legacy
provenance, while the complementary 1012 use atomic per-stratum checkpoints
under `results/generated/wa16_codim2/`.  A bounded two-worker reproduction is:

```sh
wolframscript -file HRF_RunWideAngle16Codim2Batch.wl 0 2 600 60 1 10 MissingOrUnresolved
wolframscript -file HRF_RunWideAngle16Codim2Batch.wl 1 2 600 60 1 10 MissingOrUnresolved
```

Run the two commands in separate terminals.  Then use
`HRF_WideAngle16Codim2CoverageSummary.wl` to require readable, metadata-matched
outputs and to write the compact tracked aggregate.  Missing, unreadable,
truncated, or positivity-undecided rows never count as NoHR.

## Five-point spacelike-collinear application

`03_Current_SpacelikeCollinear_5pt.nb` is a principal physics record, not a
regression-only notebook.  `04_Current_5pt_Preselection.nb` supplies its
topology-preselection stage.  The canonical scripted entry points are:

```sh
wolframscript -file HRF_RunExample03PolynomialDescendantScan.wl
wolframscript -file HRF_RunPreselected5ptScan.wl
```

When changing cancellation-factor discovery, generator construction, or
scaling determination, keep these notebooks and the five-point section of
`docs/Hidden_Region_Finder_Principles_JHEP.tex` synchronized.  The defining
interpretation is `F_0 = F_SL + F_Obs`: the factorised superleading sector
vanishes at the pinch, while the obstruction fixes the non-uniform HR
scaling.  This application underlies the public HRF statement in
arXiv:2607.15126.

## Layered certification

The final post-alignment check resolves the occupied layers of the complete
Lee--Pomeransky polynomial in the cancellation ideal.  It fixes the
cancellation depth and uniform alignment ambiguity in the original
coordinates.  Local dissection is the necessary-and-sufficient fallback when
the ideal-jet system is unavailable or non-unique.

Run the focused regression with:

```sh
wolframscript -code 'Get["HRF_LayeredDissectionRegressionTests.wl"]; Print[InputForm[hrfRunLayeredDissectionRegressionTests[]["Summary"]]]'
```

## Candidate-specific ideal saturation

Do not use a saturated full-gradient ideal as a pre-decomposition fallback.
When `F_star = F_SL + F_Obs`, derivatives of `F_Obs` generally remain nonzero
on the HR locus.  The ordinary derivative harvest only inspects candidate
factors and independent kinematic sectors.

Use `"DerivativeFactorHarvestMode" -> "SaturatedLeadingIdeal"` only after the
supplied polynomial has been identified as the complete leading cancellation
sector, together with `"FullGradientSaturationJustifiedQ" -> True`.  If only
particular derivative-sector relations are intended, pass them through
`"FactorHarvestDerivativePolynomials"` instead.  The regression
`HRF_GeneralizedDerivativeHarvestTests.wl` must retain both the positive
five-point/Crown controls and the negative applicability-guard test.

The current conceptual source is
`docs/Hidden_Region_Finder_Principles_JHEP.tex`.  Keep its positive-pinch,
dissection and five-point power-counting discussions synchronized with the
five-point audit notebook.

## Large two-loop recertification

Fresh full DSC scans are created under `results/generated/`.  To recertify a
large saved scan by structural representative in separate kernels:

```sh
wolframscript -file HRF_PrepareLayeredDSCRecertification.wl hexbox
wolframscript -file HRF_RecertifyLayeredDSCRow.wl hexbox 1
wolframscript -file HRF_CombineLayeredDSCRows.wl hexbox
```

Repeat the row command through the representative count before combining.

## Release checks

Before committing:

1. run the canonical alignment compatibility and notebook tests;
2. run the polynomial, layered, wide-angle, and Regge regression suites;
3. parse every modified `.wl` and `.nb` file with `SyntaxQ`;
4. search tracked text for user-specific absolute paths;
5. require `git diff --check` and `git status --short` to be clean after the
   release commit.
