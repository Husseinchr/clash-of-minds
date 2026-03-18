import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/core/di/injection_container.dart' as di;
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/core/theme/app_theme.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_state.dart';
import 'package:clash_of_minds/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:clash_of_minds/features/chat/presentation/bloc/chat_event.dart';
import 'package:clash_of_minds/features/chat/presentation/widgets/team_chat_widget.dart';
import 'package:clash_of_minds/features/match/domain/entities/match_entity.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_bloc.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_event.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_state.dart';

const int answerTimeoutSeconds = 15;

/// Player match screen
class PlayerMatchScreen extends StatefulWidget {
  final String matchId;

  const PlayerMatchScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<PlayerMatchScreen> createState() => _PlayerMatchScreenState();
}

class _PlayerMatchScreenState extends State<PlayerMatchScreen> {
  final _answerController = TextEditingController();
  bool _isAnswering = false;
  MatchEntity? _lastMatch;
  bool _teamEmptyDialogShown = false;
  Timer? _answerTimer;
  int _remainingSeconds = 0;
  DateTime? _lastAnswerStartTime;
  Timer? _teamTurnTimer;
  int _teamTurnRemainingSeconds = 0;
  DateTime? _lastTeamTurnStartTime;

  @override
  void dispose() {
    _answerController.dispose();
    _answerTimer?.cancel();
    _teamTurnTimer?.cancel();
    super.dispose();
  }

