import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class SignUpLoginRedirect extends StatelessWidget {
  final VoidCallback onLoginTap;
  final bool enabled;

  const SignUpLoginRedirect({
    super.key,
    required this.onLoginTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
        TextButton(
          onPressed: enabled ? onLoginTap : null,
          style: TextButton.styleFrom(foregroundColor: Appcolor.primaryColor),
          child: const Text(
            'Login',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
