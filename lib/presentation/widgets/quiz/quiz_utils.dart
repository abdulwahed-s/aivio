import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';
import 'package:aivio/data/model/quiz_settings.dart';

Color getDifficultyColor(QuizDifficulty? difficulty) {
  if (difficulty == null) return Appcolor.primaryColor;

  switch (difficulty) {
    case QuizDifficulty.easy:
      return const Color(0xFF10B981);
    case QuizDifficulty.medium:
      return const Color(0xFF3B82F6);
    case QuizDifficulty.hard:
      return const Color(0xFFEF4444);
  }
}
