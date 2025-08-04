import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = true;

  User? get currentUser => _user;
  UserModel? get currentUserModel => _userModel;
  bool get isLoading => _isLoading;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (user != null) {
      await _loadUserModel();
    } else {
      _userModel = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserModel() async {
    if (_user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }

  // ✅ Single working method
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    required GeoPoint location,
    required String address,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final userModel = UserModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        location: location,
        address: address,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(userModel.toFirestore());

      await credential.user!.updateDisplayName(name);
      await _onAuthStateChanged(credential.user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _onAuthStateChanged(credential.user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    GeoPoint? location,
    String? address,
  }) async {
    if (_user == null || _userModel == null) return;

    try {
      final updatedUser = _userModel!.copyWith(
        name: name,
        phone: phone,
        location: location,
        address: address,
      );

      await _firestore.collection('users').doc(_user!.uid).update(updatedUser.toFirestore());

      if (name != null) {
        await _user!.updateDisplayName(name);
      }

      _userModel = updatedUser;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
