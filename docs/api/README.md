# API Documentation

This directory contains the OpenAPI specification and interactive API documentation for the Architecture Evaluation Tool backend.

## Files

- `openapi.json` - OpenAPI 3.1 specification in JSON format
- `index.html` - Interactive API documentation page using Redoc

## Viewing the API Documentation

### On GitHub Pages

After the documentation is published, you can view it at:

**https://architecture-tools.github.io/add-evaluation-tool/api/**

The page includes:
- Interactive API explorer with all endpoints
- Request/response schemas
- Download link for the OpenAPI specification

### Locally

1. Start a local server in the `docs` directory:
   ```bash
   cd docs
   python3 -m http.server 4000
   ```

2. Open `http://localhost:4000/api/index.html` in your browser

3. Make sure `openapi.json` is accessible at `http://localhost:4000/api/openapi.json`

### Using Redoc CLI

You can also view the API documentation using Redoc CLI:

```bash
npx @redocly/cli preview-docs backend/openapi/openapi.json
```

### Using Swagger UI

Alternatively, you can use Swagger UI:

```bash
docker run -p 8080:8080 -e SWAGGER_JSON=/openapi.json -v $(pwd)/backend/openapi:/openapi swaggerapi/swagger-ui
```

Then open `http://localhost:8080` in your browser.

## Updating the API Documentation

The OpenAPI specification is **automatically updated** on every push to `main`:

1. The CI/CD workflow starts the backend server
2. Exports the current OpenAPI specification from `/openapi.json`
3. Automatically commits the updated `openapi.json` back to the repository
4. GitHub Pages automatically rebuilds and publishes the updated documentation

**You don't need to manually update `openapi.json`!** Just modify the API code, commit, and push - everything else happens automatically.

### Manual Update (for Local Development)

If you need to update the specification locally:

1. Make changes to the API endpoints in `backend/app/presentation/api/`
2. Run the backend server: `cd backend && poetry run uvicorn main:app --reload`
3. Export the OpenAPI spec: `curl http://localhost:8000/openapi.json > backend/openapi/openapi.json`
4. Copy to docs: `cp backend/openapi/openapi.json docs/api/openapi.json`

## API Base URLs

- **Local development**: `http://localhost:8000`
- **Production**: (configure based on your deployment)

