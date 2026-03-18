import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/features/chat/domain/entities/chat_message_entity.dart';

/// Chat states
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChatInitial extends ChatState {}

/// Loading state
class ChatLoading extends ChatState {}

/// Messages loaded state
class ChatMessagesLoaded extends ChatState {
  final List<ChatMessageEntity> messages;

  const ChatMessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Message sent state
class ChatMessageSent extends ChatState {}

/// Chat error state
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
