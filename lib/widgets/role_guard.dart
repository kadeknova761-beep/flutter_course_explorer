// Nama: Kadek Nova Krisna Putra | NIM: 2415051117

import 'package:flutter/material.dart';

/// Hanya menampilkan [child] jika [role] termasuk dalam daftar [allowed].
/// Ini mengamankan tampilan saja, bukan database (lihat Praktik 5 untuk RLS).
class RoleGuard extends StatelessWidget {
  const RoleGuard({
    super.key,
    required this.role,
    required this.allowed,
    required this.child,
  });

  final String role;
  final List<String> allowed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return allowed.contains(role) ? child : const SizedBox.shrink();
  }
}
