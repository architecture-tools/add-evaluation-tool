---
layout: default
title: Testing Automation
nav_order: 3
parent: Automation
---

## Unit tests

- **Location & naming**: Backend unit tests live under `backend/tests/` and
  follow the `test_*.py` and `*/test_*.py` naming convention so pytest
  auto-discovers them. Each test uses explicit `# Arrange`, `# Act`, `# Assert`
  comments for fast code reviews.
- **Run tests**: `cd backend && make test`
- **Generate coverage**: The same command emits terminal, XML, and JSON coverage
  reports (via `pytest-cov`). Run `poetry run python
  scripts/check_module_coverage.py` afterward to enforce per-module thresholds.
- **Adjust minimum thresholds**: Edit `backend/tests/coverage-thresholds.json`;
  each entry maps a module path to the required percentage. Commit both the
  JSON change and any follow-up fixes.
- **Coverage report format rationale**: Terminal output gives immediate
  developer feedback, XML integrates with CI dashboards, and JSON feeds the
  automated threshold checker—covering local, CI, and policy workflows without
  rerunning tests.
- **Why these minimum thresholds**: We set 80–90% minimums for the three
  riskiest modules to ensure meaningful exercise of core flows while still
  attainable for new contributors (and comfortably above the requested 30%
  floor).
- **Planned MVP thresholds**: We intend to raise these modules to at least 90%
  once the MVP stabilizes so critical regressions remain detectable even as the
  codebase grows.
- **Modules under test & rationale**: `app/domain/diagrams/entities.py` (core
  aggregate behavior), `app/infrastructure/persistence/in_memory.py` (repository
  semantics used in higher layers), and `app/application/system/services.py`
  (health reporting surfaced to customers). They change frequently and failures
  have outsized customer impact.
