import 'package:flutter/material.dart';
import 'package:sanctuaryflow/models/bible_reading.dart';
import 'package:sanctuaryflow/services/local_storage_service.dart';

class BibleTrackerScreen extends StatefulWidget {
  const BibleTrackerScreen({super.key});

  @override
  State<BibleTrackerScreen> createState() => _BibleTrackerScreenState();
}

class _BibleTrackerScreenState extends State<BibleTrackerScreen> {
  List<BibleReading> _readings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    final readings = await LocalStorageService.getBibleReadings();
    setState(() {
      _readings = readings;
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
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats section
                Container(
                  margin: const EdgeInsets.all(16),
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

                // Recent readings
                Expanded(
                  child: _readings.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _readings.length,
                          itemBuilder: (context, index) {
                            final reading = _readings[_readings.length - 1 - index];
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
    return _readings.where((reading) => 
        reading.dateRead.isAfter(weekStart)).length;
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
                  verse: verseController.text.isEmpty ? 'All' : verseController.text,
                  dateRead: DateTime.now(),
                  minutesSpent: int.tryParse(minutesController.text) ?? 0,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );

                await LocalStorageService.saveBibleReading(reading);
                await _loadReadings();
                if (mounted) Navigator.pop(context);
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
    final verseController = TextEditingController(text: reading.verse == 'All' ? '' : reading.verse);
    final minutesController = TextEditingController(text: reading.minutesSpent.toString());
    final notesController = TextEditingController(text: reading.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  verse: verseController.text.isEmpty ? 'All' : verseController.text,
                  dateRead: reading.dateRead,
                  minutesSpent: int.tryParse(minutesController.text) ?? 0,
                  notes: notesController.text.isEmpty ? null : notesController.text,
                );

                await LocalStorageService.updateBibleReading(updatedReading);
                await _loadReadings();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
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
              await _loadReadings();
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.1),
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
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
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
            backgroundColor: theme.colorScheme.error.withValues(alpha: 0.1),
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
    if (difference < 7) return '${difference} days ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }
}