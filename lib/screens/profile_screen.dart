import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      user?.email?[0].toUpperCase() ?? '?',
                      style: const TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Welcome Admin!', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(user?.email ?? 'No email',
                      style: const TextStyle(fontSize: 16, color: Color(0xFFA68A7A))),
                  const SizedBox(height: 32),
                  _buildInfoRow(Icons.email, 'Email', user?.email ?? 'N/A'),
                  const Divider(),
                  _buildInfoRow(Icons.verified_user, 'Role', 'Administrator'),
                  const Divider(),
                  _buildInfoRow(Icons.calendar_today, 'Member Since', '2026'),
                  const SizedBox(height: 32),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
}