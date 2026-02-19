import 'package:flutter/material.dart';

Future<Map<String, dynamic>?> showGroupCreationDialog(
  BuildContext context, {
  required String type,
  String? initialName,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) =>
        _GroupCreationDialog(type: type, initialName: initialName),
  );
}

class _GroupCreationDialog extends StatefulWidget {
  final String type;
  final String? initialName;

  const _GroupCreationDialog({required this.type, this.initialName});

  @override
  State<_GroupCreationDialog> createState() => _GroupCreationDialogState();
}

class _GroupCreationDialogState extends State<_GroupCreationDialog> {
  late TextEditingController _nameController;
  int _selectedColor = 0xFF6B5CE7;

  final List<int> _colors = [
    0xFF6B5CE7,
    0xFFEF4444,
    0xFF3B82F6,
    0xFF10B981,
    0xFFF59E0B,
    0xFFEC4899,
    0xFFD946EF,
    0xFF06B6D4,
    0xFF84CC16,
    0xFFF97316,
    0xFF22C55E,
    0xFF14B8A6,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialName != null;
    final title = isEdit
        ? 'Rename Group'
        : 'Create ${widget.type == 'quiz' ? 'Quiz' : 'Summary'} Group';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(
            isEdit ? Icons.edit_outlined : Icons.create_new_folder_outlined,
            color: Color(_selectedColor),
          ),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Group Name',
              hintText: 'e.g., Math Course',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          if (!isEdit) ...[
            const SizedBox(height: 24),
            Text(
              'Color',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              width: 3,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Color(color).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'color': _selectedColor,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(_selectedColor),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(isEdit ? 'Rename' : 'Create'),
        ),
      ],
    );
  }
}
