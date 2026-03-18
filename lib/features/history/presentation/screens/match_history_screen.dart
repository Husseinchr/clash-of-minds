import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/core/di/injection_container.dart' as di;
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_state.dart';
import 'package:clash_of_minds/features/history/presentation/bloc/history_bloc.dart';
import 'package:clash_of_minds/features/history/presentation/bloc/history_event.dart';
import 'package:clash_of_minds/features/history/presentation/bloc/history_state.dart';
import 'package:clash_of_minds/features/history/presentation/widgets/match_history_card.dart';
import 'package:clash_of_minds/features/history/presentation/screens/match_history_detail_screen.dart';

/// Match history screen
class MatchHistoryScreen extends StatelessWidget {
  const MatchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = di.sl<HistoryBloc>();
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          bloc.add(LoadMatchHistoryEvent(userId: authState.user.uid));
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Match History'),
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

            if (state is HistoryEmpty) {
              return _buildEmptyState(context);
            }

            if (state is HistoryLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is Authenticated) {
                    context.read<HistoryBloc>().add(
                          RefreshHistoryEvent(authState.user.uid),
                        );
                  }
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.history.length,
                  itemBuilder: (context, index) {
                    final matchHistory = state.history[index];
                    return MatchHistoryCard(
                      matchHistory: matchHistory,
                      onTap: () {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is Authenticated) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchHistoryDetailScreen(
                                matchId: matchHistory.id,
                                userId: authState.user.uid,
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              );
            }

            return _buildEmptyState(context);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No match history yet',
            style: context.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completed matches will appear here',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
