import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/features/auth/domain/entities/user_entity.dart';

/// Auth state
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AuthInitial extends AuthState {}

/// Loading state
class AuthLoading extends AuthState {}

/// Authenticated state
class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state
class Unauthenticated extends AuthState {}

/// Auth error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Display name updated state
class DisplayNameUpdated extends AuthState {
  final UserEntity user;

  const DisplayNameUpdated(this.user);

  @override
  List<Object?> get props => [user];
}
