# HiddenRegionFinder — polynomial cancellation factors (footnote 4)

**Active development** (June 2025+). Frozen collaborator bundle: [`../HiddenRegionFinder_v2/`](../HiddenRegionFinder_v2/) (GitHub-ready).

Extends cancellation-factor discovery beyond binomial \(f_k\) to **signed polynomial** combinations that vanish in the prescribed kinematic domain with \(x_i > 0\).

**Algorithm summary:** see [`ALGORITHM_CHANGELOG.md`](ALGORITHM_CHANGELOG.md) (Adaptive generator mode, physics filter, **generator-vanishing obstruction**, performance defaults).

**Pipeline conditions (stage-by-stage, by kinematic setup):** see [`PIPELINE_CONDITIONS.md`](PIPELINE_CONDITIONS.md) — raw `f_k` harvest, safe pool, generator eligibility, pair rules, obstruction gates; wide-angle vs Regge vs collinear 5pt.

## Design principles

1. **Track every new \(f_k\)** — `hrfPolynomialFactorAudit` and `hrfPolyFactorAuditTable` list raw candidates, accepted factors, and reject reasons.
2. **Track generators** — `hrfPolyGeneratorAuditTable` reports candidate generator sets, accepted sets, and discards (per-generator failure, SL-sector failure, no obstruction).
3. **Kinematic-domain acceptance** — by default `$HRFPolynomialRequireKinematicDomainQ = True` (alias `$HRFPolynomialRequireOpenKinematicStratum`) requires a `FindInstance` witness: factor \(f_k=0\) with all \(x_i>0\) and kinematics in the prescribed domain. Acceptance is monotone under domain restriction. Disable only for debugging:
   ```wl
   $HRFPolynomialRequireKinematicDomainQ = False;
   ```
4. **Primitive factors** — overall monomial \(x_i\) content is stripped from candidates (`hrfPrimitiveCancellationFactor`) so audit tables show the core binomial/polynomial only.
5. **Regression first** — Crown and Seed5pt hidden-region signatures must stay stable under polynomial extension and physics filtering.

## Load order

```wl
SetDirectory[".../HiddenRegionFinder_polynomial_factors"]
Get["HiddenRegionFinder.wl"]
Get["04_PolynomialFactor_Regression.wl"]   (* loads polynomial patch + reporting *)
Ex04PolynomialRegressionTable
Ex04PolynomialRegressionNarrative
```

Regression tests (fast, ~3 min). **Run from the Ex04 notebook** (recommended) or:

```wl
(* notebook: paths resolve via NotebookDirectory[] / $InputFileName *)
Get["HRF_PolynomialFactorRegressionTests.wl"]
hrfRunPolynomialFactorRegressionTests[]
```

Path resolution uses `$InputFileName` when the `.wl` file is `Get` directly, else `NotebookDirectory[]`, via `hrfPackageDirectory[]` / `$HRFTestDirectory`. Do **not** rely on `Directory[]` (often `$HomeDirectory` in a fresh session).

Or stepwise:

```wl
Get["HRF_PolynomialCancellationFactors.wl"]
Get["HRF_PolynomialFactorReporting.wl"]
```

## Key symbols

| Symbol | Role |
|--------|------|
| `$HRFUsePolynomialCancellationFactors` | toggle polynomial vs binomial mode (dynamic routing) |
| `$HRFPolynomialMaxMonomials` | max monomials per polynomial \(f_k\) (`Automatic` = from raw harvest per F0; set an explicit integer to cap) |
| `$HRFPolynomialRequireKinematicDomainQ` | `FindInstance` kinematic-domain check on **cancellation factors** (default True; not used in obstruction search) |
| `$HRFObstructionAlgebraicSearchLimit` | fallback subset-search node cap (default 500000) |
| `hrfObstructionFromGeneratorVanishing` | primary obstruction: ideal quotient \(F = F_{SL} + \mathrm{Obs}\) + derivative consistency on \(\{f_k=0\}\) |
| `$HRFUseGeneratorPhysicsFilterQ` | kin pairing, span dedup, sector quotient (default True) |
| `$HRFCandidateGeneratorSetLimit` | cap pair-sector trials (default 64) |
| `findObstructions[..., "GeneratorMode" -> "Adaptive"]` | default: single + multi-sector candidates |
| `hrfPolynomialFactorAudit[F, vars, ka, kv]` | binomial vs polynomial factor diff |
| `hrfFilterFactorsForGeneratorPhysics[ff, vars, kv, bounds]` | physics-eligible factor pool |
| `HRF_Example03CollinearCore.wl` | lightweight seed + ThreeLoopVertex (no 7/8-prop scans) |
| `hrfRunPolynomialFactorRegressionTests[]` | Crown + Seed5pt regression suite |

## Target cases

- **Crown** interior (4pt): 36 polynomial \(f_k\), 26 physics-eligible; **two** generators, `{{s12,-s23},0}`
- **HyperCrown** boundary `{x11} -> 0`
- **Seed5pt** vs **ThreeLoopVertex** collinear interior (`HRF_Example03CollinearCore.wl`)

