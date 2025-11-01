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
TODO: Fill interview script development

## Customer Interview Findings
TODO: Fill customer interview findings

TODO: Fill new questions to clarify

## Next Steps and Focus

### Immediate Priorities
TODO: Fill immediate priorities

### Focus for Value Delivery
TODO: Fill focus for value delivery

## MVP Vision
TODO: Fill MVP vision

### Core Features
TODO: Fill core features

### Success Criteria
TODO: Fill success criteria


