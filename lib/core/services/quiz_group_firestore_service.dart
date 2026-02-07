import 'package:aivio/data/model/quiz_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizGroupFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createGroup({
    required String userId,
    required String name,
    int? color,
  }) async {
    try {
      final groupRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizGroups')
          .add({
            'name': name,
            'color': color ?? 0xFF6B5CE7,
            'createdAt': FieldValue.serverTimestamp(),
            'quizCount': 0,
          });

      return groupRef.id;
    } catch (e) {
      throw Exception('Failed to create quiz group: $e');
    }
  }

  Stream<List<QuizGroup>> getUserQuizGroups(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('quizGroups')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => QuizGroup.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> updateGroupName({
    required String userId,
    required String groupId,
    required String newName,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizGroups')
          .doc(groupId)
          .update({'name': newName});
    } catch (e) {
      throw Exception('Failed to update quiz group name: $e');
    }
  }

  Future<void> deleteGroup({
    required String userId,
    required String groupId,
  }) async {
    try {
      final quizzesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizzes')
          .where('groupId', isEqualTo: groupId)
          .get();

      final batch = _firestore.batch();

      for (var doc in quizzesSnapshot.docs) {
        batch.update(doc.reference, {'groupId': null});
      }

      batch.delete(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('quizGroups')
            .doc(groupId),
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete quiz group: $e');
    }
  }

  Future<void> updateQuizCount({
    required String userId,
    required String groupId,
  }) async {
    try {
      final quizCount = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizzes')
          .where('groupId', isEqualTo: groupId)
          .count()
          .get();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizGroups')
          .doc(groupId)
          .update({'quizCount': quizCount.count});
    } catch (e) {
      throw Exception('Failed to update quiz count: $e');
    }
  }

  Future<QuizGroup> getGroup({
    required String userId,
    required String groupId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizGroups')
          .doc(groupId)
          .get();

      if (!doc.exists) {
        throw Exception('Quiz group not found');
      }

      return QuizGroup.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get quiz group: $e');
    }
  }
}
