import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'core/cyberpunk_theme.dart';
import 'features/habits/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _configureDatabaseFactory();
  runApp(const ProviderScope(child: HabitsApp()));
}

void _configureDatabaseFactory() {
  if (kIsWeb) {
    return;
  }

  final isDesktop = defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS;

  if (!isDesktop) {
    return;
  }

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

class HabitsApp extends ConsumerWidget {
  const HabitsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Habits App',
      debugShowCheckedModeBanner: false,
      theme: buildCyberpunkLightTheme(),
      darkTheme: buildCyberpunkDarkTheme(),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
