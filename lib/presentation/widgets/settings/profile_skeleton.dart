import 'package:aivio/presentation/widgets/skeleton_container.dart';
import 'package:flutter/material.dart';

class SettingsProfileSkeleton extends StatelessWidget {
  const SettingsProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonContainer(width: 100, height: 24),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
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
            children: [
              SkeletonContainer(
                width: 80,
                height: 80,
                borderRadius: BorderRadius.circular(40),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonContainer(width: 150, height: 24),
                    const SizedBox(height: 8),
                    const SkeletonContainer(width: 200, height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
