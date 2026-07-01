import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rooted/theme.dart';
import 'package:rooted/screens/splash_screen.dart';
import 'package:rooted/services/home_widget_service.dart';
import 'package:rooted/services/connectivity_service.dart';
import 'package:rooted/services/sync_service.dart';
import 'package:rooted/services/offline_verse_database.dart';
import 'package:rooted/services/language_service.dart';
import 'package:rooted/services/gamification_service.dart';
import 'package:rooted/services/supabase_service.dart';
import 'package:rooted/services/theme_service.dart';
import 'package:rooted/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with a timeout so it never blocks the Flutter
  // service worker handshake (which times out after 4000ms on web).
  try {
    await SupabaseService.initialize()
        .timeout(const Duration(seconds: 3));
  } catch (e) {
    // Supabase failed or timed out – app continues in offline/guest mode.
    debugPrint('Supabase init skipped: $e');
  }

  // On web, skip heavy native-only initializations entirely so runApp()
  // is reached well within the 4-second service-worker deadline.
  if (!kIsWeb) {
    // Initialize offline database (sqflite – mobile only)
    await OfflineVerseDatabase().database;

    // Initialize connectivity monitoring
    await ConnectivityService().initialize();

    // Initialize sync service (includes auto-sync on connection restore)
    await SyncService().initialize();

    // Initialize home widgets
    await HomeWidgetService.initialize();

    // Refresh daily challenges on app start
    await GamificationService.refreshChallenges();
  } else {
    // On web: initialise connectivity in the background so runApp()
    // is never delayed by it.
    unawaited(ConnectivityService().initialize().catchError((_) {}));
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LanguageService _languageService = LanguageService();
  final ThemeService _themeService = ThemeService();
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    _loadTheme();
    _languageService.localeStream.listen((locale) {
      setState(() {
        _locale = locale;
      });
    });
    _themeService.themeStream.listen((mode) {
      setState(() {
        _themeMode = mode;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache the splash icon as early as possible
    precacheImage(const AssetImage('assets/icon/app_icon.png'), context);
  }

  Future<void> _loadLocale() async {
    final locale = await _languageService.getCurrentLocale();
    setState(() {
      _locale = locale;
    });
  }

  Future<void> _loadTheme() async {
    final mode = await _themeService.getThemeMode();
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rooted - Spiritual Growth',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      
      // Localization support
      locale: _locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('fr'), // French
        Locale('pt'), // Portuguese
        Locale('zh'), // Chinese
      ],
      
      // Start with splash screen (handles routing to onboarding or home)
      home: const SplashScreen(),
    );
  }
}
