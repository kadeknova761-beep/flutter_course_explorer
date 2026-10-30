// Model Course (Pertemuan 7, Tahap 3)
// Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C

class Course {
  final int? id;
  final String code;
  final String title;
  final int credits;
  final String status;

  const Course({
    this.id,
    required this.code,
    required this.title,
    required this.credits,
    this.status = 'planned',
  });

  /// Field tambahan dari API (misalnya created_at) sengaja diabaikan.
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int?,
      code: json['code'] as String,
      title: json['title'] as String,
      credits: json['credits'] as int,
      status: (json['status'] as String?) ?? 'planned',
    );
  }

  /// id tidak dikirim karena dibuat oleh server.
  Map<String, dynamic> toJson() => {
    'code': code,
    'title': title,
    'credits': credits,
    'status': status,
  };

  Course copyWith({
    int? id,
    String? code,
    String? title,
    int? credits,
    String? status,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      credits: credits ?? this.credits,
      status: status ?? this.status,
    );
  }
}
