import 'package:flutter_ui_fundamentals/app.dart';
import 'package:flutter_ui_fundamentals/models/course.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Nama: Kadek Nova Krisna Putra | NIM: 2415051117
//
// Smoke test: aplikasi dapat dibangun dengan Provider dan menampilkan
// halaman Home beserta tiga destinasi navigasi utama. Service palsu dipakai
// agar tes tidak memanggil jaringan.
class FakeCourseApiService extends CourseApiService {
  FakeCourseApiService() : super('http://fake.local');

  @override
  Future<List<Course>> getCourses() async => const [
    Course(id: 1, code: 'MOB01', title: 'Git dan GitHub', credits: 2),
    Course(id: 2, code: 'MOB02', title: 'Dart', credits: 3, status: 'active'),
    Course(id: 3, code: 'MOB03', title: 'Widget', credits: 3, status: 'done'),
  ];
}

void main() {
  testWidgets('Course Explorer menampilkan Home dan navigasi utama', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) =>
            CourseProvider(CourseRepository(FakeCourseApiService()))
              ..loadCourses(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Course Explorer - Home'), findsOneWidget);
    expect(find.text('Courses'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
