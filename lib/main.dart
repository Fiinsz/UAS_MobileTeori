import 'dart:async' show unawaited;
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_service.dart';
import 'core/services/firestore_service.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/santri/presentation/santri_list_page.dart';
import 'features/santri/presentation/santri_detail_page.dart';
import 'features/settings/presentation/settings_page.dart';
import 'features/admin/presentation/admin_home.dart';
import 'features/admin/presentation/admin_santri_page.dart';
import 'features/admin/presentation/admin_mapel_page.dart';
import 'features/admin/presentation/admin_bobot_page.dart';
import 'features/ustadz/presentation/ustadz_home.dart';
import 'features/ustadz/presentation/input_penilaian_page.dart';
import 'features/wali/presentation/wali_home.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/auth/presentation/pending_approval_page.dart';
import 'features/admin/presentation/admin_users_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase non-blocking; if not configured, the app still runs.
  unawaited(FirebaseService.init());
  // Seed initial data into Firestore (non-blocking). Safe to call multiple times due to merge.
  unawaited(FirestoreService.seedInitialData());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'e-Penilaian Santri',
          theme: lightTheme(),
          darkTheme: darkTheme(),
          themeMode: mode,
          initialRoute: '/',
          routes: {
            '/': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/pending-approval': (context) => const PendingApprovalPage(),
            // role homes
            '/home/admin': (context) => const AdminHomePage(),
            '/home/ustadz': (context) => const UstadzHomePage(),
            '/home/wali': (context) => const WaliHomePage(),
            // santri pages
            '/santri': (context) => const SantriListPage(),
            '/santri/detail': (context) => const SantriDetailPage(),
            '/admin/santri': (context) => const AdminSantriPage(),
            '/admin/mapel': (context) => const AdminMapelPage(),
            '/admin/bobot': (context) => const AdminBobotPage(),
            '/admin/users': (context) => const AdminUsersPage(),
            // ustadz
            '/ustadz/input': (context) => const InputPenilaianPage(),
            // settings
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}
