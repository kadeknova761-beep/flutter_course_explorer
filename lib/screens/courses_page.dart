import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_identity.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../utils/course_status.dart';
import '../widgets/course_card.dart';
import '../widgets/course_state_gate.dart';
import 'course_detail_page.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  int columnsFor(double width) {
    if (width < 600) return 1;
    if (width < 840) return 2;
    return 3;
  }

  // Tap: buka detail. Course dikirim lewat constructor, sedangkan status
  // favorite dibaca halaman detail langsung dari CourseProvider.
  void openDetail(BuildContext context, Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseDetailPage(course: course)),
    );
  }

  // Long press: tampilkan info singkat course.
  void showInfo(BuildContext context, Course course) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Kode: ${course.code}'),
              Text('SKS: ${course.credits}'),
              Text('Status: ${statusLabel(course.status)}'),
              const SizedBox(height: 8),
              const Text('Dilihat oleh: $studentId - $studentName'),
              const SizedBox(height: 8),
              const Text('(Info ini muncul dari gesture long press)'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[Rebuild] CoursesPage (seluruh halaman)');

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '$studentId - $studentName',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          // Loading, error, dan success ditangani oleh CourseStateGate.
          child: CourseStateGate(
            builder: (context, courses) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final int columns = columnsFor(constraints.maxWidth);

                  return Column(
                    children: [
                      // Consumer: hanya teks ringkasan ini yang di-rebuild
                      // saat favorite berubah, bukan seluruh daftar.
                      Consumer<CourseProvider>(
                        builder: (context, provider, child) {
                          debugPrint(
                            '[Rebuild] CoursesPage - teks ringkasan (Consumer)',
                          );
                          return Text(
                            '${provider.favoriteCount} favorite | '
                            '$columns kolom | '
                            '${constraints.maxWidth.toStringAsFixed(0)} px',
                          );
                        },
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 120,
                              ),
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            final course = courses[index];

                            return CourseCard(
                              course: course,
                              onTap: () => openDetail(context, course),
                              onLongPress: () => showInfo(context, course),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
