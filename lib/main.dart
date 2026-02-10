import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'core/providers/dio_provider.dart';

import 'core/theme/pos_theme.dart';
import 'features/auth/widgets/login_screen.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/shell/pos_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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

class NexusPointPosApp extends StatelessWidget {
  const NexusPointPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexusPoint POS',
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
      authenticated: (user, _) => const PosShell(),
    );
  }
}
