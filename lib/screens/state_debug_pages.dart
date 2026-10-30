import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_identity.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../repositories/course_repository.dart';
import '../constants/api_config.dart';
import '../services/course_api_service.dart';
import '../widgets/course_state_gate.dart';

// Nama: Kadek Nova Krisna Putra | NIM: 2415051117
//
// Tahap 15 (Pertemuan 6): empat kasus debugging state management.
// Setiap kasus memiliki saklar untuk membandingkan versi RUSAK dan PERBAIKAN.

// Log hasil debugging yang ditampilkan di menu (dipakai Kasus D).
final ValueNotifier<String> stateDebugLog = ValueNotifier<String>(
  'Belum ada log',
);

// Notifier sederhana khusus untuk eksperimen Kasus A dan B.
class DebugCounterNotifier extends ChangeNotifier {
  int favoriteCount = 0;

  // true = versi RUSAK: notifyListeners() tidak dipanggil.
  bool skipNotify = false;

  void addFavorite() {
    favoriteCount++;
    if (!skipNotify) {
      notifyListeners();
    }
  }
}

class StateDebugMenuPage extends StatelessWidget {
  const StateDebugMenuPage({super.key});

  Widget caseTile(
    BuildContext context,
    String title,
    String subtitle,
    Widget page,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.bug_report),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debugging State')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            '$studentId - $studentName',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          caseTile(
            context,
            'Kasus A',
            'notifyListeners() dihapus: UI tidak berubah',
            const NotifyCasePage(),
          ),
          caseTile(
            context,
            'Kasus B',
            'Provider dibaca dari context di atas ChangeNotifierProvider',
            const ContextCasePage(),
          ),
          caseTile(
            context,
            'Kasus C',
            'CourseService sengaja error: error state harus terlihat',
            const ServiceErrorCasePage(),
          ),
          caseTile(
            context,
            'Kasus D',
            'Perubahan state setelah async: periksa mounted',
            const AsyncSetStateCasePage(),
          ),
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ValueListenableBuilder<String>(
                valueListenable: stateDebugLog,
                builder: (context, value, child) => Text('Log: $value'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Kasus A: notifyListeners() hilang ----------------
class NotifyCasePage extends StatefulWidget {
  const NotifyCasePage({super.key});

  @override
  State<NotifyCasePage> createState() => _NotifyCasePageState();
}

class _NotifyCasePageState extends State<NotifyCasePage> {
  final DebugCounterNotifier notifier = DebugCounterNotifier();

  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasus A - notifyListeners')),
      body: ChangeNotifierProvider<DebugCounterNotifier>.value(
        value: notifier,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '$studentId - $studentName',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Hapus notifyListeners() (versi RUSAK)'),
                value: notifier.skipNotify,
                onChanged: (value) {
                  setState(() => notifier.skipNotify = value);
                },
              ),
              Text(
                notifier.skipNotify
                    ? 'Mode RUSAK: data berubah tetapi listener tidak diberi tahu'
                    : 'Mode PERBAIKAN: notifyListeners() dipanggil',
              ),
              const SizedBox(height: 12),
              // Consumer hanya diperbarui jika notifyListeners() dipanggil.
              Consumer<DebugCounterNotifier>(
                builder: (context, n, child) {
                  return Text(
                    'Favorite di UI: ${n.favoriteCount}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: notifier.addFavorite,
                child: const Text('Tambah favorite'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          'Nilai sebenarnya di notifier: '
                          '${notifier.favoriteCount}',
                        ),
                      ),
                    );
                },
                child: const Text('Cek nilai sebenarnya'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Petunjuk: aktifkan saklar, tekan "Tambah favorite" beberapa '
                'kali tanpa mengubah saklar, lalu tekan "Cek nilai sebenarnya".',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------- Kasus B: context di atas ChangeNotifierProvider -------------
class ContextCasePage extends StatefulWidget {
  const ContextCasePage({super.key});

  @override
  State<ContextCasePage> createState() => _ContextCasePageState();
}

class _ContextCasePageState extends State<ContextCasePage> {
  bool useWrongContext = true;

  @override
  Widget build(BuildContext context) {
    // `context` di sini milik State, yaitu DI ATAS ChangeNotifierProvider
    // yang dibuat pada return di bawah.
    String? errorText;
    if (useWrongContext) {
      try {
        context.read<DebugCounterNotifier>();
      } catch (e) {
        final String message = e.toString();
        debugPrint('[Kasus B] ${e.runtimeType}');
        errorText =
            '${e.runtimeType}\n'
            '${message.length > 420 ? '${message.substring(0, 420)}...' : message}';
      }
    }

    return ChangeNotifierProvider<DebugCounterNotifier>(
      create: (_) => DebugCounterNotifier(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Kasus B - Context')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '$studentId - $studentName',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pakai context DI ATAS provider (RUSAK)'),
                value: useWrongContext,
                onChanged: (value) => setState(() => useWrongContext = value),
              ),
              if (errorText != null)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(errorText),
                  ),
                )
              else
                // PERBAIKAN: Consumer berada DI BAWAH provider, sehingga
                // contextnya dapat menemukan DebugCounterNotifier.
                Consumer<DebugCounterNotifier>(
                  builder: (context, n, child) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Berhasil membaca provider. '
                              'Nilai: ${n.favoriteCount}',
                            ),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed: n.addFavorite,
                              child: const Text('Tambah favorite'),
                            ),
                          ],
                        ),
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

// ---------------- Kasus C: CourseService sengaja error ----------------

// Service tiruan yang selalu gagal untuk menguji error state.
class FailingCourseService extends CourseApiService {
  FailingCourseService() : super(apiBaseUrl);

  @override
  Future<List<Course>> getCourses() async {
    await Future.delayed(const Duration(milliseconds: 800));
    throw Exception('CourseApiService gagal (simulasi Kasus C)');
  }
}

class ServiceErrorCasePage extends StatefulWidget {
  const ServiceErrorCasePage({super.key});

  @override
  State<ServiceErrorCasePage> createState() => _ServiceErrorCasePageState();
}

class _ServiceErrorCasePageState extends State<ServiceErrorCasePage> {
  bool useFailingService = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasus C - Service Error')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '$studentId - $studentName',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Service gagal (versi RUSAK)'),
              value: useFailingService,
              onChanged: (value) => setState(() => useFailingService = value),
            ),
            Expanded(
              // key berubah => provider dibuat ulang dan loadCourses() jalan lagi.
              child: ChangeNotifierProvider<CourseProvider>(
                key: ValueKey(useFailingService),
                create: (_) => CourseProvider(
                  CourseRepository(
                    useFailingService
                        ? FailingCourseService()
                        : CourseApiService(apiBaseUrl),
                  ), // CourseRepository
                )..loadCourses(),
                child: CourseStateGate(
                  builder: (context, courses) {
                    return ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        final course = courses[index];
                        return Card(
                          child: ListTile(
                            title: Text(course.title),
                            subtitle: Text(
                              '${course.code} - ${course.credits} SKS',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------- Kasus D: perubahan state setelah async -------------
class AsyncSetStateCasePage extends StatefulWidget {
  const AsyncSetStateCasePage({super.key});

  @override
  State<AsyncSetStateCasePage> createState() => _AsyncSetStateCasePageState();
}

class _AsyncSetStateCasePageState extends State<AsyncSetStateCasePage> {
  // true = versi RUSAK: setState dipanggil tanpa memeriksa mounted.
  bool skipMountedCheck = false;
  String status = 'Belum dijalankan';

  Future<void> runProcess() async {
    setState(() {
      status = 'Proses berjalan 3 detik...';
    });

    await Future.delayed(const Duration(seconds: 3));

    // PERBAIKAN: halaman bisa saja sudah ditutup selama menunggu.
    if (!skipMountedCheck && !mounted) {
      stateDebugLog.value =
          'Kasus D: halaman sudah ditutup, mounted dicek sehingga setState '
          'dilewati (aman).';
      return;
    }

    try {
      setState(() {
        status = 'Proses selesai';
      });
      stateDebugLog.value = 'Kasus D: setState berhasil dijalankan.';
    } catch (e) {
      // Pada versi RUSAK, setState setelah dispose melempar error.
      final String firstLine = e.toString().split('\n').first;
      stateDebugLog.value = 'Kasus D ERROR (tanpa cek mounted): $firstLine';
      debugPrint('[Kasus D] $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasus D - Async dan mounted')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '$studentId - $studentName',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tanpa pengecekan mounted (versi RUSAK)'),
              value: skipMountedCheck,
              onChanged: (value) => setState(() => skipMountedCheck = value),
            ),
            Text('Status: $status'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: runProcess,
              child: const Text('Jalankan proses 3 detik'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Petunjuk: tekan tombol, lalu segera tekan Kembali sebelum 3 '
              'detik berakhir. Hasilnya muncul pada kartu Log di menu '
              'Debugging State.',
            ),
          ],
        ),
      ),
    );
  }
}
