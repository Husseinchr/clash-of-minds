import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/core/di/injection_container.dart' as di;
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_state.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_bloc.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_event.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_state.dart';
import 'package:clash_of_minds/features/match/presentation/screens/match_lobby_screen.dart';

/// Create match screen
class CreateMatchScreen extends StatelessWidget {
  const CreateMatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MatchBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Match'),
        ),
        body: BlocConsumer<MatchBloc, MatchState>(
          listener: (context, state) {
            if (state is MatchCreated) {
              context.pushReplacement(
                MatchLobbyScreen(matchId: state.match.id),
              );
            } else if (state is MatchError) {
              context.showSnackBar(state.message, isError: true);
            }
          },
          builder: (context, matchState) {
            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is! Authenticated) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final user = authState.user;

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),

                        // Icon
                        Icon(
                          Icons.videogame_asset,
                          size: 100,
                          color: context.colorScheme.primary,
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Create New Match',
                          style: context.textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          'You will be the session leader.\nInvite up to 4 players to join your match using a 4-digit code.',
                          style: context.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),

                        // Info cards
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: context.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Session Leader',
                                            style: context.textTheme.titleMedium,
                                          ),
                                          Text(
                                            user.displayName,
                                            style: context.textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.groups,
                                  color: context.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Players',
                                        style: context.textTheme.titleMedium,
                                      ),
                                      Text(
                                        'Up to 4 players (2v2)',
                                        style: context.textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Create button
                        ElevatedButton(
                          onPressed: matchState is MatchLoading
                              ? null
                              : () {
                                  context.read<MatchBloc>().add(
                                        CreateMatchEvent(
                                          leaderId: user.uid,
                                          leaderName: user.displayName,
                                        ),
                                      );
                                },
                          child: matchState is MatchLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Create Match'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
