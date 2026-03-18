import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/auth/domain/entities/user_entity.dart';

/// Profile repository interface
abstract class ProfileRepository {
  /// Update profile picture
  Future<Either<Failure, String>> updateProfilePicture({
    required String uid,
    required File image,
  });

  /// Get user profile
  Future<Either<Failure, UserEntity>> getUserProfile(String uid);

  /// Update user profile
  Future<Either<Failure, void>> updateUserProfile({
    required String uid,
    String? displayName,
    String? profilePicture,
  });
}
