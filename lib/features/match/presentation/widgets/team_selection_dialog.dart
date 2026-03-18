import 'package:flutter/material.dart';
import 'package:clash_of_minds/core/constants/app_constants.dart';
import 'package:clash_of_minds/core/extensions/context_extensions.dart';
import 'package:clash_of_minds/core/theme/app_theme.dart';

/// Team selection dialog
class TeamSelectionDialog extends StatefulWidget {
  final int? team1Count;
  final int? team2Count;
  final int maxPlayersPerTeam;

  const TeamSelectionDialog({
    super.key,
    this.team1Count,
    this.team2Count,
    this.maxPlayersPerTeam = AppConstants.maxPlayersPerTeam,
  });

  @override
  State<TeamSelectionDialog> createState() => _TeamSelectionDialogState();
}

class _TeamSelectionDialogState extends State<TeamSelectionDialog> {
  int? selectedTeam;

  bool get team1Full =>
      widget.team1Count != null &&
      widget.team1Count! >= widget.maxPlayersPerTeam;
  bool get team2Full =>
      widget.team2Count != null &&
      widget.team2Count! >= widget.maxPlayersPerTeam;
  bool get bothTeamsFull => team1Full && team2Full;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Your Team',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (bothTeamsFull)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Both teams are full',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
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
              const SizedBox(height: 16),

              // Team 1
              _TeamOption(
                title: 'Team 1',
                subtitle: widget.team1Count != null
                    ? '${widget.team1Count}/${widget.maxPlayersPerTeam} players'
                    : 'No info available',
                icon: Icons.people,
                color: AppTheme.team1Color,
                isSelected: selectedTeam == 1,
                isDisabled: team1Full,
                onTap: team1Full
                    ? null
                    : () {
                        setState(() {
                          selectedTeam = 1;
                        });
                      },
              ),
              const SizedBox(height: 16),

              // Team 2
              _TeamOption(
                title: 'Team 2',
                subtitle: widget.team2Count != null
                    ? '${widget.team2Count}/${widget.maxPlayersPerTeam} players'
                    : 'No info available',
                icon: Icons.people,
                color: AppTheme.team2Color,
                isSelected: selectedTeam == 2,
                isDisabled: team2Full,
                onTap: team2Full
                    ? null
                    : () {
                        setState(() {
                          selectedTeam = 2;
                        });
                      },
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: bothTeamsFull
                        ? null
                        : () => Navigator.of(context).pop(selectedTeam),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
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
  final bool isDisabled;
  final VoidCallback? onTap;

  const _TeamOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isSelected = false,
    this.isDisabled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey.withValues(alpha: 0.1)
              : isSelected
                  ? color.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled
                ? Colors.grey
                : isSelected
                    ? color
                    : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDisabled ? Colors.grey : color,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDisabled ? Colors.grey : null,
                    ),
                  ),
                  Text(
                    isDisabled ? 'Team full' : subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isDisabled ? Colors.grey : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
