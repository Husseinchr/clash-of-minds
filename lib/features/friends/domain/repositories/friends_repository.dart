import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/friends/domain/entities/friend_entity.dart';

/// Friends repository interface
abstract class FriendsRepository {
  /// Send friend request by display name
  Future<Either<Failure, void>> sendFriendRequestByDisplayName({
    required String fromUserId,
    required String fromUserName,
    String? fromUserPhoto,
    required String displayName,
  });

  /// Get friend requests for user
  Future<Either<Failure, List<FriendRequestEntity>>> getFriendRequests(
    String userId,
  );

  /// Accept friend request
  Future<Either<Failure, void>> acceptFriendRequest(String requestId);

  /// Decline friend request
  Future<Either<Failure, void>> declineFriendRequest(String requestId);

  /// Get friends list
  Future<Either<Failure, List<FriendEntity>>> getFriends(String userId);

  /// Remove friend
  Future<Either<Failure, void>> removeFriend({
    required String userId,
    required String friendId,
  });

  /// Search users by display name
  Future<Either<Failure, List<FriendEntity>>> searchUsers(String displayName);
}
