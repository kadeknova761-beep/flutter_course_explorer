// Nama: Kadek Nova Krisna Putra | NIM: 2415051117

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/role_guard.dart';
import 'login_page.dart';
import 'responsive_shell.dart';

/// Halaman Home hasil autentikasi (HomePage pada worksheet).
/// Dinamai AccountHomePage agar tidak bentrok dengan HomePage Course Explorer.
class AccountHomePage extends StatefulWidget {
  const AccountHomePage({super.key});

  @override
  State<AccountHomePage> createState() => _AccountHomePageState();
}

class _AccountHomePageState extends State<AccountHomePage> {
  late final Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
  }

  Future<void> _logout() async {
    await AuthService.instance.logout(); // Session Removed
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final p = snap.data;
        if (snap.hasError || p == null) {
          return const Scaffold(
            body: Center(child: Text('Gagal memuat profil')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('KosFinder (${p.role})'),
            actions: [
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          // menu yang tampil berbeda untuk tiap role
          body: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(p.name.isEmpty ? p.email : p.name),
                subtitle: Text('${p.email} • ${p.role}'),
              ),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.list),
                title: Text('Daftar Kos'),
              ),
              if (p.isOwner || p.isAdmin)
                const ListTile(
                  leading: Icon(Icons.home_work),
                  title: Text('My Kos'),
                ),
              if (p.isAdmin)
                const ListTile(
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text('Kelola Data (Admin)'),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Buka Course Explorer'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ResponsiveShell()),
                ),
              ),
            ],
          ),
          // tombol "Tambah Kos" hanya untuk owner/admin
          floatingActionButton: RoleGuard(
            role: p.role,
            allowed: const ['owner', 'admin'],
            child: FloatingActionButton.extended(
              onPressed: () {
                // Halaman Add Kos dibuat di Praktik 5
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Halaman Tambah Kos (Praktik 5)'),
                  ),
                );
              },
              icon: const Icon(Icons.add_home),
              label: const Text('Tambah Kos'),
            ),
          ),
        );
      },
    );
  }
}
