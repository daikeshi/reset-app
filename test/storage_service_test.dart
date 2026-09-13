import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reset/models/activity_type.dart';
import 'package:reset/models/break_log.dart';
import 'package:reset/services/storage_service.dart';

class MemoryPreferences implements SharedPreferencesAsync {
  final values = <String, String>{};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('a malformed log does not discard valid saved history', () async {
    final preferences = MemoryPreferences();
    final storage = StorageService(preferences: preferences);
    final log = BreakLog(
      id: 'valid',
      timestamp: DateTime(2026, 9, 13, 12),
      activityType: ActivityType.walk,
      durationSeconds: 60,
      completed: true,
    );
    preferences.values['breakLogs'] = jsonEncode([
      log.toJson(),
      {'timestamp': 123, 'completed': 'invalid'},
      log.toJson(),
    ]);
    expect(await storage.loadBreakLogs(), [log, log]);
  });
}
