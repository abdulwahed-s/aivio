import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SummaryGroup extends Equatable {
  final String id;
  final String name;
  final int color;
  final DateTime createdAt;
  final int summaryCount;

  const SummaryGroup({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    this.summaryCount = 0,
  });

  factory SummaryGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SummaryGroup(
      id: doc.id,
      name: data['name'] ?? 'Untitled Group',
      color: data['color'] ?? 0xFF6B5CE7,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      summaryCount: data['summaryCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'summaryCount': summaryCount,
    };
  }

  SummaryGroup copyWith({
    String? id,
    String? name,
    int? color,
    DateTime? createdAt,
    int? summaryCount,
  }) {
    return SummaryGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      summaryCount: summaryCount ?? this.summaryCount,
    );
  }

  @override
  List<Object?> get props => [id, name, color, createdAt, summaryCount];
}
