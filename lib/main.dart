import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

Future<List<Map<String, dynamic>>> loadCourses() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );
  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final courses = data['courses'] as List<dynamic>;
  return courses.map((e) => e as Map<String, dynamic>).toList();
}

Color statusColor(String status) {
  switch (status) {
    case 'done':
      return Colors.green;
    case 'active':
      return Colors.blue;
    default:
      return Colors.orange;
  }
}

String statusLabel(String status) {
  switch (status) {
    case 'done':
      return 'Selesai';
    case 'active':
      return 'Berjalan';
    default:
      return 'Rencana';
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CourseListPage(),
    );
  }
}

class CourseListPage extends StatefulWidget {
  const CourseListPage({super.key});

  @override
  State<CourseListPage> createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  late Future<List<Map<String, dynamic>>> coursesFuture;

  @override
  void initState() {
    super.initState();
    coursesFuture = loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 8: List ke Detail')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '$studentId - $studentName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat data: ${snapshot.error}'),
                  );
                }

                final courses = snapshot.data!;

                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    final status = course['status'] as String;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.menu_book,
                          color: statusColor(status),
                        ),
                        title: Text(course['title'] as String),
                        subtitle: Text(
                          '${course['code']} - ${course['credits']} SKS',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourseDetailPage(course: course),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final status = course['status'] as String;
    final color = statusColor(status);

    return Scaffold(
      appBar: AppBar(title: Text(course['title'] as String)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '$studentId - $studentName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.title),
                    title: const Text('Judul'),
                    subtitle: Text(course['title'] as String),
                  ),
                  ListTile(
                    leading: const Icon(Icons.tag),
                    title: const Text('Kode'),
                    subtitle: Text(course['code'] as String),
                  ),
                  ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text('SKS'),
                    subtitle: Text('${course['credits']} SKS'),
                  ),
                  ListTile(
                    leading: Icon(Icons.circle, color: color),
                    title: const Text('Status'),
                    subtitle: Text(
                      statusLabel(status),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
