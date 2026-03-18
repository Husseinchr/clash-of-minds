import 'package:equatable/equatable.dart';

/// User entity
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? profilePicture;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profilePicture,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [uid, email, displayName, profilePicture, createdAt];
}
