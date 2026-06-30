import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<dynamic> _courses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      final courses = await ApiService.getCourses();
      setState(() {
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

  Future<void> _deleteCourse(int id) async {
    try {
      await ApiService.deleteCourse(id);
      _fetchCourses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted'), backgroundColor: Colors.green),
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

  void _showAddCourseDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final deptController = TextEditingController();
    final creditsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Course Name', hintText: 'e.g., Data Structures'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Course Code', hintText: 'e.g., CS202'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deptController,
                decoration: const InputDecoration(labelText: 'Department', hintText: 'e.g., Computer Science'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: creditsController,
                decoration: const InputDecoration(labelText: 'Credits', hintText: 'e.g., 3'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || codeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course name and code are required')),
                );
                return;
              }
              try {
                await ApiService.addCourse({
                  'CourseName': nameController.text.trim(),
                  'CourseCode': codeController.text.trim(),
                  'Department': deptController.text.trim(),
                  'Credits': int.tryParse(creditsController.text) ?? 3,
                });
                Navigator.pop(context);
                _fetchCourses();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Course added!'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Add Course'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCourses,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCourseDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No courses yet', style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFFFB347),
                          child: Text(
                            course['CourseName'] != null && course['CourseName'].isNotEmpty
                                ? course['CourseName'][0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(course['CourseName'] ?? 'No Name',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${course['CourseCode'] ?? 'N/A'} • ${course['Department'] ?? 'N/A'} • ${course['Credits'] ?? 0} Credits',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Color(0xFFD64933)),
                          onPressed: () => _deleteCourse(course['CourseID']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}