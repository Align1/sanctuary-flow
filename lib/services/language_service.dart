import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage app language/locale
class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  static const String _languageKey = 'selected_language';
  final StreamController<Locale> _localeController = StreamController<Locale>.broadcast();
  String _currentCode = 'en';

  String get currentLanguageCode => _currentCode;

  /// Supported languages
  static const List<LanguageOption> supportedLanguages = [
    LanguageOption(code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
    LanguageOption(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    LanguageOption(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    LanguageOption(code: 'pt', name: 'Portuguese', nativeName: 'Português', flag: '🇧🇷'),
    LanguageOption(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
  ];

  /// Get stream of locale changes
  Stream<Locale> get localeStream => _localeController.stream;

  /// Get current locale
  Future<Locale> getCurrentLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      return Locale(languageCode);
    }
    
    // Default to English
    return const Locale('en');
  }

  /// Set locale
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    _currentCode = locale.languageCode;
    _localeController.add(locale);
  }

  /// Change language by code
  Future<void> changeLanguage(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  /// Get language name by code
  String getLanguageName(String code) {
    final language = supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages[0],
    );
    return language.name;
  }

  /// Get native language name by code
  String getNativeLanguageName(String code) {
    final language = supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages[0],
    );
    return language.nativeName;
  }

  /// Get language flag by code
  String getLanguageFlag(String code) {
    final language = supportedLanguages.firstWhere(
      (lang) => lang.code == code,
      orElse: () => supportedLanguages[0],
    );
    return language.flag;
  }

  /// Dispose resources
  void dispose() {
    _localeController.close();
  }
}

/// Language option model
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

