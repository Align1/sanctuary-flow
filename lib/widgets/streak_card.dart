import 'package:flutter/material.dart';
import 'package:rooted/models/streak.dart';
import 'package:rooted/services/share_service.dart';

class StreakCard extends StatelessWidget {
  final ReadingStreak streak;
  final bool showShareButton;

  const StreakCard({
    super.key,
    required this.streak,
    this.showShareButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFF6B6B).withOpacity(0.1),
              const Color(0xFFFF6B6B).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    color: Color(0xFFFF6B6B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reading Streak',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        streak.hasReadToday() 
                            ? 'Keep it going! 🔥' 
                            : 'Start your streak today',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showShareButton && streak.currentStreak > 0)
                  IconButton(
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: () => ShareService.shareStreak(streak),
                    tooltip: 'Share streak',
                    color: const Color(0xFFFF6B6B),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StreakStat(
                  label: 'Current',
                  value: '${streak.currentStreak}',
                  sublabel: 'days',
                  icon: Icons.whatshot,
                  color: const Color(0xFFFF6B6B),
                ),
                _StreakStat(
                  label: 'Longest',
                  value: '${streak.longestStreak}',
                  sublabel: 'days',
                  icon: Icons.emoji_events,
                  color: const Color(0xFFFFD700),
                ),
                _StreakStat(
                  label: 'Weekly',
                  value: '${streak.weeklyStreak}',
                  sublabel: 'weeks',
                  icon: Icons.calendar_today,
                  color: const Color(0xFF9C27B0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakStat extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final IconData icon;
  final Color color;

  const _StreakStat({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          sublabel,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

