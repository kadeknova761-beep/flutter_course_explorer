import 'package:flutter/material.dart';

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

const List<String> skills = [
  'Flutter',
  'Dart',
  'Git',
  'GitHub',
  'JSON',
  'Responsive',
  'Navigation',
  'Widget',
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FlexiblePage(),
    );
  }
}

class FlexiblePage extends StatelessWidget {
  const FlexiblePage({super.key});

  Widget buildBox(String label, Color color) {
    return Container(
      height: 80,
      color: color,
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 4: Expanded, Flexible, Wrap')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '$studentId - $studentName',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('1. Expanded dengan flex 2:1'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: buildBox('A (flex 2)', Colors.blue.shade100),
                ),
                const SizedBox(width: 8),
                Expanded(child: buildBox('B (flex 1)', Colors.green.shade100)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('2. Row biasa (bisa overflow)'),
            const SizedBox(height: 8),
            Row(children: skills.map((e) => Chip(label: Text(e))).toList()),
            const SizedBox(height: 24),
            const Text('3. Wrap (pindah baris otomatis)'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((e) => Chip(label: Text(e))).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
