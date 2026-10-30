import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';

// Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C
//
// Service bertanggung jawab pada detail teknis komunikasi dengan backend
// (request HTTP, status code, dan decode JSON). Screen dan Provider tidak
// boleh memakai http atau jsonDecode secara langsung.
class CourseApiService {
  CourseApiService(this.baseUrl);

  final String baseUrl;

  Future<List<Course>> getCourses() async {
    final response = await http.get(Uri.parse('$baseUrl/courses'));

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil course (HTTP ${response.statusCode})');
    }

    final List data = jsonDecode(response.body) as List;
    return data.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }

  // POST /courses: membuat course baru. id dibuat oleh server.
  Future<Course> createCourse(Course course) async {
    final response = await http.post(
      Uri.parse('$baseUrl/courses'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Course.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    final detail = _errorDetail(response.body);
    throw Exception(
      'Gagal membuat course (HTTP ${response.statusCode})'
      '${detail.isEmpty ? '' : ': $detail'}',
    );
  }

  // Mengambil pesan dari body error API: {"error": "...", "status": 400}.
  // Jika body bukan JSON yang diharapkan, kembalikan string kosong.
  String _errorDetail(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map && data['error'] is String) {
        return data['error'] as String;
      }
    } catch (_) {}
    return '';
  }
}
