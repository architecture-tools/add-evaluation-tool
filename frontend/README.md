# Architecture Evaluation Tool - Flutter Frontend

Flutter web frontend for the Architecture Evaluation Tool.

## Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Generate API client from OpenAPI spec:
```bash
make generate-api
```

3. Run the app:
```bash
flutter run -d chrome --web-port=8080
```

## Project Structure

```
lib/
├── network/
│   └── src/           # Auto-generated API client (from OpenAPI)
│       ├── api/       # API client classes
│       ├── model/     # Data models
│       └── ...
├── models/            # Additional data models (mock models)
├── services/          # API service layer
├── screens/           # UI screens
├── widgets/           # Reusable widgets
├── theme/             # App theme and styling
└── main.dart          # App entry point
```

## Development

- **Format code**: `make format` or `flutter format lib`
- **Lint code**: `make lint` or `flutter analyze`
- **Run tests**: `make test` or `flutter test`

## API Client Generation

The API client is generated from the OpenAPI specification using `openapi-generator`. 

To regenerate after backend API changes:
```bash
make generate-api
```

This will update the code in `lib/network/src/` based on `../backend/openapi/openapi.json`.

The generated code can be imported directly:
```dart
import 'package:architecture_evaluation_tool/network/src/api/diagrams_api.dart';
import 'package:architecture_evaluation_tool/network/src/model/diagram_response.dart';
```

