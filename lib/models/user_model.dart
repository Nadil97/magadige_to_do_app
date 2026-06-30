class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final int currentStep;
  final int level;
  final int points;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.currentStep,
    required this.level,
    required this.points,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    int? currentStep,
    int? level,
    int? points,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      currentStep: currentStep ?? this.currentStep,
      level: level ?? this.level,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'currentStep': currentStep,
      'level': level,
      'points': points,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Stair Climber',
      currentStep: map['currentStep'] ?? 0,
      level: map['level'] ?? 1,
      points: map['points'] ?? 0,
    );
  }
}
