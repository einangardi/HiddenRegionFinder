# Polynomial-factor branch — algorithmic changelog

Summary of changes relative to the shared `HiddenRegionFinder` baseline and the PDF (footnote 4 / §5.12) obstruction recipe. Use this when updating the paper or revisiting design decisions.

## 2026-07-31 candidate-specific derivative-ideal saturation

The ordinary pre-decomposition derivative harvest remains an inspection of
primitive factors and independent kinematic sectors.  It does not impose the
simultaneous vanishing of the complete derivatives of the starting
polynomial.  This distinction is essential when an obstruction is present:
the derivatives of the obstruction need not vanish on the HR locus, and
saturating the full gradient ideal would impose the wrong equations.

The preferred opt-in mode is now
`DerivativeFactorHarvestMode -> "SaturatedLeadingIdeal"`.  It may be used
only when the supplied polynomial has already been identified as the complete
leading cancellation sector, certified by
`FullGradientSaturationJustifiedQ -> True`, or when
`FactorHarvestDerivativePolynomials` explicitly supplies the selected
derivative-sector relations.  Otherwise HRF returns
`"ApplicabilityNotEstablished"` with `SearchTruncatedQ -> True`.  Historical
mode names remain deprecated aliases subject to the same guard.

For an applicable candidate, the selected derivative ideal is saturated by
the active Schwinger parameters and any explicitly nonzero kinematic factors;
polynomial kinematic constraints may also be supplied.  Duplicate binomial
hypersurfaces are identified modulo those constraints.  The resulting factors
then pass through the unchanged positive-domain, generator, obstruction,
exact-coverage-scaling and lower-facet stages.  Time, basis-size and optional
x-degree budgets remain explicit and any reached limit marks the search
incomplete.

`HRF_GeneralizedDerivativeHarvestTests.wl` now includes 13 checks.  It verifies
that an unjustified full-gradient request is rejected, as well as the symbolic
Gram-constrained harvest, an end-to-end exact physical-witness run for the
five-point near-planar example, and an independent Crown positive control.
Without factor or generator overrides the five-point test recovers the three
normal factors, the three pair-product generators and the established scaling
`{-2,-2,-2,-2,-2,-2}`. Existing generator-override,
polynomial-factor, layered DSC/NMRK and Crown/HyperCrown exact-coverage
regressions remain unchanged.

## 2026-07-30 native-layer composition and supplied generator ideals

Composite limits are certified using the complete native delta-layer data.
Every monomial weight is the sum of its Schwinger weight and its original
delta order.  Native delta powers must therefore not be stripped after the
alignment step.  Reapplying this rule to the five-point central-soft MRK
limit gives a genuine lower facet for six of the twelve attachment labelings.
For the representative labeling the alignment vector is
`{-3,-3,0,-3,-3,-3}`, the relative HRF vector is uniform, and the composed
vector is `{-4,-4,-1,-4,-4,-4;1}`, with
`(W_SL,W_HR)=(-9,-8)`.  The apparently lower term
`-T x0 x3 x4` carries native order four and consequently lies at `W_HR`, not
below it.

The Laurent input has a common kinematic factor
`delta^4 K M P`.  Clearing it is the choice to measure all invariants and
Schwinger parameters in units of the growing hard scale.  It does not permit
replacing the infrared vector above by the uniformly shifted non-negative
list `{0,0,3,0,0,0}`.  That list is only the dimensionful-unit representative
obtained while `s12~delta^-4` varies.  The current local-coordinate and
light-cone reconstructions independently give the reduced scalar power
`delta^(4 D-20)=delta^(-4-8 epsilon)`.

`findObstructions` now exposes `"GeneratorSetOverride"`.  Its value is an
outer list of proposed nonempty generator sets, for example
`{{fA fB, fB fC, fC fA}}`.  This skips only the automatic construction of
candidate generator sets.  Factor admissibility, the positive-domain check,
exact ideal reduction, obstruction reconstruction, scaling, and
scalefulness/lower-facet certification remain active.  The option is intended
for semi-automatic analyses in which the singular-locus geometry supplies a
non-principal ideal that the generic generator constructor does not yet infer.
Its use and cardinality are recorded in `GeneratorConstructionAudit` and
`EffectiveSearchConfiguration`.

