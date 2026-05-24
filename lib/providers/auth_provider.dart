import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _expiryKey = 'token_expiry';
  static const _refreshKey = 'refresh_token';

  String? _accessToken;
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _accessToken != null;

  String get _clientId => dotenv.env['CLIENT_ID'] ?? '';
  String get _clientSecret => dotenv.env['CLIENT_SECRET'] ?? '';
  static const _redirectUri = 'swiftycompanion://callback';
  static const _tokenUrl = 'https://api.intra.42.fr/oauth/token';
  static const _authUrl = 'https://api.intra.42.fr/oauth/authorize';

  // Load token from secure storage on app start
  Future<void> init() async {
    final token = await _storage.read(key: _tokenKey);
    final expiryStr = await _storage.read(key: _expiryKey);

    if (token != null && expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isBefore(expiry)) {
        _accessToken = token;
        notifyListeners();
        return;
      }
      // Token expired — try to refresh
      await _tryRefreshToken();
    }
  }

  Future<String?> getValidToken() async {
    final expiryStr = await _storage.read(key: _expiryKey);
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 5)))) {
        await _tryRefreshToken();
      }
    }
    return _accessToken;
  }

  Future<bool> refreshAccessToken() async {
    return _tryRefreshToken();
  }

  Future<void> login() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1: Open browser for user to log in
      final result = await FlutterWebAuth2.authenticate(
        url:
            '$_authUrl'
            '?client_id=$_clientId'
            '&redirect_uri=${Uri.encodeComponent(_redirectUri)}' // hoq this work?
            '&response_type=code',
        callbackUrlScheme: 'swiftycompanion',
      );

      // Step 2: Extract code from redirect URL
      final code = Uri.parse(result).queryParameters['code'];
      if (code == null) throw Exception('No authorization code received');

      // Step 3: Exchange code for token
      await _exchangeCodeForToken(code);
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _exchangeCodeForToken(String code) async {
    // what this do?
    // This method takes the authorization code obtained from the OAuth flow and exchanges it for an access token. It sends a POST request to the token endpoint with the necessary parameters, including the client ID, client secret, authorization code, and redirect URI. If the request is successful, it saves the access token and its expiry time in secure storage. If the request fails, it throws an exception with the error message.
    final response = await http.post(
      Uri.parse(_tokenUrl),
      body: {
        'grant_type': 'authorization_code',
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'code': code,
        'redirect_uri': _redirectUri,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Token exchange failed: ${response.body}');
    }

    await _saveTokenFromResponse(response.body);
  }

  Future<bool> _tryRefreshToken() async {
    // what this do?
    // This method attempts to refresh the access token using the refresh token stored in secure storage.
    final refreshToken = await _storage.read(key: _refreshKey);
    if (refreshToken == null) {
      debugPrint('No refresh token found in storage.');
      _accessToken = null;
      notifyListeners();
      return false;
    }

    try {
      debugPrint('Attempting to refresh access token...');
      final response = await http.post(
        Uri.parse(_tokenUrl),
        body: {
          'grant_type': 'refresh_token',
          'client_id': _clientId,
          'client_secret': _clientSecret,
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('Refresh token successful!');
        await _saveTokenFromResponse(response.body);
        return true;
      } else {
        debugPrint('Refresh token failed with status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        await logout();
        return false;
      }
    } catch (e) {
      debugPrint('Refresh token threw an exception: $e');
      await logout();
      return false;
    }
  }

  Future<void> _saveTokenFromResponse(String body) async {
    final data = jsonDecode(body);
    _accessToken = data['access_token'];
    final expiresIn = data['expires_in'] as int;
    final expiry = DateTime.now().add(Duration(seconds: expiresIn));

    await _storage.write(key: _tokenKey, value: _accessToken);
    await _storage.write(key: _expiryKey, value: expiry.toIso8601String());

    if (data['refresh_token'] != null) {
      await _storage.write(key: _refreshKey, value: data['refresh_token']);
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}
