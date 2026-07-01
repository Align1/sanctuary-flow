import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding state
class OnboardingService {
  static const String _onboardingCompleteKey = 'onboarding_completed';
  static const String _appFirstLaunchKey = 'app_first_launch_date';

  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
    
    // Save first launch date if not already set
    final firstLaunch = prefs.getString(_appFirstLaunchKey);
    if (firstLaunch == null) {
      await prefs.setString(
        _appFirstLaunchKey,
        DateTime.now().toIso8601String(),
      );
    }
  }

  /// Reset onboarding (for testing)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompleteKey);
  }

  /// Get app first launch date
  static Future<DateTime?> getFirstLaunchDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString(_appFirstLaunchKey);
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  /// Check if this is first app launch
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_appFirstLaunchKey) == null;
  }
}

