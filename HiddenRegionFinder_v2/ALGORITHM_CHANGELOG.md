# Polynomial-factor branch — algorithmic changelog

Summary of changes relative to the shared `HiddenRegionFinder` baseline and the PDF (footnote 4 / §5.12) obstruction recipe. Use this when updating the paper or revisiting design decisions.

## 1. Polynomial cancellation factors (footnote 4)

- **Beyond binomial \(f_k\):** signed polynomial combinations (up to `$HRFPolynomialMaxMonomials`, default Automatic from raw harvest) from derivative factorization, whole-derivative polynomials, and signed monomial pairs.
- **Primitive stripping:** `hrfPrimitiveCancellationFactor` removes shared \(x_i\) monomial content before audit and pairing.
- **Kinematic-domain acceptance:** `$HRFPolynomialRequireKinematicDomainQ` (default `True`) requires a `FindInstance` witness with all \(x_i>0\) and kinematics in the prescribed domain.
- **Dynamic routing:** `hrfInstallPolynomialCancellationPatch[]` patches `safeCancellationFactors*` so binomial and polynomial modes compare in one session (`$HRFUsePolynomialCancellationFactors`).

## 2. Generator physics filter (`HRF_GeneratorPhysicsFilter.wl`)

- **Kin × kin forbidden:** two factors both containing kinematic variables cannot form a pair generator.
- **Kin-mixed + kin-free pairing:** requires disjoint \(x\)-support and kin-free partner total \(x\)-degree \(\le \deg F - \deg_x(f_k)\).
- **Span-redundant kin-mixed factors dropped:** each kin-mixed \(f_k\) is decomposed in `kinVars`; if every \(x\)-sector lies in the \(\mathbb{Q}\)-span of kin-free factors (`PolynomialReduce` in \(x\) only), the factor is dropped from generator candidacy.
- **Mandelstam linearity per \(f_k\):** each term has total exponent \(\le 1\) in each kinematic variable (no \(s_{12}^2\), etc. inside a single factor).
- **Sector quotient at preparation:** kin-free pair generators are canonicalized mod \(\mathrm{span}\{B, k_a B\}\) (module basis over kin-free \(x\)-polynomials \(B\)), collapsing redundant presentations before obstruction search.
- **Toggle:** `$HRFUseGeneratorPhysicsFilterQ` (default `True`).

## 3. Adaptive generator mode (new default)

- **`candidateGeneratorSetsAdaptive`** unions:
  - **Single-sector:** `{f_{i_1}\cdots f_{i_k}}` for simultaneously admissible subsets (sizes \(2\ldots\)`$HRFMaxProductSubsetSize`, default 3);
  - **Multi-sector:** pair-sector sets from `candidateGeneratorSetsDiagnostic` (Crown-style).
- **`findObstructions` default:** `"GeneratorMode" -> "Adaptive"` (was `"SingleProduct"`).
- **Selection:** among valid trials, prefer **more generators**, then **smaller obstruction** (`hrfObstructionTrialRank`). With `StopOnFirstAdmissible -> True`, all trials at the maximum generator count are scanned first; the best valid trial at that count is taken before falling back to fewer generators.
- **Obstruction size:** no fixed cap. For each F, `MaxObstructionTerms = |F terms| - 1` (at least one monomial left for F_SL). Automatic/`Infinity` use that bound; an explicit numeric `maxSize` only raises it, never lowers it. Generator monomial count does not subtract from this bound.
- **Hidden-region acceptance (when `U` is supplied):** scaling is evaluated on every valid obstruction trial; `HiddenRegionScans` lists all scaling-positive sets.
- **Bugfix:** replaced `Flatten` on nested generator-set lists with `Join @@ Table[...]` so `{ {g} }` structure is preserved.

## 3b. Obstruction search — generator vanishing (2025-06)

Replaces `FindInstance` on binary remainder equations and blind monomial-subset search as the **primary** obstruction path.

### Mathematics

