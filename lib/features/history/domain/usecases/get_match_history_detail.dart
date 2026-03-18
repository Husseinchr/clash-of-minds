import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/history/domain/entities/match_history_entity.dart';
import 'package:clash_of_minds/features/history/domain/repositories/history_repository.dart';

/// Get match history detail use case
class GetMatchHistoryDetail {
  final HistoryRepository repository;

  GetMatchHistoryDetail(this.repository);

  Future<Either<Failure, MatchHistoryEntity>> call(
    GetMatchHistoryDetailParams params,
  ) async {
    return await repository.getMatchHistoryDetail(
      matchId: params.matchId,
      userId: params.userId,
    );
  }
}

/// Get match history detail parameters
class GetMatchHistoryDetailParams extends Equatable {
  final String matchId;
  final String userId;

  const GetMatchHistoryDetailParams({
    required this.matchId,
    required this.userId,
  });

  @override
  List<Object> get props => [matchId, userId];
}
