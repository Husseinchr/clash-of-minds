import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:clash_of_minds/core/constants/app_constants.dart';
import 'package:clash_of_minds/core/error/exceptions.dart';
import 'package:clash_of_minds/features/match/data/models/match_invitation_model.dart';
import 'package:clash_of_minds/features/match/data/models/match_model.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_invitation_entity.dart';

/// Match remote data source interface
abstract class MatchRemoteDataSource {
  Future<MatchModel> createMatch({
    required String leaderId,
    required String leaderName,
  });

  Future<MatchModel> joinMatch({
    required String code,
    required String playerId,
    required String playerName,
    String? profilePicture,
  });

  Future<MatchModel?> getMatchByCode(String code);
  Future<MatchModel?> getMatchById(String matchId);
  Stream<MatchModel> watchMatch(String matchId);
  Future<void> startMatch(String matchId);
  Future<void> sendQuestion({required String matchId, required String question});
  Future<void> sendHint({required String matchId, required String hint});
  Future<void> setCurrentAnswerer({
    required String matchId,
    required String playerId,
    required String playerName,
    required String answer,
  });
  Future<void> markAnswerCorrect({
    required String matchId,
    required String playerId,
    required int teamNumber,
  });
  Future<void> markAnswerWrong({required String matchId});
  Future<void> dismissPoint({required String matchId});
  Future<void> switchTeamTurn({required String matchId});
  Future<void> endMatch(String matchId);

  /// Send match invitation
  Future<MatchInvitationModel> sendMatchInvitation({
    required String matchId,
    required String matchCode,
    required String fromUserId,
    required String fromUserName,
    required String toUserId,
    required String toUserName,
  });

  /// Get match invitations
  Future<List<MatchInvitationModel>> getMatchInvitations(String userId);

  /// Respond to invitation
  Future<MatchModel> respondToInvitation({
    required String invitationId,
    required bool accept,
    required String playerId,
    required String playerName,
    String? profilePicture,
    int? teamNumber,
  });

  /// Join match with team selection
  Future<MatchModel> joinMatchWithTeam({
    required String code,
    required String playerId,
    required String playerName,
    String? profilePicture,
    int? teamNumber,
  });

  /// Leave match - removes player from their team
  Future<void> leaveMatch({
    required String matchId,
    required String playerId,
    required String playerName,
  });
}

/// Match remote data source implementation
class MatchRemoteDataSourceImpl implements MatchRemoteDataSource {
  final FirebaseFirestore firestore;

  MatchRemoteDataSourceImpl({required this.firestore});

  /// Generate a unique 4-digit code
  Future<String> _generateUniqueCode() async {
    const maxAttempts = 10;
    for (var i = 0; i < maxAttempts; i++) {
      final code = Random().nextInt(9000) + 1000;
      final codeStr = code.toString();

      final existing = await getMatchByCode(codeStr);
      if (existing == null) {
        return codeStr;
      }
    }
    throw ServerException('Could not generate unique code');
  }

