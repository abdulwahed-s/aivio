import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class ForgotPasswordButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const ForgotPasswordButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(foregroundColor: Appcolor.primaryColor),
        child: const Text(
          'Forgot Password?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
