import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/friends/domain/entities/friend_entity.dart';
import 'package:clash_of_minds/features/friends/domain/repositories/friends_repository.dart';

/// Get friend requests use case
class GetFriendRequests {
  final FriendsRepository repository;

  GetFriendRequests(this.repository);

  Future<Either<Failure, List<FriendRequestEntity>>> call(String userId) async {
    return await repository.getFriendRequests(userId);
  }
}
