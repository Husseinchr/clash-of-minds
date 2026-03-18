import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_invitation_entity.dart';

/// Match repository interface
abstract class MatchRepository {
  /// Create a new match
  Future<Either<Failure, MatchEntity>> createMatch({
    required String leaderId,
    required String leaderName,
  });

  /// Join match with code
  Future<Either<Failure, MatchEntity>> joinMatch({
    required String code,
    required String playerId,
    required String playerName,
    String? profilePicture,
  });

  /// Get match by code
  Future<Either<Failure, MatchEntity?>> getMatchByCode(String code);

  /// Get match by ID
  Future<Either<Failure, MatchEntity?>> getMatchById(String matchId);

  /// Watch match updates
  Stream<Either<Failure, MatchEntity>> watchMatch(String matchId);

  /// Start match
  Future<Either<Failure, void>> startMatch(String matchId);

  /// Send question
  Future<Either<Failure, void>> sendQuestion({
    required String matchId,
    required String question,
  });

  /// Send hint
  Future<Either<Failure, void>> sendHint({
    required String matchId,
    required String hint,
  });

  /// Set current answerer
  Future<Either<Failure, void>> setCurrentAnswerer({
    required String matchId,
    required String playerId,
    required String playerName,
    required String answer,
  });

  /// Mark answer as correct
  Future<Either<Failure, void>> markAnswerCorrect({
    required String matchId,
    required String playerId,
    required int teamNumber,
  });

  /// Mark answer as wrong
  Future<Either<Failure, void>> markAnswerWrong({
    required String matchId,
  });

  /// Dismiss point
  Future<Either<Failure, void>> dismissPoint({
    required String matchId,
  });

  /// Switch team turn
  Future<Either<Failure, void>> switchTeamTurn({
    required String matchId,
  });

  /// End match
  Future<Either<Failure, void>> endMatch(String matchId);

  /// Send match invitation
  Future<Either<Failure, MatchInvitationEntity>> sendMatchInvitation({
    required String matchId,
    required String matchCode,
    required String fromUserId,
    required String fromUserName,
    required String toUserId,
    required String toUserName,
  });

  /// Get match invitations for user
  Future<Either<Failure, List<MatchInvitationEntity>>> getMatchInvitations(
    String userId,
  );

  /// Respond to invitation
  Future<Either<Failure, MatchEntity>> respondToInvitation({
    required String invitationId,
    required bool accept,
    required String playerId,
    required String playerName,
    String? profilePicture,
    int? teamNumber,
  });

  /// Join match with team selection
  Future<Either<Failure, MatchEntity>> joinMatchWithTeam({
    required String code,
    required String playerId,
    required String playerName,
    String? profilePicture,
    int? teamNumber,
  });

  /// Leave match - removes player from their team
  Future<Either<Failure, void>> leaveMatch({
    required String matchId,
    required String playerId,
    required String playerName,
  });
}
