// Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import 'error_view.dart';

// Widget reusable yang menampilkan empat kondisi data course dari
// CourseProvider: loading, error (ErrorView + Retry), empty, dan success.
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

    // 1. Loading
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

    // 2. Error: pesan + tombol Retry. read() dipakai karena hanya
    // memanggil aksi, bukan menampilkan data.
    if (error != null) {
      return ErrorView(
        message: error.replaceFirst('Exception: ', ''),
        onRetry: () => context.read<CourseProvider>().loadCourses(),
      );
    }

    // 3. Empty
    if (count == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.inbox_outlined, size: 48),
              const SizedBox(height: 8),
              const Text('Data course belum tersedia'),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.read<CourseProvider>().loadCourses(),
                child: const Text('Muat ulang'),
              ),
            ],
          ),
        ),
      );
    }

    // 4. Success
    return builder(context, context.read<CourseProvider>().courses);
  }
}
