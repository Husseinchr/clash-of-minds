import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/exceptions.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:clash_of_minds/features/chat/domain/entities/chat_message_entity.dart';
import 'package:clash_of_minds/features/chat/domain/repositories/chat_repository.dart';

/// Chat repository implementation
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChatMessageEntity>> sendMessage({
    required String matchId,
    required int teamNumber,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    try {
      final message = await remoteDataSource.sendMessage(
        matchId: matchId,
        teamNumber: teamNumber,
        senderId: senderId,
        senderName: senderName,
        content: content,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<ChatMessageEntity>>> watchTeamMessages({
    required String matchId,
    required int teamNumber,
  }) {
    return remoteDataSource
        .watchTeamMessages(matchId: matchId, teamNumber: teamNumber)
        .map<Either<Failure, List<ChatMessageEntity>>>(
            (messages) => Right(messages))
        .handleError((error) => Left(ServerFailure(error.toString())));
  }
}
