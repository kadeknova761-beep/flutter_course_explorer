import 'package:flutter/material.dart';

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';

// false = tanpa scroll (untuk melihat masalah)
// true  = dengan SingleChildScrollView (perbaikan)
const bool useScroll = true;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileFormPage(),
    );
  }
}

class ProfileFormPage extends StatelessWidget {
  const ProfileFormPage({super.key});

  Widget buildField(String label, {String? initialValue, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CircleAvatar(radius: 36, child: Icon(Icons.person, size: 40)),
        const SizedBox(height: 12),
        const Text(
          '$studentId - $studentName',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text('Profil Mahasiswa', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        buildField('Nama', initialValue: studentName),
        buildField('NIM', initialValue: studentId),
        buildField('Email'),
        buildField('Program Studi'),
        buildField('Kelas', initialValue: 'PTI 5C'),
        buildField('Alamat'),
        buildField('Catatan', maxLines: 3),
        ElevatedButton(onPressed: () {}, child: const Text('Simpan')),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Tahap 6: Scrollable Content')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: useScroll ? SingleChildScrollView(child: content) : content,
      ),
    );
  }
}
