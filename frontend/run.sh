#!/bin/bash

# Quick start script for Flutter frontend

echo "🚀 Starting Architecture Evaluation Tool Frontend..."
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Check for errors (excluding generated network code)
echo ""
echo "🔍 Checking for errors..."
flutter analyze lib --no-fatal-infos --exclude=lib/network/src 2>&1 | grep -E "error|Error" || echo "✅ No critical errors found"

# Run the app
echo ""
echo "🌐 Launching app on http://localhost:8080"
echo "Press Ctrl+C to stop"
echo ""
flutter run -d chrome --web-port=8080

