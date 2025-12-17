import 'package:flutter/material.dart';

const Color _primaryGreen = Color(0xFF0F9D58);
const Color _accentBlue = Color(0xFF0B7FFF);

final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.light);

ThemeData lightTheme() {
  final base = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(seedColor: _primaryGreen, brightness: Brightness.light).copyWith(secondary: _accentBlue),
    textTheme: Typography.material2021().black,
  );

  return base.copyWith(
    useMaterial3: true,
    appBarTheme: base.appBarTheme.copyWith(backgroundColor: _primaryGreen, foregroundColor: Colors.white, elevation: 2),
    cardTheme: base.cardTheme.copyWith(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: _accentBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(backgroundColor: _accentBlue),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}

ThemeData darkTheme() {
  final base = ThemeData.from(
    colorScheme: ColorScheme.fromSeed(seedColor: _primaryGreen, brightness: Brightness.dark).copyWith(secondary: _accentBlue),
    textTheme: Typography.material2021().white,
  );

  return base.copyWith(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0B1320),
    appBarTheme: base.appBarTheme.copyWith(backgroundColor: const Color(0xFF06292E), foregroundColor: Colors.white, elevation: 1),
    cardTheme: base.cardTheme.copyWith(color: const Color(0xFF071427), elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: _accentBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))),
    floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(backgroundColor: _accentBlue),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  );
}
