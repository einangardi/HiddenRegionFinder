# HiddenRegionFinder — collaboration bundle

Self-contained Mathematica material for reproducing the hidden-region case studies discussed in the project notes. This directory is intended for sharing with collaborators and eventual publication on GitHub.

## Contents

| File | Role |
|------|------|
| `HiddenRegionFinder.wl` | Core library: Symanzik polynomials, factor discovery, obstruction scans, scaling tests |
| `HRF_FinalLogicPatch.wl` | Reporting conventions (hidden-region criteria, SuperLeading (SL) (or Complement) sector for exact reductions) |
| `HRF_Example01Common.wl` | Shared compact-display helpers |
| `HRF_Example01Reporting.wl` | Example 01 region-study tables |
| `HRF_Example02ReggeKinematics.wl` | Three Regge channels T23, T12, T13 |
| `HRF_Example02Reporting.wl` | Wide vs Regge comparison tables and display helpers |
| `HRF_FivePointReporting.wl` | Example 03 topology/region summary tables |
| `01_WideAngle_2to2_OffShell.wl` | Wide-angle 4-point examples |
| `02_Forward_Regge_2to2_Massless.wl` | Regge-limit 4-point examples |
| `03_FivePoint_Spacelike_Collinear.wl` | Spacelike collinear 5-point topology scan |

## Notebooks (evaluate in order within each notebook)

1. **`00_Pedagogical_HiddenRegion_Algorithm.nb`** — Step-by-step walk-through of the algorithm layers (graph → U/F, cancellation factors, generators, obstructions, scaling).

2. **`01_WideAngle_4pt.nb`** — Crown, SuperCrown, HyperCrown, Diving Beetle in wide-angle massless kinematic (on-shell expansion).

3. **`02_ReggeLimit_4pt.nb`** — Same topologies compared with wide-angle vs three Regge channels.

4. **`03_SpacelikeCollinear_5pt.nb`** — Seven- and eight-propagator descendants; tables use `TopologyHiddenRegionTable*` / `TopologyRegionScalingTable*` (Dataset displays).

## Column glossary (Example 01 channel table)

- **Obstruction decomposition succeeded?** — whether a binary obstruction subset was found in that Mandelstam channel basis (necessary but insufficient condition for “hidden region identified”).

## Quick start

Place all files in one directory. In Mathematica:

```wl
SetDirectory["/path/to/HiddenRegionFinder_share"]
Get["HiddenRegionFinder.wl"]
Get["02_Forward_Regge_2to2_Massless.wl"]
hrfEx02InteriorComparisonDisplay["Crown"]
```

Or open a notebook and evaluate cells from the top.

## Runtime notes

- Example 01 with full HyperCrown boundary scans (~15 strata) takes a few minutes.
- Example 02 with HyperCrown boundaries takes ~2–3 minutes.
- Example 03 performs a full topology scan on load; allow several minutes on first evaluation.

Set `$HRFScalingReport = False` and `$HRFExample01Report = False` (or the Example 02/03 analogues) for quieter output.

## What is not included

This bundle deliberately omits development-only patches, debug notebooks, README patch notes, and legacy compatibility layers from the active development tree.

**Next development** (branch `HiddenRegionFinder_polynomial_factors/`): extend cancellation factors beyond binomial \(f_k\) to signed polynomial combinations (footnote 4), with regression checks on existing examples and targeted searches on HyperCrown \(\{x11\}=0\) and `ThreeLoopVertexInternalLines`.

## Requirements

- Wolfram Mathematica 12+ (tested on 14.x)
- No external packages beyond this directory
