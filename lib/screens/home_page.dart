import 'package:flutter/material.dart';
import 'package:sanctuaryflow/models/daily_verse.dart';
import 'package:sanctuaryflow/services/local_storage_service.dart';
import 'package:sanctuaryflow/services/verse_service.dart';
import 'package:sanctuaryflow/services/sample_data_service.dart';
import 'package:sanctuaryflow/widgets/feature_card.dart';
import 'package:sanctuaryflow/widgets/daily_verse_card.dart';
import 'package:sanctuaryflow/screens/bible_tracker_screen.dart';
import 'package:sanctuaryflow/screens/prayer_schedule_screen.dart';
import 'package:sanctuaryflow/screens/message_tracker_screen.dart';
import 'package:sanctuaryflow/screens/book_tracker_screen.dart';
import 'package:sanctuaryflow/screens/goals_profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DailyVerse? _todaysVerse;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await LocalStorageService.init();
    await _loadSampleData();
    await _loadTodaysVerse();
    setState(() => _isLoading = false);
  }

  Future<void> _loadTodaysVerse() async {
    try {
      final verse = await VerseService.getTodaysVerse();
      setState(() => _todaysVerse = verse);
    } catch (e) {
      debugPrint('Error loading today\'s verse: $e');
    }
  }

  Future<void> _loadSampleData() async {
    // Add sample data if none exists
    await SampleDataService.initializeSampleData();
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
          'SanctuaryFlow',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: RefreshIndicator(
        onRefresh: _loadTodaysVerse,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                'Welcome back!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Continue your spiritual journey',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                    onTap: () => _navigateToScreen(const BibleTrackerScreen()),
                    progressText: 'Genesis 1:1-10',
                  ),
                  FeatureCard(
                    title: 'Prayer Times',
                    subtitle: 'Schedule prayer reminders',
                    icon: Icons.access_time,
                    iconColor: theme.colorScheme.secondary,
                    onTap: () => _navigateToScreen(const PrayerScheduleScreen()),
                    progressText: '3 scheduled today',
                  ),
                  FeatureCard(
                    title: 'Messages',
                    subtitle: 'Track sermons & teachings',
                    icon: Icons.headphones,
                    iconColor: theme.colorScheme.tertiary,
                    onTap: () => _navigateToScreen(const MessageTrackerScreen()),
                    progressText: '45 min this week',
                  ),
                  FeatureCard(
                    title: 'Books',
                    subtitle: 'Christian book reading',
                    icon: Icons.library_books,
                    iconColor: const Color(0xFF8B5CF6),
                    onTap: () => _navigateToScreen(const BookTrackerScreen()),
                    progressText: '2 books reading',
                  ),
                  FeatureCard(
                    title: 'Goals',
                    subtitle: 'Spiritual growth goals',
                    icon: Icons.flag,
                    iconColor: const Color(0xFFF59E0B),
                    onTap: () => _navigateToScreen(const GoalsProfileScreen()),
                    progressText: '3 active goals',
                  ),
                  FeatureCard(
                    title: 'Verse Archive',
                    subtitle: 'View favorite verses',
                    icon: Icons.bookmark,
                    iconColor: const Color(0xFFEF4444),
                    onTap: () => _showVerseArchive(),
                    progressText: '12 favorites',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Future<void> _toggleFavorite(String verseId) async {
    await VerseService.toggleFavorite(verseId);
    await _loadTodaysVerse();
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

  void _showVerseArchive() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verse Archive'),
        content: const Text('View and manage your favorite verses.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}