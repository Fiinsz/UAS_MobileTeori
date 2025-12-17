import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const DebugApp());
}

class DebugApp extends StatelessWidget {
  const DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'e-Penilaian Santri - Debug',
          theme: lightTheme(),
          darkTheme: darkTheme(),
          themeMode: mode,
          home: Scaffold(
            appBar: AppBar(title: const Text('Debug Home')),
            body: const Center(child: Text('DEBUG: app entrypoint works')),
          ),
        );
      },
    );
  }
}
