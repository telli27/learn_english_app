import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'verification_screen.dart';
import '../../features/home/screens/main_screen.dart';

/// AuthWrapper checks the user's authentication status and directs to the appropriate screen:
/// - If not logged in: Login Screen
/// - If logged in but email not verified: Verification Screen
/// - If logged in and email verified: Main Screen
class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    // Check email verification status when widget initializes
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Add a slight delay to wait for Firebase auth state to be fully initialized
    await Future.delayed(const Duration(milliseconds: 800));

    // Check email verification status
    final authState = ref.read(authProvider);
    if (authState.isLoggedIn && !authState.isEmailVerified) {
      await ref.read(authProvider.notifier).checkEmailVerification();
    }

    // Mark initialization as complete
    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Show loading indicator while initialization or auth state check is in progress
    if (_isInitializing || authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If not logged in, show login screen
    if (!authState.isLoggedIn) {
      return const LoginScreen();
    }

    // If logged in but email not verified, show verification screen
    if (!authState.isEmailVerified) {
      return VerificationScreen(email: authState.email ?? '');
    }

    // If logged in and email verified, show main screen
    return const MainScreen();
  }
}
