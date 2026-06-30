import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EditStudentScreen extends StatefulWidget {
  const EditStudentScreen({super.key});

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _departmentController;
  late final TextEditingController _addressController;
  bool _saving = false;
  late Map<String, dynamic> _student;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _student = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _nameController = TextEditingController(text: _student['Name'] ?? '');
    _emailController = TextEditingController(text: _student['Email'] ?? '');
    _phoneController = TextEditingController(text: _student['Phone'] ?? '');
    _departmentController = TextEditingController(text: _student['Department'] ?? '');
    _addressController = TextEditingController(text: _student['Address'] ?? '');
  }

  Future<void> _updateStudent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await ApiService.updateStudent(_student['StudentID'], {
        'Name': _nameController.text.trim(),
        'Email': _emailController.text.trim(),
        'Phone': _phoneController.text.trim(),
        'Department': _departmentController.text.trim(),
        'Address': _addressController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student updated!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Student')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)), validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              TextFormField(controller: _departmentController, decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(Icons.business))),
              const SizedBox(height: 16),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)), maxLines: 2),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _updateStudent,
                  child: _saving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Update Student', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}