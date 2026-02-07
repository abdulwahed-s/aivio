import 'dart:convert';

import 'package:aivio/data/model/question.dart';
import 'package:aivio/data/model/quiz_settings.dart';
import 'package:aivio/data/model/summary_settings.dart';
import 'package:aivio/data/model/assignment_settings.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService(String apiKey) {
    _model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: apiKey);
  }

  Future<List<Question>> generateQuestions(
    String pdfText, {
    int numberOfQuestions = 10,
    QuizDifficulty difficulty = QuizDifficulty.medium,
    QuestionTypeOption questionType = QuestionTypeOption.mcq,
  }) async {
    final difficultyInstructions = _getDifficultyInstructions(difficulty);
    final typeInstructions = _getTypeInstructions(
      questionType,
      numberOfQuestions,
    );

    final prompt =
        '''
Based on the following lecture material, generate exactly $numberOfQuestions questions.

Difficulty Level: ${difficulty.label}
$difficultyInstructions

Question Type: ${questionType.label}
$typeInstructions

Lecture Material:
$pdfText

${_getJsonStructureInstructions(questionType)}

Rules:
- Generate EXACTLY $numberOfQuestions questions total
- Follow the difficulty level instructions strictly
- Include clear explanations for MCQ questions
- Include sample answers for essay questions
- Make questions relevant to the material
- Return ONLY the JSON array, no other text
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text ?? '';

      String jsonText = responseText.trim();

      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      } else if (jsonText.startsWith('```')) {
        jsonText = jsonText.substring(3);
      }

      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }

      jsonText = jsonText.trim();

      final List<dynamic> jsonList = json.decode(jsonText);

      return jsonList.map((json) => Question.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to generate questions please try again');
    }
  }

  Future<String> generateSummary(
    String pdfText, {
    SummaryLength length = SummaryLength.detailed,
    SummaryFormat format = SummaryFormat.keyTopics,
    int numberOfSections = 5,
  }) async {
    final lengthInstructions = _getLengthInstructions(length);
    final formatSpecificPrompt = _getFormatSpecificPrompt(
      format,
      numberOfSections,
    );

    final prompt =
        '''
Based on the following lecture material, generate a comprehensive summary in a structured JSON format.

Summary Length: ${length.label}
$lengthInstructions

Lecture Material:
$pdfText

$formatSpecificPrompt

Rules:
- You MUST return a valid JSON object.
- Do not include markdown formatting (like ```json ... ```) in the response, just the raw JSON string.
- Be accurate and faithful to the source material.
- Highlight key concepts and important details.
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      String summary = response.text ?? '';

      summary = summary.trim();
      if (summary.startsWith('```json')) {
        summary = summary.substring(7);
      } else if (summary.startsWith('```')) {
        summary = summary.substring(3);
      }
      if (summary.endsWith('```')) {
        summary = summary.substring(0, summary.length - 3);
      }
      summary = summary.trim();

      if (summary.isEmpty) {
        throw Exception('Generated summary is empty');
      }

      try {
        json.decode(summary);
      } catch (e) {
        throw Exception('Failed to parse generated summary as JSON: $e');
      }

      return summary;
    } catch (e) {
      throw Exception('Failed to generate summary: $e');
    }
  }

  Future<String> generateAssignmentHelp(
    String assignmentText, {
    AssignmentHelpType helpType = AssignmentHelpType.stepByStep,
    AssignmentDetailLevel detailLevel = AssignmentDetailLevel.detailed,
    String? userNotes,
  }) async {
    final helpTypeInstructions = _getHelpTypeInstructions(helpType);
    final detailLevelInstructions = _getDetailLevelInstructions(detailLevel);
    final notesSection = userNotes != null && userNotes.isNotEmpty
        ? '\nUser Notes/Instructions: $userNotes\n'
        : '';

    final prompt =
        '''
Based on the following assignment or problem, provide assistance according to the specified parameters.

Help Type: ${helpType.label}
$helpTypeInstructions

Detail Level: ${detailLevel.label}
$detailLevelInstructions
$notesSection
Assignment/Problem:
$assignmentText

Return ONLY a valid JSON object with this structure:
{
  "helpType": "${helpType.name}",
  "title": "A descriptive title for the assignment",
  "content": "The main help content as a markdown-formatted string",
  "sections": [
    {
      "heading": "Section Heading",
      "content": "Section content in markdown format"
    }
  ]
}

Rules:
- You MUST return a valid JSON object
- Do not include markdown code blocks (like ```json ... ```) in the response, just the raw JSON
- Format all text using markdown (e.g., **bold**, *italic*, `code`, lists, links)
- Be clear, accurate, and helpful
- Structure the content logically with appropriate sections
- Follow the help type instructions strictly
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      String help = response.text ?? '';

      help = help.trim();
      if (help.startsWith('```json')) {
        help = help.substring(7);
      } else if (help.startsWith('```')) {
        help = help.substring(3);
      }
      if (help.endsWith('```')) {
        help = help.substring(0, help.length - 3);
      }
      help = help.trim();

      if (help.isEmpty) {
        throw Exception('Generated assignment help is empty');
      }

      try {
        json.decode(help);
      } catch (e) {
        throw Exception('Failed to parse generated help as JSON: $e');
      }

      return help;
    } catch (e) {
      throw Exception('Failed to generate assignment help: $e');
    }
  }

  Future<String> generateFollowUpResponse({
    required String question,
    required String summaryContent,
    required String extractedText,
    required SummaryLength length,
    required SummaryFormat format,
    int numberOfSections = 5,
  }) async {
    final lengthInstructions = _getLengthInstructions(length);
    final formatSpecificPrompt = _getFormatSpecificPrompt(
      format,
      numberOfSections,
    );

    final prompt =
        '''
You are an AI assistant helping a user understand their study material better. The user has already received a summary and now has a follow-up question.

ORIGINAL SUMMARY (for context):
$summaryContent

ORIGINAL SOURCE MATERIAL (for reference):
$extractedText

USER'S QUESTION:
$question

Generate a response that:
1. Answers the user's question using the same formatting style as the original summary
2. Uses the EXACT SAME format and structure as specified below
3. Maintains consistency with the summary length preference
4. References the original material when relevant
5. Provides context-aware, helpful information

Summary Format Settings:
- Length: ${length.label}
$lengthInstructions

$formatSpecificPrompt

IMPORTANT: Your response MUST follow the same JSON structure as the original summary format. This ensures visual consistency for the user.

Rules:
- You MUST return a valid JSON object matching the format specified above
- Do not include markdown code blocks (like ```json ... ```) in the response, just the raw JSON
- Be accurate and reference the source material
- Keep the response focused on answering the question
- Use the same style and tone as the original summary
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      String answer = response.text ?? '';

      answer = answer.trim();
      if (answer.startsWith('```json')) {
        answer = answer.substring(7);
      } else if (answer.startsWith('```')) {
        answer = answer.substring(3);
      }
      if (answer.endsWith('```')) {
        answer = answer.substring(0, answer.length - 3);
      }
      answer = answer.trim();

      if (answer.isEmpty) {
        throw Exception('Generated response is empty');
      }

      try {
        json.decode(answer);
      } catch (e) {
        throw Exception('Failed to parse generated response as JSON: $e');
      }

      return answer;
    } catch (e) {
      throw Exception('Failed to generate follow-up response: $e');
    }
  }

  Future<String> generateAssignmentFollowUpResponse({
    required String question,
    required String assignmentContent,
    required String extractedText,
    required AssignmentHelpType helpType,
    required AssignmentDetailLevel detailLevel,
  }) async {
    final helpTypeInstructions = _getHelpTypeInstructions(helpType);
    final detailLevelInstructions = _getDetailLevelInstructions(detailLevel);

    final prompt =
        '''
You are an AI assistant helping a user understand their assignment. The user has already received help and now has a follow-up question.

ORIGINAL ASSIGNMENT HELP (for context):
$assignmentContent

ORIGINAL ASSIGNMENT PROBLEM (for reference):
$extractedText

USER'S QUESTION:
$question

Generate a response that:
1. Answers the user's question
2. Follows the same help type and detail level as the original help
3. References the original problem when relevant
4. Provides context-aware, helpful information

Help Type: ${helpType.label}
$helpTypeInstructions

Detail Level: ${detailLevel.label}
$detailLevelInstructions

IMPORTANT: Your response MUST follow the same JSON structure as the original assignment help format. This ensures visual consistency for the user.

Return ONLY a valid JSON object with this structure:
{
  "helpType": "${helpType.name}",
  "title": "Answer to: $question",
  "content": "The answer content as a markdown-formatted string",
  "sections": []
}

Rules:
- You MUST return a valid JSON object
- Do not include markdown code blocks (like ```json ... ```) in the response, just the raw JSON
- Format all text using markdown
- Be clear, accurate, and helpful
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      String answer = response.text ?? '';

      answer = answer.trim();
      if (answer.startsWith('```json')) {
        answer = answer.substring(7);
      } else if (answer.startsWith('```')) {
        answer = answer.substring(3);
      }
      if (answer.endsWith('```')) {
        answer = answer.substring(0, answer.length - 3);
      }
      answer = answer.trim();

      if (answer.isEmpty) {
        throw Exception('Generated response is empty');
      }

      try {
        json.decode(answer);
      } catch (e) {
        throw Exception('Failed to parse generated response as JSON: $e');
      }

      return answer;
    } catch (e) {
      throw Exception('Failed to generate follow-up response: $e');
    }
  }

  String _getHelpTypeInstructions(AssignmentHelpType helpType) {
    switch (helpType) {
      case AssignmentHelpType.learningHints:
        return '''
Instructions for LEARNING HINTS:
- Provide guiding questions and hints rather than direct answers
- Suggest concepts and topics to review
- Include search terms and resources for self-learning
- Break down the problem into manageable steps without solving it
- Encourage independent discovery
- Point out key formulas, theories, or methods relevant to the problem
- Do NOT provide the complete solution
''';

      case AssignmentHelpType.directSolution:
        return '''
Instructions for DIRECT SOLUTION:
- Provide the complete, final solution directly
- Focus on the answer rather than the process
- Include necessary calculations or reasoning
- Be concise and to the point
- Clearly state the final answer
- Include brief explanations where necessary for understanding
''';

      case AssignmentHelpType.stepByStep:
        return '''
Instructions for STEP-BY-STEP:
- Provide the complete solution with detailed explanations
- Break down each step of the solution process
- Explain the reasoning behind each step
- Include all calculations, formulas, and methods used
- Help the user understand WHY each step is necessary
- Use clear, educational language
- Include examples or analogies where helpful
- Aim to teach the concept while solving the problem
''';
    }
  }

  String _getDetailLevelInstructions(AssignmentDetailLevel detailLevel) {
    switch (detailLevel) {
      case AssignmentDetailLevel.brief:
        return '''
Instructions for BRIEF detail level:
- Keep explanations concise (300-500 words total)
- Focus on essential information only
- Use short, clear sentences
''';

      case AssignmentDetailLevel.detailed:
        return '''
Instructions for DETAILED detail level:
- Provide comprehensive explanations (700-1000 words total)
- Include context and background where relevant
- Balance depth with clarity
''';

      case AssignmentDetailLevel.comprehensive:
        return '''
Instructions for COMPREHENSIVE detail level:
- Provide thorough, in-depth coverage (1200-1800 words total)
- Include examples, analogies, and additional context
- Cover edge cases and alternative approaches
- Provide extensive explanations
''';
    }
  }

  String _getFormatSpecificPrompt(SummaryFormat format, int sections) {
    switch (format) {
      case SummaryFormat.bulletPoints:
        return '''
Format Type: Bullet Points
The JSON structure must be EXACTLY as follows:
{
  "format": "bulletPoints",
  "title": "A suitable title for the summary",
  "overview": "A brief overview of the entire material (2-3 sentences)",
  "categories": [
    {
      "name": "Category Name",
      "icon": "lightbulb_outline",
      "points": ["Point 1", "Point 2", "Point 3"]
    }
  ]
}

Instructions:
- Create approximately $sections categories
- Each category should have 3-5 concise bullet points
- Use descriptive category names that group related concepts
- Icon should be a Material Design icon name (e.g., "lightbulb_outline", "check_circle", "star", "info")
- Keep points clear and actionable
- Format all text fields (overview, points) using markdown for emphasis (e.g., **bold**, *italic*, `code`)
''';

      case SummaryFormat.paragraphs:
        return '''
Format Type: Paragraphs
The JSON structure must be EXACTLY as follows:
{
  "format": "paragraphs",
  "title": "A suitable title for the summary",
  "introduction": "An engaging introduction paragraph that sets the context",
  "body": [
    {
      "heading": "Section Heading (optional)",
      "paragraph": "Full paragraph text with flowing narrative..."
    }
  ]
  "conclusion": "A concluding paragraph that summarizes key insights"
}

Instructions:
- Write in flowing narrative prose
- Create approximately $sections body paragraphs
- Some paragraphs can have optional headings for better organization
- Use transitions between paragraphs
- Introduction should hook the reader
- Conclusion should tie everything together
- Maintain a natural, readable flow
- Format all text fields (introduction, paragraph, conclusion) using markdown for emphasis (e.g., **bold**, *italic*, `code`, links, etc.)
''';

      case SummaryFormat.keyTopics:
        return '''
Format Type: Key Topics
The JSON structure must be EXACTLY as follows:
{
  "format": "keyTopics",
  "title": "A suitable title for the summary",
  "overview": "A brief overview of the entire material (2-3 sentences)",
  "topics": [
    {
      "title": "Topic Title",
      "icon": "school",
      "description": "A detailed description of this topic (2-4 sentences)",
      "key_points": ["Key point 1", "Key point 2", "Key point 3"]
    }
  ],
  "key_takeaways": ["Takeaway 1", "Takeaway 2", "Takeaway 3"]
}

Instructions:
- Identify approximately $sections key topics/themes
- Icon should be a Material Design icon name (e.g., "school", "psychology", "science", "business")
- Each topic should have a comprehensive description
- Include 2-4 key points per topic
- Add 3-5 overall key takeaways at the end
- Show relationships between topics where relevant
- Format all text fields (overview, description, key_points, key_takeaways) using markdown for emphasis (e.g., **bold**, *italic*, `code`, links)
''';
    }
  }

  String _getLengthInstructions(SummaryLength length) {
    switch (length) {
      case SummaryLength.brief:
        return '''
Instructions for BRIEF summary:
- Keep the overview and sections concise.
- Total content should be around 200-300 words.
''';

      case SummaryLength.detailed:
        return '''
Instructions for DETAILED summary:
- Aim for 500-800 words total.
- Cover main concepts with explanations in the sections.
''';

      case SummaryLength.comprehensive:
        return '''
Instructions for COMPREHENSIVE summary:
- Generate 1000-1500 words total.
- Cover all major topics thoroughly in the sections.
''';
    }
  }

  String _getJsonStructureInstructions(QuestionTypeOption questionType) {
    switch (questionType) {
      case QuestionTypeOption.mcq:
        return '''
Return ONLY a valid JSON array with this structure for MCQ questions:
[
  {
    "type": "mcq",
    "question": "The question text",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctAnswerIndex": 0,
    "explanation": "Brief explanation of the correct answer"
  }
]
Each MCQ question must have exactly 4 options, and correctAnswerIndex must be 0, 1, 2, or 3.
        ''';

      case QuestionTypeOption.essay:
        return '''
Return ONLY a valid JSON array with this structure for essay questions:
[
  {
    "type": "essay",
    "question": "The open-ended question text",
    "sampleAnswer": "A comprehensive sample answer that demonstrates the expected level of detail and understanding"
  }
]
Essay questions should encourage critical thinking and detailed responses.
        ''';

      case QuestionTypeOption.mixed:
        return '''
Return ONLY a valid JSON array with a MIX of MCQ and essay questions:
[
  {
    "type": "mcq",
    "question": "The question text",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctAnswerIndex": 0,
    "explanation": "Brief explanation"
  },
  {
    "type": "essay",
    "question": "The open-ended question",
    "sampleAnswer": "A comprehensive sample answer"
  }
]
Mix approximately 60% MCQ and 40% essay questions. Each MCQ must have exactly 4 options.
        ''';
    }
  }

  String _getTypeInstructions(
    QuestionTypeOption questionType,
    int totalQuestions,
  ) {
    switch (questionType) {
      case QuestionTypeOption.mcq:
        return '''
Generate ALL questions as Multiple Choice Questions (MCQ).
- Each question must have exactly 4 options
- One option must be clearly correct
- Other options should be plausible but incorrect
        ''';

      case QuestionTypeOption.essay:
        return '''
Generate ALL questions as Essay-type questions.
- Questions should be open-ended
- Require detailed, thoughtful responses
- Test understanding, analysis, and application
- Include comprehensive sample answers
        ''';

      case QuestionTypeOption.mixed:
        final mcqCount = (totalQuestions * 0.6).round();
        final essayCount = totalQuestions - mcqCount;
        return '''
Generate a MIX of Multiple Choice and Essay questions.
- Approximately $mcqCount MCQ questions (60%)
- Approximately $essayCount Essay questions (40%)
- Distribute question types evenly throughout
- MCQ questions have 4 options each
- Essay questions are open-ended with sample answers
        ''';
    }
  }

  String _getDifficultyInstructions(QuizDifficulty difficulty) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        return '''
Instructions for EASY difficulty:
- Focus on basic concepts and definitions
- Use straightforward language
- Make correct answers obvious for those who read the material
- Include clear distinctions between correct and incorrect options
- Test recall and basic understanding
        ''';

      case QuizDifficulty.medium:
        return '''
Instructions for MEDIUM difficulty:
- Balance between recall and application
- Require understanding of concepts, not just memorization
- Include some questions that need analysis
- Make distractors (wrong options) plausible but clearly incorrect
- Test comprehension and basic application
        ''';

      case QuizDifficulty.hard:
        return '''
Instructions for HARD difficulty:
- Focus on application, analysis, and synthesis
- Create complex scenarios that require critical thinking
- Use nuanced distractors that require deep understanding to eliminate
- Ask questions that connect multiple concepts
- Test advanced understanding and ability to apply knowledge
- Include questions that require inference and reasoning
        ''';
    }
  }
}
