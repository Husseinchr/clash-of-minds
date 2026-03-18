import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/auth/domain/entities/user_entity.dart';

/// Auth repository interface
abstract class AuthRepository {
  /// Sign in with Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign in with email and password
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Get current user
  Future<Either<Failure, UserEntity?>> getCurrentUser();

  /// Create user profile
  Future<Either<Failure, void>> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  });

  /// Update display name
  Future<Either<Failure, void>> updateDisplayName({
    required String uid,
    required String displayName,
  });

  /// Check if display name is unique
  Future<Either<Failure, bool>> isDisplayNameUnique(String displayName);
}
