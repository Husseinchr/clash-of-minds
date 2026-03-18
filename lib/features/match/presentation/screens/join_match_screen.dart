import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/core/di/injection_container.dart' as di;
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/core/theme/app_theme.dart';
import 'package:clash_of_minds/core/widgets/custom_button.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_state.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_bloc.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_event.dart';
import 'package:clash_of_minds/features/match/presentation/bloc/match_state.dart';
import 'package:clash_of_minds/features/match/presentation/screens/match_lobby_screen.dart';

/// Join match screen
class JoinMatchScreen extends StatefulWidget {
  const JoinMatchScreen({super.key});

  @override
  State<JoinMatchScreen> createState() => _JoinMatchScreenState();
}

class _JoinMatchScreenState extends State<JoinMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  int? selectedTeam; // null = auto-assign, 1 or 2 = specific team

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _joinMatch(
    BuildContext context,
    String uid,
    String displayName,
    String? profilePicture,
  ) {
    if (_formKey.currentState!.validate()) {
      context.read<MatchBloc>().add(
            JoinMatchWithTeamEvent(
              code: _codeController.text.trim(),
              playerId: uid,
              playerName: displayName,
              profilePicture: profilePicture,
              teamNumber: selectedTeam,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MatchBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Join Match'),
        ),
        body: BlocConsumer<MatchBloc, MatchState>(
          listener: (context, state) {
            if (state is MatchJoined) {
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),

                          // Icon
                          Icon(
                            Icons.login,
                            size: 100,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(height: 32),

                          // Title
                          Text(
                            'Join Match',
                            style: context.textTheme.displaySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            'Enter the 4-digit code shared by the session leader',
                            style: context.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // Code input
                          TextFormField(
                            controller: _codeController,
                            decoration: const InputDecoration(
                              labelText: 'Match Code',
                              hintText: 'Enter 4-digit code',
                              prefixIcon: Icon(Icons.pin),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            textAlign: TextAlign.center,
                            style: context.textTheme.displaySmall,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a match code';
                              }
                              if (value.length != 4) {
                                return 'Code must be 4 digits';
                              }
                              if (!RegExp(r'^\d+$').hasMatch(value)) {
                                return 'Code must contain only numbers';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Team selection
                          Text(
                            'Choose Your Team',
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Auto-assign option
                          _TeamOption(
                            title: 'Auto-assign',
                            subtitle: 'Join team with fewer players',
                            icon: Icons.shuffle,
                            color: context.colorScheme.primary,
                            isSelected: selectedTeam == null,
                            onTap: () {
                              setState(() {
                                selectedTeam = null;
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Team 1 option
                          _TeamOption(
                            title: 'Team 1',
                            subtitle: 'Blue team',
                            icon: Icons.people,
                            color: AppTheme.team1Color,
                            isSelected: selectedTeam == 1,
                            onTap: () {
                              setState(() {
                                selectedTeam = 1;
                              });
                            },
                          ),
                          const SizedBox(height: 12),

                          // Team 2 option
                          _TeamOption(
                            title: 'Team 2',
                            subtitle: 'Red team',
                            icon: Icons.people,
                            color: AppTheme.team2Color,
                            isSelected: selectedTeam == 2,
                            onTap: () {
                              setState(() {
                                selectedTeam = 2;
                              });
                            },
                          ),
                          const SizedBox(height: 32),

                          // Join button
                          CustomButton(
                            text: 'Join Match',
                            onPressed: () => _joinMatch(
                              context,
                              user.uid,
                              user.displayName,
                              user.profilePicture,
                            ),
                            isLoading: matchState is MatchLoading,
                          ),

                          const SizedBox(height: 40),

                          // Info
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  context.colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: context.colorScheme.primary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'If your selected team is full, you will be assigned to the other team',
                                    style: context.textTheme.bodyMedium,
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
              },
            );
          },
        ),
      ),
    );
  }
}

class _TeamOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TeamOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
