# Obstruction pipeline — precise conditions (polynomial-factor branch)

This document records **exactly** what the code checks at each stage, for the binomial and polynomial routes, and how the three main kinematic setups differ. It reflects the current `HiddenRegionFinder_polynomial_factors` branch (2026); many checks were added or tightened since the shared baseline.

**Related files:** `HiddenRegionFinder.wl`, `HRF_PolynomialCancellationFactors.wl`, `HRF_GeneratorPhysicsFilter.wl`, `HRF_KinematicGeneratorPresets.wl`, `HRF_Example03SeedStudy.wl`.

---

## Pipeline overview

```mermaid
flowchart TD
  F0["F0 restricted polynomial"]
  RAW["1. Raw candidate harvest"]
  SAFE["2. Safe pool f_k"]
  ELIG["3. Generator-eligible f_k"]
  GEN["4. Generator candidate sets g"]
  OBS["5. Obstruction F_SL + scaling / HR"]

  F0 --> RAW --> SAFE --> ELIG --> GEN --> OBS
```

Each stage **narrows** the pool. A factor can appear in an early table but fail a later gate (this is intentional — audit tables show where it dropped).

---

## Terminology: “PDF (5.12)”

In code comments and audit columns, **PDF** means **§5.12 positive-domain feasibility**, implemented as `simultaneouslyAdmissibleSubsetQ` / `positiveCompatibleQ`:

> ∃ real values of `(kin vars, x_i)` such that  
> • kinematic assumptions `KinAssump` hold (domain **K**)  
> • all Symanzik variables `x_i > 0`  
> • every factor in the subset equals **0 simultaneously**

Implementation: `FindInstance` on  
`kinAssumptions && And @@ Thread[vars > 0] && And @@ (f == 0 & /@ factors)`  
(`HiddenRegionFinder.wl`, `simultaneouslyAdmissibleSubsetQ`).

**PDF is not** the full obstruction recipe. These are **separate** later checks:

| Check | When | Symbol / function |
|--------|------|-------------------|
| PDF on factor subset | Safe pool, pair prefilter, generator trial | `simultaneouslyAdmissibleSubsetQ` |
| Per-factor PDF | Single `f_k` can vanish with `x_i > 0` | `positiveCompatibleQ` |
| Degree bounds | Factor / generator total degree, per-`x_i` exponent | `hrfGeneratorDegreeAdmissibleQ`, `hrfCancellationFactorDegreeAdmissibleQ` |
| F0 monomial support | Each generator monomial matches some `F0` term (kin sector) | `hrfGeneratorF0SupportAdmissibleQ` |
| Mandelstam linearity | Each **term** has total exponent ≤ 1 in each kin var | `hrfFactorMandelstamLinearQ` |
| Kin pair prefilter | By default no `f×f` with shared kin variables; generalized charts may opt in | `hrfGeneratorPairKinPrefilterQ` |
| Physics pairing | Kin×kin forbidden by default; `AllowKinematicFactorPairsQ -> True` permits disjoint-`x` pairs | `hrfGeneratorPairPhysicsAdmissibleQ`, `hrfFilterFactorsForGeneratorPhysics` |
| SL ideal | `F_SL ∈ ⟨g_i⟩` exactly | `hrfObstructionSuperleadingInIdealQ` |
| SL-sector PDF | PDF on factors of generators **entering** confirmed `F_SL` | `slSectorAdmissibilityData` |
| Hidden region | Valid scaling vector for leading `U` | `hrfEvaluateValidTrialScaling`, `hrfFPObstructionRegionPresentQ` |

Audit columns name the specific gate (`JointPDFQ`, `KinPrefilterQ`, `F0SupportQ`, …). **Do not read “AdmissiblePairCount” in the selection table as “physics-admissible”** — it counts pairs passing **PDF + degree only** (see §4.3).

---

## Stage 1 — Raw candidate harvest

