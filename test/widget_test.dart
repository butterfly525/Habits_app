import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habits_app/main.dart';

void main() {
  testWidgets('renders home screen title', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HabitsApp()));
    expect(find.text('Мои привычки'), findsOneWidget);
  });
}
