# Hidden Region Finder

This repository contains the collaborator-facing Wolfram Language release of
the Hidden Region Finder (HRF), including polynomial cancellation loci,
boundary hidden regions, asymptotic-order alignment, successive cancellation
layers, and final lower-facet certification.

The release is self-contained: graph definitions, compact physics
certificates, kinematic input data, and frozen regression fixtures are stored
inside the repository.  No script requires a user-specific absolute path.

## Start here

The eight principal physics notebooks are:

| Physics question | Notebook | Main conclusion |
|---|---|---|
| Wide-angle `2 -> 2`: Crown-family examples and HyperCrown survey | `01_Current_WideAngle_4pt.nb` | The Crown has an interior Landshoff HR; SuperCrown restores the codimension-two inherited-Crown example; HyperCrown has codimension-one and adjacent-pair HRs, while the opposite-pair orbit is excluded and the interior remains unresolved |
| `2 -> 2` Regge limits: positive Crown-family examples | `02_Current_Regge_4pt.nb` | The Crown remains a positive interior control in all three channels; SuperCrown and HyperCrown boundary examples demonstrate the role of contraction strata |
| Five-point spacelike-collinear scattering | `03_Current_SpacelikeCollinear_5pt.nb` | The canonical example of a hidden region with non-uniform scaling: the factorised superleading sector and its obstruction determine the HR vector |
| Five-point central-soft MRK | `08_Current_5pt_MRK_CentralSoft.nb` | A composite MRK limit on the same seed topology; the complete edge-flow and light-cone pole audit identify one genuine Glauber loop and give matching parameter- and momentum-space power counts |
| Four-loop wide-angle audit of the 16 No-Crown graphs | `NoCrown_4Loop_WideAngle_and_Regge_Audit_Guide.nb` | The complementary “only if” test is now complete: no HR in any interior or contraction stratum through `E-2`; the formerly missing 1012 codimension-two strata have exact per-stratum NoHR certificates |
| Regge audit of the same No-Crown graphs in all three channels | `WideAngle16_NoCrown_Regge_HRF_Audit.nb` | The Regge “only if” test: no interior or boundary HR in 48 graph/channel interiors and 343356 nonempty contraction strata |
| Central NMRK with `w=z` and `wb=zb` | `06_NMRK_wz_AsymptoticOrderAlignment_Checks.nb` | One-loop and two-loop hidden-region certificates after asymptotic-order alignment |
| Double spacelike-collinear kinematics | `07_DSC_AsymptoticOrderAlignment_Checks.nb` | One-loop and two-loop DSC certificates and their occupied-layer audits |

For the four-loop No-Crown program, begin with
`NoCrown_4Loop_WideAngle_and_Regge_Audit_Guide.nb`.  It explains one ordinary
HRF run, the enumeration of graphs and contraction strata, the exact
generator-first decision procedure, the historical Newton-face cross-check,
the safe computational shortcuts, and the complete wide-angle and Regge
coverage.  The two historical audit notebooks remain detailed run archives;
the guide incorporates the completed codimension-two audit.

The self-contained comparison of the two six-point limits is
`NMRK_DSC_Kinematic_and_HRF_Comparison.tex`; the compiled document is
`output/pdf/NMRK_DSC_Kinematic_and_HRF_Comparison.pdf`.

The current mathematical and conceptual presentation of HRF is included as
`docs/Hidden_Region_Finder_Principles.tex` and
`docs/Hidden_Region_Finder_Principles.pdf`.

Among the numbered notebooks, `01_Current_WideAngle_4pt.nb`,
`02_Current_Regge_4pt.nb`, and `03_Current_SpacelikeCollinear_5pt.nb` are
principal physics applications.  `00_Current_HRF_Quickstart.nb` is the general
entry point, `04_Current_5pt_Preselection.nb` is the five-point topology-
preselection companion, and `05_Current_Regression_and_Audits.nb` collects
regression and audit controls.

## Quick start

From a Wolfram Language session opened in the repository root:

```wl
SetDirectory[NotebookDirectory[]];
Get["HiddenRegionFinder.wl"];
Get["HRF_AsymptoticOrderAlignment.wl"];
```

The ordinary HRF path remains the default.  Alignment is enabled explicitly:

