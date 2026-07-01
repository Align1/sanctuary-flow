import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

/// Centralized error handling utilities
class ErrorHandler {
  /// Convert any error to a user-friendly message
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) return 'An unexpected error occurred';

    // Supabase / Auth Errors
    final errorMessage = error.toString().toLowerCase();
    if (errorMessage.contains('user_already_exists') || 
        errorMessage.contains('already registered')) {
      return 'This email is already registered. Please try signing in instead.';
    }
    if (errorMessage.contains('invalid login credentials') || 
        errorMessage.contains('invalid_credentials')) {
      return 'Invalid email or password. Please check your details and try again.';
    }
    if (errorMessage.contains('email not confirmed')) {
      return 'Please check your email to confirm your account before signing in.';
    }
    if (errorMessage.contains('weak_password') || 
        errorMessage.contains('password should be')) {
      return 'Your password is too weak. Please use at least 6 characters.';
    }
    if (errorMessage.contains('invalid_email') || 
        errorMessage.contains('email address is invalid')) {
      return 'Please enter a valid email address.';
    }

    // Generic fallback
    if (error.toString().length > 100) {
      return 'An error occurred. Please try again or check your internet connection.';
    }

    return error.toString().replaceAll('AuthApiException:', '').trim();
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;

    final errorString = error.toString().toLowerCase();

    return errorString.contains('socketexception') ||
        errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('dns') ||
        errorString.contains('host') ||
        errorString.contains('unreachable') ||
        error is SocketException ||
        error is HttpException;
  }

  /// Retry a function with exponential backoff
  ///
  /// Example:
  /// ```dart
  /// final result = await ErrorHandler.retryWithBackoff(
  ///   () => fetchData(),
  ///   maxRetries: 5,
  ///   initialDelay: Duration(seconds: 1),
  /// );
  /// ```
  static Future<T?> retryWithBackoff<T>(
    Future<T> Function() fn, {
    int maxRetries = 5,
    Duration initialDelay = const Duration(seconds: 1),
    void Function(int attempt, dynamic error)? onRetry,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        return await fn();
      } catch (e) {
        attempt++;

        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(e)) {
          rethrow;
        }

        // If this was the last attempt, rethrow
        if (attempt >= maxRetries) {
          rethrow;
        }

        // Notify about retry
        onRetry?.call(attempt, e);

        // Wait with exponential backoff
        await Future.delayed(delay);

        // Double the delay for next attempt (capped at 30 seconds)
        delay = Duration(
          milliseconds: (delay.inMilliseconds * 2).clamp(0, 30000),
        );
      }
    }

    return null;
  }

  /// Show error snackbar with user-friendly message
  static void showErrorSnackbar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    final message = getUserFriendlyMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        showCloseIcon: true,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        showCloseIcon: true,
      ),
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
    );
  }

  /// Log error for debugging (can be extended for crash reporting)
  static void logError(
    String context,
    dynamic error, {
    StackTrace? stackTrace,
  }) {
    debugPrint('❌ ERROR [$context]: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }
}

/// Result wrapper for operations that can fail
class Result<T> {
  final T? data;
  final dynamic error;
  final bool isSuccess;

  Result.success(this.data)
      : error = null,
        isSuccess = true;

  Result.failure(this.error)
      : data = null,
        isSuccess = false;

  bool get isFailure => !isSuccess;

  /// Get data or throw error
  T getOrThrow() {
    if (isSuccess && data != null) {
      return data!;
    }
    throw error ?? Exception('Result has no data');
  }

  /// Get data or return default value
  T getOrDefault(T defaultValue) {
    return data ?? defaultValue;
  }

  /// Map result to another type
  Result<R> map<R>(R Function(T) mapper) {
    if (isSuccess && data != null) {
      try {
        return Result.success(mapper(data as T));
      } catch (e) {
        return Result.failure(e);
      }
    }
    return Result.failure(error);
  }
}