For generator(s) \(g_i\) with \(g = \prod_k f_k\) (pair-sector case: one \(g = f_a f_b\)):

\[
F_0 = F_{SL} + \mathrm{Obs}, \quad F_{SL} \in \langle g_i\rangle.
\]

**Primary algorithm (`hrfObstructionFromGeneratorVanishing`):**

1. **Ideal quotient** — `PolynomialReduce[F, {g_i}, allVars]` gives \(F_{SL} = \sum q_i g_i\) and remainder \(\mathrm{Obs}\).
2. **Derivative consistency** — on \(\{f_k = 0\}\), terms from \(\partial_i(q\,g)\) vanish; require \(\partial_i F \equiv \partial_i \mathrm{Obs} \pmod{f_k}\) for each Symanzik \(x_j\) (implemented via `hrfRestrictPolynomialModFactors`).

**Fallbacks** (only if quotient path returns `Missing`):

| Fallback | Function | Role |
|----------|----------|------|
| Meet-in-the-middle | `hrfObstructionAlgebraicSearchPrincipalMeetInMiddle` | Single \(g\): subset-sum of per-term remainders mod each \(f_k\) |
| Bounded subset scan | `hrfObstructionAlgebraicSearch` | Enumerate \(\mathrm{Obs}\) by increasing \(\|\mathrm{Obs}\|\); cap `$HRFObstructionAlgebraicSearchLimit` (default 500k) |

**Removed:** `hrfObstructionBinarySearchInstance` / `FindInstance` on remainder coefficient equations (retained in file but unused).

### Validated cases

| Case | \(F_{SL}\) | \(\mathrm{Obs}\) | Scaling |
|------|-----------|------------------|---------|
| **Seed5pt** | 6 terms in \(\langle g\rangle\) | 2 terms | `{-2,-1,-2,-2,-2,-1}` |
| **ThreeLoopVertex** | \(-s\,g\) (24 terms) | 8-term remainder | `{-2,-1,-2,-2,-2,-1,-2,-2,-2}` |

**Why subset search failed on vertex:** \(F_{SL} = -s\,g\) is not a sum of original \(F_0\) monomials with per-term vanishing mod \(f_k\); cancellation is in the **combined** quotient, not term-by-term.

### Related symbols

- `$HRFPolynomialMaxMonomials = Automatic` — cap from raw harvest per \(F_0\) (vertex ~12 monomials per factor).
- `hrfInspectThreeLoopVertexGenerators.wl` — Collinear5pt pair audit + scaling diagnostic.

## 4. Performance and regression harness defaults

- **`$HRFCandidateGeneratorSetLimit = 64`** (was unlimited; Crown had 10k+ pair trials).
- **`$HRFMaxTwoGeneratorUnionTrials = 48`** — cap on `{g1,g2}` unions; kin-free pair generators only.
- **Bugfix (Crown):** an earlier performance cap **dropped all two-generator unions** when a trial limit was active, so PairSectors only tried single-sector generators and falsely returned `F_SL = s12 × g(x)`. Unions are restored (capped); `findObstructions` now prefers **more generators** among admissible trials.
- **`$HRFEx04RunObstructionSearchQ = False`** on Example 04 notebook load (fast regression; opt-in obstruction cells).
- **`$HRFFindObstructionsStopOnFirstAdmissibleQ = False`** globally (exhaustive admissible-set scan); pass `"StopOnFirstAdmissible" -> True` only for fast smoke runs.
- **Example 04:** Crown / 5pt comparison, factor audits, optional pair tables; patch reinstall after Example 01/03 loads.

## 5. Reporting and exact-reduction logic (`HRF_FinalLogicPatch.wl`)

- Interior hidden region: obstruction **record** + admissible generators; **exact superleading reduction** (\(F_{SL}\in\langle g_i\rangle\)) counts as success even when the complement obstruction polynomial is nonzero.
- Crown interior reference: **two** x-sector generators with `CrownGeneratorCheck = {{s12,-s23},0}` (i.e. \(F_{SL}=s_{12}\,g_1+s_{23}\,g_2\)).

