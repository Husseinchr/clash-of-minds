import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/features/auth/domain/entities/user_entity.dart';

/// Profile state
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {}

/// Loading state
class ProfileLoading extends ProfileState {}

/// Profile loaded state
class ProfileLoaded extends ProfileState {
  final UserEntity user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// Profile error state
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Profile picture updated state
class ProfilePictureUpdated extends ProfileState {
  final String imageUrl;

  const ProfilePictureUpdated(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}
