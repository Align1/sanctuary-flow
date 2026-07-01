import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:rooted/utils/haptic_feedback.dart';

/// Badge unlock animation dialog
class BadgeUnlockAnimation extends StatefulWidget {
  final String badgeName;
  final String badgeDescription;
  final IconData badgeIcon;
  final Color badgeColor;
  final VoidCallback? onComplete;

  const BadgeUnlockAnimation({
    super.key,
    required this.badgeName,
    required this.badgeDescription,
    required this.badgeIcon,
    required this.badgeColor,
    this.onComplete,
  });

  @override
  State<BadgeUnlockAnimation> createState() => _BadgeUnlockAnimationState();

  /// Show badge unlock animation as dialog
  static Future<void> show(
    BuildContext context, {
    required String badgeName,
    required String badgeDescription,
    required IconData badgeIcon,
    required Color badgeColor,
  }) async {
    // Trigger haptic success pattern
    await HapticFeedbackHelper.success();

    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => BadgeUnlockAnimation(
          badgeName: badgeName,
          badgeDescription: badgeDescription,
          badgeIcon: badgeIcon,
          badgeColor: badgeColor,
          onComplete: () => Navigator.of(context).pop(),
        ),
      );
    }
  }
}

class _BadgeUnlockAnimationState extends State<BadgeUnlockAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation: 0 → 1.2 → 1.0
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_scaleController);

    // Glow animation: pulsing effect
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Start animations
    _scaleController.forward();
    _confettiController.forward();

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds:3), () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti particles
          ...List.generate(20, (index) => _buildConfetti(index)),

          // Main card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.badgeColor.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // "Achievement Unlocked" text
                Text(
                  'Achievement Unlocked!',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: widget.badgeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Animated badge
                AnimatedBuilder(
                  animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.badgeColor.withOpacity(0.1),
                          boxShadow: [
                            BoxShadow(
                              color: widget.badgeColor.withOpacity(_glowAnimation.value * 0.6),
                              blurRadius: 30 * _glowAnimation.value,
                              spreadRadius: 10 * _glowAnimation.value,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.badgeIcon,
                          size: 60,
                          color: widget.badgeColor,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Badge name
                Text(
                  widget.badgeName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                // Badge description
                Text(
                  widget.badgeDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfetti(int index) {
    final random = math.Random(index);
    final startAngle = random.nextDouble() * 2 * math.pi;
    final distance = 100 + random.nextDouble() * 100;
    
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        final progress = _confettiController.value;
        final x = math.cos(startAngle) * distance * progress;
        final y = math.sin(startAngle) * distance * progress - (progress * progress * 50);
        
        return Transform.translate(
          offset: Offset(x, y),
          child: Opacity(
            opacity: (1 - progress).clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: progress * 4 * math.pi,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: [
                    Colors.purple,
                    Colors.amber,
                    Colors.pink,
                    Colors.blue,
                    Colors.green,
                  ][index % 5],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
