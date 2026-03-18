import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/auth/domain/entities/user_entity.dart';
import 'package:clash_of_minds/features/auth/domain/repositories/auth_repository.dart';

/// Sign in with Google use case
class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.signInWithGoogle();
  }
}
