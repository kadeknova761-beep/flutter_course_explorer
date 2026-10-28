import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';

// Widget reusable yang menampilkan tiga kondisi data course dari
// CourseProvider: loading, error (dengan tombol coba lagi), dan success.
// Screen cukup mengisi builder untuk kondisi success.
class CourseStateGate extends StatelessWidget {
  final Widget Function(BuildContext context, List<Course> courses) builder;

  const CourseStateGate({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    // select(): widget ini hanya di-rebuild ketika status loading, error,
    // atau jumlah course berubah, bukan ketika favorite berubah.
    final (isLoading, error, count) = context
        .select<CourseProvider, (bool, String?, int)>(
          (p) => (p.isLoading, p.error, p.courses.length),
        );

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Memuat course...'),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 8),
              Text('Gagal memuat course', style: _titleStyle(context)),
              const SizedBox(height: 4),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                // read(): memanggil aksi, bukan menampilkan data.
                onPressed: () => context.read<CourseProvider>().loadCourses(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (count == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Belum ada data course'),
        ),
      );
    }

    return builder(context, context.read<CourseProvider>().courses);
  }

  TextStyle? _titleStyle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium;
  }
}
