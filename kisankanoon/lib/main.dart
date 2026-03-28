import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kisankanoon/firebase_options.dart';
import 'package:kisankanoon/theme/app_theme.dart';
import 'package:kisankanoon/screens/splash_screen.dart';
import 'package:kisankanoon/screens/login_screen.dart';
import 'package:kisankanoon/screens/register_screen.dart';
import 'package:kisankanoon/screens/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase with explicit options from google-services.json
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const KisanKanoonApp());
}

class KisanKanoonApp extends StatelessWidget {
  const KisanKanoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KisanKanoon — किसान क़ानून',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
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
