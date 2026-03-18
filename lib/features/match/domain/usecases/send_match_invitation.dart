import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:clash_of_minds/core/error/failures.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_invitation_entity.dart';
import 'package:clash_of_minds/features/match/domain/repositories/match_repository.dart';

/// Send match invitation use case
class SendMatchInvitation {
  final MatchRepository repository;

  SendMatchInvitation(this.repository);

  Future<Either<Failure, MatchInvitationEntity>> call(
    SendMatchInvitationParams params,
  ) async {
    return await repository.sendMatchInvitation(
      matchId: params.matchId,
      matchCode: params.matchCode,
      fromUserId: params.fromUserId,
      fromUserName: params.fromUserName,
      toUserId: params.toUserId,
      toUserName: params.toUserName,
    );
  }
}

/// Parameters for sending match invitation
class SendMatchInvitationParams extends Equatable {
  final String matchId;
  final String matchCode;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;

  const SendMatchInvitationParams({
    required this.matchId,
    required this.matchCode,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
  });

  @override
  List<Object?> get props => [
        matchId,
        matchCode,
        fromUserId,
        fromUserName,
        toUserId,
        toUserName,
      ];
}
