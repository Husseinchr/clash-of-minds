import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_invitation_entity.dart';

/// Match invitation model
class MatchInvitationModel extends MatchInvitationEntity {
  const MatchInvitationModel({
    required super.id,
    required super.matchId,
    required super.matchCode,
    required super.fromUserId,
    required super.fromUserName,
    required super.toUserId,
    required super.toUserName,
    required super.status,
    required super.createdAt,
    required super.expiresAt,
    super.respondedAt,
  });

  /// From JSON
  factory MatchInvitationModel.fromJson(Map<String, dynamic> json) {
    return MatchInvitationModel(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      matchCode: json['matchCode'] as String,
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String,
      toUserId: json['toUserId'] as String,
      toUserName: json['toUserName'] as String,
      status: InvitationStatus.values.firstWhere(
        (e) => e.toString() == 'InvitationStatus.${json['status']}',
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      expiresAt: (json['expiresAt'] as Timestamp).toDate(),
      respondedAt: json['respondedAt'] != null
          ? (json['respondedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'matchCode': matchCode,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }
}
