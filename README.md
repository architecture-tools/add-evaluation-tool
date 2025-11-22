# Architecture Evaluation Tool

<!-- [![CI/CD](https://github.com/architecture-tools/add-evaluation-tool/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/architecture-tools/add-evaluation-tool/actions/workflows/ci-cd.yml)
[![Backend Coverage](https://codecov.io/gh/architecture-tools/add-evaluation-tool/branch/main/graph/badge.svg?flag=backend)](https://codecov.io/gh/architecture-tools/add-evaluation-tool)
[![Frontend Coverage](https://codecov.io/gh/architecture-tools/add-evaluation-tool/branch/main/graph/badge.svg?flag=frontend)]
(https://codecov.io/gh/architecture-tools/add-evaluation-tool) -->

## One-liner Description

A tool for architecture evaluation using evolution theory matrix to help
software architects, students, and researchers follow structured design
approaches like Attribute-Driven Design (ADD).

## Project Goal(s)

To create a tool that helps architects evaluate software architectures by:

- Representing architectures using an evolution theory matrix
  (non-functional requirements as rows, components as columns)
- Supporting component specifications in PlantUML format
- Enabling version comparison with PlantUML diff visualization
- Facilitating structured architecture evaluation following established
  methodologies

## Threshold of Success

The tool successfully enables users to:

1. Define and visualize architectures using the evolution theory matrix
2. Specify components in PlantUML format
3. Compare different architecture versions and see diffs in PlantUML
4. Evaluate architectures against non-functional requirements
  systematically

## Description

Architecture evaluation is a critical aspect of software design, with
established methodologies like Attribute-Driven Design (ADD) providing
structured approaches. However, practitioners lack tools to systematically
apply these methods.

This tool addresses this gap by providing:

- A matrix-based visualization where rows represent non-functional
  requirements (NFRs) and columns represent architectural components
- Support for PlantUML component specifications
- Version comparison capabilities to track architecture evolution
- A local deployment solution for students, researchers, and software
  architects
- Continuous integration via GitHub Actions so linting/tests run on every
  push

## Architecture Documentation

- See `docs/architecture/architecture.md` for the context diagram, use
  cases, components, and sequences.
- See `docs/architecture/tech-stack.md` for the selected technologies and
  rationale for each component.

**Stakeholders:**

- **Students**: Learners taking architecture courses who need tools to
  practice structured design
- **Researchers**: Academics studying software architecture methodologies
- **Software Architects**: Practitioners who need systematic approaches to
  evaluate designs

**External Systems:**

- **PlantUML**: Standard format for component specifications
- **ADD Methodology**: Attribute-Driven Design framework (reference
  approach)

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

   - Frontend: <http://localhost>
   - Backend API: <http://localhost:8000>
   - API Documentation: <http://localhost:8000/docs>

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

   The API will be available at <http://localhost:8000>

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

   The frontend will be available at <http://localhost:8080>

## Documentation

📚 **Full documentation is available on
[GitHub Pages](https://architecture-tools.github.io/add-evaluation-tool/)** - A
comprehensive documentation site with all project documentation, sprint
reports, architecture details, and requirements.

### Quick Links

- **[Sprints Documentation](./docs/sprints/)**: Contains the documentation of
  each sprint.
- **[Strategic Plan](./docs/plan.md)**: Goals, thresholds, roadmap, monitoring,
  and contingency strategies.
- **[AI Usage Report](./docs/ai-usage.md)**: Documents how AI tools are being
  used throughout the project development.