```wl
findObstructions[
  F, vars, kinematicAssumptions, kinematicVariables, Automatic,
  "U" -> U,
  "AsymptoticOrderAlignmentMode" -> "Fallback",
  "AsymptoticOrderAlignmentPolynomial" -> FFull,
  "AsymptoticOrderAlignmentOptions" -> {
    "KinematicRules" -> scalingRules,
    "ScalingRange" -> Range[-2, 0]
  }
]
```

`"Fallback"` first performs the ordinary scan and aligns asymptotic orders
only if no HR is found.  `"Always"` performs both scans, while `"Only"` is
useful for targeted composite-limit studies.

## What asymptotic-order alignment means

For

```text
P(x,delta) = sum_i c_i delta^(a_i) x^(r_i),
```

an alignment vector `phi` changes the effective order to
`a_i + phi.r_i`.  A lower face in this augmented support can therefore expose
monomials that occur at different fixed-`x` powers of `delta`, but must enter
the same cancellation sector.  The alignment vector selects the starting
face; it is not by itself the physical hidden-region vector.

The final vector is certified in the original variables using the complete
Lee--Pomeransky polynomial, all occupied asymptotic layers, the cancellation
ideal, and, where necessary, a local dissection.  This fixes both the
hierarchy gap and the uniform-shift ambiguity of the alignment face.

## Directory map

```text
HiddenRegionFinder.wl                         main HRF implementation
HRF_AsymptoticOrderAlignment.wl              canonical alignment extension
HRF_IdealLayerCertification.wl               occupied-layer/ideal-jet audit
HRF_LayeredDissectionCertification.wl        local lower-facet fallback
HRF_MomentumScalingReconstruction.wl         general component-valuation and loop-basis tools
HRF_WideAngleMomentumReconstruction.wl       Crown and all positive HyperCrown momentum certificates
HRF_WideAngleMomentumReconstructionTests.wl  compact certificate regressions
HRF_HyperCrownCodimensionSurvey.wl            reproducible codimension 0--2 status table and rerun helper
HRF_WideAngle16Codim2Audit.wl                 complete generator-first codimension-two manifest and runner
HRF_RunWideAngle16Codim2Batch.wl              checkpointed codimension-two batch runner
HRF_WideAngle16Codim2CoverageSummary.wl       provenance-aware coverage accounting

00_...nb -- 08_...nb                         general, four-, five-, and six-point notebooks
01_Current_WideAngle_4pt.nb                   positive wide-angle Crown-family record
02_Current_Regge_4pt.nb                       positive three-channel Regge Crown-family record
01_WideAngle_2to2_OffShell.wl                 wide-angle graph definitions and scans
02_Forward_Regge_2to2_Massless.wl             Regge kinematics and Crown-family scans
03_Current_SpacelikeCollinear_5pt.nb          principal five-point collinear record
08_Current_5pt_MRK_CentralSoft.nb             composite central-soft MRK record
examples/five_point_mrk_central_soft/         reproducible MRK notebook inputs and checks
04_Current_5pt_Preselection.nb                five-point topology preselection
HRF_Example03CollinearCore.wl                 five-point kinematics and graph core
HRF_Example03SeedStudy.wl                     seed/vertex factor and generator audit
HRF_RunExample03PolynomialDescendantScan.wl   seven/eight-propagator descendant runner
HRF_RunPreselected5ptScan.wl                  full 70-topology scan runner
WideAngle16_NoCrown_HRF_Audit.nb             four-loop wide-angle record
WideAngle16_NoCrown_Regge_HRF_Audit.nb       four-loop three-channel Regge record
NoCrown_4Loop_WideAngle_and_Regge_Audit_Guide.nb
                                                collaborator-facing methodology guide

data/wide_angle/                             graph definitions
data/nmrk/                                   portable NMRK kinematics and alignment seeds
results/dsc/                                 compact published DSC certificates
results/nmrk_wz/                             compact published NMRK w=z certificates
results/wa16_* and results/wide_angle_16_*   compact four-loop audit summaries
results/generated/                           untracked outputs of fresh scans
testdata/alignment/                          frozen full scans used only by regressions
output/pdf/                                  compiled physics notes
docs/                                        current HRF principles notes
```

