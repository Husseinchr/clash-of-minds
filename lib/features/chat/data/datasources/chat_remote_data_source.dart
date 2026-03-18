import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clash_of_minds/core/error/exceptions.dart';
import 'package:clash_of_minds/features/chat/data/models/chat_message_model.dart';

/// Chat remote data source interface
abstract class ChatRemoteDataSource {
  /// Send a chat message
  Future<ChatMessageModel> sendMessage({
    required String matchId,
    required int teamNumber,
    required String senderId,
    required String senderName,
    required String content,
  });

  /// Get chat messages for a team
  Stream<List<ChatMessageModel>> watchTeamMessages({
    required String matchId,
    required int teamNumber,
  });
}

/// Chat remote data source implementation
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  /// Get collection reference for team chat messages
  CollectionReference<Map<String, dynamic>> _getMessagesCollection(
    String matchId,
    int teamNumber,
  ) {
    return firestore
        .collection('matches')
        .doc(matchId)
        .collection('team${teamNumber}_chat');
  }

  @override
  Future<ChatMessageModel> sendMessage({
    required String matchId,
    required int teamNumber,
    required String senderId,
    required String senderName,
    required String content,
  }) async {
    try {
      final collection = _getMessagesCollection(matchId, teamNumber);
      final docRef = collection.doc();

      final message = ChatMessageModel(
        id: docRef.id,
        matchId: matchId,
        teamNumber: teamNumber,
        senderId: senderId,
        senderName: senderName,
        content: content,
        createdAt: DateTime.now(),
      );

      await docRef.set(message.toJson());
      return message;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<ChatMessageModel>> watchTeamMessages({
    required String matchId,
    required int teamNumber,
  }) {
    return _getMessagesCollection(matchId, teamNumber)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessageModel.fromJson(doc.data()))
          .toList();
    });
  }
}
