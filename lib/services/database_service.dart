import '../models/task_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  // In-memory list for mock tasks
  static final List<TaskModel> _mockTasks = [
    TaskModel(
      id: 'task_1',
      title: 'Design Staircase To-Do App UI',
      description: 'Create a next-level responsive staircase path UI design with clean solid colors',
      status: 'Done',
      assignedTo: 'Nadil Sandaruwan',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      stairIndex: 0,
      priority: 'Hard',
    ),
    TaskModel(
      id: 'task_2',
      title: 'Setup Flutter Riverpod Architecture',
      description: 'Install dependencies and structure controllers, providers, and services',
      status: 'In Progress',
      assignedTo: 'Nadil Sandaruwan',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      stairIndex: 1,
      priority: 'Medium',
    ),
    TaskModel(
      id: 'task_3',
      title: 'Integrate Local State Management',
      description: 'Connect Riverpod state providers and link to custom staircase view',
      status: 'Todo',
      assignedTo: 'Nadil Sandaruwan',
      createdAt: DateTime.now(),
      stairIndex: 2,
      priority: 'Hard',
    ),
    TaskModel(
      id: 'task_4',
      title: 'Implement Interactive Custom Staircase Painter',
      description: 'Draw premium steps with custom animations and details',
      status: 'Todo',
      assignedTo: 'Nadil Sandaruwan',
      createdAt: DateTime.now(),
      stairIndex: 3,
      priority: 'Medium',
    ),
  ];

  // Fetch all tasks for assigned user
  Stream<List<TaskModel>> getTasks(String userDisplayName) {
    return Stream.periodic(const Duration(milliseconds: 300), (_) {
      return _mockTasks.toList();
    }).asBroadcastStream();
  }

  // Create Task
  Future<void> createTask(TaskModel task) async {
    _mockTasks.add(task);
  }

  // Update Task Status
  Future<void> updateTaskStatus(String taskId, String status) async {
    final index = _mockTasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _mockTasks[index] = _mockTasks[index].copyWith(status: status);
    }
  }

  // Edit Task
  Future<void> updateTask(TaskModel task) async {
    final index = _mockTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _mockTasks[index] = task;
    }
  }

  // Delete Task
  Future<void> deleteTask(String taskId) async {
    _mockTasks.removeWhere((t) => t.id == taskId);
  }

  // Fetch list of members to assign tasks to
  Future<List<String>> getAssignees() async {
    return ['Nadil Sandaruwan', 'Antigravity', 'UI Designer', 'Tester'];
  }

  // Update user score/level based on current climbing steps
  Future<void> updateUserProgress(UserModel user) async {
    // Local-only progress updates
  }
}
