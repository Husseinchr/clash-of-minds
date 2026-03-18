import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/friends/domain/entities/friend_entity.dart';
import 'package:clash_of_minds/features/friends/domain/repositories/friends_repository.dart';

/// Get friends use case
class GetFriends {
  final FriendsRepository repository;

  GetFriends(this.repository);

  Future<Either<Failure, List<FriendEntity>>> call(String userId) async {
    return await repository.getFriends(userId);
  }
}
