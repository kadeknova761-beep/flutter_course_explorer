import 'package:flutter/material.dart';

import '../constants/student_identity.dart';

// ===== SAKLAR DEBUGGING TAHAP 16 (PERTEMUAN 5) =====
// Kasus A: true = Row tanpa Expanded (overflow), false = perbaikan.
const bool showOverflowBug = false;
// Kasus B: true = ListView di Column tanpa Expanded (unbounded), false = perbaikan.
const bool showUnboundedBug = false;
// Kasus C: true = form tanpa scroll (keyboard overflow), false = perbaikan.
const bool showKeyboardBug = false;
// Kasus D: true = tombol bisa memicu push berkali-kali, false = ada guard.
const bool allowDoublePush = false;

class DebugMenuPage extends StatelessWidget {
  const DebugMenuPage({super.key});

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
      appBar: AppBar(title: const Text('Debugging Challenge')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '$studentId - $studentName',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('Ubah saklar kasus di bagian atas main.dart.'),
          const SizedBox(height: 12),
          caseTile(
            context,
            'Kasus A',
            'RenderFlex overflow pada Row',
            const OverflowCasePage(),
          ),
          caseTile(
            context,
            'Kasus B',
            'Vertical viewport unbounded height',
            const UnboundedCasePage(),
          ),
          caseTile(
            context,
            'Kasus C',
            'Keyboard overflow pada form',
            const KeyboardCasePage(),
          ),
          caseTile(
            context,
            'Kasus D',
            'Navigasi ganda (route ter-push berulang)',
            const DoublePushCasePage(),
          ),
        ],
      ),
    );
  }
}

// ---------------- Kasus A: RenderFlex overflow ----------------
class OverflowCasePage extends StatelessWidget {
  const OverflowCasePage({super.key});

  @override
  Widget build(BuildContext context) {
    const String sample = 'teks sangat panjang untuk menguji layout. ';
    final String longText = '$studentId - $studentName - ${sample * 6}';

    return Scaffold(
      appBar: AppBar(title: const Text('Kasus A - Overflow Row')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$studentId - $studentName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              showOverflowBug
                  ? 'Versi RUSAK: Text langsung di dalam Row'
                  : 'Versi PERBAIKAN: Text dibungkus Expanded',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: showOverflowBug
                    // RUSAK: Row tidak membatasi lebar Text.
                    ? Row(
                        children: [
                          const Icon(Icons.info),
                          const SizedBox(width: 8),
                          Text(longText),
                        ],
                      )
                    // PERBAIKAN: Expanded membatasi Text pada sisa lebar.
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info),
                          const SizedBox(width: 8),
                          Expanded(child: Text(longText)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------- Kasus B: ListView di Column tanpa Expanded -------------
class UnboundedCasePage extends StatelessWidget {
  const UnboundedCasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final list = ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.menu_book),
          title: Text('Item ke-${index + 1}'),
          subtitle: Text('$studentId - $studentName'),
        );
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Kasus B - Unbounded Height')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '$studentId - $studentName\n'
              '${showUnboundedBug ? 'Versi RUSAK: ListView langsung di Column' : 'Versi PERBAIKAN: ListView dibungkus Expanded'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (showUnboundedBug)
            list // RUSAK: Column memberi tinggi tak terbatas pada ListView.
          else
            Expanded(child: list), // PERBAIKAN: ListView mendapat sisa ruang.
        ],
      ),
    );
  }
}

// ---------------- Kasus C: keyboard overflow ----------------
class KeyboardCasePage extends StatefulWidget {
  const KeyboardCasePage({super.key});

  @override
  State<KeyboardCasePage> createState() => _KeyboardCasePageState();
}

class _KeyboardCasePageState extends State<KeyboardCasePage> {
  // Chrome di komputer tidak punya keyboard layar, jadi ruang yang
  // dipakai keyboard disimulasikan dengan padding bawah.
  static const double keyboardSimHeight = 400;

  // LOCAL STATE: simulasi keyboard hanya dipakai halaman ini.
  bool keyboardOpen = false;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = keyboardOpen ? keyboardSimHeight : 0;

    final fields = <Widget>[
      const TextField(
        decoration: InputDecoration(
          labelText: 'Nama',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      const TextField(
        decoration: InputDecoration(
          labelText: 'NIM',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      const TextField(
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Komentar',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: FilledButton(onPressed: () {}, child: const Text('Kirim')),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasus C - Keyboard'),
        actions: [
          IconButton(
            tooltip: 'Simulasi keyboard',
            icon: Icon(keyboardOpen ? Icons.keyboard_hide : Icons.keyboard),
            onPressed: () => setState(() => keyboardOpen = !keyboardOpen),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: showKeyboardBug
            // RUSAK: Column tanpa scroll, form terdorong ke bawah oleh Spacer.
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$studentId - $studentName (versi RUSAK)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ...fields,
                  ],
                ),
              )
            // PERBAIKAN: isi dibungkus SingleChildScrollView.
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$studentId - $studentName (versi PERBAIKAN)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 200),
                    ...fields,
                  ],
                ),
              ),
      ),
    );
  }
}

// ---------------- Kasus D: navigasi ganda ----------------
class DoublePushCasePage extends StatefulWidget {
  const DoublePushCasePage({super.key});

  @override
  State<DoublePushCasePage> createState() => _DoublePushCasePageState();
}

class _DoublePushCasePageState extends State<DoublePushCasePage> {
  bool isNavigating = false;
  int pushCount = 0;

  Future<void> openDetail() async {
    // GUARD: abaikan tekanan berikutnya selama navigasi sedang berjalan.
    if (!allowDoublePush) {
      if (isNavigating) return;
      isNavigating = true;
    }

    pushCount++;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DoubleDetailPage(number: pushCount)),
    );

    // Halaman detail sudah ditutup, tombol boleh dipakai lagi.
    isNavigating = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kasus D - Navigasi Ganda')),
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
            Text(
              allowDoublePush
                  ? 'Mode RUSAK: tanpa guard, push bisa berulang'
                  : 'Mode PERBAIKAN: guard isNavigating aktif',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: openDetail,
              child: const Text('Buka Detail'),
            ),
            const SizedBox(height: 8),
            // Simulasi tekan cepat berkali-kali dalam satu waktu.
            OutlinedButton(
              onPressed: () {
                openDetail();
                openDetail();
                openDetail();
              },
              child: const Text('Tekan 3x sekaligus (simulasi)'),
            ),
          ],
        ),
      ),
    );
  }
}

class DoubleDetailPage extends StatelessWidget {
  final int number;

  const DoubleDetailPage({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail ke-$number')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$studentId - $studentName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Halaman detail ke-$number di navigation stack'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
