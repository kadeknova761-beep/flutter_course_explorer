import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_identity.dart';
import '../providers/course_provider.dart';
import '../utils/course_status.dart';

class CourseDetailPage extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({super.key, required this.course});

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
    final String status = course['status'] as String;
    final String code = course['code'] as String;
    final String title = course['title'] as String;

    // watch(): status favorite dibaca dari CourseProvider (shared state),
    // sehingga selalu sama dengan daftar course dan halaman Favorites.
    final bool isFavorite = context.watch<CourseProvider>().isFavorite(code);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          statusIcon(status),
                          color: statusColor(status),
                          size: 36,
                        ),
                        title: Text(title),
                        subtitle: Text(
                          '$code - ${course['credits']} SKS - '
                          '${statusLabel(status)}',
                        ),
                      ),
                      ListTile(
                        leading: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        title: Text(
                          isFavorite
                              ? 'Status favorite: Ya'
                              : 'Status favorite: Belum',
                        ),
                      ),
                    ],
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
                        'Course $title ($code) '
                        'bernilai ${course['credits']} SKS dan saat ini '
                        'berstatus ${statusLabel(status)}.\n\n'
                        'Dilihat oleh: $studentId - $studentName',
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                // Toggle favorite langsung ke CourseProvider (read: aksi).
                FilledButton.icon(
                  onPressed: () {
                    final provider = context.read<CourseProvider>();
                    final bool wasFavorite = provider.isFavorite(code);
                    provider.toggleFavorite(code);

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            wasFavorite
                                ? '$title dihapus dari favorite'
                                : '$title ditambahkan ke favorite',
                          ),
                        ),
                      );
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  label: Text(
                    isFavorite ? 'Hapus dari Favorite' : 'Tambah ke Favorite',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
