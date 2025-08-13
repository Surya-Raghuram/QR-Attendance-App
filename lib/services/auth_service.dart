import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
        notifyListeners();
      }
    }
  }

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        await getCurrentUser();
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? studentId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        UserModel newUser = UserModel(
          uid: result.user!.uid,
          email: email,
          name: name,
          role: role,
          studentId: studentId,
          classIds: [],
        );

        await _firestore.collection('users').doc(result.user!.uid).set(newUser.toMap());

        _currentUser = newUser;
        notifyListeners();
        return newUser;
      }
      return null;
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  Future<void> updateUserClasses(List<String> classIds) async {
    if (_currentUser != null) {
      try {
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'classIds': classIds,
        });

        _currentUser = UserModel(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          name: _currentUser!.name,
          role: _currentUser!.role,
          studentId: _currentUser!.studentId,
          classIds: classIds,
        );
        notifyListeners();
      } catch (e) {
        print('Update user classes error: $e');
        rethrow;
      }
    }
  }
}