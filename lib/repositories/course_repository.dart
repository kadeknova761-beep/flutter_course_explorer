import '../models/course.dart';
import '../services/course_api_service.dart';

// Nama: Kadek Nova Krisna Putra | NIM: 2415051117
//
// Repository menjadi lapisan antara state/business logic (Provider) dan
// sumber data (Service). Provider cukup memanggil repository tanpa perlu tahu
// apakah data berasal dari JSON, REST API, atau database lokal.
class CourseRepository {
  final CourseApiService service;

  // Dependency diterima lewat constructor sehingga mudah diganti.
  CourseRepository(this.service);

  Future<List<Course>> getCourses() {
    return service.getCourses();
  }
}
