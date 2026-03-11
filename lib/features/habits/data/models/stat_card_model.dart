import '../../domain/entities/stat_card.dart';

class StatCardModel {
  const StatCardModel({
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

  StatCard toEntity() {
    return StatCard(
      id: id,
      habitId: habitId,
      position: position,
      type: type,
      noteText: noteText,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory StatCardModel.fromMap(Map<String, Object?> map) {
    return StatCardModel(
      id: map['id'] as int,
      habitId: map['habit_id'] as int,
      position: map['position'] as int,
      type: StatCardTypeX.fromDbValue(map['type'] as String? ?? 'empty'),
      noteText: map['note_text'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
