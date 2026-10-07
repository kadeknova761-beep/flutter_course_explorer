import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const String studentName = 'Kadek Nova Krisna Putra';
const String studentId = '2415051117';
const String studentClass = 'PTI 5C';

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

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavItem(this.icon, this.selectedIcon, this.label);
}

const List<NavItem> navItems = [
  NavItem(Icons.home_outlined, Icons.home, 'Home'),
  NavItem(Icons.school_outlined, Icons.school, 'Courses'),
  NavItem(Icons.person_outline, Icons.person, 'Profile'),
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
      home: ResponsiveShell(),
    );
  }
}

class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int selectedIndex = 0;

  final List<Widget> pages = const [HomePage(), CoursesPage(), ProfilePage()];

  void selectIndex(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width >= 840;
        final category = width < 600
            ? 'Compact'
            : (width < 840 ? 'Medium' : 'Expanded');

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Tahap 11: ${navItems[selectedIndex].label} ($category)',
            ),
          ),
          body: Row(
            children: [
              if (isWide)
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: selectIndex,
                  labelType: NavigationRailLabelType.all,
                  destinations: navItems
                      .map(
                        (item) => NavigationRailDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: Text(item.label),
                        ),
                      )
                      .toList(),
                ),
              if (isWide) const VerticalDivider(width: 1),
              Expanded(
                key: const ValueKey('page-content'),
                child: IndexedStack(index: selectedIndex, children: pages),
              ),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: selectIndex,
                  destinations: navItems
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icon),
                          selectedIcon: Icon(item.selectedIcon),
                          label: item.label,
                        ),
                      )
                      .toList(),
                ),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.home, size: 64),
          SizedBox(height: 12),
          Text(
            '$studentId - $studentName',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text('Selamat datang di Course Explorer'),
        ],
      ),
    );
  }
}

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late Future<List<Map<String, dynamic>>> coursesFuture;

  @override
  void initState() {
    super.initState();
    coursesFuture = loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '$studentId - $studentName',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      trailing: Text(
                        statusLabel(status),
                        style: TextStyle(
                          color: statusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundImage: AssetImage('assets/images/profile.jpg'),
          ),
          const SizedBox(height: 12),
          const Text(
            studentName,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text(studentId),
          const SizedBox(height: 16),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.badge),
                  title: Text('NIM'),
                  subtitle: Text(studentId),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Nama'),
                  subtitle: Text(studentName),
                ),
                ListTile(
                  leading: Icon(Icons.groups),
                  title: Text('Kelas'),
                  subtitle: Text(studentClass),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
