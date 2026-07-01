import 'package:flutter/material.dart';
import 'package:rooted/models/challenge.dart';
import 'package:rooted/services/gamification_service.dart';

/// Screen displaying active and completed challenges
class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Challenge> _challenges = [];
  bool _isLoading = true;
  bool _showCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);
    
    await GamificationService.refreshChallenges();
    final challenges = await GamificationService.getAllChallenges();
    
    setState(() {
      _challenges = challenges;
      _isLoading = false;
    });
  }

  List<Challenge> get _filteredChallenges {
    if (_showCompleted) {
      return _challenges.where((c) => c.isCompleted).toList();
    }
    return _challenges.where((c) => c.isActive).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        actions: [
          IconButton(
            icon: Icon(_showCompleted ? Icons.check_box : Icons.check_box_outline_blank),
            onPressed: () {
              setState(() {
                _showCompleted = !_showCompleted;
              });
            },
            tooltip: _showCompleted ? 'Show Active' : 'Show Completed',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadChallenges,
              child: _filteredChallenges.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showCompleted ? Icons.emoji_events : Icons.hourglass_empty,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _showCompleted
                                ? 'No completed challenges yet'
                                : 'No active challenges',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredChallenges.length,
                      itemBuilder: (context, index) {
                        return _buildChallengeCard(_filteredChallenges[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final difficultyColor = _getDifficultyColor(challenge.difficulty);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showChallengeDetails(challenge),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(challenge.icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challenge.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (challenge.isCompleted)
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 28),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progress bar
              if (!challenge.isCompleted)
                Column(
                  children: [
                    LinearProgressIndicator(
                      value: challenge.progressPercentage,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(difficultyColor),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${challenge.currentProgress}/${challenge.targetValue}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(challenge.progressPercentage * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              
              const SizedBox(height: 12),
              
              // Footer info
              Row(
                children: [
                  // Difficulty
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: difficultyColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getDifficultyName(challenge.difficulty),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: difficultyColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Type
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getTypeName(challenge.type),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Reward and time
                  if (!challenge.isCompleted)
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${challenge.daysRemaining}d left',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                    ),
                  Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '+${challenge.xpReward}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChallengeDetails(Challenge challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(challenge.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(child: Text(challenge.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(challenge.description),
            const SizedBox(height: 16),
            
            _buildDetailRow('Type', _getTypeName(challenge.type)),
            _buildDetailRow('Difficulty', _getDifficultyName(challenge.difficulty)),
            _buildDetailRow('Reward', '+${challenge.xpReward} XP'),
            _buildDetailRow(
              'Time Remaining',
              challenge.isCompleted
                  ? 'Completed'
                  : '${challenge.daysRemaining} days',
            ),
            
            if (!challenge.isCompleted) ...[
              const SizedBox(height: 16),
              const Text('Progress:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: challenge.progressPercentage,
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(height: 4),
              Text('${challenge.currentProgress}/${challenge.targetValue}'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _getTypeName(ChallengeType type) {
    switch (type) {
      case ChallengeType.daily:
        return 'Daily';
      case ChallengeType.weekly:
        return 'Weekly';
      case ChallengeType.monthly:
        return 'Monthly';
      case ChallengeType.special:
        return 'Special';
    }
  }

  String _getDifficultyName(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return 'Easy';
      case ChallengeDifficulty.medium:
        return 'Medium';
      case ChallengeDifficulty.hard:
        return 'Hard';
      case ChallengeDifficulty.expert:
        return 'Expert';
    }
  }

  Color _getDifficultyColor(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return Colors.green.shade600;
      case ChallengeDifficulty.medium:
        return Colors.blue.shade600;
      case ChallengeDifficulty.hard:
        return Colors.orange.shade600;
      case ChallengeDifficulty.expert:
        return Colors.red.shade600;
    }
  }
}