**Functions:** `derivativeFactors`, `derivativeFactorsExtended`, `hrfRawPolynomialCandidates`.

### 1.1 Binomial baseline (unpatched `safeCancellationFactors`)

| Source | Condition on raw piece |
|--------|-------------------------|
| `D[F0, x_i]` factorization | Drop `±1`, drop pure monomials (`monomialQ`) |
| Extended (`UseExtendedFactors -> True`) | Adds `channelDirectionFactors` on kin coefficients (wide-angle) |

No polynomial harvest; binomials only at safe-pool stage.

### 1.2 Polynomial harvest (`hrfRawPolynomialCandidates`)

| Source | Enabled when | Conditions |
|--------|--------------|------------|
| **Derivative factorization** | Always | Factors from `Factor[D[F0,x_i]]`, light-normalized |
| **Whole derivative** | `DerivativeFactorizationOnlyQ -> False` | Primitive core of full `D[F0,x_i]`: 2–`$HRFPolynomialMaxMonomials` terms, mixed sign, not monomial |
| **Signed monomial pairs** | `$HRFPolynomialEnableSignedMonomialPairs` and not deriv-only | Sums/diffs of all monomial pairs. In the two-channel wide-angle case these are harvested from every primitive coefficient-space direction: `A`, `B`, `A+B`, and `A-B` for `F=s12 A+s23 B`. Same-channel pairs from an `x_i` derivative reduce to the same primitive pair, whereas cross-channel pairs are excluded by the kin-free generator condition. The historical derivative-length cap has been removed; `$HRFPolynomialMaxDerivativeMonomials` is retained only as a displayed compatibility symbol fixed to `Infinity`. |

**Automatic “deriv-only”** (`$HRFPolynomialDerivativeFactorizationOnlyQ = Automatic`):  
`True` when **not** wide-angle two-channel `{s12,s23}` — i.e. **collinear 5pt** harvests **only** derivative factorization, not signed-pair / whole-derivative extras.

The cached effective `Automatic` monomial limit is reset before each raw harvest, so it is local to the current polynomial rather than inherited from a previously scanned boundary. Exhaustive completeness runners set both polynomial monomial limits to `Infinity`.

**Extended derivatives** (`DimensionfulKinVars` explicit): Regge / wide-angle channel-direction harvest via `derivativeFactorsExtended`. In the wide-angle two-channel case the supplementary signed-pair harvest uses all primitive linear combinations of the two channel coefficients. This removes the basis dependence that would result from using only `D[F0,s12]` and `D[F0,s23]`, including after boundary restriction.

### 1.3 Candidate-specific saturated derivative ideal

This is not a general fallback at Stage 1.  When an obstruction is still
present, the full derivatives of the starting polynomial need not vanish on
the HR locus.  The ordinary harvest therefore only inspects derivative
factors and kinematic sectors; it does not saturate their full ideal.

After a candidate leading cancellation sector has been selected, use
`DerivativeFactorHarvestMode -> "SaturatedLeadingIdeal"` together with either
`FullGradientSaturationJustifiedQ -> True` or explicit
`FactorHarvestDerivativePolynomials`.  The former certifies that the supplied
polynomial is the selected leading sector; the latter supplies only the
derivative-sector relations meant to vanish.  Without one of these two
conditions the status is `"ApplicabilityNotEstablished"` and the search is
incomplete.

For an applicable candidate, `hrfSaturatedDerivativeFactorHarvest` adds the
polynomial equations in `FactorHarvestKinematicConstraints`, saturates by the
product of active Schwinger variables and any explicit
`FactorHarvestNonzeroKinematicFactors`, and eliminates the saturation
variable.  Binomial factors are canonicalized and duplicate hypersurfaces are
identified modulo the supplied kinematic equations.  The output is still only
a factor pool: positive-domain, generator, decomposition, scaling and facet
tests remain active.  Time/basis limits are unresolved truncations.
`FactorHarvestMaxXDegree` must remain `Automatic` in a completeness claim
unless a separate degree theorem justifies it.

