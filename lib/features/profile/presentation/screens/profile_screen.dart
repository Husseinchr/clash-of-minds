import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clash_of_minds/core/di/injection_container.dart' as di;
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/core/widgets/profile_image_widget.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_event.dart';
import 'package:clash_of_minds/features/auth/presentation/bloc/auth_state.dart';
import 'package:clash_of_minds/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:clash_of_minds/features/profile/presentation/bloc/profile_event.dart';
import 'package:clash_of_minds/features/profile/presentation/bloc/profile_state.dart';

/// Profile screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _pickImage(BuildContext context, String uid) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null && context.mounted) {
      context.read<ProfileBloc>().add(
            UpdateProfilePictureEvent(
              uid: uid,
              image: File(image.path),
            ),
          );
    }
  }

  void _showEditDisplayNameDialog(
      BuildContext context, String currentDisplayName) {
    final controller = TextEditingController(text: currentDisplayName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocConsumer<AuthBloc, AuthState>(
        listener: (blocContext, state) {
          if (state is DisplayNameUpdated) {
            Navigator.pop(dialogContext);
            if (mounted) {
              context.showSnackBar('Display name updated successfully');
            }
          } else if (state is AuthError) {
            // Close the edit dialog first
            Navigator.pop(dialogContext);
            // Restore authenticated state
            context.read<AuthBloc>().add(CheckAuthStatusEvent());
            // Show error dialog
            if (mounted) {
              showDialog(
                context: context,
                builder: (errorContext) => AlertDialog(
                  title: const Text('Error'),
                  content: Text(state.message),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(errorContext),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }
          }
        },
        builder: (blocContext, state) {
          final isLoading = state is AuthLoading;

          return AlertDialog(
            title: const Text('Edit Display Name'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Enter your display name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a display name';
                  }
                  if (value.trim().length < 3) {
                    return 'Display name must be at least 3 characters';
                  }
                  if (value.trim().length > 20) {
                    return 'Display name must be at most 20 characters';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: isLoading
                    ? null
                    : (_) {
                        if (formKey.currentState!.validate()) {
                          final newName = controller.text.trim();
                          if (newName != currentDisplayName) {
                            context
                                .read<AuthBloc>()
                                .add(UpdateDisplayNameEvent(newName));
                          } else {
                            Navigator.pop(dialogContext);
                          }
                        }
                      },
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (formKey.currentState!.validate()) {
                          final newName = controller.text.trim();
                          if (newName != currentDisplayName) {
                            context
                                .read<AuthBloc>()
                                .add(UpdateDisplayNameEvent(newName));
                          } else {
                            Navigator.pop(dialogContext);
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<ProfileBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            // Don't show snackbar here as errors are handled in the dialog
            if (state is DisplayNameUpdated) {
              // Refresh to Authenticated state with new user data
              context.read<AuthBloc>().add(CheckAuthStatusEvent());
            }
          },
          builder: (context, authState) {
            // Allow both Authenticated and DisplayNameUpdated states to show profile
            // Also allow AuthError to keep showing profile (don't logout on error)
            if (authState is! Authenticated &&
                authState is! DisplayNameUpdated &&
                authState is! AuthError) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final user = authState is Authenticated
                ? authState.user
                : (authState as DisplayNameUpdated).user;

            return BlocListener<ProfileBloc, ProfileState>(
              listener: (context, profileState) {
                if (profileState is ProfilePictureUpdated) {
                  context.showSnackBar('Profile picture updated successfully');
                  // Refresh auth state
                  context.read<AuthBloc>().add(CheckAuthStatusEvent());
                } else if (profileState is ProfileError) {
                  context.showSnackBar(profileState.message, isError: true);
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),

                    // Profile picture
                    Stack(
                      children: [
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.colorScheme.primary,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: ProfileImageWidget(
                              imageUrl: user.profilePicture,
                              size: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: BlocBuilder<ProfileBloc, ProfileState>(
                            builder: (context, profileState) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: context.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: profileState is ProfileLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                        ),
                                  onPressed: profileState is ProfileLoading
                                      ? null
                                      : () => _pickImage(context, user.uid),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Display name
                    Text(
                      user.displayName,
                      style: context.textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Email
                    Text(
                      user.email,
                      style: context.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Profile info cards
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.person,
                          color: context.colorScheme.primary,
                        ),
                        title: const Text('Display Name'),
                        subtitle: Text(user.displayName),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: context.colorScheme.primary,
                          ),
                          onPressed: () => _showEditDisplayNameDialog(
                            context,
                            user.displayName,
                          ),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.email,
                          color: context.colorScheme.primary,
                        ),
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: context.colorScheme.primary,
                        ),
                        title: const Text('Member Since'),
                        subtitle: Text(
                          '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
