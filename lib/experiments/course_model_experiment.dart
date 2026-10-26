import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/course.dart';

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

void main() {
  runApp(const CourseModelExperimentApp());
}

class CourseModelExperimentApp extends StatelessWidget {
  const CourseModelExperimentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eksperimen Model Course',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CourseModelExperimentPage(),
    );
  }
}

// Hasil membaca JSON: Map mentah dan object Course hasil parsing.
class ParsedFirstCourse {
  final Map<String, dynamic> rawJson;
  final Course course;
  final int totalCourses;

  const ParsedFirstCourse(this.rawJson, this.course, this.totalCourses);
}

Future<ParsedFirstCourse> loadFirstCourse() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );
  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final list = data['courses'] as List<dynamic>;

  // Satu data JSON (Map) diubah menjadi satu object Course.
  final rawFirst = list.first as Map<String, dynamic>;
  final course = Course.fromJson(rawFirst);

  debugPrint('Hasil parsing: $course');
  return ParsedFirstCourse(rawFirst, course, list.length);
}

class CourseModelExperimentPage extends StatefulWidget {
  const CourseModelExperimentPage({super.key});

  @override
  State<CourseModelExperimentPage> createState() =>
      _CourseModelExperimentPageState();
}

class _CourseModelExperimentPageState extends State<CourseModelExperimentPage> {
  // Future dibuat satu kali agar tidak memuat ulang pada setiap rebuild.
  late final Future<ParsedFirstCourse> future = loadFirstCourse();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Model Course')),
      body: FutureBuilder<ParsedFirstCourse>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Gagal parsing: ${snapshot.error}'),
              ),
            );
          }

          final parsed = snapshot.data!;
          final course = parsed.course;
          const encoder = JsonEncoder.withIndent('  ');

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$studentId - $studentName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  '1. Data JSON mentah (Map<String, dynamic>)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(encoder.convert(parsed.rawJson)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '2. Setelah Course.fromJson() (object bertipe)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.title),
                        title: Text(course.title),
                        subtitle: const Text('course.title (String)'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.tag),
                        title: Text(course.code),
                        subtitle: const Text('course.code (String)'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.school),
                        title: Text('${course.credits} SKS'),
                        subtitle: const Text('course.credits (int)'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.flag),
                        title: Text(course.status),
                        subtitle: const Text('course.status (String)'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total course di JSON: ${parsed.totalCourses} '
                  '(yang diparsing pada demo ini: 1)',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
