import 'package:aivio/core/constant/color.dart';
import 'package:aivio/data/model/quiz_settings.dart';
import 'package:aivio/data/model/summary_settings.dart';
import 'package:aivio/data/model/assignment_settings.dart';
import 'package:flutter/material.dart';

enum GenerationType { quiz, summary, assignment }

class GenerationResult {
  final GenerationType type;
  final QuizSettings? quizSettings;
  final SummarySettings? summarySettings;
  final AssignmentSettings? assignmentSettings;

  const GenerationResult.quiz(this.quizSettings)
    : type = GenerationType.quiz,
      summarySettings = null,
      assignmentSettings = null;

  const GenerationResult.summary(this.summarySettings)
    : type = GenerationType.summary,
      quizSettings = null,
      assignmentSettings = null;

  const GenerationResult.assignment(this.assignmentSettings)
    : type = GenerationType.assignment,
      quizSettings = null,
      summarySettings = null;
}

class QuizSettingsDialog extends StatefulWidget {
  final GenerationType? initialType;

  const QuizSettingsDialog({super.key, this.initialType});

  @override
  State<QuizSettingsDialog> createState() => _QuizSettingsDialogState();
}

class _QuizSettingsDialogState extends State<QuizSettingsDialog> {
  late GenerationType _selectedGenerationType;

  QuizDifficulty _selectedDifficulty = QuizDifficulty.medium;
  QuestionTypeOption _selectedQuestionType = QuestionTypeOption.mcq;
  int _numberOfQuestions = 10;

  SummaryLength _selectedLength = SummaryLength.detailed;
  SummaryFormat _selectedFormat = SummaryFormat.keyTopics;
  int _numberOfSections = 5;

  AssignmentHelpType _selectedHelpType = AssignmentHelpType.stepByStep;
  AssignmentDetailLevel _selectedDetailLevel = AssignmentDetailLevel.detailed;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedGenerationType = widget.initialType ?? GenerationType.quiz;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Appcolor.primaryColor,
                      Appcolor.primaryColor.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _selectedGenerationType == GenerationType.quiz
                            ? Icons.quiz
                            : _selectedGenerationType == GenerationType.summary
                            ? Icons.summarize
                            : Icons.assignment,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedGenerationType == GenerationType.quiz
                                ? 'Quiz Settings'
                                : _selectedGenerationType ==
                                      GenerationType.summary
                                ? 'Summary Settings'
                                : 'Assignment Helper Settings',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedGenerationType == GenerationType.quiz
                                ? 'Customize your quiz experience'
                                : _selectedGenerationType ==
                                      GenerationType.summary
                                ? 'Customize your summary'
                                : 'Configure assignment help',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGenerationTypeSelector(),
                    const SizedBox(height: 24),

                    if (_selectedGenerationType == GenerationType.quiz)
                      _buildQuizSettings()
                    else if (_selectedGenerationType == GenerationType.summary)
                      _buildSummarySettings()
                    else
                      _buildAssignmentSettings(),

                    const SizedBox(height: 28),

                    _buildActionButtons(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenerationTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeTab(GenerationType.quiz, Icons.quiz, 'Quiz'),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTypeTab(
              GenerationType.summary,
              Icons.summarize,
              'Summary',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTypeTab(
              GenerationType.assignment,
              Icons.assignment,
              'Assignment',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab(GenerationType type, IconData icon, String label) {
    final isSelected = _selectedGenerationType == type;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGenerationType = type;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Appcolor.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.signal_cellular_alt,
          title: 'Difficulty Level',
          subtitle: 'Choose your challenge',
        ),
        const SizedBox(height: 16),
        ...QuizDifficulty.values.map((difficulty) {
          return _buildDifficultyOption(difficulty);
        }),
        const SizedBox(height: 28),

        _buildSectionHeader(
          icon: Icons.quiz_outlined,
          title: 'Question Type',
          subtitle: 'Select your preferred format',
        ),
        const SizedBox(height: 16),
        ...QuestionTypeOption.values.map((type) {
          return _buildQuestionTypeOption(type);
        }),
        const SizedBox(height: 28),

        _buildSectionHeader(
          icon: Icons.format_list_numbered,
          title: 'Number of Questions',
          subtitle: 'Slide to adjust (5-30)',
        ),
        const SizedBox(height: 20),
        _buildQuestionCountSlider(),
      ],
    );
  }

