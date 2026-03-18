import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:clash_of_minds/core/constants/app_constants.dart';
import 'package:clash_of_minds/core/error/exceptions.dart';
import 'package:clash_of_minds/features/auth/data/models/user_model.dart';

/// Auth remote data source interface
abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  });
  Future<void> updateDisplayName({
    required String uid,
    required String displayName,
  });
  Future<bool> isDisplayNameUnique(String displayName);
}

/// Auth remote data source implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign-in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw AuthException('Failed to sign in with Google');
      }

      // Check if user exists in Firestore
      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        // Create new user profile with email as temporary display name
        final userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.email!.split('@')[0],
          profilePicture: user.photoURL,
          createdAt: DateTime.now(),
        );

        await firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toJson());

        return userModel;
      }

      return UserModel.fromJson(userDoc.data()!);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Failed to sign in with email');
      }

      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw AuthException('User profile not found');
      }

      return UserModel.fromJson(userDoc.data()!);
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            throw AuthException('No user found with this email');
          case 'wrong-password':
            throw AuthException('Incorrect password');
          case 'invalid-email':
            throw AuthException('Invalid email address');
          case 'user-disabled':
            throw AuthException('This account has been disabled');
          default:
            throw AuthException(e.message ?? 'Sign in failed');
        }
      }
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // NOTE: Display name uniqueness check removed because it requires authentication
      // Display names don't need to be globally unique in this app
      // If uniqueness is needed, check after user creation or update security rules

      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Failed to create account');
      }

      // Create user profile in Firestore
      final userModel = UserModel(
        uid: user.uid,
        email: user.email!,
        displayName: displayName,
        profilePicture: null,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toJson());

      return userModel;
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            throw AuthException('Email already in use');
          case 'invalid-email':
            throw AuthException('Invalid email address');
          case 'weak-password':
            throw AuthException('Password is too weak (min 6 characters)');
          default:
            throw AuthException(e.message ?? 'Sign up failed');
        }
      }
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromJson(userDoc.data()!);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    try {
      final userModel = UserModel(
        uid: uid,
        email: email,
        displayName: displayName,
        profilePicture: null,
        createdAt: DateTime.now(),
      );

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(userModel.toJson());
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> updateDisplayName({
    required String uid,
    required String displayName,
  }) async {
    try {
      // Check if display name is unique (excluding current user)
      final querySnapshot = await firestore
          .collection(AppConstants.usersCollection)
          .where('displayName', isEqualTo: displayName)
          .get();

      // Check if any document belongs to a different user
      final isUsedByOther = querySnapshot.docs.any((doc) => doc.id != uid);
      if (isUsedByOther) {
        throw AuthException(
            'This display name is already taken. Please choose a different one.');
      }

      // Update user's document
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'displayName': displayName});

      // Update all friend documents where this user appears
      // Use collectionGroup to find all user_friends documents with this uid
      final friendDocsQuery = await firestore
          .collectionGroup('user_friends')
          .where('uid', isEqualTo: uid)
          .get();

      // Update each friend document with the new display name
      final batch = firestore.batch();
      for (final doc in friendDocsQuery.docs) {
        batch.update(doc.reference, {'displayName': displayName});
      }
      await batch.commit();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(e.toString());
    }
  }

  @override
  Future<bool> isDisplayNameUnique(String displayName) async {
    try {
      final querySnapshot = await firestore
          .collection(AppConstants.usersCollection)
          .where('displayName', isEqualTo: displayName)
          .get();

      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}
