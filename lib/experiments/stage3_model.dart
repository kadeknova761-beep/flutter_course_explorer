// Eksperimen Tahap 3 - JSON ke List<Course> (sementara, dipindah ke service di Tahap 4)
// Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C
//
// Jalankan: flutter run -d chrome -t lib/experiments/stage3_model.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/student_identity.dart';
import '../models/course.dart';

const String apiUrl = 'https://course-api-pearl.vercel.app/courses';

Future<List<Course>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
  }
  throw Exception('HTTP ${response.statusCode}');
}

void main() => runApp(const Stage3App());

class Stage3App extends StatelessWidget {
  const Stage3App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stage3Page(),
    );
  }
}

class Stage3Page extends StatefulWidget {
  const Stage3Page({super.key});

  @override
  State<Stage3Page> createState() => _Stage3PageState();
}

class _Stage3PageState extends State<Stage3Page> {
  bool _loading = false;
  String? _error;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await fetchCourses();
      debugPrint('Jumlah Course: ${data.length}');
      setState(() => _courses = data);
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Model Course dari JSON')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$studentName | $studentId | $studentClass'),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            if (_error == null && !_loading) ...[
              Text(
                'List<Course>: ${_courses.length} item',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_courses.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('toJson() course pertama: ${_courses.first.toJson()}'),
              ],
            ],
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  for (final c in _courses.take(5))
                    ListTile(
                      title: Text('${c.code} - ${c.title}'),
                      subtitle: Text(
                        'status: ${c.status} | sks: ${c.credits} | id: ${c.id}',
                      ),
                    ),
                ],
              ),
            ),
            FilledButton(onPressed: _load, child: const Text('Muat ulang')),
          ],
        ),
      ),
    );
  }
}
