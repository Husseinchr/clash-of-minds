import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';

/// Match model
class MatchModel extends MatchEntity {
  const MatchModel({
    required super.id,
    required super.code,
    required super.leaderId,
    required super.leaderName,
    required super.team1PlayerIds,
    required super.team2PlayerIds,
    required super.team1Score,
    required super.team2Score,
    required super.status,
    super.currentQuestion,
    super.currentHint,
    super.currentAnswerer,
    super.currentAnswererName,
    super.currentAnswer,
    super.answerStartTime,
    super.currentTeamTurn,
    super.teamTurnStartTime,
    super.teamTurnVersion = 0,
    super.systemMessages = const [],
    required super.createdAt,
    super.startedAt,
    super.completedAt,
  });

  /// From JSON
  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      code: json['code'] as String,
      leaderId: json['leaderId'] as String,
      leaderName: json['leaderName'] as String,
      team1PlayerIds: List<String>.from(json['team1PlayerIds'] as List),
      team2PlayerIds: List<String>.from(json['team2PlayerIds'] as List),
      team1Score: json['team1Score'] as int,
      team2Score: json['team2Score'] as int,
      status: MatchStatus.values.firstWhere(
        (e) => e.toString() == 'MatchStatus.${json['status']}',
      ),
      currentQuestion: json['currentQuestion'] as String?,
      currentHint: json['currentHint'] as String?,
      currentAnswerer: json['currentAnswerer'] as String?,
      currentAnswererName: json['currentAnswererName'] as String?,
      currentAnswer: json['currentAnswer'] as String?,
      answerStartTime: json['answerStartTime'] != null
          ? (json['answerStartTime'] as Timestamp).toDate()
          : null,
      currentTeamTurn: json['currentTeamTurn'] as int?,
      teamTurnStartTime: json['teamTurnStartTime'] != null
          ? (json['teamTurnStartTime'] as Timestamp).toDate()
          : null,
      teamTurnVersion: (json['teamTurnVersion'] as int?) ?? 0,
      systemMessages: json['systemMessages'] != null
          ? List<String>.from(json['systemMessages'] as List)
          : [],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      startedAt: json['startedAt'] != null
          ? (json['startedAt'] as Timestamp).toDate()
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'leaderId': leaderId,
      'leaderName': leaderName,
      'team1PlayerIds': team1PlayerIds,
      'team2PlayerIds': team2PlayerIds,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'status': status.toString().split('.').last,
      'currentQuestion': currentQuestion,
      'currentHint': currentHint,
      'currentAnswerer': currentAnswerer,
      'currentAnswererName': currentAnswererName,
      'currentAnswer': currentAnswer,
      'answerStartTime': answerStartTime != null
          ? Timestamp.fromDate(answerStartTime!)
          : null,
      'currentTeamTurn': currentTeamTurn,
      'teamTurnStartTime': teamTurnStartTime != null
          ? Timestamp.fromDate(teamTurnStartTime!)
          : null,
      'teamTurnVersion': teamTurnVersion,
      'systemMessages': systemMessages,
      'createdAt': Timestamp.fromDate(createdAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  /// Copy with
  MatchModel copyWith({
    String? id,
    String? code,
    String? leaderId,
    String? leaderName,
    List<String>? team1PlayerIds,
    List<String>? team2PlayerIds,
    int? team1Score,
    int? team2Score,
    MatchStatus? status,
    String? currentQuestion,
    String? currentHint,
    String? currentAnswerer,
    String? currentAnswererName,
    String? currentAnswer,
    DateTime? answerStartTime,
    int? currentTeamTurn,
    DateTime? teamTurnStartTime,
    int? teamTurnVersion,
    List<String>? systemMessages,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return MatchModel(
      id: id ?? this.id,
      code: code ?? this.code,
      leaderId: leaderId ?? this.leaderId,
      leaderName: leaderName ?? this.leaderName,
      team1PlayerIds: team1PlayerIds ?? this.team1PlayerIds,
      team2PlayerIds: team2PlayerIds ?? this.team2PlayerIds,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      status: status ?? this.status,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      currentHint: currentHint ?? this.currentHint,
      currentAnswerer: currentAnswerer ?? this.currentAnswerer,
      currentAnswererName: currentAnswererName ?? this.currentAnswererName,
      currentAnswer: currentAnswer ?? this.currentAnswer,
      answerStartTime: answerStartTime ?? this.answerStartTime,
      currentTeamTurn: currentTeamTurn ?? this.currentTeamTurn,
      teamTurnStartTime: teamTurnStartTime ?? this.teamTurnStartTime,
      teamTurnVersion: teamTurnVersion ?? this.teamTurnVersion,
      systemMessages: systemMessages ?? this.systemMessages,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
