import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/exceptions.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/friends/data/datasources/friends_remote_data_source.dart';
import 'package:clash_of_minds/features/friends/domain/entities/friend_entity.dart';
import 'package:clash_of_minds/features/friends/domain/repositories/friends_repository.dart';

/// Friends repository implementation
class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDataSource remoteDataSource;

  FriendsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> sendFriendRequestByDisplayName({
    required String fromUserId,
    required String fromUserName,
    String? fromUserPhoto,
    required String displayName,
  }) async {
    try {
      await remoteDataSource.sendFriendRequestByDisplayName(
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserPhoto: fromUserPhoto,
        displayName: displayName,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendRequestEntity>>> getFriendRequests(
    String userId,
  ) async {
    try {
      final requests = await remoteDataSource.getFriendRequests(userId);
      return Right(requests);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptFriendRequest(String requestId) async {
    try {
      await remoteDataSource.acceptFriendRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> declineFriendRequest(String requestId) async {
    try {
      await remoteDataSource.declineFriendRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendEntity>>> getFriends(String userId) async {
    try {
      final friends = await remoteDataSource.getFriends(userId);
      return Right(friends);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFriend({
    required String userId,
    required String friendId,
  }) async {
    try {
      await remoteDataSource.removeFriend(
        userId: userId,
        friendId: friendId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendEntity>>> searchUsers(
    String displayName,
  ) async {
    try {
      final users = await remoteDataSource.searchUsers(displayName);
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
