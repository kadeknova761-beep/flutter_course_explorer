import 'package:flutter/material.dart';

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

void main() {
  runApp(const LiftingStateExperimentApp());
}

class LiftingStateExperimentApp extends StatelessWidget {
  const LiftingStateExperimentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eksperimen Lifting State Up',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const LiftingStateExperimentPage(),
    );
  }
}

// ============== PARENT: SATU-SATUNYA PEMILIK STATE ==============
class LiftingStateExperimentPage extends StatefulWidget {
  const LiftingStateExperimentPage({super.key});

  @override
  State<LiftingStateExperimentPage> createState() =>
      _LiftingStateExperimentPageState();
}

class _LiftingStateExperimentPageState
    extends State<LiftingStateExperimentPage> {
  // SINGLE SOURCE OF TRUTH: hanya ada satu variabel favorite di seluruh layar.
  bool favorite = false;

  // Aksi perubahan state dikirim ke child lewat callback.
  void toggleFavorite() {
    setState(() {
      favorite = !favorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahap 3: Lifting State Up'),
        actions: [
          // Widget 3: hanya menerima nilai dari parent.
          FavoriteIconBadge(isFavorite: favorite),
        ],
      ),
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
            // Widget 1: menerima data lewat constructor, aksi lewat callback.
            CourseCard(
              title: 'Flutter UI Fundamentals',
              code: 'MOB03',
              isFavorite: favorite,
              onFavoriteChanged: toggleFavorite,
            ),
            const SizedBox(height: 8),
            // Widget 2: menampilkan nilai yang sama dan memakai callback sama.
            FavoriteStatusPanel(isFavorite: favorite, onToggle: toggleFavorite),
          ],
        ),
      ),
    );
  }
}

// ======================= CHILD 1: CourseCard =======================

// StatelessWidget: tidak menyimpan salinan favorite sendiri.
class CourseCard extends StatelessWidget {
  final String title;
  final String code;
  final bool isFavorite;
  final VoidCallback onFavoriteChanged;

  const CourseCard({
    super.key,
    required this.title,
    required this.code,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.play_circle, color: Colors.blue, size: 36),
        title: Text(title),
        subtitle: Text('$code - 3 SKS'),
        trailing: IconButton(
          tooltip: isFavorite ? 'Hapus dari favorite' : 'Tambah favorite',
          onPressed: onFavoriteChanged,
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
        ),
      ),
    );
  }
}

// ================= CHILD 2: FavoriteStatusPanel =================

class FavoriteStatusPanel extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;

  const FavoriteStatusPanel({
    super.key,
    required this.isFavorite,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isFavorite
                  ? 'Status: Flutter UI Fundamentals ada di favorite'
                  : 'Status: Flutter UI Fundamentals belum favorite',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: onToggle,
              child: Text(
                isFavorite ? 'Hapus dari panel ini' : 'Tambah dari panel ini',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= CHILD 3: FavoriteIconBadge =================

class FavoriteIconBadge extends StatelessWidget {
  final bool isFavorite;

  const FavoriteIconBadge({super.key, required this.isFavorite});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : null,
      ),
    );
  }
}
