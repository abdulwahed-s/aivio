import 'package:aivio/data/model/assignment_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentGroupFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createAssignmentGroup({
    required String userId,
    required String groupName,
    int color = 0xFFFF9800,
  }) async {
    try {
      final groupData = {
        'name': groupName,
        'color': color,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': userId,
      };

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('assignmentGroups')
          .add(groupData);

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create assignment group: $e');
    }
  }

  Stream<List<AssignmentGroup>> getUserAssignmentGroups(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('assignmentGroups')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AssignmentGroup.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> deleteAssignmentGroup({
    required String userId,
    required String groupId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('assignmentGroups')
          .doc(groupId)
          .delete();

      final assignmentsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('assignments')
          .where('groupId', isEqualTo: groupId)
          .get();

      final batch = _firestore.batch();
      for (var doc in assignmentsSnapshot.docs) {
        batch.update(doc.reference, {'groupId': null});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete assignment group: $e');
    }
  }

  Future<void> renameAssignmentGroup({
    required String userId,
    required String groupId,
    required String newName,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('assignmentGroups')
          .doc(groupId)
          .update({'name': newName});
    } catch (e) {
      throw Exception('Failed to rename assignment group: $e');
    }
  }
}
