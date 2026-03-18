import 'package:equatable/equatable.dart';

/// Match events
abstract class MatchEvent extends Equatable {
  const MatchEvent();

  @override
  List<Object?> get props => [];
}

/// Create match event
class CreateMatchEvent extends MatchEvent {
  final String leaderId;
  final String leaderName;

  const CreateMatchEvent({
    required this.leaderId,
    required this.leaderName,
  });

  @override
  List<Object?> get props => [leaderId, leaderName];
}

/// Join match event
class JoinMatchEvent extends MatchEvent {
  final String code;
  final String playerId;
  final String playerName;
  final String? profilePicture;

  const JoinMatchEvent({
    required this.code,
    required this.playerId,
    required this.playerName,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [code, playerId, playerName, profilePicture];
}

/// Watch match event
class WatchMatchEvent extends MatchEvent {
  final String matchId;

  const WatchMatchEvent(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

/// Start match event
class StartMatchEvent extends MatchEvent {
  final String matchId;

  const StartMatchEvent(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

/// Send question event
class SendQuestionEvent extends MatchEvent {
  final String matchId;
  final String question;

  const SendQuestionEvent({
    required this.matchId,
    required this.question,
  });

  @override
  List<Object?> get props => [matchId, question];
}

/// Send hint event
class SendHintEvent extends MatchEvent {
  final String matchId;
  final String hint;

  const SendHintEvent({
    required this.matchId,
    required this.hint,
  });

  @override
  List<Object?> get props => [matchId, hint];
}

/// Set answerer event
class SetAnswererEvent extends MatchEvent {
  final String matchId;
  final String playerId;
  final String playerName;
  final String answer;

  const SetAnswererEvent({
    required this.matchId,
    required this.playerId,
    required this.playerName,
    required this.answer,
  });

  @override
  List<Object?> get props => [matchId, playerId, playerName, answer];
}

/// Mark answer correct event
class MarkAnswerCorrectEvent extends MatchEvent {
  final String matchId;
  final String playerId;
  final int teamNumber;

  const MarkAnswerCorrectEvent({
    required this.matchId,
    required this.playerId,
    required this.teamNumber,
  });

  @override
  List<Object?> get props => [matchId, playerId, teamNumber];
}

/// Mark answer wrong event
class MarkAnswerWrongEvent extends MatchEvent {
  final String matchId;

  const MarkAnswerWrongEvent(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

/// Dismiss point event
class DismissPointEvent extends MatchEvent {
  final String matchId;

  const DismissPointEvent(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

/// Switch team turn event
class SwitchTeamTurnEvent extends MatchEvent {
  final String matchId;

  const SwitchTeamTurnEvent(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

/// End match event
class EndMatchEvent extends MatchEvent {
  final String matchId;

  const EndMatchEvent(this.matchId);

  @override
  List<Object?> get props => [matchId];
}

/// Send match invitation event
class SendMatchInvitationEvent extends MatchEvent {
  final String matchId;
  final String matchCode;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;

  const SendMatchInvitationEvent({
    required this.matchId,
    required this.matchCode,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
  });

  @override
  List<Object?> get props => [
        matchId,
        matchCode,
        fromUserId,
        fromUserName,
        toUserId,
        toUserName,
      ];
}

/// Load match invitations event
class LoadMatchInvitationsEvent extends MatchEvent {
  final String userId;

  const LoadMatchInvitationsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Respond to invitation event
class RespondToInvitationEvent extends MatchEvent {
  final String invitationId;
  final bool accept;
  final String playerId;
  final String playerName;
  final String? profilePicture;
  final int? teamNumber;

  const RespondToInvitationEvent({
    required this.invitationId,
    required this.accept,
    required this.playerId,
    required this.playerName,
    this.profilePicture,
    this.teamNumber,
  });

  @override
  List<Object?> get props => [
        invitationId,
        accept,
        playerId,
        playerName,
        profilePicture,
        teamNumber,
      ];
}

/// Join match with team selection event
class JoinMatchWithTeamEvent extends MatchEvent {
  final String code;
  final String playerId;
  final String playerName;
  final String? profilePicture;
  final int? teamNumber;

  const JoinMatchWithTeamEvent({
    required this.code,
    required this.playerId,
    required this.playerName,
    this.profilePicture,
    this.teamNumber,
  });

  @override
  List<Object?> get props => [
        code,
        playerId,
        playerName,
        profilePicture,
        teamNumber,
      ];
}

/// Leave match event
class LeaveMatchEvent extends MatchEvent {
  final String matchId;
  final String playerId;
  final String playerName;

  const LeaveMatchEvent({
    required this.matchId,
    required this.playerId,
    required this.playerName,
  });

  @override
  List<Object?> get props => [matchId, playerId, playerName];
}