## Recorded physics results

### Four-point Crown-minor picture

The wide-angle and Regge studies have two complementary parts.  In the tested
massless on-shell `2 -> 2` topologies through four loops, the working
conjecture is

```text
a hidden region is present  <=>  the topology has the three-loop Crown
                                  as a contraction minor.
```

This is an evidence-based conjecture, not a general graph-theoretic theorem.
The two directions are represented separately in the release.

#### Positive Crown-family examples

`01_Current_WideAngle_4pt.nb` gives the basic wide-angle positive examples and
a status-aware HyperCrown survey through codimension two.
The Crown itself has an interior hidden region.  In the larger Crown family,
the relevant region can live on a boundary stratum: setting the indicated
Schwinger parameters to zero contracts the larger graph to the Crown seed.
The notebook includes a focused current-path witness for the SuperCrown
codimension-two boundary `x8=x9=0`: its superleading polynomial is the Crown
polynomial times `x10 x11`, the obstruction vanishes, all ten active
components have `v_e=-1`, and the full weights are `(W_SL,W_HR)=(-6,-5)`.
This is a constructive example, not a full SuperCrown boundary scan.  The
notebook also displays the HyperCrown positive boundary at `x11=0`, alongside
the Crown interior and Diving Beetle controls. It then uses the exact `D4`
automorphism group of the HyperCrown square, simultaneously relabelling
external legs, edges and invariants. Crossing-related cuts are therefore
members of the same topology orbit rather than separate runs. There are two
established inequivalent boundary-HR types: a codimension-one type with four
labelled representatives and an adjacent-pair codimension-two type with four
labelled representatives. The opposite-pair codimension-two orbit has now
been excluded by an uncapped complete-polynomial-factor scan and exact
coverage: its sole generator is supported in the `s12` sector and has no
`s23` companion. The interior remains unresolved. The survey table distinguishes
established positive witnesses, certified exclusions, and capped or timed-out
searches; the latter are explicitly not no-HR certificates. It reports every accepted
HyperCrown vector and translates all distinct positive vectors to momentum
space. Boundary equations and scaling components are not conflated: `B`
records `x_e=0`, while active parameters obey `x_e ~ delta^(v_e)` and the
augmented normal is displayed as `(v_e;1)` in the fixed order
`(x0,x1,...,x11)` with the boundary variables deleted. The Crown is the familiar
generic-angle Landshoff configuration of four external-direction jets joining
two disconnected hard vertices. After contracting `x11`, the HyperCrown has
the same jet structure plus a soft `x10` loop. This is why a search confined
to the interior is not sufficient.

`02_Current_Regge_4pt.nb` supplies the corresponding positive Regge evidence.
The Crown interior is checked at wide angle and in all three Regge channels.
The SuperCrown boundary `x8=x9=0` has an accepted HR at wide angle and in all
three Regge channels; the HyperCrown boundary `x11=0` supplies the additional
positive Regge example recorded in channel `T12`.  These are explicit cases
where the hidden region of a larger graph is inherited on the contraction
stratum exposing its Crown minor.

Together these notebooks provide the positive side of both the Crown-minor
conjecture and the observed wide-angle-to-Regge correspondence.

#### No-Crown four-loop audits: the complementary “only if” tests

The 16 massless four-loop `2 -> 2` graphs have mixed-sign derivative factors
but no three-loop Crown contraction minor.  The wide-angle audit now covers
all 16 interiors and every one of the 114452 nonempty contraction strata
through `E-2`.  The historical record supplied all codimensions except 1012
codimension-two strata outside the sector containing `x8`; the current
uncapped generator-first scan gives a readable, untruncated `CompleteNoHR`
certificate for each of those 1012 strata.  No admissible cancellation
generator survives on any of them, and no positivity test remains unresolved.

The graph definitions are in `data/wide_angle/16_examples_diagrams.txt` and
the collaborator-facing synthesis is
`NoCrown_4Loop_WideAngle_and_Regge_Audit_Guide.nb`; the historical detailed
record remains `WideAngle16_NoCrown_HRF_Audit.nb`.

