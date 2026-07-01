import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/survey_service.dart';
import 'package:community_survey/models/survey.dart';
import 'package:community_survey/features/survey/survey_details_page.dart';
import 'package:community_survey/features/survey/widgets/survey_timer_widget.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:community_survey/features/context/context_provider.dart';

class SurveyListPage extends ConsumerStatefulWidget {
  const SurveyListPage({super.key});

  @override
  ConsumerState<SurveyListPage> createState() => _SurveyListPageState();
}

class _SurveyListPageState extends ConsumerState<SurveyListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  SurveyDashboardResponse? _dashboardData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSurveys();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSurveys() async {
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
        _loadSurveys();
      }
    });

    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;

    final availableOrg = _dashboardData?.organizationSurveys ?? [];
    final availableGlobal = _dashboardData?.availableSurveys ?? [];
    final completedOrg = _dashboardData?.completedOrganizationSurveys ?? [];
    final completedGlobal = _dashboardData?.completedSurveys ?? [];

    final double topPadding = 48.0 + 16.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Surveys',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600, fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color(0xFF382A3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4C364E)),
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Available'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            )
          else
            IconButton(onPressed: _loadSurveys, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: PremiumMeshBackground(
        child: _isLoading && _dashboardData == null
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && _dashboardData == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadSurveys, child: const Text('Retry')),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAvailableTab(availableOrg, availableGlobal, theme),
                      _buildCompletedTab(completedOrg, completedGlobal, theme),
                    ],
                  ),
      ),
    );
  }

  Widget _buildAvailableTab(List<Survey> orgList, List<Survey> globalList, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        if (orgList.isNotEmpty) ...[
          _buildSectionHeader('Group Surveys', orgList.length, theme),
          const SizedBox(height: 12),
          kIsWeb
              ? Wrap(
                  spacing: 16,
                  runSpacing: 0,
                  children: orgList.map((s) => SizedBox(width: 350, child: _buildSurveyCard(s, false, theme))).toList(),
                )
              : Column(
                  children: orgList.map((s) => _buildSurveyCard(s, false, theme)).toList(),
                ),
          const SizedBox(height: 20),
        ],

        if (globalList.isNotEmpty) ...[
          _buildSectionHeader('General Surveys', globalList.length, theme),
          const SizedBox(height: 12),
          kIsWeb
              ? Wrap(
                  spacing: 16,
                  runSpacing: 0,
                  children: globalList.map((s) => SizedBox(width: 350, child: _buildSurveyCard(s, false, theme))).toList(),
                )
              : Column(
                  children: globalList.map((s) => _buildSurveyCard(s, false, theme)).toList(),
                ),
        ],
      ],
    );
  }

  Widget _buildCompletedTab(List<Survey> orgList, List<Survey> globalList, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        if (orgList.isNotEmpty) ...[
          _buildSectionHeader('Completed Group Surveys', orgList.length, theme),
          const SizedBox(height: 12),
          kIsWeb
              ? Wrap(
                  spacing: 16,
                  runSpacing: 0,
                  children: orgList.map((s) => SizedBox(width: 350, child: _buildSurveyCard(s, true, theme))).toList(),
                )
              : Column(
                  children: orgList.map((s) => _buildSurveyCard(s, true, theme)).toList(),
                ),
          const SizedBox(height: 20),
        ],

        if (globalList.isNotEmpty) ...[
          _buildSectionHeader('Completed General Surveys', globalList.length, theme),
          const SizedBox(height: 12),
          kIsWeb
              ? Wrap(
                  spacing: 16,
                  runSpacing: 0,
                  children: globalList.map((s) => SizedBox(width: 350, child: _buildSurveyCard(s, true, theme))).toList(),
                )
              : Column(
                  children: globalList.map((s) => _buildSurveyCard(s, true, theme)).toList(),
                ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF2D1E3A),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF4C364E)),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.montserrat(
              color: const Color(0xFF8C52FF),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyCard(Survey survey, bool isCompleted, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isCompleted
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SurveyDetailsPage(surveyId: survey.id),
                  ),
                ).then((_) => _loadSurveys());
              },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      survey.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (survey.description != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        survey.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          color: Colors.white54,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (!isCompleted && survey.expiresAt != null) ...[
                      const SizedBox(height: 12),
                      SurveyTimerWidget(expiresAt: survey.expiresAt!, compact: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green.withOpacity(0.1) : const Color(0xFF2D1E3A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isCompleted ? Colors.green.withOpacity(0.3) : const Color(0xFF4C364E),
                      ),
                    ),
                    child: Text(
                      isCompleted ? 'Completed' : '+${survey.rewardPoints} PTS',
                      style: GoogleFonts.montserrat(
                        color: isCompleted ? Colors.green : const Color(0xFF8C52FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  if (!isCompleted) ...[
                    const SizedBox(height: 16),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white54),
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
