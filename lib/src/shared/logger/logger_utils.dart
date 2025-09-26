import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class Logger {
  static const String _name = 'VideoConferenceApp';
  static bool _logsEnabled = kDebugMode;

  static void enableLogs(bool enabled) {
    _logsEnabled = enabled;
  }

  static void write(String text, {bool isError = false}) {
    if (!_logsEnabled) return;

    Future.microtask(() {
      final String prefix = isError ? '❌ ERROR' : '📱 INFO';
      final String message = '** $prefix: $text';

      if (kDebugMode) {
        debugPrint(message);
      }

      developer.log(
        text,
        name: _name,
        level: isError ? LogLevel.error.index : LogLevel.info.index,
      );
    });
  }

  static void debug(String message, {String? tag}) {
    if (!_logsEnabled) return;

    final String finalMessage = tag != null ? '[$tag] $message' : message;
    developer.log(
      finalMessage,
      name: _name,
      level: LogLevel.debug.index,
    );

    if (kDebugMode) {
      debugPrint('🐛 DEBUG: $finalMessage');
    }
  }

  static void info(String message, {String? tag}) {
    if (!_logsEnabled) return;

    final String finalMessage = tag != null ? '[$tag] $message' : message;
    developer.log(
      finalMessage,
      name: _name,
      level: LogLevel.info.index,
    );

    if (kDebugMode) {
      debugPrint('ℹ️ INFO: $finalMessage');
    }
  }

  static void warning(String message, {String? tag}) {
    if (!_logsEnabled) return;

    final String finalMessage = tag != null ? '[$tag] $message' : message;
    developer.log(
      finalMessage,
      name: _name,
      level: LogLevel.warning.index,
    );

    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $finalMessage');
    }
  }

  static void error(String message,
      {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!_logsEnabled) return;

    final String finalMessage = tag != null ? '[$tag] $message' : message;
    developer.log(
      finalMessage,
      name: _name,
      level: LogLevel.error.index,
      error: error,
      stackTrace: stackTrace,
    );

    if (kDebugMode) {
      debugPrint('❌ ERROR: $finalMessage');
      if (error != null) {
        debugPrint('Error object: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  // WebRTC specific logging
  static void webrtc(String message, {String? peerId}) {
    if (!_logsEnabled) return;

    final String finalMessage =
        peerId != null ? '[WebRTC-$peerId] $message' : '[WebRTC] $message';
    info(finalMessage);
  }

  // Socket specific logging
  static void socket(String message, {String? event}) {
    if (!_logsEnabled) return;

    final String finalMessage =
        event != null ? '[Socket-$event] $message' : '[Socket] $message';
    info(finalMessage);
  }

  // Meeting specific logging
  static void meeting(String message, {String? meetingId}) {
    if (!_logsEnabled) return;

    final String finalMessage = meetingId != null
        ? '[Meeting-$meetingId] $message'
        : '[Meeting] $message';
    info(finalMessage);
  }

  // Performance logging
  static void performance(String operation, Duration duration) {
    if (!_logsEnabled) return;

    final String message = '$operation took ${duration.inMilliseconds}ms';
    info(message, tag: 'Performance');
  }

  // Network logging
  static void network(String message, {int? statusCode, String? url}) {
    if (!_logsEnabled) return;

    String finalMessage = message;
    if (statusCode != null) finalMessage += ' [Status: $statusCode]';
    if (url != null) finalMessage += ' [URL: $url]';

    info(finalMessage, tag: 'Network');
  }

  // Media logging (for audio/video operations)
  static void media(String message, {String? deviceId, String? mediaType}) {
    if (!_logsEnabled) return;

    String finalMessage = message;
    if (mediaType != null) finalMessage += ' [Type: $mediaType]';
    if (deviceId != null) finalMessage += ' [Device: $deviceId]';

    info(finalMessage, tag: 'Media');
  }
}