  @override
  Future<MatchModel> createMatch({
    required String leaderId,
    required String leaderName,
  }) async {
    try {
      final code = await _generateUniqueCode();
      final docRef = firestore.collection(AppConstants.matchesCollection).doc();

      final match = MatchModel(
        id: docRef.id,
        code: code,
        leaderId: leaderId,
        leaderName: leaderName,
        team1PlayerIds: [],
        team2PlayerIds: [],
        team1Score: 0,
        team2Score: 0,
        status: MatchStatus.waiting,
        createdAt: DateTime.now(),
      );

      await docRef.set(match.toJson());
      return match;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchModel> joinMatch({
    required String code,
    required String playerId,
    required String playerName,
    String? profilePicture,
  }) async {
    try {
      final match = await getMatchByCode(code);
      if (match == null) {
        throw ServerException('Match not found');
      }

      if (match.status != MatchStatus.waiting) {
        throw ServerException('Match has already started');
      }

      final totalPlayers =
          match.team1PlayerIds.length + match.team2PlayerIds.length;
      if (totalPlayers >= AppConstants.maxPlayersPerMatch) {
        throw ServerException('Match is full');
      }

      // Check if player is already in the match
      if (match.team1PlayerIds.contains(playerId) ||
          match.team2PlayerIds.contains(playerId)) {
        return match;
      }

      // Assign to team with fewer players
      final updatedMatch = match.team1PlayerIds.length <=
              match.team2PlayerIds.length
          ? match.copyWith(
              team1PlayerIds: [...match.team1PlayerIds, playerId],
            )
          : match.copyWith(
              team2PlayerIds: [...match.team2PlayerIds, playerId],
            );

      await firestore
          .collection(AppConstants.matchesCollection)
          .doc(match.id)
          .update(updatedMatch.toJson());

      return updatedMatch;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchModel?> getMatchByCode(String code) async {
    try {
      final querySnapshot = await firestore
          .collection(AppConstants.matchesCollection)
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return MatchModel.fromJson(querySnapshot.docs.first.data());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchModel?> getMatchById(String matchId) async {
    try {
      final doc = await firestore
          .collection(AppConstants.matchesCollection)
          .doc(matchId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return MatchModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<MatchModel> watchMatch(String matchId) {
    return firestore
        .collection(AppConstants.matchesCollection)
        .doc(matchId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw ServerException('Match not found');
      }
      return MatchModel.fromJson(doc.data()!);
    });
  }

  @override
  Future<void> startMatch(String matchId) async {
    try {
      await firestore
          .collection(AppConstants.matchesCollection)
          .doc(matchId)
          .update({
        'status': MatchStatus.inProgress.toString().split('.').last,
        'startedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendQuestion({
    required String matchId,
    required String question,
  }) async {
    try {
      await firestore
          .collection(AppConstants.matchesCollection)
          .doc(matchId)
          .update({
        'currentQuestion': question,
        'currentHint': null,
        'currentAnswerer': null,
        'currentAnswererName': null,
        'currentAnswer': null,
        'currentTeamTurn': null, // Clear team turn - both teams can answer
        'teamTurnStartTime': null,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendHint({required String matchId, required String hint}) async {
    try {
      await firestore
          .collection(AppConstants.matchesCollection)
          .doc(matchId)
          .update({
        'currentHint': hint,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> setCurrentAnswerer({
    required String matchId,
    required String playerId,
    required String playerName,
    required String answer,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'currentAnswerer': playerId,
        'currentAnswererName': playerName,
        'currentAnswer': answer,
      };

      // Set answerStartTime when player starts answering (empty answer)
      // Use server timestamp for consistent timing across all devices
      if (answer.isEmpty) {
        updateData['answerStartTime'] = FieldValue.serverTimestamp();
      }

      await firestore
          .collection(AppConstants.matchesCollection)
          .doc(matchId)
          .update(updateData);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAnswerCorrect({
    required String matchId,
    required String playerId,
    required int teamNumber,
  }) async {
    try {
      final match = await getMatchById(matchId);
      if (match == null) {
        throw ServerException('Match not found');
      }

      final scoreField = teamNumber == 1 ? 'team1Score' : 'team2Score';
      final currentScore = teamNumber == 1 ? match.team1Score : match.team2Score;

      await firestore
          .collection(AppConstants.matchesCollection)
          .doc(matchId)
          .update({
        scoreField: currentScore + 1,
        'currentQuestion': null,
        'currentHint': null,
        'currentAnswerer': null,
        'currentAnswererName': null,
        'currentAnswer': null,
        'answerStartTime': null,
        'currentTeamTurn': null, // Clear team turn after correct answer
        'teamTurnStartTime': null,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAnswerWrong({required String matchId}) async {
    try {
      // Get the current match to determine which team answered wrong
      final match = await getMatchById(matchId);
      if (match == null) {
        throw ServerException('Match not found');
      }

      int? nextTeamTurn;

      // If there was an answerer, set turn to the opposite team
      if (match.currentAnswerer != null) {
        final isTeam1 = match.team1PlayerIds.contains(match.currentAnswerer);
        final isTeam2 = match.team2PlayerIds.contains(match.currentAnswerer);

        if (isTeam1) {
          nextTeamTurn = 2; // Team 1 answered wrong, Team 2's turn
        } else if (isTeam2) {
          nextTeamTurn = 1; // Team 2 answered wrong, Team 1's turn
        }
      }

      await firestore
          .collection(AppConstants.matchesCollection)
          .doc(matchId)
          .update({
        'currentAnswerer': null,
        'currentAnswererName': null,
        'currentAnswer': null,
        'answerStartTime': null,
        'currentTeamTurn': nextTeamTurn,
        'teamTurnStartTime': nextTeamTurn != null ? FieldValue.serverTimestamp() : null,
        'teamTurnVersion': FieldValue.increment(1),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> dismissPoint({required String matchId}) async {
    try {
      await firestore
          .collection(AppConstants.matchesCollection)
          .doc(matchId)
          .update({
        'currentQuestion': null,
        'currentHint': null,
        'currentAnswerer': null,
        'currentAnswererName': null,
        'currentAnswer': null,
        'answerStartTime': null,
        'currentTeamTurn': null, // Clear team turn when dismissing
        'teamTurnStartTime': null,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> switchTeamTurn({required String matchId}) async {
    debugPrint('🟡 [SWITCH] switchTeamTurn called for match: $matchId');
    try {
      // Use Firestore transaction to prevent race conditions
      await firestore.runTransaction((transaction) async {
        final matchRef = firestore
            .collection(AppConstants.matchesCollection)
            .doc(matchId);

        final matchSnapshot = await transaction.get(matchRef);
        if (!matchSnapshot.exists) {
          debugPrint('🔴 [SWITCH] Match not found!');
          throw ServerException('Match not found');
        }

        final match = MatchModel.fromJson(matchSnapshot.data()!);
        debugPrint('🟡 [SWITCH] Current state - Team: ${match.currentTeamTurn}, Answerer: ${match.currentAnswerer}, Question: ${match.currentQuestion != null ? "exists" : "null"}');

        // Safety checks - only switch if:
        // 1. There is a current team turn set
        // 2. No one has claimed the question yet
        // 3. Current question still exists
        if (match.currentTeamTurn == null) {
          debugPrint('🔴 [SWITCH] Aborting - currentTeamTurn is null');
          return;
        }
        if (match.currentAnswerer != null) {
          debugPrint('🔴 [SWITCH] Aborting - someone claimed (${match.currentAnswerer})');
          return;
        }
        if (match.currentQuestion == null) {
          debugPrint('🔴 [SWITCH] Aborting - no question exists');
          return;
        }

        // Switch to the opposite team
        int? nextTeamTurn;
        if (match.currentTeamTurn == 1) {
          nextTeamTurn = 2;
        } else if (match.currentTeamTurn == 2) {
          nextTeamTurn = 1;
        }

        debugPrint('🟡 [SWITCH] Switching from Team ${match.currentTeamTurn} to Team $nextTeamTurn');

        // Only update if there was a team turn to switch
        if (nextTeamTurn != null) {
          transaction.update(matchRef, {
            'currentTeamTurn': nextTeamTurn,
            'teamTurnStartTime': FieldValue.serverTimestamp(),
            'teamTurnVersion': FieldValue.increment(1),
          });
          debugPrint('✅ [SWITCH] Update transaction queued successfully');
        }
      });
      debugPrint('✅ [SWITCH] Transaction committed successfully');
    } catch (e) {
      debugPrint('🔴 [SWITCH] Error: $e');
      // Silently fail if transaction conflict (another client already switched)
      if (!e.toString().contains('aborted') && !e.toString().contains('conflict')) {
        throw ServerException(e.toString());
      }
    }
  }

  @override
  Future<void> endMatch(String matchId) async {
    try {
      // Update match status
      await firestore
          .collection(AppConstants.matchesCollection)
          .doc(matchId)
          .update({
        'status': MatchStatus.completed.toString().split('.').last,
        'completedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Fetch completed match data
      final matchDoc = await firestore
          .collection(AppConstants.matchesCollection)
          .doc(matchId)
          .get();

      if (matchDoc.exists) {
        final match = MatchModel.fromJson(matchDoc.data()!);

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
            playerNames[playerId] = 'Unknown';
          }
        }

        // Calculate winning team
        final winningTeam = match.team1Score > match.team2Score
            ? 1
            : (match.team2Score > match.team1Score ? 2 : 0);

        // Create history entry
        final historyData = {
          'id': match.id,
          'matchCode': match.code,
          'leaderId': match.leaderId,
          'leaderName': match.leaderName,
          'team1PlayerIds': match.team1PlayerIds,
          'team2PlayerIds': match.team2PlayerIds,
          'participantIds': allPlayerIds,
          'playerNames': playerNames,
          'team1Score': match.team1Score,
          'team2Score': match.team2Score,
          'winningTeam': winningTeam,
          'createdAt': Timestamp.fromDate(match.createdAt),
          'startedAt': match.startedAt != null
              ? Timestamp.fromDate(match.startedAt!)
              : null,
          'completedAt': Timestamp.fromDate(match.completedAt!),
        };

        // Save to history collection (fault-tolerant)
        try {
          await firestore
              .collection(AppConstants.historyCollection)
              .doc(match.id)
              .set(historyData);
        } catch (e) {
          // Log error but don't fail the match completion
          debugPrint('Failed to save match to history: $e');
        }
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchInvitationModel> sendMatchInvitation({
    required String matchId,
    required String matchCode,
    required String fromUserId,
    required String fromUserName,
    required String toUserId,
    required String toUserName,
  }) async {
    try {
      // Check for existing pending invitation
      final existingQuery = await firestore
          .collection(AppConstants.matchInvitationsCollection)
          .where('matchId', isEqualTo: matchId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        return MatchInvitationModel.fromJson(existingQuery.docs.first.data());
      }

      final docRef =
          firestore.collection(AppConstants.matchInvitationsCollection).doc();

      final invitation = MatchInvitationModel(
        id: docRef.id,
        matchId: matchId,
        matchCode: matchCode,
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        toUserId: toUserId,
        toUserName: toUserName,
        status: InvitationStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );

      await docRef.set(invitation.toJson());
      return invitation;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MatchInvitationModel>> getMatchInvitations(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection(AppConstants.matchInvitationsCollection)
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MatchInvitationModel.fromJson(doc.data()))
          .where((inv) => !inv.isExpired)
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchModel> respondToInvitation({
    required String invitationId,
    required bool accept,
    required String playerId,
    required String playerName,
    String? profilePicture,
    int? teamNumber,
  }) async {
    try {
      final invDoc = await firestore
          .collection(AppConstants.matchInvitationsCollection)
          .doc(invitationId)
          .get();

      if (!invDoc.exists) {
        throw ServerException('Invitation not found');
      }

      final invitation = MatchInvitationModel.fromJson(invDoc.data()!);

      if (invitation.isExpired) {
        await firestore
            .collection(AppConstants.matchInvitationsCollection)
            .doc(invitationId)
            .update({
          'status': InvitationStatus.expired.toString().split('.').last,
        });
        throw ServerException('Invitation has expired');
      }

      await firestore
          .collection(AppConstants.matchInvitationsCollection)
          .doc(invitationId)
          .update({
        'status': accept
            ? InvitationStatus.accepted.toString().split('.').last
            : InvitationStatus.declined.toString().split('.').last,
        'respondedAt': Timestamp.fromDate(DateTime.now()),
      });

      if (!accept) {
        final match = await getMatchById(invitation.matchId);
        if (match == null) {
          throw ServerException('Match not found');
        }
        return match;
      }

      return await joinMatchWithTeam(
        code: invitation.matchCode,
        playerId: playerId,
        playerName: playerName,
        profilePicture: profilePicture,
        teamNumber: teamNumber,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MatchModel> joinMatchWithTeam({
    required String code,
    required String playerId,
    required String playerName,
    String? profilePicture,
    int? teamNumber,
  }) async {
    try {
      final match = await getMatchByCode(code);
      if (match == null) {
        throw ServerException('Match not found');
      }

      if (match.status != MatchStatus.waiting) {
        throw ServerException('Match has already started');
      }

      if (match.team1PlayerIds.contains(playerId) ||
          match.team2PlayerIds.contains(playerId)) {
        return match;
      }

      final totalPlayers =
          match.team1PlayerIds.length + match.team2PlayerIds.length;
      if (totalPlayers >= AppConstants.maxPlayersPerMatch) {
        throw ServerException('Match is full');
      }

      MatchModel updatedMatch;

      if (teamNumber == null) {
        updatedMatch = match.team1PlayerIds.length <=
                match.team2PlayerIds.length
            ? match.copyWith(
                team1PlayerIds: [...match.team1PlayerIds, playerId])
            : match.copyWith(
                team2PlayerIds: [...match.team2PlayerIds, playerId]);
      } else {
        final targetTeam =
            teamNumber == 1 ? match.team1PlayerIds : match.team2PlayerIds;

        if (targetTeam.length >= AppConstants.maxPlayersPerTeam) {
          final otherTeam =
              teamNumber == 1 ? match.team2PlayerIds : match.team1PlayerIds;
          if (otherTeam.length >= AppConstants.maxPlayersPerTeam) {
            throw ServerException('No space available in any team');
          }
          updatedMatch = teamNumber == 1
              ? match.copyWith(
                  team2PlayerIds: [...match.team2PlayerIds, playerId])
              : match.copyWith(
                  team1PlayerIds: [...match.team1PlayerIds, playerId]);
        } else {
          updatedMatch = teamNumber == 1
              ? match.copyWith(
                  team1PlayerIds: [...match.team1PlayerIds, playerId])
              : match.copyWith(
                  team2PlayerIds: [...match.team2PlayerIds, playerId]);
        }
      }

      await firestore
          .collection(AppConstants.matchesCollection)
          .doc(match.id)
          .update(updatedMatch.toJson());

      return updatedMatch;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> leaveMatch({
    required String matchId,
    required String playerId,
    required String playerName,
  }) async {
    try {
      final match = await getMatchById(matchId);
      if (match == null) {
        throw ServerException('Match not found');
      }

      // Add system message
      final systemMessage = '$playerName left the match';
      final updatedMessages = [...match.systemMessages, systemMessage];

      // Remove player from whichever team they're in
      final isTeam1 = match.team1PlayerIds.contains(playerId);
      final newTeam1 = isTeam1
          ? match.team1PlayerIds.where((id) => id != playerId).toList()
          : match.team1PlayerIds;
      final newTeam2 = !isTeam1
          ? match.team2PlayerIds.where((id) => id != playerId).toList()
          : match.team2PlayerIds;

      // Check if any team is now empty - if so, end the match
      final shouldEndMatch = newTeam1.isEmpty || newTeam2.isEmpty;

      final updatedMatch = match.copyWith(
        team1PlayerIds: newTeam1,
        team2PlayerIds: newTeam2,
        systemMessages: updatedMessages,
        status: shouldEndMatch ? MatchStatus.completed : match.status,
        completedAt: shouldEndMatch ? DateTime.now() : match.completedAt,
      );

      await firestore
          .collection(AppConstants.matchesCollection)
          .doc(matchId)
          .update(updatedMatch.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
