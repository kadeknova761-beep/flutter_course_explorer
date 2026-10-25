import 'package:flutter/material.dart';

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

class DemoCourse {
  final String code;
  final String title;
  final int credits;

  const DemoCourse(this.code, this.title, this.credits);
}

const List<DemoCourse> demoCourses = [
  DemoCourse('MOB01', 'Git & GitHub', 2),
  DemoCourse('MOB02', 'Dart Fundamentals', 2),
  DemoCourse('MOB03', 'Flutter UI Fundamentals', 3),
  DemoCourse('MOB04', 'Navigation', 2),
  DemoCourse('MOB05', 'State Management', 3),
];

void main() {
  runApp(const SetStateExperimentApp());
}

class SetStateExperimentApp extends StatelessWidget {
  const SetStateExperimentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eksperimen setState',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SetStateExperimentPage(),
    );
  }
}

// ==================== PARENT: PEMILIK STATE ====================

class SetStateExperimentPage extends StatefulWidget {
  const SetStateExperimentPage({super.key});

  @override
  State<SetStateExperimentPage> createState() => _SetStateExperimentPageState();
}

class _SetStateExperimentPageState extends State<SetStateExperimentPage> {
  // Satu nilai favorites dimiliki oleh parent.
  final Set<String> favorites = {};

  // Callback: child memanggil fungsi ini untuk mengubah favorites di parent.
  void toggleFavorite(String code) {
    setState(() {
      if (favorites.contains(code)) {
        favorites.remove(code);
      } else {
        favorites.add(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 2: Masalah setState')),
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
            // CHILD 1: menerima favorites lewat constructor.
            FavoriteSummaryPanel(favorites: favorites),
            // Contoh DUPLIKASI STATE: menyalin nilai ke state milik sendiri.
            FavoriteBadgeCopy(favoriteCount: favorites.length),
            const SizedBox(height: 8),
            // CHILD 2: menerima favorites dan callback lewat constructor.
            Expanded(
              child: CourseListPanel(
                courses: demoCourses,
                favorites: favorites,
                onToggleFavorite: toggleFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== CHILD 1: RINGKASAN ====================

class FavoriteSummaryPanel extends StatelessWidget {
  final Set<String> favorites;

  const FavoriteSummaryPanel({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Favorite (dibaca dari parent): ${favorites.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            if (favorites.isEmpty)
              const Text('Belum ada favorite')
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final code in favorites) Chip(label: Text(code)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ============ DUPLIKASI STATE (SENGAJA SALAH UNTUK EKSPERIMEN) ============

class FavoriteBadgeCopy extends StatefulWidget {
  final int favoriteCount;

  const FavoriteBadgeCopy({super.key, required this.favoriteCount});

  @override
  State<FavoriteBadgeCopy> createState() => _FavoriteBadgeCopyState();
}

class _FavoriteBadgeCopyState extends State<FavoriteBadgeCopy> {
  // Nilai disalin SEKALI di initState, sehingga menjadi sumber kebenaran kedua
  // dan tidak ikut berubah ketika parent memperbarui favorites.
  late int copiedCount;

  @override
  void initState() {
    super.initState();
    copiedCount = widget.favoriteCount;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Salinan state (tidak sinkron): $copiedCount | '
          'nilai sebenarnya: ${widget.favoriteCount}',
        ),
      ),
    );
  }
}

// ============ CHILD 2: DAFTAR COURSE (PROP DRILLING) ============

// Level 1: hanya meneruskan favorites dan onToggleFavorite ke bawah.
class CourseListPanel extends StatelessWidget {
  final List<DemoCourse> courses;
  final Set<String> favorites;
  final void Function(String code) onToggleFavorite;

  const CourseListPanel({
    super.key,
    required this.courses,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return CourseSection(
      title: 'Daftar Course',
      courses: courses,
      favorites: favorites, // PROP DRILLING: hanya diteruskan
      onToggleFavorite: onToggleFavorite, // PROP DRILLING: hanya diteruskan
    );
  }
}

// Level 2: juga hanya meneruskan, lalu mengubah favorites menjadi bool.
class CourseSection extends StatelessWidget {
  final String title;
  final List<DemoCourse> courses;
  final Set<String> favorites;
  final void Function(String code) onToggleFavorite;

  const CourseSection({
    super.key,
    required this.title,
    required this.courses,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: ListView(
            children: [
              for (final course in courses)
                CourseTile(
                  course: course,
                  isFavorite: favorites.contains(course.code),
                  onToggle: () => onToggleFavorite(course.code),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Level 3: baru di sini nilai dipakai untuk ditampilkan.
class CourseTile extends StatelessWidget {
  final DemoCourse course;
  final bool isFavorite;
  final VoidCallback onToggle;

  const CourseTile({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(course.title),
        subtitle: Text('${course.code} - ${course.credits} SKS'),
        trailing: FavoriteButton(isFavorite: isFavorite, onPressed: onToggle),
      ),
    );
  }
}

// Level 4: tombol yang benar-benar memicu perubahan state di parent.
class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isFavorite ? 'Hapus dari favorite' : 'Tambah favorite',
      onPressed: onPressed,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : null,
      ),
    );
  }
}
