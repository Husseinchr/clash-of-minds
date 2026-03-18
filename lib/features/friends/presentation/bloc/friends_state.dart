import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/features/friends/domain/entities/friend_entity.dart';

/// Friends state
abstract class FriendsState extends Equatable {
  const FriendsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FriendsInitial extends FriendsState {}

/// Loading state
class FriendsLoading extends FriendsState {}

/// Friends loaded state
class FriendsLoaded extends FriendsState {
  final List<FriendEntity> friends;

  const FriendsLoaded(this.friends);

  @override
  List<Object?> get props => [friends];
}

/// Friend requests loaded state
class FriendRequestsLoaded extends FriendsState {
  final List<FriendRequestEntity> requests;

  const FriendRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

/// Combined state - both friends and requests loaded
class FriendsAndRequestsLoaded extends FriendsState {
  final List<FriendEntity> friends;
  final List<FriendRequestEntity> requests;

  const FriendsAndRequestsLoaded({
    required this.friends,
    required this.requests,
  });

  @override
  List<Object?> get props => [friends, requests];
}

/// Friend request sent state
class FriendRequestSent extends FriendsState {}

/// Friend request accepted state
class FriendRequestAccepted extends FriendsState {}

/// Friends error state
class FriendsError extends FriendsState {
  final String message;

  const FriendsError(this.message);

  @override
  List<Object?> get props => [message];
}
