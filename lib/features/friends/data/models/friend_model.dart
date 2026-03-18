import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clash_of_minds/features/friends/domain/entities/friend_entity.dart';

/// Friend model
class FriendModel extends FriendEntity {
  const FriendModel({
    required super.uid,
    required super.displayName,
    super.profilePicture,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'profilePicture': profilePicture,
    };
  }
}

/// Friend request model
class FriendRequestModel extends FriendRequestEntity {
  const FriendRequestModel({
    required super.id,
    required super.fromUserId,
    required super.fromUserName,
    super.fromUserPhoto,
    required super.toUserId,
    required super.toUserName,
    required super.status,
    required super.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id'] as String,
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      fromUserPhoto: json['fromUserPhoto'] as String?,
      toUserId: json['toUserId'] as String,
      toUserName: json['toUserName'] as String,
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.toString() == 'FriendRequestStatus.${json['status']}',
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserPhoto': fromUserPhoto,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
