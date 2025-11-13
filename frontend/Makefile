.PHONY: generate-api install format lint test

# Generate API client from OpenAPI spec
generate-api:
	@echo "Generating API client to lib/network/src/..."
	@mkdir -p lib/network/src
	openapi-generator generate \
		-i ../backend/openapi/openapi.json \
		-g dart \
		-o lib/network/temp \
		--additional-properties=pubName=arch_eval_api,pubVersion=0.1.0
	@echo "Moving generated files to lib/network/src/..."
	@rm -rf lib/network/src/*
	@cp -r lib/network/temp/lib/* lib/network/src/
	@rm -rf lib/network/temp
	@echo "Applying post-generation fixes..."
	@python3 scripts/fix_generated_code.py
	@echo "✅ API client generated in lib/network/src/"

install:
	flutter pub get

format:
	flutter format lib

lint:
	flutter analyze

test:
	flutter test

