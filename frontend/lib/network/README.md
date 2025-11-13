# Network Layer

This directory contains the auto-generated API client code.

## Structure

```
network/
└── src/              # Generated API client source code
    ├── api/          # API client classes (DiagramsApi, HealthApi, etc.)
    ├── model/        # Data models (DiagramResponse, ComponentResponse, etc.)
    ├── api_client.dart
    ├── api_exception.dart
    └── ...
```

## Generation

The API client is generated from the OpenAPI specification using `openapi-generator`.

To regenerate:

```bash
make generate-api
```

This will:
1. Generate the code to a temporary location
2. Extract the `lib/` contents to `lib/network/src/`
3. Apply post-generation fixes (fixes known issues with union types)
4. Clean up temporary files

## Usage

Import the generated API client directly:

```dart
import 'package:architecture_evaluation_tool/network/src/api/diagrams_api.dart';
import 'package:architecture_evaluation_tool/network/src/model/diagram_response.dart';

// Use the API
final api = DiagramsApi();
final diagrams = await api.listDiagrams();
```

## Notes

- This directory is gitignored (regenerate from OpenAPI spec)
- The generated code should not be manually edited
- Regenerate after backend API changes

