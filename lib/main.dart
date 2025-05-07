// Riverpod durum yönetimi kütüphanesi
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/providers.dart';
import 'features/home/screens/main_screen.dart';
import 'core/utils/constants/theme.dart';
import 'core/data/grammar_data.dart';
import 'auth/screens/login_screen.dart';
import 'auth/screens/register_screen.dart';
import 'auth/screens/verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Dilbilgisi verilerini JSON dosyasından yükle
  await GrammarData.loadTopics();

  runApp(
    // ProviderScope: Riverpod provider'larını tüm uygulamada erişilebilir kılar
    // Tüm Riverpod uygulamaları için gereklidir
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// ConsumerWidget: Riverpod provider'larını kullanmak için özel widget sınıfı
// Normal StatelessWidget yerine kullanılır ve WidgetRef alır
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'Englitics-İngilizce Öğren',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/verification') {
          final email = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => VerificationScreen(email: email),
          );
        }
        return null;
      },
    );
  }
}
