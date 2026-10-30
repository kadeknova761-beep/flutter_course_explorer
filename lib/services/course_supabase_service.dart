// Tahap 12: SELECT dari Supabase
// Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase.from('courses').select().order('id');
    return (data as List)
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Tahap 13: INSERT ke Supabase
  // Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C
  @override
  Future<Course> createCourse(Course course) async {
    final row = await supabase
        .from('courses')
        .insert(course.toJson())
        .select()
        .single();
    return Course.fromJson(row);
  }

  // Tahap 14: UPDATE di Supabase
  // Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C
  @override
  Future<void> updateCourse(int id, Course course) async {
    await supabase.from('courses').update(course.toJson()).eq('id', id);
  }

  @override
  Future<void> deleteCourse(int id) => throw UnimplementedError();
}
