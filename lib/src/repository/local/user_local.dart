// Updated lib/src/repository/local/user_local.dart
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:get_boilerplate/src/models/user_model.dart';

class UserLocal {
  final _getStorage = GetStorage();

  // Storage keys
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';

  // Token methods
  String getAccessToken() {
    return _getStorage.read(_tokenKey) ?? '';
  }

  void saveAccessToken(String accessToken) {
    _getStorage.write(_tokenKey, accessToken);
  }

  String getRefreshToken() {
    return _getStorage.read(_refreshTokenKey) ?? '';
  }

  void saveRefreshToken(String refreshToken) {
    _getStorage.write(_refreshTokenKey, refreshToken);
  }

  // User data methods
  User? getUserData() {
    try {
      final userData = _getStorage.read(_userDataKey);
      if (userData != null) {
        final Map<String, dynamic> userMap = jsonDecode(userData);
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void saveUserData(User user) {
    final userJson = jsonEncode(user.toJson());
    _getStorage.write(_userDataKey, userJson);
  }

  // Clear all user data
  void clearUserData() {
    _getStorage.remove(_tokenKey);
    _getStorage.remove(_refreshTokenKey);
    _getStorage.remove(_userDataKey);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getAccessToken().isNotEmpty && getUserData() != null;
  }

  // Save tokens from login response
  void saveTokens({
    required String accessToken,
    String? refreshToken,
  }) {
    saveAccessToken(accessToken);
    if (refreshToken != null) {
      saveRefreshToken(refreshToken);
    }
  }
}
