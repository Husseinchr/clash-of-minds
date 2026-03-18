import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_invitation_entity.dart';

/// Match state
abstract class MatchState extends Equatable {
  const MatchState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MatchInitial extends MatchState {}

/// Loading state
class MatchLoading extends MatchState {}

/// Match created state
class MatchCreated extends MatchState {
  final MatchEntity match;

  const MatchCreated(this.match);

  @override
  List<Object?> get props => [match];
}

/// Match joined state
class MatchJoined extends MatchState {
  final MatchEntity match;

  const MatchJoined(this.match);

  @override
  List<Object?> get props => [match];
}

/// Match updated state
class MatchUpdated extends MatchState {
  final MatchEntity match;

  const MatchUpdated(this.match);

  @override
  List<Object?> get props => [match];
}

/// Match error state
class MatchError extends MatchState {
  final String message;

  const MatchError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Question sent state
class QuestionSent extends MatchState {}

/// Hint sent state
class HintSent extends MatchState {}

/// Answer marked state
class AnswerMarked extends MatchState {}

/// Point dismissed state
class PointDismissed extends MatchState {}

/// Match ended state
class MatchEnded extends MatchState {}

/// Team empty match ended state (when all players from a team leave)
class TeamEmptyMatchEnded extends MatchState {
  final int emptyTeamNumber;
  final MatchEntity match;

  const TeamEmptyMatchEnded(this.emptyTeamNumber, this.match);

  @override
  List<Object?> get props => [emptyTeamNumber, match];
}

/// Invitations loaded state
class InvitationsLoaded extends MatchState {
  final List<MatchInvitationEntity> invitations;

  const InvitationsLoaded(this.invitations);

  @override
  List<Object?> get props => [invitations];
}

/// Invitation sent state
class InvitationSent extends MatchState {}

/// Invitation responded state
class InvitationResponded extends MatchState {
  final bool accepted;
  final MatchEntity? match;

  const InvitationResponded({
    required this.accepted,
    this.match,
  });

  @override
  List<Object?> get props => [accepted, match];
}
