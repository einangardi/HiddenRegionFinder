# Release notes — v2025.06.22

Frozen snapshot for GitHub distribution. Source export from `HiddenRegionFinder_polynomial_factors` (June 2025).

## Highlights

### Obstruction search (major)

- **Primary path:** `hrfObstructionFromGeneratorVanishing` — decompose \(F_0 = F_{SL} + \mathrm{Obs}\) by ideal quotient (`PolynomialReduce`) with \(F_{SL} \in \langle g_i\rangle\).
- **Derivative check:** \(\partial_i F \equiv \partial_i \mathrm{Obs} \pmod{f_k}\) on each generator factor vanishing locus (`hrfObstructionDerivativeConsistentQ`).
- **Removed from obstruction path:** `FindInstance` on binary remainder coefficient equations.
- **Fallbacks:** meet-in-the-middle mod factors (single generator); bounded monomial-subset enumeration (`$HRFObstructionAlgebraicSearchLimit` = 500000).

### ThreeLoopVertex collinear

- One admissible generator \(g = f_a f_b\) (Collinear5pt / SingleProduct).
- \(F_{SL} = -s\,g\) (24 terms); obstruction = 8-term ideal remainder.
- Scaling vector `{-2,-1,-2,-2,-2,-1,-2,-2,-2}` accepted by `findCoverageLPScaling`.

### Seed5pt collinear

- 2-term obstruction, 6-term \(F_{SL}\) via same primary path (subset search had failed).

### Other

- `$HRFPolynomialMaxMonomials = Automatic` — dynamic cap from raw harvest per \(F_0\).
- `MaxObstructionTerms = |F| - 1` (generator monomial count no longer subtracts).
- Ex03 vertex path: `UseExtendedFactors -> False` for Collinear5pt; `hrfPolyFivePointGeneratorStats` Lookup fix.
- `hrfInspectThreeLoopVertexGenerators.wl` — vertex harvest / pair audit / scaling diagnostic.

## Excluded from this bundle

- Scratch notebooks (`*_after_reset*`, `*_first_run*`, `*_polyrun*`, `*_Yao_comparison*`)
- Internal verify scripts (`_verify_*.wl`, `_test_*.wl`)
- Legacy duplicate `Wide-angle 4-point examples.nb`

## Regression

```wl
Get["HRF_PolynomialFactorRegressionTests.wl"]
hrfRunPolynomialFactorRegressionTests[]
```

## Next development

Active work moves to `HiddenRegionFinder_polynomial_factors_dev/` (sibling directory under `HRF/`).
