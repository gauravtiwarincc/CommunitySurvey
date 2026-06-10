import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/survey_service.dart';
import 'package:community_survey/models/survey.dart';
import 'package:community_survey/features/survey/survey_details_page.dart';
import 'package:community_survey/features/survey/widgets/survey_timer_widget.dart';

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
      final data = await ref.read(surveyServiceProvider).fetchSurveysDashboard();
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

    final availableOrg = _dashboardData?.organizationSurveys ?? [];
    final availableGlobal = _dashboardData?.availableSurveys ?? [];
    final completedOrg = _dashboardData?.completedOrganizationSurveys ?? [];
    final completedGlobal = _dashboardData?.completedSurveys ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Surveys'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: theme.colorScheme.secondary,
          tabs: const [
            Tab(text: 'Available'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(onPressed: _loadSurveys, icon: const Icon(Icons.refresh)),
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
    );
  }

  Widget _buildAvailableTab(List<Survey> orgList, List<Survey> globalList, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('My Group Surveys', orgList.length, theme),
        const SizedBox(height: 8),
        if (orgList.isEmpty)
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
          ...orgList.map((s) => _buildSurveyCard(s, false, theme)),
        const SizedBox(height: 16),

        _buildSectionHeader('General Surveys', globalList.length, theme),
        const SizedBox(height: 8),
        if (globalList.isEmpty)
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
          ...globalList.map((s) => _buildSurveyCard(s, false, theme)),
      ],
    );
  }

  Widget _buildCompletedTab(List<Survey> orgList, List<Survey> globalList, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Completed Group Surveys', orgList.length, theme),
        const SizedBox(height: 8),
        if (orgList.isEmpty)
          const Card(
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Completed group surveys will appear here.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
        else
          ...orgList.map((s) => _buildSurveyCard(s, true, theme)),
        const SizedBox(height: 16),

        _buildSectionHeader('Completed General Surveys', globalList.length, theme),
        const SizedBox(height: 8),
        if (globalList.isEmpty)
          const Card(
            elevation: 0,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Completed general surveys will appear here.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          )
        else
          ...globalList.map((s) => _buildSurveyCard(s, true, theme)),
      ],
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

  Widget _buildSurveyCard(Survey survey, bool isCompleted, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          survey.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (survey.description != null) ...[
              const SizedBox(height: 4),
              Text(survey.description!),
            ],
            if (!isCompleted && survey.expiresAt != null) ...[
              const SizedBox(height: 8),
              SurveyTimerWidget(expiresAt: survey.expiresAt!, compact: true),
            ],
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ),
            ),
          ],
        ),
        onTap: isCompleted
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SurveyDetailsPage(surveyId: survey.id),
                  ),
                ).then((_) => _loadSurveys());
              },
      ),
    );
  }
}
