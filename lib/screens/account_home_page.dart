// Nama: Kadek Nova Krisna Putra | NIM: 2415051117

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('KosFinder'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return const Center(child: Text('Gagal memuat profil'));
          }
          final p = snap.data!;
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Nama'),
                subtitle: Text(p.name.isEmpty ? '-' : p.name),
              ),
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(p.email),
              ),
              ListTile(
                leading: const Icon(Icons.badge),
                title: const Text('Role'),
                subtitle: Text(p.role),
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
          );
        },
      ),
    );
  }
}
