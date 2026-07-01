import 'package:flutter/material.dart';
import 'package:rooted/models/badge.dart' as models;
import 'package:rooted/services/gamification_service.dart';

/// Screen displaying badge collection
class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<models.Badge> _badges = [];
  models.BadgeCategory _selectedCategory = models.BadgeCategory.general;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    setState(() => _isLoading = true);
    final badges = await GamificationService.getAllBadges();
    setState(() {
      _badges = badges;
      _isLoading = false;
    });
  }

  List<models.Badge> get _filteredBadges {
    if (_selectedCategory == models.BadgeCategory.general) {
      return _badges;
    }
    return _badges.where((b) => b.category == _selectedCategory).toList();
  }

  int get _unlockedCount => _badges.where((b) => b.isUnlocked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Badge Collection'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '$_unlockedCount/${_badges.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Category filter
                _buildCategoryFilter(),
                
                // Badges grid
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadBadges,
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredBadges.length,
                      itemBuilder: (context, index) {
                        return _buildBadgeCard(_filteredBadges[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: models.BadgeCategory.values.map((category) {
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getCategoryName(category)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBadgeCard(models.Badge badge) {
    final color = _getRarityColor(badge.rarity);

    return GestureDetector(
      onTap: () => _showBadgeDetails(badge),
      child: Card(
        elevation: badge.isUnlocked ? 4 : 1,
        color: badge.isUnlocked ? Colors.white : Colors.grey.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge icon
            Text(
              badge.icon,
              style: TextStyle(
                fontSize: 40,
                color: badge.isUnlocked ? null : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            
            // Badge name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                badge.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: badge.isUnlocked ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
            ),
            
            // Rarity indicator
            if (badge.isUnlocked)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getRarityName(badge.rarity),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              )
            else
              // Progress indicator for locked badges
              if (!badge.isUnlocked && badge.progress > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${badge.progress}/${badge.requirement}',
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetails(models.Badge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(badge.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                badge.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              badge.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            if (badge.isUnlocked)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                      const SizedBox(width: 8),
                      const Text('Unlocked', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (badge.unlockedAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 26),
                      child: Text(
                        'on ${badge.unlockedAt!.toString().split(' ')[0]}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progress:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: badge.progressPercentage,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_getRarityColor(badge.rarity)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${badge.progress}/${badge.requirement}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber.shade700, size: 18),
                const SizedBox(width: 8),
                Text(
                  '+${badge.xpReward} XP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
              ],
            ),
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

  String _getCategoryName(models.BadgeCategory category) {
    switch (category) {
      case models.BadgeCategory.general:
        return 'All';
      case models.BadgeCategory.reading:
        return 'Reading';
      case models.BadgeCategory.prayer:
        return 'Prayer';
      case models.BadgeCategory.streak:
        return 'Streak';
      case models.BadgeCategory.goals:
        return 'Goals';
      case models.BadgeCategory.social:
        return 'Social';
      case models.BadgeCategory.milestone:
        return 'Milestones';
    }
  }

  String _getRarityName(models.BadgeRarity rarity) {
    switch (rarity) {
      case models.BadgeRarity.common:
        return 'COMMON';
      case models.BadgeRarity.uncommon:
        return 'UNCOMMON';
      case models.BadgeRarity.rare:
        return 'RARE';
      case models.BadgeRarity.epic:
        return 'EPIC';
      case models.BadgeRarity.legendary:
        return 'LEGENDARY';
    }
  }

  Color _getRarityColor(models.BadgeRarity rarity) {
    switch (rarity) {
      case models.BadgeRarity.common:
        return Colors.grey.shade600;
      case models.BadgeRarity.uncommon:
        return Colors.green.shade600;
      case models.BadgeRarity.rare:
        return Colors.blue.shade600;
      case models.BadgeRarity.epic:
        return Colors.purple.shade600;
      case models.BadgeRarity.legendary:
        return Colors.orange.shade700;
    }
  }
}

/// Leaderboard entry model
class LeaderboardEntry {
  final int rank;
  final String userName;
  final int level;
  final int totalXP;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.userName,
    required this.level,
    required this.totalXP,
    this.isCurrentUser = false,
  });

  String get rankDisplay {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'userName': userName,
        'level': level,
        'totalXP': totalXP,
        'isCurrentUser': isCurrentUser,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank: json['rank'],
        userName: json['userName'],
        level: json['level'],
        totalXP: json['totalXP'],
        isCurrentUser: json['isCurrentUser'] ?? false,
      );

  LeaderboardEntry copyWith({
    int? rank,
    String? userName,
    int? level,
    int? totalXP,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      userName: userName ?? this.userName,
      level: level ?? this.level,
      totalXP: totalXP ?? this.totalXP,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}

