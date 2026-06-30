import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../core/theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final Function(String) onStatusChange;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onStatusChange,
    required this.onDelete,
  });

  Color _getPriorityBgColor(String priority) {
    switch (priority) {
      case 'Hard':
        return AppTheme.priorityHard;
      case 'Medium':
        return AppTheme.priorityMedium;
      case 'Easy':
      default:
        return AppTheme.priorityEasy;
    }
  }

  Color _getPriorityTextColor(String priority) {
    switch (priority) {
      case 'Hard':
        return AppTheme.textHard;
      case 'Medium':
        return AppTheme.textMedium;
      case 'Easy':
      default:
        return AppTheme.textEasy;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Done':
        return AppTheme.colorDone;
      case 'In Progress':
        return AppTheme.colorInProgress;
      case 'Todo':
      default:
        return AppTheme.colorTodo;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Done':
        return AppTheme.textDone;
      case 'In Progress':
        return AppTheme.textInProgress;
      case 'Todo':
      default:
        return AppTheme.textTodo;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBgColor = _getStatusBgColor(task.status);
    final statusTextColor = _getStatusTextColor(task.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: statusBgColor,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delete action button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black38, size: 20),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),

          // Task details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: task.isCompleted ? Colors.black38 : Colors.black87,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: task.isCompleted ? Colors.black26 : Colors.black54,
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Tags & Assignee row
                Row(
                  children: [
                    // Priority Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityBgColor(task.priority),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.priority,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _getPriorityTextColor(task.priority),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Assignee
                    const Icon(Icons.person_outline, size: 12, color: Colors.black38),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        task.assignedTo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Status Dropdown selector
          DropdownButton<String>(
            value: task.status,
            underline: const SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: statusTextColor),
            dropdownColor: AppTheme.cardBg,
            style: TextStyle(
              color: statusTextColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            items: ['Todo', 'In Progress', 'Done'].map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) onStatusChange(val);
            },
          ),
        ],
      ),
    );
  }
}
