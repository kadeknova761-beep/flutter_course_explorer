// Nama: Kadek Nova Krisna Putra | NIM: 2415051117
//
// Tahap 8 (Pertemuan 6): model Course mengubah Map<String, dynamic> dari JSON
// menjadi object bertipe sehingga UI tidak lagi mengakses key string langsung.
class Course {
  final String code;
  final String title;
  final int credits;
  final String status;

  const Course({
    required this.code,
    required this.title,
    required this.credits,
    required this.status,
  });

  // Seluruh parsing JSON dipusatkan di sini. Jika key hilang atau tipenya
  // salah, error muncul saat parsing, bukan tersebar di widget.
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      code: json['code'] as String,
      title: json['title'] as String,
      credits: json['credits'] as int,
      status: json['status'] as String,
    );
  }

  @override
  String toString() {
    return 'Course(code: $code, title: $title, credits: $credits, '
        'status: $status)';
  }
}
