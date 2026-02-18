import 'package:aivio/core/constant/color.dart';
import 'package:flutter/material.dart';

class AssignmentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onShare;
  final bool showShare;

  const AssignmentAppBar({
    required this.title,
    this.onShare,
    this.showShare = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      elevation: 0,
      backgroundColor: Appcolor.primaryColor,
      foregroundColor: Colors.white,
      actions: [
        if (showShare)
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: onShare)
        else
          const SizedBox.shrink(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
