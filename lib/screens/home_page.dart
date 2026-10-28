import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_identity.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../widgets/course_state_gate.dart';
import '../widgets/summary_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.badge, size: 36),
              title: Text(
                studentName,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('$studentId - $studentClass'),
            ),
          ),
          const SizedBox(height: 8),
          // Loading, error, dan success ditangani oleh CourseStateGate.
          CourseStateGate(
            builder: (context, courses) => HomeSummary(courses: courses),
          ),
        ],
      ),
    );
  }
}

// Bagian ringkasan yang bergantung pada data course dan favorite.
class HomeSummary extends StatelessWidget {
  final List<Course> courses;

  const HomeSummary({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    // watch(): ringkasan ikut berubah ketika favorite berubah.
    final provider = context.watch<CourseProvider>();
    debugPrint('[Rebuild] HomePage - ringkasan (watch)');

    final int totalCredits = courses.fold<int>(0, (sum, c) => sum + c.credits);
    final int doneCount = courses.where((c) => c.status == 'done').length;
    final favoriteCourses = courses
        .where((c) => provider.isFavorite(c.code))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SummaryCard(
              icon: Icons.menu_book,
              value: '${courses.length}',
              label: 'Materi',
            ),
            SummaryCard(
              icon: Icons.school,
              value: '$totalCredits',
              label: 'Total SKS',
            ),
            SummaryCard(
              icon: Icons.favorite,
              value: '${provider.favoriteCount}',
              label: 'Favorite',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('$doneCount dari ${courses.length} materi selesai'),
        const SizedBox(height: 16),
        const Text(
          'Course Favorit',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (favoriteCourses.isEmpty)
          const Text(
            'Belum ada favorite. Buka tab Courses lalu tekan ikon hati '
            'atau tombol Tambah ke Favorite di halaman detail.',
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in favoriteCourses)
                Chip(
                  avatar: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 18,
                  ),
                  label: Text(c.title),
                ),
            ],
          ),
      ],
    );
  }
}
