import 'dart:io';
import 'package:equatable/equatable.dart';

/// Profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Load profile event
class LoadProfileEvent extends ProfileEvent {
  final String uid;

  const LoadProfileEvent(this.uid);

  @override
  List<Object?> get props => [uid];
}

/// Update profile picture event
class UpdateProfilePictureEvent extends ProfileEvent {
  final String uid;
  final File image;

  const UpdateProfilePictureEvent({
    required this.uid,
    required this.image,
  });

  @override
  List<Object?> get props => [uid, image];
}
