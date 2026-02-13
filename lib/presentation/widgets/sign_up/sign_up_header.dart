import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Appcolor.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_add_outlined,
              size: 48,
              color: Appcolor.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Create Account',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Appcolor.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign up to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
