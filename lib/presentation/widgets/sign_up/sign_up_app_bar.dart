import 'package:flutter/material.dart';

class SignUpAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final bool isLoading;

  const SignUpAppBar({super.key, required this.onBack, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: isLoading ? null : onBack,
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(backgroundColor: Colors.grey.shade100),
          ),
        ],
      ),
    );
  }
}
