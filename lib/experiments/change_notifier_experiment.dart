import 'package:flutter/material.dart';

import '../providers/course_provider.dart';
import '../repositories/course_repository.dart';
import '../services/course_service.dart';

// Demo Tahap 5 (Pertemuan 6): CourseProvider (ChangeNotifier) dengan
// notifyListeners(). Provider belum dipasang (itu Tahap 6), jadi widget
// mendengarkan perubahan memakai ListenableBuilder bawaan Flutter.
// Dijalankan dengan:
//   flutter run -d chrome -t lib/experiments/change_notifier_experiment.dart

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

const Map<String, String> demoCourses = {
  'MOB01': 'Git & GitHub',
  'MOB02': 'Dart Fundamentals',
  'MOB03': 'Flutter UI Fundamentals',
  'MOB04': 'Navigation',
  'MOB05': 'State Management',
};

void main() {
  runApp(const ChangeNotifierExperimentApp());
}

class ChangeNotifierExperimentApp extends StatelessWidget {
  const ChangeNotifierExperimentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eksperimen ChangeNotifier',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ChangeNotifierExperimentPage(),
    );
  }
}

class ChangeNotifierExperimentPage extends StatefulWidget {
  const ChangeNotifierExperimentPage({super.key});

  @override
  State<ChangeNotifierExperimentPage> createState() =>
      _ChangeNotifierExperimentPageState();
}

class _ChangeNotifierExperimentPageState
    extends State<ChangeNotifierExperimentPage> {
  // Object state dibuat satu kali dan di-dispose bersama halaman.
  final CourseProvider provider = CourseProvider(
    CourseRepository(CourseService()),
  );

  @override
  void dispose() {
    provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 5: ChangeNotifier')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$studentId - $studentName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              // Builder dijalankan ulang setiap provider memanggil
              // notifyListeners(), tanpa setState() di halaman ini.
              child: ListenableBuilder(
                listenable: provider,
                builder: (context, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Favorite di CourseProvider: '
                                '${provider.favoriteCount}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (provider.favorites.isEmpty)
                                const Text('Belum ada favorite')
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    for (final code in provider.favorites)
                                      Chip(label: Text(code)),
                                  ],
                                ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: provider.clearFavorites,
                                child: const Text('Reset favorite'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            for (final entry in demoCourses.entries)
                              Card(
                                child: ListTile(
                                  title: Text(entry.value),
                                  subtitle: Text(entry.key),
                                  trailing: IconButton(
                                    tooltip: provider.isFavorite(entry.key)
                                        ? 'Hapus dari favorite'
                                        : 'Tambah favorite',
                                    onPressed: () =>
                                        provider.toggleFavorite(entry.key),
                                    icon: Icon(
                                      provider.isFavorite(entry.key)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: provider.isFavorite(entry.key)
                                          ? Colors.red
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
