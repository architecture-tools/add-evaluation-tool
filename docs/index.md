---
layout: default
title: Home
nav_order: 1
description: "Welcome to the Architecture Evaluation Tool documentation site"
---

# Architecture Evaluation Tool Documentation

Welcome to the documentation site for the **Architecture Evaluation Tool** project. This site contains all project documentation, including sprint reports, requirements, architecture documentation, and development guides.

## What's on This Site

This documentation site is organized into several main sections:

### 📋 [Sprint Documentation](./sprints/)
Contains detailed documentation for each sprint, including:
- Sprint 0: Initial research, customer interviews, and project setup
- Sprint 1 and beyond: Development progress and deliverables
- Meeting notes and interview scripts
- Sprint reports and deliverables

### 🏗️ [Architecture Documentation](./architecture/)
Technical architecture documentation including:
- System architecture and context diagrams
- Component specifications
- Technology stack decisions
- Sequence diagrams and use cases

### 📝 [Requirements](./requirements/)
Project requirements documentation:
- Functional requirements (FR1-FR12)
- Quality and non-functional requirements
- Requirements traceability

### 📊 [Strategic Plan](./plan.html)
Project planning and strategy:
- Project goals and thresholds of success
- Roadmap and milestones
- Monitoring and contingency strategies

### 🤖 [AI Usage](./ai-usage.html)
Documentation of AI tool usage throughout the project development, updated each sprint.

## Quick Links

- **GitHub Repository**: [architecture-tools/add-evaluation-tool](https://github.com/architecture-tools/add-evaluation-tool)
- **Main README**: [Project README](https://github.com/architecture-tools/add-evaluation-tool/blob/main/README.md)

## About the Project

The Architecture Evaluation Tool is a web-based application that helps software architects evaluate architectures using an evolution theory matrix. The tool:

- Parses PlantUML diagrams to extract architectural components
- Generates evaluation matrices (NFRs × Components)
- Enables scoring and calculation of overall architecture quality
- Provides version comparison with visual diffs
- Tracks quality evolution over time

## Getting Started

If you're new to the project, we recommend starting with:
1. The [Project README](https://github.com/architecture-tools/add-evaluation-tool/blob/main/README.md) for an overview
2. [Sprint 0 Report](./sprints/sprint-0/report.html) to understand the project vision
3. [Architecture Documentation](./architecture/architecture.html) for technical details

---

*This documentation site is automatically published via GitHub Pages. Last updated: {{ site.time | date: "%B %d, %Y" }}*

