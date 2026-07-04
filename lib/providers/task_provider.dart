import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());

final taskListStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final authUser = ref.watch(authStateProvider).value;
  final name = authUser?.name ?? 'Nadil Sandaruwan';
  return dbService.getTasks(name);
});

final assigneeListProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(databaseServiceProvider).getAssignees();
});

class TaskController extends StateNotifier<AsyncValue<void>> {
  final DatabaseService _dbService;

  TaskController(this._dbService) : super(const AsyncValue.data(null));

  Future<void> addTask({
    required String title,
    required String description,
    required String priority,
    required String assignedTo,
    required int stairIndex,
  }) async {
    state = const AsyncValue.loading();
    try {
      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        status: 'Todo',
        assignedTo: assignedTo,
        createdAt: DateTime.now(),
        stairIndex: stairIndex,
        priority: priority,
      );
      await _dbService.createTask(task);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateStatus(String taskId, String status) async {
    try {
      await _dbService.updateTaskStatus(taskId, status);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTask(TaskModel task) async {
    try {
      await _dbService.updateTask(task);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _dbService.deleteTask(taskId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final taskControllerProvider =
    StateNotifierProvider<TaskController, AsyncValue<void>>((ref) {
  return TaskController(ref.watch(databaseServiceProvider));
});
