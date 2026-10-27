import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../widgets/summary_card.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<Map<String, dynamic>> courses;

  const HomePage({super.key, required this.student, required this.courses});

  @override
  Widget build(BuildContext context) {
    // watch(): mendengarkan perubahan sehingga HomePage di-rebuild
    // setiap CourseProvider memanggil notifyListeners().
    final provider = context.watch<CourseProvider>();
    final favorites = provider.favorites;
    debugPrint('[Rebuild] HomePage (watch)');

    final int totalCredits = courses.fold<int>(
      0,
      (sum, c) => sum + (c['credits'] as int),
    );
    final int doneCount = courses.where((c) => c['status'] == 'done').length;
    final favoriteCourses = courses
        .where((c) => favorites.contains(c['code']))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge, size: 36),
              title: Text(
                student['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${student['nim']} - ${student['kelas']}'),
            ),
          ),
          const SizedBox(height: 8),
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
                value: '${favorites.length}',
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
                    label: Text(c['title'] as String),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
