import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/survey_service.dart';
import 'package:community_survey/models/survey.dart';
import 'package:community_survey/features/survey/survey_details_page.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/core/theme/theme_controller.dart';
import 'package:community_survey/models/admin_models.dart';
import 'package:community_survey/features/admin/admin_user_detail_page.dart';
import 'package:community_survey/features/rewards/redeem_rewards_page.dart';
import 'package:community_survey/features/survey/widgets/survey_timer_widget.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _isLoading = false;
  SurveyDashboardResponse? _dashboardData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ref.read(surveyServiceProvider).fetchDashboard();
      if (mounted) {
        setState(() => _dashboardData = data);
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    final orgConfig = themeState.config;
    final stats = _dashboardData?.stats;

    final primaryColor = orgConfig != null ? _parseHexColor(orgConfig.primaryColor, PremiumTheme.glowPurple) : PremiumTheme.glowPurple;
    final secondaryColor = orgConfig != null ? _parseHexColor(orgConfig.secondaryColor, PremiumTheme.glowMagenta) : PremiumTheme.glowMagenta;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Portal',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: PremiumMeshBackground(
        orgPrimary: primaryColor,
        orgSecondary: secondaryColor,
        child: _isLoading && _dashboardData == null
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && _dashboardData == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: primaryColor,
                    backgroundColor: PremiumTheme.surface,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 90), // AppBar breathing room
                          _buildGroupTile(context, orgConfig, stats?.rewardPoints ?? 0, theme),
                          const SizedBox(height: 20),
                          _buildStatsProgress(theme, stats?.availableCount ?? 0, stats?.completedCount ?? 0),
                          const SizedBox(height: 20),
                          AdCarousel(theme: theme),
                          const SizedBox(height: 28),
                          
                          // Available Sections
                          _buildSectionHeader('Group Surveys', _dashboardData?.organizationSurveys?.length ?? 0, theme),
                          const SizedBox(height: 12),
                          if (_dashboardData?.organizationSurveys?.isEmpty ?? true)
                            const GlassCard(
                              padding: EdgeInsets.all(20.0),
                              child: Center(
                                child: Text(
                                  'No group surveys right now.',
                                  style: TextStyle(color: Colors.white38, fontSize: 13),
                                ),
                              ),
                            )
                          else
                            ...(_dashboardData!.organizationSurveys!.map((survey) {
                              return _buildSurveyCard(context, survey, false, theme);
                            })),
                          const SizedBox(height: 20),

                          _buildSectionHeader('General Surveys', _dashboardData?.availableSurveys.length ?? 0, theme),
                          const SizedBox(height: 12),
                          if (_dashboardData?.availableSurveys.isEmpty ?? true)
                            const GlassCard(
                              padding: EdgeInsets.all(20.0),
                              child: Center(
                                child: Text(
                                  'No general surveys right now.',
                                  style: TextStyle(color: Colors.white38, fontSize: 13),
                                ),
                              ),
                            )
                          else
                            ...(_dashboardData!.availableSurveys.map((survey) {
                              return _buildSurveyCard(context, survey, false, theme);
                            })),
                          const SizedBox(height: 100), // Bottom Navigation Bar breathing room
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Color _parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  Widget _buildGroupTile(BuildContext context, OrganizationConfig? orgConfig, int rewardPoints, ThemeData theme) {
    final orgName = orgConfig?.organizationName ?? 'Tiwari Market';
    final welcomeMsg = orgConfig?.welcomeMessage ?? "Welcome to Tiwari Market's Group";
    
    final primary = orgConfig != null ? _parseHexColor(orgConfig.primaryColor, PremiumTheme.glowPurple) : PremiumTheme.glowPurple;
    final secondary = orgConfig != null ? _parseHexColor(orgConfig.secondaryColor, PremiumTheme.glowMagenta) : PremiumTheme.glowMagenta;

    // CRED/Stripe inspired credit card gradient
    final gradient = LinearGradient(
      colors: [
        primary,
        secondary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Holographic stripe look
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.stars,
              size: 140,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Metallic chip look
                    Container(
                      height: 32,
                      width: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Center(
                        child: Icon(Icons.sim_card, color: Colors.white70, size: 20),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: Colors.white, size: 13),
                          SizedBox(width: 4),
                          Text(
                            'Member',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  orgName.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  welcomeMsg,
                  style: GoogleFonts.inter(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Reward points badge
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RedeemRewardsPage(),
                          ),
                        ).then((_) => _loadData());
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars, color: Colors.white, size: 15),
                            const SizedBox(width: 8),
                            Text(
                              '$rewardPoints PTS',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Wallet details redirect
                    InkWell(
                      onTap: () {
                        final profile = ref.read(authProvider).profile;
                        if (profile != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AdminUserDetailPage(userId: profile.id),
                            ),
                          ).then((_) => _loadData());
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.account_balance_wallet, color: Colors.white, size: 15),
                            const SizedBox(width: 8),
                            Text(
                              'WALLET',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsProgress(ThemeData theme, int available, int completed) {
    final total = available + completed;
    final percent = total > 0 ? completed / total : 0.0;
    
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Gamified Circular Indicator
          SizedBox(
            height: 54,
            width: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.white.withOpacity(0.04),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  strokeWidth: 5,
                ),
                Text(
                  '${(percent * 100).toInt()}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Participation Streak',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Completed $completed of $total total available tasks.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyCard(BuildContext context, Survey survey, bool isCompleted, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          onTap: isCompleted
              ? null
              : () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SurveyDetailsPage(surveyId: survey.id),
                    ),
                  ).then((_) => _loadData());
                },
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (survey.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        survey.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (!isCompleted && survey.expiresAt != null) ...[
                      const SizedBox(height: 10),
                      SurveyTimerWidget(expiresAt: survey.expiresAt!, compact: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green.withOpacity(0.08) : theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCompleted ? Colors.green.withOpacity(0.2) : theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      isCompleted ? 'Completed' : '+${survey.rewardPoints} PTS',
                      style: GoogleFonts.plusJakartaSans(
                        color: isCompleted ? Colors.green : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (!isCompleted) ...[
                    const SizedBox(height: 10),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white30),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdCarousel extends StatefulWidget {
  final ThemeData theme;
  const AdCarousel({super.key, required this.theme});

  @override
  State<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends State<AdCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _ads = [
    {
      'type': 'image',
      'title': 'Tiwari Market Super Sale',
      'desc': 'Get up to 50% discount on groceries and home essentials this week!',
      'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=600',
    },
    {
      'type': 'video',
      'title': 'Explore Tiwari Smart Market',
      'desc': 'Watch our video tour and experience high-quality shopping.',
      'image': 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?q=80&w=600',
    },
    {
      'type': 'image',
      'title': 'Premium Smart Wear',
      'desc': 'Track your health and surveys. Shop the new fitness gear.',
      'image': 'https://images.unsplash.com/photo-1575311373937-040b8e1fd5b6?q=80&w=600',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _ads.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _mockVideoTimer?.cancel();
    super.dispose();
  }

  bool _isPlayingAdVideo = false;
  double _adVideoProgress = 0.0;
  Timer? _mockVideoTimer;
  int _countdown = 5;

  void _playAdVideo(BuildContext context) {
    setState(() {
      _isPlayingAdVideo = true;
      _adVideoProgress = 0.0;
      _countdown = 5;
    });

    _timer?.cancel();

    _mockVideoTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _adVideoProgress += 0.02; // 5 seconds total (100ms * 50 = 5 seconds)
        if (timer.tick % 10 == 0) {
          _countdown--;
        }
        if (_adVideoProgress >= 1.0) {
          _adVideoProgress = 1.0;
          _isPlayingAdVideo = false;
          _mockVideoTimer?.cancel();
          _startAutoScroll();
          _showRewardDialog(context);
        }
      });
    });
  }

  void _showRewardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF161823),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white10),
        ),
        title: Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Text(
              'Video Completed!',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Thank you for watching the sponsored video advertisement. You have earned +5 reward points!',
          style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Awesome',
              style: TextStyle(color: widget.theme.colorScheme.primary, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Ads',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade700.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.amber.shade700.withOpacity(0.2)),
              ),
              child: Text(
                'SPONSORED',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.amber.shade400,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 154,
            width: double.infinity,
            color: const Color(0xFF12141C),
            child: Stack(
              children: [
                if (_isPlayingAdVideo)
                  Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 0.35,
                          child: Image.network(
                            _ads[1]['image']!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: widget.theme.colorScheme.primary),
                            const SizedBox(height: 14),
                            Text(
                              'Playing sponsored video...',
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Earning reward points in ${_countdown > 0 ? _countdown : 1}s',
                              style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            value: _adVideoProgress,
                            backgroundColor: Colors.white12,
                            valueColor: AlwaysStoppedAnimation<Color>(widget.theme.colorScheme.primary),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white60),
                            onPressed: () {
                              _mockVideoTimer?.cancel();
                              setState(() {
                                _isPlayingAdVideo = false;
                              });
                              _startAutoScroll();
                            },
                          ),
                        )
                      ],
                    ),
                  )
                else
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _ads.length,
                    itemBuilder: (context, index) {
                      final ad = _ads[index];
                      final isVideo = ad['type'] == 'video';

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            ad['image']!,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.black.withOpacity(0.15),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    if (isVideo) ...[
                                      const Icon(Icons.play_circle_fill, color: Colors.amber, size: 16),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      ad['title']!,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  ad['desc']!,
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (isVideo)
                            Center(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _playAdVideo(context),
                                  borderRadius: BorderRadius.circular(40),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_ads.length, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 10 : 5,
              height: 5,
              decoration: BoxDecoration(
                color: _currentPage == index ? widget.theme.colorScheme.primary : Colors.white24,
                borderRadius: BorderRadius.circular(2.5),
              ),
            );
          }),
        ),
      ],
    );
  }
}
