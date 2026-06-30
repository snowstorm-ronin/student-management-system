import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  List<dynamic> _results = [];
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
      final results = await ApiService.getResults();
      final students = await ApiService.getStudents();
      final courses = await ApiService.getCourses();
      setState(() {
        _results = results;
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

  String _calculateGrade(int marks) {
    if (marks >= 90) return 'A+';
    if (marks >= 80) return 'A';
    if (marks >= 70) return 'B+';
    if (marks >= 60) return 'B';
    if (marks >= 50) return 'C';
    if (marks >= 40) return 'D';
    return 'F';
  }

  Color _getGradeColor(String grade) {
    if (grade.startsWith('A')) return Colors.green;
    if (grade.startsWith('B')) return Colors.blue;
    if (grade.startsWith('C')) return Colors.orange;
    return Colors.red;
  }

  Future<void> _deleteResult(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Delete this result record?'),
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
        final url = Uri.parse('http://localhost:3000/api/results/$id');
        final response = await http.delete(
          url,
          headers: {'Content-Type': 'application/json'},
        );
        if (response.statusCode == 200) {
          await _fetchData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Result deleted!'), backgroundColor: Colors.green),
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

  void _showEditResultDialog(Map<String, dynamic> result) {
    int? selectedStudent = result['StudentID'];
    int? selectedCourse = result['CourseID'];
    final marksController = TextEditingController(text: result['Marks']?.toString() ?? '');
    final semesterController = TextEditingController(text: result['Semester'] ?? '');
    final examTypeController = TextEditingController(text: result['ExamType'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Result'),
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
                  controller: marksController,
                  decoration: const InputDecoration(labelText: 'Marks (0-100)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: examTypeController,
                  decoration: const InputDecoration(labelText: 'Exam Type'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: semesterController,
                  decoration: const InputDecoration(labelText: 'Semester', hintText: 'e.g., Sem 3'),
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
                if (selectedStudent == null || selectedCourse == null || marksController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                final marks = int.parse(marksController.text);
                try {
                  final url = Uri.parse('http://localhost:3000/api/results/${result['ResultID']}');
                  final response = await http.put(
                    url,
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      'StudentID': selectedStudent,
                      'CourseID': selectedCourse,
                      'Marks': marks,
                      'Grade': _calculateGrade(marks),
                      'Semester': semesterController.text,
                      'ExamType': examTypeController.text,
                    }),
                  );
                  if (response.statusCode == 200) {
                    Navigator.pop(ctx);
                    _fetchData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Result updated!'), backgroundColor: Colors.green),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddResultDialog() {
    int? selectedStudent;
    int? selectedCourse;
    final marksController = TextEditingController();
    final semesterController = TextEditingController();
    final examTypeController = TextEditingController(text: 'Mid-Term');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Result'),
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
                  controller: marksController,
                  decoration: const InputDecoration(labelText: 'Marks (0-100)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: examTypeController,
                  decoration: const InputDecoration(labelText: 'Exam Type'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: semesterController,
                  decoration: const InputDecoration(labelText: 'Semester', hintText: 'e.g., Sem 3'),
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
                if (selectedStudent == null || selectedCourse == null || marksController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                final marks = int.parse(marksController.text);
                try {
                  await ApiService.addResult({
                    'StudentID': selectedStudent,
                    'CourseID': selectedCourse,
                    'Marks': marks,
                    'Grade': _calculateGrade(marks),
                    'Semester': semesterController.text,
                    'ExamType': examTypeController.text,
                  });
                  Navigator.pop(ctx);
                  _fetchData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Result added!'), backgroundColor: Colors.green),
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
        title: const Text('Results'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddResultDialog,
        icon: const Icon(Icons.add_chart),
        label: const Text('Add Result'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assessment_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No results yet', style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    final grade = result['Grade'] ?? 'N/A';
                    final gradeColor = _getGradeColor(grade);
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: gradeColor,
                          child: Text(
                            grade,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        title: Text(result['StudentName'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${result['CourseName'] ?? 'N/A'} • ${result['ExamType'] ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${result['Marks'] ?? 0}/100',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(result['Semester'] ?? '',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFFFFB347), size: 20),
                              onPressed: () => _showEditResultDialog(result),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color(0xFFD64933), size: 20),
                              onPressed: () => _deleteResult(result['ResultID']),
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