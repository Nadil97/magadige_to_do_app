import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../auth/landing_view.dart';
import '../../providers/task_provider.dart';
import '../../core/utils/notifications.dart';
import '../../models/task_model.dart';
import '../widgets/zigzag_task_list.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_dialog.dart';
import '../../core/theme/app_theme.dart';
import 'profile_view.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskListStreamProvider);
    final taskController = ref.read(taskControllerProvider.notifier);

    final tasks = tasksAsync.value ?? [];
    final completedTasks = tasks.where((t) => t.status == 'Done').toList();

    // XP and Levels based on completed status
    final points = completedTasks.length * 20;
    final level = (points / 100).floor() + 1;
    final currentLevelXp = points % 100;

    final List<Widget> tabs = [
      // Tab 1: Staircase View
      _buildStaircaseTab(
        context,
        tasksAsync,
        taskController,
        level,
        points,
        currentLevelXp,
      ),
      // Tab 2: Checklist & Manage
      _buildChecklistTab(
        context,
        tasksAsync,
        taskController,
        tasks,
        completedTasks,
      ),
      // Tab 3: Profile
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: _currentIndex == 2
          ? null
          : AppBar(
              title: Text(
                'Roadmap Planner',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              backgroundColor: AppTheme.cardBg,
              elevation: 0,
            ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppTheme.colorPrimary,
        unselectedItemColor: Colors.black38,
        backgroundColor: AppTheme.cardBg,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.alt_route_outlined),
            activeIcon: Icon(Icons.alt_route),
            label: 'Roadmap View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add_check_outlined),
            activeIcon: Icon(Icons.playlist_add_check),
            label: 'Task Checklist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddTaskDialog(nextStairIndex: tasks.length),
          );
        },
        backgroundColor: AppTheme.colorPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, size: 24),
      ),
    );
  }

  Widget _buildStaircaseTab(
    BuildContext context,
    AsyncValue<List<TaskModel>> tasksAsync,
    TaskController taskController,
    int level,
    int points,
    int currentLevelXp,
  ) {
    return Column(
      children: [
        // Clean XP Card -> Upgraded to 3D Premium Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.colorPrimary.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              const BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Level $level',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$points XP Total',
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.colorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$currentLevelXp / 100 XP',
                      style: const TextStyle(
                        color: AppTheme.colorPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 3D Progress Bar
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(
                  begin: 0.0,
                  end: (currentLevelXp / 100.0).clamp(0.0, 1.0),
                ),
                builder: (context, value, child) {
                  return Container(
                    height: 18,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E5EC), // Neumorphic grey base
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.colorSecondary,
                              AppTheme.colorPrimary,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.colorPrimary.withOpacity(0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        // Inner reflection for 3D glossy look
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 6,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // Staircase Interactive Graphic
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: tasksAsync.when(
                data: (list) => ZigZagTaskList(
                  tasks: list,
                  onTaskTap: (task) => _showTaskDetailsBottomSheet(
                    context,
                    task,
                    taskController,
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildChecklistTab(
    BuildContext context,
    AsyncValue<List<TaskModel>> tasksAsync,
    TaskController taskController,
    List<TaskModel> tasks,
    List<TaskModel> completedTasks,
  ) {
    return Column(
      children: [
        // Status checklist header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manage Checklist Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${completedTasks.length}/${tasks.length} Done',
                style: const TextStyle(
                  color: AppTheme.colorSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: tasksAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'No steps created yet. Click + to add steps.',
                    style: TextStyle(color: Colors.black38),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final task = list[index];
                  final authUser = ref.watch(authStateProvider).value;
                  final isAuthor = authUser?.uid == task.authorId;

                  // 🌟 REMOVED: Wate thibba GestureDetector eka ain kala, kelinma TaskCard eka return කරනවා
                  return TaskCard(
                    task: task,
                    onEdit: isAuthor ? () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            AddTaskDialog(nextStairIndex: 0, taskToEdit: task),
                      );
                    } : null,
                    onStatusChange: (status) {
                      taskController.updateStatus(task.id, status);
                    },
                    onDelete: isAuthor ? () async {
                      await taskController.deleteTask(task.id);
                      final taskState = ref.read(taskControllerProvider);
                      if (context.mounted) {
                        if (taskState.hasError) {
                          AppNotifications.showError(
                            context,
                            taskState.error.toString(),
                          );
                        } else {
                          AppNotifications.showSuccess(
                            context,
                            'Task deleted successfully!',
                          );
                        }
                      }
                    } : null,
                    // 🌟 ADDED: Aluth onView parameter eka methanadi pass kala
                    onView: () {
                      _showTaskDetailsBottomSheet(
                        context,
                        task,
                        taskController,
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  void _showTaskDetailsBottomSheet(
    BuildContext context,
    TaskModel task,
    TaskController controller,
  ) {
    Color statusColor;
    Color statusDarkColor;
    switch (task.status) {
      case 'Done':
        statusColor = const Color(0xFF10B981);
        statusDarkColor = const Color(0xFF065F46);
        break;
      case 'In Progress':
        statusColor = const Color(0xFFF59E0B);
        statusDarkColor = const Color(0xFF78350F);
        break;
      default:
        statusColor = const Color(0xFF3B82F6);
        statusDarkColor = const Color(0xFF1E3A8A);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Padding(
              // Padding eka bottom ekata 'mediaQuery viewInsets' damma coding scene ekedi keyboard eka up unama content eka push wenna
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                // Meka thama scroll eka denne
                physics:
                    const BouncingScrollPhysics(), // Premium smooth look ekak enna
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Header with Status and Title
                    Stack(
                      children: [
                        Positioned.fill(
                          top: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: statusDarkColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  task.status.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. Description Section
                    if (task.description.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          task.description,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF334155),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 4. Update Status Options
                    Text(
                      'Update Status (Process)',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF334155),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: ['Todo', 'In Progress', 'Done'].map((status) {
                        final isActive = task.status == status;
                        Color btnColor;
                        Color btnDark;
                        switch (status) {
                          case 'Done':
                            btnColor = const Color(0xFF10B981);
                            btnDark = const Color(0xFF065F46);
                            break;
                          case 'In Progress':
                            btnColor = const Color(0xFFF59E0B);
                            btnDark = const Color(0xFF78350F);
                            break;
                          default:
                            btnColor = const Color(0xFF3B82F6);
                            btnDark = const Color(0xFF1E3A8A);
                        }

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () {
                                if (task.status != 'Done' && status == 'Done') {
                                  _showCompletionCommentDialog(
                                    context,
                                    task,
                                    controller,
                                  );
                                } else {
                                  controller.updateStatus(task.id, status);
                                  Navigator.pop(context);
                                }
                              },
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    top: 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isActive
                                            ? btnDark
                                            : const Color(0xFFCBD5E1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive ? btnColor : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isActive
                                            ? btnColor
                                            : const Color(0xFFE2E8F0),
                                        width: 1.5,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      status,
                                      style: GoogleFonts.outfit(
                                        color: isActive
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCompletionCommentDialog(
    BuildContext context,
    TaskModel task,
    TaskController controller,
  ) {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Complete Task',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Would you like to add a completion comment before marking this as Done?',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your comment here (optional)...',
                  hintStyle: GoogleFonts.inter(fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF10B981),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final text = commentController.text.trim();
                
                // Show loading indicator
                showDialog(
                  context: dialogContext,
                  barrierDismissible: false,
                  builder: (ctx) => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                );
                
                if (text.isNotEmpty) {
                  // Use authStateProvider which holds the active user stream
                  final authUser = ref.read(authStateProvider).value;
                  if (authUser != null) {
                    await ref.read(commentControllerProvider.notifier).addComment(
                      taskId: task.id,
                      authorId: authUser.uid,
                      authorName: authUser.name,
                      text: text,
                    );
                  }
                }
                await controller.updateStatus(task.id, 'Done');
                
                if (context.mounted) {
                  Navigator.pop(dialogContext); // Close loading indicator
                  Navigator.pop(dialogContext); // Close comment dialog
                  Navigator.pop(context); // Close bottom sheet
                }
              },
              child: const Text('Mark as Done'),
            ),
          ],
        );
      },
    );
  }
}
