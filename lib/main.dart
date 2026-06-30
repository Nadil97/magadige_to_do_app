import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set mock mode to true as we are running completely locally
  AuthService.enableMockMode();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magadige To-Do',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeView(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const HomeView();
        }
        return const LoginView();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.accentCyan,
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Initialization Error: $err'),
        ),
      ),
    );
  }
}
