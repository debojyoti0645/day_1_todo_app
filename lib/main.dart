import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_themes.dart';
import 'theme_provider.dart';
import 'font_size_provider.dart';
import 'screens/splash_screen.dart';
import 'providers/task_provider.dart';

void main() async {
  // Ensure Flutter widgets binding is initialized before using plugins
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for changes in ThemeProvider and FontSizeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    // Determine the text scale factor based on user preference
    double textScaleFactor;
    switch (fontSizeProvider.fontSizeOption) {
      case FontSizeOption.small:
        textScaleFactor = 0.85;
        break;
      case FontSizeOption.medium:
        textScaleFactor = 1.0;
        break;
      case FontSizeOption.large:
        textScaleFactor = 1.15;
        break;
    }

    return MaterialApp(
      title: 'My To-Do App',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      // Apply text scaling globally
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
