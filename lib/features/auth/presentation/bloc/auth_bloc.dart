import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/features/auth/domain/usecases/get_current_user.dart';
import 'package:clash_of_minds/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:clash_of_minds/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:clash_of_minds/features/auth/domain/usecases/sign_out.dart';
import 'package:clash_of_minds/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:clash_of_minds/features/auth/domain/usecases/update_display_name.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_event.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_state.dart';

/// Auth BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignInWithEmail signInWithEmail;
  final SignUpWithEmail signUpWithEmail;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final UpdateDisplayName updateDisplayName;

  AuthBloc({
    required this.signInWithGoogle,
    required this.signInWithEmail,
    required this.signUpWithEmail,
    required this.signOut,
    required this.getCurrentUser,
    required this.updateDisplayName,
  }) : super(AuthInitial()) {
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
    on<SignInWithEmailEvent>(_onSignInWithEmail);
    on<SignUpWithEmailEvent>(_onSignUpWithEmail);
    on<SignOutEvent>(_onSignOut);
    on<UpdateDisplayNameEvent>(_onUpdateDisplayName);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUser();
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignInWithEmail(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signInWithEmail(
      SignInWithEmailParams(
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onSignUpWithEmail(
    SignUpWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    dev.log('🔵 AuthBloc: _onSignUpWithEmail called');
    dev.log('   Email: ${event.email}');
    dev.log('   Display Name: ${event.displayName}');
    emit(AuthLoading());
    dev.log('✅ AuthBloc: Emitted AuthLoading');
    final result = await signUpWithEmail(
      SignUpWithEmailParams(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      ),
    );
    dev.log('📦 AuthBloc: Got result from signUpWithEmail');
    result.fold(
      (failure) {
        dev.log('❌ AuthBloc: Sign up failed - ${failure.message}');
        emit(AuthError(failure.message));
      },
      (user) {
        dev.log('✅ AuthBloc: Sign up successful - ${user.displayName}');
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await signOut();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onUpdateDisplayName(
    UpdateDisplayNameEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is Authenticated) {
      final currentUser = (state as Authenticated).user;
      emit(AuthLoading());

      final result = await updateDisplayName(
        UpdateDisplayNameParams(
          uid: currentUser.uid,
          displayName: event.displayName,
        ),
      );

      await result.fold(
        (failure) async => emit(AuthError(failure.message)),
        (_) async {
          // Refresh user data
          final userResult = await getCurrentUser();
          userResult.fold(
            (failure) => emit(AuthError(failure.message)),
            (user) {
              if (user != null) {
                emit(DisplayNameUpdated(user));
              } else {
                emit(Unauthenticated());
              }
            },
          );
        },
      );
    }
  }
}
