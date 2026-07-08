# HiddenRegionFinder — active development

This directory is the **working copy** for ongoing development after the frozen release.

| Location | Role |
|----------|------|
| [`../HiddenRegionFinder_v2/`](../HiddenRegionFinder_v2/) | **Frozen** v2025.06.22 — GitHub / collaborators |
| **`HiddenRegionFinder_polynomial_factors_dev/`** (here) | Active development |
| [`../HiddenRegionFinder_polynomial_factors/`](../HiddenRegionFinder_polynomial_factors/) | Legacy dev tree (may lag; prefer `_dev` for new work) |

## Sync from release

To realign with the frozen baseline:

```bash
rsync -a --exclude '.git' ../HiddenRegionFinder_v2/ ./
```

## Documentation

Same as release: `README.md`, `ALGORITHM_CHANGELOG.md`, `PIPELINE_CONDITIONS.md` — update here first, then re-export to `HiddenRegionFinder_v2/` when cutting the next release.
