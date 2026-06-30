import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // ==================== STUDENTS ====================
  static Future<List<dynamic>> getStudents() async {
    final response = await http.get(Uri.parse('$baseUrl/students'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load students');
  }

  static Future<Map<String, dynamic>> addStudent(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/students'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to add student');
  }

  static Future<void> updateStudent(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/students/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update student');
    }
  }

  static Future<void> deleteStudent(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/students/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete student');
    }
  }

  // ==================== COURSES ====================
  static Future<List<dynamic>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load courses');
  }

  static Future<Map<String, dynamic>> addCourse(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/courses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to add course');
  }

  static Future<void> deleteCourse(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/courses/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete course');
    }
  }

  // ==================== ATTENDANCE ====================
  static Future<List<dynamic>> getAttendance() async {
    final response = await http.get(Uri.parse('$baseUrl/attendance'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load attendance');
  }

  static Future<Map<String, dynamic>> markAttendance(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/attendance'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to mark attendance');
  }

  // ==================== RESULTS ====================
  static Future<List<dynamic>> getResults() async {
    final response = await http.get(Uri.parse('$baseUrl/results'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load results');
  }

  static Future<Map<String, dynamic>> addResult(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/results'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Failed to add result');
  }
}