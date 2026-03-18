import 'package:equatable/equatable.dart';

/// Friend request status
enum FriendRequestStatus {
  pending,
  accepted,
  declined,
}

/// Friend entity
class FriendEntity extends Equatable {
  final String uid;
  final String displayName;
  final String? profilePicture;

  const FriendEntity({
    required this.uid,
    required this.displayName,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [uid, displayName, profilePicture];
}

/// Friend request entity
class FriendRequestEntity extends Equatable {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserPhoto;
  final String toUserId;
  final String toUserName;
  final FriendRequestStatus status;
  final DateTime createdAt;

  const FriendRequestEntity({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserPhoto,
    required this.toUserId,
    required this.toUserName,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        fromUserName,
        fromUserPhoto,
        toUserId,
        toUserName,
        status,
        createdAt,
      ];
}
