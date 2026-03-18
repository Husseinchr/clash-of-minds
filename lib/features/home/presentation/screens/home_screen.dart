import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/core/di/injection_container.dart';
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/core/widgets/custom_button.dart';
import 'package:clash_of_minds/core/theme/app_theme.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_event.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_state.dart';
import 'package:clash_of_minds/features/auth/presentation/screens/login_screen.dart';
import 'package:clash_of_minds/features/profile/presentation/screens/profile_screen.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_bloc.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_event.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_state.dart';
import 'package:clash_of_minds/features/match/presentation/screens/create_match_screen.dart';
import 'package:clash_of_minds/features/match/presentation/screens/join_match_screen.dart';
import 'package:clash_of_minds/features/match/presentation/screens/match_invitations_screen.dart';
import 'package:clash_of_minds/features/friends/presentation/screens/friends_screen.dart';
import 'package:clash_of_minds/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:clash_of_minds/features/history/presentation/screens/match_history_screen.dart';
import 'package:clash_of_minds/features/friends/presentation/bloc/friends_event.dart';
import 'package:clash_of_minds/features/friends/presentation/bloc/friends_state.dart';

/// Home screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MatchBloc _matchBloc;
  late final FriendsBloc _friendsBloc;
  String? _loadedUserId;
  String? _loadedFriendsUserId;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _matchBloc = sl<MatchBloc>();
    _friendsBloc = sl<FriendsBloc>();

    // Start periodic refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      // Check if widget is still mounted before accessing context
      if (!mounted) return;

      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        _matchBloc.add(LoadMatchInvitationsEvent(authState.user.uid));
        _friendsBloc.add(LoadFriendsEvent(authState.user.uid));
      }
    });
  }

  void _loadInvitationsIfNeeded(String userId) {
    if (_loadedUserId != userId) {
      _loadedUserId = userId;
      _matchBloc.add(LoadMatchInvitationsEvent(userId));
    }
  }

  void _loadFriendRequestsIfNeeded(String userId) {
    if (_loadedFriendsUserId != userId) {
      _loadedFriendsUserId = userId;
      _friendsBloc.add(LoadFriendsEvent(userId));
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _matchBloc.close();
    _friendsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _matchBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clash Of Minds'),
          actions: [
            // Invitations icon with badge
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is Authenticated) {
                  // Load invitations only once per user
                  _loadInvitationsIfNeeded(authState.user.uid);

                  return BlocBuilder<MatchBloc, MatchState>(
                    builder: (context, matchState) {
                      int invitationCount = 0;
                      if (matchState is InvitationsLoaded) {
                        invitationCount = matchState.invitations.length;
                      }

                      return Badge(
                        label: Text('$invitationCount'),
                        isLabelVisible: invitationCount > 0,
                        child: IconButton(
                          icon: const Icon(Icons.mail_outline),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: _matchBloc,
                                  child: MatchInvitationsScreen(
                                    userId: authState.user.uid,
                                  ),
                                ),
                              ),
                            );
                          },
                          tooltip: 'Match Invitations',
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            // Friends icon with badge
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is Authenticated) {
                  // Load friend requests only once per user
                  _loadFriendRequestsIfNeeded(authState.user.uid);

                  return BlocBuilder<FriendsBloc, FriendsState>(
                    bloc: _friendsBloc,
                    builder: (context, friendsState) {
                      int friendRequestCount = 0;
                      if (friendsState is FriendsAndRequestsLoaded) {
                        friendRequestCount = friendsState.requests.length;
                      }

                      return Badge(
                        label: Text('$friendRequestCount'),
                        isLabelVisible: friendRequestCount > 0,
                        child: IconButton(
                          icon: const Icon(Icons.people),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider.value(
                                  value: _friendsBloc,
                                  child: const FriendsScreen(),
                                ),
                              ),
                            );
                          },
                          tooltip: 'Friends',
                        ),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const MatchHistoryScreen(),
                  ),
                );
              },
              tooltip: 'Match History',
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                context.push(const ProfileScreen());
              },
              tooltip: 'Profile',
            ),
          ],
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.pushReplacement(const LoginScreen());
          } else if (state is AuthError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is! Authenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo section
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.team1Color.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: AppTheme.team2Color.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/icons/app-logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppTheme.team1Color,
                        AppTheme.accentGold,
                        AppTheme.team2Color,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'Clash Of Minds',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Welcome message
                  Text(
                    'Welcome, ${user.displayName}!',
                    style: context.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready to start a quiz tournament?',
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Create match button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.team1Color.withValues(alpha: 0.2),
                          AppTheme.accentGold.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.team1Color.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.team1Color.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_circle_outline,
                                size: 48,
                                color: AppTheme.team1Color,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Create Match',
                              style: context.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Host a new quiz tournament and invite players',
                              style: context.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'Create',
                              onPressed: () {
                                context.push(const CreateMatchScreen());
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Join match button
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.team2Color.withValues(alpha: 0.2),
                          AppTheme.accentGold.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.team2Color.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.team2Color.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.login,
                                size: 48,
                                color: AppTheme.team2Color,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Join Match',
                              style: context.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter a 4-digit code to join an existing match',
                              style: context.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            CustomButton(
                              text: 'Join',
                              onPressed: () {
                                context.push(const JoinMatchScreen());
                              },
                              isOutlined: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign out button
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(SignOutEvent());
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}
