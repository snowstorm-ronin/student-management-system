import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _loading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Sign in with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;
      final email = userCredential.user!.email;

      print('User logged in: $email, UID: $uid'); // Debug

      // Check user role from MySQL
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/users/$uid'),
      );

      print('User API response: ${response.statusCode} - ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final role = userData['role'];
        print('User role: $role'); // Debug

        if (mounted) {
          if (role == 'admin') {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (role == 'student') {
            Navigator.pushReplacementNamed(context, '/student-dashboard', arguments: {
              'uid': uid,
              'email': email,
            });
          }
        }
      } else if (response.statusCode == 404) {
        // User not in MySQL - register as student
        print('User not found, registering as student'); // Debug
        await http.post(
          Uri.parse('${ApiService.baseUrl}/users/register'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'uid': uid,
            'email': email,
            'role': 'student',
          }),
        );
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/student-dashboard', arguments: {
            'uid': uid,
            'email': email,
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login failed'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Login error: $e'); // Debug
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school,
                    size: 72,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Student Management',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Sign In', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Admin: admin@test.com / 123456\nStudent: student@test.com / 123456',
                    style: const TextStyle(color: Color(0xFFA68A7A), fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}