The same graphs were checked in the `T23`, `T12`, and `T13` Regge channels.
All 48 interiors and all 343356 nonempty contraction strata through `E-2` are
resolved, with no hidden region.  The exact reduction to six interior
permutation classes and the boundary face-closure argument are documented in
`WideAngle16_NoCrown_Regge_HRF_Audit.nb`.

These two No-Crown audits are the negative, or “only if”, side of the
Crown-minor conjecture.  Combined with notebooks 01 and 02, they also support
the wide-angle-to-Regge conjecture through four loops.  Both statements remain
conjectural beyond the tested sample.

### Five-point spacelike-collinear scattering

The two-loop five-point seed is the canonical application that introduced the
separation

```text
F_0 = F_SL + F_Obs.
```

On the positive cancellation locus, the factorised superleading sector
`F_SL` vanishes.  The obstruction `F_Obs` survives at the physical HR weight
and fixes the non-uniform scaling
`(-2,-1,-2,-2,-2,-1;1)`, with `W_HR-W_SL=1`.  Thus the ordinary facet and the
hidden region are distinguished by the weights assigned to the monomials of
the same polynomial, rather than by changing the polynomial.

This is also the application for which the use of HRF is stated publicly in
[Spacelike-Collinear Scattering by the Method of Regions](https://arxiv.org/abs/2607.15126).
The collaborator-facing record is `03_Current_SpacelikeCollinear_5pt.nb`.
It includes the six-propagator seed, the three-loop vertex topology, the
seven/eight-propagator descendant study, and the handoff to the full
70-topology preselected scan.  It now also includes the complete edge-momentum
tables for the ordinary facet and the HR, displaying explicitly the soft and
Glauber loop basis.  The topology preselection is separately
reproducible in `04_Current_5pt_Preselection.nb`.

### Five-point central-soft MRK

`08_Current_5pt_MRK_CentralSoft.nb` records the composite limit in which the
usual five-point MRK rapidity hierarchy is retained while the central emitted
momentum becomes soft.  It reports all six edge valuations.  In the adapted
basis `r=q0`, `ell=q0-q4`, the `q4` and `q5` Feynman poles approach the real
`ell+` contour from opposite half-planes and fix
`Delta ell+~delta^6`.  Together with the residual `q2=p3-ell`, this gives
local Glauber widths `(6,3,2)`.  Thus there is one genuine Glauber loop, not
two.  Its measure and that of the other loop yield the independent
momentum-space power `delta^(4D-16)`, matching parameter space.  Reproducible
scripts and compact results are in `examples/five_point_mrk_central_soft/`.

### NMRK with `w=z`

The one-loop hexagon has one structurally unique certified HR.  At two loops,
the planar hexbox has 11 certified vectors (7 full support and 4 boundary),
the nonplanar hexbox has 3 (1 full support and 2 boundary), and the
hexagon-pentagon is a negative control.  Generic central NMRK has no staged
candidate for these graphs.

### Double spacelike-collinear limit

The physical DSC chart and its signs are defined in
`07_DSC_AsymptoticOrderAlignment_Checks.nb` and
`DSC_TwistorInvariantData_20260719.wl`.  The one-loop example demonstrates why
the alignment representative and the face-only HRF scaling cannot simply be
added: the full occupied-layer audit fixes the final original-coordinate
vector.  The compact one- and two-loop certificates are under `results/dsc/`.

## Reproduction

The positive four-point studies are run directly from
`01_Current_WideAngle_4pt.nb` and `02_Current_Regge_4pt.nb`.  Their underlying
scripts are `01_WideAngle_2to2_OffShell.wl` and
`02_Forward_Regge_2to2_Massless.wl`.  Expensive optional interior and boundary
scans are disabled on a bare script load; the notebooks contain the explicit,
controlled calls for each recorded positive example.

Five-point spacelike-collinear descendants:

```sh
wolframscript -file HRF_RunExample03PolynomialDescendantScan.wl
```

The more expensive scan of all 70 preselected topologies is run with:

```sh
wolframscript -file HRF_RunPreselected5ptScan.wl
```

One-loop NMRK with `w=z`:

```sh
wolframscript -file HRF_RunWZNMRKHexagonAsymptoticOrderAlignment.wl
```

Two-loop NMRK, for example:

```sh
wolframscript -file HRF_RunNMRKMultiGraphAsymptoticOrderAlignment.wl planar-hexbox wz
```

Generic DSC, for example:

```sh
wolframscript -file HRF_RunGenericDSCAsymptoticOrderAlignment.wl hexagon
```

Fresh full scans are written under `results/generated/`; compact certificates
shipped with the release are not overwritten.

The wide-angle and Regge notebooks contain the exact commands for their
complete audits.  The complete scans are intentionally separated from the
fast regression suite because they are much more expensive.

## Regression suite

The release records the following passing checks:

| Suite | Result |
|---|---:|
| Polynomial cancellation factors and base HRF | 31/31 |
| Exact complete-polynomial-factor coverage | 2/2 |
| Crown/HyperCrown momentum reconstruction | 16/16 |
| Layered DSC/NMRK certification | 16/16 |
| Asymptotic-order-alignment API compatibility | 6/6 |
| Six-point notebook smoke tests | 17/17 |
| Crown/Regge/five-point notebook controls | 7/7 |
| Wide-angle face/pinch controls | 8/8 |
| Regge interior controls | 7/7 |
| Regge boundary controls | 9/9 |

The principal commands are:

```sh
wolframscript -code 'Get["HRF_PolynomialFactorRegressionTests.wl"]; Print[InputForm[hrfRunPolynomialFactorRegressionTests[]["Summary"]]]'
wolframscript -code 'Get["HRF_ExactCoverageRegressionTests.wl"]; Print[InputForm[hrfRunExactCoverageRegressionTests[]["Summary"]]]'
wolframscript -code 'Get["HRF_WideAngleMomentumReconstructionTests.wl"]; Print[InputForm[hrfRunWideAngleMomentumReconstructionTests[]["Summary"]]]'
wolframscript -code 'Get["HRF_NotebookSmokeTests.wl"]; Print[InputForm[hrfRunNotebookSmokeTests[]["Summary"]]]'
wolframscript -file HRF_AsymptoticOrderAlignmentCompatibilityTests.wl
wolframscript -file HRF_AsymptoticOrderAlignmentNotebookSmokeTests.wl
wolframscript -code 'Get["HRF_LayeredDissectionRegressionTests.wl"]; Print[InputForm[hrfRunLayeredDissectionRegressionTests[]["Summary"]]]'
wolframscript -code 'Get["HRF_WideAngle16FacePinchRegressionTests.wl"]; Print[InputForm[hrfRunWA16FacePinchRegressionTests[]["Summary"]]]'
wolframscript -file run_wa16_regge_interior_regression.wl
wolframscript -file run_wa16_regge_boundary_regression.wl
```

For a definitive absence claim, exploratory generator and monomial caps must
not be used.  Search limits, timeouts, or undecided positivity tests mean
`unresolved`, never `no HR`.  The detailed principles and algorithm history
are in `ALGORITHM_CHANGELOG.md`, `PIPELINE_CONDITIONS.md`, and
`RELEASE_PROVENANCE.md`.

The main correctness-sensitive budgets are public `findObstructions` options:
`"CandidateGeneratorSetLimit"`, `"MaxTwoGeneratorUnionTrials"`, and
`"PolynomialMaxMonomials"`. Results record their resolved values in
`"EffectiveSearchConfiguration"` and report `"SearchTruncatedQ"`. The current
notebooks display an exploratory profile and a certified profile in one setup
cell; the latter uses `Infinity`, `Infinity`, and `Automatic`, respectively.
Finite budgets are appropriate for finding witnesses, but never for proving
absence. The historical signed-monomial-pair enlargement is available through
`"EnableSignedMonomialPairs" -> True` only as a legacy diagnostic. The default
complete construction factorises the full derivatives and primitive channel
polynomials, so every candidate is an actual polynomial cancellation factor.

## Compatibility

The former terminology is retained only at an explicit compatibility
boundary.  `HRF_FaceliftPreselection.wl`, the old `hrfFacelift*` symbols, and
the old option names forward to their asymptotic-order-alignment counterparts.
New code, notebooks, result names, and documentation use the canonical term.

## Scope

The present implementation and examples concern massless internal
propagators.  Massive internal propagators introduce quadratic dependence on
individual Schwinger parameters and require a separate extension.
