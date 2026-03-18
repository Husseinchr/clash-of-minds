import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/core/di/injection_container.dart' as di;
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/core/theme/app_theme.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_state.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_bloc.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_event.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_state.dart';
import 'package:clash_of_minds/features/match/presentation/screens/leader_match_screen.dart';
import 'package:clash_of_minds/features/match/presentation/screens/player_match_screen.dart';
import 'package:clash_of_minds/features/match/presentation/widgets/invite_friends_bottom_sheet.dart';

/// Match lobby screen
class MatchLobbyScreen extends StatefulWidget {
  final String matchId;

  const MatchLobbyScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<MatchLobbyScreen> createState() => _MatchLobbyScreenState();
}

class _MatchLobbyScreenState extends State<MatchLobbyScreen> {
  MatchEntity? _lastMatch;

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    context.showSnackBar('Code copied to clipboard');
  }

  bool _canStartMatch(MatchEntity match) {
    return match.team1PlayerIds.isNotEmpty && match.team2PlayerIds.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MatchBloc>()..add(WatchMatchEvent(widget.matchId)),
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            // User pressed back - remove them from the match
            final authState = context.read<AuthBloc>().state;
            if (authState is Authenticated && _lastMatch != null) {
              final isLeader = _lastMatch!.leaderId == authState.user.uid;
              // Don't remove leader from match
              if (!isLeader) {
                context.read<MatchBloc>().add(
                      LeaveMatchEvent(
                        matchId: widget.matchId,
                        playerId: authState.user.uid,
                        playerName: authState.user.displayName,
                      ),
                    );
              }
            }
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Match Lobby'),
          ),
          body: BlocConsumer<MatchBloc, MatchState>(
          listener: (context, state) {
            if (state is MatchError) {
              context.showSnackBar(state.message, isError: true);
            } else if (state is MatchUpdated) {
              if (state.match.status == MatchStatus.inProgress) {
                // Navigate to match screen
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  final isLeader = state.match.leaderId == authState.user.uid;
                  context.pushReplacement(
                    isLeader
                        ? LeaderMatchScreen(matchId: widget.matchId)
                        : PlayerMatchScreen(matchId: widget.matchId),
                  );
                }
              }
            }
          },
          builder: (context, state) {
            // Store the latest match data when available
            if (state is MatchUpdated) {
              _lastMatch = state.match;
            }

            // Show loading only if we don't have any match data yet
            if (_lastMatch == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Use the cached match data (continues to show UI even during InvitationSent, etc.)
            final match = _lastMatch!;

            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is! Authenticated) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final user = authState.user;
                final isLeader = match.leaderId == user.uid;
                final canStart = _canStartMatch(match);

                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Match code
                        Card(
                          color: context.colorScheme.primary,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Text(
                                  'Match Code',
                                  style: context.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      match.code,
                                      style: context.textTheme.displayLarge
                                          ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 8,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.copy,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => _copyCode(match.code),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Share this code with players',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Invite Friends button (only for leader)
                        if (isLeader)
                          OutlinedButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (bottomSheetContext) => InviteFriendsBottomSheet(
                                  userId: user.uid,
                                  userName: user.displayName,
                                  matchId: match.id,
                                  matchCode: match.code,
                                  matchBloc: context.read<MatchBloc>(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_add),
                            label: const Text('Invite Friends'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: context.colorScheme.primary,
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        if (isLeader) const SizedBox(height: 16),

                        // Teams
                        SizedBox(
                          height: 400,
                          child: Column(
                            children: [
                              // Team 1
                              Expanded(
                                child: _TeamCard(
                                  teamNumber: 1,
                                  playerIds: match.team1PlayerIds,
                                  color: AppTheme.team1Color,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // VS
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: context.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  'VS',
                                  style: context.textTheme.titleLarge
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Team 2
                              Expanded(
                                child: _TeamCard(
                                  teamNumber: 2,
                                  playerIds: match.team2PlayerIds,
                                  color: AppTheme.team2Color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Start button (only for leader)
                        if (isLeader) ...[
                          if (!canStart)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.warningColor,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: AppTheme.warningColor,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Need at least 1 player in each team to start',
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: AppTheme.warningColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: canStart
                                ? () {
                                    context
                                        .read<MatchBloc>()
                                        .add(StartMatchEvent(widget.matchId));
                                  }
                                : null,
                            child: const Text('Start Match'),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  context.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(width: 16),
                                Text(
                                  'Waiting for ${match.leaderName} to start...',
                                  style: context.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final int teamNumber;
  final List<String> playerIds;
  final Color color;

  const _TeamCard({
    required this.teamNumber,
    required this.playerIds,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Team $teamNumber',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: playerIds.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_add_outlined,
                            size: 24,
                            color: Colors.grey[400],
                          ),
                          Text(
                            'Waiting for players...',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 9,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: playerIds.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return _PlayerListItem(
                          playerId: playerIds[index],
                          index: index,
                          color: color,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerListItem extends StatelessWidget {
  final String playerId;
  final int index;
  final Color color;

  const _PlayerListItem({
    required this.playerId,
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(playerId)
          .get(),
      builder: (context, snapshot) {
        final displayName = snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.data() as Map<String, dynamic>)['displayName']
                as String?
            : null;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 18,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayName ?? 'Loading...',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        );
      },
    );
  }
}
