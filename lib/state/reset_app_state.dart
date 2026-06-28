import 'dart:async';

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

  UserSettings get settings => _settings;
  List<BreakLog> get breakLogs => List.unmodifiable(_breakLogs);
  bool get isLoaded => _isLoaded;

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
      final yesterday = cursor.subtract(const Duration(days: 1));
      if ((completedByDay[yesterday] ?? 0) >= 3) {
        cursor = yesterday;
      } else {
        return 0;
      }
    }

    var streak = 0;
    while ((completedByDay[cursor] ?? 0) >= 3) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
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

    await notifications.initialize();
    if (_settings.notificationsEnabled) {
      await notifications.scheduleBreakReminder(_settings);
    }
  }

  void logCompletedBreak(ActivityType type, {required int durationSeconds}) {
    _logBreak(
      BreakLog(
        id: _newLogId(),
        timestamp: _now(),
        activityType: type,
        durationSeconds: durationSeconds,
        completed: true,
      ),
    );
  }

  void logSkippedBreak(ActivityType type) {
    _logBreak(
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
    _settings = _settings.copyWith(reminderIntervalMinutes: minutes);
    await _saveSettingsAndReschedule();
  }

  Future<void> setBreakDuration(int minutes) async {
    _settings = _settings.copyWith(breakDurationMinutes: minutes);
    await _saveSettings();
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    var nextEnabled = enabled;
    if (enabled) {
      final granted =
          await _notifications?.requestAuthorization(
            sound: _settings.soundEnabled,
          ) ??
          false;
      nextEnabled = granted;
    } else {
      await _notifications?.cancelAll();
    }

    _settings = _settings.copyWith(notificationsEnabled: nextEnabled);
    await _saveSettingsAndReschedule();
    return nextEnabled;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _settings = _settings.copyWith(soundEnabled: enabled);
    await _saveSettingsAndReschedule();
  }

  void _logBreak(BreakLog log) {
    _breakLogs = [log, ..._breakLogs];
    unawaited(_saveLogs());
  }

  Future<void> _saveSettingsAndReschedule() async {
    await _saveSettings();
    if (_settings.notificationsEnabled) {
      await _notifications?.scheduleBreakReminder(_settings);
    }
  }

  Future<void> _saveSettings() async {
    await _storage?.saveSettings(_settings);
  }

  Future<void> _saveLogs() async {
    await _storage?.saveBreakLogs(_breakLogs);
  }

  String _newLogId() => _now().microsecondsSinceEpoch.toString();

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
