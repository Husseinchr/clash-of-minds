import 'package:dartz/dartz.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_invitation_entity.dart';
import 'package:clash_of_minds/features/match/domain/repositories/match_repository.dart';

/// Get match invitations use case
class GetMatchInvitations {
  final MatchRepository repository;

  GetMatchInvitations(this.repository);

  Future<Either<Failure, List<MatchInvitationEntity>>> call(
    String userId,
  ) async {
    return await repository.getMatchInvitations(userId);
  }
}
