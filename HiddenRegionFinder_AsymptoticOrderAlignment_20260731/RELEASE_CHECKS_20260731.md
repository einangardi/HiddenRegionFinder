# Release checks — 31 July 2026

These checks were run from the release root with Mathematica 15.0 through
`wolframscript`.  The compact exact certificates and dedicated controls
shipped with the release were tested; the expensive full discovery scans were
not repeated merely to package the dated directory.

## Mathematica checks

| Suite | Result |
|---|---:|
| Polynomial cancellation factors and base HRF | 31/31 |
| Exact complete-polynomial-factor coverage | 2/2 |
| Crown/HyperCrown momentum reconstruction | 16/16 |
| Layered DSC/NMRK certification | 16/16 |
| Asymptotic-order-alignment API compatibility | 6/6 |
| Six-point notebook smoke tests | 17/17 |
| Explicit three-generator near-planar interface | 6/6 |
| Candidate-specific derivative-ideal saturation | 13/13 |
| Crown/Regge/five-point notebook controls | 7/7 |
| Wide-angle face/pinch controls | 8/8 |
| Wide-angle codimension-two audit engine | 6/6 |
| Regge interior controls | 7/7 |
| Regge boundary controls | 9/9 |

The 13 candidate-specific saturation checks include the negative guard: an
attempt to saturate the undecomposed full gradient without an explicit
justification returns `ApplicabilityNotEstablished` and marks the search
incomplete.

## Structural and packaging checks

- `SyntaxQ` passed for all 197 shipped Wolfram Language and notebook files.
- No user-specific absolute path occurs in the shipped Wolfram Language,
  Markdown, TeX, text, or CSV sources.
- The release contains no symbolic links.
- The release contains no `.git` directory, `.gitignore`, `.gitattributes`,
  `.DS_Store`, or TeX auxiliary build files.
- The JHEP paper was compiled twice from `docs/` with no undefined reference
  or citation; only the source inputs, bibliography output, and final PDF are
  retained.

## Scientific scope of this consolidation

The central change is the separation between pre-decomposition factor
harvesting and candidate-specific positive-pinch validation.  The five-point
near-planar example is the corresponding positive control.  Its paper and
notebook presentation now gives the local dissection explicitly and records
independent parameter-space and momentum-space power counts.
