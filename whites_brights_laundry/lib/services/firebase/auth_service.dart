import 'package:whites_brights_laundry/models/user_model.dart';

/// Abstract class defining the interface for authentication services
abstract class AuthService {
  // Authentication state
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
  String? get currentUserId;
  bool get isAuthenticated;
  
  // Authentication methods
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password, String name, String phoneNumber);
  Future<void> signOut();
  
  // User data methods
  Future<UserModel?> getUserData();
  Stream<UserModel?> getUserDataStream();
  Future<UserModel> createOrUpdateUser({
    required String name,
    String? email,
    String? phoneNumber,
  });
  Future<void> updateUserData(UserModel user);
  Future<UserModel?> getUserById(String userId);
}
