---
layout: default
title: Strategic Plan
nav_order: 5
---

# Strategic Plan

## Project goals

- Deliver an end-to-end architecture evaluation tool that unifies
  Attribute-Driven Design guidance, matrix-based analysis, and visual
  diffing of PlantUML models.
- Provide a repeatable workflow for student and research teams to capture
  architectural decisions, evaluate non-functional requirements, and
  compare architecture versions over time.
- Build an open, extensible foundation (frontend, backend, data model) that
  can evolve into a production-ready platform after the course.

## Threshold of success

- MVP users can upload a PlantUML component diagram and automatically receive
  a populated NFR × Component evaluation matrix within 2 minutes.
- The tool stores at least five historical versions of an architecture and
  produces a diff report (diagram + scores) in under 5 seconds per
  comparison.
- At least three external testers (students or researchers) can complete the
  core workflow—upload diagram, adjust scores, compare versions—without
  direct assistance.
- Documentation covers onboarding (README), architecture, and usage scenarios,
  enabling new contributors to add features within one sprint.

## Feature roadmap

- [x] Sprint 0: team formation, research, interview, documented findings,
  strategic plan.
- [ ] Sprint 1: refine product backlog, finalize architecture decisions,
  and stub core services.
- [ ] Sprint 2: implement baseline PlantUML ingestion and persistence layer
  with seed data.
- [ ] Sprint 3: deliver first-cut matrix UI and hook it to parsed model data.
- [ ] Sprint 4: add scoring logic, version storage APIs, and happy-path
  evaluation flow.
- [ ] Sprint 5: prototype diff visualizations (textual + simple diagram
  highlights) and gather feedback.
- [ ] Sprint 6: expand reporting, accessibility, and onboarding
  documentation based on user feedback.
- [ ] Sprint 7: harden quality with integration tests, CI automation, and
  performance tuning.
- [ ] Sprint 8: finalize release readiness—security review, deployment
  guides, and course presentation prep.

## Progress monitoring

- Sprint reviews every week with demo-ready increments and acceptance
  criteria checklists.
- KPI dashboard (GitHub project board, burndown chart) monitoring story
  throughput, open issues, and test coverage.
- Automated CI pipeline running unit/lint tests on every PR; nightly builds
  executing integration suites and performance smoke tests.
- Every week stakeholder sync with customer to validate assumptions, confirm
  priorities, and collect qualitative feedback.

## Contingency plans

- If PlantUML parsing proves unreliable, pivot to Structurizr DSL import
  with automatic conversion to PlantUML, keeping the matrix workflow intact.
- Should scoring formulas remain undefined, ship with a configurable
  default (weighted averages) and expose admin settings to adjust once final
  guidance arrives.
- For visual diff complexity, release a phased approach: start with textual
  diff + matrix delta, add diagram overlays once core value is stable.
- If scope threatens schedule, lock MVP at matrix evaluation + version
  comparison and defer advanced automation (ADD guidance, AI hints) to
  future iterations.
