import 'package:flutter/foundation.dart';

// Nama: Kadek Nova Krisna Putra | NIM: 2415051117
//
class CourseProvider extends ChangeNotifier {
  // State dibuat private agar hanya bisa diubah lewat method di class ini.
  final Set<String> _favorites = {};

  // Getter read-only: UI boleh membaca, tetapi tidak boleh mengubah langsung.
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
}
