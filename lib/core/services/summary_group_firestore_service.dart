import 'package:aivio/data/model/summary_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SummaryGroupFirestoreService {
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
          .collection('summaryGroups')
          .add({
            'name': name,
            'color': color ?? 0xFF6B5CE7,
            'createdAt': FieldValue.serverTimestamp(),
            'summaryCount': 0,
          });

      return groupRef.id;
    } catch (e) {
      throw Exception('Failed to create summary group: $e');
    }
  }

  Stream<List<SummaryGroup>> getUserSummaryGroups(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('summaryGroups')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SummaryGroup.fromFirestore(doc))
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
          .collection('summaryGroups')
          .doc(groupId)
          .update({'name': newName});
    } catch (e) {
      throw Exception('Failed to update summary group name: $e');
    }
  }

  Future<void> deleteGroup({
    required String userId,
    required String groupId,
  }) async {
    try {
      final summariesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('summaries')
          .where('groupId', isEqualTo: groupId)
          .get();

      final batch = _firestore.batch();

      for (var doc in summariesSnapshot.docs) {
        batch.update(doc.reference, {'groupId': null});
      }

      batch.delete(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('summaryGroups')
            .doc(groupId),
      );

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete summary group: $e');
    }
  }

  Future<void> updateSummaryCount({
    required String userId,
    required String groupId,
  }) async {
    try {
      final summaryCount = await _firestore
          .collection('users')
          .doc(userId)
          .collection('summaries')
          .where('groupId', isEqualTo: groupId)
          .count()
          .get();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('summaryGroups')
          .doc(groupId)
          .update({'summaryCount': summaryCount.count});
    } catch (e) {
      throw Exception('Failed to update summary count: $e');
    }
  }

  Future<SummaryGroup> getGroup({
    required String userId,
    required String groupId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('summaryGroups')
          .doc(groupId)
          .get();

      if (!doc.exists) {
        throw Exception('Summary group not found');
      }

      return SummaryGroup.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get summary group: $e');
    }
  }
}
