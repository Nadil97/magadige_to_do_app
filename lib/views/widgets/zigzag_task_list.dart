import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../core/theme/app_theme.dart';

class ZigZagTaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel) onTaskTap;

  const ZigZagTaskList({
    super.key,
    required this.tasks,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.checklist_rtl_rounded, size: 64, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              'No tasks yet! Add tasks to see your roadmap.',
              style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isLeft = index % 2 == 0;

        return TweenAnimationBuilder<double>(
          key: ValueKey(task.id),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(isLeft ? -30 * (1 - value) : 30 * (1 - value), 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTap: () => onTaskTap(task),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(
                bottom: 24,
                left: isLeft ? 0 : 48,
                right: isLeft ? 48 : 0,
              ),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor(task.status).withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: _getStatusColor(task.status).withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Status Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(task.status).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(task.status),
                        color: _getStatusColor(task.status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Task Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: task.isCompleted ? Colors.black38 : Colors.black87,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(task.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              task.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(task.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black26),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Done':
        return Icons.check_circle_rounded;
      case 'In Progress':
        return Icons.timelapse_rounded;
      case 'Todo':
      default:
        return Icons.circle_outlined;
    }
  }
}
