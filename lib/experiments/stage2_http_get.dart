// Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/student_identity.dart';

// Ganti nilai ini ke URL salah (misalnya /coursez) untuk menguji error, lalu kembalikan.
const String apiUrl = 'https://course-api-pearl.vercel.app/courses';

Future<List<dynamic>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as List<dynamic>;
  }
  throw Exception('HTTP ${response.statusCode}');
}

void main() => runApp(const Stage2App());

class Stage2App extends StatelessWidget {
  const Stage2App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stage2Page(),
    );
  }
}

class Stage2Page extends StatefulWidget {
  const Stage2Page({super.key});

  @override
  State<Stage2Page> createState() => _Stage2PageState();
}

class _Stage2PageState extends State<Stage2Page> {
  bool _loading = false;
  String? _error;
  List<dynamic> _items = [];

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
      debugPrint('Jumlah item: ${data.length}');
      setState(() => _items = data);
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
      appBar: AppBar(title: const Text('HTTP GET Courses')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$studentName | $studentId | $studentClass'),
            const SizedBox(height: 8),
            Text('Endpoint: $apiUrl'),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            if (_error == null && !_loading)
              Text(
                'Jumlah item: ${_items.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  for (final item in _items.take(5))
                    ListTile(
                      title: Text('${item['code']} - ${item['title']}'),
                      subtitle: Text('status: ${item['status']}'),
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
