import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmoteca/config.dart';

class FavoriteService {
  // Use central apiBase defined in lib/config.dart
  static String get baseUrl => apiBase;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<List<dynamic>> getFavorites() async {
    final token = await _getToken();
    if (token == null) return [];
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/favorites"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      if (res.statusCode == 200) {
        try {
          final decoded = jsonDecode(res.body);
          if (decoded is List) return decoded;
          if (decoded is Map && decoded['data'] is List) {
            return List<dynamic>.from(decoded['data']);
          }
        } catch (_) {
          // Non-JSON or unexpected payload; fall through to return []
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Future<bool> addFavorite(Map<String, dynamic> data) async {
    final token = await _getToken();
    if (token == null) return false;
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/favorites"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
        body: jsonEncode(data),
      );
      // Some backends return 200 OK instead of 201 Created
      if (res.statusCode == 201 || res.statusCode == 200) {
        return true;
      }
      // Try to detect success flag in JSON body
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map) {
          final success = decoded['success'];
          if (success == true) return true;
        }
      } catch (_) {}
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> removeFavorite(int favId) async {
    final token = await _getToken();
    if (token == null) return false;
    try {
      final res = await http.delete(
        Uri.parse("$baseUrl/favorites/$favId"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
