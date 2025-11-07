# Architecture Document

## Table of Contents
1. [Interactive prototype](#interactive-prototype)
2. [Context diagram (example)](#context-diagram-example)
   - [External actors](#external-actors)
3. [Use case diagram (example)](#use-case-diagram-example)
   - [Actors](#actors)
4. [Component diagram (example, code)](#component-diagram-example-code)
   - [Component responsibilities](#component-responsibilities)
5. [Sequence diagrams](#sequence-diagrams)
   - [User story: Upload PlantUML and evaluate](#user-story-upload-plantuml-and-evaluate)
   - [Quality requirement: Responsive Matrix Interaction (QAS201)](#quality-requirement-responsive-matrix-interaction-qas201)

## Interactive prototype

Link to the interactive prototype in Figma: [TBD – Figma link]

## Context diagram (example)

Source: `docs/architecture/assets/context.mmd`

```mermaid
graph TD
    subgraph "Architecture Evaluation Tool"
        AET["Architecture Evaluation Tool"]
    end

    subgraph "External Actors"
        Student["Student"]
        Researcher["Researcher"]
        Architect["Software Architect"]
    end

    subgraph "External Systems"
        PlantUML[("PlantUML Renderer")]
        Storage[("Local Storage / Database")]
    end

    %% Interactions
    Student <-->|"Use web UI"| AET
    Researcher <-->|"Use web UI"| AET
    Architect <-->|"Use web UI"| AET

    AET -->|"Render component diagrams"| PlantUML
    AET -->|"Store diagrams, matrices, diffs"| Storage
```

### External actors

- **Student**: practices structured architecture evaluation workflows.
- **Researcher**: studies and compares designs and their evolution.
- **Software Architect**: evaluates architectures against quality attributes, prepares reports.

## Use case diagram (example)

Source: `docs/architecture/assets/use-cases.mmd`

```mermaid
flowchart TD
    subgraph Actors
        Student["Student"]
        Researcher["Researcher"]
        Architect["Software Architect"]
    end

    subgraph UseCases
        UC1(["Upload PlantUML Diagram"]):::uc
        UC2(["Evaluate Architecture Matrix"]):::uc
        UC3(["Compare Versions (Diff)"]):::uc
        UC4(["Export Report"]):::uc
    end

    classDef uc fill:#eef,stroke:#336,stroke-width:1px

    Student --> UC1
    Student --> UC2
    Student --> UC3
    Student --> UC4

    Researcher --> UC1
    Researcher --> UC2
    Researcher --> UC3
    Researcher --> UC4

    Architect --> UC1
    Architect --> UC2
    Architect --> UC3
    Architect --> UC4
```

### Actors

- **Student**: uploads diagrams, evaluates, and learns.
- **Researcher**: runs evaluations and compares versions.
- **Software Architect**: prepares evaluation reports.

## Component diagram (example, code)

Source: `docs/architecture/assets/components.puml`

```plantuml
@startuml
skinparam componentStyle rectangle
skinparam wrapWidth 200
skinparam maxMessageSize 200

package "Architecture Evaluation Tool" {
  [Web UI] as WebUI
  [Upload Controller] as UploadController
  [PlantUML Parser] as Parser
  [Matrix Engine] as MatrixEngine
  [Diff Engine] as DiffEngine
  [Renderer Adapter] as RendererAdapter
  [Storage] as Storage
}

WebUI --> UploadController : upload .puml
UploadController --> Parser : parse components
Parser --> MatrixEngine : build matrix model
WebUI --> MatrixEngine : edit scores / weights
WebUI --> DiffEngine : compare versions
MatrixEngine --> Storage : persist evaluations
DiffEngine --> Storage : read prior versions
WebUI --> RendererAdapter : preview diagram
RendererAdapter --> Parser : leverage PlantUML libs

note right of MatrixEngine
  Calculates derived metrics and
  quality attribute scores
end note

note right of DiffEngine
  Computes structural/metric diffs
  between two architecture versions
end note

@enduml
```

### Component responsibilities

- **Web UI**: matrix visualization, editing scores/weights, diff view.
- **Upload Controller**: intake diagrams, validation, metadata extraction.
- **PlantUML Parser**: parse components/relations from PlantUML.
- **Matrix Engine**: build and compute matrix metrics and quality attribute scores.
- **Diff Engine**: compare two versions to produce structural and metric diffs.
- **Renderer Adapter**: integrate PlantUML rendering for previews.
- **Storage**: persist diagrams, matrices, and evaluation results.

## Sequence diagrams

### User story: Upload PlantUML and evaluate

Source: `docs/architecture/assets/seq-user-story.mmd`

```mermaid
sequenceDiagram
    participant User as User
    participant UI as Browser UI
    participant API as Backend API
    participant Parser as PlantUML Parser
    participant Matrix as Matrix Engine
    participant Store as Storage

    User->>UI: Select .puml and start evaluation
    UI->>API: POST /diagrams (file)
    API->>Parser: Parse components/relations
    Parser-->>API: Parsed model
    API->>Matrix: Initialize evaluation matrix
    Matrix-->>API: Matrix model
    API->>Store: Persist diagram + matrix
    Store-->>API: Saved
    API-->>UI: 201 Created + matrix data
    UI->>UI: Render matrix and metrics
```

### Quality requirement: Responsive Matrix Interaction (QAS201)

Derived from `docs/requirements/quality-requirements.md#performance` (QAS201: input-to-visual-update under 100ms).

Source: `docs/architecture/assets/seq-qas.mmd`

```mermaid
sequenceDiagram
    %% QAS201: Responsive Matrix Interaction (<100ms)
    participant User as User
    participant UI as Browser UI
    participant Calc as Client-side Matrix Engine
    participant API as Backend API

    User->>UI: Edit cell (score/weight)
    UI->>Calc: Recompute derived metrics (debounced)
    Calc-->>UI: Updated totals/visuals
    UI->>UI: Update DOM (under 100ms)
    Note over UI: Optimistic UI, Web Worker if needed

    alt Background sync (throttled)
        UI->>API: PATCH /matrix (delta)
        API-->>UI: 200 OK
    end
```

---

Notes:
- Diagram source code is stored under `docs/architecture/assets/`. Generate images into the same folder or subfolders as needed.
- Update the Figma link when the interactive prototype is available.

