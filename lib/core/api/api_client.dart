/// API Client following uwhportal backend compatibility patterns
/// 
/// This client is designed to be easily adaptable to the uwhportal 
/// ASP.NET Core API structure and authentication patterns.
library;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/error_handler.dart';
import '../config/environment_config.dart';

class ApiClient {
  String get _baseUrl => EnvironmentConfig.apiBaseUrl;
  
  final http.Client _client;
  String? _authToken;
  
  ApiClient({http.Client? client}) : _client = client ?? http.Client();
  
  /// Set authentication token for API calls
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  /// Get default headers including authentication
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };
  
  /// GET request with error handling
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException('No internet connection');
    } on HttpException {
      throw const NetworkException('Network request failed');
    } catch (e) {
      throw ApiException('GET request failed', originalError: e);
    }
  }
  
  /// POST request with error handling
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _defaultHeaders,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('POST request failed: $e');
    }
  }
  
  /// PUT request with error handling
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _defaultHeaders,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('PUT request failed: $e');
    }
  }
  
  /// DELETE request with error handling
  Future<void> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _defaultHeaders,
      );
      _handleResponse(response);
    } catch (e) {
      throw ApiException('DELETE request failed: $e');
    }
  }
  
  /// Handle HTTP responses and errors
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body);
    } else {
      throw ApiException(
        'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        statusCode: response.statusCode,
      );
    }
  }
  
  void dispose() {
    _client.close();
  }
}
