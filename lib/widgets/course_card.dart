import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../utils/course_status.dart';

/// Reusable widget: kartu course yang bisa di-tap, long press, dan favorite.
class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
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
    final String status = course['status'] as String;
    final String code = course['code'] as String;

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
              Icon(statusIcon(status), color: statusColor(status), size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${course['code']} - ${course['credits']} SKS'),
                    const SizedBox(height: 4),
                    Text(
                      statusLabel(status),
                      style: TextStyle(
                        color: statusColor(status),
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
                  final bool isFavorite = provider.isFavorite(code);
                  debugPrint('[Rebuild] CourseCard - tombol favorite $code');
                  return IconButton(
                    tooltip: isFavorite
                        ? 'Hapus dari favorite'
                        : 'Tambah favorite',
                    onPressed: () {
                      // read(): memanggil aksi tanpa listen.
                      context.read<CourseProvider>().toggleFavorite(code);
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
