import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/exceptions.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/auth/domain/entities/user_entity.dart';
import 'package:clash_of_minds/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:clash_of_minds/features/profile/domain/repositories/profile_repository.dart';

/// Profile repository implementation
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> updateProfilePicture({
    required String uid,
    required File image,
  }) async {
    try {
      final url = await remoteDataSource.uploadProfilePicture(
        uid: uid,
        image: image,
      );
      await remoteDataSource.updateUserProfile(
        uid: uid,
        profilePicture: url,
      );
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile(String uid) async {
    try {
      final user = await remoteDataSource.getUserProfile(uid);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile({
    required String uid,
    String? displayName,
    String? profilePicture,
  }) async {
    try {
      await remoteDataSource.updateUserProfile(
        uid: uid,
        displayName: displayName,
        profilePicture: profilePicture,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
