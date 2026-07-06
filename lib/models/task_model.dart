class TaskModel {
  final String id; // Maps to taskId in Firestore
  final String title;
  final String description;
  final String status; // 'Todo', 'In Progress', 'Done' internally
  final String authorId;
  final List<String> assignedTo; 
  final DateTime createdAt;
  final DateTime updatedAt;
  final int stairIndex;
  final String priority; // 'Easy', 'Medium', 'Hard'

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.authorId,
    required this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    required this.stairIndex,
    required this.priority,
  });

  bool get isCompleted => status == 'Done';

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? authorId,
    List<String>? assignedTo,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? stairIndex,
    String? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      authorId: authorId ?? this.authorId,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stairIndex: stairIndex ?? this.stairIndex,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    String dbStatus;
    if (status == 'In Progress') {
      dbStatus = 'in_progress';
    } else {
      dbStatus = status.toLowerCase();
    }

    return {
      'taskId': id,
      'title': title,
      'description': description,
      'status': dbStatus,
      'authorId': authorId,
      'assignedTo': assignedTo,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'stairIndex': stairIndex,
      'priority': priority,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    String internalStatus = 'Todo';
    final dbStatus = map['status'] ?? 'todo';
    if (dbStatus == 'in_progress') {
      internalStatus = 'In Progress';
    } else if (dbStatus == 'done') {
      internalStatus = 'Done';
    } else if (dbStatus == 'todo') {
      internalStatus = 'Todo';
    }

    return TaskModel(
      id: map['taskId'] ?? map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: internalStatus,
      authorId: map['authorId'] ?? '',
      assignedTo: List<String>.from(map['assignedTo'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      stairIndex: map['stairIndex'] ?? 0,
      priority: map['priority'] ?? 'Medium',
    );
  }
}
