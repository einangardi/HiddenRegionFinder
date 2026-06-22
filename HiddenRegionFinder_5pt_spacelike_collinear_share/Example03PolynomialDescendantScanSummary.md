# Example 03 Polynomial Descendant Scan

Run date: 2026-06-22.

This scan reruns the six seven-propagator and nine eight-propagator descendant
topologies of Example 03 using the current polynomial-factor HRF branch.

Settings:

- polynomial cancellation-factor patch enabled;
- generator completion enabled through the `Collinear5pt` preset;
- `Collinear5pt` / `SingleProduct` obstruction options;
- `UseExtendedFactors -> False`;
- `$HRFPolynomialRequireKinematicDomainQ = False`, matching the current Example
  03 driver convention;
- seven-propagator boundary scan: `{x6}`;
- eight-propagator boundary scan: codimension 1 and 2 strata;
- scaling search includes the coordinate-uniform fallback up to `maxAbs = 5`.

The exported data files are:

- `Example03PolynomialDescendantScanSummary.wl`
- `Example03PolynomialDescendantScanRows.csv`
- `Example03PolynomialDescendantHRRows.csv`

## Overall Result

| Count | Value |
|-------|------:|
| Total summary rows | 73 |
| HR rows with accepted scaling | 24 |
| Seven-propagator HR rows | 8 |
| Eight-propagator HR rows | 16 |
| Interior HR rows | 3 |
| Boundary HR rows | 21 |
| HR rows using polynomial SL-sector factors | 0 |
| HR rows using only binomial SL-sector factors | 24 |

Thus, in this Example 03 descendant set, the current polynomial algorithm still
does not find a successful HR whose selected superleading-sector factors are
longer polynomials. Polynomial safe factors are generated in many scans, and in
some accepted rows they appear among the cancellation factors, but every
accepted `F_SL` sector uses two binomial `f_k` factors.

There are 44 rows with an obstruction candidate but no accepted scaling, and 5
rows with no obstruction record. These failed rows include several cases where
polynomial safe factors are available, so this remains a useful audit trail for
future improvements.

## Seven-Propagator Descendants

| Graph | Interior HR | Boundary HR | Scaling vectors | SL-sector factors |
|-------|-------------|-------------|-----------------|------------------|
| `G_sbullet` | no | yes, `{x6}` | boundary `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_tbullet` | yes | yes, `{x6}` | interior `{-2,-1,-2,-2,-2,-1,-2}`; boundary `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_ubullet` | no | yes, `{x6}` | boundary `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_bullets` | no | yes, `{x6}` | boundary `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_bullett` | yes | yes, `{x6}` | interior `{-2,-1,-2,-2,-2,-1,0}`; boundary `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_bulletu` | no | yes, `{x6}` | boundary `{-2,-1,-2,-2,-2,-1}` | 2 binomial |

The surprising current conclusion is that `G_sbullet` has no accepted interior
HR in this route, even after checking the trimmed polynomial generator suggested
in the discussion. In that check the trimmed generator is admissible, but the
obstruction remains at the same leading weight as `F_SL`, so the LP hierarchy
condition fails.

## Eight-Propagator Descendants

One eight-propagator interior HR is found, for `G_tt`. All nine topologies have
at least one boundary HR.

| Graph | Interior HR | Boundary HR strata with accepted scaling | Scaling vectors | SL-sector factors |
|-------|-------------|------------------------------------------|-----------------|------------------|
| `G_ss` | no | `{x6,x7}` | `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_su` | no | `{x6,x7}` | `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_tt` | yes | `{x6}`, `{x7}`, `{x6,x7}` | interior `{-2,-1,-2,-2,-2,-1,-2,0}`; boundary `{-2,-1,-2,-2,-2,-1,0}`, `{-2,-1,-2,-2,-2,-1,-2}`, `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_us` | no | `{x6,x7}` | `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_uu` | no | `{x6,x7}` | `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_ts` | no | `{x6}`, `{x6,x7}` | `{-2,-1,-2,-2,-2,-1,-2}`; `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_st` | no | `{x7}`, `{x6,x7}` | `{-2,-1,-2,-2,-2,-1,0}`; `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_ut` | no | `{x7}`, `{x6,x7}` | `{-2,-1,-2,-2,-2,-1,0}`; `{-2,-1,-2,-2,-2,-1}` | 2 binomial |
| `G_tu` | no | `{x6}`, `{x6,x7}` | `{-2,-1,-2,-2,-2,-1,-2}`; `{-2,-1,-2,-2,-2,-1}` | 2 binomial |

## Interpretation

For these 15 Example 03 descendant topologies, the current polynomial branch
confirms the known binomial-sector HR structure, recovers two seven-propagator
interior HRs, finds one eight-propagator interior HR, and finds boundary HRs
throughout the seven- and eight-propagator families. It does not yet provide an
example where a newly completed longer polynomial `f_k` enters the selected
valid HR generator.

This is a stable baseline for moving to the 70 preselected five-point
topologies. The 70-topology scan should read the original graphs from
`RecursiveDerivativePreselectionHandoff.wl`; the recorded
`PreselectionZeroVars` should remain diagnostic only.
