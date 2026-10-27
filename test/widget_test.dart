import 'package:flutter_ui_fundamentals/app.dart';
import 'package:flutter_ui_fundamentals/providers/course_provider.dart';
import 'package:flutter_ui_fundamentals/repositories/course_repository.dart';
import 'package:flutter_ui_fundamentals/services/course_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Nama: Kadek Nova Krisna Putra | NIM: 2415051117
//
// Smoke test: aplikasi dapat dibangun dengan Provider dan menampilkan
// halaman Home beserta tiga destinasi navigasi utama.
void main() {
  testWidgets('Course Explorer menampilkan Home dan navigasi utama', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => CourseProvider(CourseRepository(CourseService())),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Course Explorer - Home'), findsOneWidget);
    expect(find.text('Courses'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
