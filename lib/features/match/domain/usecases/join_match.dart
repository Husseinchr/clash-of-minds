import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';
import 'package:clash_of_minds/features/match/domain/repositories/match_repository.dart';

/// Join match use case
class JoinMatch {
  final MatchRepository repository;

  JoinMatch(this.repository);

  Future<Either<Failure, MatchEntity>> call(JoinMatchParams params) async {
    return await repository.joinMatch(
      code: params.code,
      playerId: params.playerId,
      playerName: params.playerName,
      profilePicture: params.profilePicture,
    );
  }
}

/// Join match params
class JoinMatchParams extends Equatable {
  final String code;
  final String playerId;
  final String playerName;
  final String? profilePicture;

  const JoinMatchParams({
    required this.code,
    required this.playerId,
    required this.playerName,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [code, playerId, playerName, profilePicture];
}
