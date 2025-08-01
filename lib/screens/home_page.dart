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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize storage first (non-blocking)
    await LocalStorageService.init();
    
    // Load today's verse immediately for better UX
    await _loadTodaysVerse();
    
    // Mark as initialized to show main content
    setState(() {
      _isLoading = false;
      _isInitialized = true;
    });

    // Initialize sample data in background (non-blocking)
    _initializeSampleDataInBackground();
    
    // Preload verses in background
    VerseService.preloadVerses();
  }

  Future<void> _loadTodaysVerse() async {
    try {
      final verse = await VerseService.getTodaysVerse();
      if (mounted) {
        setState(() => _todaysVerse = verse);
      }
    } catch (e) {
      debugPrint('Error loading today\'s verse: $e');
    }
  }

  Future<void> _initializeSampleDataInBackground() async {
    try {
      await SampleDataService.initializeSampleData();
    } catch (e) {
      debugPrint('Error initializing sample data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading SanctuaryFlow...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
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

              // Daily verse card
              if (_todaysVerse != null)
                DailyVerseCard(verse: _todaysVerse!)
              else
                _buildVersePlaceholder(theme),
              const SizedBox(height: 24),

              // Features grid
              Text(
                'Your Spiritual Tools',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeaturesGrid(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersePlaceholder(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_stories,
            color: theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Loading today\'s verse...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        FeatureCard(
          title: 'Bible Reading',
          subtitle: 'Track your daily reading',
          icon: Icons.auto_stories,
          color: theme.colorScheme.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BibleTrackerScreen(),
            ),
          ),
        ),
        FeatureCard(
          title: 'Prayer Time',
          subtitle: 'Schedule reminders',
          icon: Icons.prayer_times,
          color: theme.colorScheme.secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PrayerScheduleScreen(),
            ),
          ),
        ),
        FeatureCard(
          title: 'Messages',
          subtitle: 'Track sermons & podcasts',
          icon: Icons.headphones,
          color: theme.colorScheme.tertiary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MessageTrackerScreen(),
            ),
          ),
        ),
        FeatureCard(
          title: 'Book Reading',
          subtitle: 'Track Christian books',
          icon: Icons.book,
          color: theme.colorScheme.primary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BookTrackerScreen(),
            ),
          ),
        ),
        FeatureCard(
          title: 'Spiritual Goals',
          subtitle: 'Set & track goals',
          icon: Icons.flag,
          color: theme.colorScheme.secondary,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GoalsProfileScreen(),
            ),
          ),
        ),
        FeatureCard(
          title: 'Daily Verse',
          subtitle: 'Today\'s inspiration',
          icon: Icons.quote,
          color: theme.colorScheme.tertiary,
          onTap: () => _loadTodaysVerse(),
        ),
      ],
    );
  }
}