import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/features/chat/domain/repositories/chat_repository.dart';
import 'package:clash_of_minds/features/chat/presentation/bloc/chat_event.dart';
import 'package:clash_of_minds/features/chat/presentation/bloc/chat_state.dart';

/// Chat BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;

  ChatBloc({required this.repository}) : super(ChatInitial()) {
    on<WatchTeamMessagesEvent>(_onWatchTeamMessages);
    on<SendMessageEvent>(_onSendMessage);
  }

  Future<void> _onWatchTeamMessages(
    WatchTeamMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    await emit.forEach(
      repository.watchTeamMessages(
        matchId: event.matchId,
        teamNumber: event.teamNumber,
      ),
      onData: (result) {
        return result.fold(
          (failure) => ChatError(failure.message),
          (messages) => ChatMessagesLoaded(messages),
        );
      },
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await repository.sendMessage(
      matchId: event.matchId,
      teamNumber: event.teamNumber,
      senderId: event.senderId,
      senderName: event.senderName,
      content: event.content,
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) => null, // Don't emit state - let the stream handle the update
    );
  }
}
