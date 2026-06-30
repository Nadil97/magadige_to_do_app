class TaskModel {
  final String id;
  final String title;
  final String description;
  final String status; // 'Todo', 'In Progress', 'Done'
  final String assignedTo;
  final DateTime createdAt;
  final int stairIndex;
  final String priority; // 'Easy', 'Medium', 'Hard'

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.assignedTo,
    required this.createdAt,
    required this.stairIndex,
    required this.priority,
  });

  bool get isCompleted => status == 'Done';

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? assignedTo,
    DateTime? createdAt,
    int? stairIndex,
    String? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      stairIndex: stairIndex ?? this.stairIndex,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'assignedTo': assignedTo,
      'createdAt': createdAt.toIso8601String(),
      'stairIndex': stairIndex,
      'priority': priority,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'Todo',
      assignedTo: map['assignedTo'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      stairIndex: map['stairIndex'] ?? 0,
      priority: map['priority'] ?? 'Medium',
    );
  }
}