  Widget _buildSummarySettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.straighten,
          title: 'Summary Length',
          subtitle: 'How detailed should it be?',
        ),
        const SizedBox(height: 16),
        ...SummaryLength.values.map((length) {
          return _buildSummaryLengthOption(length);
        }),
        const SizedBox(height: 28),

        _buildSectionHeader(
          icon: Icons.format_align_left,
          title: 'Summary Format',
          subtitle: 'Choose the structure',
        ),
        const SizedBox(height: 16),
        ...SummaryFormat.values.map((format) {
          return _buildSummaryFormatOption(format);
        }),
        const SizedBox(height: 28),

        _buildSectionHeader(
          icon: Icons.format_list_numbered,
          title: 'Number of Sections',
          subtitle: 'Slide to adjust (3-10)',
        ),
        const SizedBox(height: 20),
        _buildSectionCountSlider(),
      ],
    );
  }

  Widget _buildAssignmentSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.help_outline,
          title: 'Help Type',
          subtitle: 'Choose the assistance approach',
        ),
        const SizedBox(height: 16),
        ...AssignmentHelpType.values.map((helpType) {
          return _buildHelpTypeOption(helpType);
        }),
        const SizedBox(height: 28),

        _buildSectionHeader(
          icon: Icons.tune,
          title: 'Detail Level',
          subtitle: 'How comprehensive should it be?',
        ),
        const SizedBox(height: 16),
        ...AssignmentDetailLevel.values.map((detailLevel) {
          return _buildDetailLevelOption(detailLevel);
        }),
        const SizedBox(height: 28),

        _buildSectionHeader(
          icon: Icons.edit_note,
          title: 'Additional Notes (Optional)',
          subtitle: 'Add any specific instructions or context',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Appcolor.primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'E.g., "Focus on theoretical concepts" or "Show practical examples"',
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHelpTypeOption(AssignmentHelpType helpType) {
    final isSelected = _selectedHelpType == helpType;

    Color getColor() {
      switch (helpType) {
        case AssignmentHelpType.learningHints:
          return const Color(0xFF8B5CF6);
        case AssignmentHelpType.directSolution:
          return const Color(0xFFEF4444);
        case AssignmentHelpType.stepByStep:
          return Appcolor.primaryColor;
      }
    }

    IconData getIcon() {
      switch (helpType) {
        case AssignmentHelpType.learningHints:
          return Icons.lightbulb_outline;
        case AssignmentHelpType.directSolution:
          return Icons.bolt;
        case AssignmentHelpType.stepByStep:
          return Icons.stairs;
      }
    }

    final color = getColor();
    final icon = getIcon();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedHelpType = helpType;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.08)
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]!
                  : Colors.grey.shade50,
              border: Border.all(
                color: isSelected
                    ? color
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? color
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        helpType.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? color
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        helpType.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? color.withValues(alpha: 0.8)
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailLevelOption(AssignmentDetailLevel detailLevel) {
    final isSelected = _selectedDetailLevel == detailLevel;

    Color getColor() {
      switch (detailLevel) {
        case AssignmentDetailLevel.brief:
          return const Color(0xFF10B981);
        case AssignmentDetailLevel.detailed:
          return const Color(0xFFF59E0B);
        case AssignmentDetailLevel.comprehensive:
          return const Color(0xFF8B5CF6);
      }
    }

    final color = getColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedDetailLevel = detailLevel;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.08)
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]!
                  : Colors.grey.shade50,
              border: Border.all(
                color: isSelected
                    ? color
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? color
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? color : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detailLevel.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? color
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        detailLevel.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? color.withValues(alpha: 0.8)
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Appcolor.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Appcolor.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyOption(QuizDifficulty difficulty) {
    final isSelected = _selectedDifficulty == difficulty;

    Color getColor() {
      switch (difficulty) {
        case QuizDifficulty.easy:
          return const Color(0xFF10B981);
        case QuizDifficulty.medium:
          return const Color(0xFFF59E0B);
        case QuizDifficulty.hard:
          return const Color(0xFFEF4444);
      }
    }

    final color = getColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedDifficulty = difficulty;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.08)
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]!
                  : Colors.grey.shade50,
              border: Border.all(
                color: isSelected
                    ? color
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? color
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? color : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        difficulty.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? color
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        difficulty.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? color.withValues(alpha: 0.8)
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionTypeOption(QuestionTypeOption type) {
    final isSelected = _selectedQuestionType == type;

    Color getColor() {
      switch (type) {
        case QuestionTypeOption.mcq:
          return Appcolor.primaryColor;
        case QuestionTypeOption.essay:
          return const Color(0xFF8B5CF6);
        case QuestionTypeOption.mixed:
          return const Color(0xFF14B8A6);
      }
    }

    IconData getIcon() {
      switch (type) {
        case QuestionTypeOption.mcq:
          return Icons.radio_button_checked;
        case QuestionTypeOption.essay:
          return Icons.edit_note;
        case QuestionTypeOption.mixed:
          return Icons.dashboard_customize;
      }
    }

    final color = getColor();
    final icon = getIcon();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedQuestionType = type;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.08)
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]!
                  : Colors.grey.shade50,
              border: Border.all(
                color: isSelected
                    ? color
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? color
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? color
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        type.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? color.withValues(alpha: 0.8)
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCountSlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Appcolor.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Appcolor.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Appcolor.primaryColor,
                      Appcolor.primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Appcolor.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      _numberOfQuestions.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Questions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Appcolor.primaryColor,
              inactiveTrackColor: Theme.of(context).dividerColor,
              thumbColor: Colors.white,
              overlayColor: Appcolor.primaryColor.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              trackHeight: 6,
            ),
            child: Slider(
              value: _numberOfQuestions.toDouble(),
              min: 5,
              max: 30,
              divisions: 25,
              onChanged: (value) {
                setState(() {
                  _numberOfQuestions = value.round();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '30',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLengthOption(SummaryLength length) {
    final isSelected = _selectedLength == length;

    Color getColor() {
      switch (length) {
        case SummaryLength.brief:
          return const Color(0xFF10B981);
        case SummaryLength.detailed:
          return const Color(0xFFF59E0B);
        case SummaryLength.comprehensive:
          return const Color(0xFF8B5CF6);
      }
    }

    final color = getColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedLength = length;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.08)
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]!
                  : Colors.grey.shade50,
              border: Border.all(
                color: isSelected
                    ? color
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? color
                          : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                    color: isSelected ? color : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        length.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? color
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        length.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? color.withValues(alpha: 0.8)
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryFormatOption(SummaryFormat format) {
    final isSelected = _selectedFormat == format;

    Color getColor() {
      switch (format) {
        case SummaryFormat.bulletPoints:
          return Appcolor.primaryColor;
        case SummaryFormat.paragraphs:
          return const Color(0xFF8B5CF6);
        case SummaryFormat.keyTopics:
          return const Color(0xFF14B8A6);
      }
    }

    IconData getIcon() {
      switch (format) {
        case SummaryFormat.bulletPoints:
          return Icons.format_list_bulleted;
        case SummaryFormat.paragraphs:
          return Icons.subject;
        case SummaryFormat.keyTopics:
          return Icons.topic;
      }
    }

    final color = getColor();
    final icon = getIcon();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedFormat = format;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.08)
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]!
                  : Colors.grey.shade50,
              border: Border.all(
                color: isSelected
                    ? color
                    : Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? color
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade700
                        : Colors.grey.shade200,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        format.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? color
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        format.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? color.withValues(alpha: 0.8)
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white70
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCountSlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Appcolor.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Appcolor.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Appcolor.primaryColor,
                      Appcolor.primaryColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Appcolor.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      _numberOfSections.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Sections',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Appcolor.primaryColor,
              inactiveTrackColor: Theme.of(context).dividerColor,
              thumbColor: Colors.white,
              overlayColor: Appcolor.primaryColor.withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              trackHeight: 6,
            ),
            child: Slider(
              value: _numberOfSections.toDouble(),
              min: 3,
              max: 10,
              divisions: 7,
              onChanged: (value) {
                setState(() {
                  _numberOfSections = value.round();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '3',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '10',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Theme.of(context).textTheme.bodySmall?.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Theme.of(context).dividerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              if (_selectedGenerationType == GenerationType.quiz) {
                final settings = QuizSettings(
                  difficulty: _selectedDifficulty,
                  numberOfQuestions: _numberOfQuestions,
                  questionType: _selectedQuestionType,
                );
                Navigator.pop(context, GenerationResult.quiz(settings));
              } else if (_selectedGenerationType == GenerationType.summary) {
                final settings = SummarySettings(
                  length: _selectedLength,
                  format: _selectedFormat,
                  numberOfSections: _numberOfSections,
                );
                Navigator.pop(context, GenerationResult.summary(settings));
              } else {
                final settings = AssignmentSettings(
                  helpType: _selectedHelpType,
                  detailLevel: _selectedDetailLevel,
                  userNotes: _notesController.text.trim().isEmpty
                      ? null
                      : _notesController.text.trim(),
                );
                Navigator.pop(context, GenerationResult.assignment(settings));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Appcolor.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _selectedGenerationType == GenerationType.quiz
                      ? 'Start Quiz'
                      : _selectedGenerationType == GenerationType.summary
                      ? 'Generate Summary'
                      : 'Get Help',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<GenerationResult?> showQuizSettingsDialog(
  BuildContext context, {
  GenerationType? initialType,
}) {
  return showDialog<GenerationResult>(
    context: context,
    barrierDismissible: false,
    builder: (context) => QuizSettingsDialog(initialType: initialType),
  );
}
