# Contributing and Tactical Plan

## 1. Task tracking (GitHub Projects)

- System: GitHub Issues + Projects (`Tasks` board).
- Issue classification: labels `epic`, `feature`, `task`, `bug`, `spike`.
- Board workflow: Backlog → Selected for Sprint → In Progress → In Review → Verify → Done.
- Each issue includes: concise title, short description, acceptance criteria, estimate, assignee, and labels.
- Every pull request links the issue using closing keywords (e.g., `Fixes #123`).

Recommended issue template (paste into Description):

```markdown
Context
- What problem are we solving and why now?

Expected outcome
- One or two sentences describing the result

Acceptance criteria
- [ ] Checkable criterion 1
- [ ] Checkable criterion 2

Notes / links
- Diagrams, references, risks
```

## 2. Verifying that a task is done

A task is considered Done when all of the following are true:
- All acceptance criteria in the GitHub issue are satisfied.
- Code is merged to `main` via a reviewed pull request (no direct pushes).
- CI is green (build/lint/tests as applicable).
- Documentation and/or diagrams are updated when behavior or architecture changes.
- For UI/report changes, a short screenshot or demo is attached to the issue.
- The issue links to the PR/commits and the card is moved to Done on `Tasks`.

Pull request checklist:
- [ ] Linked to GitHub issue (e.g., `Fixes #123`).
- [ ] Card is on Projects `Tasks` board in the correct column.
- [ ] Meets acceptance criteria.
- [ ] CI green; no linter/type errors.
- [ ] Tests or manual verification steps included.
- [ ] Docs/diagrams updated if relevant.

## 3. Tasks not completed in one iteration

- During the sprint review, unfinished work is either split into smaller follow‑up items or moved to the next sprint with an updated estimate.
- If the scope changed, close the current issue and create a new, well‑scoped one; otherwise keep the same issue.
- Add the label `carryover` and briefly document the reason.

## 4. Task assignment

- Default mode is self‑assignment during planning within reasonable WIP limits per person.
- The lead (or on‑call) resolves conflicts, prioritizes urgent items, and reassigns when needed.
- Pairing is recommended for complex items (both may watch the issue; one assignee).
- Exactly one assignee is set at any time.

## 5. Quality expectations

- Branching: `feature/<slug>`, `fix/<slug>`, `docs/<slug>`; `main` is protected.
- Commit messages follow Conventional Commits (`feature:`, `fix:`, `docs:` …).
- Review: at least one approval; target response time is within one business day.
- CI before merge: lint/format and build/tests (when present).
- Architecture decisions: record impactful choices as ADRs in `docs/`.
- Diagrams: keep PlantUML/DSL models in version control; attach exports or diffs when it helps reviewers.
- Security and hygiene: no secrets in the repository; verify licenses for new dependencies.

---

## Workflow summary
1. Create or pick a GitHub issue with acceptance criteria and an estimate, and add it to Projects `Tasks`.
2. Assign the issue to yourself, move the card to In Progress, and create a feature branch.
3. Implement the change and keep the issue updated with relevant notes or screenshots.
4. Open a PR referencing the issue, request review, and ensure CI is green.
5. Merge, update documentation if needed, and move the card to Done.

---

## 6. Development Environment Setup

### Prerequisites
- **Docker & Docker Compose** (recommended for full stack)
- **Python 3.11+** with Poetry (for backend development)
- **Flutter SDK** (for frontend development)
- **openapi-generator** (for API client generation)

### Quick Start with Docker
```bash
docker-compose up --build
```
- Frontend: http://localhost
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

### Local Development Setup
See `README.md` for detailed setup instructions for both frontend and backend.

---

## 7. Frontend Development (Flutter)

### Code Organization
- **`lib/network/src/`**: Auto-generated API client (do not edit manually)
- **`lib/services/`**: Service layer wrapping generated API clients
- **`lib/models/`**: Additional data models and mock data
- **`lib/widgets/`**: Reusable UI components
- **`lib/screens/`**: Full-page screen widgets
- **`lib/theme/`**: App-wide styling and themes

### Development Commands
```bash
cd frontend
make install      # Install dependencies
make format       # Format code (flutter format)
make lint         # Run linter (flutter analyze)
make test         # Run tests (flutter test)
make generate-api # Regenerate API client from OpenAPI spec
```

