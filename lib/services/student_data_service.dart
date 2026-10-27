import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

// Membaca data mahasiswa dan course dari assets. Detail teknis akses file
// berada di layer service, bukan di screen.
/// Membaca assets/data/student_data.json lalu mengubahnya menjadi Map.
Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );
  return jsonDecode(jsonString) as Map<String, dynamic>;
}
