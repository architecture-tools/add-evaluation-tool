# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

## [0.1.0] - 2025-12-06

### Added

- Backend API endpoints for file upload functionality
- Backend API endpoints for retrieving list of diagrams
- Backend API endpoint for retrieving specific diagram by ID
- Backend route for parsing diagram data [#49](https://github.com/architecture-tools/add-evaluation-tool/pull/49)
- Basic frontend interface for core features [#50](https://github.com/architecture-tools/add-evaluation-tool/pull/50)
- Initial frontend-backend integration
- Update NFR list feature [#76](https://github.com/architecture-tools/add-evaluation-tool/pull/76)
- Testing for both frontend and backend [#61](https://github.com/architecture-tools/add-evaluation-tool/pull/61), [#71](https://github.com/architecture-tools/add-evaluation-tool/pull/71)
- CI/CD pipeline with automated testing [#62](https://github.com/architecture-tools/add-evaluation-tool/pull/62)
- PlantUML diagram parsing and component extraction
- NFR × Component evaluation matrix generation
- Matrix persistence and scoring functionality [#85](https://github.com/architecture-tools/add-evaluation-tool/pull/85)
- Diagram version management and storage [#96](https://github.com/architecture-tools/add-evaluation-tool/pull/96)
- Visual diff comparison between diagram versions [#97](https://github.com/architecture-tools/add-evaluation-tool/pull/97)
- OpenTelemetry integration with Grafana Beyla for observability [#95](https://github.com/architecture-tools/add-evaluation-tool/pull/95)
- Docker Compose deployment setup [#87](https://github.com/architecture-tools/add-evaluation-tool/pull/87)
- Web-based user interface for architecture evaluation
- NFR performance metrics display
- Version timeline visualization

### Fixed

- NFR performance score display (removed misleading "/10" suffix, now shows -1 to 1 range)
- Version timeline scores now fetch actual matrix scores for all diagrams
- Test reliability improvements for widget rendering

[0.1.0]: https://github.com/architecture-tools/add-evaluation-tool/releases/tag/v0.1.0
