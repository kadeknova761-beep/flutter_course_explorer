// Nama: Kadek Nova Krisna Putra | NIM: 2415051117

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';

// ===== KLASIFIKASI STATE (PERTEMUAN 6 - TAHAP 1) =====
// LOCAL STATE (hanya dipakai satu widget, dikelola dengan setState):
//   1. selectedIndex   -> _ResponsiveShellState (tab aktif navigasi)
//   2. isLoading       -> _FeedbackFormState (loading saat kirim feedback)
//   3. showDetail      -> _CourseDetailPageState (show/hide deskripsi course)
//   4. keyboardOpen    -> _KeyboardCasePageState (simulasi keyboard)
// SHARED STATE (dibutuhkan beberapa screen/widget):
//   5. favorites       -> CourseProvider (Provider), dipakai Home, Courses, Profile
//   6. data courses    -> CourseProvider.loadCourses() (Provider -> Repository -> Service)

void main() {
  // Tahap 6: CourseProvider disediakan di atas MyApp sehingga seluruh
  // widget di bawahnya dapat mengaksesnya (dipakai mulai Tahap 7).
  runApp(
    ChangeNotifierProvider(
      // loadCourses(): course dimuat lewat Provider -> Repository -> Service.
      create: (_) =>
          CourseProvider(CourseRepository(CourseService()))..loadCourses(),
      child: const MyApp(),
    ),
  );
}
