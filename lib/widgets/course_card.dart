import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../utils/course_status.dart';

/// Reusable widget: kartu course yang bisa di-tap, long press, dan favorite.
class CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CourseCard({
    super.key,
    required this.course,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias, // agar ripple InkWell mengikuti bentuk Card
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                statusIcon(course.status),
                color: statusColor(course.status),
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${course.code} - ${course.credits} SKS'),
                    const SizedBox(height: 4),
                    Text(
                      statusLabel(course.status),
                      style: TextStyle(
                        color: statusColor(course.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Consumer pada bagian kecil: hanya tombol favorite kartu ini
              // yang di-rebuild ketika favorite berubah.
              Consumer<CourseProvider>(
                builder: (context, provider, child) {
                  final bool isFavorite = provider.isFavorite(course.code);
                  debugPrint(
                    '[Rebuild] CourseCard - tombol favorite ${course.code}',
                  );
                  return IconButton(
                    tooltip: isFavorite
                        ? 'Hapus dari favorite'
                        : 'Tambah favorite',
                    onPressed: () {
                      // read(): memanggil aksi tanpa listen.
                      context.read<CourseProvider>().toggleFavorite(
                        course.code,
                      );
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
