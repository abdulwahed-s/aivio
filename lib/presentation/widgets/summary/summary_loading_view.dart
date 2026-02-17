import 'package:flutter/material.dart';

class SummaryLoadingView extends StatelessWidget {
  final String message;

  const SummaryLoadingView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
