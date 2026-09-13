import 'dart:developer' as developer;

import '../models/activity_type.dart';
import '../models/break_log.dart';
import '../models/user_settings.dart';

abstract class ResetStorage {
  Future<UserSettings> loadSettings();
  Future<void> saveSettings(UserSettings settings);
  Future<List<BreakLog>> loadBreakLogs();
  Future<void> saveBreakLogs(List<BreakLog> logs);
}

abstract class ResetNotifications {
  Future<void> initialize();
  Future<bool> requestAuthorization({required bool sound});
  Future<void> scheduleBreakReminder(UserSettings settings);
  Future<void> cancelAll();
}

class ResetAppState {
  ResetAppState({
    required ResetStorage storage,
    required ResetNotifications notifications,
    DateTime Function()? now,
  }) : _storage = storage,
       _notifications = notifications,
       _now = now ?? DateTime.now;

  ResetAppState.test({
    DateTime Function()? now,
    List<BreakLog> logs = const [],
    UserSettings settings = const UserSettings(),
  }) : _storage = null,
       _notifications = null,
       _now = now ?? DateTime.now,
       _settings = settings,
       _breakLogs = List.of(logs);

  final ResetStorage? _storage;
  final ResetNotifications? _notifications;
  final DateTime Function() _now;

  UserSettings _settings = const UserSettings();
  List<BreakLog> _breakLogs = [];
  bool _isLoaded = false;
  String? _notificationError;
  int _logSequence = 0;
  DateTime? _focusDeadline;

  UserSettings get settings => _settings;
  List<BreakLog> get breakLogs => List.unmodifiable(_breakLogs);
  bool get isLoaded => _isLoaded;
  DateTime get now => _now();
  String? get notificationError => _notificationError;
  DateTime? get focusDeadline => _focusDeadline;
  bool get isFocusing => _focusDeadline != null;

  Future<void> startFocus() async {
    if (isFocusing) return;
    _focusDeadline = _now().add(
      Duration(minutes: _settings.reminderIntervalMinutes),
    );
    await restartReminders();
  }

  Future<void> stopFocus() async {
    _focusDeadline = null;
    await restartReminders();
  }

  int get breaksToday {
    final today = _dateOnly(_now());
    return _breakLogs
        .where((log) => log.completed && _dateOnly(log.timestamp) == today)
        .length;
  }

  int get breaksThisWeek {
    final cutoff = _now().subtract(const Duration(days: 7));
    return _breakLogs
        .where((log) => log.completed && log.timestamp.isAfter(cutoff))
        .length;
  }

  int get totalBreaks => _breakLogs.length;

  int get totalMinutes {
    return _breakLogs.fold<int>(
      0,
      (total, log) => total + (log.durationSeconds ~/ 60),
    );
  }

