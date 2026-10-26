import 'package:flutter/material.dart';

import '../models/course.dart';
import '../services/course_service.dart';

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

void main() {
  runApp(const CourseServiceExperimentApp());
}

class CourseServiceExperimentApp extends StatelessWidget {
  const CourseServiceExperimentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eksperimen CourseService',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CourseServiceExperimentPage(),
    );
  }
}

class CourseServiceExperimentPage extends StatefulWidget {
  const CourseServiceExperimentPage({super.key});

  @override
  State<CourseServiceExperimentPage> createState() =>
      _CourseServiceExperimentPageState();
}

class _CourseServiceExperimentPageState
    extends State<CourseServiceExperimentPage> {
  final CourseService service = CourseService();

  // Future dibuat satu kali agar service tidak dipanggil ulang saat rebuild.
  late final Future<List<Course>> future = _load();

  Future<List<Course>> _load() async {
    final courses = await service.loadCourses();

    // Pengujian sementara lewat debugPrint.
    debugPrint('CourseService mengembalikan ${courses.length} course');
    for (final course in courses) {
      debugPrint(course.toString());
    }
    return courses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Service')),
      body: FutureBuilder<List<Course>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Gagal memuat course: ${snapshot.error}'),
              ),
            );
          }

          final courses = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$studentId - $studentName',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tipe hasil service: ${courses.runtimeType}\n'
                  'Jumlah course: ${courses.length}',
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      return Card(
                        child: ListTile(
                          title: Text(course.title),
                          subtitle: Text(
                            '${course.code} - ${course.credits} SKS - '
                            '${course.status}',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
