import 'package:flutter/material.dart';
import 'package:rooted/models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final double size;
  final bool showProgress;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.size = 80,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _parseColor(achievement.badgeColor);
    final icon = _getIcon(achievement.iconName);

    return Tooltip(
      message: achievement.title,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: achievement.isUnlocked
                  ? color
                  : color.withOpacity(0.3),
              border: Border.all(
                color: achievement.isUnlocked
                    ? color
                    : theme.colorScheme.outline.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: achievement.isUnlocked
                  ? Colors.white
                  : theme.colorScheme.onSurface.withOpacity(0.5),
              size: size * 0.4,
            ),
          ),
          if (showProgress && !achievement.isUnlocked) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: size,
              child: LinearProgressIndicator(
                value: achievement.progressPercentage / 100,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 2,
              ),
            ),
            Text(
              '${achievement.currentValue}/${achievement.targetValue}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.blue;
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'book':
        return Icons.menu_book;
      case 'book_open':
        return Icons.auto_stories;
      case 'auto_stories':
        return Icons.library_books;
      case 'school':
        return Icons.school;
      case 'stars':
        return Icons.stars;
      case 'whatshot':
        return Icons.whatshot;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'flame':
        return Icons.whatshot;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'event':
        return Icons.event;
      case 'menu_book':
        return Icons.menu_book;
      case 'library_books':
        return Icons.library_books;
      case 'local_library':
        return Icons.local_library;
      case 'flag':
        return Icons.flag;
      case 'workspace_premium':
        return Icons.workspace_premium;
      case 'hands_holding':
        return Icons.handshake;
      case 'headphones':
        return Icons.headphones;
      default:
        return Icons.emoji_events;
    }
  }
}

