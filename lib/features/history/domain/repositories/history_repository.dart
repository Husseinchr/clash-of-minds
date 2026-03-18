import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/history/domain/entities/match_history_entity.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';

/// History repository interface
abstract class HistoryRepository {
  /// Get match history for a user
  Future<Either<Failure, List<MatchHistoryEntity>>> getMatchHistory({
    required String userId,
    int limit = 20,
  });

  /// Get single match history detail
  Future<Either<Failure, MatchHistoryEntity>> getMatchHistoryDetail({
    required String matchId,
    required String userId,
  });

  /// Save completed match to history
  Future<Either<Failure, void>> saveMatchToHistory(MatchEntity match);
}
