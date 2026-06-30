import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'student_list_screen.dart';
import 'courses_screen.dart';
import 'attendance_screen.dart';
import 'results_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Students', 'icon': Icons.people, 'screen': const StudentListScreen()},
    {'title': 'Courses', 'icon': Icons.book, 'screen': const CoursesScreen()},
    {'title': 'Attendance', 'icon': Icons.event_available, 'screen': const AttendanceScreen()},
    {'title': 'Results', 'icon': Icons.assessment, 'screen': const ResultsScreen()},
    {'title': 'Reports', 'icon': Icons.bar_chart, 'screen': const ReportsScreen()},
    {'title': 'Profile', 'icon': Icons.person, 'screen': const ProfileScreen()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            decoration: const BoxDecoration(
              color: Color(0xFFFF8C42),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo/Header
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.school, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white30),
                const SizedBox(height: 16),
                // Menu Items
                ..._menuItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = _selectedIndex == index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Material(
                      color: isSelected ? Colors.white.withAlpha(30) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _selectedIndex = index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                color: Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                // Logout Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text('Logout', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Main Content Area
          Expanded(
            child: Container(
              color: const Color(0xFFFFF8F0),
              child: _menuItems[_selectedIndex]['screen'] as Widget,
            ),
          ),
        ],
      ),
    );
  }
}