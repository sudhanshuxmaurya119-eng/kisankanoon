import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentService {
  static final _db = FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Save scanned document (image stays local, metadata goes to Firestore)
  static Future<Map<String, dynamic>?> uploadDocument({
    required File imageFile,
    required String docName,
    required String docType,
  }) async {
    if (_uid == null) return null;
    try {
      // Save image path locally (file stays on device)
      final localPath = imageFile.path;

      final docData = {
        'name': docName,
        'type': docType,
        'localPath': localPath,   // local file path
        'imageUrl': '',           // no cloud storage
        'storagePath': '',
        'createdAt': FieldValue.serverTimestamp(),
        'uid': _uid,
      };

      final docRef = await _db
          .collection('users')
          .doc(_uid)
          .collection('documents')
          .add(docData);

      return {'id': docRef.id, ...docData};
    } catch (e) {
      return null;
    }
  }

  /// Real-time stream of documents from Firestore
  static Stream<List<Map<String, dynamic>>> getDocumentsStream() {
    if (_uid == null) return Stream.value([]);
    return _db
        .collection('users')
        .doc(_uid)
        .collection('documents')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList());
  }

  /// Get all documents once
  static Future<List<Map<String, dynamic>>> getDocuments() async {
    if (_uid == null) return [];
    try {
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('documents')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (_) {
      return [];
    }
  }

  /// Delete document metadata from Firestore (local file stays)
  static Future<void> deleteDocument(String docId, [String? unused]) async {
    if (_uid == null) return;
    try {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('documents')
          .doc(docId)
          .delete();
    } catch (_) {}
  }
}
