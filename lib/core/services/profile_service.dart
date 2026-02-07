import 'dart:typed_data';
import 'package:aivio/data/model/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<UserProfile> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['profile'] != null && data['profile'] is Map) {
          return UserProfile.fromMap(uid, data['profile']);
        }
        return UserProfile.fromMap(uid, data);
      } else {
        return UserProfile(uid: uid, email: '', username: 'User');
      }
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<void> updateUsername(String uid, String newUsername) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'profile.username': newUsername,
      });
    } catch (e) {
      throw Exception('Failed to update username: $e');
    }
  }

  Future<String> uploadProfileImage(
    String uid,
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final ref = _storage.ref().child('users/$uid/profile_image.jpg');

      await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final downloadUrl = await ref.getDownloadURL();

      await _firestore.collection('users').doc(uid).update({
        'profile.photoUrl': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
}
