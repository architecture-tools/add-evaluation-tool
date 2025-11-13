POETRY ?= poetry

.PHONY: install format lint test

install:
	$(POETRY) install

format:
	$(POETRY) run ruff format app main.py

lint:
	$(POETRY) run ruff check app main.py
	$(POETRY) run mypy app

test:
	$(POETRY) run pytest

# Export OpenAPI schema (requires server to be running)
export-openapi:
	@echo "Fetching OpenAPI schema from http://localhost:8000/openapi.json"
	@curl -s http://localhost:8000/openapi.json | jq . > openapi/openapi.json || \
		curl -s http://localhost:8000/openapi.json > openapi/openapi.json
	@echo "OpenAPI schema exported to openapi/openapi.json"


