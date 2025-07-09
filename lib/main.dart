// Riverpod durum yönetimi kütüphanesi
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:revenue_cat_integration/revenue_cat_integration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'core/providers.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/providers/locale_provider.dart';
import 'features/home/screens/main_screen.dart';
import 'core/utils/constants/theme.dart';
import 'core/data/grammar_data.dart';
import 'auth/screens/login_screen.dart';
import 'auth/screens/register_screen.dart';
import 'auth/screens/verification_screen.dart';
import 'auth/screens/auth_wrapper.dart';
import 'core/screens/no_internet_screen.dart';
import 'core/screens/loading_screen.dart';
import 'core/screens/weak_connection_screen.dart';
import 'features/settings/screens/terms_of_use_screen.dart';
import 'features/settings/screens/privacy_policy_screen.dart';
import 'features/settings/screens/language_selection_screen.dart';

Future<void> checkForUpdate() async {
  try {
    AppUpdateInfo info = await InAppUpdate.checkForUpdate();
    if (info.updateAvailability == UpdateAvailability.updateAvailable) {
      try {
        await InAppUpdate.performImmediateUpdate();
      } on Exception catch (e) {
        debugPrint(e.toString());
      }
    }
  } on Exception catch (e) {
    debugPrint(e.toString());
  }
}

Future<void> _configureRevenueCatSDK() async {
  await dotenv.load();
  final key = dotenv.env['REVEUNECAT_GOOGLE_API_KEY'] ?? '';

  await RevenueCatIntegrationService.instance.init(
    StoreConfig(
      entitlement: 'premium',
      configuration: PurchasesConfiguration(key),
    ),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Google Mobile Ads'i başlat
  await MobileAds.instance.initialize();

  // Load initial language data for app startup
  print("⚡ App starting, loading initial language data...");
  try {
    // Get saved locale or default to Turkish
    final prefs = await SharedPreferences.getInstance();
    final localeString = prefs.getString('selected_locale');
    String languageCode = 'tr'; // default

    if (localeString != null) {
      final parts = localeString.split('_');
      if (parts.isNotEmpty) {
        languageCode = parts[0];
      }
    }

    print("🌍 Loading data for language: $languageCode");
    await GrammarData.loadTopics(languageCode: languageCode);
    print("✅ Initial language data loaded successfully");
  } catch (e) {
    print("❌ Error loading initial language data: $e");
    // Continue anyway, data will be loaded later
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (Platform.isAndroid) {
    _configureRevenueCatSDK();
    checkForUpdate();
  }

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
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isInitializing = true;
  bool _topicsLoaded = false;
  bool _isWeakConnection = false;
  String _loadingMessage = 'İnternet bağlantısı kontrol ediliyor...';
  late DateTime _loadStartTime;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _loadStartTime = DateTime.now();

    // Give a moment for the connectivity provider to initialize
    await Future.delayed(Duration(seconds: 1));

    // Check connectivity
    final isConnected = ref.read(isConnectedProvider);

    if (!isConnected) {
      // If not connected, update the state and wait for connection
      setState(() {
        _isInitializing = false;
      });
      return;
    }

    // If connected, load topics
    setState(() {
      _loadingMessage = 'Konular yükleniyor...';
    });

    try {
      // Start a timer to check for slow loading
      _checkForSlowLoading();

      // Load topics here (if needed again)
      // await GrammarData.loadTopics();

      // Simulate loading time for testing
      // Comment this out in production
      // await Future.delayed(Duration(seconds: 5));
      if (GrammarData.topics.isEmpty) {
        // If topics are not loaded, force loading from GitHub
        debugPrint('Topics are empty, loading from GitHub...');
        // Get current language code from locale provider
        final currentLocale = ref.read(localeProvider);
        final languageCode = currentLocale.languageCode;
        debugPrint('Loading topics for language: $languageCode');
        await GrammarData.loadTopics(languageCode: languageCode);
      }
      setState(() {
        _topicsLoaded = true;
        _isInitializing = false;
        _isWeakConnection = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading topics: $e');
      }
      setState(() {
        _isInitializing = false;
        _isWeakConnection = true;
      });
    }
  }

  // Check if loading is taking too long, which may indicate a weak connection
  Future<void> _checkForSlowLoading() async {
    // Wait for 5 seconds
    await Future.delayed(Duration(seconds: 5));

    // If still initializing after 5 seconds, show weak connection screen
    if (_isInitializing && mounted) {
      setState(() {
        _isWeakConnection = true;
        _isInitializing = false;
      });
    }
  }

  // Reset app state and try loading again
  void _retryLoading() {
    setState(() {
      _isInitializing = true;
      _isWeakConnection = false;
      _topicsLoaded = false;
      _loadingMessage = 'Konular yükleniyor...';
    });

    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeControllerProvider);
    final connectivityStatus = ref.watch(connectivityProvider);
    final currentLocale = ref.watch(localeProvider);

    // Return a MaterialApp with the correct content based on connectivity
    return MaterialApp(
      title: 'Englitics-İngilizce Öğren',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', ''), // Turkish
        Locale('es', ''), // Spanish
        Locale('fr', ''), // French
        Locale('pt', ''), // Portuguese
        Locale('it', ''), // Italian
      ],
      home: connectivityStatus.when(
        data: (isConnected) {
          // If there's no internet, show no internet screen
          if (!isConnected) {
            return const NoInternetScreen();
          }

          // If showing weak connection warning
          if (_isWeakConnection) {
            return WeakConnectionScreen(onRetry: _retryLoading);
          }

          // If initializing, show loading screen
          if (_isInitializing) {
            return LoadingScreen(message: _loadingMessage);
          }

          // If topics are not loaded, try loading them again
          if (!_topicsLoaded) {
            _initializeApp();
            return LoadingScreen(message: 'Konular yükleniyor...');
          }

          // If everything is good, show the AuthWrapper that will handle auth flow
          return const MainScreen(); //AuthWrapper();
        },
        loading: () => const LoadingScreen(
            message: 'İnternet bağlantısı kontrol ediliyor...'),
        error: (_, __) => const NoInternetScreen(),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/terms_of_use': (context) => const TermsOfUseScreen(),
        '/privacy_policy': (context) => const PrivacyPolicyScreen(),
        '/verification': (context) => VerificationScreen(email: ''),
        '/language_selection': (context) => const LanguageSelectionScreen(),
      },
      onGenerateRoute: (settings) {
        /* if (settings.name == '/verification') {
      
          final email = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => VerificationScreen(email: email),
          );
        }*/
        return null;
      },
    );
  }
}
