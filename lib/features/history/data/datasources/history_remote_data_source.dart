import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clash_of_minds/core/constants/app_constants.dart';
import 'package:clash_of_minds/core/error/exceptions.dart';
import 'package:clash_of_minds/features/history/data/models/match_history_model.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';

/// History remote data source interface
abstract class HistoryRemoteDataSource {
  Future<List<MatchHistoryModel>> getMatchHistory({
    required String userId,
    int limit = 20,
  });

  Future<MatchHistoryModel> getMatchHistoryDetail({
    required String matchId,
    required String userId,
  });

  Future<void> saveMatchToHistory(MatchEntity match);
}

/// History remote data source implementation
class HistoryRemoteDataSourceImpl implements HistoryRemoteDataSource {
  final FirebaseFirestore firestore;

  HistoryRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<MatchHistoryModel>> getMatchHistory({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection(AppConstants.historyCollection)
          .where('participantIds', arrayContains: userId)
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => MatchHistoryModel.fromJson(doc.data(), userId))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchHistoryModel> getMatchHistoryDetail({
    required String matchId,
    required String userId,
  }) async {
    try {
      final docSnapshot = await firestore
          .collection(AppConstants.historyCollection)
          .doc(matchId)
          .get();

      if (!docSnapshot.exists) {
        throw ServerException('Match history not found');
      }

      return MatchHistoryModel.fromJson(docSnapshot.data()!, userId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> saveMatchToHistory(MatchEntity match) async {
    try {
      // Fetch all participant names
      final allPlayerIds = [...match.team1PlayerIds, ...match.team2PlayerIds];
      final playerNames = <String, String>{};

      for (final playerId in allPlayerIds) {
        try {
          final userDoc = await firestore
              .collection(AppConstants.usersCollection)
              .doc(playerId)
              .get();
          if (userDoc.exists) {
            playerNames[playerId] = userDoc.data()!['displayName'] as String;
          }
        } catch (e) {
          // If fetching a player name fails, use a placeholder
          playerNames[playerId] = 'Unknown';
        }
      }

      // Create history model
      final historyModel =
          await MatchHistoryModel.fromMatchEntity(match, playerNames);

      // Save to history collection
      await firestore
          .collection(AppConstants.historyCollection)
          .doc(match.id)
          .set(historyModel.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
