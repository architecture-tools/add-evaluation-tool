# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Install Node.js and openapi-generator for API client generation
RUN apt-get update && \
    apt-get install -y nodejs npm python3 && \
    npm install -g @openapitools/openapi-generator-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy pubspec files
COPY frontend/pubspec.yaml frontend/pubspec.lock* ./

# Get dependencies
RUN flutter pub get

# Copy OpenAPI spec from backend
COPY backend/openapi/openapi.json /tmp/openapi.json

# Generate API client
RUN mkdir -p lib/network/src && \
    openapi-generator-cli generate \
      -i /tmp/openapi.json \
      -g dart \
      -o lib/network/temp \
      --additional-properties=pubName=arch_eval_api,pubVersion=0.1.0 && \
    rm -rf lib/network/src/* && \
    cp -r lib/network/temp/lib/* lib/network/src/ && \
    rm -rf lib/network/temp

# Copy scripts and apply fixes
COPY frontend/scripts/fix_generated_code.py scripts/
RUN python3 scripts/fix_generated_code.py

# Copy source code
COPY frontend/ .

# Clean previous builds
RUN flutter clean

# Build for web with explicit flags
RUN flutter build web --release --no-tree-shake-icons

# Production stage
FROM nginx:alpine

# Copy built web files
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

