import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/chat/domain/entities/chat_message_entity.dart';

/// Chat repository interface
abstract class ChatRepository {
  /// Send a chat message
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String matchId,
    required int teamNumber,
    required String senderId,
    required String senderName,
    required String content,
  });

  /// Watch chat messages for a team
  Stream<Either<Failure, List<ChatMessageEntity>>> watchTeamMessages({
    required String matchId,
    required int teamNumber,
  });
}
