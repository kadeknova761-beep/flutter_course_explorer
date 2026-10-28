import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_identity.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../utils/course_status.dart';
import '../widgets/course_state_gate.dart';

// Halaman yang hanya menampilkan course favorite. Data course dan daftar
// favorite dibaca dari CourseProvider (single source of truth).
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '$studentId - $studentName',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CourseStateGate(
              builder: (context, courses) => FavoritesList(courses: courses),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesList extends StatelessWidget {
  final List<Course> courses;

  const FavoritesList({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    // watch(): daftar ikut berubah ketika favorite ditambah atau dihapus.
    final provider = context.watch<CourseProvider>();
    debugPrint('[Rebuild] FavoritesPage - daftar (watch)');

    final favoriteCourses = courses
        .where((c) => provider.isFavorite(c.code))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${favoriteCourses.length} course favorite'),
        const SizedBox(height: 8),
        Expanded(
          child: favoriteCourses.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada course favorite. Tekan ikon hati pada daftar '
                    'course atau halaman detail.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: favoriteCourses.length,
                  itemBuilder: (context, index) {
                    final course = favoriteCourses[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          statusIcon(course.status),
                          color: statusColor(course.status),
                          size: 32,
                        ),
                        title: Text(course.title),
                        subtitle: Text(
                          '${course.code} - ${course.credits} SKS - '
                          '${statusLabel(course.status)}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Hapus dari favorite',
                          onPressed: () {
                            context.read<CourseProvider>().toggleFavorite(
                              course.code,
                            );
                          },
                          icon: const Icon(Icons.favorite, color: Colors.red),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
