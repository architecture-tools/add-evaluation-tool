# Flutter Test Suite

This directory contains comprehensive tests for the Architecture Evaluation Tool Flutter frontend.

## Test Structure

```
test/
├── helpers/
│   └── test_helpers.dart          # Test utilities and mock data helpers
├── utils/
│   └── date_time_utils_test.dart  # Unit tests for utility functions
├── services/
│   ├── dashboard_service_test.dart # Unit tests for DashboardService
│   └── diagram_repository_test.dart # Unit tests for DiagramRepository
├── widgets/
│   ├── kpi_card_test.dart          # Widget tests for KPICard
│   ├── sidebar_test.dart           # Widget tests for Sidebar
│   ├── dashboard_header_test.dart   # Widget tests for DashboardHeader
│   └── quick_actions_widget_test.dart # Widget tests for QuickActionsWidget
└── integration/
    └── dashboard_flow_test.dart     # Integration tests for dashboard flow
```

## Running Tests

### Run all tests
```bash
make test
# or
flutter test
```

### Run specific test file
```bash
flutter test test/utils/date_time_utils_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Run tests in watch mode (for development)
```bash
flutter test --watch
```

## Test Categories

### Unit Tests
- **Utils**: Test utility functions like `formatRelativeTime`
- **Services**: Test business logic in services like `DashboardService` and `DiagramRepository`

### Widget Tests
- Test individual widgets in isolation
- Verify UI rendering and user interactions
- Test callback functions

### Integration Tests
- Test complete user flows
- Verify interaction between multiple widgets
- Test navigation and state management

## Test Helpers

The `test/helpers/test_helpers.dart` file provides:
- `TestHelpers.createMockDiagram()` - Creates mock DiagramResponse objects
- `TestHelpers.createMockDiagrams()` - Creates lists of mock diagrams
- `TestHelpers.createMockParseResponse()` - Creates mock ParseDiagramResponse objects
- `WidgetTestHelpers` extension - Helper methods for widget testing

## Writing New Tests

When adding new features, follow these guidelines:

1. **Unit Tests**: Test business logic in services and utilities
2. **Widget Tests**: Test UI components and user interactions
3. **Integration Tests**: Test complete user flows

### Example Unit Test
```dart
test('service method returns expected result', () {
  final service = MyService();
  final result = service.doSomething();
  expect(result, equals(expectedValue));
});
```

### Example Widget Test
```dart
testWidgets('widget displays correct text', (tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.text('Expected Text'), findsOneWidget);
});
```

## Mocking

Tests use manual mocks for API clients. For more complex scenarios, consider using `mockito` or `mocktail` packages (already added to `dev_dependencies`).

## Coverage Goals

- Aim for at least 80% code coverage
- Focus on critical business logic and user-facing features
- Don't test generated code (e.g., `lib/network/src/`)

## CI Integration

Tests are automatically run in CI/CD pipelines. Ensure all tests pass before merging PRs.

