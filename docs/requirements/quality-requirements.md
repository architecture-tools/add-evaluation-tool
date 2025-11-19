---
layout: default
title: Quality Requirements
nav_order: 2
parent: Requirements
---

# Quality Requirements

## Table of Contents

- [Priority Matrix](#priority-matrix)
- [Usability](#usability)
- [Performance](#performance)
- [Accuracy](#accuracy)
- [Maintainability](#maintainability)
- [Compatibility](#compatibility)

## Priority Matrix

**Priority Matrix for Architecture Evaluation Tool:**

| Technical Risk →<br>Business Importance ↓ | L | M | H |
|--------------------------------------------|----|----|----|
| **L** | | [QAS401](#qas401) | |
| **M** |  | [QAS201](#qas201), [QAS202](#qas202) | [QAS302](#qas302) |
| **H** | [QAS102](#qas102) | [QAS301](#qas301), [QAS501](#qas501) | [QAS101](#qas101) |

**Key:**

- Rows - Business Importance
- Columns - Technical Risk
- L - low, M - medium, H - high
- Elements - identifiers of quality requirements scenarios

**Priority Explanation:**

The priority matrix is organized by Business Importance (rows) and
Technical Risk (columns). This prioritization approach ensures that we
focus on delivering maximum value while managing technical complexity
effectively. The rationale for each priority level is explained below.

**Critical Priority (H, H)**

1. **(H, H): [QAS101](#qas101) - Intuitive web interface**
   - **Business Rationale**: The tool's primary value proposition is
     enabling architects to quickly evaluate architectures. If users
     cannot understand and use the interface within 5 minutes, the tool
     fails its core purpose. This directly impacts adoption in
     educational contexts where students need immediate usability.
   - **Technical Risk Rationale**: Designing an intuitive interface for
     complex matrix interactions and version comparisons requires careful
     UX design, extensive user testing, and iterative refinement. The
     challenge lies in making complex architectural concepts accessible
     without oversimplification.
   - **Why Critical**: This is the gateway to all other functionality.
     Without intuitive usability, even perfect parsing and calculation
     accuracy become irrelevant.

**High Priority**

2. **(H, M): [QAS301](#qas301) - Scoring calculation precision**
   - **Business Rationale**: Accurate scoring is fundamental to the
     tool's credibility. Architects rely on calculated scores to make
     decisions about architecture quality. Incorrect calculations would
     undermine trust and lead to poor architectural decisions, especially
     in educational contexts where students learn from the tool's outputs.
   - **Technical Risk Rationale**: While mathematical calculations are
     straightforward, the complexity arises from ensuring precision across
     edge cases, handling custom weights, and maintaining consistency
     across version comparisons. The risk is medium because the
     algorithms are well-defined, but implementation must be rigorous.
   - **Why High Priority**: This is a core differentiator - the tool's
     value comes from accurate evaluation, not just visualization.

3. **(H, M): [QAS501](#qas501) - PlantUML format support**
   - **Business Rationale**: PlantUML is the chosen standard input
     format. Without reliable format support, users cannot use the tool
     with their existing diagrams. This is a hard requirement that blocks
     all other functionality.
   - **Technical Risk Rationale**: PlantUML has various syntax
     conventions and versions. Parsing must handle diverse diagram styles
     while maintaining 90%+ success rate. The risk is medium because
     PlantUML libraries exist, but integration and edge case handling
     require careful implementation.
   - **Why High Priority**: This is the foundation - without parsing,
     the tool cannot function.

4. **(M, H): [QAS302](#qas302) - Component extraction accuracy**
   - **Business Rationale**: Accurate component extraction ensures the
     evaluation matrix is correctly populated. While important, some
     manual correction is acceptable in MVP, making business importance
     medium rather than high.
   - **Technical Risk Rationale**: PlantUML parsing complexity is high
     due to various syntax styles, nested structures, and relationship
     representations. Achieving 95%+ accuracy across diverse diagrams is
     technically challenging and may require iterative parser
     improvements.
   - **Why High Priority**: Despite medium business value, the high
     technical risk means we must start early and iterate, making it a
     high priority for risk mitigation.

**Medium Priority**

5. **(M, M): [QAS201](#qas201), [QAS202](#qas202) - Performance
   requirements**
   - **Business Rationale**: Performance impacts user experience but
     doesn't block core functionality. Users can tolerate some delay,
     especially in educational contexts where the focus is on learning
     rather than production efficiency.
   - **Technical Risk Rationale**: Achieving sub-100ms matrix updates
     and 3-second file processing requires optimization but is achievable
     with modern web technologies and client-side computation. The risk
     is manageable with proper architecture.
   - **Why Medium Priority**: Important for user satisfaction but not
     critical for MVP success. Can be optimized iteratively based on user
     feedback.

6. **(H, L): [QAS102](#qas102) - Clear visualization**
   - **Business Rationale**: Clear visualization is crucial for
     understanding architectural changes and quality impacts. This
     directly supports the tool's educational and evaluation purposes.
   - **Technical Risk Rationale**: Visualization is low risk because
     modern web frameworks (Flutter Web) provide robust UI capabilities.
     The challenge is design, not implementation complexity.
   - **Why Medium Priority**: While high business value, low technical
     risk means it can be addressed incrementally without blocking other
     work.

**Low Priority**

7. **(L, M): [QAS401](#qas401) - Code quality and testability**
   - **Business Rationale**: Code quality doesn't directly impact end
     users in MVP. However, it's important for maintainability and future
     development. Business importance is low for MVP but increases over
     time.
   - **Technical Risk Rationale**: Maintaining 80%+ test coverage
     requires discipline and time investment. The risk is medium because
     it's achievable but requires consistent effort throughout development.
   - **Why Low Priority**: Important for long-term success but not
     critical for MVP delivery. Can be addressed incrementally as the
     codebase grows.

**Prioritization Strategy Summary:**

The prioritization follows a risk-adjusted value approach:

- **Critical items** (H, H) are addressed first to unblock all other
  work
- **High priority items** focus on core functionality (parsing,
  calculation) and high-risk items that need early attention
- **Medium priority items** enhance user experience but don't block
  core functionality
- **Low priority items** support long-term maintainability but can be
  deferred for MVP

This approach ensures we deliver a functional, usable tool first, then
enhance performance and maintainability based on real user feedback.

## Usability

### QAS101

#### Intuitive Web Interface

- **Source**: End users (software architects)
- **Stimulus**: Architect opens the application for the first time
- **Artifact**: Web application interface
- **Environment**: Normal operation, first-time use
- **Response**: User can understand how to upload PlantUML files and
  begin evaluation within 5 minutes without external documentation
- **Response Measure**: 90% of test users successfully complete initial
  evaluation workflow without assistance

### QAST101-1

Test: Test 10 software architects with varying technical backgrounds.
Provide them with the application URL and a sample PlantUML file.
Measure time to successful completion of first architecture evaluation.

Success: 9 out of 10 users complete evaluation within 10 minutes
without requesting help.

### QAST101-2

Test: Have a survey to collect feedback from architects about the time
it took them to understand the interface and if they needed help or not.

Success: 90% of responses should have time <= 5 minutes and with no
help.

### QAS102

#### Clear Visualization of Architectural Changes

- **Source**: End users evaluating architecture evolution
- **Stimulus**: User compares two versions of architecture
- **Artifact**: Visualization components and diff interface
- **Environment**: During architecture review sessions
- **Response**: System clearly displays what components changed, how
  quality attributes were affected, and overall architecture score
  impact
- **Response Measure**: Users can identify key changes and their quality
  impacts within 30 seconds of viewing comparison

### QAST102-1

Test: Provide users with two versions of architecture containing at
least 10 components and 8 quality attributes. Measure time to correctly
identify: (a) which components were added/removed, (b) which quality
attributes improved/degraded, (c) overall score change.

Success: 90% of users were done within 30 seconds.

## Performance

### QAS201

#### Responsive Matrix Interaction

- **Source**: User interacting with evaluation matrix
- **Stimulus**: User inputs or modifies scores in a large matrix
  (components x quality attributes)
- **Artifact**: Evaluation matrix interface
- **Environment**: Normal editing session
- **Response**: Matrix updates and recalculations occur with
  imperceptible delay
- **Response Measure**: Input-to-visual-update latency under 100ms for
  all matrix operations

### QAST201-1

Test: Load matrix with 30 components and 20 quality attributes. Using
automated testing, measure time from score input to visual update across
1000 random cell modifications.

Success: measured response time for 95% of modifications must be under
100ms.

### QAS202

#### PlantUML Processing Performance

- **Source**: User uploading architecture diagrams
- **Stimulus**: Upload of complex PlantUML file (50KB+, 25+ components)
- **Artifact**: File processing system
- **Environment**: Standard web environment
- **Response**: File is parsed, components extracted, and matrix
  initialized quickly
- **Response Measure**: Processing completes within 3 seconds for 95%
  of files

### QAST202-1

Test: Process 100 sample PlantUML files of varying complexity
(10KB-100KB, 5-50 components).

Success: 95% of files must complete processing within 3 seconds on
standard hardware.

## Accuracy

### QAS301

#### Scoring Calculation Precision

- **Source**: System calculating architecture scores
- **Stimulus**: User inputs scores with custom weights
- **Artifact**: Scoring calculation engine
- **Environment**: Evaluation session
- **Response**: All calculations are mathematically precise according to
  defined algorithms
- **Response Measure**: 100% accuracy verified against manual
  calculations for 10 test cases

### QAST301-1

Test: Generate 10 random test matrices with varying weights and scoring
patterns. Compare system calculations against verified manual
calculations.

Success: achieve 100% accuracy.

### QAS302

#### Component Extraction Accuracy

- **Source**: PlantUML parsing system
- **Stimulus**: Processing of PlantUML component diagrams
- **Artifact**: Parser component
- **Environment**: Various PlantUML syntax conventions
- **Response**: All components and relationships are correctly
  identified
- **Response Measure**: 95%+ extraction accuracy across diverse
  diagram styles

### QAST302-1

Test: Process corpus of 10-15 PlantUML files with known component
counts and relationships.

Success: achieve at least 95% accuracy of components extracted for
each file.

## Maintainability

### QAS401

#### Code Quality and Testability

- **Source**: Development team maintaining system
- **Stimulus**: Need to modify existing functionality
- **Artifact**: Source code and test suite
- **Environment**: Maintenance phase
- **Response**: Changes can be made confidently with comprehensive test
  coverage
- **Response Measure**: 80%+ code coverage and all tests pass after
  modifications

### QAST401-1

Test: Measure test coverage after implementing new features.

Success: maintain 80%+ line coverage. All existing tests must pass
after changes.

## Compatibility

### QAS501

#### PlantUML Format Support

- **Source**: Users with diverse PlantUML files
- **Stimulus**: Upload of PlantUML files using different syntax styles
  and versions
- **Artifact**: Parser and compatibility layer
- **Environment**: Production environment
- **Response**: System successfully processes standard PlantUML component
  diagram conventions
- **Response Measure**: 90%+ success rate with sample diagram repository

### QAST501-1

Test: Process 20+ PlantUML files from open-source projects using
various syntax styles.

Success: Success rate must be 90% or higher for valid component
diagrams.
