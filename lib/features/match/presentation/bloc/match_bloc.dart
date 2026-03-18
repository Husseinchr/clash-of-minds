import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';
import 'package:clash_of_minds/features/match/domain/repositories/match_repository.dart';
import 'package:clash_of_minds/features/match/domain/usecases/create_match.dart';
import 'package:clash_of_minds/features/match/domain/usecases/get_match_invitations.dart';
import 'package:clash_of_minds/features/match/domain/usecases/join_match.dart';
import 'package:clash_of_minds/features/match/domain/usecases/join_match_with_team.dart';
import 'package:clash_of_minds/features/match/domain/usecases/respond_to_invitation.dart';
import 'package:clash_of_minds/features/match/domain/usecases/send_match_invitation.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_event.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_state.dart';

/// Match BLoC
class MatchBloc extends Bloc<MatchEvent, MatchState> {
  final CreateMatch createMatch;
  final JoinMatch joinMatch;
  final MatchRepository repository;
  final SendMatchInvitation sendMatchInvitation;
  final GetMatchInvitations getMatchInvitations;
  final RespondToInvitation respondToInvitation;
  final JoinMatchWithTeam joinMatchWithTeam;

  MatchBloc({
    required this.createMatch,
    required this.joinMatch,
    required this.repository,
    required this.sendMatchInvitation,
    required this.getMatchInvitations,
    required this.respondToInvitation,
    required this.joinMatchWithTeam,
  }) : super(MatchInitial()) {
    on<CreateMatchEvent>(_onCreateMatch);
    on<JoinMatchEvent>(_onJoinMatch);
    on<WatchMatchEvent>(_onWatchMatch);
    on<StartMatchEvent>(_onStartMatch);
    on<SendQuestionEvent>(_onSendQuestion);
    on<SendHintEvent>(_onSendHint);
    on<SetAnswererEvent>(_onSetAnswerer);
    on<MarkAnswerCorrectEvent>(_onMarkAnswerCorrect);
    on<MarkAnswerWrongEvent>(_onMarkAnswerWrong);
    on<DismissPointEvent>(_onDismissPoint);
    on<SwitchTeamTurnEvent>(_onSwitchTeamTurn);
    on<EndMatchEvent>(_onEndMatch);
    on<SendMatchInvitationEvent>(_onSendInvitation);
    on<LoadMatchInvitationsEvent>(_onLoadInvitations);
    on<RespondToInvitationEvent>(_onRespondToInvitation);
    on<JoinMatchWithTeamEvent>(_onJoinMatchWithTeam);
    on<LeaveMatchEvent>(_onLeaveMatch);
  }

