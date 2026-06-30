import '../models/user_model.dart';

class AuthService {
  // Always true now since Firebase is removed
  static const bool useMock = true;
  
  static UserModel? _mockUser = UserModel(
    uid: 'mock_uid_123',
    email: 'nadil@gmail.com',
    displayName: 'Nadil Sandaruwan',
    currentStep: 2,
    level: 1,
    points: 50,
  );
  
  static final List<Map<String, String>> _mockRegisteredUsers = [
    {'email': 'test@test.com', 'password': 'password123', 'name': 'Stair Master'}
  ];

  static void enableMockMode() {
    print("ℹ️ Running in Local Mock Mode (Firebase completely removed).");
  }

  // Stream of auth changes
  Stream<UserModel?> get authStateChanges {
    return Stream.value(_mockUser);
  }

  // Login
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final userMap = _mockRegisteredUsers.firstWhere(
      (u) => u['email'] == email && u['password'] == password,
      orElse: () => throw Exception('Incorrect email or password'),
    );
    
    _mockUser = UserModel(
      uid: 'mock_uid_${email.hashCode}',
      email: email,
      displayName: userMap['name'] ?? 'Stair Climber',
      currentStep: 2,
      level: 1,
      points: 50,
    );
    return _mockUser!;
  }

  // Sign up
  Future<UserModel> signUp(String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_mockRegisteredUsers.any((u) => u['email'] == email)) {
      throw Exception('Email already exists');
    }
    
    _mockRegisteredUsers.add({
      'email': email,
      'password': password,
      'name': name,
    });
    
    _mockUser = UserModel(
      uid: 'mock_uid_${email.hashCode}',
      email: email,
      displayName: name,
      currentStep: 0,
      level: 1,
      points: 0,
    );
    return _mockUser!;
  }

  // Logout
  Future<void> signOut() async {
    _mockUser = null;
  }

  UserModel? get currentUser {
    return _mockUser;
  }
}
