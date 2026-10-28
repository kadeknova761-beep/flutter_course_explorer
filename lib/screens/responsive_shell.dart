import 'package:flutter/material.dart';

import 'courses_page.dart';
import 'favorites_page.dart';
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
  NavItem(Icons.favorite, 'Favorites'),
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

  // GlobalKey menjaga state halaman ketika layout berpindah
  // antara NavigationBar dan NavigationRail.
  final GlobalKey _contentKey = GlobalKey();

  // Data course dan favorite dikelola CourseProvider, sehingga shell hanya
  // mengatur navigasi.
  Widget _buildContent() {
    return IndexedStack(
      key: _contentKey,
      index: selectedIndex,
      children: const [
        HomePage(),
        CoursesPage(),
        FavoritesPage(),
        ProfilePage(),
      ],
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
