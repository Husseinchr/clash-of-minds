import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/exceptions.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/history/data/datasources/history_remote_data_source.dart';
import 'package:clash_of_minds/features/history/domain/entities/match_history_entity.dart';
import 'package:clash_of_minds/features/history/domain/repositories/history_repository.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';

/// History repository implementation
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;

  HistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MatchHistoryEntity>>> getMatchHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final history = await remoteDataSource.getMatchHistory(
        userId: userId,
        limit: limit,
      );
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MatchHistoryEntity>> getMatchHistoryDetail({
    required String matchId,
    required String userId,
  }) async {
    try {
      final history = await remoteDataSource.getMatchHistoryDetail(
        matchId: matchId,
        userId: userId,
      );
      return Right(history);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveMatchToHistory(MatchEntity match) async {
    try {
      await remoteDataSource.saveMatchToHistory(match);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
