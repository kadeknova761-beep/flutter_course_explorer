import 'package:flutter/material.dart';

import '../services/student_data_service.dart';
import 'courses_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem(this.icon, this.label);
}

const List<NavItem> navItems = [
  NavItem(Icons.home, 'Home'),
  NavItem(Icons.school, 'Courses'),
  NavItem(Icons.person, 'Profile'),
];

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  // LOCAL STATE: tab aktif hanya dipakai oleh shell ini.
  int selectedIndex = 0;

  // late: diisi di initState(), Future dibuat satu kali.
  late Future<Map<String, dynamic>> studentFuture;

  // SHARED STATE favorites kini dikelola CourseProvider (Tahap 7),
  // sehingga shell tidak perlu menyimpannya lagi.

  // GlobalKey menjaga state halaman ketika layout berpindah
  // antara NavigationBar dan NavigationRail.
  final GlobalKey _contentKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  Widget _buildContent() {
    return FutureBuilder<Map<String, dynamic>>(
      key: _contentKey,
      future: studentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal memuat data: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final student = data['student'] as Map<String, dynamic>;
        final courses = (data['courses'] as List<dynamic>)
            .map((c) => c as Map<String, dynamic>)
            .toList();

        return IndexedStack(
          index: selectedIndex,
          children: [
            HomePage(student: student, courses: courses),
            CoursesPage(courses: courses),
            ProfilePage(student: student),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isExpanded = constraints.maxWidth >= 840;
        final appBar = AppBar(
          title: Text('Course Explorer - ${navItems[selectedIndex].label}'),
        );

        // Compact dan medium: NavigationBar di bawah.
        if (!isExpanded) {
          return Scaffold(
            appBar: appBar,
            body: _buildContent(),
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() => selectedIndex = index);
              },
              destinations: [
                for (final item in navItems)
                  NavigationDestination(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
              ],
            ),
          );
        }

        // Expanded: NavigationRail di sisi kiri.
        return Scaffold(
          appBar: appBar,
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: (index) {
                  setState(() => selectedIndex = index);
                },
                destinations: [
                  for (final item in navItems)
                    NavigationRailDestination(
                      icon: Icon(item.icon),
                      label: Text(item.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: _buildContent()),
            ],
          ),
        );
      },
    );
  }
}
