import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

// Nama: Kadek Nova Krisna Putra | NIM: 2415051117
//
// CourseProvider menyimpan dua kelompok state:
//   1. Async state data course: courses, isLoading, error (Tahap 11)
//   2. Shared state favorites: favorites dan toggleFavorite (Tahap 5)
// Provider hanya berbicara dengan repository, tidak dengan rootBundle.
class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  // ===================== ASYNC STATE =====================

  List<Course> _courses = [];
  bool _isLoading = false;
  String? _error;

  // Getter read-only: UI hanya membaca, perubahan lewat method di class ini.
  List<Course> get courses => List.unmodifiable(_courses);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCourses() async {
    // Hindari pemanggilan ganda ketika proses sebelumnya masih berjalan.
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await repository.getCourses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===================== SHARED STATE: FAVORITES =====================

  final Set<String> _favorites = {};

  Set<String> get favorites => Set.unmodifiable(_favorites);

  int get favoriteCount => _favorites.length;

  bool isFavorite(String code) => _favorites.contains(code);

  // Menambah atau menghapus course dari favorite.
  void toggleFavorite(String code) {
    if (_favorites.contains(code)) {
      _favorites.remove(code);
    } else {
      _favorites.add(code);
    }
    // Wajib dipanggil setelah state berubah agar listener membangun ulang UI.
    notifyListeners();
  }

  // Dipakai ketika course dipilih dari halaman detail.
  void addFavorite(String code) {
    // add() mengembalikan false jika code sudah ada, jadi tidak perlu notify.
    if (_favorites.add(code)) {
      notifyListeners();
    }
  }

  void clearFavorites() {
    if (_favorites.isEmpty) return;
    _favorites.clear();
    notifyListeners();
  }

  // ===================== PENGAMAN DISPOSE =====================

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // Proses async bisa selesai setelah provider dibuang (misalnya halaman
  // ditutup saat loading). Tanpa pengecekan ini akan terjadi error
  // "used after being disposed".
  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }
}
