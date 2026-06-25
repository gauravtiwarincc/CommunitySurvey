import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/features/dashboard/main_tab_container.dart';
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
import 'package:community_survey/models/advertisement.dart';
import 'package:community_survey/services/advertisement_service.dart';
import 'package:community_survey/features/dashboard/video_player_screen.dart';
import 'package:community_survey/features/context/context_provider.dart';
import 'package:community_survey/features/profile/widgets/context_switcher.dart';
import 'package:community_survey/models/user_context.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

import 'package:community_survey/features/dashboard/widgets/swiggy_tab_bar.dart';
import 'package:community_survey/features/dashboard/views/surveys_feed_view.dart';
import 'package:community_survey/features/dashboard/views/discover_feed_view.dart';
import 'package:community_survey/features/dashboard/views/rewards_feed_view.dart';

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool _isLoading = false;
  SurveyDashboardResponse? _dashboardData;
  String? _errorMessage;
  SwiggyTabMode _currentTab = SwiggyTabMode.surveys;

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
    ref.listen(contextProvider, (previous, next) async {
      if (previous?.activeContext?.contextId != next.activeContext?.contextId) {
        await Future.delayed(const Duration(milliseconds: 100));
        _loadData();
      }
    });

    final theme = Theme.of(context);
    final themeState = ref.watch(themeProvider);
    final contextState = ref.watch(contextProvider);
    final orgConfig = themeState.config;
    final stats = _dashboardData?.stats;

    // Build the sub-views with data
    final allSurveys = _dashboardData != null 
      ? [...(_dashboardData!.organizationSurveys ?? []), ...(_dashboardData!.availableSurveys)]
      : <Survey>[];
    
    // Sort by createdAt descending
    allSurveys.sort((a, b) {
      final dateA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Header: Context Switcher + Profile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(child: const ContextSwitcher()),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => ref.read(mainTabIndexProvider.notifier).state = 2, // Go to profile tab
                    child: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      child: Icon(Icons.person, color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar Placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.white54),
                    const SizedBox(width: 12),
                    Text(
                      'Search for Surveys or Tasks...',
                      style: GoogleFonts.inter(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ),

            // The Swiggy Tab Bar
            SwiggyTabBar(
              selectedMode: _currentTab,
              onTabChanged: (mode) => setState(() => _currentTab = mode),
            ),

            // The Tab Views
            Expanded(
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
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildCurrentView(allSurveys, stats, theme, contextState.activeContext, orgConfig),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView(List<Survey> surveys, SurveyDashboardStats? stats, ThemeData theme, UserContext? activeContext, OrganizationConfig? orgConfig) {
    switch (_currentTab) {
      case SwiggyTabMode.surveys:
        return SurveysFeedView(
          key: const ValueKey('surveys'),
          surveys: surveys,
          buildSurveyCard: (survey) => _buildSurveyCard(context, survey, false, theme),
        );
      case SwiggyTabMode.discover:
        return DiscoverFeedView(
          key: const ValueKey('discover'),
          statsProgress: _buildStatsProgress(theme, stats?.availableCount ?? 0, stats?.completedCount ?? 0, activeContext),
          adCarousel: AdCarousel(theme: theme),
        );
      case SwiggyTabMode.rewards:
        return RewardsFeedView(
          key: const ValueKey('rewards'),
          groupTile: _buildGroupTile(context, orgConfig, stats?.rewardPoints ?? 0, theme, activeContext),
          onRedeemRewards: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RedeemRewardsPage()));
          },
        );
    }
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

  Widget _buildGroupTile(BuildContext context, OrganizationConfig? orgConfig, int rewardPoints, ThemeData theme, UserContext? activeContext) {
    final isGroup = activeContext?.contextType == 'GROUP';
    final orgName = isGroup ? (activeContext?.displayName ?? 'Group') : (orgConfig?.organizationName ?? 'Tiwari Market');
    final welcomeMsg = isGroup ? "Welcome to ${activeContext?.displayName ?? 'Group'}" : (orgConfig?.welcomeMessage ?? "Welcome to Tiwari Market's Group");
    
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Top highlight gradient line
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, secondary],
                  ),
                ),
              ),
            ),
            // Background ambient glow
            Positioned(
              right: -30,
              bottom: -30,
              child: Icon(
                Icons.stars,
                size: 140,
                color: primary.withOpacity(0.04),
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
                          
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Center(
                          child: Icon(Icons.sim_card, color: primary.withOpacity(0.4), size: 20),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: primary, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              'Member',
                              style: TextStyle(color: primary, fontSize: 10, fontWeight: FontWeight.bold),
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
                      
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    welcomeMsg,
                    style: GoogleFonts.inter(
                      
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
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primary.withOpacity(0.25)),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars, color: primary, size: 15),
                              const SizedBox(width: 8),
                              Text(
                                '$rewardPoints PTS',
                                style: GoogleFonts.plusJakartaSans(
                                  
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
                            color: secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: secondary.withOpacity(0.25)),
                            boxShadow: [
                              BoxShadow(
                                color: secondary.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_outline, color: secondary, size: 15),
                              const SizedBox(width: 8),
                              Text(
                                'ACCOUNT',
                                style: GoogleFonts.plusJakartaSans(
                                  
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

  Widget _buildStatsProgress(ThemeData theme, int available, int completed, UserContext? activeContext) {
    final total = available + completed;
    final percent = total > 0 ? completed / total : 0.0;
    
    final isGroup = activeContext?.contextType == 'GROUP';
    final streakTitle = isGroup ? 'Group Participation Streak' : 'Individual Participation Streak';

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
                  backgroundColor: Colors.white.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  strokeWidth: 5,
                ),
                Text(
                  '${(percent * 100).toInt()}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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
                  streakTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Completed $completed of $total total available tasks.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
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
                      ),
                    ),
                    if (survey.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        survey.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          
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
                    const Icon(Icons.arrow_forward_ios, size: 12),
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

class AdCarousel extends ConsumerStatefulWidget {
  final ThemeData theme;
  const AdCarousel({super.key, required this.theme});

  @override
  ConsumerState<AdCarousel> createState() => _AdCarouselState();
}

class _AdCarouselState extends ConsumerState<AdCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  
  List<Advertisement> _ads = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadAds();
  }

  Future<void> _loadAds() async {
    try {
      final ads = await ref.read(advertisementServiceProvider).fetchAdvertisements();
      if (mounted) {
        if (ads.isNotEmpty) {
          setState(() {
            _ads = ads;
            _isLoading = false;
          });
          _startAutoScroll();
        } else {
          // Force mock ads if backend returns an empty array for demo purposes
          _loadMockAds();
        }
      }
    } catch (e) {
      if (mounted) {
        _loadMockAds();
      }
    }
  }

  void _loadMockAds() {
    setState(() {
      _ads = [
        Advertisement(
          id: 'mock1',
          type: 'image',
          title: 'Tiwari Market Super Sale',
          description: 'Get up to 50% discount on groceries and home essentials this week!',
          imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=600',
          durationSeconds: 5,
          rewardPoints: 10,
        ),
        Advertisement(
          id: 'mock2',
          type: 'video',
          title: 'Explore Tiwari Smart Market',
          description: 'Watch our video tour and experience high-quality shopping.',
          imageUrl: 'https://images.unsplash.com/photo-1578916171728-46686eac8d58?q=80&w=600',
          mediaUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
          rewardPoints: 5,
          durationSeconds: 5,
        ),
      ];
      _isLoading = false;
    });
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && _ads.isNotEmpty) {
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
    super.dispose();
  }

  void _onAdTap(Advertisement ad) {
    if (ad.type == 'video') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(ad: ad),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 154, child: Center(child: CircularProgressIndicator()));
    }
    if (_ads.isEmpty) {
      return const SizedBox();
    }

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
            color: Theme.of(context).colorScheme.surface,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _ads.length,
              itemBuilder: (context, index) {
                final ad = _ads[index];
                return GestureDetector(
                  onTap: () => _onAdTap(ad),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (ad.imageUrl != null)
                        Image.network(
                          ad.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (ad.type == 'video')
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.play_circle_fill, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'WATCH & EARN +${ad.rewardPoints}',
                                      style: GoogleFonts.plusJakartaSans( fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            Text(
                              ad.title ?? 'Advertisement',
                              style: GoogleFonts.plusJakartaSans(
                                
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (ad.description != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                ad.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
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
                color: _currentPage == index ? widget.theme.colorScheme.primary : Colors.black12,
                borderRadius: BorderRadius.circular(2.5),
              ),
            );
          }),
        ),
      ],
    );
  }
}
