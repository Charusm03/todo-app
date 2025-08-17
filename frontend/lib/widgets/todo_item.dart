import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../models/user.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final User currentUser;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.currentUser,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and completion status
            Row(
              children: [
                if (currentUser.canEdit())
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: todo.completed ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                        color:
                            todo.completed ? Colors.green : Colors.transparent,
                      ),
                      child: todo.completed
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: todo.completed ? Colors.green : Colors.grey,
                        width: 2,
                      ),
                      color: todo.completed ? Colors.green : Colors.transparent,
                    ),
                    child: todo.completed
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    todo.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: todo.completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: todo.completed ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                // Action buttons
                if (currentUser.canEdit() || currentUser.canDelete())
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      if (currentUser.canEdit())
                        PopupMenuItem(
                          onTap: onEdit,
                          child: const Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                      if (currentUser.canDelete())
                        PopupMenuItem(
                          onTap: () {
                            // Show confirmation dialog
                            Future.delayed(
                              Duration.zero,
                              () => _showDeleteConfirmation(context),
                            );
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            ),

            // Description
            if (todo.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                todo.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ],

            // Metadata
            const SizedBox(height: 8),
            Row(
              children: [
                if (todo.username != null) ...[
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    todo.username!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  _formatDate(todo.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            // Status badge
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: todo.completed
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                todo.completed ? 'Completed' : 'Pending',
                style: TextStyle(
                  fontSize: 12,
                  color: todo.completed
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
