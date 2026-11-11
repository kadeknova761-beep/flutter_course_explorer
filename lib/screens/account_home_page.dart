// Nama: Kadek Nova Krisna Putra | NIM: 2415051117

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'responsive_shell.dart';

/// Halaman Home hasil autentikasi (HomePage pada worksheet).
/// Dinamai AccountHomePage agar tidak bentrok dengan HomePage Course Explorer.
class AccountHomePage extends StatelessWidget {
  const AccountHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('KosFinder')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('Login sebagai: ${user?.email ?? '-'}'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Buka Course Explorer'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ResponsiveShell())),
          ),
        ],
      ),
    );
  }
}
