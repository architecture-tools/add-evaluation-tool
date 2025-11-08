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
Cell annotation (business importance, Technical Risk)

**Critical**
1. (H, H): [QAS101](#qas101) - Intuitive web interface (high business value, technically challenging UX design for architects)

**High Priority**

2. (H, M): [QAS301](#qas301) - Scoring calculation precision (high business value, medium technical risk - depending on the calculation and algorithm)
3. (H, M): [QAS501](#qas501) - PlantUML format support (high business value, medium technical risk)
4. (M, H): [QAS302](#qas302) - Component extraction accuracy (medium business value, high technical risk - PlantUML parsing complexity)

**Medium Priority**

5. (M, M): [QAS201](#qas201), [QAS202](#qas202) - Performance requirements (medium business value, medium technical risk)
6. (H, L): [QAS102](#qas102) - Clear visualization (high business value, low technical risk)

**Low Priority**

7. (L, M): [QAS401](#qas401) - Code quality and testability (low business value, Medium technical risk)

## Usability

### QAS101
#### Intuitive Web Interface
- **Source**: End users (software architects)
- **Stimulus**: Architect opens the application for the first time
- **Artifact**: Web application interface
- **Environment**: Normal operation, first-time use
- **Response**: User can understand how to upload PlantUML files and begin evaluation within 5 minutes without external documentation
- **Response Measure**: 90% of test users successfully complete initial evaluation workflow without assistance

### QAST101-1
Test: Test 10 software architects with varying technical backgrounds. Provide them with the application URL and a sample PlantUML file. Measure time to successful completion of first architecture evaluation. 

Success: 9 out of 10 users complete evaluation within 10 minutes without requesting help.

### QAST101-2
Test: Have a survey to collect feedback from architects about the time it took them to understand the interface and if they needed help or not.

Success: 90% of responses should have time <= 5 minutes and with no help.


### QAS102
#### Clear Visualization of Architectural Changes
- **Source**: End users evaluating architecture evolution
- **Stimulus**: User compares two versions of architecture
- **Artifact**: Visualization components and diff interface
- **Environment**: During architecture review sessions
- **Response**: System clearly displays what components changed, how quality attributes were affected, and overall architecture score impact
- **Response Measure**: Users can identify key changes and their quality impacts within 30 seconds of viewing comparison

### QAST102-1
Test: Provide users with two versions of architecturecontaining at least 10 components and 8 quality attributes. Measure time to correctly identify: (a) which components were added/removed, (b) which quality attributes improved/degraded, (c) overall score change. 

Success: 90% of users were done within 30 seconds.

## Performance

### QAS201
#### Responsive Matrix Interaction
- **Source**: User interacting with evaluation matrix
- **Stimulus**: User inputs or modifies scores in a large matrix (components x quality attributes)
- **Artifact**: Evaluation matrix interface
- **Environment**: Normal editing session
- **Response**: Matrix updates and recalculations occur with imperceptible delay
- **Response Measure**: Input-to-visual-update latency under 100ms for all matrix operations

### QAST201-1
Test: Load matrix with 30 components and 20 quality attributes. Using automated testing, measure time from score input to visual update across 1000 random cell modifications.

Success: measured response time for 95% of modifications must be under 100ms.

### QAS202
#### PlantUML Processing Performance
- **Source**: User uploading architecture diagrams
- **Stimulus**: Upload of complex PlantUML file (50KB+, 25+ components)
- **Artifact**: File processing system
- **Environment**: Standard web environment
- **Response**: File is parsed, components extracted, and matrix initialized quickly
- **Response Measure**: Processing completes within 3 seconds for 95% of files

### QAST202-1
Test: Process 100 sample PlantUML files of varying complexity (10KB-100KB, 5-50 components).

Success: 95% of files must complete processing within 3 seconds on standard hardware.

## Accuracy

### QAS301
#### Scoring Calculation Precision
- **Source**: System calculating architecture scores
- **Stimulus**: User inputs scores with custom weights
- **Artifact**: Scoring calculation engine
- **Environment**: Evaluation session
- **Response**: All calculations are mathematically precise according to defined algorithms
- **Response Measure**: 100% accuracy verified against manual calculations for 10 test cases

### QAST301-1
Test: Generate 10 random test matrices with varying weights and scoring patterns. Compare system calculations against verified manual calculations. 

Success: achieve 100% accuracy.

### QAS302
#### Component Extraction Accuracy
- **Source**: PlantUML parsing system
- **Stimulus**: Processing of PlantUML component diagrams
- **Artifact**: Parser component
- **Environment**: Various PlantUML syntax conventions
- **Response**: All components and relationships are correctly identified
- **Response Measure**: 95%+ extraction accuracy across diverse diagram styles

### QAST302-1
Test: Process corpus of 10-15 PlantUML files with known component counts and relationships.

Success: achieve at least 95% accuracy of components extracted for each file.

## Maintainability

### QAS401
#### Code Quality and Testability
- **Source**: Development team maintaining system
- **Stimulus**: Need to modify existing functionality
- **Artifact**: Source code and test suite
- **Environment**: Maintenance phase
- **Response**: Changes can be made confidently with comprehensive test coverage
- **Response Measure**: 80%+ code coverage and all tests pass after modifications

### QAST401-1
Test: Measure test coverage after implementing new features. 
Success: maintain 80%+ line coverage. All existing tests must pass after changes.

## Compatibility

### QAS501
#### PlantUML Format Support
- **Source**: Users with diverse PlantUML files
- **Stimulus**: Upload of PlantUML files using different syntax styles and versions
- **Artifact**: Parser and compatibility layer
- **Environment**: Production environment
- **Response**: System successfully processes standard PlantUML component diagram conventions
- **Response Measure**: 90%+ success rate with sample diagram repository

### QAST501-1
Test: Process 20+ PlantUML files from open-source projects using various syntax styles. 

Success: Success rate must be 90% or higher for valid component diagrams.