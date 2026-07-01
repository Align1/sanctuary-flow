import 'package:flutter/material.dart';
import 'package:rooted/models/prayer_schedule.dart';
import 'package:rooted/services/local_storage_service.dart';
import 'package:rooted/services/notification_service.dart';

class PrayerScheduleScreen extends StatefulWidget {
  const PrayerScheduleScreen({super.key});

  @override
  State<PrayerScheduleScreen> createState() => _PrayerScheduleScreenState();
}

class _PrayerScheduleScreenState extends State<PrayerScheduleScreen> {
  List<PrayerSchedule> _schedules = [];
  List<PrayerSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final schedules = await LocalStorageService.getPrayerSchedules();
    final sessions = await LocalStorageService.getPrayerSessions();
    setState(() {
      _schedules = schedules;
      _sessions = sessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
                    indicatorColor: theme.colorScheme.primary,
                    tabs: const [
                      Tab(text: 'Schedules'),
                      Tab(text: 'Sessions'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSchedulesTab(),
                        _buildSessionsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScheduleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSchedulesTab() {
    if (_schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No prayer schedules yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a schedule to get prayer reminders',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _schedules.length,
      itemBuilder: (context, index) {
        final schedule = _schedules[index];
        return _ScheduleCard(
          schedule: schedule,
          onToggle: () => _toggleSchedule(schedule),
          onDelete: () => _deleteSchedule(schedule.id),
        );
      },
    );
  }

  Widget _buildSessionsTab() {
    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No prayer sessions yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start logging your prayer times',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[_sessions.length - 1 - index];
        return _SessionCard(session: session);
      },
    );
  }

  void _showAddScheduleDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    Set<int> selectedWeekdays = <int>{};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Prayer Schedule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Morning Prayer',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText: 'Time for morning devotion...',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setDialogState(() => selectedTime = time);
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('Repeat on:'),
                Wrap(
                  children: [
                    for (int i = 1; i <= 7; i++)
                      FilterChip(
                        label: Text(_getWeekdayName(i)),
                        selected: selectedWeekdays.contains(i),
                        onSelected: (selected) {
                          setDialogState(() {
                            if (selected) {
                              selectedWeekdays.add(i);
                            } else {
                              selectedWeekdays.remove(i);
                            }
                          });
                        },
                      ),
                  ],
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
                if (titleController.text.isNotEmpty && selectedWeekdays.isNotEmpty) {
                  final now = DateTime.now();
                  final scheduledDateTime = DateTime(
                    now.year,
                    now.month,
                    now.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  final schedule = PrayerSchedule(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    scheduledTime: scheduledDateTime,
                    weekdays: selectedWeekdays.toList(),
                    isActive: true,
                    description: descriptionController.text.isEmpty 
                        ? null 
                        : descriptionController.text,
                  );

                  await LocalStorageService.savePrayerSchedule(schedule);
                  // Schedule the notification for this prayer time
                  await NotificationService.schedulePrayerReminder(schedule);
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

  String _getWeekdayName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  Future<void> _toggleSchedule(PrayerSchedule schedule) async {
    try {
      // Create updated schedule with toggled active state
      final updatedSchedule = PrayerSchedule(
        id: schedule.id,
        title: schedule.title,
        scheduledTime: schedule.scheduledTime,
        weekdays: schedule.weekdays,
        isActive: !schedule.isActive,
        description: schedule.description,
      );

      // Update in storage
      await LocalStorageService.updatePrayerSchedule(updatedSchedule);
      
      // Update notification
      await NotificationService.schedulePrayerReminder(updatedSchedule);
      
      // Reload data
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${schedule.title} ${updatedSchedule.isActive ? 'enabled' : 'disabled'}'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling schedule: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating schedule. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSchedule(String id) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prayer Schedule'),
        content: const Text('Are you sure you want to delete this prayer schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Cancel notification first
        await NotificationService.cancelPrayerReminder(id);
        
        // Delete from storage
        await LocalStorageService.deletePrayerSchedule(id);
        
        // Reload data
        await _loadData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule deleted')),
          );
        }
      } catch (e) {
        debugPrint('Error deleting schedule: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error deleting schedule. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _ScheduleCard extends StatelessWidget {
  final PrayerSchedule schedule;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ScheduleCard({
    required this.schedule,
    required this.onToggle,
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
                    schedule.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: schedule.isActive,
                  onChanged: (_) => onToggle(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  TimeOfDay.fromDateTime(schedule.scheduledTime).format(context),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Repeats: ${_formatWeekdays(schedule.weekdays)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (schedule.description != null) ...[
              const SizedBox(height: 8),
              Text(
                schedule.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: theme.colorScheme.error,
                  onPressed: onDelete,
                  tooltip: 'Delete schedule',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatWeekdays(List<int> weekdays) {
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays.map((w) => weekdayNames[w - 1]).join(', ');
  }
}

class _SessionCard extends StatelessWidget {
  final PrayerSession session;

  const _SessionCard({required this.session});

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
                Icon(
                  Icons.access_time,
                  color: theme.colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  session.prayerType ?? 'Prayer Session',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${session.minutesPrayed} min',
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
              _formatDateTime(session.startTime),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (session.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                session.notes!,
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime).inDays;
    
    String dateStr;
    if (difference == 0) {
      dateStr = 'Today';
    } else if (difference == 1) {
      dateStr = 'Yesterday';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr at $timeStr';
  }
}
