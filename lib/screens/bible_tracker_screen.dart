import 'package:flutter/material.dart';
import 'package:rooted/models/bible_reading.dart';
import 'package:rooted/services/local_storage_service.dart';
import 'package:rooted/services/streak_service.dart';
import 'package:rooted/services/achievement_service.dart';
import 'package:rooted/services/smart_reminder_service.dart';
import 'package:rooted/services/share_service.dart';
import 'package:rooted/widgets/streak_card.dart';
import 'package:rooted/models/achievement.dart';
import 'package:rooted/models/streak.dart';
import 'package:rooted/models/reading_plan.dart';
import 'package:rooted/services/reading_plan_service.dart';
import 'package:rooted/screens/reading_plans_screen.dart';

class BibleTrackerScreen extends StatefulWidget {
  const BibleTrackerScreen({super.key});

  @override
  State<BibleTrackerScreen> createState() => _BibleTrackerScreenState();
}

class _BibleTrackerScreenState extends State<BibleTrackerScreen> {
  List<BibleReading> _readings = [];
  bool _isLoading = true;
  ReadingStreak? _streak;
  ReadingPlan? _activePlan;
  DailyReading? _todaysReading;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final readings = await LocalStorageService.getBibleReadings();
    final streak = await StreakService.getStreak();
    final activePlan = await ReadingPlanService.getActivePlan();
    setState(() {
      _readings = readings;
      _streak = streak;
      _activePlan = activePlan;
      _todaysReading = activePlan?.todaysReading;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Reading Tracker'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          if (_streak != null && _streak!.currentStreak > 0)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => ShareService.shareStreak(_streak!),
              tooltip: 'Share streak',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Streak card
                if (_streak != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: StreakCard(
                      streak: _streak!,
                      showShareButton: true,
                    ),
                  ),
                ],

                // Stats section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        title: 'Total Sessions',
                        value: '${_readings.length}',
                        icon: Icons.book,
                      ),
                      _StatItem(
                        title: 'This Week',
                        value: '${_getThisWeekCount()}',
                        icon: Icons.calendar_today,
                      ),
                      _StatItem(
                        title: 'Total Minutes',
                        value: '${_getTotalMinutes()}',
                        icon: Icons.timer,
                      ),
                    ],
                  ),
                ),

                // Today's Reading from Active Plan
                if (_todaysReading != null && _activePlan != null) ...[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReadingPlansScreen(),
                          ),
                        ).then((_) => _loadData()),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primaryContainer,
                                theme.colorScheme.primaryContainer
                                    .withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.book_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Today\'s Reading',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _activePlan!.name,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.onSurface
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _todaysReading!.isCompleted
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: _todaysReading!.isCompleted
                                          ? Colors.green
                                          : theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _todaysReading!.bookName,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            'Chapters ${_todaysReading!.chapters}',
                                            style: theme.textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_todaysReading!.isCompleted)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'DONE',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: _activePlan!.progressPercentage / 100,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_activePlan!.progressPercentage}% complete • Day ${_todaysReading!.day} of ${_activePlan!.durationDays}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Recent readings
                Expanded(
                  child: _readings.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _readings.length,
                          itemBuilder: (context, index) {
                            final reading =
                                _readings[_readings.length - 1 - index];
                            return _ReadingCard(
                              reading: reading,
                              onEdit: () => _showEditReadingDialog(reading),
                              onDelete: () => _showDeleteConfirmation(reading),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReadingDialog,
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
            Icons.menu_book,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Bible readings yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first reading session',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _getThisWeekCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _readings
        .where((reading) => reading.dateRead.isAfter(weekStart))
        .length;
  }

  int _getTotalMinutes() {
    return _readings.fold(0, (sum, reading) => sum + reading.minutesSpent);
  }

  void _showAddReadingDialog() {
    final bookController = TextEditingController();
    final chapterController = TextEditingController();
    final verseController = TextEditingController();
    final minutesController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Bible Reading'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: bookController,
                decoration: const InputDecoration(
                  labelText: 'Book',
                  hintText: 'e.g., Genesis',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: chapterController,
                decoration: const InputDecoration(
                  labelText: 'Chapter',
                  hintText: 'e.g., 1',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: verseController,
                decoration: const InputDecoration(
                  labelText: 'Verses',
                  hintText: 'e.g., 1-10',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minutes spent reading',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Any insights or reflections...',
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
              if (bookController.text.isNotEmpty &&
                  chapterController.text.isNotEmpty &&
                  minutesController.text.isNotEmpty) {
                final reading = BibleReading(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  bookName: bookController.text,
                  chapter: chapterController.text,
                  verse: verseController.text.isEmpty
                      ? 'All'
                      : verseController.text,
                  dateRead: DateTime.now(),
                  minutesSpent: int.tryParse(minutesController.text) ?? 0,
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                );

                await LocalStorageService.saveBibleReading(reading);

                // Update streak
                await StreakService.updateStreak(reading);

                // Check achievements
                final beforeAchievements =
                    await AchievementService.getAchievements();
                final beforeUnlockedIds = beforeAchievements
                    .where((a) => a.isUnlocked)
                    .map((a) => a.id)
                    .toSet();

                final newAchievements =
                    await AchievementService.checkAndUpdateAchievements();
                final newlyUnlocked = newAchievements
                    .where((a) =>
                        a.isUnlocked && !beforeUnlockedIds.contains(a.id))
                    .toList();

                // Reset streak warnings since user just read
                await SmartReminderService.checkStreakPreservation();

                await _loadData();

                if (mounted) {
                  Navigator.pop(context);

                  // Show celebration for newly unlocked achievements
                  if (newlyUnlocked.isNotEmpty) {
                    _showAchievementCelebration(newlyUnlocked);
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditReadingDialog(BibleReading reading) {
    final bookController = TextEditingController(text: reading.bookName);
    final chapterController = TextEditingController(text: reading.chapter);
    final verseController = TextEditingController(
        text: reading.verse == 'All' ? '' : reading.verse);
    final minutesController =
        TextEditingController(text: reading.minutesSpent.toString());
    final notesController = TextEditingController(text: reading.notes ?? '');
    DateTime selectedDate = reading.dateRead;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Bible Reading'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: bookController,
                  decoration: const InputDecoration(
                    labelText: 'Book',
                    hintText: 'e.g., Genesis',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: chapterController,
                  decoration: const InputDecoration(
                    labelText: 'Chapter',
                    hintText: 'e.g., 1',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: verseController,
                  decoration: const InputDecoration(
                    labelText: 'Verses',
                    hintText: 'e.g., 1-10',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Minutes spent reading',
                  ),
                ),
                const SizedBox(height: 8),
                // Date picker
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date Read',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Any insights or reflections...',
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
                if (bookController.text.isNotEmpty &&
                    chapterController.text.isNotEmpty &&
                    minutesController.text.isNotEmpty) {
                  final updatedReading = BibleReading(
                    id: reading.id,
                    bookName: bookController.text,
                    chapter: chapterController.text,
                    verse: verseController.text.isEmpty
                        ? 'All'
                        : verseController.text,
                    dateRead: selectedDate,
                    minutesSpent: int.tryParse(minutesController.text) ?? 0,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                  );

                  await LocalStorageService.updateBibleReading(updatedReading);
                  await _loadData();
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BibleReading reading) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reading'),
        content: Text(
          'Are you sure you want to delete the reading of ${reading.bookName} ${reading.chapter}:${reading.verse}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await LocalStorageService.deleteBibleReading(reading.id);
              await _loadData();
              if (mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAchievementCelebration(List<Achievement> achievements) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 64,
              color: Color(0xFFFFD700),
            ),
            const SizedBox(height: 16),
            Text(
              'Achievement Unlocked! 🎉',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...achievements.map((achievement) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          _parseColor(achievement.badgeColor).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          achievement.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.description,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
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
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
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

class _ReadingCard extends StatelessWidget {
  final BibleReading reading;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ReadingCard({
    required this.reading,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${reading.bookName} ${reading.chapter}:${reading.verse}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${reading.minutesSpent} min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(reading.dateRead),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (reading.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                reading.notes!,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 24),
                  onPressed: onEdit,
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  tooltip: 'Edit reading',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 24),
                  onPressed: onDelete,
                  style: IconButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    backgroundColor: theme.colorScheme.error.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  tooltip: 'Delete reading',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
