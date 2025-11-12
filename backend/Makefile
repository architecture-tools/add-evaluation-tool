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


