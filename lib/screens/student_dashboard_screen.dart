import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  Map<String, dynamic>? _studentData;
  List<dynamic> _attendance = [];
  List<dynamic> _results = [];
  List<dynamic> _courses = [];
  bool _loading = true;
  String _uid = '';
  String _email = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _uid = args['uid'] ?? '';
    _email = args['email'] ?? '';
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      final profileResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/students/uid/$_uid'),
      );
      if (profileResponse.statusCode == 200) {
        final studentData = json.decode(profileResponse.body);
        setState(() => _studentData = studentData);

        final attendanceResponse = await http.get(
          Uri.parse('${ApiService.baseUrl}/attendance/student/${studentData['StudentID']}'),
        );
        if (attendanceResponse.statusCode == 200) {
          _attendance = json.decode(attendanceResponse.body);
        }

        final resultsResponse = await http.get(
          Uri.parse('${ApiService.baseUrl}/results/student/${studentData['StudentID']}'),
        );
        if (resultsResponse.statusCode == 200) {
          _results = json.decode(resultsResponse.body);
        }

        final coursesResponse = await http.get(
          Uri.parse('${ApiService.baseUrl}/courses'),
        );
        if (coursesResponse.statusCode == 200) {
          _courses = json.decode(coursesResponse.body);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    int present = _attendance.where((a) => a['Status'] == 'Present').length;
    int total = _attendance.length;
    double attendancePercent = total > 0 ? (present / total * 100) : 0;

    double avgMarks = 0;
    if (_results.isNotEmpty) {
      double sum = 0;
      for (var r in _results) {
        sum += (r['Marks'] ?? 0).toDouble();
      }
      avgMarks = sum / _results.length;
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_studentData?['Name'] ?? 'Student Dashboard'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Profile'),
              Tab(icon: Icon(Icons.event_available), text: 'Attendance'),
              Tab(icon: Icon(Icons.assessment), text: 'Results'),
              Tab(icon: Icon(Icons.book), text: 'Courses'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildProfileTab(),
                  _buildAttendanceTab(attendancePercent, present, total),
                  _buildResultsTab(avgMarks),
                  _buildCoursesTab(),
                ],
              ),
      ),
    );
  }

  // ==================== PROFILE TAB ====================
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              _studentData?['Name']?[0]?.toUpperCase() ?? '?',
              style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildInfoRow(Icons.person, 'Name', _studentData?['Name'] ?? 'N/A'),
                  const Divider(),
                  _buildInfoRow(Icons.email, 'Email', _email),
                  const Divider(),
                  _buildInfoRow(Icons.phone, 'Phone', _studentData?['Phone'] ?? 'N/A'),
                  const Divider(),
                  _buildInfoRow(Icons.business, 'Department', _studentData?['Department'] ?? 'N/A'),
                  const Divider(),
                  _buildInfoRow(Icons.location_on, 'Address', _studentData?['Address'] ?? 'N/A'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD64933),
                side: const BorderSide(color: Color(0xFFD64933)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ATTENDANCE TAB ====================
  Widget _buildAttendanceTab(double percent, int present, int total) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('Overall Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A2511))),
                  const SizedBox(height: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: total > 0 ? present / total : 0,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percent > 75 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      Text(
                        '${percent.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A2511)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('$present of $total classes attended',
                      style: const TextStyle(color: Color(0xFFA68A7A))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._attendance.map((a) {
            Color statusColor = a['Status'] == 'Present' ? Colors.green : Colors.red;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: statusColor, radius: 10),
                title: Text(a['CourseName'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${a['Date'] ?? ''}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(a['Status'] ?? '', style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==================== RESULTS TAB ====================
  Widget _buildResultsTab(double avgMarks) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('Average', '${avgMarks.toStringAsFixed(1)}', Icons.grade, const Color(0xFFFFB347)),
                  _buildMiniStat('Total', '${_results.length}', Icons.assessment, const Color(0xFF2196F3)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._results.map((r) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getGradeColor(r['Grade'] ?? ''),
                  child: Text(r['Grade'] ?? '?',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                title: Text(r['CourseName'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${r['ExamType'] ?? ''} • ${r['Semester'] ?? ''}'),
                trailing: Text('${r['Marks'] ?? 0}/100',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==================== COURSES TAB ====================
  Widget _buildCoursesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _courses.length,
      itemBuilder: (context, index) {
        final course = _courses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFFB347),
              child: Text(
                course['CourseName']?[0]?.toUpperCase() ?? '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(course['CourseName'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${course['CourseCode'] ?? ''} • ${course['Credits'] ?? 0} Credits'),
          ),
        );
      },
    );
  }

  // ==================== HELPER WIDGETS ====================
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF8C42)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFFA68A7A))),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF4A2511))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 36, color: color),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A2511))),
        Text(label, style: const TextStyle(color: Color(0xFFA68A7A), fontSize: 14)),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    return Colors.red;
  }
}