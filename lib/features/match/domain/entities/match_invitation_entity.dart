import 'package:equatable/equatable.dart';

/// Match invitation status enum
enum InvitationStatus {
  pending,
  accepted,
  declined,
  expired,
}

/// Match invitation entity
class MatchInvitationEntity extends Equatable {
  final String id;
  final String matchId;
  final String matchCode;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final InvitationStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;

  const MatchInvitationEntity({
    required this.id,
    required this.matchId,
    required this.matchCode,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    this.respondedAt,
  });

  /// Check if invitation is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if invitation is pending and not expired
  bool get isPending => status == InvitationStatus.pending && !isExpired;

  @override
  List<Object?> get props => [
        id,
        matchId,
        matchCode,
        fromUserId,
        fromUserName,
        toUserId,
        toUserName,
        status,
        createdAt,
        expiresAt,
        respondedAt,
      ];
}
