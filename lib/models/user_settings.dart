class UserSettings {
  const UserSettings({
    this.reminderIntervalMinutes = defaultReminderIntervalMinutes,
    this.breakDurationMinutes = 5,
    this.quietHoursStart = '22:00',
    this.quietHoursEnd = '08:00',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
  });

  final int reminderIntervalMinutes;
  final int breakDurationMinutes;
  final String quietHoursStart;
  final String quietHoursEnd;
  final bool notificationsEnabled;
  final bool soundEnabled;

  static const defaultReminderIntervalMinutes = 55;
  static const minReminderIntervalMinutes = 30;
  static const maxReminderIntervalMinutes = 120;
  static const minBreakDurationMinutes = 1;
  static const maxBreakDurationMinutes = 10;

  UserSettings copyWith({
    int? reminderIntervalMinutes,
    int? breakDurationMinutes,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool? notificationsEnabled,
    bool? soundEnabled,
  }) {
    return UserSettings(
      reminderIntervalMinutes:
          reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'reminderIntervalMinutes': reminderIntervalMinutes,
      'breakDurationMinutes': breakDurationMinutes,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
    };
  }

  factory UserSettings.fromJson(Map<String, Object?> json) {
    return UserSettings(
      reminderIntervalMinutes:
          json['reminderIntervalMinutes'] as int? ??
          defaultReminderIntervalMinutes,
      breakDurationMinutes: json['breakDurationMinutes'] as int? ?? 5,
      quietHoursStart: json['quietHoursStart'] as String? ?? '22:00',
      quietHoursEnd: json['quietHoursEnd'] as String? ?? '08:00',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
    );
  }
}
