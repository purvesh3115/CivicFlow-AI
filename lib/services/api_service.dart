import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (Code: $statusCode)';
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _buildHeaders({String? token}) {
    final headers = Map<String, String>.from(ApiConstants.defaultHeaders);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(
    String endpoint, {
    String? token,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint')
          .replace(queryParameters: queryParameters);
      final response = await _client
          .get(uri, headers: _buildHeaders(token: token))
          .timeout(AppConstants.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException(message: 'Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected network error: $e');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(token: token),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(AppConstants.receiveTimeout);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException(message: 'Connection timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected network error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final int code = response.statusCode;
    dynamic body;
    if (response.body.isNotEmpty) {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        body = response.body;
      }
    }

    if (code >= 200 && code < 300) {
      return body;
    } else if (code == 400) {
      throw ApiException(
        message: body is Map && body['message'] != null
            ? body['message']
            : 'Bad request. Please verify your input.',
        statusCode: code,
        data: body,
      );
    } else if (code == 401) {
      throw ApiException(
        message: 'Unauthorized. Please login again.',
        statusCode: code,
        data: body,
      );
    } else if (code == 403) {
      throw ApiException(
        message: 'Access denied. You do not have permission to perform this action.',
        statusCode: code,
        data: body,
      );
    } else if (code == 404) {
      throw ApiException(
        message: 'Resource not found.',
        statusCode: code,
        data: body,
      );
    } else if (code == 409) {
      throw ApiException(
        message: body is Map && body['message'] != null
            ? body['message']
            : 'A conflict occurred. Record already exists.',
        statusCode: code,
        data: body,
      );
    } else if (code >= 500) {
      throw ApiException(
        message: 'Server error. Our engineers have been notified.',
        statusCode: code,
        data: body,
      );
    } else {
      throw ApiException(
        message: 'Unexpected response from server ($code)',
        statusCode: code,
        data: body,
      );
    }
  }
}
