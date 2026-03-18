import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/auth/domain/entities/user_entity.dart';
import 'package:clash_of_minds/features/auth/domain/repositories/auth_repository.dart';

/// Get current user use case
class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<Either<Failure, UserEntity?>> call() async {
    return await repository.getCurrentUser();
  }
}
