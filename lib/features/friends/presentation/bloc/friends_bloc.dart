import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/features/friends/domain/usecases/accept_friend_request.dart';
import 'package:clash_of_minds/features/friends/domain/usecases/get_friend_requests.dart';
import 'package:clash_of_minds/features/friends/domain/usecases/get_friends.dart';
import 'package:clash_of_minds/features/friends/domain/usecases/send_friend_request.dart';
import 'package:clash_of_minds/features/friends/presentation/bloc/friends_event.dart';
import 'package:clash_of_minds/features/friends/presentation/bloc/friends_state.dart';

/// Friends BLoC
class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final GetFriends getFriends;
  final GetFriendRequests getFriendRequests;
  final SendFriendRequest sendFriendRequest;
  final AcceptFriendRequest acceptFriendRequest;

  FriendsBloc({
    required this.getFriends,
    required this.getFriendRequests,
    required this.sendFriendRequest,
    required this.acceptFriendRequest,
  }) : super(FriendsInitial()) {
    on<LoadFriendsEvent>(_onLoadFriends);
    on<LoadFriendRequestsEvent>(_onLoadFriendRequests);
    on<SendFriendRequestEvent>(_onSendFriendRequest);
    on<AcceptFriendRequestEvent>(_onAcceptFriendRequest);
  }

  Future<void> _onLoadFriends(
    LoadFriendsEvent event,
    Emitter<FriendsState> emit,
  ) async {
    emit(FriendsLoading());

    // Load both friends and requests together
    final friendsResult = await getFriends(event.userId);
    final requestsResult = await getFriendRequests(event.userId);

    // Check if both succeeded
    friendsResult.fold(
      (failure) => emit(FriendsError(failure.message)),
      (friends) {
        requestsResult.fold(
          (failure) => emit(FriendsError(failure.message)),
          (requests) => emit(FriendsAndRequestsLoaded(
            friends: friends,
            requests: requests,
          )),
        );
      },
    );
  }

  Future<void> _onLoadFriendRequests(
    LoadFriendRequestsEvent event,
    Emitter<FriendsState> emit,
  ) async {
    // Redirect to load friends which loads both
    add(LoadFriendsEvent(event.userId));
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    final result = await sendFriendRequest(
      SendFriendRequestParams(
        fromUserId: event.fromUserId,
        fromUserName: event.fromUserName,
        fromUserPhoto: event.fromUserPhoto,
        displayName: event.displayName,
      ),
    );

    // Show result then reload friends
    result.fold(
      (failure) {
        emit(FriendsError(failure.message));
        // Reload friends after error to restore the list
        add(LoadFriendsEvent(event.fromUserId));
      },
      (_) {
        emit(FriendRequestSent());
        // Reload friends after success
        add(LoadFriendsEvent(event.fromUserId));
      },
    );
  }

  Future<void> _onAcceptFriendRequest(
    AcceptFriendRequestEvent event,
    Emitter<FriendsState> emit,
  ) async {
    final result = await acceptFriendRequest(event.requestId);
    result.fold(
      (failure) => emit(FriendsError(failure.message)),
      (_) {
        emit(FriendRequestAccepted());
        add(LoadFriendsEvent(event.userId));
      },
    );
  }
}
