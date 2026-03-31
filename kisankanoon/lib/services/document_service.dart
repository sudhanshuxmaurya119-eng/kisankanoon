import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentService {
  static const _docsKeyPrefix = 'kk_docs';
  static final StreamController<List<Map<String, dynamic>>>
      _documentsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  static String get _docsKey {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null ? _docsKeyPrefix : '${_docsKeyPrefix}_$uid';
  }

  static Future<Map<String, dynamic>?> uploadDocument({
    required File imageFile,
    required String docName,
    required String docType,
    String summary = '',
  }) async {
    try {
      final savedImage = await _copyImageToManagedFolder(imageFile);
      final createdAt = DateTime.now();
      final document = <String, dynamic>{
        'id': createdAt.microsecondsSinceEpoch.toString(),
        'name': docName,
        'title': docName,
        'type': docType,
        'summary': summary,
        'localPath': savedImage.path,
        'imagePath': savedImage.path,
        'storagePath': savedImage.path,
        'createdAt': createdAt.toIso8601String(),
      };

      final documents = await getDocuments();
      documents.insert(0, document);
      await _saveDocuments(documents);
      return document;
    } catch (_) {
      return null;
    }
  }

  static Stream<List<Map<String, dynamic>>> getDocumentsStream() async* {
    yield await getDocuments();
    yield* _documentsController.stream;
  }

  static Future<List<Map<String, dynamic>>> getDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    var raw = prefs.getString(_docsKey);
    if ((raw == null || raw.isEmpty) && _docsKey != _docsKeyPrefix) {
      raw = prefs.getString(_docsKeyPrefix);
      if (raw != null && raw.isNotEmpty) {
        await prefs.setString(_docsKey, raw);
      }
    }
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final documents = decoded
        .whereType<Map>()
        .map((item) => _normalizeDocument(Map<String, dynamic>.from(item)))
        .toList();
    documents.sort(_compareByCreatedAtDesc);
    return documents;
  }

  static Future<void> deleteDocument(String docId, [String? storedPath]) async {
    final documents = await getDocuments();
    Map<String, dynamic>? deletedDocument;
    documents.removeWhere((doc) {
      final matches = doc['id'] == docId;
      if (matches) {
        deletedDocument = doc;
      }
      return matches;
    });
    await _saveDocuments(documents);

    final filePath = (storedPath != null && storedPath.isNotEmpty)
        ? storedPath
        : (deletedDocument?['localPath'] ?? deletedDocument?['imagePath'] ?? '')
            .toString();
    if (filePath.isEmpty) {
      return;
    }

    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<void> _saveDocuments(
      List<Map<String, dynamic>> documents) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_docsKey, jsonEncode(documents));
    if (!_documentsController.isClosed) {
      _documentsController
          .add(List<Map<String, dynamic>>.unmodifiable(documents));
    }
  }

  static Map<String, dynamic> _normalizeDocument(Map<String, dynamic> raw) {
    final localPath =
        (raw['localPath'] ?? raw['imagePath'] ?? raw['storagePath'] ?? '')
            .toString();
    final name = (raw['name'] ?? raw['title'] ?? 'Document').toString();
    return <String, dynamic>{
      'id': (raw['id'] ?? DateTime.now().microsecondsSinceEpoch.toString())
          .toString(),
      'name': name,
      'title': (raw['title'] ?? name).toString(),
      'type': (raw['type'] ?? 'Document').toString(),
      'summary': (raw['summary'] ?? '').toString(),
      'localPath': localPath,
      'imagePath': (raw['imagePath'] ?? localPath).toString(),
      'storagePath': (raw['storagePath'] ?? localPath).toString(),
      'createdAt':
          (raw['createdAt'] ?? DateTime.now().toIso8601String()).toString(),
    };
  }

  static int _compareByCreatedAtDesc(
    Map<String, dynamic> first,
    Map<String, dynamic> second,
  ) {
    final firstDate = DateTime.tryParse(first['createdAt']?.toString() ?? '');
    final secondDate = DateTime.tryParse(second['createdAt']?.toString() ?? '');
    final firstValue = firstDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    final secondValue = secondDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    return secondValue.compareTo(firstValue);
  }

  static Future<File> _copyImageToManagedFolder(File sourceFile) async {
    final rootDirectory = await getApplicationDocumentsDirectory();
    final documentsDirectory = Directory(
      '${rootDirectory.path}${Platform.pathSeparator}saved_documents',
    );
    if (!await documentsDirectory.exists()) {
      await documentsDirectory.create(recursive: true);
    }

    final extension = _fileExtension(sourceFile.path);
    final targetPath =
        '${documentsDirectory.path}${Platform.pathSeparator}doc_${DateTime.now().microsecondsSinceEpoch}$extension';
    return sourceFile.copy(targetPath);
  }

  static String _fileExtension(String path) {
    final dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return '.jpg';
    }
    return path.substring(dotIndex);
  }
}
