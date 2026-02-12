import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class LoginEmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;

  const LoginEmailField({
    super.key,
    required this.controller,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: Appcolor.primaryColor,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Appcolor.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
      ),
      keyboardType: TextInputType.emailAddress,
      enabled: enabled,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }
}
