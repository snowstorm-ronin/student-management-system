import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<dynamic> _students = [];
  List<dynamic> _courses = [];
  List<dynamic> _attendance = [];
  List<dynamic> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final students = await ApiService.getStudents();
      final courses = await ApiService.getCourses();
      final attendance = await ApiService.getAttendance();
      final results = await ApiService.getResults();
      setState(() {
        _students = students;
        _courses = courses;
        _attendance = attendance;
        _results = results;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalStudents = _students.length;
    final totalCourses = _courses.length;
    final totalAttendance = _attendance.length;
    final totalResults = _results.length;

    // Calculate average marks
    double avgMarks = 0;
    if (_results.isNotEmpty) {
      double sum = 0;
      for (var r in _results) {
        sum += (r['Marks'] ?? 0);
      }
      avgMarks = sum / _results.length;
    }

    // Calculate attendance percentage
    int presentCount = 0;
    for (var a in _attendance) {
      if (a['Status'] == 'Present') presentCount++;
    }
    double attendanceRate = _attendance.isNotEmpty ? (presentCount / _attendance.length * 100) : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Total Students', '$totalStudents', Icons.people, const Color(0xFFFF8C42)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Total Courses', '$totalCourses', Icons.book, const Color(0xFFFFB347)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Attendance Records', '$totalAttendance', Icons.event, const Color(0xFF4CAF50)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard('Results Entered', '$totalResults', Icons.assessment, const Color(0xFF2196F3)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Performance', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildReportRow('Average Marks', '${avgMarks.toStringAsFixed(1)}%', Icons.trending_up),
                          const Divider(),
                          _buildReportRow('Attendance Rate', '${attendanceRate.toStringAsFixed(1)}%', Icons.check_circle),
                          const Divider(),
                          _buildReportRow('Students per Course', (totalCourses > 0 ? (totalStudents / totalCourses).toStringAsFixed(1) : '0'), Icons.group),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Recent Students', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  ...(_students.take(5).map((s) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Text(s['Name']?[0]?.toUpperCase() ?? '?',
                            style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(s['Name'] ?? ''),
                      subtitle: Text('${s['Department'] ?? 'N/A'} • ${s['Email'] ?? ''}'),
                    ),
                  ))),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A2511))),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Color(0xFFA68A7A), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF8C42)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A2511))),
        ],
      ),
    );
  }
}