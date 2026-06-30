import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<dynamic> _attendance = [];
  List<dynamic> _students = [];
  List<dynamic> _courses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final attendance = await ApiService.getAttendance();
      final students = await ApiService.getStudents();
      final courses = await ApiService.getCourses();
      setState(() {
        _attendance = attendance;
        _students = students;
        _courses = courses;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteAttendance(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Delete this attendance record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final url = Uri.parse('http://localhost:3000/api/attendance/$id');
        final response = await http.delete(
          url,
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          await _fetchData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance deleted!'), backgroundColor: Colors.green),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete. Status: ${response.statusCode}'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showMarkAttendanceDialog() {
    int? selectedStudent;
    int? selectedCourse;
    String status = 'Present';
    final dateController = TextEditingController(text: DateTime.now().toString().split(' ')[0]);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Mark Attendance'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int?>(
                  value: selectedStudent,
                  decoration: const InputDecoration(labelText: 'Select Student'),
                  items: _students.map((s) => DropdownMenuItem<int?>(
                    value: s['StudentID'] as int?,
                    child: Text(s['Name'] ?? ''),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => selectedStudent = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: selectedCourse,
                  decoration: const InputDecoration(labelText: 'Select Course'),
                  items: _courses.map((c) => DropdownMenuItem<int?>(
                    value: c['CourseID'] as int?,
                    child: Text(c['CourseName'] ?? ''),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => selectedCourse = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: ['Present', 'Absent', 'Late'].map((s) => DropdownMenuItem<String>(
                    value: s,
                    child: Text(s),
                  )).toList(),
                  onChanged: (v) => setDialogState(() => status = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedStudent == null || selectedCourse == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select student and course')),
                  );
                  return;
                }
                try {
                  await ApiService.markAttendance({
                    'StudentID': selectedStudent,
                    'CourseID': selectedCourse,
                    'Date': dateController.text,
                    'Status': status,
                  });
                  Navigator.pop(ctx);
                  _fetchData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attendance marked!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showMarkAttendanceDialog,
        icon: const Icon(Icons.check_circle),
        label: const Text('Mark Attendance'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _attendance.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No attendance records', style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _attendance.length,
                  itemBuilder: (context, index) {
                    final record = _attendance[index];
                    Color statusColor;
                    switch (record['Status']) {
                      case 'Present':
                        statusColor = Colors.green;
                        break;
                      case 'Absent':
                        statusColor = Colors.red;
                        break;
                      case 'Late':
                        statusColor = Colors.orange;
                        break;
                      default:
                        statusColor = Colors.grey;
                    }
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: statusColor,
                          child: Text(
                            record['Status']?[0] ?? '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(record['StudentName'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${record['CourseName'] ?? 'N/A'} • ${record['Date'] ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                record['Status'] ?? '',
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color(0xFFD64933), size: 20),
                              onPressed: () => _deleteAttendance(record['AttendanceID']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}