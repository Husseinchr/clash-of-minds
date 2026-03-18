import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/exceptions.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/match/data/datasources/match_remote_data_source.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_invitation_entity.dart';
import 'package:clash_of_minds/features/match/domain/repositories/match_repository.dart';

/// Match repository implementation
class MatchRepositoryImpl implements MatchRepository {
  final MatchRemoteDataSource remoteDataSource;

  MatchRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MatchEntity>> createMatch({
    required String leaderId,
    required String leaderName,
  }) async {
    try {
      final match = await remoteDataSource.createMatch(
        leaderId: leaderId,
        leaderName: leaderName,
      );
      return Right(match);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> joinMatch({
    required String code,
    required String playerId,
    required String playerName,
    String? profilePicture,
  }) async {
    try {
      final match = await remoteDataSource.joinMatch(
        code: code,
        playerId: playerId,
        playerName: playerName,
        profilePicture: profilePicture,
      );
      return Right(match);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchEntity?>> getMatchByCode(String code) async {
    try {
      final match = await remoteDataSource.getMatchByCode(code);
      return Right(match);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchEntity?>> getMatchById(String matchId) async {
    try {
      final match = await remoteDataSource.getMatchById(matchId);
      return Right(match);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, MatchEntity>> watchMatch(String matchId) {
    try {
      return remoteDataSource.watchMatch(matchId).map(
            (match) => Right(match),
          );
    } on ServerException catch (e) {
      return Stream.value(Left(ServerFailure(e.message)));
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> startMatch(String matchId) async {
    try {
      await remoteDataSource.startMatch(matchId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendQuestion({
    required String matchId,
    required String question,
  }) async {
    try {
      await remoteDataSource.sendQuestion(matchId: matchId, question: question);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendHint({
    required String matchId,
    required String hint,
  }) async {
    try {
      await remoteDataSource.sendHint(matchId: matchId, hint: hint);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setCurrentAnswerer({
    required String matchId,
    required String playerId,
    required String playerName,
    required String answer,
  }) async {
    try {
      await remoteDataSource.setCurrentAnswerer(
        matchId: matchId,
        playerId: playerId,
        playerName: playerName,
        answer: answer,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAnswerCorrect({
    required String matchId,
    required String playerId,
    required int teamNumber,
  }) async {
    try {
      await remoteDataSource.markAnswerCorrect(
        matchId: matchId,
        playerId: playerId,
        teamNumber: teamNumber,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAnswerWrong({
    required String matchId,
  }) async {
    try {
      await remoteDataSource.markAnswerWrong(matchId: matchId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> dismissPoint({
    required String matchId,
  }) async {
    try {
      await remoteDataSource.dismissPoint(matchId: matchId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> switchTeamTurn({
    required String matchId,
  }) async {
    try {
      await remoteDataSource.switchTeamTurn(matchId: matchId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> endMatch(String matchId) async {
    try {
      await remoteDataSource.endMatch(matchId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchInvitationEntity>> sendMatchInvitation({
    required String matchId,
    required String matchCode,
    required String fromUserId,
    required String fromUserName,
    required String toUserId,
    required String toUserName,
  }) async {
    try {
      final invitation = await remoteDataSource.sendMatchInvitation(
        matchId: matchId,
        matchCode: matchCode,
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        toUserId: toUserId,
        toUserName: toUserName,
      );
      return Right(invitation);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchInvitationEntity>>> getMatchInvitations(
    String userId,
  ) async {
    try {
      final invitations = await remoteDataSource.getMatchInvitations(userId);
      return Right(invitations);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> respondToInvitation({
    required String invitationId,
    required bool accept,
    required String playerId,
    required String playerName,
    String? profilePicture,
    int? teamNumber,
  }) async {
    try {
      final match = await remoteDataSource.respondToInvitation(
        invitationId: invitationId,
        accept: accept,
        playerId: playerId,
        playerName: playerName,
        profilePicture: profilePicture,
        teamNumber: teamNumber,
      );
      return Right(match);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchEntity>> joinMatchWithTeam({
    required String code,
    required String playerId,
    required String playerName,
    String? profilePicture,
    int? teamNumber,
  }) async {
    try {
      final match = await remoteDataSource.joinMatchWithTeam(
        code: code,
        playerId: playerId,
        playerName: playerName,
        profilePicture: profilePicture,
        teamNumber: teamNumber,
      );
      return Right(match);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> leaveMatch({
    required String matchId,
    required String playerId,
    required String playerName,
  }) async {
    try {
      await remoteDataSource.leaveMatch(
        matchId: matchId,
        playerId: playerId,
        playerName: playerName,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
