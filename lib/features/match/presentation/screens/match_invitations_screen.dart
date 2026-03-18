import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/match_invitation_entity.dart';
import '../bloc/match_bloc.dart';
import '../bloc/match_event.dart';
import '../bloc/match_state.dart';
import '../widgets/team_selection_dialog.dart';
import 'match_lobby_screen.dart';

class MatchInvitationsScreen extends StatefulWidget {
  final String userId;

  const MatchInvitationsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MatchInvitationsScreen> createState() => _MatchInvitationsScreenState();
}

class _MatchInvitationsScreenState extends State<MatchInvitationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadInvitations();
  }

  void _loadInvitations() {
    context.read<MatchBloc>().add(LoadMatchInvitationsEvent(widget.userId));
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Invitations'),
        backgroundColor: const Color(0xFF1a1a2e),
      ),
      body: BlocConsumer<MatchBloc, MatchState>(
        listener: (context, state) {
          if (state is InvitationResponded) {
            if (state.accepted && state.match != null) {
              // Navigate to match lobby
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: sl<MatchBloc>(),
                    child: MatchLobbyScreen(matchId: state.match!.id),
                  ),
                ),
              );
            } else {
              // Show decline confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invitation declined'),
                  backgroundColor: Colors.orange,
                ),
              );
              _loadInvitations();
            }
          } else if (state is MatchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            _loadInvitations();
          }
        },
        builder: (context, state) {
          // Always show loading when data is being fetched
          // This prevents showing stale accepted invitations
          if (state is MatchLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00d4ff)),
            );
          }

          if (state is InvitationsLoaded) {
            final invitations = state.invitations;

            if (invitations.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadInvitations();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: const Color(0xFF00d4ff),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: invitations.length,
                itemBuilder: (context, index) {
                  return _buildInvitationCard(invitations[index]);
                },
              ),
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No Invitations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any pending match invitations',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationCard(MatchInvitationEntity invitation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF16213e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF0f3460), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF00d4ff),
                  radius: 20,
                  child: Text(
                    invitation.fromUserName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.fromUserName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'invited you to a match',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0f3460),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.vpn_key,
                    color: Color(0xFF00d4ff),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Code: ${invitation.matchCode}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTimeAgo(invitation.createdAt),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptInvitation(invitation),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00d4ff),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _declineInvitation(invitation),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[400],
                      side: BorderSide(color: Colors.grey[700]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _acceptInvitation(MatchInvitationEntity invitation) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    // Show team selection dialog - returns null for auto-assign, 1 or 2 for specific team
    // Also returns null if user cancels the dialog
    final teamNumber = await showDialog<int?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const TeamSelectionDialog(
        maxPlayersPerTeam: AppConstants.maxPlayersPerTeam,
      ),
    );

    // If dialog was dismissed by pressing outside (but we disabled it) or Cancel button
    // The dialog returns null when cancelled, but we want to distinguish from auto-assign
    // So we check if mounted and only proceed
    if (!mounted) return;

    // Proceed with the invitation response (teamNumber can be null for auto-assign, or 1/2)
    context.read<MatchBloc>().add(
          RespondToInvitationEvent(
            invitationId: invitation.id,
            accept: true,
            playerId: authState.user.uid,
            playerName: authState.user.displayName,
            profilePicture: authState.user.profilePicture,
            teamNumber: teamNumber,
          ),
        );
  }

  void _declineInvitation(MatchInvitationEntity invitation) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    context.read<MatchBloc>().add(
          RespondToInvitationEvent(
            invitationId: invitation.id,
            accept: false,
            playerId: authState.user.uid,
            playerName: authState.user.displayName,
            profilePicture: authState.user.profilePicture,
          ),
        );
  }
}
