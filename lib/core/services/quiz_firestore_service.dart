import 'package:aivio/data/model/question.dart';
import 'package:aivio/data/model/quiz_settings.dart';
import 'package:aivio/data/model/saved_quiz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> saveQuiz({
    required String userId,
    required String title,
    required List<Question> questions,
    QuizDifficulty? difficulty,
  }) async {
    try {
      final quizRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizzes')
          .add({
            'title': title,
            'questions': questions.map((q) => q.toJson()).toList(),
            'createdAt': FieldValue.serverTimestamp(),
            'bestScore': null,
            'timesCompleted': 0,
            'difficulty': difficulty?.name,
          });

      return quizRef.id;
    } catch (e) {
      throw Exception('Failed to save quiz: $e');
    }
  }

  Stream<List<SavedQuiz>> getUserQuizzes(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => SavedQuiz.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> updateQuizScore({
    required String userId,
    required String quizId,
    required int score,
  }) async {
    try {
      final quizRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('quizzes')
          .doc(quizId);

      final quizDoc = await quizRef.get();
      final currentBestScore = quizDoc.data()?['bestScore'] as int?;
      final timesCompleted = (quizDoc.data()?['timesCompleted'] as int?) ?? 0;

      await quizRef.update({
        'bestScore': currentBestScore == null || score > currentBestScore
            ? score
            : currentBestScore,
        'timesCompleted': timesCompleted + 1,
        'lastCompletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update quiz score: $e');
    }
  }

  Future<void> updateQuizTitle({
    required String userId,
    required String quizId,
    required String newTitle,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizzes')
          .doc(quizId)
          .update({'title': newTitle});
    } catch (e) {
      throw Exception('Failed to update quiz title: $e');
    }
  }

  Future<void> deleteQuiz({
    required String userId,
    required String quizId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizzes')
          .doc(quizId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete quiz: $e');
    }
  }

  Future<SavedQuiz> getQuiz({
    required String userId,
    required String quizId,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizzes')
          .doc(quizId)
          .get();

      if (!doc.exists) {
        throw Exception('Quiz not found');
      }

      return SavedQuiz.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get quiz: $e');
    }
  }

  Future<void> assignQuizToGroup({
    required String userId,
    required String quizId,
    required String groupId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizzes')
          .doc(quizId)
          .update({'groupId': groupId});
    } catch (e) {
      throw Exception('Failed to assign quiz to group: $e');
    }
  }

  Future<void> removeQuizFromGroup({
    required String userId,
    required String quizId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quizzes')
          .doc(quizId)
          .update({'groupId': null});
    } catch (e) {
      throw Exception('Failed to remove quiz from group: $e');
    }
  }
}