### ThreeLoopVertex inspect (`hrfInspectThreeLoopVertexGenerators.wl`)

Uses **Collinear5pt / SingleProduct** (not Adaptive + extended harvest). With `$HRFPolynomialMaxMonomials = Automatic` (default), the effective cap is taken from the raw derivative-factorization pool (vertex factors can have up to ~12 monomials after `x6,x7,x8` grouping).

| Function | Purpose |
|----------|---------|
| `hrfThreeLoopVertexHarvestAudit[]` | Raw derivative factors + reject reasons |
| `hrfThreeLoopVertexGeneratorPairAuditTable[]` | Full pair gate (kin + PDF + degree + F0 + Mandelstam) |
| `hrfThreeLoopVertexCandidateTable[]` | All of the above + selection table |

If `ListedPairCount -> 0` after Mandelstam fix: safe pool may have ≥2 `f_k` but no pair with linear kin content in the product — inspect harvest audit and consider whether vertex `F0` needs a different factorization strategy.

### Obstruction search (2025-06)

The obstruction step decomposes \(F_0 = F_{SL} + \mathrm{Obs}\) with \(F_{SL} \in \langle g_i\rangle\) exactly (`PolynomialReduce` remainder zero).

| Method | When | Function |
|--------|------|----------|
| **Generator vanishing (primary)** | Always tried first | `hrfObstructionFromGeneratorVanishing` — ideal quotient \(F = q\,g + \mathrm{Obs}\); checks \(\partial_i F \equiv \partial_i \mathrm{Obs} \pmod{f_k}\) on factor vanishing loci |
| Meet-in-the-middle | Single generator, quotient fails | `hrfObstructionAlgebraicSearchPrincipalMeetInMiddle` — subset-sum of remainders mod each factor \(f_k\) |
| Subset enumeration | Last resort | `hrfObstructionAlgebraicSearch` — bounded scan over monomial subsets |

**Not used:** `FindInstance` on remainder coefficient equations (removed).

**ThreeLoopVertex (collinear):** one generator \(g = f_a f_b\); \(F_{SL} = -s\,g\) (24 terms), \(\mathrm{Obs}\) = 8-term remainder; scaling vector `{-2,-1,-2,-2,-2,-1,-2,-2,-2}`.

**Seed5pt:** 2-term \(\mathrm{Obs}\), 6-term \(F_{SL}\); same primary path.

## Notebook

`04_PolynomialFactor_Regression.nb` — regression table, factor/generator audits, 5pt seed vs vertex comparison.

## Five-point preselection merge

This directory is the merged working tree for the next stage: applying the
current HRF algorithm to the preselected five-point topology list.

Merge rule used here:

- The HRF algorithm, notebooks for wide-angle/regge studies, generator presets,
  obstruction logic, and algorithm notes come from
  `HiddenRegionFinder_polynomial_factors_dev`.
- The five-point topology preselection code, topology input lists, and final
  70-row candidate handoff come from
  `HiddenRegionFinder_polynomial_factos-Codex-preselection`.

The preselection is deliberately a loose filter.  It decides which listed
topologies are worth sending to HRF, but it does not decide whether the eventual
hidden region is interior or boundary.  The variables recorded as
`PreselectionZeroVars` are diagnostic provenance for the recursive derivative
test only; HRF should receive the original listed graph.

Preselection inputs:

- `planarDiagram.txt`
- `nonplanarDiagram.txt`

Preselection implementation and inspection notebook:

- `HRF_PinchPreselection.wl`
- `HRF_InteriorDerivativePreselection.wl`
- `HRF_RecursiveDerivativePreselection.wl`
- `07_RecursiveDerivativePreselection.nb`
- `rebuild_recursive_derivative_preselection_notebook.wl`

Final preselection outputs:

- `RecursiveDerivativePreselectionCandidates.csv`
- `RecursiveDerivativePreselectionHandoff.csv`
- `RecursiveDerivativePreselectionHandoff.wl`

The final post-selected list contains 70 representative topologies.  Candidates
are quotiented by internal propagator-name relabelling and by the generic
external-label exchange `p4 <-> p5`, while keeping `p1`, `p2`, and `p3` fixed.
The list is ordered with the 16 Example 03 reference graphs first, followed by
remaining planar representatives and then remaining nonplanar representatives.

Do not start HRF scans automatically from this merge point.  The next task is
to build the five-point scan driver that feeds these 70 original graphs through
the current HRF algorithm and classifies them as interior, boundary, or no
hidden region.

Detailed merge provenance is recorded in `README_5PT_SCAN_MERGE.md`.

## Status

Polynomial factors, generator physics filter, Adaptive mode, primitive-factor cleanup, FindInstance kinematic acceptance (factor pool only), lightweight 5pt core, **generator-vanishing obstruction decomposition**, dynamic `$HRFPolynomialMaxMonomials`, and `hrfRunPolynomialFactorRegressionTests[]` are in place.

ThreeLoopVertex collinear interior: obstruction + scaling confirmed with `hrfInspectThreeLoopVertexGenerators.wl` and Ex04 harness (`Collinear5pt` / `SingleProduct`).
