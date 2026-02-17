import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class LoadingOverlayWidget extends StatelessWidget {
  final String message;

  const LoadingOverlayWidget({super.key, required this.message});

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

class AnimatedLoadingDots extends StatefulWidget {
  const AnimatedLoadingDots({super.key});

  @override
  State<AnimatedLoadingDots> createState() => _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<AnimatedLoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.3;

            final value = (_controller.value + delay) % 1.0;

            final bounce = value < 0.5 ? value * 2 : (1 - value) * 2;

            final colorValue = (value * 2).clamp(0.0, 1.0);
            final alpha = 0.3 + (colorValue * 0.7);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, -bounce * 8),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Appcolor.primaryColor.withValues(alpha: alpha),
                    boxShadow: [
                      BoxShadow(
                        color: Appcolor.primaryColor.withValues(
                          alpha: alpha * 0.5,
                        ),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
