import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:aivio/core/constant/color.dart';

class SummaryUtils {
  static IconData getIconFromName(String iconName) {
    final iconMap = {
      'lightbulb_outline': Icons.lightbulb_outline,
      'check_circle': Icons.check_circle,
      'star': Icons.star,
      'info': Icons.info,
      'school': Icons.school,
      'psychology': Icons.psychology,
      'science': Icons.science,
      'business': Icons.business,
      'book': Icons.book,
      'code': Icons.code,
      'calculate': Icons.calculate,
      'language': Icons.language,
      'palette': Icons.palette,
      'fitness_center': Icons.fitness_center,
    };
    return iconMap[iconName] ?? Icons.lightbulb_outline;
  }

  static Map<String, dynamic> getFormatStyle(String? format) {
    IconData icon = Icons.article_outlined;
    Color color = Appcolor.primaryColor;

    if (format != null) {
      switch (format) {
        case 'bulletPoints':
          icon = Icons.list_rounded;
          color = const Color(0xFF10B981);
          break;
        case 'paragraphs':
          icon = Icons.article_outlined;
          color = const Color(0xFF3B82F6);
          break;
        case 'keyTopics':
          icon = Icons.topic_outlined;
          color = const Color(0xFF8B5CF6);
          break;
      }
    }

    return {'icon': icon, 'color': color};
  }

  static String extractTextFromContent(String content) {
    try {
      final jsonContent = json.decode(content);
      if (jsonContent is Map<String, dynamic>) {
        return _extractTextFromJson(jsonContent);
      }
    } catch (e) {
      return content;
    }

    return content;
  }

  static String _extractTextFromJson(Map<String, dynamic> data) {
    final format = data['format'] as String?;

    switch (format) {
      case 'bulletPoints':
        return _extractBulletPointsText(data);
      case 'paragraphs':
        return _extractParagraphsText(data);
      case 'keyTopics':
        return _extractKeyTopicsText(data);
      default:
        return _extractGenericText(data);
    }
  }

  static String _extractBulletPointsText(Map<String, dynamic> data) {
    final StringBuffer buffer = StringBuffer();

    final overview = data['overview'] as String?;
    if (overview != null) {
      buffer.writeln(overview);
      buffer.writeln();
    }

    final categories = data['categories'] as List<dynamic>?;
    if (categories != null) {
      for (var category in categories) {
        final name = category['name'] as String?;
        final points = category['points'] as List<dynamic>?;

        if (name != null) {
          buffer.writeln(name);
          buffer.writeln();
        }

        if (points != null) {
          for (var point in points) {
            buffer.writeln('• ${point.toString()}');
          }
          buffer.writeln();
        }
      }
    }

    return buffer.toString().trim();
  }

  static String _extractParagraphsText(Map<String, dynamic> data) {
    final StringBuffer buffer = StringBuffer();

    final introduction = data['introduction'] as String?;
    if (introduction != null) {
      buffer.writeln('Introduction');
      buffer.writeln();
      buffer.writeln(introduction);
      buffer.writeln();
    }

    final body = data['body'] as List<dynamic>?;
    if (body != null) {
      for (var paragraph in body) {
        final heading = paragraph['heading'] as String?;
        final text = paragraph['paragraph'] as String?;

        if (heading != null) {
          buffer.writeln(heading);
          buffer.writeln();
        }

        if (text != null) {
          buffer.writeln(text);
          buffer.writeln();
        }
      }
    }

    final conclusion = data['conclusion'] as String?;
    if (conclusion != null) {
      buffer.writeln('Conclusion');
      buffer.writeln();
      buffer.writeln(conclusion);
      buffer.writeln();
    }

    return buffer.toString().trim();
  }

  static String _extractKeyTopicsText(Map<String, dynamic> data) {
    final StringBuffer buffer = StringBuffer();

    final overview = data['overview'] as String?;
    if (overview != null) {
      buffer.writeln(overview);
      buffer.writeln();
    }

    final topics = data['topics'] as List<dynamic>?;
    if (topics != null) {
      for (var topic in topics) {
        final topicTitle = topic['title'] as String?;
        final description = topic['description'] as String?;
        final keyPoints = topic['key_points'] as List<dynamic>?;

        if (topicTitle != null) {
          buffer.writeln(topicTitle);
          buffer.writeln();
        }

        if (description != null) {
          buffer.writeln(description);
          buffer.writeln();
        }

        if (keyPoints != null && keyPoints.isNotEmpty) {
          for (var point in keyPoints) {
            buffer.writeln('• ${point.toString()}');
          }
          buffer.writeln();
        }
      }
    }

    final keyTakeaways = data['key_takeaways'] as List<dynamic>?;
    if (keyTakeaways != null && keyTakeaways.isNotEmpty) {
      buffer.writeln('Key Takeaways');
      buffer.writeln();
      for (var point in keyTakeaways) {
        buffer.writeln('★ ${point.toString()}');
      }
      buffer.writeln();
    }

    return buffer.toString().trim();
  }

  static String _extractGenericText(Map<String, dynamic> data) {
    final StringBuffer buffer = StringBuffer();

    final overview = data['overview'] as String?;
    if (overview != null) {
      buffer.writeln('Overview');
      buffer.writeln();
      buffer.writeln(overview);
      buffer.writeln();
    }

    final keyTakeaways = data['key_takeaways'] as List<dynamic>?;
    if (keyTakeaways != null && keyTakeaways.isNotEmpty) {
      buffer.writeln('Key Takeaways');
      buffer.writeln();
      for (var point in keyTakeaways) {
        buffer.writeln('• ${point.toString()}');
      }
      buffer.writeln();
    }

    final sections = data['sections'] as List<dynamic>?;
    if (sections != null) {
      for (var section in sections) {
        final title = section['title'] as String?;
        final content = section['content'] as String?;

        if (title != null) {
          buffer.writeln(title);
          buffer.writeln();
        }

        if (content != null) {
          buffer.writeln(content);
          buffer.writeln();
        }
      }
    }

    return buffer.toString().trim();
  }
}
