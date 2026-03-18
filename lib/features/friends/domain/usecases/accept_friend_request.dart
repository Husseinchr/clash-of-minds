import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/friends/domain/repositories/friends_repository.dart';

/// Accept friend request use case
class AcceptFriendRequest {
  final FriendsRepository repository;

  AcceptFriendRequest(this.repository);

  Future<Either<Failure, void>> call(String requestId) async {
    return await repository.acceptFriendRequest(requestId);
  }
}
