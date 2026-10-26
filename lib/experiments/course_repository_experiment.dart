import 'package:flutter/material.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';
import '../services/course_service.dart';

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

// Service tiruan yang mensimulasikan data dari API. Dibuat hanya untuk demo.
class FakeApiCourseService extends CourseService {
  @override
  Future<List<Course>> loadCourses() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return const [
      Course(
        code: 'API01',
        title: 'Course dari API (simulasi)',
        credits: 2,
        status: 'active',
      ),
      Course(
        code: 'API02',
        title: 'Repository Pattern',
        credits: 3,
        status: 'planned',
      ),
    ];
  }
}

void main() {
  runApp(const CourseRepositoryExperimentApp());
}

class CourseRepositoryExperimentApp extends StatelessWidget {
  const CourseRepositoryExperimentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eksperimen CourseRepository',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CourseRepositoryExperimentPage(),
    );
  }
}

class CourseRepositoryExperimentPage extends StatefulWidget {
  const CourseRepositoryExperimentPage({super.key});

  @override
  State<CourseRepositoryExperimentPage> createState() =>
      _CourseRepositoryExperimentPageState();
}

class _CourseRepositoryExperimentPageState
    extends State<CourseRepositoryExperimentPage> {
  bool useFakeApi = false;
  late Future<List<Course>> future = _load();

  Future<List<Course>> _load() {
    // Hanya baris ini yang tahu service mana yang dipakai. Repository dan UI
    // di bawahnya sama persis untuk kedua sumber data.
    final CourseService service = useFakeApi
        ? FakeApiCourseService()
        : CourseService();
    final repository = CourseRepository(service);

    debugPrint('Repository memakai ${service.runtimeType}');
    return repository.getCourses();
  }

  void _changeSource(bool fakeApi) {
    setState(() {
      useFakeApi = fakeApi;
      future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Repository')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$studentId - $studentName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('JSON asset')),
                ButtonSegment(value: true, label: Text('API (simulasi)')),
              ],
              selected: {useFakeApi},
              onSelectionChanged: (values) => _changeSource(values.first),
            ),
            const SizedBox(height: 8),
            Text(
              'Sumber data: ${useFakeApi ? 'FakeApiCourseService' : 'CourseService'}',
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Course>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Gagal: ${snapshot.error}'));
                  }

                  final courses = snapshot.data!;
                  return ListView.builder(
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
