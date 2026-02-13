import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class SignUpPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool obscureText;
  final VoidCallback onToggleVisibility;

  const SignUpPasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(
          Icons.lock_outlined,
          color: Appcolor.primaryColor,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Appcolor.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade900
            : Colors.grey.shade50,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Colors.grey.shade600,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      obscureText: obscureText,
      enabled: enabled,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
}
