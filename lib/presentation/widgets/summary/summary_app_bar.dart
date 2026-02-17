import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class SummaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showShareButton;
  final VoidCallback? onSharePressed;

  const SummaryAppBar({
    super.key,
    required this.title,
    this.showShareButton = false,
    this.onSharePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      elevation: 0,
      backgroundColor: Appcolor.primaryColor,
      foregroundColor: Colors.white,
      actions: [
        if (showShareButton)
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: onSharePressed,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
