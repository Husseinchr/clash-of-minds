import 'package:equatable/equatable.dart';

/// Match history entity
class MatchHistoryEntity extends Equatable {
  final String id;
  final String matchCode;
  final String leaderId;
  final String leaderName;

  // Participant Information
  final List<String> team1PlayerIds;
  final List<String> team2PlayerIds;
  final Map<String, String> playerNames; // userId -> displayName

  // Match Results
  final int team1Score;
  final int team2Score;
  final int winningTeam; // 1, 2, or 0 for tie

  // Timestamps
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime completedAt;

  // User Context
  final int userTeamNumber; // Which team was the current user on (1 or 2)
  final bool wasLeader;

  const MatchHistoryEntity({
    required this.id,
    required this.matchCode,
    required this.leaderId,
    required this.leaderName,
    required this.team1PlayerIds,
    required this.team2PlayerIds,
    required this.playerNames,
    required this.team1Score,
    required this.team2Score,
    required this.winningTeam,
    required this.createdAt,
    this.startedAt,
    required this.completedAt,
    required this.userTeamNumber,
    required this.wasLeader,
  });

  @override
  List<Object?> get props => [
        id,
        matchCode,
        leaderId,
        leaderName,
        team1PlayerIds,
        team2PlayerIds,
        playerNames,
        team1Score,
        team2Score,
        winningTeam,
        createdAt,
        startedAt,
        completedAt,
        userTeamNumber,
        wasLeader,
      ];
}
