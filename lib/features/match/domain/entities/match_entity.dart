import 'package:equatable/equatable.dart';

/// Match status enum
enum MatchStatus {
  waiting,
  inProgress,
  completed,
}

/// Match entity
class MatchEntity extends Equatable {
  final String id;
  final String code;
  final String leaderId;
  final String leaderName;
  final List<String> team1PlayerIds;
  final List<String> team2PlayerIds;
  final int team1Score;
  final int team2Score;
  final MatchStatus status;
  final String? currentQuestion;
  final String? currentHint;
  final String? currentAnswerer;
  final String? currentAnswererName;
  final String? currentAnswer;
  final DateTime? answerStartTime; // When the current answerer started (for 15s timer)
  final int? currentTeamTurn; // Which team can currently claim the question (1, 2, or null for both)
  final DateTime? teamTurnStartTime; // When the current team's turn to claim started
  final int teamTurnVersion; // Version counter to prevent race conditions when switching teams
  final List<String> systemMessages;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const MatchEntity({
    required this.id,
    required this.code,
    required this.leaderId,
    required this.leaderName,
    required this.team1PlayerIds,
    required this.team2PlayerIds,
    required this.team1Score,
    required this.team2Score,
    required this.status,
    this.currentQuestion,
    this.currentHint,
    this.currentAnswerer,
    this.currentAnswererName,
    this.currentAnswer,
    this.answerStartTime,
    this.currentTeamTurn,
    this.teamTurnStartTime,
    this.teamTurnVersion = 0,
    this.systemMessages = const [],
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
        id,
        code,
        leaderId,
        leaderName,
        team1PlayerIds,
        team2PlayerIds,
        team1Score,
        team2Score,
        status,
        currentQuestion,
        currentHint,
        currentAnswerer,
        currentAnswererName,
        currentAnswer,
        answerStartTime,
        currentTeamTurn,
        teamTurnStartTime,
        teamTurnVersion,
        systemMessages,
        createdAt,
        startedAt,
        completedAt,
      ];
}

/// Player entity
class PlayerEntity extends Equatable {
  final String uid;
  final String displayName;
  final String? profilePicture;
  final int teamNumber;

  const PlayerEntity({
    required this.uid,
    required this.displayName,
    this.profilePicture,
    required this.teamNumber,
  });

  @override
  List<Object?> get props => [uid, displayName, profilePicture, teamNumber];
}
