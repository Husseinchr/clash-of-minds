import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/history/domain/entities/match_history_entity.dart';
import 'package:clash_of_minds/features/history/domain/repositories/history_repository.dart';

/// Get match history use case
class GetMatchHistory {
  final HistoryRepository repository;

  GetMatchHistory(this.repository);

  Future<Either<Failure, List<MatchHistoryEntity>>> call(
    GetMatchHistoryParams params,
  ) async {
    return await repository.getMatchHistory(
      userId: params.userId,
      limit: params.limit,
    );
  }
}

/// Get match history parameters
class GetMatchHistoryParams extends Equatable {
  final String userId;
  final int limit;

  const GetMatchHistoryParams({
    required this.userId,
    this.limit = 20,
  });

  @override
  List<Object> get props => [userId, limit];
}