  Future<void> _onCreateMatch(
    CreateMatchEvent event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await createMatch(
      CreateMatchParams(
        leaderId: event.leaderId,
        leaderName: event.leaderName,
      ),
    );
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (match) => emit(MatchCreated(match)),
    );
  }

  Future<void> _onJoinMatch(
    JoinMatchEvent event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await joinMatch(
      JoinMatchParams(
        code: event.code,
        playerId: event.playerId,
        playerName: event.playerName,
        profilePicture: event.profilePicture,
      ),
    );
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (match) => emit(MatchJoined(match)),
    );
  }

  Future<void> _onWatchMatch(
    WatchMatchEvent event,
    Emitter<MatchState> emit,
  ) async {
    await emit.forEach(
      repository.watchMatch(event.matchId),
      onData: (result) {
        return result.fold(
          (failure) => MatchEnded(), // Match was deleted or error occurred
          (match) {
            // Check if match is completed
            if (match.status == MatchStatus.completed) {
              // Check if it's because a team became empty (player left)
              if (match.systemMessages.isNotEmpty &&
                  match.systemMessages.last.contains('left the match')) {
                // Determine which team is empty
                final emptyTeamNumber =
                    match.team1PlayerIds.isEmpty ? 1 : 2;
                return TeamEmptyMatchEnded(emptyTeamNumber, match);
              }
              return MatchEnded();
            }
            return MatchUpdated(match);
          },
        );
      },
    );
  }

  Future<void> _onStartMatch(
    StartMatchEvent event,
    Emitter<MatchState> emit,
  ) async {
    final result = await repository.startMatch(event.matchId);
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (_) => null,
    );
  }

  Future<void> _onSendQuestion(
    SendQuestionEvent event,
    Emitter<MatchState> emit,
  ) async {
    final result = await repository.sendQuestion(
      matchId: event.matchId,
      question: event.question,
    );
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (_) => emit(QuestionSent()),
    );
  }

  Future<void> _onSendHint(
    SendHintEvent event,
    Emitter<MatchState> emit,
  ) async {
    final result = await repository.sendHint(
      matchId: event.matchId,
      hint: event.hint,
    );
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (_) => emit(HintSent()),
    );
  }

  Future<void> _onSetAnswerer(
    SetAnswererEvent event,
    Emitter<MatchState> emit,
  ) async {
    final result = await repository.setCurrentAnswerer(
      matchId: event.matchId,
      playerId: event.playerId,
      playerName: event.playerName,
      answer: event.answer,
    );
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (_) => null,
    );
  }

  Future<void> _onMarkAnswerCorrect(
    MarkAnswerCorrectEvent event,
    Emitter<MatchState> emit,
  ) async {
    final result = await repository.markAnswerCorrect(
      matchId: event.matchId,
      playerId: event.playerId,
      teamNumber: event.teamNumber,
    );
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (_) => emit(AnswerMarked()),
    );
  }

  Future<void> _onMarkAnswerWrong(
    MarkAnswerWrongEvent event,
    Emitter<MatchState> emit,
  ) async {
    final result = await repository.markAnswerWrong(matchId: event.matchId);
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (_) => emit(AnswerMarked()),
    );
  }

  Future<void> _onDismissPoint(
    DismissPointEvent event,
    Emitter<MatchState> emit,
  ) async {
    final result = await repository.dismissPoint(matchId: event.matchId);
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (_) => emit(PointDismissed()),
    );
  }

  Future<void> _onSwitchTeamTurn(
    SwitchTeamTurnEvent event,
    Emitter<MatchState> emit,
  ) async {
    final result = await repository.switchTeamTurn(matchId: event.matchId);
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (_) => null, // Silent success - the match stream will notify of the change
    );
  }

  Future<void> _onEndMatch(
    EndMatchEvent event,
    Emitter<MatchState> emit,
  ) async {
    final result = await repository.endMatch(event.matchId);
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (_) => emit(MatchEnded()),
    );
  }

  Future<void> _onSendInvitation(
    SendMatchInvitationEvent event,
    Emitter<MatchState> emit,
  ) async {
    final result = await sendMatchInvitation(
      SendMatchInvitationParams(
        matchId: event.matchId,
        matchCode: event.matchCode,
        fromUserId: event.fromUserId,
        fromUserName: event.fromUserName,
        toUserId: event.toUserId,
        toUserName: event.toUserName,
      ),
    );
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (_) => emit(InvitationSent()),
    );
  }

  Future<void> _onLoadInvitations(
    LoadMatchInvitationsEvent event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await getMatchInvitations(event.userId);
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (invitations) => emit(InvitationsLoaded(invitations)),
    );
  }

  Future<void> _onRespondToInvitation(
    RespondToInvitationEvent event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await respondToInvitation(
      RespondToInvitationParams(
        invitationId: event.invitationId,
        accept: event.accept,
        playerId: event.playerId,
        playerName: event.playerName,
        profilePicture: event.profilePicture,
        teamNumber: event.teamNumber,
      ),
    );
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (match) => emit(InvitationResponded(
        accepted: event.accept,
        match: event.accept ? match : null,
      )),
    );
  }

  Future<void> _onJoinMatchWithTeam(
    JoinMatchWithTeamEvent event,
    Emitter<MatchState> emit,
  ) async {
    emit(MatchLoading());
    final result = await joinMatchWithTeam(
      JoinMatchWithTeamParams(
        code: event.code,
        playerId: event.playerId,
        playerName: event.playerName,
        profilePicture: event.profilePicture,
        teamNumber: event.teamNumber,
      ),
    );
    result.fold(
      (failure) => emit(MatchError(failure.message)),
      (match) => emit(MatchJoined(match)),
    );
  }

  Future<void> _onLeaveMatch(
    LeaveMatchEvent event,
    Emitter<MatchState> emit,
  ) async {
    // Don't emit loading state to avoid disrupting the UI
    final result = await repository.leaveMatch(
      matchId: event.matchId,
      playerId: event.playerId,
      playerName: event.playerName,
    );
    result.fold(
      (failure) => {}, // Silently fail - user is leaving anyway
      (_) => {}, // Success - no state change needed
    );
  }
}
