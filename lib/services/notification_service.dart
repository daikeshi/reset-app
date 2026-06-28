import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/user_settings.dart';
import '../state/reset_app_state.dart';

class NotificationService implements ResetNotifications {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _breakReminderId = 1001;
  static const _channelId = 'break_reminders';
  static const _channelName = 'Break reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized || kIsWeb) {
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(settings: initializationSettings);
    _initialized = true;
  }

  @override
  Future<bool> requestAuthorization({required bool sound}) async {
    if (kIsWeb) {
      return false;
    }

    await initialize();

    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: sound);
    final macGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: sound);
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    return iosGranted ?? macGranted ?? androidGranted ?? true;
  }

  @override
  Future<void> scheduleBreakReminder(UserSettings settings) async {
    if (kIsWeb || settings.reminderIntervalMinutes <= 0) {
      return;
    }

    await initialize();
    await cancelAll();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Reminder alerts for taking healthy breaks.',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: settings.soundEnabled,
      ),
      iOS: DarwinNotificationDetails(presentSound: settings.soundEnabled),
      macOS: DarwinNotificationDetails(presentSound: settings.soundEnabled),
    );

    await _plugin.periodicallyShowWithDuration(
      id: _breakReminderId,
      title: 'Time for a break!',
      body: 'Stand up, stretch, and refresh your mind.',
      repeatDurationInterval: Duration(
        minutes: settings.reminderIntervalMinutes,
      ),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelAll() async {
    if (kIsWeb) {
      return;
    }

    await initialize();
    await _plugin.cancelAll();
  }
}
