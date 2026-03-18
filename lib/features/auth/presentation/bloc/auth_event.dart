import 'package:equatable/equatable.dart';

/// Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check auth status event
class CheckAuthStatusEvent extends AuthEvent {}

/// Sign in with Google event
class SignInWithGoogleEvent extends AuthEvent {}

/// Sign in with email event
class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Sign up with email event
class SignUpWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const SignUpWithEmailEvent({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

/// Sign out event
class SignOutEvent extends AuthEvent {}

/// Update display name event
class UpdateDisplayNameEvent extends AuthEvent {
  final String displayName;

  const UpdateDisplayNameEvent(this.displayName);

  @override
  List<Object?> get props => [displayName];
}
