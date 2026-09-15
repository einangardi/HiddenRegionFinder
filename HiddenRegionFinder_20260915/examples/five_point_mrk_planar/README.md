# Five-point simultaneous MRK and near-planarity

This directory studies the two-loop six-edge fish (theta) topology in a
composite limit that combines:

- standard fixed-transverse multi-Regge kinematics, with both rapidity gaps
  growing as `delta^(-b)`; and
- approach to the coplanar boundary, with
  `w-wbar = i delta^a`.

It is a third path through five-point kinematics.  It is distinct both from
the fixed-wide-angle near-planar expansion and from the central-soft
rapidity-ordered limit in `../five_point_mrk_central_soft/`.

## Main result

The certified representative uses attachment order `{1,2,3,5,4}` at graph
vertices `1,...,5`.  The theta endpoints are vertices 3 and 5, so they carry
`p3,p4`; `p5` is attached to the trivalent path vertex 4.  For positive
integer rates `a,b`, its positive stationary ratios behave as

```text
(rho_A,rho_B,rho_C) ~ (1,delta^b,1).
```

The local lower facet pulls back to the original Schwinger variables as

```text
v = (-2a,-2a,b-2a,-2a,-2a,-2a;1).
```

For the equal-rate representative `a=b=1`,

```text
v = (-2,-2,-1,-2,-2,-2;1).
```

There are two cancellation layers.  The `AB` and `BC` pair sectors start at
weight `-6a-b`, the `AC` pair sector starts at `-6a`, and both resolve at
the hidden-region weight `-4a`, where `U` and the Gram-normal term also
enter.  For equal rates this is

```text
-7, -6  -->  -4.
```

In the local coordinates

```text
x0=rho_A u_A+n_A, x1=u_A,
x2=rho_B u_B+n_B, x3=u_B,
x4=rho_C u_C+n_C, x5=u_C,
```

the facet vector is

```text
(u_A,u_B,u_C,n_A,n_B,n_C)
  = (-2a,-2a,-2a,-a,-a+2b,-a).
```

The exact leading polynomial has seven monomials and affine rank six, so it
is a full lower facet in the six local variables.  This supplies the
positive-pinch certificate independently of the current generic alignment
wrapper.

The raw dimensionful Gram determinant need not tend to zero in MRK because
the overall hard scale grows.  The projective statement is the exact
identity

```text
Gamma5/s12^2 = -Q2^2 delta^(2a).
```

Thus planarity is correctly approached after removal of the growing hard
scale.

## Momentum-space interpretation

For the equal-rate representative, the exact edge-flow audit gives the
following values at the Landau saddle:

```text
q0 : ( 3,-1,1)    q0^2 ~ delta^2
q1 : ( 3,-1,1)    q1^2 ~ delta^2
q2 : (-1, 3,1)    q2^2 ~ delta^2
q3 : ( 0, 3,1)    q3^2 ~ delta^2
q4 : ( 1,-1,0)    q4^2 ~ delta^2
q5 : ( 1,-1,0)    q5^2 ~ delta^2
```

The triples are the powers of `(q_e^+,q_e^-,|q_e_perp|)`.  The saddle
virtualities are not all the characteristic region virtualities.  The
Schwinger vector requires

```text
(q0^2,...,q5^2)_region ~
  (delta^2,delta^2,delta,delta^2,delta^2,delta^2).
```

Thus `q2^2` cancels one power deeper exactly at the saddle.  Since `q2` is a
dependent edge in the path-adapted basis, this does not establish a mismatch
between an independent loop momentum and its width.  Choose instead one
independent momentum on path A and one on path C.  In the corresponding local
lightcone frames, both central modes and their marginal widths scale as

```text
Delta q_A ~ (delta^(2a+b), delta^(-b), delta^a),
Delta q_C ~ (delta^(2a+b), delta^(-b), delta^a).
```

Their longitudinal fractions have correlated support
`delta^(3a+b)`.  The two loop measures each have power `a D`, while
the six region virtualities sum to `12a-b`.  Momentum-space power counting
therefore gives

```text
delta^(a D) delta^(a D) delta^(3a+b) delta^(-(12a-b))
  = delta^(-9a+2b+2a D),
```

exactly matching parameter space.  There is no independent Glauber loop in
this reconstruction.  The notebook contains the corresponding colour-coded
momentum-mode diagram.

## Attachment dependence

The rapidity-symmetric attachment `{1,2,3,4,5}` instead places the extremal
partons `p3,p5` at the two four-valent endpoints and emits the central parton
`p4` from trivalent vertex 4.  It does **not** have a positive first-sheet
pinch on this path.  Its stationary ratios have leading behaviour

```text
rho_A ~ -(Kp Mm xi/Q2) delta^(-b),
rho_B ~  (Kp(1+xi)/(Pp xi)) delta^b,
rho_C ~ -(1+xi).
```

The exact twelve-order audit finds only the endpoint-reflected pair

```text
{1,2,3,5,4}, {1,2,4,5,3}
```

with positive stationary ratios.  In both, `p4` occupies a four-valent
endpoint and `p5` a trivalent path vertex.  The reflected vector is obtained
by `x0<->x1`, `x2<->x3`, `x4<->x5`, so its exceptional component is `v3`
rather than `v2`.

## Files

- `FivePoint_MRK_Planar_Composite_Limit.nb` is the readable, self-contained
  physics notebook.
- `HRF_FivePointMRKPlanarCompositeAudit.wl` performs the exact invariant,
  local-coordinate and lower-facet checks.
- `HRF_FivePointMRKPlanarAttachmentAudit.wl` checks the positive stationary
  ratios for all twelve inequivalent external attachments.
- `HRF_FivePointMRKPlanarMomentumAudit.wl` checks the exact saddle edge
  valuations, the distinct region virtualities and the
  parameter/momentum power-counting identity.
- `rebuild_five_point_mrk_planar_notebook.wl` rebuilds the notebook.
- `results/equal_rate_audit.wl` and `results/rate_table.wl` are reproducible
  machine-readable results.
- `results/attachment_audit.wl` records the attachment scan.
- `results/momentum_mode_audit.wl` records the momentum-mode certificate.

Run the exact representative audit with

```text
wolframscript -file HRF_FivePointMRKPlanarCompositeAudit.wl
```

The representative symbolic audit takes about one minute with Mathematica
15.0 on the development machine.

## Present HRF-wrapper status

The generic alignment scan sees the relevant promoted face, proportional to

```text
(-Pp x2+Kp x3) (x1 x4-x0 x5),
```

but a single-product staged candidate is not the complete three-normal,
two-layer construction.  Its naive composed-vector test therefore rejects
the candidate.  The exact local audit in this directory proves that this is
a wrapper limitation, not evidence for absence of the region.  The general
HRF alignment wrapper should only be amended after this example has been
used as a regression test.
