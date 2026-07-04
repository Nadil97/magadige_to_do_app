import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task_model.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/task_provider.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final Function(String) onStatusChange;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onStatusChange,
    required this.onDelete,
    this.onEdit,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  // ─── Status colours ────────────────────────────────────────────────────────

  Color get _statusColor {
    switch (widget.task.status) {
      case 'Done':         return const Color(0xFF10B981);
      case 'In Progress':  return const Color(0xFFF59E0B);
      default:             return const Color(0xFF3B82F6);
    }
  }

  Color get _statusDarkColor {
    switch (widget.task.status) {
      case 'Done':         return const Color(0xFF047857);
      case 'In Progress':  return const Color(0xFFB45309);
      default:             return const Color(0xFF1D4ED8);
    }
  }

  Color get _statusLightColor {
    switch (widget.task.status) {
      case 'Done':         return const Color(0xFFD1FAE5);
      case 'In Progress':  return const Color(0xFFFEF3C7);
      default:             return const Color(0xFFDBEAFE);
    }
  }

  Color get _statusTextColor {
    switch (widget.task.status) {
      case 'Done':         return const Color(0xFF065F46);
      case 'In Progress':  return const Color(0xFF78350F);
      default:             return const Color(0xFF1E3A8A);
    }
  }

  // ─── Priority ─────────────────────────────────────────────────────────────

  Color _priorityColor(String p) {
    switch (p) {
      case 'Hard':   return const Color(0xFFEF4444);
      case 'Medium': return const Color(0xFFF97316);
      default:       return const Color(0xFF22C55E);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // The 3D slab "lift" amount — collapses to 0 when pressed
    final double lift = _isPressed ? 0 : 7;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_)   => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          bottom: 24,
          // When pressed the card sinks — we compensate margin so siblings don't jump
          top: _isPressed ? lift : 0,
        ),
        child: Stack(
          children: [
            // ── Bottom 3D slab (always visible, gives depth) ──────────────
            Positioned.fill(
              top: 7, // fixed slab thickness
              child: Container(
                decoration: BoxDecoration(
                  color: _statusDarkColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // ── Top card that translates down on press ────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, _isPressed ? 7 : 0, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _statusColor.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _statusColor.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Coloured status stripe at top ─────────────────
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_statusColor, _statusColor.withOpacity(0.6)],
                        ),
                      ),
                    ),

                    // ── Card body ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Icon circle
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _statusLightColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.task.status == 'Done'
                                  ? Icons.check_circle_rounded
                                  : widget.task.status == 'In Progress'
                                      ? Icons.timelapse_rounded
                                      : Icons.radio_button_unchecked_rounded,
                              color: _statusColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Task info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.task.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: widget.task.isCompleted
                                        ? const Color(0xFFCBD5E1)
                                        : const Color(0xFF1E293B),
                                    decoration: widget.task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                if (widget.task.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.task.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: widget.task.isCompleted
                                          ? const Color(0xFFE2E8F0)
                                          : const Color(0xFF64748B),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),

                                // Badges row
                                Row(
                                  children: [
                                    // Status badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: _statusLightColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        widget.task.status.toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: _statusTextColor,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),

                                    // Priority dot + text
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _priorityColor(widget.task.priority),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.task.priority,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _priorityColor(widget.task.priority),
                                      ),
                                    ),
                                    const SizedBox(width: 10),

                                    // Assignee
                                    const Icon(Icons.person_outline_rounded,
                                        size: 12, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Consumer(
                                        builder: (context, ref, child) {
                                          final userMap = ref.watch(userMapProvider).value;
                                          final assigneeName = userMap?[widget.task.assignedTo.firstOrNull] ?? 'Unassigned';
                                          return Text(
                                            assigneeName,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: const Color(0xFF94A3B8),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),

                          // Right side controls column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Edit button
                              if (widget.onEdit != null)
                                GestureDetector(
                                  onTap: widget.onEdit,
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0E7FF),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      color: Color(0xFF4F46E5),
                                      size: 16,
                                    ),
                                  ),
                                ),
                                
                              // Delete button
                              GestureDetector(
                                onTap: widget.onDelete,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Status Dropdown
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFFE2E8F0), width: 1),
                                ),
                                child: DropdownButton<String>(
                                  value: widget.task.status,
                                  underline: const SizedBox(),
                                  isDense: true,
                                  icon: Icon(Icons.unfold_more_rounded,
                                      color: _statusColor, size: 14),
                                  dropdownColor: Colors.white,
                                  style: GoogleFonts.outfit(
                                    color: _statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  items: ['Todo', 'In Progress', 'Done']
                                      .map((s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) widget.onStatusChange(val);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
