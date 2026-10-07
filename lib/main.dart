import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

/// Membaca assets/data/student_data.json lalu mengubahnya menjadi Map.
Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

// ===== Helper status course (dipakai di beberapa widget) =====
IconData statusIcon(String status) {
  switch (status) {
    case 'done':
      return Icons.check_circle;
    case 'active':
      return Icons.play_circle;
    default:
      return Icons.schedule;
  }
}

Color statusColor(String status) {
  switch (status) {
    case 'done':
      return Colors.green;
    case 'active':
      return Colors.blue;
    default:
      return Colors.orange;
  }
}

String statusLabel(String status) {
  switch (status) {
    case 'done':
      return 'Selesai';
    case 'active':
      return 'Berjalan';
    default:
      return 'Rencana';
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ResponsiveShell(),
    );
  }
}

// ===================== SHELL & NAVIGASI =====================

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

const List<NavItem> navItems = [
  NavItem(Icons.home, 'Home'),
  NavItem(Icons.school, 'Courses'),
  NavItem(Icons.person, 'Profile'),
];

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int selectedIndex = 0;

  // late: diisi di initState(), Future dibuat satu kali.
  late Future<Map<String, dynamic>> studentFuture;

  // State favorite dipusatkan di shell agar dipakai Home, Courses, Profile.
  final Set<String> favorites = {};

  // GlobalKey menjaga state halaman ketika layout berpindah
  // antara NavigationBar dan NavigationRail.
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  void toggleFavorite(String code) {
    setState(() {
      if (favorites.contains(code)) {
        favorites.remove(code);
      } else {
        favorites.add(code);
      }
    });
  }

  void addFavorite(String code) {
    setState(() => favorites.add(code));
  }

  Widget _buildContent() {
    return FutureBuilder<Map<String, dynamic>>(
      key: _contentKey,
      future: studentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal memuat data: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final student = data['student'] as Map<String, dynamic>;
        final courses = (data['courses'] as List<dynamic>)
            .map((c) => c as Map<String, dynamic>)
            .toList();

        return IndexedStack(
          index: selectedIndex,
          children: [
            HomePage(student: student, courses: courses, favorites: favorites),
            CoursesPage(
              courses: courses,
              favorites: favorites,
              onToggleFavorite: toggleFavorite,
              onAddFavorite: addFavorite,
            ),
            ProfilePage(student: student, favoriteCount: favorites.length),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isExpanded = constraints.maxWidth >= 840;
        final appBar = AppBar(
          title: Text('Course Explorer - ${navItems[selectedIndex].label}'),
        );

        // Compact dan medium: NavigationBar di bawah.
        if (!isExpanded) {
          return Scaffold(
            appBar: appBar,
            body: _buildContent(),
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() => selectedIndex = index);
              },
              destinations: [
                for (final item in navItems)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
          );
        }

        // Expanded: NavigationRail di sisi kiri.
        return Scaffold(
          appBar: appBar,
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: (index) {
                  setState(() => selectedIndex = index);
                },
                destinations: [
                  for (final item in navItems)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }
}

// ========================= HOME =========================

class HomePage extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<Map<String, dynamic>> courses;
  final Set<String> favorites;

  const HomePage({
    super.key,
    required this.student,
    required this.courses,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    final int totalCredits = courses.fold<int>(
      0,
      (sum, c) => sum + (c['credits'] as int),
    );
    final int doneCount = courses.where((c) => c['status'] == 'done').length;
    final favoriteCourses = courses
        .where((c) => favorites.contains(c['code']))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.badge, size: 36),
              title: Text(
                student['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${student['nim']} - ${student['kelas']}'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SummaryCard(
                icon: Icons.menu_book,
                value: '${courses.length}',
                label: 'Materi',
              ),
              SummaryCard(
                icon: Icons.school,
                value: '$totalCredits',
                label: 'Total SKS',
              ),
              SummaryCard(
                icon: Icons.favorite,
                value: '${favorites.length}',
                label: 'Favorite',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$doneCount dari ${courses.length} materi selesai'),
          const SizedBox(height: 16),
          const Text(
            'Course Favorit',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (favoriteCourses.isEmpty)
            const Text(
              'Belum ada favorite. Buka tab Courses lalu tekan ikon hati '
              'atau tombol Tambah ke Favorite di halaman detail.',
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in favoriteCourses)
                  Chip(
                    avatar: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 18,
                    ),
                    label: Text(c['title'] as String),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

// ======================== COURSES ========================

class CoursesPage extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final Set<String> favorites;
  final void Function(String code) onToggleFavorite;
  final void Function(String code) onAddFavorite;

  const CoursesPage({
    super.key,
    required this.courses,
    required this.favorites,
    required this.onToggleFavorite,
    required this.onAddFavorite,
  });

  int columnsFor(double width) {
    if (width < 600) return 1;
    if (width < 840) return 2;
    return 3;
  }

  // Tap: buka detail, tunggu hasil (true jika dipilih sebagai favorite).
  Future<void> openDetail(
    BuildContext context,
    Map<String, dynamic> course,
  ) async {
    final String code = course['code'] as String;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailPage(
          course: course,
          isFavorite: favorites.contains(code),
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == true) {
      onAddFavorite(code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${course['title']} ditambahkan ke favorite')),
      );
    }
  }

  // Long press: tampilkan info singkat course.
  void showInfo(BuildContext context, Map<String, dynamic> course) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        final String status = course['status'] as String;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['title'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Kode: ${course['code']}'),
              Text('SKS: ${course['credits']}'),
              Text('Status: ${statusLabel(status)}'),
              const SizedBox(height: 8),
              Text('Dilihat oleh: $studentId - $studentName'),
              const SizedBox(height: 8),
              const Text('(Info ini muncul dari gesture long press)'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = columnsFor(constraints.maxWidth);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                '$studentId - $studentName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '${favorites.length} favorite | $columns kolom | '
              '${constraints.maxWidth.toStringAsFixed(0)} px',
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 120,
                ),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  final String code = course['code'] as String;

                  return CourseCard(
                    course: course,
                    isFavorite: favorites.contains(code),
                    onTap: () => openDetail(context, course),
                    onLongPress: () => showInfo(context, course),
                    onFavorite: () => onToggleFavorite(code),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Reusable widget: kartu course yang bisa di-tap, long press, dan favorite.
class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onFavorite;

  const CourseCard({
    super.key,
    required this.course,
    required this.isFavorite,
    required this.onTap,
    required this.onLongPress,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final String status = course['status'] as String;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias, // agar ripple InkWell mengikuti bentuk Card
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(statusIcon(status), color: statusColor(status), size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${course['code']} - ${course['credits']} SKS'),
                    const SizedBox(height: 4),
                    Text(
                      statusLabel(status),
                      style: TextStyle(
                        color: statusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Tombol favorite dengan icon berbeda untuk aktif/nonaktif.
              IconButton(
                tooltip: isFavorite ? 'Hapus dari favorite' : 'Tambah favorite',
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ====================== DETAIL COURSE ======================

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isFavorite;

  const CourseDetailPage({
    super.key,
    required this.course,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    final String status = course['status'] as String;

    return Scaffold(
      appBar: AppBar(title: Text(course['title'] as String)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$studentId - $studentName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: Icon(
                      statusIcon(status),
                      color: statusColor(status),
                      size: 36,
                    ),
                    title: Text(course['title'] as String),
                    subtitle: Text(
                      '${course['code']} - ${course['credits']} SKS - '
                      '${statusLabel(status)}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Jika sudah favorite, tombol dinonaktifkan.
                FilledButton.icon(
                  onPressed: isFavorite
                      ? null
                      : () => Navigator.pop(context, true),
                  icon: Icon(isFavorite ? Icons.check : Icons.favorite),
                  label: Text(
                    isFavorite ? 'Sudah di Favorite' : 'Tambah ke Favorite',
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Kembali tanpa memilih'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========================= PROFILE =========================

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> student;
  final int favoriteCount;

  const ProfilePage({
    super.key,
    required this.student,
    required this.favoriteCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/profile.jpg',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: 96,
                      height: 96,
                      child: Icon(Icons.person, size: 64),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                student['name'] as String,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('${student['nim']}'),
              Text(
                'Kelas ${student['kelas']} - Semester ${student['semester']}',
              ),
              const SizedBox(height: 8),
              Text('Course favorite: $favoriteCount'),
              const SizedBox(height: 16),
              const FeedbackForm(),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ FORM FEEDBACK + DIALOG + SNACKBAR + LOADING ============

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Nama dan NIM terisi default dari konstanta identitas.
  final TextEditingController nameController = TextEditingController(
    text: studentName,
  );
  final TextEditingController nimController = TextEditingController(
    text: studentId,
  );
  final TextEditingController commentController = TextEditingController();

  String result = 'Belum ada feedback terkirim';
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    nimController.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    // 1. Validasi form sebelum melanjutkan.
    if (!formKey.currentState!.validate()) return;

    // 2. AlertDialog konfirmasi sebelum aksi penting.
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text(
            'Kirim feedback sebagai '
            '${nameController.text.trim()} (${nimController.text.trim()})?\n\n'
            '"${commentController.text.trim()}"',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmed != true) return; // dibatalkan, tidak ada proses lanjutan

    // 3. Simulasi loading singkat dengan CircularProgressIndicator.
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    // Cek mounted sebelum memakai context/setState setelah await.
    if (!mounted) return;

    setState(() {
      isLoading = false;
      result =
          'Terkirim oleh ${nameController.text.trim()} '
          '(${nimController.text.trim()}): '
          '"${commentController.text.trim()}"';
    });

    // 4. SnackBar sebagai feedback singkat setelah berhasil.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Feedback berhasil dikirim')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Form Feedback',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nimController,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'NIM wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Komentar',
                  hintText: 'Tulis komentar minimal 5 karakter',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 5) {
                    return 'Komentar minimal 5 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  // Dinonaktifkan saat loading agar tidak terkirim dua kali.
                  onPressed: isLoading ? null : submit,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(isLoading ? 'Mengirim...' : 'Kirim Feedback'),
                ),
              ),
              const SizedBox(height: 12),
              Text(result),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= REUSABLE =======================

class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
