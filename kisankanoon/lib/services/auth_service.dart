import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static String? get uid => _auth.currentUser?.uid;

  /// Register with email and password, saves profile to Firestore
  static Future<String?> registerWithEmail({
    required String name,
    required String mobile,
    required String email,
    required String password,
    String country = '',
    String state = '',
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(name);
      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'mobile': mobile,
        'email': email.trim(),
        'country': country,
        'state': state,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      final msg = e.toString();
      return 'त्रुटि: ${msg.length > 100 ? msg.substring(0, 100) : msg}';
    }
  }

  /// Login with email and password
  static Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      return 'कुछ गलत हुआ। पुनः प्रयास करें।';
    }
  }

  /// Sign out
  static Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get user profile from Firestore
  static Future<Map<String, dynamic>?> getUserProfile() async {
    if (uid == null) return null;
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data();
    } catch (_) {
      return null;
    }
  }

  static String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-credential':
        return 'ईमेल या पासवर्ड गलत है।';
      case 'wrong-password':
        return 'पासवर्ड गलत है। कृपया पुनः प्रयास करें।';
      case 'email-already-in-use':
        return 'यह ईमेल पहले से पंजीकृत है।';
      case 'weak-password':
        return 'पासवर्ड कम से कम 6 अक्षर का होना चाहिए।';
      case 'invalid-email':
        return 'ईमेल पता सही नहीं है।';
      case 'network-request-failed':
        return 'इंटरनेट कनेक्शन जांचें।';
      case 'too-many-requests':
        return 'बहुत अधिक प्रयास। कुछ देर बाद कोशिश करें।';
      default:
        return 'कुछ गलत हुआ। कृपया पुनः प्रयास करें।';
    }
  }
}
