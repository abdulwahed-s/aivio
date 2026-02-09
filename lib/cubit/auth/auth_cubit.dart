import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import 'package:flutter/foundation.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthCubit({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(AuthInitial()) {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      emit(AuthLoading());
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (displayName != null && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }

      if (userCredential.user != null) {
        await _createUserProfile(
          userId: userCredential.user!.uid,
          email: email,
          displayName: displayName,
        );
      }

      final user = _auth.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(user));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    } catch (e) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  Future<void> _createUserProfile({
    required String userId,
    required String email,
    String? displayName,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'profile': {
          'username': displayName ?? '',
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'photoUrl': null,
        },
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user profile: $e');
      }
      throw Exception('Failed to create user profile');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      return null;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = _auth.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(user));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    } catch (e) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      emit(AuthLoading());
      await _auth.sendPasswordResetEmail(email: email);
      emit(PasswordResetSent(email));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_getErrorMessage(e)));
    } catch (e) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to sign out. Please try again.'));
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return e.message ?? 'An error occurred. Please try again.';
    }
  }
}
