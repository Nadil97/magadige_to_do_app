import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../core/utils/notifications.dart';

class AddTaskDialog extends ConsumerStatefulWidget {
  final int nextStairIndex;
  final TaskModel? taskToEdit;
  const AddTaskDialog({
    super.key,
    required this.nextStairIndex,
    this.taskToEdit,
  });

  @override
  ConsumerState<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedPriority = 'Medium';
  String _selectedAssigneeId = '';

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descController.text = widget.taskToEdit!.description;
      _selectedPriority = widget.taskToEdit!.priority;
      _selectedAssigneeId = widget.taskToEdit!.assignedTo.firstOrNull ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final authUser = ref.read(authStateProvider).value;
      final currentUserId = authUser?.uid ?? '';

      if (widget.taskToEdit != null) {
        final updatedTask = widget.taskToEdit!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          priority: _selectedPriority,
          assignedTo: [_selectedAssigneeId],
        );
        await ref.read(taskControllerProvider.notifier).updateTask(updatedTask);
      } else {
        await ref
            .read(taskControllerProvider.notifier)
            .addTask(
              title: _titleController.text.trim(),
              description: _descController.text.trim(),
              priority: _selectedPriority,
              assignedTo: _selectedAssigneeId,
              stairIndex: widget.nextStairIndex,
              authorId: currentUserId,
            );
      }

      final taskState = ref.read(taskControllerProvider);
      if (mounted) {
        setState(() => _isSaving = false);
        if (taskState.hasError) {
          AppNotifications.showError(context, taskState.error.toString());
        } else {
          AppNotifications.showSuccess(
            context,
            widget.taskToEdit != null
                ? 'Task updated successfully!'
                : 'Task created successfully!',
          );
          Navigator.pop(context);
        }
      }
    }
  }

  Widget _buildFieldCard(Widget child) {
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

  @override
  Widget build(BuildContext context) {
    final assigneesAsync = ref.watch(assigneeListProvider);
    final isEditing = widget.taskToEdit != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isEditing
                              ? Icons.edit_note_rounded
                              : Icons.add_task_rounded,
                          color: const Color(0xFF4F46E5),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Edit Task' : 'New Task',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF64748B),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Form Body ───────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFieldCard(
                        TextFormField(
                          controller: _titleController,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Task Title',
                            hintStyle: GoogleFonts.outfit(
                              color: const Color(0xFFCBD5E1),
                            ),
                            prefixIcon: const Icon(
                              Icons.title_rounded,
                              color: Color(0xFF6366F1),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          validator: (val) => (val == null || val.isEmpty)
                              ? 'Enter a title'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFieldCard(
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF334155),
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Description (optional)',
                            hintStyle: GoogleFonts.inter(
                              color: const Color(0xFFCBD5E1),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dropdowns Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildFieldCard(
                              DropdownButtonFormField<String>(
                                value: _selectedPriority,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.flag_rounded,
                                    color: Color(0xFFF59E0B),
                                    size: 18,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(right: 12),
                                ),
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF1E293B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                dropdownColor: Colors.white,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF94A3B8),
                                ),
                                items: ['Easy', 'Medium', 'Hard'].map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text(p),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null)
                                    setState(() => _selectedPriority = val);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFieldCard(
                              assigneesAsync.when(
                                data: (list) {
                                  if (!list.any(
                                    (u) => u.uid == _selectedAssigneeId,
                                  )) {
                                    final authUser = ref
                                        .read(authStateProvider)
                                        .value;
                                    final currentUserId = authUser?.uid ?? '';
                                    if (list.any(
                                      (u) => u.uid == currentUserId,
                                    )) {
                                      _selectedAssigneeId = currentUserId;
                                    } else if (list.isNotEmpty) {
                                      _selectedAssigneeId = list.first.uid;
                                    }
                                  }
                                  return DropdownButtonFormField<String>(
                                    // value: _selectedAssigneeId.isEmpty ? null : _selectedAssigneeId,
                                    // decoration: const InputDecoration(
                                    //   prefixIcon: Icon(Icons.person_outline_rounded, color: Color(0xFF10B981), size: 18),
                                    //   border: InputBorder.none,
                                    //   contentPadding: EdgeInsets.only(right: 12),
                                    // ),
                                    // style: GoogleFonts.outfit(
                                    //   color: const Color(0xFF1E293B),
                                    //   fontWeight: FontWeight.bold,
                                    //   fontSize: 13,
                                    // ),
                                    // dropdownColor: Colors.white,
                                    // icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
                                    // items: list.map((user) {
                                    //   return DropdownMenuItem(value: user.uid, child: Text(user.name));
                                    // }).toList(),
                                    // onChanged: (val) {
                                    //   if (val != null) setState(() => _selectedAssigneeId = val);
                                    // },
                                    value: _selectedAssigneeId.isEmpty
                                        ? null
                                        : _selectedAssigneeId,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.person_outline_rounded,
                                        color: Color(0xFF10B981),
                                        size: 18,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(
                                        right: 12,
                                      ),
                                    ),
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF1E293B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    dropdownColor: Colors.white,
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Color(0xFF94A3B8),
                                    ),
                                    items: list.map((user) {
                                      return DropdownMenuItem(
                                        value: user.uid,
                                        child: Text(
                                          user.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null)
                                        setState(
                                          () => _selectedAssigneeId = val,
                                        );
                                    },
                                  );
                                },
                                loading: () => const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                error: (_, __) => const SizedBox(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      _SubmitButton(
                        isEditing: isEditing,
                        isSaving: _isSaving,
                        onTap: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatefulWidget {
  final bool isEditing;
  final bool isSaving;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.isEditing,
    required this.isSaving,
    required this.onTap,
  });

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.isSaving) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Stack(
        children: [
          Positioned.fill(
            top: 6,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF312E81),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            transform: Matrix4.translationValues(
              0,
              _pressed || widget.isSaving ? 6 : 0,
              0,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!_pressed && !widget.isSaving)
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            alignment: Alignment.center,
            child: widget.isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    widget.isEditing ? 'Save Changes' : 'Add Task to Stairs',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
