import '../models/course.dart';

// Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C
//
// Kontrak sumber data course. Repository hanya bergantung pada kontrak ini,
// sehingga sumber data (REST API, Supabase, cache) bisa diganti tanpa
// mengubah repository, provider, maupun screen.
abstract class CourseDataSource {
  Future<List<Course>> getCourses();
  Future<Course> createCourse(Course course);
  Future<void> updateCourse(int id, Course course);
  Future<void> deleteCourse(int id);
}
