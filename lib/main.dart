import 'dart:io';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:guardiao_cliente/controllers/global_setting_controller.dart';
import 'package:guardiao_cliente/controllers/theme_controller.dart';
import 'package:guardiao_cliente/firebase_options.dart';
import 'package:guardiao_cliente/repositories/entidade_militar_repository.dart';
import 'package:guardiao_cliente/services/localization_service.dart';
import 'package:guardiao_cliente/themes/app_theme.dart';
import 'package:guardiao_cliente/ui/splash_screen.dart';
import 'package:guardiao_cliente/utils/DarkThemeProvider.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'utils/Preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  if (Platform.isIOS) {
    TextInput.ensureInitialized();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await FirebaseAppCheck.instance.activate(
  //   appleProvider: AppleProvider.deviceCheck,
  //   androidProvider: AndroidProvider.debug
  // );

  tz.initializeTimeZones();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await Preferences.initPref();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Inicializa o ThemeController
    final ThemeController themeController = Get.put(ThemeController());

    FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DarkThemeProvider()),
      ],
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _closeKeyboard(context);
        },
        child: Obx(() {
          return GetMaterialApp(
            smartManagement: SmartManagement.full,
            initialBinding: BindingsBuilder(() {
              Get.put(GlobalSettingController()); // Inicializa o controlador global
            }),
            title: 'Guardião Cliente',
            navigatorObservers: [observer],
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme, // Tema Claro
            darkTheme: AppTheme.darkTheme, // Tema Escuro
            themeMode: themeController.themeMode.value, // Define o tema atual
            builder: (context, child) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  // Não desfoca ao clicar fora
                  FocusManager.instance.primaryFocus?.requestFocus();
                },
                child: child,
              );
            },
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('pt', 'BR')],
            fallbackLocale: LocalizationService.locale,
            translations: LocalizationService(),
            home: const SplashScreen(),
          );
        }),
      ),
    );
  }

  void _closeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      currentFocus.unfocus();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
