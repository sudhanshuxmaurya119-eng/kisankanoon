import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/document_model.dart';

class StorageService {
  static const _userKey = 'kk_current_user';
  static const _docsKey = 'kk_docs';
  static const _scanCountKey = 'kk_scan_count';
  static const _langKey = 'kk_lang';

  // User
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_userKey);
  }

  // Documents
  static Future<List<DocumentModel>> getDocs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_docsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => DocumentModel.fromJson(e)).toList();
  }

  static Future<void> saveDoc(DocumentModel doc) async {
    final docs = await getDocs();
    docs.insert(0, doc);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_docsKey, jsonEncode(docs.map((d) => d.toJson()).toList()));
  }

  static Future<void> deleteDoc(String id) async {
    final docs = await getDocs();
    docs.removeWhere((d) => d.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_docsKey, jsonEncode(docs.map((d) => d.toJson()).toList()));
  }

  // Scan count
  static Future<int> getScanCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_scanCountKey) ?? 0;
  }

  static Future<void> incrementScanCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_scanCountKey) ?? 0;
    await prefs.setInt(_scanCountKey, count + 1);
  }

  // Language
  static Future<String> getLang() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'hi';
  }

  static Future<void> setLang(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, code);
  }
}
