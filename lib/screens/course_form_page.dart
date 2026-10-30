// Nama: Kadek Nova Krisna Putra | NIM: 2415051117 | Kelas: PTI 5C
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_identity.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../utils/course_status.dart';

// Form tambah course. Halaman ini tidak memanggil http; data dikirim lewat
// CourseProvider -> CourseRepository -> CourseApiService.
class CourseFormPage extends StatefulWidget {
  const CourseFormPage({super.key});

  @override
  State<CourseFormPage> createState() => _CourseFormPageState();
}

class _CourseFormPageState extends State<CourseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _creditsController = TextEditingController();
  String _status = 'planned';

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi';
    }
    return null;
  }

  String? _validateCredits(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'SKS wajib diisi';
    final credits = int.tryParse(text);
    if (credits == null) return 'SKS harus berupa angka';
    if (credits < 1) return 'SKS minimal 1';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CourseProvider>();
    if (provider.isSaving) return;

    final course = Course(
      code: _codeController.text.trim(),
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _status,
    );

    final success = await provider.createCourse(course);

    // Halaman bisa saja sudah ditutup selama request berjalan.
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course ${course.code} berhasil dibuat')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.saveError ?? 'Gagal membuat course')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // select(): hanya rebuild ketika status isSaving berubah.
    final isSaving = context.select<CourseProvider, bool>((p) => p.isSaving);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Course')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '$studentId - $studentName',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codeController,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: 'Kode course',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _validateRequired(v, 'Kode course'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    enabled: !isSaving,
                    decoration: const InputDecoration(
                      labelText: 'Judul course',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => _validateRequired(v, 'Judul course'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _creditsController,
                    enabled: !isSaving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'SKS',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateCredits,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const ['planned', 'active', 'done']
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text('${statusLabel(s)} ($s)'),
                          ),
                        )
                        .toList(),
                    onChanged: isSaving
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _status = value);
                            }
                          },
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    // null = tombol nonaktif selama request berjalan.
                    onPressed: isSaving ? null : _submit,
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Simpan'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
