import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/profile/domain/repositories/profile_repository.dart';

/// Update profile picture use case
class UpdateProfilePicture {
  final ProfileRepository repository;

  UpdateProfilePicture(this.repository);

  Future<Either<Failure, String>> call(UpdateProfilePictureParams params) async {
    return await repository.updateProfilePicture(
      uid: params.uid,
      image: params.image,
    );
  }
}

/// Update profile picture params
class UpdateProfilePictureParams extends Equatable {
  final String uid;
  final File image;

  const UpdateProfilePictureParams({
    required this.uid,
    required this.image,
  });

  @override
  List<Object> get props => [uid, image];
}
