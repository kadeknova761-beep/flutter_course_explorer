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
    return data
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
