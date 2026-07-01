import 'package:flutter/material.dart';
import 'package:rooted/models/message_session.dart';
import 'package:rooted/services/local_storage_service.dart';

class MessageTrackerScreen extends StatefulWidget {
  const MessageTrackerScreen({super.key});

  @override
  State<MessageTrackerScreen> createState() => _MessageTrackerScreenState();
}

class _MessageTrackerScreenState extends State<MessageTrackerScreen> {
  List<MessageSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await LocalStorageService.getMessageSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Tracker'),
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
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.tertiaryContainer,
                        theme.colorScheme.tertiaryContainer.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        title: 'Total Messages',
                        value: '${_sessions.length}',
                        icon: Icons.headphones,
                      ),
                      _StatItem(
                        title: 'This Week',
                        value: '${_getThisWeekCount()}',
                        icon: Icons.calendar_today,
                      ),
                      _StatItem(
                        title: 'Total Hours',
                        value: (_getTotalMinutes() / 60).toStringAsFixed(1),
                        icon: Icons.timer,
                      ),
                    ],
                  ),
                ),

                // Messages list
                Expanded(
                  child: _sessions.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _sessions.length,
                          itemBuilder: (context, index) {
                            final session =
                                _sessions[_sessions.length - 1 - index];
                            return _MessageCard(
                              session: session,
                              onEdit: () => _showEditMessageDialog(session),
                              onDelete: () => _confirmDeleteMessage(session.id),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMessageDialog,
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
            Icons.headphones,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages tracked yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking sermons, podcasts, and teachings',
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
    return _sessions
        .where((session) => session.dateListened.isAfter(weekStart))
        .length;
  }

  int _getTotalMinutes() {
    return _sessions.fold(0, (sum, session) => sum + session.minutesListened);
  }

  void _showAddMessageDialog() {
    final titleController = TextEditingController();
    final speakerController = TextEditingController();
    final minutesController = TextEditingController();
    final notesController = TextEditingController();
    String selectedSource = 'Podcast';
    double rating = 3.0;

    final sources = ['Podcast', 'YouTube', 'Church Service', 'Radio', 'Other'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Message'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'The Power of Prayer',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: speakerController,
                  decoration: const InputDecoration(
                    labelText: 'Speaker/Pastor',
                    hintText: 'Pastor John Smith',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedSource,
                  decoration: const InputDecoration(labelText: 'Source'),
                  items: sources
                      .map((source) => DropdownMenuItem(
                            value: source,
                            child: Text(source),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedSource = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rating: ${rating.toInt()}/5'),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (value) {
                        setDialogState(() => rating = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Key insights and takeaways...',
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
                    speakerController.text.isNotEmpty &&
                    minutesController.text.isNotEmpty) {
                  final session = MessageSession(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    speaker: speakerController.text,
                    dateListened: DateTime.now(),
                    minutesListened: int.tryParse(minutesController.text) ?? 0,
                    source: selectedSource,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                    rating: rating,
                    tags: [],
                  );

                  await LocalStorageService.saveMessageSession(session);
                  await _loadSessions();
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

  void _showEditMessageDialog(MessageSession session) {
    final titleController = TextEditingController(text: session.title);
    final speakerController = TextEditingController(text: session.speaker);
    final minutesController =
        TextEditingController(text: session.minutesListened.toString());
    final notesController = TextEditingController(text: session.notes ?? '');
    String selectedSource = session.source;
    double rating = session.rating ?? 3.0;

    final sources = ['Podcast', 'YouTube', 'Church Service', 'Radio', 'Other'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Message'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'The Power of Prayer',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: speakerController,
                  decoration: const InputDecoration(
                    labelText: 'Speaker/Pastor',
                    hintText: 'Pastor John Smith',
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedSource,
                  decoration: const InputDecoration(labelText: 'Source'),
                  items: sources
                      .map((source) => DropdownMenuItem(
                            value: source,
                            child: Text(source),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedSource = value);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: minutesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rating: ${rating.toInt()}/5'),
                    Slider(
                      value: rating,
                      min: 1,
                      max: 5,
                      divisions: 4,
                      onChanged: (value) {
                        setDialogState(() => rating = value);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    hintText: 'Key insights and takeaways...',
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
                    speakerController.text.isNotEmpty &&
                    minutesController.text.isNotEmpty) {
                  final updatedSession = MessageSession(
                    id: session.id,
                    title: titleController.text,
                    speaker: speakerController.text,
                    dateListened: session.dateListened,
                    minutesListened: int.tryParse(minutesController.text) ?? 0,
                    source: selectedSource,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                    rating: rating,
                    tags: session.tags,
                  );

                  await LocalStorageService.updateMessageSession(
                      updatedSession);
                  await _loadSessions();
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

  Future<void> _confirmDeleteMessage(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content:
            const Text('Are you sure you want to delete this message session?'),
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

    if (confirm == true && mounted) {
      try {
        await LocalStorageService.deleteMessageSession(id);
        await _loadSessions();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message deleted')),
          );
        }
      } catch (e) {
        debugPrint('Error deleting message: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error deleting message. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
        Icon(icon, color: theme.colorScheme.tertiary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
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

class _MessageCard extends StatelessWidget {
  final MessageSession session;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _MessageCard({
    required this.session,
    this.onEdit,
    this.onDelete,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'by ${session.speaker}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${session.minutesListened} min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    session.source,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (session.rating != null) ...[
                  Row(
                    children: [
                      for (int i = 1; i <= 5; i++)
                        Icon(
                          i <= session.rating! ? Icons.star : Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  _formatDate(session.dateListened),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
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
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                      ),
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: theme.colorScheme.error,
                      onPressed: onDelete,
                      tooltip: 'Delete message',
                    ),
                ],
              ),
            ],
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
