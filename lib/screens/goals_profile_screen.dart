import 'package:flutter/material.dart';
import 'package:sanctuaryflow/models/spiritual_goal.dart';
import 'package:sanctuaryflow/services/local_storage_service.dart';

class GoalsProfileScreen extends StatefulWidget {
  const GoalsProfileScreen({super.key});

  @override
  State<GoalsProfileScreen> createState() => _GoalsProfileScreenState();
}

class _GoalsProfileScreenState extends State<GoalsProfileScreen> {
  List<SpiritualGoal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await LocalStorageService.getSpiritualGoals();
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiritual Goals'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Profile section
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.person,
                          size: 32,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'My Spiritual Journey',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            title: 'Active Goals',
                            value: '${_getActiveGoalsCount()}',
                            icon: Icons.flag,
                          ),
                          _StatItem(
                            title: 'Completed',
                            value: '${_getCompletedGoalsCount()}',
                            icon: Icons.check_circle,
                          ),
                          _StatItem(
                            title: 'Success Rate',
                            value: '${_getSuccessRate()}%',
                            icon: Icons.trending_up,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Goals list
                Expanded(
                  child: _goals.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _goals.length,
                          itemBuilder: (context, index) {
                            final goal = _goals[index];
                            return _GoalCard(
                              goal: goal,
                              onTap: () => _showGoalDetails(goal),
                              onProgress: () => _updateGoalProgress(goal),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No spiritual goals yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Set goals to track your spiritual growth',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _getActiveGoalsCount() {
    return _goals.where((goal) => goal.status == 'Active').length;
  }

  int _getCompletedGoalsCount() {
    return _goals.where((goal) => goal.status == 'Completed').length;
  }

  int _getSuccessRate() {
    if (_goals.isEmpty) return 0;
    final completed = _getCompletedGoalsCount();
    return ((completed / _goals.length) * 100).round();
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final targetController = TextEditingController();
    String selectedCategory = 'Prayer';
    String selectedFrequency = 'Daily';

    final categories = ['Prayer', 'Bible Study', 'Service', 'Worship', 'Fellowship', 'Other'];
    final frequencies = ['Daily', 'Weekly', 'Monthly', 'Custom'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Spiritual Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Title',
                    hintText: 'Read Bible daily',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Read at least one chapter every day...',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedCategory = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedFrequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: frequencies.map((frequency) => DropdownMenuItem(
                    value: frequency,
                    child: Text(frequency),
                  )).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedFrequency = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target Count',
                    hintText: '30 (for 30 days)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    targetController.text.isNotEmpty) {
                  final goal = SpiritualGoal(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    description: descriptionController.text,
                    category: selectedCategory,
                    startDate: DateTime.now(),
                    frequency: selectedFrequency,
                    targetCount: int.tryParse(targetController.text) ?? 1,
                    currentCount: 0,
                    isCompleted: false,
                    status: 'Active',
                  );

                  await LocalStorageService.saveSpiritualGoal(goal);
                  await _loadGoals();
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDetails(SpiritualGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(goal.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.description),
            const SizedBox(height: 12),
            Text('Category: ${goal.category}'),
            Text('Frequency: ${goal.frequency}'),
            const SizedBox(height: 8),
            Text('Progress: ${goal.currentCount}/${goal.targetCount}'),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: goal.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text('${goal.progressPercentage.toStringAsFixed(1)}% complete'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(goal.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                goal.status,
                style: TextStyle(
                  color: _getStatusColor(goal.status),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (goal.status == 'Active')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateGoalProgress(goal);
              },
              child: const Text('Update Progress'),
            ),
        ],
      ),
    );
  }

  void _updateGoalProgress(SpiritualGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${goal.title} (${goal.currentCount}/${goal.targetCount})'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _incrementProgress(goal, 1),
                  child: const Text('+1'),
                ),
                ElevatedButton(
                  onPressed: () => _incrementProgress(goal, 5),
                  child: const Text('+5'),
                ),
                ElevatedButton(
                  onPressed: () => _showCustomIncrementDialog(goal),
                  child: const Text('Custom'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCustomIncrementDialog(SpiritualGoal goal) {
    final incrementController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Increment'),
        content: TextField(
          controller: incrementController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Add amount',
            hintText: '1',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final increment = int.tryParse(incrementController.text) ?? 0;
              if (increment > 0) {
                Navigator.pop(context); // Close custom dialog
                Navigator.pop(context); // Close update dialog
                _incrementProgress(goal, increment);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _incrementProgress(SpiritualGoal goal, int increment) async {
    final newCount = goal.currentCount + increment;
    final isCompleted = newCount >= goal.targetCount;
    
    final updatedGoal = SpiritualGoal(
      id: goal.id,
      title: goal.title,
      description: goal.description,
      category: goal.category,
      startDate: goal.startDate,
      targetDate: goal.targetDate,
      frequency: goal.frequency,
      targetCount: goal.targetCount,
      currentCount: newCount,
      isCompleted: isCompleted,
      status: isCompleted ? 'Completed' : goal.status,
      milestones: goal.milestones,
    );

    await LocalStorageService.saveSpiritualGoal(updatedGoal);
    await _loadGoals();
    
    if (mounted) {
      Navigator.pop(context); // Close update dialog
      
      if (isCompleted) {
        _showGoalCompletedDialog(goal.title);
      }
    }
  }

  void _showGoalCompletedDialog(String goalTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Goal Completed!'),
        content: Text('Congratulations! You\'ve completed "$goalTitle"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF2563EB);
      case 'Completed':
        return const Color(0xFF10B981);
      case 'Paused':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF59E0B)),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFF59E0B),
          ),
        ),
        Text(
          title,
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SpiritualGoal goal;
  final VoidCallback onTap;
  final VoidCallback onProgress;

  const _GoalCard({
    required this.goal,
    required this.onTap,
    required this.onProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        const SizedBox(height: 2),
                        Text(
                          goal.category,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(goal.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(goal.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: goal.progressPercentage / 100,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getStatusColor(goal.status),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${goal.currentCount}/${goal.targetCount} (${goal.progressPercentage.toStringAsFixed(0)}%)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (goal.status == 'Active') ...[
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: onProgress,
                      icon: const Icon(Icons.add_circle),
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return const Color(0xFF2563EB);
      case 'Completed':
        return const Color(0xFF10B981);
      case 'Paused':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }
}