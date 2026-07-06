import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final Function(String) onStatusChange;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback onView; 

  const TaskCard({
    super.key,
    required this.task,
    required this.onStatusChange,
    this.onDelete,
    this.onEdit,
    required this.onView, 
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

  // ─── Mini Action Button Builder (Next Level 3D Look) ─────────────────────
  Widget _buildMiniActionButton({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: iconColor.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double lift = _isPressed ? 0 : 7;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onView(); // Card click කලත් sheet එක open වෙනවා
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          bottom: 24,
          top: _isPressed ? lift : 0,
        ),
        child: Stack(
          children: [
            // ── Bottom 3D slab ──────────────────────────────────────────────
            Positioned.fill(
              top: 7,
              child: Container(
                decoration: BoxDecoration(
                  color: _statusDarkColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // ── Top card ────────────────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, _isPressed ? 7 : 0, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _statusColor.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _statusColor.withOpacity(0.1),
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
                    // Coloured status stripe
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_statusColor, _statusColor.withOpacity(0.6)],
                        ),
                      ),
                    ),

                    // Card body
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Icon circle
                          Container(
                            width: 42,
                            height: 42,
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
                              size: 24,
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
                                    fontSize: 16,
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
                          const SizedBox(width: 8),

                          // Right side controls column (Next Level UI Layout)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  
                                  _buildMiniActionButton(
                                    icon: Icons.visibility_rounded,
                                    iconColor: const Color(0xFF0EA5E9), // Sky blue premium tint
                                    bgColor: const Color(0xFFE0F2FE),
                                    onTap: widget.onView,
                                  ),
                                  const SizedBox(width: 6),

                                  // EDIT BUTTON
                                  if (widget.onEdit != null) ...[
                                    _buildMiniActionButton(
                                      icon: Icons.edit_rounded,
                                      iconColor: const Color(0xFF6366F1),
                                      bgColor: const Color(0xFFEEF2FF),
                                      onTap: widget.onEdit!,
                                    ),
                                    const SizedBox(width: 6),
                                  ],

                                  // DELETE BUTTON
                                  if (widget.onDelete != null) ...[
                                    _buildMiniActionButton(
                                      icon: Icons.delete_outline_rounded,
                                      iconColor: const Color(0xFFEF4444),
                                      bgColor: const Color(0xFFFEE2E2),
                                      onTap: widget.onDelete!,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Status Dropdown
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {},
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
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