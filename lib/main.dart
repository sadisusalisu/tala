import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/story_provider.dart';
import 'providers/audio_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hlltirbbjqveolypyxdx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsbHRpcmJianF2ZW9seXB5eGR4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDgzNDg3NTYsImV4cCI6MjA2MzkyNDc1Nn0.mAjxQFjlJm_NOPLCShJaWkLeIVO7d8q8ph8u3WoJU1g',
  );

  runApp(const TalaApp());
}

class TalaApp extends StatelessWidget {
  const TalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'TALA',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              fontFamily: 'Comic Sans MS',
              brightness: Brightness.light,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                brightness: Brightness.light,
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.purple,
              fontFamily: 'Comic Sans MS',
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.purple,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: ThemeMode.system,
            home: const HomeScreen(),
            locale: Locale(languageProvider.currentLanguage),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}