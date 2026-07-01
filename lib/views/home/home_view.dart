import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task_model.dart';
import '../widgets/zigzag_task_list.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_dialog.dart';
import '../../core/theme/app_theme.dart';

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
      _buildStaircaseTab(context, tasksAsync, taskController, level, points, currentLevelXp),
      // Tab 2: Checklist & Manage
      _buildChecklistTab(context, tasksAsync, taskController, tasks, completedTasks),
    ];

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: Text(
          'Roadmap Planner',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: AppTheme.cardBg,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.black54),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
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
        // Clean XP Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      ),
                      Text(
                        '$points XP Total',
                        style: const TextStyle(color: Colors.black45, fontSize: 12),
                      ),
                    ],
                  ),
                  Text(
                    '$currentLevelXp/100 XP',
                    style: const TextStyle(color: AppTheme.colorPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: currentLevelXp / 100.0,
                  minHeight: 6,
                  backgroundColor: Colors.black12,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.colorPrimary),
                ),
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
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: tasksAsync.when(
                data: (list) => ZigZagTaskList(
                  tasks: list,
                  onTaskTap: (task) => _showTaskDetails(context, task, taskController),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text(
                '${completedTasks.length}/${tasks.length} Done',
                style: const TextStyle(color: AppTheme.colorSecondary, fontWeight: FontWeight.bold, fontSize: 13),
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
                  return TaskCard(
                    task: task,
                    onStatusChange: (status) {
                      taskController.updateStatus(task.id, status);
                    },
                    onDelete: () {
                      taskController.deleteTask(task.id);
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

  void _showTaskDetails(BuildContext context, TaskModel task, TaskController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  task.description.isEmpty ? 'No description provided.' : task.description,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Priority: ${task.priority}', style: const TextStyle(color: AppTheme.colorSecondary, fontWeight: FontWeight.bold)),
                    Text('Assigned to: ${task.assignedTo}', style: const TextStyle(color: Colors.black45)),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Status Select Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['Todo', 'In Progress', 'Done'].map((status) {
                    final isActive = task.status == status;
                    return ElevatedButton(
                      onPressed: () {
                        controller.updateStatus(task.id, status);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? AppTheme.colorPrimary : Colors.black12,
                        foregroundColor: isActive ? Colors.white : Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(status),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