---

## Stage 2 — Safe pool `f_k`

### 2.1 Binomial route

**Legacy pool** (`hrfLegacyBinomialSafeFactors`, Ex03 binomial audits):

- `derivativeFactors[F0, vars]` only  
- `binomialQ` (exactly 2 monomials in `x_i`)  
- Canonical dedup: `hrfNormalizeCancellationCandidates` (sign/shell equivalence)

**Standard `safeCancellationFactors`** (when polynomial patch off):

- Same as above + **`positiveCompatibleQ`** (single-factor PDF / domain witness)

**Extended binomial** (`safeCancellationFactorsExtended`, `UseExtendedFactors -> True`):

- Uses extended derivative harvest; still **binomial + positiveCompatibleQ**

### 2.2 Polynomial route (`hrfSafeCancellationFactorsPolynomial`)

Applies `hrfFilterPolynomialCandidates` → **`hrfCancellationFactorAcceptanceQ`** per raw candidate:

| # | Condition | Reject reason (audit) |
|---|-----------|------------------------|
| 1 | Not pure monomial after primitive strip | `pure monomial` |
| 2 | Shape: binomial **or** 2–`MaxMonomials` polynomial | `not binomial/polynomial candidate` |
| 3 | Kinematic domain (`$HRFPolynomialRequireKinematicDomainQ`) | `fails kinematic-domain compatibility` |
| 4 | Mixed signs (`$HRFRequireMixedSignCancellationFactorsQ`, default True) | `same-sign coefficients` |
| 5 | **Wide-angle only:** kin-free `f_k` if `$HRFRequireKinFreeCancellationFactorsQ` auto for `{s12,s23}` | `kin-dependent f_k (wide-angle…)` |
| 6 | Mandelstam linear in each `f_k` | `nonlinear Mandelstam monomial in f_k` |

Then **post-filters** on accepted list:

- **Canonical normalize** (`hrfCanonicalCancellationFactor`): strip shared `x_i` content, non-`x_i` shells, overall sign; dedup by equivalence  
- **Collinear deriv-only:** keep only classes present in derivative factorization harvest  
- Mandelstam-linear filter (again)  
- **`hrfCancellationFactorAdmissibleShapeQ`:** reject pure monomials and same-sign-only polynomials  

**Canonical factor display:** `hrfFormatCancellationFactorDisplay` — group by `x_i` monomial, factor kin combination (tables use this string).

### 2.3 Primitive / canonical normalization (both routes when patch loaded)

`hrfCanonicalCancellationFactor`:

1. `hrfPrimitiveCancellationFactor` — remove common `x_i` monomial from all terms  
2. `hrfStripOverallNonSymanzikFactors` — drop `Times` factors with **no** `x_i` (kin shells `(1-z)`, etc.)  
3. `hrfStripOverallSign` — fix overall sign via leading monomial coefficient  
4. `Factor[Expand[…]]`

---

## Stage 3 — Generator-eligible factors

**Function:** `hrfFilterFactorsForGenerators[safe, vars, F0, opts]`

| Step | Condition |
|------|-----------|
| Canonical dedup | `hrfCanonicalCancellationFactor` per pool member |
| Per-factor degree | `hrfCancellationFactorDegreeAdmissibleQ`: total `x`-degree and max per-`x_i` exponent ≤ bounds inferred from `F0` |

**Not applied here:** PDF on pairs, physics filter, kin prefilter (those are generator/pair stages).

**Physics-eligible subset** (PairSectors / Adaptive only, `$HRFUseGeneratorPhysicsFilterQ`):

- `hrfFilterFactorsForGeneratorPhysics`: drop kin-mixed `f_k` whose `x`-sectors lie in Q-span of kin-free factors  

---

