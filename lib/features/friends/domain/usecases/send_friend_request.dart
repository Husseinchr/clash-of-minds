import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/friends/domain/repositories/friends_repository.dart';

/// Send friend request use case
class SendFriendRequest {
  final FriendsRepository repository;

  SendFriendRequest(this.repository);

  Future<Either<Failure, void>> call(SendFriendRequestParams params) async {
    return await repository.sendFriendRequestByDisplayName(
      fromUserId: params.fromUserId,
      fromUserName: params.fromUserName,
      fromUserPhoto: params.fromUserPhoto,
      displayName: params.displayName,
    );
  }
}

/// Send friend request params
class SendFriendRequestParams extends Equatable {
  final String fromUserId;
  final String fromUserName;
  final String? fromUserPhoto;
  final String displayName;

  const SendFriendRequestParams({
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserPhoto,
    required this.displayName,
  });

  @override
  List<Object?> get props => [fromUserId, fromUserName, fromUserPhoto, displayName];
}
