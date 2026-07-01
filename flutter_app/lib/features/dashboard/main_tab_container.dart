import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/models/user.dart';
import 'package:community_survey/features/dashboard/dashboard_page.dart';
import 'package:community_survey/features/survey/survey_list_page.dart';
import 'package:community_survey/features/profile/profile_page.dart';
import 'package:community_survey/features/admin/admin_dashboard_page.dart';
import 'package:community_survey/features/context/context_provider.dart';
import 'package:community_survey/features/rewards/redeem_rewards_page.dart';

class TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class MainTabContainer extends ConsumerStatefulWidget {
  const MainTabContainer({super.key});

  @override
  ConsumerState<MainTabContainer> createState() => _MainTabContainerState();
}

final mainTabIndexProvider = StateProvider<int>((ref) => 0);

class _MainTabContainerState extends ConsumerState<MainTabContainer> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(contextProvider.notifier).fetchContexts());
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(mainTabIndexProvider);
    final authState = ref.watch(authProvider);
    final userRole = authState.profile?.role ?? UserRole.user;
    final isAdmin = userRole == UserRole.admin || userRole == UserRole.superAdmin;

    final List<Widget> pages = [
      const DashboardPage(), // Will just render DiscoverFeedView
      const SurveyListPage(),
      const RedeemRewardsPage(),
      const ProfilePage(),
      if (isAdmin) const AdminDashboardPage(),
    ];

    final List<TabItem> items = [
      const TabItem(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore,
        label: 'Discover',
      ),
      const TabItem(
        icon: Icons.assignment_outlined,
        activeIcon: Icons.assignment,
        label: 'Surveys',
      ),
      const TabItem(
        icon: Icons.workspace_premium_outlined,
        activeIcon: Icons.workspace_premium,
        label: 'Rewards',
      ),
      const TabItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
      ),
      if (isAdmin)
        const TabItem(
          icon: Icons.admin_panel_settings_outlined,
          activeIcon: Icons.admin_panel_settings,
          label: 'Admin',
        ),
    ];

    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;

    return Scaffold(
      extendBody: true, // Allows pages to scroll behind the floating bottom bar
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Theme.of(context).colorScheme.surface.withOpacity(0.85),
                border: Border.all(
                  
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = selectedIndex == index;

                  return InkWell(
                    onTap: () => ref.read(mainTabIndexProvider.notifier).state = index,
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: activeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            )
                          : null,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? activeColor : Colors.white60,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            width: isSelected ? 4 : 0,
                            height: 4,
                            decoration: BoxDecoration(
                              color: activeColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: activeColor,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
