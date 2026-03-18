import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../../config/network/api_config.dart';
import '../../core/utils/app_logger.dart';

/// BaseApiService provides a foundation for all REST API communication.
/// It automatically handles Firebase Auth token injection and centralized error handling.
class BaseApiService {
  static final BaseApiService _instance = BaseApiService._internal();
  factory BaseApiService() => _instance;
  BaseApiService._internal();

  final http.Client _client = http.Client();

  /// Generic GET request.
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    return _sendRequest('GET', endpoint, headers: headers);
  }

  /// Generic POST request.
  Future<dynamic> post(String endpoint, {Map<String, String>? headers, dynamic body}) async {
    return _sendRequest('POST', endpoint, headers: headers, body: body);
  }

  /// Generic PUT request.
  Future<dynamic> put(String endpoint, {Map<String, String>? headers, dynamic body}) async {
    return _sendRequest('PUT', endpoint, headers: headers, body: body);
  }

  /// Generic PATCH request.
  Future<dynamic> patch(String endpoint, {Map<String, String>? headers, dynamic body}) async {
    return _sendRequest('PATCH', endpoint, headers: headers, body: body);
  }

  /// Generic DELETE request.
  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    return _sendRequest('DELETE', endpoint, headers: headers);
  }

  /// Generic Multipart POST request for file uploads.
  Future<dynamic> postMultipart(String endpoint, {
    Map<String, String>? headers,
    required File file,
    String field = 'file',
  }) async {
    final url = Uri.parse('${ApiConfig.apiUrl}/$endpoint');
    final combinedHeaders = await _getHeaders(headers);
    // Remove Content-Type for multipart, as it's set automatically with the boundary
    combinedHeaders.remove('Content-Type');

    try {
      AppLogger.d('API Multipart Request: POST $url');
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(combinedHeaders);
      request.files.add(await http.MultipartFile.fromPath(field, file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      AppLogger.e('Multipart API Error: $e');
      rethrow;
    }
  }

  /// Core request orchestrator.
  Future<dynamic> _sendRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final url = Uri.parse('${ApiConfig.apiUrl}/$endpoint');
    final combinedHeaders = await _getHeaders(headers);

    try {
      AppLogger.d('API Request: $method $url');
      
      http.Response response;
      switch (method) {
        case 'GET':
          response = await _client.get(url, headers: combinedHeaders);
          break;
        case 'POST':
          response = await _client.post(url, headers: combinedHeaders, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await _client.put(url, headers: combinedHeaders, body: jsonEncode(body));
          break;
        case 'PATCH':
          response = await _client.patch(url, headers: combinedHeaders, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await _client.delete(url, headers: combinedHeaders);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse(response);
    } on SocketException {
      AppLogger.e('No connection: $url');
      throw Exception('No hay conexión a internet.');
    } on http.ClientException catch (e) {
      AppLogger.e('Client Exception: $e');
      throw Exception('Error en la comunicación con el servidor.');
    } catch (e) {
      AppLogger.e('Unexpected API Error: $e');
      rethrow;
    }
  }

  /// Generates headers, injecting the Firebase ID Token if available.
  Future<Map<String, String>> _getHeaders(Map<String, String>? extraHeaders) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    // Inject Firebase ID Token
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Centralized response handling and error mapping.
  dynamic _handleResponse(http.Response response) {
    final dynamic data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    AppLogger.w('API Error (${response.statusCode}): ${response.body}');

    switch (response.statusCode) {
      case 400:
        throw Exception(data['message'] ?? 'Solicitud inválida.');
      case 401:
        // Handle token expiration / re-auth if needed
        throw Exception('Sesión expirada o no autorizada.');
      case 403:
        throw Exception('No tienes permiso para realizar esta acción.');
      case 404:
        throw Exception('Recurso no encontrado.');
      case 500:
        throw Exception('Error interno del servidor. Por favor intentalo más tarde.');
      default:
        throw Exception('Error inesperado (${response.statusCode}).');
    }
  }
}
