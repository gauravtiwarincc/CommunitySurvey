import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/models/user.dart';
import 'package:community_survey/features/dashboard/dashboard_page.dart';
import 'package:community_survey/features/survey/survey_list_page.dart';
import 'package:community_survey/features/profile/profile_page.dart';
import 'package:community_survey/features/admin/admin_dashboard_page.dart';

class MainTabContainer extends ConsumerStatefulWidget {
  const MainTabContainer({super.key});

  @override
  ConsumerState<MainTabContainer> createState() => _MainTabContainerState();
}

class _MainTabContainerState extends ConsumerState<MainTabContainer> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userRole = authState.profile?.role ?? UserRole.user;
    final isAdmin = userRole == UserRole.admin || userRole == UserRole.superAdmin;

    final List<Widget> pages = [
      const DashboardPage(),
      const SurveyListPage(),
      const ProfilePage(),
      if (isAdmin) const AdminDashboardPage(),
    ];

    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard_outlined),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.assignment_outlined),
        activeIcon: Icon(Icons.assignment),
        label: 'Surveys',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
      if (isAdmin)
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings_outlined),
          activeIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}
