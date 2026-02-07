import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AssignmentGroup extends Equatable {
  final String id;
  final String name;
  final int color;
  final DateTime createdAt;
  final String userId;

  const AssignmentGroup({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.userId,
  });

  factory AssignmentGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssignmentGroup(
      id: doc.id,
      name: data['name'] ?? 'Untitled Group',
      color: data['color'] ?? 0xFFFF9800,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'color': color,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  AssignmentGroup copyWith({
    String? id,
    String? name,
    int? color,
    DateTime? createdAt,
    String? userId,
  }) {
    return AssignmentGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  @override
  List<Object?> get props => [id, name, color, createdAt, userId];
}
