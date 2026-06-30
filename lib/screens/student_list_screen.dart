import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  List<dynamic> _students = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final students = await ApiService.getStudents();
      setState(() {
        _students = students;
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

  Future<void> _deleteStudent(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete student "$name"?'),
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
        await ApiService.deleteStudent(id);
        _fetchStudents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Student deleted'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchStudents,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add-student');
          if (result == true) _fetchStudents();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No students found', style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            student['Name'] != null && student['Name'].isNotEmpty
                                ? student['Name'][0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(student['Name'] ?? 'No Name', 
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${student['Department'] ?? 'N/A'} • ${student['Phone'] ?? 'N/A'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFFFFB347)),
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                  context,
                                  '/edit-student',
                                  arguments: student,
                                );
                                if (result == true) _fetchStudents();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color(0xFFD64933)),
                              onPressed: () => _deleteStudent(
                                student['StudentID'],
                                student['Name'] ?? '',
                              ),
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