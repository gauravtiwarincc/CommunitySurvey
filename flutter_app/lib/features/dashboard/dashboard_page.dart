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
    print('DEBUG: DashboardPage build: orgConfig = $orgConfig, stats = $stats');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading && _dashboardData == null
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
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildGroupTile(context, orgConfig, stats?.rewardPoints ?? 0, theme),
                        const SizedBox(height: 16),
                        _buildStatsGrid(theme),
                        const SizedBox(height: 20),
                        AdCarousel(theme: theme),
                        const SizedBox(height: 24),
                        
                        // Available Sections
                        _buildSectionHeader('My Group Surveys', _dashboardData?.organizationSurveys?.length ?? 0, theme),
                        const SizedBox(height: 8),
                        if (_dashboardData?.organizationSurveys?.isEmpty ?? true)
                          const Card(
                            elevation: 0,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No group surveys right now.',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ...(_dashboardData!.organizationSurveys!.map((survey) {
                            return _buildSurveyCard(context, survey, false, theme);
                          })),
                        const SizedBox(height: 16),

                        _buildSectionHeader('General Surveys', _dashboardData?.availableSurveys.length ?? 0, theme),
                        const SizedBox(height: 8),
                        if (_dashboardData?.availableSurveys.isEmpty ?? true)
                          const Card(
                            elevation: 0,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No general surveys right now.',
                                style: TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ),
                          )
                        else
                          ...(_dashboardData!.availableSurveys.map((survey) {
                            return _buildSurveyCard(context, survey, false, theme);
                          })),
                      ],
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
    print('DEBUG: _buildGroupTile called: orgConfig = $orgConfig, rewardPoints = $rewardPoints');
    final orgName = orgConfig?.organizationName ?? 'Tiwari Market';
    final welcomeMsg = orgConfig?.welcomeMessage ?? "Welcome to Tiwari Market's Group";
    
    // Smooth gradient (orange to purple like the reference screenshot)
    final gradient = LinearGradient(
      colors: [
        orgConfig != null ? _parseHexColor(orgConfig.primaryColor, const Color(0xFFFF6B4A)) : const Color(0xFFFF6B4A),
        orgConfig != null ? _parseHexColor(orgConfig.secondaryColor, const Color(0xFF4A15B3)) : const Color(0xFF4A15B3),
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orgName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      welcomeMsg,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Reward points capsule badge
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RedeemRewardsPage(),
                    ),
                  ).then((_) => _loadData());
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.card_giftcard, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '$rewardPoints pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Wallet button capsule
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
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_balance_wallet, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Wallet',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
    );
  }

  Widget _buildSectionHeader(String title, int count, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(ThemeData theme) {
    final stats = _dashboardData?.stats;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildStatCard(
          title: 'Available Surveys',
          value: '${stats?.availableCount ?? 0}',
          icon: Icons.assignment,
          color: theme.colorScheme.primary,
        ),
        _buildStatCard(
          title: 'Completed Surveys',
          value: '${stats?.completedCount ?? 0}',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.15)),
      ),
      color: color.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyCard(BuildContext context, Survey survey, bool isCompleted, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (survey.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        survey.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                    if (!isCompleted && survey.expiresAt != null) ...[
                      const SizedBox(height: 8),
                      SurveyTimerWidget(expiresAt: survey.expiresAt!, compact: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green.withOpacity(0.1) : theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCompleted ? 'Completed' : '+${survey.rewardPoints} pts',
                      style: TextStyle(
                        color: isCompleted ? Colors.green : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  if (!isCompleted) ...[
                    const SizedBox(height: 8),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
        title: const Row(
          children: [
            Icon(Icons.stars, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text('Video Completed!'),
          ],
        ),
        content: const Text('Thank you for watching the sponsored video advertisement. You have earned +5 reward points!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Awesome'),
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
              'Featured Advertisements',
              style: widget.theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade700.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Sponsored',
                style: TextStyle(
                  color: Colors.amber.shade900,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 160,
            width: double.infinity,
            color: Colors.grey.shade100,
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
                          opacity: 0.4,
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
                            const CircularProgressIndicator(color: Colors.white),
                            const SizedBox(height: 16),
                            const Text(
                              'Playing Advertisement Video...',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Earning reward points in ${_countdown > 0 ? _countdown : 1}s',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            value: _adVideoProgress,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
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
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.1),
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
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      ad['title']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ad['desc']!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
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
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 32,
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
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 12 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index ? widget.theme.colorScheme.primary : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
