import 'package:flutter/material.dart' as material;
import 'package:rooted/models/reminder_settings.dart';
import 'package:rooted/services/smart_reminder_service.dart';

class ReminderSettingsScreen extends material.StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  material.State<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState
    extends material.State<ReminderSettingsScreen> {
  ReminderSettings _settings = ReminderSettings();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final settings = await SmartReminderService.getSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    await SmartReminderService.saveSettings(_settings);
    setState(() => _isSaving = false);

    if (mounted) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
            content: material.Text('Reminder settings saved')),
      );
    }
  }

  Future<void> _pickTime(bool isDailyReading) async {
    final currentHour = isDailyReading
        ? _settings.dailyReadingHour
        : _settings.weeklyProgressHour;
    final currentMinute = isDailyReading
        ? _settings.dailyReadingMinute
        : _settings.weeklyProgressMinute;

    final material.TimeOfDay? picked = await material.showTimePicker(
      context: context,
      initialTime: material.TimeOfDay(hour: currentHour, minute: currentMinute),
    );

    if (picked != null) {
      setState(() {
        if (isDailyReading) {
          _settings = _settings.copyWith(
            dailyReadingHour: picked.hour,
            dailyReadingMinute: picked.minute,
          );
        } else {
          _settings = _settings.copyWith(
            weeklyProgressHour: picked.hour,
            weeklyProgressMinute: picked.minute,
          );
        }
      });
      await _saveSettings();
    }
  }

  @override
  material.Widget build(material.BuildContext context) {
    final theme = material.Theme.of(context);

    return material.Scaffold(
      appBar: material.AppBar(
        title: const material.Text('Reminder Settings'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const material.Center(child: material.CircularProgressIndicator())
          : material.ListView(
              padding: const material.EdgeInsets.all(16),
              children: [
                // Daily Reading Reminder
                material.Card(
                  child: material.Padding(
                    padding: const material.EdgeInsets.all(16),
                    child: material.Column(
                      crossAxisAlignment: material.CrossAxisAlignment.start,
                      children: [
                        material.Row(
                          children: [
                            material.Icon(
                              material.Icons.notifications_active,
                              color: theme.colorScheme.primary,
                            ),
                            const material.SizedBox(width: 12),
                            material.Expanded(
                              child: material.Column(
                                crossAxisAlignment:
                                    material.CrossAxisAlignment.start,
                                children: [
                                  material.Text(
                                    'Daily Reading Reminder',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: material.FontWeight.w600,
                                    ),
                                  ),
                                  material.Text(
                                    'Reminds you to read the Bible every day',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            material.Switch(
                              value: _settings.dailyReadingEnabled,
                              onChanged: (value) async {
                                setState(() {
                                  _settings = _settings.copyWith(
                                    dailyReadingEnabled: value,
                                  );
                                });
                                await _saveSettings();
                              },
                            ),
                          ],
                        ),
                        if (_settings.dailyReadingEnabled) ...[
                          const material.SizedBox(height: 16),
                          material.InkWell(
                            onTap: () => _pickTime(true),
                            child: material.Container(
                              padding: const material.EdgeInsets.all(12),
                              decoration: material.BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: material.BorderRadius.circular(8),
                              ),
                              child: material.Row(
                                children: [
                                  material.Icon(
                                    material.Icons.access_time,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                  const material.SizedBox(width: 12),
                                  material.Text(
                                    'Time: ${_settings.formatTime(_settings.dailyReadingHour, _settings.dailyReadingMinute)}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const material.Spacer(),
                                  material.Icon(
                                    material.Icons.edit,
                                    size: 18,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const material.SizedBox(height: 16),

                // Streak Preservation Alert
                material.Card(
                  child: material.Padding(
                    padding: const material.EdgeInsets.all(16),
                    child: material.Column(
                      crossAxisAlignment: material.CrossAxisAlignment.start,
                      children: [
                        material.Row(
                          children: [
                            const material.Icon(
                              material.Icons.local_fire_department,
                              color: material.Color(0xFFFF6B6B),
                            ),
                            const material.SizedBox(width: 12),
                            material.Expanded(
                              child: material.Column(
                                crossAxisAlignment:
                                    material.CrossAxisAlignment.start,
                                children: [
                                  material.Text(
                                    'Streak Preservation',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: material.FontWeight.w600,
                                    ),
                                  ),
                                  material.Text(
                                    'Warns you before losing your reading streak',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            material.Switch(
                              value: _settings.streakPreservationEnabled,
                              onChanged: (value) async {
                                setState(() {
                                  _settings = _settings.copyWith(
                                    streakPreservationEnabled: value,
                                  );
                                });
                                await _saveSettings();
                              },
                            ),
                          ],
                        ),
                        if (_settings.streakPreservationEnabled) ...[
                          const material.SizedBox(height: 16),
                          material.Text(
                            'Warning time before day ends',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          material.Slider(
                            value: _settings.streakWarningHours.toDouble(),
                            min: 1,
                            max: 6,
                            divisions: 5,
                            label: '${_settings.streakWarningHours} hours',
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(
                                  streakWarningHours: value.round(),
                                );
                              });
                            },
                            onChangeEnd: (value) async {
                              await _saveSettings();
                            },
                          ),
                          material.Text(
                            '${_settings.streakWarningHours} hours before midnight',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: material.FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const material.SizedBox(height: 16),

                // Missed Activity Reminder
                material.Card(
                  child: material.Padding(
                    padding: const material.EdgeInsets.all(16),
                    child: material.Row(
                      children: [
                        material.Icon(
                          material.Icons.calendar_today,
                          color: theme.colorScheme.secondary,
                        ),
                        const material.SizedBox(width: 12),
                        material.Expanded(
                          child: material.Column(
                            crossAxisAlignment:
                                material.CrossAxisAlignment.start,
                            children: [
                              material.Text(
                                'Missed Activity Alerts',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: material.FontWeight.w600,
                                ),
                              ),
                              material.Text(
                                'Notifies you when you miss a day',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        material.Switch(
                          value: _settings.missedActivityEnabled,
                          onChanged: (value) async {
                            setState(() {
                              _settings = _settings.copyWith(
                                missedActivityEnabled: value,
                              );
                            });
                            await _saveSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const material.SizedBox(height: 16),

                // Weekly Progress Summary
                material.Card(
                  child: material.Padding(
                    padding: const material.EdgeInsets.all(16),
                    child: material.Column(
                      crossAxisAlignment: material.CrossAxisAlignment.start,
                      children: [
                        material.Row(
                          children: [
                            material.Icon(
                              material.Icons.insights,
                              color: theme.colorScheme.tertiary,
                            ),
                            const material.SizedBox(width: 12),
                            material.Expanded(
                              child: material.Column(
                                crossAxisAlignment:
                                    material.CrossAxisAlignment.start,
                                children: [
                                  material.Text(
                                    'Weekly Progress Summary',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: material.FontWeight.w600,
                                    ),
                                  ),
                                  material.Text(
                                    'Get a weekly summary of your progress',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            material.Switch(
                              value: _settings.weeklyProgressEnabled,
                              onChanged: (value) async {
                                setState(() {
                                  _settings = _settings.copyWith(
                                    weeklyProgressEnabled: value,
                                  );
                                });
                                await _saveSettings();
                              },
                            ),
                          ],
                        ),
                        if (_settings.weeklyProgressEnabled) ...[
                          const material.SizedBox(height: 16),
                          material.DropdownButtonFormField<DayOfWeek>(
                            initialValue: _settings.weeklyProgressDay,
                            decoration: const material.InputDecoration(
                              labelText: 'Day',
                              border: material.OutlineInputBorder(),
                            ),
                            items: DayOfWeek.values.map((day) {
                              return material.DropdownMenuItem(
                                value: day,
                                child: material.Text(day.displayName),
                              );
                            }).toList(),
                            onChanged: (value) async {
                              if (value != null) {
                                setState(() {
                                  _settings = _settings.copyWith(
                                    weeklyProgressDay: value,
                                  );
                                });
                                await _saveSettings();
                              }
                            },
                          ),
                          const material.SizedBox(height: 12),
                          material.InkWell(
                            onTap: () => _pickTime(false),
                            child: material.Container(
                              padding: const material.EdgeInsets.all(12),
                              decoration: material.BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: material.BorderRadius.circular(8),
                              ),
                              child: material.Row(
                                children: [
                                  material.Icon(
                                    material.Icons.access_time,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                  const material.SizedBox(width: 12),
                                  material.Text(
                                    'Time: ${_settings.formatTime(_settings.weeklyProgressHour, _settings.weeklyProgressMinute)}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  const material.Spacer(),
                                  material.Icon(
                                    material.Icons.edit,
                                    size: 18,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const material.SizedBox(height: 24),

                // Info Card
                material.Card(
                  color: theme.colorScheme.primaryContainer,
                  child: material.Padding(
                    padding: const material.EdgeInsets.all(16),
                    child: material.Row(
                      crossAxisAlignment: material.CrossAxisAlignment.start,
                      children: [
                        material.Icon(
                          material.Icons.info_outline,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const material.SizedBox(width: 12),
                        material.Expanded(
                          child: material.Text(
                            'Smart reminders help build consistent habits. They adapt to your reading patterns and provide timely encouragement.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
