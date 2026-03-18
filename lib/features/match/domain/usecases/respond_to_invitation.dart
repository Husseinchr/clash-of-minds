import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';
import 'package:clash_of_minds/features/match/domain/repositories/match_repository.dart';

/// Respond to invitation use case
class RespondToInvitation {
  final MatchRepository repository;

  RespondToInvitation(this.repository);

  Future<Either<Failure, MatchEntity>> call(
    RespondToInvitationParams params,
  ) async {
    return await repository.respondToInvitation(
      invitationId: params.invitationId,
      accept: params.accept,
      playerId: params.playerId,
      playerName: params.playerName,
      profilePicture: params.profilePicture,
      teamNumber: params.teamNumber,
    );
  }
}

/// Parameters for responding to invitation
class RespondToInvitationParams extends Equatable {
  final String invitationId;
  final bool accept;
  final String playerId;
  final String playerName;
  final String? profilePicture;
  final int? teamNumber;

  const RespondToInvitationParams({
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
