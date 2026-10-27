import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_identity.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../utils/course_status.dart';

// Halaman yang hanya menampilkan course favorite. Data course dan daftar
// favorite dibaca dari CourseProvider (single source of truth).
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    debugPrint('[Rebuild] FavoritesPage (watch)');

    final favoriteCourses = provider.courses
        .where((c) => provider.isFavorite(c.code))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$studentId - $studentName',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('${favoriteCourses.length} course favorite'),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(context, provider, favoriteCourses)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CourseProvider provider,
    List<Course> favoriteCourses,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => context.read<CourseProvider>().loadCourses(),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (favoriteCourses.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada course favorite. Tekan ikon hati pada daftar course '
          'atau halaman detail.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
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
                context.read<CourseProvider>().toggleFavorite(course.code);
              },
              icon: const Icon(Icons.favorite, color: Colors.red),
            ),
          ),
        );
      },
    );
  }
}
