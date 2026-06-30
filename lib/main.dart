import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/student_list_screen.dart';
import 'screens/add_student_screen.dart';
import 'screens/edit_student_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/results_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/courses_screen.dart';

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
    return MaterialApp(
      title: 'Student Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFF8C42),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFFF8C42),
          onPrimary: Colors.white,
          secondary: Color(0xFFFFB347),
          onSecondary: Color(0xFF4A2511),
          error: Color(0xFFD64933),
          onError: Colors.white,
          surface: Color(0xFFFFF3E6),
          onSurface: Color(0xFF4A2511),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF8C42),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF8C42),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFF3E6),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF8C42)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF8C42), width: 2),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Color(0xFF4A2511),
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: Color(0xFF4A2511)),
          bodyMedium: TextStyle(color: Color(0xFFA68A7A)),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/student-dashboard': (context) => const StudentDashboardScreen(),
        '/students': (context) => const StudentListScreen(),
        '/add-student': (context) => const AddStudentScreen(),
        '/edit-student': (context) => const EditStudentScreen(),
        '/attendance': (context) => const AttendanceScreen(),
        '/results': (context) => const ResultsScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/courses': (context) => const CoursesScreen(),
      },
    );
  }
}