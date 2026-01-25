import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Production-safe logger that only logs in debug mode.
/// 
/// This prevents sensitive information from being logged in release builds
/// and improves production app performance.
/// 
/// Usage:
/// ```dart
/// AppLogger.d('Debug message');
/// AppLogger.i('Info message');
/// AppLogger.w('Warning message');
/// AppLogger.e('Error message', error: exception, stackTrace: stackTrace);
/// ```
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// Log debug message (only in debug mode)
  static void d(String message) {
    if (kDebugMode) {
      _logger.d(message);
    }
  }

  /// Log info message (only in debug mode)
  static void i(String message) {
    if (kDebugMode) {
      _logger.i(message);
    }
  }

  /// Log warning message (only in debug mode)
  static void w(String message) {
    if (kDebugMode) {
      _logger.w(message);
    }
  }

  /// Log error message (only in debug mode)
  static void e(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log fatal error message (only in debug mode)
  static void f(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      _logger.f(message, error: error, stackTrace: stackTrace);
    }
  }
}
