// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:filmoteca/config.dart';

class AuthService {
  // Use central `apiBase` from config.dart so it's easy to change in one place
  // Note: change `apiBase` in `lib/config.dart` for emulator/device differences
  static String get baseUrl => apiBase;

  /// register: returns parsed JSON (Map) or throws on network
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final res = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
      },
    );
    return _parseResponse(res);
  }

  /// login: returns parsed JSON (Map) or throws on network
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final res = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {
        'email': email,
        'password': password,
      },
    );
    return _parseResponse(res);
  }

  static Map<String, dynamic> _parseResponse(http.Response res) {
    // Be defensive: backend may return an HTML error page (e.g. 404) which
    // would crash jsonDecode. We try to decode JSON only when appropriate.
    Map<String, dynamic>? data;
    try {
      final contentType = res.headers['content-type'] ?? '';
      if (contentType.contains('application/json')) {
        final body = res.body.isEmpty ? '{}' : res.body;
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      }
    } catch (_) {
      // ignore and fall back to non-JSON error payload below
    }

    data ??= <String, dynamic>{
      'message': 'Non-JSON response from server',
      'raw': res.body
          .toString()
          .substring(0, res.body.length > 200 ? 200 : res.body.length),
    };

    return {
      'statusCode': res.statusCode,
      'body': data,
    };
  }
}
