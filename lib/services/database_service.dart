import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all tasks for assigned user
  Stream<List<TaskModel>> getTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('assignedTo', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data()))
              .toList();
        });
  }

  // Create Task
  Future<void> createTask(TaskModel task) async {
    await _firestore.collection('tasks').doc(task.id).set(task.toMap());
  }

  // Update Task Status
  Future<void> updateTaskStatus(String taskId, String status) async {
    String dbStatus;
    if (status == 'In Progress') {
      dbStatus = 'in_progress';
    } else {
      dbStatus = status.toLowerCase();
    }

    await _firestore.collection('tasks').doc(taskId).update({
      'status': dbStatus,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  // Edit Task
  Future<void> updateTask(TaskModel task) async {
    await _firestore.collection('tasks').doc(task.id).update(task.toMap());
  }

  // Delete Task
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  // Fetch list of members to assign tasks to
  Future<List<UserModel>> getAssignees() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error fetching assignees: $e');
      return [];
    }
  }

  // Update user score/level based on current climbing steps
  Future<void> updateUserProgress(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toMap());
  }
}
