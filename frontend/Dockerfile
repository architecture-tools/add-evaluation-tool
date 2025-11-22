# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock* ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Clean previous builds
RUN flutter clean

# Build for web with explicit flags
RUN flutter build web --release --no-tree-shake-icons

# Production stage
FROM nginx:alpine

# Copy built web files
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

