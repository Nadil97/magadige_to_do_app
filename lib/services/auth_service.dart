import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserFromFirestore(firebaseUser.uid);
    });
  }

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
    return null;
  }

  // Login
  Future<UserModel> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userModel = await _getUserFromFirestore(userCredential.user!.uid);
      if (userModel == null) {
        throw Exception('User data not found in database.');
      }
      return userModel;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up
  Future<UserModel> signUp(String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = userCredential.user!.uid;
      
      final newUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
        currentStep: 0,
        level: 1,
        points: 0,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());
      
      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  bool _isGoogleInitialized = false;

  // Google Sign-In
  Future<UserModel> signInWithGoogle() async {
    try {
      if (!_isGoogleInitialized) {
        await GoogleSignIn.instance.initialize();
        _isGoogleInitialized = true;
      }
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final firebase_auth.OAuthCredential credential =
          firebase_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      final uid = userCredential.user!.uid;

      // Check if user exists
      final existingUser = await _getUserFromFirestore(uid);
      if (existingUser != null) {
        return existingUser;
      }

      // Create new user in Firestore
      final newUser = UserModel(
        uid: uid,
        name: userCredential.user!.displayName ?? 'Google User',
        email: userCredential.user!.email ?? '',
        createdAt: DateTime.now(),
        currentStep: 0,
        level: 1,
        points: 0,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());

      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  // Change Password (requires reauthentication)
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No authenticated user found.');
    }
    
    final credential = firebase_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  UserModel? get currentUser {
    return null;
  }
}
