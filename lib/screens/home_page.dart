import 'package:flutter/material.dart';
import 'package:rooted/models/daily_verse.dart';
import 'package:rooted/services/local_storage_service.dart';
import 'package:rooted/services/verse_service.dart';
import 'package:rooted/services/sample_data_service.dart';
import 'package:rooted/services/notification_service.dart';
import 'package:rooted/widgets/feature_card.dart';
import 'package:rooted/widgets/daily_verse_card.dart';
import 'package:rooted/screens/bible_tracker_screen.dart';
import 'package:rooted/screens/prayer_schedule_screen.dart';
import 'package:rooted/screens/message_tracker_screen.dart';
import 'package:rooted/screens/book_tracker_screen.dart';
import 'package:rooted/screens/goals_profile_screen.dart';
import 'package:rooted/screens/verse_archive_screen.dart';
import 'package:rooted/screens/achievements_screen.dart';
import 'package:rooted/screens/reading_plans_screen.dart';
import 'package:rooted/services/streak_service.dart';
import 'package:rooted/services/achievement_service.dart';
import 'package:rooted/services/reading_plan_service.dart';
import 'package:rooted/services/smart_reminder_service.dart';
import 'package:rooted/services/share_service.dart';
import 'package:rooted/widgets/streak_card.dart';
import 'package:rooted/models/streak.dart';
import 'package:rooted/models/reading_plan.dart';
import 'package:rooted/models/book_reading.dart';
import 'package:rooted/models/spiritual_goal.dart';
import 'package:rooted/screens/profile_screen.dart';
import 'package:rooted/screens/auth_screen.dart';
import 'package:rooted/screens/reminder_settings_screen.dart';
import 'package:rooted/services/supabase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  DailyVerse? _todaysVerse;
  bool _isLoading = true;
  ReadingStreak? _streak;
  int _unlockedAchievements = 0;
  ReadingPlan? _activePlan;
  DailyReading? _todaysReading;
  
  // Progress data
  String _bibleProgressText = 'No readings yet';
  String _prayerProgressText = 'No schedules';
  String _messageProgressText = 'No messages';
  String _bookProgressText = 'No books';
  String _goalProgressText = 'No goals';
  String _verseArchiveText = '0 favorites';
  String _userName = 'Guest';
  bool _isNewUser = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // When app resumes, check for missed activities and streak warnings
    if (state == AppLifecycleState.resumed) {
      SmartReminderService.checkStreakPreservation();
      SmartReminderService.checkMissedActivities();
    }
  }

  Future<void> _initializeApp() async {
    await LocalStorageService.init();
    
    // Initialize notification service
    await NotificationService.initialize();
    
    // Initialize achievements
    await AchievementService.initializeAchievements();
    
    // Check achievements
    await AchievementService.checkAndUpdateAchievements();
    
    // Reschedule all prayer reminders after loading data
    final schedules = await LocalStorageService.getPrayerSchedules();
    await NotificationService.rescheduleAllReminders(schedules);
    
    // Initialize smart reminders
    await SmartReminderService.initialize();
    
    await _loadTodaysVerse();
    await _loadProgressData();
    await _loadStreakAndAchievements();
    await _loadUserData();
    setState(() => _isLoading = false);
  }

  Future<void> _loadUserData() async {
    final supabase = SupabaseService();
    final user = supabase.currentUser;
    
    if (user == null || user.isAnonymous) {
      _userName = 'Guest';
      _isNewUser = false;
    } else {
      // Check if new user (created within last 10 minutes)
      final createdAt = DateTime.tryParse(user.createdAt);
      if (createdAt != null) {
        _isNewUser = DateTime.now().difference(createdAt).inMinutes < 10;
      }
      // Try to get name from metadata, fallback to email prefix
      final name = user.userMetadata?['full_name'] ?? user.userMetadata?['name'];
      if (name != null) {
        _userName = name;
      } else if (user.email != null) {
        _userName = user.email!.split('@')[0];
      } else {
        _userName = 'User';
      }
    }
  }

  Future<void> _loadProgressData() async {
    await _calculateBibleProgress();
    await _calculatePrayerProgress();
    await _calculateMessageProgress();
    await _calculateBookProgress();
    await _calculateGoalProgress();
    await _calculateVerseArchiveProgress();
    setState(() {});
  }

  Future<void> _loadStreakAndAchievements() async {
    final streak = await StreakService.getStreak();
    final achievements = await AchievementService.getAchievements();
    final activePlan = await ReadingPlanService.getActivePlan();
    
    setState(() {
      _streak = streak;
      _unlockedAchievements = achievements.where((a) => a.isUnlocked).length;
      _activePlan = activePlan;
      _todaysReading = activePlan?.todaysReading;
    });
  }

  Future<void> _calculateBibleProgress() async {
    final readings = await LocalStorageService.getBibleReadings();
    if (readings.isEmpty) {
      _bibleProgressText = 'No readings yet';
      return;
    }
    
    // Get the most recent reading
    readings.sort((a, b) => b.dateRead.compareTo(a.dateRead));
    final lastReading = readings.first;
    _bibleProgressText = '${lastReading.bookName} ${lastReading.chapter}:${lastReading.verse}';
  }

  Future<void> _calculatePrayerProgress() async {
    final schedules = await LocalStorageService.getPrayerSchedules();
    final activeSchedules = schedules.where((s) => s.isActive).toList();
    
    if (activeSchedules.isEmpty) {
      _prayerProgressText = 'No schedules';
      return;
    }

    // Count how many are scheduled for today
    final today = DateTime.now();
    final todayWeekday = today.weekday; // Monday = 1, Sunday = 7
    
    int todayCount = 0;
    for (final schedule in activeSchedules) {
      if (schedule.weekdays.contains(todayWeekday)) {
        todayCount++;
      }
    }

    if (todayCount > 0) {
      _prayerProgressText = '$todayCount scheduled today';
    } else {
      _prayerProgressText = '${activeSchedules.length} active';
    }
  }

  Future<void> _calculateMessageProgress() async {
    final sessions = await LocalStorageService.getMessageSessions();
    if (sessions.isEmpty) {
      _messageProgressText = 'No messages';
      return;
    }

    // Calculate weekly listening time
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    int weeklyMinutes = 0;
    for (final session in sessions) {
      if (session.dateListened.isAfter(weekAgo)) {
        weeklyMinutes += session.minutesListened;
      }
    }

    if (weeklyMinutes > 0) {
      if (weeklyMinutes < 60) {
        _messageProgressText = '$weeklyMinutes min this week';
      } else {
        final hours = (weeklyMinutes / 60).toStringAsFixed(1);
        _messageProgressText = '$hours hr this week';
      }
    } else {
      _messageProgressText = '${sessions.length} total';
    }
  }

  Future<void> _calculateBookProgress() async {
    final books = await LocalStorageService.getBookReadings();
    final activeBooks = books.where((b) => b.status == 'Reading').toList();
    
    if (activeBooks.isEmpty) {
      if (books.isEmpty) {
        _bookProgressText = 'No books';
      } else {
        _bookProgressText = '${books.length} book${books.length == 1 ? '' : 's'}';
      }
      return;
    }

    _bookProgressText = '${activeBooks.length} book${activeBooks.length == 1 ? '' : 's'} reading';
  }

  Future<void> _calculateGoalProgress() async {
    final goals = await LocalStorageService.getSpiritualGoals();
    final activeGoals = goals.where((g) => g.status == 'Active' && !g.isCompleted).toList();
    
    if (activeGoals.isEmpty) {
      if (goals.isEmpty) {
        _goalProgressText = 'No goals';
      } else {
        _goalProgressText = '${goals.length} total';
      }
      return;
    }

    _goalProgressText = '${activeGoals.length} active goal${activeGoals.length == 1 ? '' : 's'}';
  }

  Future<void> _calculateVerseArchiveProgress() async {
    final verses = await LocalStorageService.getDailyVerses();
    final favoriteVerses = verses.where((v) => v.isFavorite).toList();
    
    _verseArchiveText = '${favoriteVerses.length} favorite${favoriteVerses.length == 1 ? '' : 's'}';
  }

  Future<void> _loadTodaysVerse() async {
    try {
      final verse = await VerseService.getTodaysVerse();
      setState(() => _todaysVerse = verse);
    } catch (e) {
      debugPrint('Error loading today\'s verse: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _userName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        actions: [
          if (_userName == 'Guest')
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                ).then((_) => _initializeApp());
              },
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Sign In'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((_) => _initializeApp());
            },
            tooltip: 'Profile & Settings',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareOverallProgress(),
            tooltip: 'Share Progress',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReminderSettingsScreen(),
              ),
            ),
            tooltip: 'Reminder Settings',
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.emoji_events),
                if (_unlockedAchievements > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$_unlockedAchievements',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AchievementsScreen(),
              ),
            ).then((_) => _loadStreakAndAchievements()),
            tooltip: 'Achievements',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadTodaysVerse();
          await _loadProgressData();
          await _loadStreakAndAchievements();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                _userName == 'Guest' 
                  ? 'Welcome to Rooted' 
                  : (_isNewUser ? 'Welcome, $_userName' : 'Welcome back, $_userName'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (_userName == 'Guest')
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Sign in to sync your progress to the cloud',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                'Continue your spiritual journey',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),

              // Daily Verse Card
              if (_todaysVerse != null) ...[
                DailyVerseCard(
                  verse: _todaysVerse!,
                  onFavoriteToggle: () => _toggleFavorite(_todaysVerse!.id),
                  onReflectionTap: () => _showReflectionDialog(_todaysVerse!),
                ),
                const SizedBox(height: 24),
              ],

              // Streak Card (if there's a streak)
              if (_streak != null && _streak!.currentStreak > 0) ...[
                StreakCard(
                  streak: _streak!,
                  showShareButton: true,
                ),
                const SizedBox(height: 24),
              ],

              // Achievements Quick View
              if (true) // Always show achievements card
                Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementsScreen(),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.emoji_events,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Achievements',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _unlockedAchievements > 0 
                                      ? '$_unlockedAchievements unlocked'
                                      : 'View all achievements',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),

              // Features Grid
              Text(
                'Your Spiritual Growth',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  FeatureCard(
                    title: 'Bible Reading',
                    subtitle: 'Track your daily Bible study',
                    icon: Icons.menu_book,
                    iconColor: theme.colorScheme.primary,
                    onTap: () async {
                      await _navigateToScreen(const BibleTrackerScreen());
                      await _loadProgressData();
                      await _loadStreakAndAchievements();
                    },
                    progressText: _bibleProgressText,
                  ),
                  FeatureCard(
                    title: 'Reading Plans',
                    subtitle: 'Follow structured Bible reading plans',
                    icon: Icons.calendar_view_week,
                    iconColor: const Color(0xFF8B5CF6),
                    onTap: () async {
                      await _navigateToScreen(const ReadingPlansScreen());
                      await _loadStreakAndAchievements();
                    },
                    progressText: _activePlan != null 
                        ? '${_activePlan!.progressPercentage}% of ${_activePlan!.name}'
                        : 'No active plan',
                  ),
                  FeatureCard(
                    title: 'Prayer Times',
                    subtitle: 'Schedule prayer reminders',
                    icon: Icons.access_time,
                    iconColor: theme.colorScheme.secondary,
                    onTap: () async {
                      await _navigateToScreen(const PrayerScheduleScreen());
                      await _loadProgressData();
                    },
                    progressText: _prayerProgressText,
                  ),
                  FeatureCard(
                    title: 'Messages',
                    subtitle: 'Track sermons & teachings',
                    icon: Icons.headphones,
                    iconColor: theme.colorScheme.tertiary,
                    onTap: () async {
                      await _navigateToScreen(const MessageTrackerScreen());
                      await _loadProgressData();
                    },
                    progressText: _messageProgressText,
                  ),
                  FeatureCard(
                    title: 'Books',
                    subtitle: 'Christian book reading',
                    icon: Icons.library_books,
                    iconColor: const Color(0xFF8B5CF6),
                    onTap: () async {
                      await _navigateToScreen(const BookTrackerScreen());
                      await _loadProgressData();
                    },
                    progressText: _bookProgressText,
                  ),
                  FeatureCard(
                    title: 'Goals',
                    subtitle: 'Spiritual growth goals',
                    icon: Icons.flag,
                    iconColor: const Color(0xFFF59E0B),
                    onTap: () async {
                      await _navigateToScreen(const GoalsProfileScreen());
                      await _loadProgressData();
                    },
                    progressText: _goalProgressText,
                  ),
                  FeatureCard(
                    title: 'Verse Archive',
                    subtitle: 'View favorite verses',
                    icon: Icons.bookmark,
                    iconColor: const Color(0xFFEF4444),
                    onTap: () async {
                      await _showVerseArchive();
                      await _loadProgressData();
                    },
                    progressText: _verseArchiveText,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToScreen(Widget screen) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _toggleFavorite(String verseId) async {
    await VerseService.toggleFavorite(verseId);
    await _loadTodaysVerse();
    await _calculateVerseArchiveProgress();
    setState(() {});
  }

  Future<void> _shareOverallProgress() async {
    try {
      final readings = await LocalStorageService.getBibleReadings();
      final books = await LocalStorageService.getBookReadings();
      final goals = await LocalStorageService.getSpiritualGoals();
      final streak = _streak ?? await StreakService.getStreak();
      
      final completedBooks = books.where((b) => b.status == 'Completed').length;
      final completedGoals = goals.where((g) => g.isCompleted).length;
      final totalMinutes = readings.fold<int>(0, (sum, r) => sum + r.minutesSpent);

      await ShareService.shareProgressSummary(
        bibleReadings: readings.length,
        minutesSpent: totalMinutes,
        booksCompleted: completedBooks,
        goalsCompleted: completedGoals,
        streak: streak,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error sharing progress')),
        );
      }
    }
  }

  void _showReflectionDialog(DailyVerse verse) {
    final controller = TextEditingController(text: verse.reflection ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reflection'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What does this verse mean to you?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await VerseService.addReflection(verse.id, controller.text);
              await _loadTodaysVerse();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showVerseArchive() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VerseArchiveScreen()),
    );
  }
}
