import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Set to empty string to force local-only mode until backend is deployed
  static const String baseUrl = '';

  // ─── Auth token management ─────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token') ||
        prefs.containsKey('user_data');
  }

  // ─── Helpers ───────────────────────────────────────────────
  static Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
      };

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Auth APIs (with local fallback) ───────────────────────

  /// Register a new user — tries server, falls back to local storage
  static Future<Map<String, dynamic>> register({
    required String name,
    required String mobile,
    required String email,
    required String password,
    String country = '',
    String state = '',
  }) async {
    // Try server if configured
    if (baseUrl.isNotEmpty) {
      try {
        final resp = await http
            .post(
              Uri.parse('$baseUrl/api/auth/register'),
              headers: _jsonHeaders,
              body: json.encode({
                'name': name, 'mobile': mobile,
                'email': email, 'password': password,
                'country': country, 'state': state,
              }),
            )
            .timeout(const Duration(seconds: 10));
        final data = json.decode(resp.body) as Map<String, dynamic>;
        if (resp.statusCode == 201) {
          await saveToken(data['token']);
          await _saveUserData(data['user']);
        }
        return data;
      } catch (_) {}
    }

    // ── Local fallback ──────────────────────────────────────
    final prefs = await SharedPreferences.getInstance();
    // Check email not already registered
    final existing = prefs.getString('user_${email.toLowerCase().trim()}');
    if (existing != null) {
      return {'message': 'यह ईमेल पहले से पंजीकृत है।'};
    }
    // Password must be >= 6 chars
    if (password.length < 6) {
      return {'message': 'पासवर्ड कम से कम 6 अक्षर का होना चाहिए।'};
    }
    // Save user locally
    final userData = {
      'name': name, 'mobile': mobile, 'email': email,
      'password': password, 'country': country, 'state': state,
    };
    await prefs.setString('user_${email.toLowerCase().trim()}', json.encode(userData));
    await _saveUserData(userData);
    await saveToken('local_token_${email.hashCode}');
    return {'token': 'local_token', 'user': userData};
  }

  /// Login — tries server, falls back to local storage
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Try server if configured
    if (baseUrl.isNotEmpty) {
      try {
        final resp = await http
            .post(
              Uri.parse('$baseUrl/api/auth/login'),
              headers: _jsonHeaders,
              body: json.encode({'email': email, 'password': password}),
            )
            .timeout(const Duration(seconds: 10));
        final data = json.decode(resp.body) as Map<String, dynamic>;
        if (resp.statusCode == 200) {
          await saveToken(data['token']);
          await _saveUserData(data['user']);
        }
        return data;
      } catch (_) {}
    }

    // ── Local fallback ──────────────────────────────────────
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_${email.toLowerCase().trim()}');
    if (raw == null) {
      return {'message': 'यह ईमेल पंजीकृत नहीं है।'};
    }
    final userData = json.decode(raw) as Map<String, dynamic>;
    if (userData['password'] != password) {
      return {'message': 'पासवर्ड गलत है। कृपया पुनः प्रयास करें।'};
    }
    await _saveUserData(userData);
    await saveToken('local_token_${email.hashCode}');
    return {'token': 'local_token', 'user': userData};
  }

  /// Get current user profile — from local cache
  static Future<Map<String, dynamic>?> getProfile() async {
    return await getCachedUser();
  }

  // ─── Documents APIs ────────────────────────────────────────

  /// Get all documents for current user
  static Future<List<Map<String, dynamic>>> getDocuments() async {
    if (baseUrl.isNotEmpty) {
      try {
        final headers = await _authHeaders();
        final resp = await http
            .get(Uri.parse('$baseUrl/api/documents'), headers: headers)
            .timeout(const Duration(seconds: 10));
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body) as Map<String, dynamic>;
          return (data['documents'] as List).cast<Map<String, dynamic>>();
        }
      } catch (_) {}
    }
    return []; // local docs handled by StorageService
  }

  /// Upload a scanned document image
  static Future<Map<String, dynamic>?> uploadDocument({
    required File imageFile,
    required String name,
    required String type,
  }) async {
    if (baseUrl.isNotEmpty) {
      try {
        final token = await getToken();
        final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/documents'));
        if (token != null) request.headers['Authorization'] = 'Bearer $token';
        request.fields['name'] = name;
        request.fields['type'] = type;
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
        final streamed = await request.send().timeout(const Duration(seconds: 30));
        final resp = await http.Response.fromStream(streamed);
        final data = json.decode(resp.body) as Map<String, dynamic>;
        return resp.statusCode == 201 ? data['document'] as Map<String, dynamic> : null;
      } catch (_) {}
    }
    return null;
  }

  /// Delete a document by ID
  static Future<bool> deleteDocument(String docId) async {
    if (baseUrl.isEmpty) return true; // local deletion handled by StorageService
    try {
      final headers = await _authHeaders();
      final resp = await http
          .delete(Uri.parse('$baseUrl/api/documents/$docId'), headers: headers)
          .timeout(const Duration(seconds: 10));
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ─── Local user cache ──────────────────────────────────────
  static Future<void> _saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final safe = Map<String, dynamic>.from(user)..remove('password');
    await prefs.setString('user_data', json.encode(safe));
    await prefs.setString('userName', user['name'] ?? '');
  }

  static Future<Map<String, dynamic>?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user_data');
    if (raw == null) return null;
    return json.decode(raw) as Map<String, dynamic>;
  }
}