  int get currentStreak {
    final completedByDay = <DateTime, int>{};
    for (final log in _breakLogs.where((log) => log.completed)) {
      final day = _dateOnly(log.timestamp);
      completedByDay[day] = (completedByDay[day] ?? 0) + 1;
    }

    var cursor = _dateOnly(_now());
    if ((completedByDay[cursor] ?? 0) < 3) {
      final yesterday = DateTime(cursor.year, cursor.month, cursor.day - 1);
      if ((completedByDay[yesterday] ?? 0) >= 3) {
        cursor = yesterday;
      } else {
        return 0;
      }
    }

    var streak = 0;
    while ((completedByDay[cursor] ?? 0) >= 3) {
      streak += 1;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return streak;
  }

  Map<ActivityType, int> get activityBreakdown {
    final breakdown = <ActivityType, int>{};
    for (final log in _breakLogs.where((log) => log.completed)) {
      breakdown[log.activityType] = (breakdown[log.activityType] ?? 0) + 1;
    }
    return breakdown;
  }

  Future<void> initialize() async {
    final storage = _storage;
    final notifications = _notifications;
    if (storage == null || notifications == null) {
      _isLoaded = true;
      return;
    }

    final loadedSettings = await storage.loadSettings();
    final loadedLogs = await storage.loadBreakLogs();
    _settings = loadedSettings;
    _breakLogs = loadedLogs;
    _isLoaded = true;

    try {
      await notifications.initialize();
      if (_settings.notificationsEnabled) {
        final granted = await notifications.requestAuthorization(
          sound: _settings.soundEnabled,
        );
        if (!granted) {
          await _updateSettings(
            _settings.copyWith(notificationsEnabled: false),
          );
        }
      }
      await restartReminders();
    } catch (error, stackTrace) {
      await _handleNotificationFailure(error, stackTrace);
    }
  }

  Future<void> logCompletedBreak(
    ActivityType type, {
    required int durationSeconds,
  }) {
    return _logBreak(
      BreakLog(
        id: _newLogId(),
        timestamp: _now(),
        activityType: type,
        durationSeconds: durationSeconds,
        completed: true,
      ),
    );
  }

  Future<void> logSkippedBreak(ActivityType type) {
    return _logBreak(
      BreakLog(
        id: _newLogId(),
        timestamp: _now(),
        activityType: type,
        durationSeconds: 0,
        completed: false,
      ),
    );
  }

  Future<void> setReminderInterval(int minutes) async {
    await _updateSettings(
      _settings.copyWith(
        reminderIntervalMinutes: minutes.clamp(
          UserSettings.minReminderIntervalMinutes,
          UserSettings.maxReminderIntervalMinutes,
        ),
      ),
    );
    if (isFocusing) {
      _focusDeadline = _now().add(
        Duration(minutes: _settings.reminderIntervalMinutes),
      );
    }
    await restartReminders();
  }

  Future<void> setBreakDuration(int minutes) async {
    await _updateSettings(
      _settings.copyWith(
        breakDurationMinutes: minutes.clamp(
          UserSettings.minBreakDurationMinutes,
          UserSettings.maxBreakDurationMinutes,
        ),
      ),
    );
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    var nextEnabled = enabled;
    if (enabled) {
      try {
        nextEnabled =
            await _notifications?.requestAuthorization(
              sound: _settings.soundEnabled,
            ) ??
            false;
      } catch (error, stackTrace) {
        await _handleNotificationFailure(error, stackTrace);
        return false;
      }
    }

    await _updateSettings(
      _settings.copyWith(notificationsEnabled: nextEnabled),
    );
    await restartReminders();
    return _settings.notificationsEnabled;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    if (enabled && _settings.notificationsEnabled) {
      try {
        await _notifications?.requestAuthorization(sound: true);
      } catch (error, stackTrace) {
        await _handleNotificationFailure(error, stackTrace);
        return;
      }
    }
    await _updateSettings(_settings.copyWith(soundEnabled: enabled));
    await restartReminders();
  }

  Future<void> _logBreak(BreakLog log) async {
    _breakLogs = [log, ..._breakLogs];
    try {
      await _storage?.saveBreakLogs(_breakLogs);
    } catch (_) {
      _breakLogs = _breakLogs.where((entry) => entry.id != log.id).toList();
      rethrow;
    }
  }

  Future<void> restartReminders() async {
    _notificationError = null;
    try {
      if (_settings.notificationsEnabled && isFocusing) {
        await _notifications?.scheduleBreakReminder(_settings);
      } else {
        await _notifications?.cancelAll();
      }
    } catch (error, stackTrace) {
      await _handleNotificationFailure(error, stackTrace);
    }
  }

  Future<void> _updateSettings(UserSettings settings) async {
    await _storage?.saveSettings(settings);
    _settings = settings;
  }

  Future<void> _handleNotificationFailure(
    Object error,
    StackTrace stackTrace,
  ) async {
    developer.log(
      'Could not configure break reminders',
      name: 'Reset',
      error: error,
      stackTrace: stackTrace,
    );
    _notificationError = 'Reminders are unavailable. Try enabling them again.';
    _settings = _settings.copyWith(notificationsEnabled: false);
    try {
      await _notifications?.cancelAll();
    } catch (_) {
      // A failed notification service must not prevent local use of the app.
    }
    try {
      await _storage?.saveSettings(_settings);
    } catch (saveError, saveStack) {
      developer.log(
        'Could not save reminder preference',
        name: 'Reset',
        error: saveError,
        stackTrace: saveStack,
      );
    }
  }

  String _newLogId() => '${_now().microsecondsSinceEpoch}-${_logSequence++}';

  static DateTime _dateOnly(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
