import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../friends/domain/entities/friend_entity.dart';
import '../../../friends/presentation/bloc/friends_bloc.dart';
import '../../../friends/presentation/bloc/friends_event.dart';
import '../../../friends/presentation/bloc/friends_state.dart';
import '../bloc/match_bloc.dart';
import '../bloc/match_event.dart';
import '../bloc/match_state.dart';

/// Bottom sheet for inviting friends to a match
class InviteFriendsBottomSheet extends StatefulWidget {
  final String userId;
  final String userName;
  final String matchId;
  final String matchCode;
  final MatchBloc matchBloc;

  const InviteFriendsBottomSheet({
    super.key,
    required this.userId,
    required this.userName,
    required this.matchId,
    required this.matchCode,
    required this.matchBloc,
  });

  @override
  State<InviteFriendsBottomSheet> createState() =>
      _InviteFriendsBottomSheetState();
}

class _InviteFriendsBottomSheetState extends State<InviteFriendsBottomSheet> {
  final Set<String> _selectedFriendIds = {};
  bool _isSending = false;
  List<FriendEntity> _friends = [];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: widget.matchBloc),
        BlocProvider(
          create: (_) => sl<FriendsBloc>()..add(LoadFriendsEvent(widget.userId)),
        ),
      ],
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1a1a2e),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: BlocConsumer<MatchBloc, MatchState>(
                listener: (context, state) {
                  // Only handle errors - success is handled in _sendInvitations
                  if (state is MatchError) {
                    setState(() => _isSending = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, matchState) {
                  return BlocBuilder<FriendsBloc, FriendsState>(
                    builder: (context, friendsState) {
                      if (friendsState is FriendsLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF00d4ff),
                            ),
                          ),
                        );
                      }

                      if (friendsState is FriendsError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  friendsState.message,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (friendsState is FriendsLoaded ||
                          friendsState is FriendsAndRequestsLoaded) {
                        final friends = friendsState is FriendsLoaded
                            ? friendsState.friends
                            : (friendsState as FriendsAndRequestsLoaded).friends;

                        // Store friends in state for later use
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _friends = friends;
                            });
                          }
                        });

                        if (friends.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: friends.length,
                          itemBuilder: (context, index) {
                            return _buildFriendTile(friends[index]);
                          },
                        );
                      }

                      return _buildEmptyState();
                    },
                  );
                },
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF0f3460), width: 1),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Invite Friends',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select friends to invite to your match',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          if (_selectedFriendIds.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${_selectedFriendIds.length} friend${_selectedFriendIds.length == 1 ? '' : 's'} selected',
              style: const TextStyle(
                color: Color(0xFF00d4ff),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFriendTile(FriendEntity friend) {
    final isSelected = _selectedFriendIds.contains(friend.uid);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF16213e),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF00d4ff) : const Color(0xFF0f3460),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: _isSending
            ? null
            : () {
                setState(() {
                  if (isSelected) {
                    _selectedFriendIds.remove(friend.uid);
                  } else {
                    _selectedFriendIds.add(friend.uid);
                  }
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF00d4ff),
                radius: 24,
                backgroundImage: friend.profilePicture != null
                    ? NetworkImage(friend.profilePicture!)
                    : null,
                child: friend.profilePicture == null
                    ? Text(
                        friend.displayName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  friend.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF00d4ff),
                  size: 24,
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: Colors.grey[600],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No Friends Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add friends to invite them to matches',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF0f3460), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSending ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[400],
                side: BorderSide(color: Colors.grey[700]!),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedFriendIds.isEmpty || _isSending
                  ? null
                  : _sendInvitations,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00d4ff),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey[800],
                disabledForegroundColor: Colors.grey[600],
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Send Invitation${_selectedFriendIds.length > 1 ? 's' : ''}',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendInvitations() {
    setState(() => _isSending = true);

    // Send invitations for each selected friend using stored friends list
    for (final friendId in _selectedFriendIds) {
      final friend = _friends.firstWhere((f) => f.uid == friendId);
      widget.matchBloc.add(
        SendMatchInvitationEvent(
          matchId: widget.matchId,
          matchCode: widget.matchCode,
          fromUserId: widget.userId,
          fromUserName: widget.userName,
          toUserId: friend.uid,
          toUserName: friend.displayName,
        ),
      );
    }

    // Close the bottom sheet and show success message
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedFriendIds.length} invitation${_selectedFriendIds.length > 1 ? 's' : ''} sent successfully',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