## Stage 4 — Generator candidates

Controlled by **`GeneratorMode`** and **`HRF_KinematicGeneratorPresets.wl`**.

### 4.1 Degree / F0 bounds on generators (`hrfGeneratorDegreeAdmissibleQ`)

For generator (product) `g`:

- Total `x`-degree ≤ `MaxGeneratorTotalDegree` (default: from `F0`)  
- Massless: each monomial of `g` has each `x_i` exponent ≤ `MaxGeneratorVarExponent` (typically 1)  
- **F0 monomial support:** each monomial of `g` matches some `F0` term in kin sector (`hrfGeneratorF0SupportAdmissibleQ`)  
- **Mandelstam linear on `g`:** each term of expanded `g` linear in each kin var  

### 4.2 Kin pair prefilter (`hrfGeneratorPairKinPrefilterQ`)

Applied in SingleProduct resolver and pair audit (before listing):

- Reject `f × f` if `f` contains any kin var  
- Reject `f_a × f_b` if **same** kin var appears in both (even if polynomials differ)  

### 4.3 Pair admissibility — **two counting conventions**

| Counter | Checks | Used in |
|---------|--------|---------|
| **`AdmissiblePairCount`** (selection table) | PDF (5.12) on `{f_a,f_b}` **and** degree bounds on `f_a f_b` | `hrfFivePointGeneratorStudy`, route comparison |
| **`PairAdmissibleQ`** (pair audit) | Kin prefilter **and** PDF **and** degree **and** F0 support **and** Mandelstam linear on product | `GeneratorPairAuditTable` |

Example (Seed5pt): 5 eligible factors → selection table may show **2** PDF+degree pairs; pair audit lists **1** after kin prefilter (the chosen `z`-linear × bilinear pair).

### 4.4 Physics pairing (`hrfGeneratorPairPhysicsAdmissibleQ`) — PairSectors / Adaptive

| Rule | Detail |
|------|--------|
| Kin × kin | **Forbidden** (two factors both kin-dependent) |
| Kin-mixed + kin-free | Disjoint `x`-support; kin-free partner degree ≤ `deg(F) - deg(f_kin)` |
| Kin-free + kin-free | Disjoint `x`-support; product degree bounds |
| Kin prefilter | Shared kin var / squared kin-dependent factor |
| Module dedup | Redundant kin-mixed pair generators mod span `{B, s_a B}` |

For `PairSectors`, these cheap exact support/sector and degree conditions are evaluated before joint-domain `FindInstance`. This ordering matters for an uncapped harvest: a long factor that cannot have a multilinear partner is rejected without an expensive positivity solve.

The completeness prefilter does not quotient factors by support dominance. A smaller-support factor preserves the existence of a disjoint companion but need not preserve the product-monomial embedding in `F0`, so that relation is insufficient for a negative certificate.

Exact duplicate pair products are merged after expansion. This is safe because the generator polynomial—and hence its principal ideal—is identical; no linear-span or support-dominance substitution is made.

The `F0` support predicate is applied to the actual HRF pair generator `g=f_i f_j`, not to `{f_i,f_j}` as if the two factors were separate sector generators.

For two-channel wide-angle kinematics, the stricter Crown-form presentation `F_SL = +/- s12 g12 +/- s23 g23` is reported as a diagnostic. It is not a general rejection rule: Eq. (15) allows `F_SL = Sum_k M_k(x,s) g_k` with polynomial multipliers. Consequently, a candidate with no Crown-form presentation must still pass through the general ideal-membership and hierarchy audit.

