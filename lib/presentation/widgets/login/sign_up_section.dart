import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';
import 'package:aivio/core/routes/app_route.dart';

class SignUpSection extends StatelessWidget {
  final bool enabled;

  const SignUpSection({super.key, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
        ),
        TextButton(
          onPressed: enabled
              ? () {
                  Navigator.pushNamed(context, AppRoute.signUp);
                }
              : null,
          style: TextButton.styleFrom(foregroundColor: Appcolor.primaryColor),
          child: const Text(
            'Sign Up',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
