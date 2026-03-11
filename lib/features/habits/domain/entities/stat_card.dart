enum StatCardType {
  empty,
  streak,
  progressPercent,
  daysCompleted,
  daysRemaining,
  note,
}

extension StatCardTypeX on StatCardType {
  String get dbValue {
    switch (this) {
      case StatCardType.empty:
        return 'empty';
      case StatCardType.streak:
        return 'streak';
      case StatCardType.progressPercent:
        return 'progress_percent';
      case StatCardType.daysCompleted:
        return 'days_completed';
      case StatCardType.daysRemaining:
        return 'days_remaining';
      case StatCardType.note:
        return 'note';
    }
  }

  String get title {
    switch (this) {
      case StatCardType.empty:
        return 'Пустая карточка';
      case StatCardType.streak:
        return 'Дней подряд';
      case StatCardType.progressPercent:
        return 'Прогресс';
      case StatCardType.daysCompleted:
        return 'Дней всего';
      case StatCardType.daysRemaining:
        return 'Дней до конца';
      case StatCardType.note:
        return 'Заметка';
    }
  }

  static StatCardType fromDbValue(String value) {
    switch (value) {
      case 'streak':
        return StatCardType.streak;
      case 'progress_percent':
        return StatCardType.progressPercent;
      case 'days_completed':
        return StatCardType.daysCompleted;
      case 'days_remaining':
        return StatCardType.daysRemaining;
      case 'note':
        return StatCardType.note;
      case 'empty':
      default:
        return StatCardType.empty;
    }
  }
}

class StatCard {
  const StatCard({
    required this.id,
    required this.habitId,
    required this.position,
    required this.type,
    required this.noteText,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int habitId;
  final int position;
  final StatCardType type;
  final String noteText;
  final DateTime createdAt;
  final DateTime updatedAt;
}
