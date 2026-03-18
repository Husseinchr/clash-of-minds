/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String matchesCollection = 'matches';
  static const String matchInvitationsCollection = 'match_invitations';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String historyCollection = 'history';

  // Storage Paths
  static const String profilePicturesPath = 'profile_pictures';

  // Match Settings
  static const int maxPlayersPerMatch = 6;
  static const int maxPlayersPerTeam = 3;
  static const int matchCodeLength = 4;

  // Default Values
  static const String defaultProfilePicture =
      'https://via.placeholder.com/150';

  // Error Messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'No internet connection. Please check your connection.';
  static const String authErrorMessage =
      'Authentication failed. Please try again.';
}
