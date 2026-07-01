import 'package:flutter/material.dart';
import 'package:rooted/services/leaderboard_service.dart';

/// Screen displaying user rankings and leaderboard
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardEntry> _entries = [];
  LeaderboardPeriod _period = LeaderboardPeriod.allTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    final entries = await LeaderboardService.getLeaderboard(period: _period);
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildPeriodSelector(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _entries.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildTopThree();
                  }
                  
                  if (index <= 3) return const SizedBox.shrink();
                  
                  return _buildLeaderboardCard(_entries[index - 1]);
                },
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: LeaderboardPeriod.values.map((period) {
          final isSelected = _period == period;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _period = period;
                  });
                  _loadLeaderboard();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? null : Colors.grey.shade200,
                  foregroundColor: isSelected ? null : Colors.black87,
                  padding: EdgeInsets.zero,
                  textStyle: const TextStyle(fontSize: 11),
                ),
                child: Text(_getPeriodName(period)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopThree() {
    if (_entries.length < 3) return const SizedBox.shrink();

    final first = _entries[0];
    final second = _entries.length > 1 ? _entries[1] : null;
    final third = _entries.length > 2 ? _entries[2] : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (second != null) _buildPodium(second, 2, 100),
            _buildPodium(first, 1, 120),
            if (third != null) _buildPodium(third, 3, 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPodium(LeaderboardEntry entry, int position, double height) {
    return Column(
      children: [
        CircleAvatar(
          radius: position == 1 ? 35 : 30,
          backgroundColor: _getRankColor(position),
          child: Text(
            entry.userName[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          entry.userName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'Lv ${entry.level}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: height,
          width: 80,
          decoration: BoxDecoration(
            color: _getRankColor(position).withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: _getRankColor(position)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.rankDisplay,
                style: const TextStyle(fontSize: 24),
              ),
              Text(
                '${entry.totalXP} XP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(position),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: entry.isCurrentUser ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: entry.isCurrentUser
              ? Theme.of(context).primaryColor
              : Colors.grey.shade400,
          child: Text(
            entry.userName[0].toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          entry.userName,
          style: TextStyle(
            fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('Level ${entry.level} • ${entry.totalXP} XP'),
        trailing: Text(
          entry.rankDisplay,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber.shade600;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade400;
      default:
        return Colors.blue.shade600;
    }
  }

  String _getPeriodName(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.daily:
        return 'Daily';
      case LeaderboardPeriod.weekly:
        return 'Weekly';
      case LeaderboardPeriod.monthly:
        return 'Monthly';
      case LeaderboardPeriod.allTime:
        return 'All Time';
    }
  }
}

