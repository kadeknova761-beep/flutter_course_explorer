import '../models/course.dart';
import '../services/course_data_source.dart';

// Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C
//
// Repository menjadi kontrak yang dipakai Provider. Ia hanya mengenal
// CourseDataSource, bukan implementasi konkret (REST API, Supabase, dan lain-lain).
class CourseRepository {
  CourseRepository(this.dataSource);

  final CourseDataSource dataSource;

  Future<List<Course>> getCourses() => dataSource.getCourses();

  Future<Course> createCourse(Course course) => dataSource.createCourse(course);

  Future<void> updateCourse(int id, Course course) =>
      dataSource.updateCourse(id, course);

  Future<void> deleteCourse(int id) => dataSource.deleteCourse(id);
}
