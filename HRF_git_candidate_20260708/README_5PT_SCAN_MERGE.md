# Five-point preselected scan merge notes

Created on 2026-06-22 as a non-destructive merge directory for the next stage:
running the current HRF algorithm on the finalized set of preselected
five-point topologies.

## Source branches

Base directory:

```text
/Users/gardi1/Edinburgh/HRF/HiddenRegionFinder_polynomial_factors_dev
```

This is the source of truth for the HRF algorithm and documentation:

- `HiddenRegionFinder.wl`
- `HRF_PolynomialCancellationFactors.wl`
- `HRF_GeneratorPhysicsFilter.wl`
- `HRF_KinematicGeneratorPresets.wl`
- `HRF_FinalLogicPatch.wl`
- `HRF_Example01Common.wl`
- `HRF_Example01Reporting.wl`
- `HRF_Example02ReggeKinematics.wl`
- `HRF_Example02Reporting.wl`
- `HRF_Example03CollinearCore.wl`
- `HRF_Example03SeedStudy.wl`
- `HRF_PolynomialFactorReporting.wl`
- `HRF_PolynomialFactorRegressionTests.wl`
- `README.md`
- `README_DEV.md`
- `ALGORITHM_CHANGELOG.md`
- `PIPELINE_CONDITIONS.md`

Preselection source directory:

```text
/Users/gardi1/Edinburgh/HRF/HiddenRegionFinder_polynomial_factos-Codex-preselection
```

Only the finalized five-point preselection pieces were overlaid:

- `HRF_PinchPreselection.wl`
- `HRF_InteriorDerivativePreselection.wl`
- `HRF_RecursiveDerivativePreselection.wl`
- `rebuild_recursive_derivative_preselection_notebook.wl`
- `07_RecursiveDerivativePreselection.nb`
- `planarDiagram.txt`
- `nonplanarDiagram.txt`
- `RecursiveDerivativePreselectionCandidates.csv`
- `RecursiveDerivativePreselectionHandoff.csv`
- `RecursiveDerivativePreselectionHandoff.wl`
- `RecursiveDerivativePreselectionReference03.csv`
- `RecursiveDerivativePreselectionReference03Matches.csv`
- `RecursiveDerivativePreselectionScan.csv`

## Conflict policy

Where filenames existed in both branches, this merge keeps the
`HiddenRegionFinder_polynomial_factors_dev` version.  The preselection branch
had older copies of the core HRF algorithm files, so those were not used.

The preselection files are intentionally separate modules and should not patch
or overwrite the HRF algorithm.  They provide an input/handoff list for the
future scan driver.

## Preselection summary

The recursive derivative preselection works in the Example 03
spacelike-collinear domain

```wl
-1 < x < 0,  z > 1
```

with external convention

```wl
{{p1, 1}, {p2, 2}, {p3, 3}, {p4, 4}, {p5, 5}}
```

For each listed topology, `F0` is computed and a recursive derivative sign test
is applied.  If a derivative has only one sign in the physical domain, the
corresponding Feynman parameter is temporarily set to zero and the test repeats
on the restricted polynomial.  A graph is kept if the recursion reaches a
stratum where all remaining active derivatives have mixed signs.

The recorded `PreselectionZeroVars` are diagnostic only.  They explain why the
preselection kept the graph, but they are not an instruction to run HRF on a
contracted boundary graph.  The HRF scan should receive the original
`InternalLines` and `ExternalLines`.

After preselection, candidates are quotiented by:

1. internal propagator-name relabelling;
2. graph isomorphism with fixed external labels;
3. the generic exchange `p4 <-> p5`, with `p1`, `p2`, and `p3` fixed.

The resulting handoff list has 70 representative topologies.

## Next development target

Build a scan driver that reads `RecursiveDerivativePreselectionHandoff.wl` or
`.csv`, feeds each original graph through the current HRF algorithm, and records
whether the graph has:

- an interior hidden region;
- a boundary hidden region;
- both;
- or no hidden region found.

Do not launch that scan as part of this merge.  This directory is the starting
point for that development.
