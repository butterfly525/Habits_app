import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

final isDarkThemeProvider = Provider<bool>((ref) {
  return ref.watch(themeModeProvider) == ThemeMode.dark;
});

class ThemeModeToggleButton extends ConsumerWidget {
  const ThemeModeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkThemeProvider);
    return IconButton(
      tooltip: isDark ? 'Светлая тема' : 'Темная тема',
      onPressed: () {
        ref.read(themeModeProvider.notifier).state =
            isDark ? ThemeMode.light : ThemeMode.dark;
      },
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
    );
  }
}

ThemeData buildCyberpunkLightTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF00BCD4),
    onPrimary: Color(0xFF04131A),
    secondary: Color(0xFFFF2A6D),
    onSecondary: Colors.white,
    error: Color(0xFFD81B60),
    onError: Colors.white,
    surface: Color(0xFFF9F2FF),
    onSurface: Color(0xFF1A1133),
    primaryContainer: Color(0xFFB6F6FF),
    onPrimaryContainer: Color(0xFF002E36),
    secondaryContainer: Color(0xFFFFD6E7),
    onSecondaryContainer: Color(0xFF4F0A25),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF7F4FF),
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFF1A1133),
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.72),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0x5500BCD4)),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ).copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: scheme.onSurface,
        height: 1.3,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: const BorderSide(color: Color(0x9900BCD4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF2A6D),
      foregroundColor: Colors.white,
    ),
  );
}

ThemeData buildCyberpunkDarkTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF00F6FF),
    onPrimary: Color(0xFF001518),
    secondary: Color(0xFFFF4FD8),
    onSecondary: Color(0xFF22001A),
    error: Color(0xFFFF6B8B),
    onError: Color(0xFF2A0010),
    surface: Color(0xFF100726),
    onSurface: Color(0xFFF3EFFF),
    primaryContainer: Color(0xFF00343A),
    onPrimaryContainer: Color(0xFF96FAFF),
    secondaryContainer: Color(0xFF3E123F),
    onSecondaryContainer: Color(0xFFFFD8F7),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF090312),
  );

  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Color(0xFFF7F1FF),
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xCC160A30),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0x6600F6FF)),
      ),
    ),
    textTheme: base.textTheme.apply(
      bodyColor: const Color(0xFFF3EFFF),
      displayColor: const Color(0xFFF3EFFF),
    ).copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFFE4D9FF),
        height: 1.3,
      ),
    ),
    dividerColor: const Color(0x5530F7FF),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: const BorderSide(color: Color(0xAA00F6FF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF4FD8),
      foregroundColor: Color(0xFF22001A),
    ),
  );
}

class CyberpunkBackground extends StatelessWidget {
  const CyberpunkBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF080312),
                  Color(0xFF120B2B),
                  Color(0xFF071B26),
                ]
              : const [
                  Color(0xFFF9F4FF),
                  Color(0xFFE7FCFF),
                  Color(0xFFFFECF5),
                ],
        ),
      ),
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(
                  lineColor: isDark
                      ? const Color(0x2200F6FF)
                      : const Color(0x2200BCD4),
                ),
              ),
            ),
            Positioned(
              top: -80,
              right: -40,
              child: _GlowOrb(
                color: isDark ? const Color(0x33FF4FD8) : const Color(0x44FF2A6D),
                size: 240,
              ),
            ),
            Positioned(
              bottom: -90,
              left: -50,
              child: _GlowOrb(
                color: isDark ? const Color(0x3300F6FF) : const Color(0x4400BCD4),
                size: 260,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({
    required this.lineColor,
  });

  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    const step = 36.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}
