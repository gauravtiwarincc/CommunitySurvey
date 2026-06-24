import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/features/dashboard/dashboard_page.dart';
import 'package:community_survey/features/survey/survey_list_page.dart';
import 'package:community_survey/features/profile/profile_page.dart';
import 'package:community_survey/features/admin/admin_dashboard_page.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/features/web/widgets/web_header.dart';
import 'package:community_survey/features/web/widgets/web_footer.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/models/user.dart';

class WebMainLayout extends ConsumerStatefulWidget {
  const WebMainLayout({super.key});

  @override
  ConsumerState<WebMainLayout> createState() => _WebMainLayoutState();
}

class _WebMainLayoutState extends ConsumerState<WebMainLayout> {
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

    return Scaffold(
      body: PremiumMeshBackground(
        child: Column(
          children: [
            WebHeader(
              selectedIndex: _selectedIndex,
              onTabSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: ClipRect(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: pages,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
