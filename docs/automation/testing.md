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

## Integration tests (Quality attribute scenario tests)

Quality attribute scenario tests (QASTs) are integration tests that verify
that the system meets non-functional requirements by testing the full
application stack. These tests run automatically as part of the CI pipeline.

### QAST202-1: PlantUML Processing Performance

**Quality Attribute Scenario:** [QAS202 - PlantUML Processing
Performance](../requirements/quality-requirements.md#qas202)

**Test Objective:** Verify that 95% of PlantUML files complete processing
within 3 seconds.

**Automation:** The test is implemented in
[`backend/scripts/test_qast202_1.py`](../../backend/scripts/test_qast202_1.py).
It generates 100 PlantUML test files of varying complexity (10KB-100KB, 5-50
components) and measures the time from file upload through parsing completion
against the running API.

**How it works:**
1. Generates test PlantUML files with varying sizes and component counts
2. Uploads each file to the API endpoint (`POST /api/v1/diagrams`)
3. Triggers parsing for each uploaded diagram (`POST /api/v1/diagrams/{id}/parse`)
4. Measures total processing time (upload + parse) for each file
5. Verifies that 95% of files complete within 3 seconds

**Success Criteria:** 95% of files must complete processing within 3 seconds.

**CI/CD Integration:** Runs in the `test-integration` job as part of the CI
pipeline. The job automatically starts the application using docker-compose,
runs the tests, and reports results in the GitHub Actions job summary.

### QAST302-1: Component Extraction Accuracy

**Quality Attribute Scenario:** [QAS302 - Component Extraction
Accuracy](../requirements/quality-requirements.md#qas302)

**Test Objective:** Verify that component extraction achieves at least 95%
accuracy across diverse PlantUML diagram styles.

**Automation:** The test is implemented in
[`backend/scripts/test_qast302_1.py`](../../backend/scripts/test_qast302_1.py).
It uses a corpus of 15 PlantUML files with known component and relationship
counts, uploads them to the API, parses them, and compares extracted counts
against expected values.

**How it works:**
1. Loads a test corpus of 15 PlantUML files with known component/relationship
   counts
2. Uploads each file to the API (`POST /api/v1/diagrams`)
3. Parses each diagram (`POST /api/v1/diagrams/{id}/parse`)
4. Compares extracted component and relationship counts against expected values
5. Calculates accuracy percentage for each file
6. Verifies that 95% of files achieve ≥95% extraction accuracy

**Success Criteria:** At least 95% of test files must achieve ≥95% extraction
accuracy (measured as the average of component and relationship accuracy).

**CI/CD Integration:** Runs in the `test-integration` job as part of the CI
pipeline. The job automatically starts the application using docker-compose,
runs the tests, and reports results in the GitHub Actions job summary.
