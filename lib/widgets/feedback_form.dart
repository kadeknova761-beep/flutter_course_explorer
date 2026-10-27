import 'package:flutter/material.dart';

import '../constants/student_identity.dart';

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Nama dan NIM terisi default dari konstanta identitas.
  final TextEditingController nameController = TextEditingController(
    text: studentName,
  );
  final TextEditingController nimController = TextEditingController(
    text: studentId,
  );
  final TextEditingController commentController = TextEditingController();

  String result = 'Belum ada feedback terkirim';

  // LOCAL STATE: status loading hanya relevan untuk form ini.
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    nimController.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    // 1. Validasi form sebelum melanjutkan.
    if (!formKey.currentState!.validate()) return;

    // 2. AlertDialog konfirmasi sebelum aksi penting.
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: Text(
            'Kirim feedback sebagai '
            '${nameController.text.trim()} (${nimController.text.trim()})?\n\n'
            '"${commentController.text.trim()}"',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (confirmed != true) return; // dibatalkan, tidak ada proses lanjutan

    // 3. Simulasi loading singkat dengan CircularProgressIndicator.
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));

    // Cek mounted sebelum memakai context/setState setelah await.
    if (!mounted) return;

    setState(() {
      isLoading = false;
      result =
          'Terkirim oleh ${nameController.text.trim()} '
          '(${nimController.text.trim()}): '
          '"${commentController.text.trim()}"';
    });

    // 4. SnackBar sebagai feedback singkat setelah berhasil.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Feedback berhasil dikirim')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Form Feedback',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nimController,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'NIM wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Komentar',
                  hintText: 'Tulis komentar minimal 5 karakter',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 5) {
                    return 'Komentar minimal 5 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  // Dinonaktifkan saat loading agar tidak terkirim dua kali.
                  onPressed: isLoading ? null : submit,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(isLoading ? 'Mengirim...' : 'Kirim Feedback'),
                ),
              ),
              const SizedBox(height: 12),
              Text(result),
            ],
          ),
        ),
      ),
    );
  }
}