For a cap-independent certificate one may bypass generator discovery entirely.  Eq. (14), together with strict separation from `F0-F_SL`, requires the exponent support of `F_SL` to be an exposed face of the `F0` Newton polytope.  `HRF_WideAngle16FacePinchAudit.wl` enumerates that complete exact face lattice and applies the simultaneous positive pinch equations of Eq. (13) to every face.  A positive pinch must then pass the exact oriented `(rho;1)` hierarchy LP against `F0-F_SL`, `U`, and all restored-delta layers; this tests whether the `F0` face extends to the required pure lower face of the augmented LP polytope.  Therefore a stratum with no positive pinch-and-hierarchy face has no HR within these defining conditions, independently of cancellation-factor length, factor pairing, or the polynomial multipliers used to present the ideal.  The physical wide-angle coordinates used by the audit are `s23=-a`, `s12=a+b`, with `a,b>0`, equivalent to `s12>-s23>0`.

The pinch stage first rejects a face if one derivative is sign-definite.  It then applies an exact Farkas-type strengthening: if some constant real linear combination of `x_i d_i F_SL` is a nonzero polynomial with coefficients of one sign in the positive variables, a simultaneous pinch is impossible.  Only faces without either algebraic certificate are sent to a normalized exact `FindInstance` solve.

For kin-free homogeneous square-free factors, mixed coefficients already certify a positive-orthant zero: every distinct 0/1 exponent is a Newton-polytope vertex, hence monomials of either sign can be made dominant. Two certified factors with disjoint supports vanish simultaneously by combining the two positive assignments. The code uses this exact certificate and falls back to `FindInstance` outside its hypotheses.

The linear/module sector quotient is exploratory and opt-in (`UseGeneratorSectorQuotientQ -> True`). It is disabled in completeness audits because linear dependence of generator polynomials does not imply equality of their individual principal ideals or cancellation hypersurfaces.

### 4.5 Generator modes

| Mode | Construction | Typical use |
|------|--------------|-------------|
| **`SingleProduct`** | One pair `{f_a,f_b}` → `g = f_a f_b`; resolver picks lowest monomial-rank admissible pair (kin prefilter in resolver) | **Collinear 5pt** |
| **`PairSectors`** | All physics-admissible pairs → sector generators; optional multi-generator unions | **Wide-angle Crown**, boundaries |
| **`Adaptive`** | Union of SingleProduct-style subset products + PairSectors trials | Default in `findObstructions` when no preset |

**Collinear preset** (`Collinear5pt`):

```wl
GeneratorMode -> "SingleProduct"
RelaxSingleProductDegreeQ -> False
SkipPDFFindInstanceQ -> False   (* PDF enforced at resolver *)
UseExtendedFactors -> False     (* Ex03 seed study *)
```

**Per-generator admissibility** (`AdmissibleGeneratorQ` in obstruction trials):

- ≥ 2 dividing `f_k`  
- PDF on dividing factors (unless collinear legacy skip — **not** used when `RelaxSingleProductDegreeQ -> False`)  
- Degree + F0 support  

### 4.6 Supplied generator ideals

When the singular-locus analysis determines an ideal that the generic
constructor does not yet infer, use
`"GeneratorSetOverride" -> {{g1,g2,...}, ...}`.  Each inner list is one
proposed generator set; the outer list permits several alternatives.  The
override replaces only Stage 4 construction.  It does not assert that a
hidden region exists and does not bypass per-generator admissibility, the
positive-domain condition, exact ideal membership, obstruction
reconstruction, scaling, or the lower-facet/scalefulness audit in Stage 5.

This is the semi-automatic route used for the near-planar five-point
three-generator ideal.  Supplying
`{{fA fB, fB fC, fC fA}}` lets the standard downstream pipeline recover
`(-2,-2,-2,-2,-2,-2;1)` and `(W_SL,W_HR)=(-6,-4)`.  The effective
configuration records both that the override was used and how many proposed
sets were supplied.

---

## Stage 5 — Obstruction search (`findObstructions`)

For each generator set `{g_i}`:

