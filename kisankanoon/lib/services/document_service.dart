import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentService {
  static const _docsKeyPrefix = 'kk_docs';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final StreamController<List<Map<String, dynamic>>>
      _documentsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  static String get _docsKey {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid == null ? _docsKeyPrefix : '${_docsKeyPrefix}_$uid';
  }

  static CollectionReference<Map<String, dynamic>> _documentsCollection(
    String uid,
  ) {
    return _firestore.collection('users').doc(uid).collection('documents');
  }

  static Future<Map<String, dynamic>?> uploadDocument({
    required File imageFile,
    required String docName,
    required String docType,
    String summary = '',
    String documentNumber = '',
    String notes = '',
  }) async {
    try {
      final savedImage = await _copyImageToManagedFolder(imageFile);
      final createdAt = DateTime.now();
      final documentId = createdAt.microsecondsSinceEpoch.toString();
      final currentUser = FirebaseAuth.instance.currentUser;

      Map<String, dynamic> document = _normalizeDocument(<String, dynamic>{
        'id': documentId,
        'name': docName.trim().isEmpty ? 'Document' : docName.trim(),
        'title': docName.trim().isEmpty ? 'Document' : docName.trim(),
        'type': docType.trim().isEmpty ? 'General Document' : docType.trim(),
        'summary': summary.trim(),
        'documentNumber': documentNumber.trim(),
        'notes': notes.trim(),
        'localPath': savedImage.path,
        'imagePath': savedImage.path,
        'storagePath': '',
        'downloadUrl': '',
        'ownerId': currentUser?.uid ?? '',
        'createdAt': createdAt.toIso8601String(),
        'syncedToFirebase': false,
        'syncError': currentUser == null
            ? 'Please log in to sync this document with Firebase.'
            : '',
      });

      if (currentUser != null) {
        document = await _syncDocumentToFirebase(
          uid: currentUser.uid,
          sourceFile: savedImage,
          localDocument: document,
        );
      }

      final documents = await _loadLocalDocuments();
      documents.removeWhere(
        (existingDocument) =>
            existingDocument['id'].toString() == document['id'].toString(),
      );
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
    final localDocuments = await _loadLocalDocuments();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      localDocuments.sort(_compareByCreatedAtDesc);
      return localDocuments;
    }

    final syncedLocalDocuments = await _syncPendingDocuments(
      uid,
      localDocuments,
    );

    try {
      final snapshot = await _documentsCollection(uid)
          .orderBy('createdAt', descending: true)
          .get();

      final remoteDocuments = snapshot.docs
          .map(
            (doc) => _fromFirestore(
              documentId: doc.id,
              raw: doc.data(),
              localDocuments: syncedLocalDocuments,
            ),
          )
          .toList();

      final unsyncedDocuments = syncedLocalDocuments
          .where((document) => document['syncedToFirebase'] != true)
          .toList();

      final mergedDocuments = _mergeDocuments(
        remoteDocuments,
        unsyncedDocuments,
      );
      await _saveDocuments(mergedDocuments);
      return mergedDocuments;
    } catch (_) {
      syncedLocalDocuments.sort(_compareByCreatedAtDesc);
      return syncedLocalDocuments;
    }
  }

  static Future<bool> deleteDocument(String docId, [String? storedPath]) async {
    final documents = await _loadLocalDocuments();
    Map<String, dynamic>? deletedDocument;
    for (final document in documents) {
      if (document['id'].toString() == docId) {
        deletedDocument = document;
        break;
      }
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && deletedDocument != null) {
      final isSynced = deletedDocument['syncedToFirebase'] == true;
      if (isSynced) {
        try {
          final cloudPath = (deletedDocument['storagePath'] ?? '').toString();
          final downloadUrl = (deletedDocument['downloadUrl'] ?? '').toString();
          if (cloudPath.startsWith('users/')) {
            await _storage.ref().child(cloudPath).delete();
          } else if (downloadUrl.isNotEmpty) {
            await _storage.refFromURL(downloadUrl).delete();
          }
        } on FirebaseException catch (error) {
          if (error.code != 'object-not-found') {
            return false;
          }
        } catch (_) {
          return false;
        }

        try {
          await _documentsCollection(currentUser.uid).doc(docId).delete();
        } catch (_) {
          return false;
        }
      }
    }

    documents.removeWhere((document) => document['id'].toString() == docId);
    await _saveDocuments(documents);

    final filePath = (storedPath != null && storedPath.isNotEmpty)
        ? storedPath
        : (deletedDocument?['localPath'] ?? deletedDocument?['imagePath'] ?? '')
            .toString();
    if (filePath.isEmpty) {
      return true;
    }

    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    return true;
  }

  static Future<Map<String, dynamic>> _syncDocumentToFirebase({
    required String uid,
    required File sourceFile,
    required Map<String, dynamic> localDocument,
  }) async {
    final normalizedDocument = _normalizeDocument(<String, dynamic>{
      ...localDocument,
      'ownerId': uid,
    });

    try {
      final documentId = normalizedDocument['id'].toString();
      final extension = _fileExtension(sourceFile.path);
      final cloudPath = 'users/$uid/documents/$documentId$extension';

      await _storage.ref().child(cloudPath).putFile(
            sourceFile,
            SettableMetadata(
              contentType: _contentTypeForExtension(extension),
            ),
          );
      final downloadUrl = await _storage.ref().child(cloudPath).getDownloadURL();

      await _documentsCollection(uid).doc(documentId).set(
        <String, dynamic>{
          'id': documentId,
          'ownerId': uid,
          'name': normalizedDocument['name'],
          'title': normalizedDocument['title'],
          'type': normalizedDocument['type'],
          'summary': normalizedDocument['summary'],
          'documentNumber': normalizedDocument['documentNumber'],
          'notes': normalizedDocument['notes'],
          'storagePath': cloudPath,
          'downloadUrl': downloadUrl,
          'createdAt': Timestamp.fromDate(
            _parseCreatedAt(normalizedDocument['createdAt']) ?? DateTime.now(),
          ),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return _normalizeDocument(<String, dynamic>{
        ...normalizedDocument,
        'ownerId': uid,
        'storagePath': cloudPath,
        'downloadUrl': downloadUrl,
        'syncedToFirebase': true,
        'syncError': '',
      });
    } on FirebaseException catch (error) {
      return _normalizeDocument(<String, dynamic>{
        ...normalizedDocument,
        'ownerId': uid,
        'syncedToFirebase': false,
        'syncError': _firebaseErrorMessage(error),
      });
    } catch (error) {
      return _normalizeDocument(<String, dynamic>{
        ...normalizedDocument,
        'ownerId': uid,
        'syncedToFirebase': false,
        'syncError': error.toString(),
      });
    }
  }

  static Future<List<Map<String, dynamic>>> _syncPendingDocuments(
    String uid,
    List<Map<String, dynamic>> localDocuments,
  ) async {
    if (localDocuments.isEmpty) {
      return localDocuments;
    }

    var changed = false;
    final syncedDocuments = <Map<String, dynamic>>[];

    for (final document in localDocuments) {
      final ownerId = (document['ownerId'] ?? '').toString();
      final alreadySynced =
          document['syncedToFirebase'] == true && ownerId == uid;
      if (alreadySynced) {
        syncedDocuments.add(_normalizeDocument(document));
        continue;
      }

      final localPath = (document['localPath'] ?? document['imagePath'] ?? '')
          .toString();
      if (localPath.isEmpty) {
        syncedDocuments.add(
          _normalizeDocument(<String, dynamic>{
            ...document,
            'ownerId': uid,
            'syncedToFirebase': false,
            'syncError': 'Local file path is missing.',
          }),
        );
        continue;
      }

      final localFile = File(localPath);
      if (!await localFile.exists()) {
        syncedDocuments.add(
          _normalizeDocument(<String, dynamic>{
            ...document,
            'ownerId': uid,
            'syncedToFirebase': false,
            'syncError': 'Local file could not be found on this device.',
          }),
        );
        continue;
      }

      final syncedDocument = await _syncDocumentToFirebase(
        uid: uid,
        sourceFile: localFile,
        localDocument: document,
      );
      if (_documentChanged(document, syncedDocument)) {
        changed = true;
      }
      syncedDocuments.add(syncedDocument);
    }

    if (changed) {
      await _saveDocuments(syncedDocuments);
    }
    return syncedDocuments;
  }

  static Future<List<Map<String, dynamic>>> _loadLocalDocuments() async {
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

  static Future<void> _saveDocuments(
    List<Map<String, dynamic>> documents,
  ) async {
    documents.sort(_compareByCreatedAtDesc);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_docsKey, jsonEncode(documents));
    if (!_documentsController.isClosed) {
      _documentsController.add(
        List<Map<String, dynamic>>.unmodifiable(documents),
      );
    }
  }

  static Map<String, dynamic> _fromFirestore({
    required String documentId,
    required Map<String, dynamic> raw,
    required List<Map<String, dynamic>> localDocuments,
  }) {
    Map<String, dynamic>? cachedDocument;
    for (final localDocument in localDocuments) {
      if (localDocument['id'].toString() == documentId) {
        cachedDocument = localDocument;
        break;
      }
    }

    return _normalizeDocument(<String, dynamic>{
      'id': documentId,
      'name': raw['name'],
      'title': raw['title'] ?? raw['name'],
      'type': raw['type'],
      'summary': raw['summary'],
      'documentNumber': raw['documentNumber'],
      'notes': raw['notes'],
      'localPath': cachedDocument?['localPath'] ?? '',
      'imagePath':
          cachedDocument?['imagePath'] ?? cachedDocument?['localPath'] ?? '',
      'storagePath': raw['storagePath'],
      'downloadUrl': raw['downloadUrl'],
      'ownerId':
          (raw['ownerId'] ?? FirebaseAuth.instance.currentUser?.uid ?? '')
              .toString(),
      'createdAt': _timestampToIsoString(raw['createdAt']),
      'syncedToFirebase': true,
      'syncError': '',
    });
  }

  static List<Map<String, dynamic>> _mergeDocuments(
    List<Map<String, dynamic>> primaryDocuments,
    List<Map<String, dynamic>> secondaryDocuments,
  ) {
    final mergedById = <String, Map<String, dynamic>>{};

    for (final document in primaryDocuments) {
      final normalized = _normalizeDocument(document);
      mergedById[normalized['id'].toString()] = normalized;
    }

    for (final document in secondaryDocuments) {
      final normalized = _normalizeDocument(document);
      final documentId = normalized['id'].toString();
      final existing = mergedById[documentId];
      if (existing == null) {
        mergedById[documentId] = normalized;
        continue;
      }

      mergedById[documentId] = _normalizeDocument(<String, dynamic>{
        ...existing,
        if ((existing['localPath'] ?? '').toString().isEmpty &&
            (normalized['localPath'] ?? '').toString().isNotEmpty)
          'localPath': normalized['localPath'],
        if ((existing['imagePath'] ?? '').toString().isEmpty &&
            (normalized['imagePath'] ?? '').toString().isNotEmpty)
          'imagePath': normalized['imagePath'],
        if ((existing['downloadUrl'] ?? '').toString().isEmpty &&
            (normalized['downloadUrl'] ?? '').toString().isNotEmpty)
          'downloadUrl': normalized['downloadUrl'],
        if ((existing['notes'] ?? '').toString().isEmpty &&
            (normalized['notes'] ?? '').toString().isNotEmpty)
          'notes': normalized['notes'],
      });
    }

    final mergedDocuments = mergedById.values.toList();
    mergedDocuments.sort(_compareByCreatedAtDesc);
    return mergedDocuments;
  }

  static Map<String, dynamic> _normalizeDocument(Map<String, dynamic> raw) {
    final localPath =
        (raw['localPath'] ?? raw['imagePath'] ?? raw['storagePath'] ?? '')
            .toString();
    final name = (raw['name'] ?? raw['title'] ?? 'Document').toString();
    final createdAt = _timestampToIsoString(raw['createdAt']);

    return <String, dynamic>{
      'id': (raw['id'] ?? DateTime.now().microsecondsSinceEpoch.toString())
          .toString(),
      'name': name,
      'title': (raw['title'] ?? name).toString(),
      'type': (raw['type'] ?? 'General Document').toString(),
      'summary': (raw['summary'] ?? '').toString(),
      'documentNumber': (raw['documentNumber'] ?? '').toString(),
      'notes': (raw['notes'] ?? '').toString(),
      'localPath': localPath,
      'imagePath': (raw['imagePath'] ?? localPath).toString(),
      'storagePath': (raw['storagePath'] ?? '').toString(),
      'downloadUrl': (raw['downloadUrl'] ?? '').toString(),
      'ownerId': (raw['ownerId'] ?? '').toString(),
      'createdAt': createdAt,
      'syncedToFirebase': raw['syncedToFirebase'] == true,
      'syncError': (raw['syncError'] ?? '').toString(),
    };
  }

  static int _compareByCreatedAtDesc(
    Map<String, dynamic> first,
    Map<String, dynamic> second,
  ) {
    final firstDate = _parseCreatedAt(first['createdAt']);
    final secondDate = _parseCreatedAt(second['createdAt']);
    final firstValue = firstDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    final secondValue = secondDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    return secondValue.compareTo(firstValue);
  }

  static DateTime? _parseCreatedAt(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.tryParse(value?.toString() ?? '');
  }

  static String _timestampToIsoString(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }

    final raw = value?.toString() ?? '';
    if (raw.isEmpty) {
      return DateTime.now().toIso8601String();
    }
    return raw;
  }

  static bool _documentChanged(
    Map<String, dynamic> previous,
    Map<String, dynamic> current,
  ) {
    return jsonEncode(_normalizeDocument(previous)) !=
        jsonEncode(_normalizeDocument(current));
  }

  static String _firebaseErrorMessage(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Firebase denied this upload. Check Firestore/Storage rules for signed-in users.';
      case 'unauthenticated':
        return 'Please log in again before saving this document to Firebase.';
      case 'object-not-found':
        return 'The document file could not be found in Firebase Storage.';
      default:
        return error.message ?? error.code;
    }
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
    return path.substring(dotIndex).toLowerCase();
  }

  static String _contentTypeForExtension(String extension) {
    switch (extension) {
      case '.png':
        return 'image/png';
      case '.pdf':
        return 'application/pdf';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
