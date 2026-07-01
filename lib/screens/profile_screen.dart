import 'package:flutter/material.dart';
import 'package:rooted/services/supabase_service.dart';
import 'package:rooted/services/gamification_service.dart';
import 'package:rooted/services/offline_verse_database.dart';
import 'package:rooted/services/leaderboard_service.dart';
import 'package:rooted/services/streak_service.dart';
import 'package:rooted/models/level.dart';
import 'package:rooted/models/challenge.dart';
import 'package:rooted/screens/auth_screen.dart';
import 'package:rooted/screens/reminder_settings_screen.dart';
import 'package:rooted/services/language_service.dart';
import 'package:rooted/services/theme_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SupabaseService _supabase = SupabaseService();
  bool _isLoading = true;
  User? _user;
  UserProgress? _progress;
  UserLevel? _level;
  int _rank = 0;
  int _streak = 0;
  Map<String, int> _dbStats = {};
  final LanguageService _languageService = LanguageService();
  final ThemeService _themeService = ThemeService();
  bool _autoSyncEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    try {
      _user = _supabase.currentUser;
      _progress = await GamificationService.getUserProgress();
      _level = await GamificationService.getCurrentLevel();
      _rank = await LeaderboardService.getUserRank();

      final streakData = await StreakService.getStreak();
      _streak = streakData.currentStreak;

      _dbStats = await OfflineVerseDatabase().getDatabaseStats();
      
      final prefs = await SharedPreferences.getInstance();
      _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? true;
    } catch (e) {
      debugPrint('Error loading profile data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(theme),
                  const SizedBox(height: 24),
                  _buildSyncCard(theme),
                  const SizedBox(height: 24),
                  _buildStatsGrid(theme),
                  const SizedBox(height: 32),
                  _buildSettingsSection(theme),
                  const SizedBox(height: 32),
                  _buildAccountSection(theme),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    final isGuest = _supabase.isGuest;
    final displayName = isGuest
        ? 'Guest'
        : (_user?.userMetadata?['full_name'] ??
            _user?.email?.split('@')[0] ??
            'User');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[200],
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '${_level?.level ?? 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            _level?.title ?? 'Seedling',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          _buildXPBar(theme),
        ],
      ),
    );
  }

  Widget _buildXPBar(ThemeData theme) {
    final currentXP = _level?.currentXP ?? 0;
    final nextXP = _level?.xpForNextLevel ?? 100;
    final progress = currentXP / nextXP;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'XP: $currentXP',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              'Next: $nextXP',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSyncCard(ThemeData theme) {
    final pendingSync = _dbStats['pending_sync'] ?? 0;
    final isSynced = pendingSync == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSynced ? Icons.cloud_done : Icons.cloud_sync,
            color: isSynced ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSynced ? 'Cloud Synced' : 'Syncing Data...',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isSynced
                      ? 'Your progress is backed up'
                      : '$pendingSync items pending sync',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (!isSynced)
            TextButton(
              onPressed: () {
                // Trigger sync manually if needed
                _loadAllData();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(theme, 'Streak', '$_streak', Icons.local_fire_department,
            Colors.orange),
        _buildStatCard(
            theme, 'Global Rank', '#$_rank', Icons.leaderboard, Colors.blue),
        _buildStatCard(theme, 'Verses', '${_dbStats['user_verses'] ?? 0}',
            Icons.menu_book, Colors.green),
        _buildStatCard(theme, 'Total XP', '${_progress?.totalXP ?? 0}',
            Icons.stars, Colors.amber),
      ],
    );
  }

  Widget _buildStatCard(
      ThemeData theme, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingsTile(
          theme,
          Icons.notifications_none,
          'Notifications',
          'Manage your daily reminders',
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReminderSettingsScreen(),
              ),
            );
          },
        ),
        _buildSettingsTile(
          theme,
          Icons.language,
          'Language',
          _languageService.getNativeLanguageName(_languageService.currentLanguageCode),
          () => _showLanguageDialog(),
        ),
        _buildSettingsTile(
          theme,
          Icons.sync,
          'Auto-Sync',
          'Keep data updated in cloud',
          () {},
          trailing: Switch(
            value: _autoSyncEnabled,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) async {
              setState(() => _autoSyncEnabled = value);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('auto_sync_enabled', value);
            },
          ),
        ),
        _buildSettingsTile(
          theme,
          Icons.dark_mode_outlined,
          'Appearance',
          'Light / Dark mode',
          () => _showThemeDialog(),
        ),
      ],
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageService.supportedLanguages.map((lang) {
            return ListTile(
              leading: Text(lang.flag, style: const TextStyle(fontSize: 24)),
              title: Text(lang.nativeName),
              subtitle: Text(lang.name),
              onTap: () async {
                await _languageService.changeLanguage(lang.code);
                if (mounted) Navigator.pop(context);
                setState(() {});
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Appearance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('System Default'),
              onTap: () async {
                await _themeService.setThemeMode(ThemeMode.system);
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Light Mode'),
              onTap: () async {
                await _themeService.setThemeMode(ThemeMode.light);
                if (mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              onTap: () async {
                await _themeService.setThemeMode(ThemeMode.dark);
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(ThemeData theme, IconData icon, String title,
      String subtitle, VoidCallback onTap,
      {Widget? trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildAccountSection(ThemeData theme) {
    final isGuest = _supabase.isGuest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (isGuest)
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              ).then((_) => _loadAllData());
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Register Account'),
          )
        else
          OutlinedButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text(
                      'Are you sure you want to sign out? Your local data will remain safe.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sign Out',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true) {
                await _supabase.signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                }
              }
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              side: const BorderSide(color: Colors.red),
              foregroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Sign Out'),
          ),
      ],
    );
  }
}