## 6. Crown vs 5pt — what the code finds (polynomial mode)

| Case | Raw \(f_k\) | Binomial \(f_k\) | Physics-eligible | Generators (PairSectors / Adaptive) |
|------|------------:|-----------------:|-----------------:|--------------------------------------|
| **Crown** `{s12,s23}` | 36 | 18 | 26 (10 span-redundant dropped) | **2** sector generators; `{{s12,-s23},0}` |
| **Seed5pt** `{s,x,z}` | 26 | 14 | ~14 after kin-normalize + Mandelstam-linear filter | **1** coupled generator via **SingleProduct** (legacy Ex03/binomial path) |

- **Crown:** two-sector picture \(\mathcal{F}_{SL}=s_{12}\,\mathrm{gen}_1+s_{23}\,\mathrm{gen}_2\) with kin-free \(g_i\); kin-mixed pairings are often span-redundant presentations of the same module.
- **Seed5pt:** fully coupled \(x_i\) and \(\{s,x,z\}\); one generator \(g=\prod f_k\) over the safe pool (SingleProduct). **Not** PairSectors (kin×kin pairs blocked) or Adaptive subset products. Polynomial \(f_k\) are kin-normalized and Mandelstam-linear before generator construction.
- **Same code path** when `(vars, kinVars)` are passed correctly; module basis is \(\mathrm{span}\{B, k_1 B, k_2 B,\ldots\}\) for the listed `kinVars`.

## 7. PDF / notebook update map

| Location | Suggested update |
|----------|------------------|
| **Footnote 4** | Polynomial \(f_k\) with mixed signs; primitive stripping; kinematic-domain filter; audit tables. |
| **§5.12 / generator construction** | Adaptive mode; simultaneous admissibility at candidate and SL-sector stages; physics pairing rules (kin×kin, kin-mixed degree bound, span redundancy). |
| **§5.12 / Mandelstam content** | Each \(f_k\) individually linear in Mandelstams; products in **generators** may carry higher kin weight. |
| **Crown wide-angle example** | Two generators; \(F_{SL}=s_{12}\,g_1+s_{23}\,g_2\); complement obstruction may be nonzero. |
| **5pt collinear example** | Adaptive default; dimensionful `s` vs dimensionless `x,z` (`CollinearDimensionfulKinVars`); single coupled generator; **ideal-quotient obstruction** for Seed5pt and ThreeLoopVertex. |
| **`00_Pedagogical_HiddenRegion_Algorithm.nb`** | Add Adaptive mode, physics filter, prep-stage quotient; contrast Crown multi-sector vs 5pt single generator. |
| **Obstruction** | Primary: ideal quotient + derivative consistency on \(\{f_k=0\}\); no `FindInstance` on remainder equations. `FindInstance` remains only for **kinematic-domain** checks on cancellation factors (`$HRFPolynomialRequireKinematicDomainQ`). |

**Important:** `hrfGeneratorDegreeAdmissibleQ` and safe-pool filters call `hrfFactorMandelstamLinearQ` only when `Length[DownValues[hrfFactorMandelstamLinearQ]] > 0` (not `ValueQ`, which is always false for defined functions). A 2026 bug skipped Mandelstam checks on generators, allowing `z^2` products through Adaptive mode.

## 9. Pipeline conditions reference

Full stage-by-stage checklist (binomial vs polynomial, PDF vs other gates, wide-angle / Regge / collinear presets): **[`PIPELINE_CONDITIONS.md`](PIPELINE_CONDITIONS.md)**.

## 10. Regression tests

```wl
Get["HRF_PolynomialFactorRegressionTests.wl"]
hrfRunPolynomialFactorRegressionTests[]
```

Checks factor counts, physics filter, Crown/Seed5pt obstruction stability (superleading reduction), and Example 03 coupled generator for Seed5pt.
