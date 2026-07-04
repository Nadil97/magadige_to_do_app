import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../models/comment_model.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());

final taskListStreamProvider = StreamProvider<List<TaskModel>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value([]);
  return dbService.getTasks(authUser.uid);
});

final assigneeListProvider = FutureProvider<List<UserModel>>((ref) async {
  return ref.watch(databaseServiceProvider).getAssignees();
});

final userMapProvider = FutureProvider<Map<String, String>>((ref) async {
  try {
    final assignees = await ref.watch(assigneeListProvider.future);
    return {for (var user in assignees) user.uid: user.name};
  } catch (e) {
    return {};
  }
});

class TaskController extends StateNotifier<AsyncValue<void>> {
  final DatabaseService _dbService;

  TaskController(this._dbService) : super(const AsyncValue.data(null));

  Future<void> addTask({
    required String title,
    required String description,
    required String priority,
    required String assignedTo, // Selected assignee ID
    required int stairIndex,
    required String authorId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final task = TaskModel(
        id: 'tsk_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        status: 'Todo',
        assignedTo: [assignedTo],
        authorId: authorId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
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
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      await _dbService.updateTask(updatedTask);
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

// ─── Comment Providers ───────────────────────────────────────────────────────

/// Stream of comments for a given taskId
final commentsStreamProvider =
    StreamProvider.family<List<CommentModel>, String>((ref, taskId) {
  return ref.watch(databaseServiceProvider).getComments(taskId);
});

class CommentController extends StateNotifier<AsyncValue<void>> {
  final DatabaseService _dbService;

  CommentController(this._dbService) : super(const AsyncValue.data(null));

  Future<void> addComment({
    required String taskId,
    required String authorId,
    required String authorName,
    required String text,
  }) async {
    state = const AsyncValue.loading();
    try {
      final comment = CommentModel(
        commentId: 'cmt_${DateTime.now().millisecondsSinceEpoch}',
        taskId: taskId,
        authorId: authorId,
        authorName: authorName,
        text: text,
        createdAt: DateTime.now(),
      );
      await _dbService.addComment(comment);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteComment(String taskId, String commentId) async {
    state = const AsyncValue.loading();
    try {
      await _dbService.deleteComment(taskId, commentId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final commentControllerProvider =
    StateNotifierProvider<CommentController, AsyncValue<void>>((ref) {
  return CommentController(ref.watch(databaseServiceProvider));
});