The regression `HRF_GeneratorSetOverrideTests.wl` applies this interface to
the on-shell near-planar five-point example.  With three pair-product
generators it recovers the total vector `{-2,-2,-2,-2,-2,-2;1}` and
`(W_SL,W_HR)=(-6,-4)` through the standard HRF obstruction and exact-coverage
pipeline.

## 2026-07-28 release clarification: complete factors and search profiles

This release separates completeness from performance explicitly.  The
default factor pool consists of the irreducible primitive factors of the full
Schwinger derivatives and primitive channel polynomials.  These are genuine
polynomial cancellation factors.  The older construction from signed pairs
of individual monomials is disabled by default and retained only through
`"EnableSignedMonomialPairs" -> True` for legacy diagnostics.

The potentially correctness-sensitive budgets are no longer hidden notebook
choices.  `findObstructions` exposes `"CandidateGeneratorSetLimit"`,
`"MaxTwoGeneratorUnionTrials"`, and `"PolynomialMaxMonomials"`; results echo
the resolved values in `"EffectiveSearchConfiguration"` and record
`"SearchTruncatedQ"`, `"HiddenRegionSearchCompleteQ"`, the generator
construction audit, and the polynomial-factor harvest audit.  The notebooks
provide an exploratory profile with finite witness-finding budgets and a
certified profile with unbounded candidate and two-generator-union budgets.
Finite budgets, timeouts, or undecided positivity tests imply `unresolved`,
not `no HR`.

The current wide-angle controls include the SuperCrown boundary `x8=x9=0` as
a positive codimension-two witness and the HyperCrown opposite-pair orbit as
a complete negative control.  The HyperCrown interior remains unresolved;
this status is deliberately distinct from the certified opposite-pair
exclusion.

## 1. Polynomial cancellation factors (footnote 4)

