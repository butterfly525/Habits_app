import 'habit.dart';
import 'habit_completion.dart';
import 'stat_card.dart';

class HabitDetailsView {
  const HabitDetailsView({
    required this.habit,
    required this.completions,
    required this.statCards,
  });

  final Habit habit;
  final List<HabitCompletion> completions;
  final List<StatCard> statCards;
}
