import 'dart:convert';
import 'package:get_boilerplate/src/repository/base_repository.dart';
import 'package:get_boilerplate/src/repository/remote/api_gateway.dart';

class AuthenticationRepository {
  final HandleApis _handleApis = HandleApis();

  Future<ApiResponse<Map<String, dynamic>>> login(
      String username, String password) async {
    try {
      final body = {
        "phone": username,
        "password": password,
      };

      final response = await _handleApis.post(ApiGateway.LOGIN, body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final data = responseBody["data"] as Map<String, dynamic>? ?? {};

        return ApiResponse.success(data, message: 'Login successful');
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final message = responseBody["message"] ?? 'Login failed';

        return ApiResponse.error(message, statusCode: response.statusCode);
      }
    } on NetworkException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> register(
    String username,
    String password,
    String fullName,
  ) async {
    try {
      final body = {
        "phone": username,
        "password": password,
        "fullName": fullName,
      };

      final response = await _handleApis.post(ApiGateway.REGISTER, body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final data = responseBody["data"] as Map<String, dynamic>? ?? {};

        return ApiResponse.success(data, message: 'Registration successful');
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final message = responseBody["message"] ?? 'Registration failed';

        return ApiResponse.error(message, statusCode: response.statusCode);
      }
    } on NetworkException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('An unexpected error occurred: $e');
    }
  }

  Future<ApiResponse<bool>> logout() async {
    try {
      // If you have a logout endpoint
      // final response = await _handleApis.post(ApiGateway.LOGOUT, {});

      // For now, just return success (client-side logout)
      return ApiResponse.success(true, message: 'Logout successful');
    } catch (e) {
      return ApiResponse.error('Logout failed: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> refreshToken(
      String refreshToken) async {
    try {
      final body = {
        "refreshToken": refreshToken,
      };

      final response = await _handleApis.post('auth/refresh', body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final data = responseBody["data"] as Map<String, dynamic>? ?? {};

        return ApiResponse.success(data,
            message: 'Token refreshed successfully');
      } else {
        return ApiResponse.error('Token refresh failed',
            statusCode: response.statusCode);
      }
    } on NetworkException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Token refresh failed: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    try {
      final response = await _handleApis.get('auth/profile');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final data = responseBody["data"] as Map<String, dynamic>? ?? {};

        return ApiResponse.success(data);
      } else {
        return ApiResponse.error('Failed to get user profile',
            statusCode: response.statusCode);
      }
    } on NetworkException catch (e) {
      return ApiResponse.error(e.message);
    } catch (e) {
      return ApiResponse.error('Failed to get user profile: $e');
    }
  }
}
