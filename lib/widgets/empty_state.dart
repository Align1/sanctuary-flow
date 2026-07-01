import 'package:flutter/material.dart';

/// Empty state widget with illustration and action
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 80,
                  color: theme.colorScheme.primary.withOpacity(0.6),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title with slide animation
            TweenAnimationBuilder<Offset>(
              tween: Tween(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: offset * 20,
                  child: Opacity(
                    opacity: 1 - offset.dy,
                    child: child,
                  ),
                );
              },
              child: Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states
class EmptyStates {
  static Widget noFavoriteVerses(BuildContext context, VoidCallback? onAction) {
    return EmptyState(
      icon: Icons.star_outline,
      title: 'No Favorite Verses Yet',
      message: 'Mark verses as favorites to find them easily later',
      actionLabel: null,
      onAction: null,
    );
  }

  static Widget noReadingPlans(BuildContext context, VoidCallback onAction) {
    return EmptyState(
      icon: Icons.book_outlined,
      title: 'No Reading Plans',
      message: 'Create a custom plan or choose from our recommended plans to begin your Bible reading journey',
      actionLabel: 'Create Plan',
      onAction: onAction,
    );
  }

  static Widget noAchievements(BuildContext context) {
    return EmptyState(
      icon: Icons.emoji_events_outlined,
      title: 'No Achievements Yet',
      message: 'Start reading, praying, and engaging to unlock badges and achievements',
    );
  }

  static Widget noPrayerEntries(BuildContext context, VoidCallback onAction) {
    return EmptyState(
      icon: Icons.church_outlined,
      title: 'No Prayer Entries',
      message: 'Record your prayers and track answered prayers',
      actionLabel: 'Add Prayer',
      onAction: onAction,
    );
  }

  static Widget noSearchResults(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'Try different keywords or check your spelling',
    );
  }

  static Widget error(BuildContext context, {required VoidCallback onRetry}) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Something Went Wrong',
      message: 'We couldn\'t load this content. Please try again',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }
}
