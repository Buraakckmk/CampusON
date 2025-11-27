import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/theme.dart';
import 'core/app_strings.dart';
import 'screens/welcome_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppLanguageController.languageNotifier,
      builder: (context, lang, _) {
        final strings = AppStrings(lang);
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: AppTheme.themeModeNotifier,
          builder: (context, mode, __) {
            return AppStringsProvider(
              strings: strings,
              child: MaterialApp(
                title: strings.appName,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: mode,
                home: FirebaseAuth.instance.currentUser != null
                    ? const HomeScreen()
                    : const WelcomeScreen(),
              ),
            );
          },
        );
      },
    );
  }
}
