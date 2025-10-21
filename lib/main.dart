import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/user_preferences.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await UserPreferences.instance.init();
  runApp(const MedLabApp());
}

class MedLabApp extends StatelessWidget {
  const MedLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedLab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: UserPreferences.instance.isFirstLaunch()
          ? const WelcomeScreen()
          : const HomeScreen(),
    );
  }
}
