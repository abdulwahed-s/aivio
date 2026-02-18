import 'package:aivio/core/constant/color.dart';
import 'package:flutter/material.dart';

class AnimatedAIIcon extends StatefulWidget {
  const AnimatedAIIcon({super.key});

  @override
  State<AnimatedAIIcon> createState() => _AnimatedAIIconState();
}

class _AnimatedAIIconState extends State<AnimatedAIIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = 0.9 + (_controller.value * 0.1);

        return Transform.scale(
          scale: scale,
          child: Container(
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
        );
      },
    );
  }
}
