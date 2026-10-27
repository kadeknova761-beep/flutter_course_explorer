import 'package:flutter/material.dart';

import '../constants/student_identity.dart';
import '../utils/course_status.dart';

class CourseDetailPage extends StatefulWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;

  const CourseDetailPage({
    super.key,
    required this.course,
    this.isFavorite = false,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  // LOCAL STATE: hanya halaman detail ini yang perlu tahu apakah
  // deskripsi sedang ditampilkan atau disembunyikan.
  bool showDetail = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final bool isFavorite = widget.isFavorite;
    final String status = course['status'] as String;

    return Scaffold(
      appBar: AppBar(title: Text(course['title'] as String)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$studentId - $studentName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: Icon(
                      statusIcon(status),
                      color: statusColor(status),
                      size: 36,
                    ),
                    title: Text(course['title'] as String),
                    subtitle: Text(
                      '${course['code']} - ${course['credits']} SKS - '
                      '${statusLabel(status)}',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Local state dengan setState(): show/hide deskripsi course.
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      showDetail = !showDetail;
                    });
                  },
                  icon: Icon(
                    showDetail ? Icons.expand_less : Icons.expand_more,
                  ),
                  label: Text(
                    showDetail ? 'Sembunyikan deskripsi' : 'Tampilkan deskripsi',
                  ),
                ),
                if (showDetail)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Course ${course['title']} (${course['code']}) '
                        'bernilai ${course['credits']} SKS dan saat ini '
                        'berstatus ${statusLabel(status)}.\n\n'
                        'Dilihat oleh: $studentId - $studentName',
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                // Jika sudah favorite, tombol dinonaktifkan.
                FilledButton.icon(
                  onPressed: isFavorite
                      ? null
                      : () => Navigator.pop(context, true),
                  icon: Icon(isFavorite ? Icons.check : Icons.favorite),
                  label: Text(
                    isFavorite ? 'Sudah di Favorite' : 'Tambah ke Favorite',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali tanpa memilih'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