- **Beyond binomial \(f_k\):** the complete default pool is formed from the irreducible primitive factors of the full derivatives and primitive channel polynomials.  The former signed-monomial-pair enlargement is disabled by default and remains available only as a legacy diagnostic.  Its derivative-length cap has nevertheless been removed (the old public symbol is fixed to `Infinity` for display compatibility), so opting into that diagnostic does not silently reintroduce the historical length cutoff.  In the two-channel wide-angle case the channel harvest uses the primitive coefficient polynomials associated with `F=s12 A+s23 B`; crossed Mandelstam bases remain available to obstruction reconstruction without redefining the cancellation-factor pool.
- **Per-polynomial cap reset:** the cached `Automatic` value of `$HRFPolynomialEffectiveMaxMonomials` is reset before every raw harvest. A shorter factor pool from an earlier boundary can therefore never cap a later boundary. Completeness audits additionally set `$HRFPolynomialMaxMonomials = Infinity` explicitly.
- **Primitive stripping:** `hrfPrimitiveCancellationFactor` removes shared \(x_i\) monomial content before audit and pairing.
- **Uncapped-pair efficiency:** pair-sector generation now applies the exact support/kinematic-sector and degree gates before joint-domain `FindInstance`. Long factors that occupy too much Schwinger support to have a multilinear partner are therefore rejected cheaply, without reinstating a completeness-damaging term-count cap.
- **No support-dominance rejection:** the wide-angle completeness prefilter enumerates every degree- and sector-admissible factor pair. Replacing a factor by one with smaller Schwinger support preserves disjointness, but can change whether the product monomials embed in `F0`; support dominance is therefore not used to discard factors or strata.
- **Exact generator deduplication:** distinct factor-pair presentations that expand to the identical polynomial `g` are merged before generator unions are built. This preserves the same principal ideal exactly and is distinct from the unsafe linear/module quotient; on the hardest sampled stratum 1164 factor pairs reduce to 582 polynomial generators.
- **Product-generator support gate:** for each factor pair the prefilter tests the same object as HRF, `g=f_i f_j`, with `hrfGeneratorF0SupportAdmissibleQ`. It does not incorrectly assign the individual factors to two separate Mandelstam sectors.
- **Crown-form sector diagnostic:** the stricter form `F_SL = +/- s12 g12 +/- s23 g23`, with no `x`-dependent quotient, is evaluated separately. The Crown has 16 such presentations, all with hierarchy gap 1, while the largest tested no-Crown stratum has none. This is useful structural evidence, but it is not used to reject general candidates: Eq. (15) permits arbitrary polynomial multipliers `M_k(x,s)` in `F_SL = Sum_k M_k g_k`.
- **Optional generator-independent face/pinch cross-check:** the primary ordinary HRF search is generator first: generators, algebraic `F_SL+F_Obs` decompositions, scaling, and then the positive-pinch/facet tests.  `HRF_WideAngle16FacePinchAudit.wl` records a separate historical cross-check based on the fact that the support of any already admissible homogeneous `F_SL` must be exposed by its final scaling.  It obtains the `F0` face lattice from exact rational `cddlib` incidences and tests each face directly in positive physical coordinates `s23=-a`, `s12=a+b`, `a,b>0`, followed by the exact oriented `(rho;1)` hierarchy LP against `F0-F_SL`, `U`, and every restored-delta layer.  This route is not a preliminary step of ordinary HRF and is not needed before generator construction.  It assumes neither a factor-length cap nor a generator presentation and finds exactly one positive pinch-and-hierarchy face for the Crown control, with gap 1.  Its own saved coverage remains provenance-specific; the formerly missing 1012 wide-angle codimension-two strata are completed by the separate generator-first audit below.
- **Subtraction-free fast certificate:** if the complete restricted `F0` has coefficients of one sign in the positive physical channel variables, every nonempty face subpolynomial is also subtraction-free.  Homogeneity of positive Schwinger degree then guarantees a nonzero sign-definite derivative, so the entire stratum is rejected without constructing its face lattice.
- **Log-derivative Farkas certificate:** when no individual derivative is sign-definite, the audit searches exactly for a constant real combination of the logarithmic derivatives `x_i d_i F_SL` that is a nonzero subtraction-free polynomial in the positive Schwinger and channel variables.  Such a polynomial is strictly positive on the physical orthant but would vanish at any common pinch, so it is a rigorous no-pinch certificate.  This resolved all six nonlinear timeouts in the first exhaustive codimension-four graph with rational coefficient vectors.
- **Square-free positivity certificate:** a kin-free homogeneous square-free factor with coefficients of both signs has a positive-orthant zero because every distinct 0/1 exponent is a Newton-polytope vertex. Two such factors with disjoint supports vanish simultaneously by combining their independent positive assignments. `PairSectors` now uses this exact certificate before falling back to `FindInstance`; no positivity condition is dropped.
- **Completed wide-angle codimension-two audit:** the 1012 strata outside the historically retained `x8` sector are now checkpointed individually.  All 1012 return untruncated `CompleteNoHR`, with zero admissible generators and zero unresolved positivity decisions.  Together with the 188 legacy `x8` strata this closes the codimension-two coverage gap without using a preliminary face enumeration.
- **Batched sector quotient:** maximal independent polynomial generators are now selected by one exact coefficient-matrix row reduction (pivot columns of the transposed matrix), replacing repeated augmented-rank tests. The earliest independent generators—and therefore the quotient space—are unchanged.
- **Sector quotient made explicit:** `UseGeneratorSectorQuotientQ -> True` is now required to replace pair generators by a linear/module basis. It remains useful diagnostically, but is off by default and in completeness audits because linear dependence of polynomials does not by itself preserve each principal ideal or cancellation hypersurface.
- **Full-product early rejection:** the diagnostic generator builder now compares the sum of factor degrees with `deg(F)` before constructing the product or asking whether every harvested factor vanishes simultaneously. This removes a large but logically dead `FindInstance` call on uncapped pools.
- **Exact gap-audit efficiency:** the wide-angle hierarchy audit now sends the same rational constraints directly to matrix-form `LinearProgramming` after the substitution \(y=-\rho\geq0\). It agrees presentation-by-presentation with the former symbolic `LinearOptimization` solver (including the Crown positive control) and removes roughly a factor of two in LP overhead.
- **Channel-basis reduction shortcut:** when all generators are kinematics-free, reduction by their (x)-ideal acts coefficientwise on (F=s_{12}A(x)+s_{23}B(x)) and commutes with invertible Mandelstam-basis changes. The complete audit therefore performs the original-basis obstruction reduction once; kin-mixed generators still use all crossed-basis attempts.
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