  void _startTimer(BuildContext context, DateTime startTime, String myUserId, String? currentAnswerer) {
    _answerTimer?.cancel();

    // Calculate initial remaining time from server timestamp (one-time calculation)
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    int remaining;

    // Handle device clock skew for initial calculation only
    if (elapsed < 0) {
      // Device clock is behind server time - start from full duration
      remaining = answerTimeoutSeconds;
    } else if (elapsed >= answerTimeoutSeconds) {
      // Timer already expired
      remaining = 0;
    } else {
      // Normal case - calculate remaining time
      remaining = answerTimeoutSeconds - elapsed;
    }

    _remainingSeconds = remaining;

    if (_remainingSeconds <= 0) {
      // Timer already expired
      _remainingSeconds = 0;
      if (currentAnswerer == myUserId && _isAnswering) {
        _handleTimeout(context);
      }
      return;
    }

    // Simple countdown timer - just decrement every second
    // This eliminates clock skew issues after initial sync
    _answerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
        // Safety check to prevent negative values
        if (_remainingSeconds < 0) _remainingSeconds = 0;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        // If I'm the one answering and timer expired, auto-cancel
        if (currentAnswerer == myUserId && _isAnswering) {
          _handleTimeout(context);
        }
      }
    });
  }

  void _handleTimeout(BuildContext context) {
    context.showSnackBar('Time expired! Answer cancelled.', isError: true);
    _cancelAnswering(context);
  }

  void _startTeamTurnTimer(DateTime startTime) {
    _teamTurnTimer?.cancel();

    // Calculate initial remaining time from server timestamp
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    int remaining;

    // Handle device clock skew
    if (elapsed < 0) {
      remaining = 15; // Team turn timeout is 15 seconds
    } else if (elapsed >= 15) {
      remaining = 0;
    } else {
      remaining = 15 - elapsed;
    }

    _teamTurnRemainingSeconds = remaining;

    if (_teamTurnRemainingSeconds <= 0) {
      _teamTurnRemainingSeconds = 0;
      return;
    }

    // Simple countdown timer - DISPLAY ONLY, no switching
    // Only the leader triggers automatic switches to prevent coordination issues
    _teamTurnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _teamTurnRemainingSeconds--;
        if (_teamTurnRemainingSeconds < 0) _teamTurnRemainingSeconds = 0;
      });

      if (_teamTurnRemainingSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  int _getMyTeamNumber(MatchEntity match, String myId) {
    if (match.team1PlayerIds.contains(myId)) return 1;
    if (match.team2PlayerIds.contains(myId)) return 2;
    return 0;
  }

  bool _canAnswer(MatchEntity match, String myId, int myTeam) {
    // Basic conditions: question exists, no one is answering, I'm not already answering
    final basicConditions = match.currentQuestion != null &&
        match.currentAnswerer == null &&
        !_isAnswering;

    if (!basicConditions) return false;

    // Team turn check: if currentTeamTurn is set, only that team can answer
    if (match.currentTeamTurn != null) {
      return match.currentTeamTurn == myTeam;
    }

    // If no team turn is set, anyone can answer
    return true;
  }

  void _startAnswering(BuildContext context, String userId, String userName) {
    // Immediately claim the answering slot to disable other players' buttons
    context.read<MatchBloc>().add(
          SetAnswererEvent(
            matchId: widget.matchId,
            playerId: userId,
            playerName: userName,
            answer: '', // Empty answer to indicate typing
          ),
        );

    setState(() {
      _isAnswering = true;
    });
  }

  void _submitAnswer(BuildContext context, String userId, String userName) {
    if (_answerController.text.trim().isEmpty) {
      context.showSnackBar('Please enter an answer', isError: true);
      return;
    }

    // Submit the actual answer
    context.read<MatchBloc>().add(
          SetAnswererEvent(
            matchId: widget.matchId,
            playerId: userId,
            playerName: userName,
            answer: _answerController.text.trim(),
          ),
        );

    setState(() {
      _isAnswering = false;
    });
    _answerController.clear();
  }

  void _cancelAnswering(BuildContext context) {
    // Clear the answerer slot to allow others to answer
    context.read<MatchBloc>().add(
          MarkAnswerWrongEvent(widget.matchId),
        );

    setState(() {
      _isAnswering = false;
    });
    _answerController.clear();
  }

  void _showTeamChat(BuildContext context, int teamNumber, String userId, String userName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
        ),
        child: BlocProvider(
          create: (_) => di.sl<ChatBloc>()
            ..add(WatchTeamMessagesEvent(
              matchId: widget.matchId,
              teamNumber: teamNumber,
            )),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TeamChatWidget(
                    matchId: widget.matchId,
                    teamNumber: teamNumber,
                    currentUserId: userId,
                    currentUserName: userName,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MatchBloc>()..add(WatchMatchEvent(widget.matchId)),
      child: Builder(
        builder: (builderContext) => PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              // User pressed back - remove them from the match
              final authState = builderContext.read<AuthBloc>().state;
              if (authState is Authenticated && _lastMatch != null) {
                builderContext.read<MatchBloc>().add(
                      LeaveMatchEvent(
                        matchId: widget.matchId,
                        playerId: authState.user.uid,
                        playerName: authState.user.displayName,
                      ),
                    );
              }
            }
          },
          child: Scaffold(
          appBar: AppBar(
            title: const Text('Match'),
          ),
          body: BlocConsumer<MatchBloc, MatchState>(
            listener: (context, state) {
              if (state is MatchError) {
                context.showSnackBar(state.message, isError: true);
              } else if (state is MatchEnded) {
                if (!mounted) return;
                context.showSnackBar('Match ended');
                Navigator.pop(context);
              } else if (state is TeamEmptyMatchEnded) {
                // Check if dialog was already shown
                if (_teamEmptyDialogShown) return;

                // Check if current user is the one who left (not in match)
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  final userId = authState.user.uid;
                  final isInMatch =
                      state.match.team1PlayerIds.contains(userId) ||
                          state.match.team2PlayerIds.contains(userId);

                  // If user is not in match, they're the one who left - don't show dialog
                  if (!isInMatch) {
                    return;
                  }
                }

                _teamEmptyDialogShown = true;

                // Show non-dismissible dialog for other players
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
          builder: (context, matchState) {
            // Cache the match data when available
            if (matchState is MatchUpdated) {
              _lastMatch = matchState.match;
            }

            // Only show loading if we don't have any match data yet
            if (_lastMatch == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Use cached match data - continues to show UI even during AnswerMarked, etc.
            final match = _lastMatch!;

            return BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is! Authenticated) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final user = authState.user;
                final myTeam = _getMyTeamNumber(match, user.uid);
                final canAnswer = _canAnswer(match, user.uid, myTeam);
                final isMyTurn = match.currentAnswerer == user.uid;
                final teamColor = myTeam == 1 ? AppTheme.team1Color : AppTheme.team2Color;

                // Start/stop timer based on answerer state
                if (match.currentAnswerer != null && match.answerStartTime != null) {
                  // Someone is answering - restart timer only if start time changed
                  if (_lastAnswerStartTime != match.answerStartTime) {
                    _lastAnswerStartTime = match.answerStartTime;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _startTimer(context, match.answerStartTime!, user.uid, match.currentAnswerer);
                      }
                    });
                  }
                } else {
                  // No one is answering - cancel timer and reset
                  _answerTimer?.cancel();
                  _answerTimer = null;
                  _remainingSeconds = 0;
                  _lastAnswerStartTime = null;
                }

                // Start/stop team turn timer (display only - leader handles switching)
                if (match.currentTeamTurn != null && match.teamTurnStartTime != null && match.currentAnswerer == null) {
                  // Team turn is active and no one has claimed yet
                  if (_lastTeamTurnStartTime != match.teamTurnStartTime) {
                    _lastTeamTurnStartTime = match.teamTurnStartTime;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _startTeamTurnTimer(match.teamTurnStartTime!);
                      }
                    });
                  }
                } else {
                  // No team turn or someone has claimed - cancel timer and reset
                  _teamTurnTimer?.cancel();
                  _teamTurnTimer = null;
                  _teamTurnRemainingSeconds = 0;
                  _lastTeamTurnStartTime = null;
                }

                return Stack(
                  children: [
                    SafeArea(
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
                              isMyTeam: myTeam == 1,
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
                              isMyTeam: myTeam == 2,
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
                              // Current question
                              if (match.currentQuestion != null) ...[
                                Card(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.question_answer,
                                              color: AppTheme.primaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Question',
                                              style: context
                                                  .textTheme.titleMedium
                                                  ?.copyWith(
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          match.currentQuestion!,
                                          style: context.textTheme.bodyLarge
                                              ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Hint
                                if (match.currentHint != null) ...[
                                  Card(
                                    color: AppTheme.warningColor.withValues(alpha: 0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.lightbulb,
                                            color: AppTheme.warningColor,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Hint',
                                                  style: context
                                                      .textTheme.titleSmall
                                                      ?.copyWith(
                                                    color:
                                                        AppTheme.warningColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  match.currentHint!,
                                                  style: context
                                                      .textTheme.bodyMedium,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Answer button or answering UI
                                // Priority 1: If I'm answering and typing, show text field
                                if (isMyTurn && _isAnswering) ...[
                                  Card(
                                    color: AppTheme.successColor.withValues(alpha: 0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.edit,
                                                color: AppTheme.successColor,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Type Your Answer',
                                                  style: context
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    color: AppTheme.successColor,
                                                  ),
                                                ),
                                              ),
                                              // Countdown timer
                                              if (_remainingSeconds > 0) ...[
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _remainingSeconds <= 5
                                                        ? AppTheme.errorColor
                                                        : AppTheme.successColor,
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.timer,
                                                        color: Colors.white,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${_remainingSeconds}s',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: _answerController,
                                            decoration: const InputDecoration(
                                              hintText: 'Type your answer...',
                                            ),
                                            maxLines: 2,
                                            autofocus: true,
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton.icon(
                                                  onPressed: () =>
                                                      _submitAnswer(context, user.uid, user.displayName),
                                                  icon: const Icon(Icons.send),
                                                  label: const Text('Submit Answer'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppTheme.successColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              OutlinedButton(
                                                onPressed: () => _cancelAnswering(context),
                                                child: const Text('Cancel'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]
                                // Priority 2: If I'm the answerer but submitted, show waiting
                                else if (isMyTurn) ...[
                                  Card(
                                    color: AppTheme.successColor.withValues(alpha: 0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.edit,
                                                color: AppTheme.successColor,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Your Turn to Answer',
                                                style: context
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  color: AppTheme.successColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Waiting for leader to evaluate your answer...',
                                            style: context.textTheme.bodySmall
                                                ?.copyWith(
                                              color: AppTheme.successColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]
                                // Priority 3: If someone else is answering, show disabled state
                                else if (match.currentAnswerer != null) ...[
                                  Card(
                                    color: AppTheme.warningColor.withValues(alpha: 0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.timer,
                                            color: AppTheme.warningColor,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              '${match.currentAnswererName ?? "Another player"} is answering...',
                                              style: context
                                                  .textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: AppTheme.warningColor,
                                              ),
                                            ),
                                          ),
                                          // Countdown timer for other players
                                          if (_remainingSeconds > 0) ...[
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _remainingSeconds <= 5
                                                    ? AppTheme.errorColor
                                                    : AppTheme.warningColor,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                '${_remainingSeconds}s',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ]
                                // Priority 4: No one is answering - check team turn
                                else if (match.currentTeamTurn != null && match.currentTeamTurn != myTeam) ...[
                                  // Not my team's turn - show waiting message
                                  Card(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.info_outline,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Waiting for Team ${match.currentTeamTurn} to answer...',
                                              style: context
                                                  .textTheme.bodyMedium
                                                  ?.copyWith(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          // Show timer for other team's turn
                                          if (_teamTurnRemainingSeconds > 0) ...[
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                '${_teamTurnRemainingSeconds}s',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ]
                                // Priority 5: My team's turn - show button with timer
                                else if (match.currentTeamTurn == myTeam) ...[
                                  Card(
                                    color: teamColor.withValues(alpha: 0.1),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.emoji_events,
                                                color: teamColor,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Your team\'s turn!',
                                                  style: context
                                                      .textTheme.titleMedium
                                                      ?.copyWith(
                                                    color: teamColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (_teamTurnRemainingSeconds > 0) ...[
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _teamTurnRemainingSeconds <= 5
                                                        ? AppTheme.errorColor
                                                        : teamColor,
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Text(
                                                    '${_teamTurnRemainingSeconds}s',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton.icon(
                                            onPressed: canAnswer
                                                ? () => _startAnswering(context, user.uid, user.displayName)
                                                : null,
                                            icon: const Icon(Icons.pan_tool),
                                            label: const Text('Answer Question'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: teamColor,
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]
                                // Priority 6: No team turn restriction - show regular button
                                else ...[
                                  ElevatedButton.icon(
                                    onPressed: canAnswer
                                        ? () => _startAnswering(context, user.uid, user.displayName)
                                        : null,
                                    icon: const Icon(Icons.pan_tool),
                                    label: const Text('Answer Question'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ] else ...[
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.hourglass_empty,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Waiting for leader to send a question...',
                                          style: context.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                    // Floating chat button
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        backgroundColor: teamColor,
                        onPressed: myTeam > 0
                            ? () => _showTeamChat(
                                  context,
                                  myTeam,
                                  user.uid,
                                  user.displayName,
                                )
                            : null,
                        child: const Icon(Icons.chat, color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String teamName;
  final int score;
  final Color color;
  final bool isMyTeam;

  const _ScoreCard({
    required this.teamName,
    required this.score,
    required this.color,
    required this.isMyTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              teamName,
              style: context.textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isMyTeam) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.star,
                size: 16,
                color: Colors.amber,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: isMyTeam
                ? Border.all(color: Colors.amber, width: 2)
                : null,
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
