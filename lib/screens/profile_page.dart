import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/student_identity.dart';
import '../providers/course_provider.dart';
import '../widgets/feedback_form.dart';
import 'debug_challenge_pages.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // watch(): jumlah favorite ditampilkan dan harus ikut berubah.
    final int favoriteCount = context.watch<CourseProvider>().favoriteCount;
    debugPrint('[Rebuild] ProfilePage (watch)');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/profile.jpg',
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      width: 96,
                      height: 96,
                      child: Icon(Icons.person, size: 64),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                studentName,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Text(studentId),
              const Text('Kelas $studentClass - Semester $studentSemester'),
              const SizedBox(height: 8),
              Text('Course favorite: $favoriteCount'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DebugMenuPage()),
                  );
                },
                icon: const Icon(Icons.bug_report),
                label: const Text('Debugging Challenge (Tahap 16)'),
              ),
              const SizedBox(height: 16),
              const FeedbackForm(),
            ],
          ),
        ),
      ),
    );
  }
}
