import 'package:equatable/equatable.dart';

/// Chat message entity
class ChatMessageEntity extends Equatable {
  final String id;
  final String matchId;
  final int teamNumber;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime createdAt;

  const ChatMessageEntity({
    required this.id,
    required this.matchId,
    required this.teamNumber,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        matchId,
        teamNumber,
        senderId,
        senderName,
        content,
        createdAt,
      ];
}
