import 'package:flutter/material.dart';
import 'package:rooted/models/spiritual_goal.dart';

class GoalProgressCard extends StatelessWidget {
  final SpiritualGoal goal;
  final VoidCallback? onTap;
  final VoidCallback? onUpdateProgress;
  final bool showDescription;

  const GoalProgressCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onUpdateProgress,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goal.progressPercentage / 100;
    final progressColor = _getProgressColor(goal);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title and Status
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getCategoryIcon(goal.category),
                              size: 14,
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              goal.category,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              goal.frequency,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(goal.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(goal.status),
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              // Description (optional)
              if (showDescription && goal.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  goal.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 16),

              // Progress section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Progress bar
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: progressColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Progress percentage and count
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${goal.progressPercentage.toStringAsFixed(0)}%',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${goal.currentCount}/${goal.targetCount}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Action button (if provided)
              if (onUpdateProgress != null && goal.status == 'Active' && !goal.isCompleted) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onUpdateProgress,
                    icon: const Icon(Icons.add_circle_outline, size: 16),
                    label: const Text('Update Progress'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    ),
                  ),
                ),
              ],

              // Completion indicator
              if (goal.isCompleted) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Goal completed!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(SpiritualGoal goal) {
    final progress = goal.progressPercentage;
    if (goal.isCompleted) {
      return Colors.green;
    } else if (progress >= 75) {
      return const Color(0xFF10B981); // Green for high progress
    } else if (progress >= 50) {
      return const Color(0xFFF59E0B); // Amber for medium progress
    } else if (progress >= 25) {
      return const Color(0xFFF97316); // Orange for low progress
    } else {
      return const Color(0xFF6366F1); // Indigo for just started
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF3B82F6); // Blue
      case 'completed':
        return Colors.green;
      case 'paused':
        return const Color(0xFFF59E0B); // Amber
      case 'archived':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'prayer':
        return Icons.favorite;
      case 'bible study':
      case 'bible':
        return Icons.menu_book;
      case 'service':
        return Icons.volunteer_activism;
      case 'worship':
        return Icons.music_note;
      case 'fasting':
        return Icons.restaurant;
      case 'fellowship':
        return Icons.people;
      default:
        return Icons.flag;
    }
  }
}

