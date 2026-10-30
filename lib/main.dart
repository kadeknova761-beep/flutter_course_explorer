// Nama: Kadek Nova Krisna Putra | NIM: 2415051117

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'constants/api_config.dart';
import 'constants/supabase_config.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_api_service.dart';

// ===== KLASIFIKASI STATE (PERTEMUAN 6 - TAHAP 1) =====
// LOCAL STATE (hanya dipakai satu widget, dikelola dengan setState):
//   1. selectedIndex   -> _ResponsiveShellState (tab aktif navigasi)
//   2. isLoading       -> _FeedbackFormState (loading saat kirim feedback)
//   3. showDetail      -> _CourseDetailPageState (show/hide deskripsi course)
//   4. keyboardOpen    -> _KeyboardCasePageState (simulasi keyboard)
// SHARED STATE (dibutuhkan beberapa screen/widget):
//   5. favorites       -> CourseProvider (Provider), dipakai Home, Courses, Profile
//   6. data courses    -> CourseProvider.loadCourses() (Provider -> Repository -> CourseApiService)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tahap 10: Supabase diinisialisasi sebelum runApp().
  // Nilai URL dan key berasal dari env.json (tidak masuk Git).
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'SUPABASE_URL / SUPABASE_ANON_KEY kosong. Jalankan dengan: '
      'flutter run -d chrome --dart-define-from-file=env.json',
    );
  }
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // Tahap 6: CourseProvider disediakan di atas MyApp sehingga seluruh
  // widget di bawahnya dapat mengaksesnya (dipakai mulai Tahap 7).
  // Perakitan service -> repository -> provider tetap di sini. Sumber data
  // masih REST API; pindah ke Supabase dilakukan di Tahap 12 dengan
  // mengubah satu baris CourseApiService di bawah.
  runApp(
    ChangeNotifierProvider(
      create: (_) =>
          CourseProvider(CourseRepository(CourseApiService(apiBaseUrl)))
            ..loadCourses(),
      child: const MyApp(),
    ),
  );
}
