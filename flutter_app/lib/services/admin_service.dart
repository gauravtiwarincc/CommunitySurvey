import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/core/network/api_client.dart';
import 'package:community_survey/core/network/api_endpoints.dart';
import 'package:community_survey/models/admin_models.dart';
import 'package:community_survey/models/user.dart';

class AdminDashboardResponse {
  final bool success;
  final int totalMembers;
  final int totalCompleted;
  final int totalPending;
  final int totalPointsPaid;
  final List<AdminUserItem> recentUsers;
  final List<AdminSurveyItem> recentSurveys;

  AdminDashboardResponse({
    required this.success,
    required this.totalMembers,
    required this.totalCompleted,
    required this.totalPending,
    required this.totalPointsPaid,
    required this.recentUsers,
    required this.recentSurveys,
  });

  factory AdminDashboardResponse.fromJson(Map<String, dynamic> json) {
    var usersList = json['members'] as List? ?? [];
    var surveysList = json['surveys'] as List? ?? [];
    var stats = json['stats'] as Map<String, dynamic>? ?? {};
    
    return AdminDashboardResponse(
      success: json['success'] as bool? ?? false,
      totalMembers: stats['totalMembers'] as int? ?? 0,
      totalCompleted: stats['totalCompleted'] as int? ?? 0,
      totalPending: stats['totalPending'] as int? ?? 0,
      totalPointsPaid: stats['totalPointsPaid'] as int? ?? 0,
      recentUsers: usersList.map((u) => AdminUserItem.fromJson(u as Map<String, dynamic>)).toList(),
      recentSurveys: surveysList.map((s) => AdminSurveyItem.fromJson(s as Map<String, dynamic>)).toList(),
    );
  }
}

class AdminUsersResponse {
  final bool success;
  final List<AdminUserItem> users;
  final PaginationInfo pagination;

  AdminUsersResponse({
    required this.success,
    required this.users,
    required this.pagination,
  });

  factory AdminUsersResponse.fromJson(Map<String, dynamic> json) {
    var usersList = json['users'] as List? ?? [];
    return AdminUsersResponse(
      success: json['success'] as bool? ?? false,
      users: usersList.map((u) => AdminUserItem.fromJson(u as Map<String, dynamic>)).toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
    );
  }
}

class AdminUserDetailResponse {
  final bool success;
  final UserProfileInfo user;
  final List<CompletedSurveyItem> completedSurveys;
  final List<PendingSurveyItem> pendingSurveys;

  AdminUserDetailResponse({
    required this.success,
    required this.user,
    required this.completedSurveys,
    required this.pendingSurveys,
  });

  factory AdminUserDetailResponse.fromJson(Map<String, dynamic> json) {
    var completedList = json['completedSurveys'] as List? ?? [];
    var pendingList = json['pendingSurveys'] as List? ?? [];
    return AdminUserDetailResponse(
      success: json['success'] as bool? ?? false,
      user: UserProfileInfo.fromJson(json['user'] as Map<String, dynamic>),
      completedSurveys: completedList.map((c) => CompletedSurveyItem.fromJson(c as Map<String, dynamic>)).toList(),
      pendingSurveys: pendingList.map((p) => PendingSurveyItem.fromJson(p as Map<String, dynamic>)).toList(),
    );
  }
}

class AdminService {
  final Dio _dio;

  AdminService(this._dio);

  Future<AdminDashboardResponse> fetchDashboard() async {
    final response = await _dio.get(ApiEndpoints.adminDashboard);
    return AdminDashboardResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AdminUsersResponse> fetchUsers(String search, int page) async {
    final response = await _dio.get(
      ApiEndpoints.adminUsers,
      queryParameters: {
        'search': search,
        'page': page,
        'limit': 15,
      },
    );
    return AdminUsersResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AdminUserDetailResponse> fetchUserDetail(String id) async {
    final response = await _dio.get(ApiEndpoints.adminUserDetail(id));
    return AdminUserDetailResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<bool> updateUserRole(String id, String role) async {
    final response = await _dio.patch(
      ApiEndpoints.adminUserRole(id),
      data: {'role': role},
    );
    return response.data['success'] == true;
  }

  Future<List<Map<String, dynamic>>> fetchSurveyAnalytics() async {
    final response = await _dio.get(ApiEndpoints.adminSurveyAnalytics);
    final list = response.data as List? ?? [];
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<bool> createSurvey({
    required String title,
    required String? description,
    required int rewardPoints,
    required List<Map<String, dynamic>> questions,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.adminSurveys,
      data: {
        'title': title,
        'description': description,
        'rewardPoints': rewardPoints,
        'questions': questions,
      },
    );
    return response.data['success'] == true;
  }

  Future<bool> archiveSurvey(String id) async {
    final response = await _dio.post(ApiEndpoints.adminArchiveSurvey(id));
    return response.data['success'] == true;
  }

  Future<OrganizationConfig> updateTheme({
    required String organizationName,
    required String primaryColor,
    required String secondaryColor,
    required String accentColor,
    String? welcomeMessage,
    String? supportEmail,
    String? logoUrl,
  }) async {
    final response = await _dio.put(
      ApiEndpoints.organizationTheme,
      data: {
        'organizationName': organizationName,
        'primaryColor': primaryColor,
        'secondaryColor': secondaryColor,
        'accentColor': accentColor,
        if (welcomeMessage != null) 'welcomeMessage': welcomeMessage,
        if (supportEmail != null) 'supportEmail': supportEmail,
        if (logoUrl != null) 'logoUrl': logoUrl,
      },
    );
    final data = response.data;
    if (data['success'] == true) {
      return OrganizationConfig.fromJson(data['organization'] as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Failed to update theme.');
    }
  }

  Future<UserProfileInfo> updateUserStatus(String id, bool isActive) async {
    final response = await _dio.patch(
      ApiEndpoints.adminUserStatus(id),
      data: {'isActive': isActive},
    );
    final data = response.data;
    if (data['success'] == true) {
      return UserProfileInfo.fromJson(data['user'] as Map<String, dynamic>);
    } else {
      throw Exception(data['message'] ?? 'Failed to update user status.');
    }
  }
}

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(ref.watch(dioProvider));
});
