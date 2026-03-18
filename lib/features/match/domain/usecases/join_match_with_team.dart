import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';
import 'package:clash_of_minds/features/match/domain/repositories/match_repository.dart';

/// Join match with team selection use case
class JoinMatchWithTeam {
  final MatchRepository repository;

  JoinMatchWithTeam(this.repository);

  Future<Either<Failure, MatchEntity>> call(
    JoinMatchWithTeamParams params,
  ) async {
    return await repository.joinMatchWithTeam(
      code: params.code,
      playerId: params.playerId,
      playerName: params.playerName,
      profilePicture: params.profilePicture,
      teamNumber: params.teamNumber,
    );
  }
}

/// Parameters for joining match with team
class JoinMatchWithTeamParams extends Equatable {
  final String code;
  final String playerId;
  final String playerName;
  final String? profilePicture;
  final int? teamNumber;

  const JoinMatchWithTeamParams({
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
