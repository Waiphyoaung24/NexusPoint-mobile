import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_config.dart';
import 'core/providers/dio_provider.dart';
import 'core/database/app_database.dart';

import 'core/theme/pos_theme.dart';
import 'features/auth/widgets/branch_selection_screen.dart';
import 'features/auth/widgets/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/shell/pos_shell.dart';

const _kLastApiOriginKey = 'last_api_origin';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppConfig.isLocal) {
    debugPrint('Running in LOCAL environment');
    debugPrint('API Origin: ${AppConfig.apiOrigin}');
  }

  // Clear local DB cache when switching between environments (local ↔ prod)
  // so stale data from one environment never bleeds into the other.
  await _clearCacheOnEnvironmentChange();

  final appDocDir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    storage: FileStorage("${appDocDir.path}/.cookies/"),
  );

  runApp(
    ProviderScope(
      overrides: [
        cookieJarProvider.overrideWithValue(cookieJar),
      ],
      child: const NexusPointPosApp(),
    ),
  );
}

/// Detects when `AppConfig.apiOrigin` changes (e.g. local → prod or vice-versa)
/// and wipes all Drift tables so the app never shows cached data from the
/// previous environment.
Future<void> _clearCacheOnEnvironmentChange() async {
  final prefs = await SharedPreferences.getInstance();
  final lastOrigin = prefs.getString(_kLastApiOriginKey);
  final currentOrigin = AppConfig.apiOrigin;

  if (lastOrigin != null && lastOrigin != currentOrigin) {
    debugPrint('🔄 API origin changed ($lastOrigin → $currentOrigin) — clearing local cache');
    final db = AppDatabase();
    try {
      await db.menuDao.deleteAll();
      await db.modifierDao.clearAll();
    } finally {
      await db.close();
    }
  }

  await prefs.setString(_kLastApiOriginKey, currentOrigin);
}

class NexusPointPosApp extends StatelessWidget {
  const NexusPointPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: PosTheme.lightTheme(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return authState.when(
      unauthenticated: () => const LoginScreen(),
      branchPending: (user, branches) => BranchSelectionScreen(
        user: user,
        branches: branches,
      ),
      authenticated: (user, _) => const PosShell(),
    );
  }
}
