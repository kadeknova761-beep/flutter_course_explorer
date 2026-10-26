import 'package:flutter/material.dart';

// Eksperimen Tahap 4 (Pertemuan 6): ValueNotifier dan ValueListenableBuilder.
// File ini berdiri sendiri dan dijalankan dengan:
//   flutter run -d chrome -t lib/experiments/value_notifier_experiment.dart

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

void main() {
  runApp(const ValueNotifierExperimentApp());
}

class ValueNotifierExperimentApp extends StatelessWidget {
  const ValueNotifierExperimentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eksperimen ValueNotifier',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ValueNotifierExperimentPage(),
    );
  }
}

class ValueNotifierExperimentPage extends StatefulWidget {
  const ValueNotifierExperimentPage({super.key});

  @override
  State<ValueNotifierExperimentPage> createState() =>
      _ValueNotifierExperimentPageState();
}

class _ValueNotifierExperimentPageState
    extends State<ValueNotifierExperimentPage> {
  // POLA A: nilai biasa yang diubah dengan setState().
  int setStateCount = 0;

  // POLA B: ValueNotifier menyimpan nilai dan memberi tahu listener-nya.
  final ValueNotifier<int> favoriteCount = ValueNotifier<int>(0);

  // Penghitung rebuild (hanya untuk demonstrasi, bukan praktik produksi).
  int pageBuilds = 0;
  int notifierBuilds = 0;

  @override
  void dispose() {
    // ValueNotifier harus di-dispose agar tidak terjadi kebocoran memori.
    favoriteCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pageBuilds++;

    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 4: ValueNotifier')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$studentId - $studentName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ---------- POLA A: setState ----------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'A. Dengan setState()',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('Favorite (setState): $setStateCount'),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () {
                        // Seluruh build() halaman dijalankan ulang.
                        setState(() {
                          setStateCount++;
                        });
                      },
                      child: const Text('+1 dengan setState'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ---------- POLA B: ValueNotifier ----------
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'B. Dengan ValueNotifier',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    // Hanya bagian ini yang mendengarkan perubahan nilai.
                    ValueListenableBuilder<int>(
                      valueListenable: favoriteCount,
                      builder: (context, value, child) {
                        notifierBuilds++;
                        return Text(
                          'Favorite (ValueNotifier): $value | '
                          'builder dijalankan: $notifierBuilds x',
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilledButton(
                          // Tanpa setState: cukup ubah .value.
                          onPressed: () => favoriteCount.value++,
                          child: const Text('+1 dengan ValueNotifier'),
                        ),
                        OutlinedButton(
                          onPressed: () => favoriteCount.value = 0,
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // ---------- PEMBANDING ----------
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'build() halaman dijalankan: $pageBuilds x\n'
                  '(angka ini hanya bertambah jika halaman di-rebuild)',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
