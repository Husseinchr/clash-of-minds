import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/core/di/injection_container.dart' as di;
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/core/theme/app_theme.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_bloc.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_event.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_state.dart';

/// Leader match screen
class LeaderMatchScreen extends StatefulWidget {
  final String matchId;

  const LeaderMatchScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<LeaderMatchScreen> createState() => _LeaderMatchScreenState();
}

class _LeaderMatchScreenState extends State<LeaderMatchScreen> {
  final _questionController = TextEditingController();
  final _hintController = TextEditingController();
  MatchEntity? _lastMatch;
  bool _teamEmptyDialogShown = false;
  Timer? _teamTurnTimer;
  DateTime? _lastTeamTurnStartTime;

  @override
  void dispose() {
    _questionController.dispose();
    _hintController.dispose();
    _teamTurnTimer?.cancel();
    super.dispose();
  }

  void _sendQuestion(BuildContext context) {
    if (_questionController.text.trim().isEmpty) {
      context.showSnackBar('Please enter a question', isError: true);
      return;
    }

    context.read<MatchBloc>().add(
          SendQuestionEvent(
            matchId: widget.matchId,
            question: _questionController.text.trim(),
          ),
        );
    _questionController.clear();
  }

  void _sendHint(BuildContext context) {
    if (_hintController.text.trim().isEmpty) {
      context.showSnackBar('Please enter a hint', isError: true);
      return;
    }

    context.read<MatchBloc>().add(
          SendHintEvent(
            matchId: widget.matchId,
            hint: _hintController.text.trim(),
          ),
        );
    _hintController.clear();
  }

  int _getPlayerTeam(MatchEntity match, String playerId) {
    if (match.team1PlayerIds.contains(playerId)) return 1;
    if (match.team2PlayerIds.contains(playerId)) return 2;
    return 0;
  }

