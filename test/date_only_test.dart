import 'package:flutter_test/flutter_test.dart';
import 'package:habits_app/core/date_only.dart';

void main() {
  test('toDateKey normalizes time component', () {
    final date = DateTime(2026, 3, 11, 23, 59, 59);
    expect(toDateKey(date), '2026-03-11');
  });

  test('month boundaries are calculated correctly', () {
    final date = DateTime(2026, 2, 13);
    expect(monthStart(date), DateTime(2026, 2, 1));
    expect(monthEnd(date), DateTime(2026, 2, 28));
  });
}
