# Architecture Evaluation Tool

## One-liner Description
A tool for architecture evaluation using evolution theory matrix to help software architects, students, and researchers follow structured design approaches like Attribute-Driven Design (ADD).

## Project Goal(s)
To create a tool that helps architects evaluate software architectures by:
- Representing architectures using an evolution theory matrix (non-functional requirements as rows, components as columns)
- Supporting component specifications in PlantUML format
- Enabling version comparison with PlantUML diff visualization
- Facilitating structured architecture evaluation following established methodologies

## Threshold of Success
The tool successfully enables users to:
1. Define and visualize architectures using the evolution theory matrix
2. Specify components in PlantUML format
3. Compare different architecture versions and see diffs in PlantUML
4. Evaluate architectures against non-functional requirements systematically

## Description
Architecture evaluation is a critical aspect of software design, with established methodologies like Attribute-Driven Design (ADD) providing structured approaches. However, practitioners lack tools to systematically apply these methods.

This tool addresses this gap by providing:
- A matrix-based visualization where rows represent non-functional requirements (NFRs) and columns represent architectural components
- Support for PlantUML component specifications
- Version comparison capabilities to track architecture evolution
- A local deployment solution for students, researchers, and software architects

## Architecture Documentation

- See `docs/architecture/architecture.md` for the context diagram, use cases, components, and sequences.
- See `docs/architecture/tech-stack.md` for the selected technologies and rationale for each component.

**Stakeholders:**
- **Students**: Learners taking architecture courses who need tools to practice structured design
- **Researchers**: Academics studying software architecture methodologies
- **Software Architects**: Practitioners who need systematic approaches to evaluate designs

**External Systems:**
- **PlantUML**: Standard format for component specifications
- **ADD Methodology**: Attribute-Driven Design framework (reference approach)

## Feature Roadmap

### Sprint 0 (Preparation)
- [x] Repository setup
- [x] Team formation
- [x] Research existing solutions (5 alternatives)
- [x] Prepare interview script
- [x] Conduct customer interview
- [x] Document findings and MVP vision

## Building and Running

### Prerequisites

- **Docker** and **Docker Compose** (recommended)
- OR **Python 3.11+** and **Flutter SDK** for local development

### Quick Start with Docker (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/architecture-tools/add-evaluation-tool.git
   cd add-evaluation-tool
   ```

2. Start the application:
   ```bash
   docker-compose up --build
   ```

3. Access the application:
   - Frontend: http://localhost
   - Backend API: http://localhost:8000
   - API Documentation: http://localhost:8000/docs

### Local Development

#### Backend (FastAPI)

1. Navigate to backend directory:
   ```bash
   cd backend
   ```

2. Create a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Run the development server:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

   The API will be available at http://localhost:8000

#### Frontend (Flutter Web)

1. Navigate to frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the development server:
   ```bash
   flutter run -d chrome --web-port=8080
   ```

   The frontend will be available at http://localhost:8080

### Project Structure

```
.
├── backend/              # FastAPI backend
│   ├── main.py          # Application entry point
│   ├── requirements.txt # Python dependencies
│   └── Dockerfile       # Backend container config
├── frontend/            # Flutter web frontend
│   ├── lib/             # Dart source code
│   ├── web/             # Web-specific files
│   ├── pubspec.yaml     # Flutter dependencies
│   └── Dockerfile       # Frontend container config
├── docker-compose.yml   # Multi-container orchestration
└── docs/                # Project documentation
```

## Documentation

### Sprint Documentation
- **[Sprint 0 Documentation](./docs/sprints/sprint-0/)**: Contains the initial research, interview script, meeting notes, report, and [deliverable PDF](./docs/sprints/sprint-0/deliverable.pdf) from the preparation phase.

### Strategic Plan
- **[Strategic Plan](./docs/plan.md)**: Goals, thresholds, roadmap, monitoring, and contingency strategies.

### AI Usage
- **[AI Usage Report](./docs/ai-usage.md)**: Documents how AI tools are being used throughout the project development. This file is updated each sprint to track AI assistance in the development process.


