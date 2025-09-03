import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/todos/presentation/home_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Show splash screen for 2 seconds, then initialize
    Future.delayed(const Duration(seconds: 2), () {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.refreshAuthState();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app resumes from background, refresh auth state
    // This helps catch OAuth redirects that might have completed
    if (state == AppLifecycleState.resumed) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.refreshAuthState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print(
          'AuthWrapper - Initialized: $_isInitialized, Loading: ${authProvider.isLoading}, User: ${authProvider.user?.email}',
        );

        // Show splash screen during initialization
        if (!_isInitialized) {
          print('AuthWrapper - Showing SplashScreen (initializing)');
          return const SplashScreen();
        }

        // Show splash screen during authentication loading
        if (authProvider.isLoading) {
          print('AuthWrapper - Showing SplashScreen (auth loading)');
          return const SplashScreen();
        }

        // Show home screen if user is authenticated
        if (authProvider.user != null) {
          print('AuthWrapper - User authenticated, showing HomeScreen');
          return const HomeScreen();
        }

        // Show auth choice screen if no user
        print('AuthWrapper - No user, showing AuthChoiceScreen');
        return const AuthChoiceScreen();
      },
    );
  }
}