## 3c. Optional pre-HRF asymptotic-order alignment layer (2026-07)

Adds `HRF_AsymptoticOrderAlignment.wl` and an opt-in `findObstructions` wrapper mode for cases where the naive leading polynomial \(F_0\) is not the right face on which to start the HR search.

- **Default unchanged:** `findObstructions` uses `"AsymptoticOrderAlignmentMode" -> "Off"`.
- **Modes:** `"Fallback"` runs ordinary HRF first and aligns orders only if no HR is found; `"Always"` runs both; `"Only"` skips the ordinary scan for targeted diagnostics.
- **Polynomial source:** `"AsymptoticOrderAlignmentPolynomial" -> Automatic` uses the first argument of `findObstructions`; pass the full eta-dependent polynomial when the order-aligned search must see terms outside the naive \(F_0\).
- **Options:** `"AsymptoticOrderAlignmentOptions"` are passed to `hrfAsymptoticOrderAlignmentSearch`, including `"KinematicRules"`, `"ScalingRange"`, `"FacePolynomialTransform"`, and nested `"HRFOptions"`.
- **Recursion guard:** inner HRF calls made by the asymptotic-order alignment layer force `"AsymptoticOrderAlignmentMode" -> "Off"`.
- **Validated smoke test:** one-loop hexagon NMRK with `w -> z` returns 9 face presentations and 1 structurally unique HR through `findObstructions[..., "AsymptoticOrderAlignmentMode" -> "Only", ...]`.

## 3d. Ideal-layer, shift-covariant alignment certification (2026-07-20)

The former final check added the alignment vector to the scaling returned by
HRF on the selected face.  That sum is not invariant under the harmless
replacement `faceVector -> faceVector + c ConstantArray[1,n]`: the face
polynomial is unchanged, while the face-only HRF run returns the same vector
instead of the compensating shift.  It can therefore change which `U`
monomials appear at the nominal `W_HR` layer.

- **Discovery is unchanged:** the exposed face and its HRF decomposition still
  supply the cancellation factors and a shift-invariant relative direction.
- **Primary full-LP certificate:** `HRF_IdealLayerCertification.wl` retains
  every occupied eta-weight layer in the original coordinates and computes
  its leading class in the filtration
  `I^m/I^(m+1)`, where `I` is generated by the independent cancellation
  factors.  The unique positive transverse weights, together with the `U`
  balance, fix both the HR depth and the uniform alignment representative.
- **Occupied-layer rule:** an absent eta layer is not a cancellation layer.
  The eta exponent lattice spacing is recorded explicitly, so a polynomial
  containing only even eta powers does not acquire a fictitious odd
  cancellation layer.
- **Common-pinch requirement:** every transverse coordinate is suppressed by
  a unique positive weight.  A continuous family, or a solution suppressing
  only a proper subset of the factors, is not a common Landau-pinch
  certificate.
- **Dissection fallback:** `HRF_LayeredDissectionCertification.wl` constructs
  local sectors and applies the exact lower-facet test only when the
  original-coordinate ideal-jet system is nonlinear, singular, or not
  unique.  It is skipped after a successful ideal-layer certificate.
- **Layered cancellation:** successive original-coordinate weight layers are
  tested on the common pinch.  The final `W_HR` is the first resolved
  nonvanishing layer, not necessarily the first nominal obstruction layer.
- **Pullback normalization:** the exact local facet fixes the vector in the
  original Feynman coordinates.  It supersedes the raw alignment+HRF sum when
  the two differ.

Validated results:

