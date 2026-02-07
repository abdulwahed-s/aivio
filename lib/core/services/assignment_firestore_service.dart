import 'package:aivio/data/model/saved_assignment.dart';
import 'package:aivio/data/model/conversation_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> saveAssignment({
    required String userId,
    required String title,
    required String content,
    String? groupId,
    String? extractedText,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final assignmentData = {
        'title': title,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'timesViewed': 0,
        'groupId': groupId,
        'extractedText': extractedText,
        'settings': settings,
      };

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('assignments')
          .add(assignmentData);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save assignment: $e');
    }
  }

  Stream<List<SavedAssignment>> getUserAssignments(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('assignments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SavedAssignment.fromFirestore(doc))
              .toList();
        });
  }

  Future<SavedAssignment?> getAssignment({
    required String userId,
    required String assignmentId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('assignments')
          .doc(assignmentId)
          .get();

      if (doc.exists) {
        return SavedAssignment.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get assignment: $e');
    }
  }

  Future<void> deleteAssignment({
    required String userId,
    required String assignmentId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('assignments')
          .doc(assignmentId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete assignment: $e');
    }
  }

  Future<void> updateAssignmentTitle({
    required String userId,
    required String assignmentId,
    required String newTitle,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('assignments')
          .doc(assignmentId)
          .update({'title': newTitle});
    } catch (e) {
      throw Exception('Failed to update assignment title: $e');
    }
  }

  Future<void> incrementViewCount({
    required String userId,
    required String assignmentId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('assignments')
          .doc(assignmentId)
          .update({'timesViewed': FieldValue.increment(1)});
    } catch (e) {
      throw Exception('Failed to increment view count: $e');
    }
  }

  Future<void> updateAssignmentGroup({
    required String userId,
    required String assignmentId,
    String? groupId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('assignments')
          .doc(assignmentId)
          .update({'groupId': groupId});
    } catch (e) {
      throw Exception('Failed to update assignment group: $e');
    }
  }

  Future<void> addConversationToAssignment({
    required String userId,
    required String assignmentId,
    required ConversationMessage conversation,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('assignments')
          .doc(assignmentId)
          .update({
            'conversations': FieldValue.arrayUnion([conversation.toMap()]),
          });
    } catch (e) {
      throw Exception('Failed to add conversation: $e');
    }
  }
}