### Code Style
- Follow Flutter/Dart style guide: https://dart.dev/guides/language/effective-dart/style
- Run `make format` before committing
- Fix all linter warnings (`make lint`)
- Use meaningful widget and variable names
- Keep widgets focused and reusable

### API Client Generation
**When to regenerate:**
- After backend API changes (new endpoints, modified schemas)
- When OpenAPI schema (`backend/openapi/openapi.json`) is updated

**How to regenerate:**
1. Ensure backend is running and OpenAPI schema is up to date
2. Run `make generate-api` in `frontend/` directory
3. Review generated code for any issues (check `scripts/fix_generated_code.py` handles edge cases)
4. Update service layer (`lib/services/`) if API signatures changed
5. Test integration with backend

**Important:** Never manually edit files in `lib/network/src/` - they are auto-generated. If fixes are needed, update `scripts/fix_generated_code.py` instead.

### Testing
- Write unit tests for services and business logic
- Test widget rendering with mock data
- Verify API integration with real backend (manual testing or integration tests)
- Test file upload/parsing flows end-to-end

---

## 8. Backend Development (FastAPI)

### Code Organization
- **`app/domain/`**: Domain entities and business logic
- **`app/application/`**: Application services and use cases
- **`app/infrastructure/`**: External integrations (parsing, storage, persistence)
- **`app/presentation/api/`**: API routes and schemas
- **`app/core/`**: Configuration and shared utilities

### Development Commands
```bash
cd backend
make install      # Install dependencies (poetry install)
make format       # Format code (ruff format)
make lint         # Run linter (ruff check + mypy)
make test         # Run tests (pytest)
make export-openapi # Export OpenAPI schema (requires running server)
```

### Code Style
- Follow PEP 8 and use `ruff` for formatting
- Type hints are required (enforced by `mypy`)
- Use async/await for I/O operations
- Follow DDD-inspired layered architecture

### OpenAPI Schema Management
**When to export:**
- After adding/modifying API endpoints
- After changing request/response schemas
- Before frontend API client regeneration

**How to export:**
1. Start the backend server: `poetry run uvicorn main:app --reload`
2. Run `make export-openapi` in `backend/` directory
3. Commit the updated `openapi/openapi.json` to version control
4. Notify frontend team to regenerate API client

**Schema Location:**
- `backend/openapi/openapi.json` - Auto-generated from FastAPI
- This file should be committed to track API changes over time

### Testing
- Write unit tests for domain logic and services
- Write integration tests for API endpoints
- Test PlantUML parsing with various diagram formats
- Verify error handling and validation

---

## 9. API Client Generation Workflow

This project uses OpenAPI code generation to keep frontend and backend in sync.

### Complete Workflow

1. **Backend Developer** makes API changes:
   ```bash
   cd backend
   # Make changes to routes/schemas
   poetry run uvicorn main:app --reload  # Test locally
   make export-openapi                   # Export updated schema
   git add openapi/openapi.json
   git commit -m "feat: add new endpoint X"
   ```

2. **Frontend Developer** regenerates client:
   ```bash
   cd frontend
   git pull                              # Get latest openapi.json
   make generate-api                     # Regenerate client
   # Update services/widgets as needed
   git add lib/network/src/
   git commit -m "chore: regenerate API client for endpoint X"
   ```

### Best Practices
- Always commit `openapi/openapi.json` when API changes
- Regenerate frontend client in the same PR or immediately after API changes
- Test the integration after regeneration
- If generation produces errors, check `scripts/fix_generated_code.py` and update it if needed

---

## 10. Docker Development Workflow

### Using Docker Compose
- **Full stack**: `docker-compose up --build` (includes postgres, backend, frontend)
- **Backend only**: `docker-compose up backend postgres`
- **View logs**: `docker-compose logs -f [service]`

### Development with Hot Reload
- Backend: Volume mount enables hot reload (`./backend:/app`)
- Frontend: For hot reload, run locally with `flutter run -d chrome --web-port=8080`
- Database: Persisted in Docker volume `postgres_data`

### Environment Variables
- Backend: Set via `docker-compose.yml` or `.env` file
- Frontend: API base URL can be overridden via `--dart-define` flag

---

## 11. Extended PR Checklist

In addition to the standard checklist in section 2, verify:

### Frontend PRs
- [ ] API client regenerated if backend API changed
- [ ] `flutter analyze` passes with no warnings
- [ ] Code formatted with `flutter format`
- [ ] UI changes tested in browser (Chrome recommended)
- [ ] File upload/parse flow tested end-to-end
- [ ] No manual edits to `lib/network/src/` (generated code)