  void _startTeamTurnTimer(BuildContext context, DateTime startTime, String matchId) {
    debugPrint('🔵 [LEADER] _startTeamTurnTimer called');
    _teamTurnTimer?.cancel();

    const teamTurnTimeout = 15; // 15 seconds for team to claim
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    int remaining = teamTurnTimeout - elapsed;

    debugPrint('🔵 [LEADER] Elapsed: ${elapsed}s, Remaining: ${remaining}s');

    // Handle clock skew
    if (remaining < 0) {
      remaining = 0;
    } else if (remaining > teamTurnTimeout) {
      remaining = teamTurnTimeout;
    }

    if (remaining <= 0) {
      debugPrint('🔵 [LEADER] Timer already expired - switching immediately');
      // Timer already expired - switch teams immediately
      final matchBloc = context.read<MatchBloc>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          debugPrint('🔵 [LEADER] Triggering immediate switch');
          matchBloc.add(SwitchTeamTurnEvent(matchId));
        }
      });
      return;
    }

    debugPrint('🔵 [LEADER] Starting timer for ${remaining}s');
    // Start timer to auto-switch teams when time expires
    final matchBloc = context.read<MatchBloc>();
    _teamTurnTimer = Timer(Duration(seconds: remaining), () {
      debugPrint('🔵 [LEADER] Timer expired! Mounted: $mounted');
      if (mounted) {
        debugPrint('🔵 [LEADER] Triggering team switch');
        matchBloc.add(SwitchTeamTurnEvent(matchId));
      } else {
        debugPrint('🔵 [LEADER] NOT mounted - cannot switch');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MatchBloc>()..add(WatchMatchEvent(widget.matchId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Leader View'),
          actions: [
            Builder(
              builder: (builderContext) => IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () {
                  // Capture the MatchBloc before showing dialog
                  final matchBloc = builderContext.read<MatchBloc>();

                  showDialog(
                    context: builderContext,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('End Match'),
                      content:
                          const Text('Are you sure you want to end this match?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            matchBloc.add(EndMatchEvent(widget.matchId));
                          },
                          child: const Text('End Match'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        body: BlocConsumer<MatchBloc, MatchState>(
          listener: (context, state) {
            if (state is MatchError) {
              context.showSnackBar(state.message, isError: true);
            } else if (state is QuestionSent) {
              context.showSnackBar('Question sent to players');
            } else if (state is HintSent) {
              context.showSnackBar('Hint sent to players');
            } else if (state is MatchEnded) {
              if (!mounted) return;
              context.showSnackBar('Match ended');
              Navigator.pop(context);
            } else if (state is TeamEmptyMatchEnded) {
              // Check if dialog was already shown
              if (_teamEmptyDialogShown) return;

              _teamEmptyDialogShown = true;

              // Show non-dismissible dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Match Ended'),
                  content: Text(
                    'All Team ${state.emptyTeamNumber} players have left the match',
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Return to Home Screen'),
                    ),
                  ],
                ),
              );
            }
          },
          builder: (context, state) {
            // Cache the match data when available
            if (state is MatchUpdated) {
              _lastMatch = state.match;
            }

            // Only show loading if we don't have any match data yet
            if (_lastMatch == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Use cached match data - continues to show UI even during QuestionSent, HintSent, etc.
            final match = _lastMatch!;

            // Auto-switch team turn when timer expires (LEADER ONLY)
            if (match.currentTeamTurn != null && match.teamTurnStartTime != null && match.currentAnswerer == null) {
              // Team turn is active and no one has claimed yet
              debugPrint('🟢 [LEADER BUILD] Team turn active: Team ${match.currentTeamTurn}');
              if (_lastTeamTurnStartTime != match.teamTurnStartTime) {
                debugPrint('🟢 [LEADER BUILD] New team turn detected - scheduling timer start');
                _lastTeamTurnStartTime = match.teamTurnStartTime;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    debugPrint('🟢 [LEADER BUILD] Post-frame callback executing');
                    _startTeamTurnTimer(context, match.teamTurnStartTime!, widget.matchId);
                  }
                });
              } else {
                debugPrint('🟢 [LEADER BUILD] Same team turn - timer already running');
              }
            } else {
              debugPrint('🔴 [LEADER BUILD] Cancelling timer - currentTeamTurn: ${match.currentTeamTurn}, teamTurnStartTime: ${match.teamTurnStartTime}, currentAnswerer: ${match.currentAnswerer}');
              // No team turn or someone has claimed - cancel timer
              _teamTurnTimer?.cancel();
              _teamTurnTimer = null;
              _lastTeamTurnStartTime = null;
            }

            return SafeArea(
              child: Column(
                children: [
                  // System messages
                  if (match.systemMessages.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.warningColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.warningColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              match.systemMessages.last,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: AppTheme.warningColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // Score board
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: context.colorScheme.surface,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ScoreCard(
                          teamName: 'Team 1',
                          score: match.team1Score,
                          color: AppTheme.team1Color,
                        ),
                        Text(
                          'VS',
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _ScoreCard(
                          teamName: 'Team 2',
                          score: match.team2Score,
                          color: AppTheme.team2Color,
                        ),
                      ],
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Question input
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Send Question',
                                    style: context.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: _questionController,
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your question here...',
                                    ),
                                    maxLines: 3,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: () => _sendQuestion(context),
                                    icon: const Icon(Icons.send),
                                    label: const Text('Send Question'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Current question display
                          if (match.currentQuestion != null) ...[
                            Card(
                              color: AppTheme.successColor.withValues(alpha: 0.1),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.question_answer,
                                          color: AppTheme.successColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Current Question',
                                          style: context.textTheme.titleMedium
                                              ?.copyWith(
                                            color: AppTheme.successColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      match.currentQuestion!,
                                      style: context.textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Hint input
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Send Hint',
                                      style: context.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _hintController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter a hint...',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton.icon(
                                      onPressed: () => _sendHint(context),
                                      icon: const Icon(Icons.lightbulb),
                                      label: const Text('Send Hint'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Team turn indicator (when no one is answering yet)
                            if (match.currentTeamTurn != null && match.currentAnswerer == null) ...[
                              Card(
                                color: (match.currentTeamTurn == 1 ? AppTheme.team1Color : AppTheme.team2Color)
                                    .withValues(alpha: 0.1),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.groups,
                                        color: match.currentTeamTurn == 1
                                            ? AppTheme.team1Color
                                            : AppTheme.team2Color,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Team ${match.currentTeamTurn}\'s turn to answer',
                                          style: context.textTheme.titleMedium?.copyWith(
                                            color: match.currentTeamTurn == 1
                                                ? AppTheme.team1Color
                                                : AppTheme.team2Color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.timer,
                                        size: 20,
                                        color: AppTheme.warningColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '15s to claim',
                                        style: context.textTheme.bodySmall?.copyWith(
                                          color: AppTheme.warningColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Current answerer
                            if (match.currentAnswerer != null) ...[
                              Card(
                                color: AppTheme.warningColor.withValues(alpha: 0.1),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.person_pin,
                                            color: AppTheme.warningColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              match.currentAnswer != null && match.currentAnswer!.isNotEmpty
                                                  ? '${match.currentAnswererName ?? "Player"} Answer:'
                                                  : '${match.currentAnswererName ?? "Player"} is typing...',
                                              style: context
                                                  .textTheme.titleMedium
                                                  ?.copyWith(
                                                color: AppTheme.warningColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (match.currentAnswer != null && match.currentAnswer!.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: AppTheme.warningColor,
                                              width: 2,
                                            ),
                                          ),
                                          child: Text(
                                            match.currentAnswer!,
                                            style: context.textTheme.bodyLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                      // Only show Correct/Wrong buttons if answer is submitted
                                      if (match.currentAnswer != null && match.currentAnswer!.isNotEmpty) ...[
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  final teamNumber =
                                                      _getPlayerTeam(
                                                    match,
                                                    match.currentAnswerer!,
                                                  );
                                                  context.read<MatchBloc>().add(
                                                        MarkAnswerCorrectEvent(
                                                          matchId: widget.matchId,
                                                          playerId: match
                                                              .currentAnswerer!,
                                                          teamNumber: teamNumber,
                                                        ),
                                                      );
                                                },
                                                icon: const Icon(Icons.check),
                                                label: const Text('Correct'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppTheme.successColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  context.read<MatchBloc>().add(
                                                        MarkAnswerWrongEvent(
                                                          widget.matchId,
                                                        ),
                                                      );
                                                },
                                                icon: const Icon(Icons.close),
                                                label: const Text('Wrong'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppTheme.errorColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Dismiss point button
                            OutlinedButton.icon(
                              onPressed: () {
                                context.read<MatchBloc>().add(
                                      DismissPointEvent(widget.matchId),
                                    );
                              },
                              icon: const Icon(Icons.skip_next),
                              label: const Text('Point Dismissed'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String teamName;
  final int score;
  final Color color;

  const _ScoreCard({
    required this.teamName,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          teamName,
          style: context.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$score',
            style: context.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
