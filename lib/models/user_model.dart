class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;
  final int currentStep;
  final int level;
  final int points;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.currentStep,
    required this.level,
    required this.points,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    DateTime? createdAt,
    int? currentStep,
    int? level,
    int? points,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      currentStep: currentStep ?? this.currentStep,
      level: level ?? this.level,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'currentStep': currentStep,
      'level': level,
      'points': points,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? 'User',
      email: map['email'] ?? '',
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
      currentStep: map['currentStep'] ?? 0,
      level: map['level'] ?? 1,
      points: map['points'] ?? 0,
    );
  }
}
