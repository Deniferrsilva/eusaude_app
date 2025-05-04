import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart'; // <-- IMPORTADO
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await NotificationService.init();
  runApp(EuSaudeApp());
}


class EuSaudeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EuSaúde',
      theme: ThemeData(
        primaryColor: Color(0xFF1565C0), // azul principal
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1565C0), // tom azul institucional
          secondary: Color(0xFF64B5F6), // azul mais claro
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1565C0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0)),
          bodyMedium: TextStyle(fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1565C0)),
            borderRadius: BorderRadius.circular(8),
          ),
          prefixIconColor: Color(0xFF1565C0),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
