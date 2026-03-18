import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clash_of_minds/features/chat/domain/entities/chat_message_entity.dart';

/// Chat message model for Firestore serialization
class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.matchId,
    required super.teamNumber,
    required super.senderId,
    required super.senderName,
    required super.content,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      teamNumber: json['teamNumber'] as int,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      content: json['content'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'teamNumber': teamNumber,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      id: entity.id,
      matchId: entity.matchId,
      teamNumber: entity.teamNumber,
      senderId: entity.senderId,
      senderName: entity.senderName,
      content: entity.content,
      createdAt: entity.createdAt,
    );
  }
}
