import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_evaluation_tool/services/auth_service.dart';
import 'package:architecture_evaluation_tool/network/src/api.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([AuthApi])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService Tests', () {
    late AuthService authService;
    late MockAuthApi mockApi;

    setUp(() async {
      // Initialize SharedPreferences with empty values for testing
      SharedPreferences.setMockInitialValues({});
      mockApi = MockAuthApi();
      authService = AuthService(api: mockApi);
    });

    group('Register', () {
      test('successfully registers a new user', () async {
        // Arrange
        final registerResponse = RegisterResponse(
          user: UserResponse(
            id: 'user-123',
            email: 'test@example.com',
          ),
          token: TokenResponse(
            accessToken: 'test-token-123',
            tokenType: 'bearer',
          ),
        );

        final userResponse = UserResponse(
          id: 'user-123',
          email: 'test@example.com',
        );

        when(mockApi.registerApiV1AuthRegisterPost(any))
            .thenAnswer((_) async => registerResponse);
        when(mockApi.getMeApiV1AuthMeGet())
            .thenAnswer((_) async => userResponse);

        // Act
        await authService.register(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(authService.isAuthenticated, isTrue);
        expect(authService.currentUser?.email, 'test@example.com');
        expect(authService.currentUser?.id, 'user-123');
        verify(mockApi.registerApiV1AuthRegisterPost(any)).called(1);
        verify(mockApi.getMeApiV1AuthMeGet()).called(1);
      });

      test('throws exception when registration fails', () async {
        // Arrange
        when(mockApi.registerApiV1AuthRegisterPost(any))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => authService.register(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('falls back to register response user if /auth/me fails', () async {
        // Arrange
        final registerResponse = RegisterResponse(
          user: UserResponse(
            id: 'user-123',
            email: 'test@example.com',
          ),
          token: TokenResponse(
            accessToken: 'test-token-123',
            tokenType: 'bearer',
          ),
        );

        when(mockApi.registerApiV1AuthRegisterPost(any))
            .thenAnswer((_) async => registerResponse);
        when(mockApi.getMeApiV1AuthMeGet()).thenAnswer((_) async => null);

        // Act
        await authService.register(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(authService.isAuthenticated, isTrue);
        expect(authService.currentUser?.email, 'test@example.com');
        expect(authService.currentUser?.id, 'user-123');
      });
    });

    group('Login', () {
      test('successfully logs in a user', () async {
        // Arrange
        final loginResponse = LoginResponse(
          user: UserResponse(
            id: 'user-123',
            email: 'test@example.com',
          ),
          token: TokenResponse(
            accessToken: 'test-token-123',
            tokenType: 'bearer',
          ),
        );

        final userResponse = UserResponse(
          id: 'user-123',
          email: 'test@example.com',
        );

        when(mockApi.loginApiV1AuthLoginPost(any))
            .thenAnswer((_) async => loginResponse);
        when(mockApi.getMeApiV1AuthMeGet())
            .thenAnswer((_) async => userResponse);

        // Act
        await authService.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(authService.isAuthenticated, isTrue);
        expect(authService.currentUser?.email, 'test@example.com');
        expect(authService.currentUser?.id, 'user-123');
        verify(mockApi.loginApiV1AuthLoginPost(any)).called(1);
        verify(mockApi.getMeApiV1AuthMeGet()).called(1);
      });

      test('throws exception when login fails', () async {
        // Arrange
        when(mockApi.loginApiV1AuthLoginPost(any))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => authService.login(
            email: 'test@example.com',
            password: 'wrongpassword',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('falls back to login response user if /auth/me fails', () async {
        // Arrange
        final loginResponse = LoginResponse(
          user: UserResponse(
            id: 'user-123',
            email: 'test@example.com',
          ),
          token: TokenResponse(
            accessToken: 'test-token-123',
            tokenType: 'bearer',
          ),
        );

        when(mockApi.loginApiV1AuthLoginPost(any))
            .thenAnswer((_) async => loginResponse);
        when(mockApi.getMeApiV1AuthMeGet()).thenAnswer((_) async => null);

        // Act
        await authService.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(authService.isAuthenticated, isTrue);
        expect(authService.currentUser?.email, 'test@example.com');
        expect(authService.currentUser?.id, 'user-123');
      });
    });

    group('Get Current User', () {
      test('successfully gets current user with valid token', () async {
        // Arrange
        final userResponse = UserResponse(
          id: 'user-123',
          email: 'test@example.com',
        );

        when(mockApi.getMeApiV1AuthMeGet())
            .thenAnswer((_) async => userResponse);

        // Set token first
        authService = AuthService(api: mockApi);
        // We need to set token manually for this test
        // Since _setToken is private, we'll test through login
        final loginResponse = LoginResponse(
          user: userResponse,
          token: TokenResponse(
            accessToken: 'test-token-123',
            tokenType: 'bearer',
          ),
        );
        when(mockApi.loginApiV1AuthLoginPost(any))
            .thenAnswer((_) async => loginResponse);
        await authService.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Reset mock to test getCurrentUser
        reset(mockApi);
        when(mockApi.getMeApiV1AuthMeGet())
            .thenAnswer((_) async => userResponse);

        // Act
        final user = await authService.getCurrentUser();

        // Assert
        expect(user, isNotNull);
        expect(user?.email, 'test@example.com');
        expect(user?.id, 'user-123');
      });

      test('returns null and logs out when token is invalid', () async {
        // Arrange
        final loginResponse = LoginResponse(
          user: UserResponse(
            id: 'user-123',
            email: 'test@example.com',
          ),
          token: TokenResponse(
            accessToken: 'test-token-123',
            tokenType: 'bearer',
          ),
        );

        // Set token first - mock login to succeed
        authService = AuthService(api: mockApi);
        when(mockApi.loginApiV1AuthLoginPost(any))
            .thenAnswer((_) async => loginResponse);
        when(mockApi.getMeApiV1AuthMeGet())
            .thenAnswer((_) async => loginResponse.user);
        await authService.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Reset mock to test getCurrentUser with error
        reset(mockApi);
        when(mockApi.getMeApiV1AuthMeGet())
            .thenThrow(Exception('Invalid token'));

        // Act
        final user = await authService.getCurrentUser();

        // Assert
        expect(user, isNull);
        expect(authService.isAuthenticated, isFalse);
      });
    });

    group('Logout', () {
      test('successfully logs out user', () async {
        // Arrange
        final loginResponse = LoginResponse(
          user: UserResponse(
            id: 'user-123',
            email: 'test@example.com',
          ),
          token: TokenResponse(
            accessToken: 'test-token-123',
            tokenType: 'bearer',
          ),
        );

        when(mockApi.loginApiV1AuthLoginPost(any))
            .thenAnswer((_) async => loginResponse);
        when(mockApi.getMeApiV1AuthMeGet())
            .thenAnswer((_) async => loginResponse.user);

        await authService.login(
          email: 'test@example.com',
          password: 'password123',
        );

        // Act
        await authService.logout();

        // Assert
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
      });
    });

    group('Initialize', () {
      test('initializes with no stored token', () async {
        // Act
        await authService.initialize();

        // Assert
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
      });
    });

    group('Authentication State', () {
      test('isAuthenticated returns false when no token', () {
        expect(authService.isAuthenticated, isFalse);
      });

      test('isAuthenticated returns false when no user', () {
        // Even with token, if no user, not authenticated
        expect(authService.isAuthenticated, isFalse);
      });
    });
  });
}
