class CommentModel {
  final String commentId;
  final String taskId;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.commentId,
    required this.taskId,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'commentId': commentId,
      'taskId': taskId,
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['commentId'] ?? '',
      taskId: map['taskId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Unknown',
      text: map['text'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}
