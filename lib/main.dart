import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/auth/auth_screen.dart';
import 'utils/brand_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase only if not already initialized
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase already initialized, continue
    print('Firebase already initialized: $e');
  }
  
  runApp(const ResourcelyApp());
}

class ResourcelyApp extends StatelessWidget {
  const ResourcelyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resourcely',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: BrandColors.royalBlue,
        scaffoldBackgroundColor: BrandColors.lightSurface,
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: BrandColors.textDark,
          ),
          displayMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: BrandColors.textDark,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: BrandColors.textDark,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: BrandColors.textDark,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: BrandColors.textDark,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: BrandColors.textSecondary,
          ),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}