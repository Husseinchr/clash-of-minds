import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/auth/domain/repositories/auth_repository.dart';

/// Update display name use case
class UpdateDisplayName {
  final AuthRepository repository;

  UpdateDisplayName(this.repository);

  Future<Either<Failure, void>> call(UpdateDisplayNameParams params) async {
    return await repository.updateDisplayName(
      uid: params.uid,
      displayName: params.displayName,
    );
  }
}

/// Update display name params
class UpdateDisplayNameParams extends Equatable {
  final String uid;
  final String displayName;

  const UpdateDisplayNameParams({
    required this.uid,
    required this.displayName,
  });

  @override
  List<Object> get props => [uid, displayName];
}
