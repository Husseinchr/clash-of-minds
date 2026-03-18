import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clash_of_minds/core/di/injection_container.dart' as di;
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_state.dart';
import 'package:clash_of_minds/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:clash_of_minds/features/friends/presentation/bloc/friends_event.dart';
import 'package:clash_of_minds/features/friends/presentation/bloc/friends_state.dart';

/// Friends screen
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _displayNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _sendFriendRequest(BuildContext blocContext) {
    final authState = blocContext.read<AuthBloc>().state;
    if (authState is Authenticated) {
      if (_displayNameController.text.trim().isEmpty) {
        blocContext.showSnackBar('Please enter a display name', isError: true);
        return;
      }

      blocContext.read<FriendsBloc>().add(
            SendFriendRequestEvent(
              fromUserId: authState.user.uid,
              fromUserName: authState.user.displayName,
              fromUserPhoto: authState.user.profilePicture,
              displayName: _displayNameController.text.trim(),
            ),
          );
      _displayNameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is Authenticated ? authState.user.uid : '';

    return BlocProvider(
      create: (_) {
        final bloc = di.sl<FriendsBloc>();
        if (userId.isNotEmpty) {
          // LoadFriendsEvent now loads both friends and requests
          bloc.add(LoadFriendsEvent(userId));
        }
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.people), text: 'My Friends'),
              Tab(icon: Icon(Icons.notifications), text: 'Requests'),
            ],
          ),
        ),
        body: BlocConsumer<FriendsBloc, FriendsState>(
          listener: (context, state) {
            if (state is FriendsError) {
              context.showSnackBar(state.message, isError: true);
            } else if (state is FriendRequestSent) {
              context.showSnackBar('Friend request sent successfully');
            } else if (state is FriendRequestAccepted) {
              context.showSnackBar('Friend request accepted');
            }
          },
          builder: (context, state) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsList(state),
                _buildFriendRequests(state),
              ],
            );
          },
        ),
        floatingActionButton: Builder(
          builder: (builderContext) => FloatingActionButton.extended(
            onPressed: () => _showAddFriendDialog(builderContext),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Friend'),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList(FriendsState state) {
    if (state is FriendsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is FriendsAndRequestsLoaded) {
      if (state.friends.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 24),
              Text(
                'No friends yet',
                style: context.textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add friends to invite them to matches',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.friends.length,
        itemBuilder: (context, index) {
          final friend = state.friends[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: context.colorScheme.primary,
                child: Text(
                  friend.displayName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                friend.displayName,
                style: context.textTheme.titleMedium,
              ),
              trailing: Icon(
                Icons.verified_user,
                color: context.colorScheme.primary,
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFriendRequests(FriendsState state) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is FriendsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is FriendsAndRequestsLoaded) {
      if (state.requests.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 24),
              Text(
                'No friend requests',
                style: context.textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.requests.length,
        itemBuilder: (context, index) {
          final request = state.requests[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: context.colorScheme.secondary,
                child: Text(
                  request.fromUserName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                request.fromUserName,
                style: context.textTheme.titleMedium,
              ),
              subtitle: Text(
                _formatDate(request.createdAt),
                style: context.textTheme.bodySmall,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check_circle),
                    color: Colors.green,
                    iconSize: 32,
                    onPressed: () {
                      context.read<FriendsBloc>().add(
                            AcceptFriendRequestEvent(
                              requestId: request.id,
                              userId: authState.user.uid,
                            ),
                          );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    color: Colors.red,
                    iconSize: 32,
                    onPressed: () {
                      context
                          .read<FriendsBloc>()
                          .add(DeclineFriendRequestEvent(request.id));
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  void _showAddFriendDialog(BuildContext blocContext) {
    showDialog(
      context: blocContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Friend'),
        content: TextField(
          controller: _displayNameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            hintText: 'Enter friend\'s display name',
            prefixIcon: Icon(Icons.person_search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _sendFriendRequest(blocContext);
              Navigator.pop(dialogContext);
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
