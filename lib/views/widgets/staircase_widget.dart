import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../core/theme/app_theme.dart';

class StaircaseWidget extends StatefulWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel) onTaskTap;

  const StaircaseWidget({
    super.key,
    required this.tasks,
    required this.onTaskTap,
  });

  @override
  State<StaircaseWidget> createState() => _StaircaseWidgetState();
}

class _StaircaseWidgetState extends State<StaircaseWidget> with SingleTickerProviderStateMixin {
  late AnimationController _climbController;
  late int _completedCount;
  late int _prevCompletedCount;

  @override
  void initState() {
    super.initState();
    _completedCount = widget.tasks.where((t) => t.status == 'Done').length;
    _prevCompletedCount = _completedCount;
    _climbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant StaircaseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentCompleted = widget.tasks.where((t) => t.status == 'Done').length;
    if (currentCompleted != _completedCount) {
      setState(() {
        _prevCompletedCount = _completedCount;
        _completedCount = currentCompleted;
        _climbController.reset();
        _climbController.forward();
      });
    }
  }

  @override
  void dispose() {
    _climbController.dispose();
    super.dispose();
  }

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
              'No steps created yet! Add tasks to build your stairs.',
              style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    final totalSteps = widget.tasks.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        // Base configurations for 3D steps drawing
        final double stepWidth = 90.0;
        final double stepHeight = 35.0;
        final double stepDepth = 25.0; // Isometric offset

        // Starting point: Bottom Left
        final double startX = 40.0;
        final double startY = height - 60.0;

        return Stack(
          children: [
            // Custom Painter to draw actual 3D volumetric steps
            Positioned.fill(
              child: GestureDetector(
                onTapDown: (details) {
                  // Hit test steps to see if user tapped one
                  final tapPos = details.localPosition;
                  for (int i = 0; i < totalSteps; i++) {
                    final double x = startX + (i * (stepWidth - 30));
                    final double y = startY - (i * stepHeight);
                    // Check bounding box approximately
                    if (tapPos.dx >= x && tapPos.dx <= x + stepWidth &&
                        tapPos.dy >= y - stepDepth && tapPos.dy <= y + stepHeight) {
                      widget.onTaskTap(widget.tasks[i]);
                      break;
                    }
                  }
                },
                child: CustomPaint(
                  painter: RealisticStaircasePainter(
                    tasks: widget.tasks,
                    startX: startX,
                    startY: startY,
                    stepWidth: stepWidth,
                    stepHeight: stepHeight,
                    stepDepth: stepDepth,
                  ),
                ),
              ),
            ),

            // Animated Avatar standing on top of active completed steps
            AnimatedBuilder(
              animation: _climbController,
              builder: (context, child) {
                // Interpolate avatar position
                final double currentStepPos = _prevCompletedCount + 
                    ((_completedCount - _prevCompletedCount) * _climbController.value);
                
                final clampedStepPos = currentStepPos.clamp(0.0, totalSteps.toDouble());

                // Calculate exact X/Y based on step interpolation
                double avatarX;
                double avatarY;

                if (clampedStepPos == 0) {
                  // Stands on the floor before step 0
                  avatarX = startX - 25;
                  avatarY = startY - 45;
                } else {
                  final activeIndex = (clampedStepPos - 1).floor();
                  final remainder = clampedStepPos - 1 - activeIndex;

                  final x1 = startX + (activeIndex * (stepWidth - 30)) + (stepWidth / 2) - 15;
                  final y1 = startY - (activeIndex * stepHeight) - stepDepth - 20;

                  if (activeIndex < totalSteps - 1) {
                    final x2 = startX + ((activeIndex + 1) * (stepWidth - 30)) + (stepWidth / 2) - 15;
                    final y2 = startY - ((activeIndex + 1) * stepHeight) - stepDepth - 20;
                    
                    avatarX = x1 + (x2 - x1) * remainder;
                    avatarY = y1 + (y2 - y1) * remainder;
                  } else {
                    avatarX = x1;
                    avatarY = y1;
                  }
                }

                return Positioned(
                  left: avatarX,
                  top: avatarY,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.colorPrimary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.directions_run, color: Colors.white, size: 14),
                        SizedBox(width: 2),
                        Text(
                          'You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class RealisticStaircasePainter extends CustomPainter {
  final List<TaskModel> tasks;
  final double startX;
  final double startY;
  final double stepWidth;
  final double stepHeight;
  final double stepDepth;

  RealisticStaircasePainter({
    required this.tasks,
    required this.startX,
    required this.startY,
    required this.stepWidth,
    required this.stepHeight,
    required this.stepDepth,
  });

  Color _getStatusColor(String status, {int shade = 0}) {
    Color base;
    switch (status) {
      case 'Done':
        base = AppTheme.colorDone;
        break;
      case 'In Progress':
        base = AppTheme.colorInProgress;
        break;
      case 'Todo':
      default:
        base = AppTheme.colorTodo;
    }

    if (shade == 1) {
      // Darken for front face
      return HSVColor.fromColor(base).withValue((HSVColor.fromColor(base).value - 0.15).clamp(0.0, 1.0)).toColor();
    } else if (shade == 2) {
      // Even darker for side face
      return HSVColor.fromColor(base).withValue((HSVColor.fromColor(base).value - 0.25).clamp(0.0, 1.0)).toColor();
    }
    return base;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      final double x = startX + (i * (stepWidth - 30));
      final double y = startY - (i * stepHeight);

      final colorTop = _getStatusColor(task.status, shade: 0);
      final colorFront = _getStatusColor(task.status, shade: 1);
      final colorSide = _getStatusColor(task.status, shade: 2);

      // --- Draw 3D Isometric Step Block ---
      
      // 1. Front Face
      final pathFront = Path()
        ..moveTo(x, y)
        ..lineTo(x + stepWidth - 20, y)
        ..lineTo(x + stepWidth - 20, y + stepHeight)
        ..lineTo(x, y + stepHeight)
        ..close();
      canvas.drawPath(pathFront, Paint()..color = colorFront);

      // 2. Top Face
      final pathTop = Path()
        ..moveTo(x, y)
        ..lineTo(x + 20, y - stepDepth)
        ..lineTo(x + stepWidth, y - stepDepth)
        ..lineTo(x + stepWidth - 20, y)
        ..close();
      canvas.drawPath(pathTop, Paint()..color = colorTop);

      // 3. Right Side Face
      final pathSide = Path()
        ..moveTo(x + stepWidth - 20, y)
        ..lineTo(x + stepWidth, y - stepDepth)
        ..lineTo(x + stepWidth, y - stepDepth + stepHeight)
        ..lineTo(x + stepWidth - 20, y + stepHeight)
        ..close();
      canvas.drawPath(pathSide, Paint()..color = colorSide);

      // Draw index number on top/front face
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x + (stepWidth / 2) - 15, y + (stepHeight / 2) - 8));
    }
  }

  @override
  bool shouldRepaint(covariant RealisticStaircasePainter oldDelegate) {
    return oldDelegate.tasks != tasks;
  }
}
