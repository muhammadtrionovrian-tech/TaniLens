import 'package:flutter/material.dart';
import 'screens/main_shell.dart';
import 'theme/app_colors.dart';

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tani Lens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto', // Premium modern default sans-serif font
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppColors.background,
          iconTheme: IconThemeData(color: AppColors.textDark),
        ),
      ),
      home: const MainShell(),
    );
  }
}
