// Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C
// Tahap 12-15: CRUD Supabase | Tahap 17: error handling dasar

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final supabase = Supabase.instance.client;

  // Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C
  // Tahap 17: ubah error Supabase/jaringan menjadi pesan yang mudah dibaca
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PostgrestException catch (e) {
      switch (e.code) {
        case '42501':
          throw Exception('Akses ditolak oleh kebijakan database (RLS).');
        case '23514':
          throw Exception(
            'Data tidak valid: credits harus > 0 dan status planned/active/done.',
          );
        case 'PGRST205':
          throw Exception('Tabel tidak ditemukan di database.');
        default:
          throw Exception('Kesalahan database (${e.code}): ${e.message}');
      }
    } on http.ClientException {
      throw Exception(
        'Tidak dapat terhubung ke server. Periksa koneksi internet lalu coba lagi.',
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Tahap 12: SELECT dari Supabase
  @override
  Future<List<Course>> getCourses() => _guard(() async {
    final data = await supabase.from('courses').select().order('id');
    return (data as List)
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  });

  // Tahap 13: INSERT ke Supabase
  @override
  Future<Course> createCourse(Course course) => _guard(() async {
    final row = await supabase
        .from('courses')
        .insert(course.toJson())
        .select()
        .single();
    return Course.fromJson(row);
  });

  // Tahap 14: UPDATE di Supabase
  @override
  Future<void> updateCourse(int id, Course course) => _guard(() async {
    await supabase.from('courses').update(course.toJson()).eq('id', id);
  });

  // Tahap 15: DELETE course berdasarkan id di Supabase
  @override
  Future<void> deleteCourse(int id) => _guard(() async {
    await supabase.from('courses').delete().eq('id', id);
  });
}
