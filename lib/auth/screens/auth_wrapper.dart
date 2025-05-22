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
  @override
  void initState() {
    super.initState();
    // Check email verification status when widget initializes
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    final authState = ref.read(authProvider);
    if (authState.isLoggedIn && !authState.isEmailVerified) {
      // If user is logged in but email is not verified, check verification status
      await ref.read(authProvider.notifier).checkEmailVerification();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Show loading indicator while checking auth state
    if (authState.isLoading) {
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
