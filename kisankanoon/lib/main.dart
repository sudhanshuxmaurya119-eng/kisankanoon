import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kisankanoon/firebase_options.dart';
import 'package:kisankanoon/screens/login_screen.dart';
import 'package:kisankanoon/screens/main_scaffold.dart';
import 'package:kisankanoon/screens/register_screen.dart';
import 'package:kisankanoon/screens/splash_screen.dart';
import 'package:kisankanoon/services/app_language_service.dart';
import 'package:kisankanoon/services/app_theme_service.dart';
import 'package:kisankanoon/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AppLanguageService.load();
  await AppThemeService.load();
  SystemChrome.setSystemUIOverlayStyle(
    AppTheme.overlayStyleFor(AppThemeService.currentMode.value),
  );

  runApp(const AgriShieldApp());
}

class AgriShieldApp extends StatefulWidget {
  const AgriShieldApp({super.key});

  @override
  State<AgriShieldApp> createState() => _AgriShieldAppState();
}

class _AgriShieldAppState extends State<AgriShieldApp> {
  @override
  void initState() {
    super.initState();
    AppThemeService.currentMode.addListener(_handleThemeChanged);
  }

  @override
  void dispose() {
    AppThemeService.currentMode.removeListener(_handleThemeChanged);
    super.dispose();
  }

  void _handleThemeChanged() {
    SystemChrome.setSystemUIOverlayStyle(
      AppTheme.overlayStyleFor(AppThemeService.currentMode.value),
    );
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agri-Shield - किसान साथी',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: AppThemeService.currentMode.value,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainScaffold(),
      },
    );
  }
}
