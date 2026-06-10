import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/core/network/api_client.dart';
import 'package:community_survey/core/network/api_endpoints.dart';
import 'package:community_survey/models/survey.dart';

class SurveyDashboardResponse {
  final bool success;
  final List<Survey> availableSurveys;
  final List<Survey> completedSurveys;
  final List<Survey>? organizationSurveys;
  final List<Survey>? completedOrganizationSurveys;
  final DashboardStats? stats;

  SurveyDashboardResponse({
    required this.success,
    required this.availableSurveys,
    required this.completedSurveys,
    this.organizationSurveys,
    this.completedOrganizationSurveys,
    this.stats,
  });

  factory SurveyDashboardResponse.fromJson(Map<String, dynamic> json) {
    var availList = json['availableSurveys'] as List? ?? [];
    var compList = json['completedSurveys'] as List? ?? [];
    var orgList = json['organizationSurveys'] as List?;
    var compOrgList = json['completedOrganizationSurveys'] as List?;
    
    return SurveyDashboardResponse(
      success: json['success'] as bool? ?? false,
      availableSurveys: availList.map((s) => Survey.fromJson(s as Map<String, dynamic>)).toList(),
      completedSurveys: compList.map((s) => Survey.fromJson(s as Map<String, dynamic>)).toList(),
      organizationSurveys: orgList?.map((s) => Survey.fromJson(s as Map<String, dynamic>)).toList(),
      completedOrganizationSurveys: compOrgList?.map((s) => Survey.fromJson(s as Map<String, dynamic>)).toList(),
      stats: json['stats'] != null
          ? DashboardStats.fromJson(json['stats'] as Map<String, dynamic>)
          : DashboardStats(
              availableCount: availList.length + (orgList?.length ?? 0),
              completedCount: compList.length + (compOrgList?.length ?? 0),
              rewardPoints: json['rewardPoints'] as int? ?? 0,
              walletBalance: json['walletBalance'] as int? ?? 0,
            ),
    );
  }
}

class SurveyService {
  final Dio _dio;

  SurveyService(this._dio);

  Future<SurveyDashboardResponse> fetchDashboard() async {
    final response = await _dio.get(ApiEndpoints.surveysDashboard);
    return SurveyDashboardResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SurveyDashboardResponse> fetchSurveysDashboard() async {
    final response = await _dio.get(ApiEndpoints.surveysList);
    return SurveyDashboardResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Survey> fetchSurveyDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.surveyDetail(id));
    final data = response.data;
    if (data['success'] == true) {
      return Survey.fromJson(data['survey'] as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Failed to load survey details.');
    }
  }

  Future<bool> submitSurvey(String surveyId, List<Map<String, dynamic>> answers) async {
    final response = await _dio.post(
      ApiEndpoints.submitSurvey,
      data: {
        'surveyId': surveyId,
        'answers': answers,
      },
    );
    return response.data['success'] == true;
  }
}

final surveyServiceProvider = Provider<SurveyService>((ref) {
  return SurveyService(ref.watch(dioProvider));
});
