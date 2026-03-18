import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clash_of_minds/core/constants/app_constants.dart';
import 'package:clash_of_minds/core/error/exceptions.dart';
import 'package:clash_of_minds/features/friends/data/models/friend_model.dart';
import 'package:clash_of_minds/features/friends/domain/entities/friend_entity.dart';

/// Friends remote data source interface
abstract class FriendsRemoteDataSource {
  Future<void> sendFriendRequestByDisplayName({
    required String fromUserId,
    required String fromUserName,
    String? fromUserPhoto,
    required String displayName,
  });

  Future<List<FriendRequestModel>> getFriendRequests(String userId);
  Future<void> acceptFriendRequest(String requestId);
  Future<void> declineFriendRequest(String requestId);
  Future<List<FriendModel>> getFriends(String userId);
  Future<void> removeFriend({required String userId, required String friendId});
  Future<List<FriendModel>> searchUsers(String displayName);
}

/// Friends remote data source implementation
class FriendsRemoteDataSourceImpl implements FriendsRemoteDataSource {
  final FirebaseFirestore firestore;

  FriendsRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> sendFriendRequestByDisplayName({
    required String fromUserId,
    required String fromUserName,
    String? fromUserPhoto,
    required String displayName,
  }) async {
    try {
      // Find user by display name
      final userQuery = await firestore
          .collection(AppConstants.usersCollection)
          .where('displayName', isEqualTo: displayName)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw ServerException('User not found with display name: $displayName');
      }

      final toUser = userQuery.docs.first.data();
      final toUserId = toUser['uid'] as String;

      if (toUserId == fromUserId) {
        throw ServerException('Cannot send friend request to yourself');
      }

      // Check if already friends
      final friendsDoc = await firestore
          .collection('friends')
          .doc(fromUserId)
          .collection('user_friends')
          .doc(toUserId)
          .get();

      if (friendsDoc.exists) {
        throw ServerException('Already friends with this user');
      }

      // Check if request already exists
      final existingRequest = await firestore
          .collection('friend_requests')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw ServerException('Friend request already sent');
      }

      // Create friend request
      final requestRef = firestore.collection('friend_requests').doc();
      final request = FriendRequestModel(
        id: requestRef.id,
        fromUserId: fromUserId,
        fromUserName: fromUserName,
        fromUserPhoto: fromUserPhoto,
        toUserId: toUserId,
        toUserName: toUser['displayName'] as String,
        status: FriendRequestStatus.pending,
        createdAt: DateTime.now(),
      );

      await requestRef.set(request.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<FriendRequestModel>> getFriendRequests(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('friend_requests')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => FriendRequestModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      final requestDoc =
          await firestore.collection('friend_requests').doc(requestId).get();

      if (!requestDoc.exists) {
        throw ServerException('Friend request not found');
      }

      final request = FriendRequestModel.fromJson(requestDoc.data()!);

      // Update request status
      await firestore.collection('friend_requests').doc(requestId).update({
        'status': FriendRequestStatus.accepted.toString().split('.').last,
      });

      // Add to friends collection for both users
      final batch = firestore.batch();

      // Add friend for fromUser
      batch.set(
        firestore
            .collection('friends')
            .doc(request.fromUserId)
            .collection('user_friends')
            .doc(request.toUserId),
        {
          'uid': request.toUserId,
          'displayName': request.toUserName,
          'addedAt': Timestamp.now(),
        },
      );

      // Add friend for toUser
      batch.set(
        firestore
            .collection('friends')
            .doc(request.toUserId)
            .collection('user_friends')
            .doc(request.fromUserId),
        {
          'uid': request.fromUserId,
          'displayName': request.fromUserName,
          'profilePicture': request.fromUserPhoto,
          'addedAt': Timestamp.now(),
        },
      );

      await batch.commit();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> declineFriendRequest(String requestId) async {
    try {
      await firestore.collection('friend_requests').doc(requestId).update({
        'status': FriendRequestStatus.declined.toString().split('.').last,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<FriendModel>> getFriends(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('friends')
          .doc(userId)
          .collection('user_friends')
          .get();

      return querySnapshot.docs
          .map((doc) => FriendModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeFriend({
    required String userId,
    required String friendId,
  }) async {
    try {
      final batch = firestore.batch();

      batch.delete(
        firestore
            .collection('friends')
            .doc(userId)
            .collection('user_friends')
            .doc(friendId),
      );

      batch.delete(
        firestore
            .collection('friends')
            .doc(friendId)
            .collection('user_friends')
            .doc(userId),
      );

      await batch.commit();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<FriendModel>> searchUsers(String displayName) async {
    try {
      final querySnapshot = await firestore
          .collection(AppConstants.usersCollection)
          .where('displayName', isEqualTo: displayName)
          .get();

      return querySnapshot.docs
          .map((doc) => FriendModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
