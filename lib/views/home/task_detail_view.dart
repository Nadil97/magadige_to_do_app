import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/task_model.dart';
import '../../models/comment_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/notifications.dart';

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
  late TextEditingController _commentController;
  late String _selectedAssigneeId;
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
    _commentController = TextEditingController();
    _selectedAssigneeId = widget.task.assignedTo.firstOrNull ?? '';
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
    _commentController.dispose();
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
      assignedTo: [_selectedAssigneeId],
      status: _selectedStatus,
      priority: _selectedPriority,
    );

    await ref.read(taskControllerProvider.notifier).updateTask(updated);
    final taskState = ref.read(taskControllerProvider);

    if (mounted) {
      setState(() => _saving = false);
      if (taskState.hasError) {
        AppNotifications.showError(context, taskState.error.toString());
      } else {
        AppNotifications.showSuccess(context, 'Task updated successfully!');
        Navigator.pop(context);
      }
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
                      // Comments — shown only when task is Done
                      if (_selectedStatus == 'Done') ..._buildCommentsSection(),
                      const SizedBox(height: 40),
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
                  final taskState = ref.read(taskControllerProvider);
                  if (mounted) {
                    if (taskState.hasError) {
                      AppNotifications.showError(context, taskState.error.toString());
                    } else {
                      AppNotifications.showSuccess(context, 'Task deleted successfully!');
                      Navigator.pop(context);
                    }
                  }
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
    final assigneesAsync = ref.watch(assigneeListProvider);
    return _buildCard(
      assigneesAsync.when(
        data: (list) {
          if (!list.any((u) => u.uid == _selectedAssigneeId) && list.isNotEmpty) {
            _selectedAssigneeId = list.first.uid;
          }
          return DropdownButtonFormField<String>(
            value: _selectedAssigneeId.isEmpty ? null : _selectedAssigneeId,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person_outline_rounded, color: Color(0xFF0D9488), size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(right: 12),
            ),
            style: GoogleFonts.inter(
              color: const Color(0xFF334155),
              fontSize: 14,
            ),
            dropdownColor: Colors.white,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
            items: list.map((user) {
              return DropdownMenuItem(value: user.uid, child: Text(user.name));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedAssigneeId = val);
              }
            },
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(12),
          child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
        error: (_, __) => const SizedBox(),
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

  // ─── Comments Section (shown when status == Done) ─────────────────────────

  List<Widget> _buildCommentsSection() {
    final commentsAsync = ref.watch(commentsStreamProvider(widget.task.id));
    final commentState = ref.watch(commentControllerProvider);
    final isSendingComment = commentState.isLoading;
    final authUser = ref.watch(authStateProvider).value;
    final userMap = ref.watch(userMapProvider).value ?? {};
    final myName = userMap[authUser?.uid ?? ''] ?? 'Me';

    return [
      const SizedBox(height: 32),
      // Section header
      Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF10B981), Color(0xFF047857)],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Comments',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(width: 8),
          commentsAsync.when(
            data: (list) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${list.length}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF059669),
                ),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Comment input field
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.chat_bubble_outline_rounded,
                color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _commentController,
                enabled: !isSendingComment,
                maxLines: 1,
                style: GoogleFonts.inter(
                  color: const Color(0xFF1E293B),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Add a completion note…',
                  hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (_) async => _submitComment(authUser, myName),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isSendingComment
                  ? null
                  : () => _submitComment(authUser, myName),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(6),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSendingComment
                        ? [const Color(0xFF94A3B8), const Color(0xFF64748B)]
                        : [const Color(0xFF10B981), const Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    if (!isSendingComment)
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: isSendingComment
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Comment list
      commentsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF10B981)),
          ),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text('Could not load comments: $e',
              style: GoogleFonts.inter(
                  color: const Color(0xFFEF4444), fontSize: 13)),
        ),
        data: (comments) {
          if (comments.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: 36,
                      color: const Color(0xFF94A3B8).withOpacity(0.6)),
                  const SizedBox(height: 8),
                  Text(
                    'No comments yet.\nBe the first to leave a note!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: comments
                .map((c) => _buildCommentCard(c, authUser?.uid))
                .toList(),
          );
        },
      ),
    ];
  }

  Future<void> _submitComment(dynamic authUser, String myName) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    _commentController.clear();
    await ref.read(commentControllerProvider.notifier).addComment(
          taskId: widget.task.id,
          authorId: authUser?.uid ?? '',
          authorName: myName,
          text: text,
        );
    final state = ref.read(commentControllerProvider);
    if (mounted && state.hasError) {
      AppNotifications.showError(context, 'Failed to post comment.');
    }
  }

  Widget _buildCommentCard(CommentModel comment, String? myUid) {
    final isMe = comment.authorId == myUid;
    final time = _formatTime(comment.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe
              ? const Color(0xFF10B981).withOpacity(0.3)
              : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isMe
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    comment.authorName.isNotEmpty
                        ? comment.authorName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMe ? '${comment.authorName} (You)' : comment.authorName,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        time,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete button — only for own comments
                if (isMe)
                  GestureDetector(
                    onTap: () async {
                      await ref
                          .read(commentControllerProvider.notifier)
                          .deleteComment(widget.task.id, comment.commentId);
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 15, color: Color(0xFFEF4444)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              comment.text,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF334155),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
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
