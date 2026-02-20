import 'package:flutter/material.dart';

class HomeLoginState extends StatelessWidget {
  const HomeLoginState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Please log in to view your library',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
