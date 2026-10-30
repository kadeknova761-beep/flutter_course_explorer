import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_identity.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../utils/course_status.dart';
import 'course_form_page.dart';

class CourseDetailPage extends StatefulWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  // LOCAL STATE: hanya halaman detail ini yang perlu tahu apakah
  // deskripsi sedang ditampilkan atau disembunyikan.
  bool showDetail = false;

  void _openEdit(Course course) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourseFormPage(course: course)),
    );
  }

  // Hapus (HTTP DELETE): tampilkan dialog konfirmasi dulu, jalankan DELETE
  // hanya jika pengguna menyetujui.
  Future<void> _confirmDelete(Course course) async {
    // Diambil sebelum await agar tidak memakai context setelah async gap.
    final provider = context.read<CourseProvider>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus course?'),
          content: Text(
            '${course.title} (${course.code}) akan dihapus dari server. '
            'Tindakan ini tidak dapat dibatalkan.\n\n'
            'Dikonfirmasi oleh: $studentId - $studentName',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final bool success = await provider.deleteCourse(course);

    // Halaman bisa saja sudah ditutup selama request berjalan.
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course ${course.code} berhasil dihapus')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.deleteError ?? 'Gagal menghapus course'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // watch(): course dan status favorite dibaca dari CourseProvider.
    // Setelah Edit, data terbaru dicari berdasarkan id sehingga halaman
    // ini tidak menampilkan data lama. Jika tidak ditemukan, pakai data
    // yang dikirim lewat constructor.
    final provider = context.watch<CourseProvider>();
    final Course course = provider.courses.firstWhere(
      (c) => c.id != null && c.id == widget.course.id,
      orElse: () => widget.course,
    );
    final bool isFavorite = provider.isFavorite(course.code);
    final bool isDeleting = provider.isDeleting;

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '$studentId - $studentName',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          statusIcon(course.status),
                          color: statusColor(course.status),
                          size: 36,
                        ),
                        title: Text(course.title),
                        subtitle: Text(
                          '${course.code} - ${course.credits} SKS - '
                          '${statusLabel(course.status)}',
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
                    showDetail
                        ? 'Sembunyikan deskripsi'
                        : 'Tampilkan deskripsi',
                  ),
                ),
                if (showDetail)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Course ${course.title} (${course.code}) '
                        'bernilai ${course.credits} SKS dan saat ini '
                        'berstatus ${statusLabel(course.status)}.\n\n'
                        'Dilihat oleh: $studentId - $studentName',
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                // Toggle favorite langsung ke CourseProvider (read: aksi).
                FilledButton.icon(
                  onPressed: () {
                    final p = context.read<CourseProvider>();
                    final bool wasFavorite = p.isFavorite(course.code);
                    p.toggleFavorite(course.code);

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            wasFavorite
                                ? '${course.title} dihapus dari favorite'
                                : '${course.title} ditambahkan ke favorite',
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
                // Edit (HTTP PUT). Nonaktif jika course belum punya id.
                OutlinedButton.icon(
                  onPressed: course.id == null ? null : () => _openEdit(course),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Course'),
                ),
                const SizedBox(height: 8),
                // Hapus (HTTP DELETE). Nonaktif saat request berjalan agar
                // tidak terjadi klik ganda.
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: (course.id == null || isDeleting)
                      ? null
                      : () => _confirmDelete(course),
                  icon: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete),
                  label: const Text('Hapus Course'),
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
