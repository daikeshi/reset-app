import 'activity_type.dart';

class BreakLog {
  const BreakLog({
    required this.id,
    required this.timestamp,
    required this.activityType,
    required this.durationSeconds,
    required this.completed,
  });

  final String id;
  final DateTime timestamp;
  final ActivityType activityType;
  final int durationSeconds;
  final bool completed;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'activityType': activityType.storageValue,
      'durationSeconds': durationSeconds,
      'completed': completed,
    };
  }

  factory BreakLog.fromJson(Map<String, Object?> json) {
    return BreakLog(
      id: json['id'] as String? ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      activityType: ActivityType.fromStorageValue(
        json['activityType'] as String? ?? '',
      ),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BreakLog &&
            id == other.id &&
            timestamp == other.timestamp &&
            activityType == other.activityType &&
            durationSeconds == other.durationSeconds &&
            completed == other.completed;
  }

  @override
  int get hashCode {
    return Object.hash(id, timestamp, activityType, durationSeconds, completed);
  }
}
