import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:clash_of_minds/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:clash_of_minds/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:clash_of_minds/features/auth/domain/repositories/auth_repository.dart';
import 'package:clash_of_minds/features/auth/domain/usecases/get_current_user.dart';
import 'package:clash_of_minds/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:clash_of_minds/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:clash_of_minds/features/auth/domain/usecases/sign_out.dart';
import 'package:clash_of_minds/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:clash_of_minds/features/auth/domain/usecases/update_display_name.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clash_of_minds/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:clash_of_minds/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:clash_of_minds/features/profile/domain/repositories/profile_repository.dart';
import 'package:clash_of_minds/features/profile/domain/usecases/update_profile_picture.dart';
import 'package:clash_of_minds/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:clash_of_minds/features/match/data/datasources/match_remote_data_source.dart';
import 'package:clash_of_minds/features/match/data/repositories/match_repository_impl.dart';
import 'package:clash_of_minds/features/match/domain/repositories/match_repository.dart';
import 'package:clash_of_minds/features/match/domain/usecases/create_match.dart';
import 'package:clash_of_minds/features/match/domain/usecases/get_match_invitations.dart';
import 'package:clash_of_minds/features/match/domain/usecases/join_match.dart';
import 'package:clash_of_minds/features/match/domain/usecases/join_match_with_team.dart';
import 'package:clash_of_minds/features/match/domain/usecases/respond_to_invitation.dart';
import 'package:clash_of_minds/features/match/domain/usecases/send_match_invitation.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_bloc.dart';
import 'package:clash_of_minds/features/friends/data/datasources/friends_remote_data_source.dart';
import 'package:clash_of_minds/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:clash_of_minds/features/friends/domain/repositories/friends_repository.dart';
import 'package:clash_of_minds/features/friends/domain/usecases/accept_friend_request.dart';
import 'package:clash_of_minds/features/friends/domain/usecases/get_friend_requests.dart';
import 'package:clash_of_minds/features/friends/domain/usecases/get_friends.dart';
import 'package:clash_of_minds/features/friends/domain/usecases/send_friend_request.dart';
import 'package:clash_of_minds/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:clash_of_minds/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:clash_of_minds/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:clash_of_minds/features/chat/domain/repositories/chat_repository.dart';
import 'package:clash_of_minds/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:clash_of_minds/features/history/data/datasources/history_remote_data_source.dart';
import 'package:clash_of_minds/features/history/data/repositories/history_repository_impl.dart';
import 'package:clash_of_minds/features/history/domain/repositories/history_repository.dart';
import 'package:clash_of_minds/features/history/domain/usecases/get_match_history.dart';
import 'package:clash_of_minds/features/history/domain/usecases/get_match_history_detail.dart';
import 'package:clash_of_minds/features/history/presentation/bloc/history_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      signInWithGoogle: sl(),
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      updateDisplayName: sl(),
    ),
  );
  sl.registerFactory(
    () => ProfileBloc(
      updateProfilePicture: sl(),
    ),
  );
  sl.registerFactory(
    () => MatchBloc(
      createMatch: sl(),
      joinMatch: sl(),
      repository: sl(),
      sendMatchInvitation: sl(),
      getMatchInvitations: sl(),
      respondToInvitation: sl(),
      joinMatchWithTeam: sl(),
    ),
  );
  sl.registerFactory(
    () => FriendsBloc(
      getFriends: sl(),
      getFriendRequests: sl(),
      sendFriendRequest: sl(),
      acceptFriendRequest: sl(),
    ),
  );
  sl.registerFactory(
    () => ChatBloc(
      repository: sl(),
    ),
  );
  sl.registerFactory(
    () => HistoryBloc(
      getMatchHistory: sl(),
      getMatchHistoryDetail: sl(),
    ),
  );

  // Use cases - Auth
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => UpdateDisplayName(sl()));

  // Use cases - Profile
  sl.registerLazySingleton(() => UpdateProfilePicture(sl()));

  // Use cases - Match
  sl.registerLazySingleton(() => CreateMatch(sl()));
  sl.registerLazySingleton(() => JoinMatch(sl()));
  sl.registerLazySingleton(() => SendMatchInvitation(sl()));
  sl.registerLazySingleton(() => GetMatchInvitations(sl()));
  sl.registerLazySingleton(() => RespondToInvitation(sl()));
  sl.registerLazySingleton(() => JoinMatchWithTeam(sl()));

  // Use cases - Friends
  sl.registerLazySingleton(() => GetFriends(sl()));
  sl.registerLazySingleton(() => GetFriendRequests(sl()));
  sl.registerLazySingleton(() => SendFriendRequest(sl()));
  sl.registerLazySingleton(() => AcceptFriendRequest(sl()));

  // Use cases - History
  sl.registerLazySingleton(() => GetMatchHistory(sl()));
  sl.registerLazySingleton(() => GetMatchHistoryDetail(sl()));

  // Repositories - Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Repositories - Profile
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Repositories - Match
  sl.registerLazySingleton<MatchRepository>(
    () => MatchRepositoryImpl(remoteDataSource: sl()),
  );

  // Repositories - Friends
  sl.registerLazySingleton<FriendsRepository>(
    () => FriendsRepositoryImpl(remoteDataSource: sl()),
  );

  // Repositories - Chat
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // Repositories - History
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources - Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  // Data sources - Profile
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  // Data sources - Match
  sl.registerLazySingleton<MatchRemoteDataSource>(
    () => MatchRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  // Data sources - Friends
  sl.registerLazySingleton<FriendsRemoteDataSource>(
    () => FriendsRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  // Data sources - Chat
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  // Data sources - History
  sl.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => GoogleSignIn());
}
