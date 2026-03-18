import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:clash_of_minds/core/constants/app_constants.dart';
import 'package:clash_of_minds/core/error/exceptions.dart';
import 'package:clash_of_minds/features/auth/data/models/user_model.dart';

/// Profile remote data source interface
abstract class ProfileRemoteDataSource {
  Future<String> uploadProfilePicture({
    required String uid,
    required File image,
  });

  Future<UserModel> getUserProfile(String uid);

  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? profilePicture,
  });
}

/// Profile remote data source implementation
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;

  ProfileRemoteDataSourceImpl({
    required this.firestore,
  });

  @override
  Future<String> uploadProfilePicture({
    required String uid,
    required File image,
  }) async {
    try {
      // Read and decode image
      final bytes = await image.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw ServerException('Failed to decode image');
      }

      // Resize to max 400x400 to keep size small
      final resized = img.copyResize(
        decodedImage,
        width: decodedImage.width > 400 ? 400 : null,
        height: decodedImage.height > 400 ? 400 : null,
      );

      // Compress as JPEG with quality 85
      final compressed = img.encodeJpg(resized, quality: 85);

      // Convert to base64
      final base64Image = base64Encode(compressed);
      final imageUrl = 'data:image/jpeg;base64,$base64Image';

      // Update Firestore with base64 image
      await updateUserProfile(uid: uid, profilePicture: imageUrl);

      return imageUrl;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final doc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        throw ServerException('User not found');
      }

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateUserProfile({
    required String uid,
    String? displayName,
    String? profilePicture,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (displayName != null) {
        updates['displayName'] = displayName;
      }
      if (profilePicture != null) {
        updates['profilePicture'] = profilePicture;
      }

      if (updates.isNotEmpty) {
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .update(updates);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
