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
- Backend route for parsing diagram data
- Basic frontend interface for core features
- Initial frontend-backend integration
- Update NFR list feature
- Testing for both frontend and backend
- CI/CD pipeline with automated testing
- PlantUML diagram parsing and component extraction
- NFR × Component evaluation matrix generation
- Matrix persistence and scoring functionality
- Diagram version management and storage
- Visual diff comparison between diagram versions
- OpenTelemetry integration with Grafana Beyla for observability
- Docker Compose deployment setup
- Web-based user interface for architecture evaluation
- NFR performance metrics display
- Version timeline visualization

### Fixed

- NFR performance score display (removed misleading "/10" suffix, now shows -1 to 1 range)
- Version timeline scores now fetch actual matrix scores for all diagrams
- Test reliability improvements for widget rendering

[0.1.0]: https://github.com/architecture-tools/add-evaluation-tool/releases/tag/v0.1.0
