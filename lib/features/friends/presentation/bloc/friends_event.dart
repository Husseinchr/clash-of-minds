import 'package:equatable/equatable.dart';

/// Friends events
abstract class FriendsEvent extends Equatable {
  const FriendsEvent();

  @override
  List<Object?> get props => [];
}

/// Load friends event
class LoadFriendsEvent extends FriendsEvent {
  final String userId;

  const LoadFriendsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Load friend requests event
class LoadFriendRequestsEvent extends FriendsEvent {
  final String userId;

  const LoadFriendRequestsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Send friend request event
class SendFriendRequestEvent extends FriendsEvent {
  final String fromUserId;
  final String fromUserName;
  final String? fromUserPhoto;
  final String displayName;

  const SendFriendRequestEvent({
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserPhoto,
    required this.displayName,
  });

  @override
  List<Object?> get props => [fromUserId, fromUserName, fromUserPhoto, displayName];
}

/// Accept friend request event
class AcceptFriendRequestEvent extends FriendsEvent {
  final String requestId;
  final String userId;

  const AcceptFriendRequestEvent({
    required this.requestId,
    required this.userId,
  });

  @override
  List<Object?> get props => [requestId, userId];
}

/// Decline friend request event
class DeclineFriendRequestEvent extends FriendsEvent {
  final String requestId;

  const DeclineFriendRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}