1. **Candidate admissibility** — `generatorSetAdmissibilityData`: per-generator rules + PDF on union of dividing factors  
2. **Obstruction fit** — `obstructionByOriginalTermsGeneral`:
   - **Primary:** `hrfObstructionFromGeneratorVanishing` — ideal quotient \(F = F_{SL} + \mathrm{Obs}\) via `PolynomialReduce`; derivative consistency \(\partial_i F \equiv \partial_i \mathrm{Obs} \pmod{f_k}\) on generator factor vanishing loci  
   - **Fallback:** bounded algebraic subset search (`hrfObstructionAlgebraicSearch`; meet-in-the-middle for single \(g\))  
   - **Acceptance:** exact `PolynomialReduce[F_SL, {g_i}]` remainder `=== 0`  
   - **Not used:** `FindInstance` on remainder coefficient equations  
3. **SL-sector admissibility** — `slSectorAdmissibilityData`: PDF on factors of generators **used in** `F_SL`; `F_SL ∈ ⟨g_i⟩`  
4. **Hidden region** (if `U` supplied): scaling LP / coverage on valid trials  

**`MaxObstructionTerms`:** `max(1, |F| - 1)`; generator monomial count does **not** cap obstruction size.

**Diagnostics:** `SearchMethod -> "GeneratorVanishingIdealQuotient"` when primary path succeeds; `DerivativeConsistentQ` in attempt data.

Trial ranking: prefer **more generators** (unless `PreferFewerGenerators -> True`), then smaller obstruction (`hrfObstructionTrialRank`).

Caps: `$HRFCandidateGeneratorSetLimit` (default 64), `$HRFMaxTwoGeneratorUnionTrials` (48), `$HRFObstructionAlgebraicSearchLimit` (500000, fallback only).

---

## Kinematic setups — working configuration

Presets in `HRF_KinematicGeneratorPresets.wl`. **`hrfKinematicLimitFromKinVars`** maps `{s12,s23}` → WideAngle, single `{s12|s23}` → Regge, `{s,x,z}` → Collinear.

### Wide-angle 4pt (`{s12, s23}`)

| Item | Setting |
|------|---------|
| **Kin vars** | `s12`, `s23` |
| **Safe pool** | Binomial or polynomial; **`UseExtendedFactors -> True`** for channel directions |
| **Kin-free `f_k` only** | Auto `$HRFRequireKinFreeCancellationFactorsQ` |
| **Harvest** | Derivative + whole-derivative + signed pairs (deriv-only **off**) |
| **Generator mode** | **`PairSectors`**, `MaxGenerators -> 2` |
| **Target** | Two sector generators; e.g. Crown `F_SL = s12 g1 + s23 g2` |
| **Physics filter** | On; span dedup + sector quotient |
| **Domain check** | Often `$HRFPolynomialRequireKinematicDomainQ = False` in notebooks (faster) |
| **Notebook** | `01_WideAngle_4pt.nb`, Ex04 Crown / HyperCrown |

### Regge 4pt (single channel, e.g. `{s23}`)

| Item | Setting |
|------|---------|
| **Kin vars** | One Mandelstam (channel selected) |
| **Generator mode** | **`PairSectors`**, `MaxGenerators -> 1` |
| **PreferFewerGenerators** | `True` |
| **Harvest** | Extended factors; channel-direction binomials |
| **Physics** | Kin-free sector picture; one coupled generator typical |
| **Notebook** | `02_ReggeLimit_4pt.nb`, `02a`/`02b` |

### Spacelike collinear 5pt (`{s, x, z}`)

