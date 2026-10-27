import 'package:flutter/material.dart';

// Helper murni (tanpa state) untuk menerjemahkan status course ke ikon,
// warna, dan label. Dipakai oleh beberapa screen dan widget.
IconData statusIcon(String status) {
  switch (status) {
    case 'done':
      return Icons.check_circle;
    case 'active':
      return Icons.play_circle;
    default:
      return Icons.schedule;
  }
}

Color statusColor(String status) {
  switch (status) {
    case 'done':
      return Colors.green;
    case 'active':
      return Colors.blue;
    default:
      return Colors.orange;
  }
}

String statusLabel(String status) {
  switch (status) {
    case 'done':
      return 'Selesai';
    case 'active':
      return 'Berjalan';
    default:
      return 'Rencana';
  }
}
