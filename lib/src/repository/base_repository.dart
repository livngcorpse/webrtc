import 'dart:convert';
import 'dart:io';
import 'package:get_boilerplate/src/repository/local/user_local.dart';
import 'package:http/http.dart' as http;

const String rootUrl = "domain_api.com";
const String socketUrl = "domain_api.com";

class HandleApis {
  static const Duration timeoutDuration = Duration(seconds: 30);

  Future<http.Response> get(String endpoint, [String params = '']) async {
    try {
      Map<String, String> paramsObject = {};
      if (params.isNotEmpty) {
        params.split('&').forEach((element) {
          final parts = element.split('=');
          if (parts.length == 2) {
            paramsObject[parts[0]] = parts[1];
          }
        });
      }

      final uri = params.isEmpty
          ? Uri.https(rootUrl, '/$endpoint')
          : Uri.https(rootUrl, '/$endpoint', paramsObject);

      final response =
          await http.get(uri, headers: _getHeaders()).timeout(timeoutDuration);

      return response;
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on HttpException {
      throw NetworkException('Could not find the server');
    } on FormatException {
      throw NetworkException('Bad response format');
    } catch (e) {
      throw NetworkException('Unexpected error: $e');
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.https(rootUrl, '/$endpoint');

      final response = await http
          .post(
            uri,
            headers: _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      return response;
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on HttpException {
      throw NetworkException('Could not find the server');
    } on FormatException {
      throw NetworkException('Bad response format');
    } catch (e) {
      throw NetworkException('Unexpected error: $e');
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.https(rootUrl, '/$endpoint');

      final response = await http
          .put(
            uri,
            headers: _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(timeoutDuration);

      return response;
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on HttpException {
      throw NetworkException('Could not find the server');
    } on FormatException {
      throw NetworkException('Bad response format');
    } catch (e) {
      throw NetworkException('Unexpected error: $e');
    }
  }

  Future<http.Response> delete(String endpoint,
      {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.https(rootUrl, '/$endpoint');

      final response = await http
          .delete(
            uri,
            headers: _getHeaders(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);

      return response;
    } on SocketException {
      throw NetworkException('No Internet connection');
    } on HttpException {
      throw NetworkException('Could not find the server');
    } on FormatException {
      throw NetworkException('Bad response format');
    } catch (e) {
      throw NetworkException('Unexpected error: $e');
    }
  }

  Map<String, String> _getHeaders() {
    final token = UserLocal().getAccessToken();
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Connection': 'keep-alive',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });

  factory ApiResponse.fromResponse(http.Response response, {T? data}) {
    final bool isSuccess =
        response.statusCode >= 200 && response.statusCode < 300;

    String message;
    try {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      message = responseBody['message'] ?? 'Unknown error';
    } catch (e) {
      message = response.reasonPhrase ?? 'Unknown error';
    }

    return ApiResponse<T>(
      success: isSuccess,
      message: message,
      data: data,
      statusCode: response.statusCode,
    );
  }

  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: 200,
    );
  }

  factory ApiResponse.error(String message, {int statusCode = 500}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}
