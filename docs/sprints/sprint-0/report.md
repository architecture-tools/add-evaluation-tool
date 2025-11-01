# Sprint 0 Report - What We've Learned

## Team Formation
Introducing our team - Crackers! 

- Roukaya Mabrouk
- Timur Kharin
- Pechersky Ilya

During the team formation phase, we determined that Ilya was interested in writing the core logic, Timur had extensive experience in front-end development, and Roukaya wanted to work on documentation and act as a delivery manager.

## Research on Existing Solutions
There are mature methodologies for architecture design (notably SEI’s Attribute‑Driven Design, ADD) and popular modeling tools (PlantUML, ArchiMate, Structurizr DSL/CLI). However, there is little end‑to‑end tooling that combines: (1) guided ADD workflows, (2) matrix‑based evaluation (e.g., NFR × components), and (3) visual diffs between architecture versions. In practice, teams mix ADD with text‑based models stored in Git and rely on code‑diff tooling for change review.
### Products Explored
- **SEI ADD Method** — systematic, scenario‑driven design approach based on quality attributes; partial automation historically via the ArchE assistant. See [SEI ADD collection](https://www.sei.cmu.edu/library/attribute-driven-design-method-collection/) and [Wikipedia](https://en.wikipedia.org/wiki/Attribute-driven_design). Background and examples in research texts (e.g., [CMU ISR report](http://acme.able.cs.cmu.edu/pubs/uploads/pdf/CMU-ISR-13-118.pdf)).
- **PlantUML** — text DSL for UML; models are versionable and diff‑friendly in Git. See [PlantUML](https://plantuml.com) and the [Language Guide (RU)](https://pdf.plantuml.net/PlantUML_Language_Reference_Guide_ru.pdf). ArchiMate support via macros: [Archimate‑PlantUML](https://github.com/plantuml-stdlib/Archimate-PlantUML) and docs on [ArchiMate diagrams](https://plantuml.com/archimate-diagram).
- **Structurizr DSL/CLI** — generates .puml/diagrams from a single DSL source; improves repeatability and validation of changes. See [example article](https://dev.to/simonbrown/modelling-software-architecture-with-plantuml-56fc).
- **Matrix/DSM approaches** — design structure matrices and design rule theory for modularity and evolution analysis; strong academic grounding but limited integration in mainstream tooling. See HBS working paper: [DSM/DRT](https://www.hbs.edu/ris/download.aspx?name=07-081.pdf) and surveys (e.g., [ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0010448509001109)).
- **Market overviews and tools** — curated lists of architecture tools ([IcePanel overview](https://icepanel.io/blog/2025-08-26-top-9-software-architecture-tools)) and commercial analysis products like [vFunction](https://vfunction.com/blog/software-architecture-tools/).

### Qualitative Analysis
- **ADD workflow coverage**: Well documented and teachable; automation is partial. ArchE showed feasibility of guided decisions, but modern open‑source tools focus more on documentation than decision guidance (see [SEI ADD](https://www.sei.cmu.edu/library/attribute-driven-design-method-collection/), [CMU ISR](http://acme.able.cs.cmu.edu/pubs/uploads/pdf/CMU-ISR-13-118.pdf)).
- **Matrices/DSM**: Valuable for modularity and evolution analysis, yet rarely embedded into day‑to‑day modeling tools; typically appear as academic tooling or bespoke scripts ([DSM/DRT](https://www.hbs.edu/ris/download.aspx?name=07-081.pdf), [ScienceDirect](https://www.sciencedirect.com/science/article/abs/pii/S0010448509001109)).
- **Architecture diff**: No native structural diff in PlantUML; teams rely on Git/IDE text diff. Generating diagrams from a single DSL source (Structurizr) improves reproducibility and change validation ([PlantUML](https://plantuml.com), [Structurizr example](https://dev.to/simonbrown/modelling-software-architecture-with-plantuml-56fc)).
- **Modeling & extensibility**: PlantUML + ArchiMate macros offer expressive, extensible text models aligned with enterprise architecture concepts ([Archimate‑PlantUML](https://github.com/plantuml-stdlib/Archimate-PlantUML), [ArchiMate diagrams](https://plantuml.com/archimate-diagram)).
- **Cost & accessibility**: PlantUML/DSLs are open and easy to integrate; commercial tools add analytics but seldom focus on ADD + matrices as a unified flow ([vFunction](https://vfunction.com/blog/software-architecture-tools/)).
- **DevOps fit**: Text models integrate well with GitOps/CI, enabling reviews, traceability, and incremental evolution.

### Key Insights
- There is a gap for an end‑to‑end product unifying ADD guidance, matrix‑based evaluation, and structural diff visualization.
- Most pragmatic foundation: text models (PlantUML + ArchiMate) or a single‑source DSL (Structurizr) stored in Git for versioning and review.
- The evaluation matrix (rows = NFR, columns = components) will likely require a bespoke scoring/visualization module; mainstream tools do not provide this out of the box ([DSM/DRT](https://www.hbs.edu/ris/download.aspx?name=07-081.pdf)).
- A useful diff experience should parse .puml/DSL and compute structural deltas, then highlight them on diagrams; plain text diff is baseline but insufficient for architects.
- Encoding ADD quality scenarios into structured inputs and checks for tactics/patterns can make the process repeatable and auditable ([SEI ADD](https://www.sei.cmu.edu/library/attribute-driven-design-method-collection/)).
- Risks to manage: semantic alignment with ArchiMate and ADD, consistent abstraction levels, and model evolution in large repositories.

## Interview Script Development
While developing the script for interview we followed this strategy:
- Start with pleasantries and ask for permission for meeting recording.
- First question has to be about client experience and for them to describe their vision to get a closer look on the project.
- Following questions would be clarifying questions on that vision
- Move on to technical questions regarding development of the tool

We started with more open-ended questions for the vision and then moved on to close-ended questions to capture the specific details about the project while trying to apply the 3 mum's rules to be able to get reliable answers and feedback. 


## Customer Interview Findings
The first customer interview provided a clear understanding of the main project objectives, [meeting summary](./meeting-1.md#summary).

### Project Requirements

#### Functional Requirements

##### Core Analysis & Evaluation
- **FR1**: Parse PlantUML diagrams to extract architectural components and relationships
- **FR2**: Maintain a predefined set of non-functional requirements (NFRs) for evaluation
- **FR3**: Generate evaluation matrices linking architectural components to NFRs
- **FR4**: Provide interface for architects to input component-NFR relationship scores
- **FR5**: Calculate overall architecture quality scores

##### Version Management & Comparison
- **FR6**: Store and manage historical versions of architectural models
- **FR7**: Perform diff analysis between architectural diagram versions
- **FR8**: Compare quality attribute scores across different model versions
- **FR9**: Track improvements and regressions in architectural quality over time

##### User Interface & Reporting
- **FR10**: Web-based application accessible through standard browsers
- **FR11**: Display visual diffs highlighting changes between architectural versions
- **FR12**: Generate evaluation reports

#### Non-Functional Requirements

##### Usability
- **NFR1**: Intuitive web interface requiring minimal training for architects
- **NFR2**: Clear visualization of architectural changes and quality impacts

### Questions to clarify

- Agree on NFRs for the MVP
- Get formula for scoring

## Next Steps and Focus

### Immediate Priorities

1. **Clarify open questions with customer**
   - Finalize the set of NFRs (non-functional requirements) to include in the MVP evaluation matrix
   - Obtain or agree upon the scoring formula for calculating component-NFR relationship scores and overall architecture quality score
   - Confirm the expected format/structure of evaluation reports

2. **Technical architecture design**
   - Design the system architecture for the web application
   - Define data models for PlantUML parsing, components, NFRs, evaluation matrices, and version history
   - Plan the integration approach for PlantUML parsing (library selection, parsing strategy)
   - Design the version storage and comparison mechanism

3. **Development environment setup**
   - Set up project structure and development tooling
   - Choose technology stack (frontend framework, backend language/framework, database if needed)
   - Establish coding standards and repository workflows

4. **Proof of concept (POC)**
   - Implement basic PlantUML parser to extract components and relationships
   - Create a minimal matrix visualization (NFRs × Components)
   - Validate the core concept with a simple example

### Focus for Value Delivery

To deliver the most value for the customer and end-users, we should focus on:

1. **Core evaluation matrix functionality** - This is the unique differentiator that addresses the identified gap in existing tools. The ability to create, visualize, and interact with an NFR × Components matrix is the primary value proposition.

2. **PlantUML parsing and component extraction** - This is the foundation that enables the rest of the tool. Without reliable parsing, the matrix cannot be populated automatically, which would significantly reduce usability.

3. **Intuitive web-based interface** - Given that the primary users are students, researchers, and architects, an accessible web interface removes deployment barriers and enables immediate use without installation complexity.

4. **Version comparison with visual diff** - This addresses the pain point of tracking architecture evolution and understanding how changes impact quality attributes. Even a basic visual diff provides more value than plain text diffs for architectural diagrams.

5. **Scoring calculation and quality tracking** - The ability to calculate overall architecture scores and compare them across versions provides concrete feedback on architecture improvements and regressions, which is essential for iterative design processes.

## MVP Vision

The MVP will be a web-based application that enables software architects to evaluate architectures using an evolution theory matrix. Users will be able to upload PlantUML diagrams, which the tool will automatically parse to extract architectural components. The tool will generate an evaluation matrix where rows represent predefined non-functional requirements and columns represent the extracted components. Architects can input scores for each cell in the matrix, reflecting how well each component addresses each NFR. The tool will calculate an overall architecture quality score from these inputs.

The MVP will support storing multiple versions of architectures, allowing users to compare versions side-by-side with visual diffs that highlight changes in both the diagrams and the evaluation scores. This enables architects to track how architectural changes affect quality attributes over time.

The tool will be accessible through a standard web browser, require minimal setup, and provide clear visualizations that help architects understand the relationship between architectural components and quality attributes, as well as the impact of changes on architecture quality.

### Core Features

For the MVP, we will focus on delivering these core features:

1. **PlantUML Parser & Component Extractor**
   - Parse PlantUML diagram files (.puml)
   - Extract architectural components (services, modules, classes - based on abstraction level agreed with customer)
   - Extract relationships between components

2. **Evaluation Matrix Generation**
   - Create evaluation matrix with predefined NFRs as rows and extracted components as columns
   - Matrix interface for user input of component-NFR relationship scores

3. **Scoring System**
   - Accept user inputs for matrix cells (score format to be agreed with customer)
   - Calculate overall architecture quality score using agreed formula
   - Display score with visual indicators

4. **Version Management**
   - Store multiple versions of the same architecture model
   - Allow users to upload/create new versions
   - Maintain version history with metadata (timestamps, labels)

5. **Version Comparison**
   - Side-by-side comparison of two architecture versions
   - Visual diff highlighting changes in PlantUML diagrams
   - Comparison of quality attribute scores between versions
   - Highlight improvements and regressions in scores

6. **Web Interface**
   - Responsive web application accessible via browser
   - Upload/import PlantUML files
   - Matrix editing interface
   - Version selection and comparison views
   - Basic evaluation report display

### Success Criteria

The MVP will be considered successful if:

1. **Functionality**
   - Successfully parses PlantUML diagrams and extracts at least 80% of components correctly for standard PlantUML component diagrams
   - Generates evaluation matrices with correct NFRs and components
   - Calculates architecture scores using the agreed formula
   - Stores and retrieves at least 5 versions of the same architecture without data loss
   - Performs meaningful visual diffs that highlight structural changes between versions

2. **Usability**
   - A new user can upload a PlantUML file, create an evaluation matrix, and get an architecture score within 10 minutes without training
   - The interface clearly displays the relationship between components and NFRs
   - Version comparison view enables users to identify what changed and how it affects quality scores

3. **Technical**
   - Application runs locally or in a simple deployment (e.g., Docker container)
   - Application is accessible via standard web browsers (Chrome, Firefox, Safari)
   - No critical bugs that prevent core workflow completion
   - Response time for matrix generation and score calculation is under 2 seconds for diagrams with up to 20 components

4. **Value Delivery**
   - The tool provides unique value that existing solutions do not offer (combined ADD workflow + matrix evaluation + visual diff)
   - Users can meaningfully evaluate an architecture and see how changes affect quality
   - The tool demonstrates the feasibility of the approach for future enhancements


