import 'package:shared_preferences/shared_preferences.dart';
import '../network/src/api.dart';
import 'api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';

  AuthService({AuthApi? api})
      : _api = api ?? ApiConfig.authApi(),
        _useInjectedApi = api != null;

  final AuthApi _api;
  final bool _useInjectedApi;
  UserResponse? _currentUser;
  String? _token;

  UserResponse? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _currentUser != null;

  /// Get a fresh API instance with current authentication
  /// In tests, use the injected API instance; otherwise create a new one with current auth
  AuthApi get _authenticatedApi => _useInjectedApi ? _api : ApiConfig.authApi();

  /// Initialize auth service and load stored token
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);

    if (token != null) {
      await _setToken(token);
      // Try to get current user to validate token
      try {
        _currentUser = await _authenticatedApi.getMeApiV1AuthMeGet();
        if (_currentUser != null) {
          await _saveUserInfo(_currentUser!);
        }
      } catch (_) {
        // Token is invalid, clear it
        await logout();
      }
    }
  }

  /// Register a new user
  Future<void> register({
    required String email,
    required String password,
  }) async {
    final request = UserRegisterRequest(
      email: email,
      password: password,
    );

    final response = await _api.registerApiV1AuthRegisterPost(request);
    if (response == null) {
      throw Exception('Registration failed: empty response');
    }

    // Set token first to configure authentication
    await _setToken(response.token.accessToken);

    // Wait a tiny bit to ensure the API client is updated
    await Future.delayed(const Duration(milliseconds: 10));

    // Fetch current user from /auth/me to ensure we have latest info
    try {
      _currentUser = await _authenticatedApi.getMeApiV1AuthMeGet();
      if (_currentUser != null) {
        await _saveUserInfo(_currentUser!);
      } else {
        // Fallback to user from register response if /auth/me returns null
        _currentUser = response.user;
        await _saveUserInfo(response.user);
      }
    } catch (e) {
      // If /auth/me fails, fallback to user from register response
      _currentUser = response.user;
      await _saveUserInfo(response.user);
      // Re-throw if it's not an auth error (might indicate a real problem)
      if (e.toString().contains('403') || e.toString().contains('401')) {
        // Auth error - use fallback user but don't throw
        return;
      }
      rethrow;
    }
  }

  /// Login user
  Future<void> login({
    required String email,
    required String password,
  }) async {
    final request = UserLoginRequest(
      email: email,
      password: password,
    );

    final response = await _api.loginApiV1AuthLoginPost(request);
    if (response == null) {
      throw Exception('Login failed: empty response');
    }

    // Set token first to configure authentication
    await _setToken(response.token.accessToken);

    // Wait a tiny bit to ensure the API client is updated
    await Future.delayed(const Duration(milliseconds: 10));

    // Fetch current user from /auth/me to ensure we have latest info
    try {
      _currentUser = await _authenticatedApi.getMeApiV1AuthMeGet();
      if (_currentUser != null) {
        await _saveUserInfo(_currentUser!);
      } else {
        // Fallback to user from login response if /auth/me returns null
        _currentUser = response.user;
        await _saveUserInfo(response.user);
      }
    } catch (e) {
      // If /auth/me fails, fallback to user from login response
      _currentUser = response.user;
      await _saveUserInfo(response.user);
      // Re-throw if it's not an auth error (might indicate a real problem)
      if (e.toString().contains('403') || e.toString().contains('401')) {
        // Auth error - use fallback user but don't throw
        return;
      }
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    _token = null;
    _currentUser = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_userIdKey);

    // Clear authentication from API client
    defaultApiClient = ApiClient(
      basePath: defaultApiClient.basePath,
      authentication: null,
    );
  }

  /// Set authentication token and configure API client
  Future<void> _setToken(String token) async {
    _token = token;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);

    // Configure Bearer authentication for API client
    final bearerAuth = HttpBearerAuth();
    bearerAuth.accessToken = token;
    defaultApiClient = ApiClient(
      basePath: defaultApiClient.basePath,
      authentication: bearerAuth,
    );
  }

  /// Save user info to preferences
  Future<void> _saveUserInfo(UserResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, user.email);
    await prefs.setString(_userIdKey, user.id);
  }

  /// Get current user from API
  Future<UserResponse?> getCurrentUser() async {
    try {
      _currentUser = await _authenticatedApi.getMeApiV1AuthMeGet();
      if (_currentUser != null) {
        await _saveUserInfo(_currentUser!);
      }
      return _currentUser;
    } catch (_) {
      await logout();
      return null;
    }
  }
}
