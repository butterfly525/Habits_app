class StatCard {
  const StatCard({
    required this.id,
    required this.habitId,
    required this.position,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int habitId;
  final int position;
  final DateTime createdAt;
  final DateTime updatedAt;
}
