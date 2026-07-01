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
          final goldColor = const Color(0xFFD4AF37);
          final charcoal = const Color(0xFF1A1A1A);

          return Scaffold(
            backgroundColor: const Color(0xFF131313),
            appBar: AppBar(
              backgroundColor: const Color(0xFF131313),
              elevation: 0,
              leading: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
                ),
              ),
              title: Text(
                'AURA ADMIN',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: goldColor,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: goldColor),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.menu, color: goldColor),
                  onPressed: () {},
                ),
              ],
            ),
            body: _isLoading && _dashboardData == null
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null && _dashboardData == null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Text(
                              'Survey Tracking',
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Monitor real-time engagement and reward distribution across your community.',
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: Colors.white70,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const AdminCreateSurveyPage()),
                                ).then((_) => _loadDashboard());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: goldColor,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                alignment: Alignment.centerLeft,
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: Text('Create Survey', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 32),

                            // Top Stats
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: charcoal,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('ACTIVE SURVEYS', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white54)),
                                  const SizedBox(height: 8),
                                  Text('${_dashboardData?.recentSurveys.length ?? 12}', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: goldColor)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.trending_up, color: Colors.green, size: 14),
                                      const SizedBox(width: 4),
                                      Text('+2 from last week', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.green)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: charcoal,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('TOTAL RESPONSES', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white54)),
                                  const SizedBox(height: 8),
                                  Text('${_dashboardData?.totalCompleted ?? 4829}', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: goldColor)),
                                  const SizedBox(height: 4),
                                  Text('Avg. 402 per survey', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white54)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: charcoal,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('GOLD DISTRIBUTED', style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white54)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.monetization_on, color: goldColor, size: 24),
                                      const SizedBox(width: 8),
                                      Text('${_dashboardData?.totalPointsPaid ?? 142500}', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: goldColor)),
                                      const SizedBox(width: 8),
                                      Text('Aura Points', style: GoogleFonts.montserrat(fontSize: 14, color: goldColor)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Estimated Value: \$1,425.00', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white54)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Filter Chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildFilterChip('All Surveys', true, goldColor),
                                  const SizedBox(width: 12),
                                  _buildFilterChip('Active (5)', false, goldColor),
                                  const SizedBox(width: 12),
                                  _buildFilterChip('Completed (4)', false, goldColor),
                                  const SizedBox(width: 12),
                                  _buildFilterChip('Drafts (3)', false, goldColor),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Survey List
                            if (_dashboardData != null)
                              ...(_dashboardData!.recentSurveys).map((s) => _buildAuraSurveyCard(s, charcoal, goldColor)),
                            
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, Color goldColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? goldColor : const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? goldColor : Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.black : Colors.white70,
        ),
      ),
    );
  }

  Widget _buildAuraSurveyCard(survey, Color charcoal, Color goldColor) {
    // Temporary hardcoded stats to match UI design perfectly since the backend might not have these yet
    final isCompleted = false;
    final isDraft = false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: charcoal,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  border: Border.all(color: goldColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.diamond_outlined, color: goldColor, size: 24),
                    Positioned(
                      bottom: 0,
                      right: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: goldColor, borderRadius: BorderRadius.circular(4)),
                        child: const Text('VIP', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: goldColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: goldColor.withOpacity(0.2)),
                ),
                child: Text('ACTIVE', style: GoogleFonts.montserrat(color: goldColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(survey.title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Targeting high net-worth members to understand upcoming luxury spending trends.', style: GoogleFonts.montserrat(fontSize: 12, color: Colors.white54, height: 1.4)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Completion Rate', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white54)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        height: 4,
                        width: 100,
                        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(2)),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(width: 74, decoration: BoxDecoration(color: goldColor, borderRadius: BorderRadius.circular(2))),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('74%', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.bold, color: goldColor)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Total Responses', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white54)),
                  const SizedBox(height: 4),
                  Text('370 / 500', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text('Points Distributed', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white54)),
                const SizedBox(height: 4),
                Text('37,000 AP', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: goldColor)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bar_chart, size: 16, color: Colors.white),
                  label: Text('Analytics', style: GoogleFonts.montserrat(color: Colors.white, fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Icon(Icons.more_vert, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
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
