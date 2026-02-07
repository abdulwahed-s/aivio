import 'package:aivio/data/model/saved_summary.dart';
import 'package:aivio/data/model/conversation_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SummaryFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> saveSummary({
    required String userId,
    required String title,
    required String content,
    String? extractedText,
    Map<String, dynamic>? settings,
  }) async {
    try {
      final summaryRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('summaries')
          .add({
            'title': title,
            'content': content,
            'createdAt': FieldValue.serverTimestamp(),
            'timesViewed': 0,
            'extractedText': extractedText,
            'settings': settings,
            'conversations': [],
          });

      return summaryRef.id;
    } catch (e) {
      throw Exception('Failed to save summary: $e');
    }
  }

  Stream<List<SavedSummary>> getUserSummaries(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('summaries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SavedSummary.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> incrementViewCount({
    required String userId,
    required String summaryId,
  }) async {
    try {
      final summaryRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('summaries')
          .doc(summaryId);

      final summaryDoc = await summaryRef.get();
      final timesViewed = (summaryDoc.data()?['timesViewed'] as int?) ?? 0;

      await summaryRef.update({
        'timesViewed': timesViewed + 1,
        'lastViewedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update view count: $e');
    }
  }

  Future<void> updateSummaryTitle({
    required String userId,
    required String summaryId,
    required String newTitle,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('summaries')
          .doc(summaryId)
          .update({'title': newTitle});
    } catch (e) {
      throw Exception('Failed to update summary title: $e');
    }
  }

  Future<void> deleteSummary({
    required String userId,
    required String summaryId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('summaries')
          .doc(summaryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete summary: $e');
    }
  }

  Future<SavedSummary> getSummary({
    required String userId,
    required String summaryId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('summaries')
          .doc(summaryId)
          .get();

      if (!doc.exists) {
        throw Exception('Summary not found');
      }

      return SavedSummary.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get summary: $e');
    }
  }

  Future<void> assignSummaryToGroup({
    required String userId,
    required String summaryId,
    required String groupId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('summaries')
          .doc(summaryId)
          .update({'groupId': groupId});
    } catch (e) {
      throw Exception('Failed to assign summary to group: $e');
    }
  }

  Future<void> removeSummaryFromGroup({
    required String userId,
    required String summaryId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('summaries')
          .doc(summaryId)
          .update({'groupId': null});
    } catch (e) {
      throw Exception('Failed to remove summary from group: $e');
    }
  }

  Future<void> addConversationToSummary({
    required String userId,
    required String summaryId,
    required ConversationMessage conversation,
  }) async {
    try {
      final summaryRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('summaries')
          .doc(summaryId);

      await summaryRef.update({
        'conversations': FieldValue.arrayUnion([conversation.toMap()]),
      });
    } catch (e) {
      throw Exception('Failed to add conversation to summary: $e');
    }
  }
}
