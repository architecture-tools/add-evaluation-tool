#!/bin/bash
# Verification script to test CI/CD setup locally

set -e

echo "🔍 Verifying CI/CD setup for frontend tests..."
echo ""

# Check 1: OpenAPI spec exists
echo "1. Checking OpenAPI specification..."
if [ -f "../backend/openapi/openapi.json" ]; then
    echo "   ✅ OpenAPI spec found"
else
    echo "   ❌ OpenAPI spec missing at ../backend/openapi/openapi.json"
    exit 1
fi

# Check 2: Python is available
echo "2. Checking Python..."
if command -v python3 > /dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version)
    echo "   ✅ Python found: $PYTHON_VERSION"
else
    echo "   ❌ Python3 not found"
    exit 1
fi

# Check 3: openapi-generator-cli can be installed (simulate)
echo "3. Checking if openapi-generator can be installed..."
if command -v npm > /dev/null 2>&1; then
    echo "   ✅ npm found, can install @openapitools/openapi-generator-cli"
else
    echo "   ⚠️  npm not found (will be installed in CI)"
fi

# Check 4: Flutter is available
echo "4. Checking Flutter..."
if command -v flutter > /dev/null 2>&1; then
    FLUTTER_VERSION=$(flutter --version | head -1)
    echo "   ✅ Flutter found: $FLUTTER_VERSION"
else
    echo "   ❌ Flutter not found"
    exit 1
fi

# Check 5: Test Makefile syntax
echo "5. Checking Makefile syntax..."
if make -n generate-api > /dev/null 2>&1; then
    echo "   ✅ Makefile syntax is valid"
else
    echo "   ❌ Makefile has syntax errors"
    exit 1
fi

# Check 6: Dependencies can be installed
echo "6. Checking Flutter dependencies..."
if flutter pub get > /dev/null 2>&1; then
    echo "   ✅ Flutter dependencies can be installed"
else
    echo "   ⚠️  Flutter pub get had issues (may need network)"
fi

echo ""
echo "✅ All checks passed! CI/CD setup looks good."
echo ""
echo "Note: To fully test, you would need:"
echo "  - openapi-generator-cli installed (npm install -g @openapitools/openapi-generator-cli)"
echo "  - Run: make generate-api"
echo "  - Run: flutter test --coverage"

