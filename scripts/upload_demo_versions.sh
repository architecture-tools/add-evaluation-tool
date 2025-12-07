#!/bin/bash

# Script to upload and parse all demo versions
# This will create a timeline of diagram versions for visualization

BASE_URL="${BASE_URL:-http://localhost:8000}"
DEMO_DIR="demo_versions"

echo "Uploading demo versions to $BASE_URL..."

# Upload and parse each version in order
for i in {1..10}; do
  file="${DEMO_DIR}/demo_v${i}.puml"
  if [ ! -f "$file" ]; then
    echo "Warning: $file not found, skipping..."
    continue
  fi

  echo ""
  echo "Processing $file..."
  
  # Upload the diagram
  upload_response=$(curl -s -X POST "${BASE_URL}/api/v1/diagrams" \
    -F "file=@${file}" \
    -F "name=Demo Version ${i}")
  
  diagram_id=$(echo "$upload_response" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
  
  if [ -z "$diagram_id" ]; then
    echo "Failed to upload $file"
    echo "Response: $upload_response"
    continue
  fi
  
  echo "  Uploaded: diagram ID = $diagram_id"
  
  # Parse the diagram
  parse_response=$(curl -s -X POST "${BASE_URL}/api/v1/diagrams/${diagram_id}/parse")
  
  if echo "$parse_response" | grep -q '"status":"parsed"'; then
    echo "  ✓ Parsed successfully"
  else
    echo "  ✗ Parse failed or incomplete"
    echo "  Response: $parse_response"
  fi
  
  # Small delay to ensure proper ordering
  sleep 0.5
done

echo ""
echo "Done! Check the dashboard to see the version timeline."



