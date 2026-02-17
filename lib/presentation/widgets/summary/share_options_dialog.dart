import 'package:flutter/material.dart';
import 'package:aivio/core/constant/color.dart';

class ShareOptionsDialog extends StatelessWidget {
  final VoidCallback onCopyText;
  final VoidCallback onShareImage;

  const ShareOptionsDialog({
    super.key,
    required this.onCopyText,
    required this.onShareImage,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Share Summary',
        style: TextStyle(
          color: Appcolor.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.copy_rounded, color: Appcolor.primaryColor),
            title: const Text('Copy as Text'),
            subtitle: const Text('Copy summary to clipboard'),
            onTap: () {
              Navigator.of(context).pop();
              onCopyText();
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.image_rounded, color: Appcolor.primaryColor),
            title: const Text('Share as Image'),
            subtitle: const Text('Generate and share as image'),
            onTap: () {
              Navigator.of(context).pop();
              onShareImage();
            },
          ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
