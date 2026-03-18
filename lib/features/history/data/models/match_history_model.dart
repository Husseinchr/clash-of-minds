import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clash_of_minds/features/history/domain/entities/match_history_entity.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';

/// Match history model
class MatchHistoryModel extends MatchHistoryEntity {
  const MatchHistoryModel({
    required super.id,
    required super.matchCode,
    required super.leaderId,
    required super.leaderName,
    required super.team1PlayerIds,
    required super.team2PlayerIds,
    required super.playerNames,
    required super.team1Score,
    required super.team2Score,
    required super.winningTeam,
    required super.createdAt,
    super.startedAt,
    required super.completedAt,
    required super.userTeamNumber,
    required super.wasLeader,
  });

  /// From JSON (Firestore document)
  factory MatchHistoryModel.fromJson(
    Map<String, dynamic> json,
    String userId,
  ) {
    final team1PlayerIds = List<String>.from(json['team1PlayerIds'] as List);
    final team2PlayerIds = List<String>.from(json['team2PlayerIds'] as List);
    final playerNamesMap =
        Map<String, String>.from(json['playerNames'] as Map);

    // Determine user's team
    final userTeamNumber = team1PlayerIds.contains(userId)
        ? 1
        : (team2PlayerIds.contains(userId) ? 2 : 0);

    // Check if user was the leader
    final wasLeader = json['leaderId'] == userId;

    return MatchHistoryModel(
      id: json['id'] as String,
      matchCode: json['matchCode'] as String,
      leaderId: json['leaderId'] as String,
      leaderName: json['leaderName'] as String,
      team1PlayerIds: team1PlayerIds,
      team2PlayerIds: team2PlayerIds,
      playerNames: playerNamesMap,
      team1Score: json['team1Score'] as int,
      team2Score: json['team2Score'] as int,
      winningTeam: json['winningTeam'] as int,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      startedAt: json['startedAt'] != null
          ? (json['startedAt'] as Timestamp).toDate()
          : null,
      completedAt: (json['completedAt'] as Timestamp).toDate(),
      userTeamNumber: userTeamNumber,
      wasLeader: wasLeader,
    );
  }

  /// To JSON (for Firestore document)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchCode': matchCode,
      'leaderId': leaderId,
      'leaderName': leaderName,
      'team1PlayerIds': team1PlayerIds,
      'team2PlayerIds': team2PlayerIds,
      'participantIds': [...team1PlayerIds, ...team2PlayerIds],
      'playerNames': playerNames,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'winningTeam': winningTeam,
      'createdAt': Timestamp.fromDate(createdAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  /// Create from match entity (when match is completed)
  static Future<MatchHistoryModel> fromMatchEntity(
    MatchEntity match,
    Map<String, String> playerNames,
  ) async {
    // Calculate winning team
    final winningTeam = match.team1Score > match.team2Score
        ? 1
        : (match.team2Score > match.team1Score ? 2 : 0);

    return MatchHistoryModel(
      id: match.id,
      matchCode: match.code,
      leaderId: match.leaderId,
      leaderName: match.leaderName,
      team1PlayerIds: match.team1PlayerIds,
      team2PlayerIds: match.team2PlayerIds,
      playerNames: playerNames,
      team1Score: match.team1Score,
      team2Score: match.team2Score,
      winningTeam: winningTeam,
      createdAt: match.createdAt,
      startedAt: match.startedAt,
      completedAt: match.completedAt!,
      userTeamNumber: 0, // Will be calculated when fetching
      wasLeader: false, // Will be calculated when fetching
    );
  }
}
