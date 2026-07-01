import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Haptic feedback utility for providing tactile feedback
class HapticFeedbackHelper {
  static bool _hasVibrator = false;
  static bool _initialized = false;

  /// Initialize and check if device has vibrator
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      _hasVibrator = await Vibration.hasVibrator() ?? false;
      _initialized = true;
    } catch (e) {
      _hasVibrator = false;
      _initialized = true;
    }
  }

  /// Light haptic feedback for regular taps and interactions
  static Future<void> light() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Fail silently
    }
  }

  /// Medium haptic feedback for achievements and notifications
  static Future<void> medium() async {
    await initialize();
    
    try {
      if (_hasVibrator) {
        await Vibration.vibrate(duration: 50);
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      // Fail silently
    }
  }

  /// Heavy haptic feedback for major milestones
  static Future<void> heavy() async {
    await initialize();
    
    try {
      if (_hasVibrator) {
        await Vibration.vibrate(duration: 100);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Fail silently
    }
  }

  /// Success pattern for badge unlocks and completions
  static Future<void> success() async {
    await initialize();
    
    try {
      if (_hasVibrator) {
        // Success pattern: short-pause-short-pause-long
        await Vibration.vibrate(duration: 50);
        await Future.delayed(const Duration(milliseconds: 100));
        await Vibration.vibrate(duration: 50);
        await Future.delayed(const Duration(milliseconds: 100));
        await Vibration.vibrate(duration: 150);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Fail silently
    }
  }

  /// Error pattern for failures
  static Future<void> error() async {
    await initialize();
    
    try {
      if (_hasVibrator) {
        // Error pattern: long vibration
        await Vibration.vibrate(duration: 200);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Fail silently
    }
  }

  /// Selection feedback for picking items
  static Future<void> selection() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Fail silently
    }
  }
}
