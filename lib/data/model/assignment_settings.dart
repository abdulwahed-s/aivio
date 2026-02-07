enum AssignmentHelpType {
  learningHints(
    'Learning Hints',
    'Get hints and search topics to guide self-learning',
  ),
  directSolution('Direct Solution', 'Get the complete solution directly'),
  stepByStep(
    'Step-by-Step',
    'Full solution with detailed explanations for learning',
  );

  const AssignmentHelpType(this.label, this.description);
  final String label;
  final String description;
}

enum AssignmentDetailLevel {
  brief('Brief', 'Concise answers with essential information'),
  detailed('Detailed', 'Comprehensive answers with explanations'),
  comprehensive('Comprehensive', 'In-depth coverage with examples and context');

  const AssignmentDetailLevel(this.label, this.description);
  final String label;
  final String description;
}

class AssignmentSettings {
  final AssignmentHelpType helpType;
  final AssignmentDetailLevel detailLevel;
  final String? userNotes;

  const AssignmentSettings({
    this.helpType = AssignmentHelpType.stepByStep,
    this.detailLevel = AssignmentDetailLevel.detailed,
    this.userNotes,
  });

  AssignmentSettings copyWith({
    AssignmentHelpType? helpType,
    AssignmentDetailLevel? detailLevel,
    String? userNotes,
  }) {
    return AssignmentSettings(
      helpType: helpType ?? this.helpType,
      detailLevel: detailLevel ?? this.detailLevel,
      userNotes: userNotes ?? this.userNotes,
    );
  }
}
