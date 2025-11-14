---
layout: default
title: Constraints
nav_order: 3
parent: Requirements
---

# Technical and Business Constraints

## Table of Contents
- [Business Constraints](#business-constraints)
- [Technical Constraints](#technical-constraints)
- [Organizational Constraints](#organizational-constraints)
- [Regulatory and Compliance Constraints](#regulatory-and-compliance-constraints)

## Business Constraints

### Educational Context
- **Constraint**: The tool must be suitable for educational use in academic courses and research projects
- **Impact**: 
  - Deployment must be simple and accessible for stakeholders without advanced DevOps knowledge
  - Documentation must be comprehensive enough for self-service learning
  - The tool should support learning objectives related to Attribute-Driven Design (ADD) methodology
- **Rationale**: Primary stakeholders include students and researchers who need a tool that can be quickly deployed and understood without extensive training

### Single-User Focus (MVP)
- **Constraint**: MVP version targets single-user scenarios without multi-user collaboration features
- **Impact**:
  - No authentication or authorization system required initially
  - No concurrent editing or real-time collaboration features
  - Simplified data model without user management
- **Rationale**: Based on customer feedback from Sprint 1 meeting, the initial focus is on individual architecture evaluation workflows

### Manual Upload Workflow
- **Constraint**: No Git integration or automated version control in MVP
- **Impact**:
  - Users must manually upload PlantUML files for each version
  - Linear versioning system (no semantic versioning complexity)
  - No automated change detection or CI/CD integration
- **Rationale**: Customer explicitly requested manual uploads to simplify the MVP and focus on core evaluation functionality

### Docker-Based Deployment
- **Constraint**: Tool must be deployable via Docker Compose for easy client testing
- **Impact**:
  - All services must be containerized
  - Configuration must support single-command deployment
  - No external dependencies that require manual setup
- **Rationale**: Customer emphasized the importance of early deployment and frequent demos, requiring a simple deployment mechanism

## Technical Constraints

### PlantUML Format Dependency
- **Constraint**: System must support PlantUML component diagram format as the primary input
- **Impact**:
  - Parser must handle various PlantUML syntax conventions and versions
  - Limited control over input format (users may use different PlantUML styles)
  - Parsing accuracy depends on PlantUML library capabilities
- **Rationale**: PlantUML is the standard format chosen by the customer for architecture specifications

### Web-Based Architecture
- **Constraint**: Application must be accessible via standard web browsers
- **Impact**:
  - Frontend must work across major browsers (Chrome, Firefox, Safari, Edge)
  - No native desktop or mobile applications in MVP
  - Network latency considerations for API calls
- **Rationale**: Web-based access removes deployment barriers and enables immediate use without installation

### Local Storage Requirement
- **Constraint**: MVP uses local file system storage (not cloud-based)
- **Impact**:
  - Data persistence is tied to deployment location
  - No distributed storage or backup mechanisms
  - Limited scalability for large datasets
- **Rationale**: Educational context requires simple, self-contained deployment without external service dependencies

### Performance Targets
- **Constraint**: Matrix interaction must respond within 100ms (QAS201)
- **Impact**:
  - Client-side computation required for real-time updates
  - Optimistic UI updates with background synchronization
  - Potential need for Web Workers for complex calculations
- **Rationale**: User experience requirement to maintain responsive feel during matrix editing

### Scoring System Simplicity
- **Constraint**: MVP uses simple -1/0/+1 scoring system for component-NFR relationships
- **Impact**:
  - Limited granularity in evaluation scores
  - Simplified calculation algorithms
  - May not capture nuanced quality attribute relationships
- **Rationale**: Customer feedback from Sprint 1 meeting specified this scoring approach for MVP simplicity

### Technology Stack Lock-in
- **Constraint**: Backend uses Python/FastAPI, Frontend uses Flutter Web
- **Impact**:
  - Team expertise and learning curve considerations
  - Limited flexibility to change stack mid-project
  - Integration complexity between different language ecosystems
- **Rationale**: Technology choices made early in project based on team familiarity and project requirements

## Organizational Constraints

### Development Timeline
- **Constraint**: Project follows sprint-based development with fixed deadlines
- **Impact**:
  - Features must be prioritized and potentially deferred
  - MVP scope must be carefully managed
  - Quality vs. speed trade-offs may be necessary
- **Rationale**: Academic project structure with defined sprint cycles and deliverables

### Team Size and Expertise
- **Constraint**: Small development team (3 members) with specialized roles
- **Impact**:
  - Limited parallel development capacity
  - Knowledge concentration in specific areas
  - Dependency on individual team members
- **Rationale**: Educational project team structure

### Customer Availability
- **Constraint**: Customer feedback cycles depend on scheduled meetings
- **Impact**:
  - Delayed clarification of requirements
  - Potential need for assumptions and validation later
  - Importance of early demos to catch misalignments
- **Rationale**: Customer emphasized importance of frequent demos to ensure alignment

## Regulatory and Compliance Constraints

### Open Source Considerations
- **Constraint**: Project may be open-sourced or used in academic contexts
- **Impact**:
  - License selection must allow academic and research use
  - Code quality and documentation standards must support external contributors
  - No proprietary dependencies that restrict distribution
- **Rationale**: Educational and research context requires open access

### Data Privacy (Future)
- **Constraint**: Currently no user data collection, but future versions may need privacy considerations
- **Impact**:
  - Architecture should allow for future authentication/authorization
  - Data storage design should consider potential multi-tenancy
- **Rationale**: MVP is single-user, but future evolution may require user management

---

**Notes:**
- Constraints are documented to guide architectural decisions and prevent scope creep
- Some constraints may be relaxed in future iterations after MVP delivery
- Technical constraints should be validated through proof-of-concept implementations

