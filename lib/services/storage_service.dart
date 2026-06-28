import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/break_log.dart';
import '../models/user_settings.dart';
import '../state/reset_app_state.dart';

class StorageService implements ResetStorage {
  StorageService({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const _settingsKey = 'userSettings';
  static const _logsKey = 'breakLogs';

  @override
  Future<UserSettings> loadSettings() async {
    final encoded = await _preferences.getString(_settingsKey);
    if (encoded == null) {
      return const UserSettings();
    }

    try {
      final json = jsonDecode(encoded);
      if (json is Map<String, Object?>) {
        return UserSettings.fromJson(json);
      }
      if (json is Map) {
        return UserSettings.fromJson(Map<String, Object?>.from(json));
      }
    } catch (_) {
      return const UserSettings();
    }

    return const UserSettings();
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    await _preferences.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  @override
  Future<List<BreakLog>> loadBreakLogs() async {
    final encoded = await _preferences.getString(_logsKey);
    if (encoded == null) {
      return const [];
    }

    try {
      final json = jsonDecode(encoded);
      if (json is! List) {
        return const [];
      }

      return json
          .whereType<Map>()
          .map((item) => BreakLog.fromJson(Map<String, Object?>.from(item)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveBreakLogs(List<BreakLog> logs) async {
    final encoded = jsonEncode(logs.map((log) => log.toJson()).toList());
    await _preferences.setString(_logsKey, encoded);
  }
}