| Item | Setting |
|------|---------|
| **Kin vars** | `s` (dimensionful), `x`, `z` (dimensionless ratios) — `CollinearDimensionfulKinVars -> {s}` |
| **KinAssump** | e.g. `s > 0`, `x < 0`, `z > 1` |
| **Safe pool** | Polynomial strict path; **deriv-only harvest**; no Regge signed-pair extras |
| **Kin-free requirement** | **Off** (kin-mixed `f_k` allowed) |
| **Generator mode** | **`SingleProduct`**: one `g = f_a f_b` |
| **Pairing** | Kin prefilter: one kin factor may pair with kin-free partner; **not** two kin factors |
| **Ex03 study flags** | `$HRFPolynomialRequireKinematicDomainQ = False`; `$HRFUsePolynomialCancellationFactors = True` |
| **Topologies** | Seed5pt (6 vars), ThreeLoopVertex (9 vars) — same rules, different `F0` |
| **Notebook** | `03_SpacelikeCollinear_5pt.nb` In[1]–In[5] seed; **In[5c]** Seed vs Vertex; Ex04 In[16]/In[19] full obstruction |

**Why one codebase needs presets:** Wide-angle needs **two kin-free sector generators** and extended harvest; collinear needs **kin-mixed `f_k`** and a **single product generator** with stricter pair kinematics. Running Crown presets on 5pt (or collinear on Crown) mis-counts pairs and harvests wrong `f_k` classes.

---

## Binomial vs polynomial route (Ex03 audit tables)

| Stage | Binomial route | Polynomial route |
|-------|----------------|------------------|
| Safe pool | `hrfLegacyBinomialSafeFactors` | `hrfSafeCancellationFactorsPolynomial` |
| Pool size (Seed5pt) | ~2 canonical binomials | ~5 canonical (deriv classes, mixed-sign) |
| Eligible | `hrfFilterFactorsForGenerators` on respective pool | same |
| Resolver | `hrfResolveSingleProductGeneratorFactors` | same |
| Selected | Often legacy binomial pair | Polynomial pair (may coincide on Seed5pt) |
| **`NonBinomialGeneratorSelectedQ`** | — | True when selected factors ∉ legacy binomial pool |

---

## Audit tables — column guide (Ex03)

| Table | Key columns |
|-------|-------------|
| **CanonicalFactorTable** | One row per canonical class; `Topology` = Seed5pt / ThreeLoopVertex |
| **GeneratorPairAuditTable** | `PairAdmissibleQ` = full gate; `RejectionReason`; Factor1 = lower `x`-degree |
| **GeneratorSelectionTable** | `AdmissiblePairCount` = **PDF + degree only**; `SelectedFactors` = resolver choice |
| **ObstructionTrialTable** | SL decomposition, sector PDF, scaling, `HiddenRegionQ` |

**In[4]–In[5]:** Seed5pt only. **In[5c]:** Seed5pt + ThreeLoopVertex (`Ex03FivePointRoutes`).

---

## Key global flags (quick reference)

| Flag | Default | Effect |
|------|---------|--------|
| `$HRFUsePolynomialCancellationFactors` | True (Ex03) | Patch routes safe pool to polynomial harvest |
| `$HRFPolynomialMaxMonomials` | Automatic | Max terms per polynomial `f_k`; Automatic sets effective cap from raw harvest max for that F0 |
| `$HRFPolynomialRequireKinematicDomainQ` | True global; **False Ex03** | FindInstance on each `f_k` at safe-pool stage |
| `$HRFPolynomialDerivativeFactorizationOnlyQ` | Automatic | True for collinear → no signed-pair harvest |
| `$HRFRequireMixedSignCancellationFactorsQ` | True | Drop same-sign polynomials |
| `$HRFUseGeneratorPhysicsFilterQ` | True | PairSectors physics + span dedup |
| `$HRFCandidateGeneratorSetLimit` | 64 | Cap generator trials |
| `$HRFUseKinematicGeneratorPresetsQ` | True | `hrfFindObstructionsForKinematicLimit[…]` |

---

## Changelog cross-reference

Implementation history and paper update map: [`ALGORITHM_CHANGELOG.md`](ALGORITHM_CHANGELOG.md).  
Regression harness: `HRF_PolynomialFactorRegressionTests.wl`, notebook `04_PolynomialFactor_Regression.nb`.
