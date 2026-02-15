import 'package:aivio/core/constant/color.dart';
import 'package:flutter/material.dart';

class SettingsThemeSection extends StatelessWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const SettingsThemeSection({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appearance',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.dark_mode_rounded,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Dark Mode',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Switch(
                value: isDark,
                activeThumbColor: Appcolor.primaryColor,
                onChanged: onThemeChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
