import 'dart:math';

enum ActivityType {
  stretch,
  walk,
  eyes,
  hydrate,
  workout,
  meditation;

  String get storageValue => name;

  String get label {
    switch (this) {
      case ActivityType.stretch:
        return 'Stretch';
      case ActivityType.walk:
        return 'Walk';
      case ActivityType.eyes:
        return 'Eyes';
      case ActivityType.hydrate:
        return 'Hydrate';
      case ActivityType.workout:
        return 'Workout';
      case ActivityType.meditation:
        return 'Meditation';
    }
  }

  String get icon {
    switch (this) {
      case ActivityType.stretch:
        return '🧘';
      case ActivityType.walk:
        return '🚶';
      case ActivityType.eyes:
        return '👀';
      case ActivityType.hydrate:
        return '💧';
      case ActivityType.workout:
        return '💪';
      case ActivityType.meditation:
        return '🧠';
    }
  }

  List<String> get suggestions {
    switch (this) {
      case ActivityType.stretch:
        return const [
          'Neck rolls: 5 each direction',
          'Shoulder shrugs: 10 reps',
          'Stand and reach for the ceiling',
          'Wrist circles: 10 each direction',
          'Seated spinal twist: 30 seconds each side',
        ];
      case ActivityType.walk:
        return const [
          'Get a glass of water',
          'Quick walk to the mailbox',
          'Walk to a window and look outside',
          'Take a lap around your space',
          'Step outside for fresh air',
        ];
      case ActivityType.eyes:
        return const [
          'Look 20ft away for 20 seconds',
          'Close your eyes for 1 minute',
          'Rub your palms together and place over eyes',
          'Blink rapidly 20 times',
          'Focus on a distant object for 30 seconds',
        ];
      case ActivityType.hydrate:
        return const [
          'Drink a full glass of water',
          'Make a cup of tea or coffee',
          'Refill your water bottle',
          'Drink a glass of warm water',
          'Add lemon to your water',
        ];
      case ActivityType.workout:
        return const [
          '10 pushups or 15 squats',
          '30-second plank',
          'Jumping jacks for 1 minute',
          'Lunges: 10 each leg',
          'Wall sit for 30 seconds',
        ];
      case ActivityType.meditation:
        return const [
          'Close your eyes, breathe for 1 min',
          'Box breathing: 4 counts in, hold, out',
          'Body scan: relax each muscle group',
          'Simply sit and enjoy the silence',
          'Listen to ambient sounds for 2 min',
        ];
    }
  }

  static ActivityType fromStorageValue(String value) {
    return ActivityType.values.firstWhere(
      (type) => type.storageValue == value,
      orElse: () => ActivityType.stretch,
    );
  }

  static ({ActivityType type, String suggestion}) randomSuggestion([
    Random? random,
  ]) {
    final source = random ?? Random();
    final type =
        ActivityType.values[source.nextInt(ActivityType.values.length)];
    final suggestions = type.suggestions;
    return (
      type: type,
      suggestion: suggestions[source.nextInt(suggestions.length)],
    );
  }
}
