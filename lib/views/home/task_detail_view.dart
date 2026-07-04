import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class TaskDetailView extends ConsumerStatefulWidget {
  final TaskModel task;

  const TaskDetailView({super.key, required this.task});

  @override
  ConsumerState<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends ConsumerState<TaskDetailView>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _assigneeController;
  late String _selectedStatus;
  late String _selectedPriority;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description);
    _assigneeController = TextEditingController(text: widget.task.assignedTo);
    _selectedStatus = widget.task.status;
    _selectedPriority = widget.task.priority;

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _assigneeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ─── Colour helpers ────────────────────────────────────────────────────────

  Color _statusColor(String s) {
    switch (s) {
      case 'Done':        return const Color(0xFF10B981);
      case 'In Progress': return const Color(0xFFF59E0B);
      default:            return const Color(0xFF3B82F6);
    }
  }

  Color _statusDark(String s) {
    switch (s) {
      case 'Done':        return const Color(0xFF047857);
      case 'In Progress': return const Color(0xFFB45309);
      default:            return const Color(0xFF1D4ED8);
    }
  }

  Color _statusLight(String s) {
    switch (s) {
      case 'Done':        return const Color(0xFFD1FAE5);
      case 'In Progress': return const Color(0xFFFEF3C7);
      default:            return const Color(0xFFDBEAFE);
    }
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'Hard':   return const Color(0xFFEF4444);
      case 'Medium': return const Color(0xFFF97316);
      default:       return const Color(0xFF22C55E);
    }
  }

  Color _priorityDark(String p) {
    switch (p) {
      case 'Hard':   return const Color(0xFF991B1B);
      case 'Medium': return const Color(0xFF9A3412);
      default:       return const Color(0xFF166534);
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'Done':        return Icons.check_circle_rounded;
      case 'In Progress': return Icons.timelapse_rounded;
      default:            return Icons.radio_button_unchecked_rounded;
    }
  }

  // ─── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() => _saving = true);

    final updated = widget.task.copyWith(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      assignedTo: _assigneeController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
    );

    await ref.read(taskControllerProvider.notifier).updateTask(updated);

    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      _buildStatusSlab(),
                      const SizedBox(height: 24),
                      _buildSection('Task Title', _buildTitleField()),
                      const SizedBox(height: 20),
                      _buildSection('Description', _buildDescField()),
                      const SizedBox(height: 20),
                      _buildSection('Assigned To', _buildAssigneeField()),
                      const SizedBox(height: 20),
                      _buildSection('Priority', _buildPriorityPicker()),
                      const SizedBox(height: 20),
                      _buildSection('Status', _buildStatusPicker()),
                      const SizedBox(height: 32),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Back button 3D slab
              _Slab3DButton(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Color(0xFF334155)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Task Details',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
              // Delete button 3D slab
              _Slab3DButton(
                color: const Color(0xFFFEE2E2),
                darkColor: const Color(0xFFFCA5A5),
                onTap: () async {
                  await ref
                      .read(taskControllerProvider.notifier)
                      .deleteTask(widget.task.id);
                  if (mounted) Navigator.pop(context);
                },
                child: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: Color(0xFFEF4444)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Status Slab Banner ──────────────────────────────────────────────────

  Widget _buildStatusSlab() {
    return Stack(
      children: [
        Positioned.fill(
          top: 8,
          child: Container(
            decoration: BoxDecoration(
              color: _statusDark(_selectedStatus),
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _statusColor(_selectedStatus),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(_statusIcon(_selectedStatus),
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedStatus.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _titleController.text.isEmpty
                          ? 'Untitled Task'
                          : _titleController.text,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Section wrapper ────────────────────────────────────────────────────────

  Widget _buildSection(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF475569),
            ),
          ),
        ),
        child,
      ],
    );
  }

  // ─── Fields ────────────────────────────────────────────────────────────────

  Widget _buildCard(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTitleField() {
    return _buildCard(
      TextFormField(
        controller: _titleController,
        onChanged: (_) => setState(() {}), // refresh header slab
        style: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: 'Enter task title…',
          hintStyle: GoogleFonts.outfit(color: const Color(0xFFCBD5E1)),
          prefixIcon: const Icon(Icons.title_rounded,
              color: Color(0xFF6366F1), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDescField() {
    return _buildCard(
      TextFormField(
        controller: _descController,
        maxLines: 4,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF334155),
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: 'Add a description…',
          hintStyle: GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildAssigneeField() {
    return _buildCard(
      TextFormField(
        controller: _assigneeController,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF334155),
        ),
        decoration: InputDecoration(
          hintText: 'Assignee name…',
          hintStyle: GoogleFonts.inter(color: const Color(0xFFCBD5E1)),
          prefixIcon: const Icon(Icons.person_outline_rounded,
              color: Color(0xFF0D9488), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ─── Priority Picker ────────────────────────────────────────────────────────

  Widget _buildPriorityPicker() {
    return Row(
      children: ['Easy', 'Medium', 'Hard'].map((p) {
        final isActive = _selectedPriority == p;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedPriority = p),
              child: Stack(
                children: [
                  Positioned.fill(
                    top: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isActive
                            ? _priorityDark(p)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? _priorityColor(p) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive
                            ? _priorityColor(p)
                            : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          p == 'Hard'
                              ? Icons.local_fire_department_rounded
                              : p == 'Medium'
                                  ? Icons.trending_up_rounded
                                  : Icons.spa_rounded,
                          color: isActive ? Colors.white : _priorityColor(p),
                          size: 18,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p,
                          style: GoogleFonts.outfit(
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Status Picker ──────────────────────────────────────────────────────────

  Widget _buildStatusPicker() {
    return Row(
      children: ['Todo', 'In Progress', 'Done'].map((s) {
        final isActive = _selectedStatus == s;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedStatus = s),
              child: Stack(
                children: [
                  Positioned.fill(
                    top: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isActive
                            ? _statusDark(s)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isActive ? _statusColor(s) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isActive
                            ? _statusColor(s)
                            : const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(_statusIcon(s),
                            color: isActive ? Colors.white : _statusColor(s),
                            size: 18),
                        const SizedBox(height: 4),
                        Text(
                          s,
                          style: GoogleFonts.outfit(
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Save Button ────────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Stack(
      children: [
        Positioned.fill(
          top: 7,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF312E81),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        GestureDetector(
          onTap: _saving ? null : _save,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            transform: Matrix4.translationValues(0, _saving ? 7 : 0, 0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: _saving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_rounded,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Save Changes',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// ─── Reusable 3D Slab Button ─────────────────────────────────────────────────

class _Slab3DButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final Color darkColor;

  const _Slab3DButton({
    required this.child,
    required this.onTap,
    this.color = const Color(0xFFF1F5F9),
    this.darkColor = const Color(0xFFCBD5E1),
  });

  @override
  State<_Slab3DButton> createState() => _Slab3DButtonState();
}

class _Slab3DButtonState extends State<_Slab3DButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Stack(
        children: [
          Positioned.fill(
            top: 4,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.darkColor,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.darkColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
