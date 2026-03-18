import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/core/di/injection_container.dart' as di;
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/core/theme/app_theme.dart';
import 'package:clash_of_minds/features/history/presentation/bloc/history_bloc.dart';
import 'package:clash_of_minds/features/history/presentation/bloc/history_event.dart';
import 'package:clash_of_minds/features/history/presentation/bloc/history_state.dart';
import 'package:intl/intl.dart';

/// Match history detail screen
class MatchHistoryDetailScreen extends StatelessWidget {
  final String matchId;
  final String userId;

  const MatchHistoryDetailScreen({
    super.key,
    required this.matchId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<HistoryBloc>()
        ..add(LoadMatchHistoryDetailEvent(matchId: matchId, userId: userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Match Details'),
        ),
        body: BlocConsumer<HistoryBloc, HistoryState>(
          listener: (context, state) {
            if (state is HistoryError) {
              context.showSnackBar(state.message, isError: true);
            }
          },
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is HistoryDetailLoaded) {
              final match = state.matchHistory;
              final isTeam1 = match.userTeamNumber == 1;
              final userTeamColor =
                  isTeam1 ? AppTheme.team1Color : AppTheme.team2Color;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Match Header Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Match Code',
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      match.matchCode,
                                      style:
                                          context.textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: userTeamColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: userTeamColor),
                                  ),
                                  child: Text(
                                    match.wasLeader ? 'Leader' : 'Player',
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      color: userTeamColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              context,
                              Icons.calendar_today,
                              'Completed',
                              DateFormat('MMM d, y • h:mm a')
                                  .format(match.completedAt),
                            ),
                            if (match.startedAt != null) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                context,
                                Icons.timer,
                                'Duration',
                                _getDuration(match.startedAt!, match.completedAt),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Score Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Final Score',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildTeamScore(
                                  context,
                                  'Team 1',
                                  match.team1Score,
                                  AppTheme.team1Color,
                                  match.winningTeam == 1,
                                  isTeam1,
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'VS',
                                      style: context.textTheme.titleLarge?.copyWith(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (match.winningTeam == 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Draw',
                                          style: context.textTheme.bodySmall
                                              ?.copyWith(color: Colors.grey),
                                        ),
                                      ),
                                  ],
                                ),
                                _buildTeamScore(
                                  context,
                                  'Team 2',
                                  match.team2Score,
                                  AppTheme.team2Color,
                                  match.winningTeam == 2,
                                  !isTeam1,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Team Rosters
                    Text(
                      'Team Rosters',
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildTeamRoster(
                            context,
                            'Team 1',
                            match.team1PlayerIds,
                            match.playerNames,
                            AppTheme.team1Color,
                            match.leaderId,
                            userId,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTeamRoster(
                            context,
                            'Team 2',
                            match.team2PlayerIds,
                            match.playerNames,
                            AppTheme.team2Color,
                            match.leaderId,
                            userId,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text('Failed to load match details'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamScore(
    BuildContext context,
    String teamName,
    int score,
    Color color,
    bool isWinner,
    bool isUserTeam,
  ) {
    return Column(
      children: [
        Text(
          teamName,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: isUserTeam ? FontWeight.bold : FontWeight.normal,
            color: isUserTeam ? color : null,
          ),
        ),
        if (isUserTeam)
          Text(
            '(You)',
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isWinner ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: isWinner ? color : Colors.grey,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              '$score',
              style: context.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isWinner ? color : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (isWinner)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                'Winner',
                style: context.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTeamRoster(
    BuildContext context,
    String teamName,
    List<String> playerIds,
    Map<String, String> playerNames,
    Color teamColor,
    String leaderId,
    String currentUserId,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: teamColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                teamName,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: teamColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            ...playerIds.map((playerId) {
              final playerName = playerNames[playerId] ?? 'Unknown';
              final isLeader = playerId == leaderId;
              final isCurrentUser = playerId == currentUserId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: isCurrentUser ? teamColor : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        playerName,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isCurrentUser ? teamColor : null,
                        ),
                      ),
                    ),
                    if (isLeader)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Leader',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.amber[800],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}
