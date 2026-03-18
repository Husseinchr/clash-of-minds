import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';
import 'package:clash_of_minds/features/match/domain/repositories/match_repository.dart';

/// Create match use case
class CreateMatch {
  final MatchRepository repository;

  CreateMatch(this.repository);

  Future<Either<Failure, MatchEntity>> call(CreateMatchParams params) async {
    return await repository.createMatch(
      leaderId: params.leaderId,
      leaderName: params.leaderName,
    );
  }
}

/// Create match params
class CreateMatchParams extends Equatable {
  final String leaderId;
  final String leaderName;

  const CreateMatchParams({
    required this.leaderId,
    required this.leaderName,
  });

  @override
  List<Object> get props => [leaderId, leaderName];
}