### Backend PRs
- [ ] OpenAPI schema exported and committed (`make export-openapi`)
- [ ] `ruff check` and `mypy` pass
- [ ] Code formatted with `ruff format`
- [ ] API endpoints tested (manually or via tests)
- [ ] PlantUML parsing tested with sample diagrams
- [ ] Database migrations (if any) are included

### Full-Stack PRs
- [ ] Backend API changes include OpenAPI schema update
- [ ] Frontend API client regenerated
- [ ] Integration tested (frontend → backend → database)
- [ ] Docker Compose still works (`docker-compose up --build`)

### Documentation PRs
- [ ] Markdown files render correctly on GitHub Pages
- [ ] Links are valid and relative paths work
- [ ] Architecture diagrams (PlantUML) are included if changed
- [ ] README updated if setup/usage changed

---

## 12. Testing Requirements

### Unit Tests
- **Frontend**: Test services, utilities, and business logic
- **Backend**: Test domain logic, services, and parsers

### Integration Tests
- **API Endpoints**: Test full request/response cycle
- **File Upload/Parse**: Test PlantUML upload and parsing flow
- **Database**: Test persistence layer (use test database)

### Manual Testing Checklist
Before marking a task as Done:
- [ ] Feature works in local development environment
- [ ] Works with Docker Compose setup
- [ ] No console errors in browser (frontend)
- [ ] API responses match expected schemas
- [ ] Error cases handled gracefully
- [ ] UI is responsive and accessible

---

## 13. Code Review Guidelines

### What to Review
- **Functionality**: Does it meet acceptance criteria?
- **Code Quality**: Is it maintainable, readable, and follows project conventions?
- **Testing**: Are there adequate tests or manual verification steps?
- **Documentation**: Are changes documented appropriately?
- **API Changes**: Is OpenAPI schema updated? Is frontend client regenerated?

### Review Response Time
- Target: Within one business day
- Urgent: Tag with `priority:high` label
- Blocking: Comment with specific concerns or request changes

### Approval Criteria
- At least one approval required
- All CI checks must pass
- All PR checklist items verified
- No unresolved discussions

---

## 14. Common Workflows

### Adding a New API Endpoint
1. Add route in `backend/app/presentation/api/v1/endpoints/`
2. Define schemas in `backend/app/presentation/api/v1/schemas/`
3. Implement service logic in `backend/app/application/`
4. Export OpenAPI schema: `cd backend && make export-openapi`
5. Regenerate frontend client: `cd frontend && make generate-api`
6. Create service wrapper in `frontend/lib/services/`
7. Update UI to use new endpoint
8. Test end-to-end
9. Commit both backend and frontend changes

### Adding a New UI Widget
1. Create widget in `frontend/lib/widgets/`
2. Follow existing widget patterns (see `kpi_card.dart`, `sidebar.dart`)
3. Use theme from `lib/theme/app_theme.dart`
4. Add to appropriate screen
5. Test in browser
6. Ensure responsive design

### Updating PlantUML Parser
1. Modify parser in `backend/app/infrastructure/parsing/plantuml_parser.py`
2. Add test cases for new diagram formats
3. Test with various PlantUML syntax variations
4. Update documentation if parser behavior changes
5. Verify parsed components appear correctly in frontend

---

## 15. Troubleshooting

### API Client Generation Fails
- Check `openapi-generator` is installed: `which openapi-generator`
- Verify `backend/openapi/openapi.json` is valid JSON
- Check `scripts/fix_generated_code.py` for errors
- Review generated code in `lib/network/temp/` before it's moved

### Backend Won't Start
- Check database is running: `docker-compose ps postgres`
- Verify environment variables in `docker-compose.yml`
- Check logs: `docker-compose logs backend`
- Try local run: `cd backend && poetry run uvicorn main:app --reload`

### Frontend Build Errors
- Run `flutter pub get` to update dependencies
- Clear build cache: `flutter clean && flutter pub get`
- Check for API client issues: `make generate-api`
- Verify API base URL in `lib/services/api_config.dart`

### Docker Compose Issues
- Rebuild containers: `docker-compose up --build --force-recreate`
- Remove volumes if database issues: `docker-compose down -v`
- Check port conflicts (8000, 80, 5432)
