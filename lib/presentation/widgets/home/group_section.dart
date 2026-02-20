import 'package:flutter/material.dart';

class GroupSection extends StatefulWidget {
  final String groupName;
  final Color groupColor;
  final int itemCount;
  final bool isExpanded;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;
  final List<Widget> children;

  const GroupSection({
    super.key,
    required this.groupName,
    required this.groupColor,
    required this.itemCount,
    required this.isExpanded,
    this.onRename,
    this.onDelete,
    required this.children,
  });

  @override
  State<GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<GroupSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.groupColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.groupColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_right_rounded,
                      color: widget.groupColor,
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.folder_outlined,
                      color: widget.groupColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.groupName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: widget.groupColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.groupColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.itemCount}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: widget.groupColor,
                        ),
                      ),
                    ),
                    if (widget.onRename != null || widget.onDelete != null)
                      PopupMenuButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: widget.groupColor,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        itemBuilder: (context) => [
                          if (widget.onRename != null)
                            const PopupMenuItem(
                              value: 'rename',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text('Rename Group'),
                                ],
                              ),
                            ),
                          if (widget.onDelete != null)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text('Delete Group'),
                                ],
                              ),
                            ),
                        ],
                        onSelected: (value) {
                          if (value == 'rename' && widget.onRename != null) {
                            widget.onRename!();
                          } else if (value == 'delete' &&
                              widget.onDelete != null) {
                            widget.onDelete!();
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 12),
              ...widget.children,
            ],
          ],
        ),
      ),
    );
  }
}
