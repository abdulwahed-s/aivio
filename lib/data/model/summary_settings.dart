enum SummaryLength {
  brief('Brief', 'Concise summary with key points'),
  detailed('Detailed', 'Comprehensive summary with explanations'),
  comprehensive('Comprehensive', 'In-depth summary covering all major topics');

  const SummaryLength(this.label, this.description);
  final String label;
  final String description;
}

enum SummaryFormat {
  bulletPoints('Bullet Points', 'Organized list of key points'),
  paragraphs('Paragraphs', 'Flowing narrative text'),
  keyTopics('Key Topics', 'Structured by main topics');

  const SummaryFormat(this.label, this.description);
  final String label;
  final String description;
}

class SummarySettings {
  final SummaryLength length;
  final SummaryFormat format;
  final int numberOfSections;

  const SummarySettings({
    this.length = SummaryLength.detailed,
    this.format = SummaryFormat.keyTopics,
    this.numberOfSections = 5,
  });

  SummarySettings copyWith({
    SummaryLength? length,
    SummaryFormat? format,
    int? numberOfSections,
  }) {
    return SummarySettings(
      length: length ?? this.length,
      format: format ?? this.format,
      numberOfSections: numberOfSections ?? this.numberOfSections,
    );
  }
}
