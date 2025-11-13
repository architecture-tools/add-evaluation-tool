# OpenAPI Specification

This directory contains the OpenAPI specification for the Architecture Evaluation Tool API.

## Files

- `openapi.json` - Auto-generated OpenAPI 3.0 specification (exported from FastAPI)
- `openapi.yaml` - Optional YAML version of the specification

## Generating the OpenAPI Schema

FastAPI automatically generates the OpenAPI schema at runtime. To export it to a file:

```bash
# Start the server
poetry run uvicorn main:app --reload

# In another terminal, fetch and save the schema
curl http://localhost:8000/openapi.json > openapi/openapi.json

# Or convert to YAML (requires yq or similar tool)
curl http://localhost:8000/openapi.json | yq -P > openapi/openapi.yaml
```

## Using the Schema

- **API Documentation**: The schema is automatically available at `/docs` (Swagger UI) and `/redoc`
- **Client Generation**: Use tools like `openapi-generator` or `swagger-codegen` to generate client SDKs
- **API Testing**: Import into tools like Postman, Insomnia, or Bruno
- **Validation**: Use for API contract testing and validation

## Version Control

The OpenAPI schema should be committed to version control to:
- Track API changes over time
- Enable API contract testing
- Provide a stable reference for API consumers
- Support documentation generation

