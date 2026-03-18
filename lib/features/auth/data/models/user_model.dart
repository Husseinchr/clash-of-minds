import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clash_of_minds/features/auth/domain/entities/user_entity.dart';

/// User model
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.profilePicture,
    required super.createdAt,
  });

  /// From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      profilePicture: json['profilePicture'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'profilePicture': profilePicture,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// From entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      email: entity.email,
      displayName: entity.displayName,
      profilePicture: entity.profilePicture,
      createdAt: entity.createdAt,
    );
  }
}
