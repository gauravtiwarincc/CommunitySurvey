import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/survey_service.dart';
import 'package:community_survey/models/survey.dart';
import 'package:community_survey/features/survey/survey_details_page.dart';

class SurveyListPage extends ConsumerStatefulWidget {
  const SurveyListPage({super.key});

  @override
  ConsumerState<SurveyListPage> createState() => _SurveyListPageState();
}

class _SurveyListPageState extends ConsumerState<SurveyListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Survey> _surveys = [];
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
      final list = await ref.read(surveyServiceProvider).fetchSurveysList();
      if (mounted) {
        setState(() => _surveys = list);
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

    final available = _surveys.where((s) => !s.isCompleted).toList();
    final completed = _surveys.where((s) => s.isCompleted).toList();

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
      body: _isLoading && _surveys.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _surveys.isEmpty
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
                    _buildSurveyList(available, false, theme),
                    _buildSurveyList(completed, true, theme),
                  ],
                ),
    );
  }

  Widget _buildSurveyList(List<Survey> list, bool isCompletedList, ThemeData theme) {
    if (list.isEmpty) {
      return Center(
        child: Text(
          isCompletedList ? 'No completed surveys yet' : 'No surveys available',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final survey = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          elevation: 0,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              survey.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: survey.description != null ? Text(survey.description!) : null,
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompletedList ? Colors.green.withOpacity(0.1) : theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompletedList ? 'Completed' : '+${survey.rewardPoints} pts',
                    style: TextStyle(
                      color: isCompletedList ? Colors.green : theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            onTap: isCompletedList
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
      },
    );
  }
}
