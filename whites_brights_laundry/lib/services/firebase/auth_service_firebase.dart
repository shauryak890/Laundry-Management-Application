import 'package:whites_brights_laundry/services/firebase/firebase_types.dart';
import 'package:flutter/material.dart';
import 'package:whites_brights_laundry/models/user_model.dart';
import 'package:whites_brights_laundry/services/firebase/auth_service.dart';
import 'package:whites_brights_laundry/services/firebase/firebase_service.dart';

class AuthServiceFirebase implements AuthService {
  final dynamic _auth = FirebaseService.instance.auth;
  final dynamic _firestore = FirebaseService.instance.firestore;
  
  // Current user
  User? get _firebaseUser => _auth.currentUser;
  
  @override
  UserModel? get currentUser => _currentUserModel;
  UserModel? _currentUserModel;
  
  @override
  Stream<UserModel?> get authStateChanges => _auth.authStateChanges().asyncMap((user) {
    if (user == null) return null;
    return getUserById(user.uid);
  });
  
  @override
  String? get currentUserId => _firebaseUser?.uid;
  
  @override
  bool get isAuthenticated => _firebaseUser != null;
  
  // Verify phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      debugPrint('Error in verifyPhoneNumber: $e');
      rethrow;
    }
  }
  
  // Sign in with credential
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('Error in signInWithCredential: $e');
      rethrow;
    }
  }
  
  // Sign in with email and password - required by AuthService
  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        final userModel = await getUserById(userCredential.user!.uid);
        if (userModel != null) {
          _currentUserModel = userModel;
          return userModel;
        }
      }
      throw Exception('Failed to sign in');
    } catch (e) {
      debugPrint('Error in signInWithEmailAndPassword: $e');
      rethrow;
    }
  }
  
  // Sign up with email and password - required by AuthService
  @override
  Future<UserModel> signUpWithEmailAndPassword(String email, String password, String name, String phoneNumber) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Create user profile in Firestore
        final userModel = await createOrUpdateUser(
          name: name,
          phoneNumber: phoneNumber,
          email: email,
        );
        _currentUserModel = userModel;
        return userModel;
      }
      throw Exception('Failed to sign up');
    } catch (e) {
      debugPrint('Error in signUpWithEmailAndPassword: $e');
      rethrow;
    }
  }
  
  // Sign out
  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUserModel = null;
    } catch (e) {
      debugPrint('Error in signOut: $e');
      rethrow;
    }
  }
  
  // Create or update user in Firestore
  @override
  Future<UserModel> createOrUpdateUser({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      if (_firebaseUser == null) {
        throw Exception('No authenticated user found');
      }
      
      final userDoc = _firestore.collection('users').doc(_firebaseUser!.uid);
      final userSnapshot = await userDoc.get();
      
      final now = DateTime.now();
      UserModel userModel;
      
      if (!userSnapshot.exists) {
        // Create new user
        userModel = UserModel(
          id: _firebaseUser!.uid,
          name: name,
          phoneNumber: phoneNumber ?? '',
          email: email,
          createdAt: now,
          updatedAt: now,
        );
        
        await userDoc.set(userModel.toMap());
      } else {
        // Update existing user
        final existingUser = UserModel.fromMap(
          userSnapshot.data() as Map<String, dynamic>
        );
        
        userModel = existingUser.copyWith(
          name: name,
          phoneNumber: phoneNumber ?? existingUser.phoneNumber,
          email: email ?? existingUser.email,
          updatedAt: now,
        );
        
        final updates = <String, dynamic>{
          'name': name,
          'updatedAt': Timestamp.fromDate(now),
        };
        
        if (phoneNumber != null) {
          updates['phoneNumber'] = phoneNumber;
        }
        
        if (email != null) {
          updates['email'] = email;
        }
        
        await userDoc.update(updates);
      }
      
      _currentUserModel = userModel;
      return userModel;
    } catch (e) {
      debugPrint('Error in createOrUpdateUser: $e');
      rethrow;
    }
  }
  
  // Get user data from Firestore
  @override
  Future<UserModel?> getUserData() async {
    try {
      if (_firebaseUser == null) {
        return null;
      }
      
      final userDoc = await _firestore.collection('users').doc(_firebaseUser!.uid).get();
      
      if (!userDoc.exists) {
        return null;
      }
      
      _currentUserModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      return _currentUserModel;
    } catch (e) {
      debugPrint('Error in getUserData: $e');
      return null;
    }
  }
  
  // Get user data stream
  @override
  Stream<UserModel?> getUserDataStream() {
    if (_firebaseUser == null) {
      return Stream.value(null);
    }
    
    return _firestore
        .collection('users')
        .doc(_firebaseUser!.uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      _currentUserModel = UserModel.fromMap(snapshot.data() as Map<String, dynamic>);
      return _currentUserModel;
    });
  }
  
  // Update user data in Firestore
  @override
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
        .collection('users')
        .doc(user.id)
        .update(user.toMap());
      
      if (_firebaseUser?.uid == user.id) {
        _currentUserModel = user;
      }
    } catch (e) {
      debugPrint('Error updating user data: $e');
      rethrow;
    }
  }
  
  // Get user by ID
  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        return null;
      }
      
      return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting user by ID: $e');
      return null;
    }
  }
}
