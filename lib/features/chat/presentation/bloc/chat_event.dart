import 'package:equatable/equatable.dart';

/// Chat events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Watch team messages event
class WatchTeamMessagesEvent extends ChatEvent {
  final String matchId;
  final int teamNumber;

  const WatchTeamMessagesEvent({
    required this.matchId,
    required this.teamNumber,
  });

  @override
  List<Object?> get props => [matchId, teamNumber];
}

/// Send message event
class SendMessageEvent extends ChatEvent {
  final String matchId;
  final int teamNumber;
  final String senderId;
  final String senderName;
  final String content;

  const SendMessageEvent({
    required this.matchId,
    required this.teamNumber,
    required this.senderId,
    required this.senderName,
    required this.content,
  });

  @override
  List<Object?> get props => [matchId, teamNumber, senderId, senderName, content];
}
