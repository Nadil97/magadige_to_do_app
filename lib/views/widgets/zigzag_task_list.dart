import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../core/theme/app_theme.dart';

class ZigZagTaskList extends StatefulWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel) onTaskTap;

  const ZigZagTaskList({
    super.key,
    required this.tasks,
    required this.onTaskTap,
  });

  @override
  State<ZigZagTaskList> createState() => _ZigZagTaskListState();
}

class _ZigZagTaskListState extends State<ZigZagTaskList> {
  int? _pressedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.stairs_rounded, size: 64, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              'No tasks yet! Add tasks to build your stairs.',
              style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Sort tasks: Done -> In Progress -> Todo
    // This way, Done is at the start of the list. 
    // Since we reverse the rendering order to build from bottom up, Done will be at the bottom!
    final sortedTasks = List<TaskModel>.from(widget.tasks)..sort((a, b) {
      int getScore(String status) {
        if (status == 'Done') return 0;
        if (status == 'In Progress') return 1;
        return 2; // Todo
      }
      return getScore(a.status).compareTo(getScore(b.status));
    });

    // Find the total number of done tasks to place the avatar
    final doneCount = sortedTasks.where((t) => t.status == 'Done').length;

    // We render items from top of screen to bottom.
    // Index 0 in the column is the top. So we reverse the list.
    final List<Widget> listItems = [];

    // The Goal Flag at the very top
    listItems.add(
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.colorSecondary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flag_rounded, size: 32, color: AppTheme.colorSecondary),
              ),
              const SizedBox(height: 4),
              const Text(
                'Goal',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.colorSecondary),
              ),
            ],
          ),
        ),
      ),
    );

    // Build the stairs from top (highest index) down to bottom (0)
    for (int reversedIndex = sortedTasks.length - 1; reversedIndex >= 0; reversedIndex--) {
      final task = sortedTasks[reversedIndex];
      
      // If this is the boundary exactly after the last 'Done' task, insert the Avatar!
      // (If doneCount == 0, the avatar goes at the very bottom, after all tasks. We handle that at the end)
      if (doneCount > 0 && reversedIndex == doneCount - 1) {
        // Place avatar ON TOP of the highest done task
        final double leftMargin = (reversedIndex % 5) * 30.0;
        final double rightMargin = 40.0 - ((reversedIndex % 5) * 10.0);
        
        listItems.add(
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            margin: EdgeInsets.only(
              bottom: 8,
              left: leftMargin + 32, // Offset to stand on the card
              right: rightMargin,
            ),
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.colorPrimary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppTheme.colorPrimary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.directions_run_rounded, size: 24, color: Colors.white),
                ),
                const Text('You', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.colorPrimary)),
              ],
            ),
          ),
        );
      }

      final double leftMargin = (reversedIndex % 5) * 30.0;
      final double rightMargin = 40.0 - ((reversedIndex % 5) * 10.0);
      final isPressed = _pressedIndex == reversedIndex;
      final baseColor = _getStatusColor(task.status);
      final shadowColor = _getDarkerColor(baseColor);

      listItems.add(
        TweenAnimationBuilder<double>(
          key: ValueKey('task_${task.id}'),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value.clamp(0.0, 1.0), // FIXED: Clamp opacity to avoid AssertionError
                child: child,
              ),
            );
          },
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressedIndex = reversedIndex),
            onTapUp: (_) {
              setState(() => _pressedIndex = null);
              widget.onTaskTap(task);
            },
            onTapCancel: () => setState(() => _pressedIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: EdgeInsets.only(
                bottom: 16,
                left: leftMargin,
                right: rightMargin,
                top: isPressed ? 6 : 0,
              ),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isPressed
                    ? []
                    : [
                        BoxShadow(
                          color: shadowColor,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 10),
                        ),
                      ],
                border: Border.all(
                  color: baseColor.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Task Number
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${reversedIndex + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: baseColor,
                        ),
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
                          const SizedBox(height: 4),
                          Text(
                            task.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: baseColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.touch_app_rounded, color: baseColor.withOpacity(0.5), size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // If there are no done tasks, the avatar goes at the very bottom!
    if (doneCount == 0) {
      listItems.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.only(bottom: 8, left: 32),
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.colorPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.colorPrimary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.directions_run_rounded, size: 24, color: Colors.white),
              ),
              const Text('You', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.colorPrimary)),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      children: listItems,
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

  Color _getDarkerColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
  }
}

