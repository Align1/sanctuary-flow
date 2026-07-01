import 'package:flutter/material.dart';
import 'package:rooted/models/level.dart';
import 'package:rooted/services/gamification_service.dart';

/// Widget displaying user level and XP progress
class LevelProgressWidget extends StatefulWidget {
  final bool compact;
  final bool showDetails;

  const LevelProgressWidget({
    super.key,
    this.compact = false,
    this.showDetails = true,
  });

  @override
  State<LevelProgressWidget> createState() => _LevelProgressWidgetState();
}

class _LevelProgressWidgetState extends State<LevelProgressWidget> {
  UserLevel? _level;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    final level = await GamificationService.getCurrentLevel();
    setState(() {
      _level = level;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _level == null) {
      return const SizedBox.shrink();
    }

    if (widget.compact) {
      return _buildCompactView();
    }

    return _buildFullView();
  }

  Widget _buildCompactView() {
    final level = _level!;
    final tierIcon = LevelTiers.getTierForLevel(level.level).icon;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(tierIcon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Level ${level.level}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: level.progressToNextLevel,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFullView() {
    final level = _level!;
    final tier = LevelTiers.getTierForLevel(level.level);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level header
            Row(
              children: [
                Text(
                  tier.icon,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Level ',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${level.level}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        level.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        level.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // XP Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${level.currentXP} XP',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${level.xpNeeded} XP to next level',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            LinearProgressIndicator(
              value: level.progressToNextLevel,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
              minHeight: 10,
            ),

            const SizedBox(height: 8),
            
            Text(
              '${(level.progressToNextLevel * 100).toStringAsFixed(1)}% to Level ${level.level + 1}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),

            // Perks
            if (widget.showDetails && level.perks.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Perks Unlocked:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...level.perks.map((perk) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            perk,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact XP display widget
class XPIndicator extends StatelessWidget {
  final int xp;
  final bool showIcon;

  const XPIndicator({
    super.key,
    required this.xp,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(Icons.star, color: Colors.amber.shade700, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            '+$xp XP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Level up celebration dialog
class LevelUpDialog extends StatelessWidget {
  final int oldLevel;
  final int newLevel;
  final LevelTier newTier;

  const LevelUpDialog({
    super.key,
    required this.oldLevel,
    required this.newLevel,
    required this.newTier,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration icon
            Text(
              '🎉',
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            
            // Level up text
            const Text(
              'LEVEL UP!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Level change
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$oldLevel',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.arrow_forward, size: 32),
                const SizedBox(width: 16),
                Text(
                  '$newLevel',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // New tier info
            Text(
              newTier.icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              newTier.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              newTier.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            
            // New perks
            if (newTier.perks.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Perks Unlocked:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...newTier.perks.map((perk) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  size: 14, color: Colors.green.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  perk,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Continue button
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

