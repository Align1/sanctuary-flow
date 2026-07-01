import 'package:flutter/material.dart';
import 'package:rooted/models/reading_plan.dart';
import 'package:rooted/services/reading_plan_service.dart';
import 'package:rooted/services/smart_reminder_service.dart';
import 'package:rooted/services/share_service.dart';
import 'package:rooted/screens/custom_plan_screen.dart';

class ReadingPlansScreen extends StatefulWidget {
  const ReadingPlansScreen({super.key});

  @override
  State<ReadingPlansScreen> createState() => _ReadingPlansScreenState();
}

class _ReadingPlansScreenState extends State<ReadingPlansScreen> {
  List<ReadingPlan> _userPlans = [];
  List<ReadingPlan> _presetPlans = [];
  ReadingPlan? _activePlan;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    
    final userPlans = await ReadingPlanService.getPlans();
    final activePlan = await ReadingPlanService.getActivePlan();
    final presetPlans = ReadingPlanService.getPresetPlans();
    
    setState(() {
      _userPlans = userPlans;
      _activePlan = activePlan;
      _presetPlans = presetPlans;
      _isLoading = false;
    });
  }

  Future<void> _startPlan(ReadingPlan plan) async {
    // If it's a preset plan, save it first
    if (plan.type == 'preset' && !_userPlans.any((p) => p.id == plan.id)) {
      await ReadingPlanService.savePlan(plan);
    }
    
    await ReadingPlanService.startPlan(plan.id);
    await _loadPlans();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Started: ${plan.name}')),
      );
    }
  }

  Future<void> _deletePlan(String id) async {
    await ReadingPlanService.deletePlan(id);
    await _loadPlans();
  }

  void _showPlanDetails(ReadingPlan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanDetailsScreen(
          plan: plan,
          isActive: plan.id == _activePlan?.id,
          onStart: () => _startPlan(plan),
          onDelete: plan.type == 'custom' ? () => _deletePlan(plan.id) : null,
        ),
      ),
    ).then((_) => _loadPlans());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Plans'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPlans,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Active Plan Section
                  if (_activePlan != null) ...[
                    Text(
                      'Active Plan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PlanCard(
                      plan: _activePlan!,
                      isActive: true,
                      onTap: () => _showPlanDetails(_activePlan!),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Preset Plans
                  Text(
                    'Recommended Plans',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._presetPlans.map((plan) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PlanCard(
                          plan: plan,
                          isActive: false,
                          onTap: () => _showPlanDetails(plan),
                        ),
                      )),

                  // Custom Plans
                  if (_userPlans.where((p) => p.type == 'custom').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'My Custom Plans',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._userPlans
                        .where((p) => p.type == 'custom')
                        .map((plan) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _PlanCard(
                                plan: plan,
                                isActive: plan.id == _activePlan?.id,
                                onTap: () => _showPlanDetails(plan),
                              ),
                            )),
                  ],
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomPlanScreen(),
            ),
          );
          _loadPlans();
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Custom Plan'),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final ReadingPlan plan;
  final bool isActive;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isActive ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plan.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${plan.durationDays} days',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${plan.progressPercentage}% complete',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              if (isActive) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: plan.progressPercentage / 100,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PlanDetailsScreen extends StatefulWidget {
  final ReadingPlan plan;
  final bool isActive;
  final VoidCallback onStart;
  final VoidCallback? onDelete;

  const PlanDetailsScreen({
    super.key,
    required this.plan,
    required this.isActive,
    required this.onStart,
    this.onDelete,
  });

  @override
  State<PlanDetailsScreen> createState() => _PlanDetailsScreenState();
}

class _PlanDetailsScreenState extends State<PlanDetailsScreen> {
  late ReadingPlan _plan;

  @override
  void initState() {
    super.initState();
    _plan = widget.plan;
  }

  Future<void> _toggleDay(int day) async {
    await ReadingPlanService.markDayCompleted(_plan.id, day);
    final plans = await ReadingPlanService.getPlans();
    final updatedPlan = plans.firstWhere((p) => p.id == _plan.id);
    
    // Check streak preservation after completing a reading
    await SmartReminderService.checkStreakPreservation();
    
    setState(() {
      _plan = updatedPlan;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_plan.name),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => ShareService.shareReadingPlan(_plan),
            tooltip: 'Share plan',
          ),
          if (widget.onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Plan'),
                    content: const Text(
                        'Are you sure you want to delete this plan?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onDelete!();
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  _plan.description,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (widget.isActive) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'Completed',
                        value: '${_plan.daysCompleted}',
                        color: Colors.green,
                      ),
                      _StatColumn(
                        label: 'Remaining',
                        value: '${_plan.daysRemaining}',
                        color: theme.colorScheme.primary,
                      ),
                      _StatColumn(
                        label: 'Progress',
                        value: '${_plan.progressPercentage}%',
                        color: theme.colorScheme.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _plan.progressPercentage / 100,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                    minHeight: 8,
                  ),
                ],
              ],
            ),
          ),

          // Daily readings list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _plan.readings.length,
              itemBuilder: (context, index) {
                final reading = _plan.readings[index];
                final isToday = widget.isActive && _plan.todaysReading?.day == reading.day;
                
                return _DailyReadingCard(
                  reading: reading,
                  isToday: isToday,
                  canToggle: widget.isActive,
                  onToggle: () => _toggleDay(reading.day),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: !widget.isActive
          ? FloatingActionButton.extended(
              onPressed: () {
                widget.onStart();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Plan'),
            )
          : null,
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _DailyReadingCard extends StatelessWidget {
  final DailyReading reading;
  final bool isToday;
  final bool canToggle;
  final VoidCallback onToggle;

  const _DailyReadingCard({
    required this.reading,
    required this.isToday,
    required this.canToggle,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isToday
          ? theme.colorScheme.primaryContainer
          : reading.isCompleted
              ? theme.colorScheme.surfaceContainerHighest
              : null,
      child: ListTile(
        leading: canToggle
            ? Checkbox(
                value: reading.isCompleted,
                onChanged: (_) => onToggle(),
                shape: const CircleBorder(),
              )
            : CircleAvatar(
                backgroundColor: reading.isCompleted
                    ? Colors.green
                    : theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  '${reading.day}',
                  style: TextStyle(
                    color: reading.isCompleted ? Colors.white : null,
                    fontSize: 12,
                  ),
                ),
              ),
        title: Text(
          reading.bookName,
          style: TextStyle(
            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
            decoration:
                reading.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          'Chapters ${reading.chapters}',
          style: TextStyle(
            decoration:
                reading.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'TODAY',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            if (reading.isCompleted)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}

