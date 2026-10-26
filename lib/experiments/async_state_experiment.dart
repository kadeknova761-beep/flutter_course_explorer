import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../repositories/course_repository.dart';
import '../services/course_service.dart';

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

// Service JSON asli, tetapi ditunda agar indikator loading sempat terlihat.
class DelayedCourseService extends CourseService {
  @override
  Future<List<Course>> loadCourses() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return super.loadCourses();
  }
}

// Service yang selalu gagal untuk menguji tampilan error.
class FailingCourseService extends CourseService {
  @override
  Future<List<Course>> loadCourses() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    throw Exception('Gagal memuat data course (simulasi)');
  }
}

void main() {
  runApp(const AsyncStateExperimentApp());
}

class AsyncStateExperimentApp extends StatelessWidget {
  const AsyncStateExperimentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eksperimen Async State',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AsyncStateExperimentPage(),
    );
  }
}

class AsyncStateExperimentPage extends StatefulWidget {
  const AsyncStateExperimentPage({super.key});

  @override
  State<AsyncStateExperimentPage> createState() =>
      _AsyncStateExperimentPageState();
}

class _AsyncStateExperimentPageState extends State<AsyncStateExperimentPage> {
  bool simulateError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Async State')),
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
                ButtonSegment(value: false, label: Text('Berhasil')),
                ButtonSegment(value: true, label: Text('Error (simulasi)')),
              ],
              selected: {simulateError},
              onSelectionChanged: (values) {
                setState(() => simulateError = values.first);
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              // key berubah => provider dibuat ulang dan loadCourses() jalan lagi.
              child: ChangeNotifierProvider<CourseProvider>(
                key: ValueKey(simulateError),
                create: (_) => CourseProvider(
                  CourseRepository(
                    simulateError
                        ? FailingCourseService()
                        : DelayedCourseService(),
                  ),
                )..loadCourses(),
                child: const CourseStateView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// UI hanya membaca state dari provider, tanpa tahu cara data diambil.
class CourseStateView extends StatelessWidget {
  const CourseStateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Status: loading'),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                const Text('Status: error'),
                const SizedBox(height: 4),
                Text(provider.error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.read<CourseProvider>().loadCourses(),
                  child: const Text('Coba lagi'),
                ),
              ],
            ),
          );
        }

        final courses = provider.courses;
        if (courses.isEmpty) {
          return const Center(child: Text('Belum ada course'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: success (${courses.length} course)'),
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
        );
      },
    );
  }
}
