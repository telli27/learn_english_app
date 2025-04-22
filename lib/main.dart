// Riverpod durum yönetimi kütüphanesi
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'features/home/screens/main_screen.dart';
import 'core/utils/constants/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    // ref.watch: Provider'ı dinler ve değişikliklerde UI'ı otomatik günceller
    // themeControllerProvider'daki değişiklikler widget'ın yeniden yapılanmasını tetikler
    final themeMode = ref.watch(themeControllerProvider);

    return MaterialApp(
      title: 'İngilizce Öğrenme',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode, // Provider'dan alınan tema modu
      home: const MainScreen(),
    );
  }
}
