import 'package:flutter/material.dart';

/// AyuColors — derived from measured logo palette (docs/AYUCARE_DESIGN_SYSTEM.md).
/// Logo samples: bg #0A1513, emerald #346748, jade #358F4D, sage #678F61,
/// antique gold #867A4D, champagne #C6BA90, ivory #E6EFCA, moss #324B2E.
class AyuColors {
  static const deepForest = Color(0xFF0A1513);
  static const primaryGreen = Color(0xFF2F5D3A);
  static const emerald = Color(0xFF346748);
  static const jade = Color(0xFF358F4D);
  static const sage = Color(0xFF678F61);
  static const tealSage = Color(0xFF6C9E85);
  static const moss = Color(0xFF324B2E);
  static const antiqueGold = Color(0xFF867A4D);
  static const champagne = Color(0xFFC6BA90);
  static const ivory = Color(0xFFE6EFCA);
  static const cream = Color(0xFFF5F2E6);
  static const ink = Color(0xFF1C2620);
}

class AyuSpacing {
  static const xs = 4.0;
  static const s = 8.0;
  static const m = 16.0;
  static const l = 24.0;
  static const xl = 32.0;
}

class AyuRadius {
  static const s = 8.0;
  static const m = 14.0;
  static const l = 20.0;
  static const pill = 999.0;
}

ThemeData ayuLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AyuColors.primaryGreen,
    surface: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AyuColors.cream,
    colorScheme: scheme.copyWith(
      primary: AyuColors.primaryGreen,
      secondary: AyuColors.antiqueGold,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14, height: 1.55),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AyuRadius.m),
        side: BorderSide(color: AyuColors.primaryGreen.withValues(alpha: 0.12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AyuColors.primaryGreen,
        shape: const StadiumBorder(),
        minimumSize: const Size(48, 48),
      ),
    ),
  );
}

ThemeData ayuDarkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AyuColors.tealSage,
    brightness: Brightness.dark,
    surface: const Color(0xFF122019),
  );
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AyuColors.deepForest,
    colorScheme: scheme.copyWith(
      primary: AyuColors.tealSage,
      secondary: AyuColors.champagne,
    ),
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14, height: 1.55),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF122019),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AyuRadius.m),
        side: BorderSide(color: AyuColors.tealSage.withValues(alpha: 0.25)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        minimumSize: const Size(48, 48),
      ),
    ),
  );
}
