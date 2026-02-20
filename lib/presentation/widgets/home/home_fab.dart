import 'package:aivio/core/constant/color.dart';
import 'package:flutter/material.dart';

class HomeFab extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onPressed;

  const HomeFab({super.key, required this.controller, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut)),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
        label: const Text(
          'New',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Appcolor.primaryColor,
        elevation: 4,
      ),
    );
  }
}
