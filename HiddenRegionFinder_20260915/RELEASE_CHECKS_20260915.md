# Release checks — 15 September 2026

All commands are run from the release root with Wolfram Language 15.0.1.
The expensive full discovery scans are not repeated during packaging; their
compact exact certificates and dedicated regression suites are checked.

## Mathematical regression suites

| Suite | Result |
|---|---:|
| Polynomial cancellation factors and base HRF | 31/31 |
| Exact complete-polynomial-factor coverage | 2/2 |
| Crown/HyperCrown momentum reconstruction | 16/16 |
| Layered DSC/NMRK integration | 20/20 |
| Source-aware dissection and pullback | 19/19 |
| Ordinary source-aware integration | 17/17 |
| Asymptotic-order-alignment API compatibility | 6/6 |
| Six-point notebook certificate checks | 17/17 |
| Explicit three-generator near-planar interface | 6/6 |
| Candidate-specific derivative-ideal saturation | 13/13 |
| Wide-angle face/pinch controls | 8/8 |
| Wide-angle codimension-two audit engine | 6/6 |
| Regge interior controls | 7/7 |
| Regge boundary controls | 9/9 |
| Saved Part-II/dissection record consistency | 12/12 |

The historical `HRF_NotebookSmokeTests.wl` is not a release gate; its role and
the conservative scope of the generic ordinary endpoint-chart certificate are
explained in `RELEASE_PROVENANCE.md`.

The Crown entry is a negative control for premature kinematic specialisation.
Substituting `s12=1, s23=-1` before the derivative harvest mixes the two
kinematic sectors and leaves only two relations, which correctly are not
promoted to a Crown HR.  The dedicated construction keeps the derivative
components multiplying `s12` and `s23` separate; factorising those components
recovers the four cancellation factors and two product generators.  The exact
Crown coverage and momentum-space suites remain green.

## Part-II/dissection records

| Topology | Exact result |
|---|---:|
| Planar hexagon--box | 13/13 staged candidates completely dissected; 25 physical HRs |
| Same-path hexagon--pentagon | 8/8 staged candidates completely decided; 9 physical HRs |
| Separate-path hexagon--pentagon | 0 staged candidates |

Notebook 12 and
`results/nmrk_wz/partII_dissection_table8_topology_comparison.wl` reproduce
these counts from the three individual records.

## Standalone exact audits

| Audit | Result |
|---|---:|
| `K33_TripleCancellation_Audit.wl` | passed |
| `K43_Landshoff_HRF_Audit.wl` | passed |
| `SoftDoubleCollinearResolvedMapCheck.wl` | passed |

## Structural and packaging checks

The final bundle is required to satisfy all of the following before handoff:

- every shipped `.wl` and `.nb` file parses with `SyntaxQ`;
- no user-specific absolute path occurs in Wolfram Language, Markdown, TeX,
  text or CSV sources;
- every literal local source dependency resolves inside the bundle;
- no symbolic link, `.DS_Store`, TeX auxiliary file or generated scan
  directory is present;
- the manuscript compiles from `docs/` without undefined references or
  citations;
- the stale load of the removed
  `HRF_WideAngle16HigherCodimPrefilter.wl` has been deleted from
  `run_wa16_face_pinch_depth_batch.wl`.

The completed bundle contains 260 files (235 Wolfram Language scripts or
notebooks) and occupies 175 MB.  All 235 Wolfram sources parse successfully.
The portability, local-dependency and unwanted-artifact scans are clean, and
the manuscript rebuilds to 134 pages without undefined references or
citations.
