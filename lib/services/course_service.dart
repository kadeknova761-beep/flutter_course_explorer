import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/course.dart';

// Nama: Kadek Nova Krisna Putra | NIM: 2415051117
//
// Service bertanggung jawab pada detail teknis sumber data. Saat ini sumbernya
// adalah file JSON di assets; nanti bisa diganti API tanpa mengubah screen.
class CourseService {
  static const String _assetPath = 'assets/data/student_data.json';

  Future<List<Course>> loadCourses() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final list = data['courses'] as List<dynamic>;

    return list.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }
}
