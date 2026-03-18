import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/features/profile/domain/usecases/update_profile_picture.dart';
import 'package:clash_of_minds/features/profile/presentation/bloc/profile_event.dart';
import 'package:clash_of_minds/features/profile/presentation/bloc/profile_state.dart';

/// Profile BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateProfilePicture updateProfilePicture;

  ProfileBloc({
    required this.updateProfilePicture,
  }) : super(ProfileInitial()) {
    on<UpdateProfilePictureEvent>(_onUpdateProfilePicture);
  }

  Future<void> _onUpdateProfilePicture(
    UpdateProfilePictureEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    final result = await updateProfilePicture(
      UpdateProfilePictureParams(
        uid: event.uid,
        image: event.image,
      ),
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (imageUrl) => emit(ProfilePictureUpdated(imageUrl)),
    );
  }
}
