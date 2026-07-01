import 'package:flutter/material.dart';
import 'package:rooted/models/achievement.dart';
import 'package:rooted/services/achievement_service.dart';
import 'package:rooted/widgets/achievement_badge.dart';
import 'package:share_plus/share_plus.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);
    try {
      // Check and update achievements
      await AchievementService.checkAndUpdateAchievements();
      final achievements = await AchievementService.getAchievements();
      setState(() {
        _achievements = achievements;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading achievements: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareAchievements() async {
    final unlockedAchievements = _achievements.where((a) => a.isUnlocked).toList();
    
    if (unlockedAchievements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unlock achievements to share them!')),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('🏆 My Rooted Achievements');
    buffer.writeln('');
    buffer.writeln('📊 ${unlockedAchievements.length} of $_totalCount achievements unlocked!');
    buffer.writeln('Progress: ${((_unlockedCount / _totalCount) * 100).toStringAsFixed(0)}% complete');
    buffer.writeln('');
    buffer.writeln('🌟 Unlocked Achievements:');
    
    // Group by category
    final categories = <String, List<Achievement>>{};
    for (final achievement in unlockedAchievements) {
      categories.putIfAbsent(achievement.category, () => []).add(achievement);
    }
    
    for (final entry in categories.entries) {
      final categoryName = entry.key[0].toUpperCase() + entry.key.substring(1);
      buffer.writeln('');
      buffer.writeln('$categoryName:');
      for (final achievement in entry.value) {
        buffer.writeln('  ✓ ${achievement.title}');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('"I press on toward the goal for the prize of the upward call of God in Christ Jesus." - Philippians 3:14');
    buffer.writeln('');
    buffer.writeln('Shared from Rooted - Your Spiritual Growth Companion 🙏');

    await Share.share(
      buffer.toString(),
      subject: 'My Rooted Achievements',
    );
  }

  List<Achievement> get _filteredAchievements {
    if (_selectedCategory == 'All') {
      return _achievements;
    }
    return _achievements.where((a) => a.category == _selectedCategory.toLowerCase()).toList();
  }

  Map<String, String> get _categoryLabels => {
        'All': 'All',
        'bible': 'Bible Reading',
        'streak': 'Streaks',
        'book': 'Books',
        'goal': 'Goals',
        'prayer': 'Prayer',
        'general': 'General',
      };

  int get _unlockedCount => _achievements.where((a) => a.isUnlocked).length;
  int get _totalCount => _achievements.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareAchievements(),
            tooltip: 'Share achievements',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.primaryContainer.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Achievement Progress',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                '$_unlockedCount',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                'Unlocked',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: theme.colorScheme.outline.withOpacity(0.3),
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                          ),
                          Column(
                            children: [
                              Text(
                                '$_totalCount',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              Text(
                                'Total',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: _unlockedCount / _totalCount,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${((_unlockedCount / _totalCount) * 100).toStringAsFixed(0)}% Complete',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Category filter
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _categoryLabels.entries.map((entry) {
                      final isSelected = _selectedCategory == entry.key;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(entry.value),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = entry.key);
                          },
                          selectedColor: theme.colorScheme.primaryContainer,
                          checkmarkColor: theme.colorScheme.onPrimaryContainer,
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Achievements grid
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadAchievements,
                    child: _filteredAchievements.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events_outlined,
                                  size: 64,
                                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No achievements in this category',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _filteredAchievements.length,
                            itemBuilder: (context, index) {
                              final achievement = _filteredAchievements[index];
                              return _AchievementCard(
                                achievement: achievement,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _parseColor(achievement.badgeColor);

    return Card(
      elevation: achievement.isUnlocked ? 4 : 1,
      child: InkWell(
        onTap: () => _showAchievementDetails(context, achievement),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: achievement.isUnlocked
                ? LinearGradient(
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AchievementBadge(
                achievement: achievement,
                size: 60,
                showProgress: !achievement.isUnlocked,
              ),
              const SizedBox(height: 12),
              Text(
                achievement.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                achievement.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (achievement.isUnlocked && achievement.unlockedDate != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Unlocked ${_formatDate(achievement.unlockedDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';
    if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAchievementDetails(BuildContext context, Achievement achievement) {
    final theme = Theme.of(context);
    final color = _parseColor(achievement.badgeColor);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            AchievementBadge(
              achievement: achievement,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(achievement.title),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 16),
            if (!achievement.isUnlocked) ...[
              LinearProgressIndicator(
                value: achievement.progressPercentage / 100,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              const SizedBox(height: 8),
              Text(
                'Progress: ${achievement.currentValue}/${achievement.targetValue}',
                style: theme.textTheme.bodySmall,
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      achievement.unlockedDate != null
                          ? 'Unlocked ${_formatDate(achievement.unlockedDate!)}'
                          : 'Achievement Unlocked!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

