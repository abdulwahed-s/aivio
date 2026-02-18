import 'package:aivio/core/constant/color.dart';
import 'package:aivio/presentation/widgets/assignment/animated_loading_dots.dart';
import 'package:flutter/material.dart';

class AssignmentLoadingOverlay extends StatelessWidget {
  final String message;

  const AssignmentLoadingOverlay({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Theme.of(
          context,
        ).scaffoldBackgroundColor.withValues(alpha: 0.85),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Appcolor.primaryColor.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Appcolor.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Appcolor.primaryColor.withValues(alpha: 0.3),
                        Appcolor.primaryColor.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Appcolor.primaryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Appcolor.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),

                const AnimatedLoadingDots(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