| Case | Certified pullback | `W_SL` | resolved `W_HR` | depth |
|------|--------------------|-------:|-----------------:|------:|
| one-loop generic DSC hexagon | `{-2,-2,-2,0,-2,-2}` | -4 | -2 | 2 |
| one-loop NMRK with `w=z` | `{-2,-2,-3,-2,-3,-2}` | -4 | -3 | 1 |
| two-loop DSC hexbox (one structural representative) | `{0,-2,0,-2,0,-2,-2,0,0}` | -4 | -2 | 2 |

Focused regression: `HRF_LayeredDissectionRegressionTests.wl` checks four
uniform representatives of the one-loop DSC face, exact ideal orders 2 and 1
for its lowest two layers, transverse weights `{1,1}`, the eta-lattice rule,
and preservation of the NMRK `w=z` result.  The standard Seed5pt spacelike
collinear case remains covered by `HRF_PolynomialFactorRegressionTests.wl`
and `HRF_NotebookSmokeTests.wl`.

## 3e. Terminology and API migration (2026-07-24)

The former term *facelifting* has been replaced by *asymptotic-order
alignment*.  The name records the mathematical operation: the preliminary
rescaling changes a monomial order from (a_i) to
(a_i+\boldsymbol\phi\cdot\boldsymbol r_i), allowing monomials from distinct
fixed-parameter orders to occupy one exposed cancellation face.

- Canonical package: `HRF_AsymptoticOrderAlignment.wl`.
- Canonical search: `hrfAsymptoticOrderAlignmentSearch`.
- Canonical `findObstructions` options:
  `"AsymptoticOrderAlignmentMode"`,
  `"AsymptoticOrderAlignmentPolynomial"` and
  `"AsymptoticOrderAlignmentOptions"`.
- The former file, `hrfFacelift*` symbols, option names and result keys remain
  as deprecated forwarding aliases.  Canonical names take precedence if both
  option families are supplied.
- `HRF_AsymptoticOrderAlignmentCompatibilityTests.wl` verifies the canonical
  API and the compatibility boundary.

## 4. Performance profiles and regression harness defaults

- **Exploratory defaults:** `$HRFCandidateGeneratorSetLimit = 64` and
  `$HRFMaxTwoGeneratorUnionTrials = 48` bound quick witness-finding runs.
  The corresponding public options can be set to `Infinity` for certified
  coverage; every result records whether either bound was reached.
- **Bugfix (Crown):** an earlier performance cap **dropped all two-generator unions** when a trial limit was active, so PairSectors only tried single-sector generators and falsely returned `F_SL = s12 × g(x)`. Unions are restored (capped); `findObstructions` now prefers **more generators** among admissible trials.
- **`$HRFEx04RunObstructionSearchQ = False`** on Example 04 notebook load (fast regression; opt-in obstruction cells).
- **`$HRFFindObstructionsStopOnFirstAdmissibleQ = False`** globally (exhaustive admissible-set scan); pass `"StopOnFirstAdmissible" -> True` only for fast smoke runs.
- **Example 04:** Crown / 5pt comparison, factor audits, optional pair tables; patch reinstall after Example 01/03 loads.

## 5. Reporting and exact-reduction logic (`HRF_FinalLogicPatch.wl`)

- Interior hidden region: obstruction **record** + admissible generators; **exact superleading reduction** (\(F_{SL}\in\langle g_i\rangle\)) counts as success even when the complement obstruction polynomial is nonzero.
- Crown interior reference: **two** x-sector generators; exact reduction gives the two Mandelstam-channel quotients up to generator order and overall generator signs.

## 6. Crown vs 5pt — what the code finds (polynomial mode)

| Case | Current factor-pool check | Physics structure | Generators (PairSectors / Adaptive) |
|------|---------------------------|-------------------|--------------------------------------|
| **Crown** `{s12,s23}` | 32 kin-free factors in the current uncapped crossed-channel regression | no sector quotient in the completeness path | **2** sector generators; exact quotients are the two Mandelstam channels up to order and signs |
| **Seed5pt** `{s,x,z}` | derivative-only collinear pool; 6 binomial factors in the current regression | kin-mixed factors retained subject to the five-point rules | **1** coupled generator via **SingleProduct** (legacy Ex03/binomial path) |

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
