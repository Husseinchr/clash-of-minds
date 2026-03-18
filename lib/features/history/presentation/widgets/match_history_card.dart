import 'package:flutter/material.dart';
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/core/theme/app_theme.dart';
import 'package:clash_of_minds/features/history/domain/entities/match_history_entity.dart';
import 'package:intl/intl.dart';

/// Match history card widget
class MatchHistoryCard extends StatelessWidget {
  final MatchHistoryEntity matchHistory;
  final VoidCallback onTap;

  const MatchHistoryCard({
    super.key,
    required this.matchHistory,
    required this.onTap,
  });

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  String _getResultText() {
    if (matchHistory.winningTeam == 0) {
      return 'Draw';
    }
    final userWon = matchHistory.winningTeam == matchHistory.userTeamNumber;
    return userWon ? 'You Won!' : 'You Lost';
  }

  Color _getResultColor() {
    if (matchHistory.winningTeam == 0) {
      return Colors.grey;
    }
    final userWon = matchHistory.winningTeam == matchHistory.userTeamNumber;
    return userWon ? Colors.green : Colors.red;
  }

  IconData _getResultIcon() {
    if (matchHistory.winningTeam == 0) {
      return Icons.handshake;
    }
    final userWon = matchHistory.winningTeam == matchHistory.userTeamNumber;
    return userWon ? Icons.emoji_events : Icons.close;
  }

  @override
  Widget build(BuildContext context) {
    final isTeam1 = matchHistory.userTeamNumber == 1;
    final userTeamColor = isTeam1 ? AppTheme.team1Color : AppTheme.team2Color;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: userTeamColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Code and Time
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tag, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Match ${matchHistory.matchCode}',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _getRelativeTime(matchHistory.completedAt),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Score Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Team 1
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppTheme.team1Color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Team 1${isTeam1 ? ' (You)' : ''}',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight:
                                    isTeam1 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            '${matchHistory.team1Score}',
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: matchHistory.winningTeam == 1
                                  ? AppTheme.team1Color
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // VS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'VS',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Team 2
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Team 2${!isTeam1 ? ' (You)' : ''}',
                              style: context.textTheme.bodySmall?.copyWith(
                                fontWeight:
                                    !isTeam1 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppTheme.team2Color,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text(
                            '${matchHistory.team2Score}',
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: matchHistory.winningTeam == 2
                                  ? AppTheme.team2Color
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Result
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getResultColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getResultIcon(),
                      size: 16,
                      color: _getResultColor(),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getResultText(),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: _getResultColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
