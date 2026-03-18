import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/auth/domain/entities/user_entity.dart';
import 'package:clash_of_minds/features/auth/domain/repositories/auth_repository.dart';

/// Sign up with email and password use case
class SignUpWithEmail {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  Future<Either<Failure, UserEntity>> call(SignUpWithEmailParams params) async {
    return await repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}

/// Parameters for sign up with email
class SignUpWithEmailParams {
  final String email;
  final String password;
  final String displayName;

  SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.displayName,
  });
}
