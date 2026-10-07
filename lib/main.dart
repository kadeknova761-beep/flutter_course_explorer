import 'package:flutter/material.dart';

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BreakpointPage(),
    );
  }
}

class BreakpointPage extends StatelessWidget {
  const BreakpointPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 3: LayoutBuilder')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (width < 600) {
            return CompactLayout(width: width);
          } else if (width < 840) {
            return MediumLayout(width: width);
          } else {
            return ExpandedLayout(width: width);
          }
        },
      ),
    );
  }
}

class LayoutHeader extends StatelessWidget {
  final String category;
  final double width;

  const LayoutHeader({super.key, required this.category, required this.width});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '$studentId - $studentName',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Kategori: $category',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text('maxWidth: ${width.toStringAsFixed(0)}'),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final Color color;

  const InfoCard({super.key, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('$studentId - $studentName'),
        ],
      ),
    );
  }
}

// Compact: satu panel biru, ditumpuk vertikal (1 kolom).
class CompactLayout extends StatelessWidget {
  final double width;

  const CompactLayout({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LayoutHeader(category: 'Compact', width: width),
          const SizedBox(height: 16),
          InfoCard(title: 'Panel 1 (1 kolom)', color: Colors.blue.shade100),
        ],
      ),
    );
  }
}

// Medium: dua panel hijau berdampingan (2 kolom).
class MediumLayout extends StatelessWidget {
  final double width;

  const MediumLayout({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LayoutHeader(category: 'Medium', width: width),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InfoCard(title: 'Panel 1', color: Colors.green.shade100),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCard(title: 'Panel 2', color: Colors.green.shade200),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Expanded: tiga panel oranye berdampingan (3 kolom).
class ExpandedLayout extends StatelessWidget {
  final double width;

  const ExpandedLayout({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          LayoutHeader(category: 'Expanded', width: width),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InfoCard(
                  title: 'Panel 1',
                  color: Colors.orange.shade100,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCard(
                  title: 'Panel 2',
                  color: Colors.orange.shade200,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoCard(
                  title: 'Panel 3',
                  color: Colors.orange.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
