import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/admin_service.dart';
import 'package:community_survey/features/admin/admin_users_list_page.dart';
import 'package:community_survey/features/admin/admin_theme_customization_page.dart';
import 'package:community_survey/features/admin/admin_create_survey_page.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/theme/theme_controller.dart';
import 'package:community_survey/features/context/context_provider.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:community_survey/core/network/api_client.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  bool _isLoading = true;
  String? _errorMessage;
  AdminDashboardResponse? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ref.read(adminServiceProvider).fetchDashboard();
      if (mounted) {
        setState(() => _dashboardData = data);
      }
    } catch (e) {
      setState(() => _errorMessage = getApiErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminTheme = PremiumTheme.buildAdminTheme();

    return Theme(
      data: adminTheme,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(
                'Admin Console',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: PremiumMeshBackground(
        child: SafeArea(
          bottom: false,
          child: _isLoading && _dashboardData == null
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null && _dashboardData == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _errorMessage!.contains('organization') 
                                ? Icons.domain_disabled_rounded 
                                : Icons.error_outline_rounded, 
                              size: 72, 
                              color: theme.colorScheme.primary.withOpacity(0.5)
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _errorMessage!.contains('organization')
                                ? 'No Organization Assigned'
                                : 'Connection Error',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!, 
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.white70,
                                height: 1.5,
                              )
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                                foregroundColor: theme.colorScheme.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _loadDashboard, 
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry Connection')
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: 16.0,
                        bottom: 120.0,
                      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildStatsGrid(theme),
                        const SizedBox(height: 16),
                        _buildOrganizationShareCard(theme),
                        const SizedBox(height: 16),
                        Text(
                          'Administrative Actions',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        kIsWeb ? Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(width: 350, child: _buildActionCard(
                              context: context,
                              title: 'Update Branding & Styling',
                              subtitle: 'Update colors, organization name, welcome message, and logo.',
                              icon: Icons.palette_outlined,
                              color: theme.colorScheme.primary,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AdminThemeCustomizationPage(),
                                  ),
                                ).then((_) => _loadDashboard());
                              },
                            )),
                            SizedBox(width: 350, child: _buildActionCard(
                              context: context,
                              title: 'Manage Members',
                              subtitle: 'View user statistics, complete surveys progress, and activate/deactivate accounts.',
                              icon: Icons.people_outline,
                              color: Colors.teal,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AdminUsersListPage(),
                                  ),
                                ).then((_) => _loadDashboard());
                              },
                            )),
                            SizedBox(width: 350, child: _buildActionCard(
                              context: context,
                              title: 'Create Group Survey',
                              subtitle: 'Design and publish a new survey to all members of your organization.',
                              icon: Icons.add_task,
                              color: Colors.orange,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AdminCreateSurveyPage(),
                                  ),
                                ).then((_) => _loadDashboard());
                              },
                            )),
                          ]
                        ) : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildActionCard(
                              context: context,
                              title: 'Update Branding & Styling',
                              subtitle: 'Update colors, organization name, welcome message, and logo.',
                              icon: Icons.palette_outlined,
                              color: theme.colorScheme.primary,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AdminThemeCustomizationPage(),
                                  ),
                                ).then((_) => _loadDashboard());
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildActionCard(
                              context: context,
                              title: 'Manage Members',
                              subtitle: 'View user statistics, complete surveys progress, and activate/deactivate accounts.',
                              icon: Icons.people_outline,
                              color: Colors.teal,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AdminUsersListPage(),
                                  ),
                                ).then((_) => _loadDashboard());
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildActionCard(
                              context: context,
                              title: 'Create Group Survey',
                              subtitle: 'Design and publish a new survey to all members of your organization.',
                              icon: Icons.add_task,
                              color: Colors.orange,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const AdminCreateSurveyPage(),
                                  ),
                                ).then((_) => _loadDashboard());
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
        },
      ),
    );
  }

  Widget _buildOrganizationShareCard(ThemeData theme) {
    final activeContext = ref.read(contextProvider).activeContext;
    final orgConfig = ref.read(themeProvider).config;
    
    // If we're in a group context, prioritize group name/code. Otherwise fallback to the global config.
    final isGroup = activeContext?.contextType == 'GROUP';
    final orgName = isGroup ? (activeContext?.displayName ?? 'Your Organization') : (orgConfig?.organizationName ?? 'Your Organization');
    final orgCode = isGroup ? (activeContext?.inviteCode ?? '------') : (orgConfig?.organizationCode ?? '------');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark grey
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            orgName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invite members to map with your organization using the code below:',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  orgCode,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    letterSpacing: 2,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: orgCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copied to clipboard')),
                  );
                },
                icon: const Icon(Icons.copy, color: Colors.orange),
              ),
              IconButton(
                onPressed: () {
                  Share.share('Join our organization on the Community Survey app! Use Organization Code: $orgCode');
                },
                icon: const Icon(Icons.ios_share, color: Colors.orange),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.1,
      children: [
        _buildMiniStatCard(
          title: 'Total Users',
          value: '${_dashboardData?.totalMembers ?? 0}',
          icon: Icons.people,
          color: theme.colorScheme.primary,
        ),
        _buildMiniStatCard(
          title: 'Total Surveys',
          value: '${(_dashboardData?.totalCompleted ?? 0) + (_dashboardData?.totalPending ?? 0)}',
          icon: Icons.assignment,
          color: Colors.orange,
        ),
        _buildMiniStatCard(
          title: 'Active Surveys',
          value: '${_dashboardData?.totalPending ?? 0}',
          icon: Icons.play_circle_outline,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Top small accent indicator line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                color: color,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
