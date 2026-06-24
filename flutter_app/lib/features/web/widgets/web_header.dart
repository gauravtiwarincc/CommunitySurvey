import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/models/auth_session.dart';
import 'package:community_survey/models/user.dart';

class WebHeader extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const WebHeader({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final userRole = authState.profile?.role ?? UserRole.user;
    final isAdmin = userRole == UserRole.admin || userRole == UserRole.superAdmin;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                // Logo
                Icon(Icons.how_to_vote, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Community Survey',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Navigation Links
                _buildNavItem(0, 'Dashboard', Icons.dashboard_outlined, Icons.dashboard, theme),
                const SizedBox(width: 8),
                _buildNavItem(1, 'Surveys', Icons.assignment_outlined, Icons.assignment, theme),
                const SizedBox(width: 8),
                _buildNavItem(2, 'Profile', Icons.person_outline, Icons.person, theme),
                if (isAdmin) ...[
                  const SizedBox(width: 8),
                  _buildNavItem(3, 'Admin', Icons.admin_panel_settings_outlined, Icons.admin_panel_settings, theme),
                ],
                const SizedBox(width: 24),
                // Logout Button
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon, IconData activeIcon, ThemeData theme) {
    final isSelected = selectedIndex == index;
    final color = isSelected ? theme.colorScheme.primary : Colors.white70;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